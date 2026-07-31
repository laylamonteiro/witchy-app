import '../../../../core/content/content_locale.dart';
import '../models/herb_model.dart';
import 'herbs_data_en.dart';
import 'herbs_data_es.dart';
import 'herbs_data_pt.dart';

/// Ervas da enciclopédia no idioma atual do aplicativo.
List<HerbModel> get herbsData =>
    ContentLocale.instance.select(pt: herbsPt, en: herbsEn, es: herbsEs);
