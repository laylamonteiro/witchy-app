import 'package:flutter/widgets.dart';

/// Vocabulário de motion do Grimório: durações e curvas padronizadas para
/// microinterações, para que "a mesma ação tenha o mesmo tempo" em qualquer
/// tela. Nada aqui liga animação sozinho — são só constantes e um atalho
/// para a preferência de acessibilidade.
///
/// Faixas (guia, não lei):
/// - toque/press: 100–180 ms
/// - mudança pequena de estado: 200–350 ms
/// - revelação: 350–600 ms
/// - celebração rara: até ~900 ms
abstract class GrimoireMotion {
  GrimoireMotion._();

  /// Resposta imediata ao dedo (press, ripple curto).
  static const Duration tap = Duration(milliseconds: 140);

  /// Mudança pequena de estado (ícone troca, cor assenta, check surge).
  static const Duration state = Duration(milliseconds: 260);

  /// Revelação de conteúdo (carta vira, runa cai, card entra).
  static const Duration reveal = Duration(milliseconds: 450);

  /// Celebração rara (dia selado, conquista). Nunca bloqueia interação.
  static const Duration celebration = Duration(milliseconds: 900);

  /// Transição de rota comum (fade + leve subida).
  static const Duration route = Duration(milliseconds: 220);

  /// Entrada: desacelera chegando — objetos "assentam".
  static const Curve enter = Curves.easeOutCubic;

  /// Saída: acelera partindo.
  static const Curve exit = Curves.easeIn;

  /// Ênfase com um leve respiro além do alvo (selos, conquistas).
  static const Curve emphasis = Curves.easeOutBack;

  /// Se o sistema pediu para reduzir movimento, a UI vai direto ao estado
  /// final. Todo efeito novo deve consultar isto antes de animar.
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}
