import 'package:flutter/material.dart';
import '../../features/grimoire/data/models/spell_model.dart';
import '../theme/app_theme.dart';

class MoonPhaseWidget extends StatelessWidget {
  final MoonPhase phase;
  final bool showName;
  final bool showDescription;
  final double size;

  const MoonPhaseWidget({
    super.key,
    required this.phase,
    this.showName = true,
    this.showDescription = false,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emoji da fase lunar
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Text(
                phase.emoji,
                style: TextStyle(fontSize: size),
              ),
            );
          },
        ),
        if (showName) ...[
          const SizedBox(height: 8),
          Text(
            phase.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.lilac,
                ),
            textAlign: TextAlign.center,
          ),
        ],
        if (showDescription) ...[
          const SizedBox(height: 8),
          Text(
            phase.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
