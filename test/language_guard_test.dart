import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/ai/language_guard.dart';

/// A guarda que pega o idioma escapando da resposta da IA — os dois casos
/// que apareceram no app: uma palavra em inglês no meio do Clima Mágico
/// Diário e um trecho em cirílico no meio da interpretação do sonho.
void main() {
  group('escrita de outro alfabeto', () {
    test('pega a palavra em cirílico no meio do texto em português', () {
      // Caso real: "…convite para você soltar a автокобранса e confiar…".
      final intrusos = LanguageGuard.intrusos(
        'Um convite para soltar a автокобранса e confiar no amor.',
        idioma: 'pt-BR',
      );
      expect(intrusos, ['автокобранса']);
    });

    test('pega grego, árabe e japonês do mesmo jeito', () {
      for (final palavra in ['σοφία', 'حكمة', 'ゆめ']) {
        expect(
          LanguageGuard.intrusos('A sabedoria $palavra do dia.',
              idioma: 'pt-BR'),
          [palavra],
          reason: palavra,
        );
      }
    });
  });

  group('palavra de outro idioma do app', () {
    test('pega o "sometimes" no meio do clima do dia', () {
      // Caso real: "A influência de Virgem pode sometimes levar a uma
      // autocrítica excessiva."
      expect(
        LanguageGuard.intrusos(
          'A influência de Virgem pode sometimes levar a uma autocrítica.',
          idioma: 'pt-BR',
        ),
        ['sometimes'],
      );
    });

    test('pega o espanhol no texto em português', () {
      expect(
        LanguageGuard.intrusos('Confie en su corazón, pero com calma.',
            idioma: 'pt'),
        containsAll(['pero', 'corazón']),
      );
    });

    test('pega o português no texto em inglês', () {
      expect(
        LanguageGuard.intrusos('Trust your intuition, você is ready.',
            idioma: 'en'),
        ['você'],
      );
    });

    test('acha a palavra mesmo grudada na pontuação e em maiúscula', () {
      expect(
        LanguageGuard.intrusos('Respire fundo. Sometimes, siga em frente!',
            idioma: 'pt-BR'),
        ['Sometimes'],
      );
    });
  });

  group('o que NÃO é intruso', () {
    test('texto inteiro no idioma pedido passa limpo', () {
      const leitura = '## Energia do Dia\n\n'
          'A Lua em Virgem pede disciplina, foco e um cuidado gentil com '
          'você mesma. Faça um ritual simples de conexão com a terra.';
      expect(LanguageGuard.estaNoIdioma(leitura, idioma: 'pt-BR'), isTrue);
    });

    test('palavra que a própria pessoa escreveu não conta', () {
      // O sonho foi anotado com a palavra em russo; os prompts mandam
      // preservar o conteúdo dela literalmente.
      expect(
        LanguageGuard.intrusos(
          'No seu sonho, a palavra автокобранса aparece como um peso.',
          idioma: 'pt-BR',
          textoDoUsuario: 'sonhei com a palavra автокобранса escrita no muro',
        ),
        isEmpty,
      );
    });

    test('palavra que pt e es dividem não vira falso positivo', () {
      // "nunca", "porque" e "cada" existem nos dois idiomas: acusá-las
      // mandaria leitura boa para reescrita à toa.
      expect(
        LanguageGuard.estaNoIdioma(
          'Nunca duvide, porque cada passo conta.',
          idioma: 'pt-BR',
        ),
        isTrue,
      );
    });

    test('idioma desconhecido não acusa nada', () {
      expect(
        LanguageGuard.intrusos('Vertrouw op je intuïtie.', idioma: 'nl'),
        isEmpty,
      );
    });

    test('texto vazio não acusa nada', () {
      expect(LanguageGuard.intrusos('   ', idioma: 'pt-BR'), isEmpty);
    });
  });
}
