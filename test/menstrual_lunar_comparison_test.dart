import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/lunar/presentation/providers/lunar_provider.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/lunar_comparison.dart';

/// A convenção do meio-dia, que é o que sobrou de vivo da comparação lunar:
/// a roda do ciclo e a leitura perguntam a fase da Lua por este ponto do dia,
/// nunca pela meia-noite. Sem isso, um dia que cai perto da virada de fase
/// passaria a ser classificado de um jeito ou de outro conforme o fuso do
/// aparelho — por isso a convenção continua com teste próprio mesmo depois de
/// o card "Você e a Lua" sair.
void main() {
  // Exatamente o que a roda do ciclo e a leitura executam: o dia vira
  // meio-dia local, e é esse ponto que vai perguntar a fase.
  MoonPhase phaseAtNoon(DateTime day) =>
      LunarProvider.phaseOn(LunarComparison.noonOf(day));

  test('a convenção é o meio-dia local do dia observado', () {
    expect(LunarComparison.noonOf(DateTime(2026, 3, 12)),
        DateTime(2026, 3, 12, 12));
  });

  test('a hora do registro não vaza para a conta', () {
    // Dois momentos do mesmo dia perguntam à Lua exatamente o mesmo ponto:
    // é o dia que importa, não a hora em que ela abriu o app para marcar.
    expect(LunarComparison.noonOf(DateTime(2026, 3, 12, 23, 40)),
        LunarComparison.noonOf(DateTime(2026, 3, 12, 0, 5)));
  });

  // Era a comparação apagada que, de carona, ancorava a conta da lunação em
  // datas de calendário. Sem estas duas âncoras NENHUM teste do repositório
  // olharia para o resultado de LunarProvider.phaseOn — um erro de sinal ou
  // de referência na lunação passaria verde, e quem pagaria seria a fase
  // mostrada na roda do ciclo e na leitura.
  //
  // As datas ficam no meio das faixas de fase, a mais de um dia da borda
  // mais próxima, e o fuso da máquina desloca no máximo meio dia: de UTC-12
  // a UTC+14 o veredito é o mesmo.
  group('a conta da lunação continua ancorada em datas conhecidas', () {
    test('16/11/2024 ao meio-dia é Cheia', () {
      expect(phaseAtNoon(DateTime(2024, 11, 16)), MoonPhase.fullMoon);
    });

    test('08/11/2024 ao meio-dia é Quarto Crescente', () {
      expect(phaseAtNoon(DateTime(2024, 11, 8)), MoonPhase.firstQuarter);
    });
  });
}
