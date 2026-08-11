import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/navigation/app_deep_link.dart';
import 'package:grimorio_de_bolso/core/navigation/encyclopedia_section.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/data/models/guided_rituals_data.dart';

void main() {
  group('AppDeepLink', () {
    test('payloads são estáveis e fazem round-trip', () {
      expect(AppDeepLink.yourDay.payload, 'today');
      expect(AppDeepLink.grimoireIndex.payload, 'encyclopedia/index');
      expect(AppDeepLink.moonEncyclopedia.payload, 'encyclopedia/moon');
      expect(AppDeepLink.sunEncyclopedia.payload, 'encyclopedia/sun');
      expect(AppDeepLink.sabbatsEncyclopedia.payload, 'encyclopedia/sabbats');
      expect(AppDeepLink.guidedRitualSabbat.payload, 'ritual/sabbat');
      expect(AppDeepLink.guidedRitualFullMoon.payload, 'ritual/full_moon');
      expect(AppDeepLink.guidedRitualNewMoon.payload, 'ritual/new_moon');
      expect(AppDeepLink.guidedRitualSunWater.payload, 'ritual/sun_water');
      expect(AppDeepLink.dreamsDiary.payload, 'diary/dreams');
      for (final link in AppDeepLink.values) {
        expect(AppDeepLink.fromPayload(link.payload), link);
      }
    });

    test('payload desconhecido/nulo é ignorado sem erro', () {
      expect(AppDeepLink.fromPayload(null), isNull);
      expect(AppDeepLink.fromPayload(''), isNull);
      expect(AppDeepLink.fromPayload('rota/inexistente'), isNull);
    });

    test('destinos apontam para a seção/aba certa', () {
      // Bottom bar: 0 = Seu Dia, 1 = Grimório, 2 = Ferramentas, 3 = Diários.
      expect(AppDeepLink.yourDay.homeTab, 0);
      expect(AppDeepLink.yourDay.encyclopediaSection, isNull);
      expect(AppDeepLink.grimoireIndex.homeTab, 1);
      expect(AppDeepLink.grimoireIndex.encyclopediaSection,
          EncyclopediaSection.bookIndex);
      expect(AppDeepLink.moonEncyclopedia.homeTab, 1);
      expect(AppDeepLink.sunEncyclopedia.homeTab, 1);
      expect(AppDeepLink.sabbatsEncyclopedia.homeTab, 1);
      // Identidade por seção: reordenar abas nunca muda o destino.
      expect(AppDeepLink.moonEncyclopedia.encyclopediaSection,
          EncyclopediaSection.moon);
      expect(AppDeepLink.sunEncyclopedia.encyclopediaSection,
          EncyclopediaSection.sun);
      expect(AppDeepLink.sabbatsEncyclopedia.encyclopediaSection,
          EncyclopediaSection.sabbats);
      expect(AppDeepLink.guidedRitualSabbat.encyclopediaSection,
          EncyclopediaSection.sabbats);
      expect(AppDeepLink.guidedRitualFullMoon.encyclopediaSection,
          EncyclopediaSection.moon);
      expect(AppDeepLink.guidedRitualNewMoon.encyclopediaSection,
          EncyclopediaSection.moon);
      expect(AppDeepLink.guidedRitualSunWater.encyclopediaSection,
          EncyclopediaSection.sun);
      // O índice numérico da aba deriva da ordem canônica do enum.
      for (final link in AppDeepLink.values) {
        expect(link.encyclopediaTab, link.encyclopediaSection?.index,
            reason: link.name);
      }
      // Diários → aba Sonhos (Gratidão 0, Afirmações 1, Escrita 2, Sonhos 3).
      expect(AppDeepLink.dreamsDiary.homeTab, 3);
      expect(AppDeepLink.dreamsDiary.diaryTab, 3);
      expect(AppDeepLink.dreamsDiary.encyclopediaSection, isNull);
      expect(AppDeepLink.moonEncyclopedia.diaryTab, isNull);
    });

    test('destinos de ritual carregam o ritualId certo', () {
      expect(AppDeepLink.guidedRitualFullMoon.ritualId, 'full_moon');
      expect(AppDeepLink.guidedRitualNewMoon.ritualId, 'new_moon');
      expect(AppDeepLink.guidedRitualSunWater.ritualId, 'sun_water');
      expect(AppDeepLink.guidedRitualSabbat.ritualId, isNull);
      expect(AppDeepLink.guidedRitualSabbat.isGuidedRitual, isTrue);
      expect(AppDeepLink.moonEncyclopedia.isGuidedRitual, isFalse);
    });
  });

  group('PendingDeepLink.parse', () {
    test('payload com argumento resolve link + arg', () {
      final parsed = PendingDeepLink.parse('ritual/sabbat/imbolc');
      expect(parsed, isNotNull);
      expect(parsed!.link, AppDeepLink.guidedRitualSabbat);
      expect(parsed.arg, 'imbolc');
    });

    test('todo sabbat emitido pelo agendador resolve um ritual válido', () {
      for (final ritual in AllGuidedRituals.all.where((r) => r.sabbat != null)) {
        final sabbatArg = ritual.sabbat!.name.toLowerCase();
        final parsed = PendingDeepLink.parse('ritual/sabbat/$sabbatArg');
        expect(parsed?.arg, sabbatArg);
        expect(AllGuidedRituals.byId('sabbat_${parsed!.arg}'), isNotNull,
            reason: sabbatArg);
      }
    });

    test('argumento inválido resolve o link, mas não um ritual', () {
      final parsed = PendingDeepLink.parse('ritual/sabbat/naoexiste');
      expect(parsed?.link, AppDeepLink.guidedRitualSabbat);
      expect(AllGuidedRituals.byId('sabbat_${parsed!.arg}'), isNull);
    });

    test('payload sem argumento não tem arg', () {
      final parsed = PendingDeepLink.parse('ritual/full_moon');
      expect(parsed?.link, AppDeepLink.guidedRitualFullMoon);
      expect(parsed?.arg, isNull);
    });
  });

  group('DeepLinkService', () {
    tearDown(DeepLinkService.instance.consume);

    test('dispatchPayload publica o link e consume limpa', () {
      DeepLinkService.instance.dispatchPayload('encyclopedia/sabbats');
      expect(DeepLinkService.instance.pending.value,
          const PendingDeepLink(AppDeepLink.sabbatsEncyclopedia));
      DeepLinkService.instance.consume();
      expect(DeepLinkService.instance.pending.value, isNull);
    });

    test('dispatchPayload com argumento preserva o arg', () {
      DeepLinkService.instance.dispatchPayload('ritual/sabbat/beltane');
      expect(
          DeepLinkService.instance.pending.value,
          const PendingDeepLink(AppDeepLink.guidedRitualSabbat,
              arg: 'beltane'));
    });

    test('payload desconhecido não sobrescreve estado', () {
      DeepLinkService.instance.dispatchPayload('encyclopedia/moon');
      DeepLinkService.instance.dispatchPayload('desconhecido');
      expect(DeepLinkService.instance.pending.value,
          const PendingDeepLink(AppDeepLink.moonEncyclopedia));
    });
  });
}
