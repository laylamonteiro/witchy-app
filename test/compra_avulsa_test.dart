import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/config/revenuecat_config.dart';
import 'package:grimorio_de_bolso/core/services/payment_service.dart';
import 'package:grimorio_de_bolso/features/cycle_reading/data/compra_pendente_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Os dois lados da compra avulsa que custavam dinheiro de verdade.
///
/// 1. O ENTITLEMENT. `isLifetime` documentava o risco de um consumível ligado
///    a entitlement por engano no painel e se defendia sozinho; `isPro` era um
///    `containsKey` sem guarda nenhuma — e é o `isPro` que alimenta o app
///    inteiro e faz o auth_provider gravar role=premium e persistir. Uma
///    leitura de R$ 4,90 viraria Premium vitalício.
///
/// 2. O CRÉDITO. Entre a cobrança aprovada e a gravação do crédito havia duas
///    idas ao banco sem `catch`. Se qualquer uma estourasse, a pessoa pagava e
///    o app nunca mais sabia: consumível não gera entitlement e o
///    `restorePurchases` só responde por assinatura. O registro de compra
///    pendente é a única rede que existe — se ele falhar, o dinheiro some.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('guarda do entitlement Pro', () {
    test('consumível da Leitura do Ciclo nunca vale como Premium', () {
      for (final id in RevenueCatConfig.cycleReadingProductIds) {
        expect(
          PaymentService.entitlementValeComoPro(id),
          isFalse,
          reason: '$id é consumível: concederia Pro sem data de expiração',
        );
      }
    });

    test('os planos de assinatura continuam valendo', () {
      for (final id in const ['monthly', 'yearly', 'lifetime']) {
        expect(PaymentService.entitlementValeComoPro(id), isTrue);
      }
    });

    test('a lista de consumíveis não pode estar vazia', () {
      // Modo de falha silenciosa da guarda: com o conjunto vazio ela aprova
      // tudo e ninguém percebe, porque nada quebra — só volta a valer
      // dinheiro errado.
      expect(RevenueCatConfig.cycleReadingProductIds, isNotEmpty);
      expect(
        RevenueCatConfig.cycleReadingProductIds,
        containsAll([
          RevenueCatConfig.cycleReadingMonthProductId,
          RevenueCatConfig.cycleReadingWeekProductId,
        ]),
      );
    });
  });

  group('registro da compra pendente', () {
    late CompraPendenteStore store;

    CompraPendente compraDe(String userId) => CompraPendente(
          userId: userId,
          productId: RevenueCatConfig.cycleReadingMonthProductId,
          periodType: 'lunation',
          periodStart: DateTime.utc(2026, 8, 1),
          periodEnd: DateTime.utc(2026, 8, 30),
        );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      store = CompraPendenteStore();
    });

    test('sobrevive para ser recuperada, com a janela paga inteira', () async {
      await store.registrar(compraDe('bruxa-1'));

      final recuperada = await store.pendenteDe('bruxa-1');

      expect(recuperada, isNotNull);
      // A janela precisa voltar EXATA: é ela que diz o que foi comprado.
      // Creditar outro período entregaria uma leitura que ninguém pediu.
      expect(recuperada!.periodStart, DateTime.utc(2026, 8, 1));
      expect(recuperada.periodEnd, DateTime.utc(2026, 8, 30));
      expect(recuperada.periodType, 'lunation');
      expect(
        recuperada.productId,
        RevenueCatConfig.cycleReadingMonthProductId,
      );
    });

    test('não entrega o crédito de uma pessoa para outra', () async {
      // O registro sobrevive à troca de conta no mesmo aparelho.
      await store.registrar(compraDe('bruxa-1'));

      expect(await store.pendenteDe('bruxa-2'), isNull);
      expect(await store.pendenteDe('bruxa-1'), isNotNull);
    });

    test('some só depois que o crédito existe', () async {
      await store.registrar(compraDe('bruxa-1'));
      await store.limpar();

      expect(await store.pendenteDe('bruxa-1'), isNull);
    });

    test('registro ilegível é descartado, não fica tentando para sempre',
        () async {
      // Gravado pela API pública, e não semeado no mock: assim o teste não
      // depende do prefixo interno que o SharedPreferences usa no disco.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'cycle_reading_compra_pendente', '{"user_id":"bruxa-1"}');

      expect(await store.pendenteDe('bruxa-1'), isNull);
      // E some do disco: senão toda abertura da tela tentaria de novo.
      expect(prefs.getString('cycle_reading_compra_pendente'), isNull);
    });

    test('JSON corrompido não derruba a tela', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cycle_reading_compra_pendente', 'nao e json');

      expect(await store.pendenteDe('bruxa-1'), isNull);
    });

    test('o que é gravado é o que é lido', () async {
      final compra = compraDe('bruxa-1');
      final json = jsonDecode(jsonEncode(compra.toJson()));

      final volta = CompraPendente.fromJson(json as Map<String, dynamic>);

      expect(volta, isNotNull);
      expect(volta!.userId, compra.userId);
      expect(volta.productId, compra.productId);
      expect(volta.periodStart, compra.periodStart);
      expect(volta.periodEnd, compra.periodEnd);
    });
  });
}
