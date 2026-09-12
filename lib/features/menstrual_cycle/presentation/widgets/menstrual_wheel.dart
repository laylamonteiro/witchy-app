import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../domain/lunar_comparison.dart';
import '../../domain/menstrual_day.dart';
import '../menstrual_type.dart';

/// A roda do mês, com dois anéis na MESMA escala de datas.
///
/// O anel externo mostra a Lua de cada dia do intervalo; o interno
/// mostra somente os registros reais desse mesmo intervalo. Não há anel de 28
/// dias esticado até coincidir com uma lunação: o intervalo é o mês que está
/// na tela, e um dia é um dia nos dois anéis.
///
/// O centro mostra o dia em foco. Registro e estimativa se distinguem por
/// forma e por texto, não só por cor — a legenda fica fora da roda, na
/// página.
///
/// O dedo percorre as datas na horizontal, para não disputar com a rolagem
/// vertical nem com o gesto de voltar; o teclado percorre com as setas e abre
/// com Enter. O cursor acompanha o gesto sem easing, e soltar nunca altera
/// registro nenhum.
class MenstrualWheel extends StatefulWidget {
  const MenstrualWheel({
    super.key,
    required this.month,
    required this.days,
    required this.selected,
    required this.onSelect,
    required this.onOpen,
    this.size = 260,
  });

  /// O mês desenhado (dia 1 em diante).
  final DateTime month;

  /// Os registros do mês, por chave de dia.
  final Map<String, MenstrualDay> days;

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<DateTime> onOpen;

  final double size;

  @override
  State<MenstrualWheel> createState() => _MenstrualWheelState();
}

class _MenstrualWheelState extends State<MenstrualWheel> {
  /// O cursor mora aqui para acompanhar o dedo no mesmo quadro: esperar a
  /// página reconstruir colocaria um atraso entre o gesto e a linha.
  late int _index = _indexOf(widget.selected);

  /// Tocar a roda também entrega o teclado a ela: quem chegou pelo dedo pode
  /// continuar pelas setas sem procurar onde o foco foi parar.
  final FocusNode _node = FocusNode(debugLabel: 'menstrual-wheel');

  /// Quanto da Lua está iluminado em cada dia do mês, de 0 (Nova) a 1
  /// (Cheia). Fica pronto antes do desenho: a roda é repintada a cada passo
  /// do dedo, e refazer trinta contas por quadro seria trabalho à toa.
  late List<double> _lights = _lightsFor(widget.month);

  static List<double> _lightsFor(DateTime month) {
    final total = DateTime(month.year, month.month + 1, 0).day;
    return [
      for (var day = 1; day <= total; day++)
        (1 -
                math.cos(2 *
                    math.pi *
                    LunarProvider.lunationPositionOn(LunarComparison.noonOf(
                        DateTime(month.year, month.month, day))))) /
            2,
    ];
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  int get _total => DateTime(widget.month.year, widget.month.month + 1, 0).day;

  int _indexOf(DateTime day) => day.year == widget.month.year &&
          day.month == widget.month.month
      ? day.day - 1
      : 0;

  @override
  void didUpdateWidget(MenstrualWheel old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected || old.month != widget.month) {
      _index = _indexOf(widget.selected);
    }
    if (old.month != widget.month) _lights = _lightsFor(widget.month);
  }

  DateTime _dayAt(int index) =>
      DateTime(widget.month.year, widget.month.month, index + 1);

  /// O dia sob o dedo, ou nada quando o toque cai no centro — ali não há
  /// data, e mexer o cursor por causa disso seria mexer sem ela pedir.
  DateTime? _dayFromOffset(Offset local) {
    final centre = Offset(widget.size / 2, widget.size / 2);
    final vector = local - centre;
    if (vector.distance < widget.size * .18) return null;
    // O topo é o dia 1, e o tempo anda no sentido do relógio.
    final angle = math.atan2(vector.dy, vector.dx) + math.pi / 2;
    final turn = (angle / (2 * math.pi)) % 1;
    return _dayAt((turn * _total).round() % _total);
  }

  void _select(DateTime day) {
    final index = _indexOf(day);
    if (index == _index) return;
    setState(() => _index = index);
    widget.onSelect(day);
  }

