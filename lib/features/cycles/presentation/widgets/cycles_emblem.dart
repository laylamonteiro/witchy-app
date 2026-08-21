import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../domain/era_ruler.dart';

/// A arte viva da aba Ciclos: a roda das nove Eras girando devagar.
///
/// Entra como `SectionEmblemHeader.custom`, o ponto de extensão previsto pelo
/// emblema — o halo dourado, a respiração e as estrelas em volta vêm de lá.
/// O que esta arte acrescenta é o movimento próprio da seção: uma volta
/// completa e lenta, com as nove marcas espaçadas pela duração real de cada
/// Era, e uma marca acesa que percorre a roda.
class CyclesEmblemArt extends StatefulWidget {
  const CyclesEmblemArt({super.key, this.size = 92});

  final double size;

  @override
  State<CyclesEmblemArt> createState() => _CyclesEmblemArtState();
}

class _CyclesEmblemArtState extends State<CyclesEmblemArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _roda;

  @override
  void initState() {
    super.initState();
    // Uma volta a cada 40 segundos: o bastante para se perceber que anda,
    // devagar o bastante para não competir com o conteúdo da tela.
    _roda = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _roda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _roda,
        builder: (context, _) => CustomPaint(
          painter: _RodaDasEras(
            volta: _roda.value,
            trilha: gc.surfaceBorder,
            marca: gc.lilac,
            acesa: gc.starYellow,
          ),
        ),
      ),
    );
  }
}

class _RodaDasEras extends CustomPainter {
  const _RodaDasEras({
    required this.volta,
    required this.trilha,
    required this.marca,
    required this.acesa,
  });

  /// Posição da marca acesa na volta, de 0 a 1.
  final double volta;

  final Color trilha;
  final Color marca;
  final Color acesa;

  static const double _inicio = -math.pi / 2;
  static const double _giro = 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = math.min(size.width, size.height) / 2 - 6;

    canvas.drawCircle(
      centro,
      raio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = trilha,
    );

    // As nove marcas ficam onde cada Era começa — espaçadas pela duração
    // real delas, não em nove fatias iguais. É a mesma proporção que a
    // linha do tempo mostra por dentro.
    var acumulado = 0.0;
    for (final regente in EraRegente.ordem) {
      final fracao = acumulado / 120.0;
      final angulo = _inicio + _giro * fracao;
      final ponto = Offset(
        centro.dx + raio * math.cos(angulo),
        centro.dy + raio * math.sin(angulo),
      );

      // A marca mais perto da posição de agora acende.
      final distancia = (fracao - volta).abs();
      final perto = distancia < 0.045 || distancia > 0.955;

      canvas.drawCircle(
        ponto,
        perto ? 4.0 : 2.5,
        Paint()..color = perto ? acesa : marca,
      );

      acumulado += regente.anos;
    }

    // O ponteiro: a marca acesa que dá a volta.
    final anguloAgora = _inicio + _giro * volta;
    final ponteiro = Offset(
      centro.dx + raio * math.cos(anguloAgora),
      centro.dy + raio * math.sin(anguloAgora),
    );
    canvas.drawLine(
      centro,
      ponteiro,
      Paint()
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..color = marca.withValues(alpha: 0.45),
    );
    canvas.drawCircle(ponteiro, 3.0, Paint()..color = acesa);
  }

  @override
  bool shouldRepaint(_RodaDasEras old) =>
      old.volta != volta ||
      old.trilha != trilha ||
      old.marca != marca ||
      old.acesa != acesa;
}
