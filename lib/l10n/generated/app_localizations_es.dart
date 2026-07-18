// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Grimorio de Bolsillo';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Sistema / portugués de Brasil';

  @override
  String get settingsLanguagePortuguese => 'Portugués (Brasil)';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String settingsLanguageChanged(String language) {
    return 'Idioma cambiado a $language';
  }

  @override
  String get homeTitle => 'Inicio';

  @override
  String get grimoireTitle => 'Grimorio';

  @override
  String get diaryTitle => 'Diario';

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authSignup => 'Crear cuenta';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get encyclopediaTitle => 'Enciclopedia';

  @override
  String get toolsTitle => 'Herramientas';

  @override
  String get errorsGeneric => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Ningún elemento',
    );
    return '$_temp0';
  }
}
