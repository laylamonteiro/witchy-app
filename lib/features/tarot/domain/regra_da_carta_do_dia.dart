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
