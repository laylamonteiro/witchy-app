import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/debug_log_service.dart';

/// Repositório para gerenciar códigos beta
///
/// Quando o Supabase está configurado ele é a FONTE DA VERDADE: falhas de
/// escrita são propagadas como erro (nunca degradam silenciosamente para o
/// SQLite — um código "criado" só localmente não funcionaria em outros
/// dispositivos, que era exatamente o bug relatado). O SQLite é usado como
/// cache de leitura e como único backend quando o Supabase não está
/// configurado (modo 100% local do app).
class BetaCodeRepository {
  /// Cliente só é inicializado se o Supabase estiver configurado
  final SupabaseClient? _supabase =
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  /// Lista todos os códigos beta (apenas admin)
  Future<List<Map<String, dynamic>>> getAllCodes() async {
    final supabase = _supabase;
    if (supabase != null) {
      try {
        final response = await supabase
            .from(SupabaseTables.betaCodes)
            .select()
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        await debugLog('BETA_CODE', 'Erro ao listar códigos do Supabase: $e');
        // Leitura pode cair no cache local sem risco de inconsistência
        return _getCodesFromLocal();
      }
    }
    return _getCodesFromLocal();
  }

  /// Busca um código específico
  Future<Map<String, dynamic>?> getCode(String code) async {
    final cleanCode = code.trim().toUpperCase();

    final supabase = _supabase;
    if (supabase != null) {
      try {
        final response = await supabase
            .from(SupabaseTables.betaCodes)
            .select()
            .eq('code', cleanCode)
            .maybeSingle();
        return response;
      } catch (e) {
        await debugLog('BETA_CODE', 'Erro ao buscar código do Supabase: $e');
        return _getCodeFromLocal(cleanCode);
      }
    }
    return _getCodeFromLocal(cleanCode);
  }

  /// Cria um novo código beta
  ///
  /// [code] - Código a ser criado
  /// [maxUses] - Número máximo de usos permitidos (padrão: 1)
  ///
  /// Com Supabase configurado, uma falha no INSERT retorna `false` (a UI deve
  /// mostrar erro) — NÃO grava só localmente fingindo sucesso.
  Future<bool> createCode(String code, {int maxUses = 1}) async {
    final cleanCode = code.trim().toUpperCase();
    final now = DateTime.now();

    final codeData = {
      'code': cleanCode,
      'is_used': false,
      'created_at': now.toIso8601String(),
      'max_uses': maxUses,
      'current_uses': 0,
    };

    final supabase = _supabase;
    if (supabase != null) {
      try {
        await supabase.from(SupabaseTables.betaCodes).insert(codeData);
        await debugLog('BETA_CODE', 'Código $cleanCode criado no Supabase');

        // Espelhar no cache local (não crítico)
        try {
          await _saveCodeToLocal(cleanCode, now, maxUses: maxUses);
        } catch (localError) {
          await debugLog(
              'BETA_CODE', 'Cache local falhou (não crítico): $localError');
        }
        return true;
      } catch (e) {
        await debugLog('BETA_CODE', 'ERRO ao criar código no Supabase: $e');
        if (e.toString().contains('policy') ||
            e.toString().contains('permission') ||
            e.toString().contains('denied')) {
          await debugLog('BETA_CODE',
              'Possível RLS desatualizado — rode supabase/restore_database.sql');
        }
        // Fonte da verdade é o Supabase: falha = falha (sem fallback
        // silencioso que criaria um código local-only inútil).
        return false;
      }
    }
    // Modo 100% local (Supabase não configurado)
    return _createCodeLocal(cleanCode, now, maxUses: maxUses);
  }

