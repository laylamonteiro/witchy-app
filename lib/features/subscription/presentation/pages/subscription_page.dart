import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../cycle_reading/presentation/pages/cycle_reading_intro_page.dart';

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

  AppLocalizations get _l10n => AppLocalizations.of(context);
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
          _l10n.subsTitle,
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

                        // A Leitura do Ciclo é compra avulsa: não entra na
                        // assinatura, nem para quem já é Pro. Por isso ela
                        // aparece nos DOIS ramos — é aqui que a pessoa está
                        // decidindo gastar, e antes ela não era citada.
                        _buildCycleReadingCard(),
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
      subscriptionLabel = _l10n.subsUnlockAll;
      labelColor = context.gc.textSecondary;
    } else if (hasRevenueCat) {
      // Premium via RevenueCat
      if (isLifetimeSubscription) {
        subscriptionLabel = _l10n.subsLifetime;
        labelColor = context.gc.starYellow;
      } else if (expirationDate != null) {
        subscriptionLabel = _l10n.subsValidUntil(_formatDate(expirationDate));
        labelColor = context.gc.textSecondary;
      } else {
        subscriptionLabel = _l10n.subsActive;
        labelColor = context.gc.starYellow;
      }
    } else if (isBetaCodePremium) {
      subscriptionLabel = _l10n.subsLifetimeBetaCode;
      labelColor = context.gc.starYellow;
    } else if (isPremiumWithLifetime) {
      subscriptionLabel = _l10n.subsLifetime;
      labelColor = context.gc.starYellow;
    } else if (isPremiumWithMonthlyPlan) {
      // Assinatura mensal/anual (sem RevenueCat ativo no momento)
      final planName = currentUser.plan == SubscriptionPlan.monthly
          ? _l10n.premiumPlanMonthly
          : _l10n.premiumPlanYearly;
      subscriptionLabel = currentUser.isAdmin
          ? _l10n.subsPlanNameSim(planName)
          : _l10n.subsPlanName(planName);
      labelColor = context.gc.textSecondary;
    } else {
      subscriptionLabel = _l10n.subsPremiumActive;
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
            isPro ? _l10n.subsAppPremium : _l10n.profileFreePlan,
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
            _l10n.subsYourBenefits,
            style: TextStyle(
              color: context.gc.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
              Icons.auto_awesome, _l10n.subsBenefitUnlimitedForecasts),
          _buildFeatureItem(Icons.book, _l10n.subsBenefitFullGrimoire),
          _buildFeatureItem(Icons.psychology, _l10n.subsBenefitAdvisor),
          _buildFeatureItem(Icons.account_circle, _l10n.subsBenefitProfile),
          _buildFeatureItem(Icons.stars, _l10n.subsBenefitTransits),
          _buildFeatureItem(Icons.wb_sunny, _l10n.subsBenefitDailyWeather),
          _buildFeatureItem(
              Icons.calendar_today, _l10n.subsBenefitLunarCalendar),
          _buildFeatureItem(Icons.sync, _l10n.premiumBenefitCloudSync),
          _buildFeatureItem(Icons.support_agent, _l10n.subsBenefitSupport),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star),
                const SizedBox(width: 8),
                Text(
                  _l10n.premiumUnlock,
                  style: const TextStyle(
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
                _l10n.subsWhatYouGet,
                style: TextStyle(
                  color: context.gc.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                  Icons.auto_awesome, _l10n.subsBenefitUnlimitedForecasts),
              _buildFeatureItem(
                  Icons.book, _l10n.subsBenefitFullGrimoireAccess),
              _buildFeatureItem(Icons.psychology, _l10n.subsBenefitAdvisor),
              _buildFeatureItem(
                  Icons.account_circle, _l10n.subsBenefitProfile),
              _buildFeatureItem(Icons.stars, _l10n.subsBenefitTransits),
              _buildFeatureItem(
                  Icons.wb_sunny, _l10n.subsBenefitDailyWeather),
              _buildFeatureItem(
                  Icons.calendar_today, _l10n.subsBenefitLunarCalendar),
              _buildFeatureItem(Icons.sync, _l10n.premiumBenefitCloudSync),
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
                    ? _l10n.subsBetaLifetimeInfo
                    : _l10n.subsLifetimeActiveInfo,
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
                        _l10n.subsPlanName(
                            currentUser.plan == SubscriptionPlan.monthly
                                ? _l10n.premiumPlanMonthly
                                : _l10n.premiumPlanYearly),
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
                    _l10n.subsSimNote,
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
                      _l10n.profileManageSubscription,
                      style: TextStyle(color: context.gc.textPrimary),
                    ),
                    content: Text(
                      currentUser.isAdmin
                          ? _l10n.subsManageDialogAdmin
                          : _l10n.subsManageDialogUser,
                      style: TextStyle(color: context.gc.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          _l10n.commonUnderstood,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings),
                  const SizedBox(width: 8),
                  Text(_l10n.profileManageSubscription),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings),
            const SizedBox(width: 8),
            Text(_l10n.profileManageSubscription),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleReadingCard() {
    return SizedBox(
      width: double.infinity,
      child: MagicalCard(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CycleReadingIntroPage()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🌙', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _l10n.cycleReadingTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.gc.lilac,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: context.gc.softWhite.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _l10n.cycleReadingIntroTagline,
                style: TextStyle(
                  color: context.gc.softWhite.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
                    _l10n.subsHaveCode,
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
              _l10n.subsRedeemPitch,
              style: TextStyle(
                color: context.gc.softWhite.withValues(alpha: 0.7),
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
                      hintText: _l10n.subsCodeHint,
                      hintStyle: TextStyle(
                        color: context.gc.softWhite.withValues(alpha: 0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.gc.lilac),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.gc.lilac.withValues(alpha: 0.3),
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
                        SnackBar(
                          content: Text(_l10n.subsEnterCode),
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

                    // Fechar loading (mounted do State: este context É o
                    // do State — use_build_context_synchronously)
                    if (mounted) Navigator.of(context).pop();

                    // Mostrar resultado
                    if (mounted) {
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
                  child: Text(_l10n.subsRedeemAction),
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
                _l10n.subsRestorePurchases,
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

  Future<void> _openCustomerCenter() async {
    final messenger = ScaffoldMessenger.of(context);
    final gc = context.gc;
    final aberto = await _paymentService.presentCustomerCenter();
    if (!mounted || aberto) return;
    // Na web, sem endereço de portal não há para onde mandar a pessoa — avisa
    // em vez de deixar o botão parecer quebrado.
    messenger.showSnackBar(
      SnackBar(
        content: Text(_l10n.subsManageUnavailable),
        backgroundColor: gc.alert,
      ),
    );
  }

  Future<void> _restorePurchases() async {
    final result = await _paymentService.restorePurchases();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? _l10n.subsRestored
              : result.errorMessage ?? _l10n.subsNoPurchases,
        ),
        backgroundColor: result.success ? Colors.green : Colors.orange,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMd(Localizations.localeOf(context).toString())
        .format(date);
  }
}
