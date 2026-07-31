import '../../../../core/content/content_locale.dart';
import '../../../wheel_of_year/data/models/sabbat_model.dart' show SabbatType;
import 'sun_content_en.dart';
import 'sun_content_es.dart';
import 'sun_content_pt.dart';

/// Um sabbat solar (solstício/equinócio) com seu significado curto.
typedef SolarSabbat = ({SabbatType sabbat, String meaning});

/// Uma divindade solar com descrição curta.
typedef SolarDeity = ({String name, String description});

/// Conhecimento de bruxaria do Sol — conteúdo da página "Sol" da
/// Enciclopédia. Trilíngue via ContentLocale (paridade em
/// test/moon_sun_content_parity_test.dart).
class SunContent {
  const SunContent._();

  /// "O Sol na bruxaria" — a força diurna da prática mágica.
  static String get intro => ContentLocale.instance
      .select(pt: sunIntroPt, en: sunIntroEn, es: sunIntroEs);

  /// Os 4 sabbats solares (solstícios e equinócios).
  static List<SolarSabbat> get solarSabbats => ContentLocale.instance
      .select(pt: sunSabbatsPt, en: sunSabbatsEn, es: sunSabbatsEs);

  /// Correspondências solares (chips via resolveRelatedLink).
  static List<String> get correspondences => ContentLocale.instance.select(
      pt: sunCorrespondencesPt,
      en: sunCorrespondencesEn,
      es: sunCorrespondencesEs);

  /// Divindades solares pelas tradições.
  static List<SolarDeity> get solarDeities => ContentLocale.instance
      .select(pt: sunDeitiesPt, en: sunDeitiesEn, es: sunDeitiesEs);
}
