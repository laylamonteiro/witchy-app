import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/navigation/grimoire_route.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../data/data_sources/tarot_cards_data.dart';
import '../../data/models/tarot_card_model.dart';
import '../widgets/tarot_card_view.dart';

/// Biblioteca do baralho: todas as 78 cartas agrupadas por naipe.
/// Tocar numa carta abre o detalhe com imagem grande, significado e o
/// botão de inverter (mostra a leitura da carta invertida).
class TarotLibraryPage extends StatelessWidget {
  const TarotLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = <TarotSuit, List<TarotCard>>{};
    for (final card in tarotCards) {
      groups.putIfAbsent(card.suit, () => []).add(card);
    }

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(
            AppLocalizations.of(context).tarotLibraryTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 10),
              child: Text(
                '${entry.key.emoji} ${entry.key.displayName}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.gc.lilac,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.52,
              ),
              itemCount: entry.value.length,
              itemBuilder: (context, i) {
                final card = entry.value[i];
                final indice = tarotCards.indexOf(card);
                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    GrimoireRoute(
                      builder: (_) => TarotCardDetailPage(
                        initialIndex: indice,
                      ),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) => _CartaHeroi(
                            indice: indice,
                            child: TarotCardView(
                              card: card,
                              width: constraints.maxWidth,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.gc.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Detalhe de uma carta com navegação lateral pelo baralho inteiro.
class TarotCardDetailPage extends StatefulWidget {
  final int initialIndex;

  const TarotCardDetailPage({super.key, required this.initialIndex});

  @override
  State<TarotCardDetailPage> createState() => _TarotCardDetailPageState();
}

class _TarotCardDetailPageState extends State<TarotCardDetailPage> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  bool _reversed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = tarotCards[_index];

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(card.name),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: tarotCards.length,
        onPageChanged: (i) => setState(() {
          _index = i;
          _reversed = false;
        }),
        itemBuilder: (context, i) => _buildCard(context, tarotCards[i], i),
      ),
    );
  }

  Widget _buildCard(BuildContext context, TarotCard card, int indice) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: AnimatedRotation(
              turns: _reversed ? 0.5 : 0,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOutBack,
              child: _CartaHeroi(
                indice: indice,
                child: TarotCardView(card: card, width: 210),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${card.suit.emoji} ${card.suit.displayName} · ${card.displayNumber}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final keyword in card.keywords)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: context.gc.lilac.withValues(alpha: 0.14),
                    border: Border.all(
                      color: context.gc.lilac.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    keyword,
                    style: TextStyle(
                      color: context.gc.lilac,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _reversed = !_reversed),
              icon: AnimatedRotation(
                turns: _reversed ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.swap_vert, size: 18),
              ),
              label: Text(
                _reversed ? l10n.tarotUnflipCard : l10n.tarotFlipCard,
              ),
            ),
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_reversed),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.gc.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _reversed
                      ? context.gc.pink.withValues(alpha: 0.6)
                      : context.gc.surfaceBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _reversed
                        ? '🙃 ${l10n.tarotReversedMeaning}'
                        : '✨ ${l10n.tarotUprightMeaning}',
                    style: TextStyle(
                      color: _reversed ? context.gc.pink : context.gc.lilac,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _reversed ? card.reversed : card.upright,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uma carta que voa entre a grade da biblioteca e o detalhe: o Hero usa o
/// índice da carta no baralho como tag, único e igual nas duas telas, então
/// o voo casa a célula tocada com a página aberta (e, na volta após deslizar,
/// com a célula da carta em que se parou — todas as 78 vivem na grade).
///
/// Sob "reduzir movimento" o voo é desligado (o Flutter não o faz sozinho por
/// MediaQuery): a tela abre direto, como o resto do app.
class _CartaHeroi extends StatelessWidget {
  final int indice;
  final Widget child;

  const _CartaHeroi({required this.indice, required this.child});

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: !GrimoireMotion.reduced(context),
      child: Hero(
        tag: 'tarot_carta_$indice',
        // O voo carrega só a imagem; sombra/borda do TarotCardView vão junto.
        child: child,
      ),
    );
  }
}
