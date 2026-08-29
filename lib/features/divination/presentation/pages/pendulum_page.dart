import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/services/reading_archive_composer.dart';
import '../../../diary/presentation/widgets/save_to_records_button.dart';
import 'dart:math';
import '../../../../core/widgets/magical_card.dart';
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
    with TickerProviderStateMixin {
  final _questionController = TextEditingController();

  late AnimationController _swingController;

  /// Envelope de amortecimento: 0 = amplitude cheia, 1 = pêndulo assentado.
  /// Multiplica a oscilação nos últimos ~650 ms para o cristal PERDER força
  /// e pousar, em vez do corte seco para ângulo zero que havia antes.
  late AnimationController _settleController;
  late final Animation<double> _settle;

  /// Revelação da resposta: glow curto no rótulo sorteado e entrada do card
  /// de interpretação (fade + subida de 8 px).
  late AnimationController _revealController;

  PendulumAnswer? _answer;

  /// Última consulta salva — alimenta o botão "Salvar nos Registros".
  PendulumConsultation? _lastConsultation;
  String _question = '';
  bool _isSwinging = false;

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _questionController.dispose();
    _swingController.dispose();
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
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _swingController,
                    _settleController,
                    _revealController,
                  ]),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: PendulumPainter(
                        yesLabel: AppLocalizations.of(context).pendulumYes,
                        noLabel: AppLocalizations.of(context).pendulumNo,
                        maybeLabel: AppLocalizations.of(context).pendulumMaybe,
                        accentColor: context.gc.lilac,
                        successColor: context.gc.success,
                        alertColor: context.gc.alert,
                        starColor: context.gc.starYellow,
                        // O envelope (1 → 0) amortece a oscilação no fim da
                        // consulta: o cristal perde força e pousa no centro.
                        swingAngle: _isSwinging
                            ? sin(_swingController.value * 2 * pi) *
                                0.8 *
                                (1 - _settle.value)
                            : 0,
                        answer: _answer,
                        revealProgress: _revealController.value,
                      ),
                      child: Container(),
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
/// o card chega). Em `value == 1` devolve o filho puro — custo zero depois.
class _RevealEntrance extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _RevealEntrance({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, inner) {
        if (animation.value >= 1) return inner!;
        final t = const Interval(0.25, 1, curve: GrimoireMotion.enter)
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
  final double swingAngle;
  final PendulumAnswer? answer;
  final Color accentColor;
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
    required this.swingAngle,
    required this.accentColor,
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
    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Ponto de fixação
    final anchorX = size.width / 2;
    final anchorY = 20.0;

    // Comprimento da corda
    final cordLength = size.height * 0.6;

    // Posição do pêndulo
    final pendulumX = anchorX + sin(swingAngle) * cordLength * 0.5;
    final pendulumY = anchorY + cos(swingAngle) * cordLength;

    // Desenhar ponto de fixação
    canvas.drawCircle(
      Offset(anchorX, anchorY),
      4,
      fillPaint,
    );

    // Desenhar corda
    canvas.drawLine(
      Offset(anchorX, anchorY),
      Offset(pendulumX, pendulumY),
      paint,
    );

    // Desenhar pêndulo (cristal)
    final pendulumPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final pendulumPath = Path();
    pendulumPath.moveTo(pendulumX, pendulumY - 20);
    pendulumPath.lineTo(pendulumX - 10, pendulumY);
    pendulumPath.lineTo(pendulumX, pendulumY + 30);
    pendulumPath.lineTo(pendulumX + 10, pendulumY);
    pendulumPath.close();

    canvas.drawPath(pendulumPath, pendulumPaint);

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
    return oldDelegate.swingAngle != swingAngle ||
        oldDelegate.answer != answer ||
        oldDelegate.revealProgress != revealProgress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.successColor != successColor ||
        oldDelegate.alertColor != alertColor ||
        oldDelegate.starColor != starColor;
  }
}
