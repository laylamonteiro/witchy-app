import 'package:flutter/material.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../data/models/tarot_card_model.dart';

/// Renderiza uma carta: usa a imagem do baralho quando o asset existir e
/// cai num placeholder estilizado no tema enquanto as imagens não forem
/// adicionadas em assets/tarot/<deck>/.
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

/// Verso da carta (para o embaralhamento/revelação).
class TarotCardBack extends StatelessWidget {
  final double width;

  const TarotCardBack({super.key, this.width = 110});

  @override
  Widget build(BuildContext context) {
    final height = width / TarotCardView.aspectRatio;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.gc.lilac.withValues(alpha: 0.5)),
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
        child: Text('✦', style: TextStyle(
          color: context.gc.starYellow,
          fontSize: width * 0.3,
        )),
      ),
    );
  }
}
