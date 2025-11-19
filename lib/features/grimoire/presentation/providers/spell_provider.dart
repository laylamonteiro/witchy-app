import 'package:flutter/foundation.dart';
import '../../data/models/spell_model.dart';
import '../../data/repositories/spell_repository.dart';
import '../../data/data_sources/spells_data.dart';

class SpellProvider with ChangeNotifier {
  final SpellRepository _repository = SpellRepository();

  List<SpellModel> _spells = [];
  bool _isLoading = false;
  String? _error;
  bool _preloadedSpellsInitialized = false;

  List<SpellModel> get spells => _spells;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtrar feitiços do app (pré-carregados)
  List<SpellModel> get appSpells => _spells.where((s) => s.isPreloaded).toList();

  // Filtrar feitiços do usuário (criados)
  List<SpellModel> get userSpells => _spells.where((s) => !s.isPreloaded).toList();

  Future<void> loadSpells() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Carregar feitiços pré-carregados pela primeira vez
      if (!_preloadedSpellsInitialized) {
        await _loadPreloadedSpells();
        _preloadedSpellsInitialized = true;
      }

      _spells = await _repository.getAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar feitiços pré-carregados no banco pela primeira vez
  Future<void> _loadPreloadedSpells() async {
    try {
      // Verifica se já existem feitiços pré-carregados
      final existingSpells = await _repository.getAll();
      final hasPreloaded = existingSpells.any((s) => s.isPreloaded);

      if (!hasPreloaded) {
        // Insere todos os feitiços pré-carregados
        for (final spell in preloadedSpells) {
          await _repository.insert(spell);
        }
      }
    } catch (e) {
      print('Erro ao carregar feitiços pré-carregados: $e');
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
