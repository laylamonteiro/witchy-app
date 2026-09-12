import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/moon_glyph.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../data/menstrual_mood_labels.dart';
import '../../domain/lunar_comparison.dart';
import '../../domain/menstrual_day.dart';
import '../menstrual_type.dart';

/// A folha de registro de um dia, de cima para baixo: a Lua daquele dia e o
/// convite dela, a marca, a intensidade, como ela está, os sintomas e, por
/// último, uma palavra.
///
/// A escolha é explícita: começou, dia de fluxo, escape, terminou ou só uma
/// anotação. Nada é presumido a partir de outra coisa — marcar escape não
/// escreve um começo.
///
/// A saída sem gravar tem botão, e não só o gesto: no navegador não há alça
/// de arrasto nem toque fora que se anuncie, então uma folha sem "Cancelar"
/// é uma folha sem saída visível.
class MenstrualRecordForm extends StatefulWidget {
  const MenstrualRecordForm({
    super.key,
    required this.userId,
    required this.day,
    required this.onSubmit,
    this.existing,
    this.onDelete,
    this.onCancel,
    this.saving = false,
    this.error,
  });

  final String userId;
  final DateTime day;
  final MenstrualDay? existing;
  final void Function(MenstrualDay day) onSubmit;
  final VoidCallback? onDelete;

  /// A saída sem gravar. Quando nula, o formulário fecha a própria rota —
  /// o botão existe sempre, porque é a única saída anunciada da folha.
  final VoidCallback? onCancel;

  final bool saving;

  /// A falha da última tentativa. O formulário continua aqui, com o que foi
  /// escrito, para a pessoa tentar de novo.
  final String? error;

  /// Os sintomas oferecidos. A lista é curta de propósito: o resto cabe na
  /// anotação, com as palavras dela.
  static const symptoms = ['cramps', 'headache', 'tired', 'nausea', 'back', 'mood'];

  @override
  State<MenstrualRecordForm> createState() => _MenstrualRecordFormState();
}

class _MenstrualRecordFormState extends State<MenstrualRecordForm> {
  late MenstrualMark _mark = widget.existing?.mark ?? MenstrualMark.flow;
  late MenstrualFlowLevel? _flow = widget.existing?.flow;
  late final Set<String> _symptoms = {...?widget.existing?.symptoms};

  /// O humor começa como veio gravado e só muda quando ela toca num chip.
  /// Antes de virar chip ele era texto livre: um registro antigo com a
  /// palavra dela abre sem chip marcado e, se ela não escolher nenhum, a
  /// palavra volta para o banco como estava.
  late String? _mood = widget.existing?.mood;

  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');

  /// A Lua do dia em edição, uma vez: o dia não muda enquanto a folha existe.
  late final MoonPhase _phase =
      LunarProvider.phaseOn(LunarComparison.noonOf(widget.day));

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// A intensidade só faz sentido onde houve sangramento: oferecê-la num
  /// "terminou" ou numa anotação sugeriria uma observação que não foi feita.
  bool get _asksFlow =>
      _mark == MenstrualMark.start ||
      _mark == MenstrualMark.flow ||
      _mark == MenstrualMark.spotting;

  String _markLabel(AppLocalizations l10n, MenstrualMark mark) => switch (mark) {
        MenstrualMark.start => l10n.menstrualMarkStart,
        MenstrualMark.flow => l10n.menstrualMarkFlow,
        MenstrualMark.spotting => l10n.menstrualMarkSpotting,
        MenstrualMark.end => l10n.menstrualMarkEnd,
        MenstrualMark.note => l10n.menstrualMarkNote,
      };

  String _flowLabel(AppLocalizations l10n, MenstrualFlowLevel level) =>
      switch (level) {
        MenstrualFlowLevel.light => l10n.menstrualFlowLight,
        MenstrualFlowLevel.medium => l10n.menstrualFlowMedium,
        MenstrualFlowLevel.heavy => l10n.menstrualFlowHeavy,
      };

  String _symptomLabel(AppLocalizations l10n, String id) => switch (id) {
        'cramps' => l10n.menstrualSymptomCramps,
        'headache' => l10n.menstrualSymptomHeadache,
        'tired' => l10n.menstrualSymptomTired,
        'nausea' => l10n.menstrualSymptomNausea,
        'back' => l10n.menstrualSymptomBack,
        _ => l10n.menstrualSymptomMood,
      };

  /// O convite da Lua do dia: uma frase por fase, que convida e não promete.
  String _inviteOf(AppLocalizations l10n, MoonPhase phase) => switch (phase) {
        MoonPhase.newMoon => l10n.menstrualMoonInviteNewMoon,
        MoonPhase.waxingCrescent => l10n.menstrualMoonInviteWaxingCrescent,
        MoonPhase.firstQuarter => l10n.menstrualMoonInviteFirstQuarter,
        MoonPhase.waxingGibbous => l10n.menstrualMoonInviteWaxingGibbous,
        MoonPhase.fullMoon => l10n.menstrualMoonInviteFullMoon,
        MoonPhase.waningGibbous => l10n.menstrualMoonInviteWaningGibbous,
        MoonPhase.lastQuarter => l10n.menstrualMoonInviteLastQuarter,
        MoonPhase.waningCrescent => l10n.menstrualMoonInviteWaningCrescent,
      };

