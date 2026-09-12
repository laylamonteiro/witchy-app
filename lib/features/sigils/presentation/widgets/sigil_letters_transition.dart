import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../data/models/sigil_wheel_model.dart';

/// A intenção virando letras: todas as letras normalizadas aparecem, as
/// repetidas se dissipam e as que ficam se organizam lado a lado.
///
/// Quem decide o que fica é [SigilWheel.textToSigilSequence] — a animação só
/// mostra a regra acontecendo. Com movimento reduzido, a linha final já
/// aparece pronta. O resultado é sempre [letters], em qualquer velocidade.
class SigilLettersTransition extends StatefulWidget {
  const SigilLettersTransition({
    super.key,
    required this.intention,
    required this.letters,
    this.tileSize = 48,
  });

  /// A intenção escrita pela pessoa.
  final String intention;

  /// As letras que sobraram (Sigil.processedLetters), o estado final.
  final String letters;

  final double tileSize;

  /// Quanto tempo as repetidas levam para sumir; o resto assenta depois.
  static const Duration dissipate = GrimoireMotion.reveal;

  @override
  State<SigilLettersTransition> createState() => _SigilLettersTransitionState();
}

class _SigilLettersTransitionState extends State<SigilLettersTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transform = AnimationController(
    vsync: this,
    duration: SigilLettersTransition.dissipate + GrimoireMotion.state,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (GrimoireMotion.reduced(context)) {
      _transform.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _transform.forward();
    }
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letters = SigilWheel.normalizedLetters(widget.intention);
    final kept = SigilWheel.keptIndexes(widget.intention);
    final total = _transform.duration!.inMilliseconds;
    final fadeEnd =
        (SigilLettersTransition.dissipate.inMilliseconds / total).clamp(0.0, 1.0);
    return Semantics(
      label: widget.letters,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _transform,
          builder: (context, _) {
            final gone = Interval(0, fadeEnd, curve: GrimoireMotion.exit)
                .transform(_transform.value);
            final settle =
                Interval(fadeEnd, 1, curve: GrimoireMotion.enter)
                    .transform(_transform.value);
            return Wrap(
              key: const ValueKey('sigil-letters'),
              alignment: WrapAlignment.center,
              runSpacing: 8,
              children: [
                for (var i = 0; i < letters.length; i++)
                  _LetterTile(
                    key: ValueKey('sigil-letter-$i'),
                    letter: letters[i],
                    size: widget.tileSize,
                    // A repetida encolhe até não ocupar espaço: as que ficam
                    // se aproximam pelo próprio layout.
                    presence: kept.contains(i) ? 1 : 1 - gone,
                    settled: kept.contains(i) ? settle : 0,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    super.key,
    required this.letter,
    required this.size,
    required this.presence,
    required this.settled,
  });

  final String letter;
  final double size;

  /// 1 enquanto a letra existe, 0 quando se dissipou por completo.
  final double presence;

  /// 0 a 1 conforme a letra assenta na linha final.
  final double settled;

  @override
  Widget build(BuildContext context) {
    final colors = context.gc;
    final width = (size + 8) * presence;
    return SizedBox(
      width: width,
      height: size,
      child: presence <= 0
          ? const SizedBox.shrink()
          : Center(
              child: Opacity(
                opacity: presence.clamp(0.0, 1.0).toDouble(),
                child: Transform.scale(
                  scale: 0.92 + 0.08 * settled + 0.08 * (1 - presence),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color.lerp(colors.lilac, colors.starYellow, settled)!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: colors.starYellow,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
