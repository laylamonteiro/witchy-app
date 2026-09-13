import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/motion/mist_typewriter.dart';
import 'package:grimorio_de_bolso/features/grimoire/presentation/widgets/advisor_feature_links.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// O caminho de volta do prompt do Conselheiro: um nome de funcionalidade
/// destacado na resposta vira um destino do app — se, e só se, o catálogo
/// no idioma ativo o reconhece.
void main() {
  final pt = lookupAppLocalizations(const Locale('pt', 'BR'));
  final en = lookupAppLocalizations(const Locale('en'));
  final es = lookupAppLocalizations(const Locale('es'));

  group('normalize', () {
    test('ignora caixa, acento, pontuação final e artigo inicial', () {
      const n = AdvisorFeatureCatalog.normalize;
      expect(n('Leitura de Runas.'), 'leitura de runas');
      expect(n('a Interpretação de Sonhos!'), 'interpretacao de sonhos');
      expect(n('  The   Nature Guide, '), 'nature guide');
      expect(n('El Péndulo'), 'pendulo');
      expect(n(''), '');
    });
  });

  group('AdvisorFeatureCatalog', () {
    test('casa os nomes da interface com os destinos', () {
      final catalog = AdvisorFeatureCatalog.of(pt);
      expect(catalog.match('Tarot')?.id, 'tarot');
      expect(catalog.match('leitura de runas.')?.id, 'runes');
      expect(catalog.match('a Interpretação de Sonhos')?.id, 'dreams');
      expect(catalog.match('Cristais')?.id, 'ency_crystals');
      expect(catalog.match('Gratidão')?.id, 'diary_gratitude');
      expect(catalog.match('Meus Registros')?.id, 'records');
      expect(catalog.match('Clima Mágico do dia')?.id, 'weather');
    });

    test('um nome que a interface não tem fica sem destino', () {
      final catalog = AdvisorFeatureCatalog.of(pt);
      expect(catalog.match('Tarô'), isNull);
      expect(catalog.match('Xablau'), isNull);
      expect(catalog.match(''), isNull);
    });

    test('o Conselheiro não sugere a si mesmo', () {
      for (final l10n in [pt, en, es]) {
        final ids = AdvisorFeatureCatalog.of(l10n).features.map((f) => f.id);
        expect(ids, isNot(contains('mystic_advisor')));
      }
    });

    test('nos três idiomas os nomes são únicos e não vazios', () {
      for (final l10n in [pt, en, es]) {
        final names = AdvisorFeatureCatalog.of(l10n)
            .features
            .map((f) => AdvisorFeatureCatalog.normalize(f.name))
            .toList();
        expect(names.every((n) => n.isNotEmpty), isTrue);
        expect(names.toSet().length, names.length,
            reason: 'dois destinos com o mesmo nome: $names');
      }
    });

    test('os rótulos em inglês e espanhol também casam', () {
      expect(AdvisorFeatureCatalog.of(en).match('Rune Reading')?.id, 'runes');
      expect(AdvisorFeatureCatalog.of(en).match('My Records')?.id, 'records');
      expect(AdvisorFeatureCatalog.of(es).match('Lectura de Manos')?.id,
          'palmistry');
      expect(AdvisorFeatureCatalog.of(es).match('Sueños')?.id, 'diary_dreams');
    });
  });

  group('resposta em trechos', () {
    test('parseAdvisorAnswer separa corpo e destaques', () {
      final parts = parseAdvisorAnswer('Try the **Tarot** tonight.');
      expect(parts.map((p) => p.texto).toList(),
          ['Try the ', 'Tarot', ' tonight.']);
      expect(parts.map((p) => p.realce).toList(), [false, true, false]);
    });

    test('stripAdvisorMarkers remove só os asteriscos duplos', () {
      expect(stripAdvisorMarkers('Try the **Tarot** tonight.'),
          'Try the Tarot tonight.');
      expect(stripAdvisorMarkers('sem marcação'), 'sem marcação');
    });
  });

  group('MistTypewriterText', () {
    test('snapToCodePoint não parte um emoji ao meio', () {
      const text = 'a🪄b';
      // 🪄 ocupa dois code units (índices 1 e 2). Cortar em 2 partiria o par.
      expect(MistTypewriterText.snapToCodePoint(text, 2), 1);
      expect(MistTypewriterText.snapToCodePoint(text, 3), 3);
      expect(MistTypewriterText.snapToCodePoint(text, 0), 0);
      expect(MistTypewriterText.snapToCodePoint(text, 9), text.length);
    });

    test('a duração segue o comprimento, com piso e teto', () {
      expect(MistTypewriterText.durationFor(10),
          const Duration(milliseconds: 600));
      expect(MistTypewriterText.durationFor(100),
          const Duration(milliseconds: 2200));
      expect(MistTypewriterText.durationFor(4000),
          MistTypewriterText.ceiling);
    });
  });
}
