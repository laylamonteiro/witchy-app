import '../../../../core/content/content_locale.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../wheel_of_year/data/models/sabbat_model.dart';
import 'guided_rituals_en.dart';
import 'guided_rituals_es.dart';
import 'guided_rituals_pt.dart';

/// Tipo de evento mágico que dispara um ritual guiado.
enum GuidedRitualEvent { sabbat, fullMoon, newMoon, moonWater, sunWater }

/// Texto principal de um ritual guiado, localizado por id.
typedef GuidedRitualText = ({String title, String intro, String timing});

/// Um passo do ritual guiado (título curto + instrução).
typedef RitualStepText = ({String title, String description});

/// Ritual guiado que o app propõe em datas mágicas (sabbats, luas) ou sob
/// demanda (água de lua/solar). Os ids são estáveis: viajam em payloads de
/// notificação e em `guided_ritual_logs.ritual_id` — não renomear.
class GuidedRitual {
  final String id;
  final GuidedRitualEvent event;
  final SabbatType? sabbat;
  final MoonPhase? moonPhase;
  final String emoji;
  final int xpReward;

  /// Categoria pré-selecionada no CTA "Criar feitiço" do Grimório.
  final SpellCategory suggestedSpellCategory;

  const GuidedRitual({
    required this.id,
    required this.event,
    this.sabbat,
    this.moonPhase,
    required this.emoji,
    this.xpReward = 40,
    required this.suggestedSpellCategory,
  });

  GuidedRitualText get _text => ContentLocale.instance.select(
      pt: guidedRitualTextsPt,
      en: guidedRitualTextsEn,
      es: guidedRitualTextsEs)[id]!;

  String get title => _text.title;
  String get intro => _text.intro;

  /// Quando realizar (ex.: "Na noite da lua cheia, antes do sol nascer").
  String get timing => _text.timing;

  List<RitualStepText> get steps => ContentLocale.instance.select(
      pt: guidedRitualStepsPt,
      en: guidedRitualStepsEn,
      es: guidedRitualStepsEs)[id]!;

  List<String> get materials =>
      ContentLocale.instance.select(
          pt: guidedRitualMaterialsPt,
          en: guidedRitualMaterialsEn,
          es: guidedRitualMaterialsEs)[id] ??
      const [];

  /// Usos após o ritual (água de lua/solar: beber, feitiços, plantas...).
  List<String> get usesAfter =>
      ContentLocale.instance.select(
          pt: guidedRitualUsesPt,
          en: guidedRitualUsesEn,
          es: guidedRitualUsesEs)[id] ??
      const [];

  // Correspondências: sabbats reusam o conteúdo da Roda do Ano; rituais de
  // lua/água têm listas próprias nos arquivos de conteúdo.
  List<String> get crystals =>
      sabbat?.crystals ??
      ContentLocale.instance.select(
          pt: guidedRitualCrystalsPt,
          en: guidedRitualCrystalsEn,
          es: guidedRitualCrystalsEs)[id] ??
      const [];

  List<String> get herbs =>
      sabbat?.herbs ??
      ContentLocale.instance.select(
          pt: guidedRitualHerbsPt,
          en: guidedRitualHerbsEn,
          es: guidedRitualHerbsEs)[id] ??
      const [];

  List<String> get colors => sabbat?.colors ?? const [];

  List<String> get foods => sabbat?.foods ?? const [];
}
