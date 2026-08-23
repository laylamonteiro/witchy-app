/// Fora da web não há janelas: abrir falha (quem chama cai no caminho de
/// sempre) e a pergunta "sou a janela de login?" é sempre não.
Object? abrirJanelaDeLogin(String url) => null;

bool fecharSeJanelaDeLogin() => false;
