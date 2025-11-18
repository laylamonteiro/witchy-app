// lib/services/repositories/dream_repository.dart
import 'dart:math';
import '../../models/dream.dart';

class DreamRepository {
  final List<Dream> _dreams = [];

  List<Dream> getAll() {
    return List.unmodifiable(_dreams.reversed);
  }

  Dream create({
    DateTime? date,
    String? title,
    required String content,
    List<String>? tags,
    String? feelingOnWake,
  }) {
    final now = DateTime.now();
    final id = _generateId();
    final dream = Dream(
      id: id,
      date: date ?? DateTime.now(),
      title: title,
      content: content,
      tags: tags ?? [],
      feelingOnWake: feelingOnWake,
      createdAt: now,
      updatedAt: now,
    );
    _dreams.add(dream);
    return dream;
  }

  void update(Dream updated) {
    final index = _dreams.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      _dreams[index] = updated.copyWith(updatedAt: DateTime.now());
    }
  }

  void delete(String id) {
    _dreams.removeWhere((d) => d.id == id);
  }

  String _generateId() {
    final rand = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        rand.nextInt(999999).toString();
  }
}
