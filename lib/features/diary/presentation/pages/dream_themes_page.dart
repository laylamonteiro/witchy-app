import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/data_sources/dream_themes_data.dart';

/// Biblioteca de significados dos sonhos: temas e simbolismos oníricos
/// (conteúdo gratuito, acessível pelo hub de Sonhos nas Ferramentas).
class DreamThemesPage extends StatelessWidget {
  const DreamThemesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context)!.dreamMeaningsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              AppLocalizations.of(context)!.diaryDreamThemesIntro,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
          ),
          // Grade de 2 colunas com altura por conteúdo: cada par de cards
          // usa IntrinsicHeight para igualar a altura sem cortar o texto
          // (evita overflow e o "…" quando o título/subtítulo quebra linha).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (int i = 0; i < dreamThemes.length; i += 2) ...[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _DreamThemeCard(theme: dreamThemes[i])),
                        const SizedBox(width: 12),
                        Expanded(
                          child: i + 1 < dreamThemes.length
                              ? _DreamThemeCard(theme: dreamThemes[i + 1])
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
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
