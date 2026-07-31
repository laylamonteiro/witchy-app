import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/ai/prompts/ai_prompts.dart';
import 'package:grimorio_de_bolso/core/ai/prompts/ai_prompts_en.dart';
import 'package:grimorio_de_bolso/core/ai/prompts/ai_prompts_es.dart';
import 'package:grimorio_de_bolso/core/ai/prompts/ai_prompts_pt.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/core/i18n/gender.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content.dart';
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

  group('AiPrompts — campos não vazios nas três línguas', () {
    // Sondas nomeadas: cada uma resolve um campo para String.
    final probes = <String, String Function(AiPrompts p, Gender g)>{
      'localizedInstruction': (p, g) => p.localizedInstruction('pt-BR'),
      'spellGenerationSystemPrompt': (p, g) =>
          p.spellGenerationSystemPrompt(g),
      'magicalProfileSystemPrompt': (p, g) => p.magicalProfileSystemPrompt(g),
      'dailyWeatherSystemPrompt': (p, g) => p.dailyWeatherSystemPrompt(g),
      'affirmationSystemPrompt': (p, g) => p.affirmationSystemPrompt(g),
      'mysticAdvisorSystemPrompt': (p, g) => p.mysticAdvisorSystemPrompt(g),
      'palmistrySystemPrompt': (p, g) => p.palmistrySystemPrompt(g),
      'tarotSpreadSystemPrompt': (p, g) => p.tarotSpreadSystemPrompt(g),
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
      'defaultSpellName': (p, g) => p.defaultSpellName,
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