  /// Resgata um código beta.
  ///
  /// Com Supabase configurado tenta primeiro a RPC `redeem_beta_code`
  /// (atômica, à prova de corrida — ver supabase/restore_database.sql).
  /// Se a RPC não existir no projeto, usa um UPDATE condicional
  /// (`is_used = false AND current_uses < max_uses`) como aproximação.
  Future<Map<String, dynamic>> redeemCode(String code, String userId) async {
    final cleanCode = code.trim().toUpperCase();
    final supabase = _supabase;

    if (supabase != null) {
      // --- Caminho preferido: RPC atômica no servidor ---
      try {
        final result = await supabase.rpc('redeem_beta_code', params: {
          'p_code': cleanCode,
          'p_user_id': userId,
        });
        final map = Map<String, dynamic>.from(result as Map);
        if (map['success'] == true) {
          await _mirrorRedeemLocally(cleanCode, userId);
        }
        return {
          'success': map['success'] == true,
          'message': map['message'] ?? 'Código processado',
        };
      } on PostgrestException catch (e) {
        // Função ainda não criada no projeto → cai no caminho legado abaixo
        final missingFunction =
            e.code == 'PGRST202' || e.code == '42883' || e.code == '404';
        if (!missingFunction) {
          await debugLog('BETA_CODE', 'Erro na RPC redeem_beta_code: $e');
          return {
            'success': false,
            'message': 'Erro ao validar o código. Tente novamente.',
          };
        }
        await debugLog('BETA_CODE',
            'RPC redeem_beta_code ausente — usando UPDATE condicional');
      } catch (e) {
        await debugLog('BETA_CODE', 'Erro inesperado na RPC: $e');
        return {
          'success': false,
          'message': 'Erro ao validar o código. Verifique sua conexão.',
        };
      }

      // --- Caminho legado: read + UPDATE condicional ---
      return _redeemViaConditionalUpdate(supabase, cleanCode, userId);
    }

    // --- Modo 100% local ---
    return _redeemLocally(cleanCode, userId);
  }

  Future<Map<String, dynamic>> _redeemViaConditionalUpdate(
    SupabaseClient supabase,
    String cleanCode,
    String userId,
  ) async {
    try {
      final codeData = await supabase
          .from(SupabaseTables.betaCodes)
          .select()
          .eq('code', cleanCode)
          .maybeSingle();

      final validation = _validateCodeData(codeData);
      if (validation != null) return validation;

      final currentUses = (codeData!['current_uses'] ?? 0) as int;
      final maxUses = (codeData['max_uses'] ?? 1) as int;
      final newCurrentUses = currentUses + 1;
      final now = DateTime.now();

      // UPDATE condicional: só aplica se o código ainda estiver válido.
      // Para códigos de uso único, `is_used = false` bloqueia corrida
      // (o primeiro resgate seta is_used = true e o segundo não casa o WHERE).
      final updated = await supabase
          .from(SupabaseTables.betaCodes)
          .update({
            'current_uses': newCurrentUses,
            'is_used': newCurrentUses >= maxUses,
            'used_by': userId,
            'used_at': now.toIso8601String(),
          })
          .eq('code', cleanCode)
          .eq('is_used', false)
          .lt('current_uses', maxUses)
          .select();

      if (updated.isEmpty) {
        return {
          'success': false,
          'message': 'Este código já foi utilizado',
        };
      }

      // Persistir o premium no perfil (best-effort): o código JÁ foi
      // consumido acima — uma falha aqui (usuário anônimo sem UUID, RLS,
      // rede) não pode transformar o resgate em erro.
      await _persistPremiumProfile(supabase, userId, now);

      await _mirrorRedeemLocally(cleanCode, userId);
      return _successMessage();
    } catch (e) {
      await debugLog('BETA_CODE', 'Erro ao resgatar código no Supabase: $e');
      // Fonte da verdade é o Supabase: NÃO conceder premium a partir do
      // cache local quando o servidor falhou.
      return {
        'success': false,
        'message': 'Erro ao validar o código. Verifique sua conexão.',
      };
    }
  }

