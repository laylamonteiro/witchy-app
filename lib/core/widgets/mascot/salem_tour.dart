import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../theme/grimoire_colors.dart';
import 'tour_targets.dart';

/// Alvo iluminado de um passo. `slot`/`slots` fatiam um alvo largo em partes
/// iguais (a bottom bar é UM widget com quatro itens).
typedef _TourSpot = ({String id, int? slot, int slots});

/// Um passo do tour: aba a exibir + feature iluminada + fala do Salem.
typedef _TourStep = ({
  int tab,
  _TourSpot? target,
  String Function(AppLocalizations) text,
});

/// Walk-through do app guiado pelo Salem, no formato "coach mark" dos apps
/// profissionais: a tela inteira escurece, um recorte iluminado mostra APENAS
/// a feature explicada e o Salem caminha até ela a cada passo, falando por um
/// balão ancorado no lado oposto (nunca cobre o destaque). Sempre com opção
/// de pular. Exibido no 1º acesso e via "Rever tour" nas Configurações.
///
/// Durante o tour a HomePage esconde o mascote real: quem aparece é este
/// Salem-guia. Ao concluir/pular, o mascote real materializa em fumaça.
class SalemTourOverlay extends StatefulWidget {
  /// Troca a aba da bottom bar para acompanhar o passo atual.
  final ValueChanged<int> onTabChange;

  /// Tour encerrado (concluído ou pulado).
  final VoidCallback onFinished;

  const SalemTourOverlay({
    super.key,
    required this.onTabChange,
    required this.onFinished,
  });

  @override
  State<SalemTourOverlay> createState() => _SalemTourOverlayState();
}

