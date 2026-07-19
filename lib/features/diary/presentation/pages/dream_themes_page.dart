import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/data_sources/dream_themes_data.dart';

/// Lista visual de temas e simbolismos oníricos (conteúdo gratuito).
class DreamThemesPage extends StatelessWidget {
  const DreamThemesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Temas Oníricos'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              'Cada símbolo carrega muitas leituras possíveis. Explore os '
              'temas mais comuns e compare com o que você sentiu no sonho.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: dreamThemes.length,
            itemBuilder: (context, index) {
              final theme = dreamThemes[index];
              return _DreamThemeCard(theme: theme);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DreamThemeCard extends StatelessWidget {
  final DreamTheme theme;

  const _DreamThemeCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.gc.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DreamThemeDetailPage(theme: theme),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.gc.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(theme.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                theme.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.gc.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                theme.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.gc.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detalhe de um tema onírico com as diferentes leituras possíveis.
class DreamThemeDetailPage extends StatelessWidget {
  final DreamTheme theme;

  const DreamThemeDetailPage({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle('${theme.emoji} ${theme.title}'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          MagicalCard(
            child: Text(
              theme.summary,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.gc.lilac,
                  ),
            ),
          ),
          for (final reading in theme.readings)
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reading.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reading.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          MagicalCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🌙 ', style: TextStyle(color: context.gc.starYellow)),
                Expanded(
                  child: Text(
                    theme.reflection,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
