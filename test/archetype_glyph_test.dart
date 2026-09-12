import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/arcane_categories.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetype_identity.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/demons_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/models/arcane_entry_model.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/widgets/arcane_glyph.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/widgets/archetype_glyph.dart';
import 'support/short_test_timeout.dart';

/// A catraca da diagramação dos onze arquétipos desenhados.
///
/// "Bem diagramado" aqui é conta, e não gosto: caixa única, peso óptico
/// igual, centro óptico no meio e nada saindo da caixa. Tudo isso se mede
/// sem olhos, a partir dos próprios caminhos — e é o que este arquivo faz.
///
/// A medida de tudo é a TINTA: os caminhos amostrados a passo constante de
/// comprimento de arco, cada amostra valendo o mesmo pedaço de traço. Massa
/// de um traço = comprimento × espessura × opacidade; de um ponto cheio =
/// área × opacidade. As duas são área de tinta, então somam.
void main() {
  useShortTestTimeout();

  const box = ArchetypeGlyphArt.box;
  const margin = ArchetypeGlyphArt.margin;
  const centre = Offset(box / 2, box / 2);

  /// Pontos ao longo do caminho, espaçados por comprimento de arco: cada um
  /// representa o mesmo pedaço de traço, então a média deles é o centro de
  /// massa da linha.
  List<Offset> samples(Path path) {
    const step = 0.05;
    final points = <Offset>[];
    for (final metric in path.computeMetrics()) {
      final steps = (metric.length / step).round().clamp(1, 20000);
      for (var i = 0; i < steps; i++) {
        final at = metric.getTangentForOffset(metric.length * (i + .5) / steps);
        if (at != null) points.add(at.position);
      }
    }
    return points;
  }

  double inkLength(Path path) {
    var total = 0.0;
    for (final metric in path.computeMetrics()) {
      total += metric.length;
    }
    return total;
  }

  /// (massa, centro de massa, retângulo da tinta, comprimento de traço).
  ({double mass, Offset centre, Rect bounds, double length}) measure(
      ArchetypeGlyphArt art) {
    var mass = 0.0;
    var mx = 0.0;
    var my = 0.0;
    var length = 0.0;
    var left = double.infinity;
    var top = double.infinity;
    var right = -double.infinity;
    var bottom = -double.infinity;

    for (final stroke in art.strokes) {
      final width = ArchetypeGlyphArt.baseStroke * stroke.weight;
      final points = samples(stroke.path);
      expect(points, isNotEmpty, reason: 'traço sem comprimento');
      final len = inkLength(stroke.path);
      length += len;
      final share = len * width * stroke.alpha / points.length;
      for (final p in points) {
        mass += share;
        mx += share * p.dx;
        my += share * p.dy;
        // A tinta de um traço vai meia espessura para cada lado da linha.
        left = math.min(left, p.dx - width / 2);
        right = math.max(right, p.dx + width / 2);
        top = math.min(top, p.dy - width / 2);
        bottom = math.max(bottom, p.dy + width / 2);
      }
    }
    for (final dot in art.dots) {
      final m = math.pi * dot.radius * dot.radius * dot.alpha;
      mass += m;
      mx += m * dot.center.dx;
      my += m * dot.center.dy;
      left = math.min(left, dot.center.dx - dot.radius);
      right = math.max(right, dot.center.dx + dot.radius);
      top = math.min(top, dot.center.dy - dot.radius);
      bottom = math.max(bottom, dot.center.dy + dot.radius);
    }
    return (
      mass: mass,
      centre: Offset(mx / mass, my / mass),
      bounds: Rect.fromLTRB(left, top, right, bottom),
      length: length,
    );
  }

  final eleven = [for (final id in archetypeIds) archetypeGlyphArt(id)!];

  group('os onze têm desenho', () {
    test('nenhum id do catálogo cai no caminho sem desenho', () {
      expect(archetypeIds, hasLength(11));
      for (final id in archetypeIds) {
        expect(archetypeGlyphArt(id), isNotNull,
            reason: '$id não tem desenho e cairia de volta no emoji');
      }
    });

    test('o registro de desenhos é exatamente o catálogo, sem sobra', () {
      expect(archetypeGlyphIds.toSet(), archetypeIds.toSet());
    });

    test('o emoji continua no catálogo — é ele que dá o id gravado', () {
      // O desenho ACRESCENTA; o dado não muda. Se o emoji sumisse do
      // catálogo, `archetypeIdForEmoji` deixaria de achar o arquétipo e o
      // resultado gravado de quem já fez o teste viraria ausência.
      for (var i = 0; i < archetypesPt.length; i++) {
        expect(archetypesPt[i].emoji, isNotEmpty);
        expect(archetypeIdForEmoji(archetypesPt[i].emoji), archetypeIds[i]);
      }
    });
  });

  group('a caixa é a mesma para os onze', () {
    test('nenhuma tinta invade a margem da caixa', () {
      const limit = Rect.fromLTRB(margin, margin, box - margin, box - margin);
      for (var i = 0; i < archetypeIds.length; i++) {
        final ink = measure(eleven[i]).bounds;
        expect(limit.contains(ink.topLeft), isTrue,
            reason: '${archetypeIds[i]} sai da caixa em cima/à esquerda: $ink');
        expect(limit.contains(ink.bottomRight), isTrue,
            reason: '${archetypeIds[i]} sai da caixa embaixo/à direita: $ink');
      }
    });

    test('trocar de arquétipo não muda o tamanho aparente', () {
      // O maior lado da tinta de cada um, na mesma faixa: é isso que faz o
      // card da lista não pular de tamanho ao rolar de um para o outro.
      for (var i = 0; i < archetypeIds.length; i++) {
        final ink = measure(eleven[i]).bounds;
        final side = math.max(ink.width, ink.height);
        expect(side, inInclusiveRange(13, 18),
            reason: '${archetypeIds[i]} tem lado $side, fora da faixa dos '
                'outros dez');
      }
    });

    test('nem ocupa metade da caixa que os outros ocupam', () {
      // O maior lado sozinho NÃO vê o defeito que existia aqui, e é por isso
      // que este teste existe ao lado do de cima: o olho da Vidente media
      // 15,6 de lado — no meio da faixa dos outros dez — e ocupava 126 de
      // área contra 227 de média, porque tinha 8 de altura. Na lista ele lia
      // como um desenho menor que o vizinho, que é exatamente o que a caixa
      // única existe para não deixar acontecer.
      //
      // O lado comparável de uma área é a raiz quadrada dela: o lado do
      // quadrado que ocuparia o mesmo espaço. É ele que responde por "mesmo
      // tamanho aparente" quando um desenho é deitado e o outro é em pé.
      final sides = <double>[];
      for (final art in eleven) {
        final ink = measure(art).bounds;
        sides.add(math.sqrt(ink.width * ink.height));
      }
      final mean = sides.reduce((a, b) => a + b) / sides.length;
      for (var i = 0; i < sides.length; i++) {
        expect(sides[i] / mean, inInclusiveRange(0.85, 1.15),
            reason: '${archetypeIds[i]} ocupa um quadrado de ${sides[i]} '
                'contra uma média de $mean — ele lê maior ou menor que os '
                'outros dez, mesmo com a caixa e o maior lado iguais');
      }
    });
  });

  group('o peso óptico é igual', () {
    test('as onze massas de tinta ficam na mesma faixa', () {
      final masses = [for (final art in eleven) measure(art).mass];
      final mean = masses.reduce((a, b) => a + b) / masses.length;
      for (var i = 0; i < masses.length; i++) {
        expect(masses[i] / mean, inInclusiveRange(0.7, 1.3),
            reason: '${archetypeIds[i]} pesa ${masses[i]} contra uma média '
                'de $mean — compense na espessura ou na opacidade');
      }
    });

    test('a compensação está na espessura, não na contagem de linhas', () {
      // A prova de que a conta acima não é vazia: a teia e a flor têm quase o
      // DOBRO de traço do escudo, e mesmo assim pesam o mesmo — porque o
      // traço delas é mais fino. Sem a compensação, a lista teria dois
      // desenhos pretos no meio de nove cinzas.
      final web = measure(archetypeGlyphArt('a_tecela')!);
      final shield = measure(archetypeGlyphArt('a_guardia')!);
      expect(web.length, greaterThan(shield.length * 1.5),
          reason: 'a teia deixou de ser o desenho denso que motiva a conta');
      expect(web.mass / shield.mass, inInclusiveRange(0.7, 1.3));
    });
  });

  test('o centro é o óptico, e a silhueta não deriva do meio', () {
    for (var i = 0; i < archetypeIds.length; i++) {
      final m = measure(eleven[i]);
      expect((m.centre - centre).distance, lessThan(1.5),
          reason: '${archetypeIds[i]} tem o centro de massa em ${m.centre}, '
              'longe do meio da caixa');
      // Centrar pela massa e centrar pela silhueta puxam para lados
      // diferentes quando o desenho é assimétrico (o arco e flecha é o
      // caso): centra-se pela massa, mas a silhueta não pode encostar de um
      // lado só.
      expect((m.bounds.center - centre).distance, lessThan(1.8),
          reason: '${archetypeIds[i]} ficou encostado num lado da caixa');
    }
  });

  group('a mesma arte serve ao grande e ao pequeno', () {
    test('a espessura é proporcional ao tamanho, com piso de 1 pixel', () {
      // O prêmio do teste tem 56 de corpo e a linha de lista tem 14: um
      // traço fixo que funcionasse num sumiria no outro.
      final big = ArchetypeGlyphArt.strokeWidthFor(1, 56);
      final small = ArchetypeGlyphArt.strokeWidthFor(1, 28);
      expect(big / small, closeTo(2, 0.0001));
      // Abaixo de ~19 de caixa o traço proporcional ficaria abaixo de um
      // pixel lógico e sumiria em tela de baixa densidade. O piso comprime a
      // compensação de peso nos tamanhos miúdos, e é troca deliberada:
      // melhor o desenho denso pesar um pouco mais do que o fino sumir.
      expect(ArchetypeGlyphArt.strokeWidthFor(1, 6), 1);
      expect(ArchetypeGlyphArt.strokeWidthFor(.78, 12), 1);
    });

    test('no miúdo nenhum traço fica mais apagado que a tinta mínima', () {
      // O piso acima segura a ESPESSURA, e o que aparece na tela é espessura
      // × opacidade. Sem um piso na tinta, o traço mais apagado do conjunto
      // (a coroa da lua nova, a 55%) chegava à linha de lista como 1 pixel a
      // 55% — contra 1,49 do escudo na linha de cima. E a coroa é a única
      // coisa que separa aquela lua de um círculo qualquer.
      final small = ArchetypeGlyphArt.boxForEmojiSize(14);
      for (var i = 0; i < archetypeIds.length; i++) {
        for (final stroke in eleven[i].strokes) {
          final width = ArchetypeGlyphArt.strokeWidthFor(stroke.weight, small);
          final alpha =
              ArchetypeGlyphArt.alphaFor(stroke.weight, stroke.alpha, small);
          expect(alpha, lessThanOrEqualTo(1.0));
          expect(width * alpha,
              greaterThanOrEqualTo(ArchetypeGlyphArt.minInk - 1e-9),
              reason: '${archetypeIds[i]} tem um traço que some na linha de '
                  'lista: $width pixel a $alpha de opacidade');
        }
      }
      // E no tamanho grande a opacidade autorada passa INTACTA: a hierarquia
      // entre o traço cheio e o apagado é o que dá profundidade ao desenho, e
      // ela só é devolvida onde a espessura não dá conta sozinha.
      final crown = archetypeGlyphArt('a_rainha_sombria')!.strokes.last;
      expect(
        ArchetypeGlyphArt.alphaFor(
            crown.weight, crown.alpha, ArchetypeGlyphArt.boxForEmojiSize(56)),
        crown.alpha,
      );
    });

    test('a caixa do desenho dá a ele o porte do emoji que substituiu', () {
      // O emoji preenche quase todo o corpo da fonte; o desenho ocupa dois
      // terços da caixa. Sem esta conversão, trocar um pelo outro encolheria
      // a arte em um terço em todas as telas de uma vez.
      final side = ArchetypeGlyphArt.boxForEmojiSize(56);
      expect(side, greaterThan(56));
      final ink = measure(archetypeGlyphArt('a_bruxa')!).bounds;
      expect(math.max(ink.width, ink.height) * side / box, closeTo(56, 6));
    });
  });

  test('nenhuma cor fixa entrou no desenho', () {
    // As SEIS paletas, uma delas clara: quem escolhe a cor é o tema, pelo
    // acento (`gc.lilac`), que cada paleta define com contraste conferido
    // contra o próprio fundo. Um `Color(0x...)` aqui seria uma cor que
    // funciona numa paleta e some noutra.
    final source = File('lib/features/encyclopedia/presentation/widgets/'
            'archetype_glyph.dart')
        .readAsStringSync();
    expect(source.contains('context.gc.lilac'), isTrue);
    expect(source.contains('Color(0x'), isFalse,
        reason: 'uma cor fixa entrou no desenho dos arquétipos');
    expect(source.contains('Colors.'), isFalse,
        reason: 'uma cor da paleta do Material entrou no desenho');
  });

  group('a costura com o emoji das outras categorias', () {
    test('só os arquétipos têm desenho', () {
      for (final entry in ArcaneCategory.archetypes.entries) {
        expect(ArcaneCategory.archetypes.glyphIdFor(entry), isNotNull);
      }
      for (final category in [
        ArcaneCategory.angels,
        ArcaneCategory.demons,
        ArcaneCategory.sacredSymbols,
      ]) {
        for (final entry in category.entries) {
          expect(category.glyphIdFor(entry), isNull,
              reason: '${entry.name} (${category.name}) passou a ser '
                  'desenhado como arquétipo');
        }
      }
    });

    testWidgets('o demônio que usa o mesmo emoji continua com o emoji dele',
        (tester) async {
      // Stolas usa 🦉, o mesmo símbolo da Sábia, e Buer usa 🌿, o mesmo da
      // Curandeira. Quem decidisse pelo emoji poria a coruja desenhada nos
      // dois demônios — é por isso que a categoria decide primeiro.
      final owl = demonsPt.firstWhere((e) => e.name == 'Stolas');
      expect(owl.emoji, archetypesPt[4].emoji,
          reason: 'a colisão de emoji que motiva a costura sumiu');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ArcaneGlyph(
            category: ArcaneCategory.demons,
            entry: owl,
            size: 32,
          ),
        ),
      ));

      expect(find.byType(ArchetypeGlyph), findsNothing);
      expect(find.text(owl.emoji), findsOneWidget);
    });

    testWidgets('o verbete de arquétipo mostra o desenho, e mudo',
        (tester) async {
      final witch = archetypesPt.first;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ArcaneGlyph(
            category: ArcaneCategory.archetypes,
            entry: witch,
            size: 40,
          ),
        ),
      ));

      expect(find.text(witch.emoji), findsNothing);
      final glyph = tester.widget<ArchetypeGlyph>(find.byType(ArchetypeGlyph));
      expect(glyph.id, archetypeIds.first);
      expect(glyph.size, 40);
      // O desenho não fala: quem fala é o nome escrito ao lado dele em todas
      // as telas em que ele aparece.
      expect(find.byType(ExcludeSemantics), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('um verbete sem desenho e sem categoria desenhada não quebra',
        (tester) async {
      const stranger = ArcaneEntry(
        name: 'Fora do catálogo',
        emoji: '✦',
        summary: '',
        origin: '',
        history: '',
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ArcaneGlyph(
            category: ArcaneCategory.archetypes,
            entry: stranger,
            size: 24,
          ),
        ),
      ));
      expect(find.text('✦'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
