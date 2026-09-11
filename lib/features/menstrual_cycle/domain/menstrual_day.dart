import 'dart:convert';

/// O que a pessoa escolheu marcar naquele dia. A escolha é sempre explícita:
/// um escape nunca vira começo, e um dia sem registro é só isso — sem
/// registro, e não "sem sintomas".
enum MenstrualMark {
  /// Começou.
  start,

  /// Um dia de fluxo, no meio.
  flow,

  /// Escape.
  spotting,

  /// Terminou.
  end,

  /// Só uma anotação, sem dizer nada sobre sangramento.
  note,
}

/// A intensidade observada, quando a pessoa quis dizer. Nunca é presumida.
enum MenstrualFlowLevel { light, medium, heavy }

/// Um dia do registro pessoal: o que foi escrito, e nada além disso.
///
/// [revision] cresce a cada gravação e [deleted] marca a lápide — juntos,
/// eles resolvem o encontro de dois aparelhos sem ressuscitar o que alguém
/// apagou. Nenhum campo aqui é calculado.
class MenstrualDay {
  MenstrualDay({
    required this.userId,
    required DateTime day,
    required this.mark,
    this.flow,
    this.symptoms = const [],
    this.mood,
    this.note = '',
    this.revision = 1,
    this.deleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : day = DateTime(day.year, day.month, day.day),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String userId;

  /// O dia local, sem hora: o registro é de um dia, não de um instante.
  final DateTime day;

  final MenstrualMark mark;
  final MenstrualFlowLevel? flow;
  final List<String> symptoms;
  final String? mood;
  final String note;
  final int revision;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get dayKey => keyOf(day);

  /// A mesma forma de nomear um dia que o resto do app usa.
  static String keyOf(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// A intensidade pelo nome guardado, ou nenhuma: um nome desconhecido não
  /// pode virar uma observação que a pessoa não fez.
  static MenstrualFlowLevel? flowNamed(String name) {
    for (final value in MenstrualFlowLevel.values) {
      if (value.name == name) return value;
    }
    return null;
  }

  static DateTime dayOfKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  MenstrualDay copyWith({
    MenstrualMark? mark,
    MenstrualFlowLevel? flow,
    bool clearFlow = false,
    List<String>? symptoms,
    String? mood,
    bool clearMood = false,
    String? note,
    int? revision,
    bool? deleted,
    DateTime? updatedAt,
  }) =>
      MenstrualDay(
        userId: userId,
        day: day,
        mark: mark ?? this.mark,
        flow: clearFlow ? null : (flow ?? this.flow),
        symptoms: symptoms ?? this.symptoms,
        mood: clearMood ? null : (mood ?? this.mood),
        note: note ?? this.note,
        revision: revision ?? this.revision,
        deleted: deleted ?? this.deleted,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  Map<String, Object?> toRow() => {
        'user_id': userId,
        'day_key': dayKey,
        'mark': mark.name,
        'flow': flow?.name,
        'symptoms': jsonEncode(symptoms),
        'mood': mood,
        'note': note,
        'revision': revision,
        'deleted': deleted ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'synced': 0,
      };

  static MenstrualDay fromRow(Map<String, Object?> row) {
    final rawSymptoms = row['symptoms'];
    var symptoms = const <String>[];
    if (rawSymptoms is String && rawSymptoms.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawSymptoms);
        if (decoded is List) {
          symptoms = [for (final item in decoded) '$item'];
        }
      } catch (_) {
        // Uma linha estragada não pode derrubar o histórico inteiro.
      }
    }
    return MenstrualDay(
      userId: row['user_id'] as String,
      day: dayOfKey(row['day_key'] as String),
      mark: MenstrualMark.values.firstWhere(
        (value) => value.name == row['mark'],
        orElse: () => MenstrualMark.note,
      ),
      flow: switch (row['flow']) {
        final String name => flowNamed(name),
        _ => null,
      },
      symptoms: symptoms,
      mood: row['mood'] as String?,
      note: (row['note'] as String?) ?? '',
      revision: (row['revision'] as num?)?.toInt() ?? 1,
      deleted: ((row['deleted'] as num?)?.toInt() ?? 0) == 1,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch((row['created_at'] as num).toInt()),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch((row['updated_at'] as num).toInt()),
    );
  }
}
