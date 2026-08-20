import 'dart:io';

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

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Base exclusiva DESTE arquivo: a suíte roda os arquivos de teste em
    // paralelo e o banco padrão compartilhado colide entre isolates
    // ("database is locked").
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('cycle_reading_composer_test').path,
    );
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
      'tarot_readings',
      'sigils',
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

  group('mapa de calor do seletor de período', () {
    test('agrupa por dia e ignora o que está fora da janela', () async {
      final dia10 = DateTime(2026, 8, 10, 9).millisecondsSinceEpoch;
      final dia10Tarde = DateTime(2026, 8, 10, 20).millisecondsSinceEpoch;
      final dia12 = DateTime(2026, 8, 12, 8).millisecondsSinceEpoch;

      await seedDream(createdAt: dia10);
      await seed('gratitudes', {
        'title': 'grata',
        'content': 'pelo dia',
        'date': dia10Tarde,
        'created_at': dia10Tarde,
      });
      await seed('sigils', {
        'intention': 'coragem',
        'image_path': '/tmp/s.png',
        'created_at': dia12,
      });
      // Fora da janela: não pode esquentar dia nenhum.
      await seedDream(createdAt: outOfPeriod);

      final mapa = await CycleReadingComposer().dailyRecordCounts(
        userId: userId,
        start: periodStart,
        end: periodEnd,
      );

      expect(mapa['2026-08-10'], 2);
      expect(mapa['2026-08-12'], 1);
      expect(mapa['2026-07-10'], isNull);
      // Dia sem registro não entra no mapa (o calendário desenha vazio).
      expect(mapa.containsKey('2026-08-11'), isFalse);
    });

    test('o mapa e a contagem total enxergam os mesmos registros', () async {
      // A regra que impede o calendário de mostrar um dia quente que a
      // contagem não vê: as duas leem a MESMA lista de tabelas.
      await seedDream(createdAt: DateTime(2026, 8, 3).millisecondsSinceEpoch);
      await seed('tarot_readings', {
        'question': 'e agora?',
        'spread_type': 'three_cards',
        'reading_data': '{}',
        // `date` é NOT NULL no schema, como nas outras tiragens.
        'date': DateTime(2026, 8, 5).millisecondsSinceEpoch,
        'created_at': DateTime(2026, 8, 5).millisecondsSinceEpoch,
      });
      await seed('spells', {
        'name': 'Feitiço',
        'purpose': 'proteger a casa',
        'type': 'protecao',
        'category': 'protecao',
        'steps': '[]',
        'is_preloaded': 0,
        'created_at': DateTime(2026, 8, 7).millisecondsSinceEpoch,
      });
      // Pré-carregado não é registro da pessoa: fica fora dos DOIS.
      await seed('spells', {
        'name': 'Ancestral',
        'purpose': 'veio no app',
        'type': 'protecao',
        'category': 'protecao',
        'steps': '[]',
        'is_preloaded': 1,
        'created_at': DateTime(2026, 8, 8).millisecondsSinceEpoch,
      });

      final composer = CycleReadingComposer();
      final mapa = await composer.dailyRecordCounts(
        userId: userId,
        start: periodStart,
        end: periodEnd,
      );
      final total = await composer.countPeriodRecords(
        userId: userId,
        start: periodStart,
        end: periodEnd,
      );

      expect(mapa.values.fold<int>(0, (a, b) => a + b), total);
      expect(total, 3);
      expect(mapa.containsKey('2026-08-08'), isFalse);
    });

    test('registros de outra pessoa não esquentam o calendário', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('gratitudes', {
        'id': uuid.v4(),
        'user_id': 'outra-pessoa',
        'title': 'grata',
        'content': 'texto',
        'date': inPeriod,
        'created_at': inPeriod,
        'updated_at': inPeriod,
        'synced': 0,
      });

      final mapa = await CycleReadingComposer().dailyRecordCounts(
        userId: userId,
        start: periodStart,
        end: periodEnd,
      );
      expect(mapa, isEmpty);
    });
  });

  test('a contagem da tela bate com a que a leitura usa', () async {
    // Eram duas contas separadas: countPeriodRecords (o número que a tela
    // mostra, e que decide "leitura rasa") e o recordCount somado dentro
    // do compose. As afirmações criadas entravam só na segunda, então a
    // tela dizia menos do que a análise realmente tinha. Uma fonte nova
    // que esqueça a lista compartilhada quebra este teste.
    await seedDream();
    await seed('gratitudes', {
      'title': 'Grata',
      'content': 'pelo dia',
      'date': inPeriod,
    });
    await seed('affirmations', {
      'text': 'Eu confio no meu tempo',
      'category': 'confianca',
      'is_preloaded': 0,
      'is_favorite': 0,
    });
    await seed('tarot_readings', {
      'question': 'o que preciso ver?',
      'spread_type': 'single',
      'reading_data': '{}',
      'date': inPeriod,
    });
    // Pré-carregada não é registro dela: fora das DUAS contas.
    await seed('affirmations', {
      'text': 'Veio no app',
      'category': 'confianca',
      'is_preloaded': 1,
      'is_favorite': 0,
    });

    final composer = CycleReadingComposer();
    final daTela = await composer.countPeriodRecords(
      userId: userId,
      start: periodStart,
      end: periodEnd,
    );
    final material = await composer.compose(
      userId: userId,
      start: periodStart,
      end: periodEnd,
    );

    expect(daTela, material.recordCount);
    expect(daTela, 4);
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
    final oracle = material.json['oracle'] as List;
    final pend = oracle.first as Map;
    expect(pend['question'], 'Devo mudar de casa?');
    expect(pend['answer'], 'yes');
    // Fases da lua sempre presentes (cálculo local, sem mapa natal).
    final sky = material.json['sky'] as Map;
    expect(sky['moonPhases'], isNotEmpty);
  });

  test('tiragem de tarô entra na leitura (conta e aparece no oracle)',
      () async {
    await seed('tarot_readings', {
      'question': 'O que preciso ver?',
      'spread_type': 'three_cards',
      'signature': 'sig-1',
      'reading_data':
          '{"cards":[{"name":"A Lua"}],"interpretation":"olhe o que se esconde"}',
      'date': inPeriod,
    });

    final material = await CycleReadingComposer().compose(
      userId: userId,
      start: periodStart,
      end: periodEnd,
    );

    expect(material.recordCount, 1);
    expect(material.json['divinationCount'], 1);
    final oracle = material.json['oracle'] as List;
    final tarot = oracle.firstWhere((d) => (d as Map)['tool'] == 'tarot') as Map;
    expect(tarot['question'], 'O que preciso ver?');
    expect(tarot['answer'], 'olhe o que se esconde');
  });

  test('linha do tempo sai em ordem, com a lua de cada dia', () async {
    final dia1 = DateTime(2026, 8, 3).millisecondsSinceEpoch;
    final dia2 = DateTime(2026, 8, 9).millisecondsSinceEpoch;
    final dia3 = DateTime(2026, 8, 20).millisecondsSinceEpoch;
    // Semeados FORA de ordem: a ordenação é responsabilidade do composer.
    await seed('gratitudes', {
      'title': 'Gratidão tardia',
      'content': 'pelo fim do mês',
      'date': dia3,
      'created_at': dia3,
    });
    await seedDream(createdAt: dia1, content: 'o mar');
    await seed('sigils', {
      'intention': 'coragem para mudar',
      // image_path é NOT NULL no schema: todo sigilo tem o desenho salvo.
      'image_path': '/tmp/sigilo.png',
      'created_at': dia2,
    });

    final material = await CycleReadingComposer().compose(
      userId: userId,
      start: periodStart,
      end: periodEnd,
    );

    final timeline = material.json['timeline'] as List;
    expect(timeline.length, 3);
    expect(
      timeline.map((m) => (m as Map)['kind']).toList(),
      ['dream', 'sigil', 'gratitude'],
    );
    expect(
      timeline.map((m) => (m as Map)['date']).toList(),
      ['2026-08-03', '2026-08-09', '2026-08-20'],
    );
    // A nota vem do próprio registro (título/intenção), curta.
    expect((timeline[1] as Map)['note'], 'coragem para mudar');

    // E cada dia com registro tem a lua daquele dia.
    final moonByDay = material.json['moonByDay'] as Map;
    expect(moonByDay.keys.toSet(),
        {'2026-08-03', '2026-08-09', '2026-08-20'});
    expect((moonByDay['2026-08-03'] as Map)['phase'], isNotEmpty);
  });

  test('exclusão de fontes íntimas também tira da linha do tempo', () async {
    await seedDream(content: 'segredo');
    await seed('gratitudes', {
      'title': 'Grata',
      'content': 'pelo dia',
      'date': inPeriod,
    });

    final material = await CycleReadingComposer().compose(
      userId: userId,
      start: periodStart,
      end: periodEnd,
      options: const CycleReadingSourceOptions(includeDreams: false),
    );

    final timeline = material.json['timeline'] as List;
    expect(timeline.map((m) => (m as Map)['kind']), isNot(contains('dream')));
    expect(timeline.map((m) => (m as Map)['kind']), contains('gratitude'));
    // Mas o sonho continua contando como registro do período.
    expect(material.recordCount, 2);
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
        includeJournals: false,
        includeDivination: false,
        includePractice: false,
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
