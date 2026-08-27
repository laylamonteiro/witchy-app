import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/i18n/gender.dart';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/legal/legal_document_page.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../core/widgets/starfield_background.dart';
import '../widgets/breathing_badge.dart';
import '../widgets/auth_motion.dart';
import '../widgets/auth_feedback.dart';
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
  final _shakeKey = GlobalKey<ShakerState>();
  final _termsShakeKey = GlobalKey<ShakerState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
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
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  /// Voltar seguro: aberta por rota direta (deep link ou URL na web), esta
  /// tela pode ser a ÚNICA rota da pilha — um pop cego a esvaziaria e
  /// deixaria a tela preta. Sem nada abaixo, volta-se para a porta de
  /// entrada (Welcome).
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
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Shaker(
                    key: _shakeKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        // Header
                        CascadeIn(index: 0, child: _buildHeader()),
                        const SizedBox(height: 24),
                        // Campos de formulário
                        CascadeIn(index: 1, child: _buildNameField()),
                        const SizedBox(height: 16),
                        CascadeIn(index: 2, child: _buildEmailField()),
                        const SizedBox(height: 16),
                        CascadeIn(index: 3, child: _buildPasswordField()),
                        const SizedBox(height: 16),
                        CascadeIn(index: 4, child: _buildConfirmPasswordField()),
                        const SizedBox(height: 20),
                        // Termos de uso
                        CascadeIn(index: 5, child: _buildTermsCheckbox()),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        BreathingBadge(
          glowColor: context.gc.mint,
          haloSize: 96,
          child: Container(
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
        ),
        const SizedBox(height: 8),
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
      enabled: !_isLoading,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
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
      focusNode: _emailFocus,
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
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.newPassword],
      onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
      style: GoogleFonts.nunito(color: context.gc.textPrimary),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).authPasswordLabel,
        hintText: AppLocalizations.of(context).authPasswordHintMin,
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
      focusNode: _confirmPasswordFocus,
      enabled: !_isLoading,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.newPassword],
      onFieldSubmitted: (_) => _handleSignup(),
      style: GoogleFonts.nunito(color: context.gc.textPrimary),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).authConfirmPasswordLabel,
        hintText: AppLocalizations.of(context).authConfirmPasswordHint,
        prefixIcon: Icon(Icons.lock_outline, color: context.gc.lilac),
        suffixIcon: IconButton(
          tooltip: _obscureConfirmPassword
              ? AppLocalizations.of(context).authShowPassword
              : AppLocalizations.of(context).authHidePassword,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              key: ValueKey(_obscureConfirmPassword),
              color: context.gc.textSecondary,
            ),
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
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
    // A linha inteira alterna o aceite (alvo de toque generoso); os links
    // dentro do texto continuam abrindo os documentos.
    return Shaker(
      key: _termsShakeKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _acceptedTerms = value ?? false;
              });
            },
            activeColor: context.gc.lilac,
            checkColor: const Color(0xFF2B2143),
            side: BorderSide(color: context.gc.surfaceBorder),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
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
      ),
    );
  }

  Widget _buildSignupButton() {
    final enabled = !_isLoading && _acceptedTerms;
    // GestureDetector externo: um toque no botão DESABILITADO explica o
    // porquê (sacode os termos) em vez de morrer no silêncio.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? null
          : () {
              if (_isLoading) return;
              _termsShakeKey.currentState?.shake();
              showAuthSnack(
                context,
                AppLocalizations.of(context).authMustAcceptTerms,
              );
            },
      child: PressableScale(
        child: SheenSweep(
          child: ElevatedButton(
            onPressed: enabled ? _handleSignup : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
              foregroundColor: const Color(0xFF2B2143),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: context.gc.lilac.withValues(alpha: 0.3),
            ),
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
                      AppLocalizations.of(context).authCreateAccount,
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
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) {
      _shakeKey.currentState?.shake();
      return;
    }

    if (!_acceptedTerms) {
      _termsShakeKey.currentState?.shake();
      showAuthSnack(
        context,
        AppLocalizations.of(context).authMustAcceptTerms,
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

        // Conta criada mas sem sessão: o Supabase exige confirmação de
        // e-mail. Entrar no app "logada" aqui seria mentira — sem JWT,
        // todo recurso de nuvem falha como `anon` (era o bug do resgate
        // de código no webapp). Avisa, manda para o login e pronto: o
        // login já barra conta não confirmada com a mensagem certa e
        // oferece o reenvio do link.
        if (result.emailConfirmationPending) {
          if (mounted) {
            showAuthSnack(
              context,
              AppLocalizations.of(context).authConfirmEmailSent(email),
              type: AuthSnackType.success,
            );
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          }
          return;
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

      if (mounted) {
        // Mostrar sucesso
        showAuthSnack(
          context,
          GenderText.select(
            preference: TratamentoAtual.instance.preferencia,
            feminine: AppLocalizations.of(context).authSignupSuccessFeminine,
            masculine: AppLocalizations.of(context).authSignupSuccessMasculine,
            neutral: AppLocalizations.of(context).authSignupSuccessNeutral,
          ),
          type: AuthSnackType.success,
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

        _shakeKey.currentState?.shake();
        showAuthSnack(context, errorMessage, type: AuthSnackType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignup() async {
    if (!_acceptedTerms) {
      _termsShakeKey.currentState?.shake();
      showAuthSnack(
        context,
        AppLocalizations.of(context).authMustAcceptTerms,
      );
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      showAuthSnack(
        context,
        AppLocalizations.of(context).authGoogleSignupUnavailable,
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

        if (!mounted) return;
        // Navegar para home
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        showAuthSnack(
          context,
          result.errorMessage ??
              AppLocalizations.of(context).authGoogleSignupError,
          type: AuthSnackType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        showAuthSnack(
          context,
          '${AppLocalizations.of(context).authGoogleSignupError}: $e',
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
