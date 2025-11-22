import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'login_page.dart';
import 'signup_page.dart';

/// Tela de boas-vindas com opções de login ou cadastro
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1033), // Roxo mais escuro no topo
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo/Ícone
                _buildLogo(),
                const SizedBox(height: 32),
                // Título
                Text(
                  'Grimório de Bolso',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lilac,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Subtítulo
                Text(
                  'Sua jornada mágica começa aqui',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                // Features preview
                _buildFeaturesList(),
                const Spacer(flex: 2),
                // Botões
                _buildButtons(context),
                const SizedBox(height: 24),
                // Link para continuar sem conta
                TextButton(
                  onPressed: () => _continueWithoutAccount(context),
                  child: Text(
                    'Continuar sem conta',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lilac.withValues(alpha: 0.3),
            AppColors.pink.withValues(alpha: 0.3),
          ],
        ),
        border: Border.all(
          color: AppColors.lilac.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.lilac.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_stories,
        size: 56,
        color: AppColors.lilac,
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      ('Calendário Lunar', Icons.nightlight_round),
      ('Grimório Digital', Icons.menu_book),
      ('Diários Mágicos', Icons.book),
      ('Astrologia', Icons.stars),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceBorder,
        ),
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lilac.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature.$2,
                    color: AppColors.lilac,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  feature.$1,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Botão de cadastro (primário)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupPage()),
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
              'Criar Conta',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Botão de login (secundário)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.lilac,
              side: const BorderSide(color: AppColors.lilac, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Já tenho conta',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _continueWithoutAccount(BuildContext context) {
    // Navegar para a home sem criar conta
    // O usuário usará o modo local
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
