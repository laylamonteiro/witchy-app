// lib/models/dream.dart
class Dream {
  final String id;
  final DateTime date;
  final String? title;
  final String content;
  final List<String> tags; // ["pesadelo", "recorrente"]
  final String? feelingOnWake; // "ansiosa", "aliviada" etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  Dream({
    required this.id,
    required this.date,
    this.title,
    required this.content,
    required this.tags,
    this.feelingOnWake,
    required this.createdAt,
    required this.updatedAt,
  });

  Dream copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    List<String>? tags,
    String? feelingOnWake,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dream(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      feelingOnWake: feelingOnWake ?? this.feelingOnWake,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'tags': tags,
      'feelingOnWake': feelingOnWake,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Dream.fromMap(Map<String, dynamic> map) {
    return Dream(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String?,
      content: map['content'] as String,
      tags: List<String>.from(map['tags'] ?? []),
      feelingOnWake: map['feelingOnWake'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
