import '../../../../core/content/content_locale.dart';
import '../models/crystal_model.dart';
import 'crystals_data_en.dart';
import 'crystals_data_es.dart';
import 'crystals_data_pt.dart';

/// Cristais da enciclopédia no idioma atual do aplicativo.
List<CrystalModel> get crystalsData => ContentLocale.instance
    .select(pt: crystalsPt, en: crystalsEn, es: crystalsEs);
