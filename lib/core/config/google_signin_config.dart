import 'package:flutter/foundation.dart' show kIsWeb;

/// Entrada com o Google SEM sair da aba (web).
///
/// O login social da web é um redirecionamento de página inteira: o
/// navegador vai para o Google e volta. Isso deixa a página do Google no
/// histórico da aba, e o voltar acaba lá — sem que o app possa impedir,
/// porque é navegação para outra origem.
///
/// O Google Identity Services resolve na raiz: a credencial é obtida DENTRO
/// da própria página, e o Supabase troca esse ID token por uma sessão. O
/// navegador nunca sai, então a entrada do Google nunca existe.
///
/// Sem [webClientId] preenchido nada muda: o app continua no
/// redirecionamento de hoje. É de propósito — a chave entra por
/// `--dart-define` no build da web, e um build sem ela não pode quebrar o
/// login de ninguém.
abstract final class GoogleSignInConfig {
  /// ID do cliente OAuth **Web** do projeto no Google Cloud (o mesmo que o
  /// provedor Google do Supabase usa). Entra por
  /// `--dart-define=GOOGLE_WEB_CLIENT_ID=...`.
  static const String webClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  /// Só na web, e só com a chave presente.
  static bool get isConfigured => kIsWeb && webClientId.isNotEmpty;

  /// As origens em que a entrada dentro da página pode ser TENTADA.
  ///
  /// O Google não aceita curinga em *Authorized JavaScript origins*: cada
  /// endereço entra na mão, um por um. Uma origem que não esteja lá não
  /// falha discretamente — dá uma tela cheia de "Access blocked:
  /// origin_mismatch" no meio do login.
  ///
  /// Por isso a pergunta certa é "esta origem está autorizada?", e não
  /// "este endereço parece efêmero?", que era o que o código perguntava:
  /// um `RegExp(r'^[0-9a-f]{8}\.')` pega o endereço de deploy da Cloudflare
  /// e mais nada — deixa passar toda prévia com nome de branch, e pegaria
  /// por engano um domínio legítimo que começasse com oito hexadecimais.
  ///
  /// **Esta lista espelha o painel do Google Cloud.** Uma entrada aqui sem
  /// a entrada lá é a tela de bloqueio; uma entrada lá sem a entrada aqui é
  /// só o redirecionamento de sempre — inofensivo. Na dúvida, de fora.
  ///
  /// As prévias por branch ficam de FORA de propósito: o endereço nasce a
  /// cada branch, autorizá-lo exigiria mexer no painel e recompilar, e a
  /// recompilação muda o endereço de novo. Elas caem no redirecionamento,
  /// que funciona em qualquer origem. Para testar o caminho novo, use o
  /// staging — é o que docs/AMBIENTES_WEB.md já recomenda.
  static const List<String> origensAutorizadas = [
    'grimoriodebolso.app',
    'staging.grimorio-de-bolso.pages.dev',
  ];

  /// A origem atual pode tentar a entrada dentro da página?
  ///
  /// Comparação exata, sem sufixo: aceitar "termina com
  /// grimorio-de-bolso.pages.dev" autorizaria todas as prévias de uma vez —
  /// justamente o que o Google recusa.
  static bool origemAutorizada(String hostname) =>
      origensAutorizadas.contains(hostname.toLowerCase());

  /// Quanto esperar o Google mostrar a credencial antes de desistir e cair
  /// no redirecionamento de sempre.
  ///
  /// O Google pode simplesmente não mostrar nada — cookies de terceiros
  /// bloqueados, FedCM desligado, a pessoa tendo dispensado antes. Esperar
  /// para sempre seria um botão que não faz nada; esperar demais seria um
  /// botão lento. Seis segundos é o tempo de a janelinha aparecer numa
  /// conexão ruim.
  ///
  /// Hoje isto é REDE DE SEGURANÇA, não o caminho normal: o serviço escuta
  /// o aviso de "não vou aparecer" que a própria API do Google emite e
  /// desiste na hora. O prazo só vale para o navegador que não emite aviso
  /// nenhum.
  static const Duration limite = Duration(seconds: 6);
}
