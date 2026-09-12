import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/menstrual_report_marks.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Quais leituras levaram a fonte íntima junto.
///
/// A marca é registro de operação: datas e identificadores, nenhuma
/// observação dela. Serve para dizer que um relatório contém o que ela
/// autorizou, para mostrar quais leituras usaram um registro antes de
/// apagá-lo, e para apagar as cópias derivadas junto.
void main() {
  const marks = MenstrualReportMarks();

  MenstrualReportMark mark({
    required String reading,
    required String writing,
    List<String> days = const ['2026-03-04'],
    String scope = 'abc123',
  }) =>
      MenstrualReportMark(
        readingId: reading,
        writingId: writing,
        scope: scope,
        dayKeys: days,
        at: DateTime(2026, 3, 20),
      );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a marca guarda a leitura, o relatório e os dias que foram junto',
      () async {
    await marks.record('she', mark(reading: 'r1', writing: 'w1'));
    final all = await marks.all('she');
    expect(all.single.readingId, 'r1');
    expect(all.single.writingId, 'w1');
    expect(all.single.dayKeys, ['2026-03-04']);
    expect(await marks.isSensitive('she', 'w1'), isTrue);
    expect(await marks.isSensitive('she', 'outro'), isFalse);
    expect(await marks.isSensitive('outra-conta', 'w1'), isFalse,
        reason: 'A marca é da conta que autorizou');
  });

  test('gerar de novo a mesma leitura troca a marca, não soma outra',
      () async {
    await marks.record('she', mark(reading: 'r1', writing: 'w1'));
    await marks.record('she',
        mark(reading: 'r1', writing: 'w1', days: ['2026-03-04', '2026-03-06'],
            scope: 'def456'));
    final all = await marks.all('she');
    expect(all, hasLength(1));
    expect(all.single.scope, 'def456');
    expect(all.single.dayKeys, hasLength(2));
  });

  test('ela vê quais leituras usaram um registro', () async {
    await marks.record('she', mark(reading: 'r1', writing: 'w1'));
    await marks.record('she',
        mark(reading: 'r2', writing: 'w2', days: ['2026-03-06']));
    expect((await marks.using('she', '2026-03-04')).map((m) => m.readingId),
        ['r1']);
    expect((await marks.using('she', '2026-03-06')).map((m) => m.readingId),
        ['r2']);
    expect(await marks.using('she', '2026-04-01'), isEmpty);
  });

  test('apagar tudo esquece as marcas, e uma a uma também some', () async {
    await marks.record('she', mark(reading: 'r1', writing: 'w1'));
    await marks.record('she', mark(reading: 'r2', writing: 'w2'));
    await marks.remove('she', 'r1');
    expect((await marks.all('she')).map((m) => m.readingId), ['r2']);
    await marks.forget('she');
    expect(await marks.all('she'), isEmpty);
  });

  test('um armazenamento estragado não derruba nada', () async {
    SharedPreferences.setMockInitialValues(
        {'menstrual_reports_she': 'isto não é json'});
    expect(await marks.all('she'), isEmpty);
  });
}
