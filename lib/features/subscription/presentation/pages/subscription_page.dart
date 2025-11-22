import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Página de gerenciamento de assinatura
///
/// Mostra:
/// - Status atual da assinatura
/// - Opções para upgrade/downgrade
/// - Acesso ao Customer Center
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePaymentService();
  }

  Future<void> _initializePaymentService() async {
    if (!_paymentService.isInitialized) {
      setState(() => _isLoading = true);
      await _paymentService.initialize();
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Assinatura',
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
      body: ListenableBuilder(
        listenable: _paymentService,
        builder: (context, _) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status da assinatura
                _buildSubscriptionStatus(),
                const SizedBox(height: 24),

                // Ações principais
                if (_paymentService.isPro) ...[
                  _buildProFeatures(),
                  const SizedBox(height: 24),
                  _buildManageSubscriptionButton(),
                ] else ...[
                  _buildUpgradeSection(),
                ],

                const SizedBox(height: 24),

                // Restaurar compras
                _buildRestoreButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionStatus() {
    final isPro = _paymentService.isPro;
    final isLifetime = _paymentService.isLifetime;
    final expirationDate = _paymentService.subscriptionExpirationDate;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isPro
            ? LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.3),
                  AppTheme.secondary.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPro ? null : AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPro ? AppTheme.primary : Colors.white24,
          width: isPro ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Icone de status
          Icon(
            isPro ? Icons.star : Icons.star_border,
            size: 48,
            color: isPro ? AppTheme.accent : Colors.white54,
          ),
          const SizedBox(height: 12),

          // Titulo
          Text(
            isPro ? 'Grimorio de Bolso Pro' : 'Plano Gratuito',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitulo
          if (isPro) ...[
            if (isLifetime)
              const Text(
                'Acesso Vitalicio',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 14,
                ),
              )
            else if (expirationDate != null)
              Text(
                'Valido ate ${_formatDate(expirationDate)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
          ] else ...[
            const Text(
              'Desbloqueie todos os recursos',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProFeatures() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seus Beneficios Pro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(Icons.auto_awesome, 'Previsoes Magicas ilimitadas'),
          _buildFeatureItem(Icons.book, 'Grimorio completo'),
          _buildFeatureItem(Icons.calendar_today, 'Calendario lunar avancado'),
          _buildFeatureItem(Icons.sync, 'Sincronizacao entre dispositivos'),
          _buildFeatureItem(Icons.support_agent, 'Suporte prioritario'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.accent),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeSection() {
    return Column(
      children: [
        // Botao principal de upgrade
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showPaywall,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star),
                SizedBox(width: 8),
                Text(
                  'Desbloquear Pro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Lista de beneficios
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O que voce ganha com o Pro:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(Icons.auto_awesome, 'Previsoes Magicas ilimitadas'),
              _buildFeatureItem(Icons.book, 'Acesso ao Grimorio completo'),
              _buildFeatureItem(Icons.calendar_today, 'Calendario lunar avancado'),
              _buildFeatureItem(Icons.sync, 'Sincronizacao na nuvem'),
              _buildFeatureItem(Icons.block, 'Sem anuncios'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManageSubscriptionButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _openCustomerCenter,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings),
            SizedBox(width: 8),
            Text('Gerenciar Assinatura'),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return Center(
      child: TextButton(
        onPressed: _paymentService.status == PurchaseStatus.loading
            ? null
            : _restorePurchases,
        child: _paymentService.status == PurchaseStatus.loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              )
            : const Text(
                'Restaurar Compras',
                style: TextStyle(
                  color: Colors.white54,
                  decoration: TextDecoration.underline,
                ),
              ),
      ),
    );
  }

  Future<void> _showPaywall() async {
    final result = await _paymentService.presentPaywall();

    if (!mounted) return;

    if (result == PaywallResult.purchased ||
        result == PaywallResult.restored) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parabens! Voce agora e Pro!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _openCustomerCenter() async {
    await _paymentService.presentCustomerCenter();
  }

  Future<void> _restorePurchases() async {
    final result = await _paymentService.restorePurchases();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Compras restauradas com sucesso!'
              : result.errorMessage ?? 'Nenhuma compra encontrada',
        ),
        backgroundColor: result.success ? Colors.green : Colors.orange,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
