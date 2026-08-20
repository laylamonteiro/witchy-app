import '../../../../core/content/content_locale.dart';
import '../../../../core/utils/mask.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'dart:async';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';
import '../../../../core/config/captcha_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/services/debug_log_service.dart';

AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

/// Implementação do AuthRepository usando Supabase
class SupabaseAuthRepository implements AuthRepository {
  late final SupabaseClient _supabase;
  final _authStateController = StreamController<UserModel?>.broadcast();
  StreamSubscription<AuthState>? _authSubscription;
  /// GoogleSignIn nativo só existe no mobile. Na web, o login com Google é
  /// feito via OAuth do Supabase (signInWithOAuth) — e o plugin google_sign_in
  /// web sequer aceita `serverClientId`, então instanciá-lo aqui estouraria no
  /// boot da tela de login. Fica null na web.
  final GoogleSignIn? _googleSignIn = kIsWeb
      ? null
      : GoogleSignIn(
          // Web Client ID (client_type: 3) do google-services.json, exigido
          // pelo Supabase para validar o idToken do Google no mobile.
          serverClientId:
              '625869809120-vekqjnltlccc7llalu6adgl1js8tngob.apps.googleusercontent.com',
        );

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
  Future<AuthResult> signInWithEmail(
    String email,
    String password, {
    String? captchaToken,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
        captchaToken: captchaToken,
      );
      if (response.user != null) {
        final user = await _userFromSupabaseUser(response.user!);
        return AuthResult.success(user);
      }
      return AuthResult.error('Erro ao fazer login');
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.error(_l10n.authErrConnection('$e'), AuthErrorCode.networkError);
    }
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? captchaToken,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        captchaToken: captchaToken,
        data: {'display_name': displayName},
        emailRedirectTo: kIsWeb
            ? '${SupabaseConfig.url}/auth/v1/verify'
            : '${SupabaseConfig.deepLinkScheme}://email-confirm',
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
      return AuthResult.error(_l10n.authErrConnection('$e'), AuthErrorCode.networkError);
    }
  }

  /// Onde a conta NASCEU: `android`, `ios` ou `web`.
  ///
  /// É histórico, não estado: uma pessoa que criou a conta no site e hoje
  /// usa o app continua tendo `web` aqui — e é exatamente isso que a torna
  /// útil ("quantas contas novas vieram do site?").
  ///
  /// NÃO use este campo para decidir onde cancelar uma assinatura. Quem
  /// sabe disso é o RevenueCat (`CustomerInfo.managementURL`), porque a
  /// loja da assinatura pode ser outra e pode mudar. Ver
  /// docs/ORIGEM_E_PAGAMENTO.md.
  static String get _signupPlatform {
    // defaultTargetPlatform e não dart:io: `Platform` não existe na web, e
    // importá-lo condicionalmente aqui seria complexidade sem ganho.
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.android => 'android',
      _ => 'unknown',
    };
  }

  Future<void> _createProfile(User supabaseUser, String? displayName) async {
    try {
      await _supabase.from(SupabaseTables.profiles).upsert({
        'id': supabaseUser.id,
        'email': supabaseUser.email,
        'display_name': displayName,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Fora do upsert de propósito: `upsert` reescreve a linha inteira, e
      // este método também roda em login social de conta ANTIGA. Incluir a
      // origem ali apagaria o registro original toda vez que a pessoa
      // entrasse por outra plataforma. Este update só preenche o que ainda
      // está vazio — nunca sobrescreve.
      await _supabase
          .from(SupabaseTables.profiles)
          .update({'signup_platform': _signupPlatform})
          .eq('id', supabaseUser.id)
          .isFilter('signup_platform', null);
    } catch (e) {
      // Log error but don't fail registration
      print('Erro ao criar perfil: $e');
    }
  }


  @override
  Future<AuthResult> signInWithGoogle({String? captchaToken}) async {
    try {
      await debugLog('AUTH', 'Iniciando Google Sign-In...');

      // Para web, usar OAuth redirect
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          // Para onde a usuária volta DEPOIS do login — a origem do próprio
          // app (grimoriodebolso.app em produção, staging ou prévia, ou
          // localhost em dev), não o callback interno do Supabase (que era o
          // valor anterior e deixava a usuária parada numa URL do Supabase).
          //
          // COM BARRA NO FIM. Os padrões de Redirect URLs do Supabase são
          // globs literais: `https://*.grimorio-de-bolso.pages.dev/**` exige
          // a barra para casar, e `Uri.base.origin` não a tem. Sem casar, o
          // Supabase ignora o pedido em silêncio e manda para o *Site URL* —
          // ou seja, quem logava no staging reaparecia em PRODUÇÃO, com um
          // código PKCE inútil (o segredo ficou no localStorage do staging).
          // Resultado: um login que falha, um segundo que funciona, e a
          // pessoa testando o app antigo sem perceber que trocou de site.
          redirectTo: '${Uri.base.origin}/',
        );
        // O navegador já está saindo para o Google. Devolver "sucesso" com um
        // usuário anônimo (como antes) fazia a tela sincronizar essa conta
        // falsa e navegar, piscando a tela de boas-vindas antes do redirect.
        return AuthResult.redirecting();
      }


      // Para mobile, usar Google Sign-In nativo (versão 7.x usa singleton).
      // Não-nulo aqui: o caminho web já retornou acima no if (kIsWeb).
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        await debugLog('AUTH', 'Google Sign-In cancelado pelo usuário');
        return AuthResult.error('Login cancelado');
      }

      await debugLog(
          'AUTH', 'Google Sign-In: usuário obtido - ${maskEmail(googleUser.email)}');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        await debugLog('AUTH', 'Google Sign-In: idToken é null');
        return AuthResult.error(_l10n.authErrGoogleCredentials);
      }

      await debugLog('AUTH', 'Google Sign-In: obtendo tokens...');

      // Autenticar com Supabase usando o ID token do Google
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
        captchaToken: captchaToken,
      );

      if (response.user != null) {
        await debugLog('AUTH', 'Google Sign-In: sucesso! User ID: ${response.user!.id}');
        // Criar/atualizar perfil
        await _createProfile(response.user!, googleUser.displayName);
        final user = await _userFromSupabaseUser(response.user!);
        return AuthResult.success(user);
      }

      await debugLog('AUTH', 'Google Sign-In: falhou - user é null');
      return AuthResult.error('Erro ao autenticar com Google');
    } on AuthException catch (e) {
      await debugLog('AUTH', 'Google Sign-In AuthException: ${e.message}');
      return _handleAuthException(e);
    } catch (e) {
      await debugLog('AUTH', 'Google Sign-In erro: $e');
      return AuthResult.error('Erro no login com Google: $e');
    }
  }

  @override
  Future<AuthResult> signInWithFacebook() async {
    // Facebook login foi removido - manter método para compatibilidade
    return AuthResult.error(_l10n.authErrFacebookUnavailable);
  }

  @override
  Future<AuthResult> signInWithApple() async {
    // Apple Sign-In não está habilitado neste app
    return AuthResult.error(_l10n.authErrAppleUnavailable);
  }

  @override
  Future<void> signOut() async {
    Object? supabaseError;
    try {
      await debugLog('AUTH', 'Encerrando sessão do Supabase');
      await _supabase.auth.signOut();
    } catch (e) {
      supabaseError = e;
      await debugLog('AUTH', 'Erro ao encerrar sessão do Supabase: $e');
    }

    try {
      final googleSignIn = _googleSignIn;
      if (googleSignIn != null && await googleSignIn.isSignedIn()) {
        await debugLog('AUTH', 'Encerrando sessão do Google');
        await googleSignIn.signOut();
      }
    } catch (e) {
      await debugLog('AUTH', 'Erro ao encerrar sessão do Google: $e');
    }

    _authStateController.add(null);
    if (supabaseError != null) {
      throw supabaseError;
    }
  }

  @override
  Future<AuthResult> sendPasswordResetEmail(
    String email, {
    String? captchaToken,
  }) async {
    try {
      // Adicionar redirect URL para funcionar corretamente no mobile/web
      await _supabase.auth.resetPasswordForEmail(
        email,
        captchaToken: captchaToken,
        redirectTo: kIsWeb
            ? '${SupabaseConfig.url}/auth/v1/verify'
            : '${SupabaseConfig.deepLinkScheme}://reset-password',
      );
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
      return AuthResult.error(_l10n.authErrNoUser);
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
        return AuthResult.error(_l10n.authErrNoUser);
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
        return AuthResult.error(_l10n.authErrNoUser);
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
        // Ignorar erros - tabela pode não existir
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
      // Perfil pode não existir ainda
    }

    // Sem linha em `profiles`, cria agora. Acontece no login social DA WEB:
    // ele termina em redirect, então o app volta por outro caminho e o
    // _createProfile do fluxo nativo nunca roda. Sem essa linha, papel (role),
    // plano e contadores da conta não teriam onde ficar.
    if (profileData == null) {
      final metadata = supabaseUser.userMetadata ?? {};
      await _createProfile(
        supabaseUser,
        metadata['display_name'] ?? metadata['full_name'] ?? metadata['name'],
      );
      try {
        profileData = await _supabase
            .from(SupabaseTables.profiles)
            .select()
            .eq('id', supabaseUser.id)
            .maybeSingle();
      } catch (e) {
        // Segue com os dados do próprio usuário do Supabase.
      }
    }

    // Detectar método de autenticação
    AuthMethod authMethod = AuthMethod.emailPassword; // Padrão
    final appMetadata = supabaseUser.appMetadata;
    final provider = appMetadata['provider'] as String?;

    if (provider == 'google') {
      authMethod = AuthMethod.google;
    } else if (provider == 'email') {
      authMethod = AuthMethod.emailPassword;
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
      authMethod: authMethod,
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
    final normalizedMessage = message.toLowerCase().replaceAll('_', ' ');

    // Captcha ligado no projeto e recusado. Duas causas bem diferentes:
    // sem a site key compilada, o app sequer sabe gerar token — é uma
    // versão antiga, e o único caminho é atualizar. Com a chave compilada,
    // foi o desafio em si que falhou e vale tentar de novo.
    if (normalizedMessage.contains('captcha')) {
      code = AuthErrorCode.captchaRequired;
      message = CaptchaConfig.isConfigured
          ? _l10n.authCaptchaFailed
          : _l10n.authErrCaptchaOutdated;
    } else if (normalizedMessage.contains('email not confirmed') ||
        normalizedMessage.contains('email is not confirmed')) {
      message =
          'Confirme seu email antes de entrar. Verifique sua caixa de entrada.';
    } else if (message.contains('Invalid login credentials')) {
      code = AuthErrorCode.invalidPassword;
      message = 'Email ou senha incorretos';
    } else if (message.contains('User not found')) {
      code = AuthErrorCode.userNotFound;
      message = _l10n.authErrUserNotFound;
    } else if (message.contains('already registered') ||
        message.contains('already exists')) {
      code = AuthErrorCode.emailAlreadyInUse;
      message = _l10n.authErrEmailInUse;
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
      message = _l10n.authErrNetworkCheck;
    }

    return AuthResult.error(message, code);
  }

  void dispose() {
    _authSubscription?.cancel();
    _authStateController.close();
  }
}
