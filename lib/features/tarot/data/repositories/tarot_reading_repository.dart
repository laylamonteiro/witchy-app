import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../models/tarot_card_model.dart';

/// Persistência local das tiragens de Tarô (`tarot_readings`).
///
/// Runas, oráculo e pêndulo já registravam cada consulta; o Tarô só existia
/// se a pessoa salvasse à mão no acervo — e a Leitura do Ciclo não enxergava
/// as tiragens do período. Aqui toda mesa revelada vira registro.
///
/// Local-only por enquanto (fora do DataSyncService): espelhar exige a
/// tabela correspondente no Supabase — quando ela existir, basta adicionar
/// o SyncEntity e o syncItem no fim de [recordDraw]/[attachInterpretation].
class TarotReadingRepository {
  TarotReadingRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  /// Registra uma tiragem revelada. Idempotente por `signature` (a mesma
  /// mesa reaberta — ex.: a carta do dia — não cria linha nova) e devolve o
  /// id da linha, novo ou existente.
  Future<String> recordDraw({
    required String userId,
    required String spreadName,
    required String signature,
    required List<TarotDrawnCard> drawn,
    String? question,
  }) async {
    final db = await _dbHelper.database;

    final existing = await db.query(
      'tarot_readings',
      columns: ['id'],
      where: 'user_id = ? AND signature = ?',
      whereArgs: [userId, signature],
      limit: 1,
    );
    if (existing.isNotEmpty) return existing.first['id'] as String;

    final now = DateTime.now().millisecondsSinceEpoch;
    final id = const Uuid().v4();
    await db.insert('tarot_readings', {
      'id': id,
      'user_id': userId,
      'question': (question == null || question.trim().isEmpty)
          ? null
          : question.trim(),
      'spread_type': spreadName,
      'signature': signature,
      'reading_data': jsonEncode({
        'spread': spreadName,
        'cards': [
          for (final d in drawn)
            {
              'name': d.card.name,
              // Naipe + número são as chaves estáveis entre idiomas: é por
              // elas que a mesa de hoje é reconstruída ao ser revisitada.
              'suit': d.card.suit.name,
              'number': d.card.number,
              'position': d.positionLabel,
              'reversed': d.isReversed,
            },
        ],
      }),
      'date': now,
      'created_at': now,
      'updated_at': now,
      'synced': 0,
    });
    return id;
  }

  /// As cartas da tiragem [spreadName] já feita HOJE com esta [question]
  /// (sem distinguir maiúsculas), a mais recente — ou null. É o que permite
  /// REPETIR a mesa sem sortear de novo nem cobrar: a cota é por pergunta.
  Future<List<Map<String, dynamic>>?> drawOfToday({
    required String userId,
    required String spreadName,
    required String question,
    DateTime? now,
  }) async {
    final db = await _dbHelper.database;
    final agora = now ?? DateTime.now();
    final inicioDoDia =
        DateTime(agora.year, agora.month, agora.day).millisecondsSinceEpoch;
    final rows = await db.query(
      'tarot_readings',
      columns: ['question', 'reading_data'],
      where: 'user_id = ? AND spread_type = ? AND date >= ?',
      whereArgs: [userId, spreadName, inicioDoDia],
      orderBy: 'date DESC',
    );
    // A comparação fica no Dart: o LOWER() do SQLite só conhece ASCII.
    final alvo = question.trim().toLowerCase();
    for (final row in rows) {
      final guardada = (row['question'] as String?)?.trim().toLowerCase();
      if (guardada != alvo) continue;
      try {
        final data = jsonDecode(row['reading_data'] as String)
            as Map<String, dynamic>;
        final cards = data['cards'];
        if (cards is List && cards.isNotEmpty) {
          return cards.whereType<Map>().map(Map<String, dynamic>.from).toList();
        }
      } catch (_) {
        // Registro estranho: segue para o próximo.
      }
    }
    return null;
  }

  /// Anexa a interpretação do Conselheiro à tiragem já registrada — é ela
  /// que a Leitura do Ciclo cita como "a resposta" da mesa.
  Future<void> attachInterpretation({
    required String userId,
    required String signature,
    required String interpretation,
  }) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'tarot_readings',
      columns: ['id', 'reading_data'],
      where: 'user_id = ? AND signature = ?',
      whereArgs: [userId, signature],
      limit: 1,
    );
    if (rows.isEmpty) return;

    Map<String, dynamic> data;
    try {
      data = jsonDecode(rows.first['reading_data'] as String)
          as Map<String, dynamic>;
    } catch (_) {
      data = <String, dynamic>{};
    }
    data['interpretation'] = interpretation;

    await db.update(
      'tarot_readings',
      {
        'reading_data': jsonEncode(data),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [rows.first['id']],
    );
  }
}
