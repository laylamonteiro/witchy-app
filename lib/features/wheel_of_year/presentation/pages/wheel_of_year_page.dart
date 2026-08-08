import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/wheel_of_year_provider.dart';
import '../../data/models/sabbat_model.dart';
import '../../../../core/widgets/living_emblem.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../encyclopedia/presentation/widgets/related_link.dart';
import '../../../guided_rituals/data/models/guided_rituals_data.dart';
import '../../../guided_rituals/presentation/pages/guided_ritual_page.dart';

class WheelOfYearPage extends StatelessWidget {
  final bool embedded;

  const WheelOfYearPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final content = Consumer<WheelOfYearProvider>(
      builder: (context, provider, _) {
        final sabbats = provider.getAllSabbats();
        final nextSabbat = provider.getNextSabbat();
        final dateFormat = DateFormat('dd/MM/yyyy');

        return SingleChildScrollView(
          child: StaggeredEntrance(
            children: [
              // Destaque do próximo sabbat no padrão das outras abas —
              // título, o SÍMBOLO da época como emblema vivo, nome, data e
              // contagem, direto na página (sem card em volta).
              if (nextSabbat != null) ...[
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).wheelNextSabbat,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                LivingEmblem.custom(
                  customArt: Text(
                    nextSabbat.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
                Text(
                  nextSabbat.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  nextSabbat.type.southernHemisphereDate,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Center(
                  child: _buildDaysUntilChip(
                    context,
                    nextSabbat.daysUntil(DateTime.now()),
                  ),
                ),
                const SizedBox(height: 12),
              ] else
                const SectionEmblemHeader.custom(
                  customArt: Text('🎡', style: TextStyle(fontSize: 64)),
                ),

              // Lista de todos os Sabbats
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).wheelCalendar,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    ...sabbats.map((sabbat) => _buildSabbatItem(
                          context,
                          sabbat,
                          dateFormat,
                        )),
                  ],
                ),
              ),

              // Informação sobre a Roda do Ano
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: context.gc.info,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).wheelAbout,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).wheelAboutBody,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).wheelAboutSouth,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.gc.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Roda do Ano'),
      ),
      body: content,
    );
  }

  Widget _buildDaysUntilChip(BuildContext context, int days) {
    String text;
    if (days == 0) {
      text = AppLocalizations.of(context).wheelToday;
    } else if (days == 1) {
      text = AppLocalizations.of(context).wheelTomorrow;
    } else {
      text = AppLocalizations.of(context).wheelInDays(days);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.gc.lilac.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.gc.lilac),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.gc.lilac,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSabbatItem(
    BuildContext context,
    Sabbat sabbat,
    DateFormat dateFormat,
  ) {
    final now = DateTime.now();
    final daysUntil = sabbat.daysUntil(now);
    final isPast = sabbat.isPast(now);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showSabbatDetails(context, sabbat, dateFormat),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPast
                ? context.gc.surface.withValues(alpha: 0.5)
                : context.gc.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPast
                  ? context.gc.surfaceBorder.withValues(alpha: 0.5)
                  : context.gc.surfaceBorder,
            ),
          ),
          child: Row(
            children: [
              Text(
                sabbat.emoji,
                style: TextStyle(
                  fontSize: 40,
                  color: isPast ? context.gc.textPrimary.withValues(alpha: 0.5) : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sabbat.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isPast
                                ? context.gc.textSecondary
                                : context.gc.lilac,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sabbat.type.southernHemisphereDate,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.gc.textSecondary,
                          ),
                    ),
                    if (!isPast) ...[
                      const SizedBox(height: 4),
                      Text(
                        daysUntil == 0
                            ? AppLocalizations.of(context).wheelToday
                            : daysUntil == 1
                                ? AppLocalizations.of(context).wheelTomorrow
                                : AppLocalizations.of(context).wheelInDays(daysUntil),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.gc.mint,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isPast
                    ? context.gc.textSecondary.withValues(alpha: 0.5)
                    : context.gc.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSabbatDetails(
    BuildContext context,
    Sabbat sabbat,
    DateFormat dateFormat,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.gc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.gc.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  sabbat.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  sabbat.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: MagicalButton(
                text: AppLocalizations.of(context).guidedRitualOpenCta,
                icon: Icons.auto_awesome,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GuidedRitualPage(
                        ritualId:
                            AllGuidedRituals.forSabbat(sabbat.type).id,
                      ),
                    ),
                  );
                },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Datas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.gc.lilac,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.gc.lilac.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: context.gc.lilac.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌎',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).wheelSouthHemisphere,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: context.gc.lilac,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sabbat.type.southernHemisphereDate,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌍',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).wheelNorthHemisphere,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: context.gc.lilac,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sabbat.type.northernHemisphereDate,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: context.gc.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Significado',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                sabbat.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Cristais',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sabbat.type.crystals
                    .map((crystal) => LinkableChip(
                        label: crystal, color: context.gc.lilac))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Ervas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sabbat.type.herbs
                    .map((herb) => LinkableChip(
                        label: herb, color: context.gc.mint))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Cores',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sabbat.type.colors
                    .map((color) => LinkableChip(
                        label: color, color: context.gc.starYellow))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Comidas Tradicionais',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...sabbat.type.foods.map((food) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🍽️', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            food,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              Text(
                'Rituais Sugeridos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...sabbat.rituals.map((ritual) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 20,
                            color: context.gc.lilac,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ritual,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
