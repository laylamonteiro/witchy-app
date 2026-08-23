import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../data/models/cycle_reading_model.dart';
import '../../data/services/cycle_reading_service.dart';

/// Seletor de período da Leitura do Ciclo, com MAPA DE CALOR.
///
/// Existe no lugar do `showDateRangePicker` do Flutter por um motivo só: o
/// picker padrao mostra dias vazios, todos iguais, e escolher periodo as
/// cegas e escolher mal. Aqui cada dia carrega a propria densidade de
/// registros — a pessoa ve onde a vida dela deixou marca e compra o pedaco
/// que tem o que ler.
///
/// Devolve a janela em `[start, end)` (fim exclusivo, como o resto da
/// feature). Como folha, devolve pelo `Navigator.pop`; embutida numa tela
/// ([embedded] com [onConfirm]), devolve pela chamada de volta — é assim que
/// a Leitura do Ciclo abre no calendário, com a escolha das datas ocupando a
/// primeira tela inteira.
class CyclePeriodPickerSheet extends StatefulWidget {
  /// Registros por dia (`yyyy-MM-dd` -> quantos), de
  /// `CycleReadingComposer.dailyRecordCounts`.
  final Map<String, int> dailyCounts;

  /// Preco ja formatado de cada produto (null = indisponivel na loja).
  final String? weekPrice;
  final String? lunationPrice;

  /// Vitalicio: em vez do preco, o rotulo de "incluido".
  final bool lifetimeIncluded;

  /// Primeiro dia navegavel (um ano atras, na chamada real).
  final DateTime firstDate;

  /// Ultimo dia escolhivel — hoje. Nao se le um ciclo nao vivido.
  final DateTime lastDate;

  /// Janela ja marcada ao abrir (o ciclo corrente, em geral): quem so quer
  /// "esta lunacao" confirma num toque, sem procurar os dias no calendario.
  final ({DateTime start, DateTime end})? initialRange;

  /// Embutido numa tela (sem a alcinha de folha e sem `pop` no confirmar).
  final bool embedded;

  /// Chamado no confirmar quando [embedded]; fora disso, o retorno vai pelo
  /// `Navigator.pop`.
  final ValueChanged<({DateTime start, DateTime end})>? onConfirm;

  const CyclePeriodPickerSheet({
    super.key,
    required this.dailyCounts,
    required this.firstDate,
    required this.lastDate,
    this.weekPrice,
    this.lunationPrice,
    this.lifetimeIncluded = false,
    this.initialRange,
    this.embedded = false,
    this.onConfirm,
  });

  @override
  State<CyclePeriodPickerSheet> createState() => _CyclePeriodPickerSheetState();
}

class _CyclePeriodPickerSheetState extends State<CyclePeriodPickerSheet> {
  // Abre no mes da janela ja marcada; sem ela, no mes corrente.
  late DateTime _visibleMonth = DateTime(
    (widget.initialRange?.start ?? widget.lastDate).year,
    (widget.initialRange?.start ?? widget.lastDate).month,
  );

  // A janela inicial chega com o fim EXCLUSIVO (padrao da feature); aqui
  // dentro o fim e o ultimo dia vivido, entao volta um dia.
  late DateTime? _start = widget.initialRange?.start;
  late DateTime? _end = widget.initialRange == null
      ? null
      : widget.initialRange!.end.subtract(const Duration(days: 1));

  /// Os cortes de intensidade do calor, em 3 faixas.
  ///
  /// NAO e proporcao ao dia mais cheio do ano: um unico dia excepcional
  /// (20 registros) achataria todos os outros para quase invisivel, e o
  /// calendario pareceria vazio para quem registra 2 ou 3 por dia — que e
  /// a pessoa normal. Aqui os cortes saem dos QUARTIS dos dias que tem
  /// algo, entao o calor sempre distingue "pouco", "medio" e "muito"
  /// dentro da escala real daquela pessoa.
  late final List<int> _thresholds = _computeThresholds();

