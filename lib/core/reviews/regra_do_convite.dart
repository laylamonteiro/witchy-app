/// Quando convidar a pessoa a avaliar o app na loja — e, principalmente,
/// quando NÃO convidar.
///
/// Pedir avaliação é a única coisa que o app pede para si mesmo, e por isso é
/// a mais fácil de estragar. Quem instalou ontem ainda não sabe se gosta:
/// perguntar cedo é como se colhe nota 1. Quem já disse "agora não" três vezes
/// disse o que tinha a dizer. E quem já avaliou nunca mais pode ser perguntado.
///
/// A decisão inteira é aritmética sobre números e datas, de propósito: o que
/// decide se uma pessoa é interrompida se prova em teste de unidade, não em
/// tentativa e erro com gente de verdade.
///
/// Sobre a política da loja: o convite é NEUTRO e único. Nada de perguntar
/// "está gostando?" e mandar quem diz sim para a loja e quem diz não para um
/// formulário — filtrar opinião assim é o que o Google proíbe, e é o que dá
/// suspensão. Aqui só existem dois caminhos, e os dois são honestos: avaliar
/// agora, ou não agora.
library;

/// De quanto em quanto tempo o convite pode voltar, conforme ele já foi
/// dispensado.
///
/// A escada é deliberada: quem nunca dispensou vê o convite algumas vezes por
/// semana; quem dispensou uma vez passa a ver de longe em longe; quem
/// dispensou duas, raramente. Insistir mais que isso não traz avaliação — traz
/// a avaliação de uma estrela que diz "para de perguntar".
const List<Duration> intervalosDoConvite = [
  Duration(days: 2),
  Duration(days: 5),
  Duration(days: 15),
];

/// Depois de tantas dispensas, o convite some para sempre.
const int dispensasAteDesistir = 3;

/// Dias seguidos de prática que já contam como "usa o app de verdade".
const int sequenciaQueBastaParaConvidar = 7;

/// Dias praticados no total que também bastam — para quem pratica bastante,
/// mas não todo dia.
const int diasPraticadosQueBastamParaConvidar = 14;

/// A chance de o convite aparecer num momento em que ele JÁ PODERIA aparecer.
///
/// É o que faz o convite ser encontrado em vez de esperado: sem isto, ele
/// apareceria sempre no primeiro rito depois do intervalo — mesma hora, mesma
/// tela, toda vez. Com metade, ele cai em momentos diferentes da semana.
const double chanceDeAparecer = 0.5;

/// Tudo o que o app lembra sobre convites já feitos a esta pessoa.
class MemoriaDoConvite {
  const MemoriaDoConvite({
    this.jaAvaliou = false,
    this.dispensas = 0,
    this.ultimoConvite,
  });

  /// Tocou em "Avaliar" alguma vez. Não dá para saber se ela de fato deixou a
  /// nota — a loja não conta isso para o app —, e tudo bem: quem chegou até a
  /// loja já não deve ser perguntada de novo.
  final bool jaAvaliou;

  /// Quantas vezes disse "agora não".
  final int dispensas;

  /// Quando o convite apareceu pela última vez.
  final DateTime? ultimoConvite;
}

/// O quanto esta pessoa já usou o app.
class UsoAtePagora {
  const UsoAtePagora({required this.sequencia, required this.diasPraticados});

  /// Dias seguidos de prática.
  final int sequencia;

  /// Dias em que ela praticou, somando tudo.
  final int diasPraticados;

  bool get usaDeVerdade =>
      sequencia >= sequenciaQueBastaParaConvidar ||
      diasPraticados >= diasPraticadosQueBastamParaConvidar;
}

/// Se o convite pode aparecer AGORA.
///
/// [temLoja] é falso onde não há loja para abrir — a web, por exemplo, onde o
/// app também roda. [sorteio] é um número de 0 a 1 que entra de fora para esta
/// função continuar pura e testável; quem chama passa o `Random` de verdade.
bool podeConvidar({
  required MemoriaDoConvite memoria,
  required UsoAtePagora uso,
  required bool temLoja,
  required DateTime agora,
  required double sorteio,
}) {
  if (!temLoja) return false;
  if (memoria.jaAvaliou) return false;
  if (memoria.dispensas >= dispensasAteDesistir) return false;
  if (!uso.usaDeVerdade) return false;

  final ultimo = memoria.ultimoConvite;
  if (ultimo != null) {
    final espera = intervaloApos(memoria.dispensas);
    if (agora.isBefore(ultimo.add(espera))) return false;
  }

  return sorteio < chanceDeAparecer;
}

/// Quanto esperar antes do próximo convite, depois de [dispensas] recusas.
///
/// Acima da última faixa a espera não cresce mais — mas aí [podeConvidar] já
/// desistiu de vez, então este valor não chega a ser usado.
Duration intervaloApos(int dispensas) {
  if (dispensas < 0) return intervalosDoConvite.first;
  if (dispensas >= intervalosDoConvite.length) return intervalosDoConvite.last;
  return intervalosDoConvite[dispensas];
}
