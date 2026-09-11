import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/grimoire/data/models/spell_model.dart';
import '../theme/grimoire_colors.dart';

/// Posição canônica da fase dentro da lunação: 0 = nova, 0.5 = cheia, 1 = nova
/// de novo.
///
/// A conta parte da FASE, e não da data, porque o disco tem de concordar
/// sempre com o nome escrito ao lado — se um dia o cálculo de efemérides
/// mudar, o desenho muda junto sem ficar dizendo "Lua Cheia" sobre um
/// crescente.
double _posicaoNaLunacao(MoonPhase fase) {
  switch (fase) {
    case MoonPhase.newMoon:
      return 0.0;
    case MoonPhase.waxingCrescent:
      return 0.125;
    case MoonPhase.firstQuarter:
      return 0.25;
    case MoonPhase.waxingGibbous:
      return 0.375;
    case MoonPhase.fullMoon:
      return 0.5;
    case MoonPhase.waningGibbous:
      return 0.625;
    case MoonPhase.lastQuarter:
      return 0.75;
    case MoonPhase.waningCrescent:
      return 0.875;
  }
}

/// Quanto do disco está aceso, de 0 (nova) a 1 (cheia).
///
/// Exposta (e não escondida no painter) para que o teste trave a geometria
/// sem precisar montar widget nenhum: é ela que impede alguém de inverter a
/// lua numa refatoração distraída.
double fracaoIluminada(MoonPhase fase) =>
    (1 - math.cos(2 * math.pi * _posicaoNaLunacao(fase))) / 2;

/// Verdadeiro quando a luz está crescendo — e, portanto, quando o lado aceso
/// fica à DIREITA. Nova e cheia devolvem falso porque nelas não existe lado:
/// o disco está todo apagado ou todo aceso.
bool luaCrescendo(MoonPhase fase) {
  final p = _posicaoNaLunacao(fase);
  return p > 0 && p < 0.5;
}

/// O par de cores da lua numa paleta: a face acesa e a face na sombra.
///
/// Fora do widget porque é ele que precisa passar no teste das SEIS paletas
/// — e porque a armadilha aqui é grande: `softWhite` é apelido de
/// `textPrimary`, que no tema claro (Lavanda-névoa) é quase preto. Uma lua
/// pintada de softWhite nasceria de carvão justamente na paleta clara.
///
/// A regra, então, é por PAPEL e não por tom fixo: a face acesa é o acento
/// da paleta puxado na direção do texto (a luz DAQUELE céu), e a sombra é o
/// fundo da paleta com um sopro do acento — nunca preto, senão a Lua Nova
/// deixaria de existir na tela.
({Color iluminado, Color sombra}) coresDaLua(GrimoireColors gc) {
  final escuro = gc.isDark;
  return (
    iluminado: escuro
        ? Color.lerp(gc.lilac, gc.textPrimary, 0.55)!
        : Color.lerp(gc.lilac, gc.textPrimary, 0.22)!,
    sombra: escuro
        ? Color.lerp(gc.background, gc.lilac, 0.30)!
        : Color.lerp(gc.background, gc.lilac, 0.22)!,
  );
}

/// A lua do Grimório, DESENHADA.
///
/// Antes a fase era um emoji (🌑, 🌕…), ou seja: a arte vinha da fonte de
/// quem abria o app. No aparelho saía a lua em relevo da fonte do sistema;
/// no navegador, o disco chapado do fallback que o renderizador baixa. Mesma
/// tela, mesmo dia, duas luas diferentes — e nenhum ajuste "de web"
/// resolveria, porque o app nunca desenhou nada ali.
///
/// Agora desenha: disco na sombra, região iluminada recortada pelo
/// terminador e um gradiente deslocado que devolve o relevo. Só primitivas
/// que o app já usa em produção nos dois lados (drawCircle, Path.combine,
/// shader radial, MaskFilter.blur — as mesmas do LoadingWidget).
///
/// É enfeite para o leitor de tela: quem fala é o nome da fase que todos os
/// chamadores escrevem ao lado.
class MoonDisc extends StatelessWidget {
  final MoonPhase phase;

  /// Diâmetro do disco (o halo transborda de leve, como halo deve fazer).
  final double size;

