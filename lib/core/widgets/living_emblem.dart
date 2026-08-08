import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/grimoire_colors.dart';

/// As seções que têm um "emblema vivo" no topo da lista. Cada uma tem um
/// movimento próprio (respiração ~3s + estrelas piscando é o denominador
/// comum; algumas ganham brilho varrendo, oscilação, chama, bolhas...).
enum SectionEmblem {
  myGrimoire,
  moon,
  sun,
  sabbats,
  crystals,
  herbs,
  goddesses,
  elements,
  runes,
  altar,
  metals,
  astrology,
  tools,
  archetypes,
  angels,
  demons,
  symbols,
}

/// Emblema vivo: a arte SVG da seção sob uma respiração suave, com halo
/// pulsante e estrelas piscando — a mesma linguagem da BreathingMoon/Sun —
/// mais o movimento característico de cada seção.
///
/// Altura FIXA (para o deslizar entre abas nunca "pular"); congela num
/// quadro bonito quando o sistema pede "reduzir movimento" (acessibilidade).
class LivingEmblem extends StatefulWidget {
  final SectionEmblem? emblem;

  /// Arte própria no lugar do SVG da seção (ex.: o símbolo do PRÓXIMO
  /// sabbat na Roda do Ano) — mesma respiração, halo e estrelas.
  final Widget? customArt;

  final double height;

  const LivingEmblem(
      {super.key, required SectionEmblem this.emblem, this.height = 132})
      : customArt = null;

  const LivingEmblem.custom(
      {super.key, required Widget this.customArt, this.height = 132})
      : emblem = null;

  @override
  State<LivingEmblem> createState() => _LivingEmblemState();
}

