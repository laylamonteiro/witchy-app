import 'package:flutter/foundation.dart';
import '../../data/models/gratitude_model.dart';
import '../../data/repositories/gratitude_repository.dart';

class GratitudeProvider with ChangeNotifier {
  final GratitudeRepository _repository = GratitudeRepository();

  List<GratitudeModel> _gratitudes = [];
  bool _isLoading = false;
  String? _error;

  List<GratitudeModel> get gratitudes => _gratitudes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGratitudes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _gratitudes = await _repository.getAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGratitude(GratitudeModel gratitude) async {
    try {
      await _repository.insert(gratitude);
      await loadGratitudes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGratitude(GratitudeModel gratitude) async {
    try {
      await _repository.update(gratitude);
      await loadGratitudes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteGratitude(String id) async {
    try {
      await _repository.delete(id);
      await loadGratitudes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<GratitudeModel> searchGratitudes(String query) {
    final lowerQuery = query.toLowerCase();
    return _gratitudes.where((gratitude) {
      return gratitude.title.toLowerCase().contains(lowerQuery) ||
          gratitude.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<GratitudeModel> getGratitudesByTag(String tag) {
    return _gratitudes.where((gratitude) => gratitude.tags.contains(tag)).toList();
  }
}
