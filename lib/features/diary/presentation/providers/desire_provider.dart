import 'package:flutter/foundation.dart';
import '../../data/models/desire_model.dart';
import '../../data/repositories/desire_repository.dart';

class DesireProvider with ChangeNotifier {
  final DesireRepository _repository = DesireRepository();

  List<DesireModel> _desires = [];
  bool _isLoading = false;
  String? _error;
  String _currentUserId = 'local_user';

  List<DesireModel> get desires => _desires;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> setUserId(String userId) async {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    await loadDesires();
  }

  Future<void> loadDesires() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _desires = await _repository.getAll(_currentUserId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns whether the wish was persisted.
  Future<bool> addDesire(DesireModel desire) async {
    try {
      await _repository.insert(desire.copyWith(userId: _currentUserId));
      await loadDesires();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Returns whether the change was persisted.
  Future<bool> updateDesire(DesireModel desire) async {
    try {
      await _repository.update(desire.copyWith(userId: _currentUserId));
      await loadDesires();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
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
