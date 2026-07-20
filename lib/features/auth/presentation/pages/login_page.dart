import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/config/admin_config.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';

/// Tela de login com email e senha
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.gc.lilac),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Header
                _buildHeader(),
                const SizedBox(height: 48),
                // Campos de formulário
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 12),
                // Link de esqueci a senha
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.authForgotPassword,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: context.gc.lilac,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botão de login
                _buildLoginButton(),
                const SizedBox(height: 32),
                // Divisor
                _buildDivider(),
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
    );
  }

  /// Diagnóstico de configuração acessível SEM login (toque longo no
  /// cadeado). Mostra se as credenciais foram embutidas no build atual —
  /// a URL do Supabase e o comprimento da anon key (ambos são valores de
  /// cliente, públicos por design; a anon key nunca é exibida na íntegra).
  Future<void> _showConfigDiagnostic() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;

    final url = SupabaseConfig.url;
    final anonLen = SupabaseConfig.anonKey.length;

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
                child: SelectableText(value,
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
        title: Text('Diagnóstico de configuração',
            style: TextStyle(color: dialogContext.gc.lilac, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row('App', 'v${info.version}+${info.buildNumber}', true),
              row('Modo', kReleaseMode ? 'release' : 'debug', true),
              const Divider(),
              row('Supabase pronto', SupabaseConfig.isConfigured ? 'SIM' : 'NAO',
                  SupabaseConfig.isConfigured),
              row('SUPABASE_URL', url.isEmpty ? '(vazio)' : url,
                  url.isNotEmpty),
              row('ANON_KEY', anonLen == 0 ? '(vazio)' : '$anonLen chars',
                  anonLen > 0),
              const Divider(),
              row('Admin habilitado', AdminConfig.isEnabled ? 'SIM' : 'NAO',
                  AdminConfig.isEnabled),
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
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.authWelcomeBack,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.gc.lilac,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.authLoginSubtitle,
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
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.nunito(color: context.gc.textPrimary),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.authEmailLabel,
        hintText: AppLocalizations.of(context)!.authEmailHint,
        prefixIcon: Icon(Icons.email_outlined, color: context.gc.lilac),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.authEmailRequired;
        }
        // Permitir login admin (credenciais injetadas via --dart-define)
        if (AdminConfig.isEnabled && value == AdminConfig.email) return null;
        if (!value.contains('@') || !value.contains('.')) {
          return AppLocalizations.of(context)!.authEmailInvalid;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.nunito(color: context.gc.textPrimary),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.authPasswordLabel,
        hintText: '••••••',
        prefixIcon: Icon(Icons.lock_outline, color: context.gc.lilac),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: context.gc.textSecondary,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.authPasswordRequired;
        }
        // Senha do admin vinda do ambiente (--dart-define)
        final email = _emailController.text.trim();
        if (AdminConfig.isEnabled &&
            email == AdminConfig.email &&
            value == AdminConfig.password) {
          return null;
        }
        if (value.length < 6) {
          return AppLocalizations.of(context)!.authPasswordMinLength;
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
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
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2B2143)),
              ),
            )
          : Text(
              AppLocalizations.of(context)!.authLogin,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
            AppLocalizations.of(context)!.authOrContinueWith,
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
    return OutlinedButton(
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
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.authNoAccount,
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
            AppLocalizations.of(context)!.authCreateAccount,
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
    if (!_formKey.currentState!.validate()) return;

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
        throw Exception(AppLocalizations.of(context)!.authSystemNotConfigured);
      }

      final authRepo = SupabaseAuthRepository();
      final result = await authRepo.signInWithEmail(email, password);

      if (!result.success) {
        throw Exception(result.errorMessage ?? AppLocalizations.of(context)!.authLoginError);
      }

      await authProvider.syncAuthenticatedUser(result.user!);
      await authProvider.markOnboardingSeen();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'.replaceAll('Exception: ', '')),
            backgroundColor: context.gc.alert,
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.authSocialUnavailable),
          backgroundColor: context.gc.info,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = SupabaseAuthRepository();
      final result = await authRepo.signInWithGoogle();

      if (!mounted) return;

      if (result.success && result.user != null) {
        final authProvider = context.read<AuthProvider>();
        await authProvider.syncAuthenticatedUser(result.user!);
        await authProvider.markOnboardingSeen();

        if (!mounted) return;
        // Navegar para home
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? AppLocalizations.of(context)!.authGoogleError),
            backgroundColor: context.gc.alert,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.authGoogleError}: $e'),
            backgroundColor: context.gc.alert,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
