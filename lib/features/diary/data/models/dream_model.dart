import 'package:uuid/uuid.dart';

class DreamModel {
  final String id;
  final String? userId;
  final String title;
  final String content;
  final List<String> tags;
  final String? feeling;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  DreamModel({
    String? id,
    this.userId,
    required this.title,
    required this.content,
    required this.tags,
    this.feeling,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.synced = false,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId ?? 'local_user',
      'title': title,
      'content': content,
      'tags': tags.join('|||'),
      'feeling': feeling,
      'date': date.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'synced': synced ? 1 : 0,
    };
  }

  factory DreamModel.fromMap(Map<String, dynamic> map) {
    return DreamModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'],
      tags: map['tags'] != null && map['tags'].isNotEmpty
          ? (map['tags'] as String).split('|||')
          : [],
      feeling: map['feeling'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      synced: map['synced'] == 1,
    );
  }

  DreamModel copyWith({
    String? userId,
    String? title,
    String? content,
    List<String>? tags,
    String? feeling,
    DateTime? date,
    bool? synced,
  }) {
    return DreamModel(
      id: id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      feeling: feeling ?? this.feeling,
      date: date ?? this.date,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      synced: synced ?? false, // Marca como não sincronizado após edição
    );
  }
}
