import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/breathing_moon.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/moon_phase_widget.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../providers/lunar_provider.dart';

/// Carrossel Ontem/Hoje/Amanhã da lua, no "Seu Dia".
///
/// Traz indicador de páginas e setas com alvo de toque de 44dp: antes quase
/// ninguém descobria que dava para ver ontem e amanhã. Cada card calcula a
/// própria fase com um LunarProvider temporário.
class MoonDayCarousel extends StatefulWidget {
  const MoonDayCarousel({super.key});

  @override
  State<MoonDayCarousel> createState() => _MoonDayCarouselState();
}

class _MoonDayCarouselState extends State<MoonDayCarousel> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1; // 0 = Ontem, 1 = Hoje, 2 = Amanhã

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int page) => _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SizedBox(
          height: 232,
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildDayCard(context, l10n.lunarYesterday, -1),
                  _buildDayCard(context, l10n.lunarToday, 0),
                  _buildDayCard(context, l10n.wheelTomorrow, 1),
                ],
              ),
              if (_currentPage > 0)
                Positioned(
                  left: 4,
                  top: 0,
                  bottom: 0,
                  child: _ArrowButton(
                    icon: Icons.chevron_left,
                    tooltip: l10n.lunarYesterday,
                    onTap: () => _goTo(_currentPage - 1),
                  ),
                ),
              if (_currentPage < 2)
                Positioned(
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: _ArrowButton(
                    icon: Icons.chevron_right,
                    tooltip: l10n.wheelTomorrow,
                    onTap: () => _goTo(_currentPage + 1),
                  ),
                ),
            ],
          ),
        ),
        // Pontinhos: a pista visual de que existem outros dias.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final active = index == _currentPage;
            return GestureDetector(
              onTap: () => _goTo(index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? context.gc.lilac
                        : context.gc.lilac.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, String dayLabel, int dayOffset) {
    final date = DateTime.now().add(Duration(days: dayOffset));

    // Provider temporário só para calcular a fase daquela data.
    final tempProvider = LunarProvider()..setSelectedDate(date);
    final phase = tempProvider.getCurrentMoonPhase();

    // Sem onTap: a lua do dia é leitura, não atalho.
    return MagicalCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayLabel,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: phase == MoonPhase.fullMoon
                  ? BreathingMoon(
                      moonEmoji: phase.emoji,
                      size: 62,
                      showStars: true,
                      showName: true,
                      showDescription: true,
                      phase: phase,
                    )
                  : MoonPhaseWidget(
                      phase: phase,
                      showName: true,
                      showDescription: true,
                      size: 62,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seta do carrossel com área de toque de 44dp (a antiga tinha ~20).
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.gc.surface.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.gc.lilac.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(icon, color: context.gc.lilac, size: 22),
          ),
        ),
      ),
    );
  }
}
