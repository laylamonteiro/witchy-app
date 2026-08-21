import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/ai/prompts/ai_prompts.dart';
import 'package:grimorio_de_bolso/core/ai/prompts/ai_prompts_en.dart';
import 'package:grimorio_de_bolso/core/ai/prompts/ai_prompts_es.dart';
import 'package:grimorio_de_bolso/core/ai/prompts/ai_prompts_pt.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/core/i18n/gender.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/magical_profile_report.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content_en.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content_es.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content_pt.dart';

/// Paridade pt/en/es dos prompts do `AIService` (`AiPrompts`):
/// campos não vazios nas três línguas, cabeçalhos exatos do Clima Mágico
/// Diário por idioma (casando com `DailyWeatherContent.looksComplete`),
/// marcadores/formatos que a UI reconhece e seleção por locale.
void main() {
  const locales = {
    'pt': Locale('pt', 'BR'),
    'en': Locale('en', 'US'),
    'es': Locale('es', 'ES'),
  };

  final promptsByLang = {
    'pt': aiPromptsPt,
    'en': aiPromptsEn,
    'es': aiPromptsEs,
  };

  // Restaura o padrão do app após cada teste para não vazar estado global.
  tearDown(() {
    ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
  });

  /// A Análise Personalizada é tecida seção a seção, e a tela monta os
  /// cards a partir das chaves. Um prompt que perca uma chave devolve um
  /// card vazio; um que devolva a mesma instrução para tudo devolve dez
  /// cards iguais. Este teste amarra as chaves às instruções nos três
  /// idiomas — e ao formato de três blocos que a leitura em páginas espera.
  group('Perfil Mágico — uma instrução por seção, nos três idiomas', () {
    for (final entry in promptsByLang.entries) {
      test('${entry.key}: cada chave tem instrução própria', () {
        final instrucoes = {
          for (final chave in MagicalProfileSections.ordered)
            chave: entry.value.magicalProfileSectionInstruction(chave),
        };
        for (final chave in MagicalProfileSections.ordered) {
          expect(instrucoes[chave]!.trim(), isNotEmpty,
              reason: 'instrução vazia: $chave [${entry.key}]');
        }
        expect(instrucoes.values.toSet(),
            hasLength(MagicalProfileSections.ordered.length),
            reason: 'instruções repetidas em ${entry.key}');
        // A chave desconhecida não pode cair numa das dez: o `_` do switch
        // existe para não quebrar, não para clonar uma seção real.
        expect(
          instrucoes.values,
          isNot(contains(entry.value.magicalProfileSectionInstruction('xyz'))),
        );
      });

      test('${entry.key}: o prompt pede os três blocos `### `', () {
        final prompt = entry.value.magicalProfileSystemPrompt(Gender.fallback);
        expect(
          RegExp(r'^###[ \t]+\S', multiLine: true).allMatches(prompt).length,
          3,
        );
        // Nenhum `## ` no prompt: o cabeçalho da seção quem escreve é o app,
        // com a chave. Se a IA escrever o dela, o parser cria um card órfão.
        expect(RegExp(r'^##[ \t]+\S', multiLine: true).hasMatch(prompt), isFalse);
      });
    }
  });

  group('AiPrompts — campos não vazios nas três línguas', () {
    // Sondas nomeadas: cada uma resolve um campo para String.
    final probes = <String, String Function(AiPrompts p, Gender g)>{
      'localizedInstruction': (p, g) => p.localizedInstruction('pt-BR'),
      'cycleRitualToSpellIntention': (p, g) =>
          p.cycleRitualToSpellIntention('Nome', 'Corpo', ''),
      'spellGenerationSystemPrompt': (p, g) =>
          p.spellGenerationSystemPrompt(g),
      'magicalProfileSystemPrompt': (p, g) => p.magicalProfileSystemPrompt(g),
      'magicalProfileSectionInstruction (essence)': (p, g) =>
          p.magicalProfileSectionInstruction(MagicalProfileSections.essence),
      'magicalProfileSectionInstruction (shadow)': (p, g) =>
          p.magicalProfileSectionInstruction(MagicalProfileSections.shadow),
      'dailyWeatherSystemPrompt': (p, g) => p.dailyWeatherSystemPrompt(g),
      'affirmationSystemPrompt': (p, g) => p.affirmationSystemPrompt(g),
      'mysticAdvisorSystemPrompt': (p, g) => p.mysticAdvisorSystemPrompt(g),
      'palmistrySystemPrompt': (p, g) => p.palmistrySystemPrompt(g),
      'tarotSpreadSystemPrompt': (p, g) => p.tarotSpreadSystemPrompt(g),
      'tarotQuestionIntro': (p, g) => p.tarotQuestionIntro,
      'numerologySystemPrompt': (p, g) => p.numerologySystemPrompt(g),
      'dreamInterpreterSystemPrompt': (p, g) =>
          p.dreamInterpreterSystemPrompt(g),
      'palmUserMessage': (p, g) => p.palmUserMessage,
      'palmDebugUserMessage': (p, g) => p.palmDebugUserMessage,
      'affirmationUserPrompt (com contexto)': (p, g) =>
          p.affirmationUserPrompt('amor', 'contexto'),
      'affirmationUserPrompt (sem contexto)': (p, g) =>
          p.affirmationUserPrompt('amor', null),
      'dreamUserPrompt (com emoções)': (p, g) =>
          p.dreamUserPrompt('sonhei com o mar', 'paz'),
      'dreamUserPrompt (sem emoções)': (p, g) =>
          p.dreamUserPrompt('sonhei com o mar', null),
      'cycleReadingSystemPrompt': (p, g) => p.cycleReadingSystemPrompt(g),
      'cycleReadingSectionInstruction (portrait)': (p, g) =>
          p.cycleReadingSectionInstruction('portrait'),
      'cycleReadingSectionInstruction (threads)': (p, g) =>
          p.cycleReadingSectionInstruction('threads'),
      'cycleReadingSectionInstruction (sky)': (p, g) =>
          p.cycleReadingSectionInstruction('sky'),
      'cycleReadingSectionInstruction (practice)': (p, g) =>
          p.cycleReadingSectionInstruction('practice'),
      'cycleReadingSectionInstruction (rituals)': (p, g) =>
          p.cycleReadingSectionInstruction('rituals'),
      'cycleReadingSectionInstruction (affirmation)': (p, g) =>
          p.cycleReadingSectionInstruction('affirmation'),
      'cycleReadingSectionInstruction (seal)': (p, g) =>
          p.cycleReadingSectionInstruction('seal'),
      'defaultSpellName': (p, g) => p.defaultSpellName,
      'encyIdentifySystemPrompt (crystal)': (p, g) =>
          p.encyIdentifySystemPrompt('crystal'),
      'encyIdentifySystemPrompt (herb)': (p, g) =>
          p.encyIdentifySystemPrompt('herb'),
      'encyIdentifySystemPrompt (color)': (p, g) =>
          p.encyIdentifySystemPrompt('color'),
      'encyIdentifyUserMessage': (p, g) => p.encyIdentifyUserMessage,
      'encyGenerateSystemPrompt (crystal)': (p, g) =>
          p.encyGenerateSystemPrompt('crystal', 'Ametista'),
      'encyGenerateSystemPrompt (herb)': (p, g) =>
          p.encyGenerateSystemPrompt('herb', 'Alecrim'),
      'encyGenerateSystemPrompt (color)': (p, g) =>
          p.encyGenerateSystemPrompt('color', 'Verde'),
      'encyGenerateUserMessage': (p, g) =>
          p.encyGenerateUserMessage('Alecrim'),
      'errorInvalidRequest': (p, g) => p.errorInvalidRequest,
      'errorBadRequest': (p, g) => p.errorBadRequest('detalhe'),
      'errorAuthentication': (p, g) => p.errorAuthentication,
      'errorRateLimit': (p, g) => p.errorRateLimit,
      'errorServiceUnavailable': (p, g) => p.errorServiceUnavailable,
      'errorConnection': (p, g) => p.errorConnection('timeout'),
      'errorProcessing': (p, g) => p.errorProcessing('falha'),
      'errorImageTooLarge': (p, g) => p.errorImageTooLarge,
      'errorPalmUnavailable': (p, g) => p.errorPalmUnavailable,
      'errorUnknown': (p, g) => p.errorUnknown,
    };

    test('todos os campos produzem texto não vazio em todos os gêneros', () {
      promptsByLang.forEach((lang, prompts) {
        probes.forEach((name, probe) {
          for (final gender in Gender.values) {
            expect(probe(prompts, gender).trim(), isNotEmpty,
                reason: '$name [$lang/${gender.name}]');
          }
        });
      });
    });

    test('conteúdo interpolado do usuário permanece intacto', () {
      promptsByLang.forEach((lang, prompts) {
        expect(prompts.affirmationUserPrompt('Proteção', 'meu emprego novo'),
            allOf(contains('Proteção'), contains('meu emprego novo')),
            reason: 'affirmationUserPrompt [$lang]');
        expect(prompts.dreamUserPrompt('voei sobre o mar', 'euforia'),
            allOf(contains('voei sobre o mar'), contains('euforia')),
            reason: 'dreamUserPrompt [$lang]');
        expect(prompts.localizedInstruction('es-ES'), contains('es-ES'),
            reason: 'localizedInstruction [$lang]');
      });
    });
  });

  group('AiPrompts — Clima Mágico Diário exige os cabeçalhos do idioma', () {
    final headingsByLang = {
      'pt': dailyWeatherFallbackHeadingsPt,
      'en': dailyWeatherFallbackHeadingsEn,
      'es': dailyWeatherFallbackHeadingsEs,
    };

    // Os mesmos pares por idioma exigidos por
    // `DailyWeatherContent.looksComplete` (Ritual Sugerido + Cuidados).
    const looksCompletePairs = {
      'pt': ['## Ritual Sugerido', '## Cuidados do Dia'],
      'en': ['## Suggested Ritual', '## Cautions for the Day'],
      'es': ['## Ritual Sugerido', '## Cuidados del Día'],
    };

    test('prompt contém as 7 seções exatas de dailyWeatherFallbackHeadings',
        () {
      promptsByLang.forEach((lang, prompts) {
        for (final gender in Gender.values) {
          final prompt = prompts.dailyWeatherSystemPrompt(gender);
          for (final heading in headingsByLang[lang]!) {
            expect(prompt, contains('## $heading'),
                reason: 'cabeçalho "$heading" [$lang/${gender.name}]');
          }
        }
      });
    });

    test('prompt contém o par Ritual+Cuidados verificado por looksComplete',
        () {
      promptsByLang.forEach((lang, prompts) {
        for (final gender in Gender.values) {
          final prompt = prompts.dailyWeatherSystemPrompt(gender);
          for (final marker in looksCompletePairs[lang]!) {
            expect(prompt, contains(marker),
                reason: 'marcador "$marker" [$lang/${gender.name}]');
          }
          // Um texto que siga o formato pedido pelo prompt passa em
          // looksComplete (garante que o cache não será regerado à toa).
          expect(DailyWeatherContent.looksComplete(prompt), isTrue,
              reason: 'looksComplete [$lang/${gender.name}]');
        }
      });
    });
  });

  group('AiPrompts — marcadores/formatos reconhecidos pela UI', () {
    test('sonhos e quiromancia mantêm os marcadores ◈ e ✦', () {
      promptsByLang.forEach((lang, prompts) {
        for (final gender in Gender.values) {
          expect(prompts.dreamInterpreterSystemPrompt(gender),
              allOf(contains('◈'), contains('✦')),
              reason: 'sonhos [$lang/${gender.name}]');
          expect(prompts.palmistrySystemPrompt(gender),
              allOf(contains('◈'), contains('✦')),
              reason: 'quiromancia [$lang/${gender.name}]');
        }
      });
    });

    test('feitiço mantém as chaves do JSON e os valores de enum em inglês',
        () {
      const requiredFragments = [
        '"name"',
        '"purpose"',
        '"type"',
        '"category"',
        '"moonPhase"',
        '"ingredients"',
        '"steps"',
        '"duration"',
        '"observations"',
        '"attraction"',
        '"banishment"',
        'newMoon/waxingCrescent/firstQuarter/waxingGibbous/fullMoon/waningGibbous/lastQuarter/waningCrescent',
        'love/protection/prosperity/healing/cleansing/luck/creativity/communication/dreams/divination/energy/home/wisdom/study/courage/friendship/work/banishing',
      ];
      promptsByLang.forEach((lang, prompts) {
        for (final gender in Gender.values) {
          final prompt = prompts.spellGenerationSystemPrompt(gender);
          for (final fragment in requiredFragments) {
            expect(prompt, contains(fragment),
                reason: 'fragmento "$fragment" [$lang/${gender.name}]');
          }
        }
      });
    });
  });

  group('AiPrompts — Leitura do Ciclo', () {
    test('prompt de sistema referencia o contrato do material (JSON)', () {
      promptsByLang.forEach((lang, prompts) {
        for (final gender in Gender.values) {
          final prompt = prompts.cycleReadingSystemPrompt(gender);
          expect(prompt, contains('JSON'),
              reason: 'JSON [$lang/${gender.name}]');
          // A regra do horário de nascimento desconhecido cita a chave real
          // do material — é ela que impede casas/ascendente inventados.
          expect(prompt, contains('unknownBirthTime'),
              reason: 'unknownBirthTime [$lang/${gender.name}]');
        }
      });
    });

    test('os rituais pedem a anotação que o app lê', () {
      // O cartão do ritual tira a lua e os ingredientes de `[moon: ...]` e
      // `[items: ...]`. Se o prompt parar de pedir a anotação, o feitiço
      // salvo perde os dois em silêncio — nada quebra, só empobrece.
      promptsByLang.forEach((lang, prompts) {
        final instrucao = prompts.cycleReadingSectionInstruction('rituals');
        expect(instrucao, contains('[moon:'), reason: 'lua [$lang]');
        expect(instrucao, contains('[items:'), reason: 'ingredientes [$lang]');
        // Os nomes das fases são invariantes: traduzi-los quebraria o
        // recorte, que casa com `MoonPhase.name`.
        for (final fase in MoonPhase.values) {
          expect(instrucao, contains(fase.name),
              reason: '${fase.name} [$lang]');
        }
      });
    });

    test('cada seção tem instrução própria (não cai no fallback)', () {
      const sectionKeys = [
        'portrait',
        'threads',
        'sky',
        'practice',
        'rituals',
        'affirmation',
        'seal',
      ];
      promptsByLang.forEach((lang, prompts) {
        final fallback = prompts.cycleReadingSectionInstruction('__unknown__');
        final seen = <String>{};
        for (final key in sectionKeys) {
          final instruction = prompts.cycleReadingSectionInstruction(key);
          expect(instruction.trim(), isNotEmpty, reason: '$key [$lang]');
          expect(instruction, isNot(equals(fallback)),
              reason: '$key usa fallback [$lang]');
          expect(seen.add(instruction), isTrue,
              reason: '$key repetida [$lang]');
        }
      });
    });
  });

  group('AiPrompts — seleção por locale', () {
    test('aiPrompts resolve a instância do idioma ativo (fallback: pt)', () {
      locales.forEach((lang, locale) {
        ContentLocale.instance.setLocale(locale);
        expect(identical(aiPrompts, promptsByLang[lang]), isTrue,
            reason: 'aiPrompts [$lang]');
      });

      // Idioma não suportado cai no português.
      ContentLocale.instance.setLocale(const Locale('fr', 'FR'));
      expect(identical(aiPrompts, aiPromptsPt), isTrue,
          reason: 'fallback para pt');
    });
  });
}
