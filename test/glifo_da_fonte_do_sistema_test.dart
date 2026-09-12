import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Catraca de fonte do sistema.
///
/// O minSdk do app é 24 (android/app/build.gradle), ou seja Android 7. Emoji
/// lançado depois disso não existe na fonte desses aparelhos e vira
/// quadradinho; sequência ZWJ é pior ainda, porque o aparelho antigo não une
/// as partes e desenha DUAS coisas no lugar de uma.
///
/// Nos lugares listados aqui o glifo carregava informação — o estado de um
/// card, o item de uma lista, o mascote — e por isso foi trocado por ícone do
/// Material (que viaja dentro do app) ou por emoji antigo o bastante. O teste
/// existe para que ele não volte sem que alguém perceba.
///
/// A lista de arquivos é explícita de propósito: varrer `lib/` inteiro faria
/// este teste falhar por causa de conteúdo de outras frentes (os textos de
/// notificação, por exemplo, ainda usam o gato preto).
void main() {
  // Potinho, Emoji 14 — de 2021, logo só de Android 13 para cima.
  const potinho = '\u{1FAD9}';

  // Gato preto: gato + ZWJ + quadrado preto, Emoji 13 — de 2020.
  const gatoPreto = '\u{1F408}\u{200D}\u{2B1B}';

  // Pessoa em lótus, Emoji 5 — de 2017, logo só de Android 8 para cima.
  // Era a categoria "meditação" do card de sugestões: sem ela o card
  // ficava sem o desenho que o separa das outras três categorias.
  const lotus = '\u{1F9D8}';

  // Símbolos de planeta com seletor de emoji (VS16). Quase nenhuma fonte tem
  // a versão colorida que o seletor pede, e o pedido sozinho já basta para o
  // desenho sair errado.
  const planetasComSeletor = <String>[
    '\u{263F}\u{FE0F}', // Mercúrio
    '\u{2640}\u{FE0F}', // Vênus
    '\u{2642}\u{FE0F}', // Marte
  ];

  const arquivos = <String>[
    'lib/features/lunar/presentation/pages/lunar_calendar_page.dart',
    'lib/features/lunar/data/models/moon_content_pt.dart',
    'lib/features/lunar/data/models/moon_content_en.dart',
    'lib/features/lunar/data/models/moon_content_es.dart',
    'lib/core/widgets/mascot/salem_tour.dart',
    'lib/features/settings/presentation/pages/settings_page.dart',
    'lib/features/astrology/presentation/pages/'
        'personalized_suggestions_page.dart',
  ];

  test('glifo que não existe em todo aparelho não volta aos arquivos '
      'já corrigidos', () {
    for (final caminho in arquivos) {
      final arquivo = File(caminho);
      expect(arquivo.existsSync(), isTrue, reason: '$caminho não existe mais');

      final fonte = arquivo.readAsStringSync();

      expect(fonte.contains(potinho), isFalse,
          reason: '$caminho voltou a usar o potinho (U+1FAD9), que não '
              'existe abaixo do Android 13');
      expect(fonte.contains(gatoPreto), isFalse,
          reason: '$caminho voltou a usar o gato preto em sequência ZWJ, '
              'que se parte em dois desenhos no aparelho antigo');
      expect(fonte.contains(lotus), isFalse,
          reason: '$caminho voltou a usar a pessoa em lótus (U+1F9D8), '
              'que não existe abaixo do Android 8');

      for (final simbolo in planetasComSeletor) {
        expect(fonte.contains(simbolo), isFalse,
            reason: '$caminho voltou a pedir versão colorida de um símbolo '
                'de planeta, que a fonte do sistema não tem');
      }
    }
  });

  test('o card de retrógrados separa os dois estados por ícone, não por emoji',
      () {
    final fonte = File('lib/features/astrology/presentation/pages/'
            'personalized_suggestions_page.dart')
        .readAsStringSync();

    // O estado "Mercúrio retrógrado" é o que o desenho precisa distinguir.
    expect(fonte.contains('Icons.sync_problem'), isTrue,
        reason: 'o estado de Mercúrio retrógrado perdeu o ícone que o separa '
            'do estado comum');
    // O mapa de símbolos por planeta saiu de cena junto com o emoji.
    expect(fonte.contains('_retrogradeIcons'), isFalse,
        reason: 'o mapa de símbolos astrológicos voltou — ele depende da '
            'fonte do aparelho');
  });

  test('o Salem do tour cai em ícone quando o PNG não carrega', () {
    final fonte =
        File('lib/core/widgets/mascot/salem_tour.dart').readAsStringSync();

    expect(fonte.contains('Icons.pets'), isTrue,
        reason: 'a reserva do mascote precisa ser um desenho que viaja '
            'dentro do app');
  });
}
