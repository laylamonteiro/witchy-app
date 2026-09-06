import 'dart:async';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
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
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/living_emblem.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../auth/auth.dart';
import '../../data/models/pendulum_model.dart';
import '../../domain/inclinacao_do_pendulo.dart';
import '../../../../core/services/ad_service.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';

class PendulumPage extends StatefulWidget {
  /// Fonte do acelerômetro. O teste passa um Stream próprio: no
  /// `flutter test` não existe plugin, e a EventChannel responderia com
  /// MissingPluginException em vez de amostras.
  final Stream<AccelerometerEvent> Function()? acelerometro;

  const PendulumPage({super.key, this.acelerometro});

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

  /// Resposta já sorteada, guardada ANTES do assentamento para o pêndulo
  /// poder pousar apontando para ela (o card/glow só entram depois, via
  /// [_answer]). O sorteio continua puro: isto não o influencia.
  PendulumAnswer? _pendingAnswer;

  /// Ângulo em que o cristal repousa: aponta para a resposta (sim = esquerda,
  /// não = direita, talvez = reto para baixo). O balanço amortecido converge
  /// para cá — o "ricocheteio" que assenta na diagonal.
  double _targetAngle = 0;

  /// Diagonal do sim/não (~28,6°). Mesma constante posiciona os rótulos, então
  /// o cristal aponta exatamente para onde a palavra está.
  static const double _kSwingTarget = 0.5;

  double _anguloDaResposta(PendulumAnswer a) {
    switch (a) {
      case PendulumAnswer.yes:
        return -_kSwingTarget;
      case PendulumAnswer.no:
        return _kSwingTarget;
      case PendulumAnswer.maybe:
        return 0;
    }
  }

  /// Última consulta salva — alimenta o botão "Salvar nos Registros".
  PendulumConsultation? _lastConsultation;

  /// A pergunta da consulta em curso, congelada no toque em "Perguntar". O
  /// campo continua editável durante o balanço, então o que se salva é o que
  /// foi perguntado — não o que estiver no campo quando a resposta chegar.
  String _perguntaConsultada = '';
  bool _isSwinging = false;

  /// θ da corrente (unidades normalizadas; passa de ±1 no overshoot): a
  /// saída da mola que persegue a inclinação do aparelho. É ENFEITE puro: o
  /// cristal pende para o lado que a mão inclina e balança com o tranco da
  /// mão. NUNCA toca no sorteio da resposta — só entra no ângulo desenhado.
  final ValueNotifier<double> _inclinacao = ValueNotifier<double>(0);
  StreamSubscription<AccelerometerEvent>? _sensorSub;
  final _filtro = FiltroDeInclinacao();
  final _mola = MolaDoPendulo();
  double _alvoDaInclinacao = 0;

  /// Quadro a quadro, a mola anda rumo ao alvo — só enquanto o sensor está
  /// ligado (celular, em primeiro plano) e mudo com a aba escondida
  /// (TickerMode), como todo ticker deste State.
  Ticker? _tickerDaMola;
  Duration? _ultimoQuadro;
  bool? _sensorLigado;

  /// 0 = repouso (inclinação no alcance cheio); 1 = consultando/respondido
  /// (só um sopro, para o cristal pousar e apontar no rótulo). Animado para o
  /// teto não dar um pulo no toque em Perguntar.
  late AnimationController _amortecimento;

