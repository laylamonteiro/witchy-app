import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/grimoire_colors.dart';

/// As seções que têm um "emblema vivo" no topo da lista. A arte de cada uma
/// vem da mesma família de movimento (respiração ~3s, brilho suave, estrelas
/// piscando) — o contrato da [LivingEmblem].
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
/// pulsante e estrelas piscando — a mesma linguagem da BreathingMoon/Sun.
///
/// Altura FIXA (para o deslizar entre abas nunca "pular") e movimento
/// ambiente: congela num quadro bonito quando o sistema pede "reduzir
/// movimento" (acessibilidade).
///
/// Emblemas de natureza orbital (Elementos, Sabbats, Astrologia, Símbolos)
/// ganham uma camada que gira devagar por cima da base.
class LivingEmblem extends StatefulWidget {
  final SectionEmblem emblem;
  final double height;

  const LivingEmblem({super.key, required this.emblem, this.height = 132});

  @override
  State<LivingEmblem> createState() => _LivingEmblemState();
}

class _LivingEmblemState extends State<LivingEmblem>
    with TickerProviderStateMixin {
  late final AnimationController _breathe;
  late final AnimationController _orbit;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _breathe =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _orbit =
        AnimationController(vsync: this, duration: const Duration(seconds: 40));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced != _reduced) {
      _reduced = reduced;
      if (reduced) {
        _breathe.value = 0.5;
        _orbit.stop();
      } else {
        _breathe.repeat(reverse: true);
        _orbit.repeat();
      }
    }
  }

  @override
  void dispose() {
    _breathe.dispose();
    _orbit.dispose();
    super.dispose();
  }

  bool get _orbital =>
      widget.emblem == SectionEmblem.elements ||
      widget.emblem == SectionEmblem.sabbats ||
      widget.emblem == SectionEmblem.astrology ||
      widget.emblem == SectionEmblem.symbols;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final svg = _emblemSvg(widget.emblem);
    final art = SvgPicture.string(
      svg,
      height: widget.height * 0.72,
      fit: BoxFit.contain,
    );

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
                final t =
                    Curves.easeInOut.transform(_breathe.value); // 0..1
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
            // Arte, respirando (com a camada orbital por baixo, se houver).
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.045).animate(
                CurvedAnimation(parent: _breathe, curve: Curves.easeInOut),
              ),
              child: _orbital
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        RotationTransition(
                          turns: _orbit,
                          child: SvgPicture.string(
                            _orbitOverlaySvg(widget.emblem),
                            height: widget.height * 0.9,
                          ),
                        ),
                        art,
                      ],
                    )
                  : art,
            ),
            // Estrelas piscando ao redor.
            ..._stars(gc),
          ],
        ),
      ),
    );
  }

  List<Widget> _stars(GrimoireColors gc) {
    const pos = [
      Offset(-46, -34),
      Offset(48, -30),
      Offset(-42, 38),
      Offset(44, 40),
    ];
    return [
      for (var i = 0; i < pos.length; i++)
        Positioned(
          left: widget.height / 2 + pos[i].dx,
          top: widget.height / 2 + pos[i].dy,
          child: _BlinkStar(
            reduced: _reduced,
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
/// ornamentado. Recolhe-se suavemente quando a busca assume o palco — a
/// resposta à poluição visual nas listas com busca.
class SectionEmblemHeader extends StatelessWidget {
  final SectionEmblem emblem;
  final String? intro;

  /// Busca ativa? Então o emblema cede o lugar (recolhe).
  final bool collapsed;

  const SectionEmblemHeader({
    super.key,
    required this.emblem,
    this.intro,
    this.collapsed = false,
  });

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
                LivingEmblem(emblem: emblem),
                if (intro != null && intro!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                    child: Text(
                      intro!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: gc.textSecondary,
                          ),
                    ),
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
      child: Container(
        height: 1,
        color: context.gc.surfaceBorder,
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
      child: Row(
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('✦ ✧ ✦',
                style: TextStyle(color: color, fontSize: 11)),
          ),
          line,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Arte de cada emblema (pose de repouso). O movimento vem da [LivingEmblem];
// os tons acompanham o tema escuro do Grimório de Bolso.
// ---------------------------------------------------------------------------

String _emblemSvg(SectionEmblem e) => switch (e) {
      SectionEmblem.myGrimoire => _svgMyGrimoire,
      SectionEmblem.moon => _svgMoon,
      SectionEmblem.sun => _svgSun,
      SectionEmblem.sabbats => _svgSabbatsBase,
      SectionEmblem.crystals => _svgCrystal,
      SectionEmblem.herbs => _svgHerb,
      SectionEmblem.goddesses => _svgGoddess,
      SectionEmblem.elements => _svgElementsBase,
      SectionEmblem.runes => _svgRune,
      SectionEmblem.altar => _svgAltar,
      SectionEmblem.metals => _svgMetal,
      SectionEmblem.astrology => _svgAstroBase,
      SectionEmblem.tools => _svgTools,
      SectionEmblem.archetypes => _svgArchetype,
      SectionEmblem.angels => _svgAngel,
      SectionEmblem.demons => _svgDemon,
      SectionEmblem.symbols => _svgSymbolBase,
    };

/// Camada que gira por cima da base, para os emblemas orbitais.
String _orbitOverlaySvg(SectionEmblem e) => switch (e) {
      SectionEmblem.elements => _svgElementsRing,
      SectionEmblem.sabbats => _svgSabbatsRing,
      SectionEmblem.astrology => _svgAstroMoon,
      SectionEmblem.symbols => _svgSymbolRing,
      _ => '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 130 130"></svg>',
    };

const _ns = 'xmlns="http://www.w3.org/2000/svg"';

// Meu Grimório — a pena sobre a linha de feitiço.
const _svgMyGrimoire = '''
<svg $_ns viewBox="0 0 140 130">
  <rect x="18" y="94" width="14" height="18" rx="3" fill="#3A2647" stroke="#C9A653" stroke-width="1.5"/>
  <ellipse cx="25" cy="94" rx="7" ry="3" fill="#1A1224" stroke="#C9A653" stroke-width="1"/>
  <path d="M36 108 C50 100 54 112 68 104 C82 96 84 108 100 100 C110 95 114 98 120 94" fill="none" stroke="#D98FE0" stroke-width="2.2" stroke-linecap="round"/>
  <path d="M120 18 C102 26 82 48 70 76 L78 82 C94 62 110 40 126 26 C126 22 124 19 120 18 Z" fill="#F0E6FA" stroke="#C9A653" stroke-width="1.2"/>
  <path d="M70 76 L64 90 L78 82 Z" fill="#C9A653"/>
</svg>''';

// Lua — crescente lilás.
const _svgMoon = '''
<svg $_ns viewBox="0 0 120 130">
  <path d="M60 20 A42 42 0 1 0 60 104 A33 42 0 1 1 60 20 Z" fill="#C9A0E9"/>
  <circle cx="49" cy="46" r="2.4" fill="#FFE8A3"/>
  <circle cx="46" cy="72" r="1.8" fill="#FFE8A3"/>
</svg>''';

// Sol — disco com coroa de raios.
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

// Sabbats — base (miolo) + anel giratório.
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

// Cristais — ponta facetada.
const _svgCrystal = '''
<svg $_ns viewBox="0 0 120 130">
  <defs><linearGradient id="cg" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#D98FE0"/><stop offset="0.55" stop-color="#8A4FB5"/><stop offset="1" stop-color="#5A2D86"/>
  </linearGradient></defs>
  <polygon points="60,8 88,44 78,118 42,118 32,44" fill="url(#cg)" stroke="#E8C7F0" stroke-opacity="0.5" stroke-width="1.4"/>
  <polyline points="60,8 54,44 42,118" fill="none" stroke="#F6F4FF" stroke-opacity="0.28" stroke-width="1"/>
  <polyline points="60,8 70,44 78,118" fill="none" stroke="#2B1040" stroke-opacity="0.35" stroke-width="1"/>
</svg>''';

// Ervas — raminho com folhas.
const _svgHerb = '''
<svg $_ns viewBox="0 0 120 130">
  <path d="M60 122 C60 96 58 66 60 26" fill="none" stroke="#5E8C4A" stroke-width="3" stroke-linecap="round"/>
  <path d="M60 96 C42 92 34 78 36 66 C52 68 60 80 60 96Z" fill="#6B8E23"/>
  <path d="M60 72 C78 68 86 54 84 42 C68 44 60 56 60 72Z" fill="#7BA05B"/>
  <path d="M60 50 C46 46 40 36 41 27 C53 29 60 38 60 50Z" fill="#8FBC6F"/>
  <circle cx="60" cy="22" r="4" fill="#A7F0D8"/>
</svg>''';

// Deusas — lua tríplice.
const _svgGoddess = '''
<svg $_ns viewBox="0 0 150 120">
  <circle cx="75" cy="60" r="20" fill="#F6F4FF"/>
  <g fill="#C4C3CE">
    <path d="M38 40 A24 24 0 1 0 38 80 A20 20 0 1 1 38 40Z"/>
    <path d="M112 40 A24 24 0 1 1 112 80 A20 20 0 1 0 112 40Z"/>
  </g>
</svg>''';

// Elementos — miolo + anel de símbolos giratório.
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

// Runas — Fehu na pedra.
const _svgRune = '''
<svg $_ns viewBox="0 0 120 120">
  <ellipse cx="60" cy="64" rx="40" ry="46" fill="#3B3547"/>
  <ellipse cx="57" cy="60" rx="38" ry="44" fill="#4A4458"/>
  <g fill="none" stroke="#FFB35C" stroke-width="5" stroke-linecap="round">
    <path d="M48 36 L48 88"/><path d="M48 44 L72 32"/><path d="M48 62 L72 50"/>
  </g>
</svg>''';

// Altar — vela.
const _svgAltar = '''
<svg $_ns viewBox="0 0 120 130">
  <path d="M60 14 C70 26 74 34 74 42 A14 14 0 0 1 46 42 C46 34 50 26 60 14Z" fill="#FFB35C"/>
  <path d="M60 26 C65 33 67 38 67 43 A7 7 0 0 1 53 43 C53 38 55 33 60 26Z" fill="#FFE8A3"/>
  <rect x="47" y="56" width="26" height="58" rx="7" fill="#F0EDF6"/>
  <rect x="47" y="56" width="26" height="10" rx="5" fill="#DAD5E6"/>
  <path d="M60 48 L60 58" stroke="#57536B" stroke-width="2"/>
</svg>''';

// Metais — lingote.
const _svgMetal = '''
<svg $_ns viewBox="0 0 130 110">
  <defs><linearGradient id="mg" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#E8E6EF"/><stop offset="0.5" stop-color="#A9A6B8"/><stop offset="1" stop-color="#7C7890"/>
  </linearGradient></defs>
  <rect x="26" y="26" width="90" height="44" rx="9" fill="#57536B"/>
  <rect x="20" y="34" width="90" height="44" rx="9" fill="url(#mg)" stroke="#F6F4FF" stroke-opacity="0.25"/>
</svg>''';

// Astrologia — planeta + anel (frente/trás) + luazinha giratória.
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
  <circle cx="75" cy="14" r="4.5" fill="#C4C3CE"/>
</svg>''';

// Ferramentas Mágicas — caldeirão borbulhante.
const _svgTools = '''
<svg $_ns viewBox="0 0 130 132">
  <defs><linearGradient id="ca" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#3A2D4A"/><stop offset="1" stop-color="#1A1224"/>
  </linearGradient></defs>
  <path d="M31 60 C28 88 44 106 65 106 C86 106 102 88 99 60 Z" fill="url(#ca)" stroke="#4A3E5C" stroke-width="1.5"/>
  <ellipse cx="65" cy="60" rx="35" ry="10" fill="#241A32" stroke="#4A3E5C" stroke-width="1.5"/>
  <ellipse cx="65" cy="60" rx="28" ry="7" fill="#66D9B8"/>
  <circle cx="54" cy="54" r="3.5" fill="#A7F0D8"/>
  <circle cx="70" cy="55" r="2.5" fill="#A7F0D8"/>
  <path d="M44 104 L38 116 M86 104 L92 116" stroke="#4A3E5C" stroke-width="4" stroke-linecap="round"/>
</svg>''';

// Arquétipos — espelho de mão.
const _svgArchetype = '''
<svg $_ns viewBox="0 0 104 132">
  <defs><linearGradient id="mi" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#5A3E86"/><stop offset="0.55" stop-color="#3A2647"/><stop offset="1" stop-color="#2A1834"/>
  </linearGradient></defs>
  <rect x="47" y="90" width="10" height="32" rx="5" fill="#C9A653"/>
  <circle cx="52" cy="124" r="6" fill="#E3C878"/>
  <ellipse cx="52" cy="50" rx="34" ry="42" fill="none" stroke="#C9A653" stroke-width="5"/>
  <ellipse cx="52" cy="50" rx="28" ry="36" fill="url(#mi)"/>
  <circle cx="44" cy="38" r="3" fill="#F6F4FF" fill-opacity="0.7"/>
</svg>''';

// Anjos — asas + auréola.
const _svgAngel = '''
<svg $_ns viewBox="0 0 150 120">
  <ellipse cx="75" cy="26" rx="21" ry="6.5" fill="none" stroke="#FFD700" stroke-width="3.5"/>
  <path d="M68 66 C48 50 26 48 12 58 C22 62 24 68 20 74 C30 74 33 79 31 85 C42 86 46 90 46 95 C56 94 64 86 68 76 Z" fill="#F6F4FF" stroke="#D9D2EC" stroke-width="1"/>
  <path d="M82 66 C102 50 124 48 138 58 C128 62 126 68 130 74 C120 74 117 79 119 85 C108 86 104 90 104 95 C94 94 86 86 82 76 Z" fill="#F6F4FF" stroke="#D9D2EC" stroke-width="1"/>
  <circle cx="75" cy="70" r="13" fill="#FFE8A3"/>
  <circle cx="75" cy="70" r="13" fill="none" stroke="#FFD700" stroke-opacity="0.7" stroke-width="1.5"/>
</svg>''';

// Demônios — grimório selado com joia.
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
  <circle cx="56" cy="66" r="7" fill="#E23A52"/>
</svg>''';

// Símbolos Sagrados — medalhão de pentagrama + anel de estrelas giratório.
const _svgSymbolBase = '''
<svg $_ns viewBox="0 0 134 134">
  <circle cx="67" cy="67" r="46" fill="#C9A653" fill-opacity="0.12" stroke="#FFD700" stroke-width="2.5"/>
  <path d="M67 30 L88.9 97.9 L31.2 55.9 L102.8 55.9 L45.1 97.9 Z" fill="none" stroke="#FFD700" stroke-width="3" stroke-linejoin="round"/>
</svg>''';
const _svgSymbolRing = '''
<svg $_ns viewBox="0 0 134 134">
  <circle cx="67" cy="67" r="60" fill="none" stroke="#FFD700" stroke-opacity="0.4" stroke-dasharray="2 7"/>
</svg>''';
