import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/your_day/data/shortcut_registry.dart';

import 'support/short_test_timeout.dart';

/// Todo atalho do "Seu Dia" nasce com um emblema — e com um só.
///
/// O `ShortcutTool` guarda essa regra num `assert`, e `assert` só roda em
/// debug: no app publicado um atalho com os dois campos nulos passaria pelo
/// construtor calado e só apareceria como buraco na grade. Este arquivo é a
/// mesma regra fora do debug, porque o catálogo é uma lista escrita à mão —
/// o campo esquecido é o erro provável, não o impossível.
///
/// É o irmão de `test/tool_identity_test.dart`, que trava o mesmo "ou emoji,
/// ou desenho" das doze ferramentas do Grimório.
void main() {
  useShortTestTimeout();

  test('cada atalho tem emoji OU desenho — nunca os dois, nunca nenhum', () {
    expect(YourDayShortcuts.all, isNotEmpty);
    for (final tool in YourDayShortcuts.all) {
      expect(tool.emoji == null, tool.drawing != null,
          reason: '${tool.id}: o emblema é um emoji ou um desenho');
      final emoji = tool.emoji;
      // Emoji em branco é emblema ausente com outro nome: o atalho apareceria
      // como um espaço vazio sobre o nome da ferramenta.
      if (emoji != null) expect(emoji.trim(), isNotEmpty, reason: tool.id);
    }
  });

  test('os ids são únicos e os padrões existem no catálogo', () {
    // O id é o que vai para o SharedPreferences: id repetido faria `byId`
    // devolver sempre o primeiro, e o atalho gêmeo nunca abriria.
    final ids = YourDayShortcuts.all.map((t) => t.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    // Um padrão sem atalho correspondente é filtrado no `loadIds` e a pessoa
    // abre o Seu Dia com menos atalhos do que a grade foi desenhada para ter.
    for (final id in YourDayShortcuts.defaults) {
      expect(YourDayShortcuts.byId(id), isNotNull, reason: 'padrão $id');
    }
  });
}
