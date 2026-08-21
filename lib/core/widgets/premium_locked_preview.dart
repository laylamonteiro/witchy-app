import 'dart:ui';

import 'package:flutter/material.dart';

import '../../features/auth/presentation/widgets/premium_blur_widget.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/grimoire_colors.dart';

/// O que uma leitura Premium teria dito — os TÍTULOS à vista, o conteúdo sob
/// véu, e o convite embaixo.
///
/// Existe porque barrar a pessoa na porta ("isto é Premium") não vende: ela
/// nunca chega a saber o que estava comprando. Aqui ela percorre a
/// funcionalidade inteira, chega ao resultado e vê a FORMA do que a leitura
/// entregaria — cada seção pelo nome — com o texto embaçado. A degustação
/// deixa de ser um parágrafo gerado e passa a ser o mapa do que existe atrás
/// do cadeado.
///
/// Dois princípios que este widget respeita:
///
/// - **Não custa uma chamada de IA.** Os títulos são fixos, do l10n: quem
///   não comprou não faz o app gastar geração nenhuma.
/// - **Fail-closed.** O que fica sob o blur é o placeholder, nunca o texto
///   real — blur é cosmético (o leitor de tela leria tudo, e o texto fica
///   parcialmente legível). Para quem não tem acesso, o conteúdo verdadeiro
///   não chega nem a ser gerado.
class PremiumLockedPreview extends StatelessWidget {
  const PremiumLockedPreview({
    super.key,
    required this.titles,
    this.intro,
    this.ctaLabel,
    this.onCta,
    this.linesPerSection = 2,
  });

  /// Os nomes das seções que a leitura completa traria, na ordem.
  final List<String> titles;

  /// Uma linha de contexto acima da lista (opcional).
  final String? intro;

  /// Rótulo do convite; sem ele, o "Seja Premium" do app.
  final String? ctaLabel;

  /// Toque do convite; sem ele, abre o paywall padrão.
  final VoidCallback? onCta;

  /// Quantas linhas embaçadas fingem o corpo de cada seção.
  final int linesPerSection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (intro != null) ...[
          Text(
            intro!,
            style: tema.textTheme.bodySmall?.copyWith(
              color: context.gc.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
        ],
        for (var i = 0; i < titles.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lock,
                size: 15,
                color: context.gc.textSecondary.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titles[i],
                  style: tema.textTheme.titleSmall?.copyWith(
                    color: context.gc.lilac,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _CorpoSobVeu(linhas: linesPerSection),
          if (i < titles.length - 1) const SizedBox(height: 16),
        ],
        const SizedBox(height: 18),
        Center(
          child: ElevatedButton.icon(
            onPressed: onCta ?? () => showPremiumUpgradePaywall(context),
            icon: const Icon(Icons.star, size: 18),
            label: Text(ctaLabel ?? l10n.premiumBePremium),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
              foregroundColor: context.gc.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

/// As linhas embaçadas que ocupam o lugar do texto — placeholder, nunca o
/// conteúdo real (ver a nota de fail-closed no topo do arquivo).
class _CorpoSobVeu extends StatelessWidget {
  const _CorpoSobVeu({required this.linhas});

  final int linhas;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Text(
            kPremiumPlaceholderText,
            maxLines: linhas,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.gc.softWhite,
              height: 1.55,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
