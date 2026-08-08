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
  String get navEncyclopedia => 'Grimoire';

  @override
  String get navGrimoire => 'Tools';

  @override
  String get navDiaries => 'Diaries';

  @override
  String get grimoirePageTitle => 'Tools';

  @override
  String get grimoireTabAstrology => 'Mystic Astrology';

  @override
  String get grimoireTabTools => 'Magical Tools';

  @override
  String get grimoireTabMyGrimoire => 'My Grimoire';

  @override
  String get encyMyGrimoireIntro => 'Your spells, gathered by intent — create, keep and revisit your magic';

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
  String get encyclopediaPageTitle => 'Grimoire';

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
  String get commonBackAgainToExit => 'Press back again to exit';

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

  @override
  String get toolLivingGrimoireTitle => 'Living Grimoire';

  @override
  String get toolLivingGrimoireDesc =>
      'Learning trails: every lesson becomes a page of your own';

  @override
  String get toolTarotTitle => 'Tarot';

  @override
  String get toolTarotDesc => 'Spreads, card of the day and learning tutor';

  @override
  String get toolArchetypeTitle => 'Archetype Quiz';

  @override
  String get toolArchetypeDesc =>
      'Discover which archetype vibrates strongest in you';

  @override
  String get toolPalmistryTitle => 'Palm Reading';

  @override
  String get toolPalmistryDesc => 'Palmistry through the palm of your hand';

  @override
  String get commonClose => 'Close';

  @override
  String get premiumBePremium => 'Go Premium';

  @override
  String get premiumUnlock => 'Unlock Premium';

  @override
  String get premiumContentLabel => 'Premium content';

  @override
  String get premiumUpgradeAction => 'Upgrade';

  @override
  String get premiumPlansUnavailable => 'Plans are temporarily unavailable';

  @override
  String get premiumActivated => 'Premium activated successfully!';

  @override
  String get premiumPurchaseFailed => 'The purchase could not be completed';

  @override
  String get premiumHeroAccess => 'UNLOCK';

  @override
  String get premiumHeroPower => 'THE FULL POWER';

  @override
  String get premiumHeroMagic => 'OF YOUR MAGIC';

  @override
  String get premiumHeroTagline1 => 'More knowledge, more guidance and more ';

  @override
  String get premiumHeroTaglineHighlight => 'connection';

  @override
  String get premiumHeroTagline2 => ' with your path';

  @override
  String get premiumCatSemantic => 'Pocket Grimoire magic cat';

  @override
  String get premiumBenefitAdvisor => 'Unlimited Mystic Advisor';

  @override
  String get premiumBenefitEncyclopedia => 'Encyclopedia with full content';

  @override
  String get premiumBenefitDailyClimate => 'Personalized Daily Magic Weather';

  @override
  String get premiumBenefitUnlimitedReadings =>
      'Unlimited Runes, Oracle and Sigil readings';

  @override
  String get premiumBenefitCloudSync => 'Sync across devices';

  @override
  String get premiumPlanMonthly => 'Monthly';

  @override
  String get premiumPlanYearly => 'Yearly';

  @override
  String get premiumPerMonth => '/month';

  @override
  String get premiumPerYear => '/year';

  @override
  String get premiumSave33 => 'Save 33%';

  @override
  String get premiumTagSelected => 'SELECTED';

  @override
  String get premiumTagPopular => 'POPULAR';

  @override
  String premiumPlanSemantics(String title, String price, String period) {
    return '$title plan, $price $period';
  }

  @override
  String get premiumStartNow => 'Start Now';

  @override
  String get premiumCancelAnytime => 'Cancel anytime';

  @override
  String get premiumSecurePayment => 'Secure payment';

  @override
  String get premiumDataProtected => 'Your data protected';

  @override
  String get authWelcomeBack => 'Welcome back!';

  @override
  String get authLoginSubtitle => 'Log in to access your grimoire';

  @override
  String get authForgotPassword => 'I forgot my password';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'you@email.com';

  @override
  String get authEmailRequired => 'Please enter your email';

  @override
  String get authEmailInvalid => 'Please enter a valid email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordRequired => 'Please enter your password';

  @override
  String get authPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get authOrContinueWith => 'or continue with';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authSystemNotConfigured =>
      'Authentication system not configured. Please contact support.';

  @override
  String get authLoginError => 'Error logging in';

  @override
  String get authSocialUnavailable => 'Social login is unavailable right now';

  @override
  String get authGoogleError => 'Error signing in with Google';

  @override
  String get authSignupSubtitle => 'Begin your magical journey';

  @override
  String get authNameLabel => 'Name';

  @override
  String get authNameHint => 'Your magical name';

  @override
  String get authNameRequired => 'Please enter your name';

  @override
  String get authNameMinLength => 'Name must be at least 2 characters';

  @override
  String get authPasswordHintMin => 'At least 6 characters';

  @override
  String get authPasswordCreateRequired => 'Please enter a password';

  @override
  String get authConfirmPasswordLabel => 'Confirm Password';

  @override
  String get authConfirmPasswordHint => 'Type the password again';

  @override
  String get authConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get authPasswordsDontMatch => 'Passwords don\'t match';

  @override
  String get authTermsPrefix => 'I have read and accept the ';

  @override
  String get authTermsOfUse => 'Terms of Use';

  @override
  String get authTermsAnd => ' and the ';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get authOrSignupWith => 'or sign up with';

  @override
  String get authHaveAccount => 'Already have an account? ';

  @override
  String get authMustAcceptTerms => 'You must accept the terms of use';

  @override
  String get authSignupError => 'Error creating account';

  @override
  String get authEmailInUse => 'This email is already in use';

  @override
  String get authEmailInvalidShort => 'Invalid email';

  @override
  String get authSignupSuccess => 'Account created! Welcome to the Grimoire!';

  @override
  String get authGoogleSignupUnavailable =>
      'Google sign-up is unavailable right now';

  @override
  String get authGoogleSignupError => 'Error signing up with Google';

  @override
  String get welcomeSubtitle => 'Your magical journey starts here';

  @override
  String get welcomeFeatureLunar => 'Lunar Calendar';

  @override
  String get welcomeFeatureGrimoire => 'Digital Grimoire';

  @override
  String get welcomeFeatureDiaries => 'Magical Diaries';

  @override
  String get welcomeFeatureAstrology => 'Astrology';

  @override
  String get welcomeHaveAccount => 'I already have an account';

  @override
  String get forgotEmailSent => 'Email Sent!';

  @override
  String forgotEmailSentTo(String email) {
    return 'We sent a recovery link to\n$email';
  }

  @override
  String get forgotCheckInbox => 'Check your inbox and spam folder.';

  @override
  String get forgotBackToLogin => 'Back to Login';

  @override
  String get forgotResend => 'Didn\'t receive it? Send again';

  @override
  String get forgotTitle => 'Forgot your password?';

  @override
  String get forgotSubtitle =>
      'No problem! Enter your email and we\'ll send you a link to create a new password.';

  @override
  String get forgotSendLink => 'Send Recovery Link';

  @override
  String get forgotRemembered => 'Remembered your password? ';

  @override
  String get forgotBackToLoginLower => 'Back to login';

  @override
  String get forgotSendError => 'Error sending email';

  @override
  String get forgotResendError => 'Error resending email';

  @override
  String get forgotResendSuccess => 'Email resent successfully!';

  @override
  String get forgotResendErrorPrefix => 'Error resending';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordHeader => 'New Password';

  @override
  String get changePasswordSubtitle =>
      'Enter your current password and choose a new one';

  @override
  String get changePasswordCurrentLabel => 'Current Password';

  @override
  String get changePasswordCurrentRequired =>
      'Please enter your current password';

  @override
  String get changePasswordNewLabel => 'New Password';

  @override
  String get changePasswordNewRequired => 'Please enter a new password';

  @override
  String get changePasswordMustDiffer =>
      'The new password must be different from the current one';

  @override
  String get changePasswordConfirmLabel => 'Confirm New Password';

  @override
  String get changePasswordConfirmHint => 'Type the new password again';

  @override
  String get changePasswordConfirmRequired =>
      'Please confirm your new password';

  @override
  String get changePasswordError => 'Error changing password';

  @override
  String get changePasswordSuccess => 'Password changed successfully!';

  @override
  String get changePasswordWrongCurrent => 'Current password is incorrect';

  @override
  String get onbSlide1Title => 'Your Digital Grimoire';

  @override
  String get onbSlide1Desc =>
      'Keep your spells, rituals and magical recipes in one place. Organize by moon phase, ingredients and much more.';

  @override
  String get onbSlide2Title => 'Lunar Calendar';

  @override
  String get onbSlide2Desc =>
      'Follow the moon phases and discover the best moment for each kind of magic. Get notified on full and new moons.';

  @override
  String get onbSlide3Title => 'Magical Diaries';

  @override
  String get onbSlide3Desc =>
      'Record dreams, desires, gratitude and affirmations. Follow your spiritual growth day by day.';

  @override
  String get onbSlide4Title => 'Complete Astrology';

  @override
  String get onbSlide4Desc =>
      'Discover your birth chart, personalized magical profile and daily forecasts based on planetary transits.';

  @override
  String get onbSlide5Title => 'Ready to Begin?';

  @override
  String get onbSlide5Desc =>
      'Create your account to sync your data across devices and get full access to all features.';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbHaveAccount => 'I already have an account';

  @override
  String get onbNext => 'Next';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileAnonymous => 'Anonymous Witch';

  @override
  String get profileEditName => 'Edit Name';

  @override
  String get profileFreePlan => 'Free Plan';

  @override
  String get profilePremiumPlan => 'Premium Plan';

  @override
  String get profileFreePlanDesc => 'Some features are limited';

  @override
  String get profilePremiumPlanDesc => 'Full access to all features';

  @override
  String get profileUpgrade => 'Upgrade';

  @override
  String get profileFreeUsage => 'Free Plan Usage';

  @override
  String get profileSpells => 'Spells';

  @override
  String get profileDiaryEntries => 'Diary Entries';

  @override
  String get profileThisMonth => 'this month';

  @override
  String get profileMysticAdvisor => 'Mystic Advisor';

  @override
  String get profileToday => 'today';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileManageSubscription => 'Manage Subscription';

  @override
  String get profileMagicalStats => 'Magical Statistics';

  @override
  String get profileMagicalJourneys => 'Magical Journeys';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileAboutApp => 'About the App';

  @override
  String get profileLogout => 'Log Out';

  @override
  String get profileLogoutConfirm =>
      'Are you sure you want to log out?\nYour local data will be kept.';

  @override
  String get profileLogoutAction => 'Log Out';

  @override
  String get profileNotificationsSoon =>
      'Notification settings are coming soon!\n\nYou\'ll be able to customize alerts for:\n• Ritual reminders\n• Moon phases\n• Special magical dates';

  @override
  String get profileSupportEmail => 'Support Email';

  @override
  String get profileFaq => 'Frequently asked questions';

  @override
  String get profilePrivacySafe => 'Your data is safe';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutDescription =>
      'Your companion for magical practice, rituals and self-knowledge through astrology and modern witchcraft.';

  @override
  String get aboutMadeWith => 'Made with 🔮 and ✨';

  @override
  String get editBasicInfo => 'Basic Information';

  @override
  String get editNameUpdated => 'Name updated!';

  @override
  String get editGenderSection => 'Gender';

  @override
  String get editGenderHelp =>
      'How should the app address you? We use this choice in personalized texts and in the Mystic Advisor\'s replies.';

  @override
  String get editSecurity => 'Security';

  @override
  String get editChangePasswordSubtitle => 'Change your access password';

  @override
  String get editDataCollection => 'Data Collection';

  @override
  String get editAnalytics => 'Analytics';

  @override
  String get editAnalyticsSubtitle =>
      'Help improve the app by sharing anonymous usage data';

  @override
  String get editCrashReports => 'Error Reports';

  @override
  String get editCrashReportsSubtitle =>
      'Send automatic reports when the app has problems';

  @override
  String get editPersonalizedContent => 'Personalized Content';

  @override
  String get editPersonalizedContentSubtitle =>
      'Receive suggestions based on your app usage';

  @override
  String get editSyncBackup => 'Sync and Backup';

  @override
  String get editSyncBackupCloud => 'Cloud Sync and Backup';

  @override
  String get editSyncBackupOn =>
      'Keep your data protected and synced across devices';

  @override
  String get editSyncPremiumOnly => 'Premium-exclusive feature';

  @override
  String get editManageData => 'Manage Your Data';

  @override
  String get editExportData => 'Export My Data';

  @override
  String get editExportDataSubtitle => 'Download a copy of all your data';

  @override
  String get editClearLocal => 'Clear Local Data';

  @override
  String get editClearLocalSubtitle => 'Remove data saved on this device';

  @override
  String get editDeleteAccount => 'Delete My Account';

  @override
  String get editDeleteAccountSubtitle => 'Permanently remove all your data';

  @override
  String get genderFeminine => 'Feminine';

  @override
  String get genderMasculine => 'Masculine';

  @override
  String get genderNeutral => 'Neutral';

  @override
  String get editNotInformed => 'Not provided';

  @override
  String get editPrivacyMatters => 'Your Privacy Matters';

  @override
  String get editPrivacyNote =>
      'Your magical data is sacred. We never sell your personal information and you have full control over what is collected and stored.';

  @override
  String get editNewPasswordMin =>
      'The new password must be at least 6 characters';

  @override
  String get editErrorPrefix => 'Error';

  @override
  String get editChangeAction => 'Change';

  @override
  String get editExportTitle => 'Export Data';

  @override
  String get editExportConfirm =>
      'Your data will be exported in JSON format. This may take a few seconds.';

  @override
  String get editExportAction => 'Export';

  @override
  String get editExporting => 'Exporting data...';

  @override
  String get editExportSuccess => 'Data exported successfully!';

  @override
  String get editExportError => 'Error exporting';

  @override
  String get editClearLocalTitle => 'Clear Local Data?';

  @override
  String get editClearLocalConfirm =>
      'This will remove all data saved on this device. If sync is enabled, your cloud data will be kept.';

  @override
  String get editClearAction => 'Clear';

  @override
  String get editClearSuccess => 'Local data removed successfully';

  @override
  String get editClearError => 'Error clearing data';

  @override
  String get editDeleteTitle => 'Delete Account';

  @override
  String get editDeleteWarning =>
      'WARNING: This action is IRREVERSIBLE!\n\nAll your data will be permanently deleted, including:\n- Spells and rituals\n- Diary entries\n- Birth chart\n- Settings\n\nAre you absolutely sure?';

  @override
  String get editDeletePermanently => 'Delete Permanently';

  @override
  String get editDeleting => 'Deleting account...';

  @override
  String get editDeleteError => 'Error deleting account';

  @override
  String get editDeleteSuccess => 'Account deleted successfully';

  @override
  String get editDeleteErrorPrefix => 'Error deleting account';

  @override
  String get editPremiumFeature => 'Premium Feature';

  @override
  String get editSyncPremiumPitch =>
      'Cloud data sync is an exclusive feature for Premium users.\n\nWith Premium, your data stays safe and synced across all your devices.';

  @override
  String get editNotNow => 'Not Now';

  @override
  String get settingsLifetime => 'Lifetime Subscription';

  @override
  String settingsRenewsOn(String date) {
    return 'Renews on: $date';
  }

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsNotifDesc => 'Set reminders for important magical events';

  @override
  String get settingsFullMoon => 'Full Moon';

  @override
  String get settingsFullMoonDesc => 'Reminder 1 day before the Full Moon';

  @override
  String get settingsNewMoon => 'New Moon';

  @override
  String get settingsNewMoonDesc => 'Reminder 1 day before the New Moon';

  @override
  String get settingsSabbats => 'Sabbats';

  @override
  String get settingsSabbatsDesc => 'Reminder 3 days before each Sabbat';

  @override
  String get settingsNotifMobileOnly =>
      'Notifications are only sent on mobile devices';

  @override
  String get settingsNotifUpdateError => 'Could not update notifications';

  @override
  String get settingsPaymentsNotConfigured => 'Payments Not Configured';

  @override
  String get settingsPaymentsNotConfiguredDesc =>
      'The payment system has not been configured in this version of the app.\n\nIf you\'re a developer, check the console logs for details.';

  @override
  String get commonUnderstood => 'Got it';

  @override
  String get settingsTermsSubtitle => 'The rules of our circle';

  @override
  String get monthJanShort => 'Jan';

  @override
  String get monthFebShort => 'Feb';

  @override
  String get monthMarShort => 'Mar';

  @override
  String get monthAprShort => 'Apr';

  @override
  String get monthMayShort => 'May';

  @override
  String get monthJunShort => 'Jun';

  @override
  String get monthJulShort => 'Jul';

  @override
  String get monthAugShort => 'Aug';

  @override
  String get monthSepShort => 'Sep';

  @override
  String get monthOctShort => 'Oct';

  @override
  String get monthNovShort => 'Nov';

  @override
  String get monthDecShort => 'Dec';

  @override
  String get diaryNewDream => 'New Dream';

  @override
  String get diaryEditDream => 'Edit Dream';

  @override
  String get diaryTitleLabel => 'Title';

  @override
  String get diaryDreamTitleHint => 'E.g.: Dream about butterflies';

  @override
  String get diaryDreamDate => 'Dream Date';

  @override
  String get diaryDreamDescLabel => 'Dream Description';

  @override
  String get diaryDreamDescHint => 'Describe your dream in detail';

  @override
  String get diaryTagsLabel => 'Tags';

  @override
  String get diaryDreamTagsHint => 'E.g.: nightmare, recurring, lucid';

  @override
  String get diaryTagsHelper => 'Separate tags with commas';

  @override
  String get diaryDreamFeelingLabel => 'How did you feel when you woke up?';

  @override
  String get diaryDreamFeelingHint => 'E.g.: Peace, fear, joy, confusion';

  @override
  String get diaryInterpretationHeader => '🔮 Interpretation';

  @override
  String get diarySaveDream => 'Save Dream';

  @override
  String get commonUpdate => 'Update';

  @override
  String get diaryFillTitleOrDesc =>
      'Fill in at least the title or the description';

  @override
  String get diaryFillTitleOrContent =>
      'Fill in at least the title or the content';

  @override
  String get commonNoTitle => 'Untitled';

  @override
  String get commonConfirmDelete => 'Confirm deletion';

  @override
  String get diaryDeleteDreamConfirm =>
      'Do you really want to delete this dream?';

  @override
  String get diaryNewGratitude => 'New Gratitude';

  @override
  String get diaryEditGratitude => 'Edit Gratitude';

  @override
  String get diaryGratitudeTitleHint => 'E.g.: Gratitude for today';

  @override
  String get commonDate => 'Date';

  @override
  String get diaryGratitudeLabel => 'What are you grateful for today?';

  @override
  String get diaryGratitudeHint => 'Describe what you\'re grateful for...';

  @override
  String get diaryGratitudeTagsHint => 'E.g.: family, health, work';

  @override
  String get diarySaveGratitude => 'Save Gratitude';

  @override
  String get diaryDeleteGratitudeTitle => 'Delete Gratitude';

  @override
  String get diaryDeleteGratitudeConfirm =>
      'Are you sure you want to delete this gratitude?';

  @override
  String get diaryNewDesire => 'New Desire';

  @override
  String get diaryEditDesire => 'Edit Desire';

  @override
  String get diaryDesireTitleHint => 'E.g.: Travel abroad';

  @override
  String get diaryDescLabel => 'Description';

  @override
  String get diaryDesireSigilImage => 'Sigil image';

  @override
  String get diaryDesireSigilTitle => 'Sigil 🔐';

  @override
  String get diaryDesireDescHint => 'Describe your desire in detail';

  @override
  String get diaryStatusLabel => 'Status';

  @override
  String get diaryDesireProgressLabel => 'What has moved forward?';

  @override
  String get diaryDesireProgressHint => 'Record how your desire is evolving';

  @override
  String get diarySaveDesire => 'Save Desire';

  @override
  String get diaryDeleteDesireConfirm =>
      'Do you really want to delete this desire?';

  @override
  String get diaryNewAffirmation => 'New Affirmation';

  @override
  String get diaryEditAffirmation => 'Edit Affirmation';

  @override
  String get diaryPreloadedAffirmationNote =>
      'Preloaded affirmations cannot be edited or deleted.';

  @override
  String get diaryAdvisorAffirmationPitch =>
      'Let the Mystic Advisor create a powerful affirmation for you';

  @override
  String get diaryContextOptional => 'Context (optional)';

  @override
  String get diaryContextHint => 'E.g.: I\'m starting a new job...';

  @override
  String get diaryContextHelper =>
      'Describe your situation for a personalized affirmation';

  @override
  String get diaryConsulting => 'Consulting...';

  @override
  String get diaryGenerateAffirmation => 'Generate Affirmation';

  @override
  String get diaryWriteOwnAffirmation => 'Or write your own affirmation:';

  @override
  String get diaryAffirmationLabel => 'Affirmation';

  @override
  String get diaryAffirmationHint =>
      'E.g.: I am worthy of abundance and prosperity';

  @override
  String get diaryAffirmationHelper =>
      'Write in the present tense and positively';

  @override
  String get diaryCategoryLabel => 'Category';

  @override
  String get diarySaveAffirmation => 'Save Affirmation';

  @override
  String diaryAffirmationsRemaining(String used) {
    return 'Affirmations left today: $used';
  }

  @override
  String get diaryAffirmationCreated =>
      'Affirmation created by the Mystic Advisor!';

  @override
  String get diaryAffirmationError => 'Error generating affirmation';

  @override
  String get diaryTypeOrGenerate => 'Type or generate an affirmation';

  @override
  String get diaryAffirmationLimit =>
      'You\'ve reached today\'s affirmation limit. Come back tomorrow or go Premium!';

  @override
  String get diaryDeleteAffirmationTitle => 'Delete Affirmation';

  @override
  String get diaryDeleteAffirmationConfirm =>
      'Are you sure you want to delete this affirmation?';

  @override
  String get diaryLoadingDreams => 'Loading dreams...';

  @override
  String get diaryEmptyDreams =>
      'You haven\'t recorded any dreams yet.\nStart your dream journal!';

  @override
  String get diaryRegisterDream => 'Record Dream';

  @override
  String get diaryInterpretDream => 'Interpret Dream';

  @override
  String get diaryDreamThemes => 'Dream Themes';

  @override
  String get toolDreamsTitle => 'Dream Interpretation';

  @override
  String get toolDreamsDesc =>
      'Unveil the messages of your dreams and explore meanings';

  @override
  String get dreamToolsIntro =>
      'Dreams speak in symbols. Interpret yours with the Mystic Advisor or explore the meanings of the most common themes.';

  @override
  String get dreamInterpretMyDream => 'Interpret my Dream';

  @override
  String get dreamInterpretMyDreamDesc =>
      'Tell your dream and receive a reading from the Mystic Advisor';

  @override
  String get dreamMeaningsTitle => 'Dream Meanings';

  @override
  String get dreamMeaningsDesc =>
      'Water, falling, flying, teeth and other dream themes — and their possible readings';

  @override
  String get diaryLoadingGratitudes => 'Loading gratitudes...';

  @override
  String get diaryEmptyGratitudes =>
      'You haven\'t recorded any gratitude yet.\nStart cultivating abundance in your life!';

  @override
  String get diaryAddGratitude => 'Add Gratitude';

  @override
  String get diaryLoadingDesires => 'Loading desires...';

  @override
  String get diaryEmptyDesires =>
      'You haven\'t recorded any desires yet.\nStart manifesting your dreams!';

  @override
  String get diaryAddDesire => 'Add Desire';

  @override
  String get diaryLoadingAffirmations => 'Loading affirmations...';

  @override
  String get diaryAllCategories => 'All';

  @override
  String get diaryEmptyAffirmationsCategory =>
      'No affirmations in this category.\nAdd your own affirmations!';

  @override
  String get diaryAddAffirmation => 'Add Affirmation';

  @override
  String get commonGoodMorning => 'Good morning ✨';

  @override
  String get commonGoodAfternoon => 'Good afternoon ✨';

  @override
  String get commonGoodEvening => 'Good evening ✨';

  @override
  String get diaryPreviousReflections => 'Previous reflections';

  @override
  String get diarySaveReflection => 'Save reflection';

  @override
  String get diaryFreeWritingHint => 'What\'s on your mind today?';

  @override
  String get diaryReflections => 'Reflections';

  @override
  String get diaryLoadingReflections => 'Loading reflections...';

  @override
  String get diaryEmptyReflections =>
      'Your reflections will appear here.\nWrite whatever is on your mind. ✨';

  @override
  String get diaryDeleteReflectionTitle => 'Delete reflection';

  @override
  String get diaryDeleteReflectionConfirm =>
      'Are you sure you want to delete this reflection?';

  @override
  String get diaryDreamThemesIntro =>
      'Each symbol carries many possible readings. Explore the most common themes and compare them with what you felt in the dream.';

  @override
  String get dreamDescribeFirst => 'Describe your dream first';

  @override
  String get dreamInterpretedTitle => 'Interpreted dream';

  @override
  String get dreamNotesPrefix => 'Notes';

  @override
  String get dreamSavedToDiary =>
      'Dream and interpretation saved to the Diary! 🌙';

  @override
  String get dreamInterpretationTitle => 'Dream Interpretation';

  @override
  String get dreamPremiumOnly =>
      'Personalized dream interpretation is exclusive to the Premium plan.';

  @override
  String get dreamTellYourDream => 'Tell your dream';

  @override
  String get dreamTellHelp =>
      'Describe it in as much detail as possible: places, people, symbols, sensations and anything else you remember.';

  @override
  String get dreamTextHint => 'I was in a forest and…';

  @override
  String get dreamFeelingOptional =>
      'How did you feel when you woke up? (optional)';

  @override
  String get dreamInterpreting => 'Interpreting…';

  @override
  String get dreamInterpretAgain => 'Interpret again';

  @override
  String get dreamInterpretationLabel => 'Interpretation';

  @override
  String get dreamSaveToDiary => 'Save to Dream Diary';

  @override
  String get dreamDateLabel => 'Dream date';

  @override
  String get dreamNotesOptional => 'Notes (optional)';

  @override
  String get dreamSavedShort => 'Saved to Diary';

  @override
  String get tarotTabDraw => 'Reading';

  @override
  String get tarotTabLearn => 'Learn';

  @override
  String get tarotDailyCard => 'Card of the Day';

  @override
  String get tarotThreeCards => 'Three Cards';

  @override
  String get tarotCross => 'Five-Card Cross';

  @override
  String get tarotDailyDesc => 'The energy accompanying your day';

  @override
  String get tarotThreeDesc => 'Past · Present · Future';

  @override
  String get tarotCrossDesc =>
      'Situation, challenge, root, advice and tendency';

  @override
  String get tarotPosPast => 'Past';

  @override
  String get tarotPosPresent => 'Present';

  @override
  String get tarotPosFuture => 'Future';

  @override
  String get tarotPosSituation => 'Situation';

  @override
  String get tarotPosChallenge => 'Challenge';

  @override
  String get tarotPosRoot => 'Root';

  @override
  String get tarotPosAdvice => 'Advice';

  @override
  String get tarotPosTendency => 'Tendency';

  @override
  String get tarotFreeLimitReached =>
      'You\'ve already done your free reading today. Go Premium for unlimited readings!';

  @override
  String get tarotSpreadLabel => 'Spread';

  @override
  String get tarotReversed => 'reversed';

  @override
  String get tarotBreathe =>
      'Take a deep breath, think of your question and choose a spread.';

  @override
  String get tarotNewSpread => 'New reading';

  @override
  String get tarotConsultingCards => 'Consulting the cards…';

  @override
  String get tarotAdvisorInterpretation => 'Mystic Advisor\'s Interpretation';

  @override
  String get tarotBestCombo => 'Best combo';

  @override
  String get tarotDayStreak => 'Day streak';

  @override
  String get tarotAccuracy => 'Accuracy';

  @override
  String tarotAnsweredOf(String answered, String total) {
    return '$answered answered · $total cards in the deck';
  }

  @override
  String get tarotQuizTitle => 'Test what you know';

  @override
  String get tarotQuizDesc =>
      'A session of shuffled questions about card meanings. Consecutive correct answers build a combo — come back every day to keep your streak.';

  @override
  String get tarotQuizStart => '10-question session';

  @override
  String get tarotQuizBrilliant => 'Brilliant! ✨';

  @override
  String get tarotQuizDone => 'Session complete 🌙';

  @override
  String tarotQuizScore(String correct, String total) {
    return 'You got $correct out of $total.';
  }

  @override
  String get tarotQuizPraise => ' The cards recognize your dedication.';

  @override
  String get tarotQuizEncourage =>
      ' Keep practicing — each session deepens your reading.';

  @override
  String get tarotQuizFinish => 'Finish';

  @override
  String tarotQuizQuestion(String card) {
    return 'What does $card represent?';
  }

  @override
  @override
  String get palmRemainingToday => 'Readings left today';

  @override
  String get palmDailyLimitReached =>
      'You\'ve used your palm readings for today. Come back tomorrow for more. ✨';

  @override
  String get palmRateLimit =>
      'Too many readings in a short time. Please wait a moment and send the photo again.';

  String get palmImageTooLarge =>
      'The image is too large. Try less zoom or another photo.';

  @override
  String get palmImageTooSmall =>
      'The image looks too small or dark to read. Photograph your palm well lit, filling the screen.';

  @override
  String get palmReadingHeader => 'Palm Reading';

  @override
  String get palmSavedToReflections => 'Reading saved to your Reflections! ✨';

  @override
  String get palmistryTitle => 'Palmistry';

  @override
  String get palmPremiumOnly =>
      'Palm reading is exclusive to the Premium plan.';

  @override
  String get palmHowTo => '🖐️ How to photograph';

  @override
  String get palmTip1 => 'Dominant hand\'s palm open and relaxed';

  @override
  String get palmTip2 => 'Natural light, no harsh shadows over the lines';

  @override
  String get palmTip3 => 'The palm should fill almost the whole photo';

  @override
  String get palmTip4 => 'Avoid shaky or blurry photos';

  @override
  String get palmPrivacyNote =>
      'Privacy: the photo is processed on the spot and discarded — it is not saved on the device or on servers.';

  @override
  String get palmCamera => 'Camera';

  @override
  String get palmGallery => 'Gallery';

  @override
  String get palmReadingLines => 'Reading the lines of your hand…';

  @override
  String get palmYourReading => '✨ Your Reading';

  @override
  String get palmDisclaimer =>
      'Symbolic reading for reflection — it does not replace medical, psychological or professional guidance.';

  @override
  String get palmSavedShort => 'Saved to Reflections';

  @override
  String get palmSaveReading => 'Save reading';

  @override
  String get numMagicOfNumbers => 'The Magic of Numbers';

  @override
  String get numIntro =>
      'Explore the numbers vibrating in your life: your birth profile, the meaning of any number, mirror hours and the sequences that keep appearing.';

  @override
  String get numPersonalProfile => 'Personal Profile';

  @override
  String get numPersonalProfileDesc =>
      'Your 5 key numbers from your name and birth date';

  @override
  String get numLookupTitle => 'Look Up a Number';

  @override
  String get numLookupDesc =>
      'Does a number follow you? Discover its vibration';

  @override
  String get numMirrorHours => 'Mirror Hours';

  @override
  String get numMirrorHoursDesc =>
      'The message of double hours: 11:11, 22:22 and beyond';

  @override
  String get numSequences => 'Repeating Sequences';

  @override
  String get numSequencesDesc =>
      'The meaning of patterns like 333, 1010 and 1234';

  @override
  String get numWhichNumber => 'Which number follows you?';

  @override
  String get numLookupHelp =>
      'Plates, dates, doors, receipts… type the number and see its numerological essence.';

  @override
  String get numLookupHint => 'E.g.: 713';

  @override
  String get numSee => 'See';

  @override
  String numReducesTo(String original, String result) {
    return '$original reduces to $result';
  }

  @override
  String get numMirrorIntro =>
      'Did you glance at the clock exactly at a double hour? Each mirror carries a numeric vibration. Tap to see the message.';

  @override
  String numVibrationOf(String number) {
    return 'Vibration of number $number';
  }

  @override
  String numMirrorMessage(String label) {
    return 'Message of mirror $label';
  }

  @override
  String get numSequencesIntro =>
      'That number showing up everywhere may be a pattern asking for attention. The classics:';

  @override
  String numVibratesIn(String number) {
    return 'vibrates in $number';
  }

  @override
  String get numFillNameAndDate => 'Enter your full name and birth date';

  @override
  String get numDailyLimit =>
      'Daily limit reached. Go Premium for unlimited readings.';

  @override
  String get numYourBirthData => 'Your birth data';

  @override
  String get numBirthNameHelp =>
      'Use your full birth name — it carries your original numerological signature.';

  @override
  String get numFullName => 'Full name';

  @override
  String get numChooseBirthDate => 'Choose birth date';

  @override
  String get numBirthPrefix => 'Birth';

  @override
  String get numCalculate => 'Calculate my numbers';

  @override
  String get numSynthesisQuestion =>
      'Want a synthesis of how these numbers talk to each other?';

  @override
  String get numWeavingSynthesis => 'Weaving the synthesis…';

  @override
  String get numAdvisorExplanation => 'Mystic Advisor\'s Explanation';

  @override
  String get sigilCreateTitle => 'Create Sigil';

  @override
  String get sigilWhatIs => 'What is a Sigil?';

  @override
  String get sigilWhatIsDesc =>
      'Sigils are magical symbols created to manifest intentions. By turning words into abstract symbols, you create an energetic mark that carries the power of your will without revealing your intention to others.';

  @override
  String get sigilHowIntro =>
      'Set your intention, choose a word that represents it, and the app will automatically create your unique sigil.';

  @override
  String get sigilSetIntention => 'Set your Intention';

  @override
  String get sigilIntentionWord => 'Your intention word';

  @override
  String get sigilTypeWord => 'Type a word...';

  @override
  String get sigilOneWordWarning => '⚠️ Use only ONE word, no spaces';

  @override
  String get sigilExamplesHeader => '💡 Example words';

  @override
  String get sigilExample1 => 'Prosperity';

  @override
  String get sigilExample2 => 'Protection';

  @override
  String get sigilExample3 => 'Healing';

  @override
  String get sigilExample4 => 'Confidence';

  @override
  String get sigilExample5 => 'Intuition';

  @override
  String get sigilWordTip =>
      'Tip: Choose positive, specific words that resonate with you.';

  @override
  String get commonContinue => 'Continue';

  @override
  String get sigilMagicLetters => 'Magic Letters';

  @override
  String get sigilYourLetters => 'Your Sigil\'s Letters';

  @override
  String get sigilEssence => 'The magical essence of your intention';

  @override
  String get sigilYourIntention => 'Your intention:';

  @override
  String get sigilTransformedInto => 'Transformed into:';

  @override
  String get sigilWhatHappened => 'What happened?';

  @override
  String get sigilSimplified =>
      'Your word was simplified following sigil tradition:';

  @override
  String get sigilStepAccents => '1. Accents were normalized';

  @override
  String get sigilStepSpaces => '2. Spaces and symbols were removed';

  @override
  String get sigilStepDupes =>
      '3. Duplicate letters were removed (only the first occurrence is kept)';

  @override
  String get sigilWheelNote =>
      'This simplified sequence will be connected on the Witches\' Wheel to form your sigil\'s magical symbol.';

  @override
  String get sigilSeeDrawing => 'See Sigil Drawing';

  @override
  String get sigilSaveError => 'Could not save the sigil';

  @override
  String get sigilDrawingNotReady => 'Drawing is not ready yet';

  @override
  String get sigilImageError => 'Failed to generate the image';

  @override
  String get sigilSavedToGallery => 'Sigil saved to gallery! ✨';

  @override
  String get sigilGalleryPermission =>
      'Allow gallery access to save the sigil.';

  @override
  String get sigilImageSaveError => 'Could not save the image.';

  @override
  String get sigilYourSigil => 'Your Sigil';

  @override
  String get sigilYourDrawing => 'Your Sigil\'s Drawing';

  @override
  String get sigilLegendStart => 'Start';

  @override
  String get sigilLegendLetters => 'Letters';

  @override
  String get sigilLegendEnd => 'End';

  @override
  String get sigilWheel => 'Wheel';

  @override
  String get sigilPoints => 'Points';

  @override
  String get sigilShuffle => 'Shuffle letters';

  @override
  String get sigilSaveImage => 'Save image to gallery';

  @override
  String get sigilRestore => 'Restore positions';

  @override
  String get sigilHowToUse => 'How to use your sigil';

  @override
  String get sigilUse1Title => '1. Copy this drawing';

  @override
  String get sigilUse1Desc =>
      'Reproduce the tracing in your notebook, altar, candle, or ritual paper.';

  @override
  String get sigilUse2Title => '2. Personalize';

  @override
  String get sigilUse2Desc =>
      'Simplify, rotate, or add details. Making it yours is part of the magic.';

  @override
  String get sigilUse3Title => '3. Activate the sigil';

  @override
  String get sigilUse3Desc =>
      'Use it in meditation, burn it in ritual, or carry it with you to focus your intention.';

  @override
  String get sigilRemember =>
      'Remember: the magic is in your intention and in the act of creating, not only in the final drawing.';

  @override
  String get commonSaving => 'Saving...';

  @override
  String get commonFinish => 'Finish';

  @override
  String get advisorAskFirst => 'Ask your question first';

  @override
  String get advisorDailyLimit =>
      'You\'ve already consulted the Advisor today. Come back tomorrow or go Premium!';

  @override
  String get advisorGenericError =>
      'The advisor couldn\'t answer right now. Please try again later.';

  @override
  String get advisorRateLimited =>
      'The advisor needs a rest. Too many requests were made. Please wait a few minutes.';

  @override
  String get advisorTempError =>
      'Temporary error in the mystic service. Try again shortly.';

  @override
  String get advisorConnectionError =>
      'Connection error. Check your internet and try again.';

  @override
  String get advisorPortalClosed =>
      'The mystic portal is temporarily closed. Try again in a few minutes.';

  @override
  String get advisorWisdomTitle => 'The Advisor\'s Wisdom';

  @override
  String get advisorIntro =>
      'Ask a question about witchcraft, magic or mysticism, and the advisor will share their ancestral wisdom 🪄';

  @override
  String get advisorQuestionHint =>
      'E.g.: What\'s the best moon phase for a protection ritual?';

  @override
  String get advisorConsultingStars => 'Consulting the stars...';

  @override
  String get advisorConsult => 'Consult the Advisor';

  @override
  String advisorRemainingToday(String used) {
    return 'Consultations left today: $used';
  }

  @override
  String get advisorAnswers => 'The Advisor answers';

  @override
  String get spellGroupProtection => 'Protection & Cleansing';

  @override
  String get spellGroupProtectionSub => 'Defense, banishing and purification';

  @override
  String get spellGroupLove => 'Love & Bonds';

  @override
  String get spellGroupLoveSub => 'Love, self-esteem and friendship';

  @override
  String get spellGroupProsperity => 'Prosperity & Paths';

  @override
  String get spellGroupProsperitySub => 'Abundance, luck, work and studies';

  @override
  String get spellGroupDreams => 'Dreams & Visions';

  @override
  String get spellGroupDreamsSub => 'Divination, dreams and wisdom';

  @override
  String get spellGroupEnergy => 'Energy & Healing';

  @override
  String get spellGroupEnergySub => 'Vitality, healing and courage';

  @override
  String get spellGroupCreation => 'Creation & Word';

  @override
  String get spellGroupCreationSub => 'Creativity and communication';

  @override
  String get spellGroupHome => 'Home & Everyday';

  @override
  String get spellGroupHomeSub => 'House, family and daily life';

  @override
  String get grimoireSearchSpells => 'Search spells...';

  @override
  String get grimoireMySpells => 'My Spells';

  @override
  String get grimoireMySpellsSub => 'Personal creations and records';

  @override
  String get grimoireNoSpellsFound => 'No spells found 🔍';

  @override
  String get grimoireAncestral => 'Ancestral';

  @override
  String get spellNew => 'New Spell';

  @override
  String get spellEdit => 'Edit Spell';

  @override
  String get spellNameLabel => 'Spell Name *';

  @override
  String get spellNameHint => 'E.g.: Home Protection';

  @override
  String get commonRequired => 'Required field';

  @override
  String get spellPurposeLabel => 'Purpose *';

  @override
  String get spellPurposeHint => 'E.g.: Protection, Self-Love, Prosperity';

  @override
  String get spellTypeLabel => 'Spell Type *';

  @override
  String get spellCategoryLabel => 'Category *';

  @override
  String get spellMoonPhaseLabel => 'Moon Phase (Optional)';

  @override
  String get commonNone => 'None';

  @override
  String get spellIngredientsLabel => 'Ingredients';

  @override
  String get spellIngredientsHint => 'Type one ingredient per line';

  @override
  String get spellHowToLabel => 'How to Perform *';

  @override
  String get spellHowToHint => 'Describe the ritual steps';

  @override
  String get spellDurationLabel => 'Duration (in days)';

  @override
  String get spellDurationHint => 'E.g.: 3';

  @override
  String get spellNotesLabel => 'Notes';

  @override
  String get spellNotesHint => 'Results, sensations, notes...';

  @override
  String get spellAdd => 'Add Spell';

  @override
  String get spellFilterByCategory => 'Filter by category';

  @override
  String get spellAllCategories => 'All Categories';

  @override
  String get spellSourceAll => 'All';

  @override
  String get spellSourceMine => 'Mine';

  @override
  String get spellSourceAncestral => 'Ancestral';

  @override
  String get spellLoading => 'Loading spells...';

  @override
  String get spellNoneFound => 'No spells found';

  @override
  String get spellNoAncestral => 'No ancestral spells available';

  @override
  String get spellEmptyGrimoire =>
      'Your grimoire is empty.\nStart by adding your first spell!';

  @override
  String get spellMoonPrefix => 'Moon';

  @override
  String get spellSavedToGrimoire => 'Spell saved to your grimoire! ✨';

  @override
  String get spellDetails => 'Details';

  @override
  String get spellSaveToGrimoire => 'Save to Grimoire';

  @override
  String get spellRecommendedMoon => 'Recommended Moon Phase';

  @override
  String get spellHowTo => 'How to Perform';

  @override
  String spellDurationDays(String duration) {
    return 'Duration: $duration';
  }

  @override
  String get spellDay => 'day';

  @override
  String get spellDays => 'days';

  @override
  String spellCreatedAt(String date) {
    return 'Created on: $date';
  }

  @override
  String spellUpdatedAt(String date) {
    return 'Updated on: $date';
  }

  @override
  String spellDeleteConfirm(String name) {
    return 'Do you really want to delete the spell \"$name\"?';
  }

  @override
  String get recordDetails => 'Record';

  @override
  String get recordEditTitle => 'Edit Record';

  @override
  String get recordTitleLabel => 'Title *';

  @override
  String get recordContentLabel => 'Your page';

  @override
  String get recordTitleRequired => 'Give your record a title';

  @override
  String get recordContentRequired => 'Write something before saving';

  @override
  String get recordUpdated => 'Record updated! ✨';

  @override
  String recordDeleteConfirm(String name) {
    return 'Do you really want to delete the record \"$name\"?';
  }

  @override
  String get aiSpellDescribeFirst => 'Describe your intention first';

  @override
  String get aiSpellDailyLimit =>
      'You\'ve reached today\'s consultation limit. Come back tomorrow or go Premium!';

  @override
  String get aiSpellGenericError =>
      'The advisor couldn\'t manifest the spell. Please try again later.';

  @override
  String get aiSpellDescribeIntention => 'Describe your Intention';

  @override
  String get aiSpellIntentionHelp =>
      'Share what you wish to manifest. The more detail, the more powerful the spell!';

  @override
  String get aiSpellIntentionHint =>
      'E.g.: I want to attract financial prosperity to pay my bills and have more peace of mind';

  @override
  String get aiSpellManifesting => 'Manifesting...';

  @override
  String get aiSpellManifest => 'Manifest Spell ✨';

  @override
  String get aiSpellSeeDetails => 'See Details';

  @override
  String get learnUnlockPrevious =>
      'Complete the previous lesson to unlock this one.';

  @override
  String learnLessonN(String number, String title) {
    return 'Lesson $number — $title';
  }

  @override
  String learnPageWritten(String title) {
    return 'Page written: \"$title\"';
  }

  @override
  String get learnPremiumLesson => 'Premium Lesson';

  @override
  String learnCreatesPage(String title) {
    return 'Creates the page: \"$title\"';
  }

  @override
  String get learnToFill => '(to fill in)';

  @override
  String learnPageNote(String trail, String lesson) {
    return 'Living Grimoire page — $trail · $lesson';
  }

  @override
  String get learnTrailBound => 'Trail Bound!';

  @override
  String get learnPageDone => 'Page written!';

  @override
  String learnChapterBound(String title) {
    return 'The chapter \"$title\" is now a bound book in your grimoire — written by you.';
  }

  @override
  String get learnNewTitle => 'New title';

  @override
  String get learnSoBeIt => 'So be it ✨';

  @override
  String get learnPracticeGoal => 'Goal';

  @override
  String get learnPracticeHow => 'How to do it';

  @override
  String get learnPracticeThen => 'After the practice';

  @override
  String get learnStepTeaching => '📜 Teaching';

  @override
  String get learnStepPractice => '🕯️ Practice';

  @override
  String get learnStepPage => '✍️ The Page';

  @override
  String get learnGoToPractice => 'Go to practice';

  @override
  String get learnDidPractice => 'I did the practice (or will do it today)';

  @override
  String get learnWriteMyPage => 'Write my page';

  @override
  String get learnAnswerHelp =>
      'Answer in your own words — the app assembles the page and keeps it in My Grimoire. It\'s yours forever.';

  @override
  String get learnPageTitleLabel => 'Page title';

  @override
  String get learnWriteHere => 'Write here…';

  @override
  String get learnSealPage => 'Seal page into the grimoire';

  @override
  String get learnHomeTitle => 'Learn by writing your grimoire';

  @override
  String get learnHomeSubtitle =>
      'Each lesson ends with a page you create in My Grimoire. When you complete a trail, the chapter is yours — written in your own hand.';

  @override
  String get learnMaxTitle => 'Highest title reached ✨';

  @override
  String learnNextTitle(String pages, String title, String xp) {
    return '$pages pages written · next title: $title ($xp XP)';
  }

  @override
  String get learnBoundShort => 'Bound!';

  @override
  String learnPagesProgress(String done, String total) {
    return '$done/$total pages';
  }

  @override
  String learnBoundVolume(String count) {
    return '📕 Bound volume — $count pages written by you';
  }

  @override
  String get oracleDailyLimit =>
      'You\'ve reached today\'s reading limit. Come back tomorrow or go Premium!';

  @override
  String get oracleTitle => 'Oracle Cards';

  @override
  String get oracleSubtitle =>
      'Receive guidance and messages from the universe';

  @override
  String get oracleDrawing => 'Drawing cards...';

  @override
  String get oracleDraw => 'Draw Cards';

  @override
  String oracleRemainingToday(String used) {
    return 'Readings left today: $used';
  }

  @override
  String get oracleNewReading => 'New Reading';

  @override
  String get oracleYourReading => 'Your Reading';

  @override
  String get pendulumUsedAll =>
      'You\'ve used your 3 consultations today. Come back tomorrow!';

  @override
  String get pendulumAskFirst => 'Ask a question first';

  @override
  String get pendulumTitle => 'Pendulum';

  @override
  String get pendulumConsult => 'Consult the Pendulum';

  @override
  String get pendulumIntro =>
      'Ask yes-or-no questions. Focus and trust the answer.';

  @override
  String get pendulumUnlimitedAdmin => 'Unlimited consultations (Admin)';

  @override
  String pendulumUsedComeBack(String used, String total) {
    return 'Consultations used ($used/$total) - come back tomorrow';
  }

  @override
  String get pendulumYourQuestion => 'Your Question';

  @override
  String get pendulumQuestionHint => 'E.g.: Should I take that job?';

  @override
  String get pendulumAsking => 'Consulting...';

  @override
  String get pendulumAsk => 'Ask';

  @override
  String get pendulumNewConsult => 'New Consultation';

  @override
  String get pendulumYes => 'YES';

  @override
  String get pendulumNo => 'NO';

  @override
  String get pendulumMaybe => 'MAYBE';

  @override
  String get runesNoQuestion => 'No question';

  @override
  String get runesReadingTitle => 'Rune Reading';

  @override
  String get runesReadingIntro =>
      'Runes are symbols of the Norse runic alphabet used for divination. Each rune can appear upright or reversed (when applicable), changing its meaning.';

  @override
  String get runesReversedNote =>
      'Reversed Runes: When a rune appears upside down, it usually points to blocks or challenging aspects of the original meaning.';

  @override
  String get runesChooseLayout => 'Choose a Layout';

  @override
  String get runesQuestionOptional => 'Your Question (optional)';

  @override
  String get runesQuestionHint => 'What should the runes reveal?';

  @override
  String get runesDrawing => 'Drawing runes...';

  @override
  String get runesDraw => 'Draw Runes';

  @override
  String get runesReversed => 'Reversed';

  @override
  String get runesListTitle => 'Runes';

  @override
  String get runesAbout => 'About the Runes';

  @override
  String get runesAboutText =>
      'Runes are an ancient alphabet used by Germanic and Norse peoples. Beyond writing, each rune carries deep symbolic meanings and can be used for reflection, self-knowledge and oracular reading.';

  @override
  String get runesExplore =>
      'Explore the 24 runes of the Elder Futhark below. Tap each one to learn its meaning.';

  @override
  String get runesElderFuthark => 'Elder Futhark';

  @override
  String get runesKeywords => 'Keywords';

  @override
  String get runesMeaning => 'Meaning';

  @override
  String get runesRemember =>
      'Remember: runes are tools for reflection and self-knowledge. Use them as a starting point to explore your own perceptions and intuitions.';

  @override
  String get astroMysticTitle => 'Mystic Astrology';

  @override
  String get astroMysticSubtitle =>
      'Your birth chart and personalized magical profile';

  @override
  String get astroZodiacSigns => 'Zodiac Signs';

  @override
  String get astroZodiacSignsDesc =>
      'Get to know the 12 signs and their magical meanings';

  @override
  String get astroBirthChart => 'Birth Chart';

  @override
  String get astroSeeChart => 'See your full birth chart';

  @override
  String get astroCreateChart => 'Create your birth chart';

  @override
  String get astroMagicMirror => 'Magic mirror';

  @override
  String get astroMagicalProfile => 'Magical Profile';

  @override
  String get astroMagicalProfileDesc =>
      'Astrological interpretation for witchcraft';

  @override
  String get astroDailyWeather => 'Daily Magic Weather';

  @override
  String get astroDailyWeatherDesc =>
      'Planetary transits and the day\'s energy';

  @override
  String get astroSuggestions => 'Personalized Suggestions';

  @override
  String get astroSuggestionsDesc => 'Practices based on your transits';

  @override
  String get astroRecalculate => 'Recalculate Chart';

  @override
  String get astroRecalculateDesc => 'Create a new birth chart';

  @override
  String get astroAbout => 'About Astrology';

  @override
  String get astroAboutText =>
      'Your birth chart is calculated from the position of the planets at the time and place of your birth. The magical profile interprets those positions specifically for witchcraft practice.';

  @override
  String get astroHaveOnHand => 'For best results, have on hand:';

  @override
  String get astroBirthDate => 'Birth date';

  @override
  String get astroBirthTime => 'Exact birth time';

  @override
  String get astroBirthPlace => 'Birth place (city and country)';

  @override
  String get astroRecalcTitle => 'Recalculate Birth Chart?';

  @override
  String get astroRecalcConfirm =>
      'This will replace your current birth chart. Are you sure?';

  @override
  String get chartInvalidDate => 'Invalid date';

  @override
  String get chartInvalidTime => 'Invalid time';



  @override
  String get chartPlaceNotFound => 'Place not found';

  @override
  String get chartCalcError => 'Error calculating chart';

  @override
  String get chartCreateTitle => 'Create Birth Chart';

  @override
  String get chartYourChart => 'Your Birth Chart';

  @override
  String get chartIntro =>
      'To calculate your precise natal chart, we need your birth date, time and place. The more precise, the better!';

  @override
  String get chartBirthDate => 'Birth Date';

  @override
  String get chartDateFormat => 'Type in dd/mm/yyyy format';

  @override
  String get chartDateHint => 'dd/mm/yyyy';

  @override
  String get chartBirthTime => 'Birth Time';

  @override
  String get chartTimeImportant =>
      'The exact time matters for calculating the Ascendant and Houses.';

  @override
  String get chartDontKnowTime => 'I don\'t know the exact time';

  @override
  String get chartBirthPlace => 'Birth Place';

  @override
  String get chartTypeToSearch => 'Type at least 3 characters to search';

  @override
  String get chartPlaceHint => 'E.g.: London, UK';

  @override
  String get chartCalculate => 'Calculate Birth Chart ✨';

  @override
  String get chartNoonNote =>
      'Without the exact time, we\'ll use noon (12:00) and the equal house system.';

  @override
  String get settingsLanguageSubtitle => 'Manually choose the app language';

  @override
  String get quizTitle => 'Archetype Quiz';

  @override
  String quizProgress(String current, String total) {
    return '$current of $total';
  }

  @override
  String get quizYourArchetypeIs => 'Your archetype is';

  @override
  String get quizSeeInEncyclopedia => 'See in the Encyclopedia';

  @override
  String get quizRetake => 'Retake the quiz';

  @override
  String get quizStrongestEnergies => 'Your strongest energies';

  @override
  String get quizMirrorNote =>
      'Archetypes are mirrors, not drawers: you carry several — this is the one vibrating strongest in you right now. Explore the others in the Encyclopedia\'s Archetypes tab.';

  @override
  String quizSavedOn(String date) {
    return 'Result of your last quiz ($date)';
  }

  @override
  String get tarotLibraryTitle => 'Card Library';

  @override
  String get tarotTutorTitle => 'Tarot Tutor';

  @override
  String get tarotLibraryDesc =>
      'All 78 cards with image, meaning and reversed reading';

  @override
  String get tarotFlipCard => 'Reverse card';

  @override
  String get tarotUnflipCard => 'Upright position';

  @override
  String get tarotUprightMeaning => 'Meaning';

  @override
  String get tarotReversedMeaning => 'Reversed meaning';

  @override
  String get grimoireMyRecords => 'My Records';

  @override
  String get grimoireMyRecordsSub =>
      'Living Grimoire pages, studies and reflections';

  @override
  String get grimoireNoRecords =>
      'Your Living Grimoire pages and records will appear here.';

  @override
  String get learnFillAtLeastOne =>
      'Answer at least one question before sealing the page';

  @override
  String learnOpenTool(String tool) {
    return 'Open $tool';
  }

  @override
  String get learnToolHint =>
      'This lesson uses one of the app\'s tools — open it here and come back to write your page.';

  @override
  String learnSavesTo(String place) {
    return 'This page will be saved in: $place';
  }

  @override
  String get learnPlaceDreams => 'Dream Diary';

  @override
  String get learnPlaceGratitude => 'Gratitude Diary';

  @override
  String get learnPlaceAffirmations => 'Affirmations';

  @override
  String get learnPlaceDesires => 'Desire Diary';

  @override
  String get learnSection1 => 'Foundation';

  @override
  String get learnSection2 => 'Going deeper';

  @override
  String get learnSection3 => 'In practice';

  @override
  String get learnSection4 => 'To carry with you';
}
