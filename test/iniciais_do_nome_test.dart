// As iniciais do cabeçalho das Configurações rodam dentro do `build`, e é
// isso que torna um RangeError ali tão caro: a exceção não estraga um
// pedaço da tela, derruba a ABA INTEIRA — e é por ela que se chega a
// Privacidade, Sincronização, Sair da conta e Excluir conta. Quem apagasse
// o próprio nome ficava sem nenhum desses caminhos, sem entender por quê.
//
// Dois nomes estouravam, e os dois são nomes que uma pessoa digita:
//
//   ''           → `''.split(' ')` devolve [''] (UMA parte, não zero), o
//                  código não entrava no ramo de duas partes e caía num
//                  `substring(0, 1)` sobre string de comprimento 0;
//   'Ana  Maria' → `split(' ')` devolve ['Ana', '', 'Maria'], três partes,
//                  e o `[0]` da parte do meio — vazia — estourava.
//
// O diálogo "Editar Perfil" desta mesma tela era a porta: gravava o texto
// sem `trim()` e aceitava vazio (`updateProfile` guarda `''`, porque
// `'' ?? x` é `''`).
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/settings/presentation/pages/settings_page.dart';

void main() {
  group('as iniciais não derrubam a tela de Configurações', () {
    test('nome vazio não estoura — devolve um sinal em vez de exceção', () {
      expect(SettingsPage.iniciaisDoNome(''), '?');
    });

    test('nome só de espaços não estoura', () {
      expect(SettingsPage.iniciaisDoNome('   '), '?');
      expect(SettingsPage.iniciaisDoNome('\t\n'), '?');
    });

    test('dois espaços seguidos não estouram, e as iniciais são as certas',
        () {
      expect(SettingsPage.iniciaisDoNome('Ana  Maria'), 'AM');
      expect(SettingsPage.iniciaisDoNome('Ana   Maria   Silva'), 'AM');
    });

    test('espaço antes e depois não muda o resultado', () {
      expect(SettingsPage.iniciaisDoNome('  Ana Maria  '), 'AM');
      expect(SettingsPage.iniciaisDoNome(' Ana '), 'AN');
    });

    test('quebra de linha e tabulação contam como espaço', () {
      expect(SettingsPage.iniciaisDoNome('Ana\tMaria'), 'AM');
      expect(SettingsPage.iniciaisDoNome('Ana\nMaria'), 'AM');
    });

    test('o comportamento de sempre continua: duas partes, duas iniciais', () {
      expect(SettingsPage.iniciaisDoNome('Ana Maria'), 'AM');
      expect(SettingsPage.iniciaisDoNome('layla monteiro'), 'LM');
    });

    test('nome de uma palavra devolve as duas primeiras letras', () {
      expect(SettingsPage.iniciaisDoNome('Layla'), 'LA');
    });

    test('nome de uma letra só devolve essa letra', () {
      expect(SettingsPage.iniciaisDoNome('L'), 'L');
    });

    test('o e-mail, que é o reserva quando não há nome, também passa', () {
      // O cabeçalho usa `displayName ?? email ?? 'User'`: um e-mail sem
      // espaço nenhum cai no ramo de parte única.
      expect(SettingsPage.iniciaisDoNome('layla@exemplo.com'), 'LA');
    });
  });
}
