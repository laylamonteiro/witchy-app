import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../data/models/moon_content_data.dart';
import '../providers/lunar_provider.dart';
import '../../../../core/widgets/breathing_moon.dart';
import '../../../../core/widgets/expansion_magical_card.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../core/widgets/starfield_background.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../encyclopedia/presentation/widgets/related_link.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../guided_rituals/presentation/pages/guided_ritual_page.dart';
import '../../../learning/data/data_sources/trails_data.dart';
import '../../../learning/presentation/pages/trail_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

/// Página "Lua" da Enciclopédia: todo o conhecimento de bruxaria da Lua.
/// A lua de hoje, as próximas fases e as recomendações vivem no "Seu Dia";
/// aqui ficam o saber lunar, a Água de Lua, os esbats, as correspondências
/// e as divindades lunares.
class LunarCalendarPage extends StatelessWidget {
  final bool embedded;

  const LunarCalendarPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nowPhase = context.watch<LunarProvider>().getCurrentMoonPhase();

    final content = SingleChildScrollView(
      child: StaggeredEntrance(
        children: [
          // Hero: a Lua respirando sobre o céu estrelado (a fase de HOJE
          // vive no Seu Dia — aqui é o portal do saber lunar).
          StarfieldBackground(
            intensity: 0.6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              child: Column(
                children: [
                  // Slot de altura fixa: o hero da Lua e o do Sol têm o MESMO
                  // tamanho e formato, com o ícone centrado (emojis variam
                  // de métrica). A lua que respira é a fase de HOJE.
                  SizedBox(
                    height: 110,
                    child: Center(
                      child: BreathingMoon(
                        moonEmoji: nowPhase.emoji,
                        size: 72,
                        showStars: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.moonNowTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${nowPhase.emoji}  ${nowPhase.displayName}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  // Slot fixo de 2 linhas: a frase varia de tamanho, mas o
                  // hero da Lua e o do Sol terminam SEMPRE na mesma altura.
                  SizedBox(
                    height: 40,
                    child: Text(
                      nowPhase.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Água de Lua (free) → ritual guiado
          MagicalCard.accent(
            accent: context.gc.lilac,
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
                Icon(Icons.chevron_right, color: context.gc.textSecondary),
              ],
            ),
          ),

          // Águas mágicas no Grimório Vivo (trilha completa das águas)
          MagicalCard.accent(
            accent: context.gc.lilac,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TrailPage(
                  trail: learningTrails
                      .firstWhere((t) => t.id == 'aguas_magicas'),
                ),
              ),
            ),
            child: Row(
              children: [
                const Text('💧', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.toolLivingGrimoireTitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        l10n.watersTrailCardSubtitle,
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
                Icon(Icons.chevron_right, color: context.gc.textSecondary),
              ],
            ),
          ),

          // A Lua na bruxaria (free): a explicação introdutória é aberta —
          // as seções seguintes (fases, esbats) continuam Premium.
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.moonInWitchcraftTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.moonInWitchcraftSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                        height: 1.35,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    MoonContent.intro,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.5),
                  ),
                ),
              ],
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
                    final knowledge = MoonContent.phaseKnowledge[moonPhase]!;
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
                                    label: item, color: context.gc.lilac))
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

          // Esbats (premium) — no formato dos sabbats solares
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
                      MoonContent.esbatsIntro,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    ...MoonContent.esbatItems.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      item.text,
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
                      .map((item) =>
                          LinkableChip(label: item, color: context.gc.lilac))
                      .toList(),
                ),
              ),
            ),
          ),

          // Divindades lunares (premium)
          MagicalCard(
            child: PremiumContentSection(
              feature: AppFeature.lunarCalendarDetails,
              title: Text(
                l10n.moonDeitiesTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              subtitle: l10n.moonDeitiesSubtitle,
              contentBuilder: (context) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: MoonContent.lunarDeities
                      .map((deity) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: LinkableChip(
                                    label: deity.name,
                                    color: context.gc.lilac,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  deity.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(height: 1.4),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(
            AppLocalizations.of(context).lunarCalendarTitle),
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
}
