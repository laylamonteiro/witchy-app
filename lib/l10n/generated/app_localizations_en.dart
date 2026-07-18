// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pocket Grimoire';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSystem => 'System / Brazilian Portuguese';

  @override
  String get settingsLanguagePortuguese => 'Portuguese (Brazil)';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String settingsLanguageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get homeTitle => 'Home';

  @override
  String get grimoireTitle => 'Grimoire';

  @override
  String get diaryTitle => 'Diary';

  @override
  String get authLogin => 'Log in';

  @override
  String get authSignup => 'Sign up';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get encyclopediaTitle => 'Encyclopedia';

  @override
  String get toolsTitle => 'Tools';

  @override
  String get errorsGeneric => 'Something went wrong. Please try again.';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }
}
