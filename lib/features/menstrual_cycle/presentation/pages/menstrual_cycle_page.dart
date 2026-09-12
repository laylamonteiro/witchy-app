import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/moon_glyph.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../data/menstrual_consent_store.dart';
import '../../data/menstrual_mood_labels.dart';
import '../../data/repositories/menstrual_cycle_repository.dart';
import '../../domain/lunar_comparison.dart';
import '../../domain/menstrual_access.dart';
import '../../domain/menstrual_day.dart';
import '../menstrual_type.dart';
import '../widgets/lua_e_voce_card.dart';
import '../widgets/menstrual_record_form.dart';
import '../widgets/menstrual_wheel.dart';

/// A página do Ciclo, numa folha só: a abertura sagrada, o dia de hoje com a
/// Lua dele, "A Lua e você" e o mês — calendário para todo mundo, roda para
/// o Premium.
///
/// Antes de qualquer coisa, o consentimento. Recusar não apaga nada.
///
/// O calendário mostra só os dias que a pessoa registrou; a Lua de cada dia
/// é a mesma do calendário lunar do app, e aparece para todo mundo. Nada
/// aqui conta, soma ou projeta a partir do histórico: o que "A Lua e você"
/// diz é o que ela marcou, ao lado da Lua daquele dia.
///
/// Cada dia gravado aqui ganha uma página em "Meus Registros", no Grimório —
/// e cada dia apagado a perde. Nenhuma tela decide isso: quem escreve e
/// apaga o espelho é o próprio MenstrualCycleRepository, para que os três
/// caminhos que mexem na linha (esta folha, o apagar dela e o "apagar meus
/// registros do ciclo") não possam divergir.
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

  /// O mês na tela, por dia.
  Map<String, MenstrualDay> _days = const {};

  /// O histórico inteiro, vivo: o que "A Lua e você" lê.
  List<MenstrualDay> _history = const [];

  bool _loading = true;
  bool _consented = false;
  bool _saving = false;
  String? _formError;

  /// O ensaio da abertura começa recolhido: a dobra é curta, e o que ela
  /// veio fazer aqui primeiro é registrar.
  bool _aboutOpen = false;

  /// A roda é uma alternativa oferecida, não a única porta: quem não quiser
  /// explorá-la fica no calendário do mês, que continua completo.
  bool _wheelView = false;

  /// O dia em foco na roda. O calendário não tem foco — ele abre o dia que
  /// for tocado.
  late DateTime _focused = _today;

  /// As fases do mês na tela, prontas antes do desenho.
  late Map<int, MoonPhase> _moons = _moonsFor(_month);

  String get _userId => context.read<AuthProvider>().currentUser.id;

  static DateTime _dayOf(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// A Lua de um dia registrado. O registro não tem hora: o meio-dia local
  /// é a convenção de cálculo de toda a área, não o horário de nada que
  /// aconteceu com ela.
  static MoonPhase _phaseOf(DateTime day) =>
      LunarProvider.phaseOn(LunarComparison.noonOf(day));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = _userId;
    try {
      final consented = await widget.consent.recordingAllowed(userId);
      final days =
          consented ? await _monthOf(userId, _month) : const <MenstrualDay>[];
      final history =
          consented ? await _repository.history(userId) : const <MenstrualDay>[];
      if (!mounted) return;
      setState(() {
        _consented = consented;
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
            // Guardar primeiro, fechar depois: "guardado" quer dizer que a
            // gravação local terminou.
            if (ok) Navigator.of(sheetContext).pop();
          },
          // Sair sem gravar: nada foi escrito até aqui, então fechar basta —
          // e, como a página do Grimório só nasce dentro de
          // `MenstrualCycleRepository.save`, cancelar também não deixa
          // página nenhuma para trás.
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
      if (mounted) _say(l10n.menstrualSaved(_phaseOf(record.day).displayName));
      return true;
    } catch (_) {
      // O formulário continua na tela, com o que foi escrito.
      if (mounted) setState(() => _formError = l10n.menstrualSaveError);
      return false;
    }
  }

  /// Relê o mês na tela e o histórico: um dia gravado ou apagado muda os
  /// dois — o calendário e o que "A Lua e você" tem para dizer.
  Future<void> _refresh() async {
    final userId = _userId;
    final days = await _monthOf(userId, _month);
    final history = await _repository.history(userId);
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
                      style: MenstrualType.cardTitle(context)),
                  const SizedBox(height: 12),
                  Text(l10n.menstrualConsentBody,
                      style: MenstrualType.body(context)),
                  const SizedBox(height: 12),
                  Text(l10n.menstrualConsentControl,
                      style: MenstrualType.quiet(context)),
                  const SizedBox(height: 16),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _opening(context, l10n),
          _todayCard(context, l10n),
          LuaEVoceCard(days: _history, today: _today),
          // A roda só existe para o Premium; o calendário é a alternativa
          // explícita, e continua inteiro nas duas situações.
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
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// A abertura sagrada: o título, duas linhas sobre o sangue e, para quem
  /// quiser ler mais, o ensaio "A menstruação e a bruxaria" no mesmo card.
  ///
  /// Sem gate de acesso, de propósito: isto é a explicação do corpo de quem
  /// está lendo, e cobrar assinatura para dizer o que é menstruar seria
  /// vender de volta o que já é dela. O texto mora no ARB, e não numa camada
  /// de conteúdo: é texto fixo de uma tela, sem item nem chave de curadoria,
  /// e o ARB ainda cobre o pt_BR. A fronteira de vocabulário mora em
  /// test/menstrual_about_text_test.dart.
  Widget _opening(BuildContext context, AppLocalizations l10n) {
    final colors = context.gc;
    final body = MenstrualType.body(context);
    final head = MenstrualType.sectionHead(context);
    return MagicalCard(
      key: const ValueKey('menstrual-opening'),
      onTap: () => setState(() => _aboutOpen = !_aboutOpen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.menstrualOpeningTitle,
              style: MenstrualType.cardTitle(context)),
          const SizedBox(height: 12),
          Text(l10n.menstrualOpeningLine, style: body),
          _abrindo(
            context,
            !_aboutOpen
                ? const SizedBox(width: double.infinity)
                : Column(
                    key: const ValueKey('menstrual-about-text'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(l10n.menstrualAboutMeaningTitle, style: head),
                      const SizedBox(height: 8),
                      Text(l10n.menstrualAboutMeaning, style: body),
                      const SizedBox(height: 12),
                      Text(l10n.menstrualAboutMoonTitle, style: head),
                      const SizedBox(height: 8),
                      Text(l10n.menstrualAboutMoon, style: body),
                      const SizedBox(height: 12),
                      Text(l10n.menstrualAboutCraftTitle, style: head),
                      const SizedBox(height: 8),
                      Text(l10n.menstrualAboutCraft, style: body),
                      const SizedBox(height: 12),
                      Text(l10n.menstrualAboutNote,
                          style: MenstrualType.caption(context)),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _aboutOpen ? l10n.menstrualReadLess : l10n.menstrualReadMore,
                key: const ValueKey('menstrual-read-more'),
                style: head,
              ),
              const SizedBox(width: 4),
              Icon(_aboutOpen ? Icons.expand_less : Icons.expand_more,
                  size: 18, color: colors.lilac),
            ],
          ),
        ],
      ),
    );
  }

  /// Hoje: a data por extenso e a Lua do dia — a única lua protagonista da
  /// página —, o que ela marcou, como está e a palavra que deixou.
  Widget _todayCard(BuildContext context, AppLocalizations l10n) {
    final colors = context.gc;
    final todayRecord = _days[MenstrualDay.keyOf(_today)];
    final phase = _phaseOf(_today);
    final mood = todayRecord?.mood?.trim() ?? '';
    final note = todayRecord?.note.trim() ?? '';
    return MagicalCard(
      key: const ValueKey('menstrual-today-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${MaterialLocalizations.of(context).formatFullDate(_today)}'
                      ' · ${phase.displayName}',
                      key: const ValueKey('menstrual-today-moon'),
                      style: MenstrualType.eyebrow(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      todayRecord == null
                          ? l10n.menstrualNoRecordToday
                          : _markOf(l10n, todayRecord.mark),
                      key: const ValueKey('menstrual-today'),
                      // O valor do dia: o mesmo peso que a aba Ciclos dá ao
                      // que vem debaixo de uma linha discreta.
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                    if (mood.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.menstrualTodayMood(menstrualMoodLabel(l10n, mood)),
                        key: const ValueKey('menstrual-today-mood'),
                        style: MenstrualType.body(context),
                      ),
                    ],
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(note, style: MenstrualType.quiet(context)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MoonGlyph(phase: phase, size: 40),
            ],
          ),
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
    );
  }

  String _markOf(AppLocalizations l10n, MenstrualMark mark) => switch (mark) {
        MenstrualMark.start => l10n.menstrualMarkStart,
        MenstrualMark.flow => l10n.menstrualMarkFlow,
        MenstrualMark.spotting => l10n.menstrualMarkSpotting,
        MenstrualMark.end => l10n.menstrualMarkEnd,
        MenstrualMark.note => l10n.menstrualMarkNote,
      };

  /// As fases do mês inteiro, calculadas uma vez quando o mês muda. O
  /// calendário é redesenhado a cada toque, e refazer a conta de trinta
  /// dias dentro do build seria trabalho repetido a troco de nada.
  static Map<int, MoonPhase> _moonsFor(DateTime month) {
    final total = DateTime(month.year, month.month + 1, 0).day;
    return {
      for (var day = 1; day <= total; day++)
        day: _phaseOf(DateTime(month.year, month.month, day)),
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
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: context.gc.textPrimary),
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

  /// A roda do mês: o anel externo com a Lua de cada dia e o interno só com
  /// o que ela registrou.
  Widget _wheel(BuildContext context, AppLocalizations l10n) {
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
              onSelect: (day) => setState(() => _focused = day),
              onOpen: _openDay,
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.menstrualWheelLegend,
              style: MenstrualType.caption(context)),
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
              // A Lua de cada dia é a mesma do calendário lunar do app, e é
              // de todo mundo: aqui ela é visual, não comparação.
              final moon = _moons[day.day]!;
              return _DayCell(
                day: day,
                record: record,
                isToday: day == _today,
                reduced: reduced,
                moon: moon,
                moonName: moon.displayName,
                onTap: () => _openDay(day),
              );
            },
          ),
          if (_days.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.menstrualEmptyMonth,
              key: const ValueKey('menstrual-empty-month'),
              style: MenstrualType.quiet(context),
            ),
          ],
          if (access.showsGenericPremiumInvite) ...[
            const SizedBox(height: 12),
            Text(
              l10n.menstrualPremiumInvite,
              key: const ValueKey('menstrual-premium-invite'),
              style: MenstrualType.quiet(context),
            ),
          ],
        ],
      ),
    );
  }
}

