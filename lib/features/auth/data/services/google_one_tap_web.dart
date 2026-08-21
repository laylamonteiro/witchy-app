import 'dart:async';
import 'dart:js_util' as js;

/// Pede ao Google, DENTRO da própria página, a credencial de quem já está
/// logado no navegador (Google Identity Services).
///
/// Devolve o ID token, ou `null` quando o Google não mostrou nada — cookies
/// de terceiros bloqueados, a pessoa dispensou a janelinha antes, ou o
/// script nem carregou. Nulo aqui não é erro: quem chama cai no
/// redirecionamento de sempre.
///
/// O [nonceHash] vai para o Google e volta DENTRO do token; o Supabase
/// compara com o nonce cru que recebe à parte. É o que impede que um token
/// interceptado seja reaproveitado noutra sessão.
///
/// A ponte é `dart:js_util` e não `dart:js_interop` de propósito: o segundo
/// exige `extension type`, que pede linguagem 3.3, e a trava de SDK deste
/// projeto ainda é 3.0. Trocar a trava por causa de um login seria mexer no
/// piso de todo mundo — quando ela subir, este arquivo é o primeiro a
/// migrar.
Future<String?> pedirIdTokenDoGoogle({
  required String clientId,
  required String nonceHash,
  required Duration limite,
}) async {
  final api = _apiDoGoogle();
  if (api == null) return null;

  final resposta = Completer<String?>();

  void aoReceber(Object credencial) {
    final token = js.getProperty(credencial, 'credential');
    if (!resposta.isCompleted) {
      resposta.complete(token is String && token.isNotEmpty ? token : null);
    }
  }

  try {
    js.callMethod(api, 'initialize', [
      js.jsify({
        // Nomes em snake_case porque são os campos da API do Google.
        'client_id': clientId,
        'callback': js.allowInterop(aoReceber),
        'nonce': nonceHash,
        // Nunca entrar sozinha: a pessoa tocou num botão, e é a escolha dela
        // de conta que decide — não a última sessão do navegador.
        'auto_select': false,
        'cancel_on_tap_outside': true,
      })
    ]);
    js.callMethod(api, 'prompt', const []);
  } catch (_) {
    return null;
  }

  final token = await resposta.future.timeout(limite, onTimeout: () => null);
  if (token == null) {
    // Sem credencial: fecha a janelinha antes de devolver o controle, senão
    // ela ficaria aberta por cima do redirecionamento que vem a seguir.
    try {
      js.callMethod(api, 'cancel', const []);
    } catch (_) {
      // Já fechada ou nunca aberta.
    }
  }
  return token;
}

/// `google.accounts.id`, ou nulo se o script ainda não chegou.
///
/// Ele carrega com `async`: numa rede ruim pode não estar pronto quando a
/// pessoa toca no botão, e chamar o que não existe levantaria erro de JS.
Object? _apiDoGoogle() {
  try {
    final google = js.getProperty<Object?>(js.globalThis, 'google');
    if (google == null) return null;
    final accounts = js.getProperty<Object?>(google, 'accounts');
    if (accounts == null) return null;
    return js.getProperty<Object?>(accounts, 'id');
  } catch (_) {
    return null;
  }
}
