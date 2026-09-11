import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/moon_disc.dart';
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
import '../widgets/menstrual_record_form.dart';
import '../widgets/menstrual_season_card.dart';
import '../widgets/menstrual_wheel.dart';

/// A roda pessoal: o registro do próprio ciclo.
///
/// Antes de qualquer coisa, o consentimento — e ele explica o que é gratuito
/// (registrar, consultar, corrigir, exportar e apagar) e o que é Premium (a
/// roda do mês, a Lua estimada de cada dia e as Estações Internas). Recusar
/// não apaga nada.
///
/// O calendário mostra só os dias que a pessoa registrou. Um dia vazio é
/// ausência de registro, e a tela não conta, não soma e não estima nada a
/// partir do histórico: média, dia do ciclo, referência de próxima data e
/// comparação com a Lua saíram daqui de vez — não foram escondidas atrás de
/// um retrátil, e o histórico inteiro deixou de ser lido para isso.
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

  bool _loading = true;
  bool _consented = false;
  bool _saving = false;
  String? _formError;

  /// A explicação sobre a menstruação começa recolhida: no navegador a dobra
  /// é curta, e o que ela veio fazer aqui primeiro é registrar.
  bool _aboutOpen = false;

  /// A roda é uma alternativa oferecida, não a única porta: quem não quiser
  /// explorá-la fica no calendário do mês, que continua completo.
  bool _wheelView = false;

  /// O dia em foco na roda. O calendário não tem foco — ele abre o dia que
  /// for tocado.
  late DateTime _focused = _today;

  /// As fases estimadas do mês na tela, prontas antes do desenho.
  late Map<int, MoonPhase> _moons = _moonsFor(_month);

  String get _userId => context.read<AuthProvider>().currentUser.id;

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
      // Só o mês na tela é lido. O histórico inteiro era matéria-prima do
      // que se calculava; sem cálculo, pedi-lo seria abrir o registro dela
      // sem ter o que fazer com ele.
      if (!mounted) return;
      setState(() {
        _consented = consented;
        _days = {for (final day in days) day.dayKey: day};
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
  /// dia e não vai para o Diário; só sai daqui quando a própria pessoa a
  /// inclui numa Leitura do Ciclo, ligando a chave das palavras.
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
    if (!mounted) return;
    setState(() {
      _days = {for (final day in days) day.dayKey: day};
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
          // Onde antes o histórico virava número, agora há palavra: o que é
          // menstruar, o que já foi lido nisso e o que a bruxaria faz com o
          // assunto. Fecha a página para os dois planos.
          _about(context, l10n, access),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// A menstruação em palavras: o que ela é, o que já foi lido nela e por que
  /// a bruxaria olha para o sangue. Texto fixo — não lê registro nenhum, não
  /// calcula nada e não muda com o plano.
  ///
  /// Sem gate de acesso, de propósito: isto não é resultado calculado nem
  /// catálogo curado, é a explicação do corpo de quem está lendo, e cobrar
  /// assinatura para dizer o que é menstruar seria vender de volta o que já é
  /// dela. O convite Premium, quando existe, fecha ESTE card em vez de abrir
  /// outro — dois cards saíram da tela, e a página do gratuito (que é a que
  /// roda no navegador, de dobra curta) não pode voltar mais longa do que era.
  ///
  /// O texto mora no ARB, e não na camada de conteúdo (menstrual_phase_content
  /// _pt/_en/_es.dart): aquela camada é catálogo — itens com identidade
  /// estável, ordem e correspondências que a Enciclopédia resolve, e é isso
  /// que o teste de paridade dela verifica. Isto aqui é texto fixo de uma
  /// tela, sem item nem chave de curadoria, e o ARB ainda cobre o pt_BR, que
  /// a camada de conteúdo não tem (ela cai no pt). A fronteira de vocabulário
  /// que a camada ganha de graça, este texto ganha em
  /// test/menstrual_about_text_test.dart.
  Widget _about(
      BuildContext context, AppLocalizations l10n, MenstrualAccess access) {
    final colors = context.gc;
    final theme = Theme.of(context);
    final body = TextStyle(color: colors.textPrimary, height: 1.5);
    final head = TextStyle(
        color: colors.lilac, fontSize: 12, fontWeight: FontWeight.bold);
    return MagicalCard(
      key: const ValueKey('menstrual-about'),
      onTap: () => setState(() => _aboutOpen = !_aboutOpen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_outlined, size: 18, color: colors.lilac),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.menstrualAboutTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.lilac, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(_aboutOpen ? Icons.expand_less : Icons.expand_more,
                  size: 20, color: colors.textSecondary),
            ],
          ),
          AnimatedSize(
            duration: GrimoireMotion.reduced(context)
                ? Duration.zero
                : GrimoireMotion.state,
            curve: GrimoireMotion.enter,
            alignment: Alignment.topCenter,
            child: !_aboutOpen
                ? const SizedBox(width: double.infinity)
                : Column(
                    key: const ValueKey('menstrual-about-text'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(l10n.menstrualAboutOpening, style: body),
                      const SizedBox(height: 14),
                      Text(l10n.menstrualAboutMeaningTitle, style: head),
                      const SizedBox(height: 4),
                      Text(l10n.menstrualAboutMeaning, style: body),
                      const SizedBox(height: 14),
                      Text(l10n.menstrualAboutMoonTitle, style: head),
                      const SizedBox(height: 4),
                      Text(l10n.menstrualAboutMoon, style: body),
                      const SizedBox(height: 14),
                      Text(l10n.menstrualAboutCraftTitle, style: head),
                      const SizedBox(height: 4),
                      Text(l10n.menstrualAboutCraft, style: body),
                      const SizedBox(height: 14),
                      Text(
                        l10n.menstrualAboutNote,
                        style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 11,
                            height: 1.4),
                      ),
                    ],
                  ),
          ),
          if (access.showsGenericPremiumInvite) ...[
            const SizedBox(height: 10),
            Text(
              l10n.menstrualPremiumInvite,
              key: const ValueKey('menstrual-premium-invite'),
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ],
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
                moon: access.canSeeDerived ? _moons[day.day] : null,
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
  final MoonPhase? moon;

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
                // Desenhada, não o glifo da fonte: a mesma lua da roda e de
                // Seu Dia. O glifo mudava de arte entre aparelho e navegador,
                // e trocar de visão não pode trocar a lua de desenho.
                MoonDisc(phase: moon!, size: 10, halo: false),
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
