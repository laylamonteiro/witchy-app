import 'package:uuid/uuid.dart';

/// Origem de uma entrada do acervo (persistida em `free_writings.source`).
///
/// 'free' = reflexão escrita pela Bruxa (aba 💭 dos Diários); as demais são
/// páginas GERADAS — lições do Grimório Vivo e leituras — que aparecem em
/// "Meus Registros".
abstract final class FreeWritingSource {
  static const free = 'free';
  static const grimorioVivo = 'grimorio_vivo';
  static const palmistry = 'palmistry';
  static const runes = 'runes';
  static const pendulum = 'pendulum';
  static const oracle = 'oracle';
  static const tarot = 'tarot';

  /// Leitura do Ciclo (relatório da compra avulsa): fica no acervo para
  /// sempre — a análise gerada é o recibo permanente da compra.
  static const cycleReading = 'cycle_reading';

  /// Leituras de adivinhação (filtro "Leituras" do acervo).
  static const readings = {palmistry, runes, pendulum, oracle, tarot};
}

/// Uma entrada do acervo de escrita: reflexão livre (sem título) ou página
/// gerada (lição/leitura, com título e origem).
class FreeWritingModel {
  final String id;
  final String? userId;

  /// Título da página gerada; reflexões livres não têm (null).
  final String? title;

  final String content;

  /// Uma das constantes de [FreeWritingSource].
  final String source;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  FreeWritingModel({
    String? id,
    this.userId,
    this.title,
    required this.content,
    this.source = FreeWritingSource.free,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.synced = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId ?? 'local_user',
      'title': title,
      'content': content,
      'source': source,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'synced': synced ? 1 : 0,
    };
  }

  factory FreeWritingModel.fromMap(Map<String, dynamic> map) {
    return FreeWritingModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'] ?? '',
      // Linhas antigas (locais ou remotas) sem a coluna: reflexão livre.
      source: map['source'] ?? FreeWritingSource.free,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      synced: map['synced'] == 1,
    );
  }

  /// `source` NÃO é copiável de propósito: o autosave do canvas usa
  /// `copyWith(content:)` e jamais pode "des-tipar" uma página gerada.
  FreeWritingModel copyWith({
    String? userId,
    String? title,
    String? content,
    bool? synced,
  }) {
    return FreeWritingModel(
      id: id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      source: source,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      synced: synced ?? false,
    );
  }
}
