import '../../../../core/content/content_locale.dart';
import '../../../grimoire/data/models/spell_model.dart' show MoonPhase;
import 'moon_content_en.dart';
import 'moon_content_es.dart';
import 'moon_content_pt.dart';

/// Conhecimento de bruxaria de uma fase lunar.
typedef MoonPhaseKnowledge = ({String favors, List<String> goodFor});

/// Um elemento da celebração dos esbats (linha com emoji, no mesmo formato
/// dos sabbats solares da página do Sol).
typedef EsbatItem = ({String emoji, String title, String text});

/// Uma divindade lunar com descrição curta.
typedef LunarDeity = ({String name, String description});

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

  /// Esbats: o que são (introdução).
  static String get esbatsIntro => ContentLocale.instance.select(
      pt: moonEsbatsIntroPt, en: moonEsbatsIntroEn, es: moonEsbatsIntroEs);

  /// Esbats: os elementos da celebração (linhas com emoji).
  static List<EsbatItem> get esbatItems => ContentLocale.instance.select(
      pt: moonEsbatItemsPt, en: moonEsbatItemsEn, es: moonEsbatItemsEs);

  /// Divindades lunares pelas tradições.
  static List<LunarDeity> get lunarDeities => ContentLocale.instance
      .select(pt: moonDeitiesPt, en: moonDeitiesEn, es: moonDeitiesEs);

  /// Correspondências lunares (rótulos que o resolveRelatedLink entende
  /// viram chips clicáveis; os demais ficam inertes).
  static List<String> get correspondences => ContentLocale.instance.select(
      pt: moonCorrespondencesPt,
      en: moonCorrespondencesEn,
      es: moonCorrespondencesEs);
}
