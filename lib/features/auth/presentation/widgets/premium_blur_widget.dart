import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../data/models/feature_access.dart';

/// Widget que aplica blur em conteúdo premium para usuários free
class PremiumBlurWidget extends StatelessWidget {
  /// O conteúdo que será mostrado (com blur se não tiver acesso)
  final Widget child;

  /// A feature necessária para ver sem blur
  final AppFeature feature;

  /// Intensidade do blur (0-20)
  final double blurIntensity;

  /// Mensagem customizada para o overlay
  final String? customMessage;

  /// Se deve mostrar o botão de upgrade
  final bool showUpgradeButton;

  /// Callback quando o botão de upgrade é pressionado
  final VoidCallback? onUpgradePressed;

  const PremiumBlurWidget({
    super.key,
    required this.child,
    required this.feature,
    this.blurIntensity = 8.0,
    this.customMessage,
    this.showUpgradeButton = true,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final access = authProvider.checkFeatureAccess(feature);

        if (access.hasFullAccess) {
          return child;
        }

        return _buildBlurredContent(context, access);
      },
    );
  }

  Widget _buildBlurredContent(BuildContext context, AccessResult access) {
    return Stack(
      children: [
        // Conteúdo com blur
        ClipRRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurIntensity,
              sigmaY: blurIntensity,
            ),
            child: child,
          ),
        ),
        // Overlay com mensagem e botão
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Center(
              child: _buildOverlayContent(context, access),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayContent(BuildContext context, AccessResult access) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9C27B0),
                  const Color(0xFF7B1FA2),
                ],
              ),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          // Título
          const Text(
            'Conteúdo Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Mensagem
          Text(
            customMessage ?? access.message ?? 'Desbloqueie com o plano Premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          if (showUpgradeButton) ...[
            const SizedBox(height: 20),
            // Botão de upgrade
            ElevatedButton(
              onPressed: onUpgradePressed ?? () => _showUpgradeDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Seja Premium',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumUpgradeSheet(),
    );
  }
}

/// Widget para blur apenas em texto
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

        return Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: blurIntensity,
                sigmaY: blurIntensity,
              ),
              child: Text(
                text,
                style: style,
                maxLines: maxLines,
                textAlign: textAlign,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Sheet de upgrade para Premium
class PremiumUpgradeSheet extends StatelessWidget {
  const PremiumUpgradeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                false,
              ),
              _buildPricingOption(
                context,
                'Anual',
                'R\$ 79,90',
                '/ano',
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
              onPressed: () => _handleSubscribe(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
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
          const SizedBox(height: 16),
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
    bool isPopular, {
    String? savings,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPopular
            ? const Color(0xFF9C27B0).withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular
              ? const Color(0xFF9C27B0)
              : Colors.white.withValues(alpha: 0.1),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0),
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
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
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
    );
  }

  void _handleSubscribe(BuildContext context) {
    // Por enquanto, simula upgrade (será substituído por compra real)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.upgradeToPremium();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Parabéns! Você agora é Premium! ✨'),
        backgroundColor: Color(0xFF9C27B0),
      ),
    );
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
