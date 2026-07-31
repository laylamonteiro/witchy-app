import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content_en.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content_es.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content_pt.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/transit_model.dart';

/// Garante que as variantes pt/en/es do conteúdo do Clima Mágico Diário têm a
/// mesma estrutura (mesmo número de títulos de fallback, mesmas seções no
/// texto de fallback) e valores não vazios nas três línguas.
void main() {
  DailyMagicalWeather sampleWeather(
    ZodiacSign moonSign, {
    List<TransitAspect> aspects = const [],
  }) {
    return DailyMagicalWeather(
      date: DateTime(2026, 7, 20),
      transits: const [],
      aspects: aspects,
      generalInterpretation: 'Interpretação geral de teste.',
      recommendedPractices: const ['Prática A', 'Prática B'],
      energyKeywords: const ['teste'],
      overallEnergy: EnergyLevel.values.first,
      moonSign: moonSign,
      moonPhase: 'Lua Cheia',
    );
  }

  const challengingAspect = TransitAspect(
    transitPlanet: Planet.mars,
    natalPlanet: Planet.sun,
    aspectType: AspectType.square,
    orb: 2.0,
    interpretation: 'Aspecto tenso de teste.',
    energyLevel: EnergyLevel.challenging,
  );

  group('Conteúdo do Clima Mágico Diário', () {
    test('os títulos de fallback têm a mesma quantidade nas três línguas', () {
      expect(dailyWeatherFallbackHeadingsPt.length, 7);
      expect(dailyWeatherFallbackHeadingsEn.length,
          dailyWeatherFallbackHeadingsPt.length);
      expect(dailyWeatherFallbackHeadingsEs.length,
          dailyWeatherFallbackHeadingsPt.length);
    });

    test('títulos de fallback são não vazios e sem duplicatas', () {
      for (final headings in [
        dailyWeatherFallbackHeadingsPt,
        dailyWeatherFallbackHeadingsEn,
        dailyWeatherFallbackHeadingsEs,
      ]) {
        expect(headings.toSet().length, headings.length);
        for (final heading in headings) {
          expect(heading.trim(), isNotEmpty);
        }
      }
    });

    test('o placeholder premium é não vazio nas três línguas', () {
      for (final placeholder in [
        dailyWeatherPremiumPlaceholderPt,
        dailyWeatherPremiumPlaceholderEn,
        dailyWeatherPremiumPlaceholderEs,
      ]) {
        expect(placeholder.trim(), isNotEmpty);
      }
    });

    test(
        'o texto de fallback cobre todos os signos lunares nas três línguas, '
        'sem null e com os dados interpolados', () {
      for (final sign in ZodiacSign.values) {
        final weather = sampleWeather(sign);
        for (final fn in [
          dailyWeatherFallbackTextPt,
          dailyWeatherFallbackTextEn,
          dailyWeatherFallbackTextEs,
        ]) {
          final text = fn(weather);
          expect(text.trim(), isNotEmpty, reason: sign.name);
          expect(text, isNot(contains('null')), reason: sign.name);
          expect(text, contains('Interpretação geral de teste.'),
              reason: sign.name);
          expect(text, contains('- Prática A'), reason: sign.name);
          expect(text, contains('Lua Cheia'), reason: sign.name);
        }
      }
    });

    test(
        'as seções do texto de fallback são exatamente os títulos de fallback '
        'do mesmo idioma, na mesma ordem (7 seções)', () {
      final weather = sampleWeather(ZodiacSign.cancer);
      final variants = <List<String>, String>{
        dailyWeatherFallbackHeadingsPt: dailyWeatherFallbackTextPt(weather),
        dailyWeatherFallbackHeadingsEn: dailyWeatherFallbackTextEn(weather),
        dailyWeatherFallbackHeadingsEs: dailyWeatherFallbackTextEs(weather),
      };
      variants.forEach((headings, text) {
        final sections = RegExp(r'^## (.+)$', multiLine: true)
            .allMatches(text)
            .map((m) => m.group(1))
            .toList();
        expect(sections, headings);
      });
    });

    test(
        'a seção de cuidados lista os aspectos desafiadores quando existem '
        'nas três línguas', () {
      final weather =
          sampleWeather(ZodiacSign.cancer, aspects: [challengingAspect]);
      for (final fn in [
        dailyWeatherFallbackTextPt,
        dailyWeatherFallbackTextEn,
        dailyWeatherFallbackTextEs,
      ]) {
        expect(fn(weather), contains(challengingAspect.description));
      }
    });

    test('looksComplete reconhece o fallback novo nas três línguas', () {
      final weather = sampleWeather(ZodiacSign.cancer);
      for (final fn in [
        dailyWeatherFallbackTextPt,
        dailyWeatherFallbackTextEn,
        dailyWeatherFallbackTextEs,
      ]) {
        expect(DailyWeatherContent.looksComplete(fn(weather)), isTrue);
      }
    });

    test('looksComplete rejeita o fallback antigo (curto), em qualquer língua',
        () {
      const oldPt = '## Energia do Dia\n\nTexto.\n\n## A Lua Hoje\n\nTexto.\n\n'
          '## Oportunidades Mágicas\n\n- Prática.\n\n'
          '## Cristais e Aliados\n\n- Quartzo.\n\n'
          '## Mensagem das Estrelas\n\nTexto.\n';
      const oldEn = '## Energy of the Day\n\nText.\n\n## The Moon Today\n\n'
          'Text.\n\n## Magical Opportunities\n\n- Practice.\n\n'
          '## Crystals and Allies\n\n- Quartz.\n\n'
          '## Message from the Stars\n\nText.\n';
      const oldEs = '## Energía del Día\n\nTexto.\n\n## La Luna Hoy\n\n'
          'Texto.\n\n## Oportunidades Mágicas\n\n- Práctica.\n\n'
          '## Cristales y Aliados\n\n- Cuarzo.\n\n'
          '## Mensaje de las Estrellas\n\nTexto.\n';
      for (final oldText in [oldPt, oldEn, oldEs]) {
        expect(DailyWeatherContent.looksComplete(oldText), isFalse);
      }
      expect(DailyWeatherContent.looksComplete(''), isFalse);
    });
  });
}
