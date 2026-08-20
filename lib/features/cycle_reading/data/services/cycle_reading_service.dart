import 'package:intl/intl.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/content/content_locale.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/repositories/free_writing_repository.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../models/cycle_reading_model.dart';
import '../repositories/cycle_reading_repository.dart';
import 'cycle_reading_composer.dart';

/// Strings do idioma atual sem BuildContext (mesmo padrão dos serviços que
/// "assam" texto no salvamento).
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

/// As 7 seções do relatório, na ordem do brainstorm. Chaves invariantes —
/// os prompts de cada idioma as reconhecem em
/// `AiPrompts.cycleReadingSectionInstruction`.
abstract final class CycleReadingSections {
  static const portrait = 'portrait';
  static const threads = 'threads';
  static const sky = 'sky';
  static const practice = 'practice';
  static const rituals = 'rituals';
  static const affirmation = 'affirmation';
  static const seal = 'seal';

  /// A Leitura da Lunação: o produto completo, as 7 seções.
  static const ordered = [
    portrait,
    threads,
    sky,
    practice,
    rituals,
    affirmation,
    seal,
  ];

  /// A Leitura da Semana: mais direta (4 seções). O que fica de fora é o que
  /// só a lunação inteira sustenta — o balanço da prática, os rituais do
  /// próximo ciclo e o selo — e é essa diferença visível que justifica a
  /// diferença de preço.
  static const weekly = [portrait, threads, sky, affirmation];

  /// As seções de um [CycleReadingPeriodType].
  static List<String> forPeriod(String periodType) =>
      periodType == CycleReadingPeriodType.week ? weekly : ordered;
}

/// Gera o texto de UMA seção (injetável nos testes; produção usa a IA).
typedef CycleSectionGenerator = Future<String> Function(
  String sectionKey,
  String materialJson,
);

/// O que a geração entrega: o crédito atualizado, o relatório salvo no
/// acervo e os dois conteúdos compartilháveis (afirmação e selo).
class CycleReadingResult {
  final CycleReadingModel reading;
  final FreeWritingModel writing;
  final String affirmation;
  final List<String> sealKeywords;

  const CycleReadingResult({
    required this.reading,
    required this.writing,
    required this.affirmation,
    required this.sealKeywords,
  });
}

/// Orquestra a Leitura do Ciclo: agrega o período, gera seção a seção
/// (chamadas curtas — ver [AIService.generateCycleReadingSection]), salva o
/// relatório no acervo e SÓ ENTÃO consome o crédito da compra.
class CycleReadingService {
  CycleReadingService({
    CycleReadingComposer? composer,
    CycleReadingRepository? repository,
    FreeWritingRepository? writings,
    CycleSectionGenerator? generateSection,
  })  : _composer = composer ?? CycleReadingComposer(),
        _repository = repository ?? CycleReadingRepository(),
        _writings = writings ?? FreeWritingRepository(),
        _generateSection = generateSection;

  final CycleReadingComposer _composer;
  final CycleReadingRepository _repository;
  final FreeWritingRepository _writings;
  final CycleSectionGenerator? _generateSection;

  CycleReadingComposer get composer => _composer;
  CycleReadingRepository get repository => _repository;

  /// A lunação corrente: da última lua nova à próxima.
  static ({DateTime start, DateTime end}) currentLunation({DateTime? now}) {
    final reference = now ?? DateTime.now();
    return (
      start: LunarProvider.lunationStartOf(reference),
      end: LunarProvider.lunationEndOf(reference),
    );
  }

