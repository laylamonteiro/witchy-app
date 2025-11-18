import 'package:uuid/uuid.dart';

class DreamModel {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final String? feeling;
  final DateTime date;
  final DateTime createdAt;

  DreamModel({
    String? id,
    required this.title,
    required this.content,
    required this.tags,
    this.feeling,
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
      'feeling': feeling,
      'date': date.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory DreamModel.fromMap(Map<String, dynamic> map) {
    return DreamModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      tags: map['tags'] != null && map['tags'].isNotEmpty
          ? (map['tags'] as String).split('|||')
          : [],
      feeling: map['feeling'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  DreamModel copyWith({
    String? title,
    String? content,
    List<String>? tags,
    String? feeling,
    DateTime? date,
  }) {
    return DreamModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      feeling: feeling ?? this.feeling,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }
}