  /// Halo próprio. Desligue quando quem chama já tem o seu — o da
  /// [BreathingMoon] pulsa, e dois halos somados viram neon.
  final bool halo;

  const MoonDisc({
    super.key,
    required this.phase,
    this.size = 62,
    this.halo = true,
  });

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final cores = coresDaLua(gc);

    return ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _MoonDiscPainter(
              fase: phase,
              iluminado: cores.iluminado,
              sombra: cores.sombra,
              // Fecha a silhueta: sem o aro, a Lua Nova (disco inteiro na
              // sombra) quase desapareceria dentro do fundo.
              aro: gc.lilac.withValues(alpha: 0.55),
              halo: halo ? gc.lilac.withValues(alpha: 0.20) : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _MoonDiscPainter extends CustomPainter {
  final MoonPhase fase;
  final Color iluminado;
  final Color sombra;
  final Color aro;
  final Color? halo;

  const _MoonDiscPainter({
    required this.fase,
    required this.iluminado,
    required this.sombra,
    required this.aro,
    required this.halo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2;
    if (r <= 0) return;
    final centro = Offset(size.width / 2, size.height / 2);
    final circulo = Rect.fromCircle(center: centro, radius: r);

    final corHalo = halo;
    if (corHalo != null) {
      canvas.drawCircle(
        centro,
        r * 0.95,
        Paint()
          ..color = corHalo
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.28),
      );
    }

    // O disco inteiro na sombra primeiro: é ele que faz a Lua Nova existir
    // na tela, e é sobre ele que a parte acesa é recortada.
    canvas.drawCircle(centro, r, Paint()..color = sombra);

    final aceso = _caminhoAceso(circulo, centro, r);
    if (aceso != null) {
      canvas.drawPath(
        aceso,
        Paint()
          // Gradiente deslocado: é isto que devolve o relevo que antes vinha
          // de graça do glifo da fonte. O brilho acompanha o LADO da luz —
          // no crescente o sol está à direita, então o fio aceso tem de ser
          // mais claro na borda de fora, não na que encosta na sombra.
          ..shader = RadialGradient(
            center: Alignment(luaCrescendo(fase) ? 0.35 : -0.35, -0.4),
            radius: 0.95,
            colors: [iluminado, Color.lerp(iluminado, sombra, 0.45)!],
          ).createShader(circulo),
      );
    }

    final espessura = math.max(1.0, r * 0.05);
    canvas.drawCircle(
      centro,
      r - espessura / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = espessura
        ..color = aro,
    );
  }

  /// A região acesa, ou null quando não há nenhuma (Lua Nova).
  ///
  /// Uma fórmula só, sem oito casos: metade do disco do lado da luz, mais
  /// (ou menos) a elipse do terminador, cuja largura é o cosseno da posição
  /// na lunação. Perto da nova a elipse come quase toda a metade e sobra o
  /// fio do crescente; perto da cheia ela soma e sobra só um fio de sombra.
  Path? _caminhoAceso(Rect circulo, Offset centro, double r) {
    final p = _posicaoNaLunacao(fase);
    final c = math.cos(2 * math.pi * p);
    if (c >= 1 - 1e-9) return null;
    if (c <= -1 + 1e-9) return Path()..addOval(circulo);

    // -pi/2 começa no topo e varre meia volta no sentido do relógio: metade
    // direita. pi/2 começa embaixo e varre a metade esquerda.
    final inicio = luaCrescendo(fase) ? -math.pi / 2 : math.pi / 2;
    final meio = Path()
      ..addArc(circulo, inicio, math.pi)
      ..close();
    if (c.abs() < 1e-6) return meio;

    final terminador = Path()
      ..addOval(
        Rect.fromCenter(
          center: centro,
          width: 2 * r * c.abs(),
          height: 2 * r,
        ),
      );
    return Path.combine(
      c > 0 ? PathOperation.difference : PathOperation.union,
      meio,
      terminador,
    );
  }

  @override
  bool shouldRepaint(_MoonDiscPainter oldDelegate) =>
      oldDelegate.fase != fase ||
      oldDelegate.iluminado != iluminado ||
      oldDelegate.sombra != sombra ||
      oldDelegate.aro != aro ||
      oldDelegate.halo != halo;
}
