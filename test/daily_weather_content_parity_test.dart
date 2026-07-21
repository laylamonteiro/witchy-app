import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content_en.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content_es.dart';
import 'package:grimorio_de_bolso/features/astrology/data/data_sources/daily_weather_content_pt.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/transit_model.dart';

/// Garante que as variantes pt/en/es do conteúdo do Clima Mágico Diário têm a
/// mesma estrutura (mesmo número de títulos de fallback, mesmas seções no
/// texto de fallback) e valores não vazios nas três línguas.
void main() {
  DailyMagicalWeather sampleWeather(ZodiacSign moonSign) {
    return DailyMagicalWeather(
      date: DateTime(2026, 7, 20),
      transits: const [],
      aspects: const [],
      generalInterpretation: 'Interpretação geral de teste.',
      recommendedPractices: const ['Prática A', 'Prática B'],
      energyKeywords: const ['teste'],
      overallEnergy: EnergyLevel.values.first,
      moonSign: moonSign,
      moonPhase: 'Lua Cheia',
    );
  }

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
        'as seções do texto de fallback usam os títulos de fallback do mesmo '
        'idioma', () {
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
        expect(sections, isNotEmpty);
        for (final section in sections) {
          expect(headings, contains(section), reason: section);
        }
      });
    });
  });
}
