import '../../../../core/content/content_locale.dart';
import '../models/affirmation_model.dart';
import 'affirmation_content_en.dart';
import 'affirmation_content_es.dart';

/// Overlay de exibição das afirmações pré-carregadas.
///
/// As 38 afirmações padrão são SEMEADAS no banco em PT (uma única vez, com
/// UUID) — o texto persistido é dado do usuário e nunca é reescrito. Este
/// localizador traduz apenas a EXIBIÇÃO das linhas `isPreloaded`, casando
/// pelo texto PT congelado; afirmações criadas pelo usuário passam intactas.
class AffirmationLocalizer {
  AffirmationLocalizer._();

  static AffirmationModel localize(AffirmationModel affirmation) {
    if (!affirmation.isPreloaded) return affirmation;
    final overlay = ContentLocale.instance.select<Map<String, String>>(
      pt: const {},
      en: affirmationOverlaysEn,
      es: affirmationOverlaysEs,
    )[affirmation.text];
    if (overlay == null) return affirmation;
    return affirmation.copyWith(text: overlay);
  }

  /// Texto PT canônico de um texto que foi persistido TRADUZIDO (bug antigo:
  /// favoritar gravava o texto de exibição no banco, congelando o idioma).
  /// Null = o texto já é o PT canônico (ou é da própria usuária).
  static String? canonicalPtFor(String text) {
    for (final overlay in [affirmationOverlaysEn, affirmationOverlaysEs]) {
      for (final entry in overlay.entries) {
        if (entry.value == text) return entry.key;
      }
    }
    return null;
  }
}
