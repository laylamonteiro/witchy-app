import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/menstrual_cycle_schema.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A migração v28 → v29 mora em arquivo próprio: o DatabaseHelper é um
/// singleton e guarda o banco que abriu primeiro, então cada história de
/// migração precisa de um processo só seu.
///
/// As duas colunas que a v29 acrescenta ficaram sem leitor desde que a
/// Estação Interna saiu do app; a migração continua, porque a casa só migra
/// para a frente, e o que este teste guarda é que ela não perde o que já
/// estava escrito.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('a v28 phone goes through the v29 migration without losing what was '
      'written', () async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('menstrual_v28_upgrade');
    await databaseFactory.setDatabasesPath(dir.path);
    final old = await openDatabase('${dir.path}/grimorio_de_bolso.db',
        version: 28, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE ${MenstrualCycleSchema.table} (
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
      await db.insert(MenstrualCycleSchema.table, {
        'user_id': 'local_user',
        'day_key': '2026-02-10',
        'mark': 'start',
        'note': 'já estava aqui',
        'created_at': 1,
        'updated_at': 1,
      });
    });
    await old.close();
    final upgraded = await DatabaseHelper.instance.database;
    expect(await upgraded.getVersion(), 29);
    final row = (await upgraded.query(MenstrualCycleSchema.table)).single;
    expect(row['note'], 'já estava aqui');
    expect(row['season'], isNull,
        reason: 'Inherited columns arrive empty, and nothing fills them');
    expect(row['season_note'], '');
  });
}
