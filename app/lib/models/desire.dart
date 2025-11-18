// lib/models/desire.dart
enum DesireStatus {
  open,
  inProgress,
  realized,
}

class Desire {
  final String id;
  final String title; // desejo/intenção
  final String? category; // amor, trabalho, espiritualidade...
  final DesireStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Desire({
    required this.id,
    required this.title,
    this.category,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Desire copyWith({
    String? id,
    String? title,
    String? category,
    DesireStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Desire(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Desire.fromMap(Map<String, dynamic> map) {
    return Desire(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String?,
      status: DesireStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => DesireStatus.open,
      ),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
