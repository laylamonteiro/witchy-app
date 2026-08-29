import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../data/models/tarot_card_model.dart';

/// Renderiza uma carta: usa a imagem do baralho quando o asset existir e
/// cai num placeholder estilizado no tema enquanto as imagens não forem
/// adicionadas em `assets/tarot/<deck>/`.
class TarotCardView extends StatelessWidget {
  final TarotCard card;
  final TarotDeck deck;
  final bool reversed;
  final double width;

  const TarotCardView({
    super.key,
    required this.card,
    this.deck = TarotDeck.riderWaite,
    this.reversed = false,
    this.width = 110,
  });

  static const double aspectRatio = 0.585; // proporção clássica de tarot

  @override
  Widget build(BuildContext context) {
    final height = width / aspectRatio;
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        card.assetPath(deck),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) =>
            _Placeholder(card: card, width: width, height: height),
      ),
    );

    return RotatedBox(
      quarterTurns: reversed ? 2 : 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.gc.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: context.gc.lilac.withValues(alpha: 0.18),
              blurRadius: 10,
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final TarotCard card;
  final double width;
  final double height;

  const _Placeholder({
    required this.card,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(context.gc.surface, context.gc.lilac, 0.14)!,
            context.gc.surface,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.displayNumber,
            style: TextStyle(
              color: context.gc.lilac,
              fontSize: width * 0.16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: width * 0.06),
          Text(card.suit.emoji,
              style: TextStyle(fontSize: width * 0.24)),
          SizedBox(height: width * 0.06),
          Text(
            card.name,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.gc.textPrimary,
              fontSize: width * 0.11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Verso da carta (para o embaralhamento/revelação). Usa a arte oficial do
/// baralho com fallback estilizado.
class TarotCardBack extends StatelessWidget {
  final double width;
  final TarotDeck deck;

  const TarotCardBack({
    super.key,
    this.width = 110,
    this.deck = TarotDeck.riderWaite,
  });

  @override
  Widget build(BuildContext context) {
    final height = width / TarotCardView.aspectRatio;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        TarotCard.backAssetPath(deck),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: context.gc.lilac.withValues(alpha: 0.5)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(context.gc.surface, context.gc.lilac, 0.25)!,
                context.gc.surface,
              ],
            ),
          ),
          child: Center(
            child: Text('✦',
                style: TextStyle(
                  color: context.gc.starYellow,
                  fontSize: width * 0.3,
                )),
          ),
        ),
      ),
    );
  }
}

/// Vira a carta em 3D no eixo Y quando [revealed] passa a verdadeiro: a
/// primeira metade do giro mostra o [back] até ficar de lado; ali o filho
/// troca e a [front] completa o giro com contra-rotação — sem espelhar.
///
/// O [caption] (rótulo da posição) reserva o próprio espaço desde o início e
/// só ganha opacidade na segunda metade do giro, para a mesa não pular de
/// altura na revelação.
///
/// Carta invertida continua por conta da própria frente (rotação em Z dentro
/// do [TarotCardView]) — este widget gira somente em Y. Com "reduzir
/// movimento" ativo, a frente aparece pronta, sem giro.
class TarotFlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Widget? caption;
  final bool revealed;

  /// Espera antes de começar o giro — o stagger das tiragens múltiplas.
  final Duration delay;

  const TarotFlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.revealed,
    this.caption,
    this.delay = Duration.zero,
  });

  @override
  State<TarotFlipCard> createState() => _TarotFlipCardState();
}

class _TarotFlipCardState extends State<TarotFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: GrimoireMotion.reveal);

  /// Espera do stagger. Timer cancelável (não Future.delayed): carta que sai
  /// da árvore antes da vez dela não pode acordar um controller descartado.
  Timer? _espera;

  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    // Montou com a mesa já revelada (rebuild da página aberta): estado final
    // direto — o giro pertence ao EVENTO de revelar, não à tela existir.
    if (widget.revealed) _c.value = 1.0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = GrimoireMotion.reduced(context);
    // Preferência ligada com giro (ou espera) em andamento: congela no
    // estado coerente com o momento, sem terminar a animação.
    if (_reduced && (_c.isAnimating || _espera != null)) {
      _espera?.cancel();
      _espera = null;
      _c.value = widget.revealed ? 1.0 : 0.0;
    }
  }

  @override
  void didUpdateWidget(TarotFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revealed == oldWidget.revealed) return;
    _espera?.cancel();
    _espera = null;
    if (!widget.revealed) {
      // Mesa nova: volta ao verso sem cerimônia.
      _c.value = 0.0;
      return;
    }
    if (_reduced) {
      _c.value = 1.0;
      return;
    }
    if (widget.delay == Duration.zero) {
      _c.forward(from: 0);
    } else {
      _espera = Timer(widget.delay, () {
        _espera = null;
        if (mounted) _c.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _espera?.cancel();
    _c.dispose();
    super.dispose();
  }

  /// Face visível no instante [t]: verso de 0° a 90° e, dali em diante, a
  /// frente com contra-rotação (t·π − π) — assim ela chega legível, nunca
  /// espelhada, e o ângulo jamais encosta em π (a matriz degeneraria).
  Widget _face(double t) {
    if (t <= 0.0) return widget.back;
    if (t >= 1.0) return widget.front;
    final mostraFrente = t >= 0.5;
    final angulo = mostraFrente ? t * pi - pi : t * pi;
    return Transform(
      alignment: Alignment.center,
      // setEntry(3, 2) dá a perspectiva sutil — sem ela o giro parece um
      // achatamento, não uma carta física virando.
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0015)
        ..rotateY(angulo),
      child: mostraFrente ? widget.front : widget.back,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.caption,
      builder: (context, caption) {
        final t = Curves.easeInOutCubic.transform(_c.value);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _face(t),
            if (caption != null) ...[
              const SizedBox(height: 6),
              // O rótulo acompanha a segunda metade do giro: ausente com o
              // verso, inteiro quando a frente assenta.
              Opacity(
                opacity: ((t - 0.5) * 2).clamp(0.0, 1.0).toDouble(),
                child: caption,
              ),
            ],
          ],
        );
      },
    );
  }
}
