/// Configuração do captcha de autenticação (Cloudflare Turnstile).
///
/// A site key é PÚBLICA por natureza (vai dentro do app, como a chave
/// anônima do Supabase) — quem valida é o servidor, com a secret key
/// guardada no painel do Supabase. Mesmo assim entra por `--dart-define`
/// para não ficar versionada e para permitir builds sem captcha.
///
/// ORDEM DO ROLLOUT: publique a versão com a chave compilada ANTES de
/// ligar o captcha no Supabase. A proteção é por projeto — no instante em
/// que ela é ligada, versões antigas do app, que não sabem enviar o token,
/// param de conseguir entrar.
class CaptchaConfig {
  const CaptchaConfig._();

  static const String siteKey = String.fromEnvironment(
    'TURNSTILE_SITE_KEY',
    defaultValue: '',
  );

  /// Sem chave o app se comporta exatamente como antes: nenhum widget de
  /// verificação aparece e nenhum token é enviado.
  static bool get isConfigured => siteKey.isNotEmpty;
}
