import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';

/// A névoa que leva a resposta da bola até o card.
///
/// O emblema de cada ferramenta VOA do card do hub para o cabeçalho da tela
/// quando ela abre. Quando o Conselheiro responde, o mesmo gesto carrega a
/// resposta: névoa, faíscas e letras soltas sobem da bola de cristal, cruzam
/// a tela e pousam no card — e só então o texto começa a ser escrito.
///
/// Vive no Overlay porque o voo atravessa a rolagem: a bola fica no alto e o
/// card embaixo, e nenhum dos dois pode recortar o caminho.
class AdvisorMistFlight extends StatefulWidget {
  const AdvisorMistFlight({
    super.key,
    required this.from,
    required this.to,
    required this.colors,
    this.fromAnchor = Alignment.center,
    this.toAnchor = Alignment.center,
    this.toNudge = Offset.zero,
  });

  /// De onde a névoa sai e onde ela pousa — por CHAVE, não por posição.
  ///
  /// A tela rola enquanto a névoa desce, então o começo do parágrafo muda de
  /// lugar a cada quadro. Guardar o ponto de saída congelaria o destino no
  /// lugar onde o texto estava quando o voo começou, e a névoa pousaria no
  /// vazio. Os dois retângulos são lidos na hora de pintar, depois do
  /// layout: o alvo se move, e a névoa acompanha.
  final GlobalKey from;
  final GlobalKey to;

  /// Onde, dentro de cada retângulo, ficam a saída e o pouso.
  final Alignment fromAnchor;
  final Alignment toAnchor;
  final Offset toNudge;

  final GrimoireColors colors;

  /// O voo inteiro. Sem pressa: a névoa desce devagar, e é ela que dá o
  /// tempo de quem lê chegar ao começo do parágrafo.
  static const Duration duration = Duration(milliseconds: 1900);

  /// Voa de [from] até [to] por cima de tudo e volta quando a névoa pousa.
  ///
  /// Sem Overlay, sem posição na tela ou com movimento reduzido, volta na
  /// hora: a digitação da resposta não pode depender de um enfeite.
  static Future<void> play({
    required BuildContext context,
    required GlobalKey from,
    required GlobalKey to,
    Alignment fromAnchor = Alignment.center,
    Alignment toAnchor = Alignment.center,
    Offset toNudge = Offset.zero,
  }) async {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null ||
        rectOf(from) == null ||
        rectOf(to) == null ||
        GrimoireMotion.reduced(context)) {
      return;
    }
    final colors = context.gc;
    final entrada = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: AdvisorMistFlight(
          from: from,
          to: to,
          fromAnchor: fromAnchor,
          toAnchor: toAnchor,
          toNudge: toNudge,
          colors: colors,
        ),
      ),
    );
    overlay.insert(entrada);
    try {
      await Future<void>.delayed(duration);
    } finally {
      if (entrada.mounted) entrada.remove();
    }
  }

  /// O retângulo global de quem [key] marca, ou null se ainda não foi medido.
  static Rect? rectOf(GlobalKey key) {
    final render = key.currentContext?.findRenderObject();
    if (render is! RenderBox || !render.hasSize) return null;
    return render.localToGlobal(Offset.zero) & render.size;
  }

  @override
  State<AdvisorMistFlight> createState() => _AdvisorMistFlightState();
}

class _AdvisorMistFlightState extends State<AdvisorMistFlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _voo = AnimationController(
      vsync: this, duration: AdvisorMistFlight.duration)
    ..forward();

  /// As letras são desenhadas por um `TextPainter` por partícula, medido uma
  /// vez: repetir a medida a cada quadro custaria mais que o voo inteiro.
  late final Map<int, TextPainter> _letras = {
    for (var i = 0; i < _particulas.length; i++)
      if (_particulas[i].tipo == _Sopro.letra)
        i: TextPainter(
          text: TextSpan(
            text: _particulas[i].letra,
            style: TextStyle(
              color: widget.colors.lilac,
              fontSize: 15 * _particulas[i].tamanho,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
  };

  @override
  void dispose() {
    for (final painter in _letras.values) {
      painter.dispose();
    }
    _voo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _voo,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _MistFlightPainter(
              progress: _voo.value,
              from: widget.from,
              to: widget.to,
              fromAnchor: widget.fromAnchor,
              toAnchor: widget.toAnchor,
              toNudge: widget.toNudge,
              colors: widget.colors,
              letras: _letras,
            ),
          ),
        ),
      );
}

