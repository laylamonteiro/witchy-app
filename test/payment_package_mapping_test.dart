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

  /// O selo "Economize 50%" era texto fixo num ARB — uma conta com dois
  /// números que a tela não tinha na mão. Se a loja devolvesse outro preço,
  /// ou se a pessoa estivesse fora do Brasil, o selo mentia numa tela de
  /// venda. Agora ele sai dos preços reais, e some quando não dá para
  /// afirmar.
  group('economia do plano anual', () {
    int? economia(double mensal, double anual,
            {String moedaMensal = 'BRL', String moedaAnual = 'BRL'}) =>
        PaymentService.economiaEntre(
          mensal: mensal,
          anual: anual,
          moedaMensal: moedaMensal,
          moedaAnual: moedaAnual,
        );

    test('os preços de reserva dão os mesmos 50% que o texto fixo dizia', () {
      // R$ 19,90 x 12 = R$ 238,80 contra R$ 119,90.
      expect(economia(19.90, 119.90), 50);
    });

    test('acompanha o preço quando a loja muda', () {
      expect(economia(20.00, 180.00), 25);
      expect(economia(10.00, 60.00), 50);
    });

    test('moedas diferentes não se comparam', () {
      // Acontece de verdade quando o catálogo vem meio resolvido.
      expect(economia(19.90, 119.90, moedaAnual: 'USD'), isNull);
    });

    test('sem economia, sem selo', () {
      expect(economia(10.00, 120.00), isNull, reason: 'anual = 12 mensais');
      expect(economia(10.00, 200.00), isNull, reason: 'anual mais caro');
    });

    test('preço zerado ou negativo não vira porcentagem', () {
      expect(economia(0, 119.90), isNull);
      expect(economia(19.90, 0), isNull);
      expect(economia(-1, 119.90), isNull);
    });

    test('nada de 100%: seria dizer que o anual é de graça', () {
      expect(economia(1000.00, 0.01), isNull);
    });
  });
}
