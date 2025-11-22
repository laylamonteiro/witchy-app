import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../data/models/feature_access.dart';
import 'premium_blur_widget.dart';

/// Widget que mostra o uso restante de uma feature
class UsageLimitIndicator extends StatelessWidget {
  final AppFeature feature;
  final String featureName;
  final IconData? icon;

  const UsageLimitIndicator({
    super.key,
    required this.feature,
    required this.featureName,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final access = authProvider.checkFeatureAccess(feature);

        // Não mostrar para premium/admin
        if (access.hasFullAccess && access.remainingUses == null) {
          return const SizedBox.shrink();
        }

        // Se tem limite, mostrar indicador
        if (access.remainingUses != null && access.limit != null) {
          return _buildLimitIndicator(context, access);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLimitIndicator(BuildContext context, AccessResult access) {
    final remaining = access.remainingUses!;
    final limit = access.limit!;
    final percentage = remaining / limit;

    Color indicatorColor;
    if (percentage > 0.5) {
      indicatorColor = const Color(0xFF4CAF50);
    } else if (percentage > 0.2) {
      indicatorColor = const Color(0xFFFFC107);
    } else {
      indicatorColor = const Color(0xFFF44336);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: indicatorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: indicatorColor),
            const SizedBox(width: 6),
          ],
          Text(
            '$remaining/$limit',
            style: TextStyle(
              color: indicatorColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            featureName,
            style: TextStyle(
              color: indicatorColor.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão de upgrade inline compacto
class InlineUpgradeButton extends StatelessWidget {
  final String? label;
  final bool compact;

  const InlineUpgradeButton({
    super.key,
    this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Não mostrar para premium/admin
        if (authProvider.isPremium) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => _showUpgrade(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 12,
              vertical: compact ? 4 : 6,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: compact ? 12 : 14,
                ),
                if (label != null || !compact) ...[
                  SizedBox(width: compact ? 4 : 6),
                  Text(
                    label ?? 'Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
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

/// Widget que bloqueia interação se não tiver acesso
class FeatureGate extends StatelessWidget {
  final Widget child;
  final AppFeature feature;
  final VoidCallback? onTap;
  final String? blockedMessage;

  const FeatureGate({
    super.key,
    required this.child,
    required this.feature,
    this.onTap,
    this.blockedMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final access = authProvider.checkFeatureAccess(feature);

        if (access.hasFullAccess) {
          return GestureDetector(
            onTap: onTap,
            child: child,
          );
        }

        return GestureDetector(
          onTap: () => _showAccessDenied(context, access),
          child: Stack(
            children: [
              Opacity(
                opacity: 0.5,
                child: child,
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF9C27B0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccessDenied(BuildContext context, AccessResult access) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.lock_outline,
                color: Color(0xFF9C27B0),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                blockedMessage ?? access.message ?? 'Funcionalidade Premium',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const PremiumUpgradeSheet(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Desbloquear com Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Agora não',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Banner de limite atingido
class LimitReachedBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onUpgrade;

  const LimitReachedBanner({
    super.key,
    required this.message,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF44336).withValues(alpha: 0.2),
            const Color(0xFF9C27B0).withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFFC107),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onUpgrade ??
                  () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const PremiumUpgradeSheet(),
                    );
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Remover Limites',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
