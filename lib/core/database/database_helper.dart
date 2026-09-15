import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import '../../features/grimoire/data/models/spell_model.dart';
import '../../features/diary/data/models/free_writing_model.dart';
import 'menstrual_cycle_schema.dart';
import 'reading_session_schema.dart';
import 'tabelas_locais.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  /// A ABERTURA, não o banco aberto.
  ///
  /// Guardar só o resultado deixava uma janela: `_database` só era preenchido
  /// DEPOIS do await, então dois chamadores concorrentes antes da primeira
  /// resolução abriam duas conexões sobre o mesmo arquivo — e na web, onde o
  /// SQLite vive num sistema de arquivos sobre IndexedDB com índice único no
  /// nome, a segunda conexão é `ConstraintError` na cara. Acontecia no
  /// caminho de retomada do boot (BootErrorApp → _boot de novo). Guardando o
  /// Future, o segundo chamador espera o mesmo trabalho em vez de repeti-lo —
  /// a mesma trava que a sincronização usa em `_varreduraEmVoo`.
  static Future<Database>? _abertura;

  DatabaseHelper._init();

  Future<Database> get database => _abertura ??= _abrirLimpandoEmFalha();

  /// Abertura que FALHOU não pode ficar guardada: a retomada do boot
  /// (BootErrorApp → _boot de novo) precisa poder tentar outra vez, senão o
  /// primeiro erro condenaria a sessão inteira.
  Future<Database> _abrirLimpandoEmFalha() async {
    try {
      return await _initDB('grimorio_de_bolso.db');
    } catch (_) {
      _abertura = null;
      rethrow;
    }
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

    // SEM `PRAGMA foreign_keys = ON`, e é decisão, não esquecimento.
    //
    // O SQLite ignora declaração de chave estrangeira a menos que o pragma
    // esteja ligado — por CONEXÃO, não por banco. As duas que existem aqui
    // (ritual_logs → daily_rituals e magical_profiles → birth_charts, ambas
    // com ON DELETE CASCADE) não conferem nada e não cascateiam nada. Elas
    // ficam porque documentam o parentesco e porque no POSTGRES, onde o
    // sync grava, são conferidas de verdade (supabase/restore_database.sql).
    //
    // Ligar o pragma num banco que já existe teria três efeitos, e o
    // primeiro é o que decidiu:
    //
    // 1. `saveBirthChart` grava com `ConflictAlgorithm.replace`, e no SQLite
    //    REPLACE numa linha existente é DELETE + INSERT. Com o pragma ligado
    //    esse DELETE dispara o CASCADE — ou seja, regravar o mapa sob o
    //    mesmo id APAGARIA a Análise Personalizada, as dez seções que
    //    custaram dez chamadas de IA. Hoje é inofensivo justamente porque a
    //    chave é decorativa.
    // 2. Download de sync que hoje aterrissa como órfão (um registro de
    //    ritual cujo ritual não veio junto) passaria a ser RECUSADO.
    // 3. Bancos já instalados guardam órfãos. O pragma não valida o que já
    //    está lá, mas todo UPDATE naquelas linhas passaria a falhar.
    //
    // Para ligar um dia, nesta ordem: trocar o REPLACE de `birth_charts` por
    // update-ou-insert explícito; migração varrendo os órfãos existentes;
    // `PRAGMA defer_foreign_keys = ON` dentro da transação do fullDownload;
    // e só então o pragma em `onConfigure` (dentro de onCreate/onUpgrade ele
    // é no-op — o sqflite envolve os dois numa transação).
    return await openDatabase(
      path,
      version: 30,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabela de Feitiços
    await db.execute('''
      CREATE TABLE spells (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
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
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Sonhos
    await db.execute('''
      CREATE TABLE dreams (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT,
        feeling TEXT,
        interpretation TEXT,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Desejos
    await db.execute('''
      CREATE TABLE desires (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        evolution TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Rituais Diários
    await db.execute('''
      CREATE TABLE daily_rituals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        name TEXT NOT NULL,
        description TEXT,
        time TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Registros de Rituais
    await db.execute('''
      CREATE TABLE ritual_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        ritual_id TEXT NOT NULL,
        notes TEXT,
        completed_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (ritual_id) REFERENCES daily_rituals (id) ON DELETE CASCADE
      )
    ''');

    // Tabela de Sigilos
    await db.execute('''
      CREATE TABLE sigils (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        intention TEXT NOT NULL,
        image_path TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Gratidões
    await db.execute('''
      CREATE TABLE gratitudes (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Afirmações
    await db.execute('''
      CREATE TABLE affirmations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        text TEXT NOT NULL,
        category TEXT NOT NULL,
        is_preloaded INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Acervo de escrita: reflexões livres (source='free', sem título) e
    // páginas geradas — lições do Grimório Vivo e leituras (com título).
    await db.execute('''
      CREATE TABLE free_writings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        title TEXT,
        content TEXT NOT NULL,
        source TEXT NOT NULL DEFAULT 'free',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Progresso do Grimório Vivo (lições concluídas, sincronizável)
    await db.execute('''
      CREATE TABLE learning_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        lesson_id TEXT NOT NULL,
        completed_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_learning_progress_user_id ON learning_progress(user_id)');

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
        calculated_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
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
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (birth_chart_id) REFERENCES birth_charts (id) ON DELETE CASCADE
      )
    ''');

    // Tabela de Leituras de Runas
    await db.execute('''
      CREATE TABLE rune_readings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        question TEXT NOT NULL,
        spread_type TEXT NOT NULL,
        reading_data TEXT NOT NULL,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Consultas ao Pêndulo
    await db.execute('''
      CREATE TABLE pendulum_consultations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Tiragens de Oracle Cards
    await db.execute('''
      CREATE TABLE oracle_readings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        spread_type TEXT NOT NULL,
        question TEXT,
        reading_data TEXT NOT NULL,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Clima Mágico Diário (gerado por IA)
    await db.execute('''
      CREATE TABLE daily_magical_weather (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        date TEXT NOT NULL,
        ai_generated_text TEXT NOT NULL,
        weather_data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        UNIQUE(user_id, date)
      )
    ''');

    // Check-in diário: um registro por dia visitado (sequência de dias) com
    // os "ritos do dia" concluídos, separados por vírgula.
    await db.execute('''
      CREATE TABLE daily_checkins (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        date TEXT NOT NULL,
        rites TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        UNIQUE(user_id, date)
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_daily_checkins_user_id ON daily_checkins(user_id)');

    // Tabela de Códigos Premium para acesso Premium
    await db.execute('''
      CREATE TABLE beta_codes (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        is_used INTEGER NOT NULL DEFAULT 0,
        used_by TEXT,
        used_at INTEGER,
        created_at INTEGER NOT NULL,
        max_uses INTEGER NOT NULL DEFAULT 1,
        current_uses INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Registro de rituais guiados concluídos (sabbats, luas, águas mágicas).
    // ritual_id referencia ids estáticos de AllGuidedRituals (não é FK).
    await db.execute('''
      CREATE TABLE guided_ritual_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        ritual_id TEXT NOT NULL,
        event_date INTEGER,
        xp INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        completed_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Entradas pessoais da enciclopédia (foto + página gerada por IA).
    // `data` guarda o JSON com os campos do modelo da categoria.
    await db.execute('''
      CREATE TABLE user_encyclopedia_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        category TEXT NOT NULL,
        name TEXT NOT NULL,
        image_path TEXT,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Leituras do Ciclo (compra avulsa): o crédito da compra e o vínculo
    // com o relatório gerado (free_writings). `status` = 'pending' enquanto
    // a compra ainda não virou relatório salvo — é o que garante "falha de
    // geração não consome a compra".
    await db.execute('''
      CREATE TABLE cycle_readings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        period_type TEXT NOT NULL DEFAULT 'lunation',
        period_start INTEGER NOT NULL,
        period_end INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        origin TEXT NOT NULL DEFAULT 'purchase',
        product_id TEXT,
        writing_id TEXT,
        regenerations_used INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_cycle_readings_user_id ON cycle_readings(user_id)');

    // Tabela de Tiragens de Tarô (ver _createTarotReadingsSql)
    await db.execute(_createTarotReadingsSql);
    await db.execute(
        'CREATE INDEX idx_tarot_readings_user_id ON tarot_readings(user_id)');
    await ReadingSessionSchema.create(db);
    // O registro menstrual nasce com o banco, com a mesma definição da
    // migração v28.
    await MenstrualCycleSchema.create(db);

    // Lápides da sincronização (ver _createSyncTombstonesSql)
    await db.execute(_createSyncTombstonesSql);

    // Criar índices para user_id em todas as tabelas
    await db.execute('CREATE INDEX idx_spells_user_id ON spells(user_id)');
    await db.execute(
      'CREATE INDEX idx_spells_preloaded_user_id '
      'ON spells(is_preloaded, user_id)',
    );
    await db.execute('CREATE INDEX idx_dreams_user_id ON dreams(user_id)');
    await db.execute('CREATE INDEX idx_desires_user_id ON desires(user_id)');
    await db.execute(
        'CREATE INDEX idx_daily_rituals_user_id ON daily_rituals(user_id)');
    await db.execute(
        'CREATE INDEX idx_ritual_logs_user_id ON ritual_logs(user_id)');
    await db.execute('CREATE INDEX idx_sigils_user_id ON sigils(user_id)');
    await db
        .execute('CREATE INDEX idx_gratitudes_user_id ON gratitudes(user_id)');
    await db.execute(
        'CREATE INDEX idx_free_writings_user_id ON free_writings(user_id)');
    await db.execute(
        'CREATE INDEX idx_affirmations_user_id ON affirmations(user_id)');
    await db.execute(
        'CREATE INDEX idx_birth_charts_user_id ON birth_charts(user_id)');
    await db.execute(
        'CREATE INDEX idx_magical_profiles_user_id ON magical_profiles(user_id)');
    await db.execute(
        'CREATE INDEX idx_rune_readings_user_id ON rune_readings(user_id)');
    await db.execute(
        'CREATE INDEX idx_pendulum_user_id ON pendulum_consultations(user_id)');
    await db.execute(
        'CREATE INDEX idx_oracle_readings_user_id ON oracle_readings(user_id)');
    await db.execute(
        'CREATE INDEX idx_weather_user_id ON daily_magical_weather(user_id)');
    await db.execute(
        'CREATE INDEX idx_guided_ritual_logs_user_id ON guided_ritual_logs(user_id)');
    await db.execute(
        'CREATE INDEX idx_user_ency_entries_user_id ON user_encyclopedia_entries(user_id)');
  }

  /// Migra o banco de dados de uma versão antiga para a nova
  ///
  /// ⚠️ REGRA CRÍTICA: Migrações DEVEM preservar TODOS os dados existentes!
  ///
  /// Práticas obrigatórias:
  /// - ✅ Adicionar novas tabelas
  /// - ✅ Adicionar novas colunas (com ALTER TABLE ADD COLUMN)
  /// - ✅ Criar novos índices
  /// - ✅ Verificar existência antes de criar (IF NOT EXISTS)
  /// - ❌ NUNCA deletar tabelas (DROP TABLE)
  /// - ❌ NUNCA deletar colunas (não suportado em SQLite)
  /// - ❌ NUNCA limpar dados (DELETE, TRUNCATE)
  ///
  /// Atualizações do app devem ser transparentes para o usuário.
  /// Dados devem ser mantidos independente da versão anterior.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Migração da versão 1 para 2
    if (oldVersion < 2) {
      // Verificar se a tabela dreams existe, se não, criar
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='dreams'");

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
          "SELECT name FROM sqlite_master WHERE type='table' AND name='desires'");

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
          "SELECT name FROM sqlite_master WHERE type='table' AND name='daily_rituals'");

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
          "SELECT name FROM sqlite_master WHERE type='table' AND name='ritual_logs'");

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
          "SELECT name FROM sqlite_master WHERE type='table' AND name='sigils'");

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
        final isPreloadedExists =
            columns.any((col) => col['name'] == 'is_preloaded');

        if (!categoryExists) {
          await db.execute(
              'ALTER TABLE spells ADD COLUMN category TEXT NOT NULL DEFAULT "other"');
        }
        if (!isPreloadedExists) {
          await db.execute(
              'ALTER TABLE spells ADD COLUMN is_preloaded INTEGER NOT NULL DEFAULT 0');
        }
      } catch (e) {
        print('Erro ao adicionar colunas: $e');
      }
    }

    // Migração da versão 3 para 4
    if (oldVersion < 4) {
      // Verificar se a tabela gratitudes existe, se não, criar
      final gratitudesTable = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='gratitudes'");

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
          "SELECT name FROM sqlite_master WHERE type='table' AND name='affirmations'");

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
          "SELECT name FROM sqlite_master WHERE type='table' AND name='birth_charts'");

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
          "SELECT name FROM sqlite_master WHERE type='table' AND name='magical_profiles'");

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
          "SELECT name FROM sqlite_master WHERE type='table' AND name='rune_readings'");

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
          "SELECT name FROM sqlite_master WHERE type='table' AND name='pendulum_consultations'");

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
          "SELECT name FROM sqlite_master WHERE type='table' AND name='oracle_readings'");

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

    // Migração da versão 5 para 6
    if (oldVersion < 6) {
      // Verificar e criar tabela daily_magical_weather
      final weatherTable = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='daily_magical_weather'");

      if (weatherTable.isEmpty) {
        await db.execute('''
          CREATE TABLE daily_magical_weather (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL UNIQUE,
            ai_generated_text TEXT NOT NULL,
            weather_data TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      }
    }

    // Migração da versão 6 para 7 - Adicionar user_id para multi-usuário
    if (oldVersion < 7) {
      // Lista de tabelas que precisam de user_id
      final tables = [
        'spells',
        'dreams',
        'desires',
        'daily_rituals',
        'ritual_logs',
        'sigils',
        'gratitudes',
        'affirmations',
        'rune_readings',
        'pendulum_consultations',
        'oracle_readings',
        'daily_magical_weather',
      ];

      for (final table in tables) {
        try {
          // Verifica se a coluna user_id já existe
          final columns = await db.rawQuery('PRAGMA table_info($table)');
          final hasUserId = columns.any((col) => col['name'] == 'user_id');

          if (!hasUserId) {
            await db.execute(
                "ALTER TABLE $table ADD COLUMN user_id TEXT NOT NULL DEFAULT 'local_user'");
            print('Adicionado user_id na tabela $table');
          }
        } catch (e) {
          print('Erro ao adicionar user_id na tabela $table: $e');
        }
      }

      // Criar índices para user_id (com tratamento de erro para índices existentes)
      final indexQueries = [
        'CREATE INDEX IF NOT EXISTS idx_spells_user_id ON spells(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_dreams_user_id ON dreams(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_desires_user_id ON desires(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_daily_rituals_user_id ON daily_rituals(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_ritual_logs_user_id ON ritual_logs(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_sigils_user_id ON sigils(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_gratitudes_user_id ON gratitudes(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_affirmations_user_id ON affirmations(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_birth_charts_user_id ON birth_charts(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_magical_profiles_user_id ON magical_profiles(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_rune_readings_user_id ON rune_readings(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_pendulum_user_id ON pendulum_consultations(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_oracle_readings_user_id ON oracle_readings(user_id)',
        'CREATE INDEX IF NOT EXISTS idx_weather_user_id ON daily_magical_weather(user_id)',
      ];

      for (final query in indexQueries) {
        try {
          await db.execute(query);
        } catch (e) {
          print('Erro ao criar índice: $e');
        }
      }

      // Remover UNIQUE constraint da tabela daily_magical_weather se existir
      // (agora cada usuário pode ter seu próprio clima para cada data)
      try {
        // Não é possível remover constraints em SQLite diretamente,
        // mas o índice de user_id vai ajudar nas queries
      } catch (e) {
        print('Erro na migração da tabela weather: $e');
      }
    }

    // Migração da versão 7 para 8 - Adicionar colunas synced e updated_at para sincronização
    if (oldVersion < 8) {
      // Lista de tabelas que precisam de synced e updated_at
      final tables = [
        'spells',
        'dreams',
        'desires',
        'daily_rituals',
        'ritual_logs',
        'sigils',
        'gratitudes',
        'affirmations',
        'birth_charts',
        'magical_profiles',
        'rune_readings',
        'pendulum_consultations',
        'oracle_readings',
        'daily_magical_weather',
      ];

      for (final table in tables) {
        try {
          // Verifica quais colunas existem
          final columns = await db.rawQuery('PRAGMA table_info($table)');
          final hasSynced = columns.any((col) => col['name'] == 'synced');
          final hasUpdatedAt =
              columns.any((col) => col['name'] == 'updated_at');

          if (!hasSynced) {
            await db.execute(
                'ALTER TABLE $table ADD COLUMN synced INTEGER NOT NULL DEFAULT 0');
            print('Adicionado synced na tabela $table');
          }

          if (!hasUpdatedAt) {
            // Usar created_at como valor inicial para updated_at, ou timestamp atual
            await db.execute(
                'ALTER TABLE $table ADD COLUMN updated_at INTEGER NOT NULL DEFAULT ${DateTime.now().millisecondsSinceEpoch}');
            // Atualizar updated_at com created_at onde existir
            try {
              await db.execute(
                  'UPDATE $table SET updated_at = created_at WHERE created_at IS NOT NULL');
            } catch (e) {
              // Algumas tabelas podem não ter created_at
              print('Tabela $table não tem created_at: $e');
            }
            print('Adicionado updated_at na tabela $table');
          }
        } catch (e) {
          print('Erro ao adicionar colunas de sync na tabela $table: $e');
        }
      }

      // Criar índices para synced (para queries de itens pendentes)
      final syncIndexQueries = [
        'CREATE INDEX IF NOT EXISTS idx_spells_synced ON spells(synced)',
        'CREATE INDEX IF NOT EXISTS idx_dreams_synced ON dreams(synced)',
        'CREATE INDEX IF NOT EXISTS idx_desires_synced ON desires(synced)',
        'CREATE INDEX IF NOT EXISTS idx_daily_rituals_synced ON daily_rituals(synced)',
        'CREATE INDEX IF NOT EXISTS idx_ritual_logs_synced ON ritual_logs(synced)',
        'CREATE INDEX IF NOT EXISTS idx_sigils_synced ON sigils(synced)',
        'CREATE INDEX IF NOT EXISTS idx_gratitudes_synced ON gratitudes(synced)',
        'CREATE INDEX IF NOT EXISTS idx_affirmations_synced ON affirmations(synced)',
        'CREATE INDEX IF NOT EXISTS idx_birth_charts_synced ON birth_charts(synced)',
        'CREATE INDEX IF NOT EXISTS idx_magical_profiles_synced ON magical_profiles(synced)',
        'CREATE INDEX IF NOT EXISTS idx_rune_readings_synced ON rune_readings(synced)',
        'CREATE INDEX IF NOT EXISTS idx_pendulum_synced ON pendulum_consultations(synced)',
        'CREATE INDEX IF NOT EXISTS idx_oracle_readings_synced ON oracle_readings(synced)',
        'CREATE INDEX IF NOT EXISTS idx_weather_synced ON daily_magical_weather(synced)',
      ];

      for (final query in syncIndexQueries) {
        try {
          await db.execute(query);
        } catch (e) {
          print('Erro ao criar índice de sync: $e');
        }
      }

      print('Migração v8 concluída - colunas de sincronização adicionadas');
    }

    // Migração da versão 8 para 9 - Adicionar tabela de Códigos Premium
    if (oldVersion < 9) {
      final betaCodesTable = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='beta_codes'");

      if (betaCodesTable.isEmpty) {
        await db.execute('''
          CREATE TABLE beta_codes (
            id TEXT PRIMARY KEY,
            code TEXT NOT NULL UNIQUE,
            is_used INTEGER NOT NULL DEFAULT 0,
            used_by TEXT,
            used_at INTEGER,
            created_at INTEGER NOT NULL
          )
        ''');
        print('Tabela beta_codes criada');
      }
    }

    // Migração da versão 9 para 10 - Adicionar suporte a múltiplos usos nos Códigos Premium
    if (oldVersion < 10) {
      print(
          'Iniciando migração v9 -> v10: Adicionando suporte a múltiplos usos em beta_codes');

      // Verificar se as colunas já existem
      final tableInfo = await db.rawQuery('PRAGMA table_info(beta_codes)');
      final columnNames =
          tableInfo.map((col) => col['name'] as String).toList();

      if (!columnNames.contains('max_uses')) {
        await db.execute(
            'ALTER TABLE beta_codes ADD COLUMN max_uses INTEGER NOT NULL DEFAULT 1');
        print('Coluna max_uses adicionada');
      }

      if (!columnNames.contains('current_uses')) {
        await db.execute(
            'ALTER TABLE beta_codes ADD COLUMN current_uses INTEGER NOT NULL DEFAULT 0');
        print('Coluna current_uses adicionada');
      }

      // Migrar dados existentes: códigos já usados devem ter current_uses = 1
      await db.execute('''
        UPDATE beta_codes
        SET current_uses = 1, max_uses = 1
        WHERE is_used = 1 AND current_uses = 0
      ''');

      // Códigos não usados mantêm max_uses = 1 e current_uses = 0
      await db.execute('''
        UPDATE beta_codes
        SET max_uses = 1, current_uses = 0
        WHERE is_used = 0 AND current_uses = 0
      ''');

      print('Migração v10 concluída - suporte a múltiplos usos adicionado');
    }

    // Migração v11: cache diário único por usuário, preservando os dados.
    if (oldVersion < 11) {
      await db.transaction((txn) async {
        await txn.execute('''
          CREATE TABLE daily_magical_weather_v11 (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL DEFAULT 'local_user',
            date TEXT NOT NULL,
            ai_generated_text TEXT NOT NULL,
            weather_data TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0,
            UNIQUE(user_id, date)
          )
        ''');
        await txn.execute('''
          INSERT OR REPLACE INTO daily_magical_weather_v11
            (id, user_id, date, ai_generated_text, weather_data,
             created_at, updated_at, synced)
          SELECT id, COALESCE(user_id, 'local_user'), date,
                 ai_generated_text, weather_data, created_at,
                 COALESCE(updated_at, created_at), COALESCE(synced, 0)
          FROM daily_magical_weather
        ''');
        await txn.execute('DROP TABLE daily_magical_weather');
        await txn.execute(
          'ALTER TABLE daily_magical_weather_v11 RENAME TO daily_magical_weather',
        );
        await txn.execute(
          'CREATE INDEX idx_weather_user_id ON daily_magical_weather(user_id)',
        );
        await txn.execute(
          'CREATE INDEX idx_weather_synced ON daily_magical_weather(synced)',
        );
      });
    }

    // Migração v12: tabela de Escrita Livre (reflexões da aba 💡 de Diários).
    if (oldVersion < 12) {
      final freeWritingsTable = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='free_writings'");

      if (freeWritingsTable.isEmpty) {
        await db.execute('''
          CREATE TABLE free_writings (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL DEFAULT 'local_user',
            content TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_free_writings_user_id ON free_writings(user_id)');
      }
    }

    // Migração v13: feitiços precarregados são globais e não pertencem a um usuário local.
    if (oldVersion < 13) {
      await db.execute(
        """
        UPDATE spells
        SET user_id = '${SpellModel.globalUserId}', synced = 1
        WHERE is_preloaded = 1
          AND (user_id IS NULL OR user_id IN ('local_user', 'current_user'))
        """,
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_spells_preloaded_user_id '
        'ON spells(is_preloaded, user_id)',
      );
    }

    // Migração v14: interpretação de sonhos por IA salva junto do sonho.
    if (oldVersion < 14) {
      final dreamCols = await db.rawQuery('PRAGMA table_info(dreams)');
      final hasInterpretation =
          dreamCols.any((col) => col['name'] == 'interpretation');
      if (!hasInterpretation) {
        await db.execute('ALTER TABLE dreams ADD COLUMN interpretation TEXT');
      }
    }

    // Migração v15: remove feitiços ancestrais duplicados. O seed antigo
    // comparava por id (que era regenerado a cada execução) e re-inseria os
    // precarregados a cada abertura do app. Mantém o registro mais antigo de
    // cada nome e normaliza o dono global.
    if (oldVersion < 15) {
      await db.execute('''
        DELETE FROM spells
        WHERE is_preloaded = 1
          AND rowid NOT IN (
            SELECT MIN(rowid) FROM spells
            WHERE is_preloaded = 1
            GROUP BY LOWER(TRIM(name))
          )
      ''');
      await db.execute(
        """
        UPDATE spells
        SET user_id = '${SpellModel.globalUserId}', synced = 1
        WHERE is_preloaded = 1
        """,
      );
    }

    // Migração v16: progresso do Grimório Vivo passa a viver no banco
    // (antes ficava só em SharedPreferences) para sincronizar entre
    // dispositivos como os demais registros.
    if (oldVersion < 16) {
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='learning_progress'");
      if (tables.isEmpty) {
        await db.execute('''
          CREATE TABLE learning_progress (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL DEFAULT 'local_user',
            lesson_id TEXT NOT NULL,
            completed_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_learning_progress_user_id ON learning_progress(user_id)');
      }
    }

    // Migração para versão 17: rituais guiados + enciclopédia pessoal
    if (oldVersion < 17) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS guided_ritual_logs (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL DEFAULT 'local_user',
          ritual_id TEXT NOT NULL,
          event_date INTEGER,
          xp INTEGER NOT NULL DEFAULT 0,
          notes TEXT,
          completed_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          synced INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_guided_ritual_logs_user_id ON guided_ritual_logs(user_id)');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_encyclopedia_entries (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL DEFAULT 'local_user',
          category TEXT NOT NULL,
          name TEXT NOT NULL,
          image_path TEXT,
          data TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          synced INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_user_ency_entries_user_id ON user_encyclopedia_entries(user_id)');
    }

    // Migração para versão 18: check-in diário (sequência de dias + ritos)
    if (oldVersion < 18) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_checkins (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL DEFAULT 'local_user',
          date TEXT NOT NULL,
          rites TEXT NOT NULL DEFAULT '',
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          synced INTEGER NOT NULL DEFAULT 0,
          UNIQUE(user_id, date)
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_daily_checkins_user_id ON daily_checkins(user_id)');
    }

    if (oldVersion < 19) {
      // ORDEM IMPORTA: o clima antigo é a prova de que o app foi aberto
      // naquele dia (a linha só nasce quando alguém abre a página), então
      // ele alimenta a reconstrução das visitas ANTES de ser podado.
      await _backfillCheckinsFromHistory(db);
      await _keepLatestWeatherPerUser(db);
    }

    // v20: acervo único de escrita — free_writings ganha título (páginas
    // geradas) e origem. Guarda por PRAGMA: idempotente mesmo se a versão
    // gravada e o schema real divergirem.
    if (oldVersion < 20) {
      final cols = await db.rawQuery('PRAGMA table_info(free_writings)');
      if (!cols.any((c) => c['name'] == 'title')) {
        await db.execute('ALTER TABLE free_writings ADD COLUMN title TEXT');
      }
      if (!cols.any((c) => c['name'] == 'source')) {
        await db.execute(
            "ALTER TABLE free_writings ADD COLUMN source TEXT NOT NULL DEFAULT 'free'");
      }
    }

    // v21: Leitura do Ciclo — registro da compra avulsa + período coberto.
    if (oldVersion < 21) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cycle_readings (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL DEFAULT 'local_user',
          period_type TEXT NOT NULL DEFAULT 'lunation',
          period_start INTEGER NOT NULL,
          period_end INTEGER NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          origin TEXT NOT NULL DEFAULT 'purchase',
          product_id TEXT,
          writing_id TEXT,
          regenerations_used INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          synced INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_cycle_readings_user_id ON cycle_readings(user_id)');
    }

    // v22: tiragens de Tarô persistidas (como runas/oráculo/pêndulo já eram).
    // Sem isso, a tiragem só existia se salva à mão no acervo — e a Leitura
    // do Ciclo não enxergava o tarô do período. `signature` deduplica a
    // mesma mesa (ex.: a carta do dia reaberta) sem criar linha nova.
    if (oldVersion < 22) {
      await db.execute(_createTarotReadingsSql);
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_tarot_readings_user_id ON tarot_readings(user_id)');
    }

    // v23: lápides da sincronização. Sem elas, o item apagado num aparelho
    // ressuscita no download do sync seguinte — o apagar local sumia com a
    // linha e, se o aviso à nuvem falhasse, a cópia do servidor voltava.
    if (oldVersion < 23) {
      await db.execute(_createSyncTombstonesSql);
    }
    if (oldVersion < 24) {
      await ReadingSessionSchema.create(db);
    }
    // v25: álbum do Oráculo (oracle_discoveries). Mesma definição idempotente.
    // v26: consultas do Conselheiro (advisor_consultations).
    // v27: marcos das jornadas (progress_milestones).
    if (oldVersion < 27) {
      await ReadingSessionSchema.create(db);
    }
    // v28: registro menstrual. Tabela própria, fora da Leitura do Ciclo, do
    // XP, das ofertas e da telemetria.
    if (oldVersion < 28) {
      await MenstrualCycleSchema.create(db);
    }
    // v29: as colunas da Estação Interna. A estação saiu do app e ninguém
    // mais lê as colunas; a migração fica porque a casa só migra para a
    // frente (menstrual_cycle_schema.dart explica).
    if (oldVersion < 29) {
      await MenstrualCycleSchema.addSeason(db);
    }
    // v30: a pergunta do dia deixa de ser só do tarô. A tabela nova nasce
    // sabendo o que `tarot_day_state` já sabia — e a velha fica onde está: a
    // casa só migra para a frente, e apagar tabela não é migração aditiva.
    if (oldVersion < 30) {
      await ReadingSessionSchema.create(db);
      await db.execute('''
        INSERT OR IGNORE INTO day_question_state
          (user_id, day_key, tool, daily_question, last_question, synced)
        SELECT user_id, day_key, 'tarot', daily_question, last_question, 0
        FROM tarot_day_state
      ''');

      // A Carta do Dia volta a ser UMA por dia: a pergunta sai da identidade
      // dela. A ORDEM destes três passos importa, e inverter derruba a
      // abertura do app — criar o índice antes de desempatar estoura em
      // "UNIQUE constraint failed" e leva a migração inteira junto.
      //
      // 1. Desempatar: onde já houve mais de uma carta do dia no mesmo dia
      //    (perguntas diferentes), fica a PRIMEIRA — a que a pessoa chamou de
      //    "a minha de hoje". As outras perdem só a sessão de escolha; as
      //    tiragens em si continuam em `tarot_readings`, em Meus Registros e
      //    no acervo, que esta migração não toca.
      await db.execute('''
        DELETE FROM selection_sessions
        WHERE tool = 'tarot' AND spread = 'daily' AND rowid NOT IN (
          SELECT MIN(rowid) FROM selection_sessions
          WHERE tool = 'tarot' AND spread = 'daily'
          GROUP BY user_id, day_key
        )
      ''');
      // 2. O índice velho carrega a pergunta na chave; `IF NOT EXISTS` não o
      //    redefiniria, então ele precisa cair.
      await db.execute('DROP INDEX IF EXISTS idx_daily_selection_identity');
      // 3. E o novo entra sem ela.
      await db.execute('''
        CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_selection_identity
        ON selection_sessions(user_id, tool, spread, day_key)
        WHERE tool = 'tarot' AND spread = 'daily'
      ''');
      // A carta do dia deixou de ter pergunta: as que ficaram guardam uma que
      // não vale mais, e deixá-la ali faria a tela citar uma pergunta que a
      // pessoa não fez para aquela carta.
      await db.execute('''
        UPDATE selection_sessions SET question = '', normalized_question = ''
        WHERE tool = 'tarot' AND spread = 'daily'
      ''');

      // O Oráculo ganhou pergunta e era a única das quatro adivinhações sem
      // uma. Nullable de propósito, sem DEFAULT '': assim "tiragem antiga, de
      // quando não havia pergunta" continua distinguível de "a pessoa escolheu
      // não escrever nada".
      // A tabela pode não existir: ela nasce na migração v5, que um aparelho
      // vindo de uma versão posterior nunca roda. Sem esta guarda, o ALTER
      // estoura em "no such table" e derruba a migração — e migração que falha
      // é app que não abre.
      final temOracle = await db.rawQuery("SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name = 'oracle_readings'");
      if (temOracle.isNotEmpty) {
        final colunas = await db.rawQuery('PRAGMA table_info(oracle_readings)');
        if (!colunas.any((c) => c['name'] == 'question')) {
          await db
              .execute('ALTER TABLE oracle_readings ADD COLUMN question TEXT');
        }
      }
    }
  }

  /// SQL da tabela de tiragens de Tarô — compartilhado entre onCreate e a
  /// migração v22 para nunca divergirem.
  ///
  /// Local-only por enquanto (fora do DataSyncService): espelhar exige a
  /// tabela correspondente no Supabase — quando ela existir, basta
  /// adicionar o SyncEntity.
  static const _createTarotReadingsSql = '''
      CREATE TABLE IF NOT EXISTS tarot_readings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        question TEXT,
        spread_type TEXT NOT NULL,
        signature TEXT,
        reading_data TEXT NOT NULL,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''';

  /// SQL das lápides da sincronização — compartilhado entre onCreate e a
  /// migração v23 para nunca divergirem.
  ///
  /// Uma lápide registra "este item foi apagado, e quando". É ela que impede
  /// o download da sincronização de ressuscitar o que a pessoa apagou:
  /// `entity` é o nome do `SyncEntity` (o mesmo dos dois lados, local e
  /// Supabase), `deleted_at` decide quem vence quando o item foi editado ou
  /// recriado depois da exclusão, e `synced` marca se a exclusão já chegou
  /// ao servidor.
  static const _createSyncTombstonesSql = '''
      CREATE TABLE IF NOT EXISTS sync_tombstones (
        entity TEXT NOT NULL,
        item_id TEXT NOT NULL,
        user_id TEXT NOT NULL DEFAULT 'local_user',
        deleted_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (entity, item_id, user_id)
      )
    ''';

  /// Reconstrói `daily_checkins` a partir do rastro que o app já tinha:
  /// conteúdo criado, lições concluídas e climas consultados. Conserta a
  /// sequência de quem usou o app antes de o check-in existir (ou antes de
  /// ele passar a gravar todo dia).
  Future<void> _backfillCheckinsFromHistory(Database db) async {
    const evidence = <String, String>{
      'spells': 'created_at',
      'dreams': 'created_at',
      'gratitudes': 'created_at',
      'affirmations': 'created_at',
      'desires': 'created_at',
      'sigils': 'created_at',
      'rune_readings': 'created_at',
      'oracle_readings': 'created_at',
      'pendulum_consultations': 'created_at',
      'user_encyclopedia_entries': 'created_at',
      'guided_ritual_logs': 'created_at',
      'learning_progress': 'completed_at',
    };

    final found = <String, Set<String>>{};

    Future<void> collect(String sql) async {
      try {
        for (final row in await db.rawQuery(sql)) {
          final user = row['user_id'] as String?;
          final day = row['day'] as String?;
          if (user == null || day == null || day.isEmpty) continue;
          found.putIfAbsent(user, () => <String>{}).add(day);
        }
      } catch (_) {
        // Tabela ausente nesta base: segue com as demais.
      }
    }

    for (final entry in evidence.entries) {
      await collect(
        'SELECT DISTINCT user_id, '
        "date(${entry.value} / 1000, 'unixepoch', 'localtime') AS day "
        'FROM ${entry.key}',
      );
    }
    await collect(
      'SELECT DISTINCT user_id, date AS day FROM daily_magical_weather',
    );

    if (found.isEmpty) return;

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final batch = db.batch();
    for (final entry in found.entries) {
      for (final day in entry.value) {
        batch.insert(
          'daily_checkins',
          {
            'id': '${entry.key}_$day',
            'user_id': entry.key,
            'date': day,
            'rites': '',
            'created_at': stamp,
            'updated_at': stamp,
            'synced': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    await batch.commit(noResult: true);
  }

  /// Deixa só o clima mais recente de cada pessoa: ele vale por um dia e
  /// nenhuma tela lê data passada, então o histórico era acúmulo puro.
  Future<void> _keepLatestWeatherPerUser(Database db) async {
    try {
      await db.execute('''
        DELETE FROM daily_magical_weather
        WHERE id NOT IN (
          SELECT id FROM daily_magical_weather AS w
          WHERE w.date = (
            SELECT MAX(date) FROM daily_magical_weather AS m
            WHERE m.user_id = w.user_id
          )
        )
      ''');
    } catch (_) {
      // Base sem a tabela: nada a podar.
    }
  }

  /// As tabelas que a adoção de dados anônimos precisa varrer.
  ///
  /// Derivada de [TabelasLocais.conteudo], e não escrita à mão: a lista que
  /// existia aqui já tinha perdido `tarot_readings` — uma tiragem feita antes
  /// do login continuava presa a 'local_user', sumia da tela ao entrar na
  /// conta e nunca subia para a nuvem. Mesma família do que aconteceu com a
  /// exclusão de conta e com as duas limpezas locais. Derivando da lista
  /// canônica, tabela nova nasce adotada — inclusive a que não sincroniza,
  /// que também nasce anônima.
  ///
  /// O registro menstrual entra por ser conteúdo dela, e não por sincronizar:
  /// entrar na conta no mesmo aparelho não pode fazê-la perder o que já
  /// escreveu. Se um dia o envio sair do `SyncEntity`, a adoção continua.
  ///
  /// `spells` sai da lista porque é tratada à parte: os feitiços
  /// pré-carregados do app não pertencem a ninguém e não podem ser adotados.
  /// Os contadores de cota saem porque não têm a coluna que o laço abaixo
  /// carimba — ver [TabelasLocais.contadoresDeCota].
  ///
  /// `sync_tombstones` NÃO entra, e essa ausência é a correção de um
  /// vazamento: adotada, a lápide anônima virava `synced = 0` sob a conta real
  /// e a primeira varredura mandava ao servidor o id de tudo que a pessoa
  /// apagou antes de existir conta. E não purgava nada — item apagado antes do
  /// login nunca subiu para lugar nenhum. Quem a remove do aparelho é
  /// [claimLegacyData]. Ela fica de fora por não ser conteúdo dela, ou seja,
  /// pela própria [TabelasLocais.conteudo].
  @visibleForTesting
  static Set<String> tabelasDaAdocaoAnonima() {
    final tabelas = <String>{...TabelasLocais.conteudo};
    tabelas.remove('spells');
    tabelas.removeAll(TabelasLocais.contadoresDeCota);
    return tabelas;
  }

  /// Associa dados anônimos/legados à primeira conta autenticada que os abrir.
  /// Registros já pertencentes a UUIDs reais nunca são alterados.
  /// As origens do acervo que não saem do aparelho, prontas para o `IN`.
  /// Vem do enum para não haver duas listas que possam divergir.
  static final String _origensQueNaoSaem =
      FreeWritingSource.neverLeavesDevice.map((f) => "'" + f + "'").join(', ');

  Future<void> claimLegacyData(String userId) async {
    if (userId == 'local_user' || userId == 'current_user') return;

    final db = await database;
    final tables = tabelasDaAdocaoAnonima();

    await db.transaction((txn) async {
      await txn.update(
        'spells',
        {'user_id': userId, 'synced': 0},
        where: "user_id IN ('local_user', 'current_user') AND is_preloaded = 0",
      );

      for (final table in tables) {
        await txn.update(
          table,
          // O registro menstrual é adotado como todo o resto — entrar na
          // conta no mesmo aparelho não pode fazê-la perder o que já
          // escreveu —, mas entra JÁ CARIMBADO como enviado, e isso é a
          // decisão. Ele agora está no SyncEntity: carimbá-lo `synced: 0`
          // como os outros entregaria à primeira varredura do login todo o
          // histórico que ela escreveu antes de existir conta, por efeito
          // colateral da adoção e sem ninguém ter dito sim a nada. O envio
          // dele nasce do segundo sim e de mais nada — é `setSyncAllowed`
          // que manda `MenstrualCycleRepository.markForUpload` liberar
          // estas linhas, com a conta real e por escolha dela.
          {
            'user_id': userId,
            'synced': table == MenstrualCycleSchema.table ? 1 : 0,
          },
          // O acervo tem origens que não saem do aparelho (o registro do
          // ciclo). Adotá-las com `synced: 0` seria carimbá-las como "a
          // enviar" e entregá-las à primeira varredura do login — antes de
          // qualquer tela recarregar.
          where: table == 'free_writings'
              ? "user_id IN ('local_user', 'current_user') "
                  'AND source NOT IN ($_origensQueNaoSaem)'
              : "user_id IN ('local_user', 'current_user')",
          // Tabelas com UNIQUE(user_id, date) podem já ter o dia gravado
          // sob a conta real: nesse caso a linha anônima é descartada em
          // vez de derrubar a adoção inteira.
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // As lápides anônimas somem em vez de serem adotadas. Elas guardam o
      // id do que foi apagado ANTES de existir conta — conteúdo, muitas
      // vezes: `preloaded_<nome do feitiço>`, o id do mapa no perfil mágico.
      // Nada disso esteve na nuvem, então não há o que purgar lá; adotá-las
      // só entregava essa lista ao servidor no primeiro sync da conta nova.
      await txn.delete(
        'sync_tombstones',
        where: "user_id IN ('local_user', 'current_user')",
      );

      final charts = await txn.query(
        'birth_charts',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      for (final row in charts) {
        try {
          final data =
              jsonDecode(row['chart_data'] as String) as Map<String, dynamic>;
          if (data['userId'] == 'local_user' ||
              data['userId'] == 'current_user') {
            data['userId'] = userId;
            await txn.update(
              'birth_charts',
              {'chart_data': jsonEncode(data), 'synced': 0},
              where: 'id = ?',
              whereArgs: [row['id']],
            );
          }
        } catch (_) {}
      }

      final profiles = await txn.query(
        'magical_profiles',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      for (final row in profiles) {
        final birthChartId = row['birth_chart_id'] as String;
        var profileData = row['profile_data'] as String;
        try {
          final data = jsonDecode(profileData) as Map<String, dynamic>;
          data['userId'] = userId;
          profileData = jsonEncode(data);
        } catch (_) {}
        // A CHAVE PRIMÁRIA é reescrita aqui, e isso pode colidir: dois
        // perfis do mesmo mapa, ou um perfil cujo id já é o birth_chart_id
        // de outro. Sem tolerância, a colisão derrubava a TRANSAÇÃO INTEIRA
        // da adoção — a cada login, e levando junto tudo o que já tinha sido
        // adotado. Descartar a linha que colide é o mesmo que o laço das
        // tabelas de um-dia-só faz logo acima.
        await txn.update(
          'magical_profiles',
          {'id': birthChartId, 'profile_data': profileData, 'synced': 0},
          where: 'id = ?',
          whereArgs: [row['id']],
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  /// Limpa todos os dados de todas as tabelas
  ///
  /// ⚠️ ATENÇÃO: Esta operação é IRREVERSÍVEL e deleta TODOS os dados do usuário!
  ///
  /// Usado apenas em casos específicos:
  /// - Logout de usuários SEM sincronização na nuvem
  /// - Exclusão de conta
  /// - Troca de conta (para limpar dados do usuário anterior)
  ///
  /// NUNCA deve ser chamado durante:
  /// - Atualizações do app
  /// - Mudanças de versão do banco de dados (use _upgradeDB)
  /// - Upgrade/downgrade de plano
  ///
  /// A lista vem de [TabelasLocais.conteudo]. A que existia aqui, escrita à
  /// mão, tinha perdido o registro menstrual: ele sobrevivia à troca de conta
  /// no mesmo aparelho preso ao `user_id` anterior, e como o id anônimo é
  /// sempre 'local_user', a próxima pessoa a abrir a roda no mesmo telefone
  /// via o que a anterior escreveu do corpo dela.
  ///
  /// Aqui não há as ressalvas do "Limpar dados locais": a base local inteira
  /// está sendo descartada como verdade — inclusive o conteúdo pré-carregado,
  /// que a semeadura repõe na abertura seguinte.
  ///
  /// As lápides vão junto, e só aqui: elas guardam o id de tudo que a pessoa
  /// apagou, e sobreviver a uma exclusão de conta era manter no aparelho o
  /// índice exatamente daquilo que ela mandou sumir — pronto para ser enviado.
  /// Não ressuscita nada noutro aparelho, porque este método só roda quando a
  /// base local é a verdade sendo descartada (conta anônima, ou conta sem
  /// cópia na nuvem). Quem tem sincronização mantém o banco no logout — ver
  /// `AuthProvider.signOut`.
  Future<void> clearAllTables() => _apagarTabelas(
        [...TabelasLocais.conteudo, TabelasLocais.lapides],
        limpezaLocal: false,
      );

  /// Apaga deste aparelho o que a pessoa registrou: o "Limpar dados locais"
  /// das telas de Privacidade e de Editar Perfil, inteiro e num lugar só.
  ///
  /// Cada uma das duas mantinha a PRÓPRIA lista de tabelas, com o mesmo rótulo
  /// e o mesmo texto de confirmação; as duas divergiram entre si e da
  /// exportação, e o resultado era o pior possível: a pessoa tocava em "limpar
  /// todos os dados deste aparelho", recebia a mensagem de sucesso, e
  /// continuava ali o que a lista daquela tela tinha esquecido.
  ///
  /// A cópia na nuvem NÃO é tocada, e isso é o gesto, não um esquecimento: é o
  /// que a confirmação promete em voz alta ("se você tem sincronização
  /// ativada, seus dados na nuvem serão mantidos"). Vale para o registro do
  /// ciclo como para todo o resto — quem quer a cópia da conta apagada tem o
  /// gesto próprio dela na tela de Privacidade ("apagar meus registros do
  /// ciclo"), que é o único que fala com o servidor e o único que sabe dizer
  /// se conseguiu. Uma consequência disto precisa estar escrita: com a
  /// sincronização ligada, a varredura seguinte baixa de volta o que ela
  /// acabou de limpar. É o significado de "local".
  ///
  /// O que fica de fora do `DELETE` está em [TabelasLocais.limpezaParcial],
  /// com o porquê de cada ressalva. As lápides também ficam: apagá-las traria
  /// de volta, no download seguinte, exatamente o que ela mandou sumir.
  ///
  /// Não mexe em preferência nenhuma — nem nos "sim" do ciclo, nem nas marcas
  /// das Leituras. Aquilo é resposta dela, não registro, e esquecer as marcas
  /// enquanto os relatórios voltam da nuvem deixaria no acervo páginas que o
  /// "apagar meus registros do ciclo" não alcança mais.
  Future<void> limparConteudoDesteAparelho() => _apagarTabelas(
        TabelasLocais.conteudo,
        limpezaLocal: true,
      );

  /// O `DELETE` tabela por tabela.
  ///
  /// Com [limpezaLocal], valem as ressalvas de [TabelasLocais.limpezaParcial]
  /// — o conteúdo que vem com o app, o crédito de leitura ainda não usado e a
  /// lápide do ciclo. Sem ela é a exclusão de conta, e ali não há ressalva: a
  /// base local inteira deixa de valer.
  ///
  /// A tabela que não existe nesta versão do banco é SALTADA, e não engolida
  /// por um `catch`: o `catch` que existia aqui transformava qualquer falha —
  /// banco trancado, arquivo corrompido — em sucesso silencioso, e as duas
  /// telas anunciavam "dados removidos" sobre uma limpeza que não aconteceu.
  /// No gesto mais destrutivo do app, o erro precisa chegar à tela.
  Future<void> _apagarTabelas(
    Iterable<String> tabelas, {
    required bool limpezaLocal,
  }) async {
    final db = await database;
    final existentes = await _tabelasExistentes(db);
    for (final tabela in tabelas) {
      if (!existentes.contains(tabela)) continue;
      final oQueSai =
          limpezaLocal ? TabelasLocais.limpezaParcial[tabela] : null;
      if (oQueSai == null) {
        await db.delete(tabela);
      } else {
        await db.delete(tabela, where: oQueSai);
      }
    }
  }

  /// As tabelas que este banco tem de verdade.
  ///
  /// Serve à limpeza: um aparelho que abriu o app numa versão antiga pode não
  /// ter a tabela mais nova, e perguntar antes é o que permite não usar um
  /// `catch` cego em volta do `DELETE`.
  Future<Set<String>> _tabelasExistentes(Database db) async {
    final linhas = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    return {for (final linha in linhas) '${linha['name']}'};
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
