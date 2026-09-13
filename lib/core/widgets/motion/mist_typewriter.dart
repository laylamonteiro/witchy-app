import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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

/// Um texto que chega sendo escrito, letra a letra.
///
/// O texto inteiro está na árvore desde o primeiro quadro — a parte ainda
/// não escrita fica no mesmo `Text.rich`, só que transparente. Assim as
/// quebras de linha e a altura nunca mudam durante a escrita, e o leitor de
/// tela recebe a resposta completa de saída.
///
/// [started] existe porque a escrita espera a névoa pousar no card: até lá o
/// texto fica todo transparente, no lugar certo. Tocar no texto ou em
/// "Mostrar tudo" completa na hora. Com [reveal] falso (uma resposta
/// restaurada ao reabrir a tela) ou com movimento reduzido, o texto aparece
/// inteiro, sem espera.
class MistTypewriterText extends StatefulWidget {
  const MistTypewriterText({
    super.key,
    required this.spans,
    required this.style,
    this.reveal = true,
    this.started = true,
    this.skipLabel,
    this.skipKey,
    this.textKey,
    this.onCompleted,
  });

  final List<RevealSpan> spans;

  /// Estilo do corpo (os trechos herdam dele).
  final TextStyle style;

  /// Falso mostra tudo de imediato: a escrita é só para o que acabou de
  /// chegar.
  final bool reveal;

  /// Falso segura o texto todo transparente — a névoa ainda está a caminho.
  final bool started;

  /// Rótulo do botão que pula a escrita. Sem rótulo, sem botão (tocar no
  /// texto continua pulando).
  final String? skipLabel;
  final Key? skipKey;

  /// Marca só o bloco de texto. Quem vai escrever precisa saber onde fica o
  /// começo do primeiro parágrafo — é ali que a névoa pousa.
  final Key? textKey;

  final VoidCallback? onCompleted;

  /// Ritmo da escrita e teto do total: uma resposta longa não pode prender a
  /// pessoa por meio minuto.
  static const int msPerChar = 22;
  static const Duration ceiling = Duration(seconds: 9);

  /// Folga do relógio de segurança depois do fim previsto da escrita.
  static const Duration guard = Duration(seconds: 2);

  /// Quanto se tolera esperar por [started] — a névoa a caminho, ou o que
  /// mais segure a escrita. Depois disso a resposta aparece de qualquer
  /// jeito: um enfeite que não termina não pode calar o Conselheiro.
  static const Duration wait = Duration(seconds: 6);

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
  bool _running = false;

  /// Relógio de segurança. A escrita anda por ticker, e o ticker desta cena
  /// pode ficar mudo (aba em segundo plano, tela que saiu da frente): sem
  /// isto, a resposta ficaria invisível para sempre, porque o que ainda não
  /// foi escrito é transparente. O relógio não depende de ticker nenhum.
  Timer? _guard;

  String get _fullText => widget.spans.map((s) => s.text).join();

  @override
  void initState() {
    super.initState();
    _type.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _guard?.cancel();
        widget.onCompleted?.call();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
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
    }
    _sync();
  }

  /// Mostra tudo, ou começa a escrever quando a névoa pousa.
  void _sync() {
    if (!widget.reveal || GrimoireMotion.reduced(context)) {
      _running = true;
      _guard?.cancel();
      if (_type.value != 1) _type.value = 1;
      return;
    }
    if (!_running) {
      // Enquanto a escrita não começa, o relógio conta a espera pela névoa
      // — se ela nunca pousar, a resposta aparece assim mesmo.
      _guard ??= _protect(MistTypewriterText.wait);
    }
    if (!widget.started || _running) return;
    _running = true;
    _guard?.cancel();
    _guard = _protect(Duration.zero);
    _type.forward();
  }

  /// Relógio que mostra a resposta inteira [folga] depois do fim previsto da
  /// escrita. Não depende de ticker: é ele que segura o caso do ticker mudo.
  Timer _protect(Duration folga) => Timer(
        folga + _type.duration! + MistTypewriterText.guard,
        () {
          if (mounted && _type.value < 1) _type.value = 1;
        },
      );

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
    _guard?.cancel();
    _disposeRecognizers();
    _type.dispose();
    super.dispose();
  }

  /// Completa a escrita na hora.
  void skip() {
    if (_type.value != 1) _type.value = 1;
  }

  /// Os trechos com a parte ainda não escrita transparente e sem link.
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
          mouseCursor: span.onTap == null ? null : SystemMouseCursors.click,
        ));
      }
      if (visibleEnd < span.text.length) {
        children.add(TextSpan(
          text: span.text.substring(visibleEnd),
          style:
              (style ?? const TextStyle()).copyWith(color: Colors.transparent),
        ));
      }
      offset += span.text.length;
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final total = _fullText.length;
    final reduced = GrimoireMotion.reduced(context);

    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeyedSubtree(
            key: widget.textKey,
            child: AnimatedBuilder(
              animation: _type,
              builder: (context, _) {
                final count = MistTypewriterText.snapToCodePoint(
                    _fullText, (_type.value * total).round());
                final text = Text.rich(
                  TextSpan(children: _revealed(count)),
                  key: const ValueKey('mist-typewriter-text'),
                  style: widget.style,
                );
                if (_type.value >= 1) return text;
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: skip,
                  child: text,
                );
              },
            ),
          ),
          if (widget.skipLabel != null)
            AnimatedBuilder(
              animation: _type,
              builder: (context, _) => AnimatedSwitcher(
                duration: reduced ? Duration.zero : GrimoireMotion.state,
                // Enquanto a névoa vem, não há o que pular.
                child: !_running || _type.value >= 1
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
