import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../theme/grimoire_colors.dart';

/// Um passo do tour: aba da bottom bar a exibir + texto do Salem.
typedef _TourStep = ({int tab, String Function(AppLocalizations) text});

/// Walk-through do app guiado pelo Salem: um card compacto ancorado no rodapé
/// (sem escurecer a tela — a feature explicada fica totalmente visível; o
/// tour troca de aba para mostrá-la ao vivo). Sempre com opção de pular.
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
  // Abas da bottom bar: 0 = Seu Dia, 1 = Enciclopédia, 2 = Grimório,
  // 3 = Diários.
  static const List<_TourStep> _steps = [
    (tab: 0, text: _step1), // boas-vindas
    (tab: 0, text: _step2), // Seu Dia
    (tab: 1, text: _step3), // Enciclopédia
    (tab: 1, text: _step4), // Sabbats/rituais guiados
    (tab: 2, text: _step5), // Grimório
    (tab: 3, text: _step6), // Diários
    (tab: 0, text: _step7), // Configurações
    (tab: 0, text: _step8), // segredo/despedida
  ];

  static String _step1(AppLocalizations l10n) => l10n.salemTourStep1;
  static String _step2(AppLocalizations l10n) => l10n.salemTourStep2;
  static String _step3(AppLocalizations l10n) => l10n.salemTourStep3;
  static String _step4(AppLocalizations l10n) => l10n.salemTourStep4;
  static String _step5(AppLocalizations l10n) => l10n.salemTourStep5;
  static String _step6(AppLocalizations l10n) => l10n.salemTourStep6;
  static String _step7(AppLocalizations l10n) => l10n.salemTourStep7;
  static String _step8(AppLocalizations l10n) => l10n.salemTourStep8;

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

  void _back() {
    if (_current == 0) return;
    setState(() => _current--);
    widget.onTabChange(_steps[_current].tab);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final step = _steps[_current];

    // Card compacto no rodapé: a tela continua visível e interativa acima —
    // o Salem aponta a feature trocando de aba, sem sombrear nada.
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            decoration: BoxDecoration(
              color: context.gc.surface.withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.gc.lilac),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/new_cat/cat_sit_happy.png',
                      width: 52,
                      height: 52,
                      errorBuilder: (_, __, ___) =>
                          const Text('🐈‍⬛', style: TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          step.text(l10n),
                          key: ValueKey(_current),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.35),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${_current + 1}/${_steps.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: widget.onFinished,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        l10n.salemTourSkip,
                        style: TextStyle(
                          color: context.gc.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_current > 0)
                      IconButton(
                        onPressed: _back,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.arrow_back,
                            size: 20, color: context.gc.lilac),
                        tooltip: l10n.salemTourBack,
                      ),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.gc.lilac,
                        foregroundColor: context.gc.onPrimary,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
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
          ),
        ),
      ),
    );
  }
}
