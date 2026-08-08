import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/navigation/encyclopedia_section.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/starfield_background.dart';
import '../widgets/aged_paper.dart';
import 'encyclopedia_search_page.dart';

/// A capa-sumário da Enciclopédia: um livro antigo aberto sobre a "mesa"
/// roxa do app. Cada linha do sumário leva à seção correspondente.
///
/// As entradas são geradas de [EncyclopediaSection.values] — o MESMO enum que
/// gera a TabBar e o TabBarView —, então reordenar uma aba reordena o sumário
/// junto, automaticamente.
///
/// Whimsy sem fricção: ao montar, a capa do livro "abre sozinha" (~600ms,
/// pulável com um toque); ao escolher uma seção, a folha faz meia-virada
/// (~300ms) e então a aba desliza. Com animações desativadas no sistema,
/// tudo acontece instantaneamente.
class EncyclopediaIndexPage extends StatefulWidget {
  /// Chamado quando a Bruxa escolhe uma seção no sumário.
  final ValueChanged<EncyclopediaSection> onSectionSelected;

  const EncyclopediaIndexPage({super.key, required this.onSectionSelected});

  @override
  State<EncyclopediaIndexPage> createState() => _EncyclopediaIndexPageState();
}

class _EncyclopediaIndexPageState extends State<EncyclopediaIndexPage>
    with TickerProviderStateMixin {
  /// A capa abre só na PRIMEIRA visita da sessão (estático porque o State
  /// morre a cada troca de aba — as sub-páginas não mantêm estado).
  static bool _coverOpenedThisSession = false;

  /// A última saída do índice foi escolhendo uma seção? Se sim, a volta
  /// "fecha o livro": a folha assenta de volta em vez de reabrir a capa.
  static bool _leftViaSection = false;

  /// Abertura da capa (one-shot na primeira visita).
  late final AnimationController _open;

  /// Virada da folha ao escolher uma seção (reversa ao voltar).
  late final AnimationController _flip;

  /// Capa já saiu da árvore? (Depois de aberta, não custa mais nada.)
  bool _coverGone = false;

  /// Esta montagem é a volta de uma seção (folha assentando)?
  bool _closingOnReturn = false;

  /// Seção escolhida, entregue quando a virada termina.
  EncyclopediaSection? _pendingSection;

  @override
  void initState() {
    super.initState();
    _open = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _coverGone = true);
        }
      });
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..addStatusListener(_onFlipStatus);

    _closingOnReturn = _leftViaSection;
    _leftViaSection = false;
    if (_closingOnReturn || _coverOpenedThisSession) {
      // Livro já aberto nesta sessão: monta sem capa; se estamos voltando de
      // uma seção, a folha começa levantada e assenta no post-frame.
      _coverGone = true;
      if (_closingOnReturn) _flip.value = 1.0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final noAnimations = MediaQuery.disableAnimationsOf(context);
      if (_closingOnReturn) {
        if (noAnimations) {
          _flip.value = 0.0;
        } else {
          _flip.reverse();
        }
      } else if (!_coverGone) {
        _coverOpenedThisSession = true;
        if (noAnimations) {
          _open.value = 1.0;
        } else {
          _open.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _open.dispose();
    _flip.dispose();
    super.dispose();
  }

  void _onFlipStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final section = _pendingSection;
    _pendingSection = null;
    if (section != null && mounted) {
      // A próxima montagem do índice "fecha o livro" (folha assenta).
      _leftViaSection = true;
      // Sequencial de propósito: a virada TERMINA e só então a aba desliza —
      // nunca duas animações pesadas no mesmo frame. A folha fica levantada
      // durante o slide (mostrando a próxima página de papel), e este State
      // morre junto com a saída da aba.
      widget.onSectionSelected(section);
    }
  }

  void _selectSection(EncyclopediaSection section) {
    if (_flip.isAnimating || !_coverGone) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      widget.onSectionSelected(section);
      return;
    }
    _pendingSection = section;
    _flip.forward();
  }

  /// Toque durante a abertura pula direto para o livro aberto.
  void _skipOpening() {
    if (_open.isAnimating) _open.value = 1.0;
  }

  /// Emoji de cada seção no sumário (apresentação do livro; os rótulos são
  /// as mesmas chaves l10n das abas).
  static String _emojiFor(EncyclopediaSection section) => switch (section) {
        EncyclopediaSection.bookIndex => '📖',
        EncyclopediaSection.myGrimoire => '✒️',
        EncyclopediaSection.moon => '🌙',
        EncyclopediaSection.sun => '☀️',
        EncyclopediaSection.sabbats => '🔥',
        EncyclopediaSection.crystals => '💎',
        EncyclopediaSection.herbs => '🌿',
        EncyclopediaSection.colors => '🎨',
        EncyclopediaSection.goddesses => '🏛️',
        EncyclopediaSection.elements => '🌍',
        EncyclopediaSection.runes => '🗿',
        EncyclopediaSection.altar => '🕯️',
        EncyclopediaSection.metals => '🔩',
        EncyclopediaSection.archetypes => '🎭',
        EncyclopediaSection.symbols => '✨',
        EncyclopediaSection.angels => '😇',
        EncyclopediaSection.demons => '😈',
      };

  /// Mesmos rótulos das abas (fonte única de nomes).
  static String _labelFor(EncyclopediaSection section, AppLocalizations l10n) =>
      switch (section) {
        EncyclopediaSection.bookIndex => l10n.encyTabIndex,
        EncyclopediaSection.myGrimoire => l10n.grimoireTabMyGrimoire,
        EncyclopediaSection.moon => l10n.encyTabMoon,
        EncyclopediaSection.sun => l10n.encyTabSun,
        EncyclopediaSection.sabbats => l10n.encyTabSabbats,
        EncyclopediaSection.crystals => l10n.encyTabCrystals,
        EncyclopediaSection.herbs => l10n.encyTabHerbs,
        EncyclopediaSection.colors => l10n.encyTabColors,
        EncyclopediaSection.goddesses => l10n.encyTabGoddesses,
        EncyclopediaSection.elements => l10n.encyTabElements,
        EncyclopediaSection.runes => l10n.encyTabRunes,
        EncyclopediaSection.altar => l10n.encyTabAltar,
        EncyclopediaSection.metals => l10n.encyTabMetals,
        EncyclopediaSection.archetypes => l10n.encyTabArchetypes,
        EncyclopediaSection.symbols => l10n.encyCatSacredSymbols,
        EncyclopediaSection.angels => l10n.encyTabAngels,
        EncyclopediaSection.demons => l10n.encyTabDemons,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final page = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AgedPaper(
              // A área de rolagem vive DENTRO da moldura ornamental (linha
              // interna a 18px): o ClipRect corta o texto na borda, para
              // nada aparecer por cima do friso ao rolar.
              child: Padding(
                padding: const EdgeInsets.all(21),
                child: ClipRect(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(9, 9, 9, 75),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.encyIndexTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: BookInk.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.encyIndexSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: BookInk.ink.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // A busca global logo abaixo da instrução, para quem
                    // já sabe o que procura (empilha por cima, sem virar
                    // página) — é o único acesso à busca da enciclopédia.
                    _IndexEntry(
                      emoji: '🔍',
                      label: l10n.commonSearch,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EncyclopediaSearchPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const _OrnamentDivider(),
                    const SizedBox(height: 6),
                    // O sumário: uma linha por seção, na ordem canônica
                    // (pulando a própria capa).
                    for (final section
                        in EncyclopediaSection.values.skip(1)) ...[
                      _IndexEntry(
                        emoji: _emojiFor(section),
                        label: _labelFor(section, l10n),
                        onTap: () => _selectSection(section),
                      ),
                    ],
                    const SizedBox(height: 6),
                    const _OrnamentDivider(),
                  ],
                ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            right: 26,
            bottom: 24,
            child: WaxSeal(),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Stack(
        children: [
          // Por baixo da folha: o fundo do PRÓPRIO tema (o que a Bruxa
          // escolheu nas Configurações) com um céu de estrelas — a virada
          // revela o app se abrindo em magia, e a aba escolhida desliza
          // por cima dessa transição mística.
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: context.gc.background,
                child: StarfieldBackground(
                  starCount: 22,
                  intensity: 0.85,
                  child: Center(
                    child: Text(
                      '✨',
                      style: TextStyle(
                        fontSize: 34,
                        shadows: [
                          Shadow(
                            color: context.gc.lilac.withValues(alpha: 0.8),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // A folha do livro: em repouso é a página parada; ao escolher uma
          // seção, levanta no eixo da lombada (anti-horário, como quem
          // folheia) — e assenta de volta quando o índice é revisitado.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _flip,
              child: page,
              builder: (context, child) {
                if (_flip.value == 0) return child!;
                final t = Curves.easeInOut.transform(_flip.value);
                return Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(pi / 2 * t),
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withValues(alpha: 0.15 * t),
                    ),
                    child: child,
                  ),
                );
              },
            ),
          ),
          // A capa: cobre a página e vira no eixo da lombada até sair de
          // cena. Depois de aberta, sai da árvore (custo zero).
          if (!_coverGone)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _skipOpening,
                child: AnimatedBuilder(
                  animation: _open,
                  builder: (context, _) {
                    final t = Curves.easeInOutCubic.transform(_open.value);
                    // Sentido anti-horário (a capa levanta em direção à
                    // leitora) e nunca exatamente pi: a matriz degenera.
                    final angle = pi * min(t, 0.995);
                    final showBack = t > 0.5;
                    return Transform(
                      alignment: Alignment.centerLeft,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateY(angle),
                      child: showBack
                          ? Transform.flip(
                              flipX: true, child: const _CoverBack())
                          : const _CoverFront(),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Frente da capa: couro roxo profundo com filete dourado e a lua.
class _CoverFront extends StatelessWidget {
  const _CoverFront();

  @override
  Widget build(BuildContext context) {
    // A arte real da capa (aprovada), de borda a borda. Fallback para o
    // couro em gradiente + medalhão caso o asset não carregue.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(4, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/premium/encyclopedia_cover.png',
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) => Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF31234F), Color(0xFF1E1533)],
              ),
              border: Border.all(
                color: const Color(0xFFC9A653).withValues(alpha: 0.8),
                width: 1.4,
              ),
            ),
            child: const Center(
              child: Text(
                '☾',
                style: TextStyle(fontSize: 54, color: Color(0xFFC9A653)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Verso da capa (aparece na metade final da virada): papel creme liso.
class _CoverBack extends StatelessWidget {
  const _CoverBack();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BookInk.paperDark, BookInk.paperLight],
        ),
      ),
    );
  }
}

/// Uma linha do sumário: emoji, nome e a linha pontilhada de livro até a
/// margem, com um asterisco ornamental no fim.
class _IndexEntry extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _IndexEntry({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: BookInk.ink.withValues(alpha: 0.10),
        highlightColor: BookInk.ink.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 17)),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: BookInk.ink,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(child: _DottedLeader()),
              const SizedBox(width: 8),
              Text(
                '✦',
                style: TextStyle(
                  fontSize: 11,
                  color: BookInk.ink.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha pontilhada de sumário (o canvas não tem tracejado nativo:
/// pontinhos desenhados um a um).
class _DottedLeader extends StatelessWidget {
  const _DottedLeader();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 3),
      painter: _DottedLeaderPainter(),
    );
  }
}

class _DottedLeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = BookInk.ink.withValues(alpha: 0.45);
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += 5) {
      canvas.drawCircle(Offset(x, y), 0.9, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Divisor ornamental `✦ ──────── ✦` em tinta.
class _OrnamentDivider extends StatelessWidget {
  const _OrnamentDivider();

  @override
  Widget build(BuildContext context) {
    final ink = BookInk.ink.withValues(alpha: 0.5);
    return Row(
      children: [
        Text('✦', style: TextStyle(fontSize: 11, color: ink)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: ink)),
        const SizedBox(width: 8),
        Text('✦', style: TextStyle(fontSize: 11, color: ink)),
      ],
    );
  }
}
