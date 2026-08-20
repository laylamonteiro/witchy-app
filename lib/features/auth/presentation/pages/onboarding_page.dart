import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/starfield_background.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_motion.dart';
import '../widgets/breathing_badge.dart';

/// Tela de onboarding com slides explicando funcionalidades do app
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Getter (e não campo) porque as cores do tema dependem do context.
  List<OnboardingSlide> get _slides => [
    OnboardingSlide(
      icon: Icons.auto_stories,
      iconColor: context.gc.lilac,
      title: AppLocalizations.of(context).onbSlide1Title,
      description:
          AppLocalizations.of(context).onbSlide1Desc,
      gradient: [
        const Color(0xFF1A1033),
        const Color(0xFF2D1B4E),
      ],
    ),
    OnboardingSlide(
      icon: Icons.nightlight_round,
      iconColor: context.gc.starYellow,
      title: AppLocalizations.of(context).onbSlide2Title,
      description:
          AppLocalizations.of(context).onbSlide2Desc,
      gradient: [
        const Color(0xFF1A2033),
        const Color(0xFF1B3D4E),
      ],
    ),
    OnboardingSlide(
      icon: Icons.book,
      iconColor: context.gc.pink,
      title: AppLocalizations.of(context).onbSlide3Title,
      description:
          AppLocalizations.of(context).onbSlide3Desc,
      gradient: [
        const Color(0xFF331A2A),
        const Color(0xFF4E1B3D),
      ],
    ),
    OnboardingSlide(
      icon: Icons.stars,
      iconColor: context.gc.mint,
      title: AppLocalizations.of(context).onbSlide4Title,
      description:
          AppLocalizations.of(context).onbSlide4Desc,
      gradient: [
        const Color(0xFF1A3320),
        const Color(0xFF1B4E2D),
      ],
    ),
    OnboardingSlide(
      icon: Icons.auto_awesome,
      iconColor: context.gc.lilac,
      title: AppLocalizations.of(context).onbSlide5Title,
      description:
          AppLocalizations.of(context).onbSlide5Desc,
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
          // Fundo único: o gradiente se funde continuamente entre os slides,
          // acompanhando o dedo — uma jornada num céu só, sem cortes.
          Positioned.fill(child: _buildMorphingBackground()),
          const Positioned.fill(
            child: StarfieldBackground(child: SizedBox.expand()),
          ),
          // Page view com slides (transparentes: o céu é a camada de trás)
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _buildSlide(_slides[index], index);
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
                  AppLocalizations.of(context).onbSkip,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: context.gc.textSecondary,
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

  /// O céu da jornada: interpola os gradientes dos slides conforme a
  /// posição real do scroll, então o meio do arrasto é literalmente o meio
  /// do caminho entre duas cores.
  Widget _buildMorphingBackground() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        // O getter _slides constrói a lista — materializa uma vez por frame.
        final slides = _slides;
        double page = _currentPage.toDouble();
        if (_pageController.hasClients &&
            _pageController.position.haveDimensions) {
          page = _pageController.page ?? page;
        }
        final last = slides.length - 1;
        final i = page.floor().clamp(0, last);
        final j = (i + 1).clamp(0, last);
        final t = (page - i).clamp(0.0, 1.0);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(slides[i].gradient[0], slides[j].gradient[0], t)!,
                Color.lerp(slides[i].gradient[1], slides[j].gradient[1], t)!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlide(OnboardingSlide slide, int index) {
    return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Ícone respirando, com parallax mais forte que o texto:
                // camadas andando em velocidades diferentes dão profundidade
                // ao deslizar entre os slides.
                _Parallax(
                  controller: _pageController,
                  index: index,
                  factor: 60,
                  child: BreathingBadge(
                    glowColor: slide.iconColor,
                    haloSize: 170,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: slide.iconColor.withValues(alpha: 0.2),
                        border: Border.all(
                          color: slide.iconColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        slide.icon,
                        size: 70,
                        color: slide.iconColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Título
                _Parallax(
                  controller: _pageController,
                  index: index,
                  factor: 28,
                  child: Text(
                    slide.title,
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: context.gc.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // Descrição
                _Parallax(
                  controller: _pageController,
                  index: index,
                  factor: 14,
                  child: Text(
                    slide.description,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: context.gc.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(flex: 3),
              ],
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
            context.gc.background.withValues(alpha: 0.9),
            context.gc.background,
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
              // Cada bolinha é um atalho para o próprio slide (alvo de
              // toque bem maior que os 8px visíveis).
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive
                          ? context.gc.lilac
                          : context.gc.surfaceBorder,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          // Botões
          if (isLast) ...[
            // Botão de criar conta
            PressableScale(
              child: SheenSweep(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _finishOnboarding(createAccount: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.gc.lilac,
                      foregroundColor: const Color(0xFF2B2143),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).authCreateAccount,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Botão de login
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _finishOnboarding(createAccount: false),
                child: Text(
                  AppLocalizations.of(context).onbHaveAccount,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.gc.lilac,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Botão de próximo
            PressableScale(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.gc.lilac,
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
                        AppLocalizations.of(context).onbNext,
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
      final nav = Navigator.of(context);
      // A Welcome fica NA BASE da pilha antes de empilhar o destino:
      // substituir o onboarding direto por login/cadastro deixava essa tela
      // como única rota — e o voltar (botão ou gesto) esvaziava a pilha,
      // terminando numa tela preta.
      nav.pushReplacementNamed('/welcome');
      nav.pushNamed(createAccount ? '/signup' : '/login');
    }
  }
}

/// Desloca o filho conforme o slide sai do centro — cada camada com seu
/// [factor] (px por página de distância) — e esmaece nas bordas. O widget
/// escuta o PageController: nada de setState por frame.
class _Parallax extends StatelessWidget {
  final PageController controller;
  final int index;
  final double factor;
  final Widget child;

  const _Parallax({
    required this.controller,
    required this.index,
    required this.factor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double delta = 0;
        if (controller.hasClients && controller.position.haveDimensions) {
          delta = (controller.page ?? index.toDouble()) - index;
        }
        return Opacity(
          opacity: (1 - delta.abs() * 0.6).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(-delta * factor, 0),
            child: child,
          ),
        );
      },
      child: child,
    );
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
