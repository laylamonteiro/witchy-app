// lib/ui/calendar/calendar_screen.dart
import 'package:flutter/material.dart';
import '../../services/moon_phase_service.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phase = MoonPhaseService.getPhase(DateTime.now());
    final label = MoonPhaseService.getPhaseLabel(phase);
    final hint = MoonPhaseService.getPhaseHint(phase);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário Lunar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lua de hoje',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _MoonCard(label: label, hint: hint),
            const SizedBox(height: 24),
            Text(
              'Em breve',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nas próximas versões, aqui você verá o calendário completo de fases da lua, sabbats e melhores datas para cada tipo de feitiço.',
            ),
          ],
        ),
      ),
    );
  }
}

class _MoonCard extends StatelessWidget {
  final String label;
  final String hint;

  const _MoonCard({
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.9),
                  theme.colorScheme.primary.withOpacity(0.2),
                ],
              ),
            ),
            child: const Icon(
              Icons.brightness_3,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