  /// UUID v4-like (contas Supabase). Usuários locais usam ids como
  /// 'local_user', que não existem em `profiles`.
  static final RegExp _uuidRegExp = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Grava role=premium/plan=lifetime em `profiles` após um resgate
  /// (best-effort). Só tenta para ids que são UUID de conta Supabase e nunca
  /// propaga erro — o resgate em si já foi concluído.
  Future<void> _persistPremiumProfile(
    SupabaseClient supabase,
    String userId,
    DateTime now,
  ) async {
    if (!_uuidRegExp.hasMatch(userId)) {
      await debugLog('BETA_CODE',
          'Usuário local ($userId) — premium não persistido em profiles');
      return;
    }
    try {
      await supabase.from(SupabaseTables.profiles).update({
        'role': 'premium',
        'plan': 'lifetime',
        'updated_at': now.toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      await debugLog(
          'BETA_CODE', 'Falha ao persistir premium em profiles: $e');
    }
  }

  Future<Map<String, dynamic>> _redeemLocally(
      String cleanCode, String userId) async {
    final codeData = await _getCodeFromLocal(cleanCode);
    final validation = _validateCodeData(codeData);
    if (validation != null) return validation;

    final currentUses = (codeData!['current_uses'] ?? 0) as int;
    final maxUses = (codeData['max_uses'] ?? 1) as int;
    final newCurrentUses = currentUses + 1;

    await _updateCodeLocal(cleanCode, userId, DateTime.now(),
        currentUses: newCurrentUses);
    return _successMessage();
  }

  /// Validações comuns de resgate. Retorna um mapa de erro ou null se válido.
  Map<String, dynamic>? _validateCodeData(Map<String, dynamic>? codeData) {
    if (codeData == null) {
      return {'success': false, 'message': 'Código inválido'};
    }

    // is_used cobre tanto o esgotamento quanto a invalidação manual pelo
    // admin (bug antigo: invalidar não impedia resgate).
    final rawIsUsed = codeData['is_used'];
    final isUsed = rawIsUsed == true || rawIsUsed == 1;
    if (isUsed) {
      return {'success': false, 'message': 'Este código já foi utilizado'};
    }

    final currentUses = (codeData['current_uses'] ?? 0) as int;
    final maxUses = (codeData['max_uses'] ?? 1) as int;
    if (currentUses >= maxUses) {
      return {
        'success': false,
        'message': 'Este código já atingiu o limite de usos',
      };
    }
    return null;
  }

  /// Não expor quantos usos restam: evita que o usuário repasse o código
  /// sabendo que outras pessoas ainda podem usá-lo.
  Map<String, dynamic> _successMessage() {
    return {
      'success': true,
      'message': 'Código resgatado! Você agora tem acesso Premium vitalício 🎉',
    };
  }

  /// Espelha um resgate feito no Supabase para o cache local (não crítico).
  Future<void> _mirrorRedeemLocally(String cleanCode, String userId) async {
    try {
      final remote = await getCode(cleanCode);
      if (remote == null) return;
      final db = await DatabaseHelper.instance.database;
      final rawIsUsed = remote['is_used'];
      await db.update(
        'beta_codes',
        {
          'current_uses': (remote['current_uses'] ?? 0) as int,
          'is_used': (rawIsUsed == true || rawIsUsed == 1) ? 1 : 0,
          'used_by': userId,
          'used_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'code = ?',
        whereArgs: [cleanCode],
      );
    } catch (e) {
      await debugLog('BETA_CODE', 'Cache local do resgate falhou: $e');
    }
  }

  /// Invalida um código (bloqueia novos resgates)
  ///
  /// Marca `is_used = true` E `current_uses = max_uses` para garantir que o
  /// resgate seja bloqueado por qualquer uma das duas checagens.
  Future<bool> invalidateCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    final now = DateTime.now();

    final supabase = _supabase;
    if (supabase != null) {
      try {
        final codeData = await supabase
            .from(SupabaseTables.betaCodes)
            .select('max_uses')
            .eq('code', cleanCode)
            .maybeSingle();
        final maxUses = (codeData?['max_uses'] ?? 1) as int;

        await supabase.from(SupabaseTables.betaCodes).update({
          'is_used': true,
          'current_uses': maxUses,
          'used_by': 'admin',
          'used_at': now.toIso8601String(),
        }).eq('code', cleanCode);

        await _invalidateCodeLocal(cleanCode, now);
        return true;
      } catch (e) {
        await debugLog('BETA_CODE', 'Erro ao invalidar código no Supabase: $e');
        // Fonte da verdade é o Supabase: falha = falha.
        return false;
      }
    }
    return _invalidateCodeLocal(cleanCode, now);
  }

  /// Deleta um código
  Future<bool> deleteCode(String code) async {
    final cleanCode = code.trim().toUpperCase();

    final supabase = _supabase;
    if (supabase != null) {
      try {
        await supabase
            .from(SupabaseTables.betaCodes)
            .delete()
            .eq('code', cleanCode);
        await _deleteCodeLocal(cleanCode);
        return true;
      } catch (e) {
        await debugLog('BETA_CODE', 'Erro ao deletar código no Supabase: $e');
        // Fonte da verdade é o Supabase: falha = falha.
        return false;
      }
    }
    return _deleteCodeLocal(cleanCode);
  }

  // ============================================================
  // Métodos auxiliares para SQLite (fallback/cache local)
  // ============================================================

  Future<List<Map<String, dynamic>>> _getCodesFromLocal() async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.query('beta_codes', orderBy: 'created_at DESC');
    } catch (e) {
      await debugLog('BETA_CODE', 'Erro ao buscar códigos locais: $e');
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
      await debugLog('BETA_CODE', 'Erro ao buscar código local: $e');
      return null;
    }
  }

