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
/// IMPORTANTE: este widget é um IRMÃO do `DraggableCatMascot` no Stack da
/// HomePage e NÃO altera nada no mascote (comportamento do gatinho é
/// congelado). Ele ancora na posição INICIAL do gato (x=20, y=120) — no
/// primeiro open do dia o gato ainda não foi arrastado. Fora da área do
/// balão não há hit-test, então drag/tap do gato seguem intocados.
class CatChatBubble extends StatefulWidget {
  const CatChatBubble({super.key});

  static const String _lastShownKey = 'cat_bubble_last_shown_date';

  @override
  State<CatChatBubble> createState() => _CatChatBubbleState();
}

class _CatChatBubbleState extends State<CatChatBubble>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  bool _dismissed = false;

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _checkAndShow();
  }

  @override
  void dispose() {
    _controller.dispose();
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
    _controller.forward();
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
    await _markShownToday();
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) {
      setState(() => _visible = false);
    }
  }

  Future<void> _openMagicalWeather() async {
    _dismissed = true;
    await _markShownToday();
    if (!mounted) return;
    setState(() => _visible = false);
    // rootNavigator: a página abre em tela cheia, acima dos Navigators
    // aninhados das abas
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const DailyMagicalWeatherPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Positioned(
      // Logo acima da âncora inicial do mascote (x=20, y=120)
      left: 12,
      top: 36,
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.lilac.withOpacity(0.5),
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
                              child: Text(
                                CatBubbleMessages.messageForDate(
                                    DateTime.now()),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
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
                                color: AppColors.textSecondary,
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
    final fill = Paint()..color = AppColors.surface;
    final stroke = Paint()
      ..color = AppColors.lilac.withOpacity(0.5)
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
