import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/rune_model.dart';
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
        title: ResponsiveAppBarTitle(AppLocalizations.of(context)!.runesListTitle),
        backgroundColor: context.gc.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Introdução
            MagicalCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('ᚠ', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.runesAbout,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.runesAboutText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.runesExplore,
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
              AppLocalizations.of(context)!.runesElderFuthark,
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
                childAspectRatio:
                    1.0, // Aumentado de 1.2 para 1.0 para dar mais altura
              ),
              itemCount: runes.length,
              itemBuilder: (context, index) {
                final rune = runes[index];
                return _buildRuneCard(context, rune);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRuneCard(BuildContext context, Rune rune) {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Símbolo da runa
              Text(
                rune.symbol,
                style: TextStyle(
                  fontSize: 42, // Reduzido de 48 para 42
                  color: context.gc.starYellow,
                ),
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
      ),
    );
  }
}
