import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado do Salem, o gatinho mascote: visível/escondido (5 toques nele o
/// dissolvem em fumaça; 5 toques seguidos na tela, fechar o app ou o
/// "refresh" de sessão o trazem de volta) e o walk-through guiado
/// (1º acesso + "rever tour" nas Configurações).
///
/// O escondido NÃO persiste de propósito: cada sessão nova começa com o
/// Salem presente — sumir é sempre temporário.
class MascotProvider with ChangeNotifier {
  static const String _tourSeenPrefix = 'salem_tour_seen_';

  final SharedPreferences _prefs;

  bool _hidden = false;
  bool _appearPending = false;
  bool _tourRequested = false;

  MascotProvider(this._prefs);

  /// Salem está escondido (sumiu em fumaça)?
  bool get isHidden => _hidden;

  /// Salem acabou de voltar e deve MATERIALIZAR em fumaça (em vez de só
  /// aparecer)? O mascote consome via [consumeAppearPending].
  bool get appearPending => _appearPending;

  /// Um tour foi pedido (1º acesso ou "rever tour")? A HomePage consome.
  bool get tourRequested => _tourRequested;

  void hide() {
    if (_hidden) return;
    _hidden = true;
    notifyListeners();
  }

  void show() {
    if (!_hidden) return;
    _hidden = false;
    // Voltar do esconderijo = entrada em fumaça (espelho do sumiço).
    materializeNext();
  }

  /// Pede que o Salem MATERIALIZE em fumaça da próxima vez que entrar em
  /// cena — usado também ao fim do tour, quando o mascote real substitui o
  /// Salem-guia do walk-through.
  void materializeNext() {
    _appearPending = true;
    notifyListeners();
  }

  /// O mascote iniciou a animação de materializar (sem notify: chamado
  /// durante o build/pós-frame).
  void consumeAppearPending() {
    _appearPending = false;
  }

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
