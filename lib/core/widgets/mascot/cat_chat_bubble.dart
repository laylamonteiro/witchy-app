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
///
/// Formato de NUVEM: o corpo é um retângulo arredondado (área de texto
/// previsível → quebra automática confiável) e as ondulações da nuvem são
/// decorativas nas bordas. Tamanho é DINÂMICO conforme o conteúdo (mensagens
/// curtas geram um balão estreito; longas quebram em várias linhas até um
/// limite). Sem setinha (deixava de apontar para o gato ao arrastar).
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
  static const double _maxBubbleWidth = 180;
  static const double _minTextWidth = 70;
  static const EdgeInsets _contentPadding = EdgeInsets.fromLTRB(14, 11, 22, 12);

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

  /// Texto com efeito typewriter. O texto completo fica invisível por baixo
  /// para reservar o layout (largura + altura das linhas), então o balão
  /// nasce no tamanho final e não pula durante a digitação.
  Widget _buildTypewriterText() {
    return AnimatedBuilder(
      animation: _typedChars,
      builder: (context, _) {
        final count = _typedChars.value;
        final isTyping = count < _message.length;
        final visibleText = _message.substring(0, count);

        return Stack(
          children: [
            Opacity(
              opacity: 0,
              child: Text(_message, style: _messageStyle),
            ),
            Text.rich(
              TextSpan(
                text: visibleText,
                children: [
                  if (isTyping)
                    TextSpan(
                      text: '▌',
                      style: TextStyle(
                        color: AppColors.lilac.withValues(alpha: 0.9),
                        fontSize: 12,
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

    final screenWidth = MediaQuery.sizeOf(context).width;
    final scaler = MediaQuery.textScalerOf(context);

    // Largura máxima do balão respeitando a tela
    final maxBubble = math.min(_maxBubbleWidth, screenWidth - 24).toDouble();
    final horizontalPad = _contentPadding.horizontal;
    final maxTextWidth = maxBubble - horizontalPad;

    // Mede o texto permitindo quebra em várias linhas até maxTextWidth.
    // A largura resultante (linha mais longa) define um balão dinâmico:
    // curto → estreito; longo → quebra até o limite.
    final tp = TextPainter(
      text: TextSpan(text: _message, style: _messageStyle),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout(maxWidth: maxTextWidth);

    // Em telas muito estreitas o mínimo não pode exceder o máximo
    final minText = math.min(_minTextWidth, maxTextWidth);
    final textWidth = tp.width.clamp(minText, maxTextWidth);
    final bubbleWidth = textWidth + horizontalPad;

    return ValueListenableBuilder<Offset>(
      valueListenable: widget.mascotPosition,
      builder: (context, position, child) {
        final maxLeft = (screenWidth - bubbleWidth - 8).clamp(8.0, screenWidth);
        final left = (position.dx - 8).clamp(8.0, maxLeft).toDouble();
        final top = (position.dy - 92).clamp(8.0, double.infinity).toDouble();
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
                borderRadius: BorderRadius.circular(20),
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
                        top: 3,
                        right: 4,
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

/// Nuvem delicada: corpo arredondado (área de texto previsível) com bolhas
/// decorativas suaves nas bordas superior e inferior. Escala com o tamanho
/// do balão. Fundo branco, contorno lilás fino e sombra suave.
class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Raio das bolhas proporcional à altura, com teto para não exagerar
    final bump = math.min(h * 0.26, 11.0);

    Path circle(double cx, double cy, double r) => Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    // Corpo: retângulo arredondado inset para as bolhas ficarem nas bordas
    var cloud = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(bump * 0.6, bump * 0.7, w - bump * 1.2, h - bump * 1.4),
        Radius.circular(h * 0.38),
      ));

    // Bolhas ao longo do topo e da base, distribuídas pela largura
    final topY = bump * 0.85;
    final botY = h - bump * 0.85;
    final usable = w - bump * 1.4;
    final count = math.max(2, (usable / (bump * 1.7)).floor());
    for (int i = 0; i < count; i++) {
      final t = count == 1 ? 0.5 : i / (count - 1);
      final cx = bump * 0.7 + t * usable;
      // alterna o tamanho para dar naturalidade
      final rTop = bump * (i.isEven ? 1.0 : 0.82);
      final rBot = bump * (i.isEven ? 0.85 : 1.0);
      cloud = Path.combine(PathOperation.union, cloud, circle(cx, topY, rTop));
      cloud = Path.combine(PathOperation.union, cloud, circle(cx, botY, rBot));
    }
    // Bolhas laterais suaves
    cloud = Path.combine(
        PathOperation.union, cloud, circle(bump * 0.6, h * 0.5, bump * 0.8));
    cloud = Path.combine(
        PathOperation.union, cloud, circle(w - bump * 0.6, h * 0.5, bump * 0.8));

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
