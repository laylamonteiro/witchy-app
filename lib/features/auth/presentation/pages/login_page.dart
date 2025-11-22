import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
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
          icon: const Icon(Icons.arrow_back, color: AppColors.lilac),
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
                      'Esqueci minha senha',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.lilac,
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lilac.withValues(alpha: 0.2),
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 40,
            color: AppColors.lilac,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Bem-vinda de volta!',
          style: GoogleFonts.cinzelDecorative(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.lilac,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entre para acessar seu grimório',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
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

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.nunito(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Senha',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.lilac),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
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
          return 'Por favor, insira sua senha';
        }
        if (value.length < 6) {
          return 'A senha deve ter pelo menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
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
              'Entrar',
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
            color: AppColors.surfaceBorder,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou continue com',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.surfaceBorder,
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
        const SizedBox(width: 16),
        // Apple
        _buildSocialButton(
          icon: '',
          label: 'Apple',
          iconWidget: const Icon(Icons.apple, color: AppColors.textPrimary),
          onPressed: _handleAppleLogin,
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
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.surfaceBorder),
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
                color: AppColors.textPrimary,
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
          'Não tem uma conta? ',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: AppColors.textSecondary,
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
            'Criar conta',
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implementar login real com Supabase
      // Por enquanto, simula login local
      await Future.delayed(const Duration(seconds: 1));

      final authProvider = context.read<AuthProvider>();
      await authProvider.updateProfile(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        // Navegar para home
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer login: $e'),
            backgroundColor: AppColors.alert,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleGoogleLogin() {
    // TODO: Implementar login com Google
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login com Google será implementado em breve'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _handleAppleLogin() {
    // TODO: Implementar login com Apple
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login com Apple será implementado em breve'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
