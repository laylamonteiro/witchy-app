import '../../../../core/content/content_locale.dart';
import '../models/spell_model.dart';
import 'spells_content_en.dart';
import 'spells_content_es.dart';

/// Overlay de tradução de um feitiço precarregado: apenas os campos textuais
/// visíveis ao usuário. Identidade (id), taxonomia (type/category/moonPhase),
/// duração e metadados nunca fazem parte do overlay.
class SpellContentOverlay {
  final String name;
  final String purpose;
  final List<String> ingredients;
  final String steps;
  final String? observations;

  const SpellContentOverlay({
    required this.name,
    required this.purpose,
    required this.ingredients,
    required this.steps,
    this.observations,
  });
}

/// Aplica, somente na camada de apresentação, a tradução dos feitiços
/// precarregados. A seed em `spells_data.dart` (e o que está no SQLite)
/// permanece sempre em português — os ids `preloaded_*` derivam do slug do
/// nome PT e o dedup do seed é por nome, então o conteúdo persistido nunca
/// pode ser traduzido.
class SpellLocalizer {
  SpellLocalizer._();

  /// Retorna uma cópia traduzida do feitiço quando ele é precarregado e há
  /// overlay para o idioma atual; caso contrário (feitiços do usuário, PT,
  /// ou id sem overlay) retorna o próprio [spell] inalterado.
  ///
  /// Importante: id, userId, type, category, moonPhase, duration,
  /// isPreloaded, createdAt, updatedAt e synced NUNCA mudam. Por isso o
  /// modelo é reconstruído diretamente em vez de usar `copyWith`, que
  /// redefine `updatedAt` para agora e `synced` para false.
  static SpellModel localize(SpellModel spell) {
    if (!spell.isPreloaded) return spell;

    final overlays = ContentLocale.instance.select<Map<String, SpellContentOverlay>>(
      pt: const {},
      en: spellOverlaysEn,
      es: spellOverlaysEs,
    );
    final overlay = overlays[spell.id];
    if (overlay == null) return spell;

    return SpellModel(
      id: spell.id,
      userId: spell.userId,
      name: overlay.name,
      purpose: overlay.purpose,
      type: spell.type,
      category: spell.category,
      moonPhase: spell.moonPhase,
      ingredients: overlay.ingredients,
      steps: overlay.steps,
      duration: spell.duration,
      observations: overlay.observations ?? spell.observations,
      isPreloaded: spell.isPreloaded,
      createdAt: spell.createdAt,
      updatedAt: spell.updatedAt,
      synced: spell.synced,
    );
  }
}
