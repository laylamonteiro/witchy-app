import '../../../../core/content/content_locale.dart';
import '../models/rune_model.dart';
import 'runes_data_en.dart';
import 'runes_data_es.dart';
import 'runes_data_pt.dart';

// Alias para RuneModel
typedef RuneModel = Rune;

/// Lista das 24 runas no idioma atual do aplicativo.
List<RuneModel> get runesData =>
    ContentLocale.instance.select(pt: runesPt, en: runesEn, es: runesEs);
