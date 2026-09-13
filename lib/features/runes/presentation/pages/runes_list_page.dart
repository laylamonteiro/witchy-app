import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/living_emblem.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/rune_model.dart';
import '../widgets/rune_art.dart';
import '../widgets/rune_stone_view.dart';
import 'rune_detail_page.dart';

/// Tela de lista de runas
class RunesListPage extends StatelessWidget {
  const RunesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final runes = Rune.getAllRunes();

    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).runesListTitle),
        backgroundColor: context.gc.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StaggeredEntrance(
          children: [
            const LivingEmblem(emblem: SectionEmblem.runes),
            const SizedBox(height: 12),
            // Introdução
            MagicalCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Fehu escrita a caractere era o último glifo cru da
                      // tela de Runas: no aparelho sem fonte para o bloco
                      // Runic, o cabeçalho da própria lista de runas abria
                      // com um quadradinho vazio. Mesmo corpo de 32 e mesma
                      // cor de texto de antes — só que desenhada.
                      //
                      // Nome e caractere saem do catálogo já carregado
                      // acima, e não de uma cópia escrita aqui: copiados, o
                      // caractere voltava a ser o ÚNICO do bloco Runic em
                      // código executável de todo o `lib/` — a frente que
                      // existiu para matar glifo cru reintroduzindo um na
                      // própria linha que escreveu. De quebra, a primeira
                      // runa do Futhark passa a ser a que o catálogo diz.
                      RuneMark(
                        name: runes.first.name,
                        symbol: runes.first.symbol,
                        fontSize: 32,
                        color: context.gc.textPrimary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).runesAbout,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).runesAboutText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).runesExplore,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Título da lista
            Text(
              AppLocalizations.of(context).runesElderFuthark,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Grid de runas
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // Mais alta que larga, e a conta é esta: a 390dp de tela a
                // célula tem 173 de lado, e a coluna precisa de 76 (pedra) +
                // 8 + 22 (nome) + 4 + 32 (duas linhas de palavra-chave) + 24
                // de respiro = 166. Quadrada não sobrava nada, e a
                // palavra-chave era cortada no meio da letra — com fonte
                // grande, cortava o nome também.
                childAspectRatio: 0.82,
              ),
              itemCount: runes.length,
              itemBuilder: (context, index) {
                final rune = runes[index];
                return _buildRuneCard(context, rune, index);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRuneCard(BuildContext context, Rune rune, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RuneDetailPage(rune: rune),
          ),
        );
      },
      child: MagicalCard(
        margin: EdgeInsets.zero,
        // O respiro é do cartão, não de um Padding dentro dele: o
        // MagicalCard já traz 16 por padrão, e o Padding interno somava
        // outros 12 em cima e embaixo. Eram 56dp de margem vertical numa
        // célula de 173 — o que sobrava não cabia a palavra-chave.
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // A mesma pedra da tiragem: a runa está gravada nela, não
            // solta no meio do card.
            RuneStoneView(
              size: 76,
              deckPosition: index,
              symbol: rune.symbol,
              runeName: rune.name,
            ),
            const SizedBox(height: 8),

            // Nome da runa
            Text(
              rune.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.gc.lilac,
                    fontSize: 16, // Tamanho fixo para consistência
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Primeira palavra-chave
            if (rune.keywords.isNotEmpty)
              Flexible(
                child: Text(
                  rune.keywords.first,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                        fontSize: 12, // Tamanho fixo
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // Permitir até 2 linhas
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
