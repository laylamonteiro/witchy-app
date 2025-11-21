import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/birth_chart_model.dart';
import '../models/magical_profile_model.dart';

class AstrologyRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Salvar Mapa Astral
  Future<void> saveBirthChart(BirthChartModel chart) async {
    final db = await _dbHelper.database;

    await db.insert(
      'birth_charts',
      {
        'id': chart.id,
        'user_id': chart.userId,
        'birth_date': chart.birthDate.millisecondsSinceEpoch,
        'birth_time_hour': chart.birthTime.hour,
        'birth_time_minute': chart.birthTime.minute,
        'birth_place': chart.birthPlace,
        'latitude': chart.latitude,
        'longitude': chart.longitude,
        'timezone': chart.timezone,
        'unknown_birth_time': chart.unknownBirthTime ? 1 : 0,
        'chart_data': chart.toJsonString(),
        'calculated_at': chart.calculatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Buscar Mapa Astral do usuário
  Future<BirthChartModel?> getBirthChart(String userId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'birth_charts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'calculated_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    final chartData = maps.first['chart_data'] as String;
    return BirthChartModel.fromJsonString(chartData);
  }

  // Verificar se usuário tem mapa astral
  Future<bool> hasBirthChart(String userId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'birth_charts',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // Atualizar Mapa Astral
  Future<void> updateBirthChart(BirthChartModel chart) async {
    final db = await _dbHelper.database;

    await db.update(
      'birth_charts',
      {
        'birth_date': chart.birthDate.millisecondsSinceEpoch,
        'birth_time_hour': chart.birthTime.hour,
        'birth_time_minute': chart.birthTime.minute,
        'birth_place': chart.birthPlace,
        'latitude': chart.latitude,
        'longitude': chart.longitude,
        'timezone': chart.timezone,
        'unknown_birth_time': chart.unknownBirthTime ? 1 : 0,
        'chart_data': chart.toJsonString(),
        'calculated_at': chart.calculatedAt.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [chart.id],
    );
  }

  // Deletar Mapa Astral
  Future<void> deleteBirthChart(String chartId) async {
    final db = await _dbHelper.database;

    await db.delete(
      'birth_charts',
      where: 'id = ?',
      whereArgs: [chartId],
    );
  }

  // Salvar Perfil Mágico
  Future<void> saveMagicalProfile(MagicalProfile profile) async {
    final db = await _dbHelper.database;

    await db.insert(
      'magical_profiles',
      {
        'id': '${profile.userId}_${profile.birthChartId}',
        'user_id': profile.userId,
        'birth_chart_id': profile.birthChartId,
        'profile_data': profile.toJsonString(),
        'generated_at': profile.generatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Buscar Perfil Mágico
  Future<MagicalProfile?> getMagicalProfile(String userId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'magical_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'generated_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    final profileData = maps.first['profile_data'] as String;
    return MagicalProfile.fromJsonString(profileData);
  }

  // Verificar se usuário tem perfil mágico
  Future<bool> hasMagicalProfile(String userId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'magical_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}
