import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../menstrual_cycle/data/menstrual_consent_store.dart';
import '../../../menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import '../../../menstrual_cycle/domain/menstrual_day.dart';
import '../../../menstrual_cycle/domain/menstrual_reading_scope.dart';

/// A fonte íntima na tela de fontes da Leitura do Ciclo.
///
/// Ela nasce LIGADA, como as outras quatro fontes desta tela, e por dois
/// motivos que se somam: a Leitura do Ciclo é comprada à parte — o que se
/// paga é a leitura, não o acesso ao próprio registro —, e o registro do
/// ciclo é gratuito. Barrar aqui cobrava duas vezes pela mesma coisa.
///
/// Havia um gate de Premium nesta chave; ele saiu. O que continua de pé é o
/// consentimento do registro: sem ele não há prévia, porque não há registro.
///
/// Ligada, a fonte abre a prévia do período e traz os dias marcados — de
/// novo como as outras fontes, que também entram inteiras. Daí em diante ela
/// DESmarca o que não quiser mandar, dia a dia, e o relato escrito tem uma
/// chave própria ao lado.
///
/// Trocar o período fecha o que estava autorizado e reabre na janela nova:
/// os dias marcados eram os da janela anterior e o escopo carrega as próprias
/// datas — mantê-los mandaria para a leitura os dias do período errado.
class MenstrualSourceTile extends StatefulWidget {
  const MenstrualSourceTile({
    super.key,
    required this.userId,
    required this.period,
    required this.onChanged,
    this.repository,
    this.consent = const MenstrualConsentStore(),
  });

  final String userId;

  /// A janela da leitura, `[start, end)`.
  final ({DateTime start, DateTime end}) period;

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

  /// Nasce ligada e já carregando: a prévia é pedida logo depois do primeiro
  /// quadro, e um estado inicial desligado faria a chave piscar de "não" para
  /// "sim" na frente de quem está olhando.
  bool _on = true;
  bool _loading = true;
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

  @override
  void initState() {
    super.initState();
    // Depois do primeiro quadro, e não aqui: `_open` termina avisando o pai,
    // e o pai guarda o escopo com setState — chamá-lo durante a montagem
    // derrubaria a árvore.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _open();
    });
  }

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
    _descartarPrevia();
    _on = false;
    _loading = false;
  }

  /// Larga o que foi lido da janela anterior e invalida a prévia em voo.
  ///
  /// O incremento é o que desfaz também o que ainda está a caminho: sem ele,
  /// o `_open` atrasado repovoa a lista com dias que já não valem e o pai
  /// recebe autorização sem aviso.
  void _descartarPrevia() {
    _aberturaPedida++;
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
    if (!outraJanela) return;

    // Trocar o período no calendário invalida o que estava marcado: os dias
    // eram os da janela ANTERIOR, e o escopo emitido carrega o próprio
    // `start`/`end` — mantê-lo faria a leitura ler do banco os dias do
    // período errado, sem que nada avisasse.
    //
    // O que estava marcado cai SEMPRE; a chave, não. Quem a desligou
    // continua com ela desligada — trocar de mês não é pedir a fonte de
    // volta. Quem a deixou ligada vê a prévia do período novo, porque
    // ligada é como ela nasce.
    setState(() {
      _descartarPrevia();
      if (_on) _loading = true;
    });

    // Depois do frame: `didUpdateWidget` roda durante o build de quem nos
    // contém, e o pai guarda o escopo com setState — mexer nele agora
    // derrubaria a árvore. O aviso vai primeiro, e sozinho vale por si: a
    // autorização da janela velha morre no mesmo instante em que ela deixa
    // de valer, mesmo que a leitura da janela nova demore.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _emit();
      if (_on) _open();
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
              if (_words) MenstrualField.note,
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
      if (day.note.isNotEmpty) l10n.cycleReadingMenstrualHasWords,
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
          subtitle: Text(l10n.cycleReadingIncludeMenstrualHint),
          value: _on,
          onChanged: (wanted) {
            if (wanted) {
              _open();
            } else {
              _close();
            }
          },
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
