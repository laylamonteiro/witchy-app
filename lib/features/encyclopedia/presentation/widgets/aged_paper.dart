import 'dart:math';

import 'package:flutter/material.dart';

/// Paleta do livro antigo: papel creme envelhecido e tinta marrom-café.
/// Tons propositalmente amarelados (nunca branco puro) para o livro parecer
/// um objeto real sobre a "mesa" roxa escura do app.
abstract final class BookInk {
  static const Color paperLight = Color(0xFFE9DFC4);
  static const Color paperDark = Color(0xFFDCCFA8);
  static const Color ink = Color(0xFF4A3728);
  static const Color stain = Color(0xFF8A6A42);
  static const Color wax = Color(0xFF7A3B2E);
}

/// Página de papel envelhecido pintada proceduralmente (sem asset): gradiente
/// creme, manchas de idade, vinheta nas bordas, fibras e uma moldura
/// ornamental de linha dupla com florões nos cantos.
///
/// Envolva em [RepaintBoundary]: o painter é determinístico (seed fixa) e
/// nunca repinta — vira uma layer cacheada, barata de re-compor em animações.
class AgedPaper extends StatelessWidget {
  final Widget child;

  const AgedPaper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(
          painter: _AgedPaperPainter(),
          child: child,
        ),
      ),
    );
  }
}

class _AgedPaperPainter extends CustomPainter {
  // Mesma seed do StarfieldBackground: o "acaso" do app é sempre o mesmo.
  static final Random _random = Random(20260801);

  // Posições/raios das manchas e fibras são sorteados UMA vez por processo e
  // reaproveitados em qualquer tamanho (frações da página).
  static final List<(double, double, double, double)> _stains = [
    for (var i = 0; i < 10; i++)
      (
        _random.nextDouble(),
        _random.nextDouble(),
        0.06 + _random.nextDouble() * 0.12,
        0.04 + _random.nextDouble() * 0.07,
      ),
  ];

  static final List<(double, double, double, double)> _fibers = [
    for (var i = 0; i < 160; i++)
      (
        _random.nextDouble(),
        _random.nextDouble(),
        _random.nextDouble() * 2 * pi,
        2.0 + _random.nextDouble() * 6.0,
      ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Papel: gradiente creme diagonal.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BookInk.paperLight, BookInk.paperDark],
        ).createShader(rect),
    );

    // 2. Manchas de idade: halos radiais marrons bem translúcidos.
    for (final (fx, fy, fr, alpha) in _stains) {
      final center = Offset(fx * size.width, fy * size.height);
      final radius = fr * size.shortestSide * 2;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              BookInk.stain.withValues(alpha: alpha),
              BookInk.stain.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    // 3. Fibras do papel: tracinhos finos quase invisíveis.
    final fiberPaint = Paint()
      ..color = BookInk.ink.withValues(alpha: 0.04)
      ..strokeWidth = 0.7;
    for (final (fx, fy, angle, len) in _fibers) {
      final start = Offset(fx * size.width, fy * size.height);
      canvas.drawLine(
        start,
        start + Offset(cos(angle) * len, sin(angle) * len),
        fiberPaint,
      );
    }

    // 4. Vinheta: bordas levemente escurecidas.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 1.1,
          colors: [
            BookInk.stain.withValues(alpha: 0),
            BookInk.stain.withValues(alpha: 0.20),
          ],
          stops: const [0.62, 1.0],
        ).createShader(rect),
    );

    _paintFrame(canvas, size);
  }

  /// Moldura ornamental: linha dupla com florões de canto e pontos-losango.
  void _paintFrame(Canvas canvas, Size size) {
    final outer = Rect.fromLTWH(14, 14, size.width - 28, size.height - 28);
    final inner = outer.deflate(4);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..color = BookInk.ink.withValues(alpha: 0.55)
      ..strokeWidth = 1.4;
    final thin = Paint()
      ..style = PaintingStyle.stroke
      ..color = BookInk.ink.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;

    canvas.drawRect(outer, line);
    canvas.drawRect(inner, thin);

    // Florões: uma voluta dupla espelhada em cada canto.
    final flourish = Paint()
      ..style = PaintingStyle.stroke
      ..color = BookInk.ink.withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    void corner(Offset origin, double sx, double sy) {
      final path = Path()
        ..moveTo(origin.dx + 6 * sx, origin.dy + 22 * sy)
        ..quadraticBezierTo(
          origin.dx + 6 * sx,
          origin.dy + 6 * sy,
          origin.dx + 22 * sx,
          origin.dy + 6 * sy,
        )
        ..moveTo(origin.dx + 10 * sx, origin.dy + 26 * sy)
        ..quadraticBezierTo(
          origin.dx + 12 * sx,
          origin.dy + 12 * sy,
          origin.dx + 26 * sx,
          origin.dy + 10 * sy,
        );
      canvas.drawPath(path, flourish);
      canvas.drawCircle(
        Offset(origin.dx + 9 * sx, origin.dy + 9 * sy),
        1.6,
        Paint()..color = BookInk.ink.withValues(alpha: 0.5),
      );
    }

    corner(outer.topLeft, 1, 1);
    corner(Offset(outer.right, outer.top), -1, 1);
    corner(Offset(outer.left, outer.bottom), 1, -1);
    corner(outer.bottomRight, -1, -1);

    // Losangos no meio de cada lado.
    final diamond = Paint()..color = BookInk.ink.withValues(alpha: 0.45);
    for (final c in [
      Offset(outer.center.dx, outer.top),
      Offset(outer.center.dx, outer.bottom),
      Offset(outer.left, outer.center.dy),
      Offset(outer.right, outer.center.dy),
    ]) {
      final d = Path()
        ..moveTo(c.dx, c.dy - 3.4)
        ..lineTo(c.dx + 3.4, c.dy)
        ..lineTo(c.dx, c.dy + 3.4)
        ..lineTo(c.dx - 3.4, c.dy)
        ..close();
      canvas.drawPath(d, diamond);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Selo de cera pintado: disco de borda irregular, brilho radial e a lua ☾.
class WaxSeal extends StatelessWidget {
  final double size;

  const WaxSeal({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(size),
          painter: _WaxSealPainter(),
        ),
      ),
    );
  }
}

class _WaxSealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final base = size.shortestSide / 2 - 3;

    // Disco de cera com a borda perturbada (cera escorrida, não círculo).
    final blob = Path();
    for (var i = 0; i <= 72; i++) {
      final theta = i / 72 * 2 * pi;
      final r = base + sin(theta * 5) * 1.8 + sin(theta * 9 + 1.3) * 1.2;
      final p = center + Offset(cos(theta) * r, sin(theta) * r);
      if (i == 0) {
        blob.moveTo(p.dx, p.dy);
      } else {
        blob.lineTo(p.dx, p.dy);
      }
    }
    blob.close();

    canvas.drawPath(
      blob.shift(const Offset(1.5, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(blob, Paint()..color = BookInk.wax);

    // Relevo: brilho no alto, sombra interna embaixo.
    canvas.drawPath(
      blob,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          colors: [
            Colors.white.withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.18),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: base + 4)),
    );

    // Anel interno do carimbo.
    canvas.drawCircle(
      center,
      base * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = BookInk.paperLight.withValues(alpha: 0.55),
    );

    // A lua do Grimório gravada na cera.
    final glyph = TextPainter(
      text: TextSpan(
        text: '☾',
        style: TextStyle(
          fontSize: base * 0.95,
          color: BookInk.paperLight.withValues(alpha: 0.85),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    glyph.paint(
      canvas,
      center - Offset(glyph.width / 2, glyph.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
