import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/app_theme.dart';
import 'package:grimorio_de_bolso/core/theme/grimoire_colors.dart';
import 'package:grimorio_de_bolso/core/widgets/reading_markdown.dart';

/// O defeito que este arquivo guarda:
///
/// a IA escreve markdown, e markdown tem mais formas do que qualquer tela
/// lembra de vestir. Bastou o modelo destacar uma frase com `> ` — coisa que
/// nenhum prompt pediu — para a leitura sair com um retângulo AZUL-CLARO no
/// meio do grimório escuro: o padrão do flutter_markdown, feito para tema
/// claro, aparecendo em tudo o que a tela não tinha estilizado.
///
/// Daí as duas travas aqui: a base veste TODAS as formas, e nenhuma tela
/// volta a montar a sua própria folha do zero.

/// Azul-claro do pacote — a cor exata do defeito relatado.
final _azulDoPacote = Colors.blue.shade100;

double _canalLinear(double c) {
  if (c <= 0.03928) return c / 12.92;
  return math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

double _luminancia(Color c) {
  return 0.2126 * _canalLinear(c.r) +
      0.7152 * _canalLinear(c.g) +
      0.0722 * _canalLinear(c.b);
}

/// A cor que o olho vê quando [frente] (com alfa) está sobre [fundo].
Color _sobre(Color frente, Color fundo) {
  return Color.lerp(fundo, frente.withValues(alpha: 1), frente.a)!;
}

double _contraste(Color a, Color b) {
  final la = _luminancia(a);
  final lb = _luminancia(b);
  final maior = math.max(la, lb);
  final menor = math.min(la, lb);
  return (maior + 0.05) / (menor + 0.05);
}

/// Monta a folha da leitura dentro de um tema de verdade.
Future<MarkdownStyleSheet> _folha(
  WidgetTester tester,
  GrimoireColors cores,
) async {
  late MarkdownStyleSheet folha;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(cores),
      home: Builder(
        builder: (context) {
          folha = readingMarkdownStyle(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return folha;
}

Iterable<BoxDecoration> _decoracoes(WidgetTester tester) {
  return tester
      .widgetList<DecoratedBox>(find.byType(DecoratedBox))
      .map((d) => d.decoration)
      .whereType<BoxDecoration>();
}

void main() {
  group('a folha das leituras', () {
    testWidgets('não deixa forma nenhuma no padrão claro do pacote',
        (tester) async {
      final folha = await _folha(tester, GrimoireColors.vinhoOrquidea);

      // Cada um destes ficava nulo (ou claro) quando a tela montava a folha
      // do zero — e cada um já apareceu, ou pode aparecer, em texto gerado.
      expect(folha.blockquoteDecoration, isNotNull);
      expect(folha.codeblockDecoration, isNotNull);
      expect(folha.horizontalRuleDecoration, isNotNull);
      expect(folha.tableBorder, isNotNull);
      expect(folha.p?.color, isNotNull);
      expect(folha.blockquote?.color, isNotNull);
      expect(folha.listBullet?.color, isNotNull);
      expect(folha.strong?.color, isNotNull);
    });

    testWidgets('o destaque fica legível em todos os temas', (tester) async {
      for (final preset in AppThemes.all) {
        final cores = preset.colors;
        final folha = await _folha(tester, cores);
        final cartao = folha.blockquoteDecoration;
        if (cartao is! BoxDecoration) {
          fail('${preset.id}: o destaque perdeu o cartão');
        }
        final texto = folha.blockquote!.color!;

        expect(
          cartao.color,
          isNot(_azulDoPacote),
          reason: '${preset.id}: o azul do pacote de volta no destaque',
        );

        // O cartão é translúcido: quem decide a legibilidade é a cor que
        // sobra depois de assentar sobre a página.
        for (final fundo in [cores.background, cores.surface]) {
          final contraste = _contraste(texto, _sobre(cartao.color!, fundo));
          expect(
            contraste,
            greaterThanOrEqualTo(4.5),
            reason: '${preset.id}: destaque com contraste de '
                '${contraste.toStringAsFixed(2)}:1 sobre o fundo',
          );
        }
      }
    });

    testWidgets('a frase destacada chega vestida à tela', (tester) async {
      // O texto do print: o destaque que a IA escreveu por conta própria.
      const leitura = '> Sua magia nasce quando você decide agir.\n\n'
          'O **Sol em Áries na Casa 1** acende a intenção.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: ReadingMarkdown(leitura)),
        ),
      );
      await tester.pumpAndSettle();

      final lilas = GrimoireColors.vinhoOrquidea.lilac;
      final cores = _decoracoes(tester).map((d) => d.color).toList();

      expect(cores, isNot(contains(_azulDoPacote)));
      final noLilas = cores.any(
        (c) => c != null && c.r == lilas.r && c.g == lilas.g && c.b == lilas.b,
      );
      expect(
        noLilas,
        isTrue,
        reason: 'o destaque deveria sair no cartão lilás',
      );
      expect(find.textContaining('Sua magia nasce'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('o ajuste da tela não apaga a cor herdada', (tester) async {
      // `copyWith` TROCA o estilo inteiro. Uma tela que passasse um
      // `TextStyle` novo deixaria o corpo sem cor — de volta ao padrão.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ReadingMarkdown(
              'Corpo da leitura.',
              refine: (base) => base.copyWith(
                p: base.p?.copyWith(fontSize: 15),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final corpo = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
      expect(corpo.styleSheet?.p?.fontSize, 15);
      expect(
        corpo.styleSheet?.p?.color,
        GrimoireColors.vinhoOrquidea.softWhite,
      );
    });
  });

  group('nenhuma tela monta a própria folha', () {
    final fonte = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.endsWith('core/widgets/reading_markdown.dart'));

    test('markdown de leitura passa sempre pelo ReadingMarkdown', () {
      final direto = <String>[];
      final doZero = <String>[];

      for (final arquivo in fonte) {
        final codigo = arquivo.readAsStringSync();
        if (RegExp(r'\bMarkdownBody\(').hasMatch(codigo)) {
          direto.add(arquivo.path);
        }
        // O construtor cru deixa TODO o resto nulo — foi assim que o
        // destaque caiu no azul. A partir do tema (`fromTheme`) ou da base,
        // não.
        if (RegExp(r'\bMarkdownStyleSheet\(').hasMatch(codigo)) {
          doZero.add(arquivo.path);
        }
      }

      expect(
        direto,
        isEmpty,
        reason: 'use ReadingMarkdown: o MarkdownBody direto herda o padrão '
            'claro do pacote no que a tela esquecer',
      );
      expect(
        doZero,
        isEmpty,
        reason: 'folha montada do zero: parta de readingMarkdownStyle(context) '
            'e ajuste com copyWith',
      );
    });
  });
}