  /// A semana corrente: os últimos 7 dias, hoje incluído. O fim é a meia-
  /// noite de amanhã para o dia de hoje entrar inteiro (as consultas usam
  /// `>= start AND < end`).
  static ({DateTime start, DateTime end}) currentWeek({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    return (
      start: today.subtract(const Duration(days: 6)),
      end: today.add(const Duration(days: 1)),
    );
  }

  /// A janela de um [CycleReadingPeriodType].
  static ({DateTime start, DateTime end}) periodFor(
    String periodType, {
    DateTime? now,
  }) =>
      periodType == CycleReadingPeriodType.week
          ? currentWeek(now: now)
          : currentLunation(now: now);

  // ===== Período customizado e cooldown (regras da dona) =====

  /// Teto de um período escolhido a dedo: 31 dias, porque há meses de 31 —
  /// acima disso não é mais "um ciclo", é um histórico.
  static const int maxCustomPeriodDays = 31;

  /// Dias INCLUSIVOS de uma janela `>= start AND < end` (end exclusivo):
  /// 14/08 00h → 21/08 00h são 7 dias vividos.
  static int spanInDays(DateTime start, DateTime end) =>
      end.difference(start).inDays;

  /// Classifica um período escolhido a dedo: até 7 dias é produto SEMANAL;
  /// de 8 a 31, MENSAL (lunação). Quem chama já validou o teto de 31.
  static String periodTypeForSpan(DateTime start, DateTime end) =>
      spanInDays(start, end) <= 7
          ? CycleReadingPeriodType.week
          : CycleReadingPeriodType.lunation;

  /// Intervalo mínimo entre duas leituras do MESMO tipo: uma semanal a cada
  /// 7 dias, uma mensal a cada 30.
  ///
  /// Vale SÓ para quem tem o acesso incluído (Vitalício): ali a leitura não
  /// custa nada por unidade, e sem ritmo o app viraria um gerador de textos
  /// sobre a mesma semana. Quem paga por leitura não é limitado — cada
  /// leitura já é uma compra, e limitar seria recusar dinheiro e autonomia.
  /// Ver [validateCustomPeriod] e o parâmetro `includedByLifetime`.
  static Duration cooldownFor(String periodType) =>
      periodType == CycleReadingPeriodType.week
          ? const Duration(days: 7)
          : const Duration(days: 30);

  /// Quando a próxima leitura deste tipo libera; null = já liberada.
  ///
  /// Âncora: `createdAt` da última leitura GERADA do tipo (o momento da
  /// compra/geração). Regenerar a mesma janela não reinicia a contagem —
  /// `copyWith` preserva o createdAt.
  Future<DateTime?> nextAllowedAt(
    String userId,
    String periodType, {
    DateTime? now,
  }) async {
    final latest = await _repository.latestGenerated(userId, periodType);
    if (latest == null) return null;
    final release = latest.createdAt.add(cooldownFor(periodType));
    return release.isAfter(now ?? DateTime.now()) ? release : null;
  }

  /// Por que um período escolhido a dedo foi recusado (null = aceito).
  ///
  /// Existe porque a tela precisa dizer O QUE fazer a respeito, e cada
  /// motivo pede uma frase diferente — um enum evita a tela adivinhar por
  /// mensagem de erro.
  static const rejectionEmpty = 'empty';
  static const rejectionTooLong = 'tooLong';
  static const rejectionFuture = 'future';
  static const rejectionOverlaps = 'overlaps';
  static const rejectionCooldown = 'cooldown';

  /// O veredito de um período escolhido a dedo.
  ///
  /// [periodType] sai da duração (ate 7 dias = semana; 8 a 31 = lunação) e
  /// só faz sentido quando [reason] é null. [releaseAt] acompanha a recusa
  /// por cooldown; [conflict] acompanha a recusa por sobreposição — as duas
  /// dão à tela o "quando" e o "com qual leitura".
  static ({
    String? reason,
    String periodType,
    DateTime? releaseAt,
    CycleReadingModel? conflict,
  }) _verdict(
    String? reason,
    String periodType, {
    DateTime? releaseAt,
    CycleReadingModel? conflict,
  }) =>
      (
        reason: reason,
        periodType: periodType,
        releaseAt: releaseAt,
        conflict: conflict,
      );

  /// Valida um período escolhido a dedo.
  ///
  /// Duas famílias de regra, com alcances diferentes:
  ///
  /// **Sempre** (é o que a leitura consegue fazer):
  /// 1. a janela é vazia ou invertida;
  /// 2. passa de [maxCustomPeriodDays] (31, porque há meses de 31);
  /// 3. avança no futuro — não se lê um ciclo que ainda não foi vivido.
  ///
  /// **Só com [includedByLifetime]** (é o ritmo do acesso incluído):
  /// 4. cruza um período JÁ LIDO;
  /// 5. o cooldown do tipo resultante ainda não venceu.
  ///
  /// Quem paga por leitura passa direto pelas duas últimas: pode comprar
  /// qualquer período, quantas vezes quiser, inclusive relendo um pedaço já
  /// lido. Cada leitura é uma compra — e o app não tem por que dizer não.
  ///
  /// A ordem importa: as três primeiras são do próprio pedido e não custam
  /// banco; as duas últimas consultam, e a de sobreposição vem antes porque
  /// é a mais específica ("este pedaço você já leu" ajuda mais que "espere").
  Future<({
    String? reason,
    String periodType,
    DateTime? releaseAt,
    CycleReadingModel? conflict,
  })> validateCustomPeriod({
    required String userId,
    required DateTime start,
    required DateTime end,
    bool includedByLifetime = false,
    DateTime? now,
  }) async {
    final tipo = periodTypeForSpan(start, end);
    final dias = spanInDays(start, end);
    if (dias <= 0) return _verdict(rejectionEmpty, tipo);
    if (dias > maxCustomPeriodDays) return _verdict(rejectionTooLong, tipo);

    final agora = now ?? DateTime.now();
    // `end` é exclusivo: uma janela que termina "amanhã 00h" cobre até hoje
    // e é legítima. Só recusa o que passa disso.
    final amanha = DateTime(agora.year, agora.month, agora.day)
        .add(const Duration(days: 1));
    if (end.isAfter(amanha)) return _verdict(rejectionFuture, tipo);

    // A partir daqui é ritmo do acesso incluído, não limite da leitura.
    if (!includedByLifetime) return _verdict(null, tipo);

    final conflito = await _repository.overlappingGenerated(userId, start, end);
    if (conflito != null) {
      return _verdict(rejectionOverlaps, tipo, conflict: conflito);
    }

    final liberaEm = await nextAllowedAt(userId, tipo, now: agora);
    if (liberaEm != null) {
      return _verdict(rejectionCooldown, tipo, releaseAt: liberaEm);
    }
    return _verdict(null, tipo);
  }

  /// O Vitalício cobre esta janela?
  ///
  /// Decisão de produto (reafirmada pela dona): o Vitalício cobre AS DUAS
  /// janelas — semana e lunação — sem cobrança extra. É o que dá peso à
  /// compra única, e vale para todo Vitalício: compra real, Código Premium
  /// e admin. Por isso quem chama gateia por `SubscriptionPlan.lifetime`
  /// (via AuthProvider), e não por `PaymentService.isLifetime`.
  static bool lifetimeCovers(String periodType) =>
      periodType == CycleReadingPeriodType.week ||
      periodType == CycleReadingPeriodType.lunation;

  /// Identidade do ciclo para o Motor de Ofertas (1 convite por lunação).
  static String lunationKey({DateTime? now}) {
    final start = currentLunation(now: now).start;
    return '${start.year.toString().padLeft(4, '0')}-'
        '${start.month.toString().padLeft(2, '0')}-'
        '${start.day.toString().padLeft(2, '0')}';
  }

  Future<String> _defaultGenerate(String sectionKey, String materialJson) =>
      AIService.instance.generateCycleReadingSection(
        sectionKey: sectionKey,
        materialJson: materialJson,
      );

  /// Gera (ou regenera) o relatório de um crédito já registrado.
  ///
  /// A ordem é deliberada: TODAS as seções geradas → relatório salvo no
  /// acervo → crédito marcado como consumido. Qualquer falha no meio deixa
  /// o crédito `pending` (ou o relatório anterior intacto, na regeneração)
  /// — tentar de novo nunca custa nova cobrança.
  Future<CycleReadingResult> generateForCredit({
    required CycleReadingModel credit,
    required String userId,
    CycleReadingSourceOptions options = const CycleReadingSourceOptions(),
    bool regenerate = false,
  }) async {
    if (regenerate && !credit.canRegenerate) {
      throw StateError('cycle reading: regeneration limit reached');
    }

    final material = await _composer.compose(
      userId: userId,
      start: credit.periodStart,
      end: credit.periodEnd,
      periodType: credit.periodType,
      options: options,
    );
    final materialJson = material.compactJson;
    final generate = _generateSection ?? _defaultGenerate;

    final sections = <String, String>{};
    for (final key in CycleReadingSections.forPeriod(credit.periodType)) {
      sections[key] = (await generate(key, materialJson)).trim();
    }

    final affirmation = _cleanAffirmation(
      sections[CycleReadingSections.affirmation] ?? '',
    );
    final sealKeywords = _parseSealKeywords(
      sections[CycleReadingSections.seal] ?? '',
    );

    final markdown = _assembleMarkdown(
      credit: credit,
      sections: sections,
      affirmation: affirmation,
      sealKeywords: sealKeywords,
    );
    final title = reportTitle(
      credit.periodStart,
      credit.periodEnd,
      periodType: credit.periodType,
    );

    FreeWritingModel writing;
    if (regenerate && credit.writingId != null) {
      // Regeneração da MESMA janela: substitui o conteúdo, mantém a entrada
      // (id estável no acervo e na nuvem).
      final existing = await _writings.getById(credit.writingId!);
      writing = existing?.copyWith(content: markdown) ??
          FreeWritingModel(
            id: credit.writingId,
            userId: userId,
            title: title,
            content: markdown,
            source: FreeWritingSource.cycleReading,
          );
      await _writings.insert(writing);
    } else {
      writing = FreeWritingModel(
        userId: userId,
        title: title,
        content: markdown,
        source: FreeWritingSource.cycleReading,
      );
      await _writings.insert(writing);
    }

    final updated = credit.copyWith(
      status: CycleReadingStatus.generated,
      writingId: writing.id,
      regenerationsUsed:
          regenerate ? credit.regenerationsUsed + 1 : credit.regenerationsUsed,
    );
    await _repository.update(updated);

    return CycleReadingResult(
      reading: updated,
      writing: writing,
      affirmation: affirmation,
      sealKeywords: sealKeywords,
    );
  }

  /// Título do relatório no acervo (e da página). O nome diz qual janela foi
  /// lida — o acervo guarda as duas lado a lado.
  static String reportTitle(
    DateTime start,
    DateTime end, {
    String periodType = CycleReadingPeriodType.lunation,
  }) {
    final format = DateFormat('dd/MM');
    return '${periodTitle(periodType)} — '
        '${format.format(start)}–${format.format(end)}';
  }

  /// Nome do produto conforme a janela ("Leitura da Semana"/"da Lunação").
  static String periodTitle(String periodType) =>
      periodType == CycleReadingPeriodType.week
          ? _l10n.cycleReadingWeekTitle
          : _l10n.cycleReadingLunationTitle;

  String _assembleMarkdown({
    required CycleReadingModel credit,
    required Map<String, String> sections,
    required String affirmation,
    required List<String> sealKeywords,
  }) {
    final l10n = _l10n;
    final format = DateFormat('dd/MM/yyyy');
    final periodLine = credit.isWeekly
        ? l10n.cycleReadingWeekPeriodLine(
            format.format(credit.periodStart),
            format.format(credit.periodEnd),
          )
        : l10n.cycleReadingPeriodLine(
            format.format(credit.periodStart),
            format.format(credit.periodEnd),
          );
    final buffer = StringBuffer()
      ..writeln('# ${periodTitle(credit.periodType)}')
      ..writeln()
      ..writeln('_${periodLine}_')
      ..writeln();

    void section(String heading, String body) {
      if (body.trim().isEmpty) return;
      buffer
        ..writeln('## $heading')
        ..writeln()
        ..writeln(body.trim())
        ..writeln();
    }

    section(l10n.cycleReadingSectionPortrait,
        sections[CycleReadingSections.portrait] ?? '');
    section(l10n.cycleReadingSectionThreads,
        sections[CycleReadingSections.threads] ?? '');
    section(
        l10n.cycleReadingSectionSky, sections[CycleReadingSections.sky] ?? '');
    section(l10n.cycleReadingSectionPractice,
        sections[CycleReadingSections.practice] ?? '');
    section(l10n.cycleReadingSectionRituals,
        sections[CycleReadingSections.rituals] ?? '');
    section(l10n.cycleReadingSectionAffirmation,
        affirmation.isEmpty ? '' : '> $affirmation');
    section(
      l10n.cycleReadingSectionSeal,
      sealKeywords.isEmpty ? '' : sealKeywords.map((k) => '**$k**').join(' · '),
    );

    return buffer.toString().trimRight();
  }

  /// Recupera a afirmação de um relatório já salvo (linha de citação `>`)
  /// — para reabrir os cartões compartilháveis sem regerar nada.
  static String? affirmationFromMarkdown(String markdown) {
    for (final line in markdown.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('> ')) {
        final text = trimmed.substring(2).trim();
        if (text.isNotEmpty) return text;
      }
    }
    return null;
  }