  List<int> _computeThresholds() {
    final comRegistro = widget.dailyCounts.values.where((v) => v > 0).toList()
      ..sort();
    if (comRegistro.isEmpty) return const [1, 2, 3];
    int quantil(double q) =>
        comRegistro[((comRegistro.length - 1) * q).round()];
    // Cortes crescentes mesmo quando os quartis coincidem (poucos dias, ou
    // todos com a mesma contagem): sem isto, duas faixas empatadas fariam
    // dias iguais receberem tons diferentes por acaso da ordenacao.
    final baixo = quantil(0.33);
    final medio = quantil(0.66) > baixo ? quantil(0.66) : baixo + 1;
    final alto = comRegistro.last > medio ? comRegistro.last : medio + 1;
    return [baixo, medio, alto];
  }

  /// A opacidade do dia conforme a faixa em que ele cai.
  double _heatAlpha(int registros) {
    if (registros <= 0) return 0;
    if (registros <= _thresholds[0]) return 0.20;
    if (registros <= _thresholds[1]) return 0.40;
    return 0.62;
  }

  static String _key(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  int _countOn(DateTime day) => widget.dailyCounts[_key(day)] ?? 0;

  /// Quantos registros a janela escolhida abrange — mostra o que a pessoa
  /// ganha ao comprar exatamente aquele pedaco.
  int get _selectedRecords {
    final inicio = _start;
    if (inicio == null) return 0;
    final fim = _end ?? inicio;
    var total = 0;
    for (var d = inicio;
        !d.isAfter(fim);
        d = DateTime(d.year, d.month, d.day + 1)) {
      total += _countOn(d);
    }
    return total;
  }

  /// Dias INCLUSIVOS da selecao (13 a 19 = 7 dias).
  int get _selectedDays {
    final inicio = _start;
    if (inicio == null) return 0;
    final fim = _end ?? inicio;
    return fim.difference(inicio).inDays + 1;
  }

  /// O produto que a selecao vira — e o TAMANHO que decide, e mostrar isso
  /// antes da compra e o que evita a surpresa no caixa.
  String get _periodType => _selectedDays <= 8
      ? CycleReadingPeriodType.week
      : CycleReadingPeriodType.lunation;

  bool get _tooLong => _selectedDays > CycleReadingService.maxCustomPeriodDays;

  /// A janela precisa estar FECHADA e ter mais de um dia: um toque só deixa
  /// a seleção pela metade, e uma leitura de 24 horas não tem ciclo para
  /// contar. Enquanto isso não estiver de pé, o confirmar fica apagado e o
  /// resumo diz o que falta.
  bool get _canConfirm =>
      _start != null && _end != null && _selectedDays > 1 && !_tooLong;

  void _tapDay(DateTime day) {
    setState(() {
      final inicio = _start;
      // Regra do toque: sem inicio, o primeiro toque abre a janela; com
      // inicio e sem fim, o segundo fecha; qualquer toque depois disso (ou
      // antes do inicio) recomeca. E o comportamento que a pessoa ja
      // conhece de outros seletores de intervalo.
      if (inicio == null || _end != null || day.isBefore(inicio)) {
        _start = day;
        _end = null;
      } else {
        _end = day;
      }
    });
  }

  /// Um dia nunca além do último escolhível (hoje) nem antes do primeiro.
  DateTime _clampDay(DateTime day) {
    if (day.isAfter(widget.lastDate)) return widget.lastDate;
    if (day.isBefore(widget.firstDate)) return widget.firstDate;
    return day;
  }

  /// O mês visível inteiro (aparado em hoje, se o mês ainda corre).
  ({DateTime start, DateTime end}) get _janelaDoMes => (
        start: _clampDay(DateTime(_visibleMonth.year, _visibleMonth.month, 1)),
        end: _clampDay(
          DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0),
        ),
      );

  /// Os 7 primeiros dias do mês visível (a "primeira semana").
  ({DateTime start, DateTime end}) get _janelaDaSemana => (
        start: _clampDay(DateTime(_visibleMonth.year, _visibleMonth.month, 1)),
        end: _clampDay(DateTime(_visibleMonth.year, _visibleMonth.month, 7)),
      );

  bool _selecionou(({DateTime start, DateTime end}) janela) =>
      _start != null &&
      _sameDay(_start!, janela.start) &&
      _end != null &&
      _sameDay(_end!, janela.end);

  void _aplicarJanela(({DateTime start, DateTime end}) janela) {
    setState(() {
      _start = janela.start;
      _end = janela.end;
    });
  }

  void _limparSelecao() {
    setState(() {
      _start = null;
      _end = null;
    });
  }

