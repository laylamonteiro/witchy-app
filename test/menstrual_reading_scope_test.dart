import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/internal_season.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_reading_context.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_reading_scope.dart';

/// O que ela autorizou para UMA leitura, e o que nunca sai daqui.
///
/// O escopo é lista, não permissão aberta: dia a dia, na revisão que ela viu,
/// dentro da janela, com os campos que ela marcou. Corrigir um dia, apagar um
/// dia ou retirar o consentimento invalida a autorização — e a nota livre só
/// vai junto se ela disser que sim.
void main() {
  MenstrualDay day(
    int dayOfMonth, {
    MenstrualMark mark = MenstrualMark.flow,
    List<String> symptoms = const [],
    String note = '',
    InternalSeason? season,
    String seasonNote = '',
    int revision = 1,
  }) =>
      MenstrualDay(
        userId: 'she',
        day: DateTime(2026, 3, dayOfMonth),
        mark: mark,
        symptoms: symptoms,
        note: note,
        season: season,
        seasonNote: seasonNote,
        revision: revision,
      );

  MenstrualReadingScope scopeOf(
    List<MenstrualDay> days, {
    Set<MenstrualField>? fields,
    int consentRevision = 1,
  }) =>
      MenstrualReadingScope(
        userId: 'she',
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 4, 1),
        entries: [for (final d in days) MenstrualScopeEntry.of(d)],
        fields: fields ?? MenstrualReadingScope.defaultFields,
        consentRevision: consentRevision,
      );

  test('a impressão do escopo muda com qualquer parte do contrato', () {
    final days = [day(4), day(5)];
    final scope = scopeOf(days);
    expect(scope.fingerprint, scopeOf(days).fingerprint,
        reason: 'O mesmo contrato dá sempre a mesma impressão');
    expect(scope.fingerprint, isNot(scopeOf([day(4)]).fingerprint));
    expect(scope.fingerprint,
        isNot(scopeOf(days, consentRevision: 2).fingerprint),
        reason: 'Retirar e dar o sim de novo é outra autorização');
    expect(
        scope.fingerprint,
        isNot(scopeOf(days, fields: {
          ...MenstrualReadingScope.defaultFields,
          MenstrualField.note,
        }).fingerprint),
        reason: 'Incluir as palavras dela muda o que foi autorizado');
    expect(scope.matches(scopeOf(days)), isTrue);
    expect(scope.matches(scopeOf([day(4)])), isFalse);
    expect(scope.matches(null), isFalse);
  });

  test('um dia corrigido depois da autorização sai do escopo', () {
    final original = day(4);
    final scope = scopeOf([original, day(5)]);
    final corrected = original.copyWith(revision: original.revision + 1);

    expect(scope.covers(original), isTrue);
    expect(scope.covers(corrected), isFalse,
        reason: 'Ela autorizou aquele dia como ele era');
    final context = MenstrualReadingContext.of(scope, [corrected, day(5)]);
    expect(context.days.map((d) => d.dayKey), ['2026-03-05']);
    expect(context.isIntactFor([corrected, day(5)]), isFalse,
        reason: 'A geração que dependia do dia corrigido não vale mais');
    expect(context.isIntactFor([original, day(5)]), isTrue);
  });

  test('nada de fora da janela, e nada que ela não listou', () {
    final scope = scopeOf([day(4)]);
    final outside = MenstrualDay(
        userId: 'she', day: DateTime(2026, 2, 27), mark: MenstrualMark.start);
    final unlisted = day(9);
    final context =
        MenstrualReadingContext.of(scope, [day(4), outside, unlisted]);
    expect(context.days.map((d) => d.dayKey), ['2026-03-04']);
  });

  test('cada seção recebe só o que lhe cabe, e chave nova não recebe nada', () {
    final chosen = day(4,
        mark: MenstrualMark.start,
        symptoms: ['cramps'],
        note: 'um dia quieto',
        season: InternalSeason.winter,
        seasonNote: 'acolher');
    final scope = scopeOf([chosen], fields: {
      ...MenstrualReadingScope.defaultFields,
      MenstrualField.note,
      MenstrualField.seasonNote,
    });
    final context = MenstrualReadingContext.of(scope, [chosen]);

    final portrait = context.projectionFor('portrait')!;
    final firstDay = (portrait['days'] as List).first as Map<String, dynamic>;
    expect(firstDay['observed'], containsPair('mark', 'start'));
    expect(firstDay['observed'], containsPair('note', 'um dia quieto'));
    expect(firstDay['chosen_by_her'], containsPair('season', 'winter'),
        reason: 'A estação é escolha dela, e vem marcada como escolha');

    final love = context.projectionFor('love')!;
    final loveDay = (love['days'] as List).first as Map<String, dynamic>;
    expect(loveDay['observed'], isNot(contains('note')),
        reason: 'As palavras dela só vão onde precisam ir');

    final sky = context.projectionFor('sky')!;
    final skyDay = (sky['days'] as List).first as Map<String, dynamic>;
    expect(skyDay.keys, containsAll(['date', 'moon_estimated']));
    expect(skyDay, isNot(contains('observed')),
        reason: 'O céu cruza datas, não sintomas');

    final affirmation = context.projectionFor('affirmation')!;
    expect(affirmation['chosen_seasons'], ['winter']);
    expect(affirmation, isNot(contains('days')));

    expect(context.projectionFor('numbers'), isNull,
        reason: 'Os números recebem cobertura, não observações');
    expect(context.projectionFor('uma_secao_nova'), isNull,
        reason: 'Chave desconhecida nunca recebe fonte íntima por fallback');
    expect(MenstrualSectionAccess.of('uma_secao_nova'),
        MenstrualProjection.none);
  });

  test('a nota livre fica de fora enquanto ela não pedir', () {
    final chosen = day(4, note: 'minhas palavras');
    final scope = scopeOf([chosen]);
    expect(scope.includesWrittenWords, isFalse);
    final context = MenstrualReadingContext.of(scope, [chosen]);
    final portrait = context.projectionFor('portrait')!;
    final firstDay = (portrait['days'] as List).first as Map<String, dynamic>;
    expect(firstDay['observed'], isNot(contains('note')));
    expect(context.coverage['includes_written_words'], isFalse);
  });

  test('campo ausente é ausente, nunca "sem sintomas"', () {
    final chosen = day(4, symptoms: const []);
    final context = MenstrualReadingContext.of(scopeOf([chosen]), [chosen]);
    final firstDay = (context.projectionFor('portrait')!['days'] as List).first
        as Map<String, dynamic>;
    expect(firstDay['not_recorded'], contains('symptoms'));
    expect(firstDay['observed'], isNot(contains('symptoms')));
  });

  test('a cobertura diz o alcance, e não vira atividade', () {
    final days = [day(4), day(5)];
    final scope = scopeOf(days);
    final coverage = MenstrualReadingContext.of(scope, days).coverage;
    expect(coverage['authorized_days'], 2);
    expect(coverage['window'], {'start': '2026-03-01', 'end': '2026-04-01'});
    expect(coverage['scope'], scope.fingerprint);
    expect(coverage.keys, isNot(contains('streak')));
    expect(coverage.keys, isNot(contains('practice_days')));
  });

  test('sem autorização nenhuma, não há projeção', () {
    const empty = MenstrualReadingScope.none(userId: 'she');
    final context = MenstrualReadingContext.of(empty, [day(4)]);
    expect(context.isEmpty, isTrue);
    expect(context.projectionFor('portrait'), isNull);
    expect(context.coverage['authorized_days'], 0);
  });
}