class _LivingEmblemState extends State<LivingEmblem>
    with TickerProviderStateMixin {
  late final AnimationController _breathe; // respiração/halo (3s)
  late final AnimationController _orbit; // órbitas lentas (40s)
  late final AnimationController _orbitQuick; // órbita viva (astrologia, 7s)
  late final AnimationController _sweep; // brilho varrendo / escrita (3s)
  late final AnimationController _fast; // chama, joia, oscilação (1.8s)

  /// null = primeira dependência ainda não lida — garante que o primeiro
  /// didChangeDependencies SEMPRE configure (e dispare) os controllers.
  bool? _reduced;

  @override
  void initState() {
    super.initState();
    _breathe =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _orbit =
        AnimationController(vsync: this, duration: const Duration(seconds: 40));
    _orbitQuick =
        AnimationController(vsync: this, duration: const Duration(seconds: 7));
    _sweep = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200));
    _fast = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced != _reduced) {
      _reduced = reduced;
      if (reduced) {
        _breathe.value = 0.5;
        _sweep.value = 1.0;
        _fast.value = 0.5;
        _orbit.stop();
        _orbitQuick.stop();
      } else {
        _breathe.repeat(reverse: true);
        _orbit.repeat();
        _orbitQuick.repeat();
        _sweep.repeat();
        _fast.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _breathe.dispose();
    _orbit.dispose();
    _orbitQuick.dispose();
    _sweep.dispose();
    _fast.dispose();
    super.dispose();
  }

  double get _artH => widget.height * 0.72;

  Widget _svg(String s) =>
      SvgPicture.string(s, height: _artH, fit: BoxFit.contain);

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;

    return SizedBox(
      height: widget.height,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Halo pulsante — o "dourado é a cor da vida" do sistema.
            AnimatedBuilder(
              animation: _breathe,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_breathe.value);
                return Container(
                  width: widget.height * 0.9,
                  height: widget.height * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        gc.starYellow.withValues(alpha: 0.10 + 0.10 * t),
                        gc.background.withValues(alpha: 0),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Arte + movimento característico, respirando.
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.045).animate(
                CurvedAnimation(parent: _breathe, curve: Curves.easeInOut),
              ),
              child: _buildArt(gc),
            ),
            // Estrelas piscando ao redor.
            ..._stars(gc),
          ],
        ),
      ),
    );
  }

  bool get _isReduced => _reduced ?? false;

  /// A arte da seção, com seu movimento próprio.
  Widget _buildArt(GrimoireColors gc) {
    final custom = widget.customArt;
    if (custom != null) {
      return SizedBox(height: _artH, child: Center(child: custom));
    }
    switch (widget.emblem!) {
      // Orbital: base + camada girando por cima. A camada usa a MESMA
      // altura da base — os dois compartilham o viewBox, então qualquer
      // diferença de escala desalinha a composição desenhada.
      case SectionEmblem.elements:
      case SectionEmblem.sabbats:
      case SectionEmblem.symbols:
        return Stack(
          alignment: Alignment.center,
          children: [
            RotationTransition(
              turns: _orbit,
              child: SvgPicture.string(_orbitOverlaySvg(widget.emblem!),
                  height: _artH, fit: BoxFit.contain),
            ),
            _svg(_emblemSvg(widget.emblem!)),
          ],
        );

      // Astrologia: a lua orbita RÁPIDO (controller próprio, 7s) e o
      // planeta cintila com o brilho varrendo — mais vivo que as rodas
      // informativas, que giram devagar.
      case SectionEmblem.astrology:
        return Stack(
          alignment: Alignment.center,
          children: [
            RotationTransition(
              turns: _orbitQuick,
              child: SvgPicture.string(_svgAstroMoon,
                  height: _artH, fit: BoxFit.contain),
            ),
            _shimmer(_svg(_svgAstroBase), gc),
          ],
        );

      // A pena escreve a linha de feitiço, e recomeça.
      case SectionEmblem.myGrimoire:
        return Stack(
          alignment: Alignment.center,
          children: [
            _svg(_svgMyGrimoireBase),
            _writeReveal(_svg(_svgMyGrimoireLine)),
          ],
        );

      // Brilho varre a superfície.
      case SectionEmblem.crystals:
        return _shimmer(_svg(_svgCrystal), gc);
      case SectionEmblem.metals:
        return _shimmer(_svg(_svgMetal), gc);
      case SectionEmblem.archetypes:
        return _shimmer(_svg(_svgArchetype), gc);

      // O raminho balança ao vento.
      case SectionEmblem.herbs:
        return _sway(_svg(_svgHerb));

      // A chama treme.
      case SectionEmblem.altar:
        return Stack(
          alignment: Alignment.center,
          children: [
            _svg(_svgAltarCandle),
            _flame(_svg(_svgAltarFlame)),
          ],
        );

      // O caldeirão borbulha — e a poção pulsa em menta.
      case SectionEmblem.tools:
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: _brewGlow(gc)),
            _svg(_svgTools),
            ..._bubbles(gc),
          ],
        );

      // A joia do selo pulsa em rubi. Positioned.fill prende o Align ao
      // tamanho da ARTE — solto, ele expandiria à largura da tela e a
      // joia escaparia do selo.
      case SectionEmblem.demons:
        return Stack(
          alignment: Alignment.center,
          children: [
            _svg(_svgDemon),
            Positioned.fill(child: _gem()),
          ],
        );

      // Asas batem devagar.
      case SectionEmblem.angels:
        return Stack(
          alignment: Alignment.center,
          children: [
            _wing(_svg(_svgAngelWingL), left: true),
            _wing(_svg(_svgAngelWingR), left: false),
            _svg(_svgAngelBody),
          ],
        );

      // Os traços rúnicos acendem e apagam, como brasas na pedra.
      case SectionEmblem.runes:
        return Stack(
          alignment: Alignment.center,
          children: [
            _svg(_svgRuneStone),
            FadeTransition(
              opacity: Tween<double>(begin: 0.25, end: 1.0).animate(
                CurvedAnimation(parent: _fast, curve: Curves.easeInOut),
              ),
              child: _svg(_svgRuneMarks),
            ),
          ],
        );

      // Só respiração + estrelas (já têm bastante vida).
      case SectionEmblem.moon:
      case SectionEmblem.sun:
      case SectionEmblem.goddesses:
        return _svg(_emblemSvg(widget.emblem!));
    }
  }

  // --- movimentos característicos ---------------------------------------

  /// Brilho diagonal que varre a arte (cristal, metal, espelho).
  Widget _shimmer(Widget child, GrimoireColors gc) {
    return AnimatedBuilder(
      animation: _sweep,
      builder: (context, _) {
        final x = -0.4 + 1.8 * _sweep.value; // atravessa a peça
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.55),
              Colors.white.withValues(alpha: 0),
            ],
            stops: [
              (x - 0.16).clamp(0.0, 1.0),
              x.clamp(0.0, 1.0),
              (x + 0.16).clamp(0.0, 1.0),
            ],
          ).createShader(rect),
          child: child,
        );
      },
    );
  }

  /// A linha do feitiço se revela da esquerda para a direita, segura, some e
  /// recomeça — a sensação de "escrever".
  Widget _writeReveal(Widget line) {
    return AnimatedBuilder(
      animation: _sweep,
      builder: (context, _) {
        final v = _sweep.value;
        // 0–0.65 escreve · 0.65–0.85 segura · 0.85–1 some
        final edge = Curves.easeInOut.transform((v / 0.65).clamp(0.0, 1.0));
        final opacity =
            v < 0.85 ? 1.0 : (1.0 - (v - 0.85) / 0.15).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, edge, edge],
            ).createShader(rect),
            child: line,
          ),
        );
      },
    );
  }

  /// Oscilação suave em torno da base (raminho ao vento).
  Widget _sway(Widget child) {
    return AnimatedBuilder(
      animation: _fast,
      builder: (context, _) {
        final a = (math.sin(_fast.value * math.pi * 2) * 0.05);
        return Transform.rotate(
          angle: a,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
    );
  }

  /// Chama tremulando: escala irregular ancorada perto da base do fogo.
  Widget _flame(Widget flame) {
    return AnimatedBuilder(
      animation: _fast,
      builder: (context, _) {
        final t = _fast.value * math.pi * 2;
        // Amplitude generosa: numa chama pequena, 5% passava despercebido.
        final sx = 1 + 0.10 * math.sin(t * 1.3);
        final sy = 1 + 0.18 * math.sin(t);
        return Transform(
          alignment: const Alignment(0, -0.28), // base da chama
          transform: Matrix4.diagonal3Values(sx, sy, 1),
          child: flame,
        );
      },
    );
  }

  /// Bolhas subindo da boca do caldeirão — muitas, rápidas e brilhando.
  /// Positioned.fill prende cada Align ao tamanho da arte (ver o selo
  /// dos Demônios).
  List<Widget> _bubbles(GrimoireColors gc) {
    return [
      for (var i = 0; i < 5; i++)
        Positioned.fill(
          child: AnimatedBuilder(
          animation: _sweep,
          builder: (context, _) {
            // 2 voltas por ciclo do _sweep: cada bolha sobe em ~1,6s.
            final phase = (_sweep.value * 2 + i * 0.37) % 1.0;
            final dy = -0.02 - phase * 0.42; // sobe
            final op = phase < 0.12
                ? phase / 0.12
                : (1 - (phase - 0.12) / 0.88).clamp(0.0, 1.0);
            final size = (i.isEven ? 8.0 : 6.0) * (0.8 + 0.4 * phase);
            return Align(
              alignment: Alignment(-0.28 + i * 0.14, dy),
              child: Opacity(
                opacity: op,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: gc.mint,
                    boxShadow: [
                      BoxShadow(
                        color: gc.mint.withValues(alpha: 0.7),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          ),
        ),
    ];
  }

  /// O brilho da poção: um halo menta pulsando na boca do caldeirão.
  Widget _brewGlow(GrimoireColors gc) {
    return AnimatedBuilder(
      animation: _fast,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_fast.value);
        return Align(
          // Boca do caldeirão no viewBox da arte (cy 60 de 132).
          alignment: const Alignment(0, -0.09),
          child: Container(
            width: _artH * 0.48,
            height: _artH * 0.13,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.all(Radius.elliptical(999, 999)),
              boxShadow: [
                BoxShadow(
                  color: gc.mint.withValues(alpha: 0.30 + 0.40 * t),
                  blurRadius: 12 + 12 * t,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// A joia do selo pulsa em rubi, com brilho.
  Widget _gem() {
    return AnimatedBuilder(
      animation: _fast,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_fast.value);
        final size = _artH * 0.11;
        return Align(
          alignment: const Alignment(0.08, 0.0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.lerp(
                  const Color(0xFF701226), const Color(0xFFE23A52), t),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE23A52).withValues(alpha: 0.7 * t),
                  blurRadius: 7 * t,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Asa batendo devagar em torno do corpo.
  Widget _wing(Widget wing, {required bool left}) {
    return AnimatedBuilder(
      animation: _fast,
      builder: (context, _) {
        final a = math.sin(_fast.value * math.pi * 2) * 0.16 * (left ? -1 : 1);
        return Transform.rotate(
          angle: a,
          alignment: const Alignment(0, 0.16), // altura do corpo
          child: wing,
        );
      },
    );
  }

  List<Widget> _stars(GrimoireColors gc) {
    // Alinhamento fracionário: sempre simétricas em volta do centro,
    // independentemente do tamanho real do Stack.
    const pos = [
      Alignment(-0.78, -0.55),
      Alignment(0.8, -0.48),
      Alignment(-0.7, 0.6),
      Alignment(0.74, 0.64),
    ];
    return [
      for (var i = 0; i < pos.length; i++)
        Align(
          alignment: pos[i],
          child: _BlinkStar(
            reduced: _isReduced,
            delay: Duration(milliseconds: i * 420),
            color: gc.starYellow,
          ),
        ),
    ];
  }
}

class _BlinkStar extends StatefulWidget {
  final Duration delay;
  final Color color;
  final bool reduced;

  const _BlinkStar(
      {required this.delay, required this.color, required this.reduced});

  @override
  State<_BlinkStar> createState() => _BlinkStarState();
}

class _BlinkStarState extends State<_BlinkStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500));

  @override
  void initState() {
    super.initState();
    if (widget.reduced) {
      _c.value = 0.6;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.15, end: 0.9).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: Text(
        '✦',
        style: TextStyle(fontSize: 11, color: widget.color),
      ),
    );
  }
}

/// Cabeçalho de seção: o emblema vivo + a frase-intro, sob um divisor
/// ornamentado. Recolhe-se suavemente quando a busca/filtro assume o palco.
class SectionEmblemHeader extends StatelessWidget {
  final SectionEmblem? emblem;

  /// Arte própria no lugar do SVG da seção (ver [LivingEmblem.custom]).
  final Widget? customArt;

  final String? intro;

  /// Busca ativa? Então o emblema cede o lugar (recolhe).
  final bool collapsed;

  const SectionEmblemHeader({
    super.key,
    required SectionEmblem this.emblem,
    this.intro,
    this.collapsed = false,
  }) : customArt = null;

  const SectionEmblemHeader.custom({
    super.key,
    required Widget this.customArt,
    this.intro,
    this.collapsed = false,
  }) : emblem = null;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: collapsed
          ? const SizedBox(width: double.infinity)
          : Column(
              children: [
                const SizedBox(height: 4),
                emblem != null
                    ? LivingEmblem(emblem: emblem!)
                    : LivingEmblem.custom(customArt: customArt!),
                if (intro != null && intro!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                    // A intro ocupa SEMPRE a altura de 2 linhas (um texto
                    // invisível de 2 linhas dá a medida exata, no mesmo
                    // estilo/escala): abas com frase curta e longa ficam
                    // com o cabeçalho na mesma altura.
                    child: Builder(builder: (context) {
                      final style =
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: gc.textSecondary,
                              );
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 0,
                            child: Text(' \n ', style: style),
                          ),
                          Text(
                            intro!,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: style,
                          ),
                        ],
                      );
                    }),
                  ),
                _OrnamentDivider(color: gc.gold),
              ],
            ),
    );
  }
}

class _OrnamentDivider extends StatelessWidget {
  final Color color;
  const _OrnamentDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(height: 1, color: context.gc.surfaceBorder),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
      child: Row(
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child:
                Text('✦ ✧ ✦', style: TextStyle(color: color, fontSize: 11)),
          ),
          line,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Arte de cada emblema (pose de repouso). Tons no tema escuro do Grimório.
// Emblemas com movimento próprio têm a parte que se move separada, no MESMO
// viewBox da base — assim empilham alinhados no Stack.
// ---------------------------------------------------------------------------

String _emblemSvg(SectionEmblem e) => switch (e) {
      SectionEmblem.myGrimoire => _svgMyGrimoireBase,
      SectionEmblem.moon => _svgMoon,
      SectionEmblem.sun => _svgSun,
      SectionEmblem.sabbats => _svgSabbatsBase,
      SectionEmblem.crystals => _svgCrystal,
      SectionEmblem.herbs => _svgHerb,
      SectionEmblem.goddesses => _svgGoddess,
      SectionEmblem.elements => _svgElementsBase,
      SectionEmblem.runes => _svgRuneStone,
      SectionEmblem.altar => _svgAltarCandle,
      SectionEmblem.metals => _svgMetal,
      SectionEmblem.astrology => _svgAstroBase,
      SectionEmblem.tools => _svgTools,
      SectionEmblem.archetypes => _svgArchetype,
      SectionEmblem.angels => _svgAngelBody,
      SectionEmblem.demons => _svgDemon,
      SectionEmblem.symbols => _svgSymbolBase,
    };

String _orbitOverlaySvg(SectionEmblem e) => switch (e) {
      SectionEmblem.elements => _svgElementsRing,
      SectionEmblem.sabbats => _svgSabbatsRing,
      SectionEmblem.astrology => _svgAstroMoon,
      SectionEmblem.symbols => _svgSymbolRing,
      _ => '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 130 130"></svg>',
    };

const _ns = 'xmlns="http://www.w3.org/2000/svg"';

// Meu Grimório — pena + tinteiro (base) e a linha (que se escreve).
const _svgMyGrimoireBase = '''
<svg $_ns viewBox="0 0 140 130">
  <rect x="18" y="94" width="14" height="18" rx="3" fill="#3A2647" stroke="#C9A653" stroke-width="1.5"/>
  <ellipse cx="25" cy="94" rx="7" ry="3" fill="#1A1224" stroke="#C9A653" stroke-width="1"/>
  <path d="M120 18 C102 26 82 48 70 76 L78 82 C94 62 110 40 126 26 C126 22 124 19 120 18 Z" fill="#F0E6FA" stroke="#C9A653" stroke-width="1.2"/>
  <path d="M70 76 L64 90 L78 82 Z" fill="#C9A653"/>
</svg>''';
const _svgMyGrimoireLine = '''
<svg $_ns viewBox="0 0 140 130">
  <path d="M36 108 C50 100 54 112 68 104 C82 96 84 108 100 100 C110 95 114 98 120 94" fill="none" stroke="#D98FE0" stroke-width="2.4" stroke-linecap="round"/>
</svg>''';

const _svgMoon = '''
<svg $_ns viewBox="0 0 120 130">
  <path d="M60 20 A42 42 0 1 0 60 104 A33 42 0 1 1 60 20 Z" fill="#C9A0E9"/>
  <circle cx="49" cy="46" r="2.4" fill="#FFE8A3"/>
  <circle cx="46" cy="72" r="1.8" fill="#FFE8A3"/>
</svg>''';

const _svgSun = '''
<svg $_ns viewBox="0 0 130 130">
  <g fill="#FFCF5C">
    <path d="M65 8 L70 30 L60 30 Z"/><path d="M65 122 L70 100 L60 100 Z"/>
    <path d="M8 65 L30 60 L30 70 Z"/><path d="M122 65 L100 60 L100 70 Z"/>
    <path d="M25 25 L44 38 L38 44 Z"/><path d="M105 105 L86 92 L92 86 Z"/>
    <path d="M105 25 L86 38 L92 44 Z"/><path d="M25 105 L44 92 L38 86 Z"/>
  </g>
  <defs><radialGradient id="sg" cx="0.4" cy="0.35"><stop offset="0" stop-color="#FFE8A3"/><stop offset="1" stop-color="#F0A83C"/></radialGradient></defs>
  <circle cx="65" cy="65" r="24" fill="url(#sg)"/>
</svg>''';

const _svgSabbatsBase = '''
<svg $_ns viewBox="0 0 130 130">
  <circle cx="65" cy="65" r="8" fill="#C9A653"/>
</svg>''';
const _svgSabbatsRing = '''
<svg $_ns viewBox="0 0 130 130">
  <circle cx="65" cy="65" r="46" fill="none" stroke="#C9A653" stroke-width="2.5"/>
  <circle cx="65" cy="65" r="30" fill="none" stroke="#C9A653" stroke-opacity="0.4" stroke-width="1"/>
  <g stroke="#C9A653" stroke-width="2">
    <path d="M65 19 L65 111"/><path d="M19 65 L111 65"/>
    <path d="M32.5 32.5 L97.5 97.5"/><path d="M97.5 32.5 L32.5 97.5"/>
  </g>
  <circle cx="65" cy="19" r="5" fill="#FFE8A3"/><circle cx="65" cy="111" r="5" fill="#8FC6E8"/>
  <circle cx="19" cy="65" r="5" fill="#9FD08A"/><circle cx="111" cy="65" r="5" fill="#F0A83C"/>
  <circle cx="32.5" cy="32.5" r="4" fill="#E8934A"/><circle cx="97.5" cy="97.5" r="4" fill="#7FA8D9"/>
  <circle cx="97.5" cy="32.5" r="4" fill="#F2E36B"/><circle cx="32.5" cy="97.5" r="4" fill="#C86B6B"/>
</svg>''';

const _svgCrystal = '''
<svg $_ns viewBox="0 0 120 130">
  <defs><linearGradient id="cg" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#D98FE0"/><stop offset="0.55" stop-color="#8A4FB5"/><stop offset="1" stop-color="#5A2D86"/>
  </linearGradient></defs>
  <polygon points="60,8 88,44 78,118 42,118 32,44" fill="url(#cg)" stroke="#E8C7F0" stroke-opacity="0.5" stroke-width="1.4"/>
  <polyline points="60,8 54,44 42,118" fill="none" stroke="#F6F4FF" stroke-opacity="0.28" stroke-width="1"/>
  <polyline points="60,8 70,44 78,118" fill="none" stroke="#2B1040" stroke-opacity="0.35" stroke-width="1"/>
</svg>''';

const _svgHerb = '''
<svg $_ns viewBox="0 0 120 130">
  <path d="M60 122 C60 96 58 66 60 26" fill="none" stroke="#5E8C4A" stroke-width="3" stroke-linecap="round"/>
  <path d="M60 96 C42 92 34 78 36 66 C52 68 60 80 60 96Z" fill="#6B8E23"/>
  <path d="M60 72 C78 68 86 54 84 42 C68 44 60 56 60 72Z" fill="#7BA05B"/>
  <path d="M60 50 C46 46 40 36 41 27 C53 29 60 38 60 50Z" fill="#8FBC6F"/>
  <circle cx="60" cy="22" r="4" fill="#A7F0D8"/>
</svg>''';

const _svgGoddess = '''
<svg $_ns viewBox="0 0 150 120">
  <circle cx="75" cy="60" r="20" fill="#F6F4FF"/>
  <g fill="#C4C3CE">
    <path d="M38 40 A24 24 0 1 0 38 80 A20 20 0 1 1 38 40Z"/>
    <path d="M112 40 A24 24 0 1 1 112 80 A20 20 0 1 0 112 40Z"/>
  </g>
</svg>''';

const _svgElementsBase = '''
<svg $_ns viewBox="0 0 140 140">
  <circle cx="70" cy="70" r="6" fill="#FFE8A3"/>
</svg>''';
const _svgElementsRing = '''
<svg $_ns viewBox="0 0 140 140">
  <circle cx="70" cy="70" r="44" fill="none" stroke="#FFD700" stroke-opacity="0.35" stroke-dasharray="2 7"/>
  <path d="M70 17 L78 32 L62 32 Z" fill="none" stroke="#F09A38" stroke-width="2"/>
  <path d="M123 70 L108 78 L108 62 Z" fill="none" stroke="#8FC6E8" stroke-width="2"/>
  <path d="M70 123 L62 108 L78 108 Z M64.8 116 L75.2 116" fill="none" stroke="#F2E36B" stroke-width="2"/>
  <path d="M17 70 L32 62 L32 78 Z M24 64.8 L24 75.2" fill="none" stroke="#A0785A" stroke-width="2"/>
</svg>''';

// Runas — pedra (base) e traços (que acendem como brasas). Um eco fraco
// dos traços fica gravado na pedra, para o mínimo da pulsação não "apagar"
// a runa por completo.
const _svgRuneStone = '''
<svg $_ns viewBox="0 0 120 120">
  <ellipse cx="60" cy="64" rx="40" ry="46" fill="#3B3547"/>
  <ellipse cx="57" cy="60" rx="38" ry="44" fill="#4A4458"/>
  <g fill="none" stroke="#5C4A38" stroke-width="5" stroke-linecap="round">
    <path d="M48 36 L48 88"/><path d="M48 44 L72 32"/><path d="M48 62 L72 50"/>
  </g>
</svg>''';
const _svgRuneMarks = '''
<svg $_ns viewBox="0 0 120 120">
  <g fill="none" stroke="#FFB35C" stroke-width="5" stroke-linecap="round">
    <path d="M48 36 L48 88"/><path d="M48 44 L72 32"/><path d="M48 62 L72 50"/>
  </g>
</svg>''';

// Altar — vela (base) e chama (que treme).
const _svgAltarCandle = '''
<svg $_ns viewBox="0 0 120 130">
  <rect x="47" y="56" width="26" height="58" rx="7" fill="#F0EDF6"/>
  <rect x="47" y="56" width="26" height="10" rx="5" fill="#DAD5E6"/>
  <path d="M60 48 L60 58" stroke="#57536B" stroke-width="2"/>
</svg>''';
const _svgAltarFlame = '''
<svg $_ns viewBox="0 0 120 130">
  <path d="M60 14 C70 26 74 34 74 42 A14 14 0 0 1 46 42 C46 34 50 26 60 14Z" fill="#FFB35C"/>
  <path d="M60 26 C65 33 67 38 67 43 A7 7 0 0 1 53 43 C53 38 55 33 60 26Z" fill="#FFE8A3"/>
</svg>''';

const _svgMetal = '''
<svg $_ns viewBox="0 0 130 110">
  <defs><linearGradient id="mg" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#E8E6EF"/><stop offset="0.5" stop-color="#A9A6B8"/><stop offset="1" stop-color="#7C7890"/>
  </linearGradient></defs>
  <rect x="26" y="26" width="90" height="44" rx="9" fill="#57536B"/>
  <rect x="20" y="34" width="90" height="44" rx="9" fill="url(#mg)" stroke="#F6F4FF" stroke-opacity="0.25"/>
</svg>''';

const _svgAstroBase = '''
<svg $_ns viewBox="0 0 150 130">
  <defs><radialGradient id="pg" cx="0.35" cy="0.3">
    <stop offset="0" stop-color="#D98FE0"/><stop offset="0.65" stop-color="#8A5BB8"/><stop offset="1" stop-color="#5A3486"/>
  </radialGradient></defs>
  <path d="M32.2 78.9 A45 13 -18 0 1 117.8 51.1" fill="none" stroke="#FFD700" stroke-opacity="0.45" stroke-width="2.5" stroke-linecap="round"/>
  <circle cx="75" cy="65" r="24" fill="url(#pg)"/>
  <path d="M32.2 78.9 A45 13 -18 0 0 117.8 51.1" fill="none" stroke="#FFD700" stroke-opacity="0.8" stroke-width="2.5" stroke-linecap="round"/>
</svg>''';
const _svgAstroMoon = '''
<svg $_ns viewBox="0 0 150 130">
  <circle cx="75" cy="14" r="10" fill="#E8E2F5" fill-opacity="0.25"/>
  <circle cx="75" cy="14" r="6.5" fill="#E8E2F5"/>
  <circle cx="72.5" cy="12" r="1.6" fill="#C4B8DE"/>
</svg>''';

const _svgTools = '''
<svg $_ns viewBox="0 0 130 132">
  <defs><linearGradient id="ca" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#3A2D4A"/><stop offset="1" stop-color="#1A1224"/>
  </linearGradient></defs>
  <path d="M31 60 C28 88 44 106 65 106 C86 106 102 88 99 60 Z" fill="url(#ca)" stroke="#4A3E5C" stroke-width="1.5"/>
  <ellipse cx="65" cy="60" rx="35" ry="10" fill="#241A32" stroke="#4A3E5C" stroke-width="1.5"/>
  <ellipse cx="65" cy="60" rx="28" ry="7" fill="#66D9B8"/>
  <path d="M44 104 L38 116 M86 104 L92 116" stroke="#4A3E5C" stroke-width="4" stroke-linecap="round"/>
</svg>''';

const _svgArchetype = '''
<svg $_ns viewBox="0 0 104 132">
  <defs><linearGradient id="mi" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#5A3E86"/><stop offset="0.55" stop-color="#3A2647"/><stop offset="1" stop-color="#2A1834"/>
  </linearGradient></defs>
  <rect x="47" y="90" width="10" height="32" rx="5" fill="#C9A653"/>
  <circle cx="52" cy="124" r="6" fill="#E3C878"/>
  <ellipse cx="52" cy="50" rx="34" ry="42" fill="none" stroke="#C9A653" stroke-width="5"/>
  <ellipse cx="52" cy="50" rx="28" ry="36" fill="url(#mi)"/>
</svg>''';

// Anjos — corpo (halo + orbe) e cada asa separada.
const _svgAngelBody = '''
<svg $_ns viewBox="0 0 150 120">
  <ellipse cx="75" cy="26" rx="21" ry="6.5" fill="none" stroke="#FFD700" stroke-width="3.5"/>
  <circle cx="75" cy="70" r="13" fill="#FFE8A3"/>
  <circle cx="75" cy="70" r="13" fill="none" stroke="#FFD700" stroke-opacity="0.7" stroke-width="1.5"/>
</svg>''';
const _svgAngelWingL = '''
<svg $_ns viewBox="0 0 150 120">
  <path d="M68 66 C48 50 26 48 12 58 C22 62 24 68 20 74 C30 74 33 79 31 85 C42 86 46 90 46 95 C56 94 64 86 68 76 Z" fill="#F6F4FF" stroke="#D9D2EC" stroke-width="1"/>
</svg>''';
const _svgAngelWingR = '''
<svg $_ns viewBox="0 0 150 120">
  <path d="M82 66 C102 50 124 48 138 58 C128 62 126 68 130 74 C120 74 117 79 119 85 C108 86 104 90 104 95 C94 94 86 86 82 76 Z" fill="#F6F4FF" stroke="#D9D2EC" stroke-width="1"/>
</svg>''';

const _svgDemon = '''
<svg $_ns viewBox="0 0 104 132">
  <defs><linearGradient id="db" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#33121F"/><stop offset="1" stop-color="#140812"/>
  </linearGradient></defs>
  <rect x="16" y="14" width="72" height="104" rx="9" fill="url(#db)" stroke="#6B2D3E" stroke-width="1.6"/>
  <path d="M25 14 L25 118" stroke="#000000" stroke-opacity="0.4" stroke-width="3"/>
  <path d="M16 23 L30 14 M16 109 L30 118 M88 23 L74 14 M88 109 L74 118" stroke="#C9A653" stroke-width="2.5"/>
  <circle cx="56" cy="66" r="20" fill="none" stroke="#C9A653" stroke-width="2"/>
  <rect x="42" y="88" width="28" height="9" rx="3" fill="#3E2F1E" stroke="#C9A653" stroke-width="1.4"/>
</svg>''';

const _svgSymbolBase = '''
<svg $_ns viewBox="0 0 134 134">
  <circle cx="67" cy="67" r="46" fill="#C9A653" fill-opacity="0.12" stroke="#FFD700" stroke-width="2.5"/>
  <path d="M67 30 L88.9 97.9 L31.2 55.9 L102.8 55.9 L45.1 97.9 Z" fill="none" stroke="#FFD700" stroke-width="3" stroke-linejoin="round"/>
</svg>''';
const _svgSymbolRing = '''
<svg $_ns viewBox="0 0 134 134">
  <circle cx="67" cy="67" r="60" fill="none" stroke="#FFD700" stroke-opacity="0.4" stroke-dasharray="2 7"/>
</svg>''';
