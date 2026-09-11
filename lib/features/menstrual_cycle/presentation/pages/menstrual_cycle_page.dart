import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../data/data_sources/menstrual_phase_content.dart';
import '../../data/menstrual_consent_store.dart';
import '../../data/repositories/menstrual_cycle_repository.dart';
import '../../domain/internal_season.dart';
import '../../domain/menstrual_access.dart';
import '../../domain/menstrual_day.dart';
import '../../domain/menstrual_insights.dart';
import '../widgets/menstrual_lunar_card.dart';
import '../widgets/menstrual_record_form.dart';
import '../widgets/menstrual_season_card.dart';
import '../widgets/menstrual_wheel.dart';

/// A roda pessoal: o registro do próprio ciclo.
///
/// Antes de qualquer coisa, o consentimento — e ele explica o que é gratuito
/// (registrar, consultar, corrigir, exportar e apagar) e o que é Premium (o
/// que se calcula a partir disso). Recusar não apaga nada.
///
/// O calendário mostra só os dias que a pessoa registrou. Um dia vazio é
/// ausência de registro, e nada aqui conta, soma ou estima: no plano
/// gratuito esses números não são calculados nem para ficar escondidos.
class MenstrualCyclePage extends StatefulWidget {
  const MenstrualCyclePage({
    super.key,
    this.repository,
    this.consent = const MenstrualConsentStore(),
    this.today,
  });

  final MenstrualCycleRepository? repository;
  final MenstrualConsentStore consent;

  /// Só para teste: o dia que a tela considera hoje.
  final DateTime? today;

  @override
  State<MenstrualCyclePage> createState() => _MenstrualCyclePageState();
}

class _MenstrualCyclePageState extends State<MenstrualCyclePage> {
  late final MenstrualCycleRepository _repository =
      widget.repository ?? MenstrualCycleRepository();

  late final DateTime _today = _dayOf(widget.today ?? DateTime.now());
  late DateTime _month = DateTime(_today.year, _today.month);

  Map<String, MenstrualDay> _days = const {};

  /// O histórico inteiro alimenta o que se calcula; o mês alimenta o
  /// calendário. Só quem tem acesso ao derivado chega a pedir o histórico.
  List<MenstrualDay> _history = const [];
  bool _loading = true;
  bool _consented = false;
  bool _wantsNextReference = false;
  bool _saving = false;
  String? _formError;

  /// A roda é uma alternativa oferecida, não a única porta: quem não quiser
  /// explorá-la fica no calendário do mês, que continua completo.
  bool _wheelView = false;

  /// O dia em foco na roda. O calendário não tem foco — ele abre o dia que
  /// for tocado.
  late DateTime _focused = _today;

  /// As fases estimadas do mês na tela, prontas antes do desenho.
  late Map<int, MoonPhase> _moons = _moonsFor(_month);

  String get _userId => context.read<AuthProvider>().currentUser.id;

  bool get _premium => context.read<AuthProvider>().isPremiumEffective;