/// Um dia do calendário: a Lua dele, o número e, quando existe, a marca do
/// registro — sangue é disco cheio, escape é contorno, fim é barra e
/// anotação é ponto. Sem registro é sem registro.
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

  /// A Lua deste dia, a mesma do calendário lunar do app.
  final MoonPhase moon;

  /// O nome da mesma fase, para quem ouve a tela: o desenho fica fora da
  /// árvore semântica e o texto entra no lugar dele.
  final String moonName;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.gc;
    final mark = record?.mark;
    final blood = mark == MenstrualMark.start || mark == MenstrualMark.flow;
    final spotting = mark == MenstrualMark.spotting;
    final duration = reduced ? Duration.zero : GrimoireMotion.state;
    return Semantics(
      button: true,
      label: moonName,
      child: InkWell(
        key: ValueKey('menstrual-day-${MenstrualDay.keyOf(day)}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // Hoje é um anel lilac fino; os outros dias, a borda da superfície.
            border: Border.all(
              color: isToday ? colors.lilac : colors.surfaceBorder,
              width: isToday ? 1.4 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // A mesma lua de Seu Dia e da página da Lua: o glifo da fase,
              // sem halo — um brilho aqui borraria o número do dia abaixo.
              //
              // A coluna soma 32dp (10 + 18 + 4) dentro de uma célula que, a
              // 360dp de largura, tem ~37dp de miolo; abaixo de ~320dp o
              // Flutter acusaria estouro. Os tamanhos são o que cabe, não
              // gosto.
              MoonGlyph(phase: moon, size: 10, halo: false),
              // O disco só existe depois que a gravação terminou, e chega
              // trocando de cor de leve — nunca antes do commit. Cheio nos
              // dias de sangue, contorno no escape, e o número por cima,
              // em contraste quando o fundo é a cor do sangue.
              AnimatedContainer(
                duration: duration,
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: blood ? colors.pink : null,
                  border: spotting
                      ? Border.all(color: colors.pink, width: 1.4)
                      : null,
                ),
                child: Text('${day.day}',
                    style: TextStyle(
                        color: blood ? colors.onPrimary : colors.textPrimary,
                        fontSize: 12,
                        fontWeight: blood ? FontWeight.bold : null,
                        height: 1.1)),
              ),
              // Fim é barra curta; anotação é ponto. O espaço existe sempre,
              // para a Lua e o número não pularem entre um dia e outro.
              SizedBox(
                height: 4,
                child: switch (mark) {
                  MenstrualMark.end => Container(
                      width: 10,
                      height: 2,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: colors.pink,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  MenstrualMark.note => Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.pink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  _ => null,
                },
              ),
            ],
          ),
        ),
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
