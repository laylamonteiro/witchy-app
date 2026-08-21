import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';

/// O anel que mostra onde a pessoa está dentro da Era.
///
/// Três informações no mesmo desenho: a volta inteira é a Era; o arco aceso é
/// o quanto já passou; a fatia sombreada é a Fase de agora. O ponto marca o
/// instante presente.
class EraProgressRing extends StatelessWidget {
  const EraProgressRing({
    super.key,
    required this.eraProgress,
    required this.phaseStart,
    required this.phaseEnd,
    this.diameter = 220,
    this.center,
  });

  /// Quanto da Era já passou, de 0 a 1.
  final double eraProgress;

  /// Início da Fase atual, como fração da Era (0 a 1).
  final double phaseStart;

  /// Fim da Fase atual, como fração da Era (0 a 1).
  final double phaseEnd;

  final double diameter;

  /// Conteúdo do miolo — em geral o período da Era. Recebido pronto porque
  /// o pintor não tem `BuildContext` para resolver textos.
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _EraRingPainter(
          eraProgress: eraProgress.clamp(0.0, 1.0),
          phaseStart: phaseStart.clamp(0.0, 1.0),
          phaseEnd: phaseEnd.clamp(0.0, 1.0),
          trilha: context.gc.surfaceBorder,
          arco: context.gc.lilac,
          fatia: context.gc.lilac.withValues(alpha: 0.18),
          miolo: context.gc.surface,
        ),
        child: center == null
            ? null
            : Center(
                child: Padding(
                  padding: EdgeInsets.all(diameter * 0.22),
                  child: center,
                ),
              ),
      ),
    );
  }
}

class _EraRingPainter extends CustomPainter {
  const _EraRingPainter({
    required this.eraProgress,
    required this.phaseStart,
    required this.phaseEnd,
    required this.trilha,
    required this.arco,
    required this.fatia,
    required this.miolo,
  });

  final double eraProgress;
  final double phaseStart;
  final double phaseEnd;
  final Color trilha;
  final Color arco;
  final Color fatia;
  final Color miolo;

  /// A volta começa às 12 horas e corre no sentido horário.
  static const double _inicio = -math.pi / 2;
  static const double _volta = 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = math.min(size.width, size.height) / 2;
    final espessura = raio * 0.055;
    final raioArco = raio - espessura;
    final raioFatia = raioArco - espessura * 1.6;

    // Miolo, para o texto do período ter fundo próprio.
    canvas.drawCircle(centro, raioFatia, Paint()..color = miolo);

    // A fatia da Fase atual, desenhada como setor a partir do centro.
    if (phaseEnd > phaseStart) {
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: raioFatia),
        _inicio + _volta * phaseStart,
        _volta * (phaseEnd - phaseStart),
        true,
        Paint()..color = fatia,
      );
    }

    final traco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = espessura;

    // A volta inteira, apagada: é a Era completa.
    canvas.drawCircle(centro, raioArco, traco..color = trilha);

    // O trecho já percorrido.
    if (eraProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: raioArco),
        _inicio,
        _volta * eraProgress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = espessura
          ..color = arco,
      );
    }

    // O ponto do agora.
    final anguloAgora = _inicio + _volta * eraProgress;
    final pontoAgora = Offset(
      centro.dx + raioArco * math.cos(anguloAgora),
      centro.dy + raioArco * math.sin(anguloAgora),
    );
    canvas.drawCircle(pontoAgora, espessura * 1.35, Paint()..color = miolo);
    canvas.drawCircle(pontoAgora, espessura, Paint()..color = arco);
  }

  @override
  bool shouldRepaint(_EraRingPainter old) =>
      old.eraProgress != eraProgress ||
      old.phaseStart != phaseStart ||
      old.phaseEnd != phaseEnd ||
      old.arco != arco ||
      old.trilha != trilha ||
      old.fatia != fatia ||
      old.miolo != miolo;
}
