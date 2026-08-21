import 'package:flutter/material.dart';

import 'page_dots.dart';

/// Leitura dividida em páginas que deslizam para o lado.
///
/// Existe para o texto longo não virar uma tela rolável interminável: cada
/// página carrega uma ideia, e os pontinhos mostram quanto ainda falta. Cada
/// página rola sozinha quando o texto não cabe, então a paginação nunca
/// esconde conteúdo.
class PagedReading extends StatefulWidget {
  const PagedReading({
    super.key,
    required this.pages,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 16),
    this.onPageChanged,
  });

  /// Uma entrada por página, na ordem de leitura.
  final List<Widget> pages;

  /// Respiro em volta do conteúdo de cada página.
  final EdgeInsetsGeometry padding;

  final ValueChanged<int>? onPageChanged;

  @override
  State<PagedReading> createState() => _PagedReadingState();
}

class _PagedReadingState extends State<PagedReading> {
  final PageController _controlador = PageController();
  int _pagina = 0;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _irPara(int pagina) {
    _controlador.animateToPage(
      pagina,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controlador,
            itemCount: widget.pages.length,
            onPageChanged: (i) {
              setState(() => _pagina = i);
              widget.onPageChanged?.call(i);
            },
            itemBuilder: (context, i) => SingleChildScrollView(
              padding: widget.padding,
              child: widget.pages[i],
            ),
          ),
        ),
        PageDots(
          count: widget.pages.length,
          index: _pagina,
          onTap: _irPara,
        ),
      ],
    );
  }
}
