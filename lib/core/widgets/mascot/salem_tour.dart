import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../theme/grimoire_colors.dart';

/// Um passo do tour: aba da bottom bar a exibir + texto do Salem.
typedef _TourStep = ({int tab, String Function(AppLocalizations) text});

/// Walk-through do app guiado pelo Salem: overlay com scrim, o gatinho e um
/// balão de fala, passo a passo pelas 3 seções. Sempre com opção de pular.
/// Exibido no 1º acesso e via "Rever tour com o Salem" nas Configurações.
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

class _SalemTourOverlayState extends State<SalemTourOverlay> {
  static const List<_TourStep> _steps = [
    (tab: 0, text: _step1),
    (tab: 0, text: _step2),
    (tab: 0, text: _step3),
    (tab: 1, text: _step4),
    (tab: 2, text: _step5),
    (tab: 0, text: _step6),
    (tab: 0, text: _step7),
  ];

  static String _step1(AppLocalizations l10n) => l10n.salemTourStep1;
  static String _step2(AppLocalizations l10n) => l10n.salemTourStep2;
  static String _step3(AppLocalizations l10n) => l10n.salemTourStep3;
  static String _step4(AppLocalizations l10n) => l10n.salemTourStep4;
  static String _step5(AppLocalizations l10n) => l10n.salemTourStep5;
  static String _step6(AppLocalizations l10n) => l10n.salemTourStep6;
  static String _step7(AppLocalizations l10n) => l10n.salemTourStep7;

  int _current = 0;

  bool get _isLast => _current == _steps.length - 1;

  void _next() {
    if (_isLast) {
      widget.onFinished();
      return;
    }
    setState(() => _current++);
    widget.onTabChange(_steps[_current].tab);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final step = _steps[_current];

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.72),
        child: SafeArea(
          child: Column(
            children: [
              // Progresso + pular no topo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${_current + 1}/${_steps.length}',
                      style: TextStyle(
                        color: context.gc.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.onFinished,
                      child: Text(
                        l10n.salemTourSkip,
                        style: TextStyle(color: context.gc.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Salem + balão
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.gc.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.gc.lilac),
                        boxShadow: [
                          BoxShadow(
                            color: context.gc.lilac.withValues(alpha: 0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          step.text(l10n),
                          key: ValueKey(_current),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Image.asset(
                      'assets/icons/new_cat/cat_sit_happy.png',
                      width: 110,
                      height: 110,
                      errorBuilder: (_, __, ___) =>
                          const Text('🐈‍⬛', style: TextStyle(fontSize: 72)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (_current > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _current--);
                                widget.onTabChange(_steps[_current].tab);
                              },
                              child: Text(l10n.salemTourBack),
                            ),
                          ),
                        if (_current > 0) const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.gc.lilac,
                              foregroundColor: context.gc.onPrimary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _isLast ? l10n.salemTourDone : l10n.salemTourNext,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
