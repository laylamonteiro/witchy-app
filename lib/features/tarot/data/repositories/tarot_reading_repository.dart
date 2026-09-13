import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/tarot_card_model.dart';

/// Persistência local das tiragens de Tarô (`tarot_readings`).
///
/// Runas, oráculo e pêndulo já registravam cada consulta; o Tarô só existia
/// se a pessoa salvasse à mão no acervo — e a Leitura do Ciclo não enxergava
/// as tiragens do período. Aqui toda mesa revelada vira registro.
///
/// Os resultados entram na sincronização existente de `tarotReadings` como
/// pendentes (`synced: 0`). Uma seleção ainda não confirmada permanece local.
class TarotReadingRepository {
  TarotReadingRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  /// Singleton; fora de uma sessão autenticada, `syncItem` não faz nada.
  final DataSyncService _syncService = DataSyncService();

  /// Registra uma tiragem revelada. Idempotente por `signature` (a mesma
  /// mesa reaberta — ex.: a carta do dia — não cria linha nova) e devolve o
  /// id da linha, novo ou existente.
  Future<String> recordDraw({
    required String userId,
    required String spreadName,
    required String signature,
    required List<TarotDrawnCard> drawn,
    String? question,
    DatabaseExecutor? executor,
    String? sessionId,
    DateTime? date,
  }) async {
    final db = executor ?? await _dbHelper.database;

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
        if (sessionId != null) 'session_id': sessionId,
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
      'date': date?.millisecondsSinceEpoch ?? now,
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
  ///
  /// O `synced: 0` e o `syncItem` não são zelo: depois que a tiragem subiu uma
  /// vez, `_markAsSynced` a carimbou, e a varredura só recolhe linhas com
  /// `synced = 0` — sem os dois, a interpretação nunca saía deste aparelho.
  /// Ela lia a resposta hoje, trocava de telefone e a mesa voltava sem
  /// resposta; pior, uma cópia remota mais nova podia sobrescrever a linha
  /// local e levar a interpretação embora. Runas e oráculo fazem as duas
  /// coisas no mesmo verbo.
  Future<void> attachInterpretation({
    required String userId,
    required String signature,
    required String interpretation,
  }) async {
    final db = await _dbHelper.database;
    // A linha INTEIRA, e não só `id` e `reading_data`: é ela que vai para o
    // upsert do servidor, e mandar meia linha apagaria lá a pergunta, o tipo
    // de mesa e a data.
    final rows = await db.query(
      'tarot_readings',
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

    final row = Map<String, dynamic>.from(rows.first);
    row['reading_data'] = jsonEncode(data);
    row['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    row['synced'] = 0;
    await db.update(
      'tarot_readings',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
    await _syncService.syncItem(SyncEntity.tarotReadings, row);
  }
}
