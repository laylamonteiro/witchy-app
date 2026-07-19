import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../auth/auth.dart';
import '../../data/models/pendulum_model.dart';

class PendulumPage extends StatefulWidget {
  const PendulumPage({super.key});

  @override
  State<PendulumPage> createState() => _PendulumPageState();
}

class _PendulumPageState extends State<PendulumPage>
    with SingleTickerProviderStateMixin {
  final _questionController = TextEditingController();

  late AnimationController _swingController;
  PendulumAnswer? _answer;
  String _question = '';
  bool _isSwinging = false;

  @override
  void initState() {
    super.initState();
    _swingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _swingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _showAnswer();
      }
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _swingController.dispose();
    super.dispose();
  }

  Future<void> _askPendulum() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Verificar limite diário (para TODOS os usuários)
    if (!authProvider.canUsePendulum) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você já usou suas 3 consultas de hoje. Volte amanhã!'),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    if (_question.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Faça uma pergunta primeiro'),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    // ✅ Incrementar contador ANTES da animação (reserva a consulta imediatamente)
    await authProvider.incrementPendulumUses();

    setState(() {
      _isSwinging = true;
      _answer = null;
    });

    _swingController.repeat(reverse: true);

    // Esperar 3 segundos
    await Future.delayed(const Duration(seconds: 3));

    _swingController.stop();
    _showAnswer(); // Chamar diretamente após parar
  }

  void _showAnswer() {
    // Gerar resposta aleatória
    final answers = PendulumAnswer.values;
    final random = Random();

    setState(() {
      _answer = answers[random.nextInt(answers.length)];
      _isSwinging = false;
    });

    // Salvar histórico
    _saveConsultation();
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

    // Contador já foi incrementado em _askPendulum() antes da animação
    // para prevenir múltiplas consultas simultâneas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Pêndulo'),
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
                    'Consultar o Pêndulo',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: context.gc.lilac,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Faça perguntas de sim ou não. Concentre-se e confie na resposta.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.softWhite.withOpacity(0.8),
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
                              ? context.gc.success.withOpacity(0.2)
                              : context.gc.alert.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: hasRemaining
                                ? context.gc.success.withOpacity(0.5)
                                : context.gc.alert.withOpacity(0.5),
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
                                  ? 'Consultas ilimitadas (Admin)'
                                  : (hasRemaining
                                      ? '$remaining de $total consultas disponíveis hoje'
                                      : 'Consultas usadas ($used/$total) - volte amanhã'),
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
                  animation: _swingController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: PendulumPainter(
                        accentColor: context.gc.lilac,
                        successColor: context.gc.success,
                        alertColor: context.gc.alert,
                        starColor: context.gc.starYellow,
                        swingAngle: _isSwinging
                            ? sin(_swingController.value * 2 * pi) * 0.8
                            : 0,
                        answer: _answer,
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
                      : context.gc.softWhite.withOpacity(0.5),
                ),
                decoration: InputDecoration(
                  labelText: 'Sua Pergunta',
                  labelStyle: TextStyle(color: context.gc.lilac),
                  hintText: 'Ex: Devo aceitar aquele emprego?',
                  hintStyle: TextStyle(
                    color: context.gc.softWhite.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(Icons.help, color: context.gc.lilac),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.gc.lilac),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.gc.lilac.withOpacity(0.3),
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.gc.lilac.withOpacity(0.1),
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
                label: Text(_isSwinging ? 'Consultando...' : 'Perguntar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.gc.lilac,
                  foregroundColor: context.gc.darkBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  disabledBackgroundColor: context.gc.lilac.withOpacity(0.3),
                ),
              ),

            if (_answer != null) ...[
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
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _answer = null;
                    _question = '';
                    _questionController.clear();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Nova Consulta'),
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
}

class PendulumPainter extends CustomPainter {
  final double swingAngle;
  final PendulumAnswer? answer;
  final Color accentColor;
  final Color successColor;
  final Color alertColor;
  final Color starColor;

  PendulumPainter({
    required this.swingAngle,
    required this.accentColor,
    required this.successColor,
    required this.alertColor,
    required this.starColor,
    this.answer,
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
      'SIM',
      Offset(size.width * 0.2, size.height * 0.5),
      successColor,
      isSelected: answer == PendulumAnswer.yes,
    );
    _drawAnswerText(
      canvas,
      size,
      'NÃO',
      Offset(size.width * 0.8, size.height * 0.5),
      alertColor,
      isSelected: answer == PendulumAnswer.no,
    );
    _drawAnswerText(
      canvas,
      size,
      'TALVEZ',
      Offset(size.width * 0.5, size.height * 0.8),
      starColor,
      isSelected: answer == PendulumAnswer.maybe,
    );
  }

  void _drawAnswerText(
      Canvas canvas, Size size, String text, Offset position, Color color,
      {bool isSelected = false}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isSelected ? color : color.withOpacity(0.4),
          fontSize: isSelected ? 16 : 12,
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
        oldDelegate.accentColor != accentColor ||
        oldDelegate.successColor != successColor ||
        oldDelegate.alertColor != alertColor ||
        oldDelegate.starColor != starColor;
  }
}
