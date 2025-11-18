// lib/services/repositories/desire_repository.dart
import 'dart:math';
import '../../models/desire.dart';

class DesireRepository {
  final List<Desire> _desires = [];

  List<Desire> getAll() {
    return List.unmodifiable(_desires.reversed);
  }

  Desire create({
    required String title,
    String? category,
    DesireStatus status = DesireStatus.open,
    String? notes,
  }) {
    final now = DateTime.now();
    final id = _generateId();
    final desire = Desire(
      id: id,
      title: title,
      category: category,
      status: status,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    _desires.add(desire);
    return desire;
  }

  void update(Desire updated) {
    final index = _desires.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      _desires[index] = updated.copyWith(updatedAt: DateTime.now());
    }
  }

  void delete(String id) {
    _desires.removeWhere((d) => d.id == id);
  }

  String _generateId() {
    final rand = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        rand.nextInt(999999).toString();
  }
}
