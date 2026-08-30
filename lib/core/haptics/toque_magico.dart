import 'package:flutter/services.dart';

import 'vibracao_do_navegador_stub.dart'
    if (dart.library.js_interop) 'vibracao_do_navegador_web.dart';

/// O toque físico dos momentos mágicos — a vibração curta de quando a capa
/// do Grimório pousa ou o Salem responde a um carinho.
///
/// Duas pernas, nunca as duas ao mesmo tempo:
/// - No celular nativo, `HapticFeedback` (o mesmo já usado no auth e nas
///   lições) e a ponte do navegador é um vazio.
/// - Na web, `HapticFeedback` é um no-op silencioso do motor — quem vibra é
///   `navigator.vibrate`, pela ponte condicional ao lado. No iPhone a web
///   não vibra nunca (o Safari não implementa a API); a ponte engole isso
///   sem erro, e o iOS de verdade fica com o app nativo.
///
/// Sem toggle próprio de propósito (decisão de ago/2026): a vibração segue
/// as configurações do aparelho — quem silencia o celular silencia o app.
abstract final class ToqueMagico {
  /// Toque leve: o carinho no Salem.
  static void leve() {
    HapticFeedback.lightImpact();
    vibrarNoNavegador(20);
  }

  /// Toque médio: a capa que pousa, o puf de fumaça.
  static void medio() {
    HapticFeedback.mediumImpact();
    vibrarNoNavegador(40);
  }
}
