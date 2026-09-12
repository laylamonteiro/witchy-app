import 'package:shared_preferences/shared_preferences.dart';

import 'services/cycle_reading_composer.dart' show CycleReadingSourceOptions;

/// O que ela deixou de fora da análise, guardado entre uma visita e outra.
///
/// POR QUE ISTO EXISTE
/// -------------------
/// Desligar os sonhos não é preferência de sessão: é decisão de intimidade.
/// As quatro chaves viviam só no State da tela de compra, então sair da
/// página as religava todas — e, na visita seguinte, a pessoa podia comprar
/// e gerar a leitura sem perceber que o que ela tinha excluído tinha
/// voltado sozinho. Um "não" que se desfaz quando ninguém está olhando não
/// é um "não".
///
/// Fica no aparelho (SharedPreferences, por conta) e não no banco de
/// propósito: é escolha DESTE aparelho e não precisa viajar para a nuvem —
/// mandar para o servidor a lista do que ela esconde do servidor seria o
/// contrário do que o painel promete.
///
/// A fonte íntima NÃO entra aqui, e isso é decisão, não esquecimento: o
/// escopo menstrual é contrato de UMA geração, preso à revisão do
/// consentimento e à revisão de cada dia. Guardar dias autorizados no
/// aparelho transformaria um sim pontual em sim permanente.
class CycleReadingSourcesStore {
  const CycleReadingSourcesStore();

  static const String _dreamsPrefix = 'cycle_reading_source_dreams_';
  static const String _journalsPrefix = 'cycle_reading_source_journals_';
  static const String _divinationPrefix = 'cycle_reading_source_divination_';
  static const String _practicePrefix = 'cycle_reading_source_practice_';

  /// O que ela escolheu da última vez. Chave ausente = nunca mexeu, e o
  /// padrão da casa continua sendo tudo ligado.
  Future<CycleReadingSourceOptions> load(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return CycleReadingSourceOptions(
        includeDreams: prefs.getBool('$_dreamsPrefix$userId') ?? true,
        includeJournals: prefs.getBool('$_journalsPrefix$userId') ?? true,
        includeDivination: prefs.getBool('$_divinationPrefix$userId') ?? true,
        includePractice: prefs.getBool('$_practicePrefix$userId') ?? true,
      );
    } catch (_) {
      // Preferência ilegível nunca pode segurar a tela: segue no padrão,
      // que é exatamente o estado em que a página sempre abriu.
      return const CycleReadingSourceOptions();
    }
  }

  /// Grava a escolha inteira. Chamado a cada toque numa chave — persistir
  /// primeiro, recontar depois: o número da tela é a consequência, não a
  /// decisão.
  Future<void> save(String userId, CycleReadingSourceOptions options) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_dreamsPrefix$userId', options.includeDreams);
      await prefs.setBool('$_journalsPrefix$userId', options.includeJournals);
      await prefs.setBool(
          '$_divinationPrefix$userId', options.includeDivination);
      await prefs.setBool('$_practicePrefix$userId', options.includePractice);
    } catch (_) {
      // Falhar ao guardar só custa o padrão de volta na próxima visita —
      // nunca a escolha desta sessão, que já está de pé na tela.
    }
  }
}
