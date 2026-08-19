import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../features/auth/presentation/widgets/premium_blur_widget.dart';
import '../theme/grimoire_colors.dart';

/// Degustação de conteúdo Premium: a amostra REAL em cima, uma continuação
/// desfocada embaixo e o convite para desbloquear o resto.
///
/// FAIL-CLOSED, como o resto dos gates: o que fica sob o blur é o
/// placeholder ([kPremiumPlaceholderText]), nunca o conteúdo verdadeiro —
/// blur é cosmético (leitores de tela leem, e o texto fica parcialmente
/// legível). A amostra visível deve ser gerada JÁ no tamanho da degustação
/// (ex.: só as 2 primeiras frases), para o conteúdo completo nem existir no
/// aparelho.
class TeaserReveal extends StatelessWidget {
  /// A amostra genuína, totalmente visível (texto real, sem blur).
  final Widget sample;

  /// Convite exibido no botão; default: "Seja Premium" localizado.
  final String? ctaLabel;

  /// Chamado no toque do convite; default: abre o paywall Premium padrão.
  final VoidCallback? onCta;

  const TeaserReveal({
    super.key,
    required this.sample,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sample,
        const SizedBox(height: 6),
        // Continuação desfocada + véu em gradiente: comunica "tem mais",
        // sem expor nada de verdade.
        Stack(
          children: [
            ExcludeSemantics(
              child: ClipRRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Text(
                    kPremiumPlaceholderText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.gc.background.withValues(alpha: 0),
                      context.gc.background.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton.icon(
            onPressed: onCta ?? () => showPremiumUpgradePaywall(context),
            icon: const Icon(Icons.star, size: 18),
            label: Text(ctaLabel ?? l10n.premiumBePremium),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
              foregroundColor: context.gc.onPrimary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
