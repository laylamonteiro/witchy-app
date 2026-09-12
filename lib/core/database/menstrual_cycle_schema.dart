import 'package:sqflite/sqflite.dart';

/// O registro menstrual (v28; a v29 acrescentou `season` e `season_note`),
/// guardado por conta e por dia.
///
/// A tabela guarda apenas o que a pessoa escreveu: a marca escolhida por ela,
/// e os campos opcionais. Nada derivado mora aqui — dia do ciclo, médias e
/// estimativas são cálculo de quem lê, e ficam atrás do gate Premium.
///
/// Cada linha carrega `revision` e `deleted`: um aparelho offline que apaga um
/// dia deixa a lápide, e uma cópia antiga de outro aparelho não ressuscita o
/// que foi apagado, porque a revisão menor perde.
///
/// Esta tabela não entra na Leitura do Ciclo, no XP, em ofertas nem em
/// telemetria. A integração com a IA é assunto de outro pacote, e depende de
/// consentimento próprio.
abstract final class MenstrualCycleSchema {
  static const table = 'menstrual_days';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        user_id TEXT NOT NULL,
        day_key TEXT NOT NULL,
        mark TEXT NOT NULL,
        flow TEXT,
        symptoms TEXT NOT NULL DEFAULT '[]',
        mood TEXT,
        note TEXT NOT NULL DEFAULT '',
        season TEXT,
        season_note TEXT NOT NULL DEFAULT '',
        revision INTEGER NOT NULL DEFAULT 1,
        deleted INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (user_id, day_key)
      )
    ''');
    // O histórico é sempre lido por conta e por intervalo de datas.
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_${table}_user_day '
      'ON $table (user_id, day_key)',
    );
  }

  /// v29: `season` e `season_note` chegaram para a Estação Interna, e ficaram
  /// sem leitor desde que a estação saiu do app. As colunas continuam aqui, e
  /// esta migração também, porque a regra da casa é migrar para a frente: um
  /// telefone que já estava na v28 ganha as duas colunas vazias, sem perder
  /// nada, e uma linha antiga que ainda as traga é simplesmente ignorada
  /// pelo modelo (MenstrualDay.fromRow).
  static Future<void> addSeason(DatabaseExecutor db) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final existing = {for (final column in columns) '${column['name']}'};
    if (!existing.contains('season')) {
      await db.execute('ALTER TABLE $table ADD COLUMN season TEXT');
    }
    if (!existing.contains('season_note')) {
      await db.execute(
        "ALTER TABLE $table ADD COLUMN season_note TEXT NOT NULL DEFAULT ''",
      );
    }
  }
}
