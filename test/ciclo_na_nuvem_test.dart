import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/menstrual_consent_store.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/services/menstrual_archive_recorder.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dubles/servidor_de_mentira.dart';

/// A descida do registro menstrual, que é a metade menos óbvia do trabalho.
///
/// A subida é um upsert; a descida não pode ser o motor genérico. Ele decide
/// conflito por `updated_at` e escreve na tabela direto — aqui a regra é
/// `revision` (empatadas, a gravação mais recente), e quem a aplica é
/// `MenstrualCycleRepository.mergeRemote`, que também reconstrói a página do
/// dia no Grimório. Sem o desvio, `revision` viraria enfeite, um aparelho
/// antigo ressuscitaria o dia que ela apagou noutro, e a página espelho
/// ficaria contando a versão velha do mesmo dia.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = '11111111-2222-3333-4444-555555555555';
  const dia = '2026-03-14';
  final service = DataSyncService();
  late ServidorDeMentira servidor;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = await Directory.systemTemp.createTemp('grimorio_ciclo_desce');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DataSyncService.cloudSyncUserConfiguredKey, true);
    await prefs.setBool(DataSyncService.cloudSyncPreferenceKey, true);
    await const MenstrualConsentStore().setRecordingAllowed(uid, true);
    await const MenstrualConsentStore().setSyncAllowed(uid, true);

    servidor = ServidorDeMentira();
    service.configurarParaTeste(servidor, uid);

    final db = await DatabaseHelper.instance.database;
    await db.delete('menstrual_days');
    await db.delete('free_writings');
    await db.delete('sync_tombstones');
  });

  const base = 1700000000000;

  /// Uma linha local, do jeito que a roda do ciclo a grava.
  Map<String, Object?> local({
    required int revision,
    required bool deleted,
    required String note,
    String dayKey = dia,
    int updatedAt = base,
    int synced = 1,
  }) =>
      {
        'user_id': uid,
        'day_key': dayKey,
        'mark': deleted ? 'note' : 'flow',
        'flow': deleted ? null : 'medium',
        'symptoms': '[]',
        'mood': null,
        'note': note,
        'revision': revision,
        'deleted': deleted ? 1 : 0,
        'created_at': base,
        'updated_at': updatedAt,
        'synced': synced,
      };

  /// Uma linha como o Postgres a devolve: `symptoms` estruturado, `deleted`
  /// booleano, datas em ISO-8601 UTC.
  Map<String, dynamic> remota({
    required int revision,
    required bool deleted,
    required String note,
    int updatedAt = base,
  }) =>
      {
        'user_id': uid,
        'day_key': dia,
        'mark': deleted ? 'note' : 'flow',
        'flow': deleted ? null : 'medium',
        'symptoms': <String>[],
        'mood': null,
        'note': note,
        'revision': revision,
        'deleted': deleted,
        'created_at':
            DateTime.fromMillisecondsSinceEpoch(base).toUtc().toIso8601String(),
        'updated_at': DateTime.fromMillisecondsSinceEpoch(updatedAt)
            .toUtc()
            .toIso8601String(),
      };

  // Variável, não getter: dentro de um corpo de função Dart não declara
  // getter, e `uid`/`dia` são constantes deste arquivo — o valor não muda
  // entre um teste e outro.
  final idDaPagina = MenstrualArchiveRecorder.pageId(userId: uid, dayKey: dia);

  test('a revisão maior do servidor vence, e a página é reescrita', () async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('menstrual_days',
        local(revision: 1, deleted: false, note: 'o que eu escrevi aqui'));
    await servidor.upsert(
      'menstrual_days',
      remota(revision: 3, deleted: false, note: 'o que eu corrigi no celular'),
      onConflict: 'user_id,day_key',
    );

    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    final linha = (await db.query('menstrual_days')).single;
    expect(linha['note'], 'o que eu corrigi no celular');
    expect(linha['revision'], 3);
    expect(linha['synced'], 1);

    // A página do dia acompanha a linha, venha ela da tela ou de outro
    // aparelho — senão o Grimório continuaria contando a versão velha.
    final pagina = await db
        .query('free_writings', where: 'id = ?', whereArgs: [idDaPagina]);
    expect(pagina, hasLength(1));
    expect(pagina.single['content'], contains('o que eu corrigi no celular'));
    expect(pagina.single['synced'], 1,
        reason: 'a página nasce carimbada: ela nunca sai do aparelho');
  });

  test('a revisão menor do servidor perde, e a de cá vai consertá-lo',
      () async {
    // O aparelho antigo que se reconecta com a cópia velha. Vencer aqui não
    // basta: o servidor continuaria com a perdedora para sempre — ninguém
    // mais a enviaria, porque a linha daqui está carimbada como enviada — e
    // todo aparelho novo receberia a versão errada do dia.
    final db = await DatabaseHelper.instance.database;
    await db.insert('menstrual_days',
        local(revision: 4, deleted: false, note: 'a versão certa'));
    await servidor.upsert(
      'menstrual_days',
      remota(revision: 2, deleted: false, note: 'a cópia velha'),
      onConflict: 'user_id,day_key',
    );

    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    expect((await db.query('menstrual_days')).single['note'], 'a versão certa');
    expect(servidor.linhasDe('menstrual_days').single['note'], 'a versão certa',
        reason: 'a vencedora daqui volta a dever subida e conserta o servidor');
  });

  test('a cópia velha e suja não escreve por cima da nova no servidor',
      () async {
    // O aparelho que passou a semana offline. Subindo antes de descer, ele
    // faria um upsert cego: escreveria a revisão 2 por cima da 5 e
    // ressuscitaria NO SERVIDOR o dia que ela apagou no celular. É por isso
    // que a ordem aqui é desce-e-depois-sobe.
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'menstrual_days',
      local(
          revision: 2,
          deleted: false,
          note: 'a cópia que ficou offline',
          synced: 0),
    );
    await servidor.upsert(
      'menstrual_days',
      remota(revision: 5, deleted: true, note: '', updatedAt: base + 5000),
      onConflict: 'user_id,day_key',
    );

    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    expect(servidor.linhasDe('menstrual_days').single['deleted'], isTrue,
        reason: 'o dia apagado no celular não volta a existir no servidor');
    expect((await db.query('menstrual_days')).single['deleted'], 1);
    expect(await MenstrualCycleRepository().history(uid), isEmpty);
  });

  test('enviar tudo envia o registro inteiro, não só o que está sujo',
      () async {
    // É o botão de quem ficou sem cópia na nuvem — inclusive por ter apagado
    // a cópia de propósito. Mandando só o pendente ele não mandaria nada,
    // porque está tudo carimbado como enviado.
    final db = await DatabaseHelper.instance.database;
    await db.insert('menstrual_days',
        local(revision: 1, deleted: false, note: 'já carimbado aqui'));

    final resultado = await service.fullUpload();
    expect(resultado.success, isTrue, reason: resultado.detailedError);
    expect(servidor.linhasDe('menstrual_days').single['note'],
        'já carimbado aqui');
  });

  test('o apagar que a rede engoliu não vira um registro de volta', () async {
    // Sem isto, "apagar meus registros do ciclo" se desfaz sozinho: a tela
    // diz que apagou, a varredura seguinte encontra a cópia sobrevivente e
    // reinstala tudo, inclusive as páginas no Grimório.
    final db = await DatabaseHelper.instance.database;
    await db.insert('menstrual_days',
        local(revision: 1, deleted: false, note: 'para apagar', synced: 0));
    await service.syncAll();
    expect(servidor.linhasDe('menstrual_days'), hasLength(1));

    servidor.foraDoAr = true;
    final apagou = await MenstrualCycleRepository().purge(uid);
    servidor.foraDoAr = false;
    expect(apagou.apagados, 1);
    expect(apagou.nuvemLimpa, isFalse,
        reason: 'a tela precisa poder dizer que a conta ainda tem cópia');

    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    expect(await db.query('menstrual_days'), isEmpty,
        reason: 'o registro que ela mandou apagar não volta');
    expect(servidor.linhasDe('menstrual_days'), isEmpty,
        reason: 'o pedido ficou anotado e a varredura o terminou');
  });

  test('a exclusão feita noutro aparelho tira o dia e a página daqui',
      () async {
    final db = await DatabaseHelper.instance.database;
    // Gravar pela roda, e não direto no banco: é a gravação que escreve a
    // página do dia no Grimório, e é ela que precisa sair depois.
    await MenstrualCycleRepository().save(MenstrualDay(
      userId: uid,
      day: DateTime(2026, 3, 14),
      mark: MenstrualMark.flow,
      note: 'manhã mais quieta',
    ));
    await service.syncAll();
    expect(
      await db.query('free_writings', where: 'id = ?', whereArgs: [idDaPagina]),
      hasLength(1),
    );

    // Noutro aparelho ela apagou o dia: a linha volta com `deleted` e uma
    // revisão maior. Não há lápide em `sync_tombstones` — é a própria linha
    // que carrega a exclusão.
    await servidor.upsert(
      'menstrual_days',
      remota(revision: 2, deleted: true, note: '', updatedAt: base + 1000),
      onConflict: 'user_id,day_key',
    );

    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    expect(await MenstrualCycleRepository().history(uid), isEmpty,
        reason: 'o dia sai do histórico vivo');
    expect(
      await db.query('free_writings', where: 'id = ?', whereArgs: [idDaPagina]),
      isEmpty,
      reason: 'a página tinha de sair junto, senão o dia apagado no celular '
          'continuaria inteiro no Grimório do navegador',
    );
    expect(servidor.linhasDe('sync_tombstones'), isEmpty);
  });

  test('sem o segundo sim nada DESCE, nem para o aparelho', () async {
    await const MenstrualConsentStore().setSyncAllowed(uid, false);
    await servidor.upsert(
      'menstrual_days',
      remota(revision: 9, deleted: false, note: 'de outro aparelho'),
      onConflict: 'user_id,day_key',
    );

    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    final db = await DatabaseHelper.instance.database;
    expect(await db.query('menstrual_days'), isEmpty,
        reason: 'baixar já seria ler no servidor um dado de saúde que ela não '
            'autorizou a sair — e escrever aqui dias que ela talvez tenha '
            'apagado de propósito');
  });

  test('apagar a cópia da nuvem tira o que está lá e deixa o que está aqui',
      () async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('menstrual_days',
        local(revision: 1, deleted: false, note: 'fica aqui', synced: 0));
    await service.syncAll();
    expect(servidor.linhasDe('menstrual_days'), hasLength(1));

    expect(await service.apagarCicloNaNuvem(uid), isTrue);

    expect(servidor.linhasDe('menstrual_days'), isEmpty);
    expect((await db.query('menstrual_days')).single['note'], 'fica aqui');
  });

  test('apagar a cópia da nuvem recusa a conta errada', () async {
    await servidor.upsert(
      'menstrual_days',
      remota(revision: 1, deleted: false, note: 'de outra pessoa'),
      onConflict: 'user_id,day_key',
    );
    expect(await service.apagarCicloNaNuvem('outra-conta'), isFalse);
    expect(servidor.linhasDe('menstrual_days'), hasLength(1));
  });

  test('o segundo sim libera o histórico inteiro, não só o que vier depois',
      () async {
    // O que ela escreveu antes de dizer sim (ou antes de existir conta, que
    // chega adotado e já carimbado) está `synced = 1` e não sobe. Quem o
    // libera é markForUpload, e só ele.
    final db = await DatabaseHelper.instance.database;
    await db.insert('menstrual_days',
        local(revision: 1, deleted: false, note: 'de antes do sim'));

    await service.syncAll();
    expect(servidor.linhasDe('menstrual_days'), isEmpty);

    await MenstrualCycleRepository().markForUpload(uid);
    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);
    expect(servidor.linhasDe('menstrual_days').single['note'],
        'de antes do sim');
  });

  test('o apagar pendente é concluído mesmo depois de o sim ser esquecido',
      () async {
    // O caminho real da tela de Privacidade: `purge` e, na linha seguinte,
    // `forget`. Com a retentativa trancada atrás do consentimento, ela
    // morria ali — e a cópia inteira do registro de saúde ficava no servidor
    // para sempre, depois de a tela já ter dito "apagados".
    final db = await DatabaseHelper.instance.database;
    await db.insert('menstrual_days',
        local(revision: 1, deleted: false, note: 'para apagar', synced: 0));
    await service.syncAll();
    expect(servidor.linhasDe('menstrual_days'), hasLength(1));

    servidor.foraDoAr = true;
    final apagou = await MenstrualCycleRepository().purge(uid);
    servidor.foraDoAr = false;
    expect(apagou.nuvemLimpa, isFalse);
    await const MenstrualConsentStore().forget(uid);

    final resultado = await service.syncAll();
    expect(resultado.success, isTrue, reason: resultado.detailedError);
    expect(servidor.linhasDe('menstrual_days'), isEmpty,
        reason: 'apagar o que já subiu não depende de autorização para '
            'subir — é o oposto dela');
  });

  test('o apagar pendente é concluído mesmo com a sincronização desligada',
      () async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('menstrual_days',
        local(revision: 1, deleted: false, note: 'para apagar', synced: 0));
    await service.syncAll();
    expect(servidor.linhasDe('menstrual_days'), hasLength(1));

    servidor.foraDoAr = true;
    await MenstrualCycleRepository().purge(uid);
    servidor.foraDoAr = false;
    // Desligar a nuvem interrompe o que sai daqui; nunca o que ela mandou
    // sair de lá.
    await service.definirSincronizacao(false);

    await service.syncAll();
    expect(servidor.linhasDe('menstrual_days'), isEmpty);
  });

  test('o apagar pendente termina ANTES do enviar tudo', () async {
    // Na ordem errada o estrago é silencioso: o "enviar tudo" manda os dias
    // novos, a varredura seguinte termina a purga e apaga no servidor
    // exatamente o que acabou de chegar. Com tudo carimbado como enviado
    // aqui, ninguém reenvia nada e a conta fica sem cópia.
    final db = await DatabaseHelper.instance.database;
    await db.insert('menstrual_days',
        local(revision: 1, deleted: false, note: 'a cópia antiga', synced: 0));
    await service.syncAll();

    servidor.foraDoAr = true;
    await MenstrualCycleRepository().purge(uid);
    servidor.foraDoAr = false;

    await db.insert('menstrual_days',
        local(revision: 1, deleted: false, note: 'o dia novo', synced: 0));
    final resultado = await service.fullUpload();
    expect(resultado.success, isTrue, reason: resultado.detailedError);
    expect(servidor.linhasDe('menstrual_days').single['note'], 'o dia novo');

    await service.syncAll();
    expect(servidor.linhasDe('menstrual_days').single['note'], 'o dia novo',
        reason: 'a purga já tinha terminado: não sobrou nada para derrubar '
            'o que acabou de subir');
  });

  test('enviar tudo não manda a data que ela apagou antes de haver conta',
      () async {
    // A linha apagada antes do login chega pela adoção já `synced = 1`:
    // escapa do markForUpload, escapa do descarte de lápides, e nunca sai
    // pelo syncAll. Sem o filtro do "enviar tudo", este botão mandaria ao
    // servidor a data em que ela sangrou e depois apagou — para uma conta
    // que nunca teve cópia nenhuma daquele dia.
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'menstrual_days',
      local(
          revision: 2,
          deleted: true,
          note: '',
          dayKey: '2026-03-04',
          synced: 1),
    );
    await db.insert('menstrual_days',
        local(revision: 1, deleted: false, note: 'o que ficou', synced: 0));

    final resultado = await service.fullUpload();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    expect(servidor.linhasDe('menstrual_days').map((l) => l['day_key']),
        [dia],
        reason: 'a data do dia apagado não sai deste aparelho');
  });

  test('restaurar da nuvem devolve as páginas do ciclo, mesmo sem o sim',
      () async {
    // "Restaurar da nuvem" apaga o acervo inteiro e reinsere só o que veio do
    // servidor. A página do dia menstrual não sobe nunca — sem reconstruí-la
    // depois, o gesto que prometia trazer as coisas de volta apagaria o
    // registro do ciclo no Grimório de quem nem ligou o envio.
    await const MenstrualConsentStore().setSyncAllowed(uid, false);
    final db = await DatabaseHelper.instance.database;
    await MenstrualCycleRepository().save(MenstrualDay(
      userId: uid,
      day: DateTime(2026, 3, 14),
      mark: MenstrualMark.flow,
      note: 'manhã mais quieta',
    ));
    expect(
      await db.query('free_writings', where: 'id = ?', whereArgs: [idDaPagina]),
      hasLength(1),
    );

    final resultado = await service.fullDownload();
    expect(resultado.success, isTrue, reason: resultado.detailedError);

    final pagina = await db
        .query('free_writings', where: 'id = ?', whereArgs: [idDaPagina]);
    expect(pagina, hasLength(1),
        reason: 'a página é derivável da linha, e é por isso que ela não '
            'precisa do servidor');
    expect(pagina.single['content'], contains('manhã mais quieta'));
    expect((await db.query('menstrual_days')), hasLength(1),
        reason: 'a tabela do ciclo fica fora do apaga-e-baixa-tudo');
  });
}
