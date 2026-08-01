import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/navigation/encyclopedia_section.dart';
import '../widgets/aged_paper.dart';
import 'encyclopedia_search_page.dart';

/// A capa-sumário da Enciclopédia: um livro antigo aberto sobre a "mesa"
/// roxa do app. Cada linha do sumário leva à seção correspondente.
///
/// As entradas são geradas de [EncyclopediaSection.values] — o MESMO enum que
/// gera a TabBar e o TabBarView —, então reordenar uma aba reordena o sumário
/// junto, automaticamente.
class EncyclopediaIndexPage extends StatelessWidget {
  /// Chamado quando a Bruxa escolhe uma seção no sumário.
  final ValueChanged<EncyclopediaSection> onSectionSelected;

  const EncyclopediaIndexPage({super.key, required this.onSectionSelected});

  /// Emoji de cada seção no sumário (apresentação do livro; os rótulos são
  /// as mesmas chaves l10n das abas).
  static String _emojiFor(EncyclopediaSection section) => switch (section) {
        EncyclopediaSection.bookIndex => '📖',
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Container(
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 96),
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
                      const SizedBox(height: 10),
                      const _OrnamentDivider(),
                      const SizedBox(height: 6),
                      // O sumário: uma linha por seção, na ordem canônica
                      // (pulando a própria capa).
                      for (final section
                          in EncyclopediaSection.values.skip(1)) ...[
                        _IndexEntry(
                          emoji: _emojiFor(section),
                          label: _labelFor(section, l10n),
                          onTap: () => onSectionSelected(section),
                        ),
                      ],
                      const SizedBox(height: 6),
                      const _OrnamentDivider(),
                      const SizedBox(height: 6),
                      // Última linha: a busca global, para quem já sabe o
                      // que procura.
                      _IndexEntry(
                        emoji: '🔍',
                        label: l10n.commonSearch,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EncyclopediaSearchPage(),
                          ),
                        ),
                      ),
                    ],
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
