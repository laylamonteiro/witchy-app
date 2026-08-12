import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/diary/data/services/reading_archive_composer.dart';
import 'package:grimorio_de_bolso/features/divination/data/models/oracle_card_model.dart';
import 'package:grimorio_de_bolso/features/divination/data/models/pendulum_model.dart';
import 'package:grimorio_de_bolso/features/runes/data/models/rune_model.dart';
import 'package:grimorio_de_bolso/features/runes/data/models/rune_spread_model.dart';
import 'package:grimorio_de_bolso/features/tarot/data/models/tarot_card_model.dart';

/// O compositor transforma leituras em páginas de texto do acervo, no
/// formato `✦ rótulo` que o renderizador dos registros destaca.
void main() {
  setUpAll(() => ContentLocale.instance.setLocale(const Locale('pt', 'BR')));

  RuneReading buildRuneReading({String question = 'Devo seguir?'}) {
    const fehu = Rune(
      name: 'Fehu',
      symbol: 'ᚠ',
      keywords: ['riqueza'],
      description: 'Prosperidade que circula.',
    );
    return RuneReading(
      id: 'r1',
      question: question,
      spreadType: RuneSpreadType.single,
      positions: const [
        RunePosition(
          position: 0,
          rune: fehu,
          isReversed: true,
          positionMeaning: 'Presente',
        ),
      ],
      date: DateTime(2026, 1, 1),
    );
  }

  test('runas: pergunta + posições com símbolo, nome e inversão', () {
    final page = ReadingArchiveComposer.runes(buildRuneReading());
    expect(page.title, startsWith('Leitura de Runas — '));
    final lines = page.content.split('\n');
    expect(lines[0], '✦ Pergunta');
    expect(lines[1], 'Devo seguir?');
    expect(lines[2], '');
    expect(lines[3], '✦ Presente — ᚠ Fehu (invertida)');
    expect(lines[4], 'Prosperidade que circula.');
  });

  test('runas: bloco de pergunta some quando não há pergunta', () {
    final noQuestion =
        ReadingArchiveComposer.runes(buildRuneReading(question: ''));
    expect(noQuestion.content, isNot(contains('✦ Pergunta')));
    expect(noQuestion.content, startsWith('✦ Presente'));

    final sentinel = ReadingArchiveComposer.runes(
        buildRuneReading(question: 'Sem pergunta'));
    expect(sentinel.content, isNot(contains('✦ Pergunta')),
        reason: 'o texto-sentinela runesNoQuestion não é uma pergunta');
  });

  test('pêndulo: pergunta e resposta com emoji, nome e mensagem', () {
    final page = ReadingArchiveComposer.pendulum(PendulumConsultation(
      id: 'p1',
      question: 'Vai dar certo?',
      answer: PendulumAnswer.yes,
      date: DateTime(2026, 1, 1),
    ));
    expect(page.title, 'Pêndulo');
    expect(page.content, contains('✦ Sua Pergunta\nVai dar certo?'));
    expect(page.content, contains('✦ Resposta\n'));
    expect(page.content, contains(PendulumAnswer.yes.displayName));
    expect(page.content, contains(PendulumAnswer.yes.message));
  });

  test('tarot: pergunta, cartas com posição/inversão e interpretação', () {
    const card = TarotCard(
      suit: TarotSuit.major,
      number: 17,
      name: 'A Estrela',
      keywords: ['esperança'],
      upright: 'Renovação e fé.',
      reversed: 'Desânimo passageiro.',
    );
    final page = ReadingArchiveComposer.tarot(
      spreadName: 'Carta do Dia',
      question: 'O que preciso ver?',
      drawn: const [
        TarotDrawnCard(
          card: card,
          isReversed: true,
          positionLabel: 'Carta do Dia',
        ),
      ],
      interpretation: 'Confie no processo.',
    );
    expect(page.title, 'Tarot — Carta do Dia');
    expect(page.content, contains('✦ Pergunta\nO que preciso ver?'));
    expect(page.content,
        contains('✦ Carta do Dia — A Estrela (invertida)\nDesânimo passageiro.'));
    expect(page.content, contains('Confie no processo.'));

    final noExtras = ReadingArchiveComposer.tarot(
      spreadName: 'Carta do Dia',
      question: '',
      drawn: const [
        TarotDrawnCard(
          card: card,
          isReversed: false,
          positionLabel: 'Carta do Dia',
        ),
      ],
    );
    expect(noExtras.content, isNot(contains('✦ Pergunta')));
    expect(noExtras.content, contains('Renovação e fé.'));
  });

  test('oráculo: uma seção por carta com mensagem e orientação', () {
    const card = OracleCard(
      id: 1,
      name: 'A Estrela',
      message: 'Confie no caminho.',
      emoji: '⭐',
      guidance: 'Acenda uma vela branca.',
      keywords: ['esperança'],
    );
    final page = ReadingArchiveComposer.oracle(OracleReading(
      id: 'o1',
      spreadType: OracleSpreadType.threeCard,
      positions: const [
        OracleCardPosition(
          position: 0,
          card: card,
          positionMeaning: 'Passado',
        ),
      ],
      date: DateTime(2026, 1, 1),
    ));
    expect(page.title, startsWith('Cartas do Oráculo — '));
    expect(page.content,
        '✦ Passado — ⭐ A Estrela\nConfie no caminho.\nAcenda uma vela branca.');
  });
}
