import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A silhueta ✦ canônica do app: estrela de 4 pontas, 8 vértices alternando
/// o raio cheio e o raio interno, primeira ponta para cima.
///
/// Um desenho só para loader, estados vazios e selos — três cópias quase
/// iguais do mesmo Path é como a silhueta deriva com o tempo.
Path estrelaDeQuatroPontas(
  Offset centro,
  double raio, {
  double razaoInterna = 0.4,
}) {
  final caminho = Path();
  for (var i = 0; i < 8; i++) {
    final angulo = -math.pi / 2 + (math.pi / 4) * i;
    final r = i.isEven ? raio : raio * razaoInterna;
    final p = Offset(
      centro.dx + math.cos(angulo) * r,
      centro.dy + math.sin(angulo) * r,
    );
    if (i == 0) {
      caminho.moveTo(p.dx, p.dy);
    } else {
      caminho.lineTo(p.dx, p.dy);
    }
  }
  return caminho..close();
}
