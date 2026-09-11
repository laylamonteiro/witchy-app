import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../menstrual_cycle/data/menstrual_consent_store.dart';
import '../../../menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import '../../../menstrual_cycle/domain/menstrual_day.dart';
import '../../../menstrual_cycle/domain/menstrual_reading_scope.dart';

/// A fonte íntima na tela de fontes da Leitura do Ciclo.
///
/// Ela nasce desligada e continua desligada até três coisas serem verdade ao
/// mesmo tempo: a pessoa tem Premium efetivo, consentiu em registrar, e
/// escolheu — registro a registro — o que vai junto. Ligar a chave não
/// autoriza nada sozinho: ela abre a prévia do que existe na janela, e
/// autorizar é marcar.
///
/// As palavras escritas nesses dias (a anotação e a escrita da estação) são
/// uma escolha à parte, desmarcada, porque são as palavras dela.
class MenstrualSourceTile extends StatefulWidget {
  const MenstrualSourceTile({
    super.key,
    required this.userId,
    required this.period,
    required this.premium,
    required this.onChanged,
    this.repository,
    this.consent = const MenstrualConsentStore(),
  });

  final String userId;

  /// A janela da leitura, `[start, end)`.
  final ({DateTime start, DateTime end}) period;

  /// `AuthProvider.isPremiumEffective` no momento da tela. Sem ele a fonte
  /// aparece, explica que é Premium e não abre prévia nenhuma.
  final bool premium;

  /// O escopo autorizado a cada mudança — vazio quando nada está marcado.
  final ValueChanged<MenstrualReadingScope> onChanged;

  final MenstrualCycleRepository? repository;
  final MenstrualConsentStore consent;

  @override
  State<MenstrualSourceTile> createState() => _MenstrualSourceTileState();
}

class _MenstrualSourceTileState extends State<MenstrualSourceTile> {
  late final MenstrualCycleRepository _repository =
      widget.repository ?? MenstrualCycleRepository();

  bool _on = false;
  bool _loading = false;
  bool _consented = false;
  int _consentRevision = 0;
  List<MenstrualDay> _days = const [];
  final Set<String> _chosen = {};
  bool _words = false;

  /// Quantas vezes a prévia já foi pedida nesta caixinha.
  ///
  /// Uma leitura em voo não pode repovoar a lista depois que a fonte foi
  /// fechada ou que a janela mudou: o `setState` atrasado do [_open] devolvia
  /// os dias marcados com a chave DESLIGADA na tela, e o pai ficava com uma
  /// autorização que ela não vê em lugar nenhum — o contrário do que esta
  /// caixinha promete.
  int _aberturaPedida = 0;

  Future<void> _open() async {
    final pedido = ++_aberturaPedida;
    setState(() {
      _on = true;
      _loading = true;
    });
    try {
      final consented = await widget.consent.recordingAllowed(widget.userId);
      final revision = await widget.consent.consentRevision(widget.userId);
      // A janela da leitura é [start, end); o repositório lê pelas pontas,
      // então o último dia é a véspera do fim.
      final days = consented
          ? await _repository.between(
              userId: widget.userId,
              from: widget.period.start,
              to: widget.period.end.subtract(const Duration(days: 1)),
            )
          : const <MenstrualDay>[];
      // Fechou ou trocou de janela enquanto o banco respondia: o que voltou
      // é de uma pergunta que não está mais de pé.
      if (!mounted || pedido != _aberturaPedida) return;
      setState(() {
        _consented = consented;
        _consentRevision = revision;
        _days = days;
        // Abrir a fonte já traz o período inteiro marcado, e as palavras
        // dela junto: o sim está na chave, e daqui em diante ela DESmarca o
        // que não quiser mandar — dia a dia ou o relato inteiro de uma vez.
        _chosen
          ..clear()
          ..addAll(days.map((day) => day.dayKey));
        _words = true;
        _loading = false;
      });
    } catch (_) {
      if (mounted && pedido == _aberturaPedida) {
        setState(() => _loading = false);
      }
    }
    if (pedido != _aberturaPedida) return;
    _emit();
  }

  void _close() {
    setState(_limpar);
    _emit();
  }

  void _limpar() {
    // Invalida a prévia em voo junto: fechar a fonte tem de desfazer também
    // o que ainda está a caminho, senão o `_open` atrasado religa a lista
    // com a chave desligada e o pai recebe dias autorizados sem aviso.
    _aberturaPedida++;
    _on = false;
    _loading = false;
    _chosen.clear();
    _words = false;
    _days = const [];
  }

