import 'package:flutter/foundation.dart';

/// Notificador usado pela HomePage para pedir que uma seção (Enciclopédia,
/// Grimório ou Diários) volte ao seu estado inicial quando o usuário toca
/// novamente na aba já selecionada da bottom bar.
///
/// Mecanismo genérico: a HomePage possui um notifier por aba e o injeta na
/// página raiz da seção; a página escuta e reseta sua TabBar interna para a
/// primeira aba. Nenhuma lógica específica de tela vive na HomePage.
class SectionResetNotifier extends ChangeNotifier {
  /// Dispara o pedido de reset para os ouvintes da seção.
  void requestReset() => notifyListeners();
}
