import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lunar_provider.dart';
import '../../data/models/moon_content_data.dart';
import '../../../../core/widgets/expansion_magical_card.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/moon_phase_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../encyclopedia/presentation/widgets/related_link.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../guided_rituals/presentation/pages/guided_ritual_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

/// Página "Lua" da Enciclopédia: todo o conhecimento de bruxaria da Lua.
/// O carrossel Ontem/Hoje/Amanhã vive no "Seu Dia"; aqui ficam a fase de
/// hoje, o saber lunar (premium), a Água de Lua, correspondências, próximas
/// fases e recomendações de feitiço.
class LunarCalendarPage extends StatefulWidget {
  final bool embedded;

  const LunarCalendarPage({super.key, this.embedded = false});

  @override
  State<LunarCalendarPage> createState() => _LunarCalendarPageState();
}

class _LunarCalendarPageState extends State<LunarCalendarPage> {
  @override
  Widget build(BuildContext context) {
    final content = Consumer<LunarProvider>(
      builder: (context, lunarProvider, _) {
        try {
          final l10n = AppLocalizations.of(context);
          final phase = lunarProvider.getCurrentMoonPhase();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fase de hoje (compacta, free)
                MagicalCard(
                  child: Column(
                    children: [
                      Text(
                        l10n.lunarToday,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      MoonPhaseWidget(
                        phase: phase,
                        showName: true,
                        showDescription: true,
                        size: 80,
                      ),
                    ],
                  ),
                ),

                // A Lua na bruxaria (premium)
                MagicalCard(
                  child: PremiumContentSection(
                    feature: AppFeature.lunarCalendarDetails,
                    title: Text(
                      l10n.moonInWitchcraftTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    subtitle: l10n.moonInWitchcraftSubtitle,
                    contentBuilder: (context) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        MoonContent.intro,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.5),
                      ),
                    ),
                  ),
                ),

                // O que cada fase favorece (premium)
                MagicalCard(
                  child: PremiumContentSection(
                    feature: AppFeature.lunarCalendarDetails,
                    title: Text(
                      l10n.moonPhasesWitchcraftTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    subtitle: l10n.moonPhasesWitchcraftSubtitle,
                    contentBuilder: (context) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: MoonPhase.values.map((moonPhase) {
                          final knowledge =
                              MoonContent.phaseKnowledge[moonPhase]!;
                          return ExpansionMagicalCard(
                            emoji: moonPhase.emoji,
                            title: moonPhase.displayName,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  knowledge.favors,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(height: 1.4),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: knowledge.goodFor
                                      .map((item) => LinkableChip(
                                          label: item,
                                          color: context.gc.lilac))
                                      .toList(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // Água de Lua (free) → ritual guiado
                MagicalCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const GuidedRitualPage(ritualId: 'moon_water'),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🫙', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.guidedRitualsSectionTitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              l10n.moonWaterCardSubtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: context.gc.lilac,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: context.gc.textSecondary),
                    ],
                  ),
                ),

                // Esbats (premium)
                MagicalCard(
                  child: PremiumContentSection(
                    feature: AppFeature.lunarCalendarDetails,
                    title: Text(
                      l10n.moonEsbatsTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    subtitle: l10n.moonEsbatsSubtitle,
                    contentBuilder: (context) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MoonContent.esbats.what,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            MoonContent.esbats.how,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Correspondências lunares (premium)
                MagicalCard(
                  child: PremiumContentSection(
                    feature: AppFeature.lunarCalendarDetails,
                    title: Text(
                      l10n.moonCorrespondencesTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    subtitle: l10n.moonCorrespondencesSubtitle,
                    contentBuilder: (context) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: MoonContent.correspondences
                            .map((item) => LinkableChip(
                                label: item, color: context.gc.lilac))
                            .toList(),
                      ),
                    ),
                  ),
                ),

                // Próximas fases importantes (free)
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).lunarNextPhases,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).lunarNextPhasesSub,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.gc.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildAllNextPhases(context, lunarProvider),
                    ],
                  ),
                ),

                // Recomendações para feitiços (free)
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: context.gc.starYellow,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).lunarRecommendations,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSpellRecommendation(
                        context,
                        lunarProvider,
                        SpellType.attraction,
                      ),
                      const SizedBox(height: 12),
                      _buildSpellRecommendation(
                        context,
                        lunarProvider,
                        SpellType.banishment,
                      ),
                    ],
                  ),
                ),

                // Significado básico das fases (free)
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.lunarPhasesTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      ...MoonPhase.values.map((phase) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phase.emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        phase.displayName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      Text(
                                        phase.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          );
        } catch (e) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: context.gc.alert,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).lunarLoadError,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).lunarCalendarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: content,
    );
  }

  List<Widget> _buildAllNextPhases(
    BuildContext context,
    LunarProvider provider,
  ) {
    final allPhases = provider.getAllNextPhases();
    final widgets = <Widget>[];

    for (int i = 0; i < allPhases.length; i++) {
      final phaseData = allPhases[i];
      final phase = phaseData['phase'] as MoonPhase;
      final date = phaseData['date'] as DateTime;
      final daysUntil = phaseData['daysUntil'] as int;
      final hoursUntil = phaseData['hoursUntil'] as int;

      widgets.add(_buildEnhancedPhaseItem(
        context,
        phase.displayName,
        phase.emoji,
        date,
        daysUntil,
        hoursUntil,
      ));

      if (i < allPhases.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  Widget _buildEnhancedPhaseItem(
    BuildContext context,
    String phaseName,
    String emoji,
    DateTime date,
    int daysUntil,
    int hoursUntil,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    String timeText = '';
    if (daysUntil == 0) {
      if (hoursUntil == 0) {
        timeText = AppLocalizations.of(context).lunarNow;
      } else {
        timeText = AppLocalizations.of(context).lunarInHours(hoursUntil);
      }
    } else if (daysUntil == 1) {
      timeText = AppLocalizations.of(context).lunarTomorrowAt(timeFormat.format(date));
    } else {
      timeText =
          AppLocalizations.of(context).lunarInDaysAt(daysUntil, timeFormat.format(date));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.gc.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.gc.lilac.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phaseName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpellRecommendation(
    BuildContext context,
    LunarProvider lunarProvider,
    SpellType spellType,
  ) {
    final isGoodTime = lunarProvider.isGoodTimeForSpell(spellType);
    final recommendation = lunarProvider.getSpellRecommendation(spellType);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGoodTime
            ? context.gc.success.withValues(alpha: 0.1)
            : context.gc.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGoodTime ? context.gc.success : context.gc.info,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGoodTime ? Icons.check_circle : Icons.info,
            color: isGoodTime ? context.gc.success : context.gc.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spellType.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isGoodTime ? context.gc.success : context.gc.info,
                      ),
                ),
                Text(
                  recommendation,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
