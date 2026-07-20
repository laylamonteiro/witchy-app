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

  /// No description provided for @toolLivingGrimoireTitle.
  ///
  /// In pt, this message translates to:
  /// **'Grimório Vivo'**
  String get toolLivingGrimoireTitle;

  /// No description provided for @toolLivingGrimoireDesc.
  ///
  /// In pt, this message translates to:
  /// **'Trilhas de aprendizado: cada lição vira uma página sua'**
  String get toolLivingGrimoireDesc;

  /// No description provided for @toolTarotTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tarot'**
  String get toolTarotTitle;

  /// No description provided for @toolTarotDesc.
  ///
  /// In pt, this message translates to:
  /// **'Tiragens, carta do dia e tutor de aprendizado'**
  String get toolTarotDesc;

  /// No description provided for @toolArchetypeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Teste de Arquétipo'**
  String get toolArchetypeTitle;

  /// No description provided for @toolArchetypeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Descubra qual arquétipo vibra mais alto em você'**
  String get toolArchetypeDesc;

  /// No description provided for @toolPalmistryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Leitura de Mãos'**
  String get toolPalmistryTitle;

  /// No description provided for @toolPalmistryDesc.
  ///
  /// In pt, this message translates to:
  /// **'Quiromancia pela palma da sua mão'**
  String get toolPalmistryDesc;

  /// No description provided for @commonClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get commonClose;

  /// No description provided for @premiumBePremium.
  ///
  /// In pt, this message translates to:
  /// **'Seja Premium'**
  String get premiumBePremium;

  /// No description provided for @premiumUnlock.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear Premium'**
  String get premiumUnlock;

  /// No description provided for @premiumContentLabel.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo Premium'**
  String get premiumContentLabel;

  /// No description provided for @premiumUpgradeAction.
  ///
  /// In pt, this message translates to:
  /// **'Upgrade'**
  String get premiumUpgradeAction;

  /// No description provided for @premiumPlansUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Os planos estão temporariamente indisponíveis'**
  String get premiumPlansUnavailable;

  /// No description provided for @premiumActivated.
  ///
  /// In pt, this message translates to:
  /// **'Premium ativado com sucesso!'**
  String get premiumActivated;

  /// No description provided for @premiumPurchaseFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir a compra'**
  String get premiumPurchaseFailed;

  /// No description provided for @premiumHeroAccess.
  ///
  /// In pt, this message translates to:
  /// **'ACESSE'**
  String get premiumHeroAccess;

  /// No description provided for @premiumHeroPower.
  ///
  /// In pt, this message translates to:
  /// **'TODO O PODER'**
  String get premiumHeroPower;

  /// No description provided for @premiumHeroMagic.
  ///
  /// In pt, this message translates to:
  /// **'DA SUA MAGIA'**
  String get premiumHeroMagic;

  /// No description provided for @premiumHeroTagline1.
  ///
  /// In pt, this message translates to:
  /// **'Mais conhecimento, mais orientação e mais '**
  String get premiumHeroTagline1;

  /// No description provided for @premiumHeroTaglineHighlight.
  ///
  /// In pt, this message translates to:
  /// **'conexão'**
  String get premiumHeroTaglineHighlight;

  /// No description provided for @premiumHeroTagline2.
  ///
  /// In pt, this message translates to:
  /// **' com o seu caminho'**
  String get premiumHeroTagline2;

  /// No description provided for @premiumCatSemantic.
  ///
  /// In pt, this message translates to:
  /// **'Gato mágico do Grimório de Bolso'**
  String get premiumCatSemantic;

  /// No description provided for @premiumBenefitAdvisor.
  ///
  /// In pt, this message translates to:
  /// **'Conselheiro Místico ilimitado'**
  String get premiumBenefitAdvisor;

  /// No description provided for @premiumBenefitEncyclopedia.
  ///
  /// In pt, this message translates to:
  /// **'Enciclopédia com conteúdos completos'**
  String get premiumBenefitEncyclopedia;

  /// No description provided for @premiumBenefitDailyClimate.
  ///
  /// In pt, this message translates to:
  /// **'Clima Mágico Diário personalizado'**
  String get premiumBenefitDailyClimate;

  /// No description provided for @premiumBenefitUnlimitedReadings.
  ///
  /// In pt, this message translates to:
  /// **'Leituras ilimitadas de Runas, Oráculo e Sigilos'**
  String get premiumBenefitUnlimitedReadings;

  /// No description provided for @premiumBenefitCloudSync.
  ///
  /// In pt, this message translates to:
  /// **'Sincronização entre dispositivos'**
  String get premiumBenefitCloudSync;

  /// No description provided for @premiumPlanMonthly.
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get premiumPlanMonthly;

  /// No description provided for @premiumPlanYearly.
  ///
  /// In pt, this message translates to:
  /// **'Anual'**
  String get premiumPlanYearly;

  /// No description provided for @premiumPerMonth.
  ///
  /// In pt, this message translates to:
  /// **'/mês'**
  String get premiumPerMonth;

  /// No description provided for @premiumPerYear.
  ///
  /// In pt, this message translates to:
  /// **'/ano'**
  String get premiumPerYear;

  /// No description provided for @premiumSave33.
  ///
  /// In pt, this message translates to:
  /// **'Economize 33%'**
  String get premiumSave33;

  /// No description provided for @premiumTagSelected.
  ///
  /// In pt, this message translates to:
  /// **'SELECIONADO'**
  String get premiumTagSelected;

  /// No description provided for @premiumTagPopular.
  ///
  /// In pt, this message translates to:
  /// **'POPULAR'**
  String get premiumTagPopular;

  /// No description provided for @premiumPlanSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Plano {title}, {price} {period}'**
  String premiumPlanSemantics(String title, String price, String period);

  /// No description provided for @premiumStartNow.
  ///
  /// In pt, this message translates to:
  /// **'Começar Agora'**
  String get premiumStartNow;

  /// No description provided for @premiumCancelAnytime.
  ///
  /// In pt, this message translates to:
  /// **'Cancele a qualquer momento'**
  String get premiumCancelAnytime;

  /// No description provided for @premiumSecurePayment.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento seguro'**
  String get premiumSecurePayment;

  /// No description provided for @premiumDataProtected.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados protegidos'**
  String get premiumDataProtected;

  /// No description provided for @authWelcomeBack.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vinda de volta!'**
  String get authWelcomeBack;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre para acessar seu grimório'**
  String get authLoginSubtitle;

  /// No description provided for @authForgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get authForgotPassword;

  /// No description provided for @authEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In pt, this message translates to:
  /// **'seu@email.com'**
  String get authEmailHint;

  /// No description provided for @authEmailRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, insira seu email'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, insira um email válido'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, insira sua senha'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter pelo menos 6 caracteres'**
  String get authPasswordMinLength;

  /// No description provided for @authOrContinueWith.
  ///
  /// In pt, this message translates to:
  /// **'ou continue com'**
  String get authOrContinueWith;

  /// No description provided for @authNoAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem uma conta? '**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get authCreateAccount;

  /// No description provided for @authSystemNotConfigured.
  ///
  /// In pt, this message translates to:
  /// **'Sistema de autenticação não configurado. Entre em contato com o suporte.'**
  String get authSystemNotConfigured;

  /// No description provided for @authLoginError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao fazer login'**
  String get authLoginError;

  /// No description provided for @authSocialUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Login social não disponível no momento'**
  String get authSocialUnavailable;

  /// No description provided for @authGoogleError.
  ///
  /// In pt, this message translates to:
  /// **'Erro no login com Google'**
  String get authGoogleError;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Inicie sua jornada mágica'**
  String get authSignupSubtitle;

  /// No description provided for @authNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get authNameLabel;

  /// No description provided for @authNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Seu nome mágico'**
  String get authNameHint;

  /// No description provided for @authNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, insira seu nome'**
  String get authNameRequired;

  /// No description provided for @authNameMinLength.
  ///
  /// In pt, this message translates to:
  /// **'O nome deve ter pelo menos 2 caracteres'**
  String get authNameMinLength;

  /// No description provided for @authPasswordHintMin.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get authPasswordHintMin;

  /// No description provided for @authPasswordCreateRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, insira uma senha'**
  String get authPasswordCreateRequired;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Senha'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite a senha novamente'**
  String get authConfirmPasswordHint;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, confirme sua senha'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authPasswordsDontMatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não coincidem'**
  String get authPasswordsDontMatch;

  /// No description provided for @authTermsPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Li e aceito os '**
  String get authTermsPrefix;

  /// No description provided for @authTermsOfUse.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Uso'**
  String get authTermsOfUse;

  /// No description provided for @authTermsAnd.
  ///
  /// In pt, this message translates to:
  /// **' e a '**
  String get authTermsAnd;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get authPrivacyPolicy;

  /// No description provided for @authOrSignupWith.
  ///
  /// In pt, this message translates to:
  /// **'ou cadastre-se com'**
  String get authOrSignupWith;

  /// No description provided for @authHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tem uma conta? '**
  String get authHaveAccount;

  /// No description provided for @authMustAcceptTerms.
  ///
  /// In pt, this message translates to:
  /// **'Você precisa aceitar os termos de uso'**
  String get authMustAcceptTerms;

  /// No description provided for @authSignupError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao criar conta'**
  String get authSignupError;

  /// No description provided for @authEmailInUse.
  ///
  /// In pt, this message translates to:
  /// **'Este email já está em uso'**
  String get authEmailInUse;

  /// No description provided for @authEmailInvalidShort.
  ///
  /// In pt, this message translates to:
  /// **'Email inválido'**
  String get authEmailInvalidShort;

  /// No description provided for @authSignupSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Conta criada com sucesso! Bem-vinda ao Grimório!'**
  String get authSignupSuccess;

  /// No description provided for @authGoogleSignupUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro com Google não disponível no momento'**
  String get authGoogleSignupUnavailable;

  /// No description provided for @authGoogleSignupError.
  ///
  /// In pt, this message translates to:
  /// **'Erro no cadastro com Google'**
  String get authGoogleSignupError;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua jornada mágica começa aqui'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeFeatureLunar.
  ///
  /// In pt, this message translates to:
  /// **'Calendário Lunar'**
  String get welcomeFeatureLunar;

  /// No description provided for @welcomeFeatureGrimoire.
  ///
  /// In pt, this message translates to:
  /// **'Grimório Digital'**
  String get welcomeFeatureGrimoire;

  /// No description provided for @welcomeFeatureDiaries.
  ///
  /// In pt, this message translates to:
  /// **'Diários Mágicos'**
  String get welcomeFeatureDiaries;

  /// No description provided for @welcomeFeatureAstrology.
  ///
  /// In pt, this message translates to:
  /// **'Astrologia'**
  String get welcomeFeatureAstrology;

  /// No description provided for @welcomeHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho conta'**
  String get welcomeHaveAccount;

  /// No description provided for @forgotEmailSent.
  ///
  /// In pt, this message translates to:
  /// **'Email Enviado!'**
  String get forgotEmailSent;

  /// No description provided for @forgotEmailSentTo.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um link de recuperação para\n{email}'**
  String forgotEmailSentTo(String email);

  /// No description provided for @forgotCheckInbox.
  ///
  /// In pt, this message translates to:
  /// **'Verifique sua caixa de entrada e spam.'**
  String get forgotCheckInbox;

  /// No description provided for @forgotBackToLogin.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao Login'**
  String get forgotBackToLogin;

  /// No description provided for @forgotResend.
  ///
  /// In pt, this message translates to:
  /// **'Não recebeu? Enviar novamente'**
  String get forgotResend;

  /// No description provided for @forgotTitle.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a senha?'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem problemas! Digite seu email e enviaremos um link para criar uma nova senha.'**
  String get forgotSubtitle;

  /// No description provided for @forgotSendLink.
  ///
  /// In pt, this message translates to:
  /// **'Enviar Link de Recuperação'**
  String get forgotSendLink;

  /// No description provided for @forgotRemembered.
  ///
  /// In pt, this message translates to:
  /// **'Lembrou a senha? '**
  String get forgotRemembered;

  /// No description provided for @forgotBackToLoginLower.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao login'**
  String get forgotBackToLoginLower;

  /// No description provided for @forgotSendError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao enviar email'**
  String get forgotSendError;

  /// No description provided for @forgotResendError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao reenviar email'**
  String get forgotResendError;

  /// No description provided for @forgotResendSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Email reenviado com sucesso!'**
  String get forgotResendSuccess;

  /// No description provided for @forgotResendErrorPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao reenviar'**
  String get forgotResendErrorPrefix;

  /// No description provided for @changePasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Alterar Senha'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordHeader.
  ///
  /// In pt, this message translates to:
  /// **'Nova Senha'**
  String get changePasswordHeader;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Digite sua senha atual e escolha uma nova senha'**
  String get changePasswordSubtitle;

  /// No description provided for @changePasswordCurrentLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha Atual'**
  String get changePasswordCurrentLabel;

  /// No description provided for @changePasswordCurrentRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, insira sua senha atual'**
  String get changePasswordCurrentRequired;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nova Senha'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordNewRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, insira uma nova senha'**
  String get changePasswordNewRequired;

  /// No description provided for @changePasswordMustDiffer.
  ///
  /// In pt, this message translates to:
  /// **'A nova senha deve ser diferente da atual'**
  String get changePasswordMustDiffer;

  /// No description provided for @changePasswordConfirmLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Nova Senha'**
  String get changePasswordConfirmLabel;

  /// No description provided for @changePasswordConfirmHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite a nova senha novamente'**
  String get changePasswordConfirmHint;

  /// No description provided for @changePasswordConfirmRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, confirme sua nova senha'**
  String get changePasswordConfirmRequired;

  /// No description provided for @changePasswordError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao alterar senha'**
  String get changePasswordError;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Senha alterada com sucesso!'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordWrongCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Senha atual incorreta'**
  String get changePasswordWrongCurrent;

  /// No description provided for @onbSlide1Title.
  ///
  /// In pt, this message translates to:
  /// **'Seu Grimório Digital'**
  String get onbSlide1Title;

  /// No description provided for @onbSlide1Desc.
  ///
  /// In pt, this message translates to:
  /// **'Guarde seus feitiços, rituais e receitas mágicas em um só lugar. Organize por fase lunar, ingredientes e muito mais.'**
  String get onbSlide1Desc;

  /// No description provided for @onbSlide2Title.
  ///
  /// In pt, this message translates to:
  /// **'Calendário Lunar'**
  String get onbSlide2Title;

  /// No description provided for @onbSlide2Desc.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe as fases da lua e descubra o melhor momento para cada tipo de magia. Receba notificações em luas cheias e novas.'**
  String get onbSlide2Desc;

  /// No description provided for @onbSlide3Title.
  ///
  /// In pt, this message translates to:
  /// **'Diários Mágicos'**
  String get onbSlide3Title;

  /// No description provided for @onbSlide3Desc.
  ///
  /// In pt, this message translates to:
  /// **'Registre sonhos, desejos, gratidão e afirmações. Acompanhe sua evolução espiritual dia após dia.'**
  String get onbSlide3Desc;

  /// No description provided for @onbSlide4Title.
  ///
  /// In pt, this message translates to:
  /// **'Astrologia Completa'**
  String get onbSlide4Title;

  /// No description provided for @onbSlide4Desc.
  ///
  /// In pt, this message translates to:
  /// **'Descubra seu mapa astral, perfil mágico personalizado e receba previsões diárias baseadas nos trânsitos planetários.'**
  String get onbSlide4Desc;

  /// No description provided for @onbSlide5Title.
  ///
  /// In pt, this message translates to:
  /// **'Pronta para Começar?'**
  String get onbSlide5Title;

  /// No description provided for @onbSlide5Desc.
  ///
  /// In pt, this message translates to:
  /// **'Crie sua conta para sincronizar seus dados em todos os dispositivos e ter acesso completo às funcionalidades.'**
  String get onbSlide5Desc;

  /// No description provided for @onbSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get onbSkip;

  /// No description provided for @onbHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho uma conta'**
  String get onbHaveAccount;

  /// No description provided for @onbNext.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get onbNext;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meu Perfil'**
  String get profileTitle;

  /// No description provided for @profileAnonymous.
  ///
  /// In pt, this message translates to:
  /// **'Bruxa Anônima'**
  String get profileAnonymous;

  /// No description provided for @profileEditName.
  ///
  /// In pt, this message translates to:
  /// **'Editar Nome'**
  String get profileEditName;

  /// No description provided for @profileFreePlan.
  ///
  /// In pt, this message translates to:
  /// **'Plano Gratuito'**
  String get profileFreePlan;

  /// No description provided for @profilePremiumPlan.
  ///
  /// In pt, this message translates to:
  /// **'Plano Premium'**
  String get profilePremiumPlan;

  /// No description provided for @profileFreePlanDesc.
  ///
  /// In pt, this message translates to:
  /// **'Algumas funcionalidades são limitadas'**
  String get profileFreePlanDesc;

  /// No description provided for @profilePremiumPlanDesc.
  ///
  /// In pt, this message translates to:
  /// **'Acesso completo a todas as funcionalidades'**
  String get profilePremiumPlanDesc;

  /// No description provided for @profileUpgrade.
  ///
  /// In pt, this message translates to:
  /// **'Fazer Upgrade'**
  String get profileUpgrade;

  /// No description provided for @profileFreeUsage.
  ///
  /// In pt, this message translates to:
  /// **'Uso do Plano Gratuito'**
  String get profileFreeUsage;

  /// No description provided for @profileSpells.
  ///
  /// In pt, this message translates to:
  /// **'Feitiços'**
  String get profileSpells;

  /// No description provided for @profileDiaryEntries.
  ///
  /// In pt, this message translates to:
  /// **'Entradas de Diário'**
  String get profileDiaryEntries;

  /// No description provided for @profileThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'este mês'**
  String get profileThisMonth;

  /// No description provided for @profileMysticAdvisor.
  ///
  /// In pt, this message translates to:
  /// **'Conselheiro Místico'**
  String get profileMysticAdvisor;

  /// No description provided for @profileToday.
  ///
  /// In pt, this message translates to:
  /// **'hoje'**
  String get profileToday;

  /// No description provided for @profileEditProfile.
  ///
  /// In pt, this message translates to:
  /// **'Editar Perfil'**
  String get profileEditProfile;

  /// No description provided for @profileManageSubscription.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar Assinatura'**
  String get profileManageSubscription;

  /// No description provided for @profileMagicalStats.
  ///
  /// In pt, this message translates to:
  /// **'Estatísticas Mágicas'**
  String get profileMagicalStats;

  /// No description provided for @profileMagicalJourneys.
  ///
  /// In pt, this message translates to:
  /// **'Jornadas Mágicas'**
  String get profileMagicalJourneys;

  /// No description provided for @profileNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get profileNotifications;

  /// No description provided for @profileHelpSupport.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda & Suporte'**
  String get profileHelpSupport;

  /// No description provided for @profileAboutApp.
  ///
  /// In pt, this message translates to:
  /// **'Sobre o App'**
  String get profileAboutApp;

  /// No description provided for @profileLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair da Conta'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja sair?\nSeus dados locais serão mantidos.'**
  String get profileLogoutConfirm;

  /// No description provided for @profileLogoutAction.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get profileLogoutAction;

  /// No description provided for @profileNotificationsSoon.
  ///
  /// In pt, this message translates to:
  /// **'As configurações de notificações estarão disponíveis em breve!\n\nVocê poderá personalizar alertas para:\n• Lembretes de rituais\n• Fases da lua\n• Datas mágicas especiais'**
  String get profileNotificationsSoon;

  /// No description provided for @profileSupportEmail.
  ///
  /// In pt, this message translates to:
  /// **'Email de Suporte'**
  String get profileSupportEmail;

  /// No description provided for @profileFaq.
  ///
  /// In pt, this message translates to:
  /// **'Perguntas frequentes'**
  String get profileFaq;

  /// No description provided for @profilePrivacySafe.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados estão seguros'**
  String get profilePrivacySafe;

  /// No description provided for @aboutVersion.
  ///
  /// In pt, this message translates to:
  /// **'Versão {version} ({build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutDescription.
  ///
  /// In pt, this message translates to:
  /// **'Seu companheiro para práticas mágicas, rituais e autoconhecimento através da astrologia e bruxaria moderna.'**
  String get aboutDescription;

  /// No description provided for @aboutMadeWith.
  ///
  /// In pt, this message translates to:
  /// **'Desenvolvido com 🔮 e ✨'**
  String get aboutMadeWith;

  /// No description provided for @editBasicInfo.
  ///
  /// In pt, this message translates to:
  /// **'Informações Básicas'**
  String get editBasicInfo;

  /// No description provided for @editNameUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Nome atualizado!'**
  String get editNameUpdated;

  /// No description provided for @editGenderSection.
  ///
  /// In pt, this message translates to:
  /// **'Gênero'**
  String get editGenderSection;

  /// No description provided for @editGenderHelp.
  ///
  /// In pt, this message translates to:
  /// **'Como o app deve se dirigir a você? Usamos essa escolha nos textos personalizados e nas respostas do Conselheiro Místico.'**
  String get editGenderHelp;

  /// No description provided for @editSecurity.
  ///
  /// In pt, this message translates to:
  /// **'Segurança'**
  String get editSecurity;

  /// No description provided for @editChangePasswordSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Modificar sua senha de acesso'**
  String get editChangePasswordSubtitle;

  /// No description provided for @editDataCollection.
  ///
  /// In pt, this message translates to:
  /// **'Coleta de Dados'**
  String get editDataCollection;

  /// No description provided for @editAnalytics.
  ///
  /// In pt, this message translates to:
  /// **'Analytics'**
  String get editAnalytics;

  /// No description provided for @editAnalyticsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajude a melhorar o app compartilhando dados de uso anônimos'**
  String get editAnalyticsSubtitle;

  /// No description provided for @editCrashReports.
  ///
  /// In pt, this message translates to:
  /// **'Relatórios de Erro'**
  String get editCrashReports;

  /// No description provided for @editCrashReportsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviar relatórios automáticos quando o app tiver problemas'**
  String get editCrashReportsSubtitle;

  /// No description provided for @editPersonalizedContent.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo Personalizado'**
  String get editPersonalizedContent;

  /// No description provided for @editPersonalizedContentSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Receber sugestões baseadas no seu uso do app'**
  String get editPersonalizedContentSubtitle;

  /// No description provided for @editSyncBackup.
  ///
  /// In pt, this message translates to:
  /// **'Sincronização e Backup'**
  String get editSyncBackup;

  /// No description provided for @editSyncBackupCloud.
  ///
  /// In pt, this message translates to:
  /// **'Sincronização e Backup na Nuvem'**
  String get editSyncBackupCloud;

  /// No description provided for @editSyncBackupOn.
  ///
  /// In pt, this message translates to:
  /// **'Manter seus dados protegidos e sincronizados entre dispositivos'**
  String get editSyncBackupOn;

  /// No description provided for @editSyncPremiumOnly.
  ///
  /// In pt, this message translates to:
  /// **'Recurso exclusivo Premium'**
  String get editSyncPremiumOnly;

  /// No description provided for @editManageData.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar Seus Dados'**
  String get editManageData;

  /// No description provided for @editExportData.
  ///
  /// In pt, this message translates to:
  /// **'Exportar Meus Dados'**
  String get editExportData;

  /// No description provided for @editExportDataSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Baixar uma cópia de todos os seus dados'**
  String get editExportDataSubtitle;

  /// No description provided for @editClearLocal.
  ///
  /// In pt, this message translates to:
  /// **'Limpar Dados Locais'**
  String get editClearLocal;

  /// No description provided for @editClearLocalSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover dados salvos neste dispositivo'**
  String get editClearLocalSubtitle;

  /// No description provided for @editDeleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Minha Conta'**
  String get editDeleteAccount;

  /// No description provided for @editDeleteAccountSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover permanentemente todos os seus dados'**
  String get editDeleteAccountSubtitle;

  /// No description provided for @genderFeminine.
  ///
  /// In pt, this message translates to:
  /// **'Feminino'**
  String get genderFeminine;

  /// No description provided for @genderMasculine.
  ///
  /// In pt, this message translates to:
  /// **'Masculino'**
  String get genderMasculine;

  /// No description provided for @genderNeutral.
  ///
  /// In pt, this message translates to:
  /// **'Neutro'**
  String get genderNeutral;

  /// No description provided for @editNotInformed.
  ///
  /// In pt, this message translates to:
  /// **'Não informado'**
  String get editNotInformed;

  /// No description provided for @editPrivacyMatters.
  ///
  /// In pt, this message translates to:
  /// **'Sua Privacidade Importa'**
  String get editPrivacyMatters;

  /// No description provided for @editPrivacyNote.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados mágicos são sagrados. Nunca vendemos suas informações pessoais e você tem controle total sobre o que é coletado e armazenado.'**
  String get editPrivacyNote;

  /// No description provided for @editNewPasswordMin.
  ///
  /// In pt, this message translates to:
  /// **'A nova senha deve ter pelo menos 6 caracteres'**
  String get editNewPasswordMin;

  /// No description provided for @editErrorPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get editErrorPrefix;

  /// No description provided for @editChangeAction.
  ///
  /// In pt, this message translates to:
  /// **'Alterar'**
  String get editChangeAction;

  /// No description provided for @editExportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Exportar Dados'**
  String get editExportTitle;

  /// No description provided for @editExportConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados serão exportados em formato JSON. Isso pode levar alguns segundos.'**
  String get editExportConfirm;

  /// No description provided for @editExportAction.
  ///
  /// In pt, this message translates to:
  /// **'Exportar'**
  String get editExportAction;

  /// No description provided for @editExporting.
  ///
  /// In pt, this message translates to:
  /// **'Exportando dados...'**
  String get editExporting;

  /// No description provided for @editExportSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Dados exportados com sucesso!'**
  String get editExportSuccess;

  /// No description provided for @editExportError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao exportar'**
  String get editExportError;

  /// No description provided for @editClearLocalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Limpar Dados Locais?'**
  String get editClearLocalTitle;

  /// No description provided for @editClearLocalConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Isso removerá todos os dados salvos neste dispositivo. Se você tem sincronização ativada, seus dados na nuvem serão mantidos.'**
  String get editClearLocalConfirm;

  /// No description provided for @editClearAction.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get editClearAction;

  /// No description provided for @editClearSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Dados locais removidos com sucesso'**
  String get editClearSuccess;

  /// No description provided for @editClearError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao limpar dados'**
  String get editClearError;

  /// No description provided for @editDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Conta'**
  String get editDeleteTitle;

  /// No description provided for @editDeleteWarning.
  ///
  /// In pt, this message translates to:
  /// **'ATENÇÃO: Esta ação é IRREVERSÍVEL!\n\nTodos os seus dados serão permanentemente excluídos, incluindo:\n- Feitiços e rituais\n- Entradas de diário\n- Mapa astral\n- Configurações\n\nTem certeza absoluta?'**
  String get editDeleteWarning;

  /// No description provided for @editDeletePermanently.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Permanentemente'**
  String get editDeletePermanently;

  /// No description provided for @editDeleting.
  ///
  /// In pt, this message translates to:
  /// **'Excluindo conta...'**
  String get editDeleting;

  /// No description provided for @editDeleteError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao deletar conta'**
  String get editDeleteError;

  /// No description provided for @editDeleteSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Conta excluída com sucesso'**
  String get editDeleteSuccess;

  /// No description provided for @editDeleteErrorPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao excluir conta'**
  String get editDeleteErrorPrefix;

  /// No description provided for @editPremiumFeature.
  ///
  /// In pt, this message translates to:
  /// **'Recurso Premium'**
  String get editPremiumFeature;

  /// No description provided for @editSyncPremiumPitch.
  ///
  /// In pt, this message translates to:
  /// **'A sincronização de dados na nuvem é um recurso exclusivo para usuários Premium.\n\nCom o Premium, seus dados ficam sempre seguros e sincronizados entre todos os seus dispositivos.'**
  String get editSyncPremiumPitch;

  /// No description provided for @editNotNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora Não'**
  String get editNotNow;

  /// No description provided for @settingsLifetime.
  ///
  /// In pt, this message translates to:
  /// **'Assinatura Vitalícia'**
  String get settingsLifetime;

  /// No description provided for @settingsRenewsOn.
  ///
  /// In pt, this message translates to:
  /// **'Renova em: {date}'**
  String settingsRenewsOn(String date);

  /// No description provided for @settingsAppearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get settingsAppearance;

  /// No description provided for @settingsPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get settingsPrivacy;

  /// No description provided for @settingsNotifDesc.
  ///
  /// In pt, this message translates to:
  /// **'Configure lembretes para eventos mágicos importantes'**
  String get settingsNotifDesc;

  /// No description provided for @settingsFullMoon.
  ///
  /// In pt, this message translates to:
  /// **'Lua Cheia'**
  String get settingsFullMoon;

  /// No description provided for @settingsFullMoonDesc.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete 1 dia antes da Lua Cheia'**
  String get settingsFullMoonDesc;

  /// No description provided for @settingsNewMoon.
  ///
  /// In pt, this message translates to:
  /// **'Lua Nova'**
  String get settingsNewMoon;

  /// No description provided for @settingsNewMoonDesc.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete 1 dia antes da Lua Nova'**
  String get settingsNewMoonDesc;

  /// No description provided for @settingsSabbats.
  ///
  /// In pt, this message translates to:
  /// **'Sabbats'**
  String get settingsSabbats;

  /// No description provided for @settingsSabbatsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete 3 dias antes de cada Sabbat'**
  String get settingsSabbatsDesc;

  /// No description provided for @settingsNotifMobileOnly.
  ///
  /// In pt, this message translates to:
  /// **'As notificações serão enviadas apenas em dispositivos móveis'**
  String get settingsNotifMobileOnly;

  /// No description provided for @settingsNotifUpdateError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar as notificações'**
  String get settingsNotifUpdateError;

  /// No description provided for @settingsPaymentsNotConfigured.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos Não Configurados'**
  String get settingsPaymentsNotConfigured;

  /// No description provided for @settingsPaymentsNotConfiguredDesc.
  ///
  /// In pt, this message translates to:
  /// **'O sistema de pagamentos ainda não foi configurado nesta versão do app.\n\nSe você é desenvolvedor, verifique os logs do console para mais detalhes.'**
  String get settingsPaymentsNotConfiguredDesc;

  /// No description provided for @commonUnderstood.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get commonUnderstood;

  /// No description provided for @settingsTermsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'As regras do nosso círculo'**
  String get settingsTermsSubtitle;

  /// No description provided for @monthJanShort.
  ///
  /// In pt, this message translates to:
  /// **'Jan'**
  String get monthJanShort;

  /// No description provided for @monthFebShort.
  ///
  /// In pt, this message translates to:
  /// **'Fev'**
  String get monthFebShort;

  /// No description provided for @monthMarShort.
  ///
  /// In pt, this message translates to:
  /// **'Mar'**
  String get monthMarShort;

  /// No description provided for @monthAprShort.
  ///
  /// In pt, this message translates to:
  /// **'Abr'**
  String get monthAprShort;

  /// No description provided for @monthMayShort.
  ///
  /// In pt, this message translates to:
  /// **'Mai'**
  String get monthMayShort;

  /// No description provided for @monthJunShort.
  ///
  /// In pt, this message translates to:
  /// **'Jun'**
  String get monthJunShort;

  /// No description provided for @monthJulShort.
  ///
  /// In pt, this message translates to:
  /// **'Jul'**
  String get monthJulShort;

  /// No description provided for @monthAugShort.
  ///
  /// In pt, this message translates to:
  /// **'Ago'**
  String get monthAugShort;

  /// No description provided for @monthSepShort.
  ///
  /// In pt, this message translates to:
  /// **'Set'**
  String get monthSepShort;

  /// No description provided for @monthOctShort.
  ///
  /// In pt, this message translates to:
  /// **'Out'**
  String get monthOctShort;

  /// No description provided for @monthNovShort.
  ///
  /// In pt, this message translates to:
  /// **'Nov'**
  String get monthNovShort;

  /// No description provided for @monthDecShort.
  ///
  /// In pt, this message translates to:
  /// **'Dez'**
  String get monthDecShort;

  /// No description provided for @diaryNewDream.
  ///
  /// In pt, this message translates to:
  /// **'Novo Sonho'**
  String get diaryNewDream;

  /// No description provided for @diaryEditDream.
  ///
  /// In pt, this message translates to:
  /// **'Editar Sonho'**
  String get diaryEditDream;

  /// No description provided for @diaryTitleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get diaryTitleLabel;

  /// No description provided for @diaryDreamTitleHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Sonho com borboletas'**
  String get diaryDreamTitleHint;

  /// No description provided for @diaryDreamDate.
  ///
  /// In pt, this message translates to:
  /// **'Data do Sonho'**
  String get diaryDreamDate;

  /// No description provided for @diaryDreamDescLabel.
  ///
  /// In pt, this message translates to:
  /// **'Descrição do Sonho'**
  String get diaryDreamDescLabel;

  /// No description provided for @diaryDreamDescHint.
  ///
  /// In pt, this message translates to:
  /// **'Descreva seu sonho em detalhes'**
  String get diaryDreamDescHint;

  /// No description provided for @diaryTagsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tags'**
  String get diaryTagsLabel;

  /// No description provided for @diaryDreamTagsHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: pesadelo, recorrente, lúcido'**
  String get diaryDreamTagsHint;

  /// No description provided for @diaryTagsHelper.
  ///
  /// In pt, this message translates to:
  /// **'Separe as tags por vírgula'**
  String get diaryTagsHelper;

  /// No description provided for @diaryDreamFeelingLabel.
  ///
  /// In pt, this message translates to:
  /// **'Como você se sentiu ao acordar?'**
  String get diaryDreamFeelingLabel;

  /// No description provided for @diaryDreamFeelingHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Paz, medo, alegria, confusão'**
  String get diaryDreamFeelingHint;

  /// No description provided for @diaryInterpretationHeader.
  ///
  /// In pt, this message translates to:
  /// **'🔮 Interpretação'**
  String get diaryInterpretationHeader;

  /// No description provided for @diarySaveDream.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Sonho'**
  String get diarySaveDream;

  /// No description provided for @commonUpdate.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get commonUpdate;

  /// No description provided for @diaryFillTitleOrDesc.
  ///
  /// In pt, this message translates to:
  /// **'Preencha pelo menos o título ou a descrição'**
  String get diaryFillTitleOrDesc;

  /// No description provided for @diaryFillTitleOrContent.
  ///
  /// In pt, this message translates to:
  /// **'Preencha pelo menos o título ou o conteúdo'**
  String get diaryFillTitleOrContent;

  /// No description provided for @commonNoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem título'**
  String get commonNoTitle;

  /// No description provided for @commonConfirmDelete.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar exclusão'**
  String get commonConfirmDelete;

  /// No description provided for @diaryDeleteDreamConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Deseja realmente excluir este sonho?'**
  String get diaryDeleteDreamConfirm;

  /// No description provided for @diaryNewGratitude.
  ///
  /// In pt, this message translates to:
  /// **'Nova Gratidão'**
  String get diaryNewGratitude;

  /// No description provided for @diaryEditGratitude.
  ///
  /// In pt, this message translates to:
  /// **'Editar Gratidão'**
  String get diaryEditGratitude;

  /// No description provided for @diaryGratitudeTitleHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Gratidão pelo dia de hoje'**
  String get diaryGratitudeTitleHint;

  /// No description provided for @commonDate.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get commonDate;

  /// No description provided for @diaryGratitudeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pelo que você é grato(a) hoje?'**
  String get diaryGratitudeLabel;

  /// No description provided for @diaryGratitudeHint.
  ///
  /// In pt, this message translates to:
  /// **'Descreva suas gratidões...'**
  String get diaryGratitudeHint;

  /// No description provided for @diaryGratitudeTagsHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: família, saúde, trabalho'**
  String get diaryGratitudeTagsHint;

  /// No description provided for @diarySaveGratitude.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Gratidão'**
  String get diarySaveGratitude;

  /// No description provided for @diaryDeleteGratitudeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Gratidão'**
  String get diaryDeleteGratitudeTitle;

  /// No description provided for @diaryDeleteGratitudeConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja excluir esta gratidão?'**
  String get diaryDeleteGratitudeConfirm;

  /// No description provided for @diaryNewDesire.
  ///
  /// In pt, this message translates to:
  /// **'Novo Desejo'**
  String get diaryNewDesire;

  /// No description provided for @diaryEditDesire.
  ///
  /// In pt, this message translates to:
  /// **'Editar Desejo'**
  String get diaryEditDesire;

  /// No description provided for @diaryDesireTitleHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Viajar para o exterior'**
  String get diaryDesireTitleHint;

  /// No description provided for @diaryDescLabel.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get diaryDescLabel;

  /// No description provided for @diaryDesireDescHint.
  ///
  /// In pt, this message translates to:
  /// **'Descreva seu desejo em detalhes'**
  String get diaryDesireDescHint;

  /// No description provided for @diaryStatusLabel.
  ///
  /// In pt, this message translates to:
  /// **'Status'**
  String get diaryStatusLabel;

  /// No description provided for @diaryDesireProgressLabel.
  ///
  /// In pt, this message translates to:
  /// **'O que se movimentou?'**
  String get diaryDesireProgressLabel;

  /// No description provided for @diaryDesireProgressHint.
  ///
  /// In pt, this message translates to:
  /// **'Registre a evolução do seu desejo'**
  String get diaryDesireProgressHint;

  /// No description provided for @diarySaveDesire.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Desejo'**
  String get diarySaveDesire;

  /// No description provided for @diaryDeleteDesireConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Deseja realmente excluir este desejo?'**
  String get diaryDeleteDesireConfirm;

  /// No description provided for @diaryNewAffirmation.
  ///
  /// In pt, this message translates to:
  /// **'Nova Afirmação'**
  String get diaryNewAffirmation;

  /// No description provided for @diaryEditAffirmation.
  ///
  /// In pt, this message translates to:
  /// **'Editar Afirmação'**
  String get diaryEditAffirmation;

  /// No description provided for @diaryPreloadedAffirmationNote.
  ///
  /// In pt, this message translates to:
  /// **'Afirmações pré-carregadas não podem ser editadas ou excluídas.'**
  String get diaryPreloadedAffirmationNote;

  /// No description provided for @diaryAdvisorAffirmationPitch.
  ///
  /// In pt, this message translates to:
  /// **'Deixe o Conselheiro Místico criar uma afirmação poderosa para você'**
  String get diaryAdvisorAffirmationPitch;

  /// No description provided for @diaryContextOptional.
  ///
  /// In pt, this message translates to:
  /// **'Contexto (opcional)'**
  String get diaryContextOptional;

  /// No description provided for @diaryContextHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Estou começando um novo emprego...'**
  String get diaryContextHint;

  /// No description provided for @diaryContextHelper.
  ///
  /// In pt, this message translates to:
  /// **'Descreva sua situação para uma afirmação personalizada'**
  String get diaryContextHelper;

  /// No description provided for @diaryConsulting.
  ///
  /// In pt, this message translates to:
  /// **'Consultando...'**
  String get diaryConsulting;

  /// No description provided for @diaryGenerateAffirmation.
  ///
  /// In pt, this message translates to:
  /// **'Gerar Afirmação'**
  String get diaryGenerateAffirmation;

  /// No description provided for @diaryWriteOwnAffirmation.
  ///
  /// In pt, this message translates to:
  /// **'Ou escreva sua própria afirmação:'**
  String get diaryWriteOwnAffirmation;

  /// No description provided for @diaryAffirmationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Afirmação'**
  String get diaryAffirmationLabel;

  /// No description provided for @diaryAffirmationHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Sou merecedor de abundância e prosperidade'**
  String get diaryAffirmationHint;

  /// No description provided for @diaryAffirmationHelper.
  ///
  /// In pt, this message translates to:
  /// **'Escreva no presente e de forma positiva'**
  String get diaryAffirmationHelper;

  /// No description provided for @diaryCategoryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get diaryCategoryLabel;

  /// No description provided for @diarySaveAffirmation.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Afirmação'**
  String get diarySaveAffirmation;

  /// No description provided for @diaryAffirmationsRemaining.
  ///
  /// In pt, this message translates to:
  /// **'Afirmações restantes hoje: {used}'**
  String diaryAffirmationsRemaining(String used);

  /// No description provided for @diaryAffirmationCreated.
  ///
  /// In pt, this message translates to:
  /// **'Afirmação criada pelo Conselheiro Místico!'**
  String get diaryAffirmationCreated;

  /// No description provided for @diaryAffirmationError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao gerar afirmação'**
  String get diaryAffirmationError;

  /// No description provided for @diaryTypeOrGenerate.
  ///
  /// In pt, this message translates to:
  /// **'Digite ou gere uma afirmação'**
  String get diaryTypeOrGenerate;

  /// No description provided for @diaryAffirmationLimit.
  ///
  /// In pt, this message translates to:
  /// **'Você atingiu o limite diário de afirmações. Volte amanhã ou seja Premium!'**
  String get diaryAffirmationLimit;

  /// No description provided for @diaryDeleteAffirmationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Afirmação'**
  String get diaryDeleteAffirmationTitle;

  /// No description provided for @diaryDeleteAffirmationConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja excluir esta afirmação?'**
  String get diaryDeleteAffirmationConfirm;

  /// No description provided for @diaryLoadingDreams.
  ///
  /// In pt, this message translates to:
  /// **'Carregando sonhos...'**
  String get diaryLoadingDreams;

  /// No description provided for @diaryEmptyDreams.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não registrou nenhum sonho.\nComece seu diário onírico!'**
  String get diaryEmptyDreams;

  /// No description provided for @diaryRegisterDream.
  ///
  /// In pt, this message translates to:
  /// **'Registrar Sonho'**
  String get diaryRegisterDream;

  /// No description provided for @diaryInterpretDream.
  ///
  /// In pt, this message translates to:
  /// **'Interpretar Sonho'**
  String get diaryInterpretDream;

  /// No description provided for @diaryDreamThemes.
  ///
  /// In pt, this message translates to:
  /// **'Temas Oníricos'**
  String get diaryDreamThemes;

  /// No description provided for @diaryLoadingGratitudes.
  ///
  /// In pt, this message translates to:
  /// **'Carregando gratidões...'**
  String get diaryLoadingGratitudes;

  /// No description provided for @diaryEmptyGratitudes.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não registrou nenhuma gratidão.\nComece a cultivar abundância em sua vida!'**
  String get diaryEmptyGratitudes;

  /// No description provided for @diaryAddGratitude.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Gratidão'**
  String get diaryAddGratitude;

  /// No description provided for @diaryLoadingDesires.
  ///
  /// In pt, this message translates to:
  /// **'Carregando desejos...'**
  String get diaryLoadingDesires;

  /// No description provided for @diaryEmptyDesires.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não registrou nenhum desejo.\nComece a manifestar seus sonhos!'**
  String get diaryEmptyDesires;

  /// No description provided for @diaryAddDesire.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Desejo'**
  String get diaryAddDesire;

  /// No description provided for @diaryLoadingAffirmations.
  ///
  /// In pt, this message translates to:
  /// **'Carregando afirmações...'**
  String get diaryLoadingAffirmations;

  /// No description provided for @diaryAllCategories.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get diaryAllCategories;

  /// No description provided for @diaryEmptyAffirmationsCategory.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma afirmação nesta categoria.\nAdicione suas próprias afirmações!'**
  String get diaryEmptyAffirmationsCategory;

  /// No description provided for @diaryAddAffirmation.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Afirmação'**
  String get diaryAddAffirmation;

  /// No description provided for @commonGoodMorning.
  ///
  /// In pt, this message translates to:
  /// **'Bom dia ✨'**
  String get commonGoodMorning;

  /// No description provided for @commonGoodAfternoon.
  ///
  /// In pt, this message translates to:
  /// **'Boa tarde ✨'**
  String get commonGoodAfternoon;

  /// No description provided for @commonGoodEvening.
  ///
  /// In pt, this message translates to:
  /// **'Boa noite ✨'**
  String get commonGoodEvening;

  /// No description provided for @diaryPreviousReflections.
  ///
  /// In pt, this message translates to:
  /// **'Reflexões anteriores'**
  String get diaryPreviousReflections;

  /// No description provided for @diarySaveReflection.
  ///
  /// In pt, this message translates to:
  /// **'Salvar reflexão'**
  String get diarySaveReflection;

  /// No description provided for @diaryFreeWritingHint.
  ///
  /// In pt, this message translates to:
  /// **'O que está na sua mente hoje?'**
  String get diaryFreeWritingHint;

  /// No description provided for @diaryReflections.
  ///
  /// In pt, this message translates to:
  /// **'Reflexões'**
  String get diaryReflections;

  /// No description provided for @diaryLoadingReflections.
  ///
  /// In pt, this message translates to:
  /// **'Carregando reflexões...'**
  String get diaryLoadingReflections;

  /// No description provided for @diaryEmptyReflections.
  ///
  /// In pt, this message translates to:
  /// **'Suas reflexões aparecerão aqui.\nEscreva o que estiver na sua mente. ✨'**
  String get diaryEmptyReflections;

  /// No description provided for @diaryDeleteReflectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir reflexão'**
  String get diaryDeleteReflectionTitle;

  /// No description provided for @diaryDeleteReflectionConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja excluir esta reflexão?'**
  String get diaryDeleteReflectionConfirm;

  /// No description provided for @diaryDreamThemesIntro.
  ///
  /// In pt, this message translates to:
  /// **'Cada símbolo carrega muitas leituras possíveis. Explore os temas mais comuns e compare com o que você sentiu no sonho.'**
  String get diaryDreamThemesIntro;

  /// No description provided for @dreamDescribeFirst.
  ///
  /// In pt, this message translates to:
  /// **'Descreva seu sonho primeiro'**
  String get dreamDescribeFirst;

  /// No description provided for @dreamInterpretedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sonho interpretado'**
  String get dreamInterpretedTitle;

  /// No description provided for @dreamNotesPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Observações'**
  String get dreamNotesPrefix;

  /// No description provided for @dreamSavedToDiary.
  ///
  /// In pt, this message translates to:
  /// **'Sonho e interpretação salvos no Diário! 🌙'**
  String get dreamSavedToDiary;

  /// No description provided for @dreamInterpretationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Interpretação de Sonhos'**
  String get dreamInterpretationTitle;

  /// No description provided for @dreamPremiumOnly.
  ///
  /// In pt, this message translates to:
  /// **'A interpretação personalizada de sonhos é exclusiva do plano Premium.'**
  String get dreamPremiumOnly;

  /// No description provided for @dreamTellYourDream.
  ///
  /// In pt, this message translates to:
  /// **'Conte seu sonho'**
  String get dreamTellYourDream;

  /// No description provided for @dreamTellHelp.
  ///
  /// In pt, this message translates to:
  /// **'Descreva com o máximo de detalhes: lugares, pessoas, símbolos, sensações e o que mais lembrar.'**
  String get dreamTellHelp;

  /// No description provided for @dreamTextHint.
  ///
  /// In pt, this message translates to:
  /// **'Eu estava em uma floresta e…'**
  String get dreamTextHint;

  /// No description provided for @dreamFeelingOptional.
  ///
  /// In pt, this message translates to:
  /// **'Como você se sentiu ao acordar? (opcional)'**
  String get dreamFeelingOptional;

  /// No description provided for @dreamInterpreting.
  ///
  /// In pt, this message translates to:
  /// **'Interpretando…'**
  String get dreamInterpreting;

  /// No description provided for @dreamInterpretAgain.
  ///
  /// In pt, this message translates to:
  /// **'Interpretar novamente'**
  String get dreamInterpretAgain;

  /// No description provided for @dreamInterpretationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Interpretação'**
  String get dreamInterpretationLabel;

  /// No description provided for @dreamSaveToDiary.
  ///
  /// In pt, this message translates to:
  /// **'Salvar no Diário de Sonhos'**
  String get dreamSaveToDiary;

  /// No description provided for @dreamDateLabel.
  ///
  /// In pt, this message translates to:
  /// **'Data do sonho'**
  String get dreamDateLabel;

  /// No description provided for @dreamNotesOptional.
  ///
  /// In pt, this message translates to:
  /// **'Observações (opcional)'**
  String get dreamNotesOptional;

  /// No description provided for @dreamSavedShort.
  ///
  /// In pt, this message translates to:
  /// **'Salvo no Diário'**
  String get dreamSavedShort;

  /// No description provided for @tarotTabDraw.
  ///
  /// In pt, this message translates to:
  /// **'Tiragem'**
  String get tarotTabDraw;

  /// No description provided for @tarotTabLearn.
  ///
  /// In pt, this message translates to:
  /// **'Aprender'**
  String get tarotTabLearn;

  /// No description provided for @tarotDailyCard.
  ///
  /// In pt, this message translates to:
  /// **'Carta do Dia'**
  String get tarotDailyCard;

  /// No description provided for @tarotThreeCards.
  ///
  /// In pt, this message translates to:
  /// **'Três Cartas'**
  String get tarotThreeCards;

  /// No description provided for @tarotCross.
  ///
  /// In pt, this message translates to:
  /// **'Cruz de Cinco'**
  String get tarotCross;

  /// No description provided for @tarotDailyDesc.
  ///
  /// In pt, this message translates to:
  /// **'A energia que acompanha o seu dia'**
  String get tarotDailyDesc;

  /// No description provided for @tarotThreeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Passado · Presente · Futuro'**
  String get tarotThreeDesc;

  /// No description provided for @tarotCrossDesc.
  ///
  /// In pt, this message translates to:
  /// **'Situação, desafio, raiz, conselho e tendência'**
  String get tarotCrossDesc;

  /// No description provided for @tarotPosPast.
  ///
  /// In pt, this message translates to:
  /// **'Passado'**
  String get tarotPosPast;

  /// No description provided for @tarotPosPresent.
  ///
  /// In pt, this message translates to:
  /// **'Presente'**
  String get tarotPosPresent;

  /// No description provided for @tarotPosFuture.
  ///
  /// In pt, this message translates to:
  /// **'Futuro'**
  String get tarotPosFuture;

  /// No description provided for @tarotPosSituation.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get tarotPosSituation;

  /// No description provided for @tarotPosChallenge.
  ///
  /// In pt, this message translates to:
  /// **'Desafio'**
  String get tarotPosChallenge;

  /// No description provided for @tarotPosRoot.
  ///
  /// In pt, this message translates to:
  /// **'Raiz'**
  String get tarotPosRoot;

  /// No description provided for @tarotPosAdvice.
  ///
  /// In pt, this message translates to:
  /// **'Conselho'**
  String get tarotPosAdvice;

  /// No description provided for @tarotPosTendency.
  ///
  /// In pt, this message translates to:
  /// **'Tendência'**
  String get tarotPosTendency;

  /// No description provided for @tarotFreeLimitReached.
  ///
  /// In pt, this message translates to:
  /// **'Você já fez sua tiragem gratuita hoje. Assine Premium para tiragens ilimitadas!'**
  String get tarotFreeLimitReached;

  /// No description provided for @tarotSpreadLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tiragem'**
  String get tarotSpreadLabel;

  /// No description provided for @tarotReversed.
  ///
  /// In pt, this message translates to:
  /// **'invertida'**
  String get tarotReversed;

  /// No description provided for @tarotBreathe.
  ///
  /// In pt, this message translates to:
  /// **'Respire fundo, pense na sua pergunta e escolha a tiragem.'**
  String get tarotBreathe;

  /// No description provided for @tarotNewSpread.
  ///
  /// In pt, this message translates to:
  /// **'Nova tiragem'**
  String get tarotNewSpread;

  /// No description provided for @tarotConsultingCards.
  ///
  /// In pt, this message translates to:
  /// **'Consultando as cartas…'**
  String get tarotConsultingCards;

  /// No description provided for @tarotAdvisorInterpretation.
  ///
  /// In pt, this message translates to:
  /// **'Interpretação do Conselheiro Místico'**
  String get tarotAdvisorInterpretation;

  /// No description provided for @tarotBestCombo.
  ///
  /// In pt, this message translates to:
  /// **'Melhor combo'**
  String get tarotBestCombo;

  /// No description provided for @tarotDayStreak.
  ///
  /// In pt, this message translates to:
  /// **'Dias seguidos'**
  String get tarotDayStreak;

  /// No description provided for @tarotAccuracy.
  ///
  /// In pt, this message translates to:
  /// **'Precisão'**
  String get tarotAccuracy;

  /// No description provided for @tarotAnsweredOf.
  ///
  /// In pt, this message translates to:
  /// **'{answered} respondidas · {total} cartas no baralho'**
  String tarotAnsweredOf(String answered, String total);

  /// No description provided for @tarotQuizTitle.
  ///
  /// In pt, this message translates to:
  /// **'Teste o que você sabe'**
  String get tarotQuizTitle;

  /// No description provided for @tarotQuizDesc.
  ///
  /// In pt, this message translates to:
  /// **'Uma sessão com perguntas embaralhadas sobre os significados das cartas. Acertos consecutivos formam combo — volte todos os dias para manter a sequência.'**
  String get tarotQuizDesc;

  /// No description provided for @tarotQuizStart.
  ///
  /// In pt, this message translates to:
  /// **'Sessão de 10 perguntas'**
  String get tarotQuizStart;

  /// No description provided for @tarotQuizBrilliant.
  ///
  /// In pt, this message translates to:
  /// **'Brilhante! ✨'**
  String get tarotQuizBrilliant;

  /// No description provided for @tarotQuizDone.
  ///
  /// In pt, this message translates to:
  /// **'Sessão concluída 🌙'**
  String get tarotQuizDone;

  /// No description provided for @tarotQuizScore.
  ///
  /// In pt, this message translates to:
  /// **'Você acertou {correct} de {total}.'**
  String tarotQuizScore(String correct, String total);

  /// No description provided for @tarotQuizPraise.
  ///
  /// In pt, this message translates to:
  /// **' As cartas reconhecem sua dedicação.'**
  String get tarotQuizPraise;

  /// No description provided for @tarotQuizEncourage.
  ///
  /// In pt, this message translates to:
  /// **' Continue praticando — cada sessão aprofunda a leitura.'**
  String get tarotQuizEncourage;

  /// No description provided for @tarotQuizFinish.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get tarotQuizFinish;

  /// No description provided for @tarotQuizQuestion.
  ///
  /// In pt, this message translates to:
  /// **'O que representa {card}?'**
  String tarotQuizQuestion(String card);

  /// No description provided for @palmImageTooLarge.
  ///
  /// In pt, this message translates to:
  /// **'A imagem ficou grande demais. Tente com menos zoom ou outra foto.'**
  String get palmImageTooLarge;

  /// No description provided for @palmImageTooSmall.
  ///
  /// In pt, this message translates to:
  /// **'A imagem parece pequena ou escura demais para leitura. Fotografe a palma bem iluminada, preenchendo a tela.'**
  String get palmImageTooSmall;

  /// No description provided for @palmReadingHeader.
  ///
  /// In pt, this message translates to:
  /// **'Leitura de Mãos'**
  String get palmReadingHeader;

  /// No description provided for @palmSavedToReflections.
  ///
  /// In pt, this message translates to:
  /// **'Leitura salva nas suas Reflexões! ✨'**
  String get palmSavedToReflections;

  /// No description provided for @palmistryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quiromancia'**
  String get palmistryTitle;

  /// No description provided for @palmPremiumOnly.
  ///
  /// In pt, this message translates to:
  /// **'A leitura de mãos é exclusiva do plano Premium.'**
  String get palmPremiumOnly;

  /// No description provided for @palmHowTo.
  ///
  /// In pt, this message translates to:
  /// **'🖐️ Como fotografar'**
  String get palmHowTo;

  /// No description provided for @palmTip1.
  ///
  /// In pt, this message translates to:
  /// **'Palma da mão dominante aberta e relaxada'**
  String get palmTip1;

  /// No description provided for @palmTip2.
  ///
  /// In pt, this message translates to:
  /// **'Luz natural, sem sombras fortes sobre as linhas'**
  String get palmTip2;

  /// No description provided for @palmTip3.
  ///
  /// In pt, this message translates to:
  /// **'A palma deve preencher quase toda a foto'**
  String get palmTip3;

  /// No description provided for @palmTip4.
  ///
  /// In pt, this message translates to:
  /// **'Evite fotos tremidas ou desfocadas'**
  String get palmTip4;

  /// No description provided for @palmPrivacyNote.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade: a foto é processada na hora e descartada — não fica salva no aparelho nem em servidores.'**
  String get palmPrivacyNote;

  /// No description provided for @palmCamera.
  ///
  /// In pt, this message translates to:
  /// **'Câmera'**
  String get palmCamera;

  /// No description provided for @palmGallery.
  ///
  /// In pt, this message translates to:
  /// **'Galeria'**
  String get palmGallery;

  /// No description provided for @palmReadingLines.
  ///
  /// In pt, this message translates to:
  /// **'Lendo as linhas da sua mão…'**
  String get palmReadingLines;

  /// No description provided for @palmYourReading.
  ///
  /// In pt, this message translates to:
  /// **'✨ Sua Leitura'**
  String get palmYourReading;

  /// No description provided for @palmDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'Leitura simbólica para reflexão — não substitui orientação médica, psicológica ou profissional.'**
  String get palmDisclaimer;

  /// No description provided for @palmSavedShort.
  ///
  /// In pt, this message translates to:
  /// **'Salva nas Reflexões'**
  String get palmSavedShort;

  /// No description provided for @palmSaveReading.
  ///
  /// In pt, this message translates to:
  /// **'Salvar leitura'**
  String get palmSaveReading;

  /// No description provided for @numMagicOfNumbers.
  ///
  /// In pt, this message translates to:
  /// **'A Magia dos Números'**
  String get numMagicOfNumbers;

  /// No description provided for @numIntro.
  ///
  /// In pt, this message translates to:
  /// **'Explore os números que vibram na sua vida: seu perfil de nascimento, o significado de qualquer número, as horas espelho e as sequências que insistem em aparecer.'**
  String get numIntro;

  /// No description provided for @numPersonalProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil Pessoal'**
  String get numPersonalProfile;

  /// No description provided for @numPersonalProfileDesc.
  ///
  /// In pt, this message translates to:
  /// **'Seus 5 números-chave a partir do nome e da data de nascimento'**
  String get numPersonalProfileDesc;

  /// No description provided for @numLookupTitle.
  ///
  /// In pt, this message translates to:
  /// **'Consultar um Número'**
  String get numLookupTitle;

  /// No description provided for @numLookupDesc.
  ///
  /// In pt, this message translates to:
  /// **'Um número te acompanha? Descubra o que ele vibra'**
  String get numLookupDesc;

  /// No description provided for @numMirrorHours.
  ///
  /// In pt, this message translates to:
  /// **'Horas Espelho'**
  String get numMirrorHours;

  /// No description provided for @numMirrorHoursDesc.
  ///
  /// In pt, this message translates to:
  /// **'O recado das horas duplas: 11:11, 22:22 e além'**
  String get numMirrorHoursDesc;

  /// No description provided for @numSequences.
  ///
  /// In pt, this message translates to:
  /// **'Sequências Repetidas'**
  String get numSequences;

  /// No description provided for @numSequencesDesc.
  ///
  /// In pt, this message translates to:
  /// **'O significado de padrões como 333, 1010 e 1234'**
  String get numSequencesDesc;

  /// No description provided for @numWhichNumber.
  ///
  /// In pt, this message translates to:
  /// **'Que número te acompanha?'**
  String get numWhichNumber;

  /// No description provided for @numLookupHelp.
  ///
  /// In pt, this message translates to:
  /// **'Placas, datas, portas, recibos… digite o número e veja sua essência numerológica.'**
  String get numLookupHelp;

  /// No description provided for @numLookupHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: 713'**
  String get numLookupHint;

  /// No description provided for @numSee.
  ///
  /// In pt, this message translates to:
  /// **'Ver'**
  String get numSee;

  /// No description provided for @numReducesTo.
  ///
  /// In pt, this message translates to:
  /// **'{original} reduz para {result}'**
  String numReducesTo(String original, String result);

  /// No description provided for @numMirrorIntro.
  ///
  /// In pt, this message translates to:
  /// **'Olhou o relógio exatamente numa hora dupla? Cada espelho carrega uma vibração numérica. Toque para ver o recado.'**
  String get numMirrorIntro;

  /// No description provided for @numVibrationOf.
  ///
  /// In pt, this message translates to:
  /// **'Vibração do número {number}'**
  String numVibrationOf(String number);

  /// No description provided for @numMirrorMessage.
  ///
  /// In pt, this message translates to:
  /// **'Recado do espelho {label}'**
  String numMirrorMessage(String label);

  /// No description provided for @numSequencesIntro.
  ///
  /// In pt, this message translates to:
  /// **'Aquele número que aparece em todo lugar pode ser um padrão pedindo atenção. Os clássicos:'**
  String get numSequencesIntro;

  /// No description provided for @numVibratesIn.
  ///
  /// In pt, this message translates to:
  /// **'vibra no {number}'**
  String numVibratesIn(String number);

  /// No description provided for @numFillNameAndDate.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome completo e a data de nascimento'**
  String get numFillNameAndDate;

  /// No description provided for @numDailyLimit.
  ///
  /// In pt, this message translates to:
  /// **'Limite diário atingido. Assine Premium para consultas ilimitadas.'**
  String get numDailyLimit;

  /// No description provided for @numYourBirthData.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados de nascimento'**
  String get numYourBirthData;

  /// No description provided for @numBirthNameHelp.
  ///
  /// In pt, this message translates to:
  /// **'Use o nome completo de nascimento — é ele que carrega a assinatura numerológica original.'**
  String get numBirthNameHelp;

  /// No description provided for @numFullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get numFullName;

  /// No description provided for @numChooseBirthDate.
  ///
  /// In pt, this message translates to:
  /// **'Escolher data de nascimento'**
  String get numChooseBirthDate;

  /// No description provided for @numBirthPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Nascimento'**
  String get numBirthPrefix;

  /// No description provided for @numCalculate.
  ///
  /// In pt, this message translates to:
  /// **'Calcular meus números'**
  String get numCalculate;

  /// No description provided for @numSynthesisQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Quer uma síntese de como esses números conversam entre si?'**
  String get numSynthesisQuestion;

  /// No description provided for @numWeavingSynthesis.
  ///
  /// In pt, this message translates to:
  /// **'Tecendo a síntese…'**
  String get numWeavingSynthesis;

  /// No description provided for @numAdvisorExplanation.
  ///
  /// In pt, this message translates to:
  /// **'Explicação do Conselheiro Místico'**
  String get numAdvisorExplanation;

  /// No description provided for @sigilCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar Sigilo'**
  String get sigilCreateTitle;

  /// No description provided for @sigilWhatIs.
  ///
  /// In pt, this message translates to:
  /// **'O que é um Sigilo?'**
  String get sigilWhatIs;

  /// No description provided for @sigilWhatIsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Sigilos são símbolos mágicos criados para manifestar intenções. Ao transformar palavras em símbolos abstratos, você cria uma marca energética que carrega o poder da sua vontade, sem revelar sua intenção para outras pessoas.'**
  String get sigilWhatIsDesc;

  /// No description provided for @sigilHowIntro.
  ///
  /// In pt, this message translates to:
  /// **'Defina sua intenção, escolha uma palavra que a represente, e o app criará automaticamente seu sigilo único.'**
  String get sigilHowIntro;

  /// No description provided for @sigilSetIntention.
  ///
  /// In pt, this message translates to:
  /// **'Defina sua Intenção'**
  String get sigilSetIntention;

  /// No description provided for @sigilIntentionWord.
  ///
  /// In pt, this message translates to:
  /// **'Sua palavra de intenção'**
  String get sigilIntentionWord;

  /// No description provided for @sigilTypeWord.
  ///
  /// In pt, this message translates to:
  /// **'Digite uma palavra...'**
  String get sigilTypeWord;

  /// No description provided for @sigilOneWordWarning.
  ///
  /// In pt, this message translates to:
  /// **'⚠️ Use apenas UMA palavra, sem espaços'**
  String get sigilOneWordWarning;

  /// No description provided for @sigilExamplesHeader.
  ///
  /// In pt, this message translates to:
  /// **'💡 Exemplos de palavras'**
  String get sigilExamplesHeader;

  /// No description provided for @sigilExample1.
  ///
  /// In pt, this message translates to:
  /// **'Prosperidade'**
  String get sigilExample1;

  /// No description provided for @sigilExample2.
  ///
  /// In pt, this message translates to:
  /// **'Proteção'**
  String get sigilExample2;

  /// No description provided for @sigilExample3.
  ///
  /// In pt, this message translates to:
  /// **'Cura'**
  String get sigilExample3;

  /// No description provided for @sigilExample4.
  ///
  /// In pt, this message translates to:
  /// **'Confiança'**
  String get sigilExample4;

  /// No description provided for @sigilExample5.
  ///
  /// In pt, this message translates to:
  /// **'Intuição'**
  String get sigilExample5;

  /// No description provided for @sigilWordTip.
  ///
  /// In pt, this message translates to:
  /// **'Dica: Escolha palavras positivas e específicas que ressoem com você.'**
  String get sigilWordTip;

  /// No description provided for @commonContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @sigilMagicLetters.
  ///
  /// In pt, this message translates to:
  /// **'Letras Mágicas'**
  String get sigilMagicLetters;

  /// No description provided for @sigilYourLetters.
  ///
  /// In pt, this message translates to:
  /// **'Letras do seu Sigilo'**
  String get sigilYourLetters;

  /// No description provided for @sigilEssence.
  ///
  /// In pt, this message translates to:
  /// **'A essência mágica da sua intenção'**
  String get sigilEssence;

  /// No description provided for @sigilYourIntention.
  ///
  /// In pt, this message translates to:
  /// **'Sua intenção:'**
  String get sigilYourIntention;

  /// No description provided for @sigilTransformedInto.
  ///
  /// In pt, this message translates to:
  /// **'Transformada em:'**
  String get sigilTransformedInto;

  /// No description provided for @sigilWhatHappened.
  ///
  /// In pt, this message translates to:
  /// **'O que aconteceu?'**
  String get sigilWhatHappened;

  /// No description provided for @sigilSimplified.
  ///
  /// In pt, this message translates to:
  /// **'Sua palavra foi simplificada seguindo a tradição dos sigilos:'**
  String get sigilSimplified;

  /// No description provided for @sigilStepAccents.
  ///
  /// In pt, this message translates to:
  /// **'1. Acentos foram normalizados'**
  String get sigilStepAccents;

  /// No description provided for @sigilStepSpaces.
  ///
  /// In pt, this message translates to:
  /// **'2. Espaços e símbolos foram removidos'**
  String get sigilStepSpaces;

  /// No description provided for @sigilStepDupes.
  ///
  /// In pt, this message translates to:
  /// **'3. Letras duplicadas foram eliminadas (mantém apenas a primeira ocorrência)'**
  String get sigilStepDupes;

  /// No description provided for @sigilWheelNote.
  ///
  /// In pt, this message translates to:
  /// **'Esta sequência simplificada será conectada na Roda das Bruxas para formar o símbolo mágico do seu sigilo.'**
  String get sigilWheelNote;

  /// No description provided for @sigilSeeDrawing.
  ///
  /// In pt, this message translates to:
  /// **'Ver Desenho do Sigilo'**
  String get sigilSeeDrawing;

  /// No description provided for @sigilSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o sigilo'**
  String get sigilSaveError;

  /// No description provided for @sigilDrawingNotReady.
  ///
  /// In pt, this message translates to:
  /// **'Desenho ainda não está pronto'**
  String get sigilDrawingNotReady;

  /// No description provided for @sigilImageError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao gerar a imagem'**
  String get sigilImageError;

  /// No description provided for @sigilSavedToGallery.
  ///
  /// In pt, this message translates to:
  /// **'Sigilo salvo na galeria! ✨'**
  String get sigilSavedToGallery;

  /// No description provided for @sigilGalleryPermission.
  ///
  /// In pt, this message translates to:
  /// **'Permita o acesso à galeria para salvar o sigilo.'**
  String get sigilGalleryPermission;

  /// No description provided for @sigilImageSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar a imagem.'**
  String get sigilImageSaveError;

  /// No description provided for @sigilYourSigil.
  ///
  /// In pt, this message translates to:
  /// **'Seu Sigilo'**
  String get sigilYourSigil;

  /// No description provided for @sigilYourDrawing.
  ///
  /// In pt, this message translates to:
  /// **'Desenho do seu Sigilo'**
  String get sigilYourDrawing;

  /// No description provided for @sigilLegendStart.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get sigilLegendStart;

  /// No description provided for @sigilLegendLetters.
  ///
  /// In pt, this message translates to:
  /// **'Letras'**
  String get sigilLegendLetters;

  /// No description provided for @sigilLegendEnd.
  ///
  /// In pt, this message translates to:
  /// **'Fim'**
  String get sigilLegendEnd;

  /// No description provided for @sigilWheel.
  ///
  /// In pt, this message translates to:
  /// **'Roda'**
  String get sigilWheel;

  /// No description provided for @sigilPoints.
  ///
  /// In pt, this message translates to:
  /// **'Pontos'**
  String get sigilPoints;

  /// No description provided for @sigilShuffle.
  ///
  /// In pt, this message translates to:
  /// **'Embaralhar letras'**
  String get sigilShuffle;

  /// No description provided for @sigilSaveImage.
  ///
  /// In pt, this message translates to:
  /// **'Salvar imagem na galeria'**
  String get sigilSaveImage;

  /// No description provided for @sigilRestore.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar posições'**
  String get sigilRestore;

  /// No description provided for @sigilHowToUse.
  ///
  /// In pt, this message translates to:
  /// **'Como usar seu sigilo'**
  String get sigilHowToUse;

  /// No description provided for @sigilUse1Title.
  ///
  /// In pt, this message translates to:
  /// **'1. Copie este desenho'**
  String get sigilUse1Title;

  /// No description provided for @sigilUse1Desc.
  ///
  /// In pt, this message translates to:
  /// **'Reproduza o traçado em seu caderno, altar, vela, ou papel ritual.'**
  String get sigilUse1Desc;

  /// No description provided for @sigilUse2Title.
  ///
  /// In pt, this message translates to:
  /// **'2. Personalize'**
  String get sigilUse2Title;

  /// No description provided for @sigilUse2Desc.
  ///
  /// In pt, this message translates to:
  /// **'Simplifique, gire, ou adicione detalhes. Torná-lo seu faz parte da magia.'**
  String get sigilUse2Desc;

  /// No description provided for @sigilUse3Title.
  ///
  /// In pt, this message translates to:
  /// **'3. Ative o sigilo'**
  String get sigilUse3Title;

  /// No description provided for @sigilUse3Desc.
  ///
  /// In pt, this message translates to:
  /// **'Use em meditação, queime em ritual, ou carregue consigo para focar sua intenção.'**
  String get sigilUse3Desc;

  /// No description provided for @sigilRemember.
  ///
  /// In pt, this message translates to:
  /// **'Lembre-se: a magia está na sua intenção e no ato de criar, não apenas no desenho final.'**
  String get sigilRemember;

  /// No description provided for @commonSaving.
  ///
  /// In pt, this message translates to:
  /// **'Salvando...'**
  String get commonSaving;

  /// No description provided for @commonFinish.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar'**
  String get commonFinish;

  /// No description provided for @advisorAskFirst.
  ///
  /// In pt, this message translates to:
  /// **'Faça sua pergunta primeiro'**
  String get advisorAskFirst;

  /// No description provided for @advisorDailyLimit.
  ///
  /// In pt, this message translates to:
  /// **'Você já consultou o Conselheiro hoje. Volte amanhã ou seja Premium!'**
  String get advisorDailyLimit;

  /// No description provided for @advisorGenericError.
  ///
  /// In pt, this message translates to:
  /// **'O conselheiro não pôde responder agora. Tente novamente mais tarde.'**
  String get advisorGenericError;

  /// No description provided for @advisorRateLimited.
  ///
  /// In pt, this message translates to:
  /// **'O conselheiro precisa de descanso. Muitos pedidos foram feitos. Por favor, aguarde alguns minutos.'**
  String get advisorRateLimited;

  /// No description provided for @advisorTempError.
  ///
  /// In pt, this message translates to:
  /// **'Erro temporário no serviço místico. Tente novamente em instantes.'**
  String get advisorTempError;

  /// No description provided for @advisorConnectionError.
  ///
  /// In pt, this message translates to:
  /// **'Erro de conexão. Verifique sua internet e tente novamente.'**
  String get advisorConnectionError;

  /// No description provided for @advisorPortalClosed.
  ///
  /// In pt, this message translates to:
  /// **'O portal místico está temporariamente fechado. Tente novamente em alguns minutos.'**
  String get advisorPortalClosed;

  /// No description provided for @advisorWisdomTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sabedoria do Conselheiro'**
  String get advisorWisdomTitle;

  /// No description provided for @advisorIntro.
  ///
  /// In pt, this message translates to:
  /// **'Faça uma pergunta sobre bruxaria, magia ou misticismo, e o conselheiro compartilhará sua sabedoria ancestral 🪄'**
  String get advisorIntro;

  /// No description provided for @advisorQuestionHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Qual a melhor fase da lua para um ritual de proteção?'**
  String get advisorQuestionHint;

  /// No description provided for @advisorConsultingStars.
  ///
  /// In pt, this message translates to:
  /// **'Consultando os astros...'**
  String get advisorConsultingStars;

  /// No description provided for @advisorConsult.
  ///
  /// In pt, this message translates to:
  /// **'Consultar o Conselheiro'**
  String get advisorConsult;

  /// No description provided for @advisorRemainingToday.
  ///
  /// In pt, this message translates to:
  /// **'Consultas restantes hoje: {used}'**
  String advisorRemainingToday(String used);

  /// No description provided for @advisorAnswers.
  ///
  /// In pt, this message translates to:
  /// **'O Conselheiro responde'**
  String get advisorAnswers;

  /// No description provided for @spellGroupProtection.
  ///
  /// In pt, this message translates to:
  /// **'Proteção & Limpeza'**
  String get spellGroupProtection;

  /// No description provided for @spellGroupProtectionSub.
  ///
  /// In pt, this message translates to:
  /// **'Defesa, banimento e purificação'**
  String get spellGroupProtectionSub;

  /// No description provided for @spellGroupLove.
  ///
  /// In pt, this message translates to:
  /// **'Amor & Laços'**
  String get spellGroupLove;

  /// No description provided for @spellGroupLoveSub.
  ///
  /// In pt, this message translates to:
  /// **'Amor, autoestima e amizade'**
  String get spellGroupLoveSub;

  /// No description provided for @spellGroupProsperity.
  ///
  /// In pt, this message translates to:
  /// **'Prosperidade & Caminhos'**
  String get spellGroupProsperity;

  /// No description provided for @spellGroupProsperitySub.
  ///
  /// In pt, this message translates to:
  /// **'Abundância, sorte, trabalho e estudos'**
  String get spellGroupProsperitySub;

  /// No description provided for @spellGroupDreams.
  ///
  /// In pt, this message translates to:
  /// **'Sonhos & Visões'**
  String get spellGroupDreams;

  /// No description provided for @spellGroupDreamsSub.
  ///
  /// In pt, this message translates to:
  /// **'Adivinhação, sonhos e sabedoria'**
  String get spellGroupDreamsSub;

  /// No description provided for @spellGroupEnergy.
  ///
  /// In pt, this message translates to:
  /// **'Energia & Cura'**
  String get spellGroupEnergy;

  /// No description provided for @spellGroupEnergySub.
  ///
  /// In pt, this message translates to:
  /// **'Vitalidade, cura e coragem'**
  String get spellGroupEnergySub;

  /// No description provided for @spellGroupCreation.
  ///
  /// In pt, this message translates to:
  /// **'Criação & Palavra'**
  String get spellGroupCreation;

  /// No description provided for @spellGroupCreationSub.
  ///
  /// In pt, this message translates to:
  /// **'Criatividade e comunicação'**
  String get spellGroupCreationSub;

  /// No description provided for @spellGroupHome.
  ///
  /// In pt, this message translates to:
  /// **'Lar & Cotidiano'**
  String get spellGroupHome;

  /// No description provided for @spellGroupHomeSub.
  ///
  /// In pt, this message translates to:
  /// **'Casa, família e o dia a dia'**
  String get spellGroupHomeSub;

  /// No description provided for @grimoireSearchSpells.
  ///
  /// In pt, this message translates to:
  /// **'Buscar feitiços...'**
  String get grimoireSearchSpells;

  /// No description provided for @grimoireMySpells.
  ///
  /// In pt, this message translates to:
  /// **'Meus Feitiços'**
  String get grimoireMySpells;

  /// No description provided for @grimoireMySpellsSub.
  ///
  /// In pt, this message translates to:
  /// **'Criações e registros pessoais'**
  String get grimoireMySpellsSub;

  /// No description provided for @grimoireNoSpellsFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum feitiço encontrado 🔍'**
  String get grimoireNoSpellsFound;

  /// No description provided for @grimoireAncestral.
  ///
  /// In pt, this message translates to:
  /// **'Ancestral'**
  String get grimoireAncestral;

  /// No description provided for @spellNew.
  ///
  /// In pt, this message translates to:
  /// **'Novo Feitiço'**
  String get spellNew;

  /// No description provided for @spellEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar Feitiço'**
  String get spellEdit;

  /// No description provided for @spellNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome do Feitiço *'**
  String get spellNameLabel;

  /// No description provided for @spellNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Proteção de Lar'**
  String get spellNameHint;

  /// No description provided for @commonRequired.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório'**
  String get commonRequired;

  /// No description provided for @spellPurposeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Propósito *'**
  String get spellPurposeLabel;

  /// No description provided for @spellPurposeHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Proteção, Amor Próprio, Prosperidade'**
  String get spellPurposeHint;

  /// No description provided for @spellTypeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de Feitiço *'**
  String get spellTypeLabel;

  /// No description provided for @spellCategoryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Categoria *'**
  String get spellCategoryLabel;

  /// No description provided for @spellMoonPhaseLabel.
  ///
  /// In pt, this message translates to:
  /// **'Fase da Lua (Opcional)'**
  String get spellMoonPhaseLabel;

  /// No description provided for @commonNone.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma'**
  String get commonNone;

  /// No description provided for @spellIngredientsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes'**
  String get spellIngredientsLabel;

  /// No description provided for @spellIngredientsHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite um ingrediente por linha'**
  String get spellIngredientsHint;

  /// No description provided for @spellHowToLabel.
  ///
  /// In pt, this message translates to:
  /// **'Como Realizar *'**
  String get spellHowToLabel;

  /// No description provided for @spellHowToHint.
  ///
  /// In pt, this message translates to:
  /// **'Descreva os passos do ritual'**
  String get spellHowToHint;

  /// No description provided for @spellDurationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Duração (em dias)'**
  String get spellDurationLabel;

  /// No description provided for @spellDurationHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: 3'**
  String get spellDurationHint;

  /// No description provided for @spellNotesLabel.
  ///
  /// In pt, this message translates to:
  /// **'Observações'**
  String get spellNotesLabel;

  /// No description provided for @spellNotesHint.
  ///
  /// In pt, this message translates to:
  /// **'Resultados, sensações, anotações...'**
  String get spellNotesHint;

  /// No description provided for @spellAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Feitiço'**
  String get spellAdd;

  /// No description provided for @spellFilterByCategory.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar por categoria'**
  String get spellFilterByCategory;

  /// No description provided for @spellAllCategories.
  ///
  /// In pt, this message translates to:
  /// **'Todas Categorias'**
  String get spellAllCategories;

  /// No description provided for @spellSourceAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get spellSourceAll;

  /// No description provided for @spellSourceMine.
  ///
  /// In pt, this message translates to:
  /// **'Meus'**
  String get spellSourceMine;

  /// No description provided for @spellSourceAncestral.
  ///
  /// In pt, this message translates to:
  /// **'Ancestrais'**
  String get spellSourceAncestral;

  /// No description provided for @spellLoading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando feitiços...'**
  String get spellLoading;

  /// No description provided for @spellNoneFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum feitiço encontrado'**
  String get spellNoneFound;

  /// No description provided for @spellNoAncestral.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum feitiço ancestral disponível'**
  String get spellNoAncestral;

  /// No description provided for @spellEmptyGrimoire.
  ///
  /// In pt, this message translates to:
  /// **'Seu grimório está vazio.\nComece adicionando seu primeiro feitiço!'**
  String get spellEmptyGrimoire;

  /// No description provided for @spellMoonPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Lua'**
  String get spellMoonPrefix;

  /// No description provided for @spellSavedToGrimoire.
  ///
  /// In pt, this message translates to:
  /// **'Feitiço salvo no seu grimório! ✨'**
  String get spellSavedToGrimoire;

  /// No description provided for @spellDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get spellDetails;

  /// No description provided for @spellSaveToGrimoire.
  ///
  /// In pt, this message translates to:
  /// **'Salvar no Grimório'**
  String get spellSaveToGrimoire;

  /// No description provided for @spellRecommendedMoon.
  ///
  /// In pt, this message translates to:
  /// **'Fase Lunar Recomendada'**
  String get spellRecommendedMoon;

  /// No description provided for @spellHowTo.
  ///
  /// In pt, this message translates to:
  /// **'Como Realizar'**
  String get spellHowTo;

  /// No description provided for @spellDurationDays.
  ///
  /// In pt, this message translates to:
  /// **'Duração: {duration}'**
  String spellDurationDays(String duration);

  /// No description provided for @spellDay.
  ///
  /// In pt, this message translates to:
  /// **'dia'**
  String get spellDay;

  /// No description provided for @spellDays.
  ///
  /// In pt, this message translates to:
  /// **'dias'**
  String get spellDays;

  /// No description provided for @spellCreatedAt.
  ///
  /// In pt, this message translates to:
  /// **'Criado em: {date}'**
  String spellCreatedAt(String date);

  /// No description provided for @spellUpdatedAt.
  ///
  /// In pt, this message translates to:
  /// **'Atualizado em: {date}'**
  String spellUpdatedAt(String date);

  /// No description provided for @spellDeleteConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Deseja realmente excluir o feitiço \"{name}\"?'**
  String spellDeleteConfirm(String name);

  /// No description provided for @recordDetails.
  ///
  /// In pt, this message translates to:
  /// **'Registro'**
  String get recordDetails;

  /// No description provided for @recordEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar Registro'**
  String get recordEditTitle;

  /// No description provided for @recordTitleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Título *'**
  String get recordTitleLabel;

  /// No description provided for @recordContentLabel.
  ///
  /// In pt, this message translates to:
  /// **'Sua página'**
  String get recordContentLabel;

  /// No description provided for @recordTitleRequired.
  ///
  /// In pt, this message translates to:
  /// **'Dê um título ao registro'**
  String get recordTitleRequired;

  /// No description provided for @recordContentRequired.
  ///
  /// In pt, this message translates to:
  /// **'Escreva algo antes de salvar'**
  String get recordContentRequired;

  /// No description provided for @recordUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Registro atualizado! ✨'**
  String get recordUpdated;

  /// No description provided for @recordDeleteConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Deseja realmente excluir o registro \"{name}\"?'**
  String recordDeleteConfirm(String name);

  /// No description provided for @aiSpellDescribeFirst.
  ///
  /// In pt, this message translates to:
  /// **'Descreva sua intenção primeiro'**
  String get aiSpellDescribeFirst;

  /// No description provided for @aiSpellDailyLimit.
  ///
  /// In pt, this message translates to:
  /// **'Você atingiu o limite diário de consultas. Volte amanhã ou seja Premium!'**
  String get aiSpellDailyLimit;

  /// No description provided for @aiSpellGenericError.
  ///
  /// In pt, this message translates to:
  /// **'O conselheiro não pôde manifestar o feitiço. Tente novamente mais tarde.'**
  String get aiSpellGenericError;

  /// No description provided for @aiSpellDescribeIntention.
  ///
  /// In pt, this message translates to:
  /// **'Descreva sua Intenção'**
  String get aiSpellDescribeIntention;

  /// No description provided for @aiSpellIntentionHelp.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhe o que você deseja manifestar. Quanto mais detalhes, mais poderoso será o feitiço!'**
  String get aiSpellIntentionHelp;

  /// No description provided for @aiSpellIntentionHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Quero atrair prosperidade financeira para pagar minhas contas e ter mais tranquilidade'**
  String get aiSpellIntentionHint;

  /// No description provided for @aiSpellManifesting.
  ///
  /// In pt, this message translates to:
  /// **'Manifestando...'**
  String get aiSpellManifesting;

  /// No description provided for @aiSpellManifest.
  ///
  /// In pt, this message translates to:
  /// **'Manifestar Feitiço ✨'**
  String get aiSpellManifest;

  /// No description provided for @aiSpellSeeDetails.
  ///
  /// In pt, this message translates to:
  /// **'Ver Detalhes'**
  String get aiSpellSeeDetails;

  /// No description provided for @learnUnlockPrevious.
  ///
  /// In pt, this message translates to:
  /// **'Complete a lição anterior para destravar esta.'**
  String get learnUnlockPrevious;

  /// No description provided for @learnLessonN.
  ///
  /// In pt, this message translates to:
  /// **'Lição {number} — {title}'**
  String learnLessonN(String number, String title);

  /// No description provided for @learnPageWritten.
  ///
  /// In pt, this message translates to:
  /// **'Página escrita: \"{title}\"'**
  String learnPageWritten(String title);

  /// No description provided for @learnPremiumLesson.
  ///
  /// In pt, this message translates to:
  /// **'Lição Premium'**
  String get learnPremiumLesson;

  /// No description provided for @learnCreatesPage.
  ///
  /// In pt, this message translates to:
  /// **'Cria a página: \"{title}\"'**
  String learnCreatesPage(String title);

  /// No description provided for @learnToFill.
  ///
  /// In pt, this message translates to:
  /// **'(a preencher)'**
  String get learnToFill;

  /// No description provided for @learnPageNote.
  ///
  /// In pt, this message translates to:
  /// **'Página do Grimório Vivo — {trail} · {lesson}'**
  String learnPageNote(String trail, String lesson);

  /// No description provided for @learnTrailBound.
  ///
  /// In pt, this message translates to:
  /// **'Trilha Encadernada!'**
  String get learnTrailBound;

  /// No description provided for @learnPageDone.
  ///
  /// In pt, this message translates to:
  /// **'Página escrita!'**
  String get learnPageDone;

  /// No description provided for @learnChapterBound.
  ///
  /// In pt, this message translates to:
  /// **'O capítulo \"{title}\" agora é um livro encadernado no seu grimório — escrito por você.'**
  String learnChapterBound(String title);

  /// No description provided for @learnNewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo título'**
  String get learnNewTitle;

  /// No description provided for @learnSoBeIt.
  ///
  /// In pt, this message translates to:
  /// **'Que assim seja ✨'**
  String get learnSoBeIt;

  /// No description provided for @learnStepTeaching.
  ///
  /// In pt, this message translates to:
  /// **'📜 Ensino'**
  String get learnStepTeaching;

  /// No description provided for @learnStepPractice.
  ///
  /// In pt, this message translates to:
  /// **'🕯️ Prática'**
  String get learnStepPractice;

  /// No description provided for @learnStepPage.
  ///
  /// In pt, this message translates to:
  /// **'✍️ A Página'**
  String get learnStepPage;

  /// No description provided for @learnGoToPractice.
  ///
  /// In pt, this message translates to:
  /// **'Ir para a prática'**
  String get learnGoToPractice;

  /// No description provided for @learnDidPractice.
  ///
  /// In pt, this message translates to:
  /// **'Fiz a prática (ou vou fazer hoje)'**
  String get learnDidPractice;

  /// No description provided for @learnWriteMyPage.
  ///
  /// In pt, this message translates to:
  /// **'Escrever minha página'**
  String get learnWriteMyPage;

  /// No description provided for @learnAnswerHelp.
  ///
  /// In pt, this message translates to:
  /// **'Responda com as suas palavras — o app monta a página e guarda no Meu Grimório. Ela é sua para sempre.'**
  String get learnAnswerHelp;

  /// No description provided for @learnPageTitleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Título da página'**
  String get learnPageTitleLabel;

  /// No description provided for @learnWriteHere.
  ///
  /// In pt, this message translates to:
  /// **'Escreva aqui…'**
  String get learnWriteHere;

  /// No description provided for @learnSealPage.
  ///
  /// In pt, this message translates to:
  /// **'Selar página no grimório'**
  String get learnSealPage;

  /// No description provided for @learnHomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aprenda escrevendo o seu grimório'**
  String get learnHomeTitle;

  /// No description provided for @learnHomeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Cada lição termina com uma página criada por você no Meu Grimório. Ao completar uma trilha, o capítulo é seu — escrito de próprio punho.'**
  String get learnHomeSubtitle;

  /// No description provided for @learnMaxTitle.
  ///
  /// In pt, this message translates to:
  /// **'Título máximo alcançado ✨'**
  String get learnMaxTitle;

  /// No description provided for @learnNextTitle.
  ///
  /// In pt, this message translates to:
  /// **'{pages} páginas escritas · próximo título: {title} ({xp} XP)'**
  String learnNextTitle(String pages, String title, String xp);

  /// No description provided for @learnBoundShort.
  ///
  /// In pt, this message translates to:
  /// **'Encadernada!'**
  String get learnBoundShort;

  /// No description provided for @learnPagesProgress.
  ///
  /// In pt, this message translates to:
  /// **'{done}/{total} páginas'**
  String learnPagesProgress(String done, String total);

  /// No description provided for @learnBoundVolume.
  ///
  /// In pt, this message translates to:
  /// **'📕 Volume encadernado — {count} páginas escritas por você'**
  String learnBoundVolume(String count);

  /// No description provided for @oracleDailyLimit.
  ///
  /// In pt, this message translates to:
  /// **'Você atingiu o limite diário de leituras. Volte amanhã ou seja Premium!'**
  String get oracleDailyLimit;

  /// No description provided for @oracleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cartas do Oráculo'**
  String get oracleTitle;

  /// No description provided for @oracleSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Receba orientação e mensagens do universo'**
  String get oracleSubtitle;

  /// No description provided for @oracleDrawing.
  ///
  /// In pt, this message translates to:
  /// **'Tirando cartas...'**
  String get oracleDrawing;

  /// No description provided for @oracleDraw.
  ///
  /// In pt, this message translates to:
  /// **'Tirar Cartas'**
  String get oracleDraw;

  /// No description provided for @oracleRemainingToday.
  ///
  /// In pt, this message translates to:
  /// **'Leituras restantes hoje: {used}'**
  String oracleRemainingToday(String used);

  /// No description provided for @oracleNewReading.
  ///
  /// In pt, this message translates to:
  /// **'Nova Leitura'**
  String get oracleNewReading;

  /// No description provided for @oracleYourReading.
  ///
  /// In pt, this message translates to:
  /// **'Sua Leitura'**
  String get oracleYourReading;

  /// No description provided for @pendulumUsedAll.
  ///
  /// In pt, this message translates to:
  /// **'Você já usou suas 3 consultas de hoje. Volte amanhã!'**
  String get pendulumUsedAll;

  /// No description provided for @pendulumAskFirst.
  ///
  /// In pt, this message translates to:
  /// **'Faça uma pergunta primeiro'**
  String get pendulumAskFirst;

  /// No description provided for @pendulumTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pêndulo'**
  String get pendulumTitle;

  /// No description provided for @pendulumConsult.
  ///
  /// In pt, this message translates to:
  /// **'Consultar o Pêndulo'**
  String get pendulumConsult;

  /// No description provided for @pendulumIntro.
  ///
  /// In pt, this message translates to:
  /// **'Faça perguntas de sim ou não. Concentre-se e confie na resposta.'**
  String get pendulumIntro;

  /// No description provided for @pendulumUnlimitedAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Consultas ilimitadas (Admin)'**
  String get pendulumUnlimitedAdmin;

  /// No description provided for @pendulumUsedComeBack.
  ///
  /// In pt, this message translates to:
  /// **'Consultas usadas ({used}/{total}) - volte amanhã'**
  String pendulumUsedComeBack(String used, String total);

  /// No description provided for @pendulumYourQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Sua Pergunta'**
  String get pendulumYourQuestion;

  /// No description provided for @pendulumQuestionHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Devo aceitar aquele emprego?'**
  String get pendulumQuestionHint;

  /// No description provided for @pendulumAsking.
  ///
  /// In pt, this message translates to:
  /// **'Consultando...'**
  String get pendulumAsking;

  /// No description provided for @pendulumAsk.
  ///
  /// In pt, this message translates to:
  /// **'Perguntar'**
  String get pendulumAsk;

  /// No description provided for @pendulumNewConsult.
  ///
  /// In pt, this message translates to:
  /// **'Nova Consulta'**
  String get pendulumNewConsult;

  /// No description provided for @pendulumYes.
  ///
  /// In pt, this message translates to:
  /// **'SIM'**
  String get pendulumYes;

  /// No description provided for @pendulumNo.
  ///
  /// In pt, this message translates to:
  /// **'NÃO'**
  String get pendulumNo;

  /// No description provided for @pendulumMaybe.
  ///
  /// In pt, this message translates to:
  /// **'TALVEZ'**
  String get pendulumMaybe;

  /// No description provided for @runesNoQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Sem pergunta'**
  String get runesNoQuestion;

  /// No description provided for @runesReadingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Leitura de Runas'**
  String get runesReadingTitle;

  /// No description provided for @runesReadingIntro.
  ///
  /// In pt, this message translates to:
  /// **'As runas são símbolos do alfabeto rúnico nórdico usado para adivinhação. Cada runa pode aparecer em posição normal ou invertida (quando aplicável), mudando seu significado.'**
  String get runesReadingIntro;

  /// No description provided for @runesReversedNote.
  ///
  /// In pt, this message translates to:
  /// **'Runas Invertidas: Quando uma runa aparece de cabeça para baixo, geralmente indica bloqueios ou aspectos desafiadores do significado original.'**
  String get runesReversedNote;

  /// No description provided for @runesChooseLayout.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um Layout'**
  String get runesChooseLayout;

  /// No description provided for @runesQuestionOptional.
  ///
  /// In pt, this message translates to:
  /// **'Sua Pergunta (opcional)'**
  String get runesQuestionOptional;

  /// No description provided for @runesQuestionHint.
  ///
  /// In pt, this message translates to:
  /// **'O que as runas devem revelar?'**
  String get runesQuestionHint;

  /// No description provided for @runesDrawing.
  ///
  /// In pt, this message translates to:
  /// **'Tirando runas...'**
  String get runesDrawing;

  /// No description provided for @runesDraw.
  ///
  /// In pt, this message translates to:
  /// **'Tirar Runas'**
  String get runesDraw;

  /// No description provided for @runesReversed.
  ///
  /// In pt, this message translates to:
  /// **'Invertida'**
  String get runesReversed;

  /// No description provided for @runesListTitle.
  ///
  /// In pt, this message translates to:
  /// **'Runas'**
  String get runesListTitle;

  /// No description provided for @runesAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre as Runas'**
  String get runesAbout;

  /// No description provided for @runesAboutText.
  ///
  /// In pt, this message translates to:
  /// **'As runas são um alfabeto antigo usado pelos povos germânicos e nórdicos. Além de escrita, cada runa carrega significados simbólicos profundos e pode ser usada para reflexão, autoconhecimento e leitura oracular.'**
  String get runesAboutText;

  /// No description provided for @runesExplore.
  ///
  /// In pt, this message translates to:
  /// **'Explore as 24 runas do Futhark Antigo abaixo. Toque em cada uma para conhecer seu significado.'**
  String get runesExplore;

  /// No description provided for @runesElderFuthark.
  ///
  /// In pt, this message translates to:
  /// **'Futhark Antigo'**
  String get runesElderFuthark;

  /// No description provided for @runesKeywords.
  ///
  /// In pt, this message translates to:
  /// **'Palavras-chave'**
  String get runesKeywords;

  /// No description provided for @runesMeaning.
  ///
  /// In pt, this message translates to:
  /// **'Significado'**
  String get runesMeaning;

  /// No description provided for @runesRemember.
  ///
  /// In pt, this message translates to:
  /// **'Lembre-se: as runas são ferramentas de reflexão e autoconhecimento. Use-as como um ponto de partida para explorar suas próprias percepções e intuições.'**
  String get runesRemember;

  /// No description provided for @astroMysticTitle.
  ///
  /// In pt, this message translates to:
  /// **'Astrologia Mística'**
  String get astroMysticTitle;

  /// No description provided for @astroMysticSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Descubra seu mapa astral e perfil mágico personalizado'**
  String get astroMysticSubtitle;

  /// No description provided for @astroZodiacSigns.
  ///
  /// In pt, this message translates to:
  /// **'Signos do Zodíaco'**
  String get astroZodiacSigns;

  /// No description provided for @astroZodiacSignsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Conheça os 12 signos e seus significados mágicos'**
  String get astroZodiacSignsDesc;

  /// No description provided for @astroBirthChart.
  ///
  /// In pt, this message translates to:
  /// **'Mapa Astral'**
  String get astroBirthChart;

  /// No description provided for @astroSeeChart.
  ///
  /// In pt, this message translates to:
  /// **'Ver seu mapa astral completo'**
  String get astroSeeChart;

  /// No description provided for @astroCreateChart.
  ///
  /// In pt, this message translates to:
  /// **'Criar seu mapa astral'**
  String get astroCreateChart;

  /// No description provided for @astroMagicMirror.
  ///
  /// In pt, this message translates to:
  /// **'Espelho mágico'**
  String get astroMagicMirror;

  /// No description provided for @astroMagicalProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil Mágico'**
  String get astroMagicalProfile;

  /// No description provided for @astroMagicalProfileDesc.
  ///
  /// In pt, this message translates to:
  /// **'Interpretação astrológica para bruxaria'**
  String get astroMagicalProfileDesc;

  /// No description provided for @astroDailyWeather.
  ///
  /// In pt, this message translates to:
  /// **'Clima Mágico Diário'**
  String get astroDailyWeather;

  /// No description provided for @astroDailyWeatherDesc.
  ///
  /// In pt, this message translates to:
  /// **'Trânsitos planetários e energia do dia'**
  String get astroDailyWeatherDesc;

  /// No description provided for @astroSuggestions.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões Personalizadas'**
  String get astroSuggestions;

  /// No description provided for @astroSuggestionsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Práticas baseadas nos seus trânsitos'**
  String get astroSuggestionsDesc;

  /// No description provided for @astroRecalculate.
  ///
  /// In pt, this message translates to:
  /// **'Recalcular Mapa'**
  String get astroRecalculate;

  /// No description provided for @astroRecalculateDesc.
  ///
  /// In pt, this message translates to:
  /// **'Criar novo mapa astral'**
  String get astroRecalculateDesc;

  /// No description provided for @astroAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre a Astrologia'**
  String get astroAbout;

  /// No description provided for @astroAboutText.
  ///
  /// In pt, this message translates to:
  /// **'Seu mapa astral é calculado com base na posição dos planetas no momento e local do seu nascimento. O perfil mágico interpreta essas posições de forma específica para práticas de bruxaria.'**
  String get astroAboutText;

  /// No description provided for @astroHaveOnHand.
  ///
  /// In pt, this message translates to:
  /// **'Para melhores resultados, tenha em mãos:'**
  String get astroHaveOnHand;

  /// No description provided for @astroBirthDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de nascimento'**
  String get astroBirthDate;

  /// No description provided for @astroBirthTime.
  ///
  /// In pt, this message translates to:
  /// **'Hora exata de nascimento'**
  String get astroBirthTime;

  /// No description provided for @astroBirthPlace.
  ///
  /// In pt, this message translates to:
  /// **'Local de nascimento (cidade e país)'**
  String get astroBirthPlace;

  /// No description provided for @astroRecalcTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recalcular Mapa Astral?'**
  String get astroRecalcTitle;

  /// No description provided for @astroRecalcConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Isso irá substituir seu mapa astral atual. Você tem certeza?'**
  String get astroRecalcConfirm;

  /// No description provided for @chartInvalidDate.
  ///
  /// In pt, this message translates to:
  /// **'Data inválida'**
  String get chartInvalidDate;

  /// No description provided for @chartInvalidTime.
  ///
  /// In pt, this message translates to:
  /// **'Hora inválida'**
  String get chartInvalidTime;

  /// No description provided for @chartPlaceNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Local não encontrado'**
  String get chartPlaceNotFound;

  /// No description provided for @chartCalcError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao calcular mapa'**
  String get chartCalcError;

  /// No description provided for @chartCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar Mapa Astral'**
  String get chartCreateTitle;

  /// No description provided for @chartYourChart.
  ///
  /// In pt, this message translates to:
  /// **'Seu Mapa Astral'**
  String get chartYourChart;

  /// No description provided for @chartIntro.
  ///
  /// In pt, this message translates to:
  /// **'Para calcular seu mapa natal preciso, precisamos de sua data, hora e local de nascimento. Quanto mais preciso, melhor!'**
  String get chartIntro;

  /// No description provided for @chartBirthDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de Nascimento'**
  String get chartBirthDate;

  /// No description provided for @chartDateFormat.
  ///
  /// In pt, this message translates to:
  /// **'Digite no formato dd/mm/aaaa'**
  String get chartDateFormat;

  /// No description provided for @chartDateHint.
  ///
  /// In pt, this message translates to:
  /// **'dd/mm/aaaa'**
  String get chartDateHint;

  /// No description provided for @chartBirthTime.
  ///
  /// In pt, this message translates to:
  /// **'Hora de Nascimento'**
  String get chartBirthTime;

  /// No description provided for @chartTimeImportant.
  ///
  /// In pt, this message translates to:
  /// **'A hora exata é importante para calcular o Ascendente e as Casas.'**
  String get chartTimeImportant;

  /// No description provided for @chartDontKnowTime.
  ///
  /// In pt, this message translates to:
  /// **'Não sei a hora exata'**
  String get chartDontKnowTime;

  /// No description provided for @chartBirthPlace.
  ///
  /// In pt, this message translates to:
  /// **'Local de Nascimento'**
  String get chartBirthPlace;

  /// No description provided for @chartTypeToSearch.
  ///
  /// In pt, this message translates to:
  /// **'Digite pelo menos 3 caracteres para buscar'**
  String get chartTypeToSearch;

  /// No description provided for @chartPlaceHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: São Paulo, Brasil'**
  String get chartPlaceHint;

  /// No description provided for @chartCalculate.
  ///
  /// In pt, this message translates to:
  /// **'Calcular Mapa Astral ✨'**
  String get chartCalculate;

  /// No description provided for @chartNoonNote.
  ///
  /// In pt, this message translates to:
  /// **'Sem a hora exata, usaremos meio-dia (12:00) e o sistema de casas iguais.'**
  String get chartNoonNote;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha manualmente o idioma do app'**
  String get settingsLanguageSubtitle;

  /// No description provided for @quizTitle.
  ///
  /// In pt, this message translates to:
  /// **'Teste de Arquétipo'**
  String get quizTitle;

  /// No description provided for @quizProgress.
  ///
  /// In pt, this message translates to:
  /// **'{current} de {total}'**
  String quizProgress(String current, String total);

  /// No description provided for @quizYourArchetypeIs.
  ///
  /// In pt, this message translates to:
  /// **'Seu arquétipo é'**
  String get quizYourArchetypeIs;

  /// No description provided for @quizSeeInEncyclopedia.
  ///
  /// In pt, this message translates to:
  /// **'Ver na Enciclopédia'**
  String get quizSeeInEncyclopedia;

  /// No description provided for @quizRetake.
  ///
  /// In pt, this message translates to:
  /// **'Refazer o teste'**
  String get quizRetake;

  /// No description provided for @quizStrongestEnergies.
  ///
  /// In pt, this message translates to:
  /// **'Suas energias mais fortes'**
  String get quizStrongestEnergies;

  /// No description provided for @quizMirrorNote.
  ///
  /// In pt, this message translates to:
  /// **'Arquétipos são espelhos, não gavetas: você carrega vários — este é o que vibra mais alto em você agora. Explore os outros na aba Arquétipos da Enciclopédia.'**
  String get quizMirrorNote;

  /// No description provided for @quizSavedOn.
  ///
  /// In pt, this message translates to:
  /// **'Resultado do seu último teste ({date})'**
  String quizSavedOn(String date);

  /// No description provided for @tarotLibraryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Biblioteca de Cartas'**
  String get tarotLibraryTitle;

  /// No description provided for @tarotLibraryDesc.
  ///
  /// In pt, this message translates to:
  /// **'As 78 cartas com imagem, significado e leitura invertida'**
  String get tarotLibraryDesc;

  /// No description provided for @tarotFlipCard.
  ///
  /// In pt, this message translates to:
  /// **'Inverter carta'**
  String get tarotFlipCard;

  /// No description provided for @tarotUnflipCard.
  ///
  /// In pt, this message translates to:
  /// **'Posição normal'**
  String get tarotUnflipCard;

  /// No description provided for @tarotUprightMeaning.
  ///
  /// In pt, this message translates to:
  /// **'Significado'**
  String get tarotUprightMeaning;

  /// No description provided for @tarotReversedMeaning.
  ///
  /// In pt, this message translates to:
  /// **'Significado invertido'**
  String get tarotReversedMeaning;

  /// No description provided for @grimoireMyRecords.
  ///
  /// In pt, this message translates to:
  /// **'Meus Registros'**
  String get grimoireMyRecords;

  /// No description provided for @grimoireMyRecordsSub.
  ///
  /// In pt, this message translates to:
  /// **'Páginas do Grimório Vivo, estudos e reflexões'**
  String get grimoireMyRecordsSub;

  /// No description provided for @grimoireNoRecords.
  ///
  /// In pt, this message translates to:
  /// **'Suas páginas do Grimório Vivo e registros aparecerão aqui.'**
  String get grimoireNoRecords;

  /// No description provided for @learnFillAtLeastOne.
  ///
  /// In pt, this message translates to:
  /// **'Responda pelo menos uma pergunta antes de selar a página'**
  String get learnFillAtLeastOne;

  /// No description provided for @learnOpenTool.
  ///
  /// In pt, this message translates to:
  /// **'Abrir {tool}'**
  String learnOpenTool(String tool);

  /// No description provided for @learnToolHint.
  ///
  /// In pt, this message translates to:
  /// **'Esta lição usa uma ferramenta do app — abra por aqui e depois volte para escrever a página.'**
  String get learnToolHint;

  /// No description provided for @learnSavesTo.
  ///
  /// In pt, this message translates to:
  /// **'Esta página será guardada em: {place}'**
  String learnSavesTo(String place);

  /// No description provided for @learnPlaceDreams.
  ///
  /// In pt, this message translates to:
  /// **'Diário de Sonhos'**
  String get learnPlaceDreams;

  /// No description provided for @learnPlaceGratitude.
  ///
  /// In pt, this message translates to:
  /// **'Diário de Gratidão'**
  String get learnPlaceGratitude;

  /// No description provided for @learnPlaceAffirmations.
  ///
  /// In pt, this message translates to:
  /// **'Afirmações'**
  String get learnPlaceAffirmations;

  /// No description provided for @learnPlaceDesires.
  ///
  /// In pt, this message translates to:
  /// **'Diário de Desejos'**
  String get learnPlaceDesires;

  /// No description provided for @learnSection1.
  ///
  /// In pt, this message translates to:
  /// **'Fundamento'**
  String get learnSection1;

  /// No description provided for @learnSection2.
  ///
  /// In pt, this message translates to:
  /// **'Aprofundando'**
  String get learnSection2;

  /// No description provided for @learnSection3.
  ///
  /// In pt, this message translates to:
  /// **'Na prática'**
  String get learnSection3;

  /// No description provided for @learnSection4.
  ///
  /// In pt, this message translates to:
  /// **'Para levar consigo'**
  String get learnSection4;
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
