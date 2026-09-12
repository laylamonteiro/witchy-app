import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/grimoire_colors.dart';

/// Os emblemas que o app DESENHA, em vez de escrever um glifo.
///
/// Sigilos (⛤), Runas (ᚱ) e Pêndulo (⟟) eram caracteres de blocos raros do
/// Unicode: onde o aparelho não tem uma fonte com esses símbolos, o sistema
/// devolve o quadradinho de "glifo ausente" — e o cartão da ferramenta e o
/// cabeçalho da tela ficavam sem emblema nenhum. Desenho não depende de
/// fonte instalada: aparece igual em qualquer aparelho.
enum ToolDrawing {
  /// Pentagrama inscrito no círculo — o emblema dos Sigilos.
  pentagram,

  /// Raidho (ᚱ), a runa da viagem — o emblema da Leitura de Runas.
  raidho,

  /// Fio, ponto de apoio e cristal em ponta — o emblema do Pêndulo.
  pendulum,
}

/// O desenho de um emblema, num quadrado de [size].
///
/// As cores vêm de `context.gc`, então o traço acompanha as SEIS paletas
/// (inclusive a clara): `lilac` é o acento de cada tema e `gold` o realce —
/// ambos escolhidos para ter contraste com o fundo do próprio tema, o que
/// uma cor fixa não teria.
///
/// [label] é o que o leitor de tela anuncia. SEM rótulo (o padrão) o desenho
/// é decorativo e sai da árvore de semântica: nos dois lugares em que o
/// emblema aparece hoje — o card do Grimório e o cabeçalho da tela — o nome
/// da ferramenta está escrito ao lado, e rotular o desenho faria o leitor de
/// tela dizer o mesmo nome duas vezes. É a mesma regra do emblema do
/// RitualCircle, que também é arte ao lado de um rótulo que já diz tudo.
/// Quem usar o desenho SOZINHO, longe do nome, passa o rótulo.
class ToolDrawingArt extends StatelessWidget {
  const ToolDrawingArt({
    super.key,
    required this.drawing,
    required this.size,
    this.label,
  });

  final ToolDrawing drawing;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final arte = CustomPaint(
      size: Size.square(size),
      painter: _ToolDrawingPainter(
        drawing: drawing,
        traco: gc.lilac,
        realce: gc.gold,
        // O fundo do tema vira a "fresta" das facetas do cristal: sobre o
        // lilás preenchido ele contrasta tanto no tema claro quanto nos
        // escuros, porque é sempre o oposto do acento.
        vazado: gc.background,
      ),
    );
    return label == null
        ? ExcludeSemantics(child: arte)
        // Nó próprio (`container`): o desenho rotulado é uma imagem inteira,
        // e sem isso o rótulo poderia ser absorvido pelo texto vizinho.
        : Semantics(container: true, label: label, image: true, child: arte);
  }
}

class _ToolDrawingPainter extends CustomPainter {
  const _ToolDrawingPainter({
    required this.drawing,
    required this.traco,
    required this.realce,
    required this.vazado,
  });

  final ToolDrawing drawing;
  final Color traco;
  final Color realce;
  final Color vazado;

  @override
  void paint(Canvas canvas, Size size) {
    // Todas as medidas saem do lado do quadrado: o mesmo desenho serve ao
    // emblema de 40 do cartão e ao de 22 do cabeçalho.
    final s = size.shortestSide;
    if (s <= 0) return;
    switch (drawing) {
      case ToolDrawing.pentagram:
        _pentagrama(canvas, s);
        break;
      case ToolDrawing.raidho:
        _raidho(canvas, s);
        break;
      case ToolDrawing.pendulum:
        _pendulo(canvas, s);
        break;
    }
  }

  /// Pentagrama de um traço só, dentro de um anel.
  ///
  /// O glifo ⛤ é a estrela SEM anel; o anel entrou porque no cabeçalho, a 22
  /// de lado, a estrela sozinha some no meio do título. Vale conferir no
  /// aparelho: é a única liberdade que este desenho toma em relação ao
  /// símbolo que a ferramenta usava.
  void _pentagrama(Canvas canvas, double s) {
    final centro = Offset(s / 2, s / 2);
    final raio = s * 0.45;

    canvas.drawCircle(
      centro,
      raio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.05
        ..color = realce,
    );

    // Cinco pontas a partir do topo, ligadas de duas em duas: é assim que a
    // estrela fecha em traço contínuo.
    final pontas = <Offset>[
      for (var i = 0; i < 5; i++)
        Offset(
          centro.dx + raio * 0.88 * math.cos(-math.pi / 2 + i * 2 * math.pi / 5),
          centro.dy + raio * 0.88 * math.sin(-math.pi / 2 + i * 2 * math.pi / 5),
        ),
    ];
    final estrela = Path()..moveTo(pontas[0].dx, pontas[0].dy);
    for (var i = 1; i < 5; i++) {
      final p = pontas[(i * 2) % 5];
      estrela.lineTo(p.dx, p.dy);
    }
    estrela.close();

    canvas.drawPath(
      estrela,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.065
        ..strokeJoin = StrokeJoin.round
        ..color = traco,
    );
  }

  /// Raidho: haste, o ombro que volta à haste e a perna — a runa R.
  void _raidho(Canvas canvas, double s) {
    final runa = Path()
      ..moveTo(s * 0.30, s * 0.08)
      ..lineTo(s * 0.30, s * 0.92)
      ..moveTo(s * 0.30, s * 0.08)
      ..lineTo(s * 0.68, s * 0.27)
      ..lineTo(s * 0.30, s * 0.47)
      ..lineTo(s * 0.73, s * 0.92);

    canvas.drawPath(
      runa,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = traco,
    );
  }

  /// Pêndulo: ponto de apoio, fio e o cristal pendurado de ponta para baixo.
  void _pendulo(Canvas canvas, double s) {
    final ouro = Paint()..color = realce;

    canvas.drawLine(
      Offset(s * 0.50, s * 0.10),
      Offset(s * 0.50, s * 0.44),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.04
        ..strokeCap = StrokeCap.round
        ..color = realce,
    );
    canvas.drawCircle(Offset(s * 0.50, s * 0.10), s * 0.065, ouro);

    final cristal = Path()
      ..moveTo(s * 0.50, s * 0.40)
      ..lineTo(s * 0.67, s * 0.57)
      ..lineTo(s * 0.60, s * 0.77)
      ..lineTo(s * 0.50, s * 0.94)
      ..lineTo(s * 0.40, s * 0.77)
      ..lineTo(s * 0.33, s * 0.57)
      ..close();
    canvas.drawPath(cristal, Paint()..color = traco);

    // Facetas: o eixo e a linha dos ombros dão volume à pedra chapada.
    final facetas = Path()
      ..moveTo(s * 0.50, s * 0.40)
      ..lineTo(s * 0.50, s * 0.94)
      ..moveTo(s * 0.33, s * 0.57)
      ..lineTo(s * 0.67, s * 0.57);
    canvas.drawPath(
      facetas,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.035
        ..color = vazado.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _ToolDrawingPainter old) =>
      old.drawing != drawing ||
      old.traco != traco ||
      old.realce != realce ||
      old.vazado != vazado;
}
