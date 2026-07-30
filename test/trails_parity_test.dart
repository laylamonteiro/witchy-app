import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_bruxaria_tradicional_en.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_bruxaria_tradicional_es.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_bruxaria_tradicional_pt.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_branca_en.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_branca_es.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_branca_pt.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_do_caos_en.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_do_caos_es.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_do_caos_pt.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_negra_en.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_negra_es.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_negra_pt.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_verde_en.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_verde_es.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_magia_verde_pt.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_quiromancia_en.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_quiromancia_es.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_quiromancia_pt.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_tarot_en.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_tarot_es.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_tarot_pt.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_wicca_en.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_wicca_es.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails/trail_wicca_pt.dart';
import 'package:grimorio_de_bolso/features/learning/data/models/trail_model.dart';

/// Garante que as variantes pt/en/es de cada trilha de aprendizado têm a mesma
/// identidade e estrutura — mesmo id de trilha, mesmo número de lições,
/// mesmos ids de lição na mesma ordem e o mesmo número de pagePrompts. A
/// tradução nunca pode alterar a identidade nem a estrutura do conteúdo.
void main() {
  // As 8 trilhas nos três idiomas, na mesma ordem exposta por learningTrails.
  const trailsPt = <LearningTrail>[
    magiaBrancaTrailPt,
    magiaVerdeTrailPt,
    wiccaTrailPt,
    bruxariaTradicionalTrailPt,
    magiaNegraTrailPt,
    magiaDoCaosTrailPt,
    tarotTrailPt,
    quiromanciaTrailPt,
  ];
  const trailsEn = <LearningTrail>[
    magiaBrancaTrailEn,
    magiaVerdeTrailEn,
    wiccaTrailEn,
    bruxariaTradicionalTrailEn,
    magiaNegraTrailEn,
    magiaDoCaosTrailEn,
    tarotTrailEn,
    quiromanciaTrailEn,
  ];
  const trailsEs = <LearningTrail>[
    magiaBrancaTrailEs,
    magiaVerdeTrailEs,
    wiccaTrailEs,
    bruxariaTradicionalTrailEs,
    magiaNegraTrailEs,
    magiaDoCaosTrailEs,
    tarotTrailEs,
    quiromanciaTrailEs,
  ];

  test('as três línguas têm as mesmas 8 trilhas na mesma ordem', () {
    expect(trailsPt.length, 8);
    expect(trailsEn.length, trailsPt.length);
    expect(trailsEs.length, trailsPt.length);

    for (var i = 0; i < trailsPt.length; i++) {
      // O id da trilha é a identidade estável, invariante entre idiomas.
      expect(trailsEn[i].id, trailsPt[i].id, reason: 'índice $i');
      expect(trailsEs[i].id, trailsPt[i].id, reason: 'índice $i');
    }
  });

  test('cada trilha tem o mesmo número de lições e os mesmos ids na ordem', () {
    for (var i = 0; i < trailsPt.length; i++) {
      final pt = trailsPt[i];
      final en = trailsEn[i];
      final es = trailsEs[i];

      expect(pt.lessons.length, greaterThanOrEqualTo(9), reason: pt.id);
      expect(en.lessons.length, pt.lessons.length, reason: pt.id);
      expect(es.lessons.length, pt.lessons.length, reason: pt.id);

      for (var j = 0; j < pt.lessons.length; j++) {
        final lp = pt.lessons[j];
        final le = en.lessons[j];
        final ls = es.lessons[j];

        // Id da lição: identidade estável, invariante entre idiomas.
        expect(le.id, lp.id, reason: '${pt.id} lição $j');
        expect(ls.id, lp.id, reason: '${pt.id} lição $j');

        // Mesmo número de perguntas do preenchimento guiado.
        expect(le.pagePrompts.length, lp.pagePrompts.length,
            reason: '${pt.id}/${lp.id} pagePrompts');
        expect(ls.pagePrompts.length, lp.pagePrompts.length,
            reason: '${pt.id}/${lp.id} pagePrompts');
      }
    }
  });

  test('title/teaching/practice não vazios nas três línguas', () {
    for (final trails in [trailsPt, trailsEn, trailsEs]) {
      for (final trail in trails) {
        expect(trail.title.trim(), isNotEmpty, reason: trail.id);
        expect(trail.subtitle.trim(), isNotEmpty, reason: trail.id);
        expect(trail.description.trim(), isNotEmpty, reason: trail.id);

        for (final lesson in trail.lessons) {
          final id = '${trail.id}/${lesson.id}';
          expect(lesson.title.trim(), isNotEmpty, reason: id);
          expect(lesson.teaching.trim(), isNotEmpty, reason: id);
          expect(lesson.practice.trim(), isNotEmpty, reason: id);
        }
      }
    }
  });
}
