import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../models/user_entry_model.dart';

/// Entradas pessoais da enciclopédia no banco local (local-only na v1).
class UserEncyclopediaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<UserEncyclopediaEntry>> entriesFor(
    String userId,
    UserEntryCategory category,
  ) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'user_encyclopedia_entries',
      where: 'user_id = ? AND category = ?',
      whereArgs: [userId, category.key],
      orderBy: 'created_at DESC',
    );
    return rows
        .map(UserEncyclopediaEntry.fromMap)
        .whereType<UserEncyclopediaEntry>()
        .toList();
  }

  Future<UserEncyclopediaEntry> create({
    required String userId,
    required UserEntryCategory category,
    required String name,
    String? imagePath,
    required Map<String, dynamic> data,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final entry = UserEncyclopediaEntry(
      id: const Uuid().v4(),
      userId: userId,
      category: category,
      name: name,
      imagePath: imagePath,
      data: data,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert(
      'user_encyclopedia_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return entry;
  }

  /// Remove a entrada e a foto associada (se houver).
  Future<void> delete(UserEncyclopediaEntry entry) async {
    final db = await _dbHelper.database;
    await db.delete(
      'user_encyclopedia_entries',
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    final path = entry.imagePath;
    if (path != null && path.isNotEmpty) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Foto órfã não deve impedir a exclusão do registro.
      }
    }
  }

  /// Contagem de entradas criadas hoje (limite diário de uso da IA).
  Future<int> countCreatedToday(String userId) async {
    final now = DateTime.now();
    final startOfDay =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM user_encyclopedia_entries '
      'WHERE user_id = ? AND created_at >= ?',
      [userId, startOfDay],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
