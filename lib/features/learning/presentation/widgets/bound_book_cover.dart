import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../data/data_sources/trails_data.dart';

/// Which cover a bound trail receives. Keyed by trail ID; the title is
/// rendered by the UI in the current language, never part of the cover.
abstract final class TrailCoverRegistry {
  /// Accent per trail: the position in the catalog picks one of the
  /// palette's tones, so covers differ without any art asset.
  static Color accentFor(BuildContext context, String trailId) {
    final index = learningTrails.indexWhere((t) => t.id == trailId);
    final tones = [context.gc.gold, context.gc.lilac, context.gc.success];
    return tones[(index < 0 ? 0 : index) % tones.length];
  }
}

/// A closed, bound book: spine, cover and the trail's emblem. With
/// [closing] the loose pages gather and the cover comes down once; reduced
/// motion and the shelf show the closed book directly.
class BoundBookCover extends StatelessWidget {
  const BoundBookCover({
    super.key,
    required this.trailId,
    required this.emblem,
    this.width = 96,
    this.closing = false,
    this.playToken = 0,
  });

  final String trailId;
  final String emblem;
  final double width;
  final bool closing;
  final Object playToken;

  @override
  Widget build(BuildContext context) {
    final reduced = GrimoireMotion.reduced(context);
    final accent = TrailCoverRegistry.accentFor(context, trailId);
    final height = width * 1.3;
    return TweenAnimationBuilder<double>(
      key: ValueKey(playToken),
      tween: Tween<double>(begin: closing && !reduced ? 0 : 1, end: 1),
      duration: reduced ? Duration.zero : GrimoireMotion.celebration,
      curve: GrimoireMotion.enter,
      builder: (context, t, _) => SizedBox(
        width: width + 16,
        height: height + 12,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Loose pages gathering behind the cover.
            for (var i = 2; i >= 0; i--)
              Positioned(
                left: 8 + (i + 1) * 3.0 * (1 - t) + 3.0 * i * t,
                top: 4 + (2 - i) * 6.0 * (1 - t) + 1.5 * i,
                child: Container(
                  width: width - 4,
                  height: height - 4,
                  decoration: BoxDecoration(
                    color: Color.lerp(context.gc.surface, context.gc.textPrimary, .12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: context.gc.surfaceBorder),
                  ),
                ),
              ),
            // The cover closes over them: opacity and a slight drop.
            Positioned(
              left: 8,
              top: 12 - 8 * t,
              child: Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(3), right: Radius.circular(8)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(context.gc.surface, accent, .45)!,
                        Color.lerp(context.gc.surface, accent, .2)!,
                      ],
                    ),
                    border: Border.all(color: accent, width: 1.4),
                    boxShadow: [BoxShadow(
                      color: accent.withValues(alpha: .3 * t),
                      blurRadius: 14,
                    )],
                  ),
                  child: Row(children: [
                    Container(
                      width: width * .12,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .85),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(3)),
                      ),
                    ),
                    Expanded(child: Center(child: Container(
                      width: width * .5,
                      height: width * .5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: accent.withValues(alpha: .7)),
                        color: context.gc.surface.withValues(alpha: .5),
                      ),
                      child: Center(child: Text(emblem,
                          style: TextStyle(fontSize: width * .26, height: 1))),
                    ))),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