  @override
  void didUpdateWidget(covariant MenstrualSourceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final outraJanela =
        !oldWidget.period.start.isAtSameMomentAs(widget.period.start) ||
            !oldWidget.period.end.isAtSameMomentAs(widget.period.end);
    if (!outraJanela || (!_on && _chosen.isEmpty)) return;

    // Trocar o período no calendário invalida o que estava marcado: os dias
    // eram os da janela ANTERIOR, e o escopo emitido carrega o próprio
    // `start`/`end` — mantê-lo faria a leitura ler do banco os dias do
    // período errado, sem que nada avisasse.
    //
    // Fecha em vez de reabrir sozinha na janela nova: `_open` marca o
    // período inteiro por padrão, então reabrir seria o app autorizando no
    // lugar dela. Autorizar é dela; o app só desfaz.
    setState(_limpar);

    // O aviso ao pai sai DEPOIS do frame: `didUpdateWidget` roda durante o
    // build de quem nos contém, e o pai guarda o escopo com setState —
    // chamá-lo agora derrubaria a árvore.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _emit();
    });
  }

  void _emit() {
    if (!mounted) return;
    final chosen = [
      for (final day in _days)
        if (_chosen.contains(day.dayKey)) MenstrualScopeEntry.of(day),
    ];
    widget.onChanged(chosen.isEmpty
        ? MenstrualReadingScope.none(userId: widget.userId)
        : MenstrualReadingScope(
            userId: widget.userId,
            start: widget.period.start,
            end: widget.period.end,
            entries: chosen,
            fields: {
              ...MenstrualReadingScope.defaultFields,
              if (_words) ...[MenstrualField.note, MenstrualField.seasonNote],
            },
            consentRevision: _consentRevision,
          ));
  }

  String _describe(AppLocalizations l10n, MenstrualDay day) {
    final parts = <String>[
      switch (day.mark) {
        MenstrualMark.start => l10n.menstrualMarkStart,
        MenstrualMark.flow => l10n.menstrualMarkFlow,
        MenstrualMark.spotting => l10n.menstrualMarkSpotting,
        MenstrualMark.end => l10n.menstrualMarkEnd,
        MenstrualMark.note => l10n.menstrualMarkNote,
      },
      if (day.symptoms.isNotEmpty)
        l10n.cycleReadingMenstrualSymptoms(day.symptoms.length),
      if (day.note.isNotEmpty || day.seasonNote.isNotEmpty)
        l10n.cycleReadingMenstrualHasWords,
    ];
    return parts.join(' · ');
  }

  static String _readable(DateTime day) =>
      '${day.day.toString().padLeft(2, '0')}/'
      '${day.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.gc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          key: const ValueKey('cycle-reading-menstrual'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.cycleReadingIncludeMenstrual),
          subtitle: Text(widget.premium
              ? l10n.cycleReadingIncludeMenstrualHint
              : l10n.cycleReadingMenstrualPremium),
          value: _on,
          // Sem Premium a chave não abre: nada é lido, nada é mostrado.
          onChanged: widget.premium
              ? (wanted) {
                  if (wanted) {
                    _open();
                  } else {
                    _close();
                  }
                }
              : null,
        ),
        if (_on && _loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (_on && !_loading) ...[
          if (!_consented || _days.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.cycleReadingMenstrualEmpty,
                key: const ValueKey('cycle-reading-menstrual-empty'),
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            )
          else ...[
            Text(
              l10n.cycleReadingMenstrualSelected(_chosen.length),
              key: const ValueKey('cycle-reading-menstrual-count'),
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  key: const ValueKey('cycle-reading-menstrual-all'),
                  onPressed: () {
                    setState(() {
                      _chosen
                        ..clear()
                        ..addAll(_days.map((day) => day.dayKey));
                    });
                    _emit();
                  },
                  child: Text(l10n.cycleReadingMenstrualAll),
                ),
                if (_chosen.isNotEmpty)
                  TextButton(
                    key: const ValueKey('cycle-reading-menstrual-none'),
                    onPressed: () {
                      setState(_chosen.clear);
                      _emit();
                    },
                    child: Text(l10n.cycleReadingMenstrualNone),
                  ),
              ],
            ),
            for (final day in _days)
              CheckboxListTile(
                key: ValueKey('cycle-reading-menstrual-${day.dayKey}'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text('${_readable(day.day)} · ${_describe(l10n, day)}',
                    style: TextStyle(color: colors.textPrimary, fontSize: 13)),
                value: _chosen.contains(day.dayKey),
                onChanged: (marked) {
                  setState(() {
                    if (marked ?? false) {
                      _chosen.add(day.dayKey);
                    } else {
                      _chosen.remove(day.dayKey);
                    }
                  });
                  _emit();
                },
              ),
            SwitchListTile(
              key: const ValueKey('cycle-reading-menstrual-words'),
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(l10n.cycleReadingMenstrualWords),
              subtitle: Text(l10n.cycleReadingMenstrualWordsHint),
              value: _words,
              onChanged: (wanted) {
                setState(() => _words = wanted);
                _emit();
              },
            ),
            Text(
              l10n.cycleReadingMenstrualArchive,
              style: TextStyle(
                  color: colors.textSecondary, fontSize: 11, height: 1.4),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.cycleReadingMenstrualScopeNote,
              style: TextStyle(
                  color: colors.textSecondary, fontSize: 11, height: 1.4),
            ),
          ],
        ],
      ],
    );
  }
}
