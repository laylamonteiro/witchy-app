/// Os atalhos que "Práticas para este momento" oferece.
///
/// Cada um abre uma ferramenta que JÁ EXISTE no Grimório. Não há Tarô
/// menstrual, Diário menstrual nem sistema paralelo de intenções: o Ciclo é
/// a lente que sugere o momento, e o registro nasce e vive no lugar dele.
///
/// O enum mora no domínio (e não na tela) para que a lista do momento possa
/// ser calculada e testada sem montar widget nenhum.
enum MenstrualShortcut {
  /// Escrever sobre algo que chegou ao fim — abre a escrita livre do Diário.
  release,

  /// Escrever sobre algo que começa — a mesma escrita livre do Diário.
  cultivate,

  /// Uma tiragem sobre este ciclo — abre o Oráculo.
  oracle,

  /// Registrar um sonho — abre o Diário de Sonhos.
  dream,

  /// Definir uma intenção — abre o criador de sigilos, que é onde uma
  /// intenção vira gesto no Grimório.
  intention,

  /// Práticas ligadas ao sangue — abre a seção de práticas dos Saberes do
  /// Sangue.
  practices,
}

extension MenstrualShortcutEmoji on MenstrualShortcut {
  /// O emblema do atalho. Invariante: não é texto traduzível.
  String get emoji => switch (this) {
        MenstrualShortcut.release => '🍂',
        MenstrualShortcut.cultivate => '🌱',
        MenstrualShortcut.oracle => '🔮',
        MenstrualShortcut.dream => '🌙',
        MenstrualShortcut.intention => '✨',
        MenstrualShortcut.practices => '🕯️',
      };
}
