import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../data/models/feature_access.dart';
import '../../../../core/services/payment_service.dart';

/// Texto placeholder exibido (com blur) no lugar do conteúdo Premium real.
///
/// IMPORTANTE (fail-closed): o conteúdo Premium verdadeiro NUNCA deve ser
/// renderizado para usuários sem acesso — nem mesmo atrás de blur. Blur é
/// apenas cosmético: o texto continuaria na árvore de semântica (leitores de
/// tela leem tudo) e parcialmente legível. Por isso os widgets abaixo
/// renderizam este placeholder no lugar do conteúdo real.
const String kPremiumPlaceholderText =
    'As energias deste conteúdo estão veladas aos olhos comuns. '
    'Os astros sussurram segredos que apenas os iniciados podem ouvir. '
    'A lua guarda mistérios, os cristais vibram em silêncio e as ervas '
    'aguardam o momento de revelar seus poderes. Desperte seu potencial '
    'místico e descubra tudo o que o universo preparou para você. '
    'A magia completa espera por quem atravessa o véu.';

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
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const PremiumUpgradeSheet(),
          );
        },
        icon: const Icon(Icons.star, size: 18),
        label: const Text('Seja Premium'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9C27B0),
          foregroundColor: Colors.white,
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

/// Sheet de upgrade para Premium
class PremiumUpgradeSheet extends StatefulWidget {
  const PremiumUpgradeSheet({super.key});

  @override
  State<PremiumUpgradeSheet> createState() => _PremiumUpgradeSheetState();
}

class _PremiumUpgradeSheetState extends State<PremiumUpgradeSheet> {
  SubscriptionType _selectedPlan =
      SubscriptionType.yearly; // Anual por padrão (popular)
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9C27B0),
                  const Color(0xFFE91E63),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Grimório Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Desbloqueie todo o potencial mágico',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          // Benefits
          _buildBenefit(Icons.auto_stories, 'Feitiços ilimitados'),
          _buildBenefit(Icons.book, 'Enciclopédia completa'),
          _buildBenefit(Icons.psychology, 'Conselheiro Místico IA ilimitado'),
          _buildBenefit(Icons.stars, 'Mapa Astral completo'),
          _buildBenefit(Icons.auto_fix_high, 'Sigilos e Adivinhação'),
          _buildBenefit(Icons.cloud_sync, 'Backup na nuvem (em breve)'),
          const SizedBox(height: 32),
          // Pricing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPricingOption(
                context,
                'Mensal',
                'R\$ 9,90',
                '/mês',
                SubscriptionType.monthly,
                false,
              ),
              _buildPricingOption(
                context,
                'Anual',
                'R\$ 79,90',
                '/ano',
                SubscriptionType.yearly,
                true,
                savings: 'Economize 33%',
              ),
            ],
          ),
          const SizedBox(height: 24),
          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _handleSubscribe(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                disabledBackgroundColor:
                    const Color(0xFF9C27B0).withValues(alpha: 0.5),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Começar Agora',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Cancele a qualquer momento',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF9C27B0),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOption(
    BuildContext context,
    String title,
    String price,
    String period,
    SubscriptionType planType,
    bool isPopular, {
    String? savings,
  }) {
    final isSelected = _selectedPlan == planType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = planType;
        });
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF9C27B0).withValues(alpha: 0.3)
              : isPopular
                  ? const Color(0xFF9C27B0).withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF9C27B0)
                : isPopular
                    ? const Color(0xFF9C27B0).withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
            width: isSelected
                ? 3
                : isPopular
                    ? 2
                    : 1,
          ),
        ),
        child: Column(
          children: [
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'SELECIONADO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              period,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            if (savings != null) ...[
              const SizedBox(height: 4),
              Text(
                savings,
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscribe(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final paymentService = PaymentService();

      // Inicializar se necessário
      if (!paymentService.isInitialized) {
        await paymentService.initialize();
      }

      // Comprar o plano selecionado diretamente
      final result = await paymentService.purchase(_selectedPlan);

      if (!mounted) return;

      if (result.success) {
        // Atualizar estado do AuthProvider após compra bem-sucedida
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshPremiumStatus();

        // Fechar o bottom sheet
        Navigator.pop(context);

        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parabéns! Você agora é Premium! ✨'),
            backgroundColor: Color(0xFF9C27B0),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Erro ao processar pagamento'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Widget wrapper que mostra preview limitado
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
                      const Color(0xFF9C27B0).withValues(alpha: 0.8),
                      const Color(0xFFE91E63).withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        previewMessage ?? access.message ?? 'Conteúdo Premium',
                        style: const TextStyle(
                          color: Colors.white,
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
                      child: const Text(
                        'Upgrade',
                        style: TextStyle(
                          color: Colors.white,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumUpgradeSheet(),
    );
  }
}
