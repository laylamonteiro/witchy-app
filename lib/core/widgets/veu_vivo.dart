import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/grimoire_colors.dart';

/// O véu que cobre o conteúdo Premium — e que se mexe.
///
/// O que havia era um retângulo embaçado e parado. Cinco telas inteiras
/// feitas de blocos cinzentos empilhados: nada dizia que havia algo VIVO do
/// outro lado, e sem isso o véu vira só uma parede.
///
/// Aqui ele ganha três coisas, na mesma língua de movimento do resto do app
/// (respiração ~3s do [LivingEmblem], da BreathingMoon e da BreathingBadge):
///
/// - **um brilho que atravessa**, devagar, como luz passando atrás de uma
///   cortina — é o que diz "tem coisa aqui";
/// - **uma respiração no embaçado**, quase imperceptível, para o bloco
///   nunca parecer uma imagem estática;
/// - **reação ao toque**: encostar afasta o véu por um instante e o brilho
///   corre mais forte, depois ele se fecha de novo.
///
/// O que o toque NÃO faz é mostrar conteúdo real, e isso é regra, não
/// detalhe de implementação: o que existe debaixo do véu é o texto de
/// enfeite ([child]), porque para quem não tem acesso o conteúdo verdadeiro
/// nem chega a ser gerado. Espiar mostra luz, nunca palavra — o
/// fail-closed do [PremiumLockedPreview] continua de pé.
///
/// Congela num quadro bonito quando o sistema pede "reduzir movimento".
class VeuVivo extends StatefulWidget {
  const VeuVivo({
    super.key,
    required this.child,
    this.embacamento = 6,
    this.aoEspiar,
  });

  /// O que fica sob o véu. SEMPRE conteúdo de enfeite — ver a nota acima.
  final Widget child;

  /// Quanto o véu embaça em repouso.
  final double embacamento;

  /// Chamado quando a pessoa encosta no véu — para quem quiser registrar o
  /// interesse (o motor de ofertas, por exemplo).
  final VoidCallback? aoEspiar;

  @override
  State<VeuVivo> createState() => _VeuVivoState();
}

class _VeuVivoState extends State<VeuVivo> with TickerProviderStateMixin {
  /// O brilho que atravessa, e a respiração do embaçado: um controller só,
  /// em laço. 3,4s é o tempo da respiração do resto do app.
  late final AnimationController _passagem = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );

  /// O afastar do véu ao toque. Separado porque é um gesto, não um laço.
  late final AnimationController _espiada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void dispose() {
    _passagem.dispose();
    _espiada.dispose();
    super.dispose();
  }

  void _espiar() {
    if (_reduzido) return;
    widget.aoEspiar?.call();
    // `forward(from: 0)` e não `reset()+forward()`: encostar de novo no meio
    // da animação reinicia o gesto em vez de empilhar duas.
    _espiada.forward(from: 0);
  }

  bool get _reduzido => MediaQuery.disableAnimationsOf(context);

  @override
  Widget build(BuildContext context) {
    // O laço só nasce no build porque `disableAnimationsOf` precisa de
    // context — e ele PARA quando a pessoa liga "reduzir movimento" com o
    // app aberto, não só quando abre a tela já com a opção ligada. Mesmo
    // par de guardas do StarfieldBackground.
    if (!_reduzido && !_passagem.isAnimating) {
      _passagem.repeat();
    } else if (_reduzido && _passagem.isAnimating) {
      _passagem.stop();
    }

    final cor = context.gc.lilac;

    // A exclusão de semântica cobre o véu INTEIRO, e não só o texto de
    // enfeite lá dentro: para um leitor de tela não há nada aqui — nem o
    // texto, que é enfeite, nem o espiar, que só mostra luz. Quem tem ação
    // de verdade é o convite embaixo.
    return ExcludeSemantics(
      child: GestureDetector(
        onTap: _espiar,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([_passagem, _espiada]),
          child: widget.child,
          builder: (context, filho) {
            // Quanto o véu está afastado agora. Meia volta de seno: sai de
            // 0, chega a 1 no meio do gesto e volta a 0 — a cortina que
            // levanta e cai, sem degrau nas pontas.
            final espiando =
                _reduzido ? 0.0 : math.sin(_espiada.value * math.pi);

            // Respiração do embaçado: ±0,8 em volta do valor de repouso, no
            // mesmo compasso do brilho que atravessa.
            final respiro = _reduzido
                ? 0.0
                : 0.8 * math.sin(_passagem.value * 2 * math.pi);

            final sigma = (widget.embacamento + respiro - espiando * 3.2)
                .clamp(1.6, 14.0);

            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                    child: filho,
                  ),
                  // O brilho que atravessa. Positioned.fill + IgnorePointer:
                  // ele é atmosfera, nunca alvo de toque.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _BrilhoQuePassa(
                          avanco: _reduzido ? 0.34 : _passagem.value,
                          cor: cor,
                          forca: _reduzido ? 0.10 : 0.16 + espiando * 0.34,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Uma faixa de luz diagonal atravessando o véu da esquerda para a direita.
class _BrilhoQuePassa extends CustomPainter {
  _BrilhoQuePassa({
    required this.avanco,
    required this.cor,
    required this.forca,
  });

  /// 0 a 1 — onde a faixa está no percurso.
  final double avanco;
  final Color cor;

  /// Opacidade máxima da faixa.
  final double forca;

  @override
  void paint(Canvas canvas, Size size) {
    // A faixa entra fora da tela e sai fora da tela: o percurso é 2x a
    // largura, começando em -largura. Assim não há "pop" nas pontas.
    final centro = -size.width + avanco * size.width * 3;
    final largura = size.width * 0.55;

    final pincel = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cor.withValues(alpha: 0),
          cor.withValues(alpha: forca),
          cor.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(centro - largura / 2, 0, largura, size.height),
      );

    canvas.drawRect(Offset.zero & size, pincel);
  }

  @override
  bool shouldRepaint(_BrilhoQuePassa anterior) =>
      anterior.avanco != avanco ||
      anterior.forca != forca ||
      anterior.cor != cor;
}
