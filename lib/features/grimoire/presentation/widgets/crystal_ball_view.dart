import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';

/// A geometria da cena da bola, em função da largura da ilustração.
///
/// A bola é uma ILUSTRAÇÃO (a esfera lilás sobre a base dourada, com fundo
/// transparente). O que o código pinta são as camadas em volta e por dentro
/// dela: a aura atrás, a névoa e as estrelas recortadas no círculo da esfera,
/// as faíscas orbitando por fora. Para isso a cena precisa saber ONDE a esfera
/// está dentro da imagem — medido pixel a pixel na ilustração original
/// (691 × 1004): centro em (.497, .459) da largura, raio .456 da largura.
///
/// Vive fora do pintor de propósito: a contenção (a órbita mais larga cabe na
/// caixa? a aura encosta na borda?) se confere por cálculo, sem olhos.
@immutable
class CrystalBallGeometry {
  const CrystalBallGeometry(this.width);

  /// O asset da ilustração (WebP com alpha, 512 px de largura).
  static const String asset = 'assets/images/conselheiro/bola_de_cristal.webp';

  /// Altura / largura da ilustração original.
  static const double imageAspect = 1004 / 691;

  /// Largura da ilustração pintada.
  final double width;

  /// Margem em volta da ilustração, para aura e faíscas. A caixa do widget é
  /// a ilustração mais esta margem de cada lado: pintar fora da caixa não é
  /// opção, o card recortaria.
  double get halo => width * .22;

  double get imageHeight => width * imageAspect;

  Rect get imageRect => Rect.fromLTWH(halo, halo, width, imageHeight);

  /// A esfera de cristal, medida na ilustração.
  Offset get center => imageRect.topLeft + Offset(width * .497, width * .459);
  double get radius => width * .456;
  Rect get sphere => Rect.fromCircle(center: center, radius: radius);

  /// Aura lilás que respira atrás da esfera.
  double get auraRadius => radius * 1.42;

  /// O semieixo mais longo das órbitas das faíscas, e o tamanho delas.
  double get sparkOrbitMax => radius * 1.45;
  double get sparkSize => radius * .10;

  /// A caixa que o widget reserva.
  Size get box => Size(width + 2 * halo, imageHeight + 2 * halo);

  /// Onde o centro da esfera cai DENTRO da caixa do widget, em fração dela.
  ///
  /// A mesma fração em qualquer tamanho, porque tudo aqui deriva da largura.
  /// É daqui que a névoa do Conselheiro sai: o meio da caixa cairia no anel
  /// dourado da base, e o brilho tem de nascer de dentro do cristal.
  Alignment get sphereAnchor => Alignment(
        center.dx / box.width * 2 - 1,
        center.dy / box.height * 2 - 1,
      );

  /// Com o teclado aberto a bola encolhe para 64 e as faíscas saem: nesse
  /// tamanho elas viram poeira e a órbita ocuparia espaço que é do campo.
  bool get showsSparks => width >= 100;
}

/// As cores das camadas pintadas, derivadas da paleta ativa.
///
/// A esfera é a ilustração — lilás em qualquer tema —, então o que se pinta
/// POR CIMA dela (névoa, estrelas) clareia sempre, e não segue a regra
/// claro/escuro das paletas. A aura e as faíscas seguem a paleta: são elas
/// que amarram a ilustração ao tema.
@immutable
class CrystalBallPalette {
  CrystalBallPalette(GrimoireColors colors)
      : aura = colors.lilac,
        spark = colors.gold,
        sparkCore = Color.lerp(colors.gold, _luz, .35)!,
        nebula = colors.pink,
        star = _luz,
        mist = _luz;

  /// A luz que clareia a esfera lilás, em qualquer paleta.
  static const Color _luz = Color(0xFFF6F4FF);

  final Color aura;
  final Color spark;
  final Color sparkCore;
  final Color nebula;
  final Color star;
  final Color mist;
}

/// Pinta [oval] com uma queda radial que acompanha a ELIPSE inteira.
///
/// `RadialGradient.createShader` usa `radius * rect.shortestSide` — o MENOR
/// lado. Numa elipse achatada o degradê chegaria a alpha 0 na meia-altura e
/// o resto da forma sairia transparente: um disquinho no meio de cada elipse.
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

/// Uma faísca dourada em órbita elíptica em volta da esfera.
@immutable
class _Spark {
  const _Spark({
    required this.phase0,
    required this.rx,
    required this.ry,
    required this.period,
    required this.twinklePeriod,
    required this.twinklePhase,
    required this.size,
  });

