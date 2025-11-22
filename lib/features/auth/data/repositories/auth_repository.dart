import '../models/user_model.dart';

/// Resultado de uma operação de autenticação
class AuthResult {
  final bool success;
  final UserModel? user;
  final String? errorMessage;
  final AuthErrorCode? errorCode;

  const AuthResult({
    required this.success,
    this.user,
    this.errorMessage,
    this.errorCode,
  });

  factory AuthResult.success(UserModel user) => AuthResult(
        success: true,
        user: user,
      );

  factory AuthResult.error(String message, [AuthErrorCode? code]) => AuthResult(
        success: false,
        errorMessage: message,
        errorCode: code,
      );
}

/// Códigos de erro de autenticação
enum AuthErrorCode {
  invalidEmail,
  invalidPassword,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  networkError,
  tooManyRequests,
  unknown,
}

/// Interface abstrata para operações de autenticação
/// Permite trocar entre implementações local e cloud (Supabase)
abstract class AuthRepository {
  /// Verifica se há um usuário autenticado
  Future<UserModel?> getCurrentUser();

  /// Login com email e senha
  Future<AuthResult> signInWithEmail(String email, String password);

  /// Cadastro com email e senha
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Login com Google
  Future<AuthResult> signInWithGoogle();

  /// Login com Apple
  Future<AuthResult> signInWithApple();

  /// Logout
  Future<void> signOut();

  /// Envia email de recuperação de senha
  Future<AuthResult> sendPasswordResetEmail(String email);

  /// Verifica o email do usuário
  Future<AuthResult> verifyEmail();

  /// Atualiza perfil do usuário
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
    DateTime? birthDate,
    String? birthTime,
    String? birthPlace,
  });

  /// Atualiza a senha do usuário
  Future<AuthResult> updatePassword(String currentPassword, String newPassword);

  /// Deleta a conta do usuário
  Future<AuthResult> deleteAccount();

  /// Stream de mudanças no estado de autenticação
  Stream<UserModel?> get authStateChanges;
}
