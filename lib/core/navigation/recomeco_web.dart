import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Troca o documento atual pela raiz do site, SEM deixar o atual no
/// histórico (`location.replace`, não `href=`): é assim que o documento
/// contaminado da volta do OAuth — aquele em que a limpeza do `?code=`
/// atropelou a guarda de histórico do Flutter — é descartado de vez.
void recomecarNaRaiz() {
  // Libera a guarda de saída ANTES de trocar de documento: esta saída é
  // decisão do app, e o `beforeunload` de `web/index.html` existe para
  // perguntar sobre as saídas que a pessoa não pediu. Sem isto, terminar o
  // login social devolveria um "Sair do site?" — susto no pior momento.
  globalContext['__gdbSaidaAutorizada'] = true.toJS;
  web.window.location.replace('/');
}
