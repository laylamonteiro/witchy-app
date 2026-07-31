/// Mascara um e-mail para uso em logs de depuração (LGPD-friendly):
/// mantém o primeiro caractere do local-part e o domínio.
/// Ex.: `bruxa@exemplo.com` → `b***@exemplo.com`.
String maskEmail(String? email) {
  if (email == null || email.isEmpty) return '(vazio)';
  final at = email.indexOf('@');
  if (at <= 0) return '***';
  return '${email[0]}***${email.substring(at)}';
}
