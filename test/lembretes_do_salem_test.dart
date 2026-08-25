import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/services/notification_service.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// O lembrete diário do Salem deixou de ser UM texto fixo repetido todo dia
/// (que o dedo aprende a dispensar) e virou uma rotação: 14 avisos avulsos,
/// cada dia com a mensagem que o índice determinístico lhe dá. Estes testes
/// travam o contrato da rotação — o agendamento em si é do plugin e roda no
/// aparelho.
void main() {
  group('a rotação das mensagens do Salem', () {
    test('o índice é do DIA do calendário: reabrir o app não embaralha', () {
      // Mesmo dia, horas diferentes → mesma mensagem.
      expect(
        NotificationService.dailyMessageIndex(DateTime(2026, 8, 23, 7), 10),
        NotificationService.dailyMessageIndex(DateTime(2026, 8, 23, 22), 10),
      );
    });

    test('dias seguidos nunca repetem a mensagem', () {
      var anterior =
          NotificationService.dailyMessageIndex(DateTime(2026, 8, 1), 10);
      for (var i = 1; i < 30; i++) {
        final atual = NotificationService.dailyMessageIndex(
          DateTime(2026, 8, 1 + i),
          10,
        );
        expect(atual, isNot(anterior), reason: 'dia +$i repetiu');
        anterior = atual;
      }
    });

    test('a janela de 14 dias percorre o pool inteiro', () {
      final vistos = <int>{
        for (var i = 0; i < NotificationService.dailyReminderWindowDays; i++)
          NotificationService.dailyMessageIndex(DateTime(2026, 8, 1 + i), 10),
      };
      expect(vistos, hasLength(10),
          reason: '14 dias com pool de 10 cobrem todas as mensagens');
    });

    test('o pool tem 10 mensagens, todas distintas e não vazias', () {
      for (final locale in const [
        Locale('pt', 'BR'),
        Locale('en'),
        Locale('es'),
      ]) {
        final pool = NotificationService.dailyMessagePool(
          lookupAppLocalizations(locale),
        );
        expect(pool, hasLength(10), reason: '$locale');
        expect(
          pool.map((m) => m.body).toSet(),
          hasLength(10),
          reason: 'corpos repetidos em $locale',
        );
        for (final mensagem in pool) {
          expect(mensagem.title.trim(), isNotEmpty, reason: '$locale');
          expect(mensagem.body.trim(), isNotEmpty, reason: '$locale');
        }
      }
    });
  });

  test('os slots do diário e dos convites de volta não colidem', () {
    // 800001..800014 (diário) e 810001/810002 (volta) vivem longe dos ids
    // dos eventos astronômicos (prefixo*10^7), da água solar (700001) e da
    // Leitura do Ciclo (900001/2).
    final diario = [
      for (var i = 0; i < NotificationService.dailyReminderWindowDays; i++)
        NotificationService.dailyReminderNotificationId + i,
    ];
    final todos = {
      ...diario,
      NotificationService.winBackD3NotificationId,
      NotificationService.winBackD7NotificationId,
      NotificationService.sunWaterNotificationId,
      NotificationService.cycleReadingWeekNotificationId,
      NotificationService.cycleReadingLunationNotificationId,
    };
    expect(
      todos,
      hasLength(diario.length + 5),
      reason: 'algum id fixo colidiu com a janela do diário',
    );
    expect(diario.last, lessThan(NotificationService.winBackD3NotificationId));
  });
}
