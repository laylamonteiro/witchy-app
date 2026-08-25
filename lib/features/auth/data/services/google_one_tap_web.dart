import 'dart:async';
import 'dart:js_interop';
// `getProperty` mora aqui, não em `dart:js_interop`: ler um campo de objeto
// JS por nome é "unsafe" porque o tipo não é verificado em compilação. Aqui
// é o que precisamos — o que se lê é o objeto global do navegador, que pode
// simplesmente não existir.
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import '../../../../core/config/google_signin_config.dart';

/// Pede ao Google, DENTRO da própria página, a credencial de quem já está
/// logado no navegador (Google Identity Services).
///
/// Devolve o ID token, ou `null` quando o Google não deu credencial —
/// origem fora da lista autorizada, script não carregado, cookies de
/// terceiros bloqueados, a janelinha dispensada. Nulo aqui não é erro: quem
/// chama cai no redirecionamento de sempre.
///
/// O prazo é a última linha de defesa, não o caminho normal: quando o
/// Google avisa que não vai mostrar nada, a espera acaba na hora.
///
/// O [nonceHash] vai para o Google e volta DENTRO do token; o Supabase
/// compara com o nonce cru que recebe à parte. É o que impede que um token
/// interceptado seja reaproveitado noutra sessão.
Future<String?> pedirIdTokenDoGoogle({
  required String clientId,
  required String nonceHash,
  required Duration limite,
}) async {
  if (!_origemAutorizada || !_scriptCarregado) return null;

  final resposta = Completer<String?>();

  void aoReceber(_CredentialResponse credencial) {
    final token = credencial.credential;
    if (!resposta.isCompleted) {
      resposta.complete(token.isEmpty ? null : token);
    }
  }

  // O Google avisa, por este ouvinte, quando NÃO vai mostrar nada. Sem
  // escutá-lo, o app ficava os seis segundos inteiros parado num caso que
  // já estava decidido no primeiro — e o botão parecia travado.
  void aoMudarOMomento(_PromptMomentNotification momento) {
    if (resposta.isCompleted) return;
    try {
      if (momento.isDismissedMoment()) {
        // "Dispensada" inclui o desfecho BOM: a credencial saiu e a
        // janelinha fechou. Esse caso chega pelo callback acima — desistir
        // aqui jogaria fora o token que acabou de ser emitido.
        if (!_desistencias.contains(momento.getDismissedReason())) return;
      } else if (!momento.isNotDisplayed() && !momento.isSkippedMoment()) {
        return;
      }
      resposta.complete(null);
    } catch (_) {
      // Navegador que não expõe estes campos: sem sinal, vale o prazo.
    }
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
    _promptComOuvinte(aoMudarOMomento.toJS);
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

/// O Google não aceita curinga na lista de origens autorizadas: uma origem
/// que não esteja lá dá uma tela cheia de "Access blocked: origin_mismatch"
/// no meio do login. Aqui a gente nem tenta — cai no redirecionamento, que
/// funciona em qualquer origem.
///
/// A regra mora em [GoogleSignInConfig.origensAutorizadas], que espelha o
/// painel. Perguntar pela lista, e não pelo formato do endereço, é o
/// conserto: a conferência anterior só reconhecia o endereço de deploy da
/// Cloudflare (`47a8ec37.`) e deixava passar toda prévia com nome de branch.
bool get _origemAutorizada =>
    GoogleSignInConfig.origemAutorizada(web.window.location.hostname);

@JS('google.accounts.id.initialize')
external void _initialize(_IdConfiguration config);

/// O `prompt` aceita um ouvinte de momento. Declaração separada, e não um
/// parâmetro opcional, para não mexer na assinatura que já existia.
@JS('google.accounts.id.prompt')
external void _promptComOuvinte(JSFunction aoMudarOMomento);

/// Os motivos de dispensa que significam "não vai sair credencial daqui".
///
/// `credential_returned` (o desfecho bom) e `flow_restarted` ficam de fora
/// de propósito: nos dois a história continua.
const _desistencias = {'user_cancel', 'tap_outside', 'issuing_failed'};

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

/// O aviso de momento do Google.
///
/// Com FedCM (o padrão no Chrome atual) só `isDismissedMoment` e
/// `getDismissedReason` carregam informação — os outros dois existem e
/// devolvem sempre falso. Eles ficam porque ainda respondem nos navegadores
/// sem FedCM, que são exatamente aqueles em que o caminho novo mais
/// tropeça. Tudo isto é lido dentro de um `try`: um navegador que não
/// exponha algum destes campos volta a valer o prazo, e não quebra o login.
extension type _PromptMomentNotification._(JSObject _) implements JSObject {
  external bool isNotDisplayed();
  external bool isSkippedMoment();
  external bool isDismissedMoment();
  external String getDismissedReason();
}
