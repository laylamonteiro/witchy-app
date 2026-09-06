import 'package:flutter/widgets.dart';

/// Re-toque na aba já selecionada da bottom bar: a seção volta à raiz.
///
/// O `goBranch(index, initialLocation: true)` do go_router só refaz a pilha
/// de PÁGINAS do branch. As telas que o app empilha com `Navigator.push`
/// (Pêndulo, Runas, detalhes da Enciclopédia…) são rotas sem página,
/// penduradas na página raiz — o go_router não as enxerga, e elas ficavam por
/// cima: tocar em "Ferramentas" dentro do Pêndulo não fazia nada. Desempilhar
/// pelo Navigator da própria aba é o que o deep link já fazia; aqui vira o
/// comportamento padrão de TODA página empilhada, em qualquer aba.
///
/// Ordem: primeiro a pilha do Navigator (o que a pessoa vê), depois o branch e
/// o reset da seção (TabBar interna de volta à primeira aba).
void retocarAbaAtiva({
  required NavigatorState? navegadorDaAba,
  required VoidCallback irParaARaizDoBranch,
  required VoidCallback resetarSecao,
}) {
  navegadorDaAba?.popUntil((route) => route.isFirst);
  irParaARaizDoBranch();
  resetarSecao();
}
