import 'dart:async';
import 'dart:js_interop';

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
Future<String?> pedirIdTokenDoGoogle({
  required String clientId,
  required String nonceHash,
  required Duration limite,
}) async {
  if (!_scriptCarregado) return null;

  final resposta = Completer<String?>();

  void aoReceber(_CredentialResponse credencial) {
    if (!resposta.isCompleted) resposta.complete(credencial.credential);
  }

  try {
    _initialize(
      _IdConfiguration(
        client_id: clientId,
        callback: aoReceber.toJS,
        nonce: nonceHash,
        // Nunca entrar sozinha: a pessoa tocou num botão, e é a escolha dela
        // de conta que decide — não a última sessão do navegador.
        auto_select: false,
        cancel_on_tap_outside: true,
      ),
    );
    _prompt();
  } catch (_) {
    return null;
  }

  final token = await resposta.future.timeout(limite, onTimeout: () => null);
  if (token == null) {
    // Sem credencial: fecha a janelinha antes de devolver o controle, senão
    // ela ficaria aberta por cima do redirecionamento que vem a seguir.
    try {
      _cancel();
    } catch (_) {
      // Já fechada ou nunca aberta.
    }
  }
  return token;
}

/// O script do Google carrega com `async`: numa rede ruim ele pode não estar
/// pronto quando a pessoa toca no botão. Sem esta conferência, chamar
/// `google.accounts.id` levantaria um erro de JS.
bool get _scriptCarregado {
  final google = globalContext.getProperty<JSObject?>('google'.toJS);
  final accounts = google?.getProperty<JSObject?>('accounts'.toJS);
  return accounts?.getProperty<JSObject?>('id'.toJS) != null;
}

@JS('google.accounts.id.initialize')
external void _initialize(_IdConfiguration config);

@JS('google.accounts.id.prompt')
external void _prompt();

@JS('google.accounts.id.cancel')
external void _cancel();

extension type _IdConfiguration._(JSObject _) implements JSObject {
  external factory _IdConfiguration({
    // Nomes em snake_case porque são os campos da API do Google, não nossos.
    required String client_id,
    required JSFunction callback,
    String? nonce,
    bool auto_select,
    bool cancel_on_tap_outside,
  });
}

extension type _CredentialResponse._(JSObject _) implements JSObject {
  external String get credential;
}
