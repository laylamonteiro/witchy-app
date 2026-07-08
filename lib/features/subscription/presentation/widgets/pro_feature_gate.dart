import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/payment_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../pages/paywall_page.dart';

/// Widget que protege funcionalidades Pro
///
/// Se o usuário não for Pro, mostra o [lockedChild] ou um widget padrão
/// Se o usuário for Pro, mostra o [child]
///
/// Exemplo:
/// ```dart
/// ProFeatureGate(
///   child: Text('Conteudo Pro'),
///   lockedChild: Text('Desbloqueie para ver'),
/// )
/// ```
class ProFeatureGate extends StatelessWidget {
  /// Widget mostrado quando o usuário é Pro
  final Widget child;

  /// Widget mostrado quando o usuário não é Pro (opcional)
  final Widget? lockedChild;

  /// Se true, mostra paywall ao clicar no conteúdo bloqueado
  final bool showPaywallOnTap;

  /// Callback opcional quando o usuário tenta acessar conteúdo bloqueado
  final VoidCallback? onLockedTap;

  const ProFeatureGate({
    super.key,
    required this.child,
    this.lockedChild,
    this.showPaywallOnTap = true,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<PaymentService, AuthProvider>(
      builder: (context, paymentService, authProvider, _) {
        // Fonte única de premium: RevenueCat OU premium local (código beta,
        // simulação de plano pelo admin).
        if (paymentService.isPro || authProvider.isPremiumEffective) {
          return child;
        }

        final locked = lockedChild ?? _buildDefaultLockedWidget(context);

        if (showPaywallOnTap) {
          return GestureDetector(
            onTap: () async {
              if (onLockedTap != null) {
                onLockedTap!();
              } else {
                await PaywallPage.present(context);
              }
            },
            child: locked,
          );
        }

        return locked;
      },
    );
  }

  Widget _buildDefaultLockedWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, color: Colors.white54, size: 20),
          SizedBox(width: 8),
          Text(
            'Funcionalidade Pro',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

/// Widget que mostra um badge Pro se o usuário tiver assinatura
class ProBadge extends StatelessWidget {
  final double size;

  const ProBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PaymentService, AuthProvider>(
      builder: (context, paymentService, authProvider, _) {
        if (!paymentService.isPro && !authProvider.isPremiumEffective) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'PRO',
            style: TextStyle(
              color: Colors.black,
              fontSize: size * 0.7,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

/// Extensão para verificar status Pro facilmente
extension ProStatusExtension on BuildContext {
  /// Retorna true se o usuário tem acesso Premium por qualquer caminho
  /// (RevenueCat, código beta lifetime ou simulação de plano pelo admin)
  bool get isPro {
    try {
      if (Provider.of<PaymentService>(this, listen: false).isPro) return true;
    } catch (_) {}
    try {
      return Provider.of<AuthProvider>(this, listen: false).isPremiumEffective;
    } catch (_) {
      return false;
    }
  }

  /// Mostra o paywall se o usuário não for Pro
  Future<bool> requirePro() async {
    if (isPro) return true;

    await PaywallPage.present(this);
    return isPro;
  }
}
