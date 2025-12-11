/// Configuração do usuário admin (apenas para uso interno/dev).
/// As credenciais devem ser injetadas via --dart-define ou .env e nunca hardcoded.
class AdminConfig {
  static const String email = String.fromEnvironment('ADMIN_EMAIL', defaultValue: '');
  static const String password = String.fromEnvironment('ADMIN_PASSWORD', defaultValue: '');

  static bool get isEnabled => email.isNotEmpty && password.isNotEmpty;
}
