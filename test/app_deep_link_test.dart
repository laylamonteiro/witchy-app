import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/navigation/app_deep_link.dart';

void main() {
  group('AppDeepLink', () {
    test('payloads são estáveis e fazem round-trip', () {
      expect(AppDeepLink.moonEncyclopedia.payload, 'encyclopedia/moon');
      expect(AppDeepLink.sabbatsEncyclopedia.payload, 'encyclopedia/sabbats');
      for (final link in AppDeepLink.values) {
        expect(AppDeepLink.fromPayload(link.payload), link);
      }
    });

    test('payload desconhecido/nulo é ignorado sem erro', () {
      expect(AppDeepLink.fromPayload(null), isNull);
      expect(AppDeepLink.fromPayload(''), isNull);
      expect(AppDeepLink.fromPayload('rota/inexistente'), isNull);
    });

    test('destinos apontam para a aba certa da Enciclopédia', () {
      expect(AppDeepLink.moonEncyclopedia.homeTab, 0);
      expect(AppDeepLink.moonEncyclopedia.encyclopediaTab, 0);
      expect(AppDeepLink.sabbatsEncyclopedia.homeTab, 0);
      expect(AppDeepLink.sabbatsEncyclopedia.encyclopediaTab, 1);
    });
  });

  group('DeepLinkService', () {
    tearDown(DeepLinkService.instance.consume);

    test('dispatchPayload publica o link e consume limpa', () {
      DeepLinkService.instance.dispatchPayload('encyclopedia/sabbats');
      expect(DeepLinkService.instance.pending.value,
          AppDeepLink.sabbatsEncyclopedia);
      DeepLinkService.instance.consume();
      expect(DeepLinkService.instance.pending.value, isNull);
    });

    test('payload desconhecido não sobrescreve estado', () {
      DeepLinkService.instance.dispatchPayload('encyclopedia/moon');
      DeepLinkService.instance.dispatchPayload('desconhecido');
      expect(
          DeepLinkService.instance.pending.value, AppDeepLink.moonEncyclopedia);
    });
  });
}
