/// Configuração do captcha de autenticação (Cloudflare Turnstile).
///
/// A site key é PÚBLICA por natureza (vai dentro do app, como a chave
/// anônima do Supabase) — quem valida é o servidor, com a secret key
/// guardada no painel do Supabase. Mesmo assim entra por `--dart-define`
/// para não ficar versionada e para permitir builds sem captcha.
///
/// A EXIGÊNCIA JÁ ESTÁ LIGADA no servidor (Supabase → Authentication →
/// Attack Protection, provedor Turnstile — conferido em 23/08/2026). Isso
/// muda o significado de não ter a chave: não é mais "app sem captcha", é
/// "app que não entra". O Supabase recusa cadastro, entrada por senha e
/// recuperação de senha quando chegam sem token.
///
/// Por isso o release.yml PARA quando o secret TURNSTILE_SITE_KEY falta, em
/// vez de compilar sem ele. Se um dia a exigência do painel for desligada,
/// aquela trava pode voltar a ser aviso — nesta ordem, nunca na inversa.
class CaptchaConfig {
  const CaptchaConfig._();

  static const String siteKey = String.fromEnvironment(
    'TURNSTILE_SITE_KEY',
    defaultValue: '',
  );

  /// Falso significa: nenhum widget de verificação aparece e nenhum token é
  /// enviado. Com a exigência ligada no painel, isso equivale a um app que
  /// não consegue autenticar ninguém por e-mail — não a um app "sem
  /// captcha". A esteira de release existe para esse caso nunca ser
  /// publicado.
  static bool get isConfigured => siteKey.isNotEmpty;
}
