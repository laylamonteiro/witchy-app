import 'package:uuid/uuid.dart';

/// Uma reflexão de escrita livre (aba 💡 de Diários).
///
/// Texto solto, sem título nem tags — apenas o conteúdo e as datas.
class FreeWritingModel {
  final String id;
  final String? userId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  FreeWritingModel({
    String? id,
    this.userId,
    required this.content,
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
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'synced': synced ? 1 : 0,
    };
  }

  factory FreeWritingModel.fromMap(Map<String, dynamic> map) {
    return FreeWritingModel(
      id: map['id'],
      userId: map['user_id'],
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      synced: map['synced'] == 1,
    );
  }

  FreeWritingModel copyWith({
    String? userId,
    String? content,
    bool? synced,
  }) {
    return FreeWritingModel(
      id: id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      synced: synced ?? false,
    );
  }
}
