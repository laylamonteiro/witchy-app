// O dia que ela registra na roda do Ciclo Menstrual vira uma página do
// Grimório, em "Meus Registros" — é o pedido da dona: todo registro é
// registrado no Grimório.
//
// O que este arquivo protege são as quatro promessas que a página faz e que
// nenhuma tela consegue garantir sozinha:
//
// 1. IDEMPOTÊNCIA — corrigir o dia reescreve a MESMA página. Se cada
//    gravação criasse uma linha, um dia corrigido três vezes apareceria três
//    vezes no acervo, e três vezes em qualquer contagem futura;
// 2. A DATA É O DIA OBSERVADO — o cartão do acervo mostra `updated_at` e a
//    lista ordena por ele. Com o instante da digitação, um dia de março
//    preenchido em abril apareceria como abril e subiria ao topo;
// 3. A PÁGINA NÃO SAI DO APARELHO — a linha nasce e permanece carimbada
//    `synced = 1`, que é o único sinal que a varredura de `free_writings`
//    respeita;
// 4. A PÁGINA É FUNÇÃO DA LINHA — dia apagado, página apagada; conta
//    apagada, páginas apagadas. Um espelho órfão contaria no Grimório o que
//    ela pediu para esquecer.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/menstrual_cycle_schema.dart';
import 'package:grimorio_de_bolso/core/services/data_export_service.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/free_writing_model.dart';
import 'package:grimorio_de_bolso/features/diary/data/repositories/free_writing_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/services/menstrual_archive_recorder.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // A página é "assada" no idioma do conteúdo, como as páginas das leituras.
  final l10n = lookupAppLocalizations(ContentLocale.instance.locale);

  const user = 'cycle-archive-user';
  const other = 'another-account';
  late MenstrualCycleRepository repo;

  setUpAll(() async {
    // Base exclusiva DESTE arquivo: a suíte roda os arquivos em paralelo e o
    // caminho fixo do DatabaseHelper colide entre isolates.
    final dir =
        await Directory.systemTemp.createTemp('menstrual_archive_recorder');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.delete(MenstrualCycleSchema.table);
    await db.delete('free_writings');
    repo = MenstrualCycleRepository();
  });

  MenstrualDay dia(
    int diaDoMes, {
    MenstrualMark mark = MenstrualMark.flow,
    MenstrualFlowLevel? flow,
    List<String> symptoms = const [],
    String note = '',
    String owner = user,
  }) =>
      MenstrualDay(
        userId: owner,
        day: DateTime(2026, 3, diaDoMes),
        mark: mark,
        flow: flow,
        symptoms: symptoms,
        note: note,
      );

  Future<List<Map<String, Object?>>> paginas() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('free_writings',
        where: 'source = ?', whereArgs: [FreeWritingSource.menstrual]);
  }

  test('o dia registrado vira UMA página, e corrigi-lo reescreve a mesma',
      () async {
    await repo.save(dia(9, mark: MenstrualMark.start));
    var todas = await paginas();
    expect(todas, hasLength(1));
    expect(
      todas.first['id'],
      MenstrualArchiveRecorder.pageId(userId: user, dayKey: '2026-03-09'),
      reason: 'O id é derivado do registro de origem — é ele a idempotência',
    );

    await repo.save(dia(9,
        mark: MenstrualMark.start,
        flow: MenstrualFlowLevel.heavy,
        symptoms: const ['cramps'],
        note: 'um recado'));
    todas = await paginas();
    expect(todas, hasLength(1), reason: 'Corrigir não cria uma segunda página');
    final conteudo = todas.first['content'] as String;
    expect(todas.first['title'], l10n.menstrualArchiveTitle,
        reason: 'O título é o mesmo em toda página do ciclo: marca, fluxo e '
            'sintomas ficam no corpo, que o cartão do acervo não mostra');
    expect(conteudo, contains(l10n.menstrualSymptomCramps),
        reason: 'O sintoma aparece pelo rótulo, nunca pelo código');
    expect(conteudo, isNot(contains('cramps')));
    expect(conteudo, contains('um recado'));
  });

  test('as duas datas da página são o dia OBSERVADO, não o da digitação',
      () async {
    await repo.save(dia(9));
    final pagina = (await paginas()).single;
    final observado = DateTime(2026, 3, 9).millisecondsSinceEpoch;
    expect(pagina['created_at'], observado);
    expect(pagina['updated_at'], observado,
        reason: 'O cartão do acervo mostra updated_at e a lista ordena por ele: '
            'um registro retroativo não pode subir ao topo como se fosse de hoje');
  });

  test('a página nasce fora do alcance da varredura, e continua fora',
      () async {
    await repo.save(dia(9, note: 'meu'));
    expect((await paginas()).single['synced'], 1);

    // O que um toque no formulário do acervo faria: `copyWith` devolve
    // `synced: false`, e sem o recarimbo do repositório a varredura de
    // `free_writings` levaria esta linha para a nuvem na volta seguinte.
    final acervo = FreeWritingRepository();
    final entrada = await acervo.getById(
        MenstrualArchiveRecorder.pageId(userId: user, dayKey: '2026-03-09'));
    await acervo.update(entrada!.copyWith(content: 'editado à mão'));
    expect((await paginas()).single['synced'], 1);
  });

  test('apagar o dia tira a página, e apagar tudo tira só as da conta',
      () async {
    await repo.save(dia(9));
    await repo.save(dia(10));
    await repo.save(dia(11, owner: other));
    expect(await paginas(), hasLength(3));

    await repo.remove(userId: user, day: DateTime(2026, 3, 9));
    expect(
      (await paginas()).map((row) => row['user_id']).toList(),
      [user, other],
      reason: 'O dia apagado não pode continuar com vitrine no Grimório',
    );

    await repo.purge(user);
    final restantes = await paginas();
    expect(restantes, hasLength(1));
    expect(restantes.single['user_id'], other,
        reason: 'Apagar os registros de uma conta não toca na outra');
  });

  test('a anotação entra na página, e apagá-la a tira de lá', () async {
    await repo.save(dia(9, note: 'devagar'));
    var conteudo = (await paginas()).single['content'] as String;
    expect(conteudo, contains('devagar'));

    await repo.save(dia(9));
    conteudo = (await paginas()).single['content'] as String;
    expect(conteudo, isNot(contains('devagar')),
        reason: 'A página conta o dia como ele está agora, não como esteve');
  });

  test('a adoção dos dados anônimos não deixa espelho órfão nem pendente',
      () async {
    // O que `claimLegacyData` faz ao entrar na conta pela primeira vez: troca
    // o `user_id` de toda linha de `free_writings` que era de `local_user` e
    // grava `synced = 0` — sem tocar no `id`. A página do dia fica, então,
    // com a conta nova e a CHAVE VELHA, e pendente para a varredura.
    final db = await DatabaseHelper.instance.database;
    await db.insert('free_writings', {
      'id': MenstrualArchiveRecorder.pageId(
          userId: 'local_user', dayKey: '2026-03-09'),
      'user_id': user,
      'title': 'Registro do ciclo',
      'content': '✦ escrito antes da conta',
      'source': FreeWritingSource.menstrual,
      'created_at': DateTime(2026, 3, 9).millisecondsSinceEpoch,
      'updated_at': DateTime(2026, 3, 9).millisecondsSinceEpoch,
      'synced': 0,
    });

    // Ler o acervo repõe o carimbo: `synced = 0` é o que a varredura recolhe.
    await FreeWritingRepository().getAll(user);
    expect((await paginas()).single['synced'], 1);

    // Gravar o mesmo dia de novo não pode deixar DUAS páginas dele.
    await repo.save(dia(9, note: 'depois da conta'));
    expect(await paginas(), hasLength(1));
    expect((await paginas()).single['content'], contains('depois da conta'));

    // E apagar o dia alcança a página, com chave nova ou velha.
    await repo.remove(userId: user, day: DateTime(2026, 3, 9));
    expect(await paginas(), isEmpty,
        reason: 'Um espelho órfão contaria no Grimório o que ela apagou');
  });

  test('o backup leva o dia uma vez só: a linha, não o espelho', () async {
    await repo.save(dia(9, note: 'meu relato'));
    final backup = jsonDecode(await DataExportService.instance.buildJson())
        as Map<String, dynamic>;

    final acervo = (backup['free_writings'] as List).cast<Map>();
    expect(
      acervo.where((row) => row['source'] == FreeWritingSource.menstrual),
      isEmpty,
      reason: 'A página é derivável da linha; exportar as duas escreveria o '
          'mesmo dia duas vezes no arquivo que ela leva embora',
    );
    final dias = (backup[MenstrualCycleSchema.table] as List).cast<Map>();
    expect(dias.where((row) => row['note'] == 'meu relato'), hasLength(1));
  });
}
