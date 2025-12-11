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
  ///
  /// [code] - Código a ser criado
  /// [maxUses] - Número máximo de usos permitidos (padrão: 1)
  Future<bool> createCode(String code, {int maxUses = 1}) async {
    print('[BetaCodeRepository] ============ CREATE CODE INICIADO ============');
    final cleanCode = code.trim().toUpperCase();
    final now = DateTime.now();
    print('[BetaCodeRepository] createCode - código: $cleanCode, maxUses: $maxUses');
    print('[BetaCodeRepository] Supabase configurado: ${SupabaseConfig.isConfigured}');
    print('[BetaCodeRepository] _supabase is null? ${_supabase == null}');

    final codeData = {
      'code': cleanCode,
      'is_used': false,
      'created_at': now.toIso8601String(),
      'max_uses': maxUses,
      'current_uses': 0,
    };
    print('[BetaCodeRepository] Dados preparados: $codeData');

    final supabase = _supabase;
    print('[BetaCodeRepository] supabase local is null? ${supabase == null}');
    if (supabase != null) {
      print('[BetaCodeRepository] Entrando no bloco Supabase...');
      try {
        print('[BetaCodeRepository] Inserindo código no Supabase...');
        print('[BetaCodeRepository] Dados: $codeData');
        print('[BetaCodeRepository] Tabela: ${SupabaseTables.betaCodes}');

        final response = await supabase.from(SupabaseTables.betaCodes).insert(codeData).select();

        print('[BetaCodeRepository] ✅ Resposta do Supabase: $response');
        print('[BetaCodeRepository] ✅ Código inserido no Supabase com sucesso');

        // Também salvar localmente para cache
        try {
          await _saveCodeToLocal(cleanCode, now, maxUses: maxUses);
          print('[BetaCodeRepository] ✅ Código salvo localmente para cache');
        } catch (localError) {
          // Se falhar ao salvar localmente, apenas logar mas não falhar toda a operação
          print('[BetaCodeRepository] ⚠️  Erro ao salvar localmente (não crítico): $localError');
        }

        return true;
      } catch (e, stackTrace) {
        print('[BetaCodeRepository] ❌ ERRO DETALHADO ao criar código no Supabase:');
        print('[BetaCodeRepository] ❌ Erro: $e');
        print('[BetaCodeRepository] ❌ Tipo: ${e.runtimeType}');
        print('[BetaCodeRepository] ❌ Stack trace: $stackTrace');

        // Se for erro de RLS/permissão, mostrar claramente
        if (e.toString().contains('permission') ||
            e.toString().contains('policy') ||
            e.toString().contains('RLS') ||
            e.toString().contains('denied')) {
          print('[BetaCodeRepository] ⚠️  POSSÍVEL PROBLEMA DE PERMISSÃO/RLS');
          print('[BetaCodeRepository] ⚠️  Verifique as políticas da tabela beta_codes no Supabase');
        }

        print('[BetaCodeRepository] Tentando fallback para SQLite...');
        // Fallback para SQLite
        return _createCodeLocal(cleanCode, now, maxUses: maxUses);
      }
    } else {
      print('[BetaCodeRepository] ⚠️  Supabase NÃO está configurado');
      print('[BetaCodeRepository] ⚠️  URL vazia: ${SupabaseConfig.url.isEmpty}');
      print('[BetaCodeRepository] ⚠️  AnonKey vazia: ${SupabaseConfig.anonKey.isEmpty}');
      print('[BetaCodeRepository] Usando SQLite local apenas');
      return _createCodeLocal(cleanCode, now, maxUses: maxUses);
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

    // Verificar disponibilidade (current_uses < max_uses)
    final currentUses = (codeData['current_uses'] ?? 0) as int;
    final maxUses = (codeData['max_uses'] ?? 1) as int;

    if (currentUses >= maxUses) {
      return {
        'success': false,
        'message': 'Este código já atingiu o limite de usos',
      };
    }

    // Incrementar contador de usos
    final now = DateTime.now();
    final newCurrentUses = currentUses + 1;
    final isNowUsedUp = newCurrentUses >= maxUses;

    final updateData = {
      'current_uses': newCurrentUses,
      'is_used': isNowUsedUp, // Marcar como usado se atingiu o limite
      'used_by': userId, // Último usuário que usou
      'used_at': now.toIso8601String(),
    };

    final supabase = _supabase;
    if (supabase != null) {
      try {
        await supabase.from(SupabaseTables.betaCodes).update(updateData).eq('code', cleanCode);
        // Também atualizar localmente
        await _updateCodeLocal(cleanCode, userId, now, currentUses: newCurrentUses);
      } catch (e) {
        print('Erro ao resgatar código no Supabase: $e');
        // Tentar fallback local
        await _updateCodeLocal(cleanCode, userId, now, currentUses: newCurrentUses);
      }
    } else {
      await _updateCodeLocal(cleanCode, userId, now, currentUses: newCurrentUses);
    }

    final usesRemaining = maxUses - newCurrentUses;
    final message = usesRemaining > 0
        ? 'Código resgatado! Você agora tem acesso Premium vitalício 🎉\n(Restam $usesRemaining uso${usesRemaining > 1 ? 's' : ''} deste código)'
        : 'Código resgatado! Você agora tem acesso Premium vitalício 🎉';

    return {
      'success': true,
      'message': message,
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

  Future<bool> _createCodeLocal(String code, DateTime createdAt, {int maxUses = 1}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('beta_codes', {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'code': code,
        'is_used': 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'max_uses': maxUses,
        'current_uses': 0,
      });
      return true;
    } catch (e) {
      print('Erro ao criar código local: $e');
      return false;
    }
  }

  Future<void> _saveCodeToLocal(String code, DateTime createdAt, {int maxUses = 1}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      // Usar INSERT OR IGNORE para evitar duplicatas
      await db.rawInsert(
        'INSERT OR IGNORE INTO beta_codes (id, code, is_used, created_at, max_uses, current_uses) VALUES (?, ?, ?, ?, ?, ?)',
        [DateTime.now().millisecondsSinceEpoch.toString(), code, 0, createdAt.millisecondsSinceEpoch, maxUses, 0],
      );
    } catch (e) {
      print('Erro ao salvar código localmente: $e');
    }
  }

  Future<void> _updateCodeLocal(String code, String userId, DateTime usedAt, {int? currentUses}) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Se currentUses foi fornecido, atualizar; caso contrário, buscar do banco
      int newCurrentUses = currentUses ?? 1;

      // Se não foi fornecido, buscar do banco e incrementar
      if (currentUses == null) {
        final existing = await db.query('beta_codes', where: 'code = ?', whereArgs: [code]);
        if (existing.isNotEmpty) {
          final current = (existing.first['current_uses'] ?? 0) as int;
          newCurrentUses = current + 1;
        }
      }

      // Buscar max_uses para determinar is_used
      final existing = await db.query('beta_codes', where: 'code = ?', whereArgs: [code]);
      final maxUses = existing.isNotEmpty ? ((existing.first['max_uses'] ?? 1) as int) : 1;
      final isUsed = newCurrentUses >= maxUses ? 1 : 0;

      await db.update(
        'beta_codes',
        {
          'current_uses': newCurrentUses,
          'is_used': isUsed,
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
