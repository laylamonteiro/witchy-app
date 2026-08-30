import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/services/reading_archive_composer.dart';
import '../../../diary/presentation/widgets/save_to_records_button.dart';
import 'dart:math';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/living_emblem.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../auth/auth.dart';
import '../../data/models/pendulum_model.dart';
import '../../../../core/services/ad_service.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';

class PendulumPage extends StatefulWidget {
  const PendulumPage({super.key});

  @override
  State<PendulumPage> createState() => _PendulumPageState();
}

class _PendulumPageState extends State<PendulumPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _questionController = TextEditingController();

  late AnimationController _swingController;

  /// Envelope de amortecimento: 0 = amplitude cheia, 1 = pêndulo assentado.
  /// Multiplica a oscilação nos últimos ~650 ms para o cristal PERDER força
  /// e pousar, em vez do corte seco para ângulo zero que havia antes.
  late AnimationController _settleController;
  late final CurvedAnimation _settle;

  /// Revelação da resposta: glow curto no rótulo sorteado e entrada do card
  /// de interpretação (fade + subida de 8 px).
  late AnimationController _revealController;

  PendulumAnswer? _answer;

  /// Última consulta salva — alimenta o botão "Salvar nos Registros".
  PendulumConsultation? _lastConsultation;
  String _question = '';
  bool _isSwinging = false;

  /// Inclinação lateral do aparelho (−1..1), suavizada. É ENFEITE puro: o
  /// cristal pende para o lado que a mão inclina. NUNCA toca no sorteio da
  /// resposta — só entra no ângulo desenhado.
  final ValueNotifier<double> _inclinacao = ValueNotifier<double>(0);
  StreamSubscription<AccelerometerEvent>? _sensorSub;
  double _tiltFiltrado = 0;
  bool? _sensorLigado;

  /// Só onde há acelerômetro de verdade: no navegador o Safari exige
  /// permissão por gesto e o desktop não vibra nem inclina — melhor deixar
  /// o pêndulo exatamente como era.
  static bool get _plataformaComSensor =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  void _assinarSensor() {
    _sensorSub ??= accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 33), // ~30 Hz basta
    ).listen(
      (e) {
        // x é a inclinação lateral (±g no limite). Normaliza, suaviza com
        // passa-baixa e clampa — mão trêmula não vira cristal epilético.
        final alvo = (-e.x / 9.8).clamp(-1.0, 1.0);
        _tiltFiltrado = _tiltFiltrado * 0.85 + alvo * 0.15;
        final v = _tiltFiltrado.clamp(-1.0, 1.0).toDouble();
        if ((v - _inclinacao.value).abs() > 0.005) _inclinacao.value = v;
      },
      onError: (_) {
        // Sensor indisponível (MissingPluginException em teste/desktop): o
        // pêndulo segue como antes, sem inclinação.
        _desassinarSensor();
        _inclinacao.value = 0;
      },
      cancelOnError: true,
    );
  }

  void _desassinarSensor() {
    _sensorSub?.cancel();
    _sensorSub = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _swingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _settleController = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
    // easeOut no envelope = decaimento tipo exponencial: perde muito no
    // começo e pousa devagar, como um pêndulo de verdade.
    _settle = CurvedAnimation(parent: _settleController, curve: Curves.easeOut);
    _revealController = AnimationController(
      duration: GrimoireMotion.reveal,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // "Reduzir movimento" desliga a inclinação, como todo o resto.
    final quer = !GrimoireMotion.reduced(context) && _plataformaComSensor;
    if (quer == _sensorLigado) return;
    _sensorLigado = quer;
    if (quer) {
      _assinarSensor();
    } else {
      _desassinarSensor();
      _inclinacao.value = 0;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!(_sensorLigado ?? false)) return;
    // Em segundo plano o acelerômetro só gasta bateria.
    if (state == AppLifecycleState.resumed) {
      _assinarSensor();
    } else if (state == AppLifecycleState.paused) {
      _desassinarSensor();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _desassinarSensor();
    _inclinacao.dispose();
    _questionController.dispose();
    _swingController.dispose();
    _settle.dispose();
    _settleController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _askPendulum() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Verificar limite diário (para TODOS os usuários)
    if (!authProvider.canUsePendulum) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pendulumUsedAll),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    if (_question.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pendulumAskFirst),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    // ✅ Incrementar contador ANTES da animação (reserva a consulta imediatamente)
    await authProvider.incrementPendulumUses();
    if (!mounted) return;

    // Lida antes dos awaits: a preferência vale para a consulta inteira.
    final reduced = GrimoireMotion.reduced(context);

    setState(() {
      _isSwinging = true;
      _answer = null;
    });

    if (reduced) {
      // Sem movimento: uma pausa curta de "consulta" e direto à resposta.
      await Future.delayed(const Duration(milliseconds: 600));
    } else {
      _settleController.value = 0;
      _swingController.repeat(reverse: true);

      // Oscila com força e, no fim, perde amplitude até assentar — o total
      // continua ~3 s, mas o pouso é físico em vez de corte seco.
      await Future.delayed(const Duration(milliseconds: 2350));
      if (!mounted) return;
      try {
        await _settleController.forward(from: 0).orCancel;
      } on TickerCanceled {
        return;
      }
      if (!mounted) return;
      _swingController.stop();
    }

    if (!mounted) return;
    _showAnswer(); // Chamar diretamente após assentar
  }

  Future<void> _showAnswer() async {
    // Gerar resposta aleatória
    final answers = PendulumAnswer.values;
    final random = Random();

    // Anúncio ANTES de revelar a resposta (free, cooldown interno).
    await AdService.instance.showBeforeResult();
    if (!mounted) return;

    setState(() {
      _answer = answers[random.nextInt(answers.length)];
      _isSwinging = false;
    });

    // A resposta assentou: um toque leve, e o destaque/card entram juntos.
    HapticFeedback.lightImpact();
    if (GrimoireMotion.reduced(context)) {
      _revealController.value = 1.0;
    } else {
      _revealController.forward(from: 0);
    }

    // Salvar histórico
    _saveConsultation();
    // A resposta veio: se o pêndulo é o rito de hoje, está cumprido.
    unawaited(
        context.read<DailyCheckinProvider>().completeRite(DailyRites.pendulum));
  }

  Future<void> _saveConsultation() async {
    if (_answer == null) return;

    final db = await DatabaseHelper.instance.database;
    final consultation = PendulumConsultation(
      id: const Uuid().v4(),
      question: _question,
      answer: _answer!,
      date: DateTime.now(),
    );

    final now = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'id': consultation.id,
      'user_id': context.read<AuthProvider>().currentUser.id,
      'question': consultation.question,
      'answer': consultation.answer.name,
      'date': consultation.date.millisecondsSinceEpoch,
      'created_at': now,
      'updated_at': now,
      'synced': 0,
    };
    await db.insert(
      'pendulum_consultations',
      data,
    );
    await DataSyncService().syncItem(SyncEntity.pendulumConsultations, data);
    if (mounted) setState(() => _lastConsultation = consultation);

    // Contador já foi incrementado em _askPendulum() antes da animação
    // para prevenir múltiplas consultas simultâneas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).pendulumTitle),
        backgroundColor: context.gc.darkBackground,
      ),
      backgroundColor: context.gc.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  const Text('⟟', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).pendulumConsult,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: context.gc.lilac,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).pendulumIntro,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.softWhite.withValues(alpha: 0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Indicador de uso diário
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final remaining = auth.remainingPendulumUses;
                      final used = auth.currentUser.pendulumUsesToday;
                      final total = UserModel.dailyPendulumLimit;
                      final isUnlimited = remaining < 0; // Admin
                      final hasRemaining = isUnlimited || remaining > 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: hasRemaining
                              ? context.gc.success.withValues(alpha: 0.2)
                              : context.gc.alert.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: hasRemaining
                                ? context.gc.success.withValues(alpha: 0.5)
                                : context.gc.alert.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUnlimited
                                  ? Icons.all_inclusive
                                  : (hasRemaining
                                      ? Icons.check_circle
                                      : Icons.timer),
                              size: 16,
                              color: hasRemaining
                                  ? context.gc.success
                                  : context.gc.alert,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isUnlimited
                                  ? AppLocalizations.of(context).pendulumUnlimitedAdmin
                                  : (hasRemaining
                                      ? AppLocalizations.of(context)
                                          .pendulumRemainingToday(
                                              '$remaining', '$total')
                                      : AppLocalizations.of(context).pendulumUsedComeBack('$used', '$total')),
                              style: TextStyle(
                                fontSize: 12,
                                color: hasRemaining
                                    ? context.gc.success
                                    : context.gc.alert,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Visualização do pêndulo
            MagicalCard(
              child: SizedBox(
                height: 300,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    const h = 300.0;
                    final anchor = Offset(w / 2, 20);
                    // Corda um pouco mais curta que antes (0.6 → 0.5): o cristal
                    // pendurado é maior que a antiga setinha e precisa de folga
                    // acima do rótulo "TALVEZ".
                    final cordLength = h * 0.5;
                    // O cristal é o MESMO ícone dos emblemas (SectionEmblem
                    // .crystals), de cabeça para baixo. viewBox 120x130; o topo
                    // achatado fica em y=118 → invertido em y=12. A corrente
                    // prende nesse topo, e o cristal gira em torno dele.
                    const crystalH = 54.0;
                    const flatTopFrac = 12 / 130;
                    const attachTop = flatTopFrac * crystalH;
                    const alignY = flatTopFrac * 2 - 1;
                    final crystalBoxW = crystalH * 120 / 130;
                    return AnimatedBuilder(
                      animation: Listenable.merge([
                        _swingController,
                        _settleController,
                        _revealController,
                        _inclinacao,
                      ]),
                      builder: (context, _) {
                        // O envelope (1 → 0) amortece a oscilação no fim da
                        // consulta: o cristal perde força e pousa no centro. O
                        // ângulo = oscilação amortecida MAIS a inclinação do
                        // aparelho (repouso pende mais; na consulta, um
                        // vestígio). Enfeite: o sorteio não vê nada disto.
                        final swing = (_isSwinging
                                ? sin(_swingController.value * 2 * pi) *
                                    0.8 *
                                    (1 - _settle.value)
                                : 0.0) +
                            _inclinacao.value * (_isSwinging ? 0.05 : 0.12);
                        final bob = Offset(
                          anchor.dx + sin(swing) * cordLength * 0.5,
                          anchor.dy + cos(swing) * cordLength,
                        );
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Corrente dourada + rótulos + fixação.
                            Positioned.fill(
                              child: CustomPaint(
                                painter: PendulumPainter(
                                  anchor: anchor,
                                  bob: bob,
                                  swing: swing,
                                  tilt: _inclinacao.value,
                                  successColor: context.gc.success,
                                  alertColor: context.gc.alert,
                                  starColor: context.gc.starYellow,
                                  yesLabel:
                                      AppLocalizations.of(context).pendulumYes,
                                  noLabel:
                                      AppLocalizations.of(context).pendulumNo,
                                  maybeLabel:
                                      AppLocalizations.of(context).pendulumMaybe,
                                  answer: _answer,
                                  revealProgress: _revealController.value,
                                ),
                              ),
                            ),
                            // O cristal pendurado: mesmo ícone dos emblemas,
                            // invertido, girando junto da corda em torno do topo
                            // (onde a corrente prende).
                            Positioned(
                              left: bob.dx - crystalBoxW / 2,
                              top: bob.dy - attachTop,
                              width: crystalBoxW,
                              height: crystalH,
                              child: Transform.rotate(
                                angle: swing,
                                alignment: const Alignment(0, alignY),
                                child: const IgnorePointer(
                                  child: CrystalGlyph(
                                    height: crystalH,
                                    flipVertical: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Campo de pergunta
            MagicalCard(
              child: TextField(
                controller: _questionController,
                enabled: _answer == null && !_isSwinging,
                style: TextStyle(
                  color: (_answer == null && !_isSwinging)
                      ? context.gc.softWhite
                      : context.gc.softWhite.withValues(alpha: 0.5),
                ),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).pendulumYourQuestion,
                  labelStyle: TextStyle(color: context.gc.lilac),
                  hintText: AppLocalizations.of(context).pendulumQuestionHint,
                  hintStyle: TextStyle(
                    color: context.gc.softWhite.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(Icons.help, color: context.gc.lilac),
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
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.gc.lilac.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.gc.lilac),
                  ),
                ),
                maxLines: 2,
                onChanged: (value) {
                  setState(() {
                    _question = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            if (_answer == null)
              ElevatedButton.icon(
                onPressed: _isSwinging ? null : _askPendulum,
                icon: _isSwinging
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
                    : const Icon(Icons.help),
                label: Text(_isSwinging ? AppLocalizations.of(context).pendulumAsking : AppLocalizations.of(context).pendulumAsk),
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

            if (_answer != null)
              // A interpretação entra depois que o pêndulo assentou: fade +
              // subida curta, junto do destaque da resposta no painter.
              _RevealEntrance(
                animation: _revealController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MagicalCard(
                      child: Column(
                        children: [
                          Text(
                            _answer!.emoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _answer!.displayName,
                            style:
                                Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      color: context.gc.lilac,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _answer!.message,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: context.gc.softWhite,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_lastConsultation != null) ...[
                      SaveToRecordsButton(
                        key: ValueKey('save_${_lastConsultation!.id}'),
                        buildEntry: () {
                          final page =
                              ReadingArchiveComposer.pendulum(_lastConsultation!);
                          return FreeWritingModel(
                            userId: context.read<AuthProvider>().currentUser.id,
                            title: page.title,
                            content: page.content,
                            source: FreeWritingSource.pendulum,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _answer = null;
                          _question = '';
                          _questionController.clear();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(AppLocalizations.of(context).pendulumNewConsult),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.gc.lilac,
                        side: BorderSide(color: context.gc.lilac),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Entrada do bloco de resposta: opacidade 0 → 1 e subida de 8 px, presa à
/// segunda metade da revelação (primeiro o rótulo acende no painter, depois
/// o card chega).
///
/// A forma da árvore é SEMPRE a mesma (Opacity > Transform > filho): um
/// atalho que devolvesse o filho puro no fim trocaria o tipo no slot e
/// re-inflaria o subtree inteiro — o SaveToRecordsButton perderia o estado.
/// Opacity em 1.0 e translação zero são curto-circuitados pelo render.
class _RevealEntrance extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _RevealEntrance({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, inner) {
        final t = animation.value >= 1
            ? 1.0
            : const Interval(0.25, 1, curve: GrimoireMotion.enter)
                .transform(animation.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 8),
            child: inner,
          ),
        );
      },
      child: child,
    );
  }
}

class PendulumPainter extends CustomPainter {
  /// Ponto de fixação (topo) e o peso (onde a corrente encontra o cristal).
  final Offset anchor;
  final Offset bob;

  /// Ângulo do balanço (0 = repouso). Só molda a flexão da corrente — o peso
  /// já vem posicionado em [bob].
  final double swing;

  /// Inclinação do aparelho (−1..1): a corrente escorre de leve para o lado que
  /// a mão pende. Enfeite; jamais toca no sorteio.
  final double tilt;

  final PendulumAnswer? answer;
  final Color successColor;
  final Color alertColor;
  final Color starColor;
  final String yesLabel;
  final String noLabel;
  final String maybeLabel;

  /// Progresso da revelação (0 → 1): o rótulo sorteado acende com um glow
  /// curto que some ao final. Em 1 (ou sem resposta), pinta o estado
  /// estável de sempre.
  final double revealProgress;

  PendulumPainter({
    required this.anchor,
    required this.bob,
    required this.swing,
    required this.tilt,
    required this.successColor,
    required this.alertColor,
    required this.starColor,
    required this.yesLabel,
    required this.noLabel,
    required this.maybeLabel,
    this.answer,
    this.revealProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawChain(canvas);

    // Argola de fixação, dourada, onde a corrente prende.
    canvas.drawCircle(anchor, 3.2, Paint()..color = starColor);
    canvas.drawCircle(
      anchor,
      3.2,
      Paint()
        ..color = Color.lerp(starColor, Colors.white, 0.35)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Desenhar respostas ao redor (sempre visíveis)
    // Destacar a resposta selecionada quando houver resultado
    _drawAnswerText(
      canvas,
      size,
      yesLabel,
      Offset(size.width * 0.2, size.height * 0.5),
      successColor,
      isSelected: answer == PendulumAnswer.yes,
    );
    _drawAnswerText(
      canvas,
      size,
      noLabel,
      Offset(size.width * 0.8, size.height * 0.5),
      alertColor,
      isSelected: answer == PendulumAnswer.no,
    );
    _drawAnswerText(
      canvas,
      size,
      maybeLabel,
      Offset(size.width * 0.5, size.height * 0.8),
      starColor,
      isSelected: answer == PendulumAnswer.maybe,
    );
  }

  /// A corrente dourada fina: um fio curvo (não uma reta rígida) semeado de
  /// elos ovais alternados. Faz barriga para o lado enquanto balança e escorre
  /// com a inclinação — o aspecto maleável de uma correntinha de verdade.
  void _drawChain(Canvas canvas) {
    final chord = bob - anchor;
    final len = chord.distance;
    if (len < 1) return;
    final dir = chord / len;
    final perp = Offset(-dir.dy, dir.dx);
    // Barriga lateral: acompanha o balanço (a corrente "chicoteia" um pouco) e
    // escorre com a inclinação; mais um fio de folga constante para nunca
    // parecer uma vara.
    final lateral = -sin(swing) * len * 0.10 + tilt * 6.0;
    final mid = anchor + chord * 0.5 + perp * lateral + const Offset(0, 3);
    final path = Path()
      ..moveTo(anchor.dx, anchor.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, bob.dx, bob.dy);

    // Fio de base, para dar continuidade entre os elos.
    canvas.drawPath(
      path,
      Paint()
        ..color = starColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round,
    );

    // Elos: ovais pequenos, cruzando a cada passo (elo deitado, elo em pé).
    final elo = Paint()
      ..color = starColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const passo = 6.0;
    for (final metric in path.computeMetrics()) {
      final n = (metric.length / passo).floor();
      for (var i = 1; i < n; i++) {
        final t = metric.getTangentForOffset(i * passo);
        if (t == null) continue;
        canvas.save();
        canvas.translate(t.position.dx, t.position.dy);
        canvas.rotate(
            atan2(t.vector.dy, t.vector.dx) + (i.isEven ? 0.0 : pi / 2));
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 5.2, height: 2.6),
          elo,
        );
        canvas.restore();
      }
    }
  }

  void _drawAnswerText(
      Canvas canvas, Size size, String text, Offset position, Color color,
      {bool isSelected = false}) {
    // O rótulo sorteado cresce e acende junto com a revelação (t = 1 é o
    // estado estável de sempre); os demais ficam no apagado padrão.
    final t = isSelected ? revealProgress.clamp(0.0, 1.0) : 0.0;

    if (isSelected && t > 0 && t < 1) {
      // Glow curto: um halo que se expande e some — só durante a revelação.
      final glow = Paint()
        ..color = color.withValues(alpha: 0.30 * (1 - t))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(position, 14 + 22 * t, glow);
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isSelected
              ? color.withValues(alpha: 0.4 + 0.6 * t)
              : color.withValues(alpha: 0.4),
          fontSize: isSelected ? 12 + 4 * t : 12,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(PendulumPainter oldDelegate) {
    return oldDelegate.anchor != anchor ||
        oldDelegate.bob != bob ||
        oldDelegate.swing != swing ||
        oldDelegate.tilt != tilt ||
        oldDelegate.answer != answer ||
        oldDelegate.revealProgress != revealProgress ||
        oldDelegate.successColor != successColor ||
        oldDelegate.alertColor != alertColor ||
        oldDelegate.starColor != starColor;
  }
}
