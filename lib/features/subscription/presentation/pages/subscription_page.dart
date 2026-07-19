import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
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

Future<void> openSubscriptionPage(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
  );
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
      backgroundColor: context.gc.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ResponsiveAppBarTitle(
          'Assinatura',
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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return ListenableBuilder(
            listenable: _paymentService,
            builder: (context, _) {
              if (_isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: context.gc.lilac,
                  ),
                );
              }

              // Fonte única de premium (RevenueCat, Código Premium ou admin)
              final isPro = authProvider.isPremiumEffective;

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
                          // Card de resgate de Código Premium
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
    final isPro = authProvider.isPremiumEffective;

    // Determinar tipo de Premium
    final hasRevenueCat = _paymentService.isPro;
    final isLifetimeSubscription = _paymentService.isLifetime;
    final isPremiumWithMonthlyPlan = currentUser.isPremium &&
        (currentUser.plan == SubscriptionPlan.monthly ||
            currentUser.plan == SubscriptionPlan.yearly);
    final isPremiumWithLifetime =
        currentUser.isPremium && currentUser.plan == SubscriptionPlan.lifetime;
    final isBetaCodePremium =
        isPremiumWithLifetime && !currentUser.isAdmin && !hasRevenueCat;

    // Data de expiração (apenas para assinaturas via RevenueCat)
    final expirationDate = _paymentService.subscriptionExpirationDate;

    // Labels baseados no tipo de Premium
    String subscriptionLabel;
    Color labelColor;

    if (!isPro) {
      subscriptionLabel = 'Desbloqueie todos os recursos';
      labelColor = context.gc.textSecondary;
    } else if (hasRevenueCat) {
      // Premium via RevenueCat
      if (isLifetimeSubscription) {
        subscriptionLabel = 'Acesso Vitalício';
        labelColor = context.gc.starYellow;
      } else if (expirationDate != null) {
        subscriptionLabel = 'Válido até ${_formatDate(expirationDate)}';
        labelColor = context.gc.textSecondary;
      } else {
        subscriptionLabel = 'Assinatura Ativa';
        labelColor = context.gc.starYellow;
      }
    } else if (isBetaCodePremium) {
      subscriptionLabel = 'Acesso Vitalício (Código Premium)';
      labelColor = context.gc.starYellow;
    } else if (isPremiumWithLifetime) {
      subscriptionLabel = 'Acesso Vitalício';
      labelColor = context.gc.starYellow;
    } else if (isPremiumWithMonthlyPlan) {
      // Assinatura mensal/anual (sem RevenueCat ativo no momento)
      final planName =
          currentUser.plan == SubscriptionPlan.monthly ? 'Mensal' : 'Anual';
      subscriptionLabel = currentUser.isAdmin
          ? 'Plano $planName (Simulação)'
          : 'Plano $planName';
      labelColor = context.gc.textSecondary;
    } else {
      subscriptionLabel = 'Premium Ativo';
      labelColor = context.gc.starYellow;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isPro
            ? LinearGradient(
                colors: [
                  context.gc.lilac.withValues(alpha: 0.3),
                  context.gc.pink.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPro ? null : context.gc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPro ? context.gc.lilac : context.gc.textSecondary,
          width: isPro ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Ícone de status
          Icon(
            isPro ? Icons.star : Icons.star_border,
            size: 48,
            color: isPro ? context.gc.starYellow : context.gc.textSecondary,
          ),
          const SizedBox(height: 12),

          // Título
          Text(
            isPro ? 'Grimório de Bolso Premium' : 'Plano Gratuito',
            style: TextStyle(
              color: context.gc.textPrimary,
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
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seus Benefícios Premium',
            style: TextStyle(
              color: context.gc.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(Icons.auto_awesome, 'Previsões Mágicas ilimitadas'),
          _buildFeatureItem(Icons.book, 'Grimório completo'),
          _buildFeatureItem(Icons.psychology, 'Conselheiro Místico'),
          _buildFeatureItem(
              Icons.account_circle, 'Perfil mágico personalizado'),
          _buildFeatureItem(
              Icons.stars, 'Sugestões personalizadas pelos trânsitos'),
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
          Icon(icon, size: 20, color: context.gc.starYellow),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 14,
              ),
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
            key: const ValueKey('open_premium_paywall_button'),
            onPressed: _showPaywall,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                  0xFF9C27B0), // Cor consistente com outros botões Premium
              foregroundColor: context.gc.textPrimary,
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
            color: context.gc.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'O que você ganha com o Premium:',
                style: TextStyle(
                  color: context.gc.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                  Icons.auto_awesome, 'Previsões Mágicas ilimitadas'),
              _buildFeatureItem(Icons.book, 'Acesso ao Grimório completo'),
              _buildFeatureItem(Icons.psychology, 'Conselheiro Místico'),
              _buildFeatureItem(
                  Icons.account_circle, 'Perfil mágico personalizado'),
              _buildFeatureItem(Icons.stars,
                  'Sugestões personalizadas com base nos trânsitos'),
              _buildFeatureItem(Icons.wb_sunny, 'Clima mágico diário completo'),
              _buildFeatureItem(
                  Icons.calendar_today, 'Calendário lunar avançado'),
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
    final isPremiumWithLifetime =
        currentUser.isPremium && currentUser.plan == SubscriptionPlan.lifetime;
    final isBetaCodePremium =
        isPremiumWithLifetime && !currentUser.isAdmin && !hasRevenueCat;
    final isPremiumWithMonthlyPlan = currentUser.isPremium &&
        (currentUser.plan == SubscriptionPlan.monthly ||
            currentUser.plan == SubscriptionPlan.yearly);

    // Premium vitalício (Código Premium) - apenas informativo
    if (isPremiumWithLifetime && !hasRevenueCat) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.gc.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.gc.lilac.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: context.gc.lilac, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isBetaCodePremium
                    ? 'Seu acesso Premium foi resgatado via Código Premium e não expira.'
                    : 'Seu acesso Premium vitalício está ativo.',
                style: TextStyle(
                  color: context.gc.textSecondary,
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
              color: context.gc.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.gc.lilac.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: context.gc.lilac, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Plano ${currentUser.plan == SubscriptionPlan.monthly ? "Mensal" : "Anual"}',
                        style: TextStyle(
                          color: context.gc.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (currentUser.isAdmin) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Modo de simulação: Em produção, este seria um plano ativo via Play Store com renovação automática.',
                    style: TextStyle(
                      color: context.gc.textSecondary,
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
                    backgroundColor: context.gc.surface,
                    title: Text(
                      'Gerenciar Assinatura',
                      style: TextStyle(color: context.gc.textPrimary),
                    ),
                    content: Text(
                      currentUser.isAdmin
                          ? 'Em produção, este botão direcionaria para o Google Play para gerenciar a assinatura.\n\n'
                              'Você está em modo de simulação como admin.'
                          : 'Para gerenciar sua assinatura, acesse as configurações da Google Play Store ou App Store.',
                      style: TextStyle(color: context.gc.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Entendi',
                          style: TextStyle(color: context.gc.lilac),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: context.gc.textPrimary,
                side: BorderSide(color: context.gc.textSecondary),
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
          foregroundColor: context.gc.textPrimary,
          side: BorderSide(color: context.gc.textSecondary),
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
        margin: EdgeInsets.zero,
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
                Expanded(
                  child: Text(
                    'Tem um Código Premium?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.gc.lilac,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Resgate seu código para obter acesso Premium vitalício!',
              style: TextStyle(
                color: context.gc.softWhite.withOpacity(0.7),
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
                        color: context.gc.softWhite.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.gc.lilac),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.gc.lilac.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.gc.lilac),
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
                          backgroundColor:
                              result['success'] ? Colors.green : Colors.red,
                        ),
                      );

                      if (result['success']) {
                        codeController.clear();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.gc.lilac,
                    foregroundColor: context.gc.textPrimary,
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
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.gc.textSecondary,
                ),
              )
            : Text(
                'Restaurar Compras',
                style: TextStyle(
                  color: context.gc.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
      ),
    );
  }

  void _showPaywall() {
    showPremiumUpgradePaywall(context);
  }

  void _showRevenueCatNotConfiguredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Color(0xFFFFC107)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pagamentos Não Configurados',
                style: TextStyle(color: context.gc.textPrimary, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          'O sistema de pagamentos ainda não foi configurado nesta versão do app.\n\n'
          'Se você é desenvolvedor, verifique os logs do console para mais detalhes sobre como configurar o RevenueCat.',
          style: TextStyle(color: context.gc.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendi',
              style: TextStyle(color: context.gc.lilac),
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
