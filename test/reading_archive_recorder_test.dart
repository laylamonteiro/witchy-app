// A tiragem entra em "Meus Registros" sozinha, no instante em que sai — não
// há mais botão "Salvar nos Registros" para a Bruxa lembrar de tocar.
//
// O que este teste protege é a IDEMPOTÊNCIA disso: o gravador é chamado de
// novo quando o Conselheiro responde (e, no tarô, quando a mesma mesa é
// reaberta). Se cada chamada criasse uma linha, uma leitura interpretada
// apareceria duas vezes no acervo e contaria duas vezes na Leitura do Ciclo.
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
    await db.delete('rune_readings');
    await db.delete('tarot_readings');
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

  test('a sessão pode fornecer o dia original sem mudar a data ao reabrir', () async {
    final started = DateTime(2026, 9, 9);
    await recorder.record(
      readingId: 'daily-session-result',
      userId: userId,
      source: FreeWritingSource.tarot,
      createdAt: started,
      page: (title: 'Daily card', content: 'A fixed choice'),
    );
    await recorder.record(
      readingId: 'daily-session-result',
      userId: userId,
      source: FreeWritingSource.tarot,
      createdAt: DateTime(2026, 9, 10),
      page: (title: 'Daily card', content: 'With interpretation'),
    );
    final entry = await repository.getById('daily-session-result');
    expect(entry!.createdAt, started);
    expect(await todasAsEntradas(), hasLength(1));
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

  group('apagar a página apaga a consulta junto', () {
    // A página e a consulta são o mesmo registro, com o mesmo id — só a
    // página é visível. Se a linha da ferramenta sobrevivesse, o contador do
    // Ciclo não baixaria (é ela que conta) e a tiragem voltaria ao material
    // da IA pelo bloco `oracle`, com pergunta e resposta, depois de a pessoa
    // ter mandado apagar.
    test('a tiragem some da tabela da ferramenta', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('rune_readings', {
        'id': 'leitura-1',
        'user_id': userId,
        'question': 'Devo mudar?',
        'spread_type': 'single',
        'reading_data': '{}',
        'date': DateTime(2026, 8, 10).millisecondsSinceEpoch,
        'created_at': DateTime(2026, 8, 10).millisecondsSinceEpoch,
        'updated_at': DateTime(2026, 8, 10).millisecondsSinceEpoch,
        'synced': 0,
      });

      await recorder.discardReading(
        readingId: 'leitura-1',
        source: FreeWritingSource.runes,
      );

      expect(await db.query('rune_readings'), isEmpty);
    });

    test('quiromancia não tem consulta a apagar — e não estoura', () async {
      // Ela não tem tabela de histórico: a página É a leitura. Uma origem
      // fora do mapa tem de sair em silêncio, não com exceção.
      await recorder.discardReading(
        readingId: 'leitura-1',
        source: FreeWritingSource.palmistry,
      );
    });

    test('apagar uma tiragem não encosta na tiragem vizinha', () async {
      final db = await DatabaseHelper.instance.database;
      for (final id in ['mesa-1', 'mesa-2']) {
        await db.insert('tarot_readings', {
          'id': id,
          'user_id': userId,
          'question': 'O que preciso ver?',
          'spread_type': 'three_cards',
          'signature': 'sig-$id',
          'reading_data': '{}',
          'date': DateTime(2026, 8, 10).millisecondsSinceEpoch,
          'created_at': DateTime(2026, 8, 10).millisecondsSinceEpoch,
          'updated_at': DateTime(2026, 8, 10).millisecondsSinceEpoch,
          'synced': 0,
        });
      }

      await recorder.discardReading(
        readingId: 'mesa-1',
        source: FreeWritingSource.tarot,
      );

      final restantes = await db.query('tarot_readings');
      expect(restantes, hasLength(1));
      expect(restantes.single['id'], 'mesa-2');
    });
  });
}
