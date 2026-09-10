import 'package:sqflite/sqflite.dart';

/// Local presentation sessions and usage share the result's transaction.
/// None of these tables is uploaded by the generic content sync.
/// Oracle discoveries (v25) feed the album of P11; they are local until the
/// collections sync of P15 and never grant XP. Advisor consultations (v26)
/// keep a received answer on the device so reopening never re-sends it.
abstract final class ReadingSessionSchema {
  static const tables = [
    'selection_sessions',
    'tarot_day_state',
    'usage_balances',
    'usage_operations',
    'oracle_discoveries',
    'advisor_consultations',
  ];

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS selection_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        tool TEXT NOT NULL,
        spread TEXT NOT NULL,
        day_key TEXT NOT NULL,
        day_start INTEGER NOT NULL,
        day_end INTEGER NOT NULL,
        question TEXT NOT NULL,
        normalized_question TEXT NOT NULL,
        deck_version TEXT NOT NULL,
        deck_json TEXT NOT NULL,
        selected_json TEXT NOT NULL DEFAULT '[]',
        result_id TEXT,
        result_signature TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_selection_identity
      ON selection_sessions(user_id, tool, spread, day_key, normalized_question)
      WHERE tool = 'tarot' AND spread = 'daily'
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tarot_day_state (
        user_id TEXT NOT NULL,
        day_key TEXT NOT NULL,
        daily_question TEXT,
        last_question TEXT,
        synced INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY(user_id, day_key)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usage_balances (
        user_id TEXT NOT NULL,
        category TEXT NOT NULL,
        day_key TEXT NOT NULL,
        initial_used INTEGER NOT NULL CHECK(initial_used >= 0),
        PRIMARY KEY(user_id, category, day_key)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usage_operations (
        user_id TEXT NOT NULL,
        operation_id TEXT NOT NULL,
        category TEXT NOT NULL,
        day_key TEXT NOT NULL,
        amount INTEGER NOT NULL CHECK(amount > 0),
        PRIMARY KEY(user_id, operation_id)
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_usage_by_day
      ON usage_operations(user_id, category, day_key)
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS oracle_discoveries (
        user_id TEXT NOT NULL,
        card_id INTEGER NOT NULL,
        first_seen_at INTEGER NOT NULL,
        source_reading_id TEXT,
        catalog_version TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY(user_id, card_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS advisor_consultations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        question TEXT NOT NULL,
        answer TEXT,
        status TEXT NOT NULL,
        writing_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_advisor_by_user
      ON advisor_consultations(user_id, created_at)
    ''');
  }
}
