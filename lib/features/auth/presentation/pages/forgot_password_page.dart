import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../core/widgets/starfield_background.dart';
import '../widgets/breathing_badge.dart';
import '../widgets/auth_motion.dart';
import '../widgets/auth_feedback.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import 'login_page.dart';
import '../../../../core/config/captcha_config.dart';
import '../widgets/captcha_gate.dart';

/// Tela de recuperação de senha
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _shakeKey = GlobalKey<ShakerState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  /// Cooldown do reenvio: evita spam no serviço de email e comunica ao
  /// usuário que o envio JÁ aconteceu — reenviar de novo em segundos não
  /// faria o email chegar mais rápido.
  static const _resendCooldown = 30;
  int _resendSecondsLeft = 0;
  Timer? _resendTimer;

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = _resendCooldown);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _resendSecondsLeft -= 1);
      if (_resendSecondsLeft <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
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
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StarfieldBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            // A troca formulário → sucesso acontece num respiro, não num corte.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _emailSent
                  ? KeyedSubtree(
                      key: const ValueKey('success'),
                      child: _buildSuccessContent(),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('form'),
                      child: _buildFormContent(),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Shaker(
        key: _shakeKey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          // Header
          CascadeIn(index: 0, child: _buildHeader()),
          const SizedBox(height: 40),
          // Campo de email
          CascadeIn(index: 1, child: _buildEmailField()),
          const SizedBox(height: 32),
          // Botão de enviar
          CascadeIn(index: 2, child: _buildSendButton()),
          const SizedBox(height: 32),
          // Link para voltar ao login
          CascadeIn(index: 3, child: _buildBackToLogin()),
        ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),
        // Ícone de sucesso respirando — a carta partiu
        Center(
          child: BreathingBadge(
            glowColor: context.gc.success,
            haloSize: 132,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.gc.success.withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: context.gc.success,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Título
        Text(
          AppLocalizations.of(context).forgotEmailSent,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.gc.lilac,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Descrição
        Text(
          AppLocalizations.of(context).forgotEmailSentTo(_emailController.text),
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: context.gc.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context).forgotCheckInbox,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: context.gc.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        // Botão de voltar ao login
        PressableScale(
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
              foregroundColor: const Color(0xFF2B2143),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).forgotBackToLogin,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Link para reenviar — com contagem regressiva enquanto o reenvio
        // descansa, para o botão explicar a própria indisponibilidade.
        TextButton(
          onPressed:
              (_isLoading || _resendSecondsLeft > 0) ? null : _handleResend,
          child: Text(
            _resendSecondsLeft > 0
                ? AppLocalizations.of(context)
                    .forgotResendIn(_resendSecondsLeft)
                : AppLocalizations.of(context).forgotResend,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: _resendSecondsLeft > 0
                  ? context.gc.textSecondary
                  : context.gc.lilac,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        BreathingBadge(
          glowColor: context.gc.starYellow,
          haloSize: 96,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.gc.starYellow.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.lock_reset,
              size: 40,
              color: context.gc.starYellow,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).forgotTitle,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.gc.lilac,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context).forgotSubtitle,
          style: GoogleFonts.nunito(
            fontSize: 15,
            color: context.gc.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      enabled: !_isLoading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      onFieldSubmitted: (_) => _handleSendReset(),
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

  Widget _buildSendButton() {
    return PressableScale(
      child: SheenSweep(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSendReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.gc.lilac,
            foregroundColor: const Color(0xFF2B2143),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: context.gc.lilac.withValues(alpha: 0.5),
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
                    AppLocalizations.of(context).forgotSendLink,
                    key: const ValueKey('label'),
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).forgotRemembered,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: context.gc.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppLocalizations.of(context).forgotBackToLoginLower,
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

  Future<void> _handleSendReset() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) {
      _shakeKey.currentState?.shake();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      // Usar Supabase se configurado
      if (SupabaseConfig.isConfigured) {
        final captchaToken = await CaptchaGate.resolve(context);
        if (!mounted) return;
        if (CaptchaConfig.isConfigured && captchaToken == null) {
          throw Exception(AppLocalizations.of(context).authCaptchaFailed);
        }
        final authRepo = SupabaseAuthRepository();
        final result = await authRepo.sendPasswordResetEmail(
          email,
          captchaToken: captchaToken,
        );

        if (!result.success) {
          throw Exception(result.errorMessage ?? AppLocalizations.of(context).forgotSendError);
        }
      } else {
        // Simular envio se Supabase não configurado
        await Future.delayed(const Duration(seconds: 2));
      }

      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
        _startResendCooldown();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _shakeKey.currentState?.shake();
        showAuthSnack(
          context,
          '${AppLocalizations.of(context).forgotSendError}: ${e.toString().replaceAll('Exception: ', '')}',
          type: AuthSnackType.error,
        );
      }
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      // Usar Supabase se configurado
      if (SupabaseConfig.isConfigured) {
        final captchaToken = await CaptchaGate.resolve(context);
        if (!mounted) return;
        if (CaptchaConfig.isConfigured && captchaToken == null) {
          throw Exception(AppLocalizations.of(context).authCaptchaFailed);
        }
        final authRepo = SupabaseAuthRepository();
        final result = await authRepo.sendPasswordResetEmail(
          email,
          captchaToken: captchaToken,
        );

        if (!result.success) {
          throw Exception(result.errorMessage ?? AppLocalizations.of(context).forgotResendError);
        }
      } else {
        await Future.delayed(const Duration(seconds: 2));
      }

      if (mounted) {
        setState(() => _isLoading = false);
        _startResendCooldown();
        showAuthSnack(
          context,
          AppLocalizations.of(context).forgotResendSuccess,
          type: AuthSnackType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showAuthSnack(
          context,
          '${AppLocalizations.of(context).forgotResendErrorPrefix}: ${e.toString().replaceAll('Exception: ', '')}',
          type: AuthSnackType.error,
        );
      }
    }
  }
}
