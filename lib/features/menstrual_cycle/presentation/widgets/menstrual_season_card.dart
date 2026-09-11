import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
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
/// A escrita fica dentro do registro íntimo e não vai para o Diário. Ela só
/// sai daqui quando a própria pessoa a inclui numa Leitura do Ciclo (a chave
/// das palavras em menstrual_source_tile.dart leva `MenstrualField.seasonNote`
/// junto): é por isso que [MenstrualSeasonCard] diz isso com todas as letras
/// no bloco recolhível e no rodapé do campo, em vez de prometer sigilo
/// absoluto.
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

  /// A explicação da estação começa recolhida: a dúvida "o que é isso?" é de
  /// quem chega, e quem já sabe não precisa rolar por cima dela toda vez.
  bool _aboutOpen = false;

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

  /// "O que é uma estação interna?" — a resposta que faltava, no lugar onde a
  /// pergunta nasce: logo abaixo dos quatro chips, antes de qualquer escolha.
  ///
  /// Recolhível e fechada por padrão porque este card já é o bloco mais longo
  /// da tela; aberta, ela empurraria o campo de escrita para fora da dobra do
  /// navegador. Retrátil escrito à mão, e não `ExpansionTile`, porque aquele
  /// anima sem consultar [GrimoireMotion.reduced] — aqui, com movimento
  /// reduzido, a abertura é instantânea.
  Widget _about(
      BuildContext context, AppLocalizations l10n, GrimoireColors colors) {
    final paragraph =
        TextStyle(color: colors.textPrimary, fontSize: 13, height: 1.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        InkWell(
          key: const ValueKey('menstrual-season-about'),
          onTap: () => setState(() => _aboutOpen = !_aboutOpen),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.menstrualSeasonAboutTitle,
                    style: TextStyle(
                        color: colors.lilac,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(_aboutOpen ? Icons.expand_less : Icons.expand_more,
                    size: 20, color: colors.textSecondary),
              ],
            ),
          ),
        ),
        _abrindo(
          context,
          !_aboutOpen
              ? const SizedBox(width: double.infinity)
              : Column(
                  key: const ValueKey('menstrual-season-about-text'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.menstrualSeasonAboutBody, style: paragraph),
                    const SizedBox(height: 10),
                    Text(l10n.menstrualSeasonAboutUse, style: paragraph),
                    const SizedBox(height: 10),
                    // O que sai daqui quando ela autoriza uma leitura: dizer
                    // isso na explicação é a diferença entre explicar e
                    // explicar pela metade.
                    Text(l10n.menstrualSeasonAboutReading, style: paragraph),
                  ],
                ),
        ),
      ],
    );
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
          _about(context, l10n, colors),
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

/// O corpo que abre e fecha.
///
/// Com movimento reduzido NÃO há [AnimatedSize] nenhum: um AnimatedSize de
/// duração zero completa o próprio controlador durante o layout e se
/// re-suja a si mesmo ("A RenderAnimatedSize was mutated in its own
/// performLayout"). Zerar a duração não é o mesmo que não animar.
Widget _abrindo(BuildContext context, Widget corpo) {
  if (GrimoireMotion.reduced(context)) return corpo;
  return AnimatedSize(
    duration: GrimoireMotion.state,
    curve: GrimoireMotion.enter,
    alignment: Alignment.topCenter,
    child: corpo,
  );
}
