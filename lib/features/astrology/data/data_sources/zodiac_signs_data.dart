import '../../../../core/content/content_locale.dart';
import '../models/zodiac_sign_data.dart';
import 'zodiac_signs_data_en.dart';
import 'zodiac_signs_data_es.dart';
import 'zodiac_signs_data_pt.dart';

export '../models/zodiac_sign_data.dart' show ZodiacSignData;

/// Os 12 signos do zodíaco no idioma atual do aplicativo.
List<ZodiacSignData> get zodiacSignsData => ContentLocale.instance
    .select(pt: zodiacSignsPt, en: zodiacSignsEn, es: zodiacSignsEs);
