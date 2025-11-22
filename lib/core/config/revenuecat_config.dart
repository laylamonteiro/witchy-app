/// Configuração do RevenueCat para In-App Purchases
///
/// IMPORTANTE: Em produção, configure as API Keys reais no RevenueCat Dashboard
class RevenueCatConfig {
  /// API Key para iOS (App Store)
  /// Obtenha em: https://app.revenuecat.com/apps/<app_id>/api-keys
  static const String iosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_KEY',
    defaultValue: '', // Configurar em produção
  );

  /// API Key para Android (Google Play)
  /// Obtenha em: https://app.revenuecat.com/apps/<app_id>/api-keys
  static const String androidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
    defaultValue: '', // Configurar em produção
  );

  /// Verifica se o RevenueCat está configurado
  static bool get isConfigured =>
      iosApiKey.isNotEmpty || androidApiKey.isNotEmpty;

  /// IDs dos produtos de assinatura
  static const String monthlySubscriptionId = 'grimorio_premium_monthly';
  static const String yearlySubscriptionId = 'grimorio_premium_yearly';
  static const String lifetimeId = 'grimorio_premium_lifetime';

  /// Entitlement ID (configurado no RevenueCat)
  static const String premiumEntitlementId = 'premium';
}

/// IDs dos produtos para cada plataforma
class ProductIds {
  /// iOS Product IDs (configurados na App Store Connect)
  static const String iosMonthly = 'com.grimoriodebolso.premium.monthly';
  static const String iosYearly = 'com.grimoriodebolso.premium.yearly';
  static const String iosLifetime = 'com.grimoriodebolso.premium.lifetime';

  /// Android Product IDs (configurados no Google Play Console)
  static const String androidMonthly = 'grimorio_premium_monthly';
  static const String androidYearly = 'grimorio_premium_yearly';
  static const String androidLifetime = 'grimorio_premium_lifetime';
}