  Widget _buildPresets(AppLocalizations l10n) {
    Widget atalho(String rotulo, bool ativo, VoidCallback aoTocar) => Expanded(
          child: OutlinedButton(
            onPressed: aoTocar,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              visualDensity: VisualDensity.compact,
              foregroundColor:
                  ativo ? context.gc.onPrimary : context.gc.lilac,
              backgroundColor: ativo
                  ? context.gc.lilac.withValues(alpha: 0.85)
                  : Colors.transparent,
              side: BorderSide(
                color: context.gc.lilac.withValues(alpha: ativo ? 1 : 0.45),
              ),
              textStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(rotulo, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        );

    return Row(
      children: [
        atalho(
          l10n.cyclePreset30Days,
          _selecionou(_janelaDoMes),
          () => _aplicarJanela(_janelaDoMes),
        ),
        const SizedBox(width: 6),
        atalho(
          l10n.cyclePreset7Days,
          _selecionou(_janelaDaSemana),
          () => _aplicarJanela(_janelaDaSemana),
        ),
        const SizedBox(width: 6),
        atalho(l10n.cyclePresetOther, _start == null, _limparSelecao),
      ],
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  bool get _canGoBack => !DateTime(_visibleMonth.year, _visibleMonth.month)
      .isBefore(DateTime(widget.firstDate.year, widget.firstDate.month + 1));

  bool get _canGoForward => DateTime(_visibleMonth.year, _visibleMonth.month)
      .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Embutido, quem rola e a distancia das bordas sao da tela que hospeda:
    // um scroll dentro de outro no mesmo eixo trava o gesto.
    return _Envolucro(
      embedded: widget.embedded,
      child: Padding(
        padding: widget.embedded
            ? EdgeInsets.zero
            : const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.embedded)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: context.gc.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            Text(
              l10n.cycleReadingCustomPeriodTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.cycleReadingHeatLegend,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
            const SizedBox(height: 10),
            // Os três atalhos ANTES do calendário (decisão da dona, 23/08):
            // quem quer o mês inteiro ou uma semana não precisa desenhar a
            // janela dia a dia — e "Outro período" limpa tudo e devolve o
            // calendário para a escolha a dedo.
            _buildPresets(l10n),
            const SizedBox(height: 8),
            _buildMonthHeader(l10n),
            const SizedBox(height: 4),
            _buildWeekdayRow(),
            const SizedBox(height: 4),
            _buildGrid(),
            const SizedBox(height: 8),
            _buildSummary(l10n),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _canConfirm ? _confirm : null,
              child: Text(l10n.cycleReadingCustomPeriodConfirm),
            ),
          ],
        ),
      ),
    );
  }

  void _confirm() {
    final inicio = _start!;
    final fim = _end ?? inicio;
    final janela = (
      start: DateTime(inicio.year, inicio.month, inicio.day),
      // Fim EXCLUSIVO: o dia escolhido e vivido por inteiro, entao a janela
      // vai ate a meia-noite seguinte.
      end: DateTime(fim.year, fim.month, fim.day).add(const Duration(days: 1)),
    );
    final aoConfirmar = widget.onConfirm;
    if (aoConfirmar != null) {
      aoConfirmar(janela);
      return;
    }
    Navigator.of(context).pop(janela);
  }

