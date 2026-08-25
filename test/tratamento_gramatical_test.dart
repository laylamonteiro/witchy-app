import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/core/i18n/gender.dart';
import 'package:grimorio_de_bolso/core/i18n/tratamento_do_contexto.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/providers/learning_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// O relato da dona (25/08): "mesmo com o gênero masculino selecionado, há
/// vários textos com feminino aparentemente hardcoded" — a folha "Níveis da
/// sua jornada" mostrava Iniciada, Adepta, Mestra, Guardiã para todo mundo.
///
/// A escolha existia desde sempre e só chegava aos PROMPTS de IA e à saudação
/// do Seu Dia; o resto das telas trazia a marcação de gênero congelada dentro
/// da própria tradução, onde nenhuma preferência alcança.
void main() {
  final pt = lookupAppLocalizations(const Locale('pt', 'BR'));
  final es = lookupAppLocalizations(const Locale('es'));
  final en = lookupAppLocalizations(const Locale('en'));

  setUp(() => ContentLocale.instance.setLocale(const Locale('pt', 'BR')));
  tearDown(() => TratamentoAtual.instance.definir(Gender.feminine));

  group('títulos de nível do Grimório Vivo', () {
    // Índices da escada: 0 Aprendiz, 1 Iniciada, 2 Praticante, 3 Adepta,
    // 4 Mestra, 5 Guardiã.
    List<String> titulos(Gender tratamento) {
      TratamentoAtual.instance.definir(tratamento);
      return LearningProvider.levels.map((n) => n.title).toList();
    }

    test('1. o feminino é o que sempre foi — ninguém perde a voz de casa', () {
      expect(titulos(Gender.feminine), [
        'Aprendiz',
        'Iniciada',
        'Praticante',
        'Adepta',
        'Mestra',
        'Guardiã do Grimório',
      ]);
    });

    test('2. quem escolheu masculino lê a escada no masculino', () {
      expect(titulos(Gender.masculine), [
        'Aprendiz',
        'Iniciado',
        'Praticante',
        'Adepto',
        'Mestre',
        'Guardião do Grimório',
      ]);
    });

    test('3. no neutro a escada não marca gênero em degrau nenhum', () {
      // Epicenos de verdade (-ante/-ente, "guarda"), não masculino genérico:
      // é a mesma escolha do `witchTreatmentNeutral` ("Alma mágica").
      expect(titulos(Gender.neutral), [
        'Aprendiz',
        'Iniciante',
        'Praticante',
        'Oficiante',
        'Regente',
        'Guarda do Grimório',
      ]);
    });

    test('4. os limiares de XP não se mexem com o tratamento', () {
      final limiares = [0, 100, 300, 600, 1000, 1500];
      for (final tratamento in Gender.values) {
        TratamentoAtual.instance.definir(tratamento);
        expect(LearningProvider.levels.map((n) => n.minXp).toList(), limiares,
            reason: 'o nível é o mesmo; só o nome dele muda');
      }
    });
  });

  group('vocativo interpolado', () {
    test('5. o chamamento entra na frase inteira, sem triplicá-la', () {
      expect(vocativoDe(pt, Gender.feminine), 'Bruxa');
      expect(vocativoDe(pt, Gender.masculine), 'Bruxo');
      expect(vocativoDe(pt, Gender.neutral), 'Alma mágica');

      expect(pt.authCaptchaTitle('Bruxo'), 'Só um instante, Bruxo');
      expect(pt.salemTourStep1('Bruxo'), contains('Bruxo. Vem comigo!'));
      expect(pt.salemTourStep6('Bruxo'), contains('magia, Bruxo'));
    });
  });

  group('as frases que concordam por inteiro', () {
    test('6. português: as três variantes existem e são distintas', () {
      expect(pt.authWelcomeBackFeminine, 'Bem-vinda de volta!');
      expect(pt.authWelcomeBackMasculine, 'Bem-vindo de volta!');
      expect(pt.profileAnonymousMasculine, 'Bruxo Anônimo');
      expect(pt.diaryGratitudeLabelMasculine, 'Pelo que você é grato hoje?');
      expect(pt.diaryGratitudeLabelFeminine, 'Pelo que você é grata hoje?',
          reason: 'o "grato(a)" de parêntese morreu aqui');
      expect(pt.yourDayGratitudeHintNeutral, isNot(contains('grata')));
      expect(pt.conviteAlemFeiticosMasculine, endsWith('sozinho'));
    });

    test('7. espanhol marca gênero e também foi atendido', () {
      expect(es.authWelcomeBackMasculine, '¡Bienvenido de nuevo!');
      expect(es.learnLevelMasterMasculine, 'Maestro');
      expect(es.diaryGratitudeLabelMasculine, contains('agradecido'));
    });

    test('8. inglês não marca: as três variantes são a MESMA frase', () {
      expect(en.authWelcomeBackFeminine, en.authWelcomeBackMasculine);
      expect(en.learnLevelMasterFeminine, en.learnLevelMasterNeutral);
      expect(en.diaryGratitudeLabelFeminine, en.diaryGratitudeLabelMasculine);
    });
  });

  group('catraca: nenhuma frase nova pode nascer só no feminino', () {
    // Um gate, e não uma inspeção manual: a marcação de gênero volta a
    // aparecer toda vez que alguém escreve uma frase nova em português — foi
    // exatamente assim que estas dezoito chegaram até a tela da dona.
    //
    // Só palavras que se dirigem A PESSOA. Concordância com substantivo
    // feminino ("a página pronta", "a palma aberta", "uma só geração") é
    // correta e fica de fora; onde o casamento é ambíguo, a chave entra em
    // [perdoadas] com o motivo.
    const perdoadas = <String, String>{
      // "uma verificação rápida ... quase sempre passa sozinha": concorda
      // com a verificação, não com quem espera.
      'authCaptchaSubtitle': 'sozinha = a verificação',
      // "Ningún usuario con sesión iniciada" / "Sesión iniciada".
      'authErrNoUser': 'iniciada = a sessão',
      'authPopupDoneTitle': 'iniciada = a sessão',
      // "en una sola generación" / "los mismos datos ... una sola vez".
      'cycleReadingChartBody': 'sola = uma única',
      'profileLegacyRewriteBody': 'sola = uma única',
    };

    const marcas = <String, String>{
      'app_pt_BR.arb':
          r'\b(bem-?vinda|bruxa|grata|sozinha|iniciada|adepta|mestra|guardiã)\b',
      'app_pt.arb':
          r'\b(bem-?vinda|bruxa|grata|sozinha|iniciada|adepta|mestra|guardiã)\b',
      'app_es.arb':
          r'\b(bienvenida|bruja|agradecida|sola|iniciada|adepta|maestra|guardiana)\b',
    };

    for (final entrada in marcas.entries) {
      test('9. ${entrada.key} não tem frase presa no feminino', () {
        final arb = jsonDecode(
          File('lib/l10n/${entrada.key}').readAsStringSync(),
        ) as Map<String, dynamic>;
        final marca = RegExp(entrada.value, caseSensitive: false);

        final presas = <String>[];
        arb.forEach((chave, valor) {
          if (chave.startsWith('@') || valor is! String) return;
          // As variantes `...Feminine` SÃO o feminino, e `witchTreatment*`
          // é o próprio chamamento: as duas famílias são a solução.
          if (chave.endsWith('Feminine')) return;
          if (perdoadas.containsKey(chave)) return;
          final achado = marca.firstMatch(valor);
          if (achado != null) presas.add('$chave → "${achado.group(0)}"');
        });

        expect(presas, isEmpty,
            reason: 'escreva as três variantes (...Feminine/...Masculine/'
                '...Neutral) e escolha com GenderText.select, ou deixe só o '
                'vocativo marcado com {tratamento}');
      });
    }
  });
}
