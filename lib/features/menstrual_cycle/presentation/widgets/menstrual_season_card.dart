import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../encyclopedia/presentation/widgets/related_link.dart';
import '../../data/data_sources/menstrual_phase_content.dart';
import '../../domain/internal_season.dart';
import '../../domain/menstrual_day.dart';
import 'season_vignette.dart';

/// "Sua estação": a escolha simbólica do dia, o convite que vem com ela e um
/// lugar para escrever.
///
/// A estação é sempre escolha da pessoa — o app nunca deduz uma a partir de
/// data, fluxo, humor ou média, e "nenhuma" é uma resposta inteira. Tocar na
/// estação já escolhida a desmarca.
///
/// A escrita fica dentro do registro íntimo: não vai para o Diário, para o
/// acervo nem para a IA.
class MenstrualSeasonCard extends StatefulWidget {
  const MenstrualSeasonCard({
    super.key,
    required this.record,
    required this.onChoose,
    required this.onWrite,
    this.invitesWinter = false,
  });

  /// O registro do dia, quando existe.
  final MenstrualDay? record;

  /// Escolhe (ou desmarca) a estação. Devolve se a gravação deu certo.
  final Future<bool> Function(InternalSeason? season) onChoose;

  /// Guarda a escrita da estação. Devolve se a gravação deu certo.
  final Future<bool> Function(String text) onWrite;

  /// Quando o dia tem marca de sangramento, o Inverno pode ser oferecido —
  /// como convite, nunca como conclusão.
  final bool invitesWinter;

  @override
  State<MenstrualSeasonCard> createState() => _MenstrualSeasonCardState();
}

class _MenstrualSeasonCardState extends State<MenstrualSeasonCard> {
  late final TextEditingController _writing =
      TextEditingController(text: widget.record?.seasonNote ?? '');
  bool _busy = false;
  bool _sealed = false;

  @override
  void dispose() {
    _writing.dispose();
    super.dispose();
  }

  Future<void> _choose(InternalSeason season) async {
    if (_busy) return;
    final chosen = widget.record?.season == season ? null : season;
    setState(() => _busy = true);
    final ok = await widget.onChoose(chosen);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok && chosen == null) _sealed = false;
    });
  }

  Future<void> _write() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await widget.onWrite(_writing.text.trim());
    if (!mounted) return;
    setState(() {
      _busy = false;
      _sealed = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.gc;
    final season = widget.record?.season;
    final content =
        season == null ? null : MenstrualSeasonContentSource.of(season);
    return MagicalCard(
      key: const ValueKey('menstrual-season'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SeasonVignette(season: season),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content?.title ?? l10n.menstrualSeasonTitle,
                      key: const ValueKey('menstrual-season-name'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colors.lilac,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.menstrualSeasonChoiceNote,
                      style: TextStyle(
                          color: colors.textSecondary, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in InternalSeason.values)
                ChoiceChip(
                  key: ValueKey('menstrual-season-${option.name}'),
                  label: Text(MenstrualSeasonContentSource.of(option).title),
                  selected: season == option,
                  onSelected: _busy ? null : (_) => _choose(option),
                ),
            ],
          ),
          if (season == null && widget.invitesWinter) ...[
            const SizedBox(height: 12),
            Text(
              l10n.menstrualSeasonWinterInvite,
              key: const ValueKey('menstrual-season-invite'),
              style: TextStyle(color: colors.textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
          if (content != null) ...[
            const SizedBox(height: 14),
            Text(
              content.invitation,
              key: const ValueKey('menstrual-season-invitation'),
              style: TextStyle(color: colors.textPrimary, height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.menstrualSeasonPractices,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 6),
            for (final practice in content.practices)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•', style: TextStyle(color: colors.lilac)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(practice,
                          style: TextStyle(color: colors.textPrimary, height: 1.4)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Text(
              content.writingQuestion,
              key: const ValueKey('menstrual-season-question'),
              style: TextStyle(
                  color: colors.lilac, fontStyle: FontStyle.italic, height: 1.4),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('menstrual-season-writing'),
              controller: _writing,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(labelText: l10n.menstrualSeasonWriteLabel),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.menstrualSeasonPrivate,
              style: TextStyle(
                  color: colors.textSecondary, fontSize: 11, height: 1.4),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_sealed)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.bookmark_added_outlined,
                            size: 16, color: colors.success),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.menstrualSeasonSaved,
                            key: const ValueKey('menstrual-season-sealed'),
                            style: TextStyle(color: colors.success, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 12),
                ElevatedButton(
                  key: const ValueKey('menstrual-season-save'),
                  onPressed: _busy ? null : _write,
                  child: Text(_busy ? l10n.commonSaving : l10n.commonSave),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              l10n.menstrualSeasonCorrespondences,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final correspondence in content.correspondences)
                  LinkableChip(
                    key: ValueKey('menstrual-season-link-${correspondence.key}'),
                    label: correspondence.label,
                    color: colors.lilac,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
