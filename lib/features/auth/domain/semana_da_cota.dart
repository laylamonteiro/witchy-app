/// A semana a que um dia pertence, para a cota do Conselheiro Místico.
///
/// A leitura do Conselheiro é o que a assinatura vende de verdade — tirar
/// cartas é o que qualquer site faz. Então ela não é diária: quem não assina
/// tem UMA por semana, e pode gastá-la onde quiser (na página do Conselheiro
/// ou na interpretação de uma tiragem). Rara o bastante para ser um evento,
/// frequente o bastante para ser experimentada.
///
/// A semana começa na SEGUNDA e a chave é a data dela. Assim não há conta de
/// número de semana ISO para errar na virada do ano: duas datas caem na mesma
/// semana exatamente quando têm a mesma segunda-feira.
///
/// Puro e sem Flutter, como o resto do que decide o que a pessoa pode fazer:
/// aritmética de calendário se prova em teste de unidade.
String chaveDaSemana(DateTime dia) {
  // `DateTime.weekday` é 1 na segunda e 7 no domingo. Voltar `weekday - 1`
  // dias sempre cai na segunda daquela semana, e o construtor normaliza o
  // estouro de mês e de ano sozinho.
  final segunda = DateTime(dia.year, dia.month, dia.day - (dia.weekday - 1));
  return '${segunda.year}-${segunda.month}-${segunda.day}';
}

/// Se [agora] caiu numa semana diferente da de [ultimoReset] — isto é, se a
/// cota do Conselheiro virou.
bool virouASemana({required DateTime ultimoReset, required DateTime agora}) =>
    chaveDaSemana(ultimoReset) != chaveDaSemana(agora);
