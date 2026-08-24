import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Quanto tempo um pouso ainda explica um `pushRoute` que chegou depois. O
/// motor despacha a mensagem no MESMO evento de `popstate`; dois segundos são
/// folga, não precisão.
const Duration _janelaDoRecado = Duration(seconds: 2);

bool _instalado = false;
int _voltaresVistos = 0;
DateTime? _ultimoPousoEmEntradaDoApp;
DateTime? _urlDigitadaEmVoo;

/// Registra o ouvinte de `popstate` do app.
///
/// Chamado na PRIMEIRA linha do `main()`, antes do `ensureInitialized()`: o
/// ouvinte do motor só nasce quando o Navigator raiz monta, então este entra na
/// fila primeiro e lê o estado do pouso antes de qualquer reação dele. Não
/// escreve nada no histórico.
void instalarVigiaDoCorrimao() {
  if (_instalado) return;
  _instalado = true;
  web.window.addEventListener('popstate', _aoPousar.toJS);
}

void _aoPousar(web.Event evento) {
  _voltaresVistos++;
  final estado = web.window.history.state.dartify();

  // Entrada NOSSA (um degrau do corrimão) ou do motor: nos dois casos o estado
  // é um mapa com `flutter: true`. Não distinguimos os dois de propósito — o
  // `setRouteName` do motor reescreve o estado do topo com `{flutter: true}`
  // puro, apagando a marca do degrau, e quem dependesse da marca se perderia
  // exatamente no caso mais comum.
  if (_ehEntradaDoApp(estado)) {
    _ultimoPousoEmEntradaDoApp = DateTime.now();
    // NÃO limpa a marca de URL digitada: quando a pessoa mexe na barra de
    // endereço, o motor faz `go(-1)` e nos traz de volta para uma entrada
    // nossa — este pouso é a segunda metade daquele gesto, não um voltar novo.
    return;
  }

  // Sobrou o estado desconhecido: a pessoa editou a URL. O motor vai responder
  // com `go(-1)` e, logo em seguida, com um `pushRoute` do endereço NOVO — que
  // não pode ser confundido com um voltar.
  _urlDigitadaEmVoo = DateTime.now();
}

/// O `pushRoute` que acabou de chegar do motor é um VOLTAR?
///
/// Consome a resposta: cada `pushRoute` é julgado uma vez só.
bool oUltimoVoltarVeioDoCorrimao() {
  final digitada = _urlDigitadaEmVoo;
  _urlDigitadaEmVoo = null;
  if (digitada != null &&
      DateTime.now().difference(digitada) < _janelaDoRecado) {
    return false;
  }
  final pouso = _ultimoPousoEmEntradaDoApp;
  return pouso != null && DateTime.now().difference(pouso) < _janelaDoRecado;
}

/// Diagnóstico: quantos `popstate` este documento recebeu. Se a aba fechar e
/// este número não tiver subido, o voltar não chegou ao documento — e aí quem
/// fechou foi o navegador.
int voltaresVistosPeloDocumento() => _voltaresVistos;

bool _ehEntradaDoApp(Object? estado) =>
    estado is Map && (estado['flutter'] == true || estado['origin'] == true);
