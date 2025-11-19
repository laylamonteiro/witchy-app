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
      version: 2,
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
        moon_phase TEXT,
        ingredients TEXT,
        steps TEXT NOT NULL,
        duration INTEGER,
        observations TEXT,
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
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
