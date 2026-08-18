import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Enquadra o app numa largura de celular quando roda na web em telas largas.
///
/// O Grimório foi desenhado mobile-first. No desktop, sem isso, os layouts
/// esticam por toda a largura da janela e ficam estranhos. Aqui, em telas
/// largas (> [_breakpoint]), o app é renderizado num "frame" central de
/// [_frameWidth] px, com o resto da tela preenchido por um fundo escuro.
///
/// Em telas estreitas (celular no navegador) e fora da web, não altera nada —
/// retorna o [child] direto, ocupando a tela inteira.
class WebMobileFrame extends StatelessWidget {
  final Widget child;

  const WebMobileFrame({super.key, required this.child});

  /// Largura do frame — próxima de um celular grande (ex.: iPhone Pro Max).
  static const double _frameWidth = 430;

  /// Abaixo disso, considera "tela de celular" e usa a largura toda.
  static const double _breakpoint = 600;

  /// Fundo atrás do frame (um pouco mais escuro que o app, para destacá-lo).
  static const Color _backdrop = Color(0xFF05040A);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= _breakpoint) return child;

        return ColoredBox(
          color: _backdrop,
          child: Center(
            child: Container(
              width: _frameWidth,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 32,
                  ),
                ],
              ),
              // O app passa a "enxergar" a largura do frame (e não a da janela),
              // então MediaQuery-based layouts se comportam como no celular.
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(_frameWidth, constraints.maxHeight),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
