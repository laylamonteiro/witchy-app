import 'package:web/web.dart' as web;

/// Abre a URL do login numa janela/aba PRÓPRIA. Devolve null quando o
/// navegador bloquear (aí quem chama cai no redirecionamento de sempre —
/// login funcionando vale mais que histórico limpo).
///
/// A alça devolvida NÃO serve para saber se a janela fechou: o COOP das
/// páginas do Google corta o vínculo na primeira navegação e `closed`
/// passa a dizer fechada com a janela aberta (foi exatamente o defeito do
/// "Sign-in cancelled" no preview, 23/08). A aba principal só observa o
/// armazenamento.
Object? abrirJanelaDeLogin(String url) =>
    web.window.open(url, '_blank');

/// Chamado DENTRO do documento que voltou do OAuth: se este documento
/// ainda tem o vínculo com quem o abriu, fecha-se — a sessão já está
/// gravada e a aba principal a recolhe sozinha. Devolve se conseguiu
/// fechar. Sob o COOP do Google o vínculo já foi cortado e o fechar não é
/// permitido: quem chama decide o que mostrar no lugar (a marca de janela
/// diz que este documento é a janela de login).
bool fecharSeJanelaDeLogin() {
  if (web.window.opener == null) return false;
  web.window.close();
  return web.window.closed;
}

/// Lê um valor do `localStorage` CRU da origem.
///
/// Existe porque o supabase_flutter, NA WEB, persiste a sessão direto no
/// localStorage por js-interop — não pelo SharedPreferences, que na web
/// prefixa tudo com `flutter.`. A espera da aba principal lia o namespace
/// errado e nunca via a sessão que a janela gravou (o login travado no
/// preview, 23/08).
String? lerDoLocalStorage(String chave) =>
    web.window.localStorage.getItem(chave);
