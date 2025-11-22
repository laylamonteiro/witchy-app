import 'dart:async';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// Implementação do AuthRepository usando Supabase
/// TODO: Configurar Supabase e implementar métodos
///
/// Para usar, adicione ao pubspec.yaml:
/// ```yaml
/// dependencies:
///   supabase_flutter: ^2.3.0
/// ```
///
/// E configure no main.dart:
/// ```dart
/// await Supabase.initialize(
///   url: 'YOUR_SUPABASE_URL',
///   anonKey: 'YOUR_SUPABASE_ANON_KEY',
/// );
/// ```
class SupabaseAuthRepository implements AuthRepository {
  // final SupabaseClient _supabase = Supabase.instance.client;

  final _authStateController = StreamController<UserModel?>.broadcast();

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel?> getCurrentUser() async {
    // TODO: Implementar com Supabase
    // final session = _supabase.auth.currentSession;
    // if (session != null) {
    //   return _userFromSupabaseUser(session.user);
    // }
    return null;
  }

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    // TODO: Implementar com Supabase
    // try {
    //   final response = await _supabase.auth.signInWithPassword(
    //     email: email,
    //     password: password,
    //   );
    //   if (response.user != null) {
    //     final user = await _userFromSupabaseUser(response.user!);
    //     return AuthResult.success(user);
    //   }
    //   return AuthResult.error('Erro ao fazer login');
    // } on AuthException catch (e) {
    //   return _handleAuthException(e);
    // }
    return AuthResult.error('Supabase não configurado');
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // TODO: Implementar com Supabase
    // try {
    //   final response = await _supabase.auth.signUp(
    //     email: email,
    //     password: password,
    //     data: {'display_name': displayName},
    //   );
    //   if (response.user != null) {
    //     final user = await _userFromSupabaseUser(response.user!);
    //     return AuthResult.success(user);
    //   }
    //   return AuthResult.error('Erro ao criar conta');
    // } on AuthException catch (e) {
    //   return _handleAuthException(e);
    // }
    return AuthResult.error('Supabase não configurado');
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    // TODO: Implementar com Supabase
    // try {
    //   await _supabase.auth.signInWithOAuth(
    //     OAuthProvider.google,
    //     redirectTo: 'io.supabase.grimorio://callback',
    //   );
    //   return AuthResult.success(UserModel.defaultUser());
    // } on AuthException catch (e) {
    //   return _handleAuthException(e);
    // }
    return AuthResult.error('Login com Google não configurado');
  }

  @override
  Future<AuthResult> signInWithApple() async {
    // TODO: Implementar com Supabase
    // try {
    //   await _supabase.auth.signInWithOAuth(
    //     OAuthProvider.apple,
    //     redirectTo: 'io.supabase.grimorio://callback',
    //   );
    //   return AuthResult.success(UserModel.defaultUser());
    // } on AuthException catch (e) {
    //   return _handleAuthException(e);
    // }
    return AuthResult.error('Login com Apple não configurado');
  }

  @override
  Future<void> signOut() async {
    // TODO: Implementar com Supabase
    // await _supabase.auth.signOut();
    _authStateController.add(null);
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    // TODO: Implementar com Supabase
    // try {
    //   await _supabase.auth.resetPasswordForEmail(email);
    //   return AuthResult.success(UserModel.defaultUser());
    // } on AuthException catch (e) {
    //   return _handleAuthException(e);
    // }
    return AuthResult.error('Supabase não configurado');
  }

  @override
  Future<AuthResult> verifyEmail() async {
    // TODO: Implementar com Supabase
    return AuthResult.error('Supabase não configurado');
  }

  @override
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
    DateTime? birthDate,
    String? birthTime,
    String? birthPlace,
  }) async {
    // TODO: Implementar com Supabase
    // try {
    //   await _supabase.auth.updateUser(
    //     UserAttributes(
    //       data: {
    //         'display_name': displayName,
    //         'photo_url': photoUrl,
    //         'birth_date': birthDate?.toIso8601String(),
    //         'birth_time': birthTime,
    //         'birth_place': birthPlace,
    //       },
    //     ),
    //   );
    //   final user = await getCurrentUser();
    //   if (user != null) {
    //     return AuthResult.success(user);
    //   }
    //   return AuthResult.error('Erro ao atualizar perfil');
    // } on AuthException catch (e) {
    //   return _handleAuthException(e);
    // }
    return AuthResult.error('Supabase não configurado');
  }

  @override
  Future<AuthResult> updatePassword(
      String currentPassword, String newPassword) async {
    // TODO: Implementar com Supabase
    // try {
    //   await _supabase.auth.updateUser(
    //     UserAttributes(password: newPassword),
    //   );
    //   final user = await getCurrentUser();
    //   if (user != null) {
    //     return AuthResult.success(user);
    //   }
    //   return AuthResult.error('Erro ao atualizar senha');
    // } on AuthException catch (e) {
    //   return _handleAuthException(e);
    // }
    return AuthResult.error('Supabase não configurado');
  }

  @override
  Future<AuthResult> deleteAccount() async {
    // TODO: Implementar com Supabase (requer função Edge)
    // Deletar conta requer uma função Edge no Supabase
    // por motivos de segurança
    return AuthResult.error('Supabase não configurado');
  }

  // Helper para converter usuário do Supabase para UserModel
  // Future<UserModel> _userFromSupabaseUser(User supabaseUser) async {
  //   final metadata = supabaseUser.userMetadata ?? {};
  //
  //   // Buscar dados adicionais da tabela profiles
  //   final profileData = await _supabase
  //       .from('profiles')
  //       .select()
  //       .eq('id', supabaseUser.id)
  //       .single();
  //
  //   return UserModel(
  //     id: supabaseUser.id,
  //     email: supabaseUser.email ?? '',
  //     displayName: metadata['display_name'] ?? profileData['display_name'],
  //     photoUrl: metadata['photo_url'] ?? profileData['photo_url'],
  //     birthDate: profileData['birth_date'] != null
  //         ? DateTime.parse(profileData['birth_date'])
  //         : null,
  //     birthTime: profileData['birth_time'],
  //     birthPlace: profileData['birth_place'],
  //     role: UserRole.values.firstWhere(
  //       (r) => r.name == (profileData['role'] ?? 'free'),
  //       orElse: () => UserRole.free,
  //     ),
  //     plan: SubscriptionPlan.values.firstWhere(
  //       (p) => p.name == (profileData['plan'] ?? 'free'),
  //       orElse: () => SubscriptionPlan.free,
  //     ),
  //     createdAt: DateTime.parse(supabaseUser.createdAt),
  //     lastLoginAt: DateTime.now(),
  //   );
  // }

  // Helper para tratar exceções de autenticação
  // AuthResult _handleAuthException(AuthException e) {
  //   AuthErrorCode? code;
  //   String message = e.message;
  //
  //   if (message.contains('Invalid login credentials')) {
  //     code = AuthErrorCode.invalidPassword;
  //     message = 'Email ou senha incorretos';
  //   } else if (message.contains('User not found')) {
  //     code = AuthErrorCode.userNotFound;
  //     message = 'Usuário não encontrado';
  //   } else if (message.contains('Email already registered')) {
  //     code = AuthErrorCode.emailAlreadyInUse;
  //     message = 'Este email já está em uso';
  //   } else if (message.contains('Password should be')) {
  //     code = AuthErrorCode.weakPassword;
  //     message = 'A senha deve ter pelo menos 6 caracteres';
  //   }
  //
  //   return AuthResult.error(message, code);
  // }

  void dispose() {
    _authStateController.close();
  }
}
