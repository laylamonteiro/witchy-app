import 'package:web/web.dart' as web;

/// Existe alguma página ANTES do app nesta aba?
///
/// O motor mantém exatamente duas entradas suas — a de origem e a guarda
/// (`SingleEntryBrowserHistory`) —, então uma aba que nasceu no app tem
/// comprimento 2. Mais que isso significa que há para onde voltar, e só
/// nesse caso o "voltar de novo para sair" tem o que cumprir.
bool podeSairDaAba() => _entradasDaAba() > _entradasDoMotor;

/// As duas entradas que o motor mantém (origem + guarda).
const int _entradasDoMotor = 2;

int _entradasDaAba() => web.window.history.length;

/// Volta para além do app: as duas entradas do motor de uma vez.
///
/// Um `go(-2)` cru, sem `SystemNavigator.pop()` — o `exit()` do motor
/// desligaria o ouvinte de `popstate` e apagaria a guarda, deixando o
/// voltar morto e a aba à mercê do próximo gesto (ver `saida_do_app.dart`).
/// Fora de alcance, o navegador simplesmente ignora, e o app segue de pé.
void sairDaAba() {
  // Conferido de novo aqui, e não só por quem chama: um `go` fora de
  // alcance é ignorado em silêncio, e a pessoa ficaria com o aviso
  // consumido e nada acontecendo na tela.
  if (!podeSairDaAba()) return;
  web.window.history.go(-_entradasDoMotor);
}
