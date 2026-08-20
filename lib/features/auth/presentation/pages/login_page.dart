import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../core/widgets/starfield_background.dart';
import '../widgets/breathing_badge.dart';
import '../widgets/auth_motion.dart';
import '../widgets/auth_feedback.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/config/admin_config.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';
import '../../../../core/config/captcha_config.dart';
import '../widgets/captcha_gate.dart';

/// Tela de login com email e senha
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _shakeKey = GlobalKey<ShakerState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Voltar seguro: vindo do onboarding esta tela pode ser a ÚNICA rota da
  /// pilha — um pop cego a esvaziaria e deixaria a tela preta. Sem nada
  /// abaixo, volta-se para a porta de entrada (Welcome).
  void _handleBack() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacementNamed('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope intercepta o gesto/botão de voltar do sistema, que sofre do
    // mesmo esvaziamento de pilha que o botão da AppBar. Com rota abaixo,
    // canPop=true preserva o pop nativo (e o swipe-back do iOS); só a rota
    // solitária — deep link/web — é interceptada e redirecionada.
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.gc.lilac),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: _handleBack,
          ),
        ),
        body: StarfieldBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              // Teto de largura para a web desktop: sem ele o formulário
              // estica pela janela toda. Centralizado em ~480, mantém a
              // leitura de app de celular (o starfield fica fora e segue
              // preenchendo o fundo).
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Shaker(
                    key: _shakeKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        // Header
                        CascadeIn(index: 0, child: _buildHeader()),
                        const SizedBox(height: 40),
                        // Campos de formulário
                        CascadeIn(index: 1, child: _buildEmailField()),
                        const SizedBox(height: 16),
                        CascadeIn(index: 2, child: _buildPasswordField()),
                        const SizedBox(height: 12),
                        // Link de esqueci a senha
                        CascadeIn(
                          index: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordPage()),
                              ),
                              child: Text(
                                AppLocalizations.of(context).authForgotPassword,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: context.gc.lilac,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Botão de login
                        CascadeIn(index: 4, child: _buildLoginButton()),
                        const SizedBox(height: 32),
                        // Divisor
                        CascadeIn(index: 5, child: _buildDivider()),
                        const SizedBox(height: 32),
                        // Login social
                        _buildSocialLogin(),
                        const SizedBox(height: 32),
                        // Link para cadastro
                        _buildSignupLink(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Status técnico acessível SEM login (toque longo no cadeado). Mostra
  /// apenas indicadores genéricos (versão, ambiente e se o serviço de
  /// autenticação está disponível) — nunca dados sensíveis como a URL do
  /// banco ou a chave, para não vazar nada caso um usuário comum descubra.
  Future<void> _showConfigDiagnostic() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;

    Widget row(String label, String value, bool ok) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(ok ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: ok ? context.gc.success : context.gc.alert),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: Text(label,
                    style: TextStyle(
                        color: context.gc.textSecondary, fontSize: 12)),
              ),
              Expanded(
                child: Text(value,
                    style: TextStyle(
                        color: context.gc.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.gc.surface,
        title: Text(AppLocalizations.of(context).loginTechStatus,
            style: TextStyle(color: dialogContext.gc.lilac, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row(AppLocalizations.of(context).loginTechVersion,
                  'v${info.version}+${info.buildNumber}', true),
              row(
                  AppLocalizations.of(context).loginTechEnvironment,
                  kReleaseMode
                      ? AppLocalizations.of(context).loginTechProd
                      : AppLocalizations.of(context).loginTechDev,
                  true),
              const Divider(),
              // Indicador genérico: só diz se o serviço de login responde,
              // sem expor endpoint nem credenciais.
              row(
                AppLocalizations.of(context).loginTechService,
                SupabaseConfig.isConfigured
                    ? AppLocalizations.of(context).loginTechAvailable
                    : AppLocalizations.of(context).loginTechUnavailable,
                SupabaseConfig.isConfigured,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Fechar',
                style: TextStyle(color: dialogContext.gc.lilac)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Toque longo no cadeado abre o diagnóstico de configuração (sem
        // precisar logar): revela se as credenciais foram embutidas no build.
        GestureDetector(
          onLongPress: _showConfigDiagnostic,
          child: BreathingBadge(
            glowColor: context.gc.lilac,
            haloSize: 96,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.gc.lilac.withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.lock_outline,
                size: 40,
                color: context.gc.lilac,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).authWelcomeBack,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.gc.lilac,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).authLoginSubtitle,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: context.gc.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      enabled: !_isLoading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
      style: GoogleFonts.nunito(color: context.gc.textPrimary),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).authEmailLabel,
        hintText: AppLocalizations.of(context).authEmailHint,
        prefixIcon: Icon(Icons.email_outlined, color: context.gc.lilac),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).authEmailRequired;
        }
        // Permitir login admin (credenciais injetadas via --dart-define)
        if (AdminConfig.isEnabled && value == AdminConfig.email) return null;
        if (!value.contains('@') || !value.contains('.')) {
          return AppLocalizations.of(context).authEmailInvalid;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      enabled: !_isLoading,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: (_) => _handleLogin(),
      style: GoogleFonts.nunito(color: context.gc.textPrimary),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).authPasswordLabel,
        hintText: '••••••',
        prefixIcon: Icon(Icons.lock_outline, color: context.gc.lilac),
        suffixIcon: IconButton(
          tooltip: _obscurePassword
              ? AppLocalizations.of(context).authShowPassword
              : AppLocalizations.of(context).authHidePassword,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              key: ValueKey(_obscurePassword),
              color: context.gc.textSecondary,
            ),
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).authPasswordRequired;
        }
        // Senha do admin vinda do ambiente (--dart-define)
        final email = _emailController.text.trim();
        if (AdminConfig.isEnabled &&
            email == AdminConfig.email &&
            value == AdminConfig.password) {
          return null;
        }
        if (value.length < 6) {
          return AppLocalizations.of(context).authPasswordMinLength;
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return PressableScale(
      child: BreathingGlow(
        color: context.gc.lilac,
        child: SheenSweep(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
              foregroundColor: const Color(0xFF2B2143),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: context.gc.lilac.withValues(alpha: 0.5),
            ),
            // Rótulo e spinner se trocam num fade — nada de "pulo" seco.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isLoading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF2B2143)),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context).authLogin,
                      key: const ValueKey('label'),
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: context.gc.surfaceBorder,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context).authOrContinueWith,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: context.gc.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: context.gc.surfaceBorder,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google
        _buildSocialButton(
          icon: 'G',
          label: 'Google',
          onPressed: _handleGoogleLogin,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    String? icon,
    Widget? iconWidget,
    required String label,
    required VoidCallback onPressed,
  }) {
    return PressableScale(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.gc.textPrimary,
          side: BorderSide(color: context.gc.surfaceBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null)
              iconWidget
            else
              Text(
                icon ?? '',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.gc.textPrimary,
                ),
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).authNoAccount,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: context.gc.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SignupPage()),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppLocalizations.of(context).authCreateAccount,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.gc.lilac,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) {
      _shakeKey.currentState?.shake();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final authProvider = context.read<AuthProvider>();

      // Admin: credenciais injetadas no build via --dart-define
      // (ADMIN_EMAIL/ADMIN_PASSWORD, secrets do GitHub Actions)
      if (AdminConfig.isEnabled &&
          email == AdminConfig.email &&
          password == AdminConfig.password) {
        await authProvider.activateAdminMode();
        await authProvider.updateProfile(
          email: AdminConfig.email,
          displayName: 'Administrador',
        );
        await authProvider.markOnboardingSeen();

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
        return;
      }

      // Validação obrigatória com Supabase
      if (!SupabaseConfig.isConfigured) {
        throw Exception(AppLocalizations.of(context).authSystemNotConfigured);
      }

      final captchaToken = await CaptchaGate.resolve(context);
      if (!mounted) return;
      if (CaptchaConfig.isConfigured && captchaToken == null) {
        throw Exception(AppLocalizations.of(context).authCaptchaFailed);
      }

      final authRepo = SupabaseAuthRepository();
      final result = await authRepo.signInWithEmail(
        email,
        password,
        captchaToken: captchaToken,
      );

      if (!result.success) {
        throw Exception(result.errorMessage ?? AppLocalizations.of(context).authLoginError);
      }

      await authProvider.syncAuthenticatedUser(result.user!);
      await authProvider.markOnboardingSeen();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        _shakeKey.currentState?.shake();
        showAuthSnack(
          context,
          '$e'.replaceAll('Exception: ', ''),
          type: AuthSnackType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (!SupabaseConfig.isConfigured) {
      showAuthSnack(
        context,
        AppLocalizations.of(context).authSocialUnavailable,
      );
      return;
    }

    final captchaToken = await CaptchaGate.resolve(context);
    if (!mounted) return;
    if (CaptchaConfig.isConfigured && captchaToken == null) {
      showAuthSnack(
        context,
        AppLocalizations.of(context).authCaptchaFailed,
        type: AuthSnackType.error,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = SupabaseAuthRepository();
      final result = await authRepo.signInWithGoogle(
        captchaToken: captchaToken,
      );

      if (!mounted) return;

      // Login social na web sai do app: o navegador vai para o provedor e
      // volta recarregando a página. Não há o que navegar nem avisar aqui —
      // seguir adiante piscava uma tela intermediária antes da saída.
      if (result.redirecting) return;

      if (result.success && result.user != null) {
        final authProvider = context.read<AuthProvider>();
        await authProvider.syncAuthenticatedUser(result.user!);
        await authProvider.markOnboardingSeen();

        if (!mounted) return;
        // Navegar para home
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        showAuthSnack(
          context,
          result.errorMessage ?? AppLocalizations.of(context).authGoogleError,
          type: AuthSnackType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        showAuthSnack(
          context,
          '${AppLocalizations.of(context).authGoogleError}: $e',
          type: AuthSnackType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
