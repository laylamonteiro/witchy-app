import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/magical_profile_report.dart';

/// A Análise Personalizada é guardada como UM markdown e lida como cards.
/// Este teste protege a fronteira entre os dois: o que o provider escreve
/// tem de ser exatamente o que a tela consegue abrir — e perfis gerados
/// antes do formato de chaves não podem parar de abrir.
void main() {
  group('parseMagicalProfile', () {
    test('lê o formato de chaves e fatia cada seção em páginas', () {
      final markdown = [
        '${MagicalProfileSections.header(MagicalProfileSections.essence)}\n',
        '### O Sol na Casa 10\n',
        'Corpo do primeiro bloco.\n',
        '### Como aparece na prática\n',
        'Corpo do segundo bloco.\n',
        '### O que fazer com isso\n',
        'Corpo do terceiro bloco.\n',
        '\n${MagicalProfileSections.header(MagicalProfileSections.shadow)}\n',
        '### A ferida\n',
        'Corpo da sombra.\n',
      ].join();

      final secoes = parseMagicalProfile(markdown);

      expect(secoes, hasLength(2));
      expect(secoes.first.key, MagicalProfileSections.essence);
      expect(secoes.first.slides, hasLength(3));
      expect(secoes.first.slides[1].title, 'Como aparece na prática');
      expect(secoes.first.slides[1].body, 'Corpo do segundo bloco.');
      expect(secoes.last.key, MagicalProfileSections.shadow);
      expect(secoes.last.slides, hasLength(1));
    });

    test('perfil antigo, sem chave, continua abrindo com o título escrito',
        () {
      const markdown = '''
## Sua Essência Mágica

Um parágrafo curto do formato antigo.

## Mensagem Final

Outro parágrafo.
''';

      final secoes = parseMagicalProfile(markdown);

      expect(secoes, hasLength(2));
      expect(secoes.first.key, isNull);
      expect(secoes.first.legacyTitle, 'Sua Essência Mágica');
      // Sem `###`, o corpo inteiro é UMA página: fatiar por parágrafo criaria
      // páginas de duas linhas, que deslizam sem dizer nada.
      expect(secoes.first.slides, hasLength(1));
      expect(
        secoes.first.slides.single.body,
        'Um parágrafo curto do formato antigo.',
      );
    });

    test('cabeçalho sem corpo não vira card', () {
      final markdown =
          '${MagicalProfileSections.header(MagicalProfileSections.voice)}\n\n'
          '${MagicalProfileSections.header(MagicalProfileSections.love)}\n\n'
          '### Vênus em Peixes\nCorpo.\n';

      final secoes = parseMagicalProfile(markdown);

      expect(secoes, hasLength(1));
      expect(secoes.single.key, MagicalProfileSections.love);
    });

    test('texto sem cabeçalho nenhum não rende seção', () {
      expect(parseMagicalProfile('só um parágrafo solto'), isEmpty);
    });

    test('a ordem das chaves é a ordem de leitura, com a sombra por último',
        () {
      expect(MagicalProfileSections.ordered.first,
          MagicalProfileSections.essence);
      expect(
          MagicalProfileSections.ordered.last, MagicalProfileSections.shadow);
      expect(
        MagicalProfileSections.ordered.toSet(),
        hasLength(MagicalProfileSections.ordered.length),
      );
    });
  });
}
