import 'package:uuid/uuid.dart';

enum DesireStatus {
  open, // Em aberto
  manifesting, // Manifestando
  manifested, // Manifestado
  released, // Liberado
}

class DesireModel {
  final String id;
  final String title;
  final String description;
  final DesireStatus status;
  final String? evolution;
  final DateTime createdAt;
  final DateTime updatedAt;

  DesireModel({
    String? id,
    required this.title,
    required this.description,
    this.status = DesireStatus.open,
    this.evolution,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'evolution': evolution,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory DesireModel.fromMap(Map<String, dynamic> map) {
    return DesireModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: DesireStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DesireStatus.open,
      ),
      evolution: map['evolution'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  DesireModel copyWith({
    String? title,
    String? description,
    DesireStatus? status,
    String? evolution,
  }) {
    return DesireModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      evolution: evolution ?? this.evolution,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
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
