import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Página de Paywall usando RevenueCat UI
///
/// Pode ser apresentada como:
/// - Página navegável (Navigator.push)
/// - Modal (showModalBottomSheet)
/// - Inline (PaywallView widget)
///
/// Documentação: https://www.revenuecat.com/docs/tools/paywalls
class PaywallPage extends StatelessWidget {
  /// Se true, mostra botão de fechar
  final bool displayCloseButton;

  /// Callback quando o paywall é fechado
  final VoidCallback? onDismiss;

  const PaywallPage({
    super.key,
    this.displayCloseButton = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PaywallView(
        displayCloseButton: displayCloseButton,
        onDismiss: () {
          if (onDismiss != null) {
            onDismiss!();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  /// Apresenta o paywall como modal fullscreen
  static Future<PaywallResult?> showAsModal(BuildContext context) async {
    return Navigator.of(context).push<PaywallResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => PaywallPage(
          onDismiss: () => Navigator.of(context).pop(PaywallResult.cancelled),
        ),
      ),
    );
  }

  /// Apresenta o paywall usando RevenueCat UI nativo
  ///
  /// Esta é a forma recomendada de apresentar o paywall
  static Future<PaywallResult> present(BuildContext context) async {
    final paymentService = PaymentService();
    return paymentService.presentPaywall();
  }

  /// Apresenta o paywall apenas se o usuário não for Pro
  static Future<PaywallResult> presentIfNeeded(BuildContext context) async {
    final paymentService = PaymentService();
    return paymentService.presentPaywallIfNeeded();
  }
}

/// Widget de Paywall inline para embeddar em outras páginas
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
    return PaywallView(
      onPurchaseCompleted: (customerInfo, storeTransaction) {
        onPurchaseCompleted?.call();
      },
      onRestoreCompleted: (customerInfo) {
        // Verificar se restauração deu acesso Pro
        final paymentService = PaymentService();
        if (paymentService.isPro) {
          onPurchaseCompleted?.call();
        }
      },
      onDismiss: () {
        onDismiss?.call();
      },
    );
  }
}
