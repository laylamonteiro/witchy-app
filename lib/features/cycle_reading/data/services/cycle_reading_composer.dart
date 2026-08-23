import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../astrology/data/models/enums.dart';
import '../../../astrology/data/models/magical_profile_report.dart';
import '../../../astrology/data/repositories/astrology_repository.dart';
import '../../../astrology/data/services/transit_calculator.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../grimoire/data/models/spell_model.dart'
    show MoonPhase, MoonPhaseExtension;
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../../wheel_of_year/data/models/sabbat_model.dart'
    show SabbatType, SabbatTypeExtension;
import '../../../your_day/data/daily_checkin_repository.dart';
import '../models/cycle_reading_model.dart';

/// Fontes que a pessoa pode EXCLUIR da análise (intimidade em primeiro
/// lugar: a tela de compra oferece estes desligamentos antes de enviar
/// qualquer coisa para a IA).
class CycleReadingSourceOptions {
  /// Sonhos. Continua sozinho, e não dentro dos diários, porque é a fonte
  /// mais íntima de todas — quem quer excluir só isso não deveria ter de
  /// abrir mão do resto do diário junto.
  final bool includeDreams;

  /// O que ela escreve e deseja: gratidões, desejos, afirmações criadas,
  /// sigilos e escrita livre.
  final bool includeJournals;

  /// A conversa com o oráculo: runas, pêndulo, cartas, tarô e as leituras
  /// guardadas no acervo.
  final bool includeDivination;

  /// A prática efetiva: feitiços criados e as notas deixadas nos ritos.
  final bool includePractice;

