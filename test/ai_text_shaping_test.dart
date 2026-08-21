import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/ai/ai_service.dart';

/// Forma do texto que volta da IA: a poda do realce pendurado e do título
/// órfão que sobram quando a geração é cortada no meio.
void main() {
  group('semRealcePendurado', () {
    test('tira a marcação que o corte deixou aberta', () {
      // O caso real: a resposta acabou no meio de "do **Ritual…", e o
      // Markdown mostrava os dois asteriscos na tela.
      expect(
        AIService.semRealcePendurado(
          'na criação do *Ritual da Chama*, do **Ritual',
        ),
        'na criação do *Ritual da Chama*, do Ritual',
      );
    });

    test('com marcação aberta E fechada, só a aberta some', () {
      expect(
        AIService.semRealcePendurado('o **fio mais forte** e o **outro'),
        'o **fio mais forte** e o outro',
      );
    });

    test('texto com marcação fechada fica intacto', () {
      const inteiro = 'o **fio mais forte** do período';
      expect(AIService.semRealcePendurado(inteiro), inteiro);
    });

    test('sem marcação nenhuma, nada muda', () {
      expect(AIService.semRealcePendurado('texto simples'), 'texto simples');
    });
  });

  group('semTituloOrfao', () {
    test('remove o cabeçalho que ficou sem corpo no fim', () {
      const cortado = '## Suas Forças\n\nVocê é assim.\n\n## Seus Aliados Mágicos';
      expect(
        AIService.semTituloOrfao(cortado),
        '## Suas Forças\n\nVocê é assim.',
      );
    });

    test('remove também os títulos encadeados e as linhas em branco', () {
      const cortado = '## A\n\nCorpo.\n\n## B\n\n### C\n\n';
      expect(AIService.semTituloOrfao(cortado), '## A\n\nCorpo.');
    });

    test('texto que termina em frase fica intacto', () {
      const inteiro = '## A\n\nCorpo até o fim.';
      expect(AIService.semTituloOrfao(inteiro), inteiro);
    });

    test('texto só de títulos vira vazio, e não meio título', () {
      expect(AIService.semTituloOrfao('## A\n## B\n'), '');
    });
  });
}
