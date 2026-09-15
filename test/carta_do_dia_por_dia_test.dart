// A Carta do Dia voltou a ser UMA por dia: a pergunta saiu da identidade dela.
//
// A migração que faz isso tem três passos e a ORDEM importa — desempatar,
// derrubar o índice velho, criar o novo. Invertida, o `CREATE UNIQUE INDEX`
// estoura em "UNIQUE constraint failed" e leva junto a migração inteira, o que
// significa o app não abrir. É esse desastre que este arquivo tranca.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// O schema da v29, só o que esta migração toca.
Future<Database> bancoNaV29(String caminho) => openDatabase(
      caminho,
      version: 29,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE selection_sessions (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            tool TEXT NOT NULL,
            spread TEXT NOT NULL,
            day_key TEXT NOT NULL,
            day_start INTEGER NOT NULL,
            day_end INTEGER NOT NULL,
            question TEXT NOT NULL,
            normalized_question TEXT NOT NULL,
            deck_version TEXT NOT NULL,
            deck_json TEXT NOT NULL,
            selected_json TEXT NOT NULL,
            result_id TEXT,
            result_signature TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE UNIQUE INDEX idx_daily_selection_identity
          ON selection_sessions(user_id, tool, spread, day_key, normalized_question)
          WHERE tool = 'tarot' AND spread = 'daily'
        ''');
        await db.execute('''
          CREATE TABLE tarot_day_state (
            user_id TEXT NOT NULL,
            day_key TEXT NOT NULL,
            daily_question TEXT,
            last_question TEXT,
            synced INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY(user_id, day_key)
          )
        ''');
        await db.execute(
            'CREATE TABLE tarot_readings (id TEXT PRIMARY KEY, reading_data TEXT)');
      },
    );

Map<String, Object?> sessao({
  required String id,
  required String dia,
  required String pergunta,
  String usuario = 'bruxa',
  String spread = 'daily',
  int criadaEm = 1,
  String? resultado,
}) =>
    {
      'id': id,
      'user_id': usuario,
      'tool': 'tarot',
      'spread': spread,
      'day_key': dia,
      'day_start': 0,
      'day_end': 1,
      'question': pergunta,
      'normalized_question': pergunta.trim().toLowerCase(),
      'deck_version': 'rider-waite-78-v1',
      'deck_json': '[]',
      'selected_json': '[]',
      'result_id': resultado,
      'created_at': criadaEm,
      'updated_at': criadaEm,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('duas cartas do dia no mesmo dia não derrubam a migração', () async {
    final dir = await Directory.systemTemp.createTemp('carta_do_dia_v30');
    await databaseFactory.setDatabasesPath(dir.path);
    final antigo = await bancoNaV29('${dir.path}/grimorio_de_bolso.db');
    // O caso que o índice novo proibiria: a pessoa perguntou duas coisas no
    // mesmo dia e recebeu duas "cartas do dia".
    await antigo.insert('selection_sessions',
        sessao(id: 'primeira', dia: '2026-9-15', pergunta: 'Vou viajar?',
            criadaEm: 100, resultado: 'leitura-1'));
    await antigo.insert('selection_sessions',
        sessao(id: 'segunda', dia: '2026-9-15', pergunta: 'Mudo de casa?',
            criadaEm: 200, resultado: 'leitura-2'));
    // Três, para provar que não é um caso de dois.
    await antigo.insert('selection_sessions',
        sessao(id: 'terceira', dia: '2026-9-15', pergunta: 'E o trabalho?',
            criadaEm: 300, resultado: 'leitura-3'));
    // Outro dia e outra conta continuam de pé, cada um com a sua.
    await antigo.insert('selection_sessions',
        sessao(id: 'ontem', dia: '2026-9-14', pergunta: 'Vou viajar?',
            criadaEm: 50, resultado: 'leitura-0'));
    await antigo.insert('selection_sessions',
        sessao(id: 'outra-conta', dia: '2026-9-15', pergunta: 'Sei lá?',
            usuario: 'outra', criadaEm: 100, resultado: 'leitura-4'));
    // E uma tiragem de três cartas, que a migração não pode tocar.
    await antigo.insert('selection_sessions',
        sessao(id: 'tres-cartas', dia: '2026-9-15', pergunta: 'Vou viajar?',
            spread: 'threeCards', criadaEm: 400, resultado: 'leitura-5'));
    await antigo.close();

    // Se a ordem dos passos estivesse errada, a migração estouraria aqui — e
    // com ela a abertura do app.
    final db = await DatabaseHelper.instance.database;
    expect(await db.getVersion(), 30);

    final doDia = await db.query('selection_sessions',
        where: "tool = 'tarot' AND spread = 'daily'", orderBy: 'id ASC');
    expect(doDia.map((l) => l['id']).toList(),
        ['ontem', 'outra-conta', 'primeira'],
        reason: 'de cada (conta, dia) sobra a PRIMEIRA — a que a pessoa '
            'chamou de "a minha de hoje"');
    expect(doDia.every((l) => l['question'] == ''), isTrue,
        reason: 'a carta do dia não tem mais pergunta');
    expect(doDia.every((l) => l['normalized_question'] == ''), isTrue);

    // A tiragem de três cartas passou intacta, com a pergunta dela.
    final tres = await db.query('selection_sessions',
        where: "spread = 'threeCards'");
    expect(tres.single['question'], 'Vou viajar?');

    // O índice novo existe, sem a pergunta na chave.
    final indice = (await db.rawQuery(
            "SELECT sql FROM sqlite_master WHERE name = "
            "'idx_daily_selection_identity'"))
        .single['sql'] as String;
    expect(indice, contains('day_key'));
    expect(indice, isNot(contains('normalized_question')));
  });

  // Os testes abaixo correm no MESMO banco: `DatabaseHelper.instance` guarda a
  // conexão aberta, então trocar o diretório não reabre nada. Por isso cada um
  // usa a sua própria conta.
  test('o índice novo proíbe uma segunda carta do dia no mesmo dia', () async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('selection_sessions',
        sessao(id: 'u-a', dia: '2026-9-20', pergunta: '', usuario: 'unica'));
    await expectLater(
        db.insert('selection_sessions',
            sessao(id: 'u-b', dia: '2026-9-20', pergunta: '', usuario: 'unica')),
        throwsA(isA<DatabaseException>()),
        reason: 'uma por pessoa por dia, e o banco é quem garante');
    // Em outro dia, e para outra conta, continua podendo.
    await db.insert('selection_sessions',
        sessao(id: 'u-c', dia: '2026-9-21', pergunta: '', usuario: 'unica'));
    await db.insert('selection_sessions',
        sessao(id: 'u-d', dia: '2026-9-20', pergunta: '', usuario: 'vizinha'));
    expect(
        await db.query('selection_sessions',
            where: "user_id IN ('unica', 'vizinha')"),
        hasLength(3));
  });

  test('a mesma pergunta em dias diferentes continua valendo', () async {
    final db = await DatabaseHelper.instance.database;
    for (final dia in ['2026-9-23', '2026-9-24', '2026-9-25']) {
      await db.insert('selection_sessions',
          sessao(id: 'd-$dia', dia: dia, pergunta: '', usuario: 'seguida'));
    }
    expect(
        await db.query('selection_sessions', where: "user_id = 'seguida'"),
        hasLength(3));
  });
}
