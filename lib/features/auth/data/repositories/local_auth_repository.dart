import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// Implementação local do AuthRepository usando SharedPreferences
/// Usado para modo offline e testes
class LocalAuthRepository implements AuthRepository {
  static const String _userKey = 'current_user';
  static const String _isAuthenticatedKey = 'is_authenticated';

  final _authStateController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        return _currentUser;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    // Simulação de login local
    // Em produção, isso seria validado contra o Supabase
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(userJson));
        if (user.email == email) {
          // Simula login bem-sucedido se email bate
          _currentUser = user.copyWith(lastLoginAt: DateTime.now());
          await _saveUser(_currentUser!);
          _authStateController.add(_currentUser);
          return AuthResult.success(_currentUser!);
        }
      } catch (e) {
        // Ignora erros de parse
      }
    }

    // Cria novo usuário se não existir (modo local)
    final newUser = UserModel(
      id: const Uuid().v4(),
      email: email,
      role: UserRole.free,
      plan: SubscriptionPlan.free,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    _currentUser = newUser;
    await _saveUser(newUser);
    await prefs.setBool(_isAuthenticatedKey, true);
    _authStateController.add(_currentUser);

    return AuthResult.success(newUser);
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newUser = UserModel(
      id: const Uuid().v4(),
      email: email,
      displayName: displayName,
      role: UserRole.free,
      plan: SubscriptionPlan.free,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    _currentUser = newUser;
    await _saveUser(newUser);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAuthenticatedKey, true);
    _authStateController.add(_currentUser);

    return AuthResult.success(newUser);
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    // Simulação - será implementado com google_sign_in
    await Future.delayed(const Duration(milliseconds: 500));
    return AuthResult.error(
      'Login com Google não disponível no modo local',
      AuthErrorCode.unknown,
    );
  }

  @override
  Future<AuthResult> signInWithApple() async {
    // Simulação - será implementado com sign_in_with_apple
    await Future.delayed(const Duration(milliseconds: 500));
    return AuthResult.error(
      'Login com Apple não disponível no modo local',
      AuthErrorCode.unknown,
    );
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isAuthenticatedKey, false);
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    // Simulação local - sempre "sucesso"
    await Future.delayed(const Duration(seconds: 1));
    return AuthResult.success(_currentUser ?? UserModel.defaultUser());
  }

  @override
  Future<AuthResult> verifyEmail() async {
    // Simulação local - sempre verificado
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentUser != null) {
      return AuthResult.success(_currentUser!);
    }
    return AuthResult.error('Nenhum usuário logado');
  }

  @override
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
    DateTime? birthDate,
    String? birthTime,
    String? birthPlace,
  }) async {
    if (_currentUser == null) {
      return AuthResult.error('Nenhum usuário logado');
    }

    _currentUser = _currentUser!.copyWith(
      displayName: displayName ?? _currentUser!.displayName,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
      birthDate: birthDate ?? _currentUser!.birthDate,
      birthTime: birthTime ?? _currentUser!.birthTime,
      birthPlace: birthPlace ?? _currentUser!.birthPlace,
    );

    await _saveUser(_currentUser!);
    _authStateController.add(_currentUser);

    return AuthResult.success(_currentUser!);
  }

  @override
  Future<AuthResult> updatePassword(
      String currentPassword, String newPassword) async {
    // Simulação local - sempre sucesso (senhas não são armazenadas localmente)
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentUser != null) {
      return AuthResult.success(_currentUser!);
    }
    return AuthResult.error('Nenhum usuário logado');
  }

  @override
  Future<AuthResult> deleteAccount() async {
    await signOut();
    return AuthResult.success(UserModel.defaultUser());
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Atualiza o role do usuário (para testes/admin)
  Future<AuthResult> updateUserRole(UserRole role, SubscriptionPlan plan) async {
    if (_currentUser == null) {
      return AuthResult.error('Nenhum usuário logado');
    }

    _currentUser = _currentUser!.copyWith(
      role: role,
      plan: plan,
    );

    await _saveUser(_currentUser!);
    _authStateController.add(_currentUser);

    return AuthResult.success(_currentUser!);
  }

  /// Incrementa contadores de uso
  Future<void> incrementCounter(String counterName) async {
    if (_currentUser == null) return;

    switch (counterName) {
      case 'spells':
        _currentUser = _currentUser!.copyWith(
          spellsCount: _currentUser!.spellsCount + 1,
        );
        break;
      case 'diary':
        _currentUser = _currentUser!.copyWith(
          diaryEntriesThisMonth: _currentUser!.diaryEntriesThisMonth + 1,
        );
        break;
      case 'ai':
        _currentUser = _currentUser!.copyWith(
          aiConsultationsToday: _currentUser!.aiConsultationsToday + 1,
        );
        break;
      case 'pendulum':
        _currentUser = _currentUser!.copyWith(
          pendulumUsesToday: _currentUser!.pendulumUsesToday + 1,
        );
        break;
      case 'affirmations':
        _currentUser = _currentUser!.copyWith(
          affirmationsToday: _currentUser!.affirmationsToday + 1,
        );
        break;
      case 'runes':
        _currentUser = _currentUser!.copyWith(
          runeReadingsToday: _currentUser!.runeReadingsToday + 1,
        );
        break;
      case 'oracle':
        _currentUser = _currentUser!.copyWith(
          oracleReadingsToday: _currentUser!.oracleReadingsToday + 1,
        );
        break;
    }

    await _saveUser(_currentUser!);
    _authStateController.add(_currentUser);
  }

  void dispose() {
    _authStateController.close();
  }
}
