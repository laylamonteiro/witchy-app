import '../../../../core/content/content_locale.dart';
import '../models/dream_theme_model.dart';
import 'dream_themes_data_en.dart';
import 'dream_themes_data_es.dart';
import 'dream_themes_data_pt.dart';

// Reexporta o modelo para não quebrar imports existentes que acessavam
// `DreamTheme`/`DreamThemeReading` via este data source.
export '../models/dream_theme_model.dart';

/// Temas e simbolismos oníricos exibidos como cards na seção de
/// Interpretação de Sonhos, no idioma atual do aplicativo.
/// Conteúdo estático e gratuito.
List<DreamTheme> get dreamThemes => ContentLocale.instance
    .select(pt: dreamThemesPt, en: dreamThemesEn, es: dreamThemesEs);
