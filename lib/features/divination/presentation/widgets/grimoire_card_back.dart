import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';

enum _BackSymbol { moon, sun, star, eye, crystal, leaf }

/// Quatro marcas do Oráculo, deliberadamente disjuntas das seis do Tarô: são
/// 44 cartas, 11 por marca. Conversam com as cenas que o registro de arte já
/// tem (chama/vela, gota/caldeirão, espiral/porta e chave, pena/semente).
enum _OracleMark { spiral, flame, drop, feather }

/// Qual baralho este verso representa.
///
/// O Tarô e o Oráculo dividiam o mesmo desenho, e no leque — que é o mesmo
/// widget para os dois — não havia como dizer de longe qual baralho estava na
/// mão. São dois desenhos irmãos: mesmas cores, mesma espessura de traço,
/// geometria de leitura oposta (o Tarô desce numa coluna, o Oráculo irradia
/// do centro) e molduras trocadas.
enum GrimoireBackFace { tarot, oracle }

/// Decorative marks follow the original shuffled position, never the face ID.
/// Keeping that position through selection also keeps the back unchanged.
class GrimoireCardBack extends StatelessWidget {
  const GrimoireCardBack({
    super.key,
    required this.width,
    required this.height,
    required this.deckPosition,
    this.highlighted = false,
    this.face = GrimoireBackFace.tarot,
  }) : assert(deckPosition >= 0);

  final double width;
  final double height;
  final int deckPosition;
  final bool highlighted;

  /// Padrão Tarô: quem já chamava este verso continua com o mesmo desenho.
  final GrimoireBackFace face;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size(width, height),
      painter: _CardBackPainter(
        colors: context.gc,
        face: face,
        deckPosition: deckPosition,
        highlighted: highlighted,
      ),
    ),
  );
}

/// Proporção clássica da carta, repetida aqui de propósito: o verso não pode
/// depender da frente — é justamente o que o impede de entregar a carta.
const double _aspectRatio = 0.585;

/// O verso do Oráculo, irmão de `TarotCardBack`: quem chama troca uma palavra.
class OracleCardBack extends StatelessWidget {
  const OracleCardBack({
    super.key,
    this.width = 110,
    this.deckPosition = 0,
    this.highlighted = false,
  });

  final double width;
  final int deckPosition;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => GrimoireCardBack(
    width: width,
    height: width / _aspectRatio,
    deckPosition: deckPosition,
    highlighted: highlighted,
    face: GrimoireBackFace.oracle,
  );
}

class _CardBackPainter extends CustomPainter {
  const _CardBackPainter({
    required this.colors,
    required this.face,
    required this.deckPosition,
    required this.highlighted,
  });

