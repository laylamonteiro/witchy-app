import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart' show ResponsiveAppBarTitle;
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/paged_reading.dart';
import '../../../../core/widgets/premium_locked_preview.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart'
    show showPremiumUpgradePaywall;
import '../../../../l10n/generated/app_localizations.dart';

/// "O que você ainda não viu" — o destino do toque no convite.
///
/// O toque NÃO abre a tabela de preços, e isso é o desenho, não um detalhe:
/// desejo primeiro, preço por último. Quem já quer desliza até o fim; quem
/// só espiou sai sabendo o que existe — e é isso que faz voltar.
///
/// A linguagem é a que já foi aprovada no Perfil Mágico: páginas que
/// deslizam com pontinhos embaixo ([PagedReading]), e o conteúdo de cada
/// uma mostrado pela FORMA — os nomes à vista, o texto sob véu
/// ([PremiumLockedPreview]).
///
/// Duas regras que esta tela respeita e que não devem ser afrouxadas:
///
/// - **Nada é gerado por IA aqui.** Os nomes são fixos, do l10n. As
///   degustações que custavam chamada foram removidas de propósito, e não
///   voltam por esta porta.
/// - **Nada de escassez inventada.** Sem contagem regressiva, sem "últimas
///   vagas", sem número inflado. O app vende introspecção; truque de
///   urgência destrói mais confiança do que converte.
class PaginaDeDescoberta extends StatelessWidget {
  const PaginaDeDescoberta({super.key});

  static Future<void> abrir(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PaginaDeDescoberta()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ResponsiveAppBarTitle(l10n.conviteDescobertaTitulo),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: PagedReading(pages: _pecas(context, l10n)),
          ),
        ),
      ),
    );
  }

  List<Widget> _pecas(BuildContext context, AppLocalizations l10n) {
    return [
      _Peca(
        titulo: l10n.conviteVislumbrePerfilTitulo,
        linha: l10n.conviteVislumbrePerfilLinha,
        dentro: [
          l10n.profileSectionEssenceTitle,
          l10n.profileSectionIntuitionTitle,
          l10n.profileSectionVoiceTitle,
          l10n.profileSectionLoveTitle,
          l10n.profileSectionPowerTitle,
          l10n.profileSectionTransformationTitle,
          l10n.profileSectionSpiritTitle,
          l10n.profileSectionAlliesTitle,
          l10n.profileSectionPracticeTitle,
          l10n.profileSectionShadowTitle,
        ],
        linhasPorSecao: 1,
      ),
      _Peca(
        titulo: l10n.conviteVislumbreConselheiroTitulo,
        linha: l10n.conviteVislumbreConselheiroLinha,
        dentro: [
          l10n.conviteDentroConselheiroA,
          l10n.conviteDentroConselheiroB,
          l10n.conviteDentroConselheiroC,
        ],
      ),
      _Peca(
        titulo: l10n.conviteVislumbreClimaTitulo,
        linha: l10n.conviteVislumbreClimaLinha,
        dentro: [
          l10n.conviteDentroClimaA,
          l10n.conviteDentroClimaB,
          l10n.conviteDentroClimaC,
        ],
      ),
      _Peca(
        titulo: l10n.conviteVislumbreEnciclopediaTitulo,
        linha: l10n.conviteVislumbreEnciclopediaLinha,
        dentro: [
          l10n.encyTabCrystals,
          l10n.encyTabHerbs,
          l10n.encyTabColors,
          l10n.encyTabMetals,
          l10n.encyTabGoddesses,
          l10n.encyTabElements,
          l10n.encyTabAltar,
        ],
        linhasPorSecao: 1,
      ),
      _Peca(
        titulo: l10n.conviteVislumbreLeiturasTitulo,
        linha: l10n.conviteVislumbreLeiturasLinha,
        dentro: [
          l10n.toolRunesTitle,
          l10n.toolOracleTitle,
          l10n.toolTarotTitle,
          l10n.toolPendulumTitle,
        ],
        linhasPorSecao: 1,
      ),
      const _Fechamento(),
    ];
  }
}

/// Uma feature Premium: o nome, uma linha do que ela entrega, e a forma do
/// que está atrás do cadeado.
class _Peca extends StatelessWidget {
  const _Peca({
    required this.titulo,
    required this.linha,
    required this.dentro,
    this.linhasPorSecao = 2,
  });

  final String titulo;
  final String linha;
  final List<String> dentro;
  final int linhasPorSecao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: tema.textTheme.headlineSmall?.copyWith(
            color: context.gc.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          linha,
          style: tema.textTheme.bodyMedium?.copyWith(
            color: context.gc.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        PremiumLockedPreview(
          titles: dentro,
          linesPerSection: linhasPorSecao,
          ctaLabel: AppLocalizations.of(context).premiumUnlock,
          // Decisão da dona (23/08): daqui o toque vai DIRETO ao paywall —
          // quem tocou já viu o que quer, e um desvio pela página de
          // Assinatura era um passo a mais antes do preço. A página de
          // Assinatura fica para as Configurações (gestão de conta).
          onCta: () => showPremiumUpgradePaywall(context),
        ),
      ],
    );
  }
}

/// A última página: o preço, e só aqui.
class _Fechamento extends StatelessWidget {
  const _Fechamento();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          l10n.conviteFechamentoTitulo,
          style: tema.textTheme.headlineSmall?.copyWith(
            color: context.gc.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.conviteFechamentoLinha,
          style: tema.textTheme.bodyMedium?.copyWith(
            color: context.gc.textSecondary,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => showPremiumUpgradePaywall(context),
            icon: const Icon(Icons.star),
            label: Text(l10n.premiumUnlock),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
              foregroundColor: context.gc.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
