import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/legal/legal_document_page.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import '../../../../core/config/captcha_config.dart';
import '../widgets/captcha_gate.dart';

/// Tela de cadastro de novo usuário
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                const SizedBox(height: 10),
                // Header
                _buildHeader(),
                const SizedBox(height: 32),
                // Campos de formulário
                _buildNameField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 20),
                // Termos de uso
                _buildTermsCheckbox(),
                const SizedBox(height: 24),
                // Botão de cadastro
                _buildSignupButton(),
                const SizedBox(height: 32),
                // Divisor
                _buildDivider(),
                const SizedBox(height: 32),
                // Login social
                _buildSocialSignup(),
                const SizedBox(height: 32),
                // Link para login
                _buildLoginLink(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.gc.mint.withValues(alpha: 0.2),
          ),
          child: Icon(
            Icons.person_add_outlined,
            size: 40,
            color: context.gc.mint,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context).authCreateAccount,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.gc.lilac,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).authSignupSubtitle,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: context.gc.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      style: GoogleFonts.nunito(color: context.gc.textPrimary),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).authNameLabel,
        hintText: AppLocalizations.of(context).authNameHint,
        prefixIcon: Icon(Icons.person_outline, color: context.gc.lilac),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).authNameRequired;
        }
        if (value.length < 2) {
          return AppLocalizations.of(context).authNameMinLength;
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
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
      obscureText: _obscurePassword,
      style: GoogleFonts.nunito(color: context.gc.textPrimary),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).authPasswordLabel,
        hintText: AppLocalizations.of(context).authPasswordHintMin,
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
          return AppLocalizations.of(context).authPasswordCreateRequired;
        }
        if (value.length < 6) {
          return AppLocalizations.of(context).authPasswordMinLength;
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: GoogleFonts.nunito(color: context.gc.textPrimary),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).authConfirmPasswordLabel,
        hintText: AppLocalizations.of(context).authConfirmPasswordHint,
        prefixIcon: Icon(Icons.lock_outline, color: context.gc.lilac),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: context.gc.textSecondary,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).authConfirmPasswordRequired;
        }
        if (value != _passwordController.text) {
          return AppLocalizations.of(context).authPasswordsDontMatch;
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (value) {
              setState(() {
                _acceptedTerms = value ?? false;
              });
            },
            activeColor: context.gc.lilac,
            checkColor: const Color(0xFF2B2143),
            side: BorderSide(color: context.gc.surfaceBorder),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptedTerms = !_acceptedTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: context.gc.textSecondary,
                ),
                children: [
                  TextSpan(text: AppLocalizations.of(context).authTermsPrefix),
                  TextSpan(
                    text: AppLocalizations.of(context).authTermsOfUse,
                    style: TextStyle(
                      color: context.gc.lilac,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LegalDocumentPage.terms,
                            ),
                          ),
                  ),
                  TextSpan(text: AppLocalizations.of(context).authTermsAnd),
                  TextSpan(
                    text: AppLocalizations.of(context).authPrivacyPolicy,
                    style: TextStyle(
                      color: context.gc.lilac,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LegalDocumentPage.privacy,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: (_isLoading || !_acceptedTerms) ? null : _handleSignup,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.gc.lilac,
        foregroundColor: const Color(0xFF2B2143),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBackgroundColor: context.gc.lilac.withValues(alpha: 0.3),
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
              AppLocalizations.of(context).authCreateAccount,
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
            AppLocalizations.of(context).authOrSignupWith,
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

  Widget _buildSocialSignup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google
        _buildSocialButton(
          icon: 'G',
          label: 'Google',
          onPressed: _handleGoogleSignup,
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).authHaveAccount,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: context.gc.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppLocalizations.of(context).authLogin,
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

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).authMustAcceptTerms),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    // Verificação anti-robô antes de gastar a chamada de rede (não faz
    // nada enquanto a site key não estiver no build).
    final captchaToken = await CaptchaGate.resolve(context);
    if (!mounted) return;
    if (CaptchaConfig.isConfigured && captchaToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).authCaptchaFailed),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final displayName = _nameController.text.trim();
      UserModel? authenticatedUser;

      // Usar Supabase se configurado
      if (SupabaseConfig.isConfigured) {
        final authRepo = SupabaseAuthRepository();
        final result = await authRepo.signUpWithEmail(
          email: email,
          password: password,
          displayName: displayName,
          captchaToken: captchaToken,
        );

        if (!result.success) {
          throw Exception(result.errorMessage ?? AppLocalizations.of(context).authSignupError);
        }
        authenticatedUser = result.user;
      }

      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();

      if (authenticatedUser != null) {
        await authProvider.syncAuthenticatedUser(authenticatedUser);
      } else {
        await authProvider.updateProfile(
          displayName: displayName,
          email: email,
        );
      }

      // Marcar onboarding como visto (nova conta não precisa ver)
      await authProvider.markOnboardingSeen();

      if (mounted) {
        // Mostrar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).authSignupSuccess),
            backgroundColor: context.gc.success,
          ),
        );

        // Navegar para home
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = AppLocalizations.of(context).authSignupError;
        if (e.toString().contains('already')) {
          errorMessage = AppLocalizations.of(context).authEmailInUse;
        } else if (e.toString().contains('password')) {
          errorMessage = AppLocalizations.of(context).authPasswordMinLength;
        } else if (e.toString().contains('email')) {
          errorMessage = AppLocalizations.of(context).authEmailInvalidShort;
        } else {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

  Future<void> _handleGoogleSignup() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).authMustAcceptTerms),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).authGoogleSignupUnavailable),
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
            content: Text(result.errorMessage ?? AppLocalizations.of(context).authGoogleSignupError),
            backgroundColor: context.gc.alert,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).authGoogleSignupError}: $e'),
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
