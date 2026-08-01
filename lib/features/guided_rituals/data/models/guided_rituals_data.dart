import '../../../grimoire/data/models/spell_model.dart';
import '../../../wheel_of_year/data/models/sabbat_model.dart';
import 'guided_ritual_model.dart';

/// Catálogo dos rituais guiados disponíveis no app.
/// Ids estáveis (payloads de notificação + `guided_ritual_logs`): não renomear.
class AllGuidedRituals {
  static const List<GuidedRitual> all = [
    // Sabbats (correspondências vêm da Roda do Ano)
    GuidedRitual(
      id: 'sabbat_samhain',
      event: GuidedRitualEvent.sabbat,
      sabbat: SabbatType.samhain,
      emoji: '🎃',
      suggestedSpellCategory: SpellCategory.divination,
    ),
    GuidedRitual(
      id: 'sabbat_yule',
      event: GuidedRitualEvent.sabbat,
      sabbat: SabbatType.yule,
      emoji: '❄️',
      suggestedSpellCategory: SpellCategory.home,
    ),
    GuidedRitual(
      id: 'sabbat_imbolc',
      event: GuidedRitualEvent.sabbat,
      sabbat: SabbatType.imbolc,
      emoji: '🕯️',
      suggestedSpellCategory: SpellCategory.cleansing,
    ),
    GuidedRitual(
      id: 'sabbat_ostara',
      event: GuidedRitualEvent.sabbat,
      sabbat: SabbatType.ostara,
      emoji: '🌸',
      suggestedSpellCategory: SpellCategory.creativity,
    ),
    GuidedRitual(
      id: 'sabbat_beltane',
      event: GuidedRitualEvent.sabbat,
      sabbat: SabbatType.beltane,
      emoji: '🔥',
      suggestedSpellCategory: SpellCategory.love,
    ),
    GuidedRitual(
      id: 'sabbat_litha',
      event: GuidedRitualEvent.sabbat,
      sabbat: SabbatType.litha,
      emoji: '☀️',
      suggestedSpellCategory: SpellCategory.energy,
    ),
    GuidedRitual(
      id: 'sabbat_lammas',
      event: GuidedRitualEvent.sabbat,
      sabbat: SabbatType.lammas,
      emoji: '🌾',
      suggestedSpellCategory: SpellCategory.prosperity,
    ),
    GuidedRitual(
      id: 'sabbat_mabon',
      event: GuidedRitualEvent.sabbat,
      sabbat: SabbatType.mabon,
      emoji: '🍂',
      suggestedSpellCategory: SpellCategory.wisdom,
    ),

    // Fases da lua
    GuidedRitual(
      id: 'full_moon',
      event: GuidedRitualEvent.fullMoon,
      moonPhase: MoonPhase.fullMoon,
      emoji: '🌕',
      suggestedSpellCategory: SpellCategory.protection,
    ),
    GuidedRitual(
      id: 'new_moon',
      event: GuidedRitualEvent.newMoon,
      moonPhase: MoonPhase.newMoon,
      emoji: '🌑',
      suggestedSpellCategory: SpellCategory.prosperity,
    ),

    // Águas mágicas
    GuidedRitual(
      id: 'moon_water',
      event: GuidedRitualEvent.moonWater,
      moonPhase: MoonPhase.fullMoon,
      emoji: '🫙',
      suggestedSpellCategory: SpellCategory.cleansing,
    ),
    GuidedRitual(
      id: 'sun_water',
      event: GuidedRitualEvent.sunWater,
      emoji: '🌞',
      suggestedSpellCategory: SpellCategory.energy,
    ),
  ];

  static GuidedRitual? byId(String id) {
    for (final ritual in all) {
      if (ritual.id == id) return ritual;
    }
    return null;
  }

  static GuidedRitual forSabbat(SabbatType type) =>
      all.firstWhere((r) => r.sabbat == type);
}
