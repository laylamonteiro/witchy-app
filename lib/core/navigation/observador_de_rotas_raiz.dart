import 'package:flutter/material.dart';

/// Quantas vezes a pilha do Navigator RAIZ mudou — uma tela cheia abriu ou
/// fechou (Configurações, Assinatura, um diálogo de rota).
///
/// Existe porque a Home NÃO enxerga essas mudanças pelo próprio tratador de
/// voltar: `maybePop` consulta só a rota do topo, então o framework
/// desempilha uma tela cheia da raiz sem nunca passar pelo `PopScope` da
/// Home. Sem este aviso, um "toque de novo para sair" dado no Seu Dia
/// continuava armado enquanto a pessoa abria e fechava Configurações — e o
/// voltar seguinte saía do app sem aviso nenhum na tela.
final ValueNotifier<int> mudancasDaPilhaRaiz = ValueNotifier<int>(0);

/// O observador que alimenta [mudancasDaPilhaRaiz]. Um só, no MaterialApp.
class ObservadorDeRotasRaiz extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _avisar();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _avisar();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _avisar();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _avisar();

  void _avisar() => mudancasDaPilhaRaiz.value++;
}
