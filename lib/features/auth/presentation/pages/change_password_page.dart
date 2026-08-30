import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/repositories/supabase_auth_repository.dart';

/// Tela de alteração de senha
class ChangePasswordPage extends StatefulWidget {
  /// Fluxo "esqueci minha senha": a pessoa chegou pelo link do e-mail com
  /// uma sessão de recuperação e NÃO SABE a senha atual — o campo dela é
  /// escondido. Fora da recuperação o campo fica, como fricção honesta
  /// contra troca de senha num aparelho desbloqueado alheio (o backend não
  /// exige a senha atual; a checagem é só desta tela).
  final bool recovery;

  const ChangePasswordPage({super.key, this.recovery = false});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Sai da tela do jeito certo para cada modo.
  ///
  /// Em RECUPERAÇÃO esta é uma rota de TOPO do go_router (aberta por
  /// `router.go('/recuperar-senha')`, sem nada embaixo), então `Navigator.pop`
  /// seria no-op e a Bruxa ficaria presa depois de trocar a senha. Ali usa-se
  /// `context.go('/seu-dia')` — a sessão de recuperação está viva. Fora da
  /// recuperação a tela foi EMPURRADA por cima do app (MaterialPageRoute das
  /// Configurações), e o pop volta certo.
  void _sair() {
    if (widget.recovery) {
      context.go('/seu-dia');
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.gc.lilac),
          onPressed: _sair,
        ),
        title: ResponsiveAppBarTitle(
          AppLocalizations.of(context).changePasswordTitle,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.gc.lilac,
          ),
        ),
        centerTitle: true,
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
                const SizedBox(height: 32),
                // Campo de senha atual (fora do fluxo de recuperação)
                if (!widget.recovery) ...[
                  _buildCurrentPasswordField(),
                  const SizedBox(height: 16),
                ],
                // Campo de nova senha
                _buildNewPasswordField(),
                const SizedBox(height: 16),
                // Campo de confirmar nova senha
                _buildConfirmPasswordField(),
                const SizedBox(height: 32),
                // Botão de alterar
                _buildChangeButton(),
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
            color: context.gc.lilac.withValues(alpha: 0.2),
          ),
          child: Icon(
            Icons.password_outlined,
            size: 40,
            color: context.gc.lilac,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context).changePasswordHeader,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.gc.lilac,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).changePasswordSubtitle,
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

  Widget _buildCurrentPasswordField() {
    return TextFormField(
      controller: _currentPasswordController,
      obscureText: _obscureCurrentPassword,
      style: GoogleFonts.nunito(color: context.gc.textPrimary),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).changePasswordCurrentLabel,
        hintText: '••••••••',
        prefixIcon: Icon(Icons.lock_outline, color: context.gc.lilac),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
            color: context.gc.textSecondary,
          ),
          onPressed: () {
            setState(() {
              _obscureCurrentPassword = !_obscureCurrentPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).changePasswordCurrentRequired;
        }
        if (value.length < 6) {
          return AppLocalizations.of(context).authPasswordMinLength;
        }
        return null;
      },
    );
  }

  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: _newPasswordController,
      obscureText: _obscureNewPassword,
      style: GoogleFonts.nunito(color: context.gc.textPrimary),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).changePasswordNewLabel,
        hintText: AppLocalizations.of(context).authPasswordHintMin,
        prefixIcon: Icon(Icons.lock_open_outlined, color: context.gc.mint),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
            color: context.gc.textSecondary,
          ),
          onPressed: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).changePasswordNewRequired;
        }
        if (value.length < 6) {
          return AppLocalizations.of(context).authPasswordMinLength;
        }
        if (!widget.recovery && value == _currentPasswordController.text) {
          return AppLocalizations.of(context).changePasswordMustDiffer;
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
        labelText: AppLocalizations.of(context).changePasswordConfirmLabel,
        hintText: AppLocalizations.of(context).changePasswordConfirmHint,
        prefixIcon: Icon(Icons.lock_open_outlined, color: context.gc.mint),
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
          return AppLocalizations.of(context).changePasswordConfirmRequired;
        }
        if (value != _newPasswordController.text) {
          return AppLocalizations.of(context).authPasswordsDontMatch;
        }
        return null;
      },
    );
  }

  Widget _buildChangeButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleChangePassword,
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
              AppLocalizations.of(context).changePasswordTitle,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;

      // Usar Supabase se configurado
      if (SupabaseConfig.isConfigured) {
        final authRepo = SupabaseAuthRepository();
        final result = await authRepo.updatePassword(
          currentPassword,
          newPassword,
        );

        if (!result.success) {
          throw Exception(result.errorMessage ?? AppLocalizations.of(context).changePasswordError);
        }
      } else {
        // Simular alteração se Supabase não configurado
        await Future.delayed(const Duration(seconds: 2));
      }

      if (mounted) {
        // Mostrar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).changePasswordSuccess),
            backgroundColor: context.gc.success,
          ),
        );

        // Sai da tela (ver [_sair] — recuperação usa go_router).
        _sair();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        String errorMessage = AppLocalizations.of(context).changePasswordError;
        if (e.toString().contains('Invalid login') ||
            e.toString().contains('credentials') ||
            e.toString().contains('password')) {
          errorMessage = AppLocalizations.of(context).changePasswordWrongCurrent;
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
}
