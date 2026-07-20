import 'package:flutter/foundation.dart' show kDebugMode;

/// Configuração do usuário admin (apenas para uso interno/dev).
/// As credenciais devem ser injetadas via --dart-define e nunca hardcoded.
class AdminConfig {
  static const String _envEmail =
      String.fromEnvironment('ADMIN_EMAIL', defaultValue: '');
  static const String _envPassword =
      String.fromEnvironment('ADMIN_PASSWORD', defaultValue: '');

  /// Em debug (flutter run), admin/admin funciona sem configurar nada.
  /// Em release, valem apenas as credenciais injetadas no build
  /// (secrets ADMIN_EMAIL/ADMIN_PASSWORD do GitHub Actions).
  static String get email =>
      _envEmail.isNotEmpty ? _envEmail : (kDebugMode ? 'admin' : '');
  static String get password =>
      _envPassword.isNotEmpty ? _envPassword : (kDebugMode ? 'admin' : '');

  static bool get isEnabled => email.isNotEmpty && password.isNotEmpty;
}
