import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado do Salem, o gatinho mascote: visível/escondido (5 toques nele o
/// dissolvem em fumaça; 5 toques seguidos na tela o trazem de volta) e o
/// walk-through guiado (1º acesso + "rever tour" nas Configurações).
class MascotProvider with ChangeNotifier {
  static const String _hiddenKey = 'mascot_hidden';
  static const String _tourSeenPrefix = 'salem_tour_seen_';

  final SharedPreferences _prefs;

  bool _hidden;
  bool _tourRequested = false;

  MascotProvider(this._prefs) : _hidden = _prefs.getBool(_hiddenKey) ?? false;

  /// Salem está escondido (sumiu em fumaça ou desligado nas Configurações)?
  bool get isHidden => _hidden;

  /// Um tour foi pedido (1º acesso ou "rever tour")? A HomePage consome.
  bool get tourRequested => _tourRequested;

  Future<void> setHidden(bool value) async {
    if (_hidden == value) return;
    _hidden = value;
    await _prefs.setBool(_hiddenKey, value);
    notifyListeners();
  }

  Future<void> hide() => setHidden(true);
  Future<void> show() => setHidden(false);

  bool hasSeenTour(String userId) =>
      _prefs.getBool('$_tourSeenPrefix$userId') ?? false;

  Future<void> markTourSeen(String userId) async {
    await _prefs.setBool('$_tourSeenPrefix$userId', true);
  }

  /// Pede o tour (usado pelo "Rever tour com o Salem" nas Configurações).
  void requestTour() {
    _tourRequested = true;
    notifyListeners();
  }

  /// A HomePage consumiu o pedido e está exibindo o tour.
  void consumeTourRequest() {
    _tourRequested = false;
  }
}
