import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/diary/data/data_sources/dream_themes_data_en.dart';
import 'package:grimorio_de_bolso/features/diary/data/data_sources/dream_themes_data_es.dart';
import 'package:grimorio_de_bolso/features/diary/data/data_sources/dream_themes_data_pt.dart';

/// Garante que as variantes pt/en/es dos temas de sonhos têm o mesmo número de
/// itens, os mesmos ids/emojis e a mesma ordem — a tradução nunca pode alterar
/// identidade nem estrutura do conteúdo.
void main() {
  group('Temas de sonhos', () {
    test('as três línguas têm 20 temas com os mesmos ids e emojis na mesma ordem',
        () {
      expect(dreamThemesPt.length, 20);
      expect(dreamThemesEn.length, dreamThemesPt.length);
      expect(dreamThemesEs.length, dreamThemesPt.length);

      for (var i = 0; i < dreamThemesPt.length; i++) {
        // Ids e emojis são invariantes entre idiomas.
        expect(dreamThemesEn[i].id, dreamThemesPt[i].id);
        expect(dreamThemesEs[i].id, dreamThemesPt[i].id);
        expect(dreamThemesEn[i].emoji, dreamThemesPt[i].emoji);
        expect(dreamThemesEs[i].emoji, dreamThemesPt[i].emoji);
      }
    });

    test('os ids são únicos', () {
      final ids = dreamThemesPt.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('todos os temas têm campos não vazios e o mesmo número de leituras',
        () {
      for (var i = 0; i < dreamThemesPt.length; i++) {
        for (final theme in [
          dreamThemesPt[i],
          dreamThemesEn[i],
          dreamThemesEs[i],
        ]) {
          expect(theme.title.trim(), isNotEmpty, reason: theme.id);
          expect(theme.summary.trim(), isNotEmpty, reason: theme.id);
          expect(theme.reflection.trim(), isNotEmpty, reason: theme.id);
          expect(theme.readings, isNotEmpty, reason: theme.id);
          expect(theme.readings.length, dreamThemesPt[i].readings.length,
              reason: theme.id);
          for (final reading in theme.readings) {
            expect(reading.title.trim(), isNotEmpty, reason: theme.id);
            expect(reading.content.trim(), isNotEmpty, reason: theme.id);
          }
        }
      }
    });
  });
}
