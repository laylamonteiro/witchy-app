import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuração do RevenueCat para In-App Purchases
///
/// As credenciais são carregadas via variáveis de ambiente no build.
/// Configure os secrets no GitHub Actions ou passe via --dart-define.
///
/// Documentação: https://www.revenuecat.com/docs/getting-started/installation/flutter
class RevenueCatConfig {
  /// API Key para iOS (App Store)
  static const String iosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_KEY',
    defaultValue: '',
  );

  /// API Key para Android (Google Play)
  static const String androidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
    defaultValue: '',
  );

  /// API Key da web (RevenueCat Billing / Stripe) — começa com `rcb_`.
  ///
  /// É uma chave à parte das lojas: produtos e preços da web são cadastrados
  /// separadamente no painel. Sem ela, o app na web simplesmente não oferece
  /// assinatura (nada quebra).
  static const String webApiKey = String.fromEnvironment(
    'REVENUECAT_WEB_KEY',
    defaultValue: '',
  );

  /// Obtém a API key correta para a plataforma atual.
  ///
  /// `kIsWeb` é testado primeiro para o short-circuit evitar tocar `Platform.*`
  /// na web — `dart:io` Platform estoura UnsupportedError no navegador.
  static String get apiKey {
    if (kIsWeb) {
      return webApiKey;
    } else if (Platform.isIOS) {
      return iosApiKey;
    } else if (Platform.isAndroid) {
      return androidApiKey;
    }
    throw UnsupportedError('Plataforma não suportada para pagamentos');
  }

  /// Verifica se há chave para a plataforma atual. Na web depende da chave do
  /// RevenueCat Billing; sem ela o app não oferece assinatura no navegador
  /// (e nada quebra).
  static bool get isConfigured => kIsWeb
      ? webApiKey.isNotEmpty
      : ((Platform.isIOS && iosApiKey.isNotEmpty) ||
          (Platform.isAndroid && androidApiKey.isNotEmpty));

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
