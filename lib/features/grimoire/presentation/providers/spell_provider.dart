import 'package:flutter/foundation.dart';
import '../../data/models/spell_model.dart';
import '../../data/repositories/spell_repository.dart';

class SpellProvider with ChangeNotifier {
  final SpellRepository _repository = SpellRepository();

  List<SpellModel> _spells = [];
  bool _isLoading = false;
  String? _error;

  List<SpellModel> get spells => _spells;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSpells() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _spells = await _repository.getAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSpell(SpellModel spell) async {
    try {
      await _repository.insert(spell);
      await loadSpells();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateSpell(SpellModel spell) async {
    try {
      await _repository.update(spell);
      await loadSpells();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSpell(String id) async {
    try {
      await _repository.delete(id);
      await loadSpells();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<SpellModel> getSpellsByType(SpellType type) {
    return _spells.where((spell) => spell.type == type).toList();
  }

  List<SpellModel> searchSpells(String query) {
    final lowerQuery = query.toLowerCase();
    return _spells.where((spell) {
      return spell.name.toLowerCase().contains(lowerQuery) ||
          spell.purpose.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
