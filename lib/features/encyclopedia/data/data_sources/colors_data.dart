import '../../../../core/content/content_locale.dart';
import '../models/color_model.dart';
import 'colors_data_en.dart';
import 'colors_data_es.dart';
import 'colors_data_pt.dart';

/// Cores mágicas no idioma atual do aplicativo.
List<ColorModel> get colorsData =>
    ContentLocale.instance.select(pt: colorsPt, en: colorsEn, es: colorsEs);
