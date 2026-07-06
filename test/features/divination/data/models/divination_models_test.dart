import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/divination/data/models/oracle_card_model.dart';
import 'package:grimorio_de_bolso/features/divination/data/models/pendulum_model.dart';

void main() {
  group('OracleCard', () {
    test('JSON round-trip', () {
      const card = OracleCard(
        id: 1,
        name: 'The Moon',
        message: 'Trust your intuition',
        emoji: '\u{1F319}',
        guidance: 'Follow your inner voice',
        keywords: ['intuition', 'mystery', 'dreams'],
      );

      final json = card.toJson();
      final restored = OracleCard.fromJson(json);

      expect(restored.id, card.id);
      expect(restored.name, card.name);
      expect(restored.message, card.message);
      expect(restored.emoji, card.emoji);
      expect(restored.guidance, card.guidance);
      expect(restored.keywords, card.keywords);
    });
  });

  group('OracleSpreadType', () {
    test('all types have displayName', () {
      for (final type in OracleSpreadType.values) {
        expect(type.displayName, isNotEmpty);
      }
    });

    test('all types have description', () {
      for (final type in OracleSpreadType.values) {
        expect(type.description, isNotEmpty);
      }
    });

    test('cardCount values', () {
      expect(OracleSpreadType.daily.cardCount, 1);
      expect(OracleSpreadType.threeCard.cardCount, 3);
      expect(OracleSpreadType.weeklyGuidance.cardCount, 5);
    });

    test('getPositionMeaning for daily', () {
      expect(OracleSpreadType.daily.getPositionMeaning(0),
          'Mensagem do Dia');
    });

    test('getPositionMeaning for threeCard', () {
      expect(OracleSpreadType.threeCard.getPositionMeaning(0), 'Passado');
      expect(OracleSpreadType.threeCard.getPositionMeaning(1), 'Presente');
      expect(OracleSpreadType.threeCard.getPositionMeaning(2), 'Futuro');
    });

    test('getPositionMeaning for weeklyGuidance has 5 positions', () {
      for (int i = 0; i < 5; i++) {
        expect(
          OracleSpreadType.weeklyGuidance.getPositionMeaning(i),
          isNotEmpty,
        );
      }
    });
  });

  group('OracleCardPosition', () {
    test('JSON round-trip', () {
      const pos = OracleCardPosition(
        position: 0,
        card: OracleCard(
          id: 1,
          name: 'Test',
          message: 'Msg',
          emoji: '\u{2728}',
          guidance: 'Guide',
          keywords: ['a'],
        ),
        positionMeaning: 'Presente',
      );

      final json = pos.toJson();
      final restored = OracleCardPosition.fromJson(json);

      expect(restored.position, 0);
      expect(restored.card.name, 'Test');
      expect(restored.positionMeaning, 'Presente');
    });
  });

  group('OracleReading', () {
    test('JSON and string round-trip', () {
      final reading = OracleReading(
        id: 'oracle-1',
        spreadType: OracleSpreadType.threeCard,
        positions: const [
          OracleCardPosition(
            position: 0,
            card: OracleCard(
              id: 1,
              name: 'Card1',
              message: 'M1',
              emoji: '\u{2728}',
              guidance: 'G1',
              keywords: ['k1'],
            ),
            positionMeaning: 'Passado',
          ),
          OracleCardPosition(
            position: 1,
            card: OracleCard(
              id: 2,
              name: 'Card2',
              message: 'M2',
              emoji: '\u{1F319}',
              guidance: 'G2',
              keywords: ['k2'],
            ),
            positionMeaning: 'Presente',
          ),
          OracleCardPosition(
            position: 2,
            card: OracleCard(
              id: 3,
              name: 'Card3',
              message: 'M3',
              emoji: '\u{2B50}',
              guidance: 'G3',
              keywords: ['k3'],
            ),
            positionMeaning: 'Futuro',
          ),
        ],
        date: DateTime(2024, 6, 15),
      );

      final jsonStr = reading.toJsonString();
      final restored = OracleReading.fromJsonString(jsonStr);

      expect(restored.id, 'oracle-1');
      expect(restored.spreadType, OracleSpreadType.threeCard);
      expect(restored.positions.length, 3);
      expect(restored.positions[0].card.name, 'Card1');
      expect(restored.positions[2].positionMeaning, 'Futuro');
    });
  });

  group('PendulumAnswer', () {
    test('all answers have displayName', () {
      for (final answer in PendulumAnswer.values) {
        expect(answer.displayName, isNotEmpty);
      }
    });

    test('all answers have message', () {
      for (final answer in PendulumAnswer.values) {
        expect(answer.message, isNotEmpty);
      }
    });

    test('all answers have emoji', () {
      for (final answer in PendulumAnswer.values) {
        expect(answer.emoji, isNotEmpty);
      }
    });

    test('specific displayNames', () {
      expect(PendulumAnswer.yes.displayName, 'SIM');
      expect(PendulumAnswer.no.displayName, 'N\u00C3O');
      expect(PendulumAnswer.maybe.displayName, 'TALVEZ');
    });
  });

  group('PendulumConsultation', () {
    test('JSON round-trip', () {
      final consultation = PendulumConsultation(
        id: 'pend-1',
        question: 'Should I proceed?',
        answer: PendulumAnswer.yes,
        date: DateTime(2024, 6, 15),
      );

      final json = consultation.toJson();
      final restored = PendulumConsultation.fromJson(json);

      expect(restored.id, 'pend-1');
      expect(restored.question, 'Should I proceed?');
      expect(restored.answer, PendulumAnswer.yes);
      expect(restored.date, DateTime(2024, 6, 15));
    });
  });
}
