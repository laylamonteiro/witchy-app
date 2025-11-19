import 'package:flutter/foundation.dart';
import '../../data/models/dream_model.dart';
import '../../data/repositories/dream_repository.dart';

class DreamProvider with ChangeNotifier {
  final DreamRepository _repository = DreamRepository();

  List<DreamModel> _dreams = [];
  bool _isLoading = false;
  String? _error;

  List<DreamModel> get dreams => _dreams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDreams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dreams = await _repository.getAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDream(DreamModel dream) async {
    try {
      await _repository.insert(dream);
      await loadDreams();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDream(DreamModel dream) async {
    try {
      await _repository.update(dream);
      await loadDreams();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteDream(String id) async {
    try {
      await _repository.delete(id);
      await loadDreams();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<DreamModel> searchDreams(String query) {
    final lowerQuery = query.toLowerCase();
    return _dreams.where((dream) {
      return dream.title.toLowerCase().contains(lowerQuery) ||
          dream.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<DreamModel> getDreamsByTag(String tag) {
    return _dreams.where((dream) => dream.tags.contains(tag)).toList();
  }
}
