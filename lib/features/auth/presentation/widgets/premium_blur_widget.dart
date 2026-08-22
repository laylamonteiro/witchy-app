import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../data/models/feature_access.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../subscription/presentation/widgets/subscription_offer_widgets.dart';

Future<void> showPremiumUpgradePaywall(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const PremiumUpgradeSheet(),
  );
}

/// Texto placeholder exibido (com blur) no lugar do conteúdo Premium real.
///
/// IMPORTANTE (fail-closed): o conteúdo Premium verdadeiro NUNCA deve ser
/// renderizado para usuários sem acesso — nem mesmo atrás de blur. Blur é
/// apenas cosmético: o texto continuaria na árvore de semântica (leitores de
/// tela leem tudo) e parcialmente legível. Por isso os widgets abaixo
/// renderizam este placeholder no lugar do conteúdo real.
String get kPremiumPlaceholderText =>
    lookupAppLocalizations(ContentLocale.instance.locale)
        .premiumPlaceholderText;

/// Bloco de texto placeholder desfocado, usado internamente pelos gates.
class _BlurredPlaceholder extends StatelessWidget {
  final double blurIntensity;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;

  const _BlurredPlaceholder({
    required this.blurIntensity,
    this.style,
    this.maxLines,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    // ExcludeSemantics: nem o placeholder precisa poluir a acessibilidade.
    return ExcludeSemantics(
      child: ClipRRect(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: Text(
            kPremiumPlaceholderText,
            style: style ?? const TextStyle(fontSize: 14, height: 1.5),
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
            textAlign: textAlign,
          ),
        ),
      ),
    );
  }
}

/// Widget que protege conteúdo premium para usuários free (FAIL-CLOSED).
///
/// Com acesso: constrói e mostra o conteúdo real (via [builder], preferido,
/// ou [child]). Sem acesso: mostra um placeholder desfocado — o conteúdo real
/// NÃO entra na árvore de widgets.
class PremiumBlurWidget extends StatelessWidget {
  /// Construtor do conteúdo real — só é chamado quando o usuário TEM acesso.
  /// Prefira este parâmetro a [child] para conteúdo sensível.
  final WidgetBuilder? builder;

  /// O conteúdo real (alternativa a [builder]). Só é inserido na árvore
  /// quando o usuário tem acesso.
  final Widget? child;

  /// A feature necessária para ver o conteúdo
  final AppFeature feature;

  /// Intensidade do blur do placeholder (0-20)
  final double blurIntensity;

  /// Mensagem customizada (não usada mais, mantido para compatibilidade)
  final String? customMessage;

  /// Se deve mostrar o botão de upgrade (não usada mais, mantido para compatibilidade)
  final bool showUpgradeButton;

  /// Callback quando o botão de upgrade é pressionado (não usada mais)
  final VoidCallback? onUpgradePressed;

  const PremiumBlurWidget({
    super.key,
    this.builder,
    this.child,
    required this.feature,
    this.blurIntensity = 6.0,
    this.customMessage,
    this.showUpgradeButton = false,
    this.onUpgradePressed,
  }) : assert(builder != null || child != null,
            'Forneça builder ou child ao PremiumBlurWidget');

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final access = authProvider.checkFeatureAccess(feature);

        if (access.hasFullAccess) {
          return builder != null ? builder!(context) : child!;
        }

        // Sem acesso: placeholder desfocado, nunca o conteúdo real.
        return _BlurredPlaceholder(blurIntensity: blurIntensity);
      },
    );
  }
}

/// Widget que mostra conteúdo premium com título visível e botão premium
/// (FAIL-CLOSED: sem acesso, o conteúdo real não entra na árvore — um
/// placeholder desfocado é mostrado no lugar).
class PremiumContentSection extends StatelessWidget {
  /// Título da seção (sempre visível, sem blur)
  final Widget title;

  /// Explica o assunto da seção e permanece sempre legível.
  final String? subtitle;

  /// Conteúdo real (alternativa a [contentBuilder]). Só entra na árvore com acesso.
  final Widget? content;

  /// Construtor do conteúdo real — só é chamado quando o usuário TEM acesso.
  /// Prefira este parâmetro a [content] para conteúdo sensível.
  final WidgetBuilder? contentBuilder;

  /// Feature necessária para acesso completo
  final AppFeature feature;

  /// Intensidade do blur do placeholder
  final double blurIntensity;

