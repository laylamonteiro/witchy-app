import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/data_sources/blood_lore_content.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/data_sources/blood_lore_content_en.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/data_sources/blood_lore_content_es.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/data_sources/blood_lore_content_pt.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_shortcut.dart';

/// A fronteira editorial dos "Saberes do Sangue".
///
/// A área fala de história da magia, de tradições específicas e de práticas
/// com o próprio sangue. Três coisas não podem escorregar numa revisão
/// futura, e é isto que este arquivo guarda:
///
/// * **paridade**: traduzir nunca muda identidade nem estrutura. Os mesmos
///   ids, na mesma ordem, com a mesma área, a mesma etiqueta e o mesmo
///   emblema nos três idiomas;
/// * **história não vira tutorial**: o filtro amoroso é contado e nunca
///   ensinado, e nenhum passo de nenhuma prática põe sangue em comida ou
///   bebida de alguém;
/// * **místico não vira fisiologia**: a Lua é correspondência, não causa, e
///   nada aqui afirma o que o corpo dela faz.
void main() {
  tearDown(() => ContentLocale.instance.setLocale(const Locale('pt', 'BR')));

  final idiomas = {
    'pt': bloodLoreContentPt,
    'en': bloodLoreContentEn,
    'es': bloodLoreContentEs,
  };

  /// Todo texto visível de um idioma, para as varreduras de vocabulário.
  List<String> textosDe(BloodLoreContent content) => [
        content.pageTitle,
        content.intro,
        content.introNote,
        ...content.categoryTitles.values,
        ...content.categorySubtitles.values,
        ...content.tagLabels.values,
        content.safetyNote,
        content.classificationLabel,
        content.practiceIntentionLabel,
        content.practiceMaterialsLabel,
        content.practiceStepsLabel,
        content.practiceWithoutBloodLabel,
        content.entriesCountTemplate,
        content.cycleCta,
        content.momentTitle,
        content.momentIntro,
        for (final shortcut in content.shortcuts.values) ...[
          shortcut.title,
          shortcut.body,
          if (shortcut.prompt != null) shortcut.prompt!,
        ],
        ...content.moonCorrespondences.values,
        content.correspondenceTemplate,
        content.startUnderTemplate,
        content.phaseTallyTemplate,
        content.moonNotSynced,
        content.closingCorrespondence,
        for (final entry in content.entries) ...[
          entry.title,
          entry.summary,
          if (entry.intention != null) entry.intention!,
          ...entry.materials,
          ...entry.steps,
          if (entry.withoutBlood != null) entry.withoutBlood!,
          for (final section in entry.sections) ...[section.title, section.body],
          if (entry.cta != null) entry.cta!.label,
        ],
      ];

  group('Paridade', () {
    test('os três idiomas têm os mesmos verbetes, na mesma ordem', () {
      for (final entry in idiomas.entries) {
        final content = entry.value;
        expect(content.entries.length, bloodLoreContentPt.entries.length,
            reason: entry.key);
        for (var i = 0; i < content.entries.length; i++) {
          final aqui = content.entries[i];
          final base = bloodLoreContentPt.entries[i];
          // Identidade, taxonomia e emblema são invariantes: traduzir muda
          // texto, nunca estrutura.
          expect(aqui.id, base.id, reason: entry.key);
          expect(aqui.category, base.category, reason: '${entry.key}/${base.id}');
          expect(aqui.tag, base.tag, reason: '${entry.key}/${base.id}');
          expect(aqui.emoji, base.emoji, reason: '${entry.key}/${base.id}');
          expect(aqui.mentionsBlood, base.mentionsBlood,
              reason: '${entry.key}/${base.id}');
          expect(aqui.isPractice, base.isPractice,
              reason: '${entry.key}/${base.id}');
          expect(aqui.steps.length, base.steps.length,
              reason: '${entry.key}/${base.id}');
          expect(aqui.materials.length, base.materials.length,
              reason: '${entry.key}/${base.id}');
          expect(aqui.sections.length, base.sections.length,
              reason: '${entry.key}/${base.id}');
          expect(aqui.withoutBlood == null, base.withoutBlood == null,
              reason: '${entry.key}/${base.id}');
          expect(aqui.intention == null, base.intention == null,
              reason: '${entry.key}/${base.id}');
          expect(aqui.cta?.link, base.cta?.link, reason: '${entry.key}/${base.id}');
          expect(aqui.cta?.entryId, base.cta?.entryId,
              reason: '${entry.key}/${base.id}');
        }
      }
    });

    test('nenhuma chave de tela, área, etiqueta ou atalho fica sem tradução',
        () {
      for (final entry in idiomas.entries) {
        final content = entry.value;
        expect(content.categoryTitles.keys.toSet(),
            BloodLoreCategory.values.toSet(),
            reason: entry.key);
        expect(content.categorySubtitles.keys.toSet(),
            BloodLoreCategory.values.toSet(),
            reason: entry.key);
        expect(content.tagLabels.keys.toSet(), BloodLoreTag.values.toSet(),
            reason: entry.key);
        expect(content.shortcuts.keys.toSet(), MenstrualShortcut.values.toSet(),
            reason: entry.key);
        expect(content.moonCorrespondences.keys.toSet(), MoonPhase.values.toSet(),
            reason: entry.key);
      }
    });

    test('nenhum texto vem vazio', () {
      for (final entry in idiomas.entries) {
        for (final texto in textosDe(entry.value)) {
          expect(texto.trim(), isNotEmpty, reason: entry.key);
        }
      }
    });

    test('os modelos de frase carregam os marcadores que a tela preenche', () {
      for (final entry in idiomas.entries) {
        final content = entry.value;
        expect(content.entriesCountTemplate, contains('{count}'),
            reason: entry.key);
        expect(content.startUnderTemplate, contains('{phase}'),
            reason: entry.key);
        expect(content.correspondenceTemplate, contains('{phase}'),
            reason: entry.key);
        expect(content.correspondenceTemplate, contains('{meaning}'),
            reason: entry.key);
        expect(content.phaseTallyTemplate, contains('{count}'),
            reason: entry.key);
        expect(content.phaseTallyTemplate, contains('{total}'),
            reason: entry.key);
        expect(content.phaseTallyTemplate, contains('{phase}'),
            reason: entry.key);
        expect(content.closingCorrespondence, contains('{phase}'),
            reason: entry.key);
      }
    });

    test('todo convite para um verbete aponta para um verbete que existe', () {
      for (final entry in idiomas.entries) {
        final content = entry.value;
        for (final verbete in content.entries) {
          final cta = verbete.cta;
          if (cta == null || cta.link != BloodLoreLink.entry) continue;
          expect(cta.entryId, isNotNull, reason: '${entry.key}/${verbete.id}');
          expect(content.byId(cta.entryId!), isNotNull,
              reason: '${entry.key}/${verbete.id} → ${cta.entryId}');
        }
      }
    });

    test('as quatro áreas existem e nenhuma fica vazia', () {
      for (final entry in idiomas.entries) {
        for (final category in BloodLoreCategory.values) {
          expect(entry.value.of(category), isNotEmpty,
              reason: '${entry.key}/${category.name}');
        }
      }
    });
  });

  group('História não vira tutorial', () {
    test('o filtro amoroso é contado, e nunca tem passo a passo', () {
      for (final entry in idiomas.entries) {
        final filtro = entry.value.byId('filtro-de-sangue');
        expect(filtro, isNotNull, reason: entry.key);
        expect(filtro!.steps, isEmpty,
            reason: '${entry.key}: descrever o que a história registrou é uma '
                'coisa; dar o passo a passo é outra');
        expect(filtro.materials, isEmpty, reason: entry.key);
        expect(filtro.tag, BloodLoreTag.documented, reason: entry.key);
        // E ele oferece a alternativa segura em vez de deixar a pessoa no
        // vazio.
        expect(filtro.cta?.entryId, 'encanto-de-atracao', reason: entry.key);
      }
    });

    test('nenhum passo de nenhuma prática põe sangue em comida ou bebida', () {
      final comidaOuBebida = RegExp(
        r'comida|bebida|aliment|comer|beber|food|drink|beverage|eat\b',
        caseSensitive: false,
      );
      for (final entry in idiomas.entries) {
        for (final verbete in entry.value.entries) {
          for (final passo in verbete.steps) {
            expect(comidaOuBebida.hasMatch(passo), isFalse,
                reason: '${entry.key}/${verbete.id}: $passo');
          }
        }
      }
    });

    test('toda prática que fala de sangue oferece a versão sem ele', () {
      for (final entry in idiomas.entries) {
        for (final verbete in entry.value.entries) {
          if (!verbete.isPractice || !verbete.mentionsBlood) continue;
          expect(verbete.withoutBlood?.trim(), isNotEmpty,
              reason: '${entry.key}/${verbete.id}: nenhuma prática do '
                  'Grimório exige sangue');
        }
      }
    });

    test('a nota de segurança diz as quatro coisas que ela precisa dizer', () {
      // Só o seu sangue; não compartilhar; não em comida nem bebida; nada
      // que fira. E em nenhum lugar um convite a se cortar.
      const esperado = {
        'pt': ['seu próprio sangue', 'compartilhe', 'alimentos ou bebidas', 'ferir'],
        'en': ['your own menstrual blood', 'share', 'food or drink', 'injure'],
        'es': ['tu propia sangre', 'compartas', 'alimentos ni bebidas', 'herirte'],
      };
      for (final entry in idiomas.entries) {
        for (final pedaco in esperado[entry.key]!) {
          expect(entry.value.safetyNote.toLowerCase(),
              contains(pedaco.toLowerCase()),
              reason: entry.key);
        }
      }
    });

    test('nada aqui convida a se cortar para obter sangue', () {
      // Com fronteira de palavra: sem ela, "uma frase corta" viraria um
      // convite a se cortar.
      final corte = RegExp(
        r'\bse cortar\b|\bse corte\b|\bte cortes\b|\bcortarse\b|'
        r'cut yourself|\bfurar\b|\bprick\b|\bagulha\b|\bneedle\b|'
        r'\baguja\b|\blâmina\b|\bblade\b',
        caseSensitive: false,
      );
      for (final entry in idiomas.entries) {
        for (final texto in textosDe(entry.value)) {
          // A nota de segurança pode NOMEAR o que não se faz; o resto, não.
          if (texto == entry.value.safetyNote) continue;
          expect(corte.hasMatch(texto), isFalse,
              reason: '${entry.key}: $texto');
        }
      }
    });
  });

  group('Místico não vira fisiologia', () {
    test('nenhuma afirmação de corpo, de ciência ou de dever', () {
      final pseudo = RegExp(
        r'cortisol|hormon|hormôn|hormón|cientific|científic|scientif|'
        r'mais intuitiva|more intuitive|más intuitiva|você deve\b|'
        r'you must\b|debes\b|seu corpo está pedindo|your body is asking|'
        r'tu cuerpo está pidiendo',
        caseSensitive: false,
      );
      for (final entry in idiomas.entries) {
        for (final texto in textosDe(entry.value)) {
          expect(pseudo.hasMatch(texto), isFalse, reason: '${entry.key}: $texto');
        }
      }
    });

    test('a Lua nunca manda no sangue', () {
      final causa = RegExp(
        r'a lua (regula|controla|comanda|dita)|'
        r'the moon (regulates|controls|dictates|governs)|'
        r'la luna (regula|controla|dicta)',
        caseSensitive: false,
      );
      for (final entry in idiomas.entries) {
        for (final texto in textosDe(entry.value)) {
          expect(causa.hasMatch(texto), isFalse, reason: '${entry.key}: $texto');
        }
      }
    });

    test('a frase que separa as duas rodas está escrita e é uma negativa', () {
      const negativa = {
        'pt': 'não precisam estar sincronizados',
        'en': 'do not need to be in step',
        'es': 'no necesitan estar sincronizados',
      };
      for (final entry in idiomas.entries) {
        expect(entry.value.moonNotSynced.toLowerCase(),
            contains(negativa[entry.key]!.toLowerCase()),
            reason: entry.key);
      }
    });

    test('as categorias de Lua contemporâneas existem como leitura recente, '
        'e não como base da funcionalidade', () {
      for (final entry in idiomas.entries) {
        final verbete = entry.value.byId('interpretacoes-contemporaneas');
        expect(verbete, isNotNull, reason: entry.key);
        expect(verbete!.tag, BloodLoreTag.contemporary, reason: entry.key);
        expect(verbete.category, BloodLoreCategory.cycleAndMoon,
            reason: entry.key);
      }
    });

    test('a ambivalência não é apagada por "antigamente era sagrado"', () {
      for (final entry in idiomas.entries) {
        final verbete = entry.value.byId('ambivalencia');
        expect(verbete, isNotNull, reason: entry.key);
        expect(verbete!.tag, BloodLoreTag.documented, reason: entry.key);
        // A frase aparece — entre aspas, para ser desmontada.
        final corpo = verbete.sections.map((s) => s.body).join(' ');
        expect(corpo, contains('"'), reason: entry.key);
      }
    });
  });

  test('o seletor de idioma entrega o conteúdo certo', () {
    ContentLocale.instance.setLocale(const Locale('en'));
    expect(bloodLoreContent.pageTitle, bloodLoreContentEn.pageTitle);
    ContentLocale.instance.setLocale(const Locale('es'));
    expect(bloodLoreContent.pageTitle, bloodLoreContentEs.pageTitle);
    // pt_BR cai no pt, como em toda a camada de conteúdo.
    ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
    expect(bloodLoreContent.pageTitle, bloodLoreContentPt.pageTitle);
  });
}
