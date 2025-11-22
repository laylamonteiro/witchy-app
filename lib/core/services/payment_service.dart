import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/revenuecat_config.dart';

/// Status de compra
enum PurchaseStatus {
  idle,
  loading,
  success,
  error,
  cancelled,
}

/// Tipos de assinatura disponíveis
enum SubscriptionType {
  monthly,
  yearly,
  lifetime,
}

/// Resultado de uma compra
class PurchaseResult {
  final bool success;
  final String? errorMessage;
  final CustomerInfo? customerInfo;

  PurchaseResult({
    required this.success,
    this.errorMessage,
    this.customerInfo,
  });

  factory PurchaseResult.success(CustomerInfo info) {
    return PurchaseResult(success: true, customerInfo: info);
  }

  factory PurchaseResult.error(String message) {
    return PurchaseResult(success: false, errorMessage: message);
  }

  factory PurchaseResult.cancelled() {
    return PurchaseResult(success: false, errorMessage: 'Compra cancelada');
  }
}

/// Informações de um produto
class ProductInfo {
  final String identifier;
  final String title;
  final String description;
  final String priceString;
  final double price;
  final String currencyCode;
  final SubscriptionType type;

  ProductInfo({
    required this.identifier,
    required this.title,
    required this.description,
    required this.priceString,
    required this.price,
    required this.currencyCode,
    required this.type,
  });
}

/// Serviço de pagamentos usando RevenueCat
class PaymentService extends ChangeNotifier {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  bool _isInitialized = false;
  bool _isPremium = false;
  PurchaseStatus _status = PurchaseStatus.idle;
  List<ProductInfo> _products = [];
  CustomerInfo? _customerInfo;

  bool get isInitialized => _isInitialized;
  bool get isPremium => _isPremium;
  PurchaseStatus get status => _status;
  List<ProductInfo> get products => _products;
  CustomerInfo? get customerInfo => _customerInfo;

