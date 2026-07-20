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

  @override
  String get navEncyclopedia => 'Enciclopedia';

  @override
  String get navGrimoire => 'Grimorio';

  @override
  String get navDiaries => 'Diarios';

  @override
  String get grimoirePageTitle => 'Grimorio Digital';

  @override
  String get grimoireTabAstrology => 'Astrología';

  @override
  String get grimoireTabTools => 'Herramientas';

  @override
  String get grimoireTabMyGrimoire => 'Mi Grimorio';

  @override
  String get diaryPageTitle => 'Diarios';

  @override
  String get diaryTabGratitude => 'Gratitud';

  @override
  String get diaryTabAffirmations => 'Afirmaciones';

  @override
  String get diaryTabDreams => 'Sueños';

  @override
  String get diaryTabDesires => 'Deseos';

  @override
  String get encyclopediaPageTitle => 'Enciclopedia Mágica';

  @override
  String get encyTabMoon => 'Luna';

  @override
  String get encyTabSabbats => 'Sabbats';

  @override
  String get encyTabCrystals => 'Cristales';

  @override
  String get encyTabHerbs => 'Hierbas';

  @override
  String get encyTabMetals => 'Metales';

  @override
  String get encyTabColors => 'Colores';

  @override
  String get encyTabGoddesses => 'Diosas';

  @override
  String get encyTabElements => 'Elementos';

  @override
  String get encyTabAltar => 'Altar';

  @override
  String get encyTabRunes => 'Runas';

  @override
  String get encyTabArchetypes => 'Arquetipos';

  @override
  String get encyTabAngels => 'Ángeles';

  @override
  String get encyTabDemons => 'Demonios';

  @override
  String get encyTabSymbols => 'Símbolos';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonBackAgainToExit => 'Toca atrás de nuevo para salir';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonBack => 'Volver';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get toolsHeaderTitle => 'Herramientas Mágicas';

  @override
  String get toolsHeaderSubtitle =>
      'Recursos para apoyar tus prácticas de magia y manifestación';

  @override
  String get toolMysticAdvisorTitle => 'Consejero Místico';

  @override
  String get toolMysticAdvisorDesc =>
      'Sabiduría ancestral para tus dudas de brujería y magia';

  @override
  String get toolOracleTitle => 'Cartas del Oráculo';

  @override
  String get toolOracleDesc => 'Mensajes y orientación del universo';

  @override
  String get toolSigilsTitle => 'Sigilos';

  @override
  String get toolSigilsDesc => 'Crea símbolos mágicos para tus intenciones';

  @override
  String get toolNumerologyTitle => 'Numerología';

  @override
  String get toolNumerologyDesc =>
      'Tus números clave, horas espejo y secuencias';

  @override
  String get toolRunesTitle => 'Lectura de Runas';

  @override
  String get toolRunesDesc => 'Consulta las antiguas runas nórdicas';

  @override
  String get toolPendulumTitle => 'Péndulo';

  @override
  String get toolPendulumDesc => 'Preguntas de sí o no';

  @override
  String get toolLivingGrimoireTitle => 'Grimorio Vivo';

  @override
  String get toolLivingGrimoireDesc =>
      'Rutas de aprendizaje: cada lección se vuelve una página tuya';

  @override
  String get toolTarotTitle => 'Tarot';

  @override
  String get toolTarotDesc => 'Tiradas, carta del día y tutor de aprendizaje';

  @override
  String get toolArchetypeTitle => 'Test de Arquetipo';

  @override
  String get toolArchetypeDesc =>
      'Descubre qué arquetipo vibra más fuerte en ti';

  @override
  String get toolPalmistryTitle => 'Lectura de Manos';

  @override
  String get toolPalmistryDesc => 'Quiromancia por la palma de tu mano';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get premiumBePremium => 'Hazte Premium';

  @override
  String get premiumUnlock => 'Desbloquear Premium';

  @override
  String get premiumContentLabel => 'Contenido Premium';

  @override
  String get premiumUpgradeAction => 'Mejorar';

  @override
  String get premiumPlansUnavailable =>
      'Los planes no están disponibles temporalmente';

  @override
  String get premiumActivated => '¡Premium activado con éxito!';

  @override
  String get premiumPurchaseFailed => 'No se pudo completar la compra';

  @override
  String get premiumHeroAccess => 'ACCEDE A';

  @override
  String get premiumHeroPower => 'TODO EL PODER';

  @override
  String get premiumHeroMagic => 'DE TU MAGIA';

  @override
  String get premiumHeroTagline1 => 'Más conocimiento, más orientación y más ';

  @override
  String get premiumHeroTaglineHighlight => 'conexión';

  @override
  String get premiumHeroTagline2 => ' con tu camino';

  @override
  String get premiumCatSemantic => 'Gato mágico del Grimorio de Bolsillo';

  @override
  String get premiumBenefitAdvisor => 'Consejero Místico ilimitado';

  @override
  String get premiumBenefitEncyclopedia =>
      'Enciclopedia con contenidos completos';

  @override
  String get premiumBenefitDailyClimate => 'Clima Mágico Diario personalizado';

  @override
  String get premiumBenefitUnlimitedReadings =>
      'Lecturas ilimitadas de Runas, Oráculo y Sigilos';

  @override
  String get premiumBenefitCloudSync => 'Sincronización entre dispositivos';

  @override
  String get premiumPlanMonthly => 'Mensual';

  @override
  String get premiumPlanYearly => 'Anual';

  @override
  String get premiumPerMonth => '/mes';

  @override
  String get premiumPerYear => '/año';

  @override
  String get premiumSave33 => 'Ahorra 33%';

  @override
  String get premiumTagSelected => 'SELECCIONADO';

  @override
  String get premiumTagPopular => 'POPULAR';

  @override
  String premiumPlanSemantics(String title, String price, String period) {
    return 'Plan $title, $price $period';
  }

  @override
  String get premiumStartNow => 'Empezar Ahora';

  @override
  String get premiumCancelAnytime => 'Cancela cuando quieras';

  @override
  String get premiumSecurePayment => 'Pago seguro';

  @override
  String get premiumDataProtected => 'Tus datos protegidos';

  @override
  String get authWelcomeBack => '¡Bienvenida de nuevo!';

  @override
  String get authLoginSubtitle => 'Inicia sesión para acceder a tu grimorio';

  @override
  String get authForgotPassword => 'Olvidé mi contraseña';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authEmailHint => 'tu@email.com';

  @override
  String get authEmailRequired => 'Por favor, ingresa tu correo';

  @override
  String get authEmailInvalid => 'Por favor, ingresa un correo válido';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authPasswordRequired => 'Por favor, ingresa tu contraseña';

  @override
  String get authPasswordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get authOrContinueWith => 'o continúa con';

  @override
  String get authNoAccount => '¿No tienes una cuenta? ';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authSystemNotConfigured =>
      'Sistema de autenticación no configurado. Contacta con el soporte.';

  @override
  String get authLoginError => 'Error al iniciar sesión';

  @override
  String get authSocialUnavailable =>
      'El inicio de sesión social no está disponible ahora';

  @override
  String get authGoogleError => 'Error al iniciar sesión con Google';

  @override
  String get authSignupSubtitle => 'Inicia tu viaje mágico';

  @override
  String get authNameLabel => 'Nombre';

  @override
  String get authNameHint => 'Tu nombre mágico';

  @override
  String get authNameRequired => 'Por favor, ingresa tu nombre';

  @override
  String get authNameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get authPasswordHintMin => 'Mínimo 6 caracteres';

  @override
  String get authPasswordCreateRequired => 'Por favor, ingresa una contraseña';

  @override
  String get authConfirmPasswordLabel => 'Confirmar Contraseña';

  @override
  String get authConfirmPasswordHint => 'Escribe la contraseña de nuevo';

  @override
  String get authConfirmPasswordRequired => 'Por favor, confirma tu contraseña';

  @override
  String get authPasswordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get authTermsPrefix => 'He leído y acepto los ';

  @override
  String get authTermsOfUse => 'Términos de Uso';

  @override
  String get authTermsAnd => ' y la ';

  @override
  String get authPrivacyPolicy => 'Política de Privacidad';

  @override
  String get authOrSignupWith => 'o regístrate con';

  @override
  String get authHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get authMustAcceptTerms => 'Debes aceptar los términos de uso';

  @override
  String get authSignupError => 'Error al crear la cuenta';

  @override
  String get authEmailInUse => 'Este correo ya está en uso';

  @override
  String get authEmailInvalidShort => 'Correo inválido';

  @override
  String get authSignupSuccess => '¡Cuenta creada! ¡Bienvenida al Grimorio!';

  @override
  String get authGoogleSignupUnavailable =>
      'El registro con Google no está disponible ahora';

  @override
  String get authGoogleSignupError => 'Error al registrarse con Google';

  @override
  String get welcomeSubtitle => 'Tu viaje mágico empieza aquí';

  @override
  String get welcomeFeatureLunar => 'Calendario Lunar';

  @override
  String get welcomeFeatureGrimoire => 'Grimorio Digital';

  @override
  String get welcomeFeatureDiaries => 'Diarios Mágicos';

  @override
  String get welcomeFeatureAstrology => 'Astrología';

  @override
  String get welcomeHaveAccount => 'Ya tengo cuenta';

  @override
  String get forgotEmailSent => '¡Correo Enviado!';

  @override
  String forgotEmailSentTo(String email) {
    return 'Enviamos un enlace de recuperación a\n$email';
  }

  @override
  String get forgotCheckInbox => 'Revisa tu bandeja de entrada y spam.';

  @override
  String get forgotBackToLogin => 'Volver al Inicio de Sesión';

  @override
  String get forgotResend => '¿No lo recibiste? Enviar de nuevo';

  @override
  String get forgotTitle => '¿Olvidaste tu contraseña?';

  @override
  String get forgotSubtitle =>
      '¡No hay problema! Ingresa tu correo y te enviaremos un enlace para crear una nueva contraseña.';

  @override
  String get forgotSendLink => 'Enviar Enlace de Recuperación';

  @override
  String get forgotRemembered => '¿Recordaste tu contraseña? ';

  @override
  String get forgotBackToLoginLower => 'Volver al inicio de sesión';

  @override
  String get forgotSendError => 'Error al enviar el correo';

  @override
  String get forgotResendError => 'Error al reenviar el correo';

  @override
  String get forgotResendSuccess => '¡Correo reenviado con éxito!';

  @override
  String get forgotResendErrorPrefix => 'Error al reenviar';

  @override
  String get changePasswordTitle => 'Cambiar Contraseña';

  @override
  String get changePasswordHeader => 'Nueva Contraseña';

  @override
  String get changePasswordSubtitle =>
      'Ingresa tu contraseña actual y elige una nueva';

  @override
  String get changePasswordCurrentLabel => 'Contraseña Actual';

  @override
  String get changePasswordCurrentRequired =>
      'Por favor, ingresa tu contraseña actual';

  @override
  String get changePasswordNewLabel => 'Nueva Contraseña';

  @override
  String get changePasswordNewRequired =>
      'Por favor, ingresa una nueva contraseña';

  @override
  String get changePasswordMustDiffer =>
      'La nueva contraseña debe ser diferente de la actual';

  @override
  String get changePasswordConfirmLabel => 'Confirmar Nueva Contraseña';

  @override
  String get changePasswordConfirmHint =>
      'Escribe la nueva contraseña de nuevo';

  @override
  String get changePasswordConfirmRequired =>
      'Por favor, confirma tu nueva contraseña';

  @override
  String get changePasswordError => 'Error al cambiar la contraseña';

  @override
  String get changePasswordSuccess => '¡Contraseña cambiada con éxito!';

  @override
  String get changePasswordWrongCurrent => 'Contraseña actual incorrecta';

  @override
  String get onbSlide1Title => 'Tu Grimorio Digital';

  @override
  String get onbSlide1Desc =>
      'Guarda tus hechizos, rituales y recetas mágicas en un solo lugar. Organiza por fase lunar, ingredientes y mucho más.';

  @override
  String get onbSlide2Title => 'Calendario Lunar';

  @override
  String get onbSlide2Desc =>
      'Sigue las fases de la luna y descubre el mejor momento para cada tipo de magia. Recibe notificaciones en lunas llenas y nuevas.';

  @override
  String get onbSlide3Title => 'Diarios Mágicos';

  @override
  String get onbSlide3Desc =>
      'Registra sueños, deseos, gratitud y afirmaciones. Sigue tu evolución espiritual día a día.';

  @override
  String get onbSlide4Title => 'Astrología Completa';

  @override
  String get onbSlide4Desc =>
      'Descubre tu carta astral, perfil mágico personalizado y previsiones diarias basadas en los tránsitos planetarios.';

  @override
  String get onbSlide5Title => '¿Lista para Empezar?';

  @override
  String get onbSlide5Desc =>
      'Crea tu cuenta para sincronizar tus datos en todos los dispositivos y tener acceso completo a las funciones.';

  @override
  String get onbSkip => 'Saltar';

  @override
  String get onbHaveAccount => 'Ya tengo una cuenta';

  @override
  String get onbNext => 'Siguiente';

  @override
  String get profileTitle => 'Mi Perfil';

  @override
  String get profileAnonymous => 'Bruja Anónima';

  @override
  String get profileEditName => 'Editar Nombre';

  @override
  String get profileFreePlan => 'Plan Gratuito';

  @override
  String get profilePremiumPlan => 'Plan Premium';

  @override
  String get profileFreePlanDesc => 'Algunas funciones son limitadas';

  @override
  String get profilePremiumPlanDesc => 'Acceso completo a todas las funciones';

  @override
  String get profileUpgrade => 'Mejorar Plan';

  @override
  String get profileFreeUsage => 'Uso del Plan Gratuito';

  @override
  String get profileSpells => 'Hechizos';

  @override
  String get profileDiaryEntries => 'Entradas de Diario';

  @override
  String get profileThisMonth => 'este mes';

  @override
  String get profileMysticAdvisor => 'Consejero Místico';

  @override
  String get profileToday => 'hoy';

  @override
  String get profileEditProfile => 'Editar Perfil';

  @override
  String get profileManageSubscription => 'Gestionar Suscripción';

  @override
  String get profileMagicalStats => 'Estadísticas Mágicas';

  @override
  String get profileMagicalJourneys => 'Viajes Mágicos';

  @override
  String get profileNotifications => 'Notificaciones';

  @override
  String get profileHelpSupport => 'Ayuda y Soporte';

  @override
  String get profileAboutApp => 'Sobre la App';

  @override
  String get profileLogout => 'Cerrar Sesión';

  @override
  String get profileLogoutConfirm =>
      '¿Seguro que quieres cerrar sesión?\nTus datos locales se mantendrán.';

  @override
  String get profileLogoutAction => 'Salir';

  @override
  String get profileNotificationsSoon =>
      '¡La configuración de notificaciones llegará pronto!\n\nPodrás personalizar alertas para:\n• Recordatorios de rituales\n• Fases de la luna\n• Fechas mágicas especiales';

  @override
  String get profileSupportEmail => 'Correo de Soporte';

  @override
  String get profileFaq => 'Preguntas frecuentes';

  @override
  String get profilePrivacySafe => 'Tus datos están seguros';

  @override
  String aboutVersion(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String get aboutDescription =>
      'Tu compañero para prácticas mágicas, rituales y autoconocimiento a través de la astrología y la brujería moderna.';

  @override
  String get aboutMadeWith => 'Hecho con 🔮 y ✨';

  @override
  String get editBasicInfo => 'Información Básica';

  @override
  String get editNameUpdated => '¡Nombre actualizado!';

  @override
  String get editGenderSection => 'Género';

  @override
  String get editGenderHelp =>
      '¿Cómo debe dirigirse a ti la app? Usamos esta elección en los textos personalizados y en las respuestas del Consejero Místico.';

  @override
  String get editSecurity => 'Seguridad';

  @override
  String get editChangePasswordSubtitle => 'Modificar tu contraseña de acceso';

  @override
  String get editDataCollection => 'Recopilación de Datos';

  @override
  String get editAnalytics => 'Analytics';

  @override
  String get editAnalyticsSubtitle =>
      'Ayuda a mejorar la app compartiendo datos de uso anónimos';

  @override
  String get editCrashReports => 'Informes de Errores';

  @override
  String get editCrashReportsSubtitle =>
      'Enviar informes automáticos cuando la app tenga problemas';

  @override
  String get editPersonalizedContent => 'Contenido Personalizado';

  @override
  String get editPersonalizedContentSubtitle =>
      'Recibir sugerencias basadas en tu uso de la app';

  @override
  String get editSyncBackup => 'Sincronización y Copia de Seguridad';

  @override
  String get editSyncBackupCloud => 'Sincronización y Copia en la Nube';

  @override
  String get editSyncBackupOn =>
      'Mantén tus datos protegidos y sincronizados entre dispositivos';

  @override
  String get editSyncPremiumOnly => 'Función exclusiva Premium';

  @override
  String get editManageData => 'Gestionar Tus Datos';

  @override
  String get editExportData => 'Exportar Mis Datos';

  @override
  String get editExportDataSubtitle => 'Descargar una copia de todos tus datos';

  @override
  String get editClearLocal => 'Borrar Datos Locales';

  @override
  String get editClearLocalSubtitle =>
      'Eliminar datos guardados en este dispositivo';

  @override
  String get editDeleteAccount => 'Eliminar Mi Cuenta';

  @override
  String get editDeleteAccountSubtitle =>
      'Eliminar permanentemente todos tus datos';

  @override
  String get genderFeminine => 'Femenino';

  @override
  String get genderMasculine => 'Masculino';

  @override
  String get genderNeutral => 'Neutro';

  @override
  String get editNotInformed => 'No indicado';

  @override
  String get editPrivacyMatters => 'Tu Privacidad Importa';

  @override
  String get editPrivacyNote =>
      'Tus datos mágicos son sagrados. Nunca vendemos tu información personal y tienes control total sobre lo que se recopila y almacena.';

  @override
  String get editNewPasswordMin =>
      'La nueva contraseña debe tener al menos 6 caracteres';

  @override
  String get editErrorPrefix => 'Error';

  @override
  String get editChangeAction => 'Cambiar';

  @override
  String get editExportTitle => 'Exportar Datos';

  @override
  String get editExportConfirm =>
      'Tus datos se exportarán en formato JSON. Esto puede tardar unos segundos.';

  @override
  String get editExportAction => 'Exportar';

  @override
  String get editExporting => 'Exportando datos...';

  @override
  String get editExportSuccess => '¡Datos exportados con éxito!';

  @override
  String get editExportError => 'Error al exportar';

  @override
  String get editClearLocalTitle => '¿Borrar Datos Locales?';

  @override
  String get editClearLocalConfirm =>
      'Esto eliminará todos los datos guardados en este dispositivo. Si tienes la sincronización activada, tus datos en la nube se mantendrán.';

  @override
  String get editClearAction => 'Borrar';

  @override
  String get editClearSuccess => 'Datos locales eliminados con éxito';

  @override
  String get editClearError => 'Error al borrar datos';

  @override
  String get editDeleteTitle => 'Eliminar Cuenta';

  @override
  String get editDeleteWarning =>
      'ATENCIÓN: ¡Esta acción es IRREVERSIBLE!\n\nTodos tus datos se eliminarán permanentemente, incluyendo:\n- Hechizos y rituales\n- Entradas de diario\n- Carta astral\n- Configuración\n\n¿Estás absolutamente segura?';

  @override
  String get editDeletePermanently => 'Eliminar Permanentemente';

  @override
  String get editDeleting => 'Eliminando cuenta...';

  @override
  String get editDeleteError => 'Error al eliminar la cuenta';

  @override
  String get editDeleteSuccess => 'Cuenta eliminada con éxito';

  @override
  String get editDeleteErrorPrefix => 'Error al eliminar la cuenta';

  @override
  String get editPremiumFeature => 'Función Premium';

  @override
  String get editSyncPremiumPitch =>
      'La sincronización de datos en la nube es una función exclusiva para usuarios Premium.\n\nCon Premium, tus datos están siempre seguros y sincronizados entre todos tus dispositivos.';

  @override
  String get editNotNow => 'Ahora No';

  @override
  String get settingsLifetime => 'Suscripción Vitalicia';

  @override
  String settingsRenewsOn(String date) {
    return 'Se renueva el: $date';
  }

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsNotifDesc =>
      'Configura recordatorios para eventos mágicos importantes';

  @override
  String get settingsFullMoon => 'Luna Llena';

  @override
  String get settingsFullMoonDesc =>
      'Recordatorio 1 día antes de la Luna Llena';

  @override
  String get settingsNewMoon => 'Luna Nueva';

  @override
  String get settingsNewMoonDesc => 'Recordatorio 1 día antes de la Luna Nueva';

  @override
  String get settingsSabbats => 'Sabbats';

  @override
  String get settingsSabbatsDesc => 'Recordatorio 3 días antes de cada Sabbat';

  @override
  String get settingsNotifMobileOnly =>
      'Las notificaciones solo se envían en dispositivos móviles';

  @override
  String get settingsNotifUpdateError =>
      'No se pudieron actualizar las notificaciones';

  @override
  String get settingsPaymentsNotConfigured => 'Pagos No Configurados';

  @override
  String get settingsPaymentsNotConfiguredDesc =>
      'El sistema de pagos aún no se ha configurado en esta versión de la app.\n\nSi eres desarrollador, revisa los registros de la consola para más detalles.';

  @override
  String get commonUnderstood => 'Entendido';

  @override
  String get settingsTermsSubtitle => 'Las reglas de nuestro círculo';

  @override
  String get monthJanShort => 'Ene';

  @override
  String get monthFebShort => 'Feb';

  @override
  String get monthMarShort => 'Mar';

  @override
  String get monthAprShort => 'Abr';

  @override
  String get monthMayShort => 'May';

  @override
  String get monthJunShort => 'Jun';

  @override
  String get monthJulShort => 'Jul';

  @override
  String get monthAugShort => 'Ago';

  @override
  String get monthSepShort => 'Sep';

  @override
  String get monthOctShort => 'Oct';

  @override
  String get monthNovShort => 'Nov';

  @override
  String get monthDecShort => 'Dic';

  @override
  String get diaryNewDream => 'Nuevo Sueño';

  @override
  String get diaryEditDream => 'Editar Sueño';

  @override
  String get diaryTitleLabel => 'Título';

  @override
  String get diaryDreamTitleHint => 'Ej.: Sueño con mariposas';

  @override
  String get diaryDreamDate => 'Fecha del Sueño';

  @override
  String get diaryDreamDescLabel => 'Descripción del Sueño';

  @override
  String get diaryDreamDescHint => 'Describe tu sueño en detalle';

  @override
  String get diaryTagsLabel => 'Etiquetas';

  @override
  String get diaryDreamTagsHint => 'Ej.: pesadilla, recurrente, lúcido';

  @override
  String get diaryTagsHelper => 'Separa las etiquetas con comas';

  @override
  String get diaryDreamFeelingLabel => '¿Cómo te sentiste al despertar?';

  @override
  String get diaryDreamFeelingHint => 'Ej.: Paz, miedo, alegría, confusión';

  @override
  String get diaryInterpretationHeader => '🔮 Interpretación';

  @override
  String get diarySaveDream => 'Guardar Sueño';

  @override
  String get commonUpdate => 'Actualizar';

  @override
  String get diaryFillTitleOrDesc =>
      'Completa al menos el título o la descripción';

  @override
  String get diaryFillTitleOrContent =>
      'Completa al menos el título o el contenido';

  @override
  String get commonNoTitle => 'Sin título';

  @override
  String get commonConfirmDelete => 'Confirmar eliminación';

  @override
  String get diaryDeleteDreamConfirm =>
      '¿Realmente quieres eliminar este sueño?';

  @override
  String get diaryNewGratitude => 'Nueva Gratitud';

  @override
  String get diaryEditGratitude => 'Editar Gratitud';

  @override
  String get diaryGratitudeTitleHint => 'Ej.: Gratitud por el día de hoy';

  @override
  String get commonDate => 'Fecha';

  @override
  String get diaryGratitudeLabel => '¿Por qué estás agradecida hoy?';

  @override
  String get diaryGratitudeHint => 'Describe tus gratitudes...';

  @override
  String get diaryGratitudeTagsHint => 'Ej.: familia, salud, trabajo';

  @override
  String get diarySaveGratitude => 'Guardar Gratitud';

  @override
  String get diaryDeleteGratitudeTitle => 'Eliminar Gratitud';

  @override
  String get diaryDeleteGratitudeConfirm =>
      '¿Seguro que quieres eliminar esta gratitud?';

  @override
  String get diaryNewDesire => 'Nuevo Deseo';

  @override
  String get diaryEditDesire => 'Editar Deseo';

  @override
  String get diaryDesireTitleHint => 'Ej.: Viajar al extranjero';

  @override
  String get diaryDescLabel => 'Descripción';

  @override
  String get diaryDesireSigilImage => 'Imagen del sigilo';

  @override
  String get diaryDesireSigilTitle => 'Sigilo 🔐';

  @override
  String get diaryDesireDescHint => 'Describe tu deseo en detalle';

  @override
  String get diaryStatusLabel => 'Estado';

  @override
  String get diaryDesireProgressLabel => '¿Qué ha avanzado?';

  @override
  String get diaryDesireProgressHint => 'Registra la evolución de tu deseo';

  @override
  String get diarySaveDesire => 'Guardar Deseo';

  @override
  String get diaryDeleteDesireConfirm =>
      '¿Realmente quieres eliminar este deseo?';

  @override
  String get diaryNewAffirmation => 'Nueva Afirmación';

  @override
  String get diaryEditAffirmation => 'Editar Afirmación';

  @override
  String get diaryPreloadedAffirmationNote =>
      'Las afirmaciones precargadas no se pueden editar ni eliminar.';

  @override
  String get diaryAdvisorAffirmationPitch =>
      'Deja que el Consejero Místico cree una afirmación poderosa para ti';

  @override
  String get diaryContextOptional => 'Contexto (opcional)';

  @override
  String get diaryContextHint => 'Ej.: Estoy empezando un nuevo trabajo...';

  @override
  String get diaryContextHelper =>
      'Describe tu situación para una afirmación personalizada';

  @override
  String get diaryConsulting => 'Consultando...';

  @override
  String get diaryGenerateAffirmation => 'Generar Afirmación';

  @override
  String get diaryWriteOwnAffirmation => 'O escribe tu propia afirmación:';

  @override
  String get diaryAffirmationLabel => 'Afirmación';

  @override
  String get diaryAffirmationHint =>
      'Ej.: Soy merecedora de abundancia y prosperidad';

  @override
  String get diaryAffirmationHelper =>
      'Escribe en presente y de forma positiva';

  @override
  String get diaryCategoryLabel => 'Categoría';

  @override
  String get diarySaveAffirmation => 'Guardar Afirmación';

  @override
  String diaryAffirmationsRemaining(String used) {
    return 'Afirmaciones restantes hoy: $used';
  }

  @override
  String get diaryAffirmationCreated =>
      '¡Afirmación creada por el Consejero Místico!';

  @override
  String get diaryAffirmationError => 'Error al generar la afirmación';

  @override
  String get diaryTypeOrGenerate => 'Escribe o genera una afirmación';

  @override
  String get diaryAffirmationLimit =>
      'Alcanzaste el límite diario de afirmaciones. ¡Vuelve mañana o hazte Premium!';

  @override
  String get diaryDeleteAffirmationTitle => 'Eliminar Afirmación';

  @override
  String get diaryDeleteAffirmationConfirm =>
      '¿Seguro que quieres eliminar esta afirmación?';

  @override
  String get diaryLoadingDreams => 'Cargando sueños...';

  @override
  String get diaryEmptyDreams =>
      'Aún no has registrado ningún sueño.\n¡Empieza tu diario de sueños!';

  @override
  String get diaryRegisterDream => 'Registrar Sueño';

  @override
  String get diaryInterpretDream => 'Interpretar Sueño';

  @override
  String get diaryDreamThemes => 'Temas Oníricos';

  @override
  String get toolDreamsTitle => 'Interpretación de Sueños';

  @override
  String get toolDreamsDesc =>
      'Desvela los mensajes de tus sueños y explora significados';

  @override
  String get dreamToolsIntro =>
      'Los sueños hablan en símbolos. Interpreta el tuyo con el Consejero Místico o explora los significados de los temas más comunes.';

  @override
  String get dreamInterpretMyDream => 'Interpretar mi Sueño';

  @override
  String get dreamInterpretMyDreamDesc =>
      'Cuenta tu sueño y recibe una lectura del Consejero Místico';

  @override
  String get dreamMeaningsTitle => 'Significados de los Sueños';

  @override
  String get dreamMeaningsDesc =>
      'Agua, caída, vuelo, dientes y otros temas oníricos — y sus posibles lecturas';

  @override
  String get diaryLoadingGratitudes => 'Cargando gratitudes...';

  @override
  String get diaryEmptyGratitudes =>
      'Aún no has registrado ninguna gratitud.\n¡Empieza a cultivar abundancia en tu vida!';

  @override
  String get diaryAddGratitude => 'Añadir Gratitud';

  @override
  String get diaryLoadingDesires => 'Cargando deseos...';

  @override
  String get diaryEmptyDesires =>
      'Aún no has registrado ningún deseo.\n¡Empieza a manifestar tus sueños!';

  @override
  String get diaryAddDesire => 'Añadir Deseo';

  @override
  String get diaryLoadingAffirmations => 'Cargando afirmaciones...';

  @override
  String get diaryAllCategories => 'Todas';

  @override
  String get diaryEmptyAffirmationsCategory =>
      'No hay afirmaciones en esta categoría.\n¡Añade tus propias afirmaciones!';

  @override
  String get diaryAddAffirmation => 'Añadir Afirmación';

  @override
  String get commonGoodMorning => 'Buenos días ✨';

  @override
  String get commonGoodAfternoon => 'Buenas tardes ✨';

  @override
  String get commonGoodEvening => 'Buenas noches ✨';

  @override
  String get diaryPreviousReflections => 'Reflexiones anteriores';

  @override
  String get diarySaveReflection => 'Guardar reflexión';

  @override
  String get diaryFreeWritingHint => '¿Qué tienes en mente hoy?';

  @override
  String get diaryReflections => 'Reflexiones';

  @override
  String get diaryLoadingReflections => 'Cargando reflexiones...';

  @override
  String get diaryEmptyReflections =>
      'Tus reflexiones aparecerán aquí.\nEscribe lo que tengas en mente. ✨';

  @override
  String get diaryDeleteReflectionTitle => 'Eliminar reflexión';

  @override
  String get diaryDeleteReflectionConfirm =>
      '¿Seguro que quieres eliminar esta reflexión?';

  @override
  String get diaryDreamThemesIntro =>
      'Cada símbolo tiene muchas lecturas posibles. Explora los temas más comunes y compáralos con lo que sentiste en el sueño.';

  @override
  String get dreamDescribeFirst => 'Describe tu sueño primero';

  @override
  String get dreamInterpretedTitle => 'Sueño interpretado';

  @override
  String get dreamNotesPrefix => 'Observaciones';

  @override
  String get dreamSavedToDiary =>
      '¡Sueño e interpretación guardados en el Diario! 🌙';

  @override
  String get dreamInterpretationTitle => 'Interpretación de Sueños';

  @override
  String get dreamPremiumOnly =>
      'La interpretación personalizada de sueños es exclusiva del plan Premium.';

  @override
  String get dreamTellYourDream => 'Cuenta tu sueño';

  @override
  String get dreamTellHelp =>
      'Descríbelo con el mayor detalle posible: lugares, personas, símbolos, sensaciones y todo lo que recuerdes.';

  @override
  String get dreamTextHint => 'Estaba en un bosque y…';

  @override
  String get dreamFeelingOptional =>
      '¿Cómo te sentiste al despertar? (opcional)';

  @override
  String get dreamInterpreting => 'Interpretando…';

  @override
  String get dreamInterpretAgain => 'Interpretar de nuevo';

  @override
  String get dreamInterpretationLabel => 'Interpretación';

  @override
  String get dreamSaveToDiary => 'Guardar en el Diario de Sueños';

  @override
  String get dreamDateLabel => 'Fecha del sueño';

  @override
  String get dreamNotesOptional => 'Observaciones (opcional)';

  @override
  String get dreamSavedShort => 'Guardado en el Diario';

  @override
  String get tarotTabDraw => 'Tirada';

  @override
  String get tarotTabLearn => 'Aprender';

  @override
  String get tarotDailyCard => 'Carta del Día';

  @override
  String get tarotThreeCards => 'Tres Cartas';

  @override
  String get tarotCross => 'Cruz de Cinco';

  @override
  String get tarotDailyDesc => 'La energía que acompaña tu día';

  @override
  String get tarotThreeDesc => 'Pasado · Presente · Futuro';

  @override
  String get tarotCrossDesc => 'Situación, desafío, raíz, consejo y tendencia';

  @override
  String get tarotPosPast => 'Pasado';

  @override
  String get tarotPosPresent => 'Presente';

  @override
  String get tarotPosFuture => 'Futuro';

  @override
  String get tarotPosSituation => 'Situación';

  @override
  String get tarotPosChallenge => 'Desafío';

  @override
  String get tarotPosRoot => 'Raíz';

  @override
  String get tarotPosAdvice => 'Consejo';

  @override
  String get tarotPosTendency => 'Tendencia';

  @override
  String get tarotFreeLimitReached =>
      'Ya hiciste tu tirada gratuita de hoy. ¡Hazte Premium para tiradas ilimitadas!';

  @override
  String get tarotSpreadLabel => 'Tirada';

  @override
  String get tarotReversed => 'invertida';

  @override
  String get tarotBreathe =>
      'Respira hondo, piensa en tu pregunta y elige una tirada.';

  @override
  String get tarotNewSpread => 'Nueva tirada';

  @override
  String get tarotConsultingCards => 'Consultando las cartas…';

  @override
  String get tarotAdvisorInterpretation =>
      'Interpretación del Consejero Místico';

  @override
  String get tarotBestCombo => 'Mejor combo';

  @override
  String get tarotDayStreak => 'Días seguidos';

  @override
  String get tarotAccuracy => 'Precisión';

  @override
  String tarotAnsweredOf(String answered, String total) {
    return '$answered respondidas · $total cartas en el mazo';
  }

  @override
  String get tarotQuizTitle => 'Pon a prueba lo que sabes';

  @override
  String get tarotQuizDesc =>
      'Una sesión de preguntas mezcladas sobre los significados de las cartas. Los aciertos consecutivos forman combo — vuelve cada día para mantener la racha.';

  @override
  String get tarotQuizStart => 'Sesión de 10 preguntas';

  @override
  String get tarotQuizBrilliant => '¡Brillante! ✨';

  @override
  String get tarotQuizDone => 'Sesión completada 🌙';

  @override
  String tarotQuizScore(String correct, String total) {
    return 'Acertaste $correct de $total.';
  }

  @override
  String get tarotQuizPraise => ' Las cartas reconocen tu dedicación.';

  @override
  String get tarotQuizEncourage =>
      ' Sigue practicando — cada sesión profundiza la lectura.';

  @override
  String get tarotQuizFinish => 'Concluir';

  @override
  String tarotQuizQuestion(String card) {
    return '¿Qué representa $card?';
  }

  @override
  @override
  String get palmRemainingToday => 'Lecturas restantes hoy';

  @override
  String get palmDailyLimitReached =>
      'Ya hiciste tus lecturas de manos de hoy. Vuelve mañana para más. ✨';

  @override
  String get palmRateLimit =>
      'Demasiadas lecturas en poco tiempo. Espera unos instantes y envía la foto de nuevo.';

  String get palmImageTooLarge =>
      'La imagen es demasiado grande. Prueba con menos zoom u otra foto.';

  @override
  String get palmImageTooSmall =>
      'La imagen parece demasiado pequeña u oscura para leerla. Fotografía la palma bien iluminada, llenando la pantalla.';

  @override
  String get palmReadingHeader => 'Lectura de Manos';

  @override
  String get palmSavedToReflections =>
      '¡Lectura guardada en tus Reflexiones! ✨';

  @override
  String get palmistryTitle => 'Quiromancia';

  @override
  String get palmPremiumOnly =>
      'La lectura de manos es exclusiva del plan Premium.';

  @override
  String get palmHowTo => '🖐️ Cómo fotografiar';

  @override
  String get palmTip1 => 'Palma de la mano dominante abierta y relajada';

  @override
  String get palmTip2 => 'Luz natural, sin sombras fuertes sobre las líneas';

  @override
  String get palmTip3 => 'La palma debe llenar casi toda la foto';

  @override
  String get palmTip4 => 'Evita fotos movidas o desenfocadas';

  @override
  String get palmPrivacyNote =>
      'Privacidad: la foto se procesa al momento y se descarta — no se guarda en el dispositivo ni en servidores.';

  @override
  String get palmCamera => 'Cámara';

  @override
  String get palmGallery => 'Galería';

  @override
  String get palmReadingLines => 'Leyendo las líneas de tu mano…';

  @override
  String get palmYourReading => '✨ Tu Lectura';

  @override
  String get palmDisclaimer =>
      'Lectura simbólica para reflexionar — no sustituye la orientación médica, psicológica o profesional.';

  @override
  String get palmSavedShort => 'Guardada en Reflexiones';

  @override
  String get palmSaveReading => 'Guardar lectura';

  @override
  String get numMagicOfNumbers => 'La Magia de los Números';

  @override
  String get numIntro =>
      'Explora los números que vibran en tu vida: tu perfil de nacimiento, el significado de cualquier número, las horas espejo y las secuencias que insisten en aparecer.';

  @override
  String get numPersonalProfile => 'Perfil Personal';

  @override
  String get numPersonalProfileDesc =>
      'Tus 5 números clave a partir del nombre y la fecha de nacimiento';

  @override
  String get numLookupTitle => 'Consultar un Número';

  @override
  String get numLookupDesc => '¿Un número te acompaña? Descubre su vibración';

  @override
  String get numMirrorHours => 'Horas Espejo';

  @override
  String get numMirrorHoursDesc =>
      'El mensaje de las horas dobles: 11:11, 22:22 y más';

  @override
  String get numSequences => 'Secuencias Repetidas';

  @override
  String get numSequencesDesc =>
      'El significado de patrones como 333, 1010 y 1234';

  @override
  String get numWhichNumber => '¿Qué número te acompaña?';

  @override
  String get numLookupHelp =>
      'Placas, fechas, puertas, recibos… escribe el número y ve su esencia numerológica.';

  @override
  String get numLookupHint => 'Ej.: 713';

  @override
  String get numSee => 'Ver';

  @override
  String numReducesTo(String original, String result) {
    return '$original se reduce a $result';
  }

  @override
  String get numMirrorIntro =>
      '¿Miraste el reloj justo en una hora doble? Cada espejo lleva una vibración numérica. Toca para ver el mensaje.';

  @override
  String numVibrationOf(String number) {
    return 'Vibración del número $number';
  }

  @override
  String numMirrorMessage(String label) {
    return 'Mensaje del espejo $label';
  }

  @override
  String get numSequencesIntro =>
      'Ese número que aparece en todas partes puede ser un patrón pidiendo atención. Los clásicos:';

  @override
  String numVibratesIn(String number) {
    return 'vibra en el $number';
  }

  @override
  String get numFillNameAndDate =>
      'Ingresa el nombre completo y la fecha de nacimiento';

  @override
  String get numDailyLimit =>
      'Límite diario alcanzado. Hazte Premium para consultas ilimitadas.';

  @override
  String get numYourBirthData => 'Tus datos de nacimiento';

  @override
  String get numBirthNameHelp =>
      'Usa el nombre completo de nacimiento — es el que lleva la firma numerológica original.';

  @override
  String get numFullName => 'Nombre completo';

  @override
  String get numChooseBirthDate => 'Elegir fecha de nacimiento';

  @override
  String get numBirthPrefix => 'Nacimiento';

  @override
  String get numCalculate => 'Calcular mis números';

  @override
  String get numSynthesisQuestion =>
      '¿Quieres una síntesis de cómo estos números dialogan entre sí?';

  @override
  String get numWeavingSynthesis => 'Tejiendo la síntesis…';

  @override
  String get numAdvisorExplanation => 'Explicación del Consejero Místico';

  @override
  String get sigilCreateTitle => 'Crear Sigilo';

  @override
  String get sigilWhatIs => '¿Qué es un Sigilo?';

  @override
  String get sigilWhatIsDesc =>
      'Los sigilos son símbolos mágicos creados para manifestar intenciones. Al transformar palabras en símbolos abstractos, creas una marca energética que lleva el poder de tu voluntad sin revelar tu intención a otras personas.';

  @override
  String get sigilHowIntro =>
      'Define tu intención, elige una palabra que la represente, y la app creará automáticamente tu sigilo único.';

  @override
  String get sigilSetIntention => 'Define tu Intención';

  @override
  String get sigilIntentionWord => 'Tu palabra de intención';

  @override
  String get sigilTypeWord => 'Escribe una palabra...';

  @override
  String get sigilOneWordWarning => '⚠️ Usa solo UNA palabra, sin espacios';

  @override
  String get sigilExamplesHeader => '💡 Ejemplos de palabras';

  @override
  String get sigilExample1 => 'Prosperidad';

  @override
  String get sigilExample2 => 'Protección';

  @override
  String get sigilExample3 => 'Sanación';

  @override
  String get sigilExample4 => 'Confianza';

  @override
  String get sigilExample5 => 'Intuición';

  @override
  String get sigilWordTip =>
      'Consejo: Elige palabras positivas y específicas que resuenen contigo.';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get sigilMagicLetters => 'Letras Mágicas';

  @override
  String get sigilYourLetters => 'Las Letras de tu Sigilo';

  @override
  String get sigilEssence => 'La esencia mágica de tu intención';

  @override
  String get sigilYourIntention => 'Tu intención:';

  @override
  String get sigilTransformedInto => 'Transformada en:';

  @override
  String get sigilWhatHappened => '¿Qué pasó?';

  @override
  String get sigilSimplified =>
      'Tu palabra fue simplificada siguiendo la tradición de los sigilos:';

  @override
  String get sigilStepAccents => '1. Se normalizaron los acentos';

  @override
  String get sigilStepSpaces => '2. Se eliminaron espacios y símbolos';

  @override
  String get sigilStepDupes =>
      '3. Se eliminaron las letras duplicadas (solo se mantiene la primera aparición)';

  @override
  String get sigilWheelNote =>
      'Esta secuencia simplificada se conectará en la Rueda de las Brujas para formar el símbolo mágico de tu sigilo.';

  @override
  String get sigilSeeDrawing => 'Ver Dibujo del Sigilo';

  @override
  String get sigilSaveError => 'No se pudo guardar el sigilo';

  @override
  String get sigilDrawingNotReady => 'El dibujo aún no está listo';

  @override
  String get sigilImageError => 'Error al generar la imagen';

  @override
  String get sigilSavedToGallery => '¡Sigilo guardado en la galería! ✨';

  @override
  String get sigilGalleryPermission =>
      'Permite el acceso a la galería para guardar el sigilo.';

  @override
  String get sigilImageSaveError => 'No se pudo guardar la imagen.';

  @override
  String get sigilYourSigil => 'Tu Sigilo';

  @override
  String get sigilYourDrawing => 'El Dibujo de tu Sigilo';

  @override
  String get sigilLegendStart => 'Inicio';

  @override
  String get sigilLegendLetters => 'Letras';

  @override
  String get sigilLegendEnd => 'Fin';

  @override
  String get sigilWheel => 'Rueda';

  @override
  String get sigilPoints => 'Puntos';

  @override
  String get sigilShuffle => 'Mezclar letras';

  @override
  String get sigilSaveImage => 'Guardar imagen en la galería';

  @override
  String get sigilRestore => 'Restaurar posiciones';

  @override
  String get sigilHowToUse => 'Cómo usar tu sigilo';

  @override
  String get sigilUse1Title => '1. Copia este dibujo';

  @override
  String get sigilUse1Desc =>
      'Reproduce el trazado en tu cuaderno, altar, vela o papel ritual.';

  @override
  String get sigilUse2Title => '2. Personaliza';

  @override
  String get sigilUse2Desc =>
      'Simplifica, gira o añade detalles. Hacerlo tuyo es parte de la magia.';

  @override
  String get sigilUse3Title => '3. Activa el sigilo';

  @override
  String get sigilUse3Desc =>
      'Úsalo en meditación, quémalo en ritual o llévalo contigo para enfocar tu intención.';

  @override
  String get sigilRemember =>
      'Recuerda: la magia está en tu intención y en el acto de crear, no solo en el dibujo final.';

  @override
  String get commonSaving => 'Guardando...';

  @override
  String get commonFinish => 'Finalizar';

  @override
  String get advisorAskFirst => 'Haz tu pregunta primero';

  @override
  String get advisorDailyLimit =>
      'Ya consultaste al Consejero hoy. ¡Vuelve mañana o hazte Premium!';

  @override
  String get advisorGenericError =>
      'El consejero no pudo responder ahora. Inténtalo de nuevo más tarde.';

  @override
  String get advisorRateLimited =>
      'El consejero necesita descansar. Se hicieron demasiadas peticiones. Espera unos minutos.';

  @override
  String get advisorTempError =>
      'Error temporal en el servicio místico. Inténtalo de nuevo en unos instantes.';

  @override
  String get advisorConnectionError =>
      'Error de conexión. Verifica tu internet e inténtalo de nuevo.';

  @override
  String get advisorPortalClosed =>
      'El portal místico está cerrado temporalmente. Inténtalo de nuevo en unos minutos.';

  @override
  String get advisorWisdomTitle => 'La Sabiduría del Consejero';

  @override
  String get advisorIntro =>
      'Haz una pregunta sobre brujería, magia o misticismo, y el consejero compartirá su sabiduría ancestral 🪄';

  @override
  String get advisorQuestionHint =>
      'Ej.: ¿Cuál es la mejor fase lunar para un ritual de protección?';

  @override
  String get advisorConsultingStars => 'Consultando los astros...';

  @override
  String get advisorConsult => 'Consultar al Consejero';

  @override
  String advisorRemainingToday(String used) {
    return 'Consultas restantes hoy: $used';
  }

  @override
  String get advisorAnswers => 'El Consejero responde';

  @override
  String get spellGroupProtection => 'Protección y Limpieza';

  @override
  String get spellGroupProtectionSub => 'Defensa, destierro y purificación';

  @override
  String get spellGroupLove => 'Amor y Lazos';

  @override
  String get spellGroupLoveSub => 'Amor, autoestima y amistad';

  @override
  String get spellGroupProsperity => 'Prosperidad y Caminos';

  @override
  String get spellGroupProsperitySub =>
      'Abundancia, suerte, trabajo y estudios';

  @override
  String get spellGroupDreams => 'Sueños y Visiones';

  @override
  String get spellGroupDreamsSub => 'Adivinación, sueños y sabiduría';

  @override
  String get spellGroupEnergy => 'Energía y Sanación';

  @override
  String get spellGroupEnergySub => 'Vitalidad, sanación y coraje';

  @override
  String get spellGroupCreation => 'Creación y Palabra';

  @override
  String get spellGroupCreationSub => 'Creatividad y comunicación';

  @override
  String get spellGroupHome => 'Hogar y Cotidiano';

  @override
  String get spellGroupHomeSub => 'Casa, familia y el día a día';

  @override
  String get grimoireSearchSpells => 'Buscar hechizos...';

  @override
  String get grimoireMySpells => 'Mis Hechizos';

  @override
  String get grimoireMySpellsSub => 'Creaciones y registros personales';

  @override
  String get grimoireNoSpellsFound => 'No se encontraron hechizos 🔍';

  @override
  String get grimoireAncestral => 'Ancestral';

  @override
  String get spellNew => 'Nuevo Hechizo';

  @override
  String get spellEdit => 'Editar Hechizo';

  @override
  String get spellNameLabel => 'Nombre del Hechizo *';

  @override
  String get spellNameHint => 'Ej.: Protección del Hogar';

  @override
  String get commonRequired => 'Campo obligatorio';

  @override
  String get spellPurposeLabel => 'Propósito *';

  @override
  String get spellPurposeHint => 'Ej.: Protección, Amor Propio, Prosperidad';

  @override
  String get spellTypeLabel => 'Tipo de Hechizo *';

  @override
  String get spellCategoryLabel => 'Categoría *';

  @override
  String get spellMoonPhaseLabel => 'Fase Lunar (Opcional)';

  @override
  String get commonNone => 'Ninguna';

  @override
  String get spellIngredientsLabel => 'Ingredientes';

  @override
  String get spellIngredientsHint => 'Escribe un ingrediente por línea';

  @override
  String get spellHowToLabel => 'Cómo Realizar *';

  @override
  String get spellHowToHint => 'Describe los pasos del ritual';

  @override
  String get spellDurationLabel => 'Duración (en días)';

  @override
  String get spellDurationHint => 'Ej.: 3';

  @override
  String get spellNotesLabel => 'Observaciones';

  @override
  String get spellNotesHint => 'Resultados, sensaciones, anotaciones...';

  @override
  String get spellAdd => 'Añadir Hechizo';

  @override
  String get spellFilterByCategory => 'Filtrar por categoría';

  @override
  String get spellAllCategories => 'Todas las Categorías';

  @override
  String get spellSourceAll => 'Todos';

  @override
  String get spellSourceMine => 'Míos';

  @override
  String get spellSourceAncestral => 'Ancestrales';

  @override
  String get spellLoading => 'Cargando hechizos...';

  @override
  String get spellNoneFound => 'No se encontraron hechizos';

  @override
  String get spellNoAncestral => 'No hay hechizos ancestrales disponibles';

  @override
  String get spellEmptyGrimoire =>
      'Tu grimorio está vacío.\n¡Empieza añadiendo tu primer hechizo!';

  @override
  String get spellMoonPrefix => 'Luna';

  @override
  String get spellSavedToGrimoire => '¡Hechizo guardado en tu grimorio! ✨';

  @override
  String get spellDetails => 'Detalles';

  @override
  String get spellSaveToGrimoire => 'Guardar en el Grimorio';

  @override
  String get spellRecommendedMoon => 'Fase Lunar Recomendada';

  @override
  String get spellHowTo => 'Cómo Realizar';

  @override
  String spellDurationDays(String duration) {
    return 'Duración: $duration';
  }

  @override
  String get spellDay => 'día';

  @override
  String get spellDays => 'días';

  @override
  String spellCreatedAt(String date) {
    return 'Creado el: $date';
  }

  @override
  String spellUpdatedAt(String date) {
    return 'Actualizado el: $date';
  }

  @override
  String spellDeleteConfirm(String name) {
    return '¿Realmente quieres eliminar el hechizo \"$name\"?';
  }

  @override
  String get recordDetails => 'Registro';

  @override
  String get recordEditTitle => 'Editar Registro';

  @override
  String get recordTitleLabel => 'Título *';

  @override
  String get recordContentLabel => 'Tu página';

  @override
  String get recordTitleRequired => 'Dale un título al registro';

  @override
  String get recordContentRequired => 'Escribe algo antes de guardar';

  @override
  String get recordUpdated => '¡Registro actualizado! ✨';

  @override
  String recordDeleteConfirm(String name) {
    return '¿Realmente quieres eliminar el registro \"$name\"?';
  }

  @override
  String get aiSpellDescribeFirst => 'Describe tu intención primero';

  @override
  String get aiSpellDailyLimit =>
      'Alcanzaste el límite diario de consultas. ¡Vuelve mañana o hazte Premium!';

  @override
  String get aiSpellGenericError =>
      'El consejero no pudo manifestar el hechizo. Inténtalo de nuevo más tarde.';

  @override
  String get aiSpellDescribeIntention => 'Describe tu Intención';

  @override
  String get aiSpellIntentionHelp =>
      'Comparte lo que deseas manifestar. ¡Cuantos más detalles, más poderoso será el hechizo!';

  @override
  String get aiSpellIntentionHint =>
      'Ej.: Quiero atraer prosperidad financiera para pagar mis cuentas y tener más tranquilidad';

  @override
  String get aiSpellManifesting => 'Manifestando...';

  @override
  String get aiSpellManifest => 'Manifestar Hechizo ✨';

  @override
  String get aiSpellSeeDetails => 'Ver Detalles';

  @override
  String get learnUnlockPrevious =>
      'Completa la lección anterior para desbloquear esta.';

  @override
  String learnLessonN(String number, String title) {
    return 'Lección $number — $title';
  }

  @override
  String learnPageWritten(String title) {
    return 'Página escrita: \"$title\"';
  }

  @override
  String get learnPremiumLesson => 'Lección Premium';

  @override
  String learnCreatesPage(String title) {
    return 'Crea la página: \"$title\"';
  }

  @override
  String get learnToFill => '(por completar)';

  @override
  String learnPageNote(String trail, String lesson) {
    return 'Página del Grimorio Vivo — $trail · $lesson';
  }

  @override
  String get learnTrailBound => '¡Ruta Encuadernada!';

  @override
  String get learnPageDone => '¡Página escrita!';

  @override
  String learnChapterBound(String title) {
    return 'El capítulo \"$title\" ahora es un libro encuadernado en tu grimorio — escrito por ti.';
  }

  @override
  String get learnNewTitle => 'Nuevo título';

  @override
  String get learnSoBeIt => 'Que así sea ✨';

  @override
  String get learnPracticeGoal => 'Objetivo';

  @override
  String get learnPracticeHow => 'Cómo hacerlo';

  @override
  String get learnPracticeThen => 'Después de la práctica';

  @override
  String get learnStepTeaching => '📜 Enseñanza';

  @override
  String get learnStepPractice => '🕯️ Práctica';

  @override
  String get learnStepPage => '✍️ La Página';

  @override
  String get learnGoToPractice => 'Ir a la práctica';

  @override
  String get learnDidPractice => 'Hice la práctica (o la haré hoy)';

  @override
  String get learnWriteMyPage => 'Escribir mi página';

  @override
  String get learnAnswerHelp =>
      'Responde con tus palabras — la app arma la página y la guarda en Mi Grimorio. Es tuya para siempre.';

  @override
  String get learnPageTitleLabel => 'Título de la página';

  @override
  String get learnWriteHere => 'Escribe aquí…';

  @override
  String get learnSealPage => 'Sellar página en el grimorio';

  @override
  String get learnHomeTitle => 'Aprende escribiendo tu grimorio';

  @override
  String get learnHomeSubtitle =>
      'Cada lección termina con una página creada por ti en Mi Grimorio. Al completar una ruta, el capítulo es tuyo — escrito de tu puño y letra.';

  @override
  String get learnMaxTitle => 'Título máximo alcanzado ✨';

  @override
  String learnNextTitle(String pages, String title, String xp) {
    return '$pages páginas escritas · próximo título: $title ($xp XP)';
  }

  @override
  String get learnBoundShort => '¡Encuadernada!';

  @override
  String learnPagesProgress(String done, String total) {
    return '$done/$total páginas';
  }

  @override
  String learnBoundVolume(String count) {
    return '📕 Volumen encuadernado — $count páginas escritas por ti';
  }

  @override
  String get oracleDailyLimit =>
      'Alcanzaste el límite diario de lecturas. ¡Vuelve mañana o hazte Premium!';

  @override
  String get oracleTitle => 'Cartas del Oráculo';

  @override
  String get oracleSubtitle => 'Recibe orientación y mensajes del universo';

  @override
  String get oracleDrawing => 'Sacando cartas...';

  @override
  String get oracleDraw => 'Sacar Cartas';

  @override
  String oracleRemainingToday(String used) {
    return 'Lecturas restantes hoy: $used';
  }

  @override
  String get oracleNewReading => 'Nueva Lectura';

  @override
  String get oracleYourReading => 'Tu Lectura';

  @override
  String get pendulumUsedAll =>
      'Ya usaste tus 3 consultas de hoy. ¡Vuelve mañana!';

  @override
  String get pendulumAskFirst => 'Haz una pregunta primero';

  @override
  String get pendulumTitle => 'Péndulo';

  @override
  String get pendulumConsult => 'Consultar el Péndulo';

  @override
  String get pendulumIntro =>
      'Haz preguntas de sí o no. Concéntrate y confía en la respuesta.';

  @override
  String get pendulumUnlimitedAdmin => 'Consultas ilimitadas (Admin)';

  @override
  String pendulumUsedComeBack(String used, String total) {
    return 'Consultas usadas ($used/$total) - vuelve mañana';
  }

  @override
  String get pendulumYourQuestion => 'Tu Pregunta';

  @override
  String get pendulumQuestionHint => 'Ej.: ¿Debo aceptar ese empleo?';

  @override
  String get pendulumAsking => 'Consultando...';

  @override
  String get pendulumAsk => 'Preguntar';

  @override
  String get pendulumNewConsult => 'Nueva Consulta';

  @override
  String get pendulumYes => 'SÍ';

  @override
  String get pendulumNo => 'NO';

  @override
  String get pendulumMaybe => 'TAL VEZ';

  @override
  String get runesNoQuestion => 'Sin pregunta';

  @override
  String get runesReadingTitle => 'Lectura de Runas';

  @override
  String get runesReadingIntro =>
      'Las runas son símbolos del alfabeto rúnico nórdico usado para adivinación. Cada runa puede aparecer en posición normal o invertida (cuando aplica), cambiando su significado.';

  @override
  String get runesReversedNote =>
      'Runas Invertidas: Cuando una runa aparece boca abajo, suele indicar bloqueos o aspectos desafiantes del significado original.';

  @override
  String get runesChooseLayout => 'Elige un Diseño';

  @override
  String get runesQuestionOptional => 'Tu Pregunta (opcional)';

  @override
  String get runesQuestionHint => '¿Qué deben revelar las runas?';

  @override
  String get runesDrawing => 'Sacando runas...';

  @override
  String get runesDraw => 'Sacar Runas';

  @override
  String get runesReversed => 'Invertida';

  @override
  String get runesListTitle => 'Runas';

  @override
  String get runesAbout => 'Sobre las Runas';

  @override
  String get runesAboutText =>
      'Las runas son un alfabeto antiguo usado por los pueblos germánicos y nórdicos. Además de escritura, cada runa lleva significados simbólicos profundos y puede usarse para reflexión, autoconocimiento y lectura oracular.';

  @override
  String get runesExplore =>
      'Explora las 24 runas del Futhark Antiguo abajo. Toca cada una para conocer su significado.';

  @override
  String get runesElderFuthark => 'Futhark Antiguo';

  @override
  String get runesKeywords => 'Palabras clave';

  @override
  String get runesMeaning => 'Significado';

  @override
  String get runesRemember =>
      'Recuerda: las runas son herramientas de reflexión y autoconocimiento. Úsalas como punto de partida para explorar tus propias percepciones e intuiciones.';

  @override
  String get astroMysticTitle => 'Astrología Mística';

  @override
  String get astroMysticSubtitle =>
      'Descubre tu carta astral y perfil mágico personalizado';

  @override
  String get astroZodiacSigns => 'Signos del Zodíaco';

  @override
  String get astroZodiacSignsDesc =>
      'Conoce los 12 signos y sus significados mágicos';

  @override
  String get astroBirthChart => 'Carta Astral';

  @override
  String get astroSeeChart => 'Ver tu carta astral completa';

  @override
  String get astroCreateChart => 'Crear tu carta astral';

  @override
  String get astroMagicMirror => 'Espejo mágico';

  @override
  String get astroMagicalProfile => 'Perfil Mágico';

  @override
  String get astroMagicalProfileDesc =>
      'Interpretación astrológica para brujería';

  @override
  String get astroDailyWeather => 'Clima Mágico Diario';

  @override
  String get astroDailyWeatherDesc =>
      'Tránsitos planetarios y la energía del día';

  @override
  String get astroSuggestions => 'Sugerencias Personalizadas';

  @override
  String get astroSuggestionsDesc => 'Prácticas basadas en tus tránsitos';

  @override
  String get astroRecalculate => 'Recalcular Carta';

  @override
  String get astroRecalculateDesc => 'Crear una nueva carta astral';

  @override
  String get astroAbout => 'Sobre la Astrología';

  @override
  String get astroAboutText =>
      'Tu carta astral se calcula según la posición de los planetas en el momento y lugar de tu nacimiento. El perfil mágico interpreta esas posiciones de forma específica para prácticas de brujería.';

  @override
  String get astroHaveOnHand => 'Para mejores resultados, ten a mano:';

  @override
  String get astroBirthDate => 'Fecha de nacimiento';

  @override
  String get astroBirthTime => 'Hora exacta de nacimiento';

  @override
  String get astroBirthPlace => 'Lugar de nacimiento (ciudad y país)';

  @override
  String get astroRecalcTitle => '¿Recalcular Carta Astral?';

  @override
  String get astroRecalcConfirm =>
      'Esto reemplazará tu carta astral actual. ¿Estás segura?';

  @override
  String get chartInvalidDate => 'Fecha inválida';

  @override
  String get chartInvalidTime => 'Hora inválida';

  @override
  String get chartPlaceNotFound => 'Lugar no encontrado';

  @override
  String get chartCalcError => 'Error al calcular la carta';

  @override
  String get chartCreateTitle => 'Crear Carta Astral';

  @override
  String get chartYourChart => 'Tu Carta Astral';

  @override
  String get chartIntro =>
      'Para calcular tu carta natal precisa, necesitamos tu fecha, hora y lugar de nacimiento. ¡Cuanto más preciso, mejor!';

  @override
  String get chartBirthDate => 'Fecha de Nacimiento';

  @override
  String get chartDateFormat => 'Escribe en formato dd/mm/aaaa';

  @override
  String get chartDateHint => 'dd/mm/aaaa';

  @override
  String get chartBirthTime => 'Hora de Nacimiento';

  @override
  String get chartTimeImportant =>
      'La hora exacta es importante para calcular el Ascendente y las Casas.';

  @override
  String get chartDontKnowTime => 'No sé la hora exacta';

  @override
  String get chartBirthPlace => 'Lugar de Nacimiento';

  @override
  String get chartTypeToSearch => 'Escribe al menos 3 caracteres para buscar';

  @override
  String get chartPlaceHint => 'Ej.: Madrid, España';

  @override
  String get chartCalculate => 'Calcular Carta Astral ✨';

  @override
  String get chartNoonNote =>
      'Sin la hora exacta, usaremos el mediodía (12:00) y el sistema de casas iguales.';

  @override
  String get settingsLanguageSubtitle =>
      'Elige manualmente el idioma de la app';

  @override
  String get quizTitle => 'Test de Arquetipo';

  @override
  String quizProgress(String current, String total) {
    return '$current de $total';
  }

  @override
  String get quizYourArchetypeIs => 'Tu arquetipo es';

  @override
  String get quizSeeInEncyclopedia => 'Ver en la Enciclopedia';

  @override
  String get quizRetake => 'Repetir el test';

  @override
  String get quizStrongestEnergies => 'Tus energías más fuertes';

  @override
  String get quizMirrorNote =>
      'Los arquetipos son espejos, no cajones: llevas varios — este es el que vibra más fuerte en ti ahora. Explora los demás en la pestaña Arquetipos de la Enciclopedia.';

  @override
  String quizSavedOn(String date) {
    return 'Resultado de tu último test ($date)';
  }

  @override
  String get tarotLibraryTitle => 'Biblioteca de Cartas';

  @override
  String get tarotTutorTitle => 'Tutor de Tarot';

  @override
  String get tarotLibraryDesc =>
      'Las 78 cartas con imagen, significado y lectura invertida';

  @override
  String get tarotFlipCard => 'Invertir carta';

  @override
  String get tarotUnflipCard => 'Posición normal';

  @override
  String get tarotUprightMeaning => 'Significado';

  @override
  String get tarotReversedMeaning => 'Significado invertido';

  @override
  String get grimoireMyRecords => 'Mis Registros';

  @override
  String get grimoireMyRecordsSub =>
      'Páginas del Grimorio Vivo, estudios y reflexiones';

  @override
  String get grimoireNoRecords =>
      'Tus páginas del Grimorio Vivo y registros aparecerán aquí.';

  @override
  String get learnFillAtLeastOne =>
      'Responde al menos una pregunta antes de sellar la página';

  @override
  String learnOpenTool(String tool) {
    return 'Abrir $tool';
  }

  @override
  String get learnToolHint =>
      'Esta lección usa una herramienta de la app — ábrela aquí y vuelve para escribir tu página.';

  @override
  String learnSavesTo(String place) {
    return 'Esta página se guardará en: $place';
  }

  @override
  String get learnPlaceDreams => 'Diario de Sueños';

  @override
  String get learnPlaceGratitude => 'Diario de Gratitud';

  @override
  String get learnPlaceAffirmations => 'Afirmaciones';

  @override
  String get learnPlaceDesires => 'Diario de Deseos';

  @override
  String get learnSection1 => 'Fundamento';

  @override
  String get learnSection2 => 'Profundizando';

  @override
  String get learnSection3 => 'En la práctica';

  @override
  String get learnSection4 => 'Para llevar contigo';
}
