import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A marca de uma leitura que levou a fonte íntima junto.
class MenstrualReportMark {
  const MenstrualReportMark({
    required this.readingId,
    required this.writingId,
    required this.scope,
    required this.dayKeys,
    required this.at,
  });

  /// A leitura (o crédito) e a entrada dela no acervo.
  final String readingId;
  final String writingId;

  /// A impressão do escopo autorizado — o contrato daquela geração.
  final String scope;

  /// Os dias que foram junto. É o que permite dizer, depois, quais leituras
  /// usaram um registro que ela quer apagar.
  final List<String> dayKeys;

  final DateTime at;

  Map<String, Object?> toJson() => {
        'reading': readingId,
        'writing': writingId,
        'scope': scope,
        'days': dayKeys,
        'at': at.millisecondsSinceEpoch,
      };

  static MenstrualReportMark? fromJson(Object? value) {
    if (value is! Map) return null;
    final reading = value['reading'];
    final writing = value['writing'];
    if (reading is! String || writing is! String) return null;
    return MenstrualReportMark(
      readingId: reading,
      writingId: writing,
      scope: '${value['scope'] ?? ''}',
      dayKeys: [
        for (final day in (value['days'] as List? ?? const [])) '$day',
      ],
      at: DateTime.fromMillisecondsSinceEpoch(
          (value['at'] as num?)?.toInt() ?? 0),
    );
  }
}

/// Quais leituras levaram a fonte íntima junto, e de quais dias.
///
/// Fica no aparelho, ao lado dos consentimentos: é registro de operação, não
/// conteúdo — nenhuma observação dela mora aqui, só datas e identificadores.
/// Serve para três coisas que o módulo promete:
///
/// * dizer que um relatório do acervo contém o que ela autorizou;
/// * mostrar quais leituras usaram um registro ANTES de apagá-lo;
/// * apagar as cópias derivadas junto, quando ela pedir.
///
/// Consentir com o envio à IA não habilita backup na nuvem: esta marca existe
/// justamente para que o relatório derivado não viaje como um texto qualquer.
class MenstrualReportMarks {
  const MenstrualReportMarks();

  static const _prefix = 'menstrual_reports_';

  Future<List<MenstrualReportMark>> all(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$userId');
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded)
          if (MenstrualReportMark.fromJson(item) case final mark?) mark,
      ];
    } catch (_) {
      return const [];
    }
  }

  /// Guarda (ou substitui) a marca daquela leitura. Gerar de novo a mesma
  /// janela troca a marca: o escopo novo é o que vale.
  Future<void> record(String userId, MenstrualReportMark mark) async {
    final marks = [
      for (final existing in await all(userId))
        if (existing.readingId != mark.readingId) existing,
      mark,
    ];
    await _write(userId, marks);
  }

  /// Este relatório do acervo contém fonte íntima?
  Future<bool> isSensitive(String userId, String writingId) async {
    for (final mark in await all(userId)) {
      if (mark.writingId == writingId) return true;
    }
    return false;
  }

  /// As leituras que usaram aquele dia — o que ela precisa ver antes de
  /// apagar o registro.
  Future<List<MenstrualReportMark>> using(String userId, String dayKey) async =>
      [
        for (final mark in await all(userId))
          if (mark.dayKeys.contains(dayKey)) mark,
      ];

  Future<void> remove(String userId, String readingId) async {
    final marks = [
      for (final mark in await all(userId))
        if (mark.readingId != readingId) mark,
    ];
    await _write(userId, marks);
  }

  Future<void> forget(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$userId');
  }

  Future<void> _write(String userId, List<MenstrualReportMark> marks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$userId',
        jsonEncode([for (final mark in marks) mark.toJson()]));
  }
}