  /// Inicializa o RevenueCat
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!RevenueCatConfig.isConfigured) {
      print('RevenueCat não configurado - usando modo demo');
      _isInitialized = true;
      return;
    }

    try {
      // Configurar RevenueCat baseado na plataforma
      late PurchasesConfiguration configuration;

      if (Platform.isIOS) {
        configuration = PurchasesConfiguration(RevenueCatConfig.iosApiKey);
      } else if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(RevenueCatConfig.androidApiKey);
      } else {
        print('Plataforma não suportada para pagamentos');
        _isInitialized = true;
        return;
      }

      await Purchases.configure(configuration);

      // Listener para mudanças no status do cliente
      Purchases.addCustomerInfoUpdateListener((info) {
        _updateCustomerInfo(info);
      });

      // Carregar informações iniciais
      await _loadCustomerInfo();
      await _loadProducts();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Erro ao inicializar RevenueCat: $e');
      _isInitialized = true; // Continuar sem pagamentos
    }
  }

  /// Carrega informações do cliente
  Future<void> _loadCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus();
    } catch (e) {
      print('Erro ao carregar informações do cliente: $e');
    }
  }

  /// Atualiza informações do cliente
  void _updateCustomerInfo(CustomerInfo info) {
    _customerInfo = info;
    _updatePremiumStatus();
    notifyListeners();
  }

  /// Atualiza status premium
  void _updatePremiumStatus() {
    if (_customerInfo == null) {
      _isPremium = false;
      return;
    }

    // Verificar entitlement premium
    _isPremium = _customerInfo!.entitlements.active
        .containsKey(RevenueCatConfig.premiumEntitlementId);
  }

  /// Carrega produtos disponíveis
  Future<void> _loadProducts() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        print('Nenhuma oferta disponível');
        return;
      }

      _products = [];

      for (final package in offerings.current!.availablePackages) {
        final product = package.storeProduct;
        SubscriptionType type;

        switch (package.packageType) {
          case PackageType.monthly:
            type = SubscriptionType.monthly;
            break;
          case PackageType.annual:
            type = SubscriptionType.yearly;
            break;
          case PackageType.lifetime:
            type = SubscriptionType.lifetime;
            break;
          default:
            continue; // Pular outros tipos
        }

        _products.add(ProductInfo(
          identifier: product.identifier,
          title: product.title,
          description: product.description,
          priceString: product.priceString,
          price: product.price,
          currencyCode: product.currencyCode,
          type: type,
        ));
      }

      notifyListeners();
    } catch (e) {
      print('Erro ao carregar produtos: $e');
    }
  }

  /// Realiza uma compra
  Future<PurchaseResult> purchase(SubscriptionType type) async {
    if (!RevenueCatConfig.isConfigured) {
      return PurchaseResult.error('Pagamentos não configurados');
    }

    _setStatus(PurchaseStatus.loading);

    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        _setStatus(PurchaseStatus.error);
        return PurchaseResult.error('Nenhuma oferta disponível');
      }

      // Encontrar o pacote correto
      Package? package;
      switch (type) {
        case SubscriptionType.monthly:
          package = offerings.current!.monthly;
          break;
        case SubscriptionType.yearly:
          package = offerings.current!.annual;
          break;
        case SubscriptionType.lifetime:
          package = offerings.current!.lifetime;
          break;
      }

      if (package == null) {
        _setStatus(PurchaseStatus.error);
        return PurchaseResult.error('Produto não encontrado');
      }

      // Realizar compra
      final customerInfo = await Purchases.purchasePackage(package);
      _updateCustomerInfo(customerInfo);

      _setStatus(PurchaseStatus.success);
      return PurchaseResult.success(customerInfo);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        _setStatus(PurchaseStatus.cancelled);
        return PurchaseResult.cancelled();
      }
      _setStatus(PurchaseStatus.error);
      return PurchaseResult.error('Erro na compra: $e');
    } catch (e) {
      _setStatus(PurchaseStatus.error);
      return PurchaseResult.error('Erro inesperado: $e');
    }
  }

  /// Restaura compras anteriores
  Future<PurchaseResult> restorePurchases() async {
    if (!RevenueCatConfig.isConfigured) {
      return PurchaseResult.error('Pagamentos não configurados');
    }

    _setStatus(PurchaseStatus.loading);

    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateCustomerInfo(customerInfo);

      if (_isPremium) {
        _setStatus(PurchaseStatus.success);
        return PurchaseResult.success(customerInfo);
      } else {
        _setStatus(PurchaseStatus.idle);
        return PurchaseResult.error('Nenhuma compra encontrada para restaurar');
      }
    } catch (e) {
      _setStatus(PurchaseStatus.error);
      return PurchaseResult.error('Erro ao restaurar: $e');
    }
  }

  /// Associa usuário do Supabase ao RevenueCat
  Future<void> setUserId(String userId) async {
    if (!RevenueCatConfig.isConfigured) return;

    try {
      await Purchases.logIn(userId);
      await _loadCustomerInfo();
    } catch (e) {
      print('Erro ao definir ID do usuário: $e');
    }
  }

  /// Remove associação do usuário
  Future<void> clearUserId() async {
    if (!RevenueCatConfig.isConfigured) return;

    try {
      await Purchases.logOut();
      await _loadCustomerInfo();
    } catch (e) {
      print('Erro ao remover ID do usuário: $e');
    }
  }

  /// Obtém preço formatado para um tipo de assinatura
  String? getPriceString(SubscriptionType type) {
    final product = _products.firstWhere(
      (p) => p.type == type,
      orElse: () => ProductInfo(
        identifier: '',
        title: '',
        description: '',
        priceString: '',
        price: 0,
        currencyCode: '',
        type: type,
      ),
    );

    return product.priceString.isNotEmpty ? product.priceString : null;
  }

  /// Define status
  void _setStatus(PurchaseStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  /// Verifica se há assinatura ativa
  bool get hasActiveSubscription {
    if (_customerInfo == null) return false;
    return _customerInfo!.entitlements.active.isNotEmpty;
  }

  /// Data de expiração da assinatura (se houver)
  DateTime? get subscriptionExpirationDate {
    if (_customerInfo == null) return null;

    final premium = _customerInfo!.entitlements.active[
        RevenueCatConfig.premiumEntitlementId];
    if (premium == null) return null;

    final expirationDate = premium.expirationDate;
    if (expirationDate == null) return null;

    return DateTime.tryParse(expirationDate);
  }

  /// Verifica se é vitalício
  bool get isLifetime {
    if (_customerInfo == null) return false;

    final premium = _customerInfo!.entitlements.active[
        RevenueCatConfig.premiumEntitlementId];
    if (premium == null) return false;

    // Lifetime não tem data de expiração
    return premium.expirationDate == null;
  }
}
