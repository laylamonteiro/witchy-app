import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/usage_coordinator.dart';
import '../../domain/daily_tarot_session.dart';
import '../models/tarot_card_model.dart';
import '../../../../core/divination/dia_da_pergunta_repository.dart';
import 'tarot_reading_repository.dart';

/// A Carta do Dia: UMA por pessoa por dia, e a mesma o dia inteiro.
///
/// Ela não tem pergunta. É a carta DO DIA — a energia que acompanha o dia de
/// quem a tirou —, não a resposta de alguma coisa. Antes ela era indexada pela
/// pergunta, e o efeito era o contrário do nome: uma pergunta diferente no
/// mesmo dia gerava outra "carta do dia", cobrando do Free e sem limite nenhum
/// no Premium. Quem tirasse três vezes tinha três cartas do dia, o que é o
/// mesmo que não ter nenhuma.
///
/// Por não ter pergunta, ela também não consome cota — de ninguém. O que a
/// assinatura vende é perguntar OUTRA coisa no mesmo dia, e isso continua
/// valendo para as tiragens de três cartas e da cruz.
///
/// Escolher continua sendo da pessoa: o baralho é embaralhado e gravado antes
/// de o leque aparecer, e a animação nunca sorteia, grava nem consome.
class DailyTarotRepository {
  DailyTarotRepository({DatabaseHelper? dbHelper, Random? random})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _random = random ?? Random();

  final DatabaseHelper _dbHelper;
  final Random _random;
  static const deckVersion = DailyTarotSession.deckVersion;