  /// Se deve mostrar o botão de upgrade
  final bool showUpgradeButton;

  const PremiumContentSection({
    super.key,
    required this.title,
    this.subtitle,
    this.content,
    this.contentBuilder,
    required this.feature,
    this.blurIntensity = 6.0,
    this.showUpgradeButton = true,
  }) : assert(content != null || contentBuilder != null,
            'Forneça content ou contentBuilder ao PremiumContentSection');

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final access = authProvider.checkFeatureAccess(feature);

        if (access.hasFullAccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                _VisiblePremiumSubtitle(subtitle!),
              ],
              contentBuilder != null ? contentBuilder!(context) : content!,
            ],
          );
        }

        // Título sem blur + placeholder desfocado + botão premium.
        // O conteúdo real NÃO é renderizado.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título sempre visível
            title,
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              _VisiblePremiumSubtitle(subtitle!),
              const SizedBox(height: 12),
            ],
            _BlurredPlaceholder(blurIntensity: blurIntensity),
            // Botão premium
            if (showUpgradeButton) ...[
              const SizedBox(height: 16),
              _buildPremiumButton(context),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPremiumButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          showPremiumUpgradePaywall(context);
        },
        icon: const Icon(Icons.star, size: 18),
        label: Text(AppLocalizations.of(context).premiumBePremium),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.gc.lilac,
          foregroundColor: context.gc.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

class _VisiblePremiumSubtitle extends StatelessWidget {
  final String text;

  const _VisiblePremiumSubtitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.35,
          ),
    );
  }
}

/// Widget para texto premium (FAIL-CLOSED: sem acesso, mostra placeholder
/// desfocado — o texto real não entra na árvore).
class PremiumBlurText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final AppFeature feature;
  final double blurIntensity;
  final int? maxLines;
  final TextAlign? textAlign;

  const PremiumBlurText({
    super.key,
    required this.text,
    required this.feature,
    this.style,
    this.blurIntensity = 6.0,
    this.maxLines,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final access = authProvider.checkFeatureAccess(feature);

        if (access.hasFullAccess) {
          return Text(
            text,
            style: style,
            maxLines: maxLines,
            textAlign: textAlign,
          );
        }

        // Sem acesso: placeholder desfocado no lugar do texto real.
        return _BlurredPlaceholder(
          blurIntensity: blurIntensity,
          style: style,
          maxLines: maxLines,
          textAlign: textAlign,
        );
      },
    );
  }
}

/// Sobe o paywall ([PremiumUpgradeSheet]) direto sobre a tela anterior e,
/// quando a pessoa dispensa, fecha a tela atual — evitando telas
/// intermediárias de "Seja Premium" nas funcionalidades 100% Premium.
///
/// Uso: numa página exclusiva Premium, chame no primeiro frame quando o
/// acesso for negado. O corpo pode ficar vazio enquanto o paywall sobe.
Future<void> showPaywallThenPop(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const PremiumUpgradeSheet(),
  );
  if (context.mounted) Navigator.of(context).maybePop();
}

/// Sheet de upgrade para Premium
class PremiumUpgradeSheet extends StatefulWidget {
  const PremiumUpgradeSheet({super.key});

  @override
  State<PremiumUpgradeSheet> createState() => _PremiumUpgradeSheetState();
}

