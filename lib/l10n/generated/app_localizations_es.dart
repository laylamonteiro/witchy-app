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
}
