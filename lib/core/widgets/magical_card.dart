import 'package:flutter/material.dart';
import '../theme/grimoire_colors.dart';

/// Card padrão do app. Três variantes, do mais discreto ao mais forte:
///
/// * `MagicalCard(...)` — a superfície neutra de sempre (conteúdo comum).
/// * `MagicalCard.accent(...)` — borda e brilho na cor de acento: destaca um
///   bloco sem gritar (ex.: o rito do momento, um convite).
/// * `MagicalCard.hero(...)` — gradiente do acento + sombra: a AÇÃO PRIMÁRIA
///   da tela. Use no máximo um por tela, senão o destaque perde o sentido.
class MagicalCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Cor de acento das variantes destacadas (null = card neutro).
  final Color? accent;

  /// Variante de destaque máximo (gradiente + sombra).
  final bool hero;

  const MagicalCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
  })  : accent = null,
        hero = false;

  const MagicalCard.accent({
    super.key,
    required this.child,
    required Color this.accent,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
  }) : hero = false;

  const MagicalCard.hero({
    super.key,
    required this.child,
    required Color this.accent,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
  }) : hero = true;

  @override
  State<MagicalCard> createState() => _MagicalCardState();
}

class _MagicalCardState extends State<MagicalCard> {
  // Encolher de leve no toque dá resposta tátil ao card — só quando ele é
  // tocável (tem onTap). Sem onTap, é uma superfície estática.
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accent;
    final hero = widget.hero;
    final padding = widget.padding;
    final margin = widget.margin;
    final child = widget.child;
    final onTap = widget.onTap;
    final onLongPress = widget.onLongPress;
    final tappable = onTap != null || onLongPress != null;
    final radius = BorderRadius.circular(hero ? 20 : 16);

    final Gradient? gradient = (hero && accentColor != null)
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                accentColor.withValues(alpha: 0.24),
                context.gc.surface,
              ),
              context.gc.surface,
            ],
          )
        : null;

    final borderColor = accentColor == null
        ? context.gc.surfaceBorder
        : accentColor.withValues(alpha: hero ? 0.85 : 0.5);

    final glow = context.gc.lilac;
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        // A sombra fica FORA do Material: dentro do Ink ela seria recortada.
        decoration: (hero && accentColor != null)
            ? BoxDecoration(
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.28),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              )
            : null,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          // Ink pinta o fundo NO Material, então o splash do toque aparece por
          // cima do gradiente em vez de ficar escondido atrás dele.
          child: Ink(
            decoration: BoxDecoration(
              color: gradient == null ? context.gc.surface : null,
              gradient: gradient,
              borderRadius: radius,
              border: Border.all(
                color: borderColor,
                width: hero ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: radius,
              // Brilho lilás do tema no toque (em vez do cinza padrão).
              splashColor: glow.withValues(alpha: 0.12),
              highlightColor: glow.withValues(alpha: 0.06),
              onHighlightChanged: tappable
                  ? (v) => setState(() => _pressed = v)
                  : null,
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
