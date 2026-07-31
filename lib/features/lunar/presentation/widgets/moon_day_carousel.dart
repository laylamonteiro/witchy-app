import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/breathing_moon.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/moon_phase_widget.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../providers/lunar_provider.dart';

/// Carrossel Ontem/Hoje/Amanhã da lua — extraído da LunarCalendarPage sem
/// mudança visual para viver na aba "Seu Dia". Cada card calcula a própria
/// fase com um LunarProvider temporário (não depende de provider externo).
class MoonDayCarousel extends StatefulWidget {
  /// Toque em um card (ex.: navegar para a página da Lua).
  final VoidCallback? onDayTap;

  const MoonDayCarousel({super.key, this.onDayTap});

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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildDayCard(
                context,
                AppLocalizations.of(context).lunarYesterday,
                -1,
                dateFormat,
              ),
              _buildDayCard(
                context,
                AppLocalizations.of(context).lunarToday,
                0,
                dateFormat,
              ),
              _buildDayCard(
                context,
                AppLocalizations.of(context).wheelTomorrow,
                1,
                dateFormat,
              ),
            ],
          ),
          // Seta esquerda
          if (_currentPage > 0)
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.gc.surface.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: context.gc.lilac,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          // Seta direita
          if (_currentPage < 2)
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.gc.surface.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: context.gc.lilac,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    String dayLabel,
    int dayOffset,
    DateFormat dateFormat,
  ) {
    // Calcular a data baseada no offset (-1 = ontem, 0 = hoje, 1 = amanhã)
    final date = DateTime.now().add(Duration(days: dayOffset));

    // Criar um provider temporário para a data específica
    final tempProvider = LunarProvider()..setSelectedDate(date);
    final phase = tempProvider.getCurrentMoonPhase();

    return MagicalCard(
      onTap: widget.onDayTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayLabel,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 2),
            Text(
              dateFormat.format(date),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            // Usar BreathingMoon para Lua Cheia, MoonPhaseWidget para outras fases
            Flexible(
              child: phase == MoonPhase.fullMoon
                  ? BreathingMoon(
                      moonEmoji: phase.emoji,
                      size: 70,
                      showStars: true,
                      showName: true,
                      showDescription: true,
                      phase: phase,
                    )
                  : MoonPhaseWidget(
                      phase: phase,
                      showName: true,
                      showDescription: true,
                      size: 70,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
