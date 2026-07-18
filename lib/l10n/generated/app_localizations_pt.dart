// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Grimório de Bolso';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Sistema / português do Brasil';

  @override
  String get settingsLanguagePortuguese => 'Português (Brasil)';

  @override
  String get settingsLanguageEnglish => 'Inglês';

  @override
  String get settingsLanguageSpanish => 'Espanhol';

  @override
  String settingsLanguageChanged(String language) {
    return 'Idioma alterado para $language';
  }

  @override
  String get homeTitle => 'Início';

  @override
  String get grimoireTitle => 'Grimório';

  @override
  String get diaryTitle => 'Diário';

  @override
  String get authLogin => 'Entrar';

  @override
  String get authSignup => 'Criar conta';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get encyclopediaTitle => 'Enciclopédia';

  @override
  String get toolsTitle => 'Ferramentas';

  @override
  String get errorsGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Grimório de Bolso';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Sistema / português do Brasil';

  @override
  String get settingsLanguagePortuguese => 'Português (Brasil)';

  @override
  String get settingsLanguageEnglish => 'Inglês';

  @override
  String get settingsLanguageSpanish => 'Espanhol';

  @override
  String settingsLanguageChanged(String language) {
    return 'Idioma alterado para $language';
  }

  @override
  String get homeTitle => 'Início';

  @override
  String get grimoireTitle => 'Grimório';

  @override
  String get diaryTitle => 'Diário';

  @override
  String get authLogin => 'Entrar';

  @override
  String get authSignup => 'Criar conta';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get encyclopediaTitle => 'Enciclopédia';

  @override
  String get toolsTitle => 'Ferramentas';

  @override
  String get errorsGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }
}
