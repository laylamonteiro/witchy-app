/// A credencial do Google obtida DENTRO da página (web) — ver
/// `GoogleSignInConfig`. Fora da web, o stub devolve nulo e quem chama segue
/// pelo caminho nativo.
export 'google_one_tap_stub.dart'
    if (dart.library.js_util) 'google_one_tap_web.dart';
