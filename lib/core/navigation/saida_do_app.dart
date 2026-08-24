/// Sair do app pelo VOLTAR: no celular sim, na WEB nunca.
///
/// Na web só existem dois jeitos de entregar a aba ao navegador, e os dois são
/// armadilhas:
///
/// 1. `SystemNavigator.pop()` — cai no `exit()` do motor, que ANTES de tentar
///    sair faz `tearDown()`: desliga o ouvinte de `popstate` (para sempre, o
///    motor nunca recria o histórico) e apaga a entrada-guarda. Dali em diante
///    o app segue na tela, mas cego, e o voltar seguinte fecha a aba a partir
///    de qualquer tela. E o framework chama esse atalho SOZINHO quando nenhum
///    observador do binding trata o `popRoute` (binding.dart:1116-1132) — é
///    por isso que existe o `PorteiroDoVoltar`, instalado antes do `runApp`.
///
/// 2. `history.go(-2)` — o que este arquivo fazia. Dependia de `history.length`
///    para adivinhar se havia página antes do app, e esse número não responde
///    a pergunta: o motor só usa `replaceState` depois do boot, então o
///    histórico do app nunca cresce e `length` fala do que veio ANTES dele.
///    Quando a adivinhação dava certo, o app ia embora no segundo voltar — o
///    relato de 23/08. Ver `saida_do_app_web.dart`.
///
/// Fora da web nada disso vale: lá o `SystemNavigator.pop()` manda o app para
/// segundo plano, que é reversível e esperado. Por isso a decisão mora aqui, na
/// fronteira: [podeSairDaAba] devolve `false` na web, e o passo 4 da
/// `CaminhadaDoVoltar` termina em "você já está no Seu Dia".
export 'saida_do_app_stub.dart'
    if (dart.library.js_interop) 'saida_do_app_web.dart';
