import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/database/database_helper.dart';

/// Repositório para gerenciar códigos beta
///
/// Usa Supabase quando configurado para sincronização entre dispositivos.
/// Fallback para SQLite local quando Supabase não estáconfigurado.
class BetaCodeRepository {
  /// Cliente só é inicializado se o Supabase estiver configurado
  final SupabaseClient? _supabase =
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  /// Lista todos os códigos beta (apenas admin)
  Future<List<Map<String, dynamic>>> getAllCodes() async {
    print('[BetaCodeRepository] getAllCodes - iniciando...');
    final supabase = _supabase;
    if (supabase != null) {
      try {
        print('[BetaCodeRepository] Buscando códigos no Supabase...');
        final response = await supabase.from(SupabaseTables.betaCodes).select().order('created_at', ascending: false);
        print('[BetaCodeRepository] Supabase retornou ${response.length} códigos');
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        print('[BetaCodeRepository] ❌ Erro ao buscar códigos do Supabase: $e');
        print('[BetaCodeRepository] Tentando fallback para SQLite...');
        // Fallback para SQLite
        return _getCodesFromLocal();
      }
    } else {
      print('[BetaCodeRepository] Supabase não configurado, usando SQLite');
      return _getCodesFromLocal();
    }
  }

  /// Busca um código específico
  Future<Map<String, dynamic>?> getCode(String code) async {
    final cleanCode = code.trim().toUpperCase();

    final supabase = _supabase;
    if (supabase != null) {
      try {
        final response =
            await supabase.from(SupabaseTables.betaCodes).select().eq('code', cleanCode).maybeSingle();
        return response;
      } catch (e) {
        print('Erro ao buscar código do Supabase: $e');
        // Fallback para SQLite
        return _getCodeFromLocal(cleanCode);
      }
    } else {
      return _getCodeFromLocal(cleanCode);
    }
  }

  /// Cria um novo código beta
  Future<bool> createCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    final now = DateTime.now();
    print('[BetaCodeRepository] createCode - código: $cleanCode');

    final codeData = {
      'code': cleanCode,
      'is_used': false,
      'created_at': now.toIso8601String(),
    };

