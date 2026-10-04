// A Carta Diária do Oráculo é UMA por dia — e a pergunta não manda nisso.
//
// Ela abria com uma pergunta que a pessoa nunca tinha escrito ali: a sessão
// nascia semeada com o rascunho do dia, escrito em OUTRA ferramenta. E saía
// duas vezes no mesmo dia por dois caminhos — mudando a pergunta (o resume
// casava por ela) ou só apertando "Nova leitura" (que pulava o resume).
//
// Agora ela tem caixa de pergunta como as outras mesas, e é justamente por
// isso que estes casos existem: com caixa, a tentação de deixar a pergunta
// entrar na identidade volta a cada mudança. Aqui ela fica trancada do lado
// de fora.
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/core/divination/dia_da_pergunta_repository.dart';
import 'package:grimorio_de_bolso/core/services/usage_coordinator.dart';
import 'package:grimorio_de_bolso/features/divination/data/data_sources/oracle_cards_data.dart';
import 'package:grimorio_de_bolso/features/divination/data/models/oracle_card_model.dart';
import 'package:grimorio_de_bolso/features/divination/data/repositories/oracle_selection_repository.dart';
import 'package:grimorio_de_bolso/features/divination/domain/oracle_selection_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  const user = 'oracle-daily-user';
  final day = DateTime(2026, 10, 2, 9);
  late OracleSelectionRepository repo;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('carta_do_dia_oraculo');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    for (final t in [
      ...ReadingSessionSchema.tables,
      'oracle_readings',
      'tarot_readings',
    ]) {
      await db.delete(t);
    }
    repo = OracleSelectionRepository(random: Random(7));
  });

  Future<OracleSelectionSession> diaria({bool startNew = false}) =>
      repo.prepare(
          userId: user,
          spread: OracleSpreadType.daily,
          catalog: oracleCardsData,
          startNew: startNew,
          now: day);

  Future<int> sessoesDiarias() async {
    final db = await DatabaseHelper.instance.database;
    final linhas = await db.query('selection_sessions',
        where: 'user_id = ? AND tool = ? AND spread = ?',
        whereArgs: [user, OracleSelectionSession.tool, 'daily']);
    return linhas.length;
  }

  group('a pergunta não entra na identidade', () {
    test('a caixa nasce VAZIA, mesmo com pergunta escrita em outra mesa',
        () async {
      // Exatamente a queixa: escrever numa mesa paga e abrir a Carta Diária.
      final paga = await repo.prepare(
          userId: user,
          spread: OracleSpreadType.threeCard,
          catalog: oracleCardsData,
          now: day);
      await repo.atualizarPergunta(
          userId: user, sessionId: paga.id, pergunta: 'Mudo de cidade?');

      final doDia = await diaria();
      expect(doDia.question, isEmpty,
          reason: 'a Carta do Dia não herda o que foi escrito em outra mesa');
    });

    test('perguntas diferentes devolvem a MESMA sessão, a MESMA carta',
        () async {
      final primeira = await diaria();
      final baralho = primeira.deck;

      await repo.atualizarPergunta(
          userId: user, sessionId: primeira.id, pergunta: 'E o trabalho?');
      final depoisDeA = await diaria();

      await repo.atualizarPergunta(
          userId: user, sessionId: primeira.id, pergunta: 'E o amor?');
      final depoisDeB = await diaria();

      expect(depoisDeA.id, primeira.id);
      expect(depoisDeB.id, primeira.id, reason: 'digitar não abre sessão nova');
      expect(depoisDeB.deck, baralho, reason: 'digitar não re-sorteia o leque');
      expect(depoisDeB.question, 'E o amor?',
          reason: 'a pergunta é guardada — ela só não manda na identidade');
      expect(await sessoesDiarias(), 1);
    });

    test('"Nova leitura" não sorteia outra Carta Diária', () async {
      final primeira = await diaria();
      final depois = await diaria(startNew: true);
      expect(depois.id, primeira.id);
      expect(depois.deck, primeira.deck);
      expect(await sessoesDiarias(), 1,
          reason: 'era por aqui que saía a segunda do dia, sem pergunta mudar');
    });

    test('uma linha ilegível não deixa a pessoa o dia inteiro sem carta',
        () async {
      final db = await DatabaseHelper.instance.database;
      await diaria();
      // Deck truncado: `fromRow` recusa a linha.
      await db.update('selection_sessions', {'deck_json': '["so-uma"]'},
          where: 'user_id = ? AND tool = ? AND spread = ?',
          whereArgs: [user, OracleSelectionSession.tool, 'daily']);

      final nova = await diaria();
      expect(nova.deck.length, OracleSelectionSession.cardCount);
      expect(await sessoesDiarias(), 1, reason: 'a podre sai, a boa entra');
    });
  });

  test('a Carta Diária é de graça e NÃO paga a mesa cobrada', () async {
    // Se a diária ancorasse `daily_question`, `decidirTiragem` liberaria de
    // graça toda mesa que repetisse aquela pergunta — e o Free, que tem UMA
    // cota, ganharia a mesa paga de brinde.
    final doDia = await diaria();
    await repo.atualizarPergunta(
        userId: user, sessionId: doDia.id, pergunta: 'Z');
    var atual = await diaria();
    while (!atual.isComplete) {
      atual = (await repo.select(
        userId: user,
        sessionId: atual.id,
        cardId: atual.deck.firstWhere((c) => !atual.selectedIds.contains(c)),
        expectedCount: atual.selectedIds.length,
        catalog: oracleCardsData,
        positionLabels: List.generate(atual.cardsNeeded, (i) => 'P$i'),
        isCurrentUser: () => true,
        isPremium: () => false,
        freeLimit: 1,
        legacyOracleUsed: 0,
      ))
          .session;
    }

    final db = await DatabaseHelper.instance.database;
    final estado = await db.query('day_question_state',
        where: 'user_id = ? AND tool = ?',
        whereArgs: [user, DiaDaPerguntaRepository.oraculo]);
    for (final linha in estado) {
      expect(linha['daily_question'], isNull,
          reason: 'a diária não ancora a pergunta do dia');
      expect(linha['last_question'], isNull,
          reason: 'nem deixa rascunho para a caixa da mesa paga herdar');
    }
    expect(
        await UsageCoordinator()
            .oracleUsed(userId: user, legacyUsed: 0, day: day),
        0,
        reason: 'tirar a carta do dia não gasta cota');

    // E a mesa paga, com a MESMA pergunta, continua cobrando.
    final paga = await repo.prepare(
        userId: user,
        spread: OracleSpreadType.threeCard,
        catalog: oracleCardsData,
        now: day);
    await repo.atualizarPergunta(
        userId: user, sessionId: paga.id, pergunta: 'Z');
    var mesa = await repo.prepare(
        userId: user,
        spread: OracleSpreadType.threeCard,
        catalog: oracleCardsData,
        now: day);
    while (!mesa.isComplete) {
      mesa = (await repo.select(
        userId: user,
        sessionId: mesa.id,
        cardId: mesa.deck.firstWhere((c) => !mesa.selectedIds.contains(c)),
        expectedCount: mesa.selectedIds.length,
        catalog: oracleCardsData,
        positionLabels: List.generate(mesa.cardsNeeded, (i) => 'P$i'),
        isCurrentUser: () => true,
        isPremium: () => false,
        freeLimit: 1,
        legacyOracleUsed: 0,
      ))
          .session;
    }
    expect(
        await UsageCoordinator()
            .oracleUsed(userId: user, legacyUsed: 0, day: day),
        1,
        reason: 'a diária não pode ter pago a mesa de três cartas');
  });
}
