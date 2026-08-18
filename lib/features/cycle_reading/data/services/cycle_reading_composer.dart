import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../astrology/data/models/enums.dart';
import '../../../astrology/data/repositories/astrology_repository.dart';
import '../../../astrology/data/services/transit_calculator.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../grimoire/data/models/spell_model.dart' show MoonPhase;
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../../your_day/data/daily_checkin_repository.dart';

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

  /// Abaixo disto a leitura sai rasa — a tela de compra avisa antes de
  /// cobrar (confiança vale mais que uma venda).
  static const int minRecordsForDepth = 5;

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
    CycleReadingSourceOptions options = const CycleReadingSourceOptions(),
  }) async {
    final db = await _db;
    final json = <String, dynamic>{
      'period': {
        'start': _dayKey(start),
        'end': _dayKey(end),
        'type': 'lunation',
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
          },
      ];
    }

    // ===== Afirmações favoritas (autoimagem desejada) =====
    try {
      final favorites = await db.rawQuery(
        'SELECT text FROM affirmations WHERE user_id = ? AND is_favorite = 1 '
        'ORDER BY updated_at DESC LIMIT ?',
        [userId, _maxItemsPerSource],
      );
      if (favorites.isNotEmpty) {
        json['favoriteAffirmations'] = [
          for (final row in favorites) _excerpt(row['text']),
        ];
      }
    } catch (_) {}

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
      json['archivedReadings'] = [
        for (final row in archivedReadings.take(_maxItemsPerSource))
          _excerpt(row['title'] ?? row['content']),
      ];
    }

    // ===== Perguntas feitas ao oráculo (as dúvidas reais do período) =====
    final runeReadings = await rowsOf('rune_readings');
    final pendulumConsults = await rowsOf('pendulum_consultations');
    final oracleReadings = await rowsOf('oracle_readings');
    recordCount +=
        runeReadings.length + pendulumConsults.length + oracleReadings.length;
    if (options.includeOracleQuestions) {
      final questions = <String>[
        for (final row in runeReadings)
          if (_isNotBlank(row['question'])) _excerpt(row['question']),
        for (final row in pendulumConsults)
          if (_isNotBlank(row['question'])) _excerpt(row['question']),
      ];
      if (questions.isNotEmpty) {
        json['oracleQuestions'] = questions.take(_maxItemsPerSource).toList();
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
