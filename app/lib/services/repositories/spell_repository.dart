// lib/services/repositories/spell_repository.dart
import 'dart:math';
import '../../models/spell.dart';

class SpellRepository {
  final List<Spell> _spells = [];

  List<Spell> getAll() {
    return List.unmodifiable(_spells.reversed);
  }

  Spell create({
    required String name,
    required List<String> tags,
    required SpellType type,
    String? moonPhaseRecommendation,
    required String ingredients,
    required String steps,
    String? notes,
  }) {
    final now = DateTime.now();
    final id = _generateId();
    final spell = Spell(
      id: id,
      name: name,
      tags: tags,
      type: type,
      moonPhaseRecommendation: moonPhaseRecommendation,
      ingredients: ingredients,
      steps: steps,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    _spells.add(spell);
    return spell;
  }

  void update(Spell updated) {
    final index = _spells.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _spells[index] = updated.copyWith(updatedAt: DateTime.now());
    }
  }

  void delete(String id) {
    _spells.removeWhere((s) => s.id == id);
  }

  String _generateId() {
    final rand = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        rand.nextInt(999999).toString();
  }
}
