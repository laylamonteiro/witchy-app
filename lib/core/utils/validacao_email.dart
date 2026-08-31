// Validação de FORMATO de e-mail no cadastro — a defesa barata contra
// endereços malformados que viram "hard bounce" e queimam a reputação de
// envio do projeto (o motivo dos avisos do Supabase).
//
// O que ela NÃO faz: pegar erro de digitação numa caixa que existe de
// verdade (`joaosilva` -> `joaosila`@gmail.com passa aqui — o domínio é
// válido). Só a confirmação de e-mail pega esses; por isso ela fica ligada.
//
// O que ela FAZ: barrar o que é malformado de fato — sem `@`, sem TLD
// (`joao@gmail`), TLD de uma letra (`joao@x.c`), espaço no meio, `@` a mais,
// pontos duplos, domínio quebrado.
//
// Deliberadamente PERMISSIVA com o que é válido de verdade (tags com `+`,
// pontos e hífens, subdomínios): barrar um e-mail bom custa um cadastro
// real, e isso é pior que deixar passar um duvidoso — a confirmação segura o
// resto. Só afeta cadastros NOVOS; ninguém que já existe é revalidado.

/// Normaliza para validar/enviar/gravar: sem espaços nas pontas e em caixa
/// baixa. O Supabase já guarda o e-mail em minúsculas; alinhar aqui evita que
/// `Joao@Gmail.COM` e `joao@gmail.com` pareçam contas diferentes na tela.
String normalizarEmail(String email) => email.trim().toLowerCase();

/// Um rótulo de domínio: começa e termina em alfanumérico, com hífens no
/// meio, de 1 a 63 caracteres. Depois vem o TLD (`.com`, `.br`), 2+ letras.
final _regexEmail = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+"
  r'@'
  r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
  r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*'
  r'\.[a-zA-Z]{2,}$',
);

/// `true` quando o formato é plausível o bastante para valer o envio de um
/// e-mail. Recebe o texto CRU do campo — normaliza por dentro.
bool emailTemFormatoValido(String email) {
  final e = normalizarEmail(email);
  // Limite prático do RFC 5321 para o endereço inteiro.
  if (e.isEmpty || e.length > 254) return false;
  // Pontos consecutivos são sempre inválidos (local ou domínio) e o regex
  // abaixo, sozinho, deixaria `a..b@x.com` passar.
  if (e.contains('..')) return false;
  return _regexEmail.hasMatch(e);
}
