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

  @override
  String get navEncyclopedia => 'Enciclopédia';

  @override
  String get navGrimoire => 'Grimório';

  @override
  String get navDiaries => 'Diários';

  @override
  String get grimoirePageTitle => 'Grimório Digital';

  @override
  String get grimoireTabAstrology => 'Astrologia';

  @override
  String get grimoireTabTools => 'Ferramentas';

  @override
  String get grimoireTabMyGrimoire => 'Meu Grimório';

  @override
  String get diaryPageTitle => 'Diários';

  @override
  String get diaryTabGratitude => 'Gratidão';

  @override
  String get diaryTabAffirmations => 'Afirmações';

  @override
  String get diaryTabDreams => 'Sonhos';

  @override
  String get diaryTabDesires => 'Desejos';

  @override
  String get encyclopediaPageTitle => 'Enciclopédia Mágica';

  @override
  String get encyTabMoon => 'Lua';

  @override
  String get encyTabSabbats => 'Sabbats';

  @override
  String get encyTabCrystals => 'Cristais';

  @override
  String get encyTabHerbs => 'Ervas';

  @override
  String get encyTabMetals => 'Metais';

  @override
  String get encyTabColors => 'Cores';

  @override
  String get encyTabGoddesses => 'Deusas';

  @override
  String get encyTabElements => 'Elementos';

  @override
  String get encyTabAltar => 'Altar';

  @override
  String get encyTabRunes => 'Runas';

  @override
  String get encyTabArchetypes => 'Arquétipos';

  @override
  String get encyTabAngels => 'Anjos';

  @override
  String get encyTabDemons => 'Demônios';

  @override
  String get encyTabSymbols => 'Símbolos';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get toolsHeaderTitle => 'Ferramentas Mágicas';

  @override
  String get toolsHeaderSubtitle =>
      'Recursos para auxiliar em suas práticas de magia e manifestação';

  @override
  String get toolMysticAdvisorTitle => 'Conselheiro Místico';

  @override
  String get toolMysticAdvisorDesc =>
      'Sabedoria ancestral para suas dúvidas de bruxaria e magia';

  @override
  String get toolOracleTitle => 'Cartas do Oráculo';

  @override
  String get toolOracleDesc => 'Mensagens e orientação do universo';

  @override
  String get toolSigilsTitle => 'Sigilos';

  @override
  String get toolSigilsDesc => 'Crie símbolos mágicos para suas intenções';

  @override
  String get toolNumerologyTitle => 'Numerologia';

  @override
  String get toolNumerologyDesc =>
      'Seus números-chave, horas espelho e sequências';

  @override
  String get toolRunesTitle => 'Leitura de Runas';

  @override
  String get toolRunesDesc => 'Consulte as antigas runas nórdicas';

  @override
  String get toolPendulumTitle => 'Pêndulo';

  @override
  String get toolPendulumDesc => 'Perguntas de sim ou não';
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

  @override
  String get navEncyclopedia => 'Enciclopédia';

  @override
  String get navGrimoire => 'Grimório';

  @override
  String get navDiaries => 'Diários';

  @override
  String get grimoirePageTitle => 'Grimório Digital';

  @override
  String get grimoireTabAstrology => 'Astrologia';

  @override
  String get grimoireTabTools => 'Ferramentas';

  @override
  String get grimoireTabMyGrimoire => 'Meu Grimório';

  @override
  String get diaryPageTitle => 'Diários';

  @override
  String get diaryTabGratitude => 'Gratidão';

  @override
  String get diaryTabAffirmations => 'Afirmações';

  @override
  String get diaryTabDreams => 'Sonhos';

  @override
  String get diaryTabDesires => 'Desejos';

  @override
  String get encyclopediaPageTitle => 'Enciclopédia Mágica';

  @override
  String get encyTabMoon => 'Lua';

  @override
  String get encyTabSabbats => 'Sabbats';

  @override
  String get encyTabCrystals => 'Cristais';

  @override
  String get encyTabHerbs => 'Ervas';

  @override
  String get encyTabMetals => 'Metais';

  @override
  String get encyTabColors => 'Cores';

  @override
  String get encyTabGoddesses => 'Deusas';

  @override
  String get encyTabElements => 'Elementos';

  @override
  String get encyTabAltar => 'Altar';

  @override
  String get encyTabRunes => 'Runas';

  @override
  String get encyTabArchetypes => 'Arquétipos';

  @override
  String get encyTabAngels => 'Anjos';

  @override
  String get encyTabDemons => 'Demônios';

  @override
  String get encyTabSymbols => 'Símbolos';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get toolsHeaderTitle => 'Ferramentas Mágicas';

  @override
  String get toolsHeaderSubtitle =>
      'Recursos para auxiliar em suas práticas de magia e manifestação';

  @override
  String get toolMysticAdvisorTitle => 'Conselheiro Místico';

  @override
  String get toolMysticAdvisorDesc =>
      'Sabedoria ancestral para suas dúvidas de bruxaria e magia';

  @override
  String get toolOracleTitle => 'Cartas do Oráculo';

  @override
  String get toolOracleDesc => 'Mensagens e orientação do universo';

  @override
  String get toolSigilsTitle => 'Sigilos';

  @override
  String get toolSigilsDesc => 'Crie símbolos mágicos para suas intenções';

  @override
  String get toolNumerologyTitle => 'Numerologia';

  @override
  String get toolNumerologyDesc =>
      'Seus números-chave, horas espelho e sequências';

  @override
  String get toolRunesTitle => 'Leitura de Runas';

  @override
  String get toolRunesDesc => 'Consulte as antigas runas nórdicas';

  @override
  String get toolPendulumTitle => 'Pêndulo';

  @override
  String get toolPendulumDesc => 'Perguntas de sim ou não';
}
