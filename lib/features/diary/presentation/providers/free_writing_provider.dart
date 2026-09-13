import 'package:flutter/foundation.dart';
import '../../data/models/free_writing_model.dart';
import '../../data/repositories/free_writing_repository.dart';
import '../../data/services/reading_archive_recorder.dart';

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

  /// Apaga uma entrada do acervo — e, se ela for a página de uma tiragem, a
  /// consulta que a gerou.
  ///
  /// As duas são o MESMO registro, com o mesmo id; só a página é visível.
  /// Deixar a linha da ferramenta para trás significaria um contador do
  /// Ciclo que não baixa e uma tiragem que volta ao material da IA depois
  /// de apagada. A leitura da entrada vem ANTES da exclusão, que é a última
  /// chance de saber de que origem ela era.
  Future<void> delete(String id) async {
    try {
      final entrada = await _repository.getById(id);
      await _repository.delete(id);
      if (entrada != null) {
        await ReadingArchiveRecorder().discardReading(
          readingId: id,
          source: entrada.source,
        );
      }
      await loadFreeWritings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
