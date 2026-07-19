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

  @override
  String get navEncyclopedia => 'Encyclopedia';

  @override
  String get navGrimoire => 'Grimoire';

  @override
  String get navDiaries => 'Diaries';

  @override
  String get grimoirePageTitle => 'Digital Grimoire';

  @override
  String get grimoireTabAstrology => 'Astrology';

  @override
  String get grimoireTabTools => 'Tools';

  @override
  String get grimoireTabMyGrimoire => 'My Grimoire';

  @override
  String get diaryPageTitle => 'Diaries';

  @override
  String get diaryTabGratitude => 'Gratitude';

  @override
  String get diaryTabAffirmations => 'Affirmations';

  @override
  String get diaryTabDreams => 'Dreams';

  @override
  String get diaryTabDesires => 'Desires';

  @override
  String get encyclopediaPageTitle => 'Magical Encyclopedia';

  @override
  String get encyTabMoon => 'Moon';

  @override
  String get encyTabSabbats => 'Sabbats';

  @override
  String get encyTabCrystals => 'Crystals';

  @override
  String get encyTabHerbs => 'Herbs';

  @override
  String get encyTabMetals => 'Metals';

  @override
  String get encyTabColors => 'Colors';

  @override
  String get encyTabGoddesses => 'Goddesses';

  @override
  String get encyTabElements => 'Elements';

  @override
  String get encyTabAltar => 'Altar';

  @override
  String get encyTabRunes => 'Runes';

  @override
  String get encyTabArchetypes => 'Archetypes';

  @override
  String get encyTabAngels => 'Angels';

  @override
  String get encyTabDemons => 'Demons';

  @override
  String get encyTabSymbols => 'Symbols';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonBack => 'Back';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get toolsHeaderTitle => 'Magical Tools';

  @override
  String get toolsHeaderSubtitle =>
      'Resources to support your magic and manifestation practices';

  @override
  String get toolMysticAdvisorTitle => 'Mystic Counselor';

  @override
  String get toolMysticAdvisorDesc =>
      'Ancestral wisdom for your witchcraft and magic questions';

  @override
  String get toolOracleTitle => 'Oracle Cards';

  @override
  String get toolOracleDesc => 'Messages and guidance from the universe';

  @override
  String get toolSigilsTitle => 'Sigils';

  @override
  String get toolSigilsDesc => 'Create magical symbols for your intentions';

  @override
  String get toolNumerologyTitle => 'Numerology';

  @override
  String get toolNumerologyDesc =>
      'Your key numbers, mirror hours and sequences';

  @override
  String get toolRunesTitle => 'Rune Reading';

  @override
  String get toolRunesDesc => 'Consult the ancient Norse runes';

  @override
  String get toolPendulumTitle => 'Pendulum';

  @override
  String get toolPendulumDesc => 'Yes or no questions';
}
