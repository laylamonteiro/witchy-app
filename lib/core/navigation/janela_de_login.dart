/// A janela própria do login social na web (e os no-ops fora dela).
///
/// O motivo de ela existir: o login por redirecionamento leva a ABA DO APP
/// para dentro das páginas do Google, e elas ficam no histórico — o gesto
/// de voltar, depois, reabria a tela de login do Google (visto em produção
/// e no preview, 23/08, mesmo com as guardas de histórico). Nenhuma guarda
/// remove entradas alheias do histórico; a única solução por construção é
/// o Google nunca ENTRAR nele — o login acontece numa janela própria, e a
/// aba do app fica parada onde está.
///
/// ATENÇÃO ao COOP: as páginas do Google cortam o vínculo entre as janelas
/// (Cross-Origin-Opener-Policy) assim que o pop-up navega para elas. Depois
/// do corte, `closed` na alça da janela MENTE (diz fechada com ela aberta)
/// e a janela perde o direito de se fechar sozinha. Por isso a aba
/// principal NUNCA decide nada pela alça — só observa o armazenamento — e
/// a janela usa a marca abaixo para saber que é a janela de login.
export 'janela_de_login_stub.dart'
    if (dart.library.js_interop) 'janela_de_login_web.dart';

/// A marca (SharedPreferences, compartilhada pela origem na web) de que há
/// uma janela de login em andamento: a aba principal a grava ao abrir a
/// janela e a limpa quando a espera termina; a janela, ao voltar do OAuth,
/// a lê para saber que NÃO deve virar o app — mostra o "pode fechar esta
/// aba" em vez de recomeçar.
const String chaveJanelaDeLoginEmAndamento = 'janela_de_login_em_andamento';

/// Idade máxima da marca: mais velha que isto é sobra de uma tentativa
/// abandonada, não uma janela viva.
const Duration validadeDaMarcaDeJanela = Duration(minutes: 10);
