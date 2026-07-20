import '../../../../core/content/content_locale.dart';
import '../models/arcane_entry_model.dart';
import 'sacred_symbols_data_en.dart';
import 'sacred_symbols_data_es.dart';
import 'sacred_symbols_data_pt.dart';

/// Símbolos Sagrados da Bruxaria no idioma atual do aplicativo.
List<ArcaneEntry> get sacredSymbolsData => ContentLocale.instance
    .select(pt: sacredSymbolsPt, en: sacredSymbolsEn, es: sacredSymbolsEs);
