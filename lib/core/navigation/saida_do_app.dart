/// Sair do app pelo VOLTAR, na web (e o no-op fora dela).
///
/// Por que isto existe em vez de `SystemNavigator.pop()`: na web esse
/// atalho cai no `exit()` do motor do Flutter, e o `exit()` faz duas coisas
/// irreversíveis ANTES de tentar sair (fonte: engine 3.47.0,
/// `web_ui/.../navigation/history.dart`):
///
/// 1. `tearDown()` chama `dispose()`, que DESLIGA o ouvinte de `popstate` —
///    para sempre, porque o motor nunca recria o histórico;
/// 2. `tearDown()` faz `go(-1)`, apagando a entrada-guarda que o motor
///    empurrou no boot; só então o `exit()` faz o segundo `go(-1)`.
///
/// E `history.go(-1)` chamado por script NUNCA fecha uma aba: quando o app
/// é a primeira entrada da aba, o segundo `go(-1)` não faz nada. O
/// resultado é o pior dos mundos — o app continua na tela, mas sem guarda e
/// sem ouvinte: dali em diante QUALQUER gesto de voltar vai direto para o
/// navegador, que não tem para onde ir e FECHA A ABA, de qualquer tela do
/// app. Foi exatamente o relato de 23/08 ("fecha a aba antes de chegar em
/// Seu Dia"): a saída tinha sido acionada uma vez, e o voltar do app estava
/// morto desde então.
///
/// Aqui a saída é honesta: pedimos ao NAVEGADOR para voltar para além do
/// app (a entrada-guarda e a entrada de origem), sem desmontar nada. Se
/// havia uma página antes do app naquela aba, é para lá que se vai — é o
/// "sair do app" possível na web. Se o app é a primeira entrada, não há
/// para onde ir: nenhuma página pode fechar uma aba que ela não abriu, e
/// [podeSairDaAba] responde isso ANTES de armar a saída.
export 'saida_do_app_stub.dart'
    if (dart.library.js_interop) 'saida_do_app_web.dart';