  Widget _buildMonthHeader(AppLocalizations l10n) {
    final nome = DateFormat.yMMMM(l10n.localeName).format(_visibleMonth);
    return Row(
      children: [
        IconButton(
          onPressed: _canGoBack ? () => _changeMonth(-1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            // Primeira letra maiuscula: DateFormat devolve "agosto de 2026"
            // em pt, e como titulo fica melhor "Agosto de 2026".
            nome.isEmpty
                ? nome
                : '${nome[0].toUpperCase()}${nome.substring(1)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        IconButton(
          onPressed: _canGoForward ? () => _changeMonth(1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow() {
    // Iniciais do idioma ativo, comecando no domingo (como o grid abaixo).
    final simbolos = DateFormat.EEEE(
      Localizations.localeOf(context).toLanguageTag(),
    ).dateSymbols.NARROWWEEKDAYS;
    return Row(
      children: [
        for (final dia in simbolos)
          Expanded(
            child: Center(
              child: Text(
                dia,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.gc.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGrid() {
    final primeiro = DateTime(_visibleMonth.year, _visibleMonth.month);
    // weekday: 1=segunda ... 7=domingo. O grid comeca no domingo, entao o
    // domingo (7) precisa de zero espacos a frente.
    final vazios = primeiro.weekday % 7;
    final diasNoMes =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 3,
      crossAxisSpacing: 3,
      // Mais largo que alto: o calendário deixa de tomar a tela inteira
      // (decisão da dona, 23/08) e o resto da página aparece na abertura.
      childAspectRatio: 1.45,
      children: [
        for (var i = 0; i < vazios; i++) const SizedBox.shrink(),
        for (var dia = 1; dia <= diasNoMes; dia++)
          _buildDayCell(DateTime(_visibleMonth.year, _visibleMonth.month, dia)),
      ],
    );
  }

  Widget _buildDayCell(DateTime day) {
    final foraDaFaixa = day.isAfter(widget.lastDate) ||
        day.isBefore(DateTime(
          widget.firstDate.year,
          widget.firstDate.month,
          widget.firstDate.day,
        ));
    final registros = _countOn(day);
    final inicio = _start;
    final fim = _end;
    final ehInicio = inicio != null && _sameDay(day, inicio);
    final ehFim = fim != null && _sameDay(day, fim);
    final noMeio =
        inicio != null && fim != null && day.isAfter(inicio) && day.isBefore(fim);
    final selecionado = ehInicio || ehFim || noMeio;

    // O calor por faixa (ver _thresholds): um unico registro ja aparece,
    // senao o mapa mentiria por omissao.
    final calor = registros == 0
        ? Colors.transparent
        : context.gc.lilac.withValues(alpha: _heatAlpha(registros));

    return InkWell(
      onTap: foraDaFaixa ? null : () => _tapDay(day),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: selecionado ? context.gc.lilac.withValues(alpha: 0.85) : calor,
          borderRadius: BorderRadius.circular(8),
          border: (ehInicio || ehFim)
              ? Border.all(color: context.gc.lilac, width: 2)
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: foraDaFaixa
                          ? context.gc.textSecondary.withValues(alpha: 0.4)
                          : selecionado
                              ? context.gc.onPrimary
                              : context.gc.textPrimary,
                      fontWeight:
                          registros > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
              // O ponto confirma o calor para quem nao distingue o tom (e
              // para daltonicos): cor sozinha nao pode ser a unica pista.
              if (registros > 0)
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        selecionado ? context.gc.onPrimary : context.gc.lilac,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(AppLocalizations l10n) {
    if (_start == null) {
      return Text(
        l10n.cycleReadingCustomPeriodHint,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.gc.textSecondary,
            ),
      );
    }
    if (_tooLong) {
      return Text(
        l10n.cycleReadingRejectTooLong,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.gc.alert,
            ),
      );
    }
    // Janela pela metade (um toque só): o resumo some e o confirmar fica
    // apagado. Sem frase explicando — a pessoa toca o segundo dia e
    // descobre sozinha; instrução para um gesto óbvio é ruído.
    if (_end == null || _selectedDays <= 1) return const SizedBox.shrink();

    final semana = _periodType == CycleReadingPeriodType.week;
    final produto =
        semana ? l10n.cycleReadingWeekTitle : l10n.cycleReadingLunationTitle;
    final preco = widget.lifetimeIncluded
        ? l10n.cycleReadingLifetimeTag
        : (semana ? widget.weekPrice : widget.lunationPrice);

    // Uma linha so: a caixa grande que vivia aqui parecia um botao e foi
    // substituida pelos atalhos ACIMA do calendario (decisao da dona,
    // 23/08). Qual produto a selecao vira continua a vista antes do
    // confirmar — decidido pelo tamanho, sem surpresa no caixa.
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: preco == null ? produto : '$produto - $preco',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextSpan(
            text: ' · ${l10n.cycleReadingSelectionSummary(
              _selectedDays,
              _selectedRecords,
            )}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Como folha, o seletor cuida da area segura e da propria rolagem; embutido
/// numa tela, quem rola e a tela.
class _Envolucro extends StatelessWidget {
  const _Envolucro({required this.embedded, required this.child});

  final bool embedded;
  final Widget child;

  @override
  Widget build(BuildContext context) => embedded
      ? child
      : SafeArea(child: SingleChildScrollView(child: child));
}
