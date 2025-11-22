/// Módulo de Subscription - Gerenciamento de assinaturas com RevenueCat
///
/// Este módulo contém:
/// - PaywallPage: Página para apresentar ofertas de assinatura
/// - SubscriptionPage: Página de gerenciamento de assinatura
/// - CustomerCenterPage: Central do assinante para gerenciar assinatura
/// - ProFeatureGate: Widget para proteger funcionalidades Pro
///
/// Uso:
/// ```dart
/// // Apresentar paywall
/// await PaywallPage.present(context);
///
/// // Apresentar paywall apenas se não for Pro
/// await PaywallPage.presentIfNeeded(context);
///
/// // Abrir Customer Center
/// await CustomerCenterPage.present(context);
///
/// // Proteger funcionalidade
/// ProFeatureGate(
///   child: Text('Conteudo Pro'),
/// )
/// ```

export 'presentation/pages/paywall_page.dart';
export 'presentation/pages/subscription_page.dart';
export 'presentation/pages/customer_center_page.dart';
export 'presentation/widgets/pro_feature_gate.dart';
