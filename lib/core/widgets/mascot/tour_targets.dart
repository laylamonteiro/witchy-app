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

/// Registro dos alvos iluminaveis do tour: o [TourTarget] se inscreve ao
/// montar e sai ao desmontar, e o tour resolve a posição real na tela na hora
/// de desenhar o recorte.
class TourTargets {
  const TourTargets._();

  static final Map<String, GlobalKey> _keys = {};

  static void _register(String id, GlobalKey key) => _keys[id] = key;

  /// Só remove se ainda for a MESMA chave: numa reconstrução da árvore o novo
  /// alvo se registra antes de o antigo sair, e quem vale é o novo.
  static void _unregister(String id, GlobalKey key) {
    if (identical(_keys[id], key)) _keys.remove(id);
  }

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
///
/// A GlobalKey nasce e morre com este State — de propósito. Uma chave guardada
/// em estático sobrevive à troca de idioma (que recria a árvore inteira) e o
/// Flutter tenta reaproveitar o elemento antigo na árvore nova, quebrando a
/// tela com "check that it really is our descendant".
class TourTarget extends StatefulWidget {
  final String id;
  final Widget child;

  const TourTarget({super.key, required this.id, required this.child});

  @override
  State<TourTarget> createState() => _TourTargetState();
}

class _TourTargetState extends State<TourTarget> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    TourTargets._register(widget.id, _key);
  }

  @override
  void didUpdateWidget(TourTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      TourTargets._unregister(oldWidget.id, _key);
      TourTargets._register(widget.id, _key);
    }
  }

  @override
  void dispose() {
    TourTargets._unregister(widget.id, _key);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _key, child: widget.child);
}
