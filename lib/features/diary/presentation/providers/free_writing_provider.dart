import 'package:flutter/foundation.dart';
import '../../data/models/free_writing_model.dart';
import '../../data/repositories/free_writing_repository.dart';

class FreeWritingProvider with ChangeNotifier {
  final FreeWritingRepository _repository = FreeWritingRepository();

  List<FreeWritingModel> _freeWritings = [];
  bool _isLoading = false;
  String? _error;
  String _currentUserId = 'local_user';

  List<FreeWritingModel> get freeWritings => _freeWritings;

  /// Só o que a Bruxa escreveu de fato (aba 💭 dos Diários) — as páginas
  /// geradas (lições e leituras) moram em "Meus Registros".
  List<FreeWritingModel> get reflections => _freeWritings
      .where((w) => w.source == FreeWritingSource.free)
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> setUserId(String userId) async {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    await loadFreeWritings();
  }

  Future<void> loadFreeWritings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _freeWritings = await _repository.getAll(_currentUserId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Salva (upsert) uma reflexão. Usado pelo autosave do canvas: o mesmo id é
  /// reutilizado a cada digitação, então o insert com replace atualiza a linha.
  Future<void> save(FreeWritingModel writing) async {
    try {
      await _repository.insert(writing.copyWith(userId: _currentUserId));
      await loadFreeWritings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
      await loadFreeWritings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
