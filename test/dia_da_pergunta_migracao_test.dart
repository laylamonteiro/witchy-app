// A pergunta do dia deixou de ser só do tarô. A migração v30 tem de levar o
// que `tarot_day_state` já sabia para a tabela nova SEM apagar a velha: a casa
// só migra para a frente.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/divination/dia_da_pergunta_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('a v30 copia a pergunta do dia do tarô e deixa a tabela velha de pé',
      () async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('dia_da_pergunta_v30');
    await databaseFactory.setDatabasesPath(dir.path);

    // Um aparelho na v29, com duas contas e dois dias guardados.
    final antigo = await openDatabase(
      '${dir.path}/grimorio_de_bolso.db',
      version: 29,
      onCreate: (db, _) async {
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
        await db.insert('tarot_day_state', {
          'user_id': 'bruxa',
          'day_key': '2026-9-15',
          'daily_question': 'vou viajar?',
          'last_question': 'Vou viajar?',
        });
        // Um rascunho sem âncora: a pessoa digitou e não confirmou.
        await db.insert('tarot_day_state', {
          'user_id': 'bruxa',
          'day_key': '2026-9-14',
          'daily_question': null,
          'last_question': 'Mudo de casa?',
        });
        // Outra conta, para provar que a cópia não mistura as duas.
        await db.insert('tarot_day_state', {
          'user_id': 'outra',
          'day_key': '2026-9-15',
          'daily_question': 'e o trabalho?',
          'last_question': 'E o trabalho?',
        });
      },
    );
    await antigo.close();

    final db = await DatabaseHelper.instance.database;
    expect(await db.getVersion(), 30);

    final copiadas = await db.query('day_question_state',
        orderBy: 'user_id ASC, day_key ASC');
    expect(copiadas.length, 3);
    expect(copiadas.every((l) => l['tool'] == DiaDaPerguntaRepository.tarot),
        isTrue,
        reason: 'tudo o que existia era do tarô');

    final deHoje = copiadas.firstWhere(
        (l) => l['user_id'] == 'bruxa' && l['day_key'] == '2026-9-15');
    expect(deHoje['daily_question'], 'vou viajar?',
        reason: 'a âncora da cota vem normalizada, como estava');
    expect(deHoje['last_question'], 'Vou viajar?',
        reason: 'o rascunho conserva a grafia original — é ele que repõe o '
            'texto no campo');

    final rascunho = copiadas.firstWhere((l) => l['day_key'] == '2026-9-14');
    expect(rascunho['daily_question'], isNull);
    expect(rascunho['last_question'], 'Mudo de casa?');

    // A tabela velha continua onde estava, intacta.
    expect((await db.query('tarot_day_state')).length, 3);
  });

  test('a tabela nova separa as ferramentas', () async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('dia_da_pergunta_tools');
    await databaseFactory.setDatabasesPath(dir.path);
    final db = await DatabaseHelper.instance.database;
    const dia = '2026-9-15';

    final repo = DiaDaPerguntaRepository();
    final quando = DateTime(2026, 9, 15);
    await repo.remember(
        userId: 'bruxa',
        day: quando,
        tool: DiaDaPerguntaRepository.tarot,
        question: 'Vou viajar?',
        ancorar: true);
    await repo.remember(
        userId: 'bruxa',
        day: quando,
        tool: DiaDaPerguntaRepository.runas,
        question: 'Mudo de casa?');

    final tarot = await repo.read('bruxa', quando,
        tool: DiaDaPerguntaRepository.tarot);
    final runas = await repo.read('bruxa', quando,
        tool: DiaDaPerguntaRepository.runas);
    final oraculo = await repo.read('bruxa', quando,
        tool: DiaDaPerguntaRepository.oraculo);

    expect(tarot.perguntaDoDia, 'vou viajar?');
    expect(tarot.ultimaPergunta, 'Vou viajar?');
    // Escrever no tarô não ancora nem preenche as runas: a cota é de cada uma.
    expect(runas.perguntaDoDia, isNull,
        reason: 'só uma tiragem cobrada ancora a pergunta do dia');
    expect(runas.ultimaPergunta, 'Mudo de casa?');
    expect(oraculo.perguntaDoDia, isNull);
    expect(oraculo.ultimaPergunta, isNull);

    expect(
        (await db.query('day_question_state',
                where: 'user_id = ? AND day_key = ?',
                whereArgs: ['bruxa', dia]))
            .length,
        3,
        reason: 'uma linha por ferramenta tocada');
  });
}
