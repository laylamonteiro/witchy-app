import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/navigation/app_deep_link.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../encyclopedia/presentation/widgets/related_link.dart';
import '../../../guided_rituals/data/models/magical_moment_data.dart';
import '../../../guided_rituals/presentation/pages/guided_ritual_page.dart';
// A extensão de SabbatType (name/emoji) precisa estar em escopo aqui.
import '../../../wheel_of_year/data/models/sabbat_model.dart';
import '../../data/models/sun_content_data.dart';

/// Página "Sol" da Enciclopédia: o conhecimento de bruxaria do Sol —
/// o período solar de agora, o saber solar (premium), a Água Solar,
/// as horas do dia, os sabbats solares, correspondências e divindades.
class SunPage extends StatelessWidget {
  const SunPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nowPeriod = MagicDayPeriod.fromHour(DateTime.now().hour);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // O Sol na bruxaria (premium)
          MagicalCard(
            child: PremiumContentSection(
              feature: AppFeature.sunKnowledge,
              title: Text(
                l10n.sunInWitchcraftTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              subtitle: l10n.sunInWitchcraftSubtitle,
              contentBuilder: (context) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  SunContent.intro,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5),
                ),
              ),
            ),
          ),

          // Água Solar (free) → ritual guiado
          MagicalCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const GuidedRitualPage(ritualId: 'sun_water'),
              ),
            ),
            child: Row(
              children: [
                const Text('☀️', style: TextStyle(fontSize: 32)),
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
                        l10n.sunWaterCardSubtitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: context.gc.starYellow,
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

          // O Sol agora (free) — período solar do momento
          MagicalCard(
            child: Column(
              children: [
                Text(
                  l10n.sunNowTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(nowPeriod.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  nowPeriod.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.starYellow,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  nowPeriod.goodFor,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),

          // As horas do Sol (free) — os períodos mágicos do dia
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sunHoursTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                ...MagicDayPeriod.values.map((period) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            period.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  period.title,
                                  style:
                                      Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  period.goodFor,
                                  style: Theme.of(context).textTheme.bodySmall,
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

          // Sabbats solares (free) — toque leva à aba Sabbats
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sunSolarSabbatsTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                ...SunContent.solarSabbats.map((solar) => InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => DeepLinkService.instance
                          .dispatch(AppDeepLink.sabbatsEncyclopedia),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              solar.sabbat.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    solar.sabbat.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  Text(
                                    solar.meaning,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                size: 18, color: context.gc.textSecondary),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),

          // Correspondências solares (premium)
          MagicalCard(
            child: PremiumContentSection(
              feature: AppFeature.sunKnowledge,
              title: Text(
                l10n.sunCorrespondencesTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              subtitle: l10n.sunCorrespondencesSubtitle,
              contentBuilder: (context) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SunContent.correspondences
                      .map((item) => LinkableChip(
                          label: item, color: context.gc.starYellow))
                      .toList(),
                ),
              ),
            ),
          ),

          // Divindades solares (premium)
          MagicalCard(
            child: PremiumContentSection(
              feature: AppFeature.sunKnowledge,
              title: Text(
                l10n.sunDeitiesTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              subtitle: l10n.sunDeitiesSubtitle,
              contentBuilder: (context) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: SunContent.solarDeities
                      .map((deity) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: LinkableChip(
                                    label: deity.name,
                                    color: context.gc.starYellow,
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
  }
}
