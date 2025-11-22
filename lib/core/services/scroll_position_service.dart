import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para persistir e restaurar posições de scroll
///
/// Uso:
/// ```dart
/// // Em um StatefulWidget
/// final _scrollController = ScrollController();
///
/// @override
/// void initState() {
///   super.initState();
///   ScrollPositionService.restorePosition('my_list', _scrollController);
/// }
///
/// @override
/// void dispose() {
///   ScrollPositionService.savePosition('my_list', _scrollController);
///   super.dispose();
/// }
/// ```
class ScrollPositionService {
  static const String _prefix = 'scroll_position_';

  /// Salva a posição atual do scroll
  static Future<void> savePosition(String key, ScrollController controller) async {
    if (!controller.hasClients) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_prefix$key', controller.offset);
  }

  /// Restaura a posição salva do scroll
  static Future<void> restorePosition(String key, ScrollController controller) async {
    final prefs = await SharedPreferences.getInstance();
    final position = prefs.getDouble('$_prefix$key');

    if (position != null && position > 0) {
      // Aguardar o próximo frame para garantir que o layout está pronto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.hasClients) {
          final maxScroll = controller.position.maxScrollExtent;
          final targetPosition = position.clamp(0.0, maxScroll);
          controller.jumpTo(targetPosition);
        }
      });
    }
  }

  /// Remove a posição salva
  static Future<void> clearPosition(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
  }

  /// Remove todas as posições salvas
  static Future<void> clearAllPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

/// Mixin para facilitar o uso do scroll persistence em StatefulWidgets
mixin ScrollPositionPersistence<T extends StatefulWidget> on State<T> {
  ScrollController? _scrollController;
  String get scrollPositionKey;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _restoreScrollPosition();
  }

  @override
  void dispose() {
    _saveScrollPosition();
    _scrollController?.dispose();
    super.dispose();
  }

  ScrollController get scrollController {
    _scrollController ??= ScrollController();
    return _scrollController!;
  }

  Future<void> _restoreScrollPosition() async {
    await ScrollPositionService.restorePosition(scrollPositionKey, scrollController);
  }

  Future<void> _saveScrollPosition() async {
    await ScrollPositionService.savePosition(scrollPositionKey, scrollController);
  }
}

/// Widget wrapper que automaticamente salva/restaura posição de scroll
class ScrollPositionWrapper extends StatefulWidget {
  final String positionKey;
  final Widget Function(ScrollController controller) builder;

  const ScrollPositionWrapper({
    super.key,
    required this.positionKey,
    required this.builder,
  });

  @override
  State<ScrollPositionWrapper> createState() => _ScrollPositionWrapperState();
}

class _ScrollPositionWrapperState extends State<ScrollPositionWrapper> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    ScrollPositionService.restorePosition(widget.positionKey, _controller);
  }

  @override
  void dispose() {
    ScrollPositionService.savePosition(widget.positionKey, _controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_controller);
  }
}
