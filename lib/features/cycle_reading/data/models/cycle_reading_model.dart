import 'package:uuid/uuid.dart';

/// Estado de uma Leitura do Ciclo (persistido em `cycle_readings.status`).
abstract final class CycleReadingStatus {
  /// Compra registrada, relatório ainda não gerado/salvo. A compra SÓ é
  /// consumida quando vira `generated` — falha de geração mantém o crédito
  /// e o app tenta de novo sem nova cobrança.
  static const pending = 'pending';

  /// Relatório gerado e salvo no acervo (`free_writings`).
  static const generated = 'generated';
}

/// Como o crédito nasceu (persistido em `cycle_readings.origin`).
abstract final class CycleReadingOrigin {
  /// Produto consumível comprado na loja.
  static const purchase = 'purchase';

  /// Leitura mensal inclusa da assinatura Premium.
  static const pro = 'pro';
}

/// O registro de UMA Leitura do Ciclo: a compra (ou concessão Pro), o
/// período coberto e o vínculo com o relatório salvo no acervo.
class CycleReadingModel {
  final String id;
  final String? userId;

  /// Tipo do período — MVP: só 'lunation' (a lunação corrente).
  final String periodType;

  final DateTime periodStart;
  final DateTime periodEnd;

  /// Uma das constantes de [CycleReadingStatus].
  final String status;

  /// Uma das constantes de [CycleReadingOrigin].
  final String origin;

  /// Id do produto consumível comprado (null para concessão Pro).
  final String? productId;

  /// Id da entrada em `free_writings` com o relatório (após gerado).
  final String? writingId;

  /// Regenerações da MESMA janela já usadas (teto: 2).
  final int regenerationsUsed;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  /// Teto de regenerações da mesma janela.
  static const int maxRegenerations = 2;

  CycleReadingModel({
    String? id,
    this.userId,
    this.periodType = 'lunation',
    required this.periodStart,
    required this.periodEnd,
    this.status = CycleReadingStatus.pending,
    this.origin = CycleReadingOrigin.purchase,
    this.productId,
    this.writingId,
    this.regenerationsUsed = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.synced = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isPending => status == CycleReadingStatus.pending;
  bool get isGenerated => status == CycleReadingStatus.generated;
  bool get canRegenerate =>
      isGenerated && regenerationsUsed < maxRegenerations;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId ?? 'local_user',
      'period_type': periodType,
      'period_start': periodStart.millisecondsSinceEpoch,
      'period_end': periodEnd.millisecondsSinceEpoch,
      'status': status,
      'origin': origin,
      'product_id': productId,
      'writing_id': writingId,
      'regenerations_used': regenerationsUsed,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'synced': synced ? 1 : 0,
    };
  }

  factory CycleReadingModel.fromMap(Map<String, dynamic> map) {
    return CycleReadingModel(
      id: map['id'],
      userId: map['user_id'],
      periodType: map['period_type'] ?? 'lunation',
      periodStart: DateTime.fromMillisecondsSinceEpoch(map['period_start']),
      periodEnd: DateTime.fromMillisecondsSinceEpoch(map['period_end']),
      status: map['status'] ?? CycleReadingStatus.pending,
      origin: map['origin'] ?? CycleReadingOrigin.purchase,
      productId: map['product_id'],
      writingId: map['writing_id'],
      regenerationsUsed: (map['regenerations_used'] as int?) ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      synced: map['synced'] == 1,
    );
  }

  CycleReadingModel copyWith({
    String? status,
    String? writingId,
    int? regenerationsUsed,
    bool? synced,
  }) {
    return CycleReadingModel(
      id: id,
      userId: userId,
      periodType: periodType,
      periodStart: periodStart,
      periodEnd: periodEnd,
      status: status ?? this.status,
      origin: origin,
      productId: productId,
      writingId: writingId ?? this.writingId,
      regenerationsUsed: regenerationsUsed ?? this.regenerationsUsed,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      synced: synced ?? false,
    );
  }
}
