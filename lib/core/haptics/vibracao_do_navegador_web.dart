import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// A perna web do `ToqueMagico`: `navigator.vibrate(ms)`.
///
/// A checagem de existência antes da chamada não é frescura: o Safari (iOS
/// inteiro, PWA incluída) não implementa a API de vibração, e chamar um
/// método que não existe via interop estoura TypeError no console. Aqui a
/// ausência vira silêncio — mesma política do resto das pontes web do app.
void vibrarNoNavegador(int ms) {
  final navegador = web.window.navigator as JSObject;
  if (!navegador.has('vibrate')) return;
  navegador.callMethod('vibrate'.toJS, ms.toJS);
}
