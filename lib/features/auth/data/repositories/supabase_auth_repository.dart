import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';
import '../../../../core/config/supabase_config.dart';

/// Implementação do AuthRepository usando Supabase
class SupabaseAuthRepository implements AuthRepository {
  late final SupabaseClient _supabase;
  final _authStateController = StreamController<UserModel?>.broadcast();
  StreamSubscription<AuthState>? _authSubscription;

  SupabaseAuthRepository() {
    _supabase = Supabase.instance.client;
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) async {
      if (data.session?.user != null) {
        final user = await _userFromSupabaseUser(data.session!.user);
        _authStateController.add(user);
      } else {
        _authStateController.add(null);
      }
    });
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      return _userFromSupabaseUser(session.user);
    }
    return null;
  }

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        final user = await _userFromSupabaseUser(response.user!);
        return AuthResult.success(user);
      }
      return AuthResult.error('Erro ao fazer login');
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.error('Erro de conexão: $e', AuthErrorCode.networkError);
    }
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );

      if (response.user != null) {
        // Criar perfil na tabela profiles
        await _createProfile(response.user!, displayName);

        final user = await _userFromSupabaseUser(response.user!);
        return AuthResult.success(user);
      }
      return AuthResult.error('Erro ao criar conta');
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.error('Erro de conexão: $e', AuthErrorCode.networkError);
    }
  }

  Future<void> _createProfile(User supabaseUser, String? displayName) async {
    try {
      await _supabase.from(SupabaseTables.profiles).upsert({
        'id': supabaseUser.id,
        'email': supabaseUser.email,
        'display_name': displayName,
        'role': 'free',
        'plan': 'free',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error but don't fail registration
      print('Erro ao criar perfil: $e');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConfig.redirectUrl,
      );
      // O resultado vem via onAuthStateChange
      return AuthResult.success(UserModel.defaultUser());
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.error('Erro no login com Google: $e');
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: SupabaseConfig.redirectUrl,
      );
      // O resultado vem via onAuthStateChange
      return AuthResult.success(UserModel.defaultUser());
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.error('Erro no login com Apple: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _authStateController.add(null);
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return AuthResult.success(UserModel.defaultUser());
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.error('Erro ao enviar email: $e');
    }
  }

  @override
  Future<AuthResult> verifyEmail() async {
    // Supabase envia email de verificação automaticamente
    // Este método pode ser usado para reenviar
    try {
      final user = _supabase.auth.currentUser;
      if (user?.email != null) {
        await _supabase.auth.resend(
          type: OtpType.signup,
          email: user!.email!,
        );
        return AuthResult.success(await _userFromSupabaseUser(user));
      }
      return AuthResult.error('Nenhum usuário logado');
    } catch (e) {
      return AuthResult.error('Erro ao verificar email: $e');
    }
  }

  @override
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
    DateTime? birthDate,
    String? birthTime,
    String? birthPlace,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return AuthResult.error('Nenhum usuário logado');
      }

      // Atualizar metadata do usuário
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            if (displayName != null) 'display_name': displayName,
            if (photoUrl != null) 'photo_url': photoUrl,
          },
        ),
      );

      // Atualizar tabela profiles
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (displayName != null) updateData['display_name'] = displayName;
      if (photoUrl != null) updateData['photo_url'] = photoUrl;
      if (birthDate != null) updateData['birth_date'] = birthDate.toIso8601String();
      if (birthTime != null) updateData['birth_time'] = birthTime;
      if (birthPlace != null) updateData['birth_place'] = birthPlace;

      await _supabase
          .from(SupabaseTables.profiles)
          .update(updateData)
          .eq('id', user.id);

      final updatedUser = await getCurrentUser();
      if (updatedUser != null) {
        return AuthResult.success(updatedUser);
      }
      return AuthResult.error('Erro ao atualizar perfil');
    } catch (e) {
      return AuthResult.error('Erro ao atualizar perfil: $e');
    }
  }

  @override
  Future<AuthResult> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      final user = await getCurrentUser();
      if (user != null) {
        return AuthResult.success(user);
      }
      return AuthResult.error('Erro ao atualizar senha');
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.error('Erro ao atualizar senha: $e');
    }
  }

  @override
  Future<AuthResult> deleteAccount() async {
    // Deletar conta requer uma função Edge no Supabase
    // por motivos de segurança (RLS)
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return AuthResult.error('Nenhum usuário logado');
      }

      // Deletar dados do usuário das tabelas
      await _deleteUserData(user.id);

      // Chamar função Edge para deletar o usuário Auth
      // await _supabase.functions.invoke('delete-user');

      await signOut();
      return AuthResult.success(UserModel.defaultUser());
    } catch (e) {
      return AuthResult.error('Erro ao deletar conta: $e');
    }
  }

  Future<void> _deleteUserData(String userId) async {
    // Deletar dados de todas as tabelas do usuário
    final tables = [
      SupabaseTables.spells,
      SupabaseTables.dreams,
      SupabaseTables.desires,
      SupabaseTables.gratitudes,
      SupabaseTables.affirmations,
      SupabaseTables.dailyRituals,
      SupabaseTables.ritualLogs,
      SupabaseTables.sigils,
      SupabaseTables.birthCharts,
      SupabaseTables.magicalProfiles,
      SupabaseTables.runeReadings,
      SupabaseTables.pendulumConsultations,
      SupabaseTables.oracleReadings,
      SupabaseTables.dailyMagicalWeather,
      SupabaseTables.profiles,
    ];

    for (final table in tables) {
      try {
        await _supabase.from(table).delete().eq('user_id', userId);
      } catch (e) {
        print('Erro ao deletar dados de $table: $e');
      }
    }
  }

  /// Converte usuário do Supabase para UserModel
  Future<UserModel> _userFromSupabaseUser(User supabaseUser) async {
    final metadata = supabaseUser.userMetadata ?? {};

    // Buscar dados adicionais da tabela profiles
    Map<String, dynamic>? profileData;
    try {
      final response = await _supabase
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', supabaseUser.id)
          .maybeSingle();
      profileData = response;
    } catch (e) {
      print('Erro ao buscar perfil: $e');
    }

    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: metadata['display_name'] ?? profileData?['display_name'],
      photoUrl: metadata['photo_url'] ?? profileData?['photo_url'],
      birthDate: profileData?['birth_date'] != null
          ? DateTime.tryParse(profileData!['birth_date'])
          : null,
      birthTime: profileData?['birth_time'],
      birthPlace: profileData?['birth_place'],
      role: UserRole.values.firstWhere(
        (r) => r.name == (profileData?['role'] ?? 'free'),
        orElse: () => UserRole.free,
      ),
      plan: SubscriptionPlan.values.firstWhere(
        (p) => p.name == (profileData?['plan'] ?? 'free'),
        orElse: () => SubscriptionPlan.free,
      ),
      createdAt: DateTime.parse(supabaseUser.createdAt),
      lastLoginAt: DateTime.now(),
      spellsCount: profileData?['spells_count'] ?? 0,
      diaryEntriesThisMonth: profileData?['diary_entries_this_month'] ?? 0,
      aiConsultationsToday: profileData?['ai_consultations_today'] ?? 0,
      pendulumUsesToday: profileData?['pendulum_uses_today'] ?? 0,
      affirmationsToday: profileData?['affirmations_today'] ?? 0,
      runeReadingsToday: profileData?['rune_readings_today'] ?? 0,
      oracleReadingsToday: profileData?['oracle_readings_today'] ?? 0,
    );
  }

  /// Trata exceções de autenticação do Supabase
  AuthResult _handleAuthException(AuthException e) {
    AuthErrorCode? code;
    String message = e.message;

    if (message.contains('Invalid login credentials')) {
      code = AuthErrorCode.invalidPassword;
      message = 'Email ou senha incorretos';
    } else if (message.contains('User not found')) {
      code = AuthErrorCode.userNotFound;
      message = 'Usuário não encontrado';
    } else if (message.contains('already registered') ||
        message.contains('already exists')) {
      code = AuthErrorCode.emailAlreadyInUse;
      message = 'Este email já está em uso';
    } else if (message.contains('Password should be') ||
        message.contains('password')) {
      code = AuthErrorCode.weakPassword;
      message = 'A senha deve ter pelo menos 6 caracteres';
    } else if (message.contains('rate limit') ||
        message.contains('too many')) {
      code = AuthErrorCode.tooManyRequests;
      message = 'Muitas tentativas. Aguarde alguns minutos.';
    } else if (message.contains('network') || message.contains('connection')) {
      code = AuthErrorCode.networkError;
      message = 'Erro de conexão. Verifique sua internet.';
    }

    return AuthResult.error(message, code);
  }

  void dispose() {
    _authSubscription?.cancel();
    _authStateController.close();
  }
}
