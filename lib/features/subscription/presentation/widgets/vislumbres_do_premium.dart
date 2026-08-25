import '../../../../l10n/generated/app_localizations.dart';

/// Uma coisa que o Premium abre, dita em duas linhas.
///
/// É o material do estado "longe" do cartão de convite: quem não está perto
/// de limite nenhum não quer saber de contagem, quer saber do que existe.
class VislumbreDoPremium {
  const VislumbreDoPremium({required this.titulo, required this.linha});

  final String titulo;
  final String linha;
}

/// O catálogo, na ordem em que roda.
///
/// Cada entrada nomeia uma feature REAL e diz o que ela entrega — nada de
/// promessa vaga, e nada que exija gerar conteúdo por IA para ser mostrado.
/// A mesma matéria alimenta a página de descoberta, onde cada uma vira uma
/// peça inteira.
List<VislumbreDoPremium> vislumbresDoPremium(AppLocalizations l10n) => [
      VislumbreDoPremium(
        titulo: l10n.conviteVislumbrePerfilTitulo,
        linha: l10n.conviteVislumbrePerfilLinha,
      ),
      VislumbreDoPremium(
        titulo: l10n.conviteVislumbreErasTitulo,
        linha: l10n.conviteVislumbreErasLinha,
      ),
      VislumbreDoPremium(
        titulo: l10n.conviteVislumbreClimaTitulo,
        linha: l10n.conviteVislumbreClimaLinha,
      ),
      VislumbreDoPremium(
        titulo: l10n.conviteVislumbreEnciclopediaTitulo,
        linha: l10n.conviteVislumbreEnciclopediaLinha,
      ),
      VislumbreDoPremium(
        titulo: l10n.conviteVislumbreLeiturasTitulo,
        linha: l10n.conviteVislumbreLeiturasLinha,
      ),
      VislumbreDoPremium(
        titulo: l10n.conviteVislumbreConselheiroTitulo,
        linha: l10n.conviteVislumbreConselheiroLinha,
      ),
    ];
