import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/data_sources/tarot_cards_data.dart';
import '../../data/models/tarot_card_model.dart';
import '../widgets/tarot_card_view.dart';
import 'tarot_learn_tab.dart';

/// Tarot: tiragens com significados + tutor de aprendizado.
class TarotPage extends StatefulWidget {
  const TarotPage({super.key});

  @override
  State<TarotPage> createState() => _TarotPageState();
}

class _TarotPageState extends State<TarotPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Tarot'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.gc.lilac,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelPadding: const EdgeInsets.symmetric(horizontal: 24),
          tabs: const [
            Tab(text: 'Tiragem'),
            Tab(text: 'Aprender'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SpreadTab(),
          TarotLearnTab(),
        ],
      ),
    );
  }
}

/// Tipos de tiragem disponíveis.
enum TarotSpread { daily, threeCards, cross }

extension TarotSpreadX on TarotSpread {
  String get displayName => switch (this) {
        TarotSpread.daily => 'Carta do Dia',
        TarotSpread.threeCards => 'Três Cartas',
        TarotSpread.cross => 'Cruz de Cinco',
      };

  String get description => switch (this) {
        TarotSpread.daily => 'A energia que acompanha o seu dia',
        TarotSpread.threeCards => 'Passado · Presente · Futuro',
        TarotSpread.cross =>
          'Situação, desafio, raiz, conselho e tendência',
      };

  String get emoji => switch (this) {
        TarotSpread.daily => '🌞',
        TarotSpread.threeCards => '🔮',
        TarotSpread.cross => '✚',
      };

  List<String> get positions => switch (this) {
        TarotSpread.daily => ['Carta do Dia'],
        TarotSpread.threeCards => ['Passado', 'Presente', 'Futuro'],
        TarotSpread.cross => [
            'Situação',
            'Desafio',
            'Raiz',
            'Conselho',
            'Tendência',
          ],
      };
}

class _SpreadTab extends StatefulWidget {
  const _SpreadTab();

  @override
  State<_SpreadTab> createState() => _SpreadTabState();
}

class _SpreadTabState extends State<_SpreadTab> {
  TarotSpread? _activeSpread;
  List<TarotDrawnCard> _drawn = [];
  bool _revealed = false;

  String? _aiReading;
  bool _isReadingAI = false;

  /// Carta do dia: determinística pela data (mesma carta o dia todo).
  TarotDrawnCard _dailyCard() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    final card = tarotCards[random.nextInt(tarotCards.length)];
    return TarotDrawnCard(
      card: card,
      isReversed: random.nextInt(4) == 0,
      positionLabel: 'Carta do Dia',
    );
  }

  Future<void> _startSpread(TarotSpread spread) async {
    // Carta do dia é determinística e sempre disponível; as demais tiragens
    // seguem o limite diário do plano Free (mesmo contador do Oráculo).
    if (spread != TarotSpread.daily) {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.canUseOracle) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Você já fez sua tiragem gratuita hoje. Assine Premium para tiragens ilimitadas!',
            ),
            backgroundColor: context.gc.alert,
          ),
        );
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const PremiumUpgradeSheet(),
        );
        return;
      }
      await authProvider.incrementOracleReadings();
    }

    final positions = spread.positions;
    List<TarotDrawnCard> drawn;
    if (spread == TarotSpread.daily) {
      drawn = [_dailyCard()];
    } else {
      final random = Random();
      final deck = List<TarotCard>.from(tarotCards)..shuffle(random);
      drawn = [
        for (var i = 0; i < positions.length; i++)
          TarotDrawnCard(
            card: deck[i],
            isReversed: random.nextInt(4) == 0,
            positionLabel: positions[i],
          ),
      ];
    }

    if (!mounted) return;
    setState(() {
      _activeSpread = spread;
      _drawn = drawn;
      _revealed = false;
      _aiReading = null;
    });

    // Pequena pausa de "embaralhamento" antes de revelar.
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _revealed = true);
  }

  Future<void> _askCounselor() async {
    if (_drawn.isEmpty || _isReadingAI) return;

    final authProvider = context.read<AuthProvider>();
    // Interpretação do Conselheiro Místico: exclusiva Premium.
    if (!authProvider.isPremiumEffective) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PremiumUpgradeSheet(),
      );
      return;
    }

    setState(() => _isReadingAI = true);
    try {
      final summary = StringBuffer()
        ..writeln('Tiragem: ${_activeSpread!.displayName}');
      for (final drawn in _drawn) {
        summary.writeln(
          '- ${drawn.positionLabel}: ${drawn.card.name}'
          '${drawn.isReversed ? ' (invertida)' : ''} — ${drawn.meaning}',
        );
      }
      final reading = await AIService.instance
          .interpretTarotSpread(summary: summary.toString());
      if (!mounted) return;
      setState(() => _aiReading = reading);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'.replaceAll('Exception: ', '')),
          backgroundColor: context.gc.alert,
        ),
      );
    } finally {
      if (mounted) setState(() => _isReadingAI = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_activeSpread == null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'Respire fundo, pense na sua pergunta e escolha a tiragem.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.gc.textSecondary,
                    ),
              ),
            ),
            for (final spread in TarotSpread.values)
              InkWell(
                onTap: () => _startSpread(spread),
                borderRadius: BorderRadius.circular(12),
                child: MagicalCard(
                  child: Row(
                    children: [
                      Text(spread.emoji,
                          style: const TextStyle(fontSize: 30)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spread.displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: context.gc.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              spread.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: context.gc.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: context.gc.textSecondary),
                    ],
                  ),
                ),
              ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_activeSpread!.emoji} ${_activeSpread!.displayName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _activeSpread = null;
                      _drawn = [];
                      _aiReading = null;
                    }),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Nova tiragem'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  for (final drawn in _drawn)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      child: _revealed
                          ? Column(
                              key: ValueKey('front_${drawn.positionLabel}'),
                              children: [
                                TarotCardView(
                                  card: drawn.card,
                                  reversed: drawn.isReversed,
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    drawn.positionLabel,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: context.gc.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : TarotCardBack(
                              key: ValueKey('back_${drawn.positionLabel}'),
                            ),
                    ),
                ],
              ),
            ),
            if (_revealed) ...[
              for (final drawn in _drawn)
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${drawn.positionLabel} — ${drawn.card.name}'
                        '${drawn.isReversed ? ' (invertida)' : ''}',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: context.gc.lilac,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: drawn.card.keywords
                            .map((k) => Text(
                                  '· $k',
                                  style: TextStyle(
                                    color: context.gc.textSecondary,
                                    fontSize: 12,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        drawn.meaning,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isReadingAI ? null : _askCounselor,
                      icon: _isReadingAI
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.gc.onPrimary,
                              ),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        _isReadingAI
                            ? 'Consultando as cartas…'
                            : 'Interpretação do Conselheiro Místico',
                      ),
                    ),
                    if (_aiReading != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _aiReading!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.6),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