  final double phase0;

  /// Semieixos da órbita, em fração do raio da esfera.
  final double rx;
  final double ry;

  /// Segundos por volta e por piscada. Dividem o ciclo de 60 s do loop.
  final double period;
  final double twinklePeriod;
  final double twinklePhase;

  /// Tamanho, em fração de [CrystalBallGeometry.sparkSize].
  final double size;
}

/// Um ponto de estrela dentro do cristal.
@immutable
class _Star {
  const _Star({
    required this.dx,
    required this.dy,
    required this.twinklePeriod,
    required this.twinklePhase,
    required this.size,
    required this.fourPointed,
  });

  /// Posição em fração do raio, a partir do centro da esfera.
  final double dx;
  final double dy;
  final double twinklePeriod;
  final double twinklePhase;

  /// Em fração do raio da esfera.
  final double size;
  final bool fourPointed;
}

/// Períodos que dividem 60 s: o loop dá a volta sem salto em nenhuma camada.
const List<double> _orbitPeriods = [10, 12, 15];
const List<double> _twinklePeriods = [1, 1.2, 1.5, 2, 2.5, 3];

/// Posições congeladas: sementes fixas, para a cena não mudar entre quadros,
/// rebuilds ou aparelhos.
final List<_Spark> _sparks = () {
  final random = math.Random(7);
  return List.generate(7, (i) {
    return _Spark(
      phase0: random.nextDouble() * math.pi * 2,
      rx: 1.15 + random.nextDouble() * .30,
      ry: .60 + random.nextDouble() * .50,
      period: _orbitPeriods[i % _orbitPeriods.length],
      twinklePeriod: _twinklePeriods[random.nextInt(_twinklePeriods.length)],
      twinklePhase: random.nextDouble() * math.pi * 2,
      size: .7 + random.nextDouble() * .6,
    );
  });
}();

final List<_Star> _stars = () {
  final random = math.Random(21);
  return List.generate(14, (i) {
    final angle = random.nextDouble() * math.pi * 2;
    final distance = math.sqrt(random.nextDouble()) * .78;
    return _Star(
      dx: math.cos(angle) * distance,
      dy: math.sin(angle) * distance * .85 - .08,
      twinklePeriod: _twinklePeriods[random.nextInt(_twinklePeriods.length)],
      twinklePhase: random.nextDouble() * math.pi * 2,
      size: .018 + random.nextDouble() * .02,
      fourPointed: i % 3 == 0,
    );
  });
}();

/// Estrela de quatro pontas de raio 1, reaproveitada em toda faísca: o
/// caminho é construído uma vez e só transladado/escalado por quadro.
final Path _unitStar = () {
  final path = Path();
  for (var i = 0; i < 4; i++) {
    final outer = i * math.pi / 2;
    final inner = outer + math.pi / 4;
    final tip = Offset(math.cos(outer), math.sin(outer));
    final notch = Offset(math.cos(inner) * .32, math.sin(inner) * .32);
    if (i == 0) {
      path.moveTo(tip.dx, tip.dy);
    } else {
      path.lineTo(tip.dx, tip.dy);
    }
    path.lineTo(notch.dx, notch.dy);
  }
  return path..close();
}();

/// The advisor's crystal ball: the illustration with living layers around
/// and inside it — a breathing aura, drifting mist, twinkling stars and
/// golden sparks in orbit. One animation, always on; [active] no longer
/// changes the look (the request's wait is told by the page, not the ball).
/// A change of [pulseToken] makes the aura flare once — the answer arriving.
/// Under reduced motion the scene rests on a still frame. The loop is a
/// ticker, so TickerMode pauses it off-screen.
class CrystalBallView extends StatefulWidget {
  const CrystalBallView({
    super.key,
    this.size = 120,
    this.active = false,
    this.pulseToken,
  });

  /// Largura da ilustração; a caixa do widget é maior (ver
  /// [CrystalBallGeometry.box]).
  final double size;

  /// Mantido por compatibilidade: a tela ainda informa a espera, mas a bola
  /// se move igual com ou sem requisição em voo.
  final bool active;

  /// Quando muda (para algo não nulo), a aura pulsa uma vez.
  final Object? pulseToken;

  @override
  State<CrystalBallView> createState() => _CrystalBallViewState();
}

