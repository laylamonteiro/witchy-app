import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import 'dream_interpretation_page.dart';
import 'dream_themes_page.dart';

/// Hub de Sonhos na aba Ferramentas: interpretação pelo Conselheiro
/// Místico (Premium, gate dentro do fluxo) e a biblioteca gratuita de
/// Significados dos Sonhos.
class DreamToolsPage extends StatelessWidget {
  const DreamToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(l10n.toolDreamsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  const Text('🌙', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    l10n.dreamToolsIntro,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            _optionCard(
              context,
              emoji: '🔮',
              title: l10n.dreamInterpretMyDream,
              description: l10n.dreamInterpretMyDreamDesc,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DreamInterpretationPage(),
                ),
              ),
            ),
            _optionCard(
              context,
              emoji: '📖',
              title: l10n.dreamMeaningsTitle,
              description: l10n.dreamMeaningsDesc,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DreamThemesPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: MagicalCard(
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.softWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.softWhite.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.gc.lilac,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
