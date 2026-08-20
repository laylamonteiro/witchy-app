import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../astrology/data/models/enums.dart';
import '../../../astrology/data/repositories/astrology_repository.dart';
import '../../../astrology/data/services/transit_calculator.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../grimoire/data/models/spell_model.dart'
    show MoonPhase, MoonPhaseExtension;
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../../your_day/data/daily_checkin_repository.dart';
import '../models/cycle_reading_model.dart';

/// Fontes que a pessoa pode EXCLUIR da análise (intimidade em primeiro
/// lugar: a tela de compra oferece estes desligamentos antes de enviar
/// qualquer coisa para a IA).
class CycleReadingSourceOptions {
  /// Sonhos (conteúdo íntimo por definição).
  final bool includeDreams;

  /// Escrita livre / reflexões.
  final bool includeFreeWriting;

  /// Perguntas feitas a runas e pêndulo.
  final bool includeOracleQuestions;

  const CycleReadingSourceOptions({
    this.includeDreams = true,
    this.includeFreeWriting = true,
    this.includeOracleQuestions = true,
  });
}

/// O material compacto do período: o JSON enviado à IA (que NARRA, nunca
/// calcula) e as contagens usadas pela tela de compra e pelo gatilho de
/// oferta.
class CycleReadingMaterial {
  /// JSON compacto do período (trechos curtos e contagens, nunca diários
  /// inteiros — controla tokens e exposição de dados).
  final Map<String, dynamic> json;

  /// Total de registros feitos pela pessoa no período (a matéria-prima da
  /// leitura). Menos de [CycleReadingComposer.minRecordsForDepth] = avisar
  /// ANTES da compra que a leitura sairá rasa.
  final int recordCount;

  const CycleReadingMaterial({required this.json, required this.recordCount});

  String get compactJson => jsonEncode(json);
}

/// Monta o retrato do período a partir do que a pessoa registrou no app +
/// fatos do céu calculados NO APARELHO (trânsitos sobre o mapa natal e
/// fases da lua). A IA recebe fatos prontos e narra — mesma filosofia dos
/// docs de acuracidade do mapa astral.
class CycleReadingComposer {
  CycleReadingComposer({
    Database? db,
    AstrologyRepository? astrology,
    TransitCalculator? transits,
  })  : _dbOverride = db,
        _astrology = astrology ?? AstrologyRepository(),
        _transits = transits ?? TransitCalculator();

  final Database? _dbOverride;
  final AstrologyRepository _astrology;
  final TransitCalculator _transits;

  /// Abaixo disto a leitura da lunação sai rasa — a tela de compra avisa
  /// antes de cobrar (confiança vale mais que uma venda).
  static const int minRecordsForDepth = 5;

  /// O mesmo aviso para a semana: sete dias rendem menos que uma lunação, e
  /// exigir o mesmo volume acusaria de rasa quase toda semana honesta.
  static const int minRecordsForWeek = 3;

  /// Mínimo de registros do período para a leitura não sair rasa.
  static int minRecordsFor(String periodType) =>
      periodType == CycleReadingPeriodType.week
          ? minRecordsForWeek
          : minRecordsForDepth;

  /// Teto de itens citados por fonte (tokens + intimidade).
  static const int _maxItemsPerSource = 6;

  /// Teto de caracteres de cada trecho citado.
  static const int _maxExcerptLength = 160;

  Future<Database> get _db async =>
      _dbOverride ?? await DatabaseHelper.instance.database;