  /// Recupera as palavras-chave do selo de um relatório já salvo: a linha
  /// `**a** · **b** · **c**` da ÚLTIMA seção (o selo fecha o relatório —
  /// negritos de outras seções ficam de fora do recorte).
  static List<String> sealFromMarkdown(String markdown) {
    final lastHeading = markdown.lastIndexOf('\n## ');
    final tail =
        lastHeading == -1 ? markdown : markdown.substring(lastHeading);
    return RegExp(r'\*\*([^*]+)\*\*')
        .allMatches(tail)
        .map((m) => m.group(1)!.trim())
        .where((word) => word.isNotEmpty)
        .take(3)
        .toList();
  }

  /// A afirmação vem "crua" do modelo: remove aspas e fica com a primeira
  /// linha não vazia.
  static String _cleanAffirmation(String raw) {
    final line = raw
        .split('\n')
        .map((l) => l.trim())
        .firstWhere((l) => l.isNotEmpty, orElse: () => '');
    return line.replaceAll(RegExp('["“”«»]'), '').trim();
  }

  /// As 3 palavras-chave do selo, tolerante a vírgulas/linhas/marcadores.
  static List<String> _parseSealKeywords(String raw) {
    return raw
        .split(RegExp(r'[,\n;·•]'))
        .map((word) => word.replaceAll(RegExp(r'[*\-"“”]'), '').trim())
        .where((word) => word.isNotEmpty)
        .take(3)
        .toList();
  }
}
