import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/records_archive_migration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A migração dos registros do Grimório Vivo (spells 'registro_*') para o
/// acervo free_writings: conteúdo preservado, id estável, idempotência.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uuidA = '11111111-2222-3333-4444-555555555555';
  const uuidB = '66666666-7777-8888-9999-aaaaaaaaaaaa';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.delete('spells');
    await db.delete('free_writings');
  });

  Future<void> seedSpell(
    String id, {
    String name = 'Página',
    String steps = '✦ Pergunta\nResposta',
    String? observations = 'Página escrita na trilha X — lição Y',
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('spells', {
      'id': id,
      'user_id': 'user-1',
      'name': name,
      'purpose': 'Estudo',
      'type': 'attraction',
      'category': 'other',
      'ingredients': '',
      'steps': steps,
      'observations': observations,
      'is_preloaded': 0,
      'created_at': 1700000000000,
      'updated_at': 1700000001000,
      'synced': 0,
    });
  }

  test('migra registros preservando conteúdo, datas e uuid do sufixo',
      () async {
    await seedSpell('registro_$uuidA', name: 'A Guardiã');
    await seedSpell('registro_$uuidB',
        name: 'Sem nota', observations: null, steps: 'Só o texto');
    await seedSpell('feitico-normal', name: 'Feitiço de verdade');

    final prefs = await SharedPreferences.getInstance();
    final deleted = <String>[];
    await RecordsArchiveMigration(
      deleteRemote: (id) async => deleted.add(id),
    ).run(prefs);

    final db = await DatabaseHelper.instance.database;
    final archive =
        await db.query('free_writings', orderBy: 'created_at ASC');
    expect(archive, hasLength(2));

    final a = archive.firstWhere((r) => r['id'] == uuidA);
    expect(a['title'], 'A Guardiã');
    expect(a['content'],
        'Página escrita na trilha X — lição Y\n\n✦ Pergunta\nResposta');
    expect(a['source'], 'grimorio_vivo');
    expect(a['created_at'], 1700000000000);
    expect(a['updated_at'], 1700000001000);
    expect(a['synced'], 0);

    final b = archive.firstWhere((r) => r['id'] == uuidB);
    expect(b['content'], 'Só o texto', reason: 'sem nota, sem prefixo');

    final spells = await db.query('spells');
    expect(spells, hasLength(1));
    expect(spells.first['id'], 'feitico-normal');

    expect(deleted, unorderedEquals(['registro_$uuidA', 'registro_$uuidB']));
    expect(prefs.getBool(RecordsArchiveMigration.prefsKey), isTrue);
  });

  test('segunda execução é no-op (flag gravada)', () async {
    await seedSpell('registro_$uuidA');
    final prefs = await SharedPreferences.getInstance();
    var calls = 0;
    final migration =
        RecordsArchiveMigration(deleteRemote: (_) async => calls++);
    await migration.run(prefs);
    expect(calls, 1);
    await migration.run(prefs);
    expect(calls, 1, reason: 'flag ligada: nem consulta o banco');
  });

  test('re-execução após falha no meio não duplica nem sobrescreve edição',
      () async {
    // Simula execução anterior interrompida: o item já existe no acervo
    // (e foi EDITADO), mas o spell antigo ainda não foi apagado.
    final db = await DatabaseHelper.instance.database;
    await db.insert('free_writings', {
      'id': uuidA,
      'user_id': 'user-1',
      'title': 'Título editado pela Bruxa',
      'content': 'Conteúdo editado',
      'source': 'grimorio_vivo',
      'created_at': 1700000000000,
      'updated_at': 1700000002000,
      'synced': 1,
    });
    await seedSpell('registro_$uuidA');

    final prefs = await SharedPreferences.getInstance();
    await RecordsArchiveMigration(deleteRemote: (_) async {}).run(prefs);

    final archive = await db.query('free_writings');
    expect(archive, hasLength(1));
    expect(archive.first['title'], 'Título editado pela Bruxa',
        reason: 'ConflictAlgorithm.ignore preserva a edição');
    expect(await db.query('spells'), isEmpty);
    expect(prefs.getBool(RecordsArchiveMigration.prefsKey), isTrue);
  });

  test('archiveIdFor preserva uuid e regenera sufixo estranho', () {
    expect(RecordsArchiveMigration.archiveIdFor('registro_$uuidA'), uuidA);
    final regenerated =
        RecordsArchiveMigration.archiveIdFor('registro_nao-eh-uuid');
    expect(regenerated, isNot(contains('registro')));
    expect(
      RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
          .hasMatch(regenerated),
      isTrue,
    );
  });

  test('não toca feitiços com nome parecido (ESCAPE do LIKE)', () async {
    // 'registroX...' sem underscore não pode casar com o LIKE.
    await seedSpell('registroX-nao-migra', name: 'Falso positivo');
    final prefs = await SharedPreferences.getInstance();
    await RecordsArchiveMigration(deleteRemote: (_) async {}).run(prefs);

    final db = await DatabaseHelper.instance.database;
    expect(await db.query('free_writings'), isEmpty);
    expect((await db.query('spells')).first['id'], 'registroX-nao-migra');
  });
}
