import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/moon_glyph.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../data/menstrual_mood_labels.dart';
import '../../domain/lunar_comparison.dart';
import '../../domain/menstrual_day.dart';
import '../menstrual_type.dart';

/// "A Lua e você": cada começo do sangue dela ao lado da Lua daquele dia, o
/// resumo dos últimos ciclos completos e as emoções que ela mais anotou nos
/// dias de sangue.
///
/// O card recebe o histórico pronto e o dia de hoje, e não consulta provider
/// nenhum: quem o monta decide o que ele vê, e o teste o monta sozinho. A
/// conta inteira mora em [LunarComparison]; aqui só se escolhe o que dizer.
///
/// A linha do tempo mostra os começos mais recentes até [shownStarts] e diz
/// quantos ficaram antes deles: o card vive numa página que já é longa, e um
/// histórico de anos não pode empurrar o resto para fora da dobra.
class LuaEVoceCard extends StatelessWidget {
  const LuaEVoceCard({super.key, required this.days, required this.today});

  /// Os dias registrados — o histórico inteiro, não só o mês na tela: um
  /// começo de três meses atrás é tão começo quanto o de ontem.
  final List<MenstrualDay> days;

  /// O dia que o card considera hoje. Começos marcados adiante dele ainda não
  /// aconteceram e ficam de fora.
  final DateTime today;

  /// Quantos começos a linha do tempo mostra por vez.
  static const shownStarts = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.gc;
    final report = LunarComparison.report(days, today: today);
    final timeline = report.timeline;
    final summary = report.summary;
    final head = MenstrualType.sectionHead(context);
    final body = MenstrualType.body(context);
    final quiet = MenstrualType.quiet(context);

    final shown = timeline.length <= shownStarts
        ? timeline
        : timeline.sublist(timeline.length - shownStarts);
    final earlier = timeline.length - shown.length;
    final rows = <Widget>[
      for (final observation in shown) _StartRow(observation: observation),
    ];
    final reduced = GrimoireMotion.reduced(context);

    return MagicalCard(
      key: const ValueKey('lua-e-voce'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.brightness_2_outlined, size: 18, color: colors.lilac),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.menstrualLunarTitle,
                  style: MenstrualType.cardTitle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (timeline.isEmpty)
            Text(
              l10n.menstrualLunarEmpty,
              key: const ValueKey('lua-e-voce-empty'),
              style: body,
            )
          else ...[
            Text(l10n.menstrualLunarStartsTitle, style: head),
            const SizedBox(height: 8),
            if (reduced)
              Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rows)
            else
              StaggeredEntrance(children: rows),
            if (earlier > 0)
              Text(
                l10n.menstrualLunarEarlier(earlier),
                key: const ValueKey('lua-e-voce-earlier'),
                style: quiet,
              ),
            const SizedBox(height: 12),
            if (summary == null)
              Text(
                l10n.menstrualLunarPending(timeline.length),
                key: const ValueKey('lua-e-voce-pending'),
                style: quiet,
              )
            else ...[
              if (summary.nearNewMoon > 0)
                Text(
                  l10n.menstrualLunarNearNew(
                      summary.nearNewMoon, summary.total),
                  key: const ValueKey('lua-e-voce-near-new'),
                  style: body,
                ),
              if (summary.nearFullMoon > 0)
                Text(
                  l10n.menstrualLunarNearFull(
                      summary.nearFullMoon, summary.total),
                  key: const ValueKey('lua-e-voce-near-full'),
                  style: body,
                ),
              if (summary.nearNewMoon == 0 && summary.nearFullMoon == 0)
                Text(
                  l10n.menstrualLunarNeither(summary.total),
                  key: const ValueKey('lua-e-voce-neither'),
                  style: body,
                ),
            ],
          ],
          if (report.moods.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.menstrualLunarMoodsTitle, style: head),
            const SizedBox(height: 8),
            Text(
              // Pelo rótulo, não pelo id gravado — e a palavra livre de um
              // registro antigo continua sendo a palavra dela.
              l10n.menstrualLunarMoods(report.moods
                  .map((tally) => menstrualMoodLabel(l10n, tally.mood))
                  .join(', ')),
              key: const ValueKey('lua-e-voce-moods'),
              style: body,
            ),
          ],
          if (!report.isEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.menstrualLunarBlessing,
                style: MenstrualType.caption(context)),
          ],
        ],
      ),
    );
  }
}

/// Um começo: a data, a Lua daquele dia e — quando é o caso — de
/// qual ponta ele ficou perto. O glifo é enfeite; quem fala é o nome da fase.
class _StartRow extends StatelessWidget {
  const _StartRow({required this.observation});

  final LunarObservation observation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.gc;
    final tag = switch (observation.nearness) {
      LunarNearness.newMoon => l10n.menstrualLunarTagNew,
      LunarNearness.fullMoon => l10n.menstrualLunarTagFull,
      LunarNearness.neither => null,
    };
    return Padding(
      key: ValueKey('lua-e-voce-start-${MenstrualDay.keyOf(observation.day)}'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sem halo: numa lista de datas o brilho viraria uma coluna de
          // manchas lilases, e a Lua daqui é referência, não protagonista.
          MoonGlyph(phase: observation.phase, size: 18, halo: false),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MaterialLocalizations.of(context)
                      .formatShortDate(observation.day),
                  style: MenstrualType.body(context),
                ),
                Text(
                  observation.phase.displayName,
                  style: MenstrualType.quiet(context),
                ),
                if (tag != null)
                  Text(tag,
                      style: MenstrualType.caption(context)
                          .copyWith(color: colors.lilac)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
