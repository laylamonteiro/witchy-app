import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../../features/astrology/presentation/pages/daily_magical_weather_page.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

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
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
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
///   (SharedPreferences `cat_bubble_last_shown_date`, escopado por conta).
/// - "X" fecha; tocar no corpo abre o Clima Mágico Diário. Ambos gravam a
///   data para não reaparecer no mesmo dia.
/// - Formato orgânico com poucos lóbulos amplos e uma pequena cauda
///   apontando para o gato. O tamanho continua dinâmico conforme o conteúdo.
class CatChatBubble extends StatefulWidget {
  final ValueListenable<Offset> mascotPosition;
  final String? message;

  const CatChatBubble({
    super.key,
    required this.mascotPosition,
    this.message,
  });

  static const String _lastShownKey = 'cat_bubble_last_shown_date';

  @override
  State<CatChatBubble> createState() => _CatChatBubbleState();
}

class _CatChatBubbleState extends State<CatChatBubble>
    with TickerProviderStateMixin {
  bool _visible = false;
  bool _dismissed = false;

  // Dimensões compactas
  static const double _maxBubbleWidth = 176;
  static const double _minTextWidth = 88;
  static const EdgeInsets _contentPadding = EdgeInsets.fromLTRB(18, 18, 18, 23);

  static const TextStyle _messageStyle = TextStyle(
    color: Color(0xFF2B2143),
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  /// Mensagem do dia (fixada no initState).
  late final String _message =
      widget.message ?? CatBubbleMessages.messageForDate(DateTime.now());

  /// Pop de entrada: escala elástica (o balão "estoura" na tela).
  late final AnimationController _popController;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  /// Typewriter: revela o texto letra a letra.
  late final AnimationController _typeController;
  late final Animation<int> _typedChars;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      duration: const Duration(milliseconds: 520),
      reverseDuration: const Duration(milliseconds: 190),
      vsync: this,
    );
    _scale = CurvedAnimation(
      parent: _popController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeIn,
    );
    _fade = CurvedAnimation(
      parent: _popController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );

    _typeController = AnimationController(
      duration: Duration(milliseconds: (_message.length * 32).clamp(600, 2600)),
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

  /// Chave escopada por CONTA: cada usuário vê o balão 1x por dia.
  String _prefsKey() {
    final userId = context.read<AuthProvider>().currentUser.id;
    return '${CatChatBubble._lastShownKey}_$userId';
  }

  Future<void> _checkAndShow() async {
    final key = _prefsKey(); // lê o contexto ANTES de qualquer await
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getString(key);
    final today = CatBubbleMessages.dateKey(DateTime.now());

    if (lastShown == today) return; // já apareceu hoje

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || _dismissed) return;

    setState(() => _visible = true);
    await _popController.forward();
    if (!mounted || _dismissed) return;
    await _typeController.forward();
  }

  Future<void> _markShownToday() async {
    final key = _prefsKey();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, CatBubbleMessages.dateKey(DateTime.now()));
  }

  Future<void> _close() async {
    _dismissed = true;
    _typeController.stop();
    await _markShownToday();
    if (!mounted) return;
    await _popController.reverse();
    if (mounted) setState(() => _visible = false);
  }

  Future<void> _openMagicalWeather() async {
    _dismissed = true;
    _typeController.stop();
    await _markShownToday();
    if (!mounted) return;
    setState(() => _visible = false);
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const DailyMagicalWeatherPage()),
    );
  }

  /// Texto com efeito typewriter. A parte ainda não digitada permanece no
  /// mesmo RichText, mas transparente. Assim, prefixo e mensagem completa
  /// compartilham exatamente as mesmas quebras, posição e altura.
  Widget _buildTypewriterText() {
    return AnimatedBuilder(
      animation: _typedChars,
      builder: (context, _) {
        final count = _typedChars.value;
        return Text.rich(
          key: const Key('cat-bubble-typewriter'),
          TextSpan(
            children: [
              TextSpan(text: _message.substring(0, count)),
              TextSpan(
                text: _message.substring(count),
                style: const TextStyle(color: Colors.transparent),
              ),
            ],
          ),
          style: _messageStyle,
          textAlign: TextAlign.center,
          softWrap: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final scaler = MediaQuery.textScalerOf(context);
    final maxBubble = math.min(_maxBubbleWidth, screenWidth - 24).toDouble();
    final horizontalPadding = _contentPadding.horizontal;
    final maxTextWidth = maxBubble - horizontalPadding;
    final textPainter = TextPainter(
      text: TextSpan(text: _message, style: _messageStyle),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout(maxWidth: maxTextWidth);
    final minTextWidth = math.min(_minTextWidth, maxTextWidth);
    final textWidth = textPainter.width.clamp(minTextWidth, maxTextWidth);
    final bubbleWidth = textWidth + horizontalPadding;

    return ValueListenableBuilder<Offset>(
      valueListenable: widget.mascotPosition,
      builder: (context, position, child) {
        final maxLeft = (screenWidth - bubbleWidth - 8).clamp(8.0, screenWidth);
        final left = (position.dx - 8).clamp(8.0, maxLeft).toDouble();
        // A cauda fica visualmente conectada ao gatinho sem cobrir o rosto.
        final top = (position.dy - 70).clamp(8.0, double.infinity).toDouble();
        return Positioned(left: left, top: top, child: child!);
      },
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            key: const Key('cat-bubble-size'),
            width: bubbleWidth,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openMagicalWeather,
                borderRadius: BorderRadius.circular(32),
                child: CustomPaint(
                  painter: _CloudPainter(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: _contentPadding,
                        child: SizedBox(
                          width: double.infinity,
                          child: _buildTypewriterText(),
                        ),
                      ),
                      // Botão fechar: chip lilás sólido (sempre visível,
                      // independente do fundo) sobre o corpo branco da nuvem.
                      Positioned(
                        top: 6,
                        right: 7,
                        child: GestureDetector(
                          onTap: _close,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.lilac,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Balão delicado com poucos lóbulos largos, evitando o aspecto quadrado e a
/// repetição de pequenas bolhas. A cauda inferior acompanha o gato ao arrastar.
class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyBottom = h - 10;

    final cloud = Path()
      ..moveTo(w * 0.31, bodyBottom)
      // base esquerda e lateral
      ..cubicTo(
          w * 0.18, bodyBottom + 1, w * 0.08, h * 0.82, w * 0.08, h * 0.67)
      ..cubicTo(w * 0.01, h * 0.61, w * 0.02, h * 0.43, w * 0.11, h * 0.38)
      ..cubicTo(w * 0.08, h * 0.24, w * 0.21, h * 0.15, w * 0.31, h * 0.19)
      // três lóbulos amplos no topo
      ..cubicTo(w * 0.36, h * 0.04, w * 0.51, h * 0.03, w * 0.57, h * 0.16)
      ..cubicTo(w * 0.67, h * 0.03, w * 0.82, h * 0.08, w * 0.82, h * 0.22)
      ..cubicTo(w * 0.94, h * 0.19, w * 1.01, h * 0.32, w * 0.94, h * 0.43)
      // lateral e base direita
      ..cubicTo(w * 1.01, h * 0.52, w * 0.98, h * 0.68, w * 0.89, h * 0.70)
      ..cubicTo(w * 0.91, h * 0.84, w * 0.77, bodyBottom + 1, w * 0.67,
          bodyBottom - 2)
      ..cubicTo(
          w * 0.58, h * 1.01, w * 0.46, h * 0.96, w * 0.43, bodyBottom - 1)
      // pequena cauda voltada ao centro do gato
      ..lineTo(w * 0.37, h)
      ..quadraticBezierTo(w * 0.31, h * 0.98, w * 0.31, bodyBottom)
      ..close();

    // Sombra suave
    canvas.save();
    canvas.translate(0, 3);
    canvas.drawPath(
      cloud,
      Paint()
        ..color = AppColors.lilac.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.restore();

    // Preenchimento branco + contorno lilás
    canvas.drawPath(cloud, Paint()..color = Colors.white);
    canvas.drawPath(
      cloud,
      Paint()
        ..color = AppColors.lilac.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
