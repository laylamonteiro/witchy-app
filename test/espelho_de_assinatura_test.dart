import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/services/payment_service.dart';

/// A trava central do "nunca perde o acesso enquanto o plano vigorar": o
/// downgrade para Free (no boot e no refresh) só acontece com SINAL POSITIVO
/// de que a assinatura não vale mais — RevenueCat consultado E negando. Uma
/// falha de carregamento (web/rede ruim) não pode virar "não é assinante" e
/// derrubar quem o servidor (espelho de `profiles`) já reconheceu como Premium.
void main() {
  bool rebaixa({
    required bool statusConhecido,
    required bool isPro,
    bool isLifetime = false,
    bool isAdmin = false,
  }) =>
      PaymentService.deveRebaixar(
        statusConhecido: statusConhecido,
        isPro: isPro,
        isLifetime: isLifetime,
        isAdmin: isAdmin,
      );

  group('deveRebaixar', () {
    test('status desconhecido NUNCA rebaixa (protege o assinante do espelho)',
        () {
      // O caso que importa: RevenueCat não carregou (isPro=false por falta de
      // resposta). O acesso concedido pelo servidor tem que sobreviver.
      expect(rebaixa(statusConhecido: false, isPro: false), isFalse);
      expect(rebaixa(statusConhecido: false, isPro: true), isFalse);
    });

    test('só rebaixa quando o RevenueCat confirma que não é mais Pro', () {
      expect(rebaixa(statusConhecido: true, isPro: false), isTrue);
    });

    test('Pro ativo não rebaixa', () {
      expect(rebaixa(statusConhecido: true, isPro: true), isFalse);
    });

    test('vitalício (Código Premium/compra) nunca é rebaixado', () {
      // RevenueCat não conhece o lifetime de Código Premium: isPro=false é
      // esperado e não pode derrubar o acesso.
      expect(
        rebaixa(statusConhecido: true, isPro: false, isLifetime: true),
        isFalse,
      );
    });

    test('admin nunca é rebaixado', () {
      expect(
        rebaixa(statusConhecido: true, isPro: false, isAdmin: true),
        isFalse,
      );
    });
  });
}
