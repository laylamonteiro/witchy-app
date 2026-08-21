import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/ai/ai_service.dart';

/// Forma do texto que volta da IA: contagem de seções (usada para saber se o
/// Perfil Mágico veio inteiro) e a poda do título órfão que sobra quando a
/// geração é cortada logo depois de um cabeçalho.
void main() {
  group('contaSecoes', () {
    test('conta apenas cabeçalhos de nível 2 com conteúdo', () {
      const texto = '''
# Título do documento

## Primeira

Corpo.

## Segunda

Corpo.

### Subseção

Corpo.
''';
      expect(AIService.contaSecoes(texto), 2);
    });

    test('não conta um "##" solto nem "##" no meio da linha', () {
      expect(AIService.contaSecoes('##\n\ntexto ## ainda\n'), 0);
    });

    test('independe do idioma', () {
      expect(AIService.contaSecoes('## Your Essence\nx\n## Final Message\ny'), 2);
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
