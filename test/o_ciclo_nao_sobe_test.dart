import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/free_writing_model.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/menstrual_consent_store.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
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
///
/// O que mudou: a LINHA de `menstrual_days` passa a poder subir, atrás de um
/// segundo sim. A PÁGINA continua sem subir — e é isso que estes testes
/// separam. São dois dados diferentes do mesmo dia, e o segundo é o corpo
/// dela escrito em prosa; mandar os dois seria mandar o dia duas vezes.
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
    await db.delete('menstrual_days');
    await db.delete('sync_tombstones');
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

  Map<String, Object?> linhaDoCiclo(String dayKey, {String? userId}) => {
        'user_id': userId ?? uid,
        'day_key': dayKey,
        'mark': 'flow',
        'flow': 'medium',
        'symptoms': '["cramps"]',
        'mood': 'sensitive',
        'note': 'manhã mais quieta',
        'revision': 1,
        'deleted': 0,
        'created_at': base,
        'updated_at': base,
        'synced': 0,
      };

  test('sem o segundo sim, a linha do ciclo não sobe', () async {
    // A sincronização do app está LIGADA (o setUp liga), e é esse o ponto:
    // ligar a nuvem não fala pelo registro menstrual. Sem o sim próprio, a
    // linha fica onde está.
    final db = await DatabaseHelper.instance.database;
    await db.insert('menstrual_days', linhaDoCiclo('2026-03-14'));

    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    expect(servidor.linhasDe('menstrual_days'), isEmpty,
        reason: 'dado de saúde saiu do aparelho sem o segundo sim');
    // E a linha continua pendente: não foi carimbada como enviada por
    // engano, então o dia sobe inteiro quando ela disser sim.
    final local = await db.query('menstrual_days');
    expect(local.single['synced'], 0);
  });

  test('com o segundo sim, a linha sobe e a página continua aqui', () async {
    await const MenstrualConsentStore().setRecordingAllowed(uid, true);
    await const MenstrualConsentStore().setSyncAllowed(uid, true);

    final db = await DatabaseHelper.instance.database;
    await db.insert('menstrual_days', linhaDoCiclo('2026-03-14'));
    // A página espelho que o dia ganha no Grimório, do jeito que o
    // MenstrualArchiveRecorder a escreve.
    await db.insert('free_writings',
        pagina('menstrual-$uid-2026-03-14', FreeWritingSource.menstrual));

    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    final enviadas = servidor.linhasDe('menstrual_days');
    expect(enviadas, hasLength(1), reason: 'a linha do dia sobe');
    expect(enviadas.single['day_key'], '2026-03-14');
    expect(enviadas.single['note'], 'manhã mais quieta');
    // `symptoms` vira estrutura para o jsonb, e `deleted` vira booleano.
    expect(enviadas.single['symptoms'], ['cramps']);
    expect(enviadas.single['deleted'], isFalse);
    // As colunas mortas da Estação Interna não existem no servidor.
    expect(enviadas.single.containsKey('season'), isFalse);
    expect(enviadas.single.containsKey('synced'), isFalse);

    expect(
      servidor.linhasDe('free_writings').map((l) => l['id']),
      isNot(contains('menstrual-$uid-2026-03-14')),
      reason: 'a página do dia não sobe nem com o segundo sim ligado',
    );
  });

  test('apagar um dia não deixa lápide no servidor', () async {
    // O `item_id` de uma lápide menstrual seria a data exata em que ela
    // sangrou e depois apagou, guardada em claro no servidor para sempre.
    // Quem carrega a exclusão é a própria linha, com `deleted`.
    await const MenstrualConsentStore().setRecordingAllowed(uid, true);
    await const MenstrualConsentStore().setSyncAllowed(uid, true);

    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'menstrual_days',
      linhaDoCiclo('2026-03-14')
        ..['deleted'] = 1
        ..['revision'] = 2
        ..['note'] = '',
    );

    await service.deleteItem(SyncEntity.menstrualDays, '2026-03-14');
    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    expect(await db.query('sync_tombstones'), isEmpty,
        reason: 'nem no aparelho: a lista guarda a data do que ela apagou');
    expect(servidor.linhasDe('sync_tombstones'), isEmpty);
    // A exclusão viaja na linha, que é o que os outros aparelhos leem.
    expect(servidor.linhasDe('menstrual_days').single['deleted'], isTrue);
  });

  test('ligar o envio não manda as datas que ela apagou antes de consentir',
      () async {
    // A lápide de um dia menstrual É a data em que ela sangrou e depois
    // apagou. Enquanto o envio esteve desligado, ninguém no mundo tinha cópia
    // daquele dia — então a lápide não tem a quem avisar, e liberá-la no
    // momento do sim seria mandar ao servidor exatamente o mapa dos dias
    // apagados que este desenho recusa a guardar.
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'menstrual_days',
      linhaDoCiclo('2026-03-14')
        ..['deleted'] = 1
        ..['revision'] = 2
        ..['note'] = ''
        ..['synced'] = 0,
    );
    await db.insert(
        'menstrual_days', linhaDoCiclo('2026-03-20')..['synced'] = 1);

    // O gesto de ligar, do jeito que a roda do ciclo o faz.
    await const MenstrualConsentStore().setRecordingAllowed(uid, true);
    await const MenstrualConsentStore().setSyncAllowed(uid, true);
    final repositorio = MenstrualCycleRepository();
    await repositorio.descartarLapidesPendentes(uid);
    await repositorio.markForUpload(uid);

    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    expect(
      servidor.linhasDe('menstrual_days').map((l) => l['day_key']),
      ['2026-03-20'],
      reason: 'sobe o registro dela, não a data do que ela apagou',
    );
    expect(
      (await db.query('menstrual_days')).map((l) => l['day_key']),
      ['2026-03-20'],
      reason: 'e a data apagada também não fica guardada aqui à toa',
    );
  });

  test('a adoção do login não carimba o registro do ciclo como "a enviar"',
      () async {
    // O histórico escrito antes de existir conta É dela e continua aqui — mas
    // adotá-lo com `synced = 0` entregaria tudo à primeira varredura do
    // login, por efeito colateral, sem ninguém ter dito sim a nada.
    final db = await DatabaseHelper.instance.database;
    await db.insert(
        'menstrual_days', linhaDoCiclo('2026-02-02', userId: 'local_user'));

    await DatabaseHelper.instance.claimLegacyData(uid);

    final adotada = await db.query('menstrual_days');
    expect(adotada.single['user_id'], uid, reason: 'o registro passa a ser dela');
    expect(adotada.single['synced'], 1,
        reason: 'adotar não é consentir em enviar');

    // E mesmo com o segundo sim ligado DEPOIS, quem libera o histórico é o
    // markForUpload que a tela chama — não a adoção.
    await const MenstrualConsentStore().setRecordingAllowed(uid, true);
    await const MenstrualConsentStore().setSyncAllowed(uid, true);
    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);
    expect(servidor.linhasDe('menstrual_days'), isEmpty);
  });
}
