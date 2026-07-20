import 'package:flutter/material.dart';

/// Navegação por swipe entre verbetes da Enciclopédia (padrão da
/// Biblioteca de Cartas do Tarot): cada página é o detalhe completo do
/// verbete; deslizar para o lado vai ao anterior/próximo sem voltar à lista.
class EntryPager extends StatefulWidget {
  final int itemCount;
  final int initialIndex;
  final IndexedWidgetBuilder itemBuilder;

  const EntryPager({
    super.key,
    required this.itemCount,
    required this.initialIndex,
    required this.itemBuilder,
  });

  @override
  State<EntryPager> createState() => _EntryPagerState();
}

class _EntryPagerState extends State<EntryPager> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
    );
  }
}
