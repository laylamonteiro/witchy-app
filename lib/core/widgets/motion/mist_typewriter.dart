import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme/grimoire_colors.dart';
import '../../theme/grimoire_motion.dart';

/// Um trecho do texto a revelar: corpo comum ou destaque, tocável ou não.
@immutable
class RevealSpan {
  const RevealSpan(this.text, {this.style, this.onTap, this.semanticsLabel});

  final String text;

  /// Estilo do trecho, mesclado sobre o estilo do corpo.
  final TextStyle? style;

  /// Quando presente, o trecho vira link: um toque chama isto.
  final VoidCallback? onTap;

  /// O que o leitor de tela anuncia no lugar do texto (ex.: "Abrir Tarot").
  final String? semanticsLabel;
}

/// Um texto que chega sendo escrito sob uma névoa que desce.
///
/// O texto inteiro está na árvore desde o primeiro quadro — a parte ainda
/// não escrita fica no mesmo `Text.rich`, só que transparente, então as
/// quebras de linha e a altura nunca mudam durante a revelação (o padrão do
/// balão do Salem). Por cima, uma faixa de névoa na cor do card acompanha a
/// linha que está sendo escrita e vai descendo com ela; abaixo da faixa o
/// texto continua coberto até a névoa chegar lá.
///
/// Tocar no texto ou em "Mostrar tudo" completa a revelação na hora. Com
/// [reveal] falso (uma resposta restaurada) ou movimento reduzido, o texto
/// aparece inteiro, sem névoa.
class MistTypewriterText extends StatefulWidget {
  const MistTypewriterText({
    super.key,
    required this.spans,
    required this.style,
    required this.fogColor,
    this.reveal = true,
    this.skipLabel,
    this.skipKey,
    this.onCompleted,
  });

  final List<RevealSpan> spans;

  /// Estilo do corpo (os trechos herdam dele).
  final TextStyle style;

  /// A cor da névoa: a superfície em que o texto está, para a faixa
  /// esconder o que ainda não foi escrito.
  final Color fogColor;

  /// Falso mostra tudo de imediato: a revelação é só para o que acabou de
  /// chegar.
  final bool reveal;

  /// Rótulo do botão que pula a revelação. Sem rótulo, sem botão (tocar no
  /// texto continua pulando).
  final String? skipLabel;
  final Key? skipKey;
  final VoidCallback? onCompleted;

  /// Ritmo da escrita e teto do total: uma resposta longa não pode prender a
  /// pessoa por meio minuto.
  static const int msPerChar = 22;
  static const Duration ceiling = Duration(seconds: 9);

  static Duration durationFor(int chars) => Duration(
      milliseconds:
          (chars * msPerChar).clamp(600, ceiling.inMilliseconds).toInt());

  /// Comprimento total, em unidades de código, de todos os trechos.
  static int lengthOf(List<RevealSpan> spans) =>
      spans.fold(0, (total, span) => total + span.text.length);

  /// Recua [count] para não partir um par substituto (emoji) ao meio: um
  /// quadro com metade de um emoji é um quadradinho piscando.
  @visibleForTesting
  static int snapToCodePoint(String text, int count) {
    if (count <= 0 || count >= text.length) {
      return count.clamp(0, text.length).toInt();
    }
    final unit = text.codeUnitAt(count - 1);
    final isHighSurrogate = unit >= 0xD800 && unit <= 0xDBFF;
    return isHighSurrogate ? count - 1 : count;
  }

  @override
  State<MistTypewriterText> createState() => _MistTypewriterTextState();
}

