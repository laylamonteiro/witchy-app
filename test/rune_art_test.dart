import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/runes/data/data_sources/runes_data_en.dart';
import 'package:grimorio_de_bolso/features/runes/data/data_sources/runes_data_es.dart';
import 'package:grimorio_de_bolso/features/runes/data/data_sources/runes_data_pt.dart';
import 'package:grimorio_de_bolso/features/runes/data/models/rune_model.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/widgets/rune_art.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/widgets/rune_stone_view.dart';

import 'support/short_test_timeout.dart';

/// Comprimento total dos traços de um desenho, em unidades da caixa.
double _tinta(RuneArt art) {
  var total = 0.0;
  for (final stroke in art.strokes) {
    for (var i = 1; i < stroke.length; i++) {
      total += (stroke[i] - stroke[i - 1]).distance;
    }
  }
  return total;
}

/// A caixa que a tinta de um desenho ocupa, SEM contar a espessura.
Rect _caixa(RuneArt art) {
  final xs = [for (final s in art.strokes) for (final p in s) p.dx];
  final ys = [for (final s in art.strokes) for (final p in s) p.dy];
  return Rect.fromLTRB(xs.reduce(math.min), ys.reduce(math.min),
      xs.reduce(math.max), ys.reduce(math.max));
}

void main() {
  useShortTestTimeout();

  // O catálogo é a fonte, não uma lista escrita à mão: uma runa acrescentada
  // amanhã entra aqui sozinha e cobra o próprio desenho.
  group('as 24 do catálogo têm desenho', () {
    test('toda runa dos três idiomas resolve para um desenho', () {
      for (final lista in const <List<Rune>>[runesPt, runesEn, runesEs]) {
        expect(lista, hasLength(24));
        for (final rune in lista) {
          expect(runeArtFor(rune.name), isNotNull,
              reason: 'sem desenho para ${rune.name}');
        }
      }
    });

    test('os nomes desenhados são exatamente os do catálogo', () {
      // Nos dois sentidos: uma runa sem desenho cairia na reserva, e um
      // desenho órfão seria um nome escrito errado que ninguém usa.
      expect(runeArtNames.toSet(), runesPt.map((r) => r.name).toSet());
    });
  });

  group('as 24 formam uma mesa só', () {
    test('todas ocupam a mesma altura, de 0,08 a 0,92', () {
      for (final nome in runeArtNames) {
        final caixa = _caixa(runeArtFor(nome)!);
        expect(caixa.top, closeTo(0.08, 0.001), reason: nome);
        expect(caixa.bottom, closeTo(0.92, 0.001), reason: nome);
      }
    });

    test('todas ficam centradas na horizontal', () {
      for (final nome in runeArtNames) {
        final caixa = _caixa(runeArtFor(nome)!);
        expect(caixa.center.dx, closeTo(0.5, 0.011), reason: nome);
      }
    });

    test('nenhuma vaza da caixa, nem com a meia-espessura do traço', () {
      for (final nome in runeArtNames) {
        final art = runeArtFor(nome)!;
        // Numa caixa de 1 pixel de lado a espessura seria a nominal, sem o
        // piso de 1 pixel atrapalhar a conta: é a meia-espessura relativa.
        final meia = RuneArt.baseStroke * art.weight / 2;
        final caixa = _caixa(art);
        expect(caixa.left - meia, greaterThan(0), reason: nome);
        expect(caixa.right + meia, lessThan(1), reason: nome);
        expect(caixa.top - meia, greaterThan(0), reason: nome);
        expect(caixa.bottom + meia, lessThan(1), reason: nome);
      }
    });

    test('não há duas runas com o mesmo desenho', () {
      // A catraca contra o erro que ninguém revisa: copiar a vizinha de cima
      // para começar uma runa e esquecer de mexer nos pontos. O app passaria
      // a ENSINAR a forma errada, e nenhum dos outros testes veria — a cópia
      // tem altura certa, centro certo e peso certo, porque é uma runa
      // legítima, só que a errada. Pega também os pares que se parecem e não
      // são iguais: Eihwaz e Perthro, Ehwaz e Mannaz.
      final vistos = <String, String>{};
      for (final nome in runeArtNames) {
        final assinatura = runeArtFor(nome)!.strokes.toString();
        expect(vistos[assinatura], isNull,
            reason: '$nome tem o mesmo traçado de ${vistos[assinatura]}');
        vistos[assinatura] = nome;
      }
      expect(vistos, hasLength(24));
    });

    test('nenhum traço é horizontal', () {
      // A regra do entalhe, que o arquivo afirma e nada conferia: traço
      // paralelo ao veio da madeira some, e por isso nenhuma das vinte e
      // quatro tem uma horizontal — nem a travessa de Hagalaz, que é
      // inclinada de propósito.
      //
      // Mede-se o ÂNGULO, e não o desnível. A primeira versão desta catraca
      // cobrava `dy > 0,05` e não dizia nada sobre horizontalidade: um
      // segmento de dy 0,06 com dx 0,60 é uma barra chapada de 5,7° e
      // passava, enquanto um remate de dy 0,04 com dx 0,01 é praticamente
      // vertical e reprovava. O segmento mais deitado das vinte e quatro tem
      // 22,6° (os ganchos de Eihwaz), seguido de Perthro com 24,0° e Wunjo
      // com 24,2°: o piso de 15° deixa folga larga para autorar sem afrouxar
      // a regra a ponto de deixar passar a barra que ela existe para barrar.
      for (final nome in runeArtNames) {
        for (final stroke in runeArtFor(nome)!.strokes) {
          for (var i = 1; i < stroke.length; i++) {
            final dy = (stroke[i].dy - stroke[i - 1].dy).abs();
            final dx = (stroke[i].dx - stroke[i - 1].dx).abs();
            expect(math.atan2(dy, dx) * 180 / math.pi, greaterThan(15.0),
                reason: '$nome tem um segmento quase horizontal');
          }
        }
      }
    });

    test('a compensação de espessura fica na faixa documentada', () {
      final tintas = {
        for (final nome in runeArtNames) nome: _tinta(runeArtFor(nome)!)
      };
      final media = tintas.values.reduce((a, b) => a + b) / tintas.length;
      for (final entry in tintas.entries) {
        final art = runeArtFor(entry.key)!;
        // O peso autorado é `(média / tinta) ^ 0,30` preso em [0,86; 1,20].
        // Este teste é a prova de que ninguém desenhou uma runa e esqueceu
        // de refazer a conta: é exatamente isso que faria uma delas chegar
        // mais fina que as vizinhas na lista.
        final bruto = math.pow(media / entry.value, 0.30).toDouble();
        final esperado = bruto < 0.86 ? 0.86 : (bruto > 1.20 ? 1.20 : bruto);
        expect(art.weight, closeTo(esperado, 0.012), reason: entry.key);
      }
    });
  });

  group('a reserva honesta', () {
    test('um nome desconhecido não tem desenho', () {
      expect(runeArtFor('Cweorth'), isNull);
      expect(runeArtFor(''), isNull);
      // A chave é o NOME, não o caractere: passar o caractere não acha nada.
      expect(runeArtFor('ᚠ'), isNull);
    });

    testWidgets('sem desenho, o caractere do catálogo continua na tela',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: RuneMark(
            name: 'Cweorth',
            symbol: 'ᚻ',
            fontSize: 32,
            color: Colors.amber,
          ),
        ),
      ));
      expect(find.text('ᚻ'), findsOneWidget);
    });

    testWidgets('com desenho, o caractere não é escrito', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: RuneMark(
            name: 'Fehu',
            symbol: 'ᚠ',
            fontSize: 32,
            color: Colors.amber,
          ),
        ),
      ));
      expect(find.text('ᚠ'), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('a pedra', () {
    testWidgets('com o nome, a runa é desenhada na pedra', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RuneStoneView(
              size: 76,
              deckPosition: 0,
              symbol: 'ᚠ',
              runeName: 'Fehu',
            ),
          ),
        ),
      ));
      expect(find.byType(RuneStoneView), findsOneWidget);
      expect(find.text('ᚠ'), findsNothing);
      // O `symbol` segue ali: é por ele que os testes de fluxo distinguem a
      // pedra virada para cima da virada para baixo.
      expect(
          tester.widget<RuneStoneView>(find.byType(RuneStoneView)).symbol, 'ᚠ');
    });

    testWidgets('sem o nome, a pedra volta a escrever o caractere',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RuneStoneView(size: 76, deckPosition: 0, symbol: 'ᚠ'),
          ),
        ),
      ));
      expect(find.text('ᚠ'), findsOneWidget);
    });

    testWidgets('a pedra virada para baixo não mostra runa nenhuma',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(child: RuneStoneView(size: 76, deckPosition: 3)),
        ),
      ));
      expect(find.byType(RuneMark), findsNothing);
      expect(find.text('ᚠ'), findsNothing);
    });
  });
}
