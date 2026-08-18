import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/services/cycle_reading_composer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

/// O agregador da Leitura do Ciclo: só registros DO período, trechos curtos
/// (nunca diários inteiros), contagens corretas e respeito às exclusões de
/// fontes íntimas.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'user-1';
  const uuid = Uuid();
  final periodStart = DateTime(2026, 8, 1);
  final periodEnd = DateTime(2026, 8, 30);
  final inPeriod = DateTime(2026, 8, 10).millisecondsSinceEpoch;
  final outOfPeriod = DateTime(2026, 7, 10).millisecondsSinceEpoch;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    for (final table in [
      'dreams',
      'gratitudes',
      'desires',
      'affirmations',
      'free_writings',
      'rune_readings',
      'oracle_readings',
      'pendulum_consultations',
      'ritual_logs',
      'guided_ritual_logs',
      'spells',
      'daily_checkins',
      'daily_magical_weather',
      'birth_charts',
    ]) {
      await db.delete(table);
    }
  });

  Future<void> seed(String table, Map<String, dynamic> values) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(table, {
      'id': uuid.v4(),
      'user_id': userId,
      'created_at': inPeriod,
      'updated_at': inPeriod,
      'synced': 0,
      ...values,
    });
  }

  Future<void> seedDream({int? createdAt, String content = 'sonhei'}) =>
      seed('dreams', {
        'title': 'Sonho',
        'content': content,
        'date': createdAt ?? inPeriod,
        'created_at': createdAt ?? inPeriod,
      });

  test('conta apenas registros do período', () async {
    await seedDream();
    await seedDream(createdAt: outOfPeriod);
    await seed('gratitudes', {
      'title': 'Grata',
      'content': 'pelo dia',
      'date': inPeriod,
    });
    await seed('rune_readings', {
      'question': 'Devo mudar?',
      'spread_type': 'single',
      'reading_data': '{}',
      'date': inPeriod,
    });

    final composer = CycleReadingComposer();
    final count = await composer.countPeriodRecords(
      userId: userId,
      start: periodStart,
      end: periodEnd,
    );
    expect(count, 3);
  });

  test('material traz trechos e contagens do período', () async {
    await seedDream(content: 'sonhei com o mar aberto');
    await seed('desires', {
      'title': 'Casa nova',
      'description': 'quero me mudar',
      'status': 'open',
    });
    await seed('pendulum_consultations', {
      'question': 'Devo mudar de casa?',
      'answer': 'yes',
      'date': inPeriod,
    });

    final material = await CycleReadingComposer().compose(
      userId: userId,
      start: periodStart,
      end: periodEnd,
    );

    expect(material.recordCount, 3);
    expect(material.json['recordCount'], 3);
    expect(material.json['dreamCount'], 1);
    final dreams = material.json['dreams'] as List;
    expect((dreams.first as Map)['excerpt'], 'sonhei com o mar aberto');
    final desires = material.json['desires'] as List;
    expect((desires.first as Map)['title'], 'Casa nova');
    final questions = material.json['oracleQuestions'] as List;
    expect(questions, ['Devo mudar de casa?']);
    // Fases da lua sempre presentes (cálculo local, sem mapa natal).
    final sky = material.json['sky'] as Map;
    expect(sky['moonPhases'], isNotEmpty);
  });

  test('trechos são curtos: nunca o diário inteiro', () async {
    await seedDream(content: 'palavra ${'muito longa ' * 40}fim');

    final material = await CycleReadingComposer().compose(
      userId: userId,
      start: periodStart,
      end: periodEnd,
    );
    final dreams = material.json['dreams'] as List;
    final excerpt = (dreams.first as Map)['excerpt'] as String;
    expect(excerpt.length, lessThanOrEqualTo(161));
    expect(excerpt, endsWith('…'));
  });

  test('fontes íntimas excluídas não entram no material (mas contam)',
      () async {
    await seedDream(content: 'segredo do sonho');
    await seed('free_writings', {
      'title': null,
      'content': 'reflexao intima',
      'source': 'free',
    });
    await seed('rune_readings', {
      'question': 'pergunta intima',
      'spread_type': 'single',
      'reading_data': '{}',
      'date': inPeriod,
    });

    final material = await CycleReadingComposer().compose(
      userId: userId,
      start: periodStart,
      end: periodEnd,
      options: const CycleReadingSourceOptions(
        includeDreams: false,
        includeFreeWriting: false,
        includeOracleQuestions: false,
      ),
    );

    // O texto íntimo não aparece em lugar nenhum do JSON.
    final encoded = material.compactJson;
    expect(encoded, isNot(contains('segredo do sonho')));
    expect(encoded, isNot(contains('reflexao intima')));
    expect(encoded, isNot(contains('pergunta intima')));
    // Mas o volume do período continua contado (aviso de leitura rasa).
    expect(material.recordCount, 3);
    expect(material.json['dreamCount'], 1);
  });

  test('registros de outra pessoa ficam de fora', () async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('dreams', {
      'id': uuid.v4(),
      'user_id': 'outra-pessoa',
      'title': 'Sonho alheio',
      'content': 'nada meu',
      'date': inPeriod,
      'created_at': inPeriod,
      'updated_at': inPeriod,
      'synced': 0,
    });

    final material = await CycleReadingComposer().compose(
      userId: userId,
      start: periodStart,
      end: periodEnd,
    );
    expect(material.recordCount, 0);
    expect(material.compactJson, isNot(contains('Sonho alheio')));
  });
}
