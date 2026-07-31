import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/tarot/data/data_sources/tarot_concept_questions_en.dart';
import 'package:grimorio_de_bolso/features/tarot/data/data_sources/tarot_concept_questions_es.dart';
import 'package:grimorio_de_bolso/features/tarot/data/data_sources/tarot_concept_questions_pt.dart';

/// As 12 perguntas conceituais do quiz de Tarot nas 3 línguas: mesma
/// contagem, 4 opções cada, textos não vazios. A correta é sempre a [0].
void main() {
  test('12 perguntas com 4 opções nas 3 línguas', () {
    for (final list in [
      tarotConceptQuestionsPt,
      tarotConceptQuestionsEn,
      tarotConceptQuestionsEs
    ]) {
      expect(list.length, 12);
      for (final (text, options) in list) {
        expect(text.trim(), isNotEmpty);
        expect(options.length, 4);
        for (final o in options) {
          expect(o.trim(), isNotEmpty);
        }
      }
    }
  });
}
