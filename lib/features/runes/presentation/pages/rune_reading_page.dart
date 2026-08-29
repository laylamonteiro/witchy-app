import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/navigation/grimoire_route.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../data/models/rune_spread_model.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/services/reading_archive_composer.dart';
import '../../../diary/presentation/widgets/save_to_records_button.dart';
import '../../data/data_sources/runes_data.dart';
import '../../data/repositories/rune_reading_repository.dart';
import 'rune_detail_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/widgets/premium_locked_preview.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';

class RuneReadingPage extends StatefulWidget {
  const RuneReadingPage({super.key});

  @override
  State<RuneReadingPage> createState() => _RuneReadingPageState();
}

class _RuneReadingPageState extends State<RuneReadingPage>
    with SingleTickerProviderStateMixin {
  final _questionController = TextEditingController();
  final _repository = RuneReadingRepository();

  RuneSpreadType _selectedSpread = RuneSpreadType.single;
  List<RunePosition>? _drawnRunes;
  late AnimationController _animController;
  bool _isDrawing = false;

  /// Cadência da queda das runas: cada uma leva [GrimoireMotion.reveal] para
  /// assentar, com até 90ms entre vizinhas. Nas mesas grandes o passo aperta
  /// para a entrada inteira caber em [_tetoEntradaMs].
  static final int _duracaoQuedaMs = GrimoireMotion.reveal.inMilliseconds;
  static const int _tetoEntradaMs = 1200;

  int _passoQuedaMs(int quantas) {
    if (quantas <= 1) return 0;
    return min(90, (_tetoEntradaMs - _duracaoQuedaMs) ~/ (quantas - 1));
  }

  int _totalEntradaMs(int quantas) =>
      (quantas - 1) * _passoQuedaMs(quantas) + _duracaoQuedaMs;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _drawRunes() async {
    // Verificar limite diário para usuários free
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.canUseRunes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).oracleDailyLimit),
          backgroundColor: context.gc.alert,
          duration: Duration(seconds: 4),
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

    setState(() {
      _isDrawing = true;
    });

    // Aguardar um momento para efeito dramático
    await Future.delayed(const Duration(milliseconds: 500));

    // Embaralhar runas
    final allRunes = List<RuneModel>.from(runesData)..shuffle();

    // Tirar número de runas baseado no spread
    final count = _selectedSpread.runeCount;
    final drawn = <RunePosition>[];

    for (int i = 0; i < count; i++) {
      final rune = allRunes[i];
      final isReversed = Random().nextBool(); // 50% chance de invertida

      drawn.add(RunePosition(
        position: i,
        rune: rune,
        isReversed: isReversed,
        positionMeaning: _selectedSpread.getPositionMeaning(i),
      ));
    }

    // Incrementar uso de runas
    await authProvider.incrementRuneReadings();

    // Anúncio ANTES de revelar as runas (free, cooldown interno).
    await AdService.instance.showBeforeResult();
    if (!mounted) return;

    setState(() {
      _drawnRunes = drawn;
      _isDrawing = false;
      _aiReading = null;
    });

    // A leitura acabou de se revelar: um único toque físico marca o momento.
    HapticFeedback.lightImpact();

    // Sob "reduzir movimento" as runas aparecem já assentadas; senão, a
    // queda escalonada é dimensionada para a mesa sorteada.
    if (GrimoireMotion.reduced(context)) {
      _animController.value = 1.0;
    } else {
      _animController.duration =
          Duration(milliseconds: _totalEntradaMs(drawn.length));
      _animController.forward(from: 0);
    }

    // Salvar leitura
    await _saveReading(drawn);
    // A tiragem aconteceu: se as runas são o rito de hoje, está cumprido.
    if (mounted) {
      unawaited(
          context.read<DailyCheckinProvider>().completeRite(DailyRites.runes));
    }
  }

  /// Última leitura salva — alimenta o botão "Salvar nos Registros".
  RuneReading? _lastReading;

  /// Interpretação do Conselheiro Místico (Premium), como no Tarot.
  String? _aiReading;
  bool _isReadingAI = false;

  Future<void> _saveReading(List<RunePosition> positions) async {
    final reading = RuneReading(
      id: const Uuid().v4(),
      question: _questionController.text.isNotEmpty
          ? _questionController.text
          : AppLocalizations.of(context).runesNoQuestion,
      spreadType: _selectedSpread,
      positions: positions,
      date: DateTime.now(),
    );

    await _repository.saveReading(
      reading,
      context.read<AuthProvider>().currentUser.id,
    );
    if (mounted) setState(() => _lastReading = reading);
  }

  /// Resumo da tiragem — o material que o Conselheiro lê, seja para o
  /// conselho completo ou para a degustação. O compositor do acervo já
  /// produz o texto limpo.
  String _readingSummary(RuneReading reading) {
    final page = ReadingArchiveComposer.runes(reading);
    return '${page.title}\n${page.content}';
  }

  /// Interpretação do Conselheiro Místico (Premium): tece a leitura das
  /// runas já sorteadas — mesmo fluxo do Tarot.
  Future<void> _askCounselor() async {
    final reading = _lastReading;
    if (reading == null || _isReadingAI) return;

    // Sem acesso o botão nem aparece: o card mostra a degustação no lugar.
    if (!context.read<AuthProvider>().isPremiumEffective) return;

    setState(() => _isReadingAI = true);
    try {
      final question = reading.question.trim();
      final noQuestion =
          question.isEmpty || question == AppLocalizations.of(context).runesNoQuestion;
      final interpretation = await AIService.instance.interpretRuneSpread(
        summary: _readingSummary(reading),
        question: noQuestion ? null : question,
      );
      if (!mounted) return;
      setState(() => _aiReading = interpretation);
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
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).runesReadingTitle),
        backgroundColor: context.gc.darkBackground,
      ),
      backgroundColor: context.gc.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_drawnRunes == null) ...[
              MagicalCard(
                child: Column(
                  children: [
                    const Text('ᚱᚢᚾᚨ', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).runesReadingTitle,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: context.gc.lilac,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).runesReadingIntro,
                      style: TextStyle(
                        color: context.gc.softWhite.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).runesReversedNote,
                      style: TextStyle(
                        color: context.gc.lilac.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                AppLocalizations.of(context).runesChooseLayout,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.gc.lilac,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Opções de spread
              _buildSpreadOption(
                RuneSpreadType.single,
                Icons.crop_square,
              ),
              const SizedBox(height: 12),
              _buildSpreadOption(
                RuneSpreadType.threeCast,
                Icons.view_column,
              ),
              const SizedBox(height: 12),
              _buildSpreadOption(
                RuneSpreadType.nordicCross,
                Icons.add,
              ),
              const SizedBox(height: 12),
              _buildSpreadOption(
                RuneSpreadType.nineWorlds,
                Icons.grid_3x3,
              ),

              const SizedBox(height: 16),

              // Campo de pergunta
              MagicalCard(
                child: TextField(
                  controller: _questionController,
                  style: TextStyle(color: context.gc.softWhite),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).runesQuestionOptional,
                    labelStyle: TextStyle(color: context.gc.lilac),
                    hintText: AppLocalizations.of(context).runesQuestionHint,
                    hintStyle: TextStyle(
                      color: context.gc.softWhite.withValues(alpha: 0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.gc.lilac),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: context.gc.lilac.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.gc.lilac),
                    ),
                  ),
                  maxLines: 2,
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isDrawing ? null : _drawRunes,
                // Enquanto o sorteio prepara a mesa, os glifos do cartão de
                // abertura se revezam no botão; sob "reduzir movimento" fica
                // o indicador circular de sempre.
                icon: !_isDrawing
                    ? const Icon(Icons.auto_awesome)
                    : GrimoireMotion.reduced(context)
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.gc.darkBackground,
                              ),
                            ),
                          )
                        : _GlifosDoSorteio(cor: context.gc.darkBackground),
                label: Text(_isDrawing ? AppLocalizations.of(context).runesDrawing : AppLocalizations.of(context).runesDraw),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.gc.lilac,
                  foregroundColor: context.gc.darkBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  disabledBackgroundColor: context.gc.lilac.withValues(alpha: 0.3),
                ),
              ),

              // Exibir usos restantes para usuários free
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (authProvider.isPremium) return const SizedBox.shrink();
                  final remaining =
                      authProvider.currentUser.remainingRuneReadings;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      AppLocalizations.of(context).oracleRemainingToday('$remaining/${UserModel.freeRuneReadingsLimit}'),
                      style: TextStyle(
                        color: remaining > 0
                            ? context.gc.softWhite.withValues(alpha: 0.6)
                            : context.gc.alert,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],

            // Resultado
            if (_drawnRunes != null) ...[
              _buildReadingResult(_drawnRunes!),
              if (_lastReading != null) ...[
                _buildCounselorCard(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: SaveToRecordsButton(
                    key: ValueKey('save_${_lastReading!.id}'),
                    buildEntry: () {
                      final page = ReadingArchiveComposer.runes(
                        _lastReading!,
                        interpretation: _aiReading,
                      );
                      return FreeWritingModel(
                        userId: context.read<AuthProvider>().currentUser.id,
                        title: page.title,
                        content: page.content,
                        source: FreeWritingSource.runes,
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _drawnRunes = null;
                    _animController.reset();
                    _questionController.clear();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).oracleNewReading),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.gc.lilac,
                  side: BorderSide(color: context.gc.lilac),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpreadOption(RuneSpreadType spread, IconData icon) {
    final isSelected = _selectedSpread == spread;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSpread = spread;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.gc.lilac.withValues(alpha: 0.2)
              : context.gc.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.gc.lilac : context.gc.surfaceBorder,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? context.gc.lilac : context.gc.softWhite,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spread.displayName,
                    style: TextStyle(
                      color: isSelected ? context.gc.lilac : context.gc.softWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spread.description,
                    style: TextStyle(
                      color: context.gc.softWhite.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: context.gc.lilac,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingResult(List<RunePosition> positions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MagicalCard(
          child: Column(
            children: [
              const Text('✨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).oracleYourReading,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: context.gc.lilac,
                    ),
              ),
              if (_questionController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _questionController.text,
                  style: TextStyle(
                    color: context.gc.softWhite.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Runas tiradas — cada uma entra como se lançada na mesa: cai de
        // alguns pixels, assenta rotação e tamanho e acende, uma após a
        // outra. As variações (altura da queda, lado da inclinação) derivam
        // do índice da posição, nunca de sorteio novo: o resultado da
        // tiragem é intocável.
        ...positions.map((position) {
          final indice = position.position;
          final totalMs = _totalEntradaMs(positions.length);
          final inicioMs = indice * _passoQuedaMs(positions.length);
          final curva = Interval(
            inicioMs / totalMs,
            (inicioMs + _duracaoQuedaMs) / totalMs,
            curve: GrimoireMotion.enter,
          );
          // Queda entre 12 e 20px; inclinação de 2–4° alternando o lado.
          final queda = 12.0 + 2.0 * (indice % 5);
          final angulo =
              (indice.isEven ? 1 : -1) * (2 + indice % 3) * pi / 180;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                // Reduzir movimento: a runa aparece já assentada no lugar.
                if (GrimoireMotion.reduced(context)) return child!;
                final t = curva.transform(_animController.value);
                if (t >= 1.0) return child!;
                return Opacity(
                  opacity: t.clamp(0.0, 1.0).toDouble(),
                  child: Transform.translate(
                    offset: Offset(0, -queda * (1 - t)),
                    child: Transform.rotate(
                      angle: angulo * (1 - t),
                      child: Transform.scale(
                        scale: 0.94 + 0.06 * t,
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    GrimoireRoute(
                      builder: (_) => RuneDetailPage(rune: position.rune),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: context.gc.lilac.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                position.rune.symbol,
                                style: TextStyle(
                                  fontSize: 32,
                                  color: context.gc.lilac,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  position.positionMeaning,
                                  style: TextStyle(
                                    color: context.gc.softWhite.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  position.rune.name,
                                  style: TextStyle(
                                    color: context.gc.lilac,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (position.isReversed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.gc.alert.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                AppLocalizations.of(context).runesReversed,
                                style: TextStyle(
                                  color: context.gc.alert,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Palavras-chave, como nos cards da tiragem de Tarot.
                      Wrap(
                        spacing: 6,
                        children: position.rune.keywords
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
                        position.isReversed &&
                                position.rune.reversedMeaning != null
                            ? position.rune.reversedMeaning!
                            : position.rune.divination,
                        style: TextStyle(
                          color: context.gc.softWhite,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Card do Conselheiro Místico: botão premium que vira o texto tecido —
  /// idêntico ao da tiragem de Tarot.
  Widget _buildCounselorCard() {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_lastReading != null &&
              !context.watch<AuthProvider>().isPremiumEffective)
            // Sem acesso: no lugar do botão, o sumário do que o
            // Conselheiro teceria sobre as runas que já estão na mesa.
            _previaDoConselheiro(context)
          else if (_aiReading == null)
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
                    : AppLocalizations.of(context).tarotAdvisorInterpretation,
              ),
            )
          else ...[
            Text(
              AppLocalizations.of(context).tarotAdvisorInterpretation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.gc.lilac,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _aiReading!,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ],
        ],
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

/// Glifos que se revezam no botão enquanto o sorteio prepara a mesa — os
/// mesmos caracteres do cartão de abertura ('ᚱᚢᚾᚨ'), acendendo e apagando
/// um por vez. Puramente decorativo (o rótulo do botão já diz o estado),
/// por isso fora da árvore de semântica.
///
/// Quem decide o fallback sob "reduzir movimento" é o chamador; ainda
/// assim, o loop aqui segue a regra da casa: só começa depois de ler a
/// preferência de acessibilidade, nunca no initState.
class _GlifosDoSorteio extends StatefulWidget {
  const _GlifosDoSorteio({required this.cor});

  final Color cor;

  @override
  State<_GlifosDoSorteio> createState() => _GlifosDoSorteioState();
}

class _GlifosDoSorteioState extends State<_GlifosDoSorteio>
    with SingleTickerProviderStateMixin {
  static const List<String> _glifos = ['ᚱ', 'ᚢ', 'ᚾ', 'ᚨ'];

  late final AnimationController _c;
  bool? _reduzido;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduzido = MediaQuery.disableAnimationsOf(context);
    if (reduzido == _reduzido) return;
    _reduzido = reduzido;
    if (reduzido) {
      _c.stop();
      _c.value = 0.5;
    } else {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 20,
        height: 20,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final volta = _c.value * _glifos.length;
            final indice = volta.floor() % _glifos.length;
            // Meia-senoide por glifo: acende e apaga sem sumir de vez.
            final brilho = 0.35 + 0.65 * sin(pi * (volta % 1.0));
            return Center(
              child: Opacity(
                opacity: brilho.clamp(0.0, 1.0).toDouble(),
                child: Text(
                  _glifos[indice],
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.0,
                    fontWeight: FontWeight.bold,
                    color: widget.cor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
