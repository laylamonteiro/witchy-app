import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// Tela de onboarding com slides explicando funcionalidades do app
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      icon: Icons.auto_stories,
      iconColor: AppColors.lilac,
      title: 'Seu Grimório Digital',
      description:
          'Guarde seus feitiços, rituais e receitas mágicas em um só lugar. Organize por fase lunar, ingredientes e muito mais.',
      gradient: [
        const Color(0xFF1A1033),
        const Color(0xFF2D1B4E),
      ],
    ),
    OnboardingSlide(
      icon: Icons.nightlight_round,
      iconColor: AppColors.starYellow,
      title: 'Calendário Lunar',
      description:
          'Acompanhe as fases da lua e descubra o melhor momento para cada tipo de magia. Receba notificações em luas cheias e novas.',
      gradient: [
        const Color(0xFF1A2033),
        const Color(0xFF1B3D4E),
      ],
    ),
    OnboardingSlide(
      icon: Icons.book,
      iconColor: AppColors.pink,
      title: 'Diários Mágicos',
      description:
          'Registre sonhos, desejos, gratidão e afirmações. Acompanhe sua evolução espiritual dia após dia.',
      gradient: [
        const Color(0xFF331A2A),
        const Color(0xFF4E1B3D),
      ],
    ),
    OnboardingSlide(
      icon: Icons.stars,
      iconColor: AppColors.mint,
      title: 'Astrologia Completa',
      description:
          'Descubra seu mapa astral, perfil mágico personalizado e receba previsões diárias baseadas nos trânsitos planetários.',
      gradient: [
        const Color(0xFF1A3320),
        const Color(0xFF1B4E2D),
      ],
    ),
    OnboardingSlide(
      icon: Icons.auto_awesome,
      iconColor: AppColors.lilac,
      title: 'Pronta para Começar?',
      description:
          'Crie sua conta para sincronizar seus dados em todos os dispositivos, ou continue no modo local.',
      gradient: [
        const Color(0xFF1A1033),
        const Color(0xFF2D1B4E),
      ],
      isLast: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view com slides
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _buildSlide(_slides[index]);
            },
          ),
          // Skip button
          if (_currentPage < _slides.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Pular',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: slide.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Ícone
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slide.iconColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: slide.iconColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: slide.iconColor.withValues(alpha: 0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  slide.icon,
                  size: 70,
                  color: slide.iconColor,
                ),
              ),
              const SizedBox(height: 48),
              // Título
              Text(
                slide.title,
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Descrição
              Text(
                slide.description,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final isLast = _currentPage == _slides.length - 1;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(32, 24, 32, 32 + bottomPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.background.withValues(alpha: 0.9),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicadores de página
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? AppColors.lilac
                      : AppColors.surfaceBorder,
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          // Botões
          if (isLast) ...[
            // Botão de criar conta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _finishOnboarding(createAccount: true),
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
            // Botão de continuar sem conta
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _finishOnboarding(createAccount: false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.lilac,
                  side: const BorderSide(color: AppColors.lilac, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continuar sem Conta',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Botão de próximo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  foregroundColor: const Color(0xFF2B2143),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Próximo',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    _pageController.animateToPage(
      _slides.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding({required bool createAccount}) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.markOnboardingSeen();

    if (mounted) {
      if (createAccount) {
        Navigator.of(context).pushReplacementNamed('/signup');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }
}

/// Modelo de dados para um slide do onboarding
class OnboardingSlide {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<Color> gradient;
  final bool isLast;

  const OnboardingSlide({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.gradient,
    this.isLast = false,
  });
}
