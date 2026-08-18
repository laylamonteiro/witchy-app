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

  static const ordered = [
    portrait,
    threads,
    sky,
    practice,
    rituals,
    affirmation,
    seal,
  ];
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

  /// A lunação corrente: da última lua nova à próxima (MVP: único período).
  static ({DateTime start, DateTime end}) currentLunation({DateTime? now}) {
    final reference = now ?? DateTime.now();
    return (
      start: LunarProvider.lunationStartOf(reference),
      end: LunarProvider.lunationEndOf(reference),
    );
  }

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
      options: options,
    );
    final materialJson = material.compactJson;
    final generate = _generateSection ?? _defaultGenerate;

    final sections = <String, String>{};
    for (final key in CycleReadingSections.ordered) {
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
    final title = reportTitle(credit.periodStart, credit.periodEnd);

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

  /// Título do relatório no acervo (e da página).
  static String reportTitle(DateTime start, DateTime end) {
    final format = DateFormat('dd/MM');
    return '${_l10n.cycleReadingTitle} — '
        '${format.format(start)}–${format.format(end)}';
  }

  String _assembleMarkdown({
    required CycleReadingModel credit,
    required Map<String, String> sections,
    required String affirmation,
    required List<String> sealKeywords,
  }) {
    final l10n = _l10n;
    final format = DateFormat('dd/MM/yyyy');
    final buffer = StringBuffer()
      ..writeln('# ${l10n.cycleReadingTitle}')
      ..writeln()
      ..writeln('_${l10n.cycleReadingPeriodLine(
        format.format(credit.periodStart),
        format.format(credit.periodEnd),
      )}_')
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
