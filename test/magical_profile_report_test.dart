import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/magical_profile_report.dart';

/// A Análise Personalizada é guardada como UM markdown e lida como cards.
/// Este teste protege a fronteira entre os dois: o que o provider escreve
/// tem de ser exatamente o que a tela consegue abrir — e perfis gerados
/// antes do formato de chaves não podem parar de abrir.
void main() {
  group('parseMagicalProfile', () {
    test('um ## solto da IA não derruba a grade de dez cards', () {
      // O parser distinguia formato novo de antigo pela presença de
      // `## [chave]`. Bastava a IA escrever um `##` por conta própria dentro
      // de uma seção para nascer uma seção sem chave — e a tela inteira
      // desviava para o modo "perfil antigo", sumindo com a grade de dez
      // cards e com todo botão de tecer de novo. O prompt pede o formato;
      // nada garante que a resposta obedeça.
      final markdown = [
        '${MagicalProfileSections.header(MagicalProfileSections.essence)}\n',
        '### O Sol na Casa 10\n',
        'Corpo do primeiro bloco.\n',
        '## Uma digressão que ninguém pediu\n',
        'Texto da digressão.\n',
        '\n${MagicalProfileSections.header(MagicalProfileSections.shadow)}\n',
        '### A ferida\n',
        'Corpo da sombra.\n',
      ].join();

      final secoes = parseMagicalProfile(markdown);

      // Duas seções, as duas COM chave: nenhuma órfã para desviar a tela.
      expect(secoes, hasLength(2));
      expect(secoes.every((s) => s.key != null), isTrue);
      expect(secoes.first.key, MagicalProfileSections.essence);
      expect(secoes.last.key, MagicalProfileSections.shadow);
    });

    test('o texto do ## solto continua na tela, como mais uma página', () {
      // Rebaixar não pode virar descartar: a pessoa pagou pela geração.
      final markdown = [
        '${MagicalProfileSections.header(MagicalProfileSections.essence)}\n',
        '### O Sol na Casa 10\n',
        'Corpo do primeiro bloco.\n',
        '## Uma digressão que ninguém pediu\n',
        'Texto da digressão.\n',
      ].join();

      final secoes = parseMagicalProfile(markdown);

      expect(secoes, hasLength(1));
      expect(secoes.first.slides, hasLength(2));
      expect(secoes.first.slides.last.title, 'Uma digressão que ninguém pediu');
      expect(secoes.first.slides.last.body, 'Texto da digressão.');
    });

    test('sem nenhuma chave, o formato antigo continua valendo', () {
      // A defesa não pode custar os perfis que já existem: sem `## [chave]`
      // em lugar nenhum, `##` volta a ser título de seção.
      const markdown = '## Sua Essência\n'
          'Corpo da essência.\n'
          '## Sua Sombra\n'
          'Corpo da sombra.\n';

      final secoes = parseMagicalProfile(markdown);

      expect(secoes, hasLength(2));
      expect(secoes.first.key, isNull);
      expect(secoes.first.legacyTitle, 'Sua Essência');
      expect(secoes.last.legacyTitle, 'Sua Sombra');
    });

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

    test('remover uma seção não mexe nas vizinhas', () {
      final markdown = [
        '${MagicalProfileSections.header(MagicalProfileSections.essence)}\n',
        '### A\nCorpo A.\n\n',
        '${MagicalProfileSections.header(MagicalProfileSections.voice)}\n',
        '### B\nCorpo B.\n\n',
        '${MagicalProfileSections.header(MagicalProfileSections.shadow)}\n',
        '### C\nCorpo C.\n',
      ].join();

      final semVoz = removeMagicalProfileSection(
        markdown,
        MagicalProfileSections.voice,
      );
      final secoes = parseMagicalProfile(semVoz);

      expect(secoes.map((s) => s.key), [
        MagicalProfileSections.essence,
        MagicalProfileSections.shadow,
      ]);
      expect(semVoz, isNot(contains('Corpo B.')));
      expect(semVoz, contains('Corpo A.'));
      expect(semVoz, contains('Corpo C.'));
    });

    test('remover a única seção deixa o texto vazio', () {
      final markdown =
          '${MagicalProfileSections.header(MagicalProfileSections.love)}\n\n'
          '### Vênus\nCorpo.\n';
      expect(
        removeMagicalProfileSection(markdown, MagicalProfileSections.love),
        isEmpty,
      );
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
