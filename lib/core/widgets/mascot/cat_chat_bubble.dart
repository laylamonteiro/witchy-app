import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../../features/astrology/presentation/pages/daily_magical_weather_page.dart';

/// Mensagens do balão diário do mascote (lógica pura, testável).
class CatBubbleMessages {
  CatBubbleMessages._();

  static const List<String> messages = [
    'Que tal olhar o clima mágico do seu dia?',
    'Seu clima mágico já foi revelado hoje?',
    'Os astros prepararam algo interessante para você.',
    'Descubra a energia mágica deste dia.',
  ];

  /// Mensagem determinística do dia: rotaciona pelo dia do ano.
  static String messageForDate(DateTime date) {
    final dayOfYear =
        date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return messages[dayOfYear % messages.length];
  }

  /// Chave de data no formato yyyy-MM-dd (para o controle "1x por dia").
  static String dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

/// Balão de conversa diário exibido ACIMA do gatinho mascote.
///
/// - Aparece apenas no primeiro open do app em cada dia
///   (SharedPreferences `cat_bubble_last_shown_date`).
/// - "X" fecha; tocar no corpo abre o Clima Mágico Diário. Ambos gravam a
///   data para não reaparecer no mesmo dia.
///
/// Este widget é um irmão do `DraggableCatMascot` no Stack da HomePage e
/// acompanha a posição publicada pelo mascote.
class CatChatBubble extends StatefulWidget {
  final ValueListenable<Offset> mascotPosition;

  const CatChatBubble({
    super.key,
    required this.mascotPosition,
  });

  static const String _lastShownKey = 'cat_bubble_last_shown_date';

  @override
  State<CatChatBubble> createState() => _CatChatBubbleState();
}

class _CatChatBubbleState extends State<CatChatBubble>
    with TickerProviderStateMixin {
  bool _visible = false;
  bool _dismissed = false;

  /// Mensagem do dia (fixada no initState para dimensionar o typewriter).
  late final String _message = CatBubbleMessages.messageForDate(DateTime.now());

  /// Pop de entrada: escala elástica (o balão "estoura" na tela, como uma
  /// fala surgindo) + fade rápido no início.
  late final AnimationController _popController;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  /// Typewriter: revela o texto letra a letra, como se o gatinho estivesse
  /// falando naquele momento.
  late final AnimationController _typeController;
  late final Animation<int> _typedChars;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      duration: const Duration(milliseconds: 550),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scale = CurvedAnimation(
      parent: _popController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeIn,
    );
    _fade = CurvedAnimation(
      parent: _popController,
      // Opacidade completa logo no início do pop, para o overshoot elástico
      // acontecer com o balão já visível
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );

    _typeController = AnimationController(
      // ~35ms por letra, com piso para mensagens curtas
      duration: Duration(milliseconds: (_message.length * 35).clamp(600, 3000)),
      vsync: this,
    );
    _typedChars = StepTween(begin: 0, end: _message.length).animate(
      CurvedAnimation(parent: _typeController, curve: Curves.linear),
    );

    _checkAndShow();
  }

  @override
  void dispose() {
    _popController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShow() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getString(CatChatBubble._lastShownKey);
    final today = CatBubbleMessages.dateKey(DateTime.now());

    if (lastShown == today) return; // já apareceu hoje

    // Pequena espera para a home assentar antes do balão surgir
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || _dismissed) return;

    setState(() => _visible = true);
    // Pop primeiro; o gatinho "começa a falar" (typewriter) assim que o
    // balão termina de estourar na tela
    await _popController.forward();
    if (!mounted || _dismissed) return;
    await _typeController.forward();
  }

  Future<void> _markShownToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      CatChatBubble._lastShownKey,
      CatBubbleMessages.dateKey(DateTime.now()),
    );
  }

  Future<void> _close() async {
    _dismissed = true;
    _typeController.stop();
    await _markShownToday();
    if (!mounted) return;
    await _popController.reverse();
    if (mounted) {
      setState(() => _visible = false);
    }
  }

  Future<void> _openMagicalWeather() async {
    _dismissed = true;
    _typeController.stop();
    await _markShownToday();
    if (!mounted) return;
    setState(() => _visible = false);
    // rootNavigator: a página abre em tela cheia, acima dos Navigators
    // aninhados das abas
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const DailyMagicalWeatherPage()),
    );
  }

  static const TextStyle _messageStyle = TextStyle(
    color: Color(0xFF211A2E),
    fontSize: 13,
    height: 1.35,
  );

  /// Texto com efeito typewriter (letras aparecendo uma a uma) e um cursor
  /// "▌" enquanto o gatinho ainda está "falando".
  ///
  /// O texto completo fica invisível por baixo para reservar o espaço final —
  /// o balão nasce já no tamanho certo e não fica pulando durante a digitação.
  Widget _buildTypewriterText() {
    return AnimatedBuilder(
      animation: _typedChars,
      builder: (context, _) {
        final count = _typedChars.value;
        final isTyping = count < _message.length;
        final visibleText = _message.substring(0, count);

        return Stack(
          children: [
            // Reserva o layout com o texto completo (invisível)
            Opacity(
              opacity: 0,
              child: Text(_message, style: _messageStyle),
            ),
            // Texto revelado progressivamente + cursor de "fala"
            Text.rich(
              TextSpan(
                text: visibleText,
                children: [
                  if (isTyping)
                    TextSpan(
                      text: '▌',
                      style: TextStyle(
                        color: AppColors.lilac.withValues(alpha: 0.9),
                      ),
                    ),
                ],
              ),
              style: _messageStyle,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return ValueListenableBuilder<Offset>(
      valueListenable: widget.mascotPosition,
      builder: (context, position, child) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final maxLeft = screenWidth > 266 ? screenWidth - 258 : 8.0;
        final left = (position.dx - 8).clamp(8.0, maxLeft).toDouble();
        final top =
            (position.dy - 86).clamp(8.0, double.infinity).toDouble();

        return Positioned(
          left: left,
          top: top,
          child: child!,
        );
      },
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          alignment: Alignment.bottomLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openMagicalWeather,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.lilac.withValues(alpha: 0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lilac.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: _buildTypewriterText(),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Botão fechar (X)
                          InkWell(
                            onTap: _close,
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Rabinho do balão apontando para o gatinho (abaixo)
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: CustomPaint(
                    size: const Size(16, 9),
                    painter: _BubbleTailPainter(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Triângulo do rabinho do balão, na mesma cor/borda do container.
class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = AppColors.lilac.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, fill);
    // Só as laterais do triângulo (o topo encosta no balão)
    canvas.drawLine(Offset.zero,
        Offset(size.width / 2, size.height), stroke);
    canvas.drawLine(Offset(size.width, 0),
        Offset(size.width / 2, size.height), stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
