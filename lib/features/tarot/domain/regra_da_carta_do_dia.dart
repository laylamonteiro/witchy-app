/// A carta do dia e a cota do plano Free — agora que a pergunta é obrigatória.
///
/// Antes, a carta do dia SEM pergunta era o caminho grátis, e a primeira
/// pergunta do dia já contava como tiragem nova. Com a pergunta obrigatória
/// esse caminho grátis sumiria e a Free perderia a carta do dia. A regra:
/// a PRIMEIRA pergunta do dia É a carta do dia (grátis, lembrada); repetir a
/// mesma pergunta devolve a mesma carta sem cobrar (a carta é determinística
/// pela pergunta); uma pergunta DIFERENTE no mesmo dia é tiragem nova e
/// gasta a cota, como sempre foi.
bool deveCobrarCartaDoDia({
  required String? perguntaLembradaHoje,
  required String pergunta,
}) {
  if (perguntaLembradaHoje == null) return false;
  return _normalizar(perguntaLembradaHoje) != _normalizar(pergunta);
}

String _normalizar(String pergunta) => pergunta.trim().toLowerCase();

/// Guarda uma pergunta com o carimbo do dia: `'$hoje|$pergunta'`. É o
/// formato das duas chaves do Tarô nas preferências (a pergunta da carta do
/// dia e a última pergunta usada), para "virou o dia, some" ser só comparar
/// o prefixo.
String carimbarPerguntaDoDia({
  required String hoje,
  required String pergunta,
}) =>
    '$hoje|$pergunta';

/// A pergunta guardada, se o carimbo for de [hoje]; senão null (o dia virou,
/// nada guardado, valor estranho). Corta só no primeiro `|`: a pergunta pode
/// ter o caractere dentro.
String? perguntaSeForDeHoje({
  required String? guardada,
  required String hoje,
}) {
  if (guardada == null) return null;
  final prefixo = '$hoje|';
  if (!guardada.startsWith(prefixo)) return null;
  final pergunta = guardada.substring(prefixo.length);
  return pergunta.isEmpty ? null : pergunta;
}
