import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/menstrual_cycle_schema.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/models/cycle_reading_model.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/services/cycle_reading_service.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/menstrual_consent_store.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_reading_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

/// A autorização é conferida antes de CADA chamada — não perguntada de novo,
/// só conferida. Se ela retira o sim, corrige um registro autorizado ou troca
/// de conta no meio, a geração para ali: nada mais sai, o rascunho vai embora
/// e o crédito continua dela.
void main() {
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  const user = 'she';

  late MenstrualCycleRepository records;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('cycle_scope');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await const MenstrualConsentStore().setRecordingAllowed(user, true);
    final db = await DatabaseHelper.instance.database;
    await db.delete(MenstrualCycleSchema.table);
    records = MenstrualCycleRepository();
  });

  Future<MenstrualReadingScope> authorize() async {
    final saved = await records.save(MenstrualDay(
        userId: user, day: DateTime(2026, 3, 4), mark: MenstrualMark.start));
    return MenstrualReadingScope(
      userId: user,
      start: DateTime(2026, 3, 1),
      end: DateTime(2026, 4, 1),
      entries: [MenstrualScopeEntry.of(saved)],
      consentRevision:
          await const MenstrualConsentStore().consentRevision(user),
    );
  }

  CycleReadingModel creditOf() => CycleReadingModel(
        userId: user,
        periodStart: DateTime(2026, 3, 1),
        periodEnd: DateTime(2026, 4, 1),
        status: CycleReadingStatus.pending,
      );

  test('retirar o consentimento no meio interrompe a geração', () async {
    final scope = await authorize();
    var calls = 0;
    final service = CycleReadingService(
      generateSection: (sectionKey, materialJson) async {
        calls++;
        // Ela retira o sim depois da primeira seção.
        if (calls == 1) {
          await const MenstrualConsentStore().setRecordingAllowed(user, false);
        }
        return 'texto da seção';
      },
    );

    await expectLater(
      service.generateForCredit(
        credit: creditOf(),
        userId: user,
        menstrual: scope,
      ),
      throwsA(isA<MenstrualScopeChanged>()),
    );
    expect(calls, 1, reason: 'A segunda chamada não chegou a sair');
  });

  test('corrigir um registro autorizado no meio interrompe a geração',
      () async {
    final scope = await authorize();
    var calls = 0;
    final service = CycleReadingService(
      generateSection: (sectionKey, materialJson) async {
        calls++;
        if (calls == 1) {
          // O mesmo dia, corrigido: a revisão sobe e a autorização era da
          // versão anterior.
          await records.save(MenstrualDay(
              userId: user,
              day: DateTime(2026, 3, 4),
              mark: MenstrualMark.start,
              note: 'pensando melhor'));
        }
        return 'texto da seção';
      },
    );

    await expectLater(
      service.generateForCredit(
        credit: creditOf(),
        userId: user,
        menstrual: scope,
      ),
      throwsA(isA<MenstrualScopeChanged>()),
    );
    expect(calls, 1);
  });

  test('sem fonte íntima, nada disso acontece', () async {
    var calls = 0;
    final service = CycleReadingService(
      generateSection: (sectionKey, materialJson) async {
        calls++;
        return 'texto da seção';
      },
    );
    final result = await service.generateForCredit(
      credit: creditOf(),
      userId: user,
    );
    expect(calls, greaterThan(1));
    expect(result.reading.status, CycleReadingStatus.generated);
  });
}
