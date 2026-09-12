import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';

/// A constelação da sessão: uma estrela por arquétipo que recebeu respostas,
/// mais perto do centro quanto mais pontos, ligadas num anel em volta do
/// arquétipo revelado.
///
/// O desenho é determinístico — as mesmas respostas dão sempre a mesma
/// figura: as estrelas entram na ordem do catálogo, espalhadas em ângulos
/// iguais, e a figura gira conforme a posição do vencedor no catálogo. A
/// chave é opaca aqui: o que importa é ser a mesma em [scores], [order] e
/// [winner] (hoje é o id do arquétipo). As estrelas acendem uma a uma; com
/// movimento reduzido a constelação já aparece inteira. Nada aqui pontua: a
/// contagem é a mesma que a tela já calculou.
///
/// Houve uma versão em que cada estrela ocupava a fatia do SEU arquétipo
/// entre as onze, e a posição era relativa à largura e à altura da caixa
/// separadamente. Numa caixa mais larga que alta, isso esticava o anel até
/// as estrelas saírem pela lateral do card, e quatro ou cinco estrelas em
/// fatias arbitrárias das onze viravam um zigue-zague com cordas cruzando o
/// meio, por cima do desenho. Agora a figura mora num QUADRADO do tamanho
/// do menor lado, e as estrelas presentes dividem a volta entre si.
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

  /// O anel, em fração do meio-lado do quadrado: a estrela mais pontuada
  /// fica em [innerRing], a menos pontuada em [outerRing]. O meio fica
  /// livre para o arquétipo, e a borda fica livre para o halo da vencedora.
  static const innerRing = .70;
  static const outerRing = .92;

  /// Quanto do meio-lado o anel usa: com [outerRing] dá 0,405 do lado, e
  /// sobram uns 9% de cada lado para o brilho não ser cortado.
  static const _reach = .44;

  /// Onde cada estrela mora, entre 0 e 1 nos dois eixos de um quadrado. Só
  /// depende da ordem do catálogo, da pontuação e de quem venceu.
  static List<ConstellationStar> stars({
    required Map<String, int> scores,
    required List<String> order,
    required String winner,
  }) {
    final keys = [for (final key in order) if ((scores[key] ?? 0) > 0) key];
    if (keys.isEmpty) return const [];
    final highest = scores.values.fold<int>(0, (a, b) => a > b ? a : b);
    final slots = order.isEmpty ? keys.length : order.length;
    // A figura começa no alto e gira com a posição da vencedora no
    // catálogo: dois resultados diferentes não desenham o mesmo anel.
    final winnerSlot = order.indexOf(winner);
    final start = -math.pi / 2 +
        2 * math.pi * ((winnerSlot < 0 ? 0 : winnerSlot) / slots);
    return [
      for (var i = 0; i < keys.length; i++)
        () {
          final key = keys[i];
          final angle = start + 2 * math.pi * (i / keys.length);
          final score = scores[key] ?? 0;
          final weight = highest <= 0 ? 0.0 : score / highest;
          final radius = outerRing - (outerRing - innerRing) * weight;
          return ConstellationStar(
            key: key,
            position: Offset(.5 + radius * _reach * math.cos(angle),
                .5 + radius * _reach * math.sin(angle)),
            weight: weight,
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

  /// Entre 0 e 1 nos dois eixos de um quadrado centrado na caixa.
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
    // O quadrado do menor lado, no meio da caixa: é o que mantém o anel
    // redondo e dentro do card, seja a caixa larga ou alta.
    final side = math.min(size.width, size.height);
    final origin = Offset((size.width - side) / 2, (size.height - side) / 2);
    final points = [
      for (final star in stars)
        origin + Offset(star.position.dx * side, star.position.dy * side),
    ];
    final lit = progress <= 0
        ? 0
        : (progress * stars.length).ceil().clamp(0, stars.length);

    // As linhas do céu, atrás das estrelas: um anel, que só se fecha quando
    // a última estrela acende — e não se fecha com duas, que seriam ida e
    // volta pela mesma linha.
    final linePaint = Paint()
      ..color = colors.lilac.withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 1; i < lit; i++) {
      canvas.drawLine(points[i - 1], points[i], linePaint);
    }
    if (lit == stars.length && stars.length > 2) {
      canvas.drawLine(points.last, points.first, linePaint);
    }

    for (var i = 0; i < lit; i++) {
      final star = stars[i];
      final center = points[i];
      final radius = 1.6 + 2.4 * star.weight;
      if (star.isWinner) {
        canvas.drawCircle(center, radius * 2.8,
            Paint()..color = colors.gold.withValues(alpha: .16));
      }
      canvas.drawCircle(center, radius * 1.9,
          Paint()..color = (star.isWinner ? colors.gold : colors.lilac)
              .withValues(alpha: .2));
      canvas.drawCircle(center, radius,
          Paint()..color = star.isWinner ? colors.gold : colors.starYellow);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) =>
      old.progress != progress || old.stars != stars || old.colors != colors;
}
