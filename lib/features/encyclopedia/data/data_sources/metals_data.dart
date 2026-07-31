import '../../../../core/content/content_locale.dart';
import '../models/metal_model.dart';
import 'metals_data_en.dart';
import 'metals_data_es.dart';
import 'metals_data_pt.dart';

/// Metais da enciclopédia no idioma atual do aplicativo.
List<MetalModel> get metalsData =>
    ContentLocale.instance.select(pt: metalsPt, en: metalsEn, es: metalsEs);
