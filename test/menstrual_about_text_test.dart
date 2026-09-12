import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// A prosa sobre a menstruação mora no ARB, e o ARB não passa por nenhum
/// teste de fronteira da camada de conteúdo. Este arquivo é essa fronteira:
/// é o que impede uma revisão futura de transformar explicação em promessa
/// de saúde — ou a Lua em relógio do corpo — nos quatro idiomas de uma vez.
void main() {
  final locales = <String, AppLocalizations>{
    'pt': lookupAppLocalizations(const Locale('pt')),
    'pt_BR': lookupAppLocalizations(const Locale('pt', 'BR')),
    'en': lookupAppLocalizations(const Locale('en')),
    'es': lookupAppLocalizations(const Locale('es')),
  };

  List<String> textos(AppLocalizations l10n) => [
        l10n.menstrualAboutTitle,
        l10n.menstrualAboutOpening,
        l10n.menstrualAboutMeaningTitle,
        l10n.menstrualAboutMeaning,
        l10n.menstrualAboutMoonTitle,
        l10n.menstrualAboutMoon,
        l10n.menstrualAboutCraftTitle,
        l10n.menstrualAboutCraft,
        l10n.menstrualAboutNote,
      ];

  test('nenhum idioma fica sem o texto', () {
    for (final entry in locales.entries) {
      for (final texto in textos(entry.value)) {
        expect(texto.trim(), isNotEmpty, reason: entry.key);
      }
    }
  });

  test('a explicação não promete corpo: nada de hormônio, ovulação, '
      'fertilidade, gravidez ou menopausa — e nada de usar o sangue', () {
    // A mesma barreira da camada de conteúdo, mais o que é específico de um
    // texto que fala de sangue: descrever o papel histórico basta, instruir
    // manipulação ou ingestão nunca.
    final proibido = RegExp(
      r'hormon|hormôn|ovula|fertil|fértil|gravid|grávid|pregnan|embaraz|'
      r'elixir|menopaus|ingeri|ingest|beber\b|drink',
      caseSensitive: false,
    );
    for (final entry in locales.entries) {
      for (final texto in textos(entry.value)) {
        expect(proibido.hasMatch(texto), isFalse,
            reason: '${entry.key}: $texto');
      }
    }
  });

  test('a Lua nunca é vendida como sincronia: a negativa está escrita', () {
    // A analogia entre ciclo e Lua é tradição; sincronia seria afirmação
    // sobre o corpo dela. O texto tem de negar, com todas as letras, em todos
    // os idiomas — se alguém reescrever o parágrafo, este teste cai.
    const negativas = {
      'pt': 'não acompanha as fases da Lua',
      'pt_BR': 'não acompanha as fases da Lua',
      'en': 'does not follow the phases of the Moon',
      'es': 'no sigue las fases de la Luna',
    };
    for (final entry in locales.entries) {
      expect(entry.value.menstrualAboutMoon, contains(negativas[entry.key]),
          reason: entry.key);
    }
  });
}
