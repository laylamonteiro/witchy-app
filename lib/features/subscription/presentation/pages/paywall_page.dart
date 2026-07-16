import 'package:flutter/material.dart';

import '../../../../core/services/payment_service.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';

/// Ponto único de entrada para a oferta Premium do aplicativo.
class PaywallPage extends StatelessWidget {
  final bool displayCloseButton;
  final VoidCallback? onDismiss;

  const PaywallPage({
    super.key,
    this.displayCloseButton = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF090A12),
      body: SafeArea(child: PremiumUpgradeSheet()),
    );
  }

  static Future<void> showAsModal(BuildContext context) {
    return present(context);
  }

  static Future<void> present(BuildContext context) {
    return showPremiumUpgradePaywall(context);
  }

  static Future<void> presentIfNeeded(BuildContext context) async {
    if (PaymentService().isPro) return;
    await present(context);
  }
}

/// Compatibilidade para chamadas antigas: abre o mesmo paywall modal,
/// sem incorporar uma segunda implementação na árvore.
class PaywallWidget extends StatelessWidget {
  final VoidCallback? onPurchaseCompleted;
  final VoidCallback? onDismiss;

  const PaywallWidget({
    super.key,
    this.onPurchaseCompleted,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await PaywallPage.present(context);
          onDismiss?.call();
          if (PaymentService().isPro) onPurchaseCompleted?.call();
        },
        child: const Text('Desbloquear Premium'),
      ),
    );
  }
}