  /// Só onde há acelerômetro de verdade: no navegador o Safari exige
  /// permissão por gesto e o desktop não vibra nem inclina — melhor deixar
  /// o pêndulo exatamente como era.
  static bool get _plataformaComSensor =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Stream<AccelerometerEvent> _acelerometroDoAparelho() =>
      accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 33), // ~30 Hz basta
      );

  void _assinarSensor() {
    _sensorSub ??= (widget.acelerometro ?? _acelerometroDoAparelho)().listen(
      (e) {
        // x é a inclinação lateral — e também o tranco da mão, que chega no
        // mesmo eixo. Normaliza (fundo de escala em ~30°), tira o ruído e
        // entrega como ALVO da mola: quem balança é a corrente, no ticker.
        _alvoDaInclinacao =
            _filtro.atualizar(InclinacaoDoPendulo.normalizar(e.x));
      },
      onError: (_) {
        // Sensor indisponível (MissingPluginException em teste/desktop): o
        // pêndulo segue como antes, sem inclinação.
        _desassinarSensor();
      },
      cancelOnError: true,
    );
    _tickerDaMola ??= createTicker(_avancarMola)..start();
  }

  void _desassinarSensor() {
    _sensorSub?.cancel();
    _sensorSub = null;
    _tickerDaMola?.dispose();
    _tickerDaMola = null;
    _ultimoQuadro = null;
    _filtro.zerar();
    _mola.zerar();
    _alvoDaInclinacao = 0;
    _inclinacao.value = 0;
  }

  /// Um quadro da corrente: a mola persegue o alvo e o cristal segue θ.
  void _avancarMola(Duration decorrido) {
    final anterior = _ultimoQuadro;
    _ultimoQuadro = decorrido;
    if (anterior == null) return;
    final dt =
        (decorrido - anterior).inMicroseconds / Duration.microsecondsPerSecond;
    final theta = _mola.avancar(dt, _alvoDaInclinacao);
    if ((theta - _inclinacao.value).abs() > 0.002) _inclinacao.value = theta;
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
    _amortecimento = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _amortecimento.dispose();
    super.dispose();
  }

  Future<void> _askPendulum() async {
    // Toque duplo: o segundo toque chegava antes de `_isSwinging` virar true
    // (o await do contador vinha primeiro) e gastava DUAS consultas.
    if (_isSwinging) return;
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

    final pergunta = _questionController.text.trim();
    if (pergunta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pendulumAskFirst),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    // Lida antes dos awaits: a preferência vale para a consulta inteira.
    final reduced = GrimoireMotion.reduced(context);

    // Estado de "consultando" ANTES de qualquer await: é o que tranca o botão
    // contra o toque duplo e congela a pergunta desta consulta.
    setState(() {
      _isSwinging = true;
      _answer = null;
      _pendingAnswer = null;
      _targetAngle = 0;
      _perguntaConsultada = pergunta;
    });
    // Zera a fase antes de tudo: no modo "reduzir movimento" (que não gira o
    // controller) o cristal fica reto durante a pausa, em vez de travado num
    // ângulo herdado da consulta anterior.
    _swingController.value = 0;
    _settleController.value = 0;
    // A inclinação recolhe para o sopro de consulta — animado, para o cristal
    // não pular quando o teto muda.
    if (reduced) {
      _amortecimento.value = 1;
    } else {
      _amortecimento.forward();
    }

    try {
      // Incrementar contador ANTES da animação (reserva a consulta na hora).
      await authProvider.incrementPendulumUses();
      if (!mounted) return;

      if (reduced) {
        // Sem movimento: uma pausa curta de "consulta" e direto à resposta.
        await Future.delayed(const Duration(milliseconds: 600));
      } else {
        _swingController.repeat(reverse: true);

        // Oscila com força e, no fim, perde amplitude até assentar — o total
        // continua ~3 s, mas o pouso é físico em vez de corte seco.
        await Future.delayed(const Duration(milliseconds: 2350));
        if (!mounted) return;

        // Sorteia AGORA, antes do assentamento, para o cristal ricochetear e
        // pousar apontando para a resposta (a revelação — card/glow — só vem
        // depois, em _showAnswer). O sorteio segue puro.
        _pendingAnswer = PendulumAnswer.values[Random().nextInt(3)];
        _targetAngle = _anguloDaResposta(_pendingAnswer!);

        try {
          await _settleController.forward(from: 0).orCancel;
        } on TickerCanceled {
          // Assentamento interrompido (tela coberta, app em segundo plano):
          // o `finally` devolve o botão, em vez de deixá-lo morto.
          return;
        }
        if (!mounted) return;
        _swingController.stop();
      }

      if (!mounted) return;
      await _showAnswer();
    } finally {
      // Qualquer saída SEM resposta (cancelamento, exceção) libera o botão.
      // Antes, o TickerCanceled deixava `_isSwinging` em true para sempre:
      // botão e campo desabilitados até sair da tela.
      if (mounted && _isSwinging) {
        _swingController.stop();
        _amortecimento.reverse();
        setState(() => _isSwinging = false);
      }
    }
  }

  Future<void> _showAnswer() async {
    // O assentamento já sorteou (para o cristal pousar apontando); se veio do
    // modo "reduzir movimento", que pulou o assentamento, sorteia agora.
    final escolhido =
        _pendingAnswer ?? PendulumAnswer.values[Random().nextInt(3)];

    // Anúncio ANTES de revelar a resposta (free, cooldown interno).
    await AdService.instance.showBeforeResult();
    if (!mounted) return;

    setState(() {
      _answer = escolhido;
      _isSwinging = false;
      // O cristal repousa apontando para a resposta.
      _targetAngle = _anguloDaResposta(escolhido);
    });

    // A resposta assentou: um toque leve, e o destaque/card entram juntos.
    HapticFeedback.lightImpact();
    if (GrimoireMotion.reduced(context)) {
      _revealController.value = 1.0;
      // Sem assentamento animado: fixa o cristal no ângulo final da resposta.
      _settleController.value = 1.0;
    } else {
      _revealController.forward(from: 0);
    }

    // Salvar histórico
    _saveConsultation();
    // A resposta veio: se o pêndulo é o rito de hoje, está cumprido.
    unawaited(
        context.read<DailyCheckinProvider>().completeRite(DailyRites.pendulum));
  }

  /// Volta a tela ao estado de "pergunte": a resposta some e o cristal volta
  /// ao repouso (reto), pronto para a próxima pergunta. Chamado pelo botão
  /// "Nova consulta" (que também limpa a pergunta) e por quem edita a
  /// pergunta depois de uma resposta.
  void _reiniciarConsulta({required bool limparPergunta}) {
    setState(() {
      _answer = null;
      _pendingAnswer = null;
      _perguntaConsultada = '';
      if (limparPergunta) _questionController.clear();
      _targetAngle = 0;
      _settleController.value = 0;
    });
    if (GrimoireMotion.reduced(context)) {
      _amortecimento.value = 0;
    } else {
      _amortecimento.reverse();
    }
  }

  Future<void> _saveConsultation() async {
    if (_answer == null) return;

    final db = await DatabaseHelper.instance.database;
    final consultation = PendulumConsultation(
      id: const Uuid().v4(),
      question: _perguntaConsultada,
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

            // Pergunta + Perguntar no MESMO card (como o CTA do card de
            // Leitura do Ciclo), antes do pêndulo: a pessoa se concentra,
            // pergunta e só então o cristal balança abaixo e responde.
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _questionController,
                    // SEMPRE editável. Desabilitar o campo durante a consulta
                    // derrubava o foco: o teclado fechava sozinho enquanto o
                    // pêndulo balançava e, com a resposta na tela, tocar no
                    // campo não abria mais nada. A pergunta consultada já está
                    // congelada em _perguntaConsultada.
                    style: TextStyle(color: context.gc.softWhite),
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context).pendulumYourQuestion,
                      labelStyle: TextStyle(color: context.gc.lilac),
                      hintText:
                          AppLocalizations.of(context).pendulumQuestionHint,
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.gc.lilac),
                      ),
                    ),
                    maxLines: 2,
                    onChanged: (_) {
                      // Mexer na pergunta depois da resposta é começar outra
                      // consulta: o card de resposta sai e o cristal volta ao
                      // repouso. Sem setState por tecla fora desse caso.
                      if (_answer != null && !_isSwinging) {
                        _reiniciarConsulta(limparPergunta: false);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    // Mesmo traje do CTA da Leitura do Ciclo (ver
                    // MagicalButton.ctaDecoration): o gradiente fica no
                    // DecoratedBox porque ElevatedButton não aceita gradiente,
                    // e o botão vai transparente por cima. Enquanto consulta,
                    // esmaece — e o rótulo diz o que está acontecendo.
                    child: Opacity(
                      opacity: _isSwinging ? 0.55 : 1,
                      child: DecoratedBox(
                        decoration: MagicalButton.ctaDecoration(context),
                        child: ElevatedButton.icon(
                          onPressed: _isSwinging ? null : _askPendulum,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: context.gc.onPrimary,
                            disabledBackgroundColor: Colors.transparent,
                            disabledForegroundColor: context.gc.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: _isSwinging
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      context.gc.onPrimary,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.help_outline, size: 18),
                          label: Text(_isSwinging
                              ? AppLocalizations.of(context).pendulumAsking
                              : AppLocalizations.of(context).pendulumAsk),
                        ),
                      ),
                    ),
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
                    // Ponta do cristal a partir da fixação: a corda mais o
                    // corpo visível do cristal (110/130 do viewBox). Os rótulos
                    // ficam logo além dessa ponta, no arco que ela percorre —
                    // por isso o cristal aponta exatamente para a palavra.
                    final pointerR = cordLength + crystalH * 110 / 130;
                    final labelR = pointerR + 18;
                    Offset onArc(double a) => Offset(
                          anchor.dx + sin(a) * labelR,
                          anchor.dy + cos(a) * labelR,
                        );
                    final yesPos = onArc(-_kSwingTarget);
                    final noPos = onArc(_kSwingTarget);
                    final maybePos = onArc(0);
                    // Até onde a inclinação pode levar o cristal NESTA
                    // largura sem a ponta sair do card (InclinacaoDoPendulo).
                    final tetoDaInclinacao = InclinacaoDoPendulo.anguloMaximo(
                      larguraDaArea: w,
                      raioDaPonta: pointerR,
                      larguraDoCristal: crystalBoxW,
                    );
                    return AnimatedBuilder(
                      animation: Listenable.merge([
                        _swingController,
                        _settleController,
                        _revealController,
                        _amortecimento,
                        _inclinacao,
                      ]),
                      builder: (context, _) {
                        // Ângulo do cristal: converge para _targetAngle (aponta
                        // para a resposta) enquanto a oscilação amortecida some —
                        // o ricocheteio de um pêndulo pousando na diagonal. Fora
                        // da consulta, repousa no alvo + a inclinação do aparelho.
                        // Enfeite: o sorteio não vê nada disto.
                        final settleV = _settle.value;
                        // Inclinação: alcance cheio em repouso; consultando
                        // ou respondido, só o sopro do teto absoluto — o lerp
                        // evita o pulo na troca. Enfeite: o sorteio não vê
                        // nada disto.
                        final tetoAgora = lerpDouble(
                          tetoDaInclinacao,
                          InclinacaoDoPendulo.tetoAmortecido,
                          _amortecimento.value,
                        )!;
                        final inclinacao = InclinacaoDoPendulo.angulo(
                          _inclinacao.value,
                          anguloMaximo: tetoAgora,
                        );
                        final swing = _targetAngle * settleV +
                            (_isSwinging
                                ? sin(_swingController.value * 2 * pi) *
                                    0.6 *
                                    (1 - settleV)
                                : 0.0) +
                            inclinacao;
                        // Órbita circular (sem achatamento): a ponta do cristal
                        // segue a linha da corda, então apontar para o alvo é
                        // apontar para o rótulo.
                        final bob = Offset(
                          anchor.dx + sin(swing) * cordLength,
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
                                  tilt: _inclinacao.value.clamp(-1.0, 1.0),
                                  successColor: context.gc.success,
                                  alertColor: context.gc.alert,
                                  starColor: context.gc.starYellow,
                                  yesLabel:
                                      AppLocalizations.of(context).pendulumYes,
                                  noLabel:
                                      AppLocalizations.of(context).pendulumNo,
                                  maybeLabel:
                                      AppLocalizations.of(context).pendulumMaybe,
                                  yesPos: yesPos,
                                  noPos: noPos,
                                  maybePos: maybePos,
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
                                // O cristal é espelhado na vertical (flip), e
                                // espelho inverte o sentido do giro: girar por
                                // -swing faz a PONTA apontar na direção da
                                // corrente (= para a resposta), não o contrário.
                                angle: -swing,
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
                      onPressed: () =>
                          _reiniciarConsulta(limparPergunta: true),
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

  /// Posições dos rótulos, no arco que a ponta do cristal percorre — o "sim" e
  /// o "não" ficam lá embaixo, na diagonal, onde o pêndulo de fato pousa (e não
  /// no meio, onde nunca pararia).
  final Offset yesPos;
  final Offset noPos;
  final Offset maybePos;

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
    required this.yesPos,
    required this.noPos,
    required this.maybePos,
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

    // Rótulos no arco (sempre visíveis); o sorteado acende na revelação.
    _drawAnswerText(canvas, yesLabel, yesPos, successColor,
        isSelected: answer == PendulumAnswer.yes);
    _drawAnswerText(canvas, noLabel, noPos, alertColor,
        isSelected: answer == PendulumAnswer.no);
    _drawAnswerText(canvas, maybeLabel, maybePos, starColor,
        isSelected: answer == PendulumAnswer.maybe);
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
      Canvas canvas, String text, Offset position, Color color,
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
        oldDelegate.yesPos != yesPos ||
        oldDelegate.noPos != noPos ||
        oldDelegate.maybePos != maybePos ||
        oldDelegate.successColor != successColor ||
        oldDelegate.alertColor != alertColor ||
        oldDelegate.starColor != starColor;
  }
}
