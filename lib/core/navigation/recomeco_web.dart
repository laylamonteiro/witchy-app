import 'package:web/web.dart' as web;

/// Troca o documento atual pela raiz do site, SEM deixar o atual no
/// histórico (`location.replace`, não `href=`): é assim que o documento
/// contaminado da volta do OAuth — aquele em que a limpeza do `?code=`
/// atropelou a guarda de histórico do Flutter — é descartado de vez.
void recomecarNaRaiz() {
  web.window.location.replace('/');
}