class _CrystalBallViewState extends State<CrystalBallView>
    with TickerProviderStateMixin {
  static const int _loopSeconds = 60;

  late final AnimationController _loop = AnimationController(
      vsync: this, duration: const Duration(seconds: _loopSeconds));
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
  bool _reduced = false;

  ImageStream? _stream;
  ImageStreamListener? _listener;
  ImageInfo? _image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = GrimoireMotion.reduced(context);
    _sync();
    _resolveImage();
  }

  @override
  void didUpdateWidget(CrystalBallView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulseToken != null &&
        widget.pulseToken != oldWidget.pulseToken &&
        !_reduced) {
      _pulse.forward(from: 0);
    }
  }

  void _sync() {
    if (_reduced) {
      _loop.stop();
      // Um quadro bonito: névoa deslocada, estrelas em pontos diferentes.
      _loop.value = .3;
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  /// A ilustração é resolvida com a configuração local (densidade certa) e
  /// entregue ao pintor como `ui.Image`: as camadas internas ficam ENTRE a
  /// imagem e as faíscas, o que um `Image.asset` empilhado não permitiria.
  void _resolveImage() {
    final stream = const AssetImage(CrystalBallGeometry.asset)
        .resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stopListening();
    final listener = ImageStreamListener(_onImage, onError: (_, __) {
      // Sem asset (testes, bundle incompleto) a cena segue só com as camadas.
    });
    _listener = listener;
    _stream = stream;
    stream.addListener(listener);
  }

  void _onImage(ImageInfo info, bool synchronousCall) {
    if (!mounted) {
      info.dispose();
      return;
    }
    final previous = _image;
    if (synchronousCall) {
      _image = info;
    } else {
      setState(() => _image = info);
    }
    previous?.dispose();
  }

  void _stopListening() {
    final stream = _stream;
    final listener = _listener;
    if (stream != null && listener != null) stream.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _stopListening();
    _image?.dispose();
    _loop.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = CrystalBallGeometry(widget.size).box;
    return ExcludeSemantics(
      child: AnimatedContainer(
        duration: _reduced ? Duration.zero : GrimoireMotion.state,
        curve: GrimoireMotion.enter,
        width: box.width,
        height: box.height,
        child: AnimatedBuilder(
          animation: Listenable.merge([_loop, _pulse]),
          builder: (context, _) => CustomPaint(
            painter: _CrystalBallPainter(
              colors: context.gc,
              time: _loop.value * _loopSeconds,
              pulse: _pulse.value,
              image: _image?.image,
              width: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}

class _CrystalBallPainter extends CustomPainter {
  const _CrystalBallPainter({
    required this.colors,
    required this.time,
    required this.pulse,
    required this.image,
    required this.width,
  });

  final GrimoireColors colors;

  /// Segundos dentro do ciclo de 60 s.
  final double time;

  /// 0 → 1 durante o pulso da chegada da resposta; 0 em repouso.
  final double pulse;

  final ui.Image? image;
  final double width;

  static double _wave(double time, double period, [double phase = 0]) =>
      math.sin(2 * math.pi * time / period + phase);

  @override
  void paint(Canvas canvas, Size size) {
    final g = CrystalBallGeometry(width);
    final p = CrystalBallPalette(colors);
    final r = g.radius;
    final c = g.center;

    final breath = .5 + .5 * _wave(time, 3.75);
    final heat = .55 + .45 * breath;
    final flare = math.sin(math.pi * pulse.clamp(0.0, 1.0).toDouble());

    // Aura, atrás de tudo. Transparente dentro da esfera (a ilustração é
    // opaca ali), acesa logo fora do aro e apagando até a borda.
    final auraRadius = g.auraRadius * (1 + .03 * breath);
    final edge = r / auraRadius;
    canvas.drawCircle(
      c,
      auraRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            p.aura.withValues(alpha: .10),
            p.aura.withValues(alpha: .10),
            p.aura.withValues(
                alpha: (.30 * heat + .08 + .30 * flare).clamp(0.0, 1.0).toDouble()),
            p.aura.withValues(alpha: 0),
          ],
          stops: [0, edge * .97, edge * 1.02, 1],
        ).createShader(Rect.fromCircle(center: c, radius: auraRadius)),
    );

    // Faíscas da metade de trás da órbita: a ilustração cobre as que passam
    // atrás da esfera, e as que sobram ficam mais apagadas, como devem.
    if (g.showsSparks) _paintSparks(canvas, g, p, behind: true);

    final illustration = image;
    if (illustration != null) {
      paintImage(
        canvas: canvas,
        rect: g.imageRect,
        image: illustration,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
    }

    // Por dentro do cristal: nebulosa, névoa e estrelas, recortadas um pouco
    // aquém do aro para não pintar sobre o contorno da ilustração.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r * .96)));

    _drawRadialOval(
      canvas,
      Rect.fromCenter(
          center: c - Offset(0, r * .05), width: r * 1.56, height: r * 1.32),
      [
        p.nebula.withValues(alpha: .10 + .22 * heat),
        p.aura.withValues(alpha: .05 + .10 * heat),
        p.aura.withValues(alpha: 0),
      ],
      const [0, .6, 1],
    );

    for (var i = 0; i < 3; i++) {
      final angle = 2 * math.pi * time / 6 + i * 2.1;
      final drift = Offset(
        math.cos(angle) * r * .25,
        math.sin(angle * .7) * r * .18 - r * .08,
      );
      final alpha = (.20 + .10 * math.sin(angle)).clamp(0.0, 1.0).toDouble();
      _drawRadialOval(
        canvas,
        Rect.fromCenter(
            center: c + drift, width: r * (1.44 - i * .2), height: r * .64),
        [p.mist.withValues(alpha: alpha), p.mist.withValues(alpha: 0)],
      );
    }

    // O conjunto de estrelas gira uma volta por ciclo; cada uma pisca no seu
    // ritmo. As de baixo são puladas: ali estão as garras douradas da base.
    final rotation = 2 * math.pi * time / _CrystalBallViewState._loopSeconds;
    final cosR = math.cos(rotation);
    final sinR = math.sin(rotation);
    for (final star in _stars) {
      final x = c.dx + (star.dx * cosR - star.dy * sinR) * r;
      final y = c.dy + (star.dx * sinR + star.dy * cosR) * r;
      if (y > c.dy + r * .55) continue;
      final twinkle =
          .5 + .5 * _wave(time, star.twinklePeriod, star.twinklePhase);
      final paint = Paint()
        ..color = p.star.withValues(alpha: (.35 + .6 * twinkle).clamp(0.0, 1.0).toDouble());
      if (star.fourPointed) {
        _drawStar(canvas, Offset(x, y), r * star.size * (1 + .5 * twinkle),
            star.twinklePhase, paint);
      } else {
        canvas.drawCircle(Offset(x, y), r * star.size * .45, paint);
      }
    }
    canvas.restore();

    if (g.showsSparks) _paintSparks(canvas, g, p, behind: false);
  }

  void _paintSparks(Canvas canvas, CrystalBallGeometry g, CrystalBallPalette p,
      {required bool behind}) {
    final r = g.radius;
    final c = g.center;
    for (final spark in _sparks) {
      final theta = spark.phase0 + 2 * math.pi * time / spark.period;
      final isBehind = math.sin(theta) < 0;
      if (isBehind != behind) continue;
      final bob = r * .05 * _wave(time, 7.5, spark.twinklePhase);
      final position = Offset(
        c.dx + math.cos(theta) * r * spark.rx,
        c.dy + math.sin(theta) * r * spark.ry - bob,
      );
      final twinkle =
          .5 + .5 * _wave(time, spark.twinklePeriod, spark.twinklePhase);
      final size = g.sparkSize * spark.size;
      if (behind) {
        _drawStar(
          canvas,
          position,
          size * .8,
          theta,
          Paint()
            ..color = p.sparkCore
                .withValues(alpha: (.2 + .4 * twinkle).clamp(0.0, 1.0).toDouble()),
        );
        continue;
      }
      // Brilho radial dourado embaixo da faísca da frente.
      _drawRadialOval(
        canvas,
        Rect.fromCircle(center: position, radius: size * 2.2),
        [
          p.spark.withValues(alpha: (.30 * twinkle).clamp(0.0, 1.0).toDouble()),
          p.spark.withValues(alpha: 0),
        ],
      );
      _drawStar(
        canvas,
        position,
        size * (1 + .6 * twinkle),
        theta,
        Paint()
          ..color = p.sparkCore
              .withValues(alpha: (.35 + .6 * twinkle).clamp(0.0, 1.0).toDouble()),
      );
    }
  }

  void _drawStar(
      Canvas canvas, Offset at, double radius, double angle, Paint paint) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(angle);
    canvas.scale(radius);
    canvas.drawPath(_unitStar, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CrystalBallPainter old) =>
      old.time != time ||
      old.pulse != pulse ||
      old.image != image ||
      old.width != width ||
      old.colors != colors;
}