    final supabase = _supabase;
    if (supabase != null) {
      try {
        print('[BetaCodeRepository] Inserindo código no Supabase...');
        await supabase.from(SupabaseTables.betaCodes).insert(codeData);
        print('[BetaCodeRepository] ✅ Código inserido no Supabase com sucesso');
        // Também salvar localmente para cache
        await _saveCodeToLocal(cleanCode, now);
        print('[BetaCodeRepository] ✅ Código salvo localmente para cache');
        return true;
      } catch (e) {
        print('[BetaCodeRepository] ❌ Erro ao criar código no Supabase: $e');
        print('[BetaCodeRepository] Tentando fallback para SQLite...');
        // Fallback para SQLite
        return _createCodeLocal(cleanCode, now);
      }
    } else {
      print('[BetaCodeRepository] Supabase não configurado, usando SQLite');
      return _createCodeLocal(cleanCode, now);
    }
  }

  /// Resgata um código beta
  Future<Map<String, dynamic>> redeemCode(String code, String userId) async {
    final cleanCode = code.trim().toUpperCase();

    // Buscar código
    final codeData = await getCode(cleanCode);

    if (codeData == null) {
      return {
        'success': false,
        'message': 'Código inválido',
      };
    }

    // Verificar se já foi usado
    final isUsed = codeData['is_used'] == true || codeData['is_used'] == 1;
    if (isUsed) {
      return {
        'success': false,
        'message': 'Este código já foi utilizado',
      };
    }

    // Marcar como usado
    final now = DateTime.now();
    final updateData = {
      'is_used': true,
      'used_by': userId,
      'used_at': now.toIso8601String(),
    };

    final supabase = _supabase;
    if (supabase != null) {
      try {
        await supabase.from(SupabaseTables.betaCodes).update(updateData).eq('code', cleanCode);
        // Também atualizar localmente
        await _updateCodeLocal(cleanCode, userId, now);
      } catch (e) {
        print('Erro ao resgatar código no Supabase: $e');
        // Tentar fallback local
        await _updateCodeLocal(cleanCode, userId, now);
      }
    } else {
      await _updateCodeLocal(cleanCode, userId, now);
    }

    return {
      'success': true,
      'message': 'Código resgatado! Você agora tem acesso Premium vitalício 🎉',
    };
  }

  /// Invalida um código (marca como usado)
  Future<bool> invalidateCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    final now = DateTime.now();

    final updateData = {
      'is_used': true,
      'used_by': 'admin',
      'used_at': now.toIso8601String(),
    };

    final supabase = _supabase;
    if (supabase != null) {
      try {
        await supabase.from(SupabaseTables.betaCodes).update(updateData).eq('code', cleanCode);
        await _updateCodeLocal(cleanCode, 'admin', now);
        return true;
      } catch (e) {
        print('Erro ao invalidar código no Supabase: $e');
        return _invalidateCodeLocal(cleanCode, now);
      }
    } else {
      return _invalidateCodeLocal(cleanCode, now);
    }
  }

  /// Deleta um código
  Future<bool> deleteCode(String code) async {
    final cleanCode = code.trim().toUpperCase();

    final supabase = _supabase;
    if (supabase != null) {
      try {
        await supabase.from(SupabaseTables.betaCodes).delete().eq('code', cleanCode);
        await _deleteCodeLocal(cleanCode);
        return true;
      } catch (e) {
        print('Erro ao deletar código no Supabase: $e');
        return _deleteCodeLocal(cleanCode);
      }
    } else {
      return _deleteCodeLocal(cleanCode);
    }
  }

  // ============================================================
  // Métodos auxiliares para SQLite (fallback/cache local)
  // ============================================================

  Future<List<Map<String, dynamic>>> _getCodesFromLocal() async {
    try {
      print('[BetaCodeRepository] Buscando códigos locais no SQLite...');
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'beta_codes',
        orderBy: 'created_at DESC',
      );
      print('[BetaCodeRepository] SQLite retornou ${result.length} códigos');
      return result;
    } catch (e) {
      print('[BetaCodeRepository] ❌ Erro ao buscar códigos locais: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _getCodeFromLocal(String code) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'beta_codes',
        where: 'code = ?',
        whereArgs: [code],
      );
      return result.isEmpty ? null : result.first;
    } catch (e) {
      print('Erro ao buscar código local: $e');
      return null;
    }
  }

  Future<bool> _createCodeLocal(String code, DateTime createdAt) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('beta_codes', {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'code': code,
        'is_used': 0,
        'created_at': createdAt.millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Erro ao criar código local: $e');
      return false;
    }
  }

  Future<void> _saveCodeToLocal(String code, DateTime createdAt) async {
    try {
      final db = await DatabaseHelper.instance.database;
      // Usar INSERT OR IGNORE para evitar duplicatas
      await db.rawInsert(
        'INSERT OR IGNORE INTO beta_codes (id, code, is_used, created_at) VALUES (?, ?, ?, ?)',
        [DateTime.now().millisecondsSinceEpoch.toString(), code, 0, createdAt.millisecondsSinceEpoch],
      );
    } catch (e) {
      print('Erro ao salvar código localmente: $e');
    }
  }

  Future<void> _updateCodeLocal(String code, String userId, DateTime usedAt) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'beta_codes',
        {
          'is_used': 1,
          'used_by': userId,
          'used_at': usedAt.millisecondsSinceEpoch,
        },
        where: 'code = ?',
        whereArgs: [code],
      );
    } catch (e) {
      print('Erro ao atualizar código local: $e');
    }
  }

  Future<bool> _invalidateCodeLocal(String code, DateTime now) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'beta_codes',
        {
          'is_used': 1,
          'used_by': 'admin',
          'used_at': now.millisecondsSinceEpoch,
        },
        where: 'code = ?',
        whereArgs: [code],
      );
      return true;
    } catch (e) {
      print('Erro ao invalidar código local: $e');
      return false;
    }
  }

  Future<bool> _deleteCodeLocal(String code) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'beta_codes',
        where: 'code = ?',
        whereArgs: [code],
      );
      return true;
    } catch (e) {
      print('Erro ao deletar código local: $e');
      return false;
    }
  }
}
