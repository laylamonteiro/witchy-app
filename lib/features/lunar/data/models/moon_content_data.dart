import '../../../../core/content/content_locale.dart';
import '../../../grimoire/data/models/spell_model.dart' show MoonPhase;
import 'moon_content_en.dart';
import 'moon_content_es.dart';
import 'moon_content_pt.dart';

/// Conhecimento de bruxaria de uma fase lunar.
typedef MoonPhaseKnowledge = ({String favors, List<String> goodFor});

/// Conteúdo dos esbats (celebrações da lua cheia).
typedef EsbatsContent = ({String what, String how});

/// Conhecimento de bruxaria da Lua — conteúdo da página "Lua" da
/// Enciclopédia. Trilíngue via ContentLocale (paridade em
/// test/moon_sun_content_parity_test.dart).
class MoonContent {
  const MoonContent._();

  /// "A Lua na bruxaria" — por que a Lua rege a prática mágica.
  static String get intro => ContentLocale.instance
      .select(pt: moonIntroPt, en: moonIntroEn, es: moonIntroEs);

  /// O que cada fase favorece nos trabalhos mágicos.
  static Map<MoonPhase, MoonPhaseKnowledge> get phaseKnowledge =>
      ContentLocale.instance.select(
          pt: moonPhaseKnowledgePt,
          en: moonPhaseKnowledgeEn,
          es: moonPhaseKnowledgeEs);

  /// Esbats: o que são e como celebrar.
  static EsbatsContent get esbats => ContentLocale.instance
      .select(pt: moonEsbatsPt, en: moonEsbatsEn, es: moonEsbatsEs);

  /// Correspondências lunares (rótulos que o resolveRelatedLink entende
  /// viram chips clicáveis; os demais ficam inertes).
  static List<String> get correspondences => ContentLocale.instance.select(
      pt: moonCorrespondencesPt,
      en: moonCorrespondencesEn,
      es: moonCorrespondencesEs);
}