class _PremiumUpgradeSheetState extends State<PremiumUpgradeSheet> {
  final PaymentService _paymentService = PaymentService();
  SubscriptionType _selectedPlan = SubscriptionType.yearly;
  bool _isInitializing = false;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _initializeProducts();
  }

  Future<void> _initializeProducts() async {
    // Sem a saída antecipada por `isInitialized`: ela pulava exatamente o
    // caso ruim. Um boot com rede ruim marca inicializado e deixa o catálogo
    // vazio — e a tela mostrava "planos indisponíveis" com o botão de compra
    // morto pela sessão inteira, porque ninguém tentava de novo.
    setState(() => _isInitializing = true);
    await _paymentService.garantirCatalogo();
    if (!mounted) return;
    setState(() {
      _isInitializing = false;
      _selectAvailablePlan();
    });
  }

  void _selectAvailablePlan() {
    if (_productFor(_selectedPlan) == null &&
        _productFor(SubscriptionType.monthly) != null) {
      _selectedPlan = SubscriptionType.monthly;
    }
  }

  ProductInfo? _productFor(SubscriptionType type) {
    return _paymentService.getProduct(type);
  }

  String _priceFor(SubscriptionType type, String fallback) {
    return _productFor(type)?.priceString ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.96,
        ),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10 + bottomPadding),
        decoration: BoxDecoration(
          color: context.gc.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.gc.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      key: const ValueKey('close_premium_paywall'),
                      tooltip: AppLocalizations.of(context).commonClose,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: context.gc.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _paymentService,
                builder: (context, _) {
                  if (_isInitializing) {
                    return Center(
                      child: CircularProgressIndicator(color: context.gc.lilac),
                    );
                  }

                  final monthlyAvailable =
                      _productFor(SubscriptionType.monthly) != null;
                  final yearlyAvailable =
                      _productFor(SubscriptionType.yearly) != null;
                  final lifetimeAvailable =
                      _productFor(SubscriptionType.lifetime) != null;
                  final selectedAvailable = _productFor(_selectedPlan) != null;
                  final noProducts = _paymentService.isInitialized &&
                      !monthlyAvailable &&
                      !yearlyAvailable &&
                      !lifetimeAvailable;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = math.min(constraints.maxWidth - 8, 720.0);

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: PremiumOfferPanel(
                                selectedPlan: _selectedPlan,
                                onSelected: (plan) =>
                                    setState(() => _selectedPlan = plan),
                                // Só aparecem enquanto a loja não respondeu:
                                // o preço de verdade vem da RevenueCat.
                                monthlyPrice: _priceFor(
                                  SubscriptionType.monthly,
                                  'R\$ 19,90',
                                ),
                                yearlyPrice: _priceFor(
                                  SubscriptionType.yearly,
                                  'R\$ 119,90',
                                ),
                                lifetimePrice: lifetimeAvailable
                                    ? _priceFor(
                                        SubscriptionType.lifetime,
                                        '',
                                      )
                                    : null,
                                monthlyEnabled: monthlyAvailable,
                                yearlyEnabled: yearlyAvailable,
                                lifetimeEnabled: lifetimeAvailable,
                                purchaseLoading: _isPurchasing ||
                                    _paymentService.status ==
                                        PurchaseStatus.loading,
                                purchaseEnabled: selectedAvailable && !noProducts,
                                onPurchase: _purchaseSelectedPlan,
                                unavailableNotice: noProducts
                                    ? Text(
                                        AppLocalizations.of(context).premiumPlansUnavailable,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: context.gc.warning),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchaseSelectedPlan() async {
    if (_isPurchasing || _productFor(_selectedPlan) == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();
    setState(() => _isPurchasing = true);
    try {
      final result = await _paymentService.purchase(_selectedPlan);
      if (!mounted) return;

      if (result.success) {
        await authProvider.refreshPremiumStatus();
        if (!mounted) return;
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).premiumActivated),
            backgroundColor: context.gc.success,
          ),
        );
      } else if (!result.foiCancelada) {
        // Pelo campo, não pelo texto: comparar com o literal 'Compra
        // cancelada' passava a acusar erro num cancelamento normal assim que
        // a mensagem fosse traduzida.
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result.errorMessage ??
                  AppLocalizations.of(context).premiumPurchaseFailed,
            ),
            backgroundColor: context.gc.alert,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }
}

class PremiumPreviewWrapper extends StatelessWidget {
  final Widget child;
  final AppFeature feature;
  final String? previewMessage;

  const PremiumPreviewWrapper({
    super.key,
    required this.child,
    required this.feature,
    this.previewMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final access = authProvider.checkFeatureAccess(feature);

        if (access.hasFullAccess) {
          return child;
        }

        // Se for preview, mostrar com indicador
        if (access.isPreview) {
          return Column(
            children: [
              // Banner de preview
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.gc.lilac.withValues(alpha: 0.8),
                      context.gc.pink.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: context.gc.textPrimary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        previewMessage ?? access.message ?? AppLocalizations.of(context).premiumContentLabel,
                        style: TextStyle(
                          color: context.gc.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showUpgrade(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context).premiumUpgradeAction,
                        style: TextStyle(
                          color: context.gc.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Conteúdo com blur
              Expanded(
                child: PremiumBlurWidget(
                  feature: feature,
                  showUpgradeButton: false,
                  child: child,
                ),
              ),
            ],
          );
        }

        // Bloqueado - não mostrar
        return const SizedBox.shrink();
      },
    );
  }

  void _showUpgrade(BuildContext context) {
    showPremiumUpgradePaywall(context);
  }
}
