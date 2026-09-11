/// A convenção de cálculo que liga um dia do registro à Lua estimada.
///
/// Um registro não tem hora: para perguntar à Lua o que havia naquele dia, o
/// app usa sempre o **meio-dia local**. É convenção de cálculo, não o horário
/// de nada que aconteceu com ela — e é o que garante que trocar o fuso do
/// aparelho não reclassifique o histórico inteiro.
///
/// Este arquivo já carregou a comparação "Você e a Lua" inteira: janela
/// simétrica de ±2 dias em torno da Nova e da Cheia, contagem dos começos
/// perto de cada ponta, resumo versionado sobre os três intervalos completos
/// mais recentes. O card saiu da página do Ciclo em afda4c2 e levou junto o
/// único consumidor de tudo aquilo em lib/. O que restou vivo é só a
/// convenção do meio-dia, que a roda do ciclo e a leitura continuam chamando.
///
/// O resto foi APAGADO em vez de ficar guardado como reserva: regra que só
/// tem teste como chamador finge cobertura e faz o próximo agente acreditar
/// que existe tela lendo aquilo. O histórico do git guarda a versão completa
/// — inclusive o MenstrualInsights, apagado na mesma limpeza, de onde ela
/// tirava quantos começos exigir — se um dia o card voltar.
///
/// O nome do arquivo e da classe ficou como estava de propósito: renomear
/// mexeria na roda e na leitura sem mudar nada para quem usa o app.
abstract final class LunarComparison {
  /// A convenção de cálculo: o meio-dia local do dia observado.
  static DateTime noonOf(DateTime day) =>
      DateTime(day.year, day.month, day.day, 12);
}
