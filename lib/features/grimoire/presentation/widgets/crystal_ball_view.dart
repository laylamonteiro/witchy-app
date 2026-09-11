import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';

/// A geometria da cena da bola, em função da largura pintada.
///
/// Vive fora do pintor de propósito: o que faz a bola POUSAR no pedestal é
/// relação entre duas elipses, e isso se confere por cálculo — sem olhos e
/// sem imagem de referência. O desenho anterior punha o pedestal inteiro
/// ABAIXO da esfera (topo do pedestal em .885 da largura, fundo da esfera em
/// .88), então ele nunca encostava na bola e lia como uma sombra solta.
@immutable
class CrystalBallGeometry {
  const CrystalBallGeometry(this.width);

  /// Largura pintada. A caixa do widget é [width] x [height].
  final double width;

  /// A caixa era 1.1 x a largura porque o pedestal antigo descia até 1.095.
  /// O pedestal novo termina em 1.014, e os 8 px mortos que sobravam embaixo
  /// afastavam a bola do título do card sem motivo nenhum.
  double get height => width * 1.05;
  double get radius => width * .42;
  Offset get center => Offset(width / 2, width * .46);

  Rect get sphere => Rect.fromCircle(center: center, radius: radius);

  /// O pedestal em que a bola descansa.
  ///
  /// O centro da elipse fica praticamente no ponto mais baixo da esfera, então
  /// o arco de trás do pedestal passa POR TRÁS da bola (é pintado antes) e as
  /// duas silhuetas se cruzam a ~61% do raio: a bola afunda no pedestal em vez
  /// de pairar sobre ele. A largura sobe para 86% da largura da esfera — mais
  /// estreito que a bola, como um pedestal deve ser, mas longe dos 75% de
  /// antes, que faziam a elipse parecer um disco à parte.
  Rect get pedestal => Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 1.01),
        width: radius * 1.72,
        height: radius * .62,
      );

  /// Mancha que escurece o pedestal em volta do ponto de apoio.
  Rect get contactShadow => Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius),
        width: radius * 1.35,
        height: radius * .42,
      );

  /// Reflexo especular no quadrante superior esquerdo da esfera.
  Rect get glint => Rect.fromCenter(
        center: center + Offset(-radius * .35, -radius * .45),
        width: radius * .5,
        height: radius * .25,
      );
}

/// As cores da cena, derivadas da paleta ativa.
///
/// Fica pública pelo mesmo motivo da geometria: são SEIS paletas e uma delas é
/// CLARA. Toda escolha que depende do claro/escuro — o que escurece, o que
/// clareia — só se confere comparando luminância, e olhar o tema padrão não
/// confere nada. No desenho anterior o reflexo era `textPrimary` puro, que no
/// tema claro é quase preto: um brilho especular que escurecia a bola.
@immutable
class CrystalBallPalette {
  CrystalBallPalette(GrimoireColors colors)
      : shade = colors.isDark ? colors.background : colors.textPrimary,
        shadeAlpha = colors.isDark ? .5 : .3,
        specular = colors.isDark ? colors.textPrimary : colors.onPrimary,
        pedestalTop = Color.lerp(colors.surface, colors.gold, .30)!,
        // O aro de ouro a .6 sobre card escuro era um anel amarelo nítido — era
        // ele que fazia o pedestal ler como um disco à parte.
        pedestalRim = colors.gold.withValues(alpha: .35),
        sphereTop = Color.lerp(colors.surface, colors.lilac, .55)!,
        sphereMid = Color.lerp(colors.surface, colors.lilac, .25)!,
        sphereBottom = Color.lerp(colors.background, colors.lilac, .25)!,
        sphereRim = colors.lilac.withValues(alpha: .7),
        // A névoa CLAREIA a esfera, então ela segue o mesmo par das outras
        // cores: no tema claro, textPrimary é quase preto e a névoa viraria
        // fuligem dentro da bola em vez de brilho.
        mist = colors.isDark ? colors.textPrimary : colors.onPrimary;

  /// O que escurece nesta paleta (sombra de contato e pé do pedestal).
  final Color shade;
  final double shadeAlpha;

  /// O que clareia nesta paleta (reflexo especular).
  final Color specular;

  final Color pedestalTop;
  final Color pedestalRim;
  final Color sphereTop;
  final Color sphereMid;
  final Color sphereBottom;
  final Color sphereRim;
  final Color mist;

  /// Pé do pedestal: o topo escurecido pelo [shade] da paleta.
  ///
  /// Não dá para usar `background` direto como segunda parada do degradê: no
  /// tema claro ele é MAIS CLARO que o pedestal, e a peça acabava iluminada
  /// por baixo — luz vindo do chão, volume invertido.
  Color get pedestalBottom => Color.lerp(pedestalTop, shade, .40)!;
}

