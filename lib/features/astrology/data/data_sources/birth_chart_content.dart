import '../../../../core/content/content_locale.dart';
import '../models/enums.dart';
import 'birth_chart_content_en.dart';
import 'birth_chart_content_es.dart';
import 'birth_chart_content_pt.dart';

/// Uma seção didática (título + corpo) das explicações do mapa astral.
class BirthChartSection {
  final String title;
  final String body;

  const BirthChartSection({required this.title, required this.body});
}

/// Conteúdo localizado da página do mapa astral (`BirthChartViewPage`).
///
/// Estruturado por chaves invariantes (ids estáveis em [ui], enum [Planet],
/// número de casa 1..12, enum [AspectType]) para que as três línguas tenham
/// exatamente a mesma forma — a paridade é verificada por
/// test/astrology_content_parity_test.dart.
class BirthChartContent {
  /// Rótulos e textos curtos da página, por id estável.
  final Map<String, String> ui;

  /// Significado curto exibido nas linhas de planeta (Trio Principal e
  /// Planetas Pessoais). O do Ascendente fica em `ui['ascendantMeaning']`
  /// porque Ascendente não é um valor de [Planet].
  final Map<Planet, String> planetRowMeanings;

  // Trio Principal (Sol, Lua, Ascendente)
  final List<BirthChartSection> trioSections;
  final BirthChartSection trioTip;

  // Planetas Pessoais (Mercúrio, Vênus, Marte)
  final String personalIntro;
  final List<BirthChartSection> personalSections;
  final BirthChartSection personalTip;

  // Planetas Sociais (Júpiter, Saturno)
  final String socialIntro;
  final List<BirthChartSection> socialSections;

  // Planetas Transpessoais (Urano, Netuno, Plutão)
  final String transpersonalIntro;
  final List<BirthChartSection> transpersonalSections;

  // Pontos Astrológicos (MC, IC, Dsc, Vx, Lilith, Fortuna, Nodos)
  final String pointsIntro;
  final List<BirthChartSection> pointsSections;

  // Casas Astrológicas
  final String housesIntro;
  final Map<int, String> houseMeanings; // 1..12
  final BirthChartSection housesTip;

  // Aspectos Principais
  final String aspectsIntro;
  final Map<AspectType, String> aspectTypeMeanings;
  final BirthChartSection aspectsTip;

  const BirthChartContent({
    required this.ui,
    required this.planetRowMeanings,
    required this.trioSections,
    required this.trioTip,
    required this.personalIntro,
    required this.personalSections,
    required this.personalTip,
    required this.socialIntro,
    required this.socialSections,
    required this.transpersonalIntro,
    required this.transpersonalSections,
    required this.pointsIntro,
    required this.pointsSections,
    required this.housesIntro,
    required this.houseMeanings,
    required this.housesTip,
    required this.aspectsIntro,
    required this.aspectTypeMeanings,
    required this.aspectsTip,
  });
}

/// Conteúdo da página do mapa astral no idioma atual do aplicativo.
BirthChartContent get birthChartContent => ContentLocale.instance.select(
      pt: birthChartContentPt,
      en: birthChartContentEn,
      es: birthChartContentEs,
    );
