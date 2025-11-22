import 'dart:io';

/// Configuração do RevenueCat para In-App Purchases
///
/// Documentação: https://www.revenuecat.com/docs/getting-started/installation/flutter
class RevenueCatConfig {
  /// API Key para iOS (App Store)
  /// Em produção, use chaves diferentes para cada plataforma
  static const String iosApiKey = 'test_pXihQfrQyXPuOlWoYzUGYCruxym';

  /// API Key para Android (Google Play)
  /// Em produção, use chaves diferentes para cada plataforma
  static const String androidApiKey = 'test_pXihQfrQyXPuOlWoYzUGYCruxym';

  /// Obtém a API key correta para a plataforma atual
  static String get apiKey {
    if (Platform.isIOS) {
      return iosApiKey;
    } else if (Platform.isAndroid) {
      return androidApiKey;
    }
    throw UnsupportedError('Plataforma não suportada para pagamentos');
  }

  /// Verifica se o RevenueCat está configurado
  static bool get isConfigured =>
      iosApiKey.isNotEmpty && androidApiKey.isNotEmpty;

  /// Entitlement ID principal (configurado no RevenueCat Dashboard)
  /// Este é o entitlement que dá acesso às funcionalidades Pro
  static const String proEntitlementId = 'Grimorio de Bolso Pro';

  /// Offering ID padrão
  static const String defaultOfferingId = 'default';

  /// IDs dos produtos de assinatura
  static const String monthlyProductId = 'monthly';
  static const String yearlyProductId = 'yearly';
  static const String lifetimeProductId = 'lifetime';
}

/// IDs dos produtos para cada plataforma
class ProductIds {
  /// iOS Product IDs (configurados na App Store Connect)
  static const String iosMonthly = 'com.grimoriodebolso.pro.monthly';
  static const String iosYearly = 'com.grimoriodebolso.pro.yearly';
  static const String iosLifetime = 'com.grimoriodebolso.pro.lifetime';

  /// Android Product IDs (configurados no Google Play Console)
  static const String androidMonthly = 'grimorio_pro_monthly';
  static const String androidYearly = 'grimorio_pro_yearly';
  static const String androidLifetime = 'grimorio_pro_lifetime';
}
