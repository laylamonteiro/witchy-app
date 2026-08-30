import '../models/user_model.dart';

/// Resultado de uma operação de autenticação
class AuthResult {
  final bool success;
  final UserModel? user;
  final String? errorMessage;
  final AuthErrorCode? errorCode;

  /// A autenticação SAIU do app: o navegador foi para o provedor e voltará por
  /// redirect, recarregando a página. Não é sucesso nem erro — não há usuário
  /// para entregar, e quem chamou não deve navegar nem mostrar mensagem, sob
  /// pena de piscar uma tela intermediária antes de o navegador sair.
  final bool redirecting;

  /// A conta foi criada mas o Supabase NÃO devolveu sessão: o projeto exige
  /// confirmação de e-mail e ela está pendente. Tratar como logado aqui é
  /// mentira cara — o app inteiro passa a falar com o servidor como `anon`
  /// e cada recurso de nuvem falha em silêncio (foi o bug do resgate de
  /// Código Premium no webapp). Quem chamar deve mandar a pessoa confirmar
  /// o e-mail e entrar pela tela de login.
  final bool emailConfirmationPending;

  const AuthResult({
    required this.success,
    this.user,
    this.errorMessage,
    this.errorCode,
    this.redirecting = false,
    this.emailConfirmationPending = false,
  });

  factory AuthResult.redirecting() =>
      const AuthResult(success: false, redirecting: true);

  factory AuthResult.success(UserModel user) => AuthResult(
        success: true,
        user: user,
      );

  factory AuthResult.confirmationPending(UserModel user) => AuthResult(
        success: true,
        user: user,
        emailConfirmationPending: true,
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
  /// O projeto exige captcha e esta versão do app não sabe enviá-lo —
  /// só acontece com quem ainda não atualizou.
  captchaRequired,

  /// Conta existe mas o e-mail nunca foi confirmado (o projeto exige
  /// confirmação). Quem recebe este código deve OFERECER O REENVIO do
  /// link — o original expira em horas e, sem sessão, o reenvio da tela
  /// de perfil não alcança essa pessoa.
  emailNotConfirmed,
  unknown,
}

/// Interface abstrata para operações de autenticação
/// Permite trocar entre implementações local e cloud (Supabase)
abstract class AuthRepository {
  /// Verifica se há um usuário autenticado
  Future<UserModel?> getCurrentUser();

  /// Login com email e senha
  Future<AuthResult> signInWithEmail(
    String email,
    String password, {
    String? captchaToken,
  });

  /// Cadastro com email e senha
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? captchaToken,
  });

  /// Login com Google
  Future<AuthResult> signInWithGoogle({String? captchaToken});

  /// Login com Facebook
  Future<AuthResult> signInWithFacebook();

  /// Login com Apple (mantido para compatibilidade)
  Future<AuthResult> signInWithApple();

  /// Logout
  Future<void> signOut();

  /// Envia email de recuperação de senha
  Future<AuthResult> sendPasswordResetEmail(
    String email, {
    String? captchaToken,
  });

  /// Reenvia o e-mail de confirmação da conta.
  ///
  /// Pede [captchaToken] porque o Supabase exige captcha também no reenvio
  /// (Attack Protection ligado): sem token, a chamada é recusada.
  Future<AuthResult> verifyEmail({String? captchaToken});

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
