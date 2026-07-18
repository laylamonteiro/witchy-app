import 'package:flutter/foundation.dart';
import '../../data/models/spell_model.dart';
import '../../data/repositories/spell_repository.dart';

class SpellProvider with ChangeNotifier {
  final SpellRepository _repository = SpellRepository();

  List<SpellModel> _spells = [];
  bool _isLoading = false;
  String? _error;
  String _currentUserId = 'local_user';

  List<SpellModel> get spells => _spells;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtrar feitiços do app (pré-carregados)
  List<SpellModel> get appSpells =>
      _spells.where((s) => s.isPreloaded).toList();

  // Filtrar feitiços do usuário (criados) - já filtrados por userId no repository
  List<SpellModel> get userSpells =>
      _spells.where((s) => !s.isPreloaded).toList();

  /// Define o ID do usuário atual e recarrega os feitiços
  Future<void> setUserId(String userId) async {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      await loadSpells();
    }
  }

  Future<void> loadSpells() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.ensurePreloadedSpells();

      // Carregar apenas os feitiços do usuário atual + pré-carregados
      _spells = await _repository.getForUser(_currentUserId);
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
      await _repository.insert(
        spell.isPreloaded ? spell : spell.copyWith(userId: _currentUserId),
      );
      await loadSpells();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateSpell(SpellModel spell) async {
    try {
      await _repository.update(spell.copyWith(userId: _currentUserId));
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

  List<SpellModel> getSpellsByCategory(SpellCategory category) {
    return _spells.where((spell) => spell.category == category).toList();
  }

  List<SpellModel> searchSpells(String query) {
    final lowerQuery = query.toLowerCase();
    return _spells.where((spell) {
      return spell.name.toLowerCase().contains(lowerQuery) ||
          spell.purpose.toLowerCase().contains(lowerQuery) ||
          spell.category.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
