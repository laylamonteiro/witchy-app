import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/models/cycle_reading_model.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/services/cycle_reading_service.dart';

/// A janela com que a leitura abre é UMA, e mora no serviço: a tela da
/// leitura e o cartão de Ciclos a pedem ao mesmo lugar. Eram duas — a tela
/// tinha a dela, o cartão contava desde a última leitura — e a dona viu os
/// dois números discordarem.
void main() {
  test('a lunação sugerida é o mês do calendário até hoje, inteiro', () {
    final janela = CycleReadingService.suggestedWindow(
      CycleReadingPeriodType.lunation,
      now: DateTime(2026, 9, 12, 15, 40),
    );
    expect(janela.start, DateTime(2026, 9, 1));
    expect(janela.end, DateTime(2026, 9, 13),
        reason: 'The end is exclusive: today is lived whole');
  });

  test('a virada de mês é normalizada pelo construtor', () {
    final janela = CycleReadingService.suggestedWindow(
      CycleReadingPeriodType.lunation,
      now: DateTime(2026, 9, 30, 23),
    );
    expect(janela.end, DateTime(2026, 10, 1));
  });

  test('a semana sugerida é a semana corrente', () {
    final now = DateTime(2026, 9, 12);
    expect(
      CycleReadingService.suggestedWindow(CycleReadingPeriodType.week,
          now: now),
      CycleReadingService.currentWeek(now: now),
    );
  });
}
