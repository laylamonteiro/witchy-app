import '../../../../core/content/content_locale.dart';
import 'sigil_content_en.dart';
import 'sigil_content_es.dart';
import 'sigil_content_pt.dart';

/// Passo de uso do sigilo pronto (título + descrição), exibido na etapa 3.
typedef SigilUsageStep = ({String title, String description});

/// Conteúdo estático da feature de Sigilos no idioma atual do aplicativo.
///
/// O conteúdo por idioma vive em `sigil_content_pt/en/es.dart`; esta classe
/// apenas seleciona a variante via [ContentLocale] (mesmo padrão de
/// `runes_data.dart`). Chrome de UI (títulos, botões, snackbars) continua
/// no l10n/ARB.
class SigilContent {
  SigilContent._();

  /// O que é um sigilo (card de introdução da etapa 1).
  static String get whatIsDescription => ContentLocale.instance.select(
        pt: sigilWhatIsDescPt,
        en: sigilWhatIsDescEn,
        es: sigilWhatIsDescEs,
      );

  /// Como o método funciona (introdução da etapa 1).
  static String get howIntro => ContentLocale.instance.select(
        pt: sigilHowIntroPt,
        en: sigilHowIntroEn,
        es: sigilHowIntroEs,
      );

  /// Sugestões de palavras de intenção (etapa 1).
  static List<String> get intentionExamples => ContentLocale.instance.select(
        pt: sigilIntentionExamplesPt,
        en: sigilIntentionExamplesEn,
        es: sigilIntentionExamplesEs,
      );

  /// Dica sobre a escolha da palavra de intenção (etapa 1).
  static String get wordTip => ContentLocale.instance.select(
        pt: sigilWordTipPt,
        en: sigilWordTipEn,
        es: sigilWordTipEs,
      );

  /// Introdução à explicação da simplificação das letras (etapa 2).
  static String get simplifiedIntro => ContentLocale.instance.select(
        pt: sigilSimplifiedIntroPt,
        en: sigilSimplifiedIntroEn,
        es: sigilSimplifiedIntroEs,
      );

  /// Descrição das etapas da técnica de simplificação (etapa 2).
  static List<String> get simplificationSteps => ContentLocale.instance.select(
        pt: sigilSimplificationStepsPt,
        en: sigilSimplificationStepsEn,
        es: sigilSimplificationStepsEs,
      );

  /// Nota sobre a Roda das Bruxas (etapa 2).
  static String get wheelNote => ContentLocale.instance.select(
        pt: sigilWheelNotePt,
        en: sigilWheelNoteEn,
        es: sigilWheelNoteEs,
      );

  /// Como usar o sigilo pronto (etapa 3).
  static List<SigilUsageStep> get usageSteps => ContentLocale.instance.select(
        pt: sigilUsageStepsPt,
        en: sigilUsageStepsEn,
        es: sigilUsageStepsEs,
      );

  /// Lembrete interpretativo final (etapa 3).
  static String get rememberNote => ContentLocale.instance.select(
        pt: sigilRememberNotePt,
        en: sigilRememberNoteEn,
        es: sigilRememberNoteEs,
      );
}