  const CycleReadingSourceOptions({
    this.includeDreams = true,
    this.includeJournals = true,
    this.includeDivination = true,
    this.includePractice = true,
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

  /// Os números reais do período, calculados em Dart (ver [NumerosDoCiclo]).
  /// Nulo só em materiais montados à mão (testes antigos): o [compose]
  /// sempre os entrega.
  final NumerosDoCiclo? numbers;

  const CycleReadingMaterial({
    required this.json,
    required this.recordCount,
    this.numbers,
  });

  String get compactJson => jsonEncode(json);

  /// O material que UMA seção precisa ver.
  ///
  /// O relatório é gerado seção a seção, e o JSON inteiro ia em todas as
  /// chamadas — a IA relia o mesmo material 7 vezes. Aqui as seções cuja
  /// instrução já diz de onde ela tira o texto recebem só isso.
  ///
  /// O corte é conservador de propósito: retrato, fios, rituais e afirmação
  /// continuam vendo TUDO, porque são as que precisam cruzar fontes para
  /// achar o que floresce e o que pede atenção — economizar ali sairia caro
  /// na única coisa que a leitura promete, que é falar da vida daquela
  /// pessoa. Onde não há certeza, o material vai inteiro.
  String compactJsonFor(String sectionKey) {
    final campos = _sectionFields[sectionKey];
    if (campos == null) return compactJson;
    return jsonEncode({
      for (final entry in json.entries)
        if (campos.contains(entry.key)) entry.key: entry.value,
    });
  }

  /// Só as seções listadas aqui recebem material reduzido. As demais (e
  /// qualquer seção nova) recebem tudo — esquecer de cadastrar uma seção
  /// custa tokens, nunca contexto.
  ///
  /// O bloco "numbers" entra em TODAS: é minúsculo e traz os números já
  /// calculados que a IA deve citar em vez de recalcular. O "person" (o
  /// nome, para a narrativa em terceira pessoa) idem.
  static const Map<String, Set<String>> _sectionFields = {
    // "o céu sobre você": a própria instrução manda usar sky + timeline +
    // moonByDay. Os trechos longos de cada fonte não entram: a nota curta
    // de cada momento na timeline já diz o que ela registrou naquele dia.
    'sky': {
      'period',
      'person',
      'sky',
      'moonByDay',
      'timeline',
      'recordCount',
      'practiceDays',
      'streak',
      'numbers',
    },
    // "sua prática": fala dos ritos e feitiços dela. Sonhos, gratidões e
    // tiragens não são matéria desta seção.
    'practice': {
      'period',
      'person',
      'practice',
      'profile',
      'timeline',
      'moonByDay',
      'sky',
      'learning',
      'recordCount',
      'practiceDays',
      'streak',
      'numbers',
    },
    // O selo são 3 palavras que resumem o ciclo: a forma do período (a
    // timeline e as contagens) basta, e é o que ele de fato usa.
    'seal': {
      'period',
      'person',
      'timeline',
      'moonByDay',
      'sky',
      'recordCount',
      'dreamCount',
      'divinationCount',
      'practiceDays',
      'streak',
      'numbers',
    },
  };
}

/// Os números REAIS do ciclo, calculados em Dart a partir do material que o
/// [CycleReadingComposer.compose] já coletou (sem nova ida ao banco, exceto
/// a contagem leve do período anterior).
///
/// A regra "a IA narra, nunca calcula" continua de pé — ela existe para a
/// IA não inventar fase de lua nem data. Quem calcula é o APP: estes números
/// viram uma seção determinística do relatório (montada por código) e vão no
/// bloco "numbers" do JSON para a IA citar exatamente como estão.
class NumerosDoCiclo {
  /// Registros do período (mesma matéria-prima do recordCount).
  final int totalRecords;

  /// Dias do período com pelo menos um registro.
  final int activeDays;

  /// Duração da janela em dias de calendário.
  final int periodDays;

  /// Fase da lua com mais registros (null quando o período está vazio).
  final MoonPhase? topPhase;
  final int topPhaseCount;

  /// Fonte mais presente — uma chave canônica de [canonicalSources]
  /// (null quando o período está vazio).
  final String? topSource;
  final int topSourceCount;

  /// Maior sequência de dias SEGUIDOS com registro.
  final int longestStreak;

  /// Registros da janela imediatamente anterior, de mesma duração.
  final int previousPeriodRecords;

  const NumerosDoCiclo({
    required this.totalRecords,
    required this.activeDays,
    required this.periodDays,
    required this.topPhase,
    required this.topPhaseCount,
    required this.topSource,
    required this.topSourceCount,
    required this.longestStreak,
    required this.previousPeriodRecords,
  });

  /// As quatro fontes que a tela de privacidade oferece desligar, nas MESMAS
  /// chaves de sempre — e na ordem de desempate: empate na contagem fica com
  /// a primeira daqui, de forma determinística, para o relatório (e os
  /// testes) não flutuarem entre gerações do mesmo material.
  static const sourceDreams = 'dreams';
  static const sourceJournals = 'journals';
  static const sourceDivination = 'divination';
  static const sourcePractice = 'practice';
  static const canonicalSources = [
    sourceDreams,
    sourceJournals,
    sourceDivination,
    sourcePractice,
  ];

  /// Calcula tudo de entradas puras (testável sem banco e sem IA).
  ///
  /// [countsByDay] usa chaves `yyyy-MM-dd`; [phaseByDay] traz a fase da lua
  /// de cada dia ativo; [countsBySource] usa as chaves de
  /// [canonicalSources].
  factory NumerosDoCiclo.calcular({
    required DateTime start,
    required DateTime end,
    required Map<String, int> countsByDay,
    required Map<String, MoonPhase> phaseByDay,
    required Map<String, int> countsBySource,
    required int previousPeriodRecords,
  }) {
    final ativos =
        countsByDay.entries.where((e) => e.value > 0).toList(growable: false);
    final total = ativos.fold<int>(0, (soma, e) => soma + e.value);

    // Fase com mais registros: cada dia ativo soma seus registros na fase
    // daquele dia. Empate: a PRIMEIRA na ordem do enum (nova → minguante),
    // porque `>` só troca a campeã quando a contagem é estritamente maior.
    final porFase = <MoonPhase, int>{};
    for (final e in ativos) {
      final fase = phaseByDay[e.key];
      if (fase == null) continue;
      porFase[fase] = (porFase[fase] ?? 0) + e.value;
    }
    MoonPhase? topPhase;
    var topPhaseCount = 0;
    for (final fase in MoonPhase.values) {
      final n = porFase[fase] ?? 0;
      if (n > topPhaseCount) {
        topPhase = fase;
        topPhaseCount = n;
      }
    }

    // Fonte mais presente: mesmo desempate determinístico, pela ordem
    // canônica.
    String? topSource;
    var topSourceCount = 0;
    for (final fonte in canonicalSources) {
      final n = countsBySource[fonte] ?? 0;
      if (n > topSourceCount) {
        topSource = fonte;
        topSourceCount = n;
      }
    }

    // Maior sequência de dias seguidos: os dias viram índices UTC (imunes a
    // horário de verão) e a sequência cresce quando o índice avança em 1.
    final indices = ativos.map((e) => _dayIndex(e.key)).toList()..sort();
    var maior = 0;
    var atual = 0;
    int? anterior;
    for (final indice in indices) {
      atual = (anterior != null && indice == anterior + 1) ? atual + 1 : 1;
      if (atual > maior) maior = atual;
      anterior = indice;
    }

    return NumerosDoCiclo(
      totalRecords: total,
      activeDays: ativos.length,
      periodDays: _periodDays(start, end),
      topPhase: topPhase,
      topPhaseCount: topPhaseCount,
      topSource: topSource,
      topSourceCount: topSourceCount,
      longestStreak: maior,
      previousPeriodRecords: previousPeriodRecords,
    );
  }

  /// Índice do dia de uma chave `yyyy-MM-dd`, em UTC — a aritmética de dias
  /// nunca escorrega numa virada de horário de verão.
  static int _dayIndex(String dayKey) {
    final partes = dayKey.split('-');
    return DateTime.utc(
          int.parse(partes[0]),
          int.parse(partes[1]),
          int.parse(partes[2]),
        ).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  /// Dias de calendário da janela `>= start AND < end`: fim exclusivo à
  /// meia-noite não conta o dia; qualquer hora além dela conta o dia já
  /// começado. Calculado em UTC pelos componentes, pela mesma razão de
  /// [_dayIndex].
  static int _periodDays(DateTime start, DateTime end) {
    final inicio = DateTime.utc(start.year, start.month, start.day);
    final fimDia = DateTime.utc(end.year, end.month, end.day);
    final inteiros = fimDia.difference(inicio).inDays;
    final temResto =
        end.hour != 0 || end.minute != 0 || end.second != 0 ||
            end.millisecond != 0 || end.microsecond != 0;
    return temResto ? inteiros + 1 : inteiros;
  }

  /// O bloco "numbers" do JSON do material — nomes de campo em inglês, como
  /// o resto do JSON. O nome da fase vai localizado (displayName): a IA narra
  /// no idioma do app e deve citar o nome exatamente como está aqui.
  Map<String, dynamic> toJson() => {
        'totalRecords': totalRecords,
        'activeDays': activeDays,
        'periodDays': periodDays,
        if (topPhase != null)
          'topPhase': {'phase': topPhase!.displayName, 'count': topPhaseCount},
        if (topSource != null)
          'topSource': {'source': topSource, 'count': topSourceCount},
        if (longestStreak > 0) 'longestStreak': longestStreak,
        'previousPeriodRecords': previousPeriodRecords,
      };
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

  /// Teto de pontos da linha do tempo. Uma lunação movimentada rende bem
  /// mais que isto; o corte é por AMOSTRAGEM UNIFORME (ver [_sampleEvenly]),
  /// nunca pelos primeiros N — pegar só o começo daria uma cronologia que
  /// morre no meio do mês.
  static const int _maxTimelineMoments = 40;

  /// Teto de cada nota da linha do tempo: ali o que importa é QUANDO e O
  /// QUÊ; o conteúdo cheio já vai nas listas por fonte.
  static const int _maxTimelineNoteLength = 70;

  Future<Database> get _db async =>
      _dbOverride ?? await DatabaseHelper.instance.database;

  /// As tabelas que contam como "registro da pessoa" no período.
  ///
  /// Uma lista só, usada pela contagem total e pelo mapa de calor: se as
  /// duas divergissem, o calendário mostraria um dia quente que a contagem
  /// não enxerga (ou o contrário).
  static const List<String> _recordTables = [
    'dreams',
    'gratitudes',
    'desires',
    // As afirmações que ela CRIOU (as pré-carregadas ficam de fora pelo
    // filtro): estavam sendo somadas dentro da leitura e não aqui, então a
    // tela dizia um número e a análise usava outro.
    'affirmations',
    'free_writings',
    'rune_readings',
    'oracle_readings',
    'pendulum_consultations',
    'tarot_readings',
    'ritual_logs',
    'guided_ritual_logs',
    'spells',
    'sigils',
  ];

  /// A coluna de tempo de cada tabela: rito concluído marca `completed_at`;
  /// o resto, `created_at`.
  static String _timeColumnOf(String table) =>
      table.endsWith('_logs') ? 'completed_at' : 'created_at';

  /// Filtro do que NÃO é registro da pessoa: feitiço que já veio no app e
  /// o relatório da própria Leitura do Ciclo — sem isso, uma leitura
  /// inflaria o ciclo seguinte.
  static String _ownRecordsFilter(String table) => switch (table) {
        'spells' => ' AND is_preloaded = 0',
        'affirmations' => ' AND is_preloaded = 0',
        'free_writings' =>
          " AND source != '${FreeWritingSource.cycleReading}'",
        _ => '',
      };

  /// Quantos registros a pessoa fez em CADA dia da janela — o mapa de calor
  /// do seletor de período.
  ///
  /// A chave é `yyyy-MM-dd` no fuso do aparelho. O agrupamento é feito em
  /// Dart, e não com `date()` no SQL, de propósito: o SQLite converteria os
  /// millis em UTC e um registro das 22h cairia no dia seguinte para quem
  /// vive a leste — o calendário mostraria calor no dia errado.
  ///
  /// Dias sem registro simplesmente não aparecem no mapa.
  Future<Map<String, int>> dailyRecordCounts({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await _db;
    final counts = <String, int>{};
    for (final table in _recordTables) {
      final timeColumn = _timeColumnOf(table);
      try {
        final rows = await db.rawQuery(
          'SELECT $timeColumn AS t FROM $table '
          'WHERE user_id = ? AND $timeColumn >= ? AND $timeColumn < ?'
          '${_ownRecordsFilter(table)}',
          [
            userId,
            start.millisecondsSinceEpoch,
            end.millisecondsSinceEpoch,
          ],
        );
        for (final row in rows) {
          final millis = row['t'];
          if (millis is! int) continue;
          final dia = _dayKey(DateTime.fromMillisecondsSinceEpoch(millis));
          counts[dia] = (counts[dia] ?? 0) + 1;
        }
      } catch (_) {
        // Tabela ausente numa base antiga: segue com as demais.
      }
    }
    return counts;
  }

  /// Contagem barata dos registros do período — usada pelo card de oferta
  /// no Seu Dia ("Sua lunação rendeu {N} registros") e pelo aviso de
  /// leitura rasa, sem montar o material inteiro.
  Future<int> countPeriodRecords({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await _db;
    var total = 0;
    for (final table in _recordTables) {
      final timeColumn = _timeColumnOf(table);
      final preloadedFilter = _ownRecordsFilter(table);
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
  ///
  /// [userName] é o nome do perfil: com ele no material, a narrativa fala
  /// DA pessoa em terceira pessoa, pelo nome (decisão da dona, 23/08) —
  /// sem ele, a leitura segue falando com "você".
  Future<CycleReadingMaterial> compose({
    required String userId,
    required DateTime start,
    required DateTime end,
    String periodType = CycleReadingPeriodType.lunation,
    CycleReadingSourceOptions options = const CycleReadingSourceOptions(),
    String? userName,
  }) async {
    final db = await _db;
    final json = <String, dynamic>{
      'period': {
        'start': _dayKey(start),
        'end': _dayKey(end),
        'type': periodType,
      },
      if (userName != null && userName.trim().isNotEmpty)
        'person': {'name': userName.trim()},
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
    if (options.includeJournals && gratitudes.isNotEmpty) {
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
    if (options.includeJournals && desires.isNotEmpty) {
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
    //
    // Declaradas fora do try porque os números do ciclo (lá embaixo) também
    // as contam — e uma base antiga sem a tabela só deixa a lista vazia.
    var createdAffirmations = const <Map<String, Object?>>[];
    try {
      createdAffirmations = await rowsOf(
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
      if (options.includeJournals && texts.isNotEmpty) {
        json['affirmations'] = texts.take(_maxItemsPerSource).toList();
      }
    } catch (_) {}

    // ===== Sigilos (a intenção mágica desenhada — pura personalização) =====
    final sigils = await rowsOf('sigils');
    recordCount += sigils.length;
    if (options.includeJournals && sigils.isNotEmpty) {
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
    if (options.includeJournals && reflections.isNotEmpty) {
      json['freeWriting'] = [
        for (final row in reflections.take(_maxItemsPerSource))
          {
            'date': _dayOf(row['created_at']),
            'excerpt': _excerpt(row['content']),
          },
      ];
    }
    if (options.includeDivination && archivedReadings.isNotEmpty) {
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
    final tarotReadings = await rowsOf('tarot_readings');
    recordCount += runeReadings.length +
        pendulumConsults.length +
        oracleReadings.length +
        tarotReadings.length;
    if (options.includeDivination) {
      // Não só a pergunta — a tiragem inteira: a runa/carta e o que ela
      // respondeu. É a conversa real da pessoa com o oráculo no período.
      final divinations = <Map<String, dynamic>>[
        for (final row in runeReadings.take(_maxItemsPerSource))
          {
            'date': _dayOf(row['created_at']),
            'tool': 'runes',
            if (_isNotBlank(row['question']))
              'question': _excerpt(row['question']),
            if (_readingInterpretation(row['reading_data']) case final m?)
              'answer': m,
          },
        for (final row in pendulumConsults.take(_maxItemsPerSource))
          {
            'date': _dayOf(row['created_at']),
            'tool': 'pendulum',
            if (_isNotBlank(row['question']))
              'question': _excerpt(row['question']),
            if (_isNotBlank(row['answer'])) 'answer': _excerpt(row['answer']),
          },
        for (final row in oracleReadings.take(_maxItemsPerSource))
          {
            'date': _dayOf(row['created_at']),
            'tool': 'oracle-cards',
            if (_readingInterpretation(row['reading_data']) case final m?)
              'answer': m,
          },
        for (final row in tarotReadings.take(_maxItemsPerSource))
          {
            'date': _dayOf(row['created_at']),
            'tool': 'tarot',
            if (_isNotBlank(row['question']))
              'question': _excerpt(row['question']),
            if (_readingInterpretation(row['reading_data']) case final m?)
              'answer': m,
          },
      ].where((d) => d.length > 2).toList();
      if (divinations.isNotEmpty) {
        json['oracle'] = divinations;
      }
    }
    json['divinationCount'] = runeReadings.length +
        pendulumConsults.length +
        oracleReadings.length +
        tarotReadings.length;

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
      // magia dela buscou, não só quantos foram. As CONTAGENS acima ficam
      // mesmo com a fonte desligada: dizer "você fez 4 ritos" não expõe
      // nada; dizer o nome e a nota, sim.
      if (options.includePractice && spells.isNotEmpty)
        'spells': [
          for (final row in spells.take(_maxItemsPerSource))
            {
              'name': _excerpt(row['name']),
              if (_isNotBlank(row['purpose'])) 'purpose': _excerpt(row['purpose']),
            },
        ],
      // Notas que ela deixou nos ritos concluídos (quando houver).
      if (options.includePractice &&
          [...ritualLogs, ...guidedLogs].any((r) => _isNotBlank(r['notes'])))
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

    // ===== Linha do tempo (a espinha cronológica da narrativa) =====
    // Cada registro datado vira um ponto {date, kind, note} ordenado no
    // tempo. É este eixo que permite narrar o período em ORDEM — "no início,
    // sob a lua nova...; perto da cheia..." — em vez de listar fontes soltas.
    // Respeita os mesmos desligamentos de privacidade das listas acima.
    final moments = <({int ms, String kind, String? note})>[];
    void addMoment(Object? millis, String kind, Object? text) {
      if (millis is! int) return;
      moments.add((
        ms: millis,
        kind: kind,
        note: _isNotBlank(text) ? _shortExcerpt(text) : null,
      ));
    }

    if (options.includeDreams) {
      for (final row in dreams) {
        addMoment(row['date'] ?? row['created_at'], 'dream', row['title']);
      }
    }
    if (options.includeJournals) {
      for (final row in gratitudes) {
        addMoment(
          row['date'] ?? row['created_at'],
          'gratitude',
          _isNotBlank(row['title']) ? row['title'] : row['content'],
        );
      }
      for (final row in desires) {
        addMoment(row['created_at'], 'desire', row['title']);
      }
      for (final row in sigils) {
        addMoment(row['created_at'], 'sigil', row['intention']);
      }
      for (final row in reflections) {
        addMoment(row['created_at'], 'reflection', row['content']);
      }
    }
    if (options.includeDivination) {
      for (final row in runeReadings) {
        addMoment(row['created_at'], 'runes', row['question']);
      }
      for (final row in pendulumConsults) {
        addMoment(row['created_at'], 'pendulum', row['question']);
      }
      for (final row in oracleReadings) {
        addMoment(row['created_at'], 'oracle-cards', null);
      }
      for (final row in tarotReadings) {
        addMoment(row['created_at'], 'tarot', row['question']);
      }
    }
    if (options.includePractice) {
      for (final row in [...ritualLogs, ...guidedLogs]) {
        addMoment(row['completed_at'], 'ritual', row['notes']);
      }
      for (final row in spells) {
        addMoment(row['created_at'], 'spell', row['name']);
      }
    }

    moments.sort((a, b) => a.ms.compareTo(b.ms));
    final sampled = _sampleEvenly(moments, _maxTimelineMoments);
    if (sampled.isNotEmpty) {
      json['timeline'] = [
        for (final m in sampled)
          {
            'date': _dayOf(m.ms),
            'kind': m.kind,
            if (m.note != null) 'note': m.note,
          },
      ];

      // A lua de CADA dia com registro (fase + signo quando calculável):
      // o elo entre o que a pessoa viveu e o céu daquele momento — a base
      // da narrativa cronológica que relaciona registro e trânsito.
      final moonByDay = <String, Map<String, String>>{};
      for (final m in sampled) {
        final day = _dayOf(m.ms);
        if (day.isEmpty || moonByDay.containsKey(day)) continue;
        final date = DateTime.fromMillisecondsSinceEpoch(m.ms);
        final noon = DateTime(date.year, date.month, date.day, 12);
        final entry = <String, String>{
          'phase': LunarProvider.phaseOn(noon).displayName,
        };
        // Só a Lua (moonSignOn), nunca a mesa inteira de trânsitos: são
        // dezenas de dias, e calcular todos os planetas em cada um seria
        // pagar caríssimo por um dado só. Sem efemérides a fase sozinha já
        // sustenta a cronologia.
        final sign = await _transits.moonSignOn(noon);
        if (sign != null) entry['sign'] = sign.displayName;
        moonByDay[day] = entry;
      }
      json['moonByDay'] = moonByDay;
    }

    // ===== O céu do período (calculado no aparelho; a IA só narra) =====
    json['sky'] = await _skyFacts(userId, start, end);

    // ===== O céu do PRÓXIMO ciclo (idem) — a matéria da previsão =====
    // Janela de mesma duração, começando onde a lida termina.
    json['skyAhead'] =
        await _skyAheadFacts(userId, end, end.add(end.difference(start)));

    // ===== Quem ela é, segundo a própria Análise Personalizada =====
    final perfil = await _profileFacts(userId);
    if (perfil.isNotEmpty) json['profile'] = perfil;

    // ===== Os números do ciclo (calculados AQUI — a IA só os cita) =====
    // Tudo sai das linhas que este método JÁ buscou; a única ida extra ao
    // banco é a contagem leve do período anterior, que reusa o
    // countPeriodRecords da tela de oferta (mesmas tabelas, mesmos filtros).
    //
    // As contagens ignoram os desligamentos de privacidade de propósito,
    // como o recordCount: dizer "você fez 12 registros" não expõe nada —
    // expor seria citar o conteúdo, e conteúdo os números não têm.
    final countsByDay = <String, int>{};
    void contaDia(Object? millis) {
      if (millis is! int) return;
      final dia = _dayKey(DateTime.fromMillisecondsSinceEpoch(millis));
      countsByDay[dia] = (countsByDay[dia] ?? 0) + 1;
    }

    // Os mesmos campos de data que a linha do tempo usa (date ?? created_at
    // para sonhos e gratidões; completed_at para ritos): o dia contado é o
    // dia que a narrativa cita.
    for (final row in dreams) {
      contaDia(row['date'] ?? row['created_at']);
    }
    for (final row in gratitudes) {
      contaDia(row['date'] ?? row['created_at']);
    }
    for (final row in [
      ...desires,
      ...createdAffirmations,
      ...sigils,
      ...writings,
      ...runeReadings,
      ...pendulumConsults,
      ...oracleReadings,
      ...tarotReadings,
      ...spells,
    ]) {
      contaDia(row['created_at']);
    }
    for (final row in [...ritualLogs, ...guidedLogs]) {
      contaDia(row['completed_at']);
    }

    // A fase da lua de cada dia ativo, calculada no aparelho — nunca pela
    // IA (mesma matemática do moonByDay, ao meio-dia local).
    final phaseByDay = <String, MoonPhase>{};
    for (final dia in countsByDay.keys) {
      final partes = dia.split('-');
      phaseByDay[dia] = LunarProvider.phaseOn(DateTime(
        int.parse(partes[0]),
        int.parse(partes[1]),
        int.parse(partes[2]),
        12,
      ));
    }

    // Por fonte, nas mesmas quatro famílias dos desligamentos da intro. As
    // leituras arquivadas (savedReadings) pertencem à divinação — é o
    // desligamento que as governa no material.
    final countsBySource = <String, int>{
      NumerosDoCiclo.sourceDreams: dreams.length,
      NumerosDoCiclo.sourceJournals: gratitudes.length +
          desires.length +
          createdAffirmations.length +
          sigils.length +
          (writings.length - archivedReadings.length),
      NumerosDoCiclo.sourceDivination: runeReadings.length +
          pendulumConsults.length +
          oracleReadings.length +
          tarotReadings.length +
          archivedReadings.length,
      NumerosDoCiclo.sourcePractice:
          ritualLogs.length + guidedLogs.length + spells.length,
    };

    final duracao = end.difference(start);
    final numeros = NumerosDoCiclo.calcular(
      start: start,
      end: end,
      countsByDay: countsByDay,
      phaseByDay: phaseByDay,
      countsBySource: countsBySource,
      previousPeriodRecords: await countPeriodRecords(
        userId: userId,
        start: start.subtract(duracao),
        end: start,
      ),
    );
    json['numbers'] = numeros.toJson();

    json['recordCount'] = recordCount;
    return CycleReadingMaterial(
      json: json,
      recordCount: recordCount,
      numbers: numeros,
    );
  }

  /// O retrato mágico dela, tirado da Análise Personalizada que ela já leu.
  ///
  /// A leitura do ciclo conta o que ela VIVEU; o perfil diz de que jeito ela
  /// pratica. Juntando os dois, o ritual sugerido deixa de ser "acenda uma
  /// vela branca" e passa a ser o que combina com o mapa dela.
  ///
  /// Só entra o que já foi tecido — nada é gerado aqui: a leitura do ciclo
  /// não paga a conta de IA da análise do perfil. E entra CURTO: a primeira
  /// página de cada seção, aparada, porque o material inteiro dobraria o
  /// tamanho do JSON em toda chamada.
  Future<Map<String, String>> _profileFacts(String userId) async {
    try {
      final profile = await _astrology.getMagicalProfile(userId);
      final texto = profile?.aiGeneratedText;
      if (texto == null || texto.trim().isEmpty) return const {};

      final facts = <String, String>{};
      for (final secao in parseMagicalProfile(texto)) {
        final chave = secao.key;
        if (chave == null || !_profileKeys.contains(chave)) continue;
        final corpo = secao.slides.first.body.trim();
        if (corpo.isEmpty) continue;
        facts[chave] = corpo.length <= _maxProfileExcerpt
            ? corpo
            : '${corpo.substring(0, _maxProfileExcerpt)}…';
      }
      return facts;
    } catch (e) {
      debugPrint('CycleReadingComposer: perfil indisponível ($e)');
      return const {};
    }
  }

  /// As seções do perfil que ajudam a leitura do ciclo: quem ela é, como a
  /// intuição chega, o que ressoa com ela e o que dói. As outras (Vênus,
  /// Marte, Casa 8, Casa 12) diriam mais sobre o mapa do que sobre o ciclo.
  static const _profileKeys = {
    MagicalProfileSections.essence,
    MagicalProfileSections.intuition,
    MagicalProfileSections.allies,
    MagicalProfileSections.practice,
    MagicalProfileSections.shadow,
  };

  /// Teto de cada trecho do perfil (o material inteiro dobraria o JSON).
  static const int _maxProfileExcerpt = 240;

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

  /// O céu do PRÓXIMO ciclo — a matéria da seção "o que se anuncia".
  ///
  /// Mesma regra do [_skyFacts]: tudo calculado NO APARELHO — fases e
  /// trânsitos das efemérides, sabbats da Roda do Ano — e a IA só narra e
  /// interpreta. Best-effort como o resto do céu: sem mapa natal (ou sem
  /// efemérides), a previsão segue só com a lua e os sabbats.
  Future<Map<String, dynamic>> _skyAheadFacts(
    String userId,
    DateTime from,
    DateTime to,
  ) async {
    final ahead = <String, dynamic>{
      'window': {'from': _dayKey(from), 'to': _dayKey(to)},
    };

    // As viradas de fase da janela que vem, com a data de cada uma.
    final phases = <Map<String, String>>[];
    var cursor = DateTime(from.year, from.month, from.day, 12);
    MoonPhase? previous;
    while (cursor.isBefore(to)) {
      final phase = LunarProvider.phaseOn(cursor);
      if (phase != previous) {
        phases.add({'phase': phase.displayName, 'from': _dayKey(cursor)});
        previous = phase;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    ahead['moonPhases'] = phases;

    // Sabbats da Roda do Ano que caem na janela (datas do hemisfério sul,
    // como toda a Roda no app): o gancho de ensinamento mais direto que a
    // previsão tem. Os dois anos porque a janela pode cruzar a virada.
    final inicioDia = DateTime(from.year, from.month, from.day);
    final sabbats = <Map<String, String>>[
      for (final year in {from.year, to.year})
        for (final type in SabbatType.values)
          if (!type.getDateForYear(year).isBefore(inicioDia) &&
              type.getDateForYear(year).isBefore(to))
            {'sabbat': type.name, 'on': _dayKey(type.getDateForYear(year))},
    ]..sort((a, b) => a['on']!.compareTo(b['on']!));
    if (sabbats.isNotEmpty) ahead['sabbats'] = sabbats;

    try {
      final chart = await _astrology.getBirthChart(userId);
      if (chart == null) return ahead;

      // O MEIO da janela como referência: um retrato do céu que vem, não
      // uma efeméride dia a dia — o JSON dobraria sem mudar a narrativa.
      // O natal não se repete aqui: já vai em sky.natal.
      final reference = from.add(to.difference(from) ~/ 2);
      final transits = await _transits.calculateTransits(reference);
      ahead['transits'] = [
        for (final transit in transits)
          if (transit.planet != Planet.moon)
            '${transit.planet.displayName} in ${transit.sign.displayName}'
            '${transit.isRetrograde ? ' (retrograde)' : ''}',
      ];

      final aspects = await _transits.calculateTransitAspects(transits, chart);
      ahead['aspects'] = [
        for (final aspect in aspects
            .where((a) => a.transitPlanet != Planet.moon)
            .take(8))
          '${aspect.transitPlanet.displayName} '
          '${aspect.aspectType.displayName} '
          '${aspect.natalPlanet.displayName} natal '
          '(orb ${aspect.orb.toStringAsFixed(1)} deg)',
      ];
    } catch (e) {
      debugPrint('CycleReadingComposer: céu à frente indisponível ($e)');
    }
    return ahead;
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

  /// Amostra [max] itens distribuídos por TODA a lista (primeiro e último
  /// sempre incluídos). Preserva a forma do período — começo, meio e fim —
  /// em vez de truncar no primeiro terço.
  static List<T> _sampleEvenly<T>(List<T> items, int max) {
    if (items.length <= max) return items;
    if (max <= 1) return items.isEmpty ? const [] : [items.first];
    final step = (items.length - 1) / (max - 1);
    return [
      for (var i = 0; i < max; i++) items[(i * step).round()],
    ];
  }

  /// Nota curta da linha do tempo (mais apertada que [_excerpt]).
  static String _shortExcerpt(Object? value) {
    final text = '$value'.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length <= _maxTimelineNoteLength) return text;
    final cut = text.substring(0, _maxTimelineNoteLength);
    final lastSpace = cut.lastIndexOf(' ');
    return '${cut.substring(0, lastSpace > 30 ? lastSpace : cut.length)}…';
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
