import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/core/services/usage_coordinator.dart';
import 'package:grimorio_de_bolso/features/tarot/data/data_sources/tarot_cards_data.dart';
import 'package:grimorio_de_bolso/features/tarot/data/models/tarot_card_model.dart';
import 'package:grimorio_de_bolso/features/tarot/data/repositories/daily_tarot_repository.dart';
import 'package:grimorio_de_bolso/core/divination/dia_da_pergunta_repository.dart';
import 'package:grimorio_de_bolso/features/tarot/data/repositories/tarot_reading_repository.dart';
import 'package:grimorio_de_bolso/features/tarot/domain/daily_tarot_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  const user = 'daily-tarot-user';
  final day = DateTime(2026, 9, 9, 23, 59);
  late DailyTarotRepository repo;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('daily_tarot');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.execute('DROP TRIGGER IF EXISTS fail_daily_draw');
    for (final table in [...ReadingSessionSchema.tables, 'tarot_readings']) {
      await db.delete(table);
    }
    repo = DailyTarotRepository(random: Random(42));
  });

  /// A Carta do Dia não recebe pergunta nem plano: é UMA por dia e não cobra.
  Future<DailyTarotSession> prepare({
      bool premium = false, int legacyUsed = 0, String owner = user,
      DateTime? at}) async {
    if (legacyUsed > 0) {
      // O espelho do AuthProvider semeia o dia — o que antes o `prepare` fazia.
      await UsageCoordinator()
          .oracleUsed(userId: owner, legacyUsed: legacyUsed, day: at ?? day);
    }
    return repo.prepare(
        userId: owner, catalog: tarotCards, now: at ?? day);
  }

  Future<DailyTarotCommit> commit(DailyTarotSession session, {
    String? cardId, bool premium = false, bool active = true, String owner = user,
  }) => repo.selectAndCommit(userId: owner, sessionId: session.id,
      cardId: cardId ?? session.deck.last.id, catalog: tarotCards,
      positionLabel: 'Daily card', isCurrentUser: () => active);

  Future<int> used({DateTime? at, String owner = user, int legacy = 0}) =>
      UsageCoordinator().oracleUsed(userId: owner, legacyUsed: legacy, day: at ?? day);

  test('opening and abandoning retains all 78 IDs and orientations without use', () async {
    final first = await prepare();
    expect(first.deck.length, 78);
    expect(first.deck.map((c) => c.id).toSet().length, 78);
    expect(first.selectedId, isNull);
    expect(await used(legacy: 0), 0);
    // O leque é o MESMO ao reabrir, com outro sorteador: a identidade das
    // cartas é fixada antes de o leque aparecer, e nada aqui sorteia de novo.
    repo = DailyTarotRepository(random: Random(987));
    final resumed = await prepare();
    expect(resumed.id, first.id);
    expect(resumed.deck.map((c) => c.toJson()), first.deck.map((c) => c.toJson()));
    expect(resumed.question, isEmpty);
  });

  test('the exact selected card is recorded; duplicate commits record once', () async {
    final session = await prepare();
    final chosen = session.deck.last;
    final results = await Future.wait([
      commit(session, cardId: chosen.id),
      commit(session, cardId: chosen.id),
    ]);
    expect(results.where((r) => r.created).length, 1);
    expect(results.map((r) => r.session.resultId).toSet().length, 1);
    expect(await used(legacy: 0), 0, reason: 'a carta do dia não cobra');
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('tarot_readings');
    expect(rows, hasLength(1));
    final data = jsonDecode(rows.single['reading_data'] as String) as Map;
    final card = (data['cards'] as List).single as Map;
    final expected = tarotCards.firstWhere((c) => c.id == chosen.id);
    expect(card['suit'], expected.suit.name);
    expect(card['number'], expected.number);
    expect(card['reversed'], chosen.reversed);
    final retry = await commit(session, cardId: session.deck.first.id);
    expect(retry.created, isFalse);
    expect(retry.session.selectedId, chosen.id);
    expect((await prepare(premium: true)).selectedId, chosen.id);
  });

  test('failed result write rolls back usage and retains the choice for restart', () async {
    final session = await prepare();
    final db = await DatabaseHelper.instance.database;
    await db.execute('''
      CREATE TRIGGER fail_daily_draw BEFORE INSERT ON tarot_readings
      BEGIN SELECT RAISE(ABORT, 'simulated interrupted write'); END
    ''');
    await expectLater(commit(session), throwsA(isA<DatabaseException>()));
    expect(await used(legacy: 0), 0);
    expect(await db.query('tarot_readings'), isEmpty);
    repo = DailyTarotRepository(random: Random(99));
    final resumed = await prepare();
    expect(resumed.selectedId, session.deck.last.id);
    await db.execute('DROP TRIGGER fail_daily_draw');
    final retry = await commit(resumed, cardId: session.deck.first.id);
    expect(retry.session.selectedId, session.deck.last.id);
    expect(await used(legacy: 0), 0);
  });

  test('a carta do dia é a mesma o dia todo, sem pergunta e sem cobrar',
      () async {
    final primeira = await prepare();
    expect(primeira.question, isEmpty,
        reason: 'é a carta DO DIA, não a resposta de alguma coisa');
    final feita = await commit(primeira);
    expect(feita.created, isTrue);

    // Abrir de novo, quantas vezes for, devolve a MESMA carta — nada de
    // sortear outra até vir uma que agrade.
    for (var i = 0; i < 3; i++) {
      final denovo = await prepare();
      expect(denovo.id, primeira.id);
      expect(denovo.selectedId, feita.session.selectedId);
      expect(denovo.isCommitted, isTrue);
    }
    final db = await DatabaseHelper.instance.database;
    expect(await db.query('tarot_readings'), hasLength(1));
    expect(await used(legacy: 0), 0);
  });

  test('a cota do dia não alcança a carta do dia', () async {
    // A cota do Free já toda gasta, e por outra ferramenta ainda.
    await UsageCoordinator()
        .oracleUsed(userId: user, legacyUsed: 1, day: day);
    await UsageCoordinator().recordOracleUse(userId: user, legacyUsed: 0,
        day: day, operationId: 'oracle-other');
    expect(await used(legacy: 0), 2);

    // A carta do dia sai assim mesmo: ela não tem pergunta, então não há o
    // que cobrar. O que a assinatura vende é perguntar OUTRA coisa no mesmo
    // dia, e isso é assunto das outras tiragens.
    final session = await prepare();
    final feita = await commit(session);
    expect(feita.session.isCommitted, isTrue);
    expect(await used(legacy: 0), 2, reason: 'nada foi debitado');
  });

  test('crossing midnight keeps the session day and leaves the next day quota', () async {
    final session = await prepare();
    final result = await commit(session);
    expect(result.session.dayKey, '2026-9-9');
    expect(await used(legacy: 0), 0);
    final next = DateTime(2026, 9, 10);
    expect(await used(at: next), 0);
    final tomorrow = await prepare(at: next);
    expect(tomorrow.id, isNot(session.id));
    expect(tomorrow.selectedId, isNull);
  });

  test('account switch and foreign session IDs never commit to another account', () async {
    final session = await prepare();
    await expectLater(commit(session, active: false), throwsA(isA<TarotAccountChanged>()));
    await expectLater(commit(session, owner: 'other'), throwsA(isA<TarotAccountChanged>()));
    expect(await used(legacy: 0), 0);
    expect((await prepare()).selectedId, isNull);
    final other = await prepare(owner: 'other');
    expect(other.id, isNot(session.id));
  });

  test('an existing daily reading is adopted, including orientation and interpretation', () async {
    final existing = TarotReadingRepository();
    final card = tarotCards[7];
    final id = await existing.recordDraw(userId: user, spreadName: 'daily',
        signature: 'legacy-reading', question: 'My question?', date: day,
        drawn: [TarotDrawnCard(card: card, isReversed: true, positionLabel: 'Daily')]);
    await existing.attachInterpretation(userId: user, signature: 'legacy-reading',
        interpretation: 'Saved interpretation');
    final session = await prepare(legacyUsed: 1);
    expect(session.resultId, id);
    expect(session.resultSignature, 'legacy-reading');
    expect(session.selectedId, card.id);
    expect(session.card(card.id).reversed, isTrue);
    expect(await repo.interpretation(session), 'Saved interpretation');
    expect(await used(legacy: 0), 1, reason: 'o contador legado, não a carta');
  });

  test('future readings cannot replace the current day and invalid IDs cannot select', () async {
    await TarotReadingRepository().recordDraw(userId: user, spreadName: 'daily',
        signature: 'future', question: 'My question?', date: DateTime(2026, 9, 10),
        drawn: [TarotDrawnCard(card: tarotCards[0], isReversed: false, positionLabel: 'Daily')]);
    final session = await prepare();
    expect(session.isCommitted, isFalse);
    await expectLater(commit(session, cardId: 'not-a-card'), throwsStateError);
    expect((await prepare()).selectedId, isNull);
    expect(await used(legacy: 0), 0);
  });

  test('a memória antiga da pergunta do dia atravessa a mudança', () async {
    // A carta do dia não ancora mais nada — mas a pergunta que já estava
    // guardada nas preferências continua valendo para as OUTRAS tiragens.
    SharedPreferences.setMockInitialValues({
      'tarot_daily_q_$user': '2026-9-9|my question?',
      'tarot_last_q_$user': '2026-9-9|My question?',
    });
    final session = await prepare(legacyUsed: 1);
    await commit(session);
    expect(await used(legacy: 0), 1, reason: 'o contador legado, não a carta');
    final estado = await DiaDaPerguntaRepository()
        .read(user, day, tool: DiaDaPerguntaRepository.tarot);
    expect(estado.perguntaDoDia, 'my question?');
    expect(estado.ultimaPergunta, 'My question?');
  });
}