  Future<bool> _createCodeLocal(String code, DateTime createdAt,
      {int maxUses = 1}) async {
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
      await debugLog('BETA_CODE', 'Erro ao criar código local: $e');
      return false;
    }
  }

  Future<void> _saveCodeToLocal(String code, DateTime createdAt,
      {int maxUses = 1}) async {
    final db = await DatabaseHelper.instance.database;
    // Usar INSERT OR IGNORE para evitar duplicatas
    await db.rawInsert(
      'INSERT OR IGNORE INTO beta_codes (id, code, is_used, created_at, max_uses, current_uses) VALUES (?, ?, ?, ?, ?, ?)',
      [
        DateTime.now().millisecondsSinceEpoch.toString(),
        code,
        0,
        createdAt.millisecondsSinceEpoch,
        maxUses,
        0,
      ],
    );
  }

  /// Atualiza um código local após resgate. [currentUses] é obrigatório —
  /// a versão antiga tinha um caminho implícito que incrementava usos ao
  /// invalidar (bug corrigido).
  Future<void> _updateCodeLocal(
    String code,
    String userId,
    DateTime usedAt, {
    required int currentUses,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final existing =
          await db.query('beta_codes', where: 'code = ?', whereArgs: [code]);
      final maxUses =
          existing.isNotEmpty ? ((existing.first['max_uses'] ?? 1) as int) : 1;

      await db.update(
        'beta_codes',
        {
          'current_uses': currentUses,
          'is_used': currentUses >= maxUses ? 1 : 0,
          'used_by': userId,
          'used_at': usedAt.millisecondsSinceEpoch,
        },
        where: 'code = ?',
        whereArgs: [code],
      );
    } catch (e) {
      await debugLog('BETA_CODE', 'Erro ao atualizar código local: $e');
    }
  }

  Future<bool> _invalidateCodeLocal(String code, DateTime now) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final existing =
          await db.query('beta_codes', where: 'code = ?', whereArgs: [code]);
      final maxUses =
          existing.isNotEmpty ? ((existing.first['max_uses'] ?? 1) as int) : 1;

      await db.update(
        'beta_codes',
        {
          'is_used': 1,
          'current_uses': maxUses,
          'used_by': 'admin',
          'used_at': now.millisecondsSinceEpoch,
        },
        where: 'code = ?',
        whereArgs: [code],
      );
      return true;
    } catch (e) {
      await debugLog('BETA_CODE', 'Erro ao invalidar código local: $e');
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
      await debugLog('BETA_CODE', 'Erro ao deletar código local: $e');
      return false;
    }
  }
}