/// O que sobe da bola: névoa, faísca e letra solta.
enum _Sopro { nevoa, faisca, letra }

@immutable
class _Particula {
  const _Particula({
    required this.tipo,
    required this.atraso,
    required this.lateral,
    required this.tamanho,
    required this.giro,
    required this.letra,
  });

  final _Sopro tipo;

  /// Fração do voo em que esta partícula parte: elas saem em fila, não em
  /// bloco, senão a névoa vira uma bolha só.
  final double atraso;

  /// O quanto ela abre para o lado no meio do caminho (-1 a 1).
  final double lateral;

  final double tamanho;
  final double giro;

  /// Letra sem sentido — o rascunho da resposta antes de virar palavra. Só
  /// letras latinas comuns: nada de glifo que falte no aparelho.
  final String letra;
}

/// Letras que todo aparelho desenha, sem acento e sem símbolo raro.
const String _alfabeto = 'aeioulmnrstvz';

/// Posições congeladas: semente fixa, para o voo ser sempre o mesmo.
///
/// A receita se repete a cada dez: metade é névoa, para o rastro ter corpo;
/// três letras, que são o rascunho da resposta; duas faíscas, que são o
/// brilho do cristal saindo junto.
final List<_Particula> _particulas = () {
  final random = math.Random(11);
  const receita = [
    _Sopro.nevoa,
    _Sopro.nevoa,
    _Sopro.letra,
    _Sopro.nevoa,
    _Sopro.faisca,
    _Sopro.nevoa,
    _Sopro.letra,
    _Sopro.nevoa,
    _Sopro.faisca,
    _Sopro.letra,
  ];
  return List.generate(32, (i) {
    return _Particula(
      tipo: receita[i % receita.length],
      atraso: (i / 32) * .55,
      lateral: random.nextDouble() * 2 - 1,
      tamanho: .7 + random.nextDouble() * .6,
      giro: (random.nextDouble() - .5) * math.pi,
      letra: _alfabeto[random.nextInt(_alfabeto.length)],
    );
  });
}();

/// Estrela de quatro pontas de raio 1, desenhada uma vez só.
final Path _estrela = () {
  final path = Path();
  for (var i = 0; i < 4; i++) {
    final ponta = i * math.pi / 2;
    final vale = ponta + math.pi / 4;
    final p = Offset(math.cos(ponta), math.sin(ponta));
    final v = Offset(math.cos(vale) * .32, math.sin(vale) * .32);
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(v.dx, v.dy);
  }
  return path..close();
}();

class _MistFlightPainter extends CustomPainter {
  const _MistFlightPainter({
    required this.progress,
    required this.from,
    required this.to,
    required this.fromAnchor,
    required this.toAnchor,
    required this.toNudge,
    required this.colors,
    required this.letras,
  });

  final double progress;
  final GlobalKey from;
  final GlobalKey to;
  final Alignment fromAnchor;
  final Alignment toAnchor;
  final Offset toNudge;
  final GrimoireColors colors;
  final Map<int, TextPainter> letras;

