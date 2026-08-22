import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/debug_log_service.dart';

/// Uma compra avulsa que a loja já aprovou e o app ainda não transformou em
/// crédito.
///
/// POR QUE ISTO EXISTE
/// -------------------
/// A Leitura do Ciclo é vendida como consumível, e consumível não tem rede:
/// não gera entitlement (decisão correta — um consumível em entitlement vira
/// Premium vitalício) e o `restorePurchases` do RevenueCat só responde por
/// assinatura. Entre a cobrança aprovada e a gravação do crédito há duas idas
/// ao banco. Se qualquer uma estourar — armazenamento bloqueado no navegador,
/// aparelho sem espaço, banco fechado —, a pessoa pagou e o app nunca mais
/// soube: não havia como recuperar, por nenhum caminho.
///
/// O registro é gravado ANTES de tentar o crédito, não no `catch`: um erro que
/// derrube o app inteiro entre a cobrança e o `catch` também precisa deixar
/// rastro. Só é apagado quando o crédito existe de verdade.
class CompraPendente {
  const CompraPendente({
    required this.userId,
    required this.productId,
    required this.periodType,
    required this.periodStart,
    required this.periodEnd,
  });

  final String userId;
  final String productId;
  final String periodType;
  final DateTime periodStart;
  final DateTime periodEnd;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'product_id': productId,
        'period_type': periodType,
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
      };

  static CompraPendente? fromJson(Map<String, dynamic> json) {
    final userId = json['user_id'];
    final productId = json['product_id'];
    final periodType = json['period_type'];
    final start = DateTime.tryParse(json['period_start']?.toString() ?? '');
    final end = DateTime.tryParse(json['period_end']?.toString() ?? '');

    if (userId is! String ||
        productId is! String ||
        periodType is! String ||
        start == null ||
        end == null) {
      return null;
    }

    return CompraPendente(
      userId: userId,
      productId: productId,
      periodType: periodType,
      periodStart: start,
      periodEnd: end,
    );
  }
}

/// Guarda a compra pendente no aparelho.
///
/// Uma de cada vez, de propósito: a compra é bloqueante na tela, então não há
/// como acumular duas. Guardar uma lista abriria a porta para um registro
/// órfão ficar preso para sempre sem ninguém notar.
class CompraPendenteStore {
  static const _chave = 'cycle_reading_compra_pendente';

  /// Registra a intenção. Nunca propaga erro: se nem isto for possível, a
  /// compra ainda vai ser tentada — perder a rede é ruim, deixar de tentar o
  /// crédito por causa da rede seria pior.
  Future<void> registrar(CompraPendente compra) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chave, jsonEncode(compra.toJson()));
    } catch (e) {
      await debugLog('CYCLE_READING', 'Falha ao registrar compra pendente: $e');
    }
  }

  /// A compra pendente desta pessoa, se houver.
  ///
  /// Filtra por `userId` porque o registro sobrevive à troca de conta no mesmo
  /// aparelho — e crédito de uma pessoa não pode cair no grimório de outra.
  Future<CompraPendente?> pendenteDe(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cru = prefs.getString(_chave);
      if (cru == null) return null;

      final compra = CompraPendente.fromJson(
        jsonDecode(cru) as Map<String, dynamic>,
      );
      if (compra == null) {
        // Registro ilegível não tem como virar crédito e ficaria tentando
        // para sempre a cada abertura da tela.
        await limpar();
        return null;
      }

      return compra.userId == userId ? compra : null;
    } catch (e) {
      await debugLog('CYCLE_READING', 'Falha ao ler compra pendente: $e');
      return null;
    }
  }

  /// Apaga o registro. Só depois de o crédito existir.
  Future<void> limpar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chave);
    } catch (e) {
      await debugLog('CYCLE_READING', 'Falha ao limpar compra pendente: $e');
    }
  }
}
