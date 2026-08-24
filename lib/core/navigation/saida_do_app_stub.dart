/// Fora da web quem sai do app é o `SystemNavigator.pop()`, que ali funciona
/// como deve (manda para segundo plano) — e é a `SaidaDaAbaReal` que o chama,
/// sem passar por aqui.
///
/// Estas duas peças são da web, onde a resposta é sempre não: ver
/// `saida_do_app_web.dart`.
bool podeSairDaAba() => false;

void sairDaAba() {}
