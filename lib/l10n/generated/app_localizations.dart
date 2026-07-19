import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Grimório de Bolso'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema / português do Brasil'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguagePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português (Brasil)'**
  String get settingsLanguagePortuguese;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In pt, this message translates to:
  /// **'Inglês'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In pt, this message translates to:
  /// **'Espanhol'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageChanged.
  ///
  /// In pt, this message translates to:
  /// **'Idioma alterado para {language}'**
  String settingsLanguageChanged(String language);

  /// No description provided for @homeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get homeTitle;

  /// No description provided for @grimoireTitle.
  ///
  /// In pt, this message translates to:
  /// **'Grimório'**
  String get grimoireTitle;

  /// No description provided for @diaryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Diário'**
  String get diaryTitle;

  /// No description provided for @authLogin.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get authLogin;

  /// No description provided for @authSignup.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get authSignup;

  /// No description provided for @premiumTitle.
  ///
  /// In pt, this message translates to:
  /// **'Premium'**
  String get premiumTitle;

  /// No description provided for @encyclopediaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enciclopédia'**
  String get encyclopediaTitle;

  /// No description provided for @toolsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ferramentas'**
  String get toolsTitle;

  /// No description provided for @errorsGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado. Tente novamente.'**
  String get errorsGeneric;

  /// No description provided for @itemsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhum item} =1{1 item} other{{count} itens}}'**
  String itemsCount(int count);

  /// No description provided for @navEncyclopedia.
  ///
  /// In pt, this message translates to:
  /// **'Enciclopédia'**
  String get navEncyclopedia;

  /// No description provided for @navGrimoire.
  ///
  /// In pt, this message translates to:
  /// **'Grimório'**
  String get navGrimoire;

  /// No description provided for @navDiaries.
  ///
  /// In pt, this message translates to:
  /// **'Diários'**
  String get navDiaries;

  /// No description provided for @grimoirePageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Grimório Digital'**
  String get grimoirePageTitle;

  /// No description provided for @grimoireTabAstrology.
  ///
  /// In pt, this message translates to:
  /// **'Astrologia'**
  String get grimoireTabAstrology;

  /// No description provided for @grimoireTabTools.
  ///
  /// In pt, this message translates to:
  /// **'Ferramentas'**
  String get grimoireTabTools;

  /// No description provided for @grimoireTabMyGrimoire.
  ///
  /// In pt, this message translates to:
  /// **'Meu Grimório'**
  String get grimoireTabMyGrimoire;

  /// No description provided for @diaryPageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Diários'**
  String get diaryPageTitle;

  /// No description provided for @diaryTabGratitude.
  ///
  /// In pt, this message translates to:
  /// **'Gratidão'**
  String get diaryTabGratitude;

  /// No description provided for @diaryTabAffirmations.
  ///
  /// In pt, this message translates to:
  /// **'Afirmações'**
  String get diaryTabAffirmations;

  /// No description provided for @diaryTabDreams.
  ///
  /// In pt, this message translates to:
  /// **'Sonhos'**
  String get diaryTabDreams;

  /// No description provided for @diaryTabDesires.
  ///
  /// In pt, this message translates to:
  /// **'Desejos'**
  String get diaryTabDesires;

  /// No description provided for @encyclopediaPageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enciclopédia Mágica'**
  String get encyclopediaPageTitle;

  /// No description provided for @encyTabMoon.
  ///
  /// In pt, this message translates to:
  /// **'Lua'**
  String get encyTabMoon;

  /// No description provided for @encyTabSabbats.
  ///
  /// In pt, this message translates to:
  /// **'Sabbats'**
  String get encyTabSabbats;

  /// No description provided for @encyTabCrystals.
  ///
  /// In pt, this message translates to:
  /// **'Cristais'**
  String get encyTabCrystals;

  /// No description provided for @encyTabHerbs.
  ///
  /// In pt, this message translates to:
  /// **'Ervas'**
  String get encyTabHerbs;

  /// No description provided for @encyTabMetals.
  ///
  /// In pt, this message translates to:
  /// **'Metais'**
  String get encyTabMetals;

  /// No description provided for @encyTabColors.
  ///
  /// In pt, this message translates to:
  /// **'Cores'**
  String get encyTabColors;

  /// No description provided for @encyTabGoddesses.
  ///
  /// In pt, this message translates to:
  /// **'Deusas'**
  String get encyTabGoddesses;

  /// No description provided for @encyTabElements.
  ///
  /// In pt, this message translates to:
  /// **'Elementos'**
  String get encyTabElements;

  /// No description provided for @encyTabAltar.
  ///
  /// In pt, this message translates to:
  /// **'Altar'**
  String get encyTabAltar;

  /// No description provided for @encyTabRunes.
  ///
  /// In pt, this message translates to:
  /// **'Runas'**
  String get encyTabRunes;

  /// No description provided for @encyTabArchetypes.
  ///
  /// In pt, this message translates to:
  /// **'Arquétipos'**
  String get encyTabArchetypes;

  /// No description provided for @encyTabAngels.
  ///
  /// In pt, this message translates to:
  /// **'Anjos'**
  String get encyTabAngels;

  /// No description provided for @encyTabDemons.
  ///
  /// In pt, this message translates to:
  /// **'Demônios'**
  String get encyTabDemons;

  /// No description provided for @encyTabSymbols.
  ///
  /// In pt, this message translates to:
  /// **'Símbolos'**
  String get encyTabSymbols;

  /// No description provided for @commonSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get commonDelete;

  /// No description provided for @commonBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get commonBack;

  /// No description provided for @commonEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonSearch.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get commonSearch;

  /// No description provided for @commonConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @toolsHeaderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ferramentas Mágicas'**
  String get toolsHeaderTitle;

  /// No description provided for @toolsHeaderSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Recursos para auxiliar em suas práticas de magia e manifestação'**
  String get toolsHeaderSubtitle;

  /// No description provided for @toolMysticAdvisorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conselheiro Místico'**
  String get toolMysticAdvisorTitle;

  /// No description provided for @toolMysticAdvisorDesc.
  ///
  /// In pt, this message translates to:
  /// **'Sabedoria ancestral para suas dúvidas de bruxaria e magia'**
  String get toolMysticAdvisorDesc;

  /// No description provided for @toolOracleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cartas do Oráculo'**
  String get toolOracleTitle;

  /// No description provided for @toolOracleDesc.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens e orientação do universo'**
  String get toolOracleDesc;

  /// No description provided for @toolSigilsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sigilos'**
  String get toolSigilsTitle;

  /// No description provided for @toolSigilsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Crie símbolos mágicos para suas intenções'**
  String get toolSigilsDesc;

  /// No description provided for @toolNumerologyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Numerologia'**
  String get toolNumerologyTitle;

  /// No description provided for @toolNumerologyDesc.
  ///
  /// In pt, this message translates to:
  /// **'Seus números-chave, horas espelho e sequências'**
  String get toolNumerologyDesc;

  /// No description provided for @toolRunesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Leitura de Runas'**
  String get toolRunesTitle;

  /// No description provided for @toolRunesDesc.
  ///
  /// In pt, this message translates to:
  /// **'Consulte as antigas runas nórdicas'**
  String get toolRunesDesc;

  /// No description provided for @toolPendulumTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pêndulo'**
  String get toolPendulumTitle;

  /// No description provided for @toolPendulumDesc.
  ///
  /// In pt, this message translates to:
  /// **'Perguntas de sim ou não'**
  String get toolPendulumDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
