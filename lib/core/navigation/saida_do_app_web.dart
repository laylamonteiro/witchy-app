import 'package:web/web.dart' as web;

/// Existe alguma página ANTES do app nesta aba?
///
/// O motor mantém exatamente duas entradas suas — a de origem e a guarda
/// (`SingleEntryBrowserHistory`) —, então uma aba que nasceu no app tem
/// comprimento 2. Mais que isso significa que há para onde voltar, e só
/// nesse caso o "voltar de novo para sair" tem o que cumprir.
bool podeSairDaAba() => web.window.history.length > 2;

/// Volta para além do app: as duas entradas do motor de uma vez.
///
/// Um `go(-2)` cru, sem `SystemNavigator.pop()` — o `exit()` do motor
/// desligaria o ouvinte de `popstate` e apagaria a guarda, deixando o
/// voltar morto e a aba à mercê do próximo gesto (ver `saida_do_app.dart`).
/// Fora de alcance, o navegador simplesmente ignora, e o app segue de pé.
void sairDaAba() => web.window.history.go(-2);
