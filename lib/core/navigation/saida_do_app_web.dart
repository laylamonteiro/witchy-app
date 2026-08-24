/// NA WEB O VOLTAR NÃO SAI DO APP. Ponto.
///
/// Havia aqui um `history.go(-2)` autorizado por `history.length > 3`. A
/// pergunta que essa conta tentava responder — "existe uma página real antes do
/// app nesta aba?" — é INDECIDÍVEL de dentro da página, e a conta respondia
/// outra coisa:
///
///  * `SingleEntryBrowserHistory.setRouteName` sempre chama
///    `_setupFlutterEntry(replace: true)`, ou seja, `replaceState` (engine
///    3.47.0, `web_ui/.../navigation/history.dart`). O histórico do app NUNCA
///    cresce: as duas entradas do motor são as mesmas do primeiro quadro até o
///    último. Logo `length` mede exclusivamente o que já existia na aba ANTES
///    do app;
///  * e mede isso mal: numa aba nova o Chrome ainda conta a página inicial, e
///    um retorno de login social soma entradas próprias.
///
/// O resultado era uma moeda ao ar. Quem abrisse o app por um link — uma busca,
/// o WhatsApp, o Instagram — ou numa aba nova com página inicial passava no
/// teste, e então o segundo voltar deliberado no Seu Dia executava o `go(-2)` e
/// a tirava do Grimório. "Sai depois de 2 voltares" é o relato inteiro, com o
/// aviso de "toque de novo para sair" possivelmente escondido atrás da barra de
/// baixo.
///
/// Nenhuma página fecha uma aba que ela não abriu, e "sair" de um app que É a
/// própria aba não é serviço nenhum: quem quer sair fecha a aba. O que o voltar
/// deve fazer na web é caminhar até o Seu Dia e ficar lá.
bool podeSairDaAba() => false;

/// Sem efeito, e de propósito: porta fechada e documentada, para que quem
/// pensar em reabri-la leia antes por que ela fechou.
void sairDaAba() {}
