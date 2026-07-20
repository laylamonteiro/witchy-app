import '../../../../core/content/content_locale.dart';
import '../models/goddess_model.dart';
import 'goddesses_data_en.dart';
import 'goddesses_data_es.dart';
import 'goddesses_data_pt.dart';

/// Deusas no idioma atual do aplicativo.
List<GoddessModel> get goddessesData => ContentLocale.instance
    .select(pt: goddessesPt, en: goddessesEn, es: goddessesEs);
