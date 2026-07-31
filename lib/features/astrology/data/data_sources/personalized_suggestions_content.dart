import '../../../../core/content/content_locale.dart';
import '../models/enums.dart';
import 'personalized_suggestions_content_en.dart';
import 'personalized_suggestions_content_es.dart';
import 'personalized_suggestions_content_pt.dart';

/// Texto localizado de um planeta retrógrado (título, efeitos e dicas).
class RetrogradePlanetInfo {
  final String title;
  final String effects;
  final String tips;

  const RetrogradePlanetInfo({
    required this.title,
    required this.effects,
    required this.tips,
  });
}

/// Conteúdo localizado da página de sugestões personalizadas
/// (`PersonalizedSuggestionsPage`).
///
/// Estruturado por chaves invariantes (ids estáveis em [ui] e enum [Planet])
/// para que as três línguas tenham exatamente a mesma forma — a paridade é
/// verificada por test/astrology_content_parity_test.dart.
class PersonalizedSuggestionsContent {
  /// Rótulos e textos curtos da página, por id estável. Templates usam
  /// placeholders `{count}`, `{title}` e `{sign}`.
  final Map<String, String> ui;

  /// Efeitos e dicas por planeta retrógrado (Mercúrio..Plutão).
  final Map<Planet, RetrogradePlanetInfo> retrogradeInfo;

  const PersonalizedSuggestionsContent({
    required this.ui,
    required this.retrogradeInfo,
  });
}

/// Conteúdo da página de sugestões personalizadas no idioma atual do app.
PersonalizedSuggestionsContent get personalizedSuggestionsContent =>
    ContentLocale.instance.select(
      pt: personalizedSuggestionsContentPt,
      en: personalizedSuggestionsContentEn,
      es: personalizedSuggestionsContentEs,
    );