/// Pinta [oval] com uma queda radial que acompanha a ELIPSE inteira.
///
/// `RadialGradient.createShader` usa `radius * rect.shortestSide` — o MENOR
/// lado. Numa elipse achatada isso é uma armadilha silenciosa: a sombra de
/// contato é 3,2x mais larga que alta e o reflexo é 2x, então o degradê
/// chegava a alpha 0 a 31% e a 50% da meia-largura e o resto da forma saía
/// transparente. O que aparecia na tela era um disquinho no meio de cada
/// elipse — a "sombra de apoio" com um terço da largura declarada e o brilho
/// especular MENOR e mais fraco que a elipse chapada que ele substituiu.
///
/// Achatando o canvas, o degradê vira um círculo desenhado sobre um círculo:
/// a queda chega a zero exatamente na borda da elipse, em toda direção.
void _drawRadialOval(Canvas canvas, Rect oval, List<Color> colors,
    [List<double>? stops]) {
  final raio = oval.width / 2;
  canvas.save();
  canvas.translate(oval.center.dx, oval.center.dy);
  canvas.scale(1, oval.height / oval.width);
  canvas.drawCircle(
    Offset.zero,
    raio,
    Paint()
      ..shader = RadialGradient(colors: colors, stops: stops).createShader(
          Rect.fromCircle(center: Offset.zero, radius: raio)),
  );
  canvas.restore();
}

/// The advisor's crystal ball drawn in the active palette: base, sphere,
/// reflections and mist. While [active] the mist swirls for as long as the
/// real request lasts; otherwise, and under reduced motion, it rests on the
/// still frame. The loop is a ticker, so TickerMode pauses it off-screen.
class CrystalBallView extends StatefulWidget {
  const CrystalBallView({super.key, this.size = 120, this.active = false});

  final double size;
  final bool active;

  @override
  State<CrystalBallView> createState() => _CrystalBallViewState();
}

class _CrystalBallViewState extends State<CrystalBallView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _mist = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400));
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = GrimoireMotion.reduced(context);
    _sync();
  }

  @override
  void didUpdateWidget(CrystalBallView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _sync();
  }

  void _sync() {
    if (widget.active && !_reduced) {
      if (!_mist.isAnimating) _mist.repeat();
    } else {
      _mist.stop();
      _mist.value = 0;
    }
  }

  @override
  void dispose() {
    _mist.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedContainer(
      duration: _reduced ? Duration.zero : GrimoireMotion.state,
      curve: GrimoireMotion.enter,
      width: widget.size,
      height: widget.size * 1.05,
      child: AnimatedBuilder(
        animation: _mist,
        builder: (context, _) => CustomPaint(
          painter: _CrystalBallPainter(
            colors: context.gc,
            phase: _mist.value,
            active: widget.active,
          ),
        ),
      ),
    ),
  );
}

class _CrystalBallPainter extends CustomPainter {
  const _CrystalBallPainter({required this.colors, required this.phase, required this.active});

  final GrimoireColors colors;
  final double phase;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final g = CrystalBallGeometry(size.width);
    final p = CrystalBallPalette(colors);
    final r = g.radius;
    final center = g.center;

    // Pedestal. É pintado ANTES da esfera de propósito: o arco de trás fica
    // escondido atrás dela, que é o que faz a bola pousar em vez de flutuar.
    final base = g.pedestal;
    canvas.drawOval(base, Paint()
      ..shader = LinearGradient(
        // Vertical. O degradê de antes não declarava begin/end, então corria
        // na horizontal — num disco visto de cima isso não dá volume nenhum,
        // dá metade dourada e metade quase invisível.
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [p.pedestalTop, p.pedestalBottom],
      ).createShader(base));
    canvas.drawOval(base.deflate(.5), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = p.pedestalRim);

    // Sombra de contato: escurece o pedestal em volta do ponto de apoio. Sem
    // MaskFilter — degradê radial rende igual no CanvasKit da web e no
    // Impeller do Android. O recorte no pedestal é cinto de segurança da
    // geometria (hoje a elipse da sombra já cabe inteira dentro dele, e o teste
    // trava isso): se alguém alargar a mancha, ela para na borda do pedestal em
    // vez de manchar o card.
    canvas.save();
    canvas.clipPath(Path()..addOval(base));
    _drawRadialOval(canvas, g.contactShadow, [
      p.shade.withValues(alpha: p.shadeAlpha),
      p.shade.withValues(alpha: 0.0),
    ]);
    canvas.restore();

    // Sphere.
    final sphere = g.sphere;
    canvas.drawCircle(center, r, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.35, -.4),
        radius: .95,
        colors: [p.sphereTop, p.sphereMid, p.sphereBottom],
        stops: const [0, .55, 1],
      ).createShader(sphere));

    // Mist: three arcs drifting with the phase; still and faint when idle.
    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));
    for (var i = 0; i < 3; i++) {
      final angle = phase * math.pi * 2 + i * 2.1;
      final drift = Offset(math.cos(angle) * r * .25, math.sin(angle * .7) * r * .2);
      final alpha = active ? .22 + .12 * math.sin(angle) : .10;
      canvas.drawOval(
        Rect.fromCenter(center: center + drift, width: r * (1.3 - i * .2), height: r * .55),
        Paint()
          ..color = p.mist.withValues(alpha: alpha.clamp(0.0, 1.0).toDouble())
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * .18),
      );
    }
    canvas.restore();

    // Rim and highlight.
    canvas.drawCircle(center, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = p.sphereRim);

    // O reflexo era uma elipse de cor chapada, de borda dura: lia como adesivo
    // colado na bola. Agora ele apaga do centro para fora.
    _drawRadialOval(
      canvas,
      g.glint,
      [
        p.specular.withValues(alpha: .45),
        p.specular.withValues(alpha: .14),
        p.specular.withValues(alpha: 0.0),
      ],
      const [0, .55, 1],
    );
  }

  @override
  bool shouldRepaint(_CrystalBallPainter old) =>
      old.phase != phase || old.active != active || old.colors != colors;
}
