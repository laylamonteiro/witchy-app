import 'package:flutter/material.dart';

import '../../theme/grimoire_motion.dart';

/// Shows a received text as paragraphs entering one after another, briefly.
/// The whole content is in the tree from the first frame: nothing waits on
/// the animation, reduced motion shows it at once, and [key] changes replay.
class StaggeredParagraphs extends StatefulWidget {
  const StaggeredParagraphs({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  /// Longest total entrance, whatever the paragraph count.
  static const Duration ceiling = Duration(milliseconds: 1200);

  static List<String> split(String text) => [
    for (final part in text.split(RegExp(r'\n\s*\n')))
      if (part.trim().isNotEmpty) part.trim(),
  ];

  @override
  State<StaggeredParagraphs> createState() => _StaggeredParagraphsState();
}

class _StaggeredParagraphsState extends State<StaggeredParagraphs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance =
      AnimationController(vsync: this, duration: StaggeredParagraphs.ceiling);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (GrimoireMotion.reduced(context)) {
      _entrance.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paragraphs = StaggeredParagraphs.split(widget.text);
    if (paragraphs.isEmpty) return const SizedBox.shrink();
    final stepMs = GrimoireMotion.state.inMilliseconds;
    final total = StaggeredParagraphs.ceiling.inMilliseconds;
    final gap = paragraphs.length == 1
        ? 0
        : ((total - stepMs) ~/ (paragraphs.length - 1)).clamp(0, 90);
    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < paragraphs.length; i++)
            Builder(builder: (context) {
              final start = (i * gap / total).toDouble();
              final end = ((i * gap + stepMs) / total).clamp(0.0, 1.0).toDouble();
              final t = Interval(start, end, curve: GrimoireMotion.enter)
                  .transform(_entrance.value);
              return Padding(
                padding: EdgeInsets.only(bottom: i == paragraphs.length - 1 ? 0 : 12),
                child: Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 6 * (1 - t)),
                    child: Text(paragraphs[i], style: widget.style),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
