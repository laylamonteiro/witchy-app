import 'package:flutter/widgets.dart';

/// Ids dos widgets que o tour do Salem consegue iluminar.
class TourTargetIds {
  const TourTargetIds._();

  /// A bottom bar inteira — o tour ilumina um item por vez (ver `slot`).
  static const String bottomBar = 'bottom_bar';

  /// A TabBar da Enciclopédia (Lua | Sol | Sabbats | ...).
  static const String encyclopediaTabs = 'encyclopedia_tabs';

  /// A engrenagem de Configurações (a do "Seu Dia").
  static const String settings = 'settings';
}

/// Registro dos alvos iluminaveis do tour: cada id guarda UMA GlobalKey, e o
/// tour resolve a posição real na tela na hora de desenhar o recorte.
///
/// Importante: um mesmo id não pode ser marcado em dois lugares vivos ao mesmo
/// tempo (as quatro abas ficam TODAS montadas no IndexedStack) — GlobalKey
/// duplicada quebra a árvore de widgets.
class TourTargets {
  const TourTargets._();

  static final Map<String, GlobalKey> _keys = {};

  static GlobalKey keyFor(String id) =>
      _keys.putIfAbsent(id, () => GlobalKey());

  /// Retângulo do alvo em coordenadas de tela, ou null se ele ainda não foi
  /// montado/medido.
  static Rect? rectOf(String id) {
    final context = _keys[id]?.currentContext;
    if (context == null) return null;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

/// Marca o widget como alvo iluminável do tour do Salem.
class TourTarget extends StatelessWidget {
  final String id;
  final Widget child;

  const TourTarget({super.key, required this.id, required this.child});

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: TourTargets.keyFor(id), child: child);
}
