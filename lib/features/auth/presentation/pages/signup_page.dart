import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

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
            color: AppColors.mint.withValues(alpha: 0.2),
          ),
          child: const Icon(
            Icons.person_add_outlined,
            size: 40,
            color: AppColors.mint,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Criar Conta',
          style: GoogleFonts.cinzelDecorative(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.lilac,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicie sua jornada mágica',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      style: GoogleFonts.nunito(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Nome',
        hintText: 'Seu nome mágico',
        prefixIcon: const Icon(Icons.person_outline, color: AppColors.lilac),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira seu nome';
        }
        if (value.length < 2) {
          return 'O nome deve ter pelo menos 2 caracteres';
        }
        return null;
      },
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
        hintText: 'Mínimo 6 caracteres',
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
          return 'Por favor, insira uma senha';
        }
        if (value.length < 6) {
          return 'A senha deve ter pelo menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: GoogleFonts.nunito(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Confirmar Senha',
        hintText: 'Digite a senha novamente',
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.lilac),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
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
          return 'Por favor, confirme sua senha';
        }
        if (value != _passwordController.text) {
          return 'As senhas não coincidem';
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
            activeColor: AppColors.lilac,
            checkColor: const Color(0xFF2B2143),
            side: const BorderSide(color: AppColors.surfaceBorder),
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
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Li e aceito os '),
                  TextSpan(
                    text: 'Termos de Uso',
                    style: TextStyle(
                      color: AppColors.lilac,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' e a '),
                  TextSpan(
                    text: 'Política de Privacidade',
                    style: TextStyle(
                      color: AppColors.lilac,
                      fontWeight: FontWeight.bold,
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
        backgroundColor: AppColors.lilac,
        foregroundColor: const Color(0xFF2B2143),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBackgroundColor: AppColors.lilac.withValues(alpha: 0.3),
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
              'Criar Conta',
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
            'ou cadastre-se com',
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
        const SizedBox(width: 16),
        // Apple
        _buildSocialButton(
          icon: '',
          label: 'Apple',
          iconWidget: const Icon(Icons.apple, color: AppColors.textPrimary),
          onPressed: _handleAppleSignup,
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Já tem uma conta? ',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: AppColors.textSecondary,
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
            'Entrar',
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

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa aceitar os termos de uso'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final displayName = _nameController.text.trim();

      // Usar Supabase se configurado
      if (SupabaseConfig.isConfigured) {
        final authRepo = SupabaseAuthRepository();
        final result = await authRepo.signUpWithEmail(
          email: email,
          password: password,
          displayName: displayName,
        );

        if (!result.success) {
          throw Exception(result.errorMessage ?? 'Erro ao criar conta');
        }
      }

      final authProvider = context.read<AuthProvider>();

      // Atualizar perfil local também
      await authProvider.updateProfile(
        displayName: displayName,
        email: email,
      );

      // Marcar onboarding como visto (nova conta não precisa ver)
      await authProvider.markOnboardingSeen();

      if (mounted) {
        // Mostrar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Bem-vinda ao Grimório!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navegar para home
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erro ao criar conta';
        if (e.toString().contains('already')) {
          errorMessage = 'Este email já está em uso';
        } else if (e.toString().contains('password')) {
          errorMessage = 'A senha deve ter pelo menos 6 caracteres';
        } else if (e.toString().contains('email')) {
          errorMessage = 'Email inválido';
        } else {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

  Future<void> _handleGoogleSignup() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa aceitar os termos de uso'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro com Google não disponível no momento'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = SupabaseAuthRepository();
      final result = await authRepo.signInWithGoogle();

      if (!result.success) {
        throw Exception(result.errorMessage ?? 'Erro no cadastro com Google');
      }

      // OAuth vai redirecionar, então não precisamos fazer nada aqui
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no cadastro com Google: $e'),
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

  Future<void> _handleAppleSignup() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa aceitar os termos de uso'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro com Apple não disponível no momento'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = SupabaseAuthRepository();
      final result = await authRepo.signInWithApple();

      if (!result.success) {
        throw Exception(result.errorMessage ?? 'Erro no cadastro com Apple');
      }

      // OAuth vai redirecionar, então não precisamos fazer nada aqui
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no cadastro com Apple: $e'),
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
}
