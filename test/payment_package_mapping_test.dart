import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/services/payment_service.dart';

/// A web (RevenueCat Billing) entrega os pacotes como `PackageType.custom`:
/// sem esta dedução por identificador, todos seriam descartados — a tela
/// mostraria "planos indisponíveis" e o Vitalício nunca apareceria.
void main() {
  SubscriptionType? mapId(String raw) =>
      PaymentService.subscriptionTypeFromIdentifier(raw);

  group('subscriptionTypeFromIdentifier', () {
    test('reconhece as durações em inglês', () {
      expect(mapId('monthly'), SubscriptionType.monthly);
      expect(mapId('annual'), SubscriptionType.yearly);
      expect(mapId('yearly'), SubscriptionType.yearly);
      expect(mapId('lifetime'), SubscriptionType.lifetime);
    });

    test('reconhece as durações em português', () {
      expect(mapId('plano_mensal'), SubscriptionType.monthly);
      expect(mapId('plano_anual'), SubscriptionType.yearly);
      expect(mapId('vitalicio'), SubscriptionType.lifetime);
    });

    test('não confunde "plano" (contém "ano") com anual', () {
      // "plano_mensal" contém a substring "ano" (em "plano"): a dedução não
      // pode cair nessa armadilha e marcar como anual.
      expect(mapId('plano_mensal'), SubscriptionType.monthly);
      expect(mapId('meu_plano_mensal_web'), SubscriptionType.monthly);
    });

    test('casa com identificador do produto embutido', () {
      expect(mapId('rc_default grimorio_pro_lifetime'),
          SubscriptionType.lifetime);
      expect(mapId('web_pkg grimorio_pro_monthly'),
          SubscriptionType.monthly);
    });

    test('devolve null quando não há duração reconhecível', () {
      expect(mapId('custom'), isNull);
      expect(mapId('leitura_ciclo_semana'), isNull);
      expect(mapId(''), isNull);
    });
  });
}