  static DateTime _dayOf(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = _userId;
    try {
      final consented = await widget.consent.recordingAllowed(userId);
      final days = consented ? await _monthOf(userId, _month) : const <MenstrualDay>[];
      final wants = await widget.consent.nextReferenceWanted(userId);
      // O histórico inteiro só é montado para quem pode ver o que se
      // calcula dele: no gratuito ele não chega nem a ser lido.
      final history = consented && _premium
          ? await _repository.all(userId)
          : const <MenstrualDay>[];
      if (!mounted) return;
      setState(() {
        _consented = consented;
        _wantsNextReference = wants;
        _days = {for (final day in days) day.dayKey: day};
        _history = history;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<MenstrualDay>> _monthOf(String userId, DateTime month) =>
      _repository.between(
        userId: userId,
        from: DateTime(month.year, month.month),
        to: DateTime(month.year, month.month + 1, 0),
      );

  Future<void> _accept() async {
    final userId = _userId;
    await widget.consent.setRecordingAllowed(userId, true);
    if (!mounted) return;
    setState(() => _loading = true);
    await _load();
  }

  Future<void> _changeMonth(int months) async {
    final userId = _userId;
    final month = DateTime(_month.year, _month.month + months);
    final days = await _monthOf(userId, month);
    if (!mounted) return;
    setState(() {
      _month = month;
      _days = {for (final day in days) day.dayKey: day};
      // O foco da roda acompanha o mês: apontar para uma data que saiu da
      // tela deixaria o centro contando outra história.
      _focused = _month.year == _today.year && _month.month == _today.month
          ? _today
          : DateTime(month.year, month.month);
      _moons = _moonsFor(month);
    });
  }

  Future<void> _openDay(DateTime day) async {
    final existing = _days[MenstrualDay.keyOf(day)];
    _formError = null;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // A alça de arrasto é o segundo afordance de saída: no navegador,
      // arrastar a folha para baixo é invisível sem ela.
      showDragHandle: true,
      backgroundColor: context.gc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => MenstrualRecordForm(
          key: ValueKey('menstrual-form-${MenstrualDay.keyOf(day)}'),
          userId: _userId,
          day: day,
          existing: existing,
          saving: _saving,
          error: _formError,
          onSubmit: (record) async {
            setSheetState(() => _saving = true);
            final ok = await _save(record);
            if (!sheetContext.mounted) return;
            setSheetState(() => _saving = false);
            // Guardar primeiro, fechar depois: "registro salvo" quer dizer
            // que a gravação local terminou.
            if (ok) Navigator.of(sheetContext).pop();
          },
          // Sair sem gravar: nada foi escrito até aqui, então fechar basta.
          onCancel: () => Navigator.of(sheetContext).pop(),
          onDelete: existing == null
              ? null
              : () async {
                  await _repository.remove(userId: _userId, day: day);
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop();
                  await _refresh();
                  if (mounted) _say(AppLocalizations.of(context).menstrualDeleted);
                },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<bool> _save(MenstrualDay record) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _repository.save(record);
      await _refresh();
      if (mounted) _say(l10n.menstrualSaved);
      return true;
    } catch (_) {
      // O formulário continua na tela, com o que foi escrito.
      if (mounted) setState(() => _formError = l10n.menstrualSaveError);
      return false;
    }
  }

  /// A estação do dia. Escolher já é registrar: um dia sem linha ganha uma,
  /// com a marca de anotação — que não diz nada sobre sangramento. Tocar de
  /// novo na estação escolhida a desmarca, e desmarcar não apaga o resto.
  Future<bool> _chooseSeason(InternalSeason? season) async {
    final record = _todayRecord().copyWith(
      season: season,
      clearSeason: season == null,
    );
    return _persist(record);
  }

  /// A escrita que veio com o convite da estação. Fica no registro íntimo do
  /// dia: não vai para o Diário, para o acervo nem para a IA.
  Future<bool> _writeSeason(String text) async =>
      _persist(_todayRecord().copyWith(seasonNote: text));

  MenstrualDay _todayRecord() =>
      _days[MenstrualDay.keyOf(_today)] ??
      MenstrualDay(userId: _userId, day: _today, mark: MenstrualMark.note);

  Future<bool> _persist(MenstrualDay record) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _repository.save(record);
      await _refresh();
      return true;
    } catch (_) {
      if (mounted) _say(l10n.menstrualSaveError);
      return false;
    }
  }

  Future<void> _refresh() async {
    final userId = _userId;
    final days = await _monthOf(userId, _month);
    final history =
        _premium ? await _repository.all(userId) : const <MenstrualDay>[];
    if (!mounted) return;
    setState(() {
      _days = {for (final day in days) day.dayKey: day};
      _history = history;
    });
  }

  void _say(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final access = MenstrualAccess(
      gender: auth.currentUser.gender,
      consented: _consented,
      premium: auth.isPremiumEffective,
    );
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: Text(l10n.menstrualCardTitle),
        backgroundColor: context.gc.surface,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : access.canRecord
              ? _record(context, l10n, access)
              : _consent(context, l10n),
    );
  }

  Widget _consent(BuildContext context, AppLocalizations l10n) =>
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              key: const ValueKey('menstrual-consent'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.menstrualConsentTitle,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(color: context.gc.lilac)),
                  const SizedBox(height: 12),
                  Text(l10n.menstrualConsentBody,
                      style: TextStyle(color: context.gc.textPrimary, height: 1.5)),
                  const SizedBox(height: 12),
                  Text(l10n.menstrualConsentControl,
                      style: TextStyle(
                          color: context.gc.textSecondary, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const ValueKey('menstrual-consent-accept'),
                      onPressed: _accept,
                      child: Text(l10n.menstrualConsentAccept),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _record(
      BuildContext context, AppLocalizations l10n, MenstrualAccess access) {
    final todayRecord = _days[MenstrualDay.keyOf(_today)];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.menstrualTodayTitle,
                    style: TextStyle(color: context.gc.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  todayRecord == null
                      ? l10n.menstrualNoRecordToday
                      : _markOf(l10n, todayRecord.mark),
                  key: const ValueKey('menstrual-today'),
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: context.gc.textPrimary),
                ),
                if (todayRecord?.note.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(todayRecord!.note,
                      style: TextStyle(color: context.gc.textSecondary)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const ValueKey('menstrual-record-today'),
                    onPressed: () => _openDay(_today),
                    icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                    label: Text(l10n.menstrualRecordAction),
                  ),
                ),
              ],
            ),
          ),
          // A roda só existe onde a comparação existe; o calendário é a
          // alternativa explícita, e continua inteiro nas duas situações.
          if (access.canSeeDerived)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      key: const ValueKey('menstrual-view-toggle'),
                      segments: [
                        ButtonSegment(
                          value: false,
                          icon: const Icon(Icons.calendar_month_outlined, size: 16),
                          label: Text(l10n.menstrualViewCalendar),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: const Icon(Icons.brightness_2_outlined, size: 16),
                          label: Text(l10n.menstrualViewWheel),
                        ),
                      ],
                      selected: {_wheelView},
                      showSelectedIcon: false,
                      onSelectionChanged: (choice) =>
                          setState(() => _wheelView = choice.first),
                    ),
                  ),
                ],
              ),
            ),
          if (access.canSeeDerived && _wheelView)
            _wheel(context, l10n)
          else
            _calendar(context, l10n, access),
          // A estação é escolha simbólica, não resultado — mas é conteúdo
          // editorial, e por isso mora no Premium.
          if (access.canChooseSeason)
            MenstrualSeasonCard(
              record: todayRecord,
              invitesWinter: todayRecord?.mark == MenstrualMark.start ||
                  todayRecord?.mark == MenstrualMark.flow,
              onChoose: _chooseSeason,
              onWrite: _writeSeason,
            ),
          // Só aqui o histórico vira número — e só para quem tem acesso.
          if (access.canSeeDerived) ...[
            _derived(context, l10n),
            MenstrualLunarCard(insights: MenstrualInsights.of(_history)),
          ],
          if (access.showsGenericPremiumInvite)
            MagicalCard(
              key: const ValueKey('menstrual-premium-invite'),
              child: Text(
                l10n.menstrualPremiumInvite,
                style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }


  /// O que se calcula a partir do histórico. Esta parte da tela só é montada
  /// para quem tem acesso: no gratuito, nenhum destes números existe.
  Widget _derived(BuildContext context, AppLocalizations l10n) {
    final insights = MenstrualInsights.of(_history);
    final colors = context.gc;
    final cycleDay = insights.cycleDayOn(_today);
    final average = insights.averageIntervalDays;
    final range = insights.intervalRange;
    final reference = insights.nextReference(optedIn: _wantsNextReference);
    return MagicalCard(
      key: const ValueKey('menstrual-derived'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.menstrualDerivedTitle,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: colors.lilac, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (cycleDay != null)
            Text(l10n.menstrualCycleDayToday(cycleDay),
                key: const ValueKey('menstrual-cycle-day'),
                style: TextStyle(color: colors.textPrimary)),
          if (insights.hasSummary) ...[
            const SizedBox(height: 6),
            if (average != null)
              Text(l10n.menstrualObservedAverage(average),
                  key: const ValueKey('menstrual-average'),
                  style: TextStyle(color: colors.textPrimary)),
            if (range != null)
              Text(l10n.menstrualObservedRange(range.shortest, range.longest),
                  style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            // O tamanho da amostra anda junto dos números: um resumo sem ele
            // parece mais firme do que é.
            Text(l10n.menstrualObservedSample(insights.sampleSize),
                key: const ValueKey('menstrual-sample'),
                style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          ] else ...[
            const SizedBox(height: 6),
            Text(l10n.menstrualSummaryPending(insights.intervals.length),
                key: const ValueKey('menstrual-summary-pending'),
                style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          ],
          if (insights.hasSummary) ...[
            SwitchListTile(
              key: const ValueKey('menstrual-next-reference-switch'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.menstrualNextReferenceWanted,
                  style: TextStyle(color: colors.textPrimary, fontSize: 13)),
              value: _wantsNextReference,
              onChanged: (wanted) async {
                await widget.consent.setNextReferenceWanted(_userId, wanted);
                if (mounted) setState(() => _wantsNextReference = wanted);
              },
            ),
            if (reference != null) ...[
              Text(
                l10n.menstrualNextReference(
                    _readable(reference)),
                key: const ValueKey('menstrual-next-reference'),
                style: TextStyle(color: colors.textPrimary),
              ),
              // A data passou: dizer que a estimativa envelheceu, e nada
              // além disso. Sem somar um ciclo fictício, sem falar em atraso.
              if (insights.referenceIsStale(_today,
                  optedIn: _wantsNextReference))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.menstrualReferenceStale,
                    key: const ValueKey('menstrual-reference-stale'),
                    style: TextStyle(
                        color: colors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                ),
            ],
          ],
          const SizedBox(height: 10),
          Text(l10n.menstrualDerivedNote,
              style: TextStyle(
                  color: colors.textSecondary, fontSize: 11, height: 1.4)),
        ],
      ),
    );
  }

  static String _readable(DateTime day) =>
      '${day.day.toString().padLeft(2, '0')}/'
      '${day.month.toString().padLeft(2, '0')}/${day.year}';

  String _markOf(AppLocalizations l10n, MenstrualMark mark) => switch (mark) {
        MenstrualMark.start => l10n.menstrualMarkStart,
        MenstrualMark.flow => l10n.menstrualMarkFlow,
        MenstrualMark.spotting => l10n.menstrualMarkSpotting,
        MenstrualMark.end => l10n.menstrualMarkEnd,
        MenstrualMark.note => l10n.menstrualMarkNote,
      };

  /// As fases estimadas do mês inteiro, calculadas uma vez quando o mês
  /// muda. O calendário é redesenhado a cada toque, e refazer a conta de
  /// trinta dias dentro do build seria trabalho repetido a troco de nada.
  static Map<int, MoonPhase> _moonsFor(DateTime month) {
    final total = DateTime(month.year, month.month + 1, 0).day;
    return {
      for (var day = 1; day <= total; day++)
        // O registro não tem hora: o meio-dia local é convenção de cálculo,
        // não o horário de nada que aconteceu com ela.
        day: LunarProvider.phaseOn(DateTime(month.year, month.month, day, 12)),
    };
  }

  /// O mês na tela e os dois botões de virar — os mesmos na roda e no
  /// calendário, para que trocar de visão não mude a navegação.
  Widget _monthHeader(BuildContext context, AppLocalizations l10n) {
    final first = DateTime(_month.year, _month.month);
    return Row(
      children: [
        IconButton(
          key: const ValueKey('menstrual-previous-month'),
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left),
          tooltip: l10n.menstrualPreviousMonth,
        ),
        Expanded(
          child: Text(
            '${first.month.toString().padLeft(2, '0')}/${first.year}',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: context.gc.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          key: const ValueKey('menstrual-next-month'),
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right),
          tooltip: l10n.menstrualNextMonth,
        ),
      ],
    );
  }

  /// A roda do mês: o anel externo com a Lua estimada de cada dia e o interno
  /// só com o que ela registrou. A legenda distingue registro, estimativa e
  /// escolha por texto, não só por cor.
  Widget _wheel(BuildContext context, AppLocalizations l10n) {
    final focused = _days[MenstrualDay.keyOf(_focused)];
    return MagicalCard(
      key: const ValueKey('menstrual-wheel-card'),
      child: Column(
        children: [
          _monthHeader(context, l10n),
          const SizedBox(height: 8),
          Center(
            child: MenstrualWheel(
              month: _month,
              days: _days,
              selected: _focused,
              season: focused?.season == null
                  ? null
                  : MenstrualSeasonContentSource.of(focused!.season!).title,
              onSelect: (day) => setState(() => _focused = day),
              onOpen: _openDay,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.menstrualWheelLegend,
            style: TextStyle(
                color: context.gc.textSecondary, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _calendar(
      BuildContext context, AppLocalizations l10n, MenstrualAccess access) {
    final first = DateTime(_month.year, _month.month);
    final total = DateTime(_month.year, _month.month + 1, 0).day;
    // Segunda a domingo, como o restante do app.
    final leading = (first.weekday - 1) % 7;
    final cells = leading + total;
    final reduced = GrimoireMotion.reduced(context);
    return MagicalCard(
      key: const ValueKey('menstrual-calendar'),
      child: Column(
        children: [
          _monthHeader(context, l10n),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: cells,
            itemBuilder: (context, index) {
              if (index < leading) return const SizedBox.shrink();
              final day = DateTime(_month.year, _month.month, index - leading + 1);
              final record = _days[MenstrualDay.keyOf(day)];
              return _DayCell(
                day: day,
                record: record,
                isToday: day == _today,
                reduced: reduced,
                // Cruzar o que ela registrou com a Lua é comparação, e
                // comparação é Premium: no gratuito a Lua nem é calculada.
                moon: access.canSeeDerived ? _moons[day.day]?.emoji : null,
                moonName:
                    access.canSeeDerived ? _moons[day.day]?.displayName : null,
                onTap: () => _openDay(day),
              );
            },
          ),
          if (_days.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.menstrualEmptyMonth,
              key: const ValueKey('menstrual-empty-month'),
              style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
            ),
          ],
          if (access.canSeeDerived) ...[
            const SizedBox(height: 10),
            Text(
              l10n.menstrualMoonLegend,
              key: const ValueKey('menstrual-moon-legend'),
              style: TextStyle(
                  color: context.gc.textSecondary, fontSize: 11, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

/// Um dia do calendário: o número e, quando existe, a marca do registro.
/// Sem registro é sem registro — a célula não diz nada sobre o corpo.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.record,
    required this.isToday,
    required this.reduced,
    required this.moon,
    required this.moonName,
    required this.onTap,
  });

  final DateTime day;
  final MenstrualDay? record;
  final bool isToday;
  final bool reduced;

  /// A Lua estimada pelo app para este dia, quando a comparação é oferecida.
  /// É estimativa, e a legenda do calendário diz isso.
  final String? moon;

  /// O nome da mesma fase, para quem ouve a tela: o desenho fica fora da
  /// árvore semântica e o texto entra no lugar dele.
  final String? moonName;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.gc;
    final marked = record != null;
    return Semantics(
      button: true,
      label: moonName,
      child: InkWell(
        key: ValueKey('menstrual-day-${MenstrualDay.keyOf(day)}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: reduced ? Duration.zero : GrimoireMotion.state,
          decoration: BoxDecoration(
            color: marked ? colors.lilac.withValues(alpha: .22) : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isToday ? colors.gold : colors.surfaceBorder,
              width: isToday ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Altura de linha fixa nos dois textos: a célula do calendário
              // é quadrada e apertada, e a Lua não pode empurrar o número
              // para fora dela.
              if (moon != null)
                ExcludeSemantics(
                  child: Text(moon!,
                      style: const TextStyle(fontSize: 10, height: 1)),
                ),
              Text('${day.day}',
                  style: TextStyle(
                      color: colors.textPrimary, fontSize: 12, height: 1.1)),
              // A marca só existe depois que a gravação terminou, e ela
              // chega crescendo de leve — nunca antes do commit, nunca como
              // simulação de sangue, e a cor não indica gravidade.
              AnimatedScale(
                scale: marked ? 1 : 0,
                duration: reduced ? Duration.zero : GrimoireMotion.state,
                curve: Curves.easeOutBack,
                child: Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: colors.pink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
