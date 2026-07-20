import '../../../../core/content/content_locale.dart';
import '../models/arcane_entry_model.dart';
import 'archetypes_data_en.dart';
import 'archetypes_data_es.dart';
import 'archetypes_data_pt.dart';

/// Arquétipos do caminho mágico no idioma atual do aplicativo.
List<ArcaneEntry> get archetypesData => ContentLocale.instance
    .select(pt: archetypesPt, en: archetypesEn, es: archetypesEs);
