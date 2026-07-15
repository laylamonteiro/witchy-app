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
///   (SharedPreferences `cat_bubble_last_shown_date`).
/// - "X" fecha; tocar no corpo abre o Clima Mágico Diário. Ambos gravam a
///   data para não reaparecer no mesmo dia.
///
/// Este widget é um irmão do `DraggableCatMascot` no Stack da HomePage e
/// acompanha a posição publicada pelo mascote.
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

  /// Mensagem do dia (fixada no initState para dimensionar o typewriter).
  late final String _message =
      widget.message ?? CatBubbleMessages.messageForDate(DateTime.now());

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

  /// Chave escopada por CONTA: cada usuário vê o balão 1x por dia.
  /// (Com chave global, logar com outra conta no mesmo dia não mostrava o
  /// balão — bug reportado.)
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
              child: Text(
                _message,
                style: _messageStyle,
                softWrap: true,
              ),
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
              softWrap: true,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = (screenWidth - 16).clamp(0.0, 210.0);
    final textPainter = TextPainter(
      text: TextSpan(text: _message, style: _messageStyle),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final minWidth = availableWidth < 100 ? availableWidth : 100.0;
    final bubbleWidth =
        (textPainter.width + 32).clamp(minWidth, availableWidth);

    return ValueListenableBuilder<Offset>(
      valueListenable: widget.mascotPosition,
      builder: (context, position, child) {
        final maxLeft = screenWidth - bubbleWidth - 8;
        final left = (position.dx - 8).clamp(8.0, maxLeft).toDouble();
        final top = (position.dy - 86).clamp(8.0, double.infinity).toDouble();

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
          child: SizedBox(
            key: const Key('cat-bubble-size'),
            width: bubbleWidth,
            // Balão em formato de NUVEM (delicado, sem setinha — a seta
            // parava de apontar para o gato quando ele era arrastado)
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openMagicalWeather,
                borderRadius: BorderRadius.circular(28),
                child: CustomPaint(
                  painter: _CloudPainter(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
                        child: _buildTypewriterText(),
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: InkWell(
                          onTap: _close,
                          borderRadius: BorderRadius.circular(14),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.black54,
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

/// Nuvem desenhada como a UNIÃO de um corpo arredondado com "bolhas" nas
/// bordas — o contorno resultante é ondulado como o desenho de uma nuvem.
/// Fundo branco, contorno lilás e sombra suave, no visual do app.
class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    Path bump(double cx, double cy, double rx, double ry) => Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx * w, cy * h),
        width: rx * 2 * w,
        height: ry * 2 * h,
      ));

    // Corpo central da nuvem
    var cloud = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.22, w * 0.88, h * 0.62),
        Radius.circular(h * 0.31),
      ));

    // Bolhas do topo, laterais e base (frações da largura/altura)
    const bumps = [
      [0.22, 0.26, 0.13, 0.24], // topo esquerdo
      [0.42, 0.16, 0.14, 0.26], // topo centro-esquerdo (mais alto)
      [0.62, 0.20, 0.13, 0.25], // topo centro-direito
      [0.80, 0.30, 0.11, 0.21], // topo direito
      [0.08, 0.52, 0.09, 0.20], // lateral esquerda
      [0.92, 0.55, 0.09, 0.20], // lateral direita
      [0.28, 0.86, 0.13, 0.15], // base esquerda
      [0.55, 0.90, 0.14, 0.13], // base centro
      [0.78, 0.85, 0.11, 0.14], // base direita
    ];
    for (final b in bumps) {
      cloud = Path.combine(
        PathOperation.union,
        cloud,
        bump(b[0], b[1], b[2], b[3]),
      );
    }

    // Sombra suave lilás (deslocada para baixo)
    canvas.save();
    canvas.translate(0, 4);
    canvas.drawPath(
      cloud,
      Paint()
        ..color = AppColors.lilac.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.restore();

    // Preenchimento branco + contorno lilás delicado
    canvas.drawPath(cloud, Paint()..color = Colors.white);
    canvas.drawPath(
      cloud,
      Paint()
        ..color = AppColors.lilac.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
