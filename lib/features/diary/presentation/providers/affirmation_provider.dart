import 'package:flutter/foundation.dart';
import '../../data/models/affirmation_model.dart';
import '../../data/repositories/affirmation_repository.dart';

class AffirmationProvider with ChangeNotifier {
  final AffirmationRepository _repository = AffirmationRepository();

  List<AffirmationModel> _affirmations = [];
  bool _isLoading = false;
  String? _error;
  AffirmationCategory? _selectedCategory;

  List<AffirmationModel> get affirmations => _selectedCategory == null
      ? _affirmations
      : _affirmations.where((a) => a.category == _selectedCategory).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  AffirmationCategory? get selectedCategory => _selectedCategory;

  Future<void> loadAffirmations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Verificar se já existem afirmações pré-carregadas
      final hasPreloaded = await _repository.hasPreloadedData();

      // Se não existirem, carregar as afirmações padrão
      if (!hasPreloaded) {
        await _repository.insertAll(AffirmationModel.getPreloadedAffirmations());
      }

      _affirmations = await _repository.getAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(AffirmationCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addAffirmation(AffirmationModel affirmation) async {
    try {
      await _repository.insert(affirmation);
      await loadAffirmations();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(AffirmationModel affirmation) async {
    try {
      final updated = affirmation.copyWith(isFavorite: !affirmation.isFavorite);
      await _repository.update(updated);
      await loadAffirmations();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteAffirmation(String id) async {
    try {
      await _repository.delete(id);
      await loadAffirmations();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<AffirmationModel> getFavorites() {
    return _affirmations.where((a) => a.isFavorite).toList();
  }
}
