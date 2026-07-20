import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

enum DesireStatus {
  open, // Em aberto
  manifesting, // Manifestando
  manifested, // Manifestado
  released, // Liberado
}

class DesireModel {
  final String id;
  final String? userId;
  final String title;
  final String description;
  final DesireStatus status;
  final String? evolution;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  DesireModel({
    String? id,
    this.userId,
    required this.title,
    required this.description,
    this.status = DesireStatus.open,
    this.evolution,
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
      'description': description,
      'status': status.name,
      'evolution': evolution,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'synced': synced ? 1 : 0,
    };
  }

  factory DesireModel.fromMap(Map<String, dynamic> map) {
    return DesireModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      status: DesireStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DesireStatus.open,
      ),
      evolution: map['evolution'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      synced: map['synced'] == 1,
    );
  }

  /// Prefixo que marca uma descrição que, na verdade, guarda a imagem PNG
  /// (base64) de um sigilo salvo no Diário de Desejos. Fica no próprio campo
  /// `description` para sincronizar como texto, sem alterar o schema.
  static const String sigilImagePrefix = 'sigilimg::';

  /// Indica se este desejo guarda a imagem de um sigilo em vez de texto.
  bool get hasSigilImage => description.startsWith(sigilImagePrefix);

  /// Bytes PNG do sigilo quando [hasSigilImage]; null caso contrário.
  Uint8List? get sigilImageBytes {
    if (!hasSigilImage) return null;
    try {
      return base64Decode(description.substring(sigilImagePrefix.length));
    } catch (_) {
      return null;
    }
  }

  /// Codifica os bytes PNG de um sigilo para armazenar em `description`.
  static String encodeSigilImage(Uint8List bytes) =>
      '$sigilImagePrefix${base64Encode(bytes)}';

  DesireModel copyWith({
    String? userId,
    String? title,
    String? description,
    DesireStatus? status,
    String? evolution,
    bool? synced,
  }) {
    return DesireModel(
      id: id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      evolution: evolution ?? this.evolution,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      synced: synced ?? false,
    );
  }
}

extension DesireStatusExtension on DesireStatus {
  String get displayName {
    switch (this) {
      case DesireStatus.open:
        return 'Em Aberto';
      case DesireStatus.manifesting:
        return 'Manifestando';
      case DesireStatus.manifested:
        return 'Manifestado';
      case DesireStatus.released:
        return 'Liberado';
    }
  }

  String get emoji {
    switch (this) {
      case DesireStatus.open:
        return '🌱';
      case DesireStatus.manifesting:
        return '🌙';
      case DesireStatus.manifested:
        return '✨';
      case DesireStatus.released:
        return '🕊️';
    }
  }
}