  final GrimoireColors colors;
  final GrimoireBackFace face;
  final int deckPosition;
  final bool highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    switch (face) {
      case GrimoireBackFace.tarot:
        _paintTarot(canvas, size);
      case GrimoireBackFace.oracle:
        _paintOracle(canvas, size);
    }
  }

  void _paintTarot(Canvas canvas, Size size) {
    final symbol = _BackSymbol.values[deckPosition % _BackSymbol.values.length];
    final rect = Offset.zero & size;
    final outline = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    final accent = colors.lilac;
    final trim = colors.gold;
    final center = rect.center;
    final w = size.width;

    canvas.drawRRect(outline, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(colors.surface, accent, .10)!,
          colors.surface,
          Color.lerp(colors.surface, colors.background, .35)!,
        ],
      ).createShader(rect));

    // Both borders are painted over the art and remain inside the hit box.
    final borderWidth = highlighted ? 2.5 : 1.5;
    canvas.drawRRect(outline.deflate(borderWidth / 2), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = accent.withValues(alpha: highlighted ? 1 : .85));
    canvas.drawRRect(outline.deflate(w * .045), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = trim.withValues(alpha: .5));

    final ornament = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = accent.withValues(alpha: .28);
    canvas.drawCircle(center, w * .30, ornament);
    canvas.drawCircle(center, w * .265,
        ornament..color = trim.withValues(alpha: .32));
    ornament.color = accent.withValues(alpha: .35);
    canvas.drawLine(Offset(center.dx, size.height * .20),
        center - Offset(0, w * .36), ornament);
    canvas.drawLine(center + Offset(0, w * .36),
        Offset(center.dx, size.height * .80), ornament);

    _drawSymbol(canvas, symbol, center, w * .46, accent);
    // Either side of the fan exposes a corner even when the center is covered.
    for (final x in [.14, .86]) {
      for (final y in [.11, .89]) {
        _drawSymbol(canvas, symbol, Offset(w * x, size.height * y),
            w * .17, accent);
      }
    }
    for (final y in [.15, .85]) {
      _drawSymbol(canvas, _BackSymbol.star,
          Offset(center.dx, size.height * y), w * .065, trim);
    }
  }

  /// O verso do Oráculo. Mesma família de cores e o mesmo peso de traço do
  /// Tarô; geometria deliberadamente outra, para o olho dizer "este é o outro
  /// baralho" antes de ler qualquer coisa. O Tarô lê na vertical (espinha e
  /// dois círculos); aqui tudo parte do centro, que é o que uma mensagem faz.
  void _paintOracle(Canvas canvas, Size size) {
    final mark = _OracleMark.values[deckPosition % _OracleMark.values.length];
    final rect = Offset.zero & size;
    final outline = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    final accent = colors.lilac;
    final trim = colors.gold;
    final center = rect.center;
    final w = size.width;

    // Gradiente VERTICAL puxando para o dourado: é a assinatura da frente do
    // Oráculo, e é o que amarra verso e frente no mesmo baralho.
    canvas.drawRRect(outline, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(colors.surface, trim, .12)!,
          colors.surface,
          Color.lerp(colors.surface, colors.background, .35)!,
        ],
      ).createShader(rect));

    // Trama de losangos no campo inteiro: preenche sem competir com a rosa.
    canvas.save();
    canvas.clipRRect(outline.deflate(w * .045));
    final trama = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .5
      ..color = accent.withValues(alpha: .10);
    for (var d = -size.height; d < size.width + size.height; d += w * .22) {
      canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), trama);
      canvas.drawLine(Offset(d, size.height), Offset(d + size.height, 0), trama);
    }
    canvas.restore();

    // Molduras TROCADAS em relação ao Tarô: fora o dourado, dentro o lilás.
    // Sem inventar cor nenhuma, a inversão já basta para separar os baralhos.
    final borderWidth = highlighted ? 2.5 : 1.5;
    canvas.drawRRect(outline.deflate(borderWidth / 2), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = trim.withValues(alpha: highlighted ? 1 : .85));
    canvas.drawRRect(outline.deflate(w * .045), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = accent.withValues(alpha: .5));

    // A rosa: doze raios curtos entre dois anéis finos, e um anel externo
    // pontilhado.
    final anel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = trim.withValues(alpha: .32);
    final interno = w * .16;
    final externo = w * .25;
    canvas.drawCircle(center, interno, anel);
    canvas.drawCircle(center, externo, anel);
    final raio = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: .35);
    final ponto = Paint()..color = trim.withValues(alpha: .30);
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
          center + direction * interno, center + direction * externo, raio);
      canvas.drawCircle(center + direction * (w * .30), .9, ponto);
    }

    _drawOracleMark(canvas, mark, center, w * .26, accent);
    // No leque as cartas se cobrem: o que sobra à vista é uma tira estreita
    // de borda. Por isso a marca se repete, pequena, nos quatro meios.
    for (final ponta in const [
      Offset(.10, .5), Offset(.90, .5), Offset(.5, .11), Offset(.5, .89),
    ]) {
      _drawOracleMark(canvas, mark,
          Offset(w * ponta.dx, size.height * ponta.dy), w * .14, trim);
    }
  }

  /// As quatro marcas do Oráculo dividem o mesmo espaço de 24 unidades e a
  /// mesma espessura de traço das seis do Tarô: os dois versos pesam igual.
  void _drawOracleMark(Canvas canvas, _OracleMark mark, Offset center,
      double diameter, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(diameter / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color.withValues(alpha: .14);

    switch (mark) {
      case _OracleMark.spiral:
        final spiral = Path()..moveTo(0, 0);
        for (var i = 1; i <= 48; i++) {
          final t = i / 48;
          final angle = t * math.pi * 4;
          final radius = t * 11;
          spiral.lineTo(math.cos(angle) * radius, math.sin(angle) * radius);
        }
        canvas.drawPath(spiral, stroke);
      case _OracleMark.flame:
        final flame = Path()
          ..moveTo(0, -12)
          ..cubicTo(6, -4, 9, -1, 9, 3)
          ..cubicTo(9, 8, 5, 11, 0, 11)
          ..cubicTo(-5, 11, -9, 8, -9, 3)
          ..cubicTo(-9, -1, -4, -3, 0, -12)
          ..close();
        canvas.drawPath(flame, fill);
        canvas.drawPath(flame, stroke);
        canvas.drawPath(Path()
          ..moveTo(0, -2)
          ..cubicTo(3, 1, 4, 3, 4, 6)
          ..cubicTo(4, 9, 2, 10, 0, 10)
          ..cubicTo(-2, 10, -4, 9, -4, 6)
          ..cubicTo(-4, 3, -3, 1, 0, -2)
          ..close(), stroke);
      case _OracleMark.drop:
        final drop = Path()
          ..moveTo(0, -12)
          ..quadraticBezierTo(9, -3, 9, 2)
          // Meia-volta por BAIXO (no sentido do relógio, que numa tela com o
          // y para baixo passa pelo pé): é a barriga da gota.
          ..arcToPoint(const Offset(-9, 2),
              radius: const Radius.circular(9), clockwise: true)
          ..quadraticBezierTo(-9, -3, 0, -12)
          ..close();
        canvas.drawPath(drop, fill);
        canvas.drawPath(drop, stroke);
        canvas.drawArc(
            Rect.fromCircle(center: const Offset(-2, 3), radius: 4.5),
            math.pi * .55, math.pi * .7, false, stroke);
      case _OracleMark.feather:
        canvas.drawPath(Path()
          ..moveTo(-5, 12)
          ..quadraticBezierTo(0, 3, 5, -11), stroke);
        final plume = Path()
          ..moveTo(5, -11)
          ..cubicTo(-4, -9, -8, -1, -3, 7)
          ..cubicTo(6, 4, 9, -4, 5, -11)
          ..close();
        canvas.drawPath(plume, fill);
        canvas.drawPath(plume, stroke);
        for (var i = 0; i < 3; i++) {
          final y = -5.0 + i * 3.5;
          canvas.drawLine(
              Offset(-2.0 - i, y + 2.5), Offset(3.0 - i * .8, y - .5), stroke);
        }
    }
    canvas.restore();
  }

  /// All six marks share a 24-unit drawing space and the same line weight.
  void _drawSymbol(Canvas canvas, _BackSymbol symbol, Offset center,
      double diameter, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(diameter / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color.withValues(alpha: .14);

    switch (symbol) {
      case _BackSymbol.moon:
        final moon = Path()
          ..moveTo(4, -10)
          ..cubicTo(-12, -11, -13, 9, 2, 10)
          ..cubicTo(6, 10, 9, 8, 10, 5)
          ..cubicTo(-1, 8, -5, -4, 4, -10)
          ..close();
        canvas.drawPath(moon, fill);
        canvas.drawPath(moon, stroke);
      case _BackSymbol.sun:
        canvas.drawCircle(Offset.zero, 5, fill);
        canvas.drawCircle(Offset.zero, 5, stroke);
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          final direction = Offset(math.cos(angle), math.sin(angle));
          canvas.drawLine(direction * 8, direction * 11, stroke);
        }
      case _BackSymbol.star:
        final star = Path();
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi / 4 - math.pi / 2;
          final radius = i.isEven ? 11.0 : 3.5;
          final point = Offset(math.cos(angle), math.sin(angle)) * radius;
          if (i == 0) {
            star.moveTo(point.dx, point.dy);
          } else {
            star.lineTo(point.dx, point.dy);
          }
        }
        star.close();
        canvas.drawPath(star, fill);
        canvas.drawPath(star, stroke);
      case _BackSymbol.eye:
        final eye = Path()
          ..moveTo(-11, 0)
          ..quadraticBezierTo(0, -13, 11, 0)
          ..quadraticBezierTo(0, 13, -11, 0)
          ..close();
        canvas.drawPath(eye, fill);
        canvas.drawPath(eye, stroke);
        canvas.drawCircle(Offset.zero, 3.5, stroke);
        canvas.drawCircle(Offset.zero, 1.2, Paint()..color = color);
      case _BackSymbol.crystal:
        final crystal = Path()
          ..moveTo(0, -11)
          ..lineTo(7, -5)
          ..lineTo(7, 6)
          ..lineTo(0, 11)
          ..lineTo(-7, 6)
          ..lineTo(-7, -5)
          ..close();
        canvas.drawPath(crystal, fill);
        canvas.drawPath(crystal, stroke);
        canvas.drawPath(Path()
          ..moveTo(0, -11)
          ..lineTo(-2, -4)
          ..lineTo(-2, 5)
          ..lineTo(0, 11)
          ..moveTo(-7, -5)
          ..lineTo(-2, -4)
          ..lineTo(7, -5)
          ..moveTo(-7, 6)
          ..lineTo(-2, 5)
          ..lineTo(7, 6), stroke);
      case _BackSymbol.leaf:
        canvas.drawPath(Path()
          ..moveTo(-5, 11)
          ..quadraticBezierTo(1, 3, 2, -10), stroke);
        for (final y in [-6.0, 2.0]) {
          final leaves = Path()
            ..moveTo(0, y + 3)
            ..quadraticBezierTo(-9, y + 3, -9, y - 4)
            ..quadraticBezierTo(-1, y - 4, 0, y + 3)
            ..moveTo(1, y)
            ..quadraticBezierTo(9, y + 1, 10, y - 6)
            ..quadraticBezierTo(3, y - 6, 1, y);
          canvas.drawPath(leaves, fill);
          canvas.drawPath(leaves, stroke);
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CardBackPainter oldDelegate) =>
      oldDelegate.colors != colors ||
      oldDelegate.face != face ||
      oldDelegate.deckPosition != deckPosition ||
      oldDelegate.highlighted != highlighted;
}
