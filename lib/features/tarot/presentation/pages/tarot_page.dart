import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/data_sources/tarot_cards_data.dart';
import '../../data/models/tarot_card_model.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/services/reading_archive_composer.dart';
import '../../../diary/presentation/widgets/save_to_records_button.dart';
import '../widgets/tarot_card_view.dart';
import 'tarot_learn_tab.dart';
import 'tarot_library_page.dart';
import '../../../../core/services/ad_service.dart';

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
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).toolTarotTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.gc.lilac,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelPadding: const EdgeInsets.symmetric(horizontal: 24),
          tabs: [
            Tab(text: AppLocalizations.of(context).tarotTabDraw),
            Tab(text: AppLocalizations.of(context).tarotTabLearn),
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
  String displayName(AppLocalizations l10n) => switch (this) {
        TarotSpread.daily => l10n.tarotDailyCard,
        TarotSpread.threeCards => l10n.tarotThreeCards,
        TarotSpread.cross => l10n.tarotCross,
      };

  String description(AppLocalizations l10n) => switch (this) {
        TarotSpread.daily => l10n.tarotDailyDesc,
        TarotSpread.threeCards => l10n.tarotThreeDesc,
        TarotSpread.cross => l10n.tarotCrossDesc,
      };

  String get emoji => switch (this) {
        TarotSpread.daily => '🌞',
        TarotSpread.threeCards => '🔮',
        TarotSpread.cross => '✚',
      };

  List<String> positions(AppLocalizations l10n) => switch (this) {
        TarotSpread.daily => [l10n.tarotDailyCard],
        TarotSpread.threeCards => [
            l10n.tarotPosPast,
            l10n.tarotPosPresent,
            l10n.tarotPosFuture,
          ],
        TarotSpread.cross => [
            l10n.tarotPosSituation,
            l10n.tarotPosChallenge,
            l10n.tarotPosRoot,
            l10n.tarotPosAdvice,
            l10n.tarotPosTendency,
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

  /// Pergunta opcional de quem consulta — capturada ao iniciar a tiragem.
  final _questionController = TextEditingController();
  String _question = '';

  String? _aiReading;
  bool _isReadingAI = false;

  late final String _userId;

  @override
  void initState() {
    super.initState();
    _userId = context.read<AuthProvider>().currentUser.id;
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  /// Assinatura única das cartas tiradas (tipo de tiragem + cartas + invertida).
  /// Serve para reconhecer a MESMA tiragem — inclusive a carta do dia, que é
  /// determinística — e não deixar regerar a interpretação.
  String _signature(TarotSpread spread, List<TarotDrawnCard> drawn) {
    // Usa (naipe, número) — chaves estáveis entre idiomas — para que a
    // interpretação salva sobreviva à troca de idioma do app.
    // Inclui a pergunta: outra pergunta sobre as mesmas cartas gera outra
    // interpretação (não reaproveita o cache).
    return '${spread.name}|'
        '${drawn.map((d) => '${d.card.suit.name}${d.card.number}:${d.isReversed ? 'R' : 'U'}').join('|')}'
        '|q:${_question.toLowerCase()}';
  }

  /// Interpretação salva para exatamente esta assinatura (ou null).
  Future<String?> _savedReadingFor(String signature) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('tarot_sig_$_userId') == signature) {
      return prefs.getString('tarot_ai_$_userId');
    }
    return null;
  }

  Future<void> _persistReading(String signature, String reading) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tarot_sig_$_userId', signature);
    await prefs.setString('tarot_ai_$_userId', reading);
  }

  /// Chave do dia de hoje, para lembrar a última pergunta da carta do dia.
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// Esta pergunta já rendeu a carta do dia HOJE?
  ///
  /// A carta é determinística: a mesma pergunta devolve a mesma carta. Então
  /// repetir a pergunta não é uma tiragem nova — não gasta a cota do dia nem
  /// esbarra no limite (senão a Bruxa ficaria sem poder rever a própria carta).
  Future<bool> _isTodaysDailyQuestion(String question) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tarot_daily_q_$_userId') ==
        '${_todayKey()}|${question.toLowerCase()}';
  }

  Future<void> _rememberDailyQuestion(String question) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'tarot_daily_q_$_userId',
      '${_todayKey()}|${question.toLowerCase()}',
    );
  }

  /// Carta do dia: determinística pela data E pelo usuário (mesma carta o dia
  /// todo, mas diferente para cada pessoa — não é a mesma para todo mundo).
  ///
  /// A PERGUNTA entra na semente: mudar a pergunta muda a carta (cada
  /// pergunta merece a sua), mas repetir a MESMA pergunta no mesmo dia
  /// devolve a mesma carta. Sem pergunta, vale a carta do dia clássica.
  TarotDrawnCard _dailyCard(String question) {
    final now = DateTime.now();
    final asked = question.trim().toLowerCase();
    var seed =
        (now.year * 10000 + now.month * 100 + now.day) ^ _userId.hashCode;
    if (asked.isNotEmpty) seed = seed ^ asked.hashCode;
    final random = Random(seed);
    final card = tarotCards[random.nextInt(tarotCards.length)];
    return TarotDrawnCard(
      card: card,
      isReversed: random.nextInt(4) == 0,
      positionLabel: AppLocalizations.of(context).tarotDailyCard,
    );
  }

  Future<void> _startSpread(TarotSpread spread) async {
    final question = _questionController.text.trim();
    // A carta do dia SEM pergunta é sempre livre: é a mesma o dia inteiro.
    // Com pergunta ela sorteia outra carta — aí é tiragem nova e, no plano
    // Free, gasta a do dia (mesmo contador do Oráculo). Repetir a mesma
    // pergunta devolve a mesma carta e não cobra de novo. As demais tiragens
    // seguem o limite como sempre.
    final isNewDailyQuestion = spread == TarotSpread.daily &&
        question.isNotEmpty &&
        !await _isTodaysDailyQuestion(question);
    if (!mounted) return;

    if (spread != TarotSpread.daily || isNewDailyQuestion) {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.canUseOracle) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).tarotFreeLimitReached,
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
      if (!mounted) return;
    }
    if (isNewDailyQuestion) await _rememberDailyQuestion(question);
    if (!mounted) return;

    final positions = spread.positions(AppLocalizations.of(context));
    List<TarotDrawnCard> drawn;
    if (spread == TarotSpread.daily) {
      drawn = [_dailyCard(question)];
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
    // Anúncio ANTES de revelar as cartas (free, não na carta do dia): a
    // usuária quer o resultado, então o anúncio é visto — e as cartas só
    // aparecem quando ele fecha.
    if (spread != TarotSpread.daily) {
      await AdService.instance.showBeforeResult();
      if (!mounted) return;
    }

    // A tiragem aconteceu: o rito de hoje pode se dar por cumprido.
    unawaited(context.read<DailyCheckinProvider>().completeRite(
          DailyRites.divination,
        ));
    setState(() {
      _activeSpread = spread;
      _question = question;
      _drawn = drawn;
      _revealed = false;
      _aiReading = null;
    });

    // Se estas MESMAS cartas já têm uma interpretação salva, restaura — assim
    // o usuário não fica regerando a resposta (ex.: a carta do dia).
    final saved = await _savedReadingFor(_signature(spread, drawn));

    // Pequena pausa de "embaralhamento" antes de revelar.
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _revealed = true;
      if (saved != null) _aiReading = saved;
    });
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
        ..writeln('${AppLocalizations.of(context).tarotSpreadLabel}: ${_activeSpread!.displayName(AppLocalizations.of(context))}');
      for (final drawn in _drawn) {
        summary.writeln(
          '- ${drawn.positionLabel}: ${drawn.card.name}'
          '${drawn.isReversed ? ' (${AppLocalizations.of(context).tarotReversed})' : ''} — ${drawn.meaning}',
        );
      }
      final reading = await AIService.instance.interpretTarotSpread(
        summary: summary.toString(),
        question: _question.isEmpty ? null : _question,
      );
      if (!mounted) return;
      setState(() => _aiReading = reading);
      // Guarda a interpretação atrelada a estas cartas para não regerar.
      await _persistReading(_signature(_activeSpread!, _drawn), reading);
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
    // Voltar desfaz por camadas: com uma tiragem aberta, o gesto de voltar
    // fecha a tiragem (volta ao seletor) em vez de sair da página inteira.
    return PopScope(
      canPop: _activeSpread == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        setState(() {
          _activeSpread = null;
          _drawn = [];
          _aiReading = null;
          _question = '';
        });
      },
      child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_activeSpread == null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                AppLocalizations.of(context).tarotBreathe,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.gc.textSecondary,
                    ),
              ),
            ),
            // Pergunta opcional: o Conselheiro Místico ancora a leitura nela.
            // Caixa dourada de destaque — é o convite principal da tiragem.
            MagicalCard.accent(
              accent: context.gc.gold,
              child: TextField(
                controller: _questionController,
                maxLines: 2,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: context.gc.textPrimary),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).tarotQuestionOptional,
                  labelStyle: TextStyle(
                    color: context.gc.gold,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: AppLocalizations.of(context).tarotQuestionHint,
                  hintStyle: TextStyle(
                    color: context.gc.starYellow.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                  prefixIcon:
                      Icon(Icons.auto_awesome, color: context.gc.gold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: context.gc.gold.withValues(alpha: 0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: context.gc.gold.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: context.gc.gold, width: 1.5),
                  ),
                ),
              ),
            ),
            // Biblioteca de Cartas: acesso rápido a partir da Tiragem.
            MagicalCard(
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TarotLibraryPage()),
                ),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    const Text('📚', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).tarotLibraryTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: context.gc.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            AppLocalizations.of(context).tarotLibraryDesc,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: context.gc.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: context.gc.textSecondary),
                  ],
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
                              spread.displayName(AppLocalizations.of(context)),
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
                              spread.description(AppLocalizations.of(context)),
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
                    '${_activeSpread!.emoji} ${_activeSpread!.displayName(AppLocalizations.of(context))}',
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
                      _question = '';
                    }),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(AppLocalizations.of(context).tarotNewSpread),
                  ),
                ],
              ),
            ),
            if (_question.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(
                  AppLocalizations.of(context).tarotQuestionPrefix(_question),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
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
                        '${drawn.isReversed ? ' (${AppLocalizations.of(context).tarotReversed})' : ''}',
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
                    if (_aiReading == null)
                      // Sem interpretação para estas cartas: mostra o botão.
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
                              ? AppLocalizations.of(context).tarotConsultingCards
                              : AppLocalizations.of(context)
                                  .tarotAdvisorInterpretation,
                        ),
                      )
                    else ...[
                      // Já interpretado: mostra só o texto. O botão volta apenas
                      // em uma nova tiragem (cartas diferentes).
                      Text(
                        AppLocalizations.of(context).tarotAdvisorInterpretation,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: context.gc.lilac,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: SaveToRecordsButton(
                  // Uma chave por tiragem: o botão renasce a cada cartas
                  // novas (a assinatura muda), mas não ao interpretar.
                  key: ValueKey('save_${_signature(_activeSpread!, _drawn)}'),
                  buildEntry: () {
                    final page = ReadingArchiveComposer.tarot(
                      spreadName: _activeSpread!
                          .displayName(AppLocalizations.of(context)),
                      question: _question,
                      drawn: _drawn,
                      interpretation: _aiReading,
                    );
                    return FreeWritingModel(
                      userId: _userId,
                      title: page.title,
                      content: page.content,
                      source: FreeWritingSource.tarot,
                    );
                  },
                ),
              ),
            ],
          ],
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }
}
