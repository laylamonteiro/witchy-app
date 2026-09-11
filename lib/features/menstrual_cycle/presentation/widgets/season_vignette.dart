import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../domain/internal_season.dart';

/// A vinheta da Estação Interna escolhida: repouso, broto, flor aberta ou
/// folha.
///
/// Ela reage à escolha e não diz nada sobre o corpo — é o mesmo desenho
/// enquanto a estação for a mesma, e troca por camadas quando a pessoa
/// escolhe outra. Sem laço, sem partícula e sem respiração obrigatória: o
/// estado parado é o estado normal. Com movimento reduzido, a troca é
/// imediata.
class SeasonVignette extends StatelessWidget {
  const SeasonVignette({super.key, required this.season, this.size = 84});

  /// A estação escolhida, ou nenhuma — e nenhuma também é um desenho.
  final InternalSeason? season;
  final double size;

  @override
  Widget build(BuildContext context) {
    final reduced = GrimoireMotion.reduced(context);
    final colors = context.gc;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedSwitcher(
        duration: reduced ? Duration.zero : GrimoireMotion.reveal,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: CustomPaint(
          key: ValueKey(season?.name ?? 'none'),
          size: Size.square(size),
          painter: _SeasonPainter(
            season: season,
            accent: switch (season) {
              InternalSeason.winter => colors.lilac,
              InternalSeason.spring => colors.mint,
              InternalSeason.summer => colors.gold,
              InternalSeason.autumn => colors.pink,
              null => colors.surfaceBorder,
            },
            quiet: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SeasonPainter extends CustomPainter {
  const _SeasonPainter({
    required this.season,
    required this.accent,
    required this.quiet,
  });

  final InternalSeason? season;
  final Color accent;
  final Color quiet;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = quiet.withValues(alpha: .35);
    canvas.drawCircle(center, side * .46, ring);

    final ink = Paint()
      ..style = PaintingStyle.fill
      ..color = accent.withValues(alpha: .85);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: .9);

    switch (season) {
      // Repouso: um brilho pequeno, baixo, e o chão onde ele descansa.
      case InternalSeason.winter:
        canvas.drawLine(
          Offset(center.dx - side * .24, center.dy + side * .2),
          Offset(center.dx + side * .24, center.dy + side * .2),
          line,
        );
        canvas.drawCircle(
          Offset(center.dx, center.dy + side * .04),
          side * .12,
          ink..color = accent.withValues(alpha: .55),
        );
      // Broto: um caule que sobe e duas folhas que se abrem uma vez.
      case InternalSeason.spring:
        final base = Offset(center.dx, center.dy + side * .24);
        canvas.drawLine(base, Offset(center.dx, center.dy - side * .16), line);
        for (final direction in [-1.0, 1.0]) {
          final leaf = Path()
            ..moveTo(center.dx, center.dy + side * .02)
            ..quadraticBezierTo(
              center.dx + direction * side * .22,
              center.dy - side * .06,
              center.dx + direction * side * .04,
              center.dy - side * .16,
            )
            ..quadraticBezierTo(
              center.dx + direction * side * .02,
              center.dy - side * .04,
              center.dx,
              center.dy + side * .02,
            );
          canvas.drawPath(leaf, ink..color = accent.withValues(alpha: .7));
        }
      // Flor aberta: pétalas acomodadas em volta de uma luz difusa.
      case InternalSeason.summer:
        canvas.drawCircle(
            center, side * .3, ink..color = accent.withValues(alpha: .16));
        for (var i = 0; i < 6; i++) {
          final angle = i * math.pi / 3;
          final petal = Offset(
            center.dx + side * .2 * math.cos(angle),
            center.dy + side * .2 * math.sin(angle),
          );
          canvas.drawCircle(
              petal, side * .09, ink..color = accent.withValues(alpha: .6));
        }
        canvas.drawCircle(
            center, side * .08, ink..color = accent.withValues(alpha: .95));
      // Folha: uma só, virada de lado, com a nervura à mostra.
      case InternalSeason.autumn:
        final leaf = Path()
          ..moveTo(center.dx - side * .24, center.dy + side * .14)
          ..quadraticBezierTo(center.dx - side * .06, center.dy - side * .3,
              center.dx + side * .24, center.dy - side * .14)
          ..quadraticBezierTo(center.dx + side * .06, center.dy + side * .3,
              center.dx - side * .24, center.dy + side * .14);
        canvas.drawPath(leaf, ink..color = accent.withValues(alpha: .6));
        canvas.drawLine(
          Offset(center.dx - side * .2, center.dy + side * .12),
          Offset(center.dx + side * .2, center.dy - side * .12),
          line,
        );
      // Nenhuma escolha é um desenho também: o círculo vazio, esperando.
      case null:
        canvas.drawCircle(
            center, side * .1, ink..color = quiet.withValues(alpha: .35));
    }
  }

  @override
  bool shouldRepaint(_SeasonPainter old) =>
      old.season != season || old.accent != accent || old.quiet != quiet;
}
