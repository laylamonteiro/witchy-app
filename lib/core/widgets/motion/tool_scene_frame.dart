import 'package:flutter/material.dart';

import '../../theme/grimoire_motion.dart';

/// A bounded scene with lifecycle-aware tickers and an accessible final state.
/// Timers, sensors and domain operations remain their owners' responsibility.
class ToolSceneFrame extends StatefulWidget {
  const ToolSceneFrame({super.key, required this.child});
  final Widget child;

  @override
  State<ToolSceneFrame> createState() => _ToolSceneFrameState();
}

class _ToolSceneFrameState extends State<ToolSceneFrame>
    with WidgetsBindingObserver {
  late bool _active = WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) setState(() => _active = state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    return TickerMode(
      enabled: _active && current && TickerMode.of(context) &&
          !GrimoireMotion.reduced(context),
      child: widget.child,
    );
  }
}
