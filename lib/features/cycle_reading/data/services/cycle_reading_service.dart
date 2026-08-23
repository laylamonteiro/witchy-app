import 'package:intl/intl.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/content/content_locale.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/repositories/free_writing_repository.dart';
import '../../../grimoire/data/models/spell_model.dart'
    show MoonPhaseExtension;
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../models/cycle_reading_model.dart';
import '../repositories/cycle_reading_repository.dart';
import 'cycle_reading_composer.dart';
import 'cycle_reading_draft_store.dart';

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

  /// "O ciclo em números": a seção DETERMINÍSTICA do relatório, calculada
  /// em Dart e montada por código. NÃO entra em [ordered] nem em [weekly]
  /// de propósito — essas listas guiam as CHAMADAS DE IA, e esta seção
  /// nunca vai à IA: ela recebe os mesmos números prontos no bloco
  /// "numbers" do material, só para citá-los sem recalcular.
  static const numbers = 'numbers';

  /// "O que se anuncia": a previsão do próximo ciclo. A IA a escreve, mas
  /// SÓ do campo skyAhead do material — fases, trânsitos, aspectos e
  /// sabbats da janela seguinte, todos calculados no aparelho — amarrados
  /// aos fios do período e à simbologia da bruxaria. Convite e preparo,
  /// nunca destino (a instrução da seção repete a regra).
  static const forecast = 'forecast';

  /// A Leitura da Lunação: o produto completo, as 8 seções.
  static const ordered = [
    portrait,
    threads,
    sky,
    practice,
    forecast,
    rituals,
    affirmation,
    seal,
  ];

  /// A Leitura da Semana: mais direta (5 seções). A previsão entra AQUI
  /// TAMBÉM (decisão da dona, 23/08: "é pra isso que o usuário vai pagar").
  /// O que fica de fora é o que só a lunação inteira sustenta — o balanço
  /// da prática, os rituais e o selo — e é essa diferença visível que
  /// justifica a diferença de preço.
  static const weekly = [portrait, threads, sky, forecast, affirmation];

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
    CycleReadingDraftStore drafts = const CycleReadingDraftStore(),
  })  : _composer = composer ?? CycleReadingComposer(),
        _repository = repository ?? CycleReadingRepository(),
        _writings = writings ?? FreeWritingRepository(),
        _generateSection = generateSection,
        _drafts = drafts;

  final CycleReadingComposer _composer;
  final CycleReadingRepository _repository;
  final FreeWritingRepository _writings;
  final CycleSectionGenerator? _generateSection;
  final CycleReadingDraftStore _drafts;

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

  /// A semana corrente: o giro completo, de um dia da semana ao MESMO dia
  /// na semana seguinte — segunda a segunda, hoje incluído. São 8 dias
  /// vividos (decisão da dona, 23/08: o ciclo semanal fecha no dia em que
  /// começou, não na véspera). O fim é a meia-noite de amanhã para o dia
  /// de hoje entrar inteiro (as consultas usam `>= start AND < end`).
  static ({DateTime start, DateTime end}) currentWeek({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    return (
      start: today.subtract(const Duration(days: 7)),
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

  // ===== Período customizado (regras da dona) =====

  /// Teto de um período escolhido a dedo: 31 dias, porque há meses de 31 —
  /// acima disso não é mais "um ciclo", é um histórico.
  static const int maxCustomPeriodDays = 31;

  /// Dias INCLUSIVOS de uma janela `>= start AND < end` (end exclusivo):
  /// 14/08 00h → 21/08 00h são 7 dias vividos.
  static int spanInDays(DateTime start, DateTime end) =>
      end.difference(start).inDays;

  /// O último dia VIVIDO de uma janela com fim exclusivo — o que as telas
  /// mostram. O `end` cru é a meia-noite do dia SEGUINTE ao último lido:
  /// estampá-lo dizia à pessoa que a leitura cobre um dia que não cobre.
  static DateTime lastDayOf(DateTime end) {
    final midnight = DateTime(end.year, end.month, end.day);
    return midnight == end
        ? midnight.subtract(const Duration(days: 1))
        : midnight;
  }

  /// Quando convidar de volta depois de uma leitura: uma semana ou uma
  /// lunação depois dela.
  ///
  /// NÃO é limite — não existe mais espera para ler de novo. É só o ritmo do
  /// lembrete ("passaram-se sete dias, o que seu grimório guardou?"), que
  /// nasce do tamanho do ciclo lido.
  static Duration inviteBackAfter(String periodType) =>
      periodType == CycleReadingPeriodType.week
          ? const Duration(days: 8)
          : const Duration(days: 30);

  /// Classifica um período escolhido a dedo: até 8 dias (o giro de segunda
  /// a segunda) é produto SEMANAL; de 9 a 31, MENSAL (lunação). Quem chama
  /// já validou o teto de 31.
  static String periodTypeForSpan(DateTime start, DateTime end) =>
      spanInDays(start, end) <= 8
          ? CycleReadingPeriodType.week
          : CycleReadingPeriodType.lunation;

  /// Por que um período escolhido a dedo foi recusado (null = aceito).
  ///
  /// Existe porque a tela precisa dizer O QUE fazer a respeito, e cada
  /// motivo pede uma frase diferente — um enum evita a tela adivinhar por
  /// mensagem de erro.
  static const rejectionEmpty = 'empty';
  static const rejectionTooLong = 'tooLong';
  static const rejectionFuture = 'future';

  /// O veredito de um período escolhido a dedo.
  ///
  /// [periodType] sai da duração (até 7 dias = semana; 8 a 31 = lunação) e
  /// só faz sentido quando [reason] é null. [conflict] é INFORMATIVO: traz a
  /// leitura já gerada que cruza a janela, para a tela poder avisar — nunca
  /// para barrar.
  static ({
    String? reason,
    String periodType,
    CycleReadingModel? conflict,
  }) _verdict(
    String? reason,
    String periodType, {
    CycleReadingModel? conflict,
  }) =>
      (
        reason: reason,
        periodType: periodType,
        conflict: conflict,
      );

  /// Valida um período escolhido a dedo.
  ///
  /// Recusa só o que a leitura não CONSEGUE fazer:
  /// 1. a janela é vazia ou invertida;
  /// 2. passa de [maxCustomPeriodDays] (31, porque há meses de 31);
  /// 3. avança no futuro — não se lê um ciclo que ainda não foi vivido.
  ///
  /// Não há mais ritmo nenhum: nem espera entre leituras, nem proibição de
  /// reler um pedaço. Quem paga por leitura nunca teve; quem tem o Vitalício
  /// (compra, Código Premium ou admin) passou a não ter também — decisão de
  /// produto: o acesso incluído é acesso, não uma assinatura racionada.
  ///
  /// Cruzar um período já lido continua sendo dito, em [conflict], porque é
  /// informação boa ("este pedaço você já leu") — mas quem decide é a pessoa.
  Future<({
    String? reason,
    String periodType,
    CycleReadingModel? conflict,
  })> validateCustomPeriod({
    required String userId,
    required DateTime start,
    required DateTime end,
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

    // Aceita — e, de quebra, conta se já existe leitura cruzando a janela.
    return _verdict(
      null,
      tipo,
      conflict: await _repository.overlappingGenerated(userId, start, end),
    );
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
  ///
  /// Cada seção pronta é guardada num rascunho ([CycleReadingDraftStore]):
  /// se a quinta chamada falhar, a próxima tentativa retoma da quinta em vez
  /// de refazer as quatro anteriores.
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
    final generate = _generateSection ?? _defaultGenerate;

    // Impressão digital do material: muda quando ela desliga uma fonte na
    // privacidade ou registra algo novo no período. Rascunho de material
    // diferente é descartado em vez de misturado.
    //
    // Tamanho + hash, e não só o hash: uma colisão faria seções escritas
    // com material diferente entrarem no mesmo relatório, e é barato
    // demais exigir que o tamanho também bata.
    final materialJson = material.compactJson;
    final fingerprint = '${materialJson.length}:${materialJson.hashCode}';
    if (regenerate) {
      // Regenerar é pedir um texto NOVO: reaproveitar o rascunho devolveria
      // exatamente o que ela quis trocar.
      await _drafts.clear(credit.id);
    }
    final sections = regenerate
        ? <String, String>{}
        : await _drafts.load(credit.id, fingerprint);

    for (final key in CycleReadingSections.forPeriod(credit.periodType)) {
      if (sections[key]?.isNotEmpty ?? false) continue;
      // Cada seção recebe só o material que ela usa (ver compactJsonFor).
      sections[key] = (await generate(
        key,
        material.compactJsonFor(key),
      )).trim();
      // Grava a cada seção: é o que permite retomar de onde parou.
      await _drafts.save(credit.id, fingerprint, sections);
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
      numeros: material.numbers,
    );
    final title = reportTitle(
      credit.periodStart,
      credit.periodEnd,
      periodType: credit.periodType,
    );

    FreeWritingModel writing;
    // Basta o crédito já apontar para uma entrada do acervo: ou é
    // regeneração, ou é uma leitura NOVA da mesma janela exata, que herdou o
    // registro anterior. Nos dois casos o certo é reescrever a entrada — sem
    // isto, o acervo ganharia uma segunda leitura do mesmo período.
    if (credit.writingId != null) {
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

    // Relatório salvo e crédito consumido: o rascunho cumpriu o papel.
    await _drafts.clear(credit.id);

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
        '${format.format(start)}–${format.format(lastDayOf(end))}';
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
    NumerosDoCiclo? numeros,
  }) {
    final l10n = _l10n;
    final format = DateFormat('dd/MM/yyyy');
    // O fim estampado é o último dia LIDO (ver [lastDayOf]) — o `end` cru é
    // exclusivo e apontaria um dia fora da leitura.
    final fim = format.format(lastDayOf(credit.periodEnd));
    final periodLine = credit.isWeekly
        ? l10n.cycleReadingWeekPeriodLine(
            format.format(credit.periodStart),
            fim,
          )
        : l10n.cycleReadingPeriodLine(
            format.format(credit.periodStart),
            fim,
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
    // Logo após o retrato: os números reais do período. É a âncora factual
    // do relatório — a pessoa lê a narrativa e, em seguida, o chão dela.
    // Montada por CÓDIGO, nunca por IA (ver [numbersSectionBody]).
    if (numeros != null) {
      section(l10n.cycleReadingSectionNumbers, numbersSectionBody(numeros));
    }
    section(l10n.cycleReadingSectionThreads,
        sections[CycleReadingSections.threads] ?? '');
    section(
        l10n.cycleReadingSectionSky, sections[CycleReadingSections.sky] ?? '');
    section(l10n.cycleReadingSectionPractice,
        sections[CycleReadingSections.practice] ?? '');
    // A previsão vem ANTES dos rituais de propósito: primeiro o que o céu
    // que vem anuncia, depois a prática que responde a ele.
    section(l10n.cycleReadingSectionForecast,
        sections[CycleReadingSections.forecast] ?? '');
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

  /// O corpo da seção "O ciclo em números" — montado por CÓDIGO, nunca por
  /// IA: são contagens reais, e número real não se pede a um modelo de
  /// linguagem. Linhas sem dado (período vazio → sem fase top, sem fonte,
  /// sem sequência) simplesmente não entram; o total e o período anterior
  /// ficam sempre, porque zero ali é informação verdadeira.
  static String numbersSectionBody(NumerosDoCiclo numeros) {
    final l10n = _l10n;
    final linhas = <String>[
      l10n.cycleNumbersRecords(
        numeros.totalRecords,
        numeros.activeDays,
        numeros.periodDays,
      ),
      if (numeros.topPhase != null)
        l10n.cycleNumbersTopPhase(
          numeros.topPhase!.displayName,
          numeros.topPhaseCount,
        ),
      if (numeros.topSource != null)
        l10n.cycleNumbersTopSource(
          _nomeDaFonte(numeros.topSource!),
          numeros.topSourceCount,
        ),
      if (numeros.longestStreak > 0)
        l10n.cycleNumbersStreak(numeros.longestStreak),
      l10n.cycleNumbersPrevious(numeros.previousPeriodRecords),
    ];
    // Lista Markdown: cada número em sua linha, com o marcador que o
    // renderizador das leituras já estiliza.
    return linhas.map((linha) => '- $linha').join('\n');
  }

  /// O nome de cada fonte é um SUBSTANTIVO próprio para frase ("Sonhos"),
  /// não o rótulo do desligamento da intro ("Usar meus sonhos") — reusar o
  /// rótulo deixava a linha torta: "Fonte mais presente: Usar meus sonhos".
  /// As famílias são as mesmas quatro dos desligamentos, só o nome muda.
  static String _nomeDaFonte(String source) {
    final l10n = _l10n;
    return switch (source) {
      NumerosDoCiclo.sourceDreams => l10n.cycleSourceDreams,
      NumerosDoCiclo.sourceJournals => l10n.cycleSourceJournals,
      NumerosDoCiclo.sourceDivination => l10n.cycleSourceDivination,
      _ => l10n.cycleSourcePractice,
    };
  }

  /// Recupera a afirmação de um relatório já salvo (linha de citação `>`)
  /// — para reabrir os cartões compartilháveis sem regerar nada.
  static String? affirmationFromMarkdown(String markdown) {
    for (final line in markdown.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('> ')) {
        // Leituras já salvas trazem o realce dentro da citação; aqui a
        // afirmação sai como frase, para o cartão e para o texto do
        // compartilhamento.
        final text = semRealce(trimmed.substring(2)).trim();
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
    return semRealce(line.replaceAll(RegExp('["“”«»]'), '')).trim();
  }

  /// Tira a marcação de realce (`**assim**`) de um texto que vai sair do
  /// app como texto puro.
  ///
  /// A afirmação é o caso: ela é uma frase, não um trecho de Markdown — vira
  /// imagem para compartilhar e legenda da imagem, e ali `**` não é realce,
  /// é sujeira na tela. O prompt pede o realce para os PARÁGRAFOS, e o
  /// modelo, obediente, marca a afirmação também.
  ///
  /// Não use isto no corpo do relatório: lá o `**` é lido pelo Markdown (e a
  /// seção das palavras-chave depende dele para ser recortada).
  static String semRealce(String texto) => texto.replaceAll('**', '');

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
