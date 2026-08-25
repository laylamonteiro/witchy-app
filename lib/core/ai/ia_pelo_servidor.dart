import '../config/supabase_config.dart';

/// A IA passa pelo SEU servidor, em vez de o app falar direto com o provedor.
///
/// Sem isto, o app manda a chave da Groq/Gemini no cabeçalho, do próprio
/// navegador. No aparelho já é frágil; na web é público — o JavaScript de
/// grimoriodebolso.app carrega a chave em texto, e quem abrir o DevTools a
/// copia e passa a consumir a cota e a fatura sem passar pelo app.
///
/// Com o interruptor ligado, o pedido vai para a Edge Function
/// `supabase/functions/ia`, que põe a chave do lado do servidor. A chave
/// nunca sai de lá.
///
/// **DESLIGADO por padrão, e é de propósito.** A função precisa estar
/// publicada ANTES: religar num projeto sem ela quebraria a IA para todo
/// mundo. A ordem é publicar (docs/CHAVES_DE_IA.md), conferir com o `curl`
/// de lá, e só então acrescentar
/// `--dart-define=IA_PELO_SERVIDOR=true` ao build.
///
/// **Exige conta**, por decisão da dona do produto: a função recusa quem não
/// tem sessão do Supabase. É o que impede o intermediário de virar um proxy
/// aberto — sem isso, trocaríamos "roubam a chave" por "usam a chave pelo
/// meu servidor", que é o mesmo prejuízo com mais passos.
abstract final class IaPeloServidor {
  static const bool ligado = bool.fromEnvironment('IA_PELO_SERVIDOR');

  /// Só vale com o Supabase configurado: sem URL e sem chave anônima não há
  /// para onde mandar, e cair no caminho direto é melhor do que não
  /// responder.
  static bool get ativo => ligado && SupabaseConfig.isConfigured;

  static String get endereco => '${SupabaseConfig.url}/functions/v1/ia';
}
