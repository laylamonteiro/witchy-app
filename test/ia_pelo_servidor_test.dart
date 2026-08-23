import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/ai/ia_pelo_servidor.dart';

/// O app manda a chave da Groq/Gemini no cabeçalho, do próprio navegador. Na
/// web isso é público: o JavaScript publicado carrega a chave em texto, e
/// quem abrir o DevTools a copia e passa a consumir a cota — e a fatura —
/// sem passar pelo app.
///
/// O intermediário (supabase/functions/ia) resolve isso pondo a chave do
/// lado do servidor. Mas ele precisa estar PUBLICADO antes de o app apontar
/// para lá: religar num projeto sem a função quebraria a IA para todo mundo.
///
/// Por isso o interruptor nasce desligado, e é isso que este teste tranca.
/// Um build que ligasse o caminho novo por engano — sem `--dart-define` e
/// sem função no ar — não teria sintoma nenhum até alguém tentar usar a IA.
void main() {
  test('nasce desligado: sem --dart-define, o caminho é o de sempre', () {
    // Os testes rodam sem `--dart-define`, então esta é a situação real de
    // um build que não recebeu o interruptor.
    expect(IaPeloServidor.ligado, isFalse);
    expect(IaPeloServidor.ativo, isFalse);
  });

  test('sem Supabase configurado, não há para onde mandar', () {
    // `ativo` exige as duas coisas. Um build com o interruptor ligado e sem
    // URL do Supabase cairia no endereço vazio — melhor seguir no caminho
    // direto do que não responder.
    expect(IaPeloServidor.ativo, isFalse);
  });

  test('o endereço aponta para a função, não para o provedor', () {
    // Se alguém trocar o caminho, o pedido sai com a sessão do Supabase no
    // cabeçalho para um endereço que não é o nosso.
    expect(IaPeloServidor.endereco, endsWith('/functions/v1/ia'));
    expect(IaPeloServidor.endereco, isNot(contains('groq.com')));
    expect(IaPeloServidor.endereco, isNot(contains('googleapis.com')));
  });
}
