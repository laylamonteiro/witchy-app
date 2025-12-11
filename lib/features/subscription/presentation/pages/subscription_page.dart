import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';

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
      backgroundColor: AppColors.background,
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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return ListenableBuilder(
            listenable: _paymentService,
            builder: (context, _) {
              if (_isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.lilac,
                  ),
                );
              }

              // Usuário é Pro se tiver assinatura ativa OU Premium via código beta
              final isPro = _paymentService.isPro || authProvider.isPremium;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Status da assinatura
                        _buildSubscriptionStatus(authProvider),
                        const SizedBox(height: 24),

                        // Ações principais
                        if (isPro) ...[
                          _buildProFeatures(),
                          const SizedBox(height: 24),
                          _buildManageSubscriptionButton(authProvider),
                        ] else ...[
                          _buildUpgradeSection(),
                          const SizedBox(height: 24),
                          // Card de resgate de código beta
                          _buildBetaCodeCard(authProvider),
                        ],

                        const SizedBox(height: 24),

                        // Restaurar compras
                        _buildRestoreButton(),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionStatus(AuthProvider authProvider) {
    final currentUser = authProvider.currentUser;
    final isPro = _paymentService.isPro || authProvider.isPremium;

    // Determinar tipo de Premium
    final hasRevenueCat = _paymentService.isPro;
    final isLifetimeSubscription = _paymentService.isLifetime;
    final isPremiumWithMonthlyPlan = currentUser.isPremium &&
        (currentUser.plan == SubscriptionPlan.monthly ||
         currentUser.plan == SubscriptionPlan.yearly);
    final isPremiumWithLifetime = currentUser.isPremium &&
        currentUser.plan == SubscriptionPlan.lifetime;

    // Data de expiração (apenas para assinaturas via RevenueCat)
    final expirationDate = _paymentService.subscriptionExpirationDate;

    // Labels baseados no tipo de Premium
    String subscriptionLabel;
    Color labelColor;

    if (!isPro) {
      subscriptionLabel = 'Desbloqueie todos os recursos';
      labelColor = Colors.white54;
    } else if (hasRevenueCat) {
      // Premium via RevenueCat
      if (isLifetimeSubscription) {
        subscriptionLabel = 'Acesso Vitalício';
        labelColor = AppColors.starYellow;
      } else if (expirationDate != null) {
        subscriptionLabel = 'Válido até ${_formatDate(expirationDate)}';
        labelColor = Colors.white70;
      } else {
        subscriptionLabel = 'Assinatura Ativa';
        labelColor = AppColors.starYellow;
      }
    } else if (isPremiumWithLifetime) {
      // Premium vitalício (código beta ou admin)
      subscriptionLabel = 'Acesso Vitalício (Código Beta)';
      labelColor = AppColors.starYellow;
    } else if (isPremiumWithMonthlyPlan) {
      // Assinatura mensal/anual (sem RevenueCat ativo no momento)
      final planName = currentUser.plan == SubscriptionPlan.monthly ? 'Mensal' : 'Anual';
      subscriptionLabel = currentUser.isAdmin
          ? 'Plano $planName (Simulação)'
          : 'Plano $planName';
      labelColor = Colors.white70;
    } else {
      subscriptionLabel = 'Premium Ativo';
      labelColor = AppColors.starYellow;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isPro
            ? LinearGradient(
                colors: [
                  AppColors.lilac.withValues(alpha: 0.3),
                  AppColors.pink.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPro ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPro ? AppColors.lilac : Colors.white24,
          width: isPro ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Ícone de status
          Icon(
            isPro ? Icons.star : Icons.star_border,
            size: 48,
            color: isPro ? AppColors.starYellow : Colors.white54,
          ),
          const SizedBox(height: 12),

          // Título
          Text(
            isPro ? 'Grimório de Bolso Premium' : 'Plano Gratuito',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Subtítulo
          Text(
            subscriptionLabel,
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProFeatures() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seus Benefícios Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(Icons.auto_awesome, 'Previsões Mágicas ilimitadas'),
          _buildFeatureItem(Icons.book, 'Grimório completo'),
          _buildFeatureItem(Icons.psychology, 'Conselheiro Místico'),
          _buildFeatureItem(Icons.account_circle, 'Perfil mágico personalizado'),
          _buildFeatureItem(Icons.stars, 'Sugestões personalizadas pelos trânsitos'),
          _buildFeatureItem(Icons.wb_sunny, 'Clima mágico diário completo'),
          _buildFeatureItem(Icons.calendar_today, 'Calendário lunar avançado'),
          _buildFeatureItem(Icons.sync, 'Sincronização entre dispositivos'),
          _buildFeatureItem(Icons.support_agent, 'Suporte prioritário'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.starYellow),
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
              backgroundColor: const Color(0xFF9C27B0), // Cor consistente com outros botões Premium
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
                  'Desbloquear Premium',
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O que você ganha com o Premium:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(Icons.auto_awesome, 'Previsões Mágicas ilimitadas'),
              _buildFeatureItem(Icons.book, 'Acesso ao Grimório completo'),
              _buildFeatureItem(Icons.psychology, 'Conselheiro Místico'),
              _buildFeatureItem(Icons.account_circle, 'Perfil mágico personalizado'),
              _buildFeatureItem(Icons.stars, 'Sugestões personalizadas com base nos trânsitos'),
              _buildFeatureItem(Icons.wb_sunny, 'Clima mágico diário completo'),
              _buildFeatureItem(Icons.calendar_today, 'Calendário lunar avançado'),
              _buildFeatureItem(Icons.sync, 'Sincronização na nuvem'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManageSubscriptionButton(AuthProvider authProvider) {
    final currentUser = authProvider.currentUser;
    final hasRevenueCat = _paymentService.isPro;
    final isPremiumWithLifetime = currentUser.isPremium &&
        currentUser.plan == SubscriptionPlan.lifetime;
    final isPremiumWithMonthlyPlan = currentUser.isPremium &&
        (currentUser.plan == SubscriptionPlan.monthly ||
         currentUser.plan == SubscriptionPlan.yearly);

    // Premium vitalício (código beta) - apenas informativo
    if (isPremiumWithLifetime && !hasRevenueCat) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lilac.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.lilac, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Seu acesso Premium foi concedido via código beta e não expira',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Premium com plano mensal/anual (simulando assinatura)
    if (isPremiumWithMonthlyPlan && !hasRevenueCat) {
      return Column(
        children: [
          // Info do plano
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lilac.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.lilac, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Plano ${currentUser.plan == SubscriptionPlan.monthly ? "Mensal" : "Anual"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (currentUser.isAdmin) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Modo de simulação: Em produção, este seria um plano ativo via Play Store com renovação automática.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Botão simulado de cancelar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text(
                      'Gerenciar Assinatura',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text(
                      currentUser.isAdmin
                          ? 'Em produção, este botão direcionaria para o Google Play para gerenciar a assinatura.\n\n'
                            'Você está em modo de simulação como admin.'
                          : 'Para gerenciar sua assinatura, acesse as configurações da Google Play Store ou App Store.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Entendi',
                          style: TextStyle(color: AppColors.lilac),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
          ),
        ],
      );
    }

    // Premium via RevenueCat - botão real
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

  Widget _buildBetaCodeCard(AuthProvider authProvider) {
    final TextEditingController codeController = TextEditingController();

    return SizedBox(
      width: double.infinity,
      child: MagicalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '🎟️',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tem um Código Beta?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lilac,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Resgate seu código para obter acesso Premium vitalício!',
              style: TextStyle(
                color: AppColors.softWhite.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      hintText: 'Digite seu código',
                      hintStyle: TextStyle(
                        color: AppColors.softWhite.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.lilac),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.lilac.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.lilac),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final code = codeController.text.trim();
                    if (code.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, digite um código'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Mostrar loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    // Resgatar código
                    final result = await authProvider.redeemBetaCode(code);

                    // Fechar loading
                    if (context.mounted) Navigator.of(context).pop();

                    // Mostrar resultado
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message']),
                          backgroundColor: result['success']
                              ? Colors.green
                              : Colors.red,
                        ),
                      );

                      if (result['success']) {
                        codeController.clear();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lilac,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Resgatar'),
                ),
            ],
          ),
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

  void _showPaywall() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumUpgradeSheet(),
    );
  }

  void _showRevenueCatNotConfiguredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Color(0xFFFFC107)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pagamentos Não Configurados',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'O sistema de pagamentos ainda não foi configurado nesta versão do app.\n\n'
          'Se você é desenvolvedor, verifique os logs do console para mais detalhes sobre como configurar o RevenueCat.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendi',
              style: TextStyle(color: AppColors.lilac),
            ),
          ),
        ],
      ),
    );
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
