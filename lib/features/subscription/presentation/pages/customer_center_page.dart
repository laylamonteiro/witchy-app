import 'package:flutter/material.dart';
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
class CustomerCenterPage extends StatefulWidget {
  const CustomerCenterPage({super.key});

  @override
  State<CustomerCenterPage> createState() => _CustomerCenterPageState();
}

class _CustomerCenterPageState extends State<CustomerCenterPage> {
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    // Apresentar o Customer Center nativo automaticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openNativeCustomerCenter();
    });
  }

  Future<void> _openNativeCustomerCenter() async {
    await _paymentService.presentCustomerCenter();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.lilac,
            ),
            const SizedBox(height: 24),
            const Text(
              'Abrindo Central do Assinante...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            TextButton(
              onPressed: _openNativeCustomerCenter,
              child: const Text(
                'Tentar Novamente',
                style: TextStyle(
                  color: AppColors.lilac,
                ),
              ),
            ),
          ],
        ),
      ),
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
/// Mostra informações da assinatura e opção de abrir o Customer Center nativo
class CustomerCenterWidget extends StatelessWidget {
  const CustomerCenterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentService = PaymentService();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.support_agent,
            size: 48,
            color: AppColors.lilac,
          ),
          const SizedBox(height: 16),
          const Text(
            'Central do Assinante',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gerencie sua assinatura, solicite suporte ou cancele',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => paymentService.presentCustomerCenter(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lilac,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Abrir Central'),
          ),
        ],
      ),
    );
  }
}