  Future<DailyTarotSession> prepare({
    required String userId,
    required List<TarotCard> catalog,
    DateTime? now,
  }) async {
    if (catalog.length != 78 || catalog.map((c) => c.id).toSet().length != 78) {
      throw const FormatException('Expected the complete tarot catalog');
    }
    final instant = now ?? DateTime.now();
    final key = UsageCoordinator.dayKey(instant);
    final start = DateTime(instant.year, instant.month, instant.day);
    final end = DateTime(instant.year, instant.month, instant.day + 1);
    final seed = await DiaDaPerguntaRepository.legacySeed(userId, instant,
        tool: DiaDaPerguntaRepository.tarot);
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      // A memória do dia continua sendo semeada aqui: a Carta do Dia é, para
      // muita gente, a primeira coisa que se abre no dia, e é ela que cria a
      // linha em que as tiragens seguintes vão ancorar a pergunta.
      await DiaDaPerguntaRepository.ensureIn(txn,
          userId: userId,
          dayKey: key,
          tool: DiaDaPerguntaRepository.tarot,
          seed: seed);

      // UMA por pessoa por dia: a pergunta não entra na identidade.
      final existing = await txn.query('selection_sessions',
          where: 'user_id = ? AND tool = ? AND spread = ? AND day_key = ?',
          whereArgs: [userId, 'tarot', 'daily', key],
          orderBy: 'created_at ASC, rowid ASC',
          limit: 1);
      if (existing.isNotEmpty) return DailyTarotSession.fromRow(existing.single);

      // Adota uma carta do dia já tirada antes de oferecer uma escolha nova —
      // a PRIMEIRA do dia, que é a que a pessoa chamou de "a minha de hoje".
      // O limite de cima impede casar com o registro de outro dia.
      final oldDraws = await txn.query('tarot_readings',
          where: 'user_id = ? AND spread_type = ? AND date >= ? AND date < ?',
          whereArgs: [userId, 'daily', start.millisecondsSinceEpoch,
            end.millisecondsSinceEpoch],
          orderBy: 'date ASC, id ASC', limit: 1);
      final legacy = oldDraws.isEmpty ? null : oldDraws.single;

      final cards = [...catalog]..shuffle(_random);
      final deck = [for (final card in cards)
        HiddenTarotCard(id: card.id, reversed: _random.nextInt(4) == 0)];
      String? selectedId;
      String? legacySignature;
      if (legacy != null) {
        final payload = jsonDecode(legacy['reading_data'] as String)
            as Map<String, dynamic>;
        final recorded = payload['cards'] as List;
        if (recorded.length != 1) {
          throw const FormatException('Invalid existing daily reading');
        }
        final saved = recorded.single as Map<String, dynamic>;
        final card = catalog.firstWhere((c) =>
            (c.suit.name == saved['suit'] && c.number == saved['number']) ||
            (saved['suit'] == null && c.name == saved['name']));
        selectedId = card.id;
        final index = deck.indexWhere((c) => c.id == selectedId);
        deck[index] = HiddenTarotCard(
            id: card.id, reversed: saved['reversed'] == true);
        legacySignature = legacy['signature'] as String?;
        if (legacySignature == null) {
          legacySignature = 'daily-legacy:${legacy['id']}';
          await txn.update('tarot_readings', {'signature': legacySignature},
              where: 'id = ? AND user_id = ?',
              whereArgs: [legacy['id'], userId]);
        }
      }

      final row = <String, Object?>{
        'id': const Uuid().v4(),
        'user_id': userId,
        'tool': 'tarot',
        'spread': 'daily',
        'day_key': key,
        'day_start': start.millisecondsSinceEpoch,
        'day_end': end.millisecondsSinceEpoch,
        // Sem pergunta: é a carta DO DIA, não a resposta de nada.
        'question': '',
        'normalized_question': '',
        'deck_version': deckVersion,
        'deck_json': jsonEncode(deck.map((c) => c.toJson()).toList()),
        'selected_json': jsonEncode([if (selectedId != null) selectedId]),
        'result_id': legacy?['id'],
        'result_signature': legacySignature,
        'created_at': instant.millisecondsSinceEpoch,
        'updated_at': instant.millisecondsSinceEpoch,
      };
      await txn.insert('selection_sessions', row);
      return DailyTarotSession.fromRow(row);
    });
  }

  Future<DailyTarotCommit> selectAndCommit({
    required String userId,
    required String sessionId,
    required String cardId,
    required List<TarotCard> catalog,
    required String positionLabel,
    required bool Function() isCurrentUser,
  }) async {
    final db = await _dbHelper.database;
    // Persist the choice first: a result-write failure must not allow a
    // different card on retry, even after the process is restarted.
    await db.transaction((txn) async {
      _checkAccount(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (session.isCommitted || session.selectedId != null) return;
      session.card(cardId); // Validate membership; never redraw here.
      _checkAccount(isCurrentUser);
      await txn.update('selection_sessions',
          {'selected_json': jsonEncode([cardId]),
            'updated_at': DateTime.now().millisecondsSinceEpoch},
          where: 'id = ? AND user_id = ?', whereArgs: [sessionId, userId]);
    });

    return db.transaction((txn) async {
      _checkAccount(isCurrentUser);
      final session = await _read(txn, userId, sessionId);
      if (session.isCommitted) return DailyTarotCommit(session, created: false);
      final selected = session.card(session.selectedId!);
      final card = catalog.firstWhere((c) => c.id == selected.id);
      _checkAccount(isCurrentUser);
      // Sem cota: a Carta do Dia é uma só por dia e não tem pergunta, então
      // não há o que cobrar nem de quem. O que a assinatura vende é perguntar
      // outra coisa no mesmo dia, e isso é assunto das outras tiragens.
      final signature = 'daily-session:${session.id}';
      final resultId = await TarotReadingRepository(dbHelper: _dbHelper)
          .recordDraw(
        userId: userId,
        spreadName: 'daily',
        signature: signature,
        drawn: [TarotDrawnCard(card: card, isReversed: selected.reversed,
            positionLabel: positionLabel)],
        question: session.question,
        executor: txn,
        sessionId: session.id,
        date: session.dayStart,
      );
      _checkAccount(isCurrentUser);
      await txn.update('selection_sessions', {
        'result_id': resultId,
        'result_signature': signature,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ? AND user_id = ?', whereArgs: [session.id, userId]);
      return DailyTarotCommit(await _read(txn, userId, sessionId), created: true);
    });
  }

  Future<String?> interpretation(DailyTarotSession session) async {
    if (!session.isCommitted) return null;
    final db = await _dbHelper.database;
    final rows = await db.query('tarot_readings', columns: ['reading_data'],
        where: 'id = ? AND user_id = ?',
        whereArgs: [session.resultId, session.userId], limit: 1);
    if (rows.isEmpty) return null;
    final data = jsonDecode(rows.single['reading_data'] as String) as Map;
    return data['interpretation'] as String?;
  }

  static Future<DailyTarotSession> _read(
      DatabaseExecutor db, String userId, String id) async {
    final rows = await db.query('selection_sessions',
        where: 'id = ? AND user_id = ? AND tool = ? AND spread = ?',
        whereArgs: [id, userId, 'tarot', 'daily'], limit: 1);
    if (rows.isEmpty) throw const TarotAccountChanged();
    return DailyTarotSession.fromRow(rows.single);
  }

  static void _checkAccount(bool Function() isCurrentUser) {
    if (!isCurrentUser()) throw const TarotAccountChanged();
  }

}
