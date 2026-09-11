import 'package:sqflite/sqflite.dart';

/// O registro menstrual (v28), guardado por conta e por dia.
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
}
