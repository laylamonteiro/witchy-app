import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
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
          icon: const Icon(Icons.arrow_back, color: AppColors.lilac),
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
            color: AppColors.success.withValues(alpha: 0.2),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 64,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 32),
        // Título
        Text(
          'Email Enviado!',
          style: GoogleFonts.cinzelDecorative(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.lilac,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Descrição
        Text(
          'Enviamos um link de recuperação para\n${_emailController.text}',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Verifique sua caixa de entrada e spam.',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: AppColors.textSecondary,
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
            backgroundColor: AppColors.lilac,
            foregroundColor: const Color(0xFF2B2143),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Voltar ao Login',
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
            'Não recebeu? Enviar novamente',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.lilac,
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
            color: AppColors.starYellow.withValues(alpha: 0.2),
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 40,
            color: AppColors.starYellow,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Esqueceu a senha?',
          style: GoogleFonts.cinzelDecorative(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.lilac,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sem problemas! Digite seu email e enviaremos um link para criar uma nova senha.',
          style: GoogleFonts.nunito(
            fontSize: 15,
            color: AppColors.textSecondary,
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
      style: GoogleFonts.nunito(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'seu@email.com',
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.lilac),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira seu email';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Por favor, insira um email válido';
        }
        return null;
      },
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSendReset,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lilac,
        foregroundColor: const Color(0xFF2B2143),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBackgroundColor: AppColors.lilac.withValues(alpha: 0.5),
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
              'Enviar Link de Recuperação',
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
          'Lembrou a senha? ',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: AppColors.textSecondary,
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
            'Voltar ao login',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.lilac,
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
      // TODO: Implementar recuperação real com Supabase
      // Por enquanto, simula envio
      await Future.delayed(const Duration(seconds: 2));

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
            content: Text('Erro ao enviar email: $e'),
            backgroundColor: AppColors.alert,
          ),
        );
      }
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implementar reenvio real com Supabase
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email reenviado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reenviar: $e'),
            backgroundColor: AppColors.alert,
          ),
        );
      }
    }
  }
}