  void _submit() {
    if (widget.saving) return;
    final mood = _mood?.trim() ?? '';
    widget.onSubmit(MenstrualDay(
      userId: widget.userId,
      day: widget.day,
      mark: _mark,
      flow: _asksFlow ? _flow : null,
      symptoms: MenstrualRecordForm.symptoms
          .where(_symptoms.contains)
          .toList(growable: false),
      mood: mood.isEmpty ? null : mood,
      note: _note.text.trim(),
    ));
  }

  /// Sair sem gravar. Descartar já era o que acontecia ao tocar fora da
  /// folha; aqui só ganha nome e alvo. Nada foi escrito no repositório até o
  /// "Salvar", então não há o que desfazer.
  void _cancel() {
    if (widget.saving) return;
    final onCancel = widget.onCancel;
    if (onCancel != null) {
      onCancel();
      return;
    }
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.gc;
    final head = MenstrualType.sectionHead(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.menstrualSheetTitle,
                    style: MenstrualType.cardTitle(context)),
              ),
              IconButton(
                key: const ValueKey('menstrual-close'),
                onPressed: widget.saving ? null : _cancel,
                icon: const Icon(Icons.close, size: 20),
                tooltip: l10n.commonClose,
                color: colors.textSecondary,
              ),
            ],
          ),
          // A data em edição e a Lua dela, no alto: um dia retroativo nunca
          // é salvo por engano achando que é hoje. O glifo é enfeite; quem
          // fala é a data e o nome da fase.
          Row(
            children: [
              MoonGlyph(phase: _phase, size: 22, halo: false),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.menstrualEditingDay(
                    MaterialLocalizations.of(context)
                        .formatMediumDate(widget.day),
                    _phase.displayName,
                  ),
                  key: const ValueKey('menstrual-editing-day'),
                  style: MenstrualType.eyebrow(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _inviteOf(l10n, _phase),
            key: const ValueKey('menstrual-moon-invite'),
            style: MenstrualType.body(context),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mark in MenstrualMark.values)
                ChoiceChip(
                  key: ValueKey('menstrual-mark-${mark.name}'),
                  label: Text(_markLabel(l10n, mark)),
                  selected: _mark == mark,
                  onSelected: (_) => setState(() => _mark = mark),
                ),
            ],
          ),
          if (_asksFlow) ...[
            const SizedBox(height: 12),
            Text(l10n.menstrualFlowLabel, style: head),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final level in MenstrualFlowLevel.values)
                  ChoiceChip(
                    key: ValueKey('menstrual-flow-${level.name}'),
                    label: Text(_flowLabel(l10n, level)),
                    selected: _flow == level,
                    onSelected: (selected) =>
                        setState(() => _flow = selected ? level : null),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(l10n.menstrualMoodLabel, style: head),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in menstrualMoods)
                ChoiceChip(
                  key: ValueKey('menstrual-mood-$id'),
                  label: Text(menstrualMoodLabel(l10n, id)),
                  selected: _mood == id,
                  // Tocar de novo desmarca: ela pode não querer dizer nada.
                  onSelected: (selected) =>
                      setState(() => _mood = selected ? id : null),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.menstrualSymptomsLabel, style: head),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in MenstrualRecordForm.symptoms)
                FilterChip(
                  key: ValueKey('menstrual-symptom-$id'),
                  label: Text(_symptomLabel(l10n, id)),
                  selected: _symptoms.contains(id),
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _symptoms.add(id);
                    } else {
                      _symptoms.remove(id);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('menstrual-note'),
            controller: _note,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(hintText: l10n.menstrualNoteLabel),
          ),
          if (widget.error != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.error!,
              key: const ValueKey('menstrual-error'),
              style: MenstrualType.body(context).copyWith(color: colors.alert),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                key: const ValueKey('menstrual-cancel'),
                onPressed: widget.saving ? null : _cancel,
                style: TextButton.styleFrom(
                    foregroundColor: colors.textSecondary),
                child: Text(l10n.commonCancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                key: const ValueKey('menstrual-save'),
                onPressed: widget.saving ? null : _submit,
                child: Text(widget.saving ? l10n.commonSaving : l10n.commonSave),
              ),
            ],
          ),
          if (widget.onDelete != null) ...[
            const SizedBox(height: 8),
            // Na mesma margem que Cancelar e Salvar: as ações da folha
            // ficam todas na mesma coluna, e não uma centralizada abaixo.
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                key: const ValueKey('menstrual-delete'),
                onPressed: widget.saving ? null : widget.onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(l10n.menstrualDelete),
                style: TextButton.styleFrom(foregroundColor: colors.alert),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