  /// Contagem barata dos registros do período — usada pelo card de oferta
  /// no Seu Dia ("Sua lunação rendeu {N} registros") e pelo aviso de
  /// leitura rasa, sem montar o material inteiro.
  Future<int> countPeriodRecords({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await _db;
    const tables = [
      'dreams',
      'gratitudes',
      'desires',
      'free_writings',
      'rune_readings',
      'oracle_readings',
      'pendulum_consultations',
      'ritual_logs',
      'guided_ritual_logs',
      'spells',
      'sigils',
    ];
    var total = 0;
    for (final table in tables) {
      final timeColumn =
          table.endsWith('_logs') ? 'completed_at' : 'created_at';
      // Relatórios de leituras anteriores não são "registros da pessoa" —
      // sem o filtro, a própria leitura inflaria o ciclo seguinte.
      final preloadedFilter = switch (table) {
        'spells' => ' AND is_preloaded = 0',
        'free_writings' =>
          " AND source != '${FreeWritingSource.cycleReading}'",
        _ => '',
      };
      try {
        final rows = await db.rawQuery(
          'SELECT COUNT(*) AS total FROM $table '
          'WHERE user_id = ? AND $timeColumn >= ? AND $timeColumn < ?'
          '$preloadedFilter',
          [
            userId,
            start.millisecondsSinceEpoch,
            end.millisecondsSinceEpoch,
          ],
        );
        total += (rows.first['total'] as int?) ?? 0;
      } catch (_) {
        // Tabela ausente numa base antiga: segue com as demais.
      }
    }
    return total;
  }

  /// Monta o material completo do período.
  Future<CycleReadingMaterial> compose({
    required String userId,
    required DateTime start,
    required DateTime end,
    String periodType = CycleReadingPeriodType.lunation,
    CycleReadingSourceOptions options = const CycleReadingSourceOptions(),
  }) async {
    final db = await _db;
    final json = <String, dynamic>{
      'period': {
        'start': _dayKey(start),
        'end': _dayKey(end),
        'type': periodType,
      },
    };
    var recordCount = 0;

    Future<List<Map<String, Object?>>> rowsOf(
      String table, {
      String timeColumn = 'created_at',
      String? extraWhere,
      String orderBy = 'created_at ASC',
    }) async {
      try {
        return await db.rawQuery(
          'SELECT * FROM $table WHERE user_id = ? '
          'AND $timeColumn >= ? AND $timeColumn < ?'
          '${extraWhere == null ? '' : ' AND $extraWhere'} '
          'ORDER BY $orderBy',
          [
            userId,
            start.millisecondsSinceEpoch,
            end.millisecondsSinceEpoch,
          ],
        );
      } catch (_) {
        return const [];
      }
    }

    // ===== Sonhos =====
    final dreams = await rowsOf('dreams');
    recordCount += dreams.length;
    if (options.includeDreams && dreams.isNotEmpty) {
      json['dreams'] = [
        for (final row in dreams.take(_maxItemsPerSource))
          {
            'date': _dayOf(row['date'] ?? row['created_at']),
            'title': _excerpt(row['title']),
            if (_isNotBlank(row['feeling'])) 'feeling': _excerpt(row['feeling']),
            'excerpt': _excerpt(row['content']),
            if (_isNotBlank(row['interpretation']))
              'meaning': _excerpt(row['interpretation']),
          },
      ];
    }
    json['dreamCount'] = dreams.length;

    // ===== Gratidões =====
    final gratitudes = await rowsOf('gratitudes');
    recordCount += gratitudes.length;
    if (gratitudes.isNotEmpty) {
      json['gratitudes'] = [
        for (final row in gratitudes.take(_maxItemsPerSource))
          {
            'date': _dayOf(row['date'] ?? row['created_at']),
            'excerpt': _excerpt(
              _isNotBlank(row['title']) ? row['title'] : row['content'],
            ),
          },
      ];
    }

    // ===== Desejos (manifestações) =====
    final desires = await rowsOf('desires');
    recordCount += desires.length;
    if (desires.isNotEmpty) {
      json['desires'] = [
        for (final row in desires.take(_maxItemsPerSource))
          {
            'title': _excerpt(row['title']),
            'status': '${row['status']}',
            if (_isNotBlank(row['description']))
              'excerpt': _excerpt(row['description']),
            if (_isNotBlank(row['evolution']))
              'evolution': _excerpt(row['evolution']),
          },
      ];
    }

    // ===== Afirmações da pessoa (autoimagem desejada) =====
    // As que ela CRIOU (is_preloaded=0) contam como registro do período e
    // são as mais reveladoras; somam-se as favoritas (mesmo pré-carregadas),
    // porque favoritar também é uma escolha que diz algo sobre ela.
    try {
      final createdAffirmations = await rowsOf(
        'affirmations',
        extraWhere: 'is_preloaded = 0',
      );
      recordCount += createdAffirmations.length;
      final favorites = await db.rawQuery(
        'SELECT text FROM affirmations WHERE user_id = ? AND is_favorite = 1 '
        'ORDER BY updated_at DESC LIMIT ?',
        [userId, _maxItemsPerSource],
      );
      final texts = <String>{
        for (final row in createdAffirmations.take(_maxItemsPerSource))
          if (_isNotBlank(row['text'])) _excerpt(row['text']),
        for (final row in favorites)
          if (_isNotBlank(row['text'])) _excerpt(row['text']),
      };
      if (texts.isNotEmpty) {
        json['affirmations'] = texts.take(_maxItemsPerSource).toList();
      }
    } catch (_) {}

    // ===== Sigilos (a intenção mágica desenhada — pura personalização) =====
    final sigils = await rowsOf('sigils');
    recordCount += sigils.length;
    if (sigils.isNotEmpty) {
      json['sigils'] = [
        for (final row in sigils.take(_maxItemsPerSource))
          if (_isNotBlank(row['intention'])) _excerpt(row['intention']),
      ];
    }

    // ===== Escrita livre + leituras arquivadas =====
    final writings = (await rowsOf('free_writings'))
        .where((row) =>
            (row['source'] ?? 'free') != FreeWritingSource.cycleReading)
        .toList();
    recordCount += writings.length;
    final reflections = writings
        .where((row) => (row['source'] ?? 'free') == FreeWritingSource.free)
        .toList();
    final archivedReadings = writings
        .where((row) =>
            FreeWritingSource.readings.contains(row['source'] ?? ''))
        .toList();
    if (options.includeFreeWriting && reflections.isNotEmpty) {
      json['freeWriting'] = [
        for (final row in reflections.take(_maxItemsPerSource))
          {
            'date': _dayOf(row['created_at']),
            'excerpt': _excerpt(row['content']),
          },
      ];
    }
    if (archivedReadings.isNotEmpty) {
      // O que a pessoa GUARDOU no acervo (tarot, oráculo, runas, quiromancia
      // salvos): agora vai o conteúdo real da leitura, não só o título — é
      // dele que sai a especificidade.
      json['savedReadings'] = [
        for (final row in archivedReadings.take(_maxItemsPerSource))
          {
            'type': '${row['source']}',
            if (_isNotBlank(row['title'])) 'title': _excerpt(row['title']),
            'excerpt': _excerpt(row['content']),
          },
      ];
    }

    // ===== Perguntas feitas ao oráculo (as dúvidas reais do período) =====
    final runeReadings = await rowsOf('rune_readings');
    final pendulumConsults = await rowsOf('pendulum_consultations');
    final oracleReadings = await rowsOf('oracle_readings');
    recordCount +=
        runeReadings.length + pendulumConsults.length + oracleReadings.length;
    if (options.includeOracleQuestions) {
      // Não só a pergunta — a tiragem inteira: a runa/carta e o que ela
      // respondeu. É a conversa real da pessoa com o oráculo no período.
      final divinations = <Map<String, dynamic>>[
        for (final row in runeReadings.take(_maxItemsPerSource))
          {
            'tool': 'runes',
            if (_isNotBlank(row['question']))
              'question': _excerpt(row['question']),
            if (_readingInterpretation(row['reading_data']) case final m?)
              'answer': m,
          },
        for (final row in pendulumConsults.take(_maxItemsPerSource))
          {
            'tool': 'pendulum',
            if (_isNotBlank(row['question']))
              'question': _excerpt(row['question']),
            if (_isNotBlank(row['answer'])) 'answer': _excerpt(row['answer']),
          },
        for (final row in oracleReadings.take(_maxItemsPerSource))
          {
            'tool': 'oracle-cards',
            if (_readingInterpretation(row['reading_data']) case final m?)
              'answer': m,
          },
      ].where((d) => d.length > 1).toList();
      if (divinations.isNotEmpty) {
        json['oracle'] = divinations;
      }
    }
    json['divinationCount'] =
        runeReadings.length + pendulumConsults.length + oracleReadings.length;

    // ===== Prática mágica efetiva =====
    final ritualLogs = await rowsOf(
      'ritual_logs',
      timeColumn: 'completed_at',
      orderBy: 'completed_at ASC',
    );
    final guidedLogs = await rowsOf(
      'guided_ritual_logs',
      timeColumn: 'completed_at',
      orderBy: 'completed_at ASC',
    );
    final spells = await rowsOf(
      'spells',
      extraWhere: 'is_preloaded = 0',
    );
    recordCount += ritualLogs.length + guidedLogs.length + spells.length;
    json['practice'] = {
      'ritualLogs': ritualLogs.length,
      'guidedRituals': guidedLogs.length,
      'spellsCreated': spells.length,
      // Os feitiços que ela CRIOU no período (nome + propósito) — o que a
      // magia dela buscou, não só quantos foram.
      if (spells.isNotEmpty)
        'spells': [
          for (final row in spells.take(_maxItemsPerSource))
            {
              'name': _excerpt(row['name']),
              if (_isNotBlank(row['purpose'])) 'purpose': _excerpt(row['purpose']),
            },
        ],
      // Notas que ela deixou nos ritos concluídos (quando houver).
      if ([...ritualLogs, ...guidedLogs].any((r) => _isNotBlank(r['notes'])))
        'ritualNotes': [
          for (final row in [...ritualLogs, ...guidedLogs])
            if (_isNotBlank(row['notes'])) _excerpt(row['notes']),
        ].take(_maxItemsPerSource).toList(),
    };

    // ===== Constância (check-ins) e estudo =====
    try {
      final checkinRows = await db.rawQuery(
        'SELECT date FROM daily_checkins WHERE user_id = ? '
        'AND date >= ? AND date < ?',
        [userId, _dayKey(start), _dayKey(end)],
      );
      json['practiceDays'] = checkinRows.length;
    } catch (_) {}
    json['streak'] = await DailyCheckinRepository().currentStreak(userId);

    final lessons = await rowsOf(
      'learning_progress',
      timeColumn: 'completed_at',
      orderBy: 'completed_at ASC',
    );
    if (lessons.isNotEmpty) {
      json['learning'] = {'lessonsCompleted': lessons.length};
    }

    // ===== Clima mágico já narrado (só o mais recente é guardado) =====
    try {
      final weather = await db.rawQuery(
        'SELECT date, ai_generated_text FROM daily_magical_weather '
        'WHERE user_id = ? AND date >= ? AND date < ? '
        'ORDER BY date DESC LIMIT 1',
        [userId, _dayKey(start), _dayKey(end)],
      );
      if (weather.isNotEmpty) {
        json['latestMagicalWeather'] = {
          'date': '${weather.first['date']}',
          'excerpt': _excerpt(weather.first['ai_generated_text']),
        };
      }
    } catch (_) {}

    // ===== O céu do período (calculado no aparelho; a IA só narra) =====
    json['sky'] = await _skyFacts(userId, start, end);

    json['recordCount'] = recordCount;
    return CycleReadingMaterial(json: json, recordCount: recordCount);
  }

  /// Fatos do céu: fases da lua do período + trânsitos sobre o mapa natal.
  /// Best-effort: sem mapa (ou sem efemérides) a leitura segue só com a
  /// lua — nunca derruba a geração paga.
  Future<Map<String, dynamic>> _skyFacts(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final sky = <String, dynamic>{};

    // Fases da lua do período: as viradas de fase, dia a dia.
    final phases = <Map<String, String>>[];
    var cursor = DateTime(start.year, start.month, start.day, 12);
    MoonPhase? previous;
    while (cursor.isBefore(end)) {
      final phase = LunarProvider.phaseOn(cursor);
      if (phase != previous) {
        phases.add({'phase': phase.displayName, 'from': _dayKey(cursor)});
        previous = phase;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    sky['moonPhases'] = phases;

    try {
      final chart = await _astrology.getBirthChart(userId);
      if (chart == null) return sky;

      sky['natal'] = {
        'sun': chart.sun.sign.displayName,
        'moon': chart.moon.sign.displayName,
        // unknownBirthTime: sem casas/ascendente — a IA é instruída a não
        // inventar o que não foi calculado.
        if (!chart.unknownBirthTime && chart.ascendant != null)
          'ascendant': chart.ascendant!.sign.displayName,
        'unknownBirthTime': chart.unknownBirthTime,
      };

      // Trânsitos de referência do período (limitado ao presente: o
      // relatório fala do ciclo vivido, não do futuro distante).
      final now = DateTime.now();
      final reference = end.isBefore(now) ? end : now;
      // Conectores em inglês de propósito: são fatos para a IA (que narra
      // no idioma do app), e o scanner de PT hardcoded vale para lib/.
      final transits = await _transits.calculateTransits(reference);
      sky['transits'] = [
        for (final transit in transits)
          if (transit.planet != Planet.moon)
            '${transit.planet.displayName} in ${transit.sign.displayName}'
            '${transit.isRetrograde ? ' (retrograde)' : ''}',
      ];

      final aspects = await _transits.calculateTransitAspects(transits, chart);
      sky['aspects'] = [
        for (final aspect in aspects
            .where((a) => a.transitPlanet != Planet.moon)
            .take(8))
          '${aspect.transitPlanet.displayName} '
          '${aspect.aspectType.displayName} '
          '${aspect.natalPlanet.displayName} natal '
          '(orb ${aspect.orb.toStringAsFixed(1)} deg)',
      ];
    } catch (e) {
      debugPrint('CycleReadingComposer: céu indisponível ($e)');
    }
    return sky;
  }

  static bool _isNotBlank(Object? value) =>
      value is String && value.trim().isNotEmpty;

  /// A resposta de uma tiragem (runas/oráculo), extraída do JSON bruto
  /// `reading_data`. Best-effort: procura a interpretação salva; se não
  /// achar, junta os nomes das runas/cartas. Qualquer falha de parse
  /// devolve null — o campo simplesmente não entra, sem quebrar a leitura.
  static String? _readingInterpretation(Object? raw) {
    if (raw is! String || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        for (final key in const ['interpretation', 'summary', 'meaning']) {
          if (_isNotBlank(decoded[key])) return _excerpt(decoded[key]);
        }
        // Sem texto pronto: liste o que foi tirado (runas/cartas).
        for (final key in const ['runes', 'cards', 'positions', 'draws']) {
          final list = decoded[key];
          if (list is List && list.isNotEmpty) {
            final nomes = <String>[
              for (final item in list.take(5))
                if (item is Map && _isNotBlank(item['name']))
                  '${item['name']}'
                else if (item is String && _isNotBlank(item))
                  item,
            ];
            if (nomes.isNotEmpty) return _excerpt(nomes.join(', '));
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Trecho curto e de linha única: espaços colapsados e corte em limite de
  /// palavra — nunca o diário inteiro.
  static String _excerpt(Object? value) {
    final text = '$value'.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length <= _maxExcerptLength) return text;
    final cut = text.substring(0, _maxExcerptLength);
    final lastSpace = cut.lastIndexOf(' ');
    return '${cut.substring(0, lastSpace > 60 ? lastSpace : cut.length)}…';
  }

  static String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _dayOf(Object? millis) => millis is int
      ? _dayKey(DateTime.fromMillisecondsSinceEpoch(millis))
      : '';
}
