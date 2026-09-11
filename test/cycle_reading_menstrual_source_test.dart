import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/services/cycle_reading_composer.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/internal_season.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_reading_context.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_reading_scope.dart';

/// O caminho da fonte íntima até o material da leitura.
///
/// O risco que este teste guarda é um só: o material geral vai INTEIRO para
/// qualquer seção que não esteja cadastrada no recorte por seção. Se a fonte
/// íntima morasse no JSON geral, uma seção nova a receberia por esquecimento.
/// Ela mora fora dele, e é injetada seção a seção pela lista fechada do
/// módulo.
void main() {
  final days = [
    MenstrualDay(
        userId: 'she',
        day: DateTime(2026, 3, 4),
        mark: MenstrualMark.start,
        symptoms: const ['cramps'],
        note: 'um dia quieto',
        season: InternalSeason.winter),
    MenstrualDay(
        userId: 'she', day: DateTime(2026, 3, 6), mark: MenstrualMark.spotting),
  ];

  final scope = MenstrualReadingScope(
    userId: 'she',
    start: DateTime(2026, 3, 1),
    end: DateTime(2026, 4, 1),
    entries: [for (final day in days) MenstrualScopeEntry.of(day)],
  );

  CycleReadingMaterial materialWith(MenstrualReadingContext? context) =>
      CycleReadingMaterial(
        json: {
          'period': {'start': '2026-03-01', 'end': '2026-04-01'},
          'recordCount': 3,
          'timeline': const ['algo que ela escreveu'],
        },
        recordCount: 3,
        menstrual: context,
      );

  Map<String, dynamic> decode(String json) =>
      jsonDecode(json) as Map<String, dynamic>;

  test('a fonte íntima nunca mora no material geral', () {
    final material =
        materialWith(MenstrualReadingContext.of(scope, days));
    expect(decode(material.compactJson).containsKey('menstrual'), isFalse,
        reason: 'O JSON geral é o que vai para seção não cadastrada');
  });

  test('cada seção recebe a projeção que lhe cabe', () {
    final material =
        materialWith(MenstrualReadingContext.of(scope, days));

    final portrait = decode(material.compactJsonFor('portrait'));
    expect(portrait['menstrual'], isNotNull);
    final portraitDay =
        ((portrait['menstrual'] as Map)['days'] as List).first as Map;
    expect((portraitDay['observed'] as Map)['mark'], 'start');

    final sky = decode(material.compactJsonFor('sky'));
    final skyDay = ((sky['menstrual'] as Map)['days'] as List).first as Map;
    expect(skyDay.containsKey('observed'), isFalse,
        reason: 'O céu cruza datas, não sintomas');
    expect(skyDay['moon_estimated'], isNotNull);

    final affirmation = decode(material.compactJsonFor('affirmation'));
    expect((affirmation['menstrual'] as Map)['chosen_seasons'], ['winter']);
    expect((affirmation['menstrual'] as Map).containsKey('days'), isFalse);

    expect(decode(material.compactJsonFor('uma_secao_nova'))
        .containsKey('menstrual'), isFalse,
        reason: 'Seção desconhecida não recebe fonte íntima por fallback');
    expect(decode(material.compactJsonFor('numbers')).containsKey('menstrual'),
        isFalse);
  });

  test('a contagem da leitura cresce; a contagem comercial não', () {
    final material =
        materialWith(MenstrualReadingContext.of(scope, days));
    expect(material.recordCount, 3,
        reason: 'É o sinal que mede a leitura e alimenta oferta');
    expect(material.readingIncludedRecordCount, 5);
    expect(material.menstrualCoverage!['authorized_days'], 2);
  });

  test('sem autorização, o material é exatamente o de antes', () {
    final material = materialWith(null);
    expect(material.readingIncludedRecordCount, material.recordCount);
    expect(material.menstrualCoverage, isNull);
    for (final section in ['portrait', 'sky', 'affirmation', 'threads']) {
      expect(decode(material.compactJsonFor(section)).containsKey('menstrual'),
          isFalse,
          reason: section);
    }
  });

  test('um escopo vazio não chega a lugar nenhum', () {
    const empty = MenstrualReadingScope.none(userId: 'she');
    final material =
        materialWith(MenstrualReadingContext.of(empty, days));
    expect(decode(material.compactJsonFor('portrait')).containsKey('menstrual'),
        isFalse);
    expect(material.menstrualCoverage, isNull);
  });
}
