import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/numerology/data/numerology_meanings_data_en.dart';
import 'package:grimorio_de_bolso/features/numerology/data/numerology_meanings_data_es.dart';
import 'package:grimorio_de_bolso/features/numerology/data/numerology_meanings_data_pt.dart';

/// Paridade pt/en/es dos significados numerológicos: mesmas chaves, mesmos
/// números/emojis invariantes, textos não vazios.
void main() {
  test('numberMeanings: mesmas chaves (1-9, 11, 22, 33) nas 3 línguas', () {
    const expected = {1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33};
    expect(numberMeaningsPt.keys.toSet(), expected);
    expect(numberMeaningsEn.keys.toSet(), expected);
    expect(numberMeaningsEs.keys.toSet(), expected);

    for (final n in expected) {
      for (final m in [
        numberMeaningsPt[n]!,
        numberMeaningsEn[n]!,
        numberMeaningsEs[n]!
      ]) {
        expect(m.number, n);
        expect(m.title.trim(), isNotEmpty, reason: 'número $n');
        expect(m.keywords.length, 4, reason: 'número $n');
        expect(m.description.trim(), isNotEmpty, reason: 'número $n');
        expect(m.shadow.trim(), isNotEmpty, reason: 'número $n');
      }
    }
  });

  test('profileNumberInfos: mesmas chaves e emojis invariantes', () {
    expect(profileNumberInfosEn.keys.toSet(), profileNumberInfosPt.keys.toSet());
    expect(profileNumberInfosEs.keys.toSet(), profileNumberInfosPt.keys.toSet());
    for (final key in profileNumberInfosPt.keys) {
      expect(profileNumberInfosEn[key]!.emoji, profileNumberInfosPt[key]!.emoji);
      expect(profileNumberInfosEs[key]!.emoji, profileNumberInfosPt[key]!.emoji);
      for (final info in [
        profileNumberInfosPt[key]!,
        profileNumberInfosEn[key]!,
        profileNumberInfosEs[key]!
      ]) {
        expect(info.label.trim(), isNotEmpty, reason: key);
        expect(info.explanation.trim(), isNotEmpty, reason: key);
      }
    }
  });

  test('repeatedSequenceMessages: mesmas sequências nas 3 línguas', () {
    expect(repeatedSequenceMessagesEn.keys.toSet(),
        repeatedSequenceMessagesPt.keys.toSet());
    expect(repeatedSequenceMessagesEs.keys.toSet(),
        repeatedSequenceMessagesPt.keys.toSet());
    for (final entry in repeatedSequenceMessagesPt.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
      expect(repeatedSequenceMessagesEn[entry.key]!.trim(), isNotEmpty);
      expect(repeatedSequenceMessagesEs[entry.key]!.trim(), isNotEmpty);
    }
  });
}
