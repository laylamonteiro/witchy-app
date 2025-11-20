import 'package:uuid/uuid.dart';

class GratitudeModel {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime date;
  final DateTime createdAt;

  GratitudeModel({
    String? id,
    required this.title,
    required this.content,
    required this.tags,
    DateTime? date,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags.join('|||'),
      'date': date.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory GratitudeModel.fromMap(Map<String, dynamic> map) {
    return GratitudeModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      tags: map['tags'] != null && map['tags'].isNotEmpty
          ? (map['tags'] as String).split('|||')
          : [],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  GratitudeModel copyWith({
    String? title,
    String? content,
    List<String>? tags,
    DateTime? date,
  }) {
    return GratitudeModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }
}
