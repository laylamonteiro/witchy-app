/// A semana a que um dia pertence, para a cota da interpretação da tiragem.
///
/// Ler o que as cartas dizem JUNTAS é o que a assinatura vende — tirar é o que
/// qualquer site faz. Então essa leitura não é diária: quem não assina tem UMA
/// por semana, dividida entre tarô, runas e oráculo. Rara o bastante para ser
/// um evento, frequente o bastante para ser experimentada.
///
/// É cota PRÓPRIA, separada da página do Conselheiro Místico, que segue com a
/// dela por dia.
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
