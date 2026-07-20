import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import 'login_page.dart';

/// Tela de recuperação de senha
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _emailSent ? _buildSuccessContent() : _buildFormContent(),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          // Header
          _buildHeader(),
          const SizedBox(height: 48),
          // Campo de email
          _buildEmailField(),
          const SizedBox(height: 32),
          // Botão de enviar
          _buildSendButton(),
          const SizedBox(height: 32),
          // Link para voltar ao login
          _buildBackToLogin(),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),
        // Ícone de sucesso
        Container(
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
        const SizedBox(height: 32),
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
        ElevatedButton(
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
        const SizedBox(height: 16),
        // Link para reenviar
        TextButton(
          onPressed: _isLoading ? null : _handleResend,
          child: Text(
            AppLocalizations.of(context).forgotResend,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: context.gc.lilac,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
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
        const SizedBox(height: 24),
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

  Widget _buildSendButton() {
    return ElevatedButton(
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
              AppLocalizations.of(context).forgotSendLink,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      // Usar Supabase se configurado
      if (SupabaseConfig.isConfigured) {
        final authRepo = SupabaseAuthRepository();
        final result = await authRepo.sendPasswordResetEmail(email);

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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).forgotSendError}: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: context.gc.alert,
          ),
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
        final authRepo = SupabaseAuthRepository();
        final result = await authRepo.sendPasswordResetEmail(email);

        if (!result.success) {
          throw Exception(result.errorMessage ?? AppLocalizations.of(context).forgotResendError);
        }
      } else {
        await Future.delayed(const Duration(seconds: 2));
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).forgotResendSuccess),
            backgroundColor: context.gc.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).forgotResendErrorPrefix}: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: context.gc.alert,
          ),
        );
      }
    }
  }
}
