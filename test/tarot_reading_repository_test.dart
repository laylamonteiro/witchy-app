import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/tarot/data/data_sources/tarot_cards_data.dart';
import 'package:grimorio_de_bolso/features/tarot/data/models/tarot_card_model.dart';
import 'package:grimorio_de_bolso/features/tarot/data/repositories/tarot_reading_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A cota do Tarô é por pergunta: uma mesa já feita hoje com a pergunta do
/// dia é REVISITADA, não sorteada de novo. Quem entrega as cartas de volta é
/// o registro da tiragem, pelo naipe + número.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const uid = 'bruxa';
  final repo = TarotReadingRepository();

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('grimorio_tarot_repo');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.delete('tarot_readings');
  });

  List<TarotDrawnCard> mesa() => [
        TarotDrawnCard(
          card: tarotCards[3],
          isReversed: true,
          positionLabel: 'Passado',
        ),
        TarotDrawnCard(
          card: tarotCards[40],
          isReversed: false,
          positionLabel: 'Presente',
        ),
        TarotDrawnCard(
          card: tarotCards[61],
          isReversed: false,
          positionLabel: 'Futuro',
        ),
      ];

  test('registra e devolve a mesa de hoje pela pergunta, sem maiúsculas',
      () async {
    await repo.recordDraw(
      userId: uid,
      spreadName: 'threeCards',
      signature: 'sig-1',
      drawn: mesa(),
      question: 'Vou Viajar?',
    );

    final cartas = await repo.drawOfToday(
      userId: uid,
      spreadName: 'threeCards',
      question: '  vou viajar?  ',
    );
    expect(cartas, isNotNull);
    expect(cartas!.length, 3);
    expect(cartas.first['suit'], tarotCards[3].suit.name);
    expect(cartas.first['number'], tarotCards[3].number);
    expect(cartas.first['name'], tarotCards[3].name);
    expect(cartas.first['reversed'], isTrue);
    expect(cartas[1]['reversed'], isFalse);
  });

  test('outra pergunta, outra tiragem ou outra pessoa: nada', () async {
    await repo.recordDraw(
      userId: uid,
      spreadName: 'threeCards',
      signature: 'sig-2',
      drawn: mesa(),
      question: 'Vou viajar?',
    );
    expect(
      await repo.drawOfToday(
        userId: uid,
        spreadName: 'threeCards',
        question: 'Devo aceitar?',
      ),
      isNull,
    );
    expect(
      await repo.drawOfToday(
        userId: uid,
        spreadName: 'cross',
        question: 'Vou viajar?',
      ),
      isNull,
    );
    expect(
      await repo.drawOfToday(
        userId: 'outra',
        spreadName: 'threeCards',
        question: 'Vou viajar?',
      ),
      isNull,
    );
  });

  test('a mesa de ontem não conta', () async {
    final db = await DatabaseHelper.instance.database;
    final ontem = DateTime.now()
        .subtract(const Duration(days: 1))
        .millisecondsSinceEpoch;
    await db.insert('tarot_readings', {
      'id': 'antiga',
      'user_id': uid,
      'question': 'Vou viajar?',
      'spread_type': 'threeCards',
      'signature': 'sig-ontem',
      'reading_data': jsonEncode({
        'spread': 'threeCards',
        'cards': [
          {'name': 'x', 'suit': 'major', 'number': 0, 'reversed': false},
        ],
      }),
      'date': ontem,
      'created_at': ontem,
      'updated_at': ontem,
      'synced': 0,
    });

    expect(
      await repo.drawOfToday(
        userId: uid,
        spreadName: 'threeCards',
        question: 'Vou viajar?',
      ),
      isNull,
    );
  });
}
