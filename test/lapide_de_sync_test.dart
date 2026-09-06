import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dubles/servidor_de_mentira.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = '11111111-2222-3333-4444-555555555555';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final service = DataSyncService();
  late ServidorDeMentira servidor;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    servidor = ServidorDeMentira();
    service.configurarParaTeste(servidor, uid);
    final db = await DatabaseHelper.instance.database;
    await db.delete('dreams');
    await db.delete('sync_tombstones');
  });

  // Um instante base fixo, para as relações antes/depois ficarem explícitas.
  const base = 1700000000000;

  String iso(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms).toUtc().toIso8601String();

  Map<String, dynamic> sonho(String id, {int updatedAt = base}) => {
        'id': id,
        'user_id': uid,
        'title': 'Cobra no jardim',
        'content': 'Uma cobra dourada atravessava o canteiro.',
        'date': base,
        'created_at': base,
        'updated_at': updatedAt,
        'synced': 0,
      };

  /// A mesma linha como o servidor a guarda (datas em ISO, sem `synced`).
  Map<String, dynamic> sonhoRemoto(String id, {int updatedAt = base}) => {
        'id': id,
        'user_id': uid,
        'title': 'Cobra no jardim',
        'content': 'Uma cobra dourada atravessava o canteiro.',
        'date': iso(base),
        'created_at': iso(base),
        'updated_at': iso(updatedAt),
      };

  Map<String, dynamic> lapideRemota(String id, {required int deletedAt}) => {
        'user_id': uid,
        'entity': 'dreams',
        'item_id': id,
        'deleted_at': iso(deletedAt),
      };

  Future<List<Map<String, dynamic>>> lapidesLocais() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('sync_tombstones');
  }

  group('a lápide da exclusão', () {
    test('item apagado com a rede fora do ar não ressuscita no sync seguinte',
        () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('dreams', sonho('sonho-1'));

      // Primeira varredura: o sonho sobe para a nuvem.
      var resultado = await service.syncAll();
      expect(resultado.success, isTrue, reason: resultado.detailedError);
      expect(servidor.linhasDe('dreams'), hasLength(1));

      // O apagar do repositório, com a rede fora do ar: a linha local some
      // e o aviso à nuvem morre no catch do deleteItem. É o cenário de
      // avião, túnel, wifi caído — o mais comum de todos.
      servidor.foraDoAr = true;
      await db.delete('dreams', where: 'id = ?', whereArgs: ['sonho-1']);
      await service.deleteItem(SyncEntity.dreams, 'sonho-1');

      // A rede volta e a varredura roda de novo.
      servidor.foraDoAr = false;
      resultado = await service.syncAll();
      expect(resultado.success, isTrue, reason: resultado.detailedError);

      final deVolta =
          await db.query('dreams', where: 'id = ?', whereArgs: ['sonho-1']);
      expect(
        deVolta,
        isEmpty,
        reason: 'o sonho apagado ressuscitou no download da sincronização',
      );
      expect(
        servidor.linhasDe('dreams'),
        isEmpty,
        reason: 'a cópia do servidor precisa ser purgada quando a rede volta',
      );
    });

    test('apagar com a rede no ar purga a linha e registra a lápide remota',
        () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('dreams', sonho('sonho-2'));
      await service.syncAll();

      await db.delete('dreams', where: 'id = ?', whereArgs: ['sonho-2']);
      await service.deleteItem(SyncEntity.dreams, 'sonho-2');

      expect(servidor.linhasDe('dreams'), isEmpty);
      expect(
        servidor.linhasDe('sync_tombstones'),
        hasLength(1),
        reason: 'sem a lápide remota, os outros aparelhos nunca sabem',
      );
      final locais = await lapidesLocais();
      expect(locais, hasLength(1));
      expect(locais.first['synced'], 1,
          reason: 'exclusão avisada não precisa ser retentada');
    });

    test('a exclusão feita noutro aparelho alcança este', () async {
      final db = await DatabaseHelper.instance.database;
      // A linha vive aqui, já sincronizada; o outro aparelho apagou: no
      // servidor restou só a lápide.
      await db.insert('dreams', {...sonho('sonho-3'), 'synced': 1});
      servidor.tabelas['sync_tombstones'] = [
        lapideRemota('sonho-3', deletedAt: base + 1000),
      ];

      final resultado = await service.syncAll();
      expect(resultado.success, isTrue, reason: resultado.detailedError);

      final restante =
          await db.query('dreams', where: 'id = ?', whereArgs: ['sonho-3']);
      expect(restante, isEmpty,
          reason: 'a exclusão precisa viajar entre os aparelhos da pessoa');
    });

    test('a edição mais nova que a exclusão vence a lápide', () async {
      final db = await DatabaseHelper.instance.database;
      // Apagado no outro aparelho, mas EDITADO aqui depois disso. Apagar a
      // edição em silêncio é a perda que a regra mostRecent existe para
      // impedir.
      await db.insert('dreams', sonho('sonho-4', updatedAt: base + 2000));
      servidor.tabelas['sync_tombstones'] = [
        lapideRemota('sonho-4', deletedAt: base + 1000),
      ];

      final resultado = await service.syncAll();
      expect(resultado.success, isTrue, reason: resultado.detailedError);

      final local =
          await db.query('dreams', where: 'id = ?', whereArgs: ['sonho-4']);
      expect(local, hasLength(1), reason: 'a edição vence a exclusão antiga');
      expect(servidor.linhasDe('dreams'), hasLength(1),
          reason: 'a linha vencedora volta a subir');
      expect(servidor.linhasDe('sync_tombstones'), isEmpty,
          reason: 'a lápide vencida cai, senão a briga recomeça a cada sync');
      expect(await lapidesLocais(), isEmpty);
    });

    test('a cópia remota recriada depois da exclusão volta a descer',
        () async {
      final db = await DatabaseHelper.instance.database;
      // Apagado aqui fora do ar; enquanto isso o outro aparelho recriou o
      // item (updated_at mais novo que a exclusão). A recriação vence.
      servidor.foraDoAr = true;
      await service.deleteItem(SyncEntity.dreams, 'sonho-5');
      servidor.foraDoAr = false;

      final agora = DateTime.now().millisecondsSinceEpoch;
      servidor.tabelas['dreams'] = [
        sonhoRemoto('sonho-5', updatedAt: agora + 60000),
      ];

      final resultado = await service.syncAll();
      expect(resultado.success, isTrue, reason: resultado.detailedError);

      final local =
          await db.query('dreams', where: 'id = ?', whereArgs: ['sonho-5']);
      expect(local, hasLength(1),
          reason: 'a recriação mais nova desce mesmo com lápide local');
      expect(await lapidesLocais(), isEmpty);
    });

    test('recriar sob o mesmo id derruba a lápide', () async {
      final db = await DatabaseHelper.instance.database;
      // O caso do Perfil Mágico, cujo id é o do mapa: apagar e gerar de
      // novo reusa o id. A lápide da exclusão não pode purgar a recriação.
      servidor.foraDoAr = true;
      await service.deleteItem(SyncEntity.dreams, 'sonho-6');
      servidor.foraDoAr = false;

      final agora = DateTime.now().millisecondsSinceEpoch;
      await db.insert('dreams', sonho('sonho-6', updatedAt: agora + 60000));

      var resultado = await service.syncAll();
      expect(resultado.success, isTrue, reason: resultado.detailedError);
      expect(servidor.linhasDe('dreams'), hasLength(1));
      expect(await lapidesLocais(), isEmpty,
          reason: 'subir a linha é afirmar que ela existe');

      // E a varredura seguinte não pode desfazer: a lápide remota que
      // sobrou é mais velha que a linha e cai.
      resultado = await service.syncAll();
      expect(resultado.success, isTrue, reason: resultado.detailedError);
      final local =
          await db.query('dreams', where: 'id = ?', whereArgs: ['sonho-6']);
      expect(local, hasLength(1));
      expect(servidor.linhasDe('dreams'), hasLength(1));
      expect(servidor.linhasDe('sync_tombstones'), isEmpty);
    });

    test('sem a migração no painel, a purga ainda impede a ressurreição',
        () async {
      // Até sync_tombstones_migration.sql rodar, as operações de lápide
      // falham no servidor. A purga da linha não depende delas.
      servidor.semTabelaDeLapides = true;
      final db = await DatabaseHelper.instance.database;
      await db.insert('dreams', sonho('sonho-7'));
      await service.syncAll();

      servidor.foraDoAr = true;
      await db.delete('dreams', where: 'id = ?', whereArgs: ['sonho-7']);
      await service.deleteItem(SyncEntity.dreams, 'sonho-7');
      servidor.foraDoAr = false;

      final resultado = await service.syncAll();
      expect(resultado.success, isTrue, reason: resultado.detailedError);

      expect(
        await db.query('dreams', where: 'id = ?', whereArgs: ['sonho-7']),
        isEmpty,
      );
      expect(servidor.linhasDe('dreams'), isEmpty);
      final locais = await lapidesLocais();
      expect(locais, hasLength(1));
      expect(locais.first['synced'], 0,
          reason: 'a lápide fica pendente até a migração existir, para os '
              'outros aparelhos saberem um dia');
    });

    test('fullDownload não traz de volta o que foi apagado', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('dreams', sonho('sonho-8'));
      await service.syncAll();

      servidor.foraDoAr = true;
      await db.delete('dreams', where: 'id = ?', whereArgs: ['sonho-8']);
      await service.deleteItem(SyncEntity.dreams, 'sonho-8');
      servidor.foraDoAr = false;

      final resultado = await service.fullDownload();
      expect(resultado.success, isTrue, reason: resultado.detailedError);

      expect(
        await db.query('dreams', where: 'id = ?', whereArgs: ['sonho-8']),
        isEmpty,
        reason: 'o "baixar tudo" era o caminho mais largo da ressurreição',
      );
      expect(servidor.linhasDe('dreams'), isEmpty);
    });
  });
}
