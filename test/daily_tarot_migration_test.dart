import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('real v23 upgrade preserves existing readings and adds session storage', () async {
    SharedPreferences.setMockInitialValues({});
    final dir = await Directory.systemTemp.createTemp('tarot_v23_upgrade');
    await databaseFactory.setDatabasesPath(dir.path);
    final old = await openDatabase('${dir.path}/grimorio_de_bolso.db', version: 23,
        onCreate: (db, _) async {
          await db.execute('CREATE TABLE tarot_readings (id TEXT PRIMARY KEY, reading_data TEXT)');
          await db.insert('tarot_readings', {'id': 'legacy', 'reading_data': 'preserved'});
        });
    await old.close();
    final upgraded = await DatabaseHelper.instance.database;
    expect(await upgraded.getVersion(), 25);
    expect((await upgraded.query('tarot_readings')).single['reading_data'], 'preserved');
    final tables = (await upgraded.rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'"))
        .map((row) => row['name']).toSet();
    expect(tables, containsAll(ReadingSessionSchema.tables));
  });
}
