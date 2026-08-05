import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/data_sources/affirmation_localizer.dart';
import '../../data/models/affirmation_model.dart';
import '../../data/repositories/affirmation_repository.dart';

class AffirmationProvider with ChangeNotifier {
  final AffirmationRepository _repository = AffirmationRepository();

  List<AffirmationModel> _affirmations = [];
  bool _isLoading = false;
  String? _error;
  AffirmationCategory? _selectedCategory;
  String _currentUserId = 'local_user';

  /// A lista em memória guarda o texto CRU do banco (PT nas pré-carregadas);
  /// a tradução é aplicada aqui, na exibição — trocar o idioma do app
  /// retraduz na hora, sem depender de recarga.
  List<AffirmationModel> get affirmations => (_selectedCategory == null
          ? _affirmations
          : _affirmations.where((a) => a.category == _selectedCategory))
      .map(AffirmationLocalizer.localize)
      .toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  AffirmationCategory? get selectedCategory => _selectedCategory;

  Future<void> setUserId(String userId) async {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    await loadAffirmations();
  }

  static const String _seedVersionKey = 'affirmations_seed_version';

  /// Semeia as afirmações padrão na primeira vez e, quando o conteúdo é
  /// revisado (seedVersion sobe), troca as antigas pelas novas na próxima
  /// abertura. As favoritadas ficam — viraram escolha da pessoa.
  Future<void> _ensureSeed() async {
    final prefs = await SharedPreferences.getInstance();
    final seeded = prefs.getInt(_seedVersionKey) ??
        // Sem marca: quem já tem linhas veio da semeadura 1; banco vazio
        // ainda não foi semeado.
        (await _repository.hasPreloadedData() ? 1 : 0);
    if (seeded >= AffirmationModel.seedVersion) return;

    if (seeded > 0) {
      await _repository.deletePreloadedExceptFavorites();
    }
    await _repository.insertAll(AffirmationModel.getPreloadedAffirmations());
    await prefs.setInt(_seedVersionKey, AffirmationModel.seedVersion);
  }

  Future<void> loadAffirmations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _ensureSeed();

      // Guarda o texto CRU; a tradução acontece na exibição. De quebra,
      // repara linhas pré-carregadas que um favoritar antigo persistiu
      // traduzidas (o banco volta ao PT canônico, chave dos overlays).
      final rows = await _repository.getAll(_currentUserId);
      final repaired = <AffirmationModel>[];
      for (final row in rows) {
        final canonical =
            row.isPreloaded ? AffirmationLocalizer.canonicalPtFor(row.text) : null;
        if (canonical != null && canonical != row.text) {
          final fixed = row.copyWith(text: canonical);
          await _repository.update(fixed);
          repaired.add(fixed);
        } else {
          repaired.add(row);
        }
      }
      _affirmations = repaired;
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
      await _repository.insert(
        affirmation.copyWith(userId: _currentUserId),
      );
      await loadAffirmations();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(AffirmationModel affirmation) async {
    try {
      // O modelo vindo da UI pode estar com o texto TRADUZIDO (exibição);
      // persiste sempre a linha crua do banco, achada por id — nunca gravar
      // texto de exibição é o que mantém o PT canônico das pré-carregadas.
      final raw = _affirmations.firstWhere(
        (a) => a.id == affirmation.id,
        orElse: () => affirmation,
      );
      final updated = raw.copyWith(isFavorite: !affirmation.isFavorite);
      await _repository.update(updated.copyWith(userId: _currentUserId));
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
    return _affirmations
        .where((a) => a.isFavorite)
        .map(AffirmationLocalizer.localize)
        .toList();
  }

  /// Afirmação do dia (Seu Dia): determinística por data sobre as
  /// pré-carregadas, ignorando o filtro de categoria. Ordena por id para o
  /// resultado ser o mesmo em qualquer dispositivo/ordem de leitura do banco.
  AffirmationModel? affirmationForDate(DateTime date) {
    final preloaded = _affirmations.where((a) => a.isPreloaded).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (preloaded.isEmpty) return null;
    final dayOfYear =
        date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    // Tradução na exibição: trocar o idioma retraduz na hora.
    return AffirmationLocalizer.localize(preloaded[dayOfYear % preloaded.length]);
  }
}
