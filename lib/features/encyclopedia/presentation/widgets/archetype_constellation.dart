import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';

/// A constelação da sessão: uma estrela por arquétipo que recebeu respostas,
/// mais alta quanto mais pontos, ligadas na ordem do céu.
///
/// O desenho é determinístico — as mesmas respostas dão sempre a mesma
/// figura, porque a posição vem da posição da chave no catálogo e não de
/// sorteio. A chave é opaca aqui: o que importa é ser a mesma em [scores],
/// [order] e [winner] (hoje é o id do arquétipo). As estrelas acendem uma a
/// uma; com movimento reduzido a constelação já aparece inteira. Nada aqui
/// pontua: a contagem é a mesma que a tela já calculou.
class ArchetypeConstellation extends StatelessWidget {
  const ArchetypeConstellation({
    super.key,
    required this.scores,
    required this.order,
    required this.winner,
    this.height = 180,
    this.animate = false,
  });

  /// Pontos por arquétipo, na chave invariante do catálogo.
  final Map<String, int> scores;

  /// Todas as chaves do catálogo, em ordem estável entre idiomas.
  final List<String> order;

  /// A chave vencedora, que ganha o halo.
  final String winner;

  final double height;

  /// Só a sessão recém-concluída acende; um resultado guardado abre pronto.
  final bool animate;

  /// Onde cada estrela mora, entre 0 e 1 nos dois eixos. Depende apenas da
  /// posição da chave no catálogo e da pontuação.
  static List<ConstellationStar> stars({
    required Map<String, int> scores,
    required List<String> order,
    required String winner,
  }) {
    final keys = [for (final key in order) if ((scores[key] ?? 0) > 0) key];
    if (keys.isEmpty) return const [];
    final highest = scores.values.fold<int>(0, (a, b) => a > b ? a : b);
    final slots = order.isEmpty ? keys.length : order.length;
    return [
      for (var i = 0; i < keys.length; i++)
        () {
          final key = keys[i];
          final slot = order.indexOf(key);
          final angle = 2 * math.pi * ((slot < 0 ? i : slot) / slots) - math.pi / 2;
          final score = scores[key] ?? 0;
          // Quanto mais pontos, mais perto do centro — mas nenhuma estrela
          // entra no meio: é ali que o arquétipo aparece.
          final radius = highest <= 0 ? .85 : .85 - .30 * (score / highest);
          return ConstellationStar(
            key: key,
            position: Offset(.5 + radius * math.cos(angle) * .9,
                .5 + radius * math.sin(angle) * .9),
            weight: highest <= 0 ? 0 : score / highest,
            isWinner: key == winner,
          );
        }(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final figure = stars(scores: scores, order: order, winner: winner);
    if (figure.isEmpty) return const SizedBox.shrink();
    final reduced = GrimoireMotion.reduced(context);
    final play = animate && !reduced;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: play ? 0 : 1, end: 1),
        duration: play ? GrimoireMotion.celebration : Duration.zero,
        curve: Curves.linear,
        builder: (context, t, _) => CustomPaint(
          key: const ValueKey('quiz-constellation'),
          painter: _ConstellationPainter(
            stars: figure,
            colors: context.gc,
            progress: t,
          ),
        ),
      ),
    );
  }
}

/// Uma estrela da constelação, já resolvida em posição relativa.
class ConstellationStar {
  const ConstellationStar({
    required this.key,
    required this.position,
    required this.weight,
    required this.isWinner,
  });

  final String key;

  /// Entre 0 e 1 nos dois eixos.
  final Offset position;

  /// Entre 0 e 1: a pontuação relativa à mais alta da sessão.
  final double weight;

  final bool isWinner;
}

class _ConstellationPainter extends CustomPainter {
  const _ConstellationPainter({
    required this.stars,
    required this.colors,
    required this.progress,
  });

  final List<ConstellationStar> stars;
  final GrimoireColors colors;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (stars.isEmpty) return;
    final points = [
      for (final star in stars)
        Offset(star.position.dx * size.width, star.position.dy * size.height),
    ];
    final lit = progress <= 0
        ? 0
        : (progress * stars.length).ceil().clamp(0, stars.length);

    // As linhas do céu, atrás das estrelas.
    final linePaint = Paint()
      ..color = colors.lilac.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 1; i < lit; i++) {
      canvas.drawLine(points[i - 1], points[i], linePaint);
    }

    for (var i = 0; i < lit; i++) {
      final star = stars[i];
      final center = points[i];
      final radius = 2.5 + 4.5 * star.weight;
      if (star.isWinner) {
        canvas.drawCircle(center, radius * 3,
            Paint()..color = colors.gold.withValues(alpha: .18));
      }
      canvas.drawCircle(center, radius * 1.8,
          Paint()..color = (star.isWinner ? colors.gold : colors.lilac)
              .withValues(alpha: .22));
      canvas.drawCircle(center, radius,
          Paint()..color = star.isWinner ? colors.gold : colors.starYellow);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) =>
      old.progress != progress || old.stars != stars || old.colors != colors;
}