  static Offset _curva(Offset a, Offset c, Offset b, double t) {
    final u = 1 - t;
    return Offset(
      u * u * a.dx + 2 * u * t * c.dx + t * t * b.dx,
      u * u * a.dy + 2 * u * t * c.dy + t * t * b.dy,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Lidos AGORA, já com o layout deste quadro: a página está rolando por
    // baixo, e tanto a bola quanto o parágrafo mudaram de lugar desde o
    // quadro anterior.
    final origemRect = AdvisorMistFlight.rectOf(from);
    final destinoRect = AdvisorMistFlight.rectOf(to);
    if (origemRect == null || destinoRect == null) return;
    final origem = fromAnchor.withinRect(origemRect);
    final destino = toAnchor.withinRect(destinoRect) + toNudge;
    final distancia = (destino - origem).distance;
    if (distancia < 1) return;
    final base = (origemRect.shortestSide * .17).clamp(10.0, 26.0).toDouble();

    // O brilho nascendo DENTRO do cristal: acende no começo e se apaga
    // quando a névoa já está a caminho.
    final acende = Curves.easeOut.transform((progress / .28).clamp(0.0, 1.0));
    final apaga =
        1 - Curves.easeIn.transform(((progress - .32) / .34).clamp(0.0, 1.0));
    final nascendo = (acende * apaga).clamp(0.0, 1.0).toDouble();
    if (nascendo > 0) {
      final raio = base * (1.8 + 1.4 * acende);
      canvas.drawCircle(
        origem,
        raio,
        Paint()
          ..shader = RadialGradient(
            colors: [
              colors.textPrimary.withValues(alpha: .55 * nascendo),
              colors.lilac.withValues(alpha: .32 * nascendo),
              colors.lilac.withValues(alpha: 0),
            ],
            stops: const [0, .45, 1],
          ).createShader(Rect.fromCircle(center: origem, radius: raio)),
      );
    }

    for (var i = 0; i < _particulas.length; i++) {
      final p = _particulas[i];
      final t = ((progress - p.atraso) / (1 - p.atraso)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      // Sai do cristal e desce sem pressa: sem aceleração no meio, o rastro
      // fica legível em vez de virar um risco.
      final andar = Curves.easeInOutSine.transform(t);
      final controle = Offset(
        (origem.dx + destino.dx) / 2 + p.lateral * distancia * .22,
        (origem.dy + destino.dy) / 2 - distancia * .12,
      );
      final onde = _curva(origem, controle, destino, andar);
      // Entra e sai: nasce da bola e se desfaz ao pousar.
      final brilho = math.sin(math.pi * t).clamp(0.0, 1.0).toDouble();

      switch (p.tipo) {
        case _Sopro.nevoa:
          final largura = base * 2.6 * p.tamanho * (.7 + .6 * andar);
          final oval = Rect.fromCenter(
            center: onde,
            width: largura,
            height: largura * .62,
          );
          canvas.save();
          canvas.translate(oval.center.dx, oval.center.dy);
          canvas.scale(1, oval.height / oval.width);
          canvas.drawCircle(
            Offset.zero,
            oval.width / 2,
            Paint()
              ..shader = RadialGradient(
                colors: [
                  colors.lilac.withValues(alpha: .30 * brilho),
                  colors.lilac.withValues(alpha: .10 * brilho),
                  colors.lilac.withValues(alpha: 0),
                ],
                stops: const [0, .55, 1],
              ).createShader(Rect.fromCircle(
                  center: Offset.zero, radius: oval.width / 2)),
          );
          canvas.restore();
        case _Sopro.faisca:
          final raio = base * .32 * p.tamanho * (1 + .4 * brilho);
          canvas.save();
          canvas.translate(onde.dx, onde.dy);
          canvas.rotate(p.giro + andar * math.pi);
          canvas.scale(raio);
          canvas.drawPath(
            _estrela,
            Paint()
              ..color = Color.lerp(colors.gold, colors.textPrimary, .35)!
                  .withValues(alpha: .85 * brilho),
          );
          canvas.restore();
        case _Sopro.letra:
          final painter = letras[i];
          if (painter != null) {
            final caixa = Rect.fromCenter(
              center: onde,
              width: painter.width + 8,
              height: painter.height + 8,
            );
            canvas.saveLayer(
              caixa,
              Paint()..color = Color.fromRGBO(0, 0, 0, brilho),
            );
            canvas.translate(onde.dx, onde.dy);
            // Endireita ao chegar: a letra solta vira letra escrita.
            canvas.rotate(p.giro * (1 - andar));
            painter.paint(
                canvas, Offset(-painter.width / 2, -painter.height / 2));
            canvas.restore();
          }
      }
    }
  }

  @override
  // O voo repinta a cada quadro: além do avanço, os dois retângulos se
  // movem com a rolagem, e eles só são lidos dentro do [paint].
  bool shouldRepaint(_MistFlightPainter old) => true;
}
