import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/widgets/related_link.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/data_sources/menstrual_phase_content.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/data_sources/menstrual_phase_content_en.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/data_sources/menstrual_phase_content_es.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/data_sources/menstrual_phase_content_pt.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/models/menstrual_season_content.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/internal_season.dart';

/// As quatro Estações Internas nos três idiomas: mesma ordem, mesmas chaves
/// de correspondência e nenhum texto vazio. A tradução muda a prosa e o nome
/// do verbete — nunca a identidade nem a estrutura.
///
/// E, porque este conteúdo fala perto do corpo de alguém, o teste também
/// guarda a fronteira: nada aqui promete hormônio, ovulação, fertilidade ou
/// gravidez, em nenhum dos três idiomas.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
  });

  final byLanguage = <String, List<MenstrualSeasonContent>>{
    'pt': menstrualSeasonsPt,
    'en': menstrualSeasonsEn,
    'es': menstrualSeasonsEs,
  };

  test('há uma estação para cada uma, na ordem canônica', () {
    for (final entry in byLanguage.entries) {
      expect(entry.value.length, InternalSeason.values.length,
          reason: entry.key);
      for (var i = 0; i < InternalSeason.values.length; i++) {
        expect(entry.value[i].season, InternalSeason.values[i],
            reason: '${entry.key} na posição $i');
      }
    }
  });

  test('as correspondências têm as mesmas chaves, na mesma ordem', () {
    for (var i = 0; i < menstrualSeasonsPt.length; i++) {
      final expected =
          menstrualSeasonsPt[i].correspondences.map((c) => c.key).toList();
      expect(expected.length, inInclusiveRange(2, 3),
          reason: 'de duas a três por estação');
      for (final list in [menstrualSeasonsEn, menstrualSeasonsEs]) {
        expect(list[i].correspondences.map((c) => c.key).toList(), expected,
            reason: 'posição $i');
      }
    }
  });

  test('todo texto está preenchido, com duas ou três práticas', () {
    for (final entry in byLanguage.entries) {
      for (final content in entry.value) {
        final where = '${entry.key}/${content.season.name}';
        expect(content.title.trim(), isNotEmpty, reason: where);
        expect(content.invitation.trim(), isNotEmpty, reason: where);
        expect(content.writingQuestion.trim(), isNotEmpty, reason: where);
        expect(content.practices.length, inInclusiveRange(2, 3), reason: where);
        for (final practice in content.practices) {
          expect(practice.trim(), isNotEmpty, reason: where);
        }
        for (final correspondence in content.correspondences) {
          expect(correspondence.key.trim(), isNotEmpty, reason: where);
          expect(correspondence.label.trim(), isNotEmpty, reason: where);
        }
      }
    }
  });

  test('cada correspondência abre um verbete que existe naquele idioma', () {
    for (final entry in byLanguage.entries) {
      ContentLocale.instance.setLocale(Locale(entry.key));
      for (final content in entry.value) {
        for (final correspondence in content.correspondences) {
          expect(resolveRelatedLink(correspondence.label), isNotNull,
              reason: '${entry.key}: ${correspondence.label} '
                  '(${correspondence.key}) não tem destino');
        }
      }
    }
  });

  test('nenhum texto promete hormônio, ovulação, fertilidade ou gravidez', () {
    final forbidden = RegExp(
      r'hormon|hormôn|ovula|fertil|fértil|gravid|grávid|pregnan|embaraz|'
      r'elixir|menopaus',
      caseSensitive: false,
    );
    for (final entry in byLanguage.entries) {
      for (final content in entry.value) {
        final text = [
          content.title,
          content.invitation,
          content.writingQuestion,
          ...content.practices,
        ].join(' ');
        expect(forbidden.hasMatch(text), isFalse,
            reason: '${entry.key}/${content.season.name}: $text');
      }
    }
  });

  test('o seletor devolve a estação pedida no idioma ativo', () {
    ContentLocale.instance.setLocale(const Locale('en'));
    expect(MenstrualSeasonContentSource.of(InternalSeason.winter).title,
        menstrualSeasonsEn.first.title);
    ContentLocale.instance.setLocale(const Locale('es'));
    expect(MenstrualSeasonContentSource.of(InternalSeason.autumn).title,
        menstrualSeasonsEs.last.title);
  });
}
