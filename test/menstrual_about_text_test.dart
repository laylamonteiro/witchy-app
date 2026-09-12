import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// A prosa da página do Ciclo mora no ARB — a abertura, o ensaio, a frase
/// de cuidado e os oito convites da Lua — e o ARB não passa por nenhum
/// teste de fronteira da camada de conteúdo. Este arquivo é essa fronteira:
/// é o que impede uma revisão futura de transformar reverência em promessa
/// de saúde, a Lua em relógio do corpo, ou o texto em app que se justifica —
/// nos quatro idiomas de uma vez.
void main() {
  final locales = <String, AppLocalizations>{
    'pt': lookupAppLocalizations(const Locale('pt')),
    'pt_BR': lookupAppLocalizations(const Locale('pt', 'BR')),
    'en': lookupAppLocalizations(const Locale('en')),
    'es': lookupAppLocalizations(const Locale('es')),
  };

  List<String> ensaio(AppLocalizations l10n) => [
        l10n.menstrualOpeningTitle,
        l10n.menstrualOpeningLine,
        l10n.menstrualAboutMeaningTitle,
        l10n.menstrualAboutMeaning,
        l10n.menstrualAboutMoonTitle,
        l10n.menstrualAboutMoon,
        l10n.menstrualAboutCraftTitle,
        l10n.menstrualAboutCraft,
        l10n.menstrualAboutNote,
      ];

  List<String> convites(AppLocalizations l10n) => [
        l10n.menstrualMoonInviteNewMoon,
        l10n.menstrualMoonInviteWaxingCrescent,
        l10n.menstrualMoonInviteFirstQuarter,
        l10n.menstrualMoonInviteWaxingGibbous,
        l10n.menstrualMoonInviteFullMoon,
        l10n.menstrualMoonInviteWaningGibbous,
        l10n.menstrualMoonInviteLastQuarter,
        l10n.menstrualMoonInviteWaningCrescent,
      ];

  List<String> textos(AppLocalizations l10n) =>
      [...ensaio(l10n), ...convites(l10n)];

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

  test('o texto não se justifica: nada de diagnóstico, estimativa, '
      '"não afirma" nem "(opcional)"', () {
    // Decisão da dona: o app parou de se explicar para quem lê. A frase de
    // cuidado é uma só, e as outras dizem o que o sangue é — não o que o
    // app não faz.
    final boilerplate = RegExp(
      r'diagn|estima|não afirma|does not claim|no afirma|não promete|'
      r'does not promise|no promete|opcional|optional',
      caseSensitive: false,
    );
    for (final entry in locales.entries) {
      for (final texto in textos(entry.value)) {
        expect(boilerplate.hasMatch(texto), isFalse,
            reason: '${entry.key}: $texto');
      }
    }
  });

  test('a Lua nunca vira causa: sem sincronia, regulação ou influência '
      'sobre o sangue', () {
    // A analogia entre ciclo e Lua é tradição; sincronia seria afirmação
    // sobre o corpo dela. O ensaio e os convites podem pôr as duas coisas
    // lado a lado, nunca uma mandando na outra.
    final causa = RegExp(
      r'sincron|synchron|regula|alinha|align|influ|govern|controla|control',
      caseSensitive: false,
    );
    for (final entry in locales.entries) {
      for (final texto in [
        entry.value.menstrualAboutMoon,
        ...convites(entry.value),
      ]) {
        expect(causa.hasMatch(texto), isFalse,
            reason: '${entry.key}: $texto');
      }
    }
  });

  test('os convites da Lua são curtos: convite e gesto, sem discurso', () {
    for (final entry in locales.entries) {
      for (final texto in convites(entry.value)) {
        expect(texto.split(RegExp(r'\s+')).length, lessThanOrEqualTo(20),
            reason: '${entry.key}: $texto');
      }
    }
  });
}
