import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/altar_content_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/altar_content_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/altar_content_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/arcane_categories.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetype_quiz_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetype_quiz_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetype_quiz_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/elements_content_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/elements_content_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/elements_content_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/models/altar_content_model.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/models/arcane_entry_model.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/models/archetype_quiz_model.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/models/elements_content_model.dart';

/// Paridade pt/en/es do conteúdo extraído das páginas da Enciclopédia
/// (Altar, Elementos e Teste de Arquétipo): mesmas contagens/estruturas nas
/// três línguas, invariantes (emojis) idênticos posição a posição e, no quiz,
/// o mapeamento resposta→arquétipo dá o mesmo resultado em qualquer idioma.
void main() {
  const altarByLocale = <String, AltarContent>{
    'pt': altarContentPt,
    'en': altarContentEn,
    'es': altarContentEs,
  };

  const elementsByLocale = <String, ElementsContent>{
    'pt': elementsContentPt,
    'en': elementsContentEn,
    'es': elementsContentEs,
  };

  const quizByLocale = <String, List<ArchetypeQuizQuestion>>{
    'pt': archetypeQuizQuestionsPt,
    'en': archetypeQuizQuestionsEn,
    'es': archetypeQuizQuestionsEs,
  };

  const archetypesByLocale = <String, List<ArcaneEntry>>{
    'pt': archetypesPt,
    'en': archetypesEn,
    'es': archetypesEs,
  };

  group('Categorias arcanas — assets invariantes', () {
    test('imageAssetFor devolve o mesmo caminho nos 3 idiomas', () {
      addTearDown(
          () => ContentLocale.instance.setLocale(const Locale('pt', 'BR')));
      for (final category in ArcaneCategory.values) {
        final paths = <String>{};
        for (final locale in const [
          Locale('pt', 'BR'),
          Locale('en'),
          Locale('es')
        ]) {
          ContentLocale.instance.setLocale(locale);
          final entries = category.entries;
          expect(entries, isNotEmpty, reason: category.name);
          paths.add(category.imageAssetFor(entries.first));
        }
        expect(paths.length, 1,
            reason: '${category.name}: caminho deve ser invariante');
        expect(paths.first, contains('assets/images/${category.assetFolder}/'));
      }
    });
  });

  group('Altar', () {
    test('contagens iguais nas três línguas', () {
      for (final entry in altarByLocale.entries) {
        final locale = entry.key;
        final c = entry.value;
        expect(c.beginnerSteps.length, altarContentPt.beginnerSteps.length,
            reason: 'beginnerSteps $locale');
        expect(c.firstTimesItems.length,
            altarContentPt.firstTimesItems.length,
            reason: 'firstTimesItems $locale');
        expect(c.speakExamples.length, altarContentPt.speakExamples.length,
            reason: 'speakExamples $locale');
        expect(c.faqs.length, altarContentPt.faqs.length,
            reason: 'faqs $locale');
        expect(c.mountSteps.length, altarContentPt.mountSteps.length,
            reason: 'mountSteps $locale');
        expect(c.items.length, altarContentPt.items.length,
            reason: 'items $locale');
        expect(c.avoidItems.length, altarContentPt.avoidItems.length,
            reason: 'avoidItems $locale');
        expect(c.purifyMethods.length, altarContentPt.purifyMethods.length,
            reason: 'purifyMethods $locale');
        expect(c.maintainItems.length, altarContentPt.maintainItems.length,
            reason: 'maintainItems $locale');
        expect(c.usageItems.length, altarContentPt.usageItems.length,
            reason: 'usageItems $locale');
      }
    });

    test('emojis invariantes posição a posição', () {
      for (final entry in altarByLocale.entries) {
        final locale = entry.key;
        final c = entry.value;
        for (var i = 0; i < altarContentPt.items.length; i++) {
          expect(c.items[i].emoji, altarContentPt.items[i].emoji,
              reason: 'items[$i] $locale');
        }
        for (var i = 0; i < altarContentPt.purifyMethods.length; i++) {
          expect(
              c.purifyMethods[i].emoji, altarContentPt.purifyMethods[i].emoji,
              reason: 'purifyMethods[$i] $locale');
        }
      }
    });

    test('nenhum texto vazio', () {
      for (final entry in altarByLocale.entries) {
        final locale = entry.key;
        final c = entry.value;
        final texts = <String>[
          c.pageTitle, c.introTitle, c.introBody, c.introHint,
          c.beginnerTitle, c.beginnerSubtitle, c.beginnerIntro,
          c.firstTimesTitle, c.speakTitle, c.speakNote, c.faqTitle,
          c.mountTitle, c.itemsTitle, c.itemsNote, c.avoidTitle, c.safetyNote,
          c.purifyTitle, c.purifyIntro, c.purifyFrequency, c.maintainTitle,
          c.usageTitle, c.routineTitle, c.routineBody, c.finalTitle,
          c.finalBody,
          ...c.beginnerSteps
              .expand((s) => [s.title, s.description, s.tip]),
          ...c.firstTimesItems,
          ...c.speakExamples.expand((s) => [s.label, s.phrase]),
          ...c.faqs.expand((f) => [f.question, f.answer]),
          ...c.mountSteps.expand((s) => [s.title, s.description]),
          ...c.items.expand((i) => [i.title, i.description]),
          ...c.avoidItems.expand((s) => [s.title, s.description]),
          ...c.purifyMethods.expand((m) => [m.title, m.description]),
          ...c.maintainItems.expand((s) => [s.title, s.description]),
          ...c.usageItems.expand((s) => [s.title, s.description]),
        ];
        for (final text in texts) {
          expect(text.trim(), isNotEmpty, reason: 'texto vazio em $locale');
        }
      }
    });
  });

  group('Elementos', () {
    test('quatro elementos e listas com contagens iguais', () {
      for (final entry in elementsByLocale.entries) {
        final locale = entry.key;
        final c = entry.value;
        expect(c.elements.length, 4, reason: 'elements $locale');
        expect(c.balanceItems.length,
            elementsContentPt.balanceItems.length,
            reason: 'balanceItems $locale');
        expect(c.practices.length, elementsContentPt.practices.length,
            reason: 'practices $locale');
      }
    });

    test('emojis invariantes posição a posição', () {
      for (final entry in elementsByLocale.entries) {
        final locale = entry.key;
        final c = entry.value;
        for (var i = 0; i < elementsContentPt.elements.length; i++) {
          expect(c.elements[i].emoji, elementsContentPt.elements[i].emoji,
              reason: 'elements[$i] $locale');
        }
        for (var i = 0; i < elementsContentPt.balanceItems.length; i++) {
          expect(
              c.balanceItems[i].emoji, elementsContentPt.balanceItems[i].emoji,
              reason: 'balanceItems[$i] $locale');
        }
      }
    });

    test('ordem canônica Terra, Água, Fogo, Ar', () {
      for (final c in elementsByLocale.values) {
        expect(c.elements.map((e) => e.emoji).toList(),
            ['🌍', '🌊', '🔥', '💨']);
        expect(c.balanceItems.map((e) => e.emoji).toList(),
            ['🌍', '🌊', '🔥', '💨']);
      }
    });

    test('nenhum texto vazio', () {
      for (final entry in elementsByLocale.entries) {
        final locale = entry.key;
        final c = entry.value;
        final texts = <String>[
          c.pageTitle, c.introTitle, c.introBody, c.introHint,
          c.essenceLabel, c.qualitiesLabel, c.directionLabel, c.seasonLabel,
          c.lifePhaseLabel, c.timeOfDayLabel, c.colorsLabel, c.toolsLabel,
          c.correspondencesLabel,
          c.balanceTitle, c.balanceIntro, c.imbalanceTitle, c.imbalanceBody,
          c.practicesTitle, c.honoringTitle, c.honoringBody,
          ...c.elements.expand((e) => [
                e.name, e.essence, e.qualities, e.direction, e.season,
                e.lifePhase, e.timeOfDay, e.colors, e.tools,
                e.correspondences, e.whenToWorkTitle, e.whenToWork,
              ]),
          ...c.balanceItems.expand((b) => [b.name, b.description]),
          ...c.practices.expand((p) => [p.title, p.description]),
        ];
        for (final text in texts) {
          expect(text.trim(), isNotEmpty, reason: 'texto vazio em $locale');
        }
      }
    });
  });

  group('Teste de Arquétipo', () {
    test('mesmo número de perguntas e opções nas três línguas', () {
      expect(archetypeQuizQuestionsEn.length,
          archetypeQuizQuestionsPt.length);
      expect(archetypeQuizQuestionsEs.length,
          archetypeQuizQuestionsPt.length);
      for (var q = 0; q < archetypeQuizQuestionsPt.length; q++) {
        expect(archetypeQuizQuestionsEn[q].options.length,
            archetypeQuizQuestionsPt[q].options.length,
            reason: 'pergunta $q (en)');
        expect(archetypeQuizQuestionsEs[q].options.length,
            archetypeQuizQuestionsPt[q].options.length,
            reason: 'pergunta $q (es)');
      }
    });

    test('chave archetypeEmoji invariante posição a posição', () {
      for (var q = 0; q < archetypeQuizQuestionsPt.length; q++) {
        for (var o = 0;
            o < archetypeQuizQuestionsPt[q].options.length;
            o++) {
          final pt = archetypeQuizQuestionsPt[q].options[o].archetypeEmoji;
          expect(archetypeQuizQuestionsEn[q].options[o].archetypeEmoji, pt,
              reason: 'pergunta $q opção $o (en)');
          expect(archetypeQuizQuestionsEs[q].options[o].archetypeEmoji, pt,
              reason: 'pergunta $q opção $o (es)');
        }
      }
    });

    test('toda opção aponta para um arquétipo existente em cada idioma', () {
      for (final quizEntry in quizByLocale.entries) {
        final locale = quizEntry.key;
        final archetypes = archetypesByLocale[locale]!;
        final emojis = archetypes.map((a) => a.emoji).toSet();
        // Emojis devem ser únicos para servir de chave estável.
        expect(emojis.length, archetypes.length,
            reason: 'emojis duplicados em archetypes ($locale)');
        for (var q = 0; q < quizEntry.value.length; q++) {
          for (final option in quizEntry.value[q].options) {
            expect(emojis, contains(option.archetypeEmoji),
                reason:
                    'pergunta $q: ${option.archetypeEmoji} sem arquétipo ($locale)');
          }
        }
      }
    });

    test('mesmas escolhas → mesmo arquétipo em qualquer idioma', () {
      // Replica a lógica da página: cada resposta soma 1 ponto ao emoji da
      // opção; vence a maior pontuação (empate: quem pontuou primeiro).
      String winnerFor(List<ArchetypeQuizQuestion> questions,
          List<int> choices) {
        final scores = <String, int>{};
        for (var q = 0; q < questions.length; q++) {
          final key = questions[q].options[choices[q]].archetypeEmoji;
          scores[key] = (scores[key] ?? 0) + 1;
        }
        return scores.entries
            .reduce((a, b) => b.value > a.value ? b : a)
            .key;
      }

      final n = archetypeQuizQuestionsPt.length;
      final optionCounts = [
        for (final q in archetypeQuizQuestionsPt) q.options.length,
      ];
      // Padrões de escolha variados, incluindo casos com empate.
      final patterns = <List<int>>[
        List.filled(n, 0),
        List.filled(n, 1),
        List.filled(n, 5),
        [for (var q = 0; q < n; q++) q % optionCounts[q]],
        [for (var q = 0; q < n; q++) (q * 3 + 1) % optionCounts[q]],
        [for (var q = 0; q < n; q++) (optionCounts[q] - 1 - q) % optionCounts[q]],
      ];

      for (final choices in patterns) {
        final winnerPt = winnerFor(archetypeQuizQuestionsPt, choices);
        final winnerEn = winnerFor(archetypeQuizQuestionsEn, choices);
        final winnerEs = winnerFor(archetypeQuizQuestionsEs, choices);
        expect(winnerEn, winnerPt, reason: 'escolhas $choices (en)');
        expect(winnerEs, winnerPt, reason: 'escolhas $choices (es)');

        // O vencedor resolve para o MESMO arquétipo (mesmo índice) nas três
        // línguas, como faz a página via `e.emoji == winner`.
        final idxPt =
            archetypesPt.indexWhere((e) => e.emoji == winnerPt);
        final idxEn =
            archetypesEn.indexWhere((e) => e.emoji == winnerEn);
        final idxEs =
            archetypesEs.indexWhere((e) => e.emoji == winnerEs);
        expect(idxPt, isNonNegative, reason: 'escolhas $choices');
        expect(idxEn, idxPt, reason: 'escolhas $choices (en)');
        expect(idxEs, idxPt, reason: 'escolhas $choices (es)');
      }
    });

    test('mapeamento PT original preservado (emoji ↔ nome em português)', () {
      // Garante que a migração nome→emoji não mudou o resultado em PT.
      const legacyNameByEmoji = <String, String>{
        '🧙‍♀️': 'A Bruxa',
        '🌿': 'A Curandeira',
        '👁️': 'A Vidente',
        '🛡️': 'A Guardiã',
        '🦉': 'A Sábia',
        '🌸': 'A Donzela',
        '🤱': 'A Mãe',
        '🏹': 'A Caçadora',
        '🕸️': 'A Tecelã',
        '⚗️': 'A Alquimista',
        '🌑': 'A Rainha Sombria',
      };
      for (final q in archetypeQuizQuestionsPt) {
        for (final option in q.options) {
          final expectedName = legacyNameByEmoji[option.archetypeEmoji];
          expect(expectedName, isNotNull,
              reason: 'emoji desconhecido: ${option.archetypeEmoji}');
          final entry = archetypesPt
              .firstWhere((e) => e.emoji == option.archetypeEmoji);
          expect(entry.name, expectedName,
              reason: 'emoji ${option.archetypeEmoji}');
        }
      }
    });
  });
}
