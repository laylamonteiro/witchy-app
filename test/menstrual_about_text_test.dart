import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// A prosa sobre a menstruação e sobre as Estações Internas mora no ARB, e o
/// ARB não passa pelo teste de fronteira da camada de conteúdo
/// (test/menstrual_season_content_parity_test.dart). Este arquivo é essa
/// fronteira para o texto novo: é o que impede uma revisão futura de
/// transformar explicação em promessa de saúde — ou a Lua em relógio do
/// corpo — nos quatro idiomas de uma vez.
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
        l10n.menstrualSeasonAboutTitle,
        l10n.menstrualSeasonAboutBody,
        l10n.menstrualSeasonAboutUse,
        l10n.menstrualSeasonAboutReading,
        l10n.menstrualSeasonPrivate,
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

  test('a explicação da estação diz o que sai dali para a Leitura do Ciclo',
      () {
    // Explicar a estação sem dizer que ela acompanha a leitura autorizada
    // seria explicar pela metade: MenstrualReadingScope.defaultFields leva
    // MenstrualField.season assim que a fonte é ligada.
    const leitura = {
      'pt': 'Leitura do Ciclo',
      'pt_BR': 'Leitura do Ciclo',
      'en': 'Cycle Reading',
      'es': 'Lectura del Ciclo',
    };
    for (final entry in locales.entries) {
      expect(entry.value.menstrualSeasonAboutReading,
          contains(leitura[entry.key]),
          reason: entry.key);
    }
  });

  test('o rodapé do campo de escrita não promete sigilo que o app não cumpre',
      () {
    // `menstrualSeasonPrivate` dizia que a escrita não ia "para o Diário, para
    // o acervo nem para a IA". A escrita da estação é `MenstrualField
    // .seasonNote`, e a chave das palavras de menstrual_source_tile.dart a
    // manda junto com a Leitura do Ciclo — que fica no acervo. A frase antiga
    // era falsa e contradizia, no mesmo card, o bloco recolhível logo acima.
    // O rodapé tem de nomear a saída que existe.
    const leitura = {
      'pt': 'Leitura do Ciclo',
      'pt_BR': 'Leitura do Ciclo',
      'en': 'Cycle Reading',
      'es': 'Lectura del Ciclo',
    };
    final negaAIA = RegExp(r'nem para a IA|ni a la IA|or to the AI');
    for (final entry in locales.entries) {
      final texto = entry.value.menstrualSeasonPrivate;
      expect(texto, contains(leitura[entry.key]), reason: entry.key);
      expect(negaAIA.hasMatch(texto), isFalse,
          reason: '${entry.key}: $texto');
    }
  });

  test('quem manda ligar uma chave a chama pelo nome que está na tela', () {
    // Os dois textos mandam a pessoa ligar o interruptor das palavras na
    // Leitura do Ciclo. Antes diziam "a chave das palavras", que não é o
    // rótulo de nada: na tela o interruptor se chama
    // `cycleReadingMenstrualWords`. Instrução que não bate com o que a pessoa
    // vê é pior do que instrução nenhuma — e renomear o interruptor sem
    // corrigir a instrução tem de derrubar este teste.
    for (final entry in locales.entries) {
      final rotulo = entry.value.cycleReadingMenstrualWords;
      expect(entry.value.menstrualSeasonAboutReading, contains(rotulo),
          reason: entry.key);
      expect(entry.value.menstrualSeasonPrivate, contains(rotulo),
          reason: entry.key);
    }
  });
}
