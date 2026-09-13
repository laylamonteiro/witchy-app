import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dubles/servidor_de_mentira.dart';

/// A lápide que sobrevivia ao desligar.
///
/// Quem apaga algo com a nuvem ligada e sem rede deixa a lápide pendente no
/// aparelho. Ela guarda o `id` do que foi apagado — e id aqui é conteúdo com
/// frequência demais: `preloaded_<nome do feitiço>`, o id do mapa no perfil
/// mágico, `<conta>_<dia>` no check-in. Se a pessoa desliga a sincronização
/// em seguida, essa lista fica guardada, intacta, esperando; e na primeira
/// varredura depois de religar ela sai do aparelho — pelo gesto que a pessoa
/// fez justamente para nada mais sair.
///
/// O conserto é descartar as PENDENTES ao desligar, e o preço é explícito:
/// um item apagado com a nuvem desligada volta se ela for religada, porque
/// guardar a memória da exclusão é guardar o id. Entre ressuscitar um item,
/// que ela apaga de novo, e manter no aparelho a lista exata do que ela
/// mandou sumir, o ressuscitado é o dano menor.
///
/// Vale para TODAS as entidades, não só para o ciclo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = '77777777-6666-5555-4444-333333333333';
  final service = DataSyncService();
  late ServidorDeMentira servidor;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = await Directory.systemTemp.createTemp('grimorio_lapides_off');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DataSyncService.cloudSyncUserConfiguredKey, true);
    await prefs.setBool(DataSyncService.cloudSyncPreferenceKey, true);

    servidor = ServidorDeMentira();
    service.configurarParaTeste(servidor, uid);

    final db = await DatabaseHelper.instance.database;
    await db.delete('sync_tombstones');
    await db.delete('dreams');
  });

  const base = 1700000000000;

  Future<void> sonho(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('dreams', {
      'id': id,
      'user_id': uid,
      'title': 'um sonho',
      'content': 'corpo',
      'date': base,
      'created_at': base,
      'updated_at': base,
      'synced': 0,
    });
  }

  test('desligar descarta a lápide que ainda não foi avisada', () async {
    await sonho('sonho-1');
    await service.syncAll();
    expect(servidor.linhasDe('dreams'), hasLength(1));

    // Apagar sem rede: a linha some daqui, a nuvem não fica sabendo, e a
    // lápide fica pendente.
    final db = await DatabaseHelper.instance.database;
    await db.delete('dreams', where: 'id = ?', whereArgs: ['sonho-1']);
    servidor.foraDoAr = true;
    await service.deleteItem(SyncEntity.dreams, 'sonho-1');
    servidor.foraDoAr = false;

    final pendentes =
        await db.query('sync_tombstones', where: 'synced = 0');
    expect(pendentes, hasLength(1),
        reason: 'a lápide pendente é a premissa deste teste');
    expect(pendentes.single['item_id'], 'sonho-1');

    // Ela desliga a sincronização.
    expect(await service.descartarLapidesPendentes(), 1);

    expect(await db.query('sync_tombstones'), isEmpty,
        reason: 'o id do que ela apagou não fica guardado esperando religar');
  });

  test('desligar PELO interruptor descarta, e não só o método solto',
      () async {
    // O interruptor existe em duas telas (Sincronização e Backup, e o
    // Perfil), e um teste que só chama `descartarLapidesPendentes` não
    // perceberia uma delas esquecendo o descarte. O gesto inteiro — gravar a
    // preferência e o que ela arrasta — mora em `definirSincronizacao`, e é
    // ele que as telas chamam.
    await sonho('sonho-4');
    await service.syncAll();

    final db = await DatabaseHelper.instance.database;
    await db.delete('dreams', where: 'id = ?', whereArgs: ['sonho-4']);
    servidor.foraDoAr = true;
    await service.deleteItem(SyncEntity.dreams, 'sonho-4');
    servidor.foraDoAr = false;
    expect(await db.query('sync_tombstones', where: 'synced = 0'), hasLength(1));

    await service.definirSincronizacao(false);

    expect(await service.cloudSyncEnabled, isFalse);
    expect(await db.query('sync_tombstones'), isEmpty,
        reason: 'desligar pelo interruptor é o gesto que fecha o vazamento');

    // E religar não ressuscita a lista: ela não existe mais.
    await service.definirSincronizacao(true);
    expect(await service.cloudSyncEnabled, isTrue);
    expect(await db.query('sync_tombstones'), isEmpty);
  });

  test('a lápide JÁ enviada continua, porque o servidor já sabe', () async {
    await sonho('sonho-2');
    await service.syncAll();
    await service.deleteItem(SyncEntity.dreams, 'sonho-2');

    final db = await DatabaseHelper.instance.database;
    expect(await db.query('sync_tombstones', where: 'synced = 1'),
        hasLength(1));

    await service.descartarLapidesPendentes();

    expect(
      await db.query('sync_tombstones'),
      hasLength(1),
      reason: 'derrubá-la traria de volta o que outro aparelho apagou: ela '
          'descreve o que o servidor JÁ sabe, não um recado por dar',
    );
  });

  test('o preço: o item apagado com a nuvem desligada volta ao religar',
      () async {
    // Escrito como teste porque é consequência, não descuido — e porque uma
    // reescrita futura que "conserte" isto estará reintroduzindo o vazamento.
    await sonho('sonho-3');
    await service.syncAll();
    expect(servidor.linhasDe('dreams'), hasLength(1));

    final db = await DatabaseHelper.instance.database;
    await db.delete('dreams', where: 'id = ?', whereArgs: ['sonho-3']);
    servidor.foraDoAr = true;
    await service.deleteItem(SyncEntity.dreams, 'sonho-3');
    servidor.foraDoAr = false;

    await service.descartarLapidesPendentes();

    // Religou: o download traz de volta o que só existe no servidor.
    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);
    expect(
      (await db.query('dreams')).map((l) => l['id']),
      contains('sonho-3'),
      reason: 'é o preço aceito: não sobrou nada aqui que se lembrasse da '
          'exclusão, porque lembrar seria guardar o id',
    );
  });
}
