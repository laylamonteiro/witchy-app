/// O lado Dart do corrimão do voltar (o script que ergue e repõe os degraus
/// mora em `web/index.html`).
///
/// Aqui não se escreve NADA no histórico. A única função deste vigia é
/// classificar em que tipo de entrada o navegador aterrissou, porque o motor
/// manda a MESMA mensagem — `pushRoute` — em duas situações opostas:
///
///  * um VOLTAR que caiu num degrau nosso (o caso normal, o dia inteiro) —
///    tem de virar um voltar de verdade;
///  * um ENDEREÇO DIGITADO na barra, que o motor responde com `go(-1)` e
///    depois anuncia como `pushRoute` do endereço novo — tem de seguir o
///    caminho normal do framework.
///
/// Sem esta distinção o app trocaria endereço digitado por voltar ou, pior,
/// o `_WidgetsAppState` responderia ao `pushRoute` com `pushNamed` e o VOLTAR
/// EMPILHARIA uma tela.
export 'corrimao_de_voltar_stub.dart'
    if (dart.library.js_interop) 'corrimao_de_voltar_web.dart';
