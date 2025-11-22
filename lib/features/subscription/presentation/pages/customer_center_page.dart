import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Página de Customer Center do RevenueCat
///
/// Permite ao usuário:
/// - Ver detalhes da assinatura ativa
/// - Cancelar ou modificar assinatura
/// - Solicitar reembolso
/// - Acessar suporte
///
/// Documentação: https://www.revenuecat.com/docs/tools/customer-center
class CustomerCenterPage extends StatelessWidget {
  const CustomerCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Central do Assinante',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const CustomerCenterView(),
    );
  }

  /// Apresenta o Customer Center usando RevenueCat UI nativo
  ///
  /// Esta é a forma recomendada de apresentar o Customer Center
  static Future<void> present(BuildContext context) async {
    final paymentService = PaymentService();
    await paymentService.presentCustomerCenter();
  }

  /// Abre o Customer Center como uma nova página
  static Future<void> pushPage(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CustomerCenterPage(),
      ),
    );
  }
}

/// Widget de Customer Center inline
///
/// Pode ser usado para embeddar o Customer Center em outras páginas
class CustomerCenterWidget extends StatelessWidget {
  const CustomerCenterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerCenterView();
  }
}
