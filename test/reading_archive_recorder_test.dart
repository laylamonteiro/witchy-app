/// A tiragem entra em "Meus Registros" sozinha, no instante em que sai — não
/// há mais botão "Salvar nos Registros" para a Bruxa lembrar de tocar.
///
/// O que este teste protege é a IDEMPOTÊNCIA disso: o gravador é chamado de
/// novo quando o Conselheiro responde (e, no tarô, quando a mesma mesa é
/// reaberta). Se cada chamada criasse uma linha, uma leitura interpretada
/// apareceria duas vezes no acervo e contaria duas vezes na Leitura do Ciclo.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/free_writing_model.dart';
import 'package:grimorio_de_bolso/features/diary/data/repositories/free_writing_repository.dart';
import 'package:grimorio_de_bolso/features/diary/data/services/reading_archive_recorder.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'user-1';
  final recorder = ReadingArchiveRecorder();
  final repository = FreeWritingRepository();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Base exclusiva DESTE arquivo: a suíte roda os arquivos em paralelo e o
    // caminho fixo do DatabaseHelper colide entre isolates.
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('reading_archive_recorder_test').path,
    );
  });

  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('free_writings');
  });

  Future<List<Map<String, Object?>>> todasAsEntradas() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('free_writings');
  }

  test('a leitura vira página do acervo, com o id da própria leitura',
      () async {
    await recorder.record(
      readingId: 'leitura-1',
      userId: userId,
      source: FreeWritingSource.runes,
      page: (title: 'Runas — Três Runas', content: '✦ Sua pergunta\nDevo ir?'),
    );

    final entrada = await repository.getById('leitura-1');
    expect(entrada, isNotNull);
    expect(entrada!.source, FreeWritingSource.runes);
    expect(entrada.title, 'Runas — Três Runas');
    expect(entrada.content, contains('Devo ir?'));
    expect(entrada.userId, userId);
  });

  test('o conselho reescreve a MESMA página, sem criar uma segunda', () async {
    const page = (title: 'Runas — Três Runas', content: 'só a tiragem');
    await recorder.record(
      readingId: 'leitura-1',
      userId: userId,
      source: FreeWritingSource.runes,
      page: page,
    );
    await recorder.record(
      readingId: 'leitura-1',
      userId: userId,
      source: FreeWritingSource.runes,
      page: (title: page.title, content: 'só a tiragem\n\n✦ Conselheiro\nvá'),
    );

    expect(await todasAsEntradas(), hasLength(1));
    final entrada = await repository.getById('leitura-1');
    expect(entrada!.content, contains('Conselheiro'));
  });

  test('regravar preserva o instante da TIRAGEM, não o da reescrita',
      () async {
    // É por created_at que a Leitura do Ciclo põe a leitura no dia certo da
    // linha do tempo: o conselho que chega horas depois não pode mudá-lo.
    final db = await DatabaseHelper.instance.database;
    final tiragem = DateTime(2026, 8, 10, 21, 30).millisecondsSinceEpoch;
    await db.insert('free_writings', {
      'id': 'leitura-1',
      'user_id': userId,
      'title': 'Runas — Três Runas',
      'content': 'só a tiragem',
      'source': FreeWritingSource.runes,
      'created_at': tiragem,
      'updated_at': tiragem,
      'synced': 0,
    });

    await recorder.record(
      readingId: 'leitura-1',
      userId: userId,
      source: FreeWritingSource.runes,
      page: (title: 'Runas — Três Runas', content: 'com o conselho'),
    );

    final entrada = await repository.getById('leitura-1');
    expect(entrada!.createdAt.millisecondsSinceEpoch, tiragem);
    expect(entrada.content, 'com o conselho');
  });
}