class _MistTypewriterTextState extends State<MistTypewriterText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _type = AnimationController(
    vsync: this,
    duration: MistTypewriterText.durationFor(
        MistTypewriterText.lengthOf(widget.spans)),
  );
  late List<TapGestureRecognizer?> _recognizers = _buildRecognizers();
  bool _started = false;

  /// Layout do texto completo para localizar a linha do cursor. Cacheado:
  /// só refaz o layout quando largura, estilo ou trechos mudam; a posição do
  /// cursor é lida a cada quadro.
  TextPainter? _painter;
  double? _painterWidth;
  TextStyle? _painterStyle;
  TextScaler? _painterScaler;
  TextDirection? _painterDirection;

  String get _fullText => widget.spans.map((s) => s.text).join();

  @override
  void initState() {
    super.initState();
    _type.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onCompleted?.call();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.reveal || GrimoireMotion.reduced(context)) {
      _started = true;
      if (_type.value != 1) _type.value = 1;
    } else if (!_started) {
      _started = true;
      _type.forward();
    }
  }

  @override
  void didUpdateWidget(MistTypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sameShape(oldWidget.spans, widget.spans)) {
      // O card reconstrói os trechos a cada setState (ex.: "guardando"),
      // com closures novas. Mesmo texto e mesmos links: só o alvo do toque
      // é atualizado, sem descartar um recognizer no meio de um gesto.
      for (var i = 0; i < widget.spans.length; i++) {
        _recognizers[i]?.onTap = widget.spans[i].onTap;
      }
    } else {
      _disposeRecognizers();
      _recognizers = _buildRecognizers();
      _painter?.dispose();
      _painter = null;
    }
    if (!widget.reveal && _type.value != 1) _type.value = 1;
  }

  static bool _sameShape(List<RevealSpan> a, List<RevealSpan> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].text != b[i].text ||
          (a[i].onTap == null) != (b[i].onTap == null) ||
          a[i].style != b[i].style) {
        return false;
      }
    }
    return true;
  }

  List<TapGestureRecognizer?> _buildRecognizers() => [
        for (final span in widget.spans)
          span.onTap == null
              ? null
              : (TapGestureRecognizer()..onTap = span.onTap),
      ];

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer?.dispose();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    _painter?.dispose();
    _type.dispose();
    super.dispose();
  }

  /// Completa a revelação na hora.
  void skip() {
    if (_type.value != 1) _type.value = 1;
  }

  /// Os trechos com a cauda ainda não escrita transparente e sem link.
  List<InlineSpan> _revealed(int count) {
    final children = <InlineSpan>[];
    var offset = 0;
    for (var i = 0; i < widget.spans.length; i++) {
      final span = widget.spans[i];
      final visibleEnd = (count - offset).clamp(0, span.text.length).toInt();
      final style = span.style;
      if (visibleEnd > 0) {
        children.add(TextSpan(
          text: span.text.substring(0, visibleEnd),
          style: style,
          recognizer: _recognizers[i],
          semanticsLabel: span.semanticsLabel,
          mouseCursor:
              span.onTap == null ? null : SystemMouseCursors.click,
        ));
      }
      if (visibleEnd < span.text.length) {
        children.add(TextSpan(
          text: span.text.substring(visibleEnd),
          style: (style ?? const TextStyle())
              .copyWith(color: Colors.transparent),
        ));
      }
      offset += span.text.length;
    }
    return children;
  }

  TextPainter _layout(double width, TextStyle style, TextScaler scaler,
      TextDirection direction) {
    var painter = _painter;
    if (painter == null ||
        _painterWidth != width ||
        _painterStyle != style ||
        _painterScaler != scaler ||
        _painterDirection != direction) {
      painter?.dispose();
      painter = TextPainter(
        text: TextSpan(
          style: style,
          children: [
            for (final span in widget.spans)
              TextSpan(text: span.text, style: span.style),
          ],
        ),
        textDirection: direction,
        textScaler: scaler,
      )..layout(maxWidth: width);
      _painter = painter;
      _painterWidth = width;
      _painterStyle = style;
      _painterScaler = scaler;
      _painterDirection = direction;
    }
    return painter;
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final total = _fullText.length;
    final reduced = GrimoireMotion.reduced(context);

    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            return AnimatedBuilder(
              animation: _type,
              builder: (context, _) {
                final count = MistTypewriterText.snapToCodePoint(
                    _fullText, (_type.value * total).round());
                final done = _type.value >= 1;
                final text = SizedBox(
                  width: width,
                  child: Text.rich(
                    TextSpan(children: _revealed(count)),
                    key: const ValueKey('mist-typewriter-text'),
                    style: style,
                    textScaler: scaler,
                  ),
                );
                if (done || reduced) return text;
                final painter = _layout(width, style, scaler, direction);
                final caret = painter.getOffsetForCaret(
                    TextPosition(offset: count), Rect.zero);
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: skip,
                  child: CustomPaint(
                    foregroundPainter: MistFogPainter(
                      front: caret.dy,
                      lineHeight: painter.preferredLineHeight,
                      fog: widget.fogColor,
                      tint: context.gc.lilac,
                      drift: _type.value,
                    ),
                    child: text,
                  ),
                );
              },
            );
          }),
          if (widget.skipLabel != null)
            AnimatedBuilder(
              animation: _type,
              builder: (context, _) => AnimatedSwitcher(
                duration: reduced ? Duration.zero : GrimoireMotion.state,
                child: _type.value >= 1
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          key: widget.skipKey,
                          onPressed: skip,
                          child: Text(widget.skipLabel!),
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A névoa que desce com a escrita.
///
/// [front] é a altura da linha que está sendo escrita. Acima dela o texto
/// já apareceu; a faixa cobre a linha atual até um pouco abaixo e some
/// gradualmente para cima, com um fio lilás na frente. Uma segunda faixa,
/// mais larga e mais tênue, oscila de lado com [drift] para a névoa parecer
/// andar enquanto desce.
@visibleForTesting
class MistFogPainter extends CustomPainter {
  const MistFogPainter({
    required this.front,
    required this.lineHeight,
    required this.fog,
    required this.tint,
    required this.drift,
  });

  final double front;
  final double lineHeight;
  final Color fog;
  final Color tint;

  /// 0 → 1 ao longo da revelação.
  final double drift;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final top = front - 1.2 * lineHeight;
    final bottom = front + 2.2 * lineHeight;

    // Faixa larga, tênue e deslocada: a névoa andando.
    final sway = size.width * .05 * math.sin(drift * 6 * math.pi);
    final wide = Rect.fromLTRB(
      -size.width * .2 + sway,
      top - 1.8 * lineHeight,
      size.width * 1.2 + sway,
      bottom + .8 * lineHeight,
    );
    canvas.drawRect(
      wide,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fog.withValues(alpha: 0),
            fog.withValues(alpha: .35),
            fog.withValues(alpha: .35),
            fog.withValues(alpha: 0),
          ],
          stops: const [0, .4, .75, 1],
        ).createShader(wide),
    );

    // A faixa principal: esconde a linha atual e o que vem depois.
    final band = Rect.fromLTRB(0, top, size.width, bottom);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fog.withValues(alpha: 0),
            fog.withValues(alpha: .85),
            fog.withValues(alpha: .85),
            fog.withValues(alpha: 0),
          ],
          stops: const [0, .35, .7, 1],
        ).createShader(band),
    );

    // Abaixo da faixa tudo continua coberto até a névoa descer.
    if (bottom < size.height) {
      canvas.drawRect(
        Rect.fromLTRB(0, bottom - 1, size.width, size.height),
        Paint()..color = fog.withValues(alpha: .96),
      );
    }

    // O fio de luz na frente da névoa.
    canvas.drawRect(
      Rect.fromLTRB(0, front - .1 * lineHeight, size.width, front + .5 * lineHeight),
      Paint()..color = tint.withValues(alpha: .10),
    );
  }

  @override
  bool shouldRepaint(MistFogPainter old) =>
      old.front != front ||
      old.lineHeight != lineHeight ||
      old.fog != fog ||
      old.tint != tint ||
      old.drift != drift;
}
