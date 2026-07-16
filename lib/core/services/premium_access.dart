import 'payment_service.dart';

/// Fonte ÚNICA de verdade para acesso Premium, acessível de qualquer camada
/// (widgets, providers e serviços sem BuildContext).
///
/// Combina os dois caminhos que concedem Premium no app:
/// - Assinatura ativa no RevenueCat (`PaymentService.isPro`)
/// - Premium local: role premium/admin ou plano lifetime (Código Premium,
///   simulação de plano pelo admin)
///
/// O estado local é mantido atualizado pelo `AuthProvider` a cada mudança de
/// usuário (ver `AuthProvider.notifyListeners`). Serviços como sync devem usar
/// `PremiumAccess.instance.isPremium` em vez de `PaymentService().isPro`;
/// widgets devem preferir `AuthProvider.isPremiumEffective`.
class PremiumAccess {
  PremiumAccess._();

  static final PremiumAccess instance = PremiumAccess._();

  bool _localPremium = false;

  /// Atualiza o componente local do status Premium (chamado pelo AuthProvider).
  void updateLocalPremium(bool value) {
    _localPremium = value;
  }

  /// True se o usuário tem acesso Premium por qualquer caminho.
  bool get isPremium => PaymentService().isPro || _localPremium;
}