class _SalemTourOverlayState extends State<SalemTourOverlay>
    with TickerProviderStateMixin {
  /// Abas da bottom bar: 0 = Seu Dia, 1 = Enciclopédia, 2 = Grimório,
  /// 3 = Diários.
  static const int _navSlots = 4;

  static const _TourSpot _navYourDay =
      (id: TourTargetIds.bottomBar, slot: 0, slots: _navSlots);
  static const _TourSpot _navEncyclopedia =
      (id: TourTargetIds.bottomBar, slot: 1, slots: _navSlots);
  static const _TourSpot _navGrimoire =
      (id: TourTargetIds.bottomBar, slot: 2, slots: _navSlots);
  static const _TourSpot _navDiaries =
      (id: TourTargetIds.bottomBar, slot: 3, slots: _navSlots);
  static const _TourSpot _encyclopediaTabs =
      (id: TourTargetIds.encyclopediaTabs, slot: null, slots: 1);
  static const _TourSpot _settings =
      (id: TourTargetIds.settings, slot: null, slots: 1);

  static const List<_TourStep> _steps = [
    (tab: 0, target: null, text: _step1), // boas-vindas
    (tab: 0, target: _navYourDay, text: _step2), // Seu Dia
    (tab: 1, target: _navEncyclopedia, text: _step3), // Enciclopédia
    (tab: 1, target: _encyclopediaTabs, text: _step4), // Sabbats/rituais
    (tab: 2, target: _navGrimoire, text: _step5), // Grimório
    (tab: 3, target: _navDiaries, text: _step6), // Diários
    (tab: 0, target: _settings, text: _step7), // Configurações
    (tab: 0, target: null, text: _step8), // segredo/despedida
  ];

  static String _step1(AppLocalizations l10n) => l10n.salemTourStep1;
  static String _step2(AppLocalizations l10n) => l10n.salemTourStep2;
  static String _step3(AppLocalizations l10n) => l10n.salemTourStep3;
  static String _step4(AppLocalizations l10n) => l10n.salemTourStep4;
  static String _step5(AppLocalizations l10n) => l10n.salemTourStep5;
  static String _step6(AppLocalizations l10n) => l10n.salemTourStep6;
  static String _step7(AppLocalizations l10n) => l10n.salemTourStep7;
  static String _step8(AppLocalizations l10n) => l10n.salemTourStep8;

  /// Cantos do recorte, folga em volta da feature e tamanho do Salem-guia.
  static const double _holeRadius = 18;
  static const double _holePadding = 6;
  static const double _salemSize = 76;

  int _current = 0;

  /// Recorte de onde o holofote saiu e para onde vai (null = tela toda
  /// escurecida, sem destaque).
  Rect? _fromRect;
  Rect? _toRect;

  /// Alvos só existem depois do layout (e a troca de aba leva alguns frames):
  /// um pulso curto re-resolve a posição enquanto o tour está em cena.
  Timer? _syncTimer;

  late final AnimationController _moveController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
    value: 1,
  );

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTarget());
    _syncTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _syncTarget(),
    );
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _moveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isLast => _current == _steps.length - 1;

  /// Recalcula o recorte do passo atual; quando ele muda de lugar, o holofote
  /// desliza até a nova feature.
  void _syncTarget() {
    if (!mounted) return;
    final target = _steps[_current].target;
    Rect? rect;
    if (target != null) {
      final base = TourTargets.rectOf(target.id);
      if (base != null) {
        final slot = target.slot;
        final slice = slot == null
            ? base
            : Rect.fromLTWH(
                base.left + base.width / target.slots * slot,
                base.top,
                base.width / target.slots,
                base.height,
              );
        rect = slice.inflate(_holePadding);
      }
    }
    if (rect == _toRect) return;
    setState(() {
      _fromRect = _holeAt(_moveController.value);
      _toRect = rect;
    });
    _moveController.forward(from: 0);
  }

  void _goTo(int index) {
    setState(() => _current = index);
    widget.onTabChange(_steps[index].tab);
    // A aba nova só existe no próximo frame; o pulso de sincronia cobre os
    // casos em que o layout demora mais que isso.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTarget());
  }

  void _next() {
    if (_isLast) {
      widget.onFinished();
      return;
    }
    _goTo(_current + 1);
  }

  void _back() {
    if (_current == 0) return;
    _goTo(_current - 1);
  }

  /// Recorte interpolado: cresce a partir do centro quando aparece e encolhe
  /// para o centro quando some.
  Rect? _holeAt(double raw) {
    final t = Curves.easeInOutCubic.transform(raw.clamp(0.0, 1.0));
    final from = _fromRect;
    final to = _toRect;
    if (from == null && to == null) return null;
    if (from == null) {
      return Rect.lerp(
          Rect.fromCenter(center: to!.center, width: 0, height: 0), to, t);
    }
    if (to == null) {
      return Rect.lerp(
          from, Rect.fromCenter(center: from.center, width: 0, height: 0), t);
    }
    return Rect.lerp(from, to, t);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([_moveController, _pulseController]),
        builder: (context, _) {
          final animated = _holeAt(_moveController.value);
          // Recorte grande o bastante para valer a pena desenhar; nos passos
          // sem alvo (boas-vindas/despedida) a tela fica só escurecida.
          final Rect? hole =
              (animated != null && animated.width > 1 && animated.height > 1)
                  ? animated
                  : null;
          // Feature embaixo → balão em cima (e vice-versa): o destaque nunca
          // fica coberto pela fala.
          final targetLow = hole != null && hole.center.dy > size.height / 2;

          final double salemLeft;
          final double salemTop;
          if (hole == null) {
            salemLeft = (size.width - _salemSize) / 2;
            salemTop = size.height * 0.32;
          } else {
            salemLeft = (hole.center.dx - _salemSize / 2)
                .clamp(16.0, size.width - _salemSize - 16);
            salemTop =
                targetLow ? hole.top - _salemSize - 14 : hole.bottom + 14;
          }
          final bob = (_pulseController.value - 0.5) * 6;

          return Stack(
            children: [
              // Sombreamento com o recorte da feature. Absorve os toques: só
              // o tour responde enquanto ele está em cena.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _next,
                  child: CustomPaint(
                    painter: _SpotlightPainter(
                      hole: hole,
                      radius: _holeRadius,
                      color: Colors.black.withValues(alpha: 0.78),
                    ),
                  ),
                ),
              ),

              // Anel pulsante em volta da feature iluminada.
              if (hole != null)
                Positioned.fromRect(
                  rect: hole.inflate(2 + 3 * _pulseController.value),
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_holeRadius + 4),
                        border: Border.all(color: context.gc.lilac, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: context.gc.lilac.withValues(alpha: 0.5),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // O Salem-guia: caminha até a feature de cada passo.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOutCubic,
                left: salemLeft,
                top: salemTop,
                width: _salemSize,
                height: _salemSize,
                // O bob fica DENTRO do filho: se entrasse no `top`, o
                // AnimatedPositioned reiniciaria a animação a cada frame.
                child: Transform.translate(
                  offset: Offset(0, bob),
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: context.gc.lilac.withValues(alpha: 0.45),
                            blurRadius: 26,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/icons/new_cat/cat_sit_happy.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('🐈‍⬛', style: TextStyle(fontSize: 44)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Balão de fala, ancorado no lado oposto ao destaque.
              AnimatedAlign(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOutCubic,
                alignment:
                    targetLow ? Alignment.topCenter : Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildBubble(context, l10n),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBubble(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.gc.lilac),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              _steps[_current].text(l10n),
              key: ValueKey(_current),
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Progresso em pontinhos, como nos onboardings de app.
              for (var i = 0; i < _steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Container(
                    width: i == _current ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _current
                          ? context.gc.lilac
                          : context.gc.lilac.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: widget.onFinished,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  l10n.salemTourSkip,
                  style:
                      TextStyle(color: context.gc.textSecondary, fontSize: 12),
                ),
              ),
              if (_current > 0)
                IconButton(
                  onPressed: _back,
                  visualDensity: VisualDensity.compact,
                  icon:
                      Icon(Icons.arrow_back, size: 20, color: context.gc.lilac),
                  tooltip: l10n.salemTourBack,
                ),
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.gc.lilac,
                  foregroundColor: context.gc.onPrimary,
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                ),
                child: Text(
                  _isLast ? l10n.salemTourDone : l10n.salemTourNext,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Escurece a tela inteira menos o recorte arredondado da feature em foco.
class _SpotlightPainter extends CustomPainter {
  final Rect? hole;
  final double radius;
  final Color color;

  const _SpotlightPainter({
    required this.hole,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Path()..addRect(Offset.zero & size);
    final currentHole = hole;
    final scrim = currentHole == null
        ? screen
        : Path.combine(
            PathOperation.difference,
            screen,
            Path()
              ..addRRect(
                RRect.fromRectAndRadius(
                    currentHole, Radius.circular(radius)),
              ),
          );
    canvas.drawPath(scrim, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.hole != hole ||
      oldDelegate.color != color ||
      oldDelegate.radius != radius;
}
