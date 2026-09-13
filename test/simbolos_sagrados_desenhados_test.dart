// A catraca da diagramação dos três Símbolos Sagrados desenhados.
//
// POR QUE ELES SÃO DESENHO. O Pentagrama (⛤ U+26E4), o Ankh (☥ U+2625) e o
// Olho de Hórus (𓂀 U+13080) não são emoji: são caracteres de blocos raros do
// Unicode. Nenhum sistema móvel traz fonte de hieróglifo egípcio, e o ⛤ o
// próprio app já registrava como quebrado quando trocou o emblema dos Sigilos
// por desenho (tool_emblem_art.dart). Onde o aparelho não tem a fonte, o que
// aparecia era o quadradinho de glifo ausente — no título da tela do verbete,
// na pílula de origem, no card da lista e na busca global.
//
// POR QUE UM ARQUIVO À PARTE, e não mais três casos no teste dos onze: a
// catraca dos arquétipos compara cada um com a MÉDIA dos onze e ainda exige
// que o registro de desenhos seja exatamente o catálogo de arquétipos, sem
// sobra. Os três não entram lá — cada conjunto se equilibra consigo mesmo. O
// que os dois compartilham é a LINGUAGEM (mesma caixa de 24, mesma margem,
// mesmo traço) e a conta que a mede, que é a mesma daqui.
//
// A medida de tudo é a TINTA: os caminhos amostrados a passo constante de
// comprimento de arco, cada amostra valendo o mesmo pedaço de traço. Massa de
// um traço = comprimento × espessura × opacidade; de um ponto cheio = área ×
// opacidade. As duas são área de tinta, então somam.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/arcane_categories.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/sacred_symbols_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/sacred_symbols_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/sacred_symbols_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/widgets/archetype_glyph.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();

  const box = ArchetypeGlyphArt.box;
  const margin = ArchetypeGlyphArt.margin;
  const centre = Offset(box / 2, box / 2);

  /// Os três, na ordem em que aparecem no catálogo.
  const ids = ['pentagrama', 'ankh', 'olho_de_horus'];

  /// O caractere de cada um — a chave que liga o verbete ao desenho.
  const caracteres = {
    'pentagrama': '⛤',
    'ankh': '☥',
    'olho_de_horus': '𓂀',
  };

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

  final tres = [for (final id in ids) sacredSymbolGlyphArt(id)!];

  group('os três caracteres que não são emoji viraram desenho', () {
    test('cada um dos três tem desenho', () {
      for (final id in ids) {
        expect(sacredSymbolGlyphArt(id), isNotNull,
            reason: '$id não tem desenho e cairia de volta no caractere cru');
      }
    });

    test('o registro é exatamente os três, sem sobra', () {
      expect(sacredSymbolGlyphIds.toSet(), ids.toSet());
    });

    test('o resolvedor acha os dois conjuntos, e não os mistura', () {
      // Quem pinta pergunta a um só: `glifoDesenhado`. Os ids dos dois
      // conjuntos são disjuntos de propósito — se um se repetisse, um
      // arquétipo passaria a mostrar o desenho de um símbolo.
      for (final id in ids) {
        expect(glifoDesenhado(id), same(sacredSymbolGlyphArt(id)));
        expect(archetypeGlyphArt(id), isNull,
            reason: '$id existe nos DOIS registros: um deles vai ser ignorado');
      }
      for (final id in archetypeGlyphIds) {
        expect(sacredSymbolGlyphArt(id), isNull,
            reason: '$id existe nos DOIS registros');
      }
    });

    test('o caractere continua no catálogo — é ele a chave do desenho', () {
      // O desenho ACRESCENTA; o dado não muda. Sem o caractere no catálogo,
      // `sacredSymbolIdForEmoji` não acharia o símbolo e o verbete voltaria a
      // não ter emblema nenhum.
      for (final entry in caracteres.entries) {
        expect(sacredSymbolIdForEmoji(entry.value), entry.key);
      }
      final doCatalogo = sacredSymbolsPt.map((e) => e.emoji).toSet();
      for (final caractere in caracteres.values) {
        expect(doCatalogo, contains(caractere),
            reason: '$caractere saiu do catálogo e o desenho ficou órfão');
      }
    });

    test('os oito símbolos restantes continuam no emoji deles', () {
      // Só os três caracteres de bloco raro ganharam desenho. Desenhar os
      // outros oito seria trabalho sem defeito para consertar — o emoji
      // deles existe no piso do app.
      final comDesenho = sacredSymbolsPt
          .where((e) => sacredSymbolIdForEmoji(e.emoji) != null)
          .length;
      expect(comDesenho, 3);
    });

    test('o caractere é o mesmo nos três idiomas — é o que faz a chave valer',
        () {
      expect(sacredSymbolsEn, hasLength(sacredSymbolsPt.length));
      expect(sacredSymbolsEs, hasLength(sacredSymbolsPt.length));
      for (var i = 0; i < sacredSymbolsPt.length; i++) {
        expect(sacredSymbolsEn[i].emoji, sacredSymbolsPt[i].emoji);
        expect(sacredSymbolsEs[i].emoji, sacredSymbolsPt[i].emoji);
      }
    });

    test('a costura da categoria leva o verbete ao desenho', () {
      // É por `glyphIdFor` que as quatro superfícies (título do verbete,
      // pílula de origem, card da lista e busca global) decidem entre desenho
      // e caractere. Uma só resposta, quatro lugares.
      for (final entry in sacredSymbolsPt) {
        final id = ArcaneCategory.sacredSymbols.glyphIdFor(entry);
        if (caracteres.values.contains(entry.emoji)) {
          expect(id, isNotNull,
              reason: '${entry.name} usa um caractere de bloco raro e ficou '
                  'sem desenho');
          expect(glifoDesenhado(id!), isNotNull);
        } else {
          expect(id, isNull, reason: '${entry.name} não tem desenho');
        }
      }
    });
  });

  group('a caixa é a mesma para os três', () {
    test('nenhuma tinta invade a margem da caixa', () {
      const limit = Rect.fromLTRB(margin, margin, box - margin, box - margin);
      for (var i = 0; i < ids.length; i++) {
        final ink = measure(tres[i]).bounds;
        expect(limit.contains(ink.topLeft), isTrue,
            reason: '${ids[i]} sai da caixa em cima/à esquerda: $ink');
        expect(limit.contains(ink.bottomRight), isTrue,
            reason: '${ids[i]} sai da caixa embaixo/à direita: $ink');
      }
    });

    test('trocar de símbolo não muda o tamanho aparente', () {
      for (var i = 0; i < ids.length; i++) {
        final ink = measure(tres[i]).bounds;
        final side = math.max(ink.width, ink.height);
        expect(side, inInclusiveRange(13, 18),
            reason: '${ids[i]} tem lado $side, fora da faixa dos outros dois');
      }
    });

    test('nem ocupa metade da caixa que os outros ocupam', () {
      // O maior lado sozinho MENTE para desenho deitado — foi o defeito que o
      // olho da Vidente teve entre os onze. O lado comparável de uma área é a
      // raiz quadrada dela.
      final sides = <double>[];
      for (final art in tres) {
        final ink = measure(art).bounds;
        sides.add(math.sqrt(ink.width * ink.height));
      }
      final mean = sides.reduce((a, b) => a + b) / sides.length;
      for (var i = 0; i < sides.length; i++) {
        expect(sides[i] / mean, inInclusiveRange(0.85, 1.15),
            reason: '${ids[i]} ocupa um quadrado de ${sides[i]} contra uma '
                'média de $mean — ele lê maior ou menor que os outros dois');
      }
    });
  });

  group('o peso óptico é igual', () {
    test('as três massas de tinta ficam na mesma faixa', () {
      final masses = [for (final art in tres) measure(art).mass];
      final mean = masses.reduce((a, b) => a + b) / masses.length;
      for (var i = 0; i < masses.length; i++) {
        expect(masses[i] / mean, inInclusiveRange(0.7, 1.3),
            reason: '${ids[i]} pesa ${masses[i]} contra uma média de $mean — '
                'compense na espessura ou na opacidade');
      }
    });

    test('a compensação está na espessura, não na contagem de linhas', () {
      // A prova de que a conta acima não é vazia: o pentagrama tem quase o
      // DOBRO de traço do ankh, e mesmo assim pesa o mesmo — porque o traço
      // dele é mais fino. Sem a compensação, a lista teria uma estrela preta
      // ao lado de um ankh cinza.
      final estrela = measure(sacredSymbolGlyphArt('pentagrama')!);
      final ankh = measure(sacredSymbolGlyphArt('ankh')!);
      expect(estrela.length, greaterThan(ankh.length * 1.5),
          reason: 'o pentagrama deixou de ser o desenho denso que motiva a '
              'compensação');
      expect(estrela.mass / ankh.mass, inInclusiveRange(0.7, 1.3));
    });

    test('pesam como os onze arquétipos, que dividem a lista com eles', () {
      // Na busca global um símbolo sagrado aparece na linha de cima e um
      // arquétipo na de baixo. Se os dois conjuntos se equilibrassem só por
      // dentro, nada impediria o trio inteiro de ser mais leve (ou mais
      // pesado) que os onze — e a busca leria como duas famílias de desenho.
      final sagrados = [for (final art in tres) measure(art).mass];
      final arquetipos = [
        for (final id in archetypeGlyphIds) measure(archetypeGlyphArt(id)!).mass
      ];
      final mediaSagrados =
          sagrados.reduce((a, b) => a + b) / sagrados.length;
      final mediaArquetipos =
          arquetipos.reduce((a, b) => a + b) / arquetipos.length;
      expect(mediaSagrados / mediaArquetipos, inInclusiveRange(0.8, 1.2),
          reason: 'os três pesam $mediaSagrados contra $mediaArquetipos dos '
              'onze — na busca global eles dividem a mesma lista');
    });
  });

  test('o centro é o óptico, e a silhueta não deriva do meio', () {
    for (var i = 0; i < ids.length; i++) {
      final m = measure(tres[i]);
      expect((m.centre - centre).distance, lessThan(1.5),
          reason: '${ids[i]} tem o centro de massa em ${m.centre}, longe do '
              'meio da caixa');
      expect((m.bounds.center - centre).distance, lessThan(1.8),
          reason: '${ids[i]} ficou encostado num lado da caixa');
    }
  });
}
