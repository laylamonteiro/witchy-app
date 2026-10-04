/// A cota do plano Free é por PERGUNTA, não por tiragem.
///
/// Com a mesma pergunta a pessoa faz cada mesa uma vez — carta do dia, três
/// cartas, cruz, a tiragem de runas, a do oráculo — sem gastar nada. É uma
/// pergunta DIFERENTE que abre uma tiragem nova e consome a cota do dia.
/// Premium não tem cota.
///
/// "Sem pergunta" não é caso especial: [normalizarPergunta] devolve `''`, e a
/// regra compara strings normalizadas. A primeira tiragem sem pergunta cobra e
/// fixa `''` como a pergunta do dia; as seguintes sem pergunta saem livres,
/// exatamente como aconteceria com uma pergunta escrita. Não é brecha — é o
/// mesmo balde.
///
/// Esta regra nasceu dentro do tarô e mora aqui desde que runas e oráculo
/// passaram a usá-la. É deliberadamente pura: quem decide o que a pessoa pode
/// tirar é aritmética sobre duas strings e dois booleanos, e aritmética se
/// prova em teste de unidade. A MESMA função serve a prévia na tela e a
/// cobrança no repositório — se as duas divergissem, o botão mentiria.
library;

/// A forma canônica de uma pergunta: é ela que decide "é a mesma pergunta?" e
/// é ela que vai para `normalized_question` em `selection_sessions`.
///
/// Sem ela cada ferramenta normalizava à sua maneira — uma com `trim`, outra
/// sem — e "Vou viajar? " contava como pergunta nova em um lugar e como a
/// mesma no outro.
String normalizarPergunta(String pergunta) => pergunta.trim().toLowerCase();

/// Se a pergunta lembrada do dia é diferente da que está sendo feita — e
/// portanto se esta tiragem abre uma cota nova.
///
/// Sem pergunta lembrada, não há o que cobrar: é a primeira do dia.
bool deveCobrarCartaDoDia({
  required String? perguntaLembradaHoje,
  required String pergunta,
}) {
  if (perguntaLembradaHoje == null) return false;
  return normalizarPergunta(perguntaLembradaHoje) !=
      normalizarPergunta(pergunta);
}

/// Guarda uma pergunta com o carimbo do dia: `'$hoje|$pergunta'`. É o formato
/// das preferências legadas (a pergunta da carta do dia e a última usada),
/// para "virou o dia, some" ser só comparar o prefixo.
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

/// O que fazer com um pedido de tiragem.
enum DecisaoDaTiragem {
  /// Sorteia sem cobrar.
  liberar,

  /// Pergunta nova: gasta uma cota e sorteia.
  cobrar,

  /// Mesa já feita hoje com esta pergunta: mostra a mesma, sem cobrar.
  repetir,

  /// Pergunta nova sem cota: convite ao Premium.
  bloquear,
}

DecisaoDaTiragem decidirTiragem({
  required bool premium,
  required String? perguntaDoDia,
  required String pergunta,
  required bool tiragemJaFeitaHoje,
  required bool temCota,
}) {
  if (premium) return DecisaoDaTiragem.liberar;
  final mesmaPergunta = perguntaDoDia != null &&
      !deveCobrarCartaDoDia(
        perguntaLembradaHoje: perguntaDoDia,
        pergunta: pergunta,
      );
  if (mesmaPergunta) {
    return tiragemJaFeitaHoje
        ? DecisaoDaTiragem.repetir
        : DecisaoDaTiragem.liberar;
  }
  return temCota ? DecisaoDaTiragem.cobrar : DecisaoDaTiragem.bloquear;
}

/// O que a tela diz ANTES de a pessoa escolher a carta.
///
/// Existe porque a surpresa cara é a outra ordem: escolher a carta e só então
/// descobrir que aquela pergunta custava a tiragem do dia — ou que não havia
/// mais tiragem. A prévia sai da MESMA [decidirTiragem] que o repositório
/// aplica, então o aviso nunca pode discordar do que vai acontecer.
enum SituacaoDaTiragem {
  /// Não custa nada: é a pergunta de hoje, ou a primeira e ainda há cota.
  livre,

  /// Pergunta nova, com cota: esta tiragem é a do dia.
  gastaUma,

  /// Pergunta nova, sem cota. Há duas saídas, e as duas são legítimas: voltar
  /// para a pergunta de hoje ou assinar.
  semCota,

  /// Esta mesa já foi feita hoje com esta pergunta — reabrir mostra a mesma.
  jaFeita,
}

SituacaoDaTiragem avaliarTiragem({
  required bool premium,
  required String? perguntaDoDia,
  required String pergunta,
  required bool temCota,
  required bool tiragemJaFeitaHoje,
}) {
  // Mesa já feita é sempre livre, em qualquer plano: não há sorteio novo, é a
  // mesma mesa de volta. Vem antes da cota de propósito — reabrir o que já se
  // viu nunca pode esbarrar em limite.
  if (tiragemJaFeitaHoje) return SituacaoDaTiragem.jaFeita;
  return switch (decidirTiragem(
    premium: premium,
    perguntaDoDia: perguntaDoDia,
    pergunta: pergunta,
    tiragemJaFeitaHoje: false,
    temCota: temCota,
  )) {
    DecisaoDaTiragem.liberar ||
    DecisaoDaTiragem.repetir =>
      SituacaoDaTiragem.livre,
    DecisaoDaTiragem.cobrar => SituacaoDaTiragem.gastaUma,
    DecisaoDaTiragem.bloquear => SituacaoDaTiragem.semCota,
  };
}
