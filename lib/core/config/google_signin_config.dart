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

  /// Quanto esperar o Google mostrar a credencial antes de desistir e cair
  /// no redirecionamento de sempre.
  ///
  /// O Google pode simplesmente não mostrar nada — cookies de terceiros
  /// bloqueados, FedCM desligado, a pessoa tendo dispensado antes. Esperar
  /// para sempre seria um botão que não faz nada; esperar demais seria um
  /// botão lento. Seis segundos é o tempo de a janelinha aparecer numa
  /// conexão ruim.
  static const Duration limite = Duration(seconds: 6);
}