  void _move(int by) {
    final index = (_index + by).clamp(0, _total - 1);
    if (index != _index) _select(_dayAt(index));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.arrowDown:
        _move(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowUp:
        _move(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        widget.onOpen(_dayAt(_index));
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.gc;
    final selected = _dayAt(_index);
    final record = widget.days[MenstrualDay.keyOf(selected)];
    final phase = LunarProvider.phaseOn(LunarComparison.noonOf(selected));
    return Semantics(
      key: const ValueKey('menstrual-wheel'),
      // Uma etiqueta por seleção, não por quadro: a árvore semântica fala do
      // dia em foco, do que está registrado nele e da Lua daquele dia.
      label: [
        '${selected.day}/${selected.month}/${selected.year}',
        if (record == null) l10n.menstrualNoRecordDay else l10n.menstrualHasRecordDay,
        phase.displayName,
      ].join(' · '),
      button: true,
      // O nó é dela: o desenho fica fora da árvore, e o que se ouve é o
      // texto do dia em foco.
      container: true,
      child: Focus(
        focusNode: _node,
        onKeyEvent: _onKey,
        child: GestureDetector(
          onTapDown: (details) {
            _node.requestFocus();
            final day = _dayFromOffset(details.localPosition);
            if (day != null) _select(day);
          },
          // Abrir é sempre o dia em foco depois do toque, nunca o anterior.
          onTapUp: (_) => widget.onOpen(_dayAt(_index)),
          // Só horizontal: a rolagem vertical da página continua dela, e
          // soltar o dedo nunca altera registro nenhum.
          onHorizontalDragUpdate: (details) {
            final day = _dayFromOffset(details.localPosition);
            if (day != null) _select(day);
          },
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ExcludeSemantics(
                  child: CustomPaint(
                    size: Size.square(widget.size),
                    painter: _WheelPainter(
                      month: widget.month,
                      total: _total,
                      lights: _lights,
                      days: widget.days,
                      selectedIndex: _index,
                      ring: colors.surfaceBorder,
                      moonLight: colors.starYellow,
                      moonDark: colors.background,
                      mark: colors.pink,
                      cursor: colors.gold,
                    ),
                  ),
                ),
                ExcludeSemantics(
                  child: SizedBox(
                    width: widget.size * .44,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${selected.day}',
                            style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold)),
                        Text(phase.displayName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: MenstrualType.caption(context)),
                        if (record != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(Icons.circle,
                                size: 8, color: colors.pink),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter({
    required this.month,
    required this.total,
    required this.lights,
    required this.days,
    required this.selectedIndex,
    required this.ring,
    required this.moonLight,
    required this.moonDark,
    required this.mark,
    required this.cursor,
  });

  final DateTime month;
  final int total;

  /// A luz da Lua de cada dia do mês, já calculada.
  final List<double> lights;

  final Map<String, MenstrualDay> days;
  final int selectedIndex;
  final Color ring;
  final Color moonLight;
  final Color moonDark;
  final Color mark;
  final Color cursor;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final side = size.shortestSide;
    final outer = side * .46;
    final inner = side * .33;
    final step = 2 * math.pi / total;

    final guide = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ring.withValues(alpha: .5);
    canvas.drawCircle(centre, outer, guide);
    canvas.drawCircle(centre, inner, guide);

    for (var i = 0; i < total; i++) {
      final day = DateTime(month.year, month.month, i + 1);
      final angle = -math.pi / 2 + i * step;
      final direction = Offset(math.cos(angle), math.sin(angle));

      // Anel externo: a Lua daquele dia, do escuro ao claro.
      final moon = Paint()
        ..style = PaintingStyle.fill
        ..color = Color.lerp(moonDark, moonLight,
            i < lights.length ? lights[i] : 0)!;
      canvas.drawCircle(centre + direction * outer, side * .016, moon);
      canvas.drawCircle(
        centre + direction * outer,
        side * .016,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8
          ..color = ring,
      );

      // Anel interno: só o que ela registrou, com forma por tipo de marca.
      final record = days[MenstrualDay.keyOf(day)];
      if (record != null) {
        final spot = centre + direction * inner;
        final ink = Paint()..color = mark;
        switch (record.mark) {
          case MenstrualMark.start:
          case MenstrualMark.flow:
            canvas.drawCircle(spot, side * .018, ink);
          case MenstrualMark.spotting:
            canvas.drawCircle(
                spot,
                side * .018,
                ink
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1.6);
          case MenstrualMark.end:
            canvas.drawRect(
              Rect.fromCenter(
                  center: spot, width: side * .032, height: side * .012),
              ink,
            );
          case MenstrualMark.note:
            canvas.drawRect(
              Rect.fromCenter(
                  center: spot, width: side * .026, height: side * .026),
              ink
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.4,
            );
        }
      }
    }

    // O cursor: uma linha do centro até o dia em foco, sem easing.
    final angle = -math.pi / 2 + selectedIndex * step;
    final direction = Offset(math.cos(angle), math.sin(angle));
    canvas.drawLine(
      centre + direction * (side * .2),
      centre + direction * (outer + side * .03),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = cursor,
    );
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.month != month ||
      old.lights != lights ||
      old.total != total ||
      old.selectedIndex != selectedIndex ||
      old.days != days ||
      old.ring != ring ||
      old.mark != mark ||
      old.cursor != cursor;
}
