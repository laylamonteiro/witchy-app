/// A janela própria do login social na web (e os no-ops fora dela).
///
/// O motivo de ela existir: o login por redirecionamento leva a ABA DO APP
/// para dentro das páginas do Google, e elas ficam no histórico — o gesto
/// de voltar, depois, reabria a tela de login do Google (visto em produção
/// e no preview, 23/08, mesmo com as guardas de histórico). Nenhuma guarda
/// remove entradas alheias do histórico; a única solução por construção é
/// o Google nunca ENTRAR nele — o login acontece numa janela própria, e a
/// aba do app fica parada onde está.
export 'janela_de_login_stub.dart'
    if (dart.library.js_interop) 'janela_de_login_web.dart';
