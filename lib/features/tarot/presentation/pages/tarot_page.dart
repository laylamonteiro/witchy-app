import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/repositories/daily_tarot_repository.dart';
import '../../data/repositories/tarot_day_repository.dart';
import '../../domain/daily_tarot_session.dart';
import 'daily_tarot_selection_page.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../domain/regra_da_carta_do_dia.dart';
import '../../data/data_sources/tarot_cards_data.dart';
import '../../data/models/tarot_card_model.dart';
import '../../data/repositories/tarot_reading_repository.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/services/reading_archive_composer.dart';
import '../../../diary/presentation/widgets/save_to_records_button.dart';
import '../widgets/tarot_card_view.dart';
import 'tarot_learn_tab.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/widgets/premium_locked_preview.dart';

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
        children: [
          _SpreadTab(key: ValueKey(context.select<AuthProvider, String>(
              (auth) => auth.currentUser.id))),
          const TarotLearnTab(),
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
  const _SpreadTab({super.key});

  @override
  State<_SpreadTab> createState() => _SpreadTabState();
}

class _SpreadTabState extends State<_SpreadTab>
    with WidgetsBindingObserver {
  TarotSpread? _activeSpread;
  List<TarotDrawnCard> _drawn = [];
  bool _revealed = false;
  bool _starting = false;
  String? _activeDailySignature;
  final _dailyRepository = DailyTarotRepository();

  /// Pergunta de quem consulta — obrigatória, capturada ao iniciar a
  /// tiragem. O foco volta para cá quando alguém tenta tirar sem perguntar.
  final _questionController = TextEditingController();
  final _questionFocus = FocusNode();
  String _question = '';

  /// O que foi posto no campo por esta tela (a pergunta de hoje) e em que
  /// dia. Quando o dia vira com a tela aberta, o campo só é limpo se ainda
  /// mostrar exatamente isto — o que a pessoa digitou por conta própria fica.
  String? _perguntaPreenchida;
  String? _diaPreenchido;

  String? _aiReading;
  bool _isReadingAI = false;

  late final String _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _userId = context.read<AuthProvider>().currentUser.id;
    _carregarPerguntaDoDia();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _questionController.dispose();
    _questionFocus.dispose();
    super.dispose();
  }

  /// Voltou do segundo plano: se o dia virou, a pergunta de ontem sai do
  /// campo (e a de hoje, se já houver, entra).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _carregarPerguntaDoDia();
  }

  /// A carta do dia usa a identidade persistida da sessão. As outras mesas
  /// mantêm a assinatura legada para restaurar a interpretação existente.
  String _signature(TarotSpread spread, List<TarotDrawnCard> drawn) {
    if (spread == TarotSpread.daily && _activeDailySignature != null) {
      return _activeDailySignature!;
    }
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

  /// A pergunta que rendeu a carta do dia HOJE (null se ainda não houve).
  ///
  /// A carta fica persistida: a mesma pergunta devolve a mesma carta. Então
  /// repetir a pergunta não é uma tiragem nova — não gasta a cota do dia nem
  /// esbarra no limite (senão a Bruxa ficaria sem poder rever a própria carta).
  Future<String?> _perguntaDaCartaDeHoje() async =>
      (await TarotDayRepository().read(_userId, DateTime.now())).dailyQuestion;

  Future<void> _rememberDailyQuestion(String question) async {
    await TarotDayRepository().remember(userId: _userId,
        day: DateTime.now(), question: question, daily: true);
  }

  /// A ÚLTIMA pergunta que rendeu uma tiragem (qualquer uma), por conta e
  /// por dia. É ela que volta ao campo ao abrir a tela — a pessoa faz as
  /// outras tiragens sem redigitar. Na Free é, na prática, a da carta do dia
  /// (as demais tiragens gastam a cota); no Premium, a última mesmo. Vira o
  /// dia, some.
  Future<void> _lembrarUltimaPergunta(String question) async {
    await TarotDayRepository().remember(userId: _userId,
        day: DateTime.now(), question: question);
    _perguntaPreenchida = question;
    _diaPreenchido = _todayKey();
  }

  /// Ao abrir (e ao voltar do segundo plano): a pergunta de hoje volta ao
  /// campo; a de ontem, não. Se o dia virou com a tela aberta e o campo
  /// ainda mostra o que foi preenchido, limpa — o que a pessoa digitou fica.
  Future<void> _carregarPerguntaDoDia() async {
    TarotDayState state;
    try {
      state = await TarotDayRepository().read(_userId, DateTime.now());
    } catch (_) {
      return; // A failed draft lookup must not overwrite typed text.
    }
    if (!mounted) return;
    final hoje = _todayKey();
    final deHoje = state.lastQuestion;
    final campo = _questionController.text;
    if (deHoje != null) {
      if (campo.isEmpty || campo == _perguntaPreenchida) {
        _questionController.text = deHoje;
      }
    } else if (_diaPreenchido != null &&
        _diaPreenchido != hoje &&
        campo == _perguntaPreenchida) {
      _questionController.clear();
    }
    _perguntaPreenchida = deHoje;
    _diaPreenchido = hoje;
  }

  /// Reconstrói a mesa registrada hoje: cada carta pelo naipe + número
  /// (chaves estáveis entre idiomas; registros antigos só têm o nome). Null
  /// se algo não bater — aí sorteia de novo, em vez de mostrar mesa capenga.
  List<TarotDrawnCard>? _restaurarMesa(
    List<Map<String, dynamic>> cartas,
    List<String> positions,
  ) {
    if (cartas.length != positions.length) return null;
    final drawn = <TarotDrawnCard>[];
    for (var i = 0; i < cartas.length; i++) {
      final registro = cartas[i];
      final suit = registro['suit'];
      final number = registro['number'];
      TarotCard? card;
      for (final candidata in tarotCards) {
        final porChave = suit is String &&
            number is int &&
            candidata.suit.name == suit &&
            candidata.number == number;
        final porNome = suit == null && candidata.name == registro['name'];
        if (porChave || porNome) {
          card = candidata;
          break;
        }
      }
      if (card == null) return null;
      drawn.add(TarotDrawnCard(
        card: card,
        isReversed: registro['reversed'] == true,
        positionLabel: positions[i],
      ));
    }
    return drawn;
  }

  Future<void> _startSpread(TarotSpread spread) async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      if (spread == TarotSpread.daily) {
        await _startDailySpread();
      } else {
        await _startLegacySpread(spread);
      }
    } on TarotQuotaExceeded {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).tarotFreeLimitReached)));
      await showModalBottomSheet<void>(context: context,
          isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => const PremiumUpgradeSheet());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).cardSelectionLoadError)));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _startDailySpread() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).tarotQuestionRequired)));
      _questionFocus.requestFocus();
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.refreshOracleUsage();
    if (!mounted || auth.currentUser.id != _userId) return;
    final session = await _dailyRepository.prepare(
      userId: _userId,
      question: question,
      catalog: tarotCards,
      premium: auth.isPremiumEffective,
      legacyOracleUsed: auth.currentUser.oracleReadingsToday,
      freeLimit: UserModel.freeOracleReadingsLimit,
    );
    if (!mounted || auth.currentUser.id != _userId) return;
    _questionFocus.unfocus();
    final position = AppLocalizations.of(context).tarotDailyCard;
    DailyTarotCommit? result;
    if (session.isCommitted) {
      result = DailyTarotCommit(session, created: false);
    } else {
      result = await Navigator.of(context).push<DailyTarotCommit>(
        MaterialPageRoute(builder: (_) => DailyTarotSelectionPage(
          session: session,
          onCommit: (cardId) => _dailyRepository.selectAndCommit(
            userId: _userId,
            sessionId: session.id,
            cardId: cardId,
            catalog: tarotCards,
            positionLabel: position,
            isCurrentUser: () => mounted && auth.currentUser.id == _userId,
            isPremium: () => auth.isPremiumEffective,
            freeLimit: UserModel.freeOracleReadingsLimit,
          ),
        )),
      );
    }
    if (!mounted || result == null || auth.currentUser.id != _userId) return;
    final committedResult = result;
    final completed = committedResult.session;
    final entry = completed.card(completed.selectedId!);
    final card = tarotCards.firstWhere((c) => c.id == entry.id);
    final saved = await _dailyRepository.interpretation(completed) ??
        await _savedReadingFor(completed.resultSignature!);
    await auth.refreshOracleUsage();
    if (!mounted || auth.currentUser.id != _userId) return;
    await precacheImage(AssetImage(card.assetPath(TarotDeck.riderWaite)), context,
        onError: (Object error, StackTrace? stack) {});
    if (!mounted || auth.currentUser.id != _userId) return;
    final reduced = GrimoireMotion.reduced(context);
    setState(() {
      _activeSpread = TarotSpread.daily;
      _activeDailySignature = completed.resultSignature;
      _question = completed.question;
      _drawn = [TarotDrawnCard(card: card, isReversed: entry.reversed,
          positionLabel: AppLocalizations.of(context).tarotDailyCard)];
      _revealed = reduced || !committedResult.created;
      _aiReading = saved;
    });
    if (committedResult.created) {
      unawaited(context.read<DailyCheckinProvider>().completeRite(DailyRites.divination));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _activeDailySignature != completed.resultSignature) return;
        setState(() => _revealed = true);
      });
    }
  }

  Future<void> _startLegacySpread(TarotSpread spread) async {
    final question = _questionController.text.trim();
    // Sem pergunta não há tiragem: as cartas respondem a alguma coisa. O
    // toque no card é o que ensina a regra — o aviso vem com o foco no campo.
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).tarotQuestionRequired),
          backgroundColor: context.gc.alert,
        ),
      );
      _questionFocus.requestFocus();
      return;
    }

    // A cota é por PERGUNTA, não por tiragem: com a pergunta do dia a pessoa
    // faz cada tiragem (carta do dia, três cartas, cruz) uma vez; tocar de
    // novo numa mesa já feita hoje só a mostra de novo; uma pergunta nova
    // gasta a cota (mesmo contador do Oráculo) — no Free, a única do dia.
    // Premium não tem cota. Ver decidirTiragem.
    final authProvider = context.read<AuthProvider>();
    await authProvider.refreshOracleUsage();
    if (!mounted || authProvider.currentUser.id != _userId) return;
    final perguntaDoDia = await _perguntaDaCartaDeHoje();
    final registrada = await TarotReadingRepository().drawOfToday(
      userId: _userId,
      spreadName: spread.name,
      question: question,
    );
    if (!mounted) return;
    final decisao = decidirTiragem(
      premium: authProvider.isPremiumEffective,
      perguntaDoDia: perguntaDoDia,
      pergunta: question,
      tiragemJaFeitaHoje: registrada != null,
      temCota: authProvider.canUseOracle,
    );
    switch (decisao) {
      case DecisaoDaTiragem.bloquear:
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
      case DecisaoDaTiragem.cobrar:
        await authProvider.incrementOracleReadings();
        if (!mounted) return;
        break;
      case DecisaoDaTiragem.liberar:
      case DecisaoDaTiragem.repetir:
        break;
    }
    // A pergunta que segura a cota de hoje: a primeira do dia e cada nova
    // cobrada (no Premium é só memória).
    if (decisao == DecisaoDaTiragem.cobrar || perguntaDoDia == null) {
      await _rememberDailyQuestion(question);
    }
    // E, para qualquer tiragem, a última pergunta — a que volta ao campo.
    await _lembrarUltimaPergunta(question);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final positions = spread.positions(l10n);
    // Mesa já feita hoje com esta pergunta: as MESMAS cartas, sem sortear de
    // novo (a cota é por pergunta) e sem anúncio — é uma revisita.
    final restaurada =
        decisao == DecisaoDaTiragem.repetir && registrada != null
            ? _restaurarMesa(registrada, positions)
            : null;
    List<TarotDrawnCard> drawn;
    if (restaurada != null) {
      drawn = restaurada;
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
    // Anúncio ANTES de revelar as cartas (free, não na carta do dia nem na
    // revisita): a usuária quer o resultado, então o anúncio é visto — e as
    // cartas só aparecem quando ele fecha.
    if (spread != TarotSpread.daily && restaurada == null) {
      await AdService.instance.showBeforeResult();
      if (!mounted) return;
    }
    if (restaurada != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tarotRepeatingToday)),
      );
    }

    // A tiragem aconteceu: o rito de hoje pode se dar por cumprido.
    unawaited(context.read<DailyCheckinProvider>().completeRite(
          DailyRites.divination,
        ));
    setState(() {
      _activeSpread = spread;
      _activeDailySignature = null;
      _question = question;
      _drawn = drawn;
      _revealed = false;
      _aiReading = null;
    });

    // Se estas MESMAS cartas já têm uma interpretação salva, restaura — assim
    // o usuário não fica regerando a resposta (ex.: a carta do dia).
    final saved = await _savedReadingFor(_signature(spread, drawn));

    // A mesa revelada é registro da jornada (como cada consulta de runas já
    // era) — é daqui que a Leitura do Ciclo enxerga o tarô do período.
    // Idempotente por assinatura: reabrir a carta do dia não duplica.
    unawaited(TarotReadingRepository().recordDraw(
      userId: _userId,
      spreadName: spread.name,
      signature: _signature(spread, drawn),
      drawn: drawn,
      question: question,
    ));

    // Pequena pausa de "embaralhamento" antes de revelar.
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    // Um toque só por revelação: a mesa vira como um evento único, não um
    // tique por carta — e vale também sob "reduzir movimento".
    HapticFeedback.lightImpact();
    setState(() {
      _revealed = true;
      if (saved != null) _aiReading = saved;
    });
  }

  /// Resumo das cartas na mesa — o material que o Conselheiro lê, seja para
  /// o conselho completo ou para a degustação.
  String _spreadSummary() {
    final l10n = AppLocalizations.of(context);
    final summary = StringBuffer()
      ..writeln('${l10n.tarotSpreadLabel}: '
          '${_activeSpread!.displayName(l10n)}');
    for (final drawn in _drawn) {
      summary.writeln(
        '- ${drawn.positionLabel}: ${drawn.card.name}'
        '${drawn.isReversed ? ' (${l10n.tarotReversed})' : ''} — ${drawn.meaning}',
      );
    }
    return summary.toString();
  }

  Future<void> _askCounselor() async {
    if (_drawn.isEmpty || _isReadingAI) return;

    // Interpretação do Conselheiro Místico: exclusiva Premium. Sem acesso o
    // botão nem aparece — o card mostra a degustação no lugar.
    if (!context.read<AuthProvider>().isPremiumEffective) return;

    setState(() => _isReadingAI = true);
    try {
      final reading = await AIService.instance.interpretTarotSpread(
        summary: _spreadSummary(),
        question: _question.isEmpty ? null : _question,
      );
      if (!mounted) return;
      setState(() => _aiReading = reading);
      // Guarda a interpretação atrelada a estas cartas para não regerar.
      await _persistReading(_signature(_activeSpread!, _drawn), reading);
      // E anexa ao registro da tiragem — a Leitura do Ciclo cita a resposta.
      unawaited(TarotReadingRepository().attachInterpretation(
        userId: _userId,
        signature: _signature(_activeSpread!, _drawn),
        interpretation: reading,
      ));
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
            // Pergunta obrigatória: as cartas e o Conselheiro Místico ancoram
            // a leitura nela. Caixa dourada — é o convite principal da tiragem.
            MagicalCard.accent(
              accent: context.gc.gold,
              child: TextField(
                controller: _questionController,
                focusNode: _questionFocus,
                maxLines: 2,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: context.gc.textPrimary),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).tarotQuestionLabel,
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
            for (final spread in TarotSpread.values)
              InkWell(
                onTap: _starting ? null : () => _startSpread(spread),
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
                  for (var i = 0; i < _drawn.length; i++)
                    TarotFlipCard(
                      key: ValueKey('carta_${_drawn[i].positionLabel}'),
                      revealed: _revealed,
                      // Stagger: cada carta começa 90 ms depois da anterior —
                      // a mesa vira em onda, sem esperar ninguém terminar.
                      delay: Duration(milliseconds: 90 * i),
                      back: const TarotCardBack(),
                      front: TarotCardView(
                        card: _drawn[i].card,
                        reversed: _drawn[i].isReversed,
                      ),
                      caption: SizedBox(
                        width: 110,
                        child: Text(
                          _drawn[i].positionLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.gc.textSecondary,
                            fontSize: 12,
                          ),
                        ),
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
                    if (!context.watch<AuthProvider>().isPremiumEffective)
                      // Sem acesso: no lugar do botão, o sumário do que o
                      // Conselheiro teceria sobre as cartas que já estão na
                      // mesa.
                      _previaDoConselheiro(context)
                    else if (_aiReading == null)
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

/// O que o Conselheiro Místico teceria sobre a tiragem que já está na mesa.
///
/// Sem Premium não sai chamada de IA nenhuma: os títulos são fixos, e o que
/// eles mostram é a FORMA da leitura — como as peças conversam, a narrativa
/// que formam, a resposta à pergunta e o conselho final. É mais informação
/// do que a antiga degustação dava, e não custa geração.
Widget _previaDoConselheiro(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return PremiumLockedPreview(
    titles: [
      l10n.counselorLockedTitle1,
      l10n.counselorLockedTitle2,
      l10n.counselorLockedTitle3,
      l10n.counselorLockedTitle4,
    ],
  );
}
