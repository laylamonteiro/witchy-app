import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('grimorio_de_bolso.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;

    if (kIsWeb) {
      // Na web, usa apenas o nome do arquivo
      path = filePath;
    } else {
      // No mobile, usa o caminho completo
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabela de Feitiços
    await db.execute('''
      CREATE TABLE spells (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        purpose TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        moon_phase TEXT,
        ingredients TEXT,
        steps TEXT NOT NULL,
        duration INTEGER,
        observations TEXT,
        is_preloaded INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Tabela de Sonhos
    await db.execute('''
      CREATE TABLE dreams (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT,
        feeling TEXT,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Tabela de Desejos
    await db.execute('''
      CREATE TABLE desires (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        evolution TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Tabela de Rituais Diários
    await db.execute('''
      CREATE TABLE daily_rituals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        time TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    // Tabela de Registros de Rituais
    await db.execute('''
      CREATE TABLE ritual_logs (
        id TEXT PRIMARY KEY,
        ritual_id TEXT NOT NULL,
        notes TEXT,
        completed_at INTEGER NOT NULL,
        FOREIGN KEY (ritual_id) REFERENCES daily_rituals (id) ON DELETE CASCADE
      )
    ''');

    // Tabela de Sigilos
    await db.execute('''
      CREATE TABLE sigils (
        id TEXT PRIMARY KEY,
        intention TEXT NOT NULL,
        image_path TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Tabela de Gratidões
    await db.execute('''
      CREATE TABLE gratitudes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Tabela de Afirmações
    await db.execute('''
      CREATE TABLE affirmations (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        category TEXT NOT NULL,
        is_preloaded INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Mapas Astrais
    await db.execute('''
      CREATE TABLE birth_charts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        birth_date INTEGER NOT NULL,
        birth_time_hour INTEGER NOT NULL,
        birth_time_minute INTEGER NOT NULL,
        birth_place TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timezone TEXT NOT NULL,
        unknown_birth_time INTEGER NOT NULL DEFAULT 0,
        chart_data TEXT NOT NULL,
        calculated_at INTEGER NOT NULL
      )
    ''');

    // Tabela de Perfis Mágicos
    await db.execute('''
      CREATE TABLE magical_profiles (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        birth_chart_id TEXT NOT NULL,
        profile_data TEXT NOT NULL,
        generated_at INTEGER NOT NULL,
        FOREIGN KEY (birth_chart_id) REFERENCES birth_charts (id) ON DELETE CASCADE
      )
    ''');

    // Tabela de Leituras de Runas
    await db.execute('''
      CREATE TABLE rune_readings (
        id TEXT PRIMARY KEY,
        question TEXT NOT NULL,
        spread_type TEXT NOT NULL,
        reading_data TEXT NOT NULL,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Tabela de Consultas ao Pêndulo
    await db.execute('''
      CREATE TABLE pendulum_consultations (
        id TEXT PRIMARY KEY,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Tabela de Tiragens de Oracle Cards
    await db.execute('''
      CREATE TABLE oracle_readings (
        id TEXT PRIMARY KEY,
        spread_type TEXT NOT NULL,
        reading_data TEXT NOT NULL,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Migração da versão 1 para 2
    if (oldVersion < 2) {
      // Verificar se a tabela dreams existe, se não, criar
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='dreams'"
      );

      if (tables.isEmpty) {
        await db.execute('''
          CREATE TABLE dreams (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            tags TEXT,
            feeling TEXT,
            date INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      }

      // Verificar se a tabela desires existe, se não, criar
      final desiresTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='desires'"
      );

      if (desiresTable.isEmpty) {
        await db.execute('''
          CREATE TABLE desires (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            status TEXT NOT NULL,
            evolution TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      }

      // Verificar se a tabela daily_rituals existe, se não, criar
      final ritualsTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='daily_rituals'"
      );

      if (ritualsTable.isEmpty) {
        await db.execute('''
          CREATE TABLE daily_rituals (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            time TEXT NOT NULL,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at INTEGER NOT NULL
          )
        ''');
      }

      // Verificar se a tabela ritual_logs existe, se não, criar
      final logsTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='ritual_logs'"
      );

      if (logsTable.isEmpty) {
        await db.execute('''
          CREATE TABLE ritual_logs (
            id TEXT PRIMARY KEY,
            ritual_id TEXT NOT NULL,
            notes TEXT,
            completed_at INTEGER NOT NULL,
            FOREIGN KEY (ritual_id) REFERENCES daily_rituals (id) ON DELETE CASCADE
          )
        ''');
      }

      // Verificar se a tabela sigils existe, se não, criar
      final sigilsTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='sigils'"
      );

      if (sigilsTable.isEmpty) {
        await db.execute('''
          CREATE TABLE sigils (
            id TEXT PRIMARY KEY,
            intention TEXT NOT NULL,
            image_path TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      }
    }

    // Migração da versão 2 para 3
    if (oldVersion < 3) {
      // Adicionar campos category e is_preloaded na tabela spells
      try {
        // Verifica se a coluna já existe
        final columns = await db.rawQuery('PRAGMA table_info(spells)');
        final categoryExists = columns.any((col) => col['name'] == 'category');
        final isPreloadedExists = columns.any((col) => col['name'] == 'is_preloaded');

        if (!categoryExists) {
          await db.execute('ALTER TABLE spells ADD COLUMN category TEXT NOT NULL DEFAULT "other"');
        }
        if (!isPreloadedExists) {
          await db.execute('ALTER TABLE spells ADD COLUMN is_preloaded INTEGER NOT NULL DEFAULT 0');
        }
      } catch (e) {
        print('Erro ao adicionar colunas: $e');
      }
    }

    // Migração da versão 3 para 4
    if (oldVersion < 4) {
      // Verificar se a tabela gratitudes existe, se não, criar
      final gratitudesTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='gratitudes'"
      );

      if (gratitudesTable.isEmpty) {
        await db.execute('''
          CREATE TABLE gratitudes (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            tags TEXT,
            date INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      }

      // Verificar se a tabela affirmations existe, se não, criar
      final affirmationsTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='affirmations'"
      );

      if (affirmationsTable.isEmpty) {
        await db.execute('''
          CREATE TABLE affirmations (
            id TEXT PRIMARY KEY,
            text TEXT NOT NULL,
            category TEXT NOT NULL,
            is_preloaded INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            is_favorite INTEGER NOT NULL DEFAULT 0
          )
        ''');
      }
    }

    // Migração da versão 4 para 5
    if (oldVersion < 5) {
      // Verificar e criar tabela birth_charts
      final birthChartsTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='birth_charts'"
      );

      if (birthChartsTable.isEmpty) {
        await db.execute('''
          CREATE TABLE birth_charts (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            birth_date INTEGER NOT NULL,
            birth_time_hour INTEGER NOT NULL,
            birth_time_minute INTEGER NOT NULL,
            birth_place TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timezone TEXT NOT NULL,
            unknown_birth_time INTEGER NOT NULL DEFAULT 0,
            chart_data TEXT NOT NULL,
            calculated_at INTEGER NOT NULL
          )
        ''');
      }

      // Verificar e criar tabela magical_profiles
      final magicalProfilesTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='magical_profiles'"
      );

      if (magicalProfilesTable.isEmpty) {
        await db.execute('''
          CREATE TABLE magical_profiles (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            birth_chart_id TEXT NOT NULL,
            profile_data TEXT NOT NULL,
            generated_at INTEGER NOT NULL,
            FOREIGN KEY (birth_chart_id) REFERENCES birth_charts (id) ON DELETE CASCADE
          )
        ''');
      }

      // Verificar e criar tabela rune_readings
      final runeReadingsTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='rune_readings'"
      );

      if (runeReadingsTable.isEmpty) {
        await db.execute('''
          CREATE TABLE rune_readings (
            id TEXT PRIMARY KEY,
            question TEXT NOT NULL,
            spread_type TEXT NOT NULL,
            reading_data TEXT NOT NULL,
            date INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      }

      // Verificar e criar tabela pendulum_consultations
      final pendulumTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='pendulum_consultations'"
      );

      if (pendulumTable.isEmpty) {
        await db.execute('''
          CREATE TABLE pendulum_consultations (
            id TEXT PRIMARY KEY,
            question TEXT NOT NULL,
            answer TEXT NOT NULL,
            date INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      }

      // Verificar e criar tabela oracle_readings
      final oracleTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='oracle_readings'"
      );

      if (oracleTable.isEmpty) {
        await db.execute('''
          CREATE TABLE oracle_readings (
            id TEXT PRIMARY KEY,
            spread_type TEXT NOT NULL,
            reading_data TEXT NOT NULL,
            date INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      }
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
