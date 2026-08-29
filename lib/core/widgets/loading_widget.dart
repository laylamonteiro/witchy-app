import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/grimoire_colors.dart';

/// O loader oficial do Grimório: lua crescente lilás com estrelinhas que
/// acendem em sequência ao redor, no lugar do spinner genérico do Material.
///
/// A API é a mesma de sempre — `LoadingWidget(message: ...)` — porque as
/// telas só sabem passar a mensagem; toda a magia fica aqui dentro.
///
/// Sob "reduzir movimento" o laço nem começa: a lua fica parada e as
/// estrelas congelam a meia-luz — quem pediu calma continua sabendo que
/// algo carrega pelo contexto e pela mensagem embaixo.
class LoadingWidget extends StatefulWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  /// Um ciclo completo do céu: cada estrela acende e apaga dentro dele.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  /// As janelas de cada estrela dentro do ciclo. Tipadas como
  /// CurvedAnimation (e não Animation) porque também precisam ser
  /// liberadas no dispose.
  late final List<CurvedAnimation> _janelas = List.generate(
    _estrelas.length,
    (i) => CurvedAnimation(
      parent: _c,
      // Começos escalonados; a última janela fecha antes do fim do ciclo
      // para o repeat() não dar salto visível (nada de estroboscópio).
      curve: Interval(i * 0.16, i * 0.16 + 0.45),
    ),
  );

  /// Acende (rápido) e apaga (devagar) dentro da janela, sem nunca sumir
  /// de vez — estrela apagada por completo piscaria feito estrobo.
  static final Animatable<double> _pulso = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 0.25, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.0, end: 0.25)
          .chain(CurveTween(curve: Curves.easeIn)),
      weight: 60,
    ),
  ]);

  late final List<Animation<double>> _brilhos =
      _janelas.map(_pulso.animate).toList();

  /// null = primeira leitura de dependências ainda não aconteceu.
  bool? _reduzido;

  /// O laço infinito só liga depois de ler a preferência de acessibilidade
  /// (e nunca em quem pediu movimento reduzido) — ligar no initState também
  /// prenderia qualquer teste de widget num pumpAndSettle eterno.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduzido = MediaQuery.disableAnimationsOf(context);
    if (reduzido == _reduzido) return;
    _reduzido = reduzido;
    if (reduzido) {
      _c.stop();
      // Meio do ciclo: as estrelas param em brilhos desiguais, como um
      // céu de verdade — semi-acesas, nunca todas apagadas.
      _c.value = 0.5;
    } else {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    for (final janela in _janelas) {
      janela.dispose();
    }
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;

    // Decorativo para o leitor de tela: quando há mensagem, o Text abaixo
    // é quem fala; sem mensagem, um rótulo neutro cobre o silêncio.
    Widget arte = ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            children: [
              // A lua não gira nem pulsa — só as estrelas se movem.
              Center(
                child: CustomPaint(
                  size: const Size(38, 38),
                  painter: _LuaCrescentePainter(cor: gc.lilac),
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => Stack(
                    children: [
                      for (var i = 0; i < _estrelas.length; i++)
                        Align(
                          alignment: _estrelas[i].alinhamento,
                          child: Transform.scale(
                            scale: 0.7 + 0.3 * _brilhos[i].value,
                            child: CustomPaint(
                              size: Size.square(_estrelas[i].tamanho),
                              painter: _EstrelaPainter(
                                cor: (_estrelas[i].dourada
                                        ? gc.starYellow
                                        : gc.textSecondary)
                                    .withValues(
                                  alpha: 0.9 * _brilhos[i].value,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.message == null) {
      arte = Semantics(label: 'Carregando…', child: arte);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          arte,
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Posição, tamanho e cor de cada estrelinha ao redor da lua.
class _Estrela {
  final Alignment alinhamento;
  final double tamanho;
  final bool dourada;

  const _Estrela(this.alinhamento, this.tamanho, this.dourada);
}

/// Fora do círculo da lua para nenhuma estrela nascer atrás dela.
const List<_Estrela> _estrelas = [
  _Estrela(Alignment(-0.95, -0.6), 9, true),
  _Estrela(Alignment(0.8, -0.95), 10, false),
  _Estrela(Alignment(0.95, 0.55), 8, true),
  _Estrela(Alignment(-0.65, 0.95), 7, false),
];

/// Lua crescente: círculo cheio menos um círculo deslocado — o mesmo
/// truque de recorte das luas dos emblemas, sem SVG.
class _LuaCrescentePainter extends CustomPainter {
  final Color cor;

  const _LuaCrescentePainter({required this.cor});

  @override
  void paint(Canvas canvas, Size size) {
    final raio = size.width / 2;
    final centro = Offset(raio, raio);

    // Halo discreto atrás da lua — presença, não neon.
    canvas.drawCircle(
      centro,
      raio * 0.9,
      Paint()
        ..color = cor.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    final cheia = Path()
      ..addOval(Rect.fromCircle(center: centro, radius: raio * 0.8));
    final recorte = Path()
      ..addOval(
        Rect.fromCircle(
          center: centro.translate(raio * 0.42, -raio * 0.14),
          radius: raio * 0.68,
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, cheia, recorte),
      Paint()..color = cor,
    );
  }

  @override
  bool shouldRepaint(_LuaCrescentePainter oldDelegate) =>
      oldDelegate.cor != cor;
}

/// Estrela de 4 pontas (8 vértices alternando raio cheio e raio curto),
/// a mesma silhueta ✦ do rastro do Salem.
class _EstrelaPainter extends CustomPainter {
  final Color cor;

  const _EstrelaPainter({required this.cor});

  @override
  void paint(Canvas canvas, Size size) {
    final raio = size.width / 2;
    final centro = Offset(raio, raio);
    final caminho = Path();

    for (var i = 0; i < 8; i++) {
      // -pi/2 para a primeira ponta olhar para cima.
      final angulo = -math.pi / 2 + (math.pi / 4) * i;
      final distancia = i.isEven ? raio : raio * 0.4;
      final x = centro.dx + distancia * math.cos(angulo);
      final y = centro.dy + distancia * math.sin(angulo);
      if (i == 0) {
        caminho.moveTo(x, y);
      } else {
        caminho.lineTo(x, y);
      }
    }
    caminho.close();

    canvas.drawPath(caminho, Paint()..color = cor);
  }

  @override
  bool shouldRepaint(_EstrelaPainter oldDelegate) => oldDelegate.cor != cor;
}
