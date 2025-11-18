import 'package:flutter/foundation.dart';
import '../../data/models/desire_model.dart';
import '../../data/repositories/desire_repository.dart';

class DesireProvider with ChangeNotifier {
  final DesireRepository _repository = DesireRepository();

  List<DesireModel> _desires = [];
  bool _isLoading = false;
  String? _error;

  List<DesireModel> get desires => _desires;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDesires() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _desires = await _repository.getAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDesire(DesireModel desire) async {
    try {
      await _repository.insert(desire);
      await loadDesires();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDesire(DesireModel desire) async {
    try {
      await _repository.update(desire);
      await loadDesires();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteDesire(String id) async {
    try {
      await _repository.delete(id);
      await loadDesires();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<DesireModel> getDesiresByStatus(DesireStatus status) {
    return _desires.where((desire) => desire.status == status).toList();
  }
}
