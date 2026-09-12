import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/free_writing_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dubles/servidor_de_mentira.dart';

/// A promessa que ela lê para dizer sim é que o registro do ciclo não sai
/// deste aparelho. O acervo ganhou uma página espelho de cada dia — e o
/// acervo, esse, sincroniza sem porteiro próprio.
///
/// Quem faz a promessa valer é uma linha no funil por onde TODA varredura
/// passa (`_isSyncableItem`), mais a exclusão dessas origens na adoção de
/// dados anônimos. Este arquivo existe porque as duas são fáceis de apagar
/// sem perceber: são uma condição dentro de um `if` e um `NOT IN` dentro de
/// um `where`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = '99999999-8888-7777-6666-555555555555';

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Diretório próprio: os arquivos de teste rodam em paralelo e disputam
    // o mesmo banco no caminho padrão.
    final dir = await Directory.systemTemp.createTemp('grimorio_ciclo_nuvem');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  final service = DataSyncService();
  late ServidorDeMentira servidor;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DataSyncService.cloudSyncUserConfiguredKey, true);
    await prefs.setBool(DataSyncService.cloudSyncPreferenceKey, true);
    servidor = ServidorDeMentira();
    service.configurarParaTeste(servidor, uid);
    final db = await DatabaseHelper.instance.database;
    await db.delete('free_writings');
  });

  const base = 1700000000000;

  Map<String, dynamic> pagina(String id, String source, {String? userId}) => {
        'id': id,
        'user_id': userId ?? uid,
        'title': 'título',
        'content': 'corpo',
        'source': source,
        'created_at': base,
        'updated_at': base,
        'synced': 0,
      };

  test('a página do ciclo não sobe; a reflexão ao lado dela sobe', () async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('free_writings', pagina('reflexao-1', FreeWritingSource.free));
    for (final origem in FreeWritingSource.neverLeavesDevice) {
      await db.insert('free_writings', pagina('ciclo-$origem', origem));
    }

    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    final enviadas = servidor.linhasDe('free_writings');
    expect(
      enviadas.map((l) => l['id']),
      contains('reflexao-1'),
      reason: 'o acervo comum continua sincronizando',
    );
    for (final origem in FreeWritingSource.neverLeavesDevice) {
      expect(
        enviadas.map((l) => l['id']),
        isNot(contains('ciclo-$origem')),
        reason: 'a página do ciclo saiu do aparelho',
      );
      expect(
        enviadas.map((l) => l['source']),
        isNot(contains(origem)),
        reason: 'nem o nome da origem pode viajar',
      );
    }
  });

  test('a adoção do login não carimba a página do ciclo como "a enviar"',
      () async {
    final db = await DatabaseHelper.instance.database;
    // O estado de quem usou o app antes de criar conta.
    await db.insert('free_writings',
        pagina('reflexao-2', FreeWritingSource.free, userId: 'local_user'));
    await db.insert(
        'free_writings',
        pagina('ciclo-anonimo', FreeWritingSource.menstrual,
            userId: 'local_user'));

    await DatabaseHelper.instance.claimLegacyData(uid);

    final adotada = await db
        .query('free_writings', where: 'id = ?', whereArgs: ['reflexao-2']);
    expect(adotada.single['user_id'], uid,
        reason: 'a reflexão anônima passa a ser dela');

    final ciclo = await db
        .query('free_writings', where: 'id = ?', whereArgs: ['ciclo-anonimo']);
    expect(ciclo.single['user_id'], 'local_user',
        reason: 'adotar seria carimbá-la como pendente de envio, e a primeira '
            'varredura do login roda antes de qualquer tela recarregar');

    // E a varredura logo em seguida, que é a ordem real do login, não a leva.
    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);
    expect(
      servidor.linhasDe('free_writings').map((l) => l['id']),
      isNot(contains('ciclo-anonimo')),
    );
  });
}
