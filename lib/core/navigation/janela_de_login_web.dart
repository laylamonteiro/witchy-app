import 'package:web/web.dart' as web;

/// Abre a URL do login numa janela/aba PRÓPRIA. Devolve null quando o
/// navegador bloquear (aí quem chama cai no redirecionamento de sempre —
/// login funcionando vale mais que histórico limpo).
Object? abrirJanelaDeLogin(String url) =>
    web.window.open(url, '_blank');

/// A janela aberta por [abrirJanelaDeLogin] já foi fechada? (Também é o
/// sinal de desistência: fechou sem sessão = cancelou o login.)
bool janelaDeLoginFechada(Object? janela) =>
    janela is! web.Window || janela.closed;

/// Chamado DENTRO do documento que voltou do OAuth: se este documento é a
/// janela de login (tem quem o abriu), fecha-se — a sessão já está gravada
/// e a aba principal a recolhe sozinha. Devolve se conseguiu fechar; não
/// conseguindo (o navegador cortou o vínculo com quem abriu), quem chama
/// segue com o recomeço de sempre e o app continua utilizável aqui mesmo.
bool fecharSeJanelaDeLogin() {
  if (web.window.opener == null) return false;
  web.window.close();
  return web.window.closed;
}
