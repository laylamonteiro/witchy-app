import 'package:flutter/material.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';

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
      backgroundColor: context.gc.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ResponsiveAppBarTitle(
          'Central do Assinante',
          style: TextStyle(
            color: context.gc.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.gc.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: context.gc.lilac,
            ),
            const SizedBox(height: 24),
            Text(
              'Abrindo Central do Assinante...',
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            TextButton(
              onPressed: _openNativeCustomerCenter,
              child: Text(
                'Tentar Novamente',
                style: TextStyle(
                  color: context.gc.lilac,
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
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.support_agent,
            size: 48,
            color: context.gc.lilac,
          ),
          const SizedBox(height: 16),
          Text(
            'Central do Assinante',
            style: TextStyle(
              color: context.gc.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gerencie sua assinatura, solicite suporte ou cancele',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => paymentService.presentCustomerCenter(),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
              foregroundColor: context.gc.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Abrir Central'),
          ),
        ],
      ),
    );
  }
}
