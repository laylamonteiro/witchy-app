import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
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
  final Package? package;

  ProductInfo({
    required this.identifier,
    required this.title,
    required this.description,
    required this.priceString,
    required this.price,
    required this.currencyCode,
    required this.type,
    this.package,
  });
}

/// Serviço de pagamentos usando RevenueCat
///
/// Documentação oficial: https://www.revenuecat.com/docs/getting-started/installation/flutter
class PaymentService extends ChangeNotifier {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  bool _isInitialized = false;
  bool _isPro = false;
  PurchaseStatus _status = PurchaseStatus.idle;
  List<ProductInfo> _products = [];
  CustomerInfo? _customerInfo;
  Offerings? _offerings;

  bool get isInitialized => _isInitialized;
  bool get isPro => _isPro;
  PurchaseStatus get status => _status;
  List<ProductInfo> get products => _products;
  CustomerInfo? get customerInfo => _customerInfo;
  Offerings? get offerings => _offerings;

  /// Inicializa o RevenueCat SDK
  ///
  /// Deve ser chamado no início do app, preferencialmente em main.dart
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!RevenueCatConfig.isConfigured) {
      debugPrint('RevenueCat não configurado - usando modo demo');
      _isInitialized = true;
      return;
    }

    try {
      // Verificar se plataforma é suportada
      if (!Platform.isIOS && !Platform.isAndroid) {
        debugPrint('Plataforma não suportada para pagamentos');
        _isInitialized = true;
        return;
      }

      // Configurar RevenueCat
      final configuration = PurchasesConfiguration(RevenueCatConfig.apiKey)
        ..appUserID = null // Usar ID anônimo inicialmente
        ..observerMode = false
        ..usesStoreKit2IfAvailable = true;

      await Purchases.configure(configuration);

      // Habilitar logs em debug
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      // Listener para mudanças no status do cliente
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Carregar informações iniciais
      await _loadCustomerInfo();
      await _loadOfferings();

      _isInitialized = true;
      notifyListeners();

      debugPrint('RevenueCat inicializado com sucesso');
    } catch (e) {
      debugPrint('Erro ao inicializar RevenueCat: $e');
      _isInitialized = true; // Continuar sem pagamentos
    }
  }

  /// Callback quando CustomerInfo é atualizado
  void _onCustomerInfoUpdated(CustomerInfo info) {
    _customerInfo = info;
    _updateProStatus();
    notifyListeners();
  }

  /// Carrega informações do cliente
  Future<void> _loadCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus();
    } catch (e) {
      debugPrint('Erro ao carregar informações do cliente: $e');
    }
  }

  /// Atualiza status Pro baseado no entitlement
  void _updateProStatus() {
    if (_customerInfo == null) {
      _isPro = false;
      return;
    }

    // Verificar entitlement "Grimorio de Bolso Pro"
    _isPro = _customerInfo!.entitlements.active
        .containsKey(RevenueCatConfig.proEntitlementId);

    debugPrint('Status Pro atualizado: $_isPro');
  }

  /// Verifica se o usuário tem o entitlement Pro ativo
  bool hasPro() {
    return _customerInfo?.entitlements.active
        .containsKey(RevenueCatConfig.proEntitlementId) ?? false;
  }

  /// Carrega ofertas disponíveis
  Future<void> _loadOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();

      if (_offerings?.current == null) {
        debugPrint('Nenhuma oferta disponível');
        return;
      }

      _products = [];

      for (final package in _offerings!.current!.availablePackages) {
        final product = package.storeProduct;
        SubscriptionType? type;

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
            continue;
        }

        _products.add(ProductInfo(
          identifier: product.identifier,
          title: product.title,
          description: product.description,
          priceString: product.priceString,
          price: product.price,
          currencyCode: product.currencyCode,
          type: type,
          package: package,
        ));
      }

      notifyListeners();
      debugPrint('Produtos carregados: ${_products.length}');
    } catch (e) {
      debugPrint('Erro ao carregar ofertas: $e');
    }
  }

  /// Recarrega ofertas
  Future<void> refreshOfferings() async {
    await _loadOfferings();
  }

  // ============================================================
  // PAYWALL - RevenueCat UI
  // Documentação: https://www.revenuecat.com/docs/tools/paywalls
  // ============================================================

  /// Apresenta o paywall como modal
  ///
  /// Retorna PaywallResult indicando se houve compra, cancelamento ou erro
  Future<PaywallResult> presentPaywall({
    Offering? offering,
    bool displayCloseButton = true,
  }) async {
    if (!_isInitialized || !RevenueCatConfig.isConfigured) {
      return PaywallResult.cancelled;
    }

    try {
      final result = await RevenueCatUI.presentPaywall(
        offering: offering,
        displayCloseButton: displayCloseButton,
      );

      // Recarregar informações após paywall
      await _loadCustomerInfo();

      return result;
    } catch (e) {
      debugPrint('Erro ao apresentar paywall: $e');
      return PaywallResult.error;
    }
  }

  /// Apresenta paywall condicionalmente (só se não for Pro)
  ///
  /// Usa o paywallIfNeeded que só mostra se o usuário não tiver o entitlement
  Future<PaywallResult> presentPaywallIfNeeded({
    String? requiredEntitlementIdentifier,
  }) async {
    if (!_isInitialized || !RevenueCatConfig.isConfigured) {
      return PaywallResult.cancelled;
    }

    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(
        requiredEntitlementIdentifier ?? RevenueCatConfig.proEntitlementId,
      );

      await _loadCustomerInfo();
      return result;
    } catch (e) {
      debugPrint('Erro ao apresentar paywall condicional: $e');
      return PaywallResult.error;
    }
  }

  // ============================================================
  // CUSTOMER CENTER
  // Documentação: https://www.revenuecat.com/docs/tools/customer-center
  // ============================================================

  /// Apresenta o Customer Center para gerenciamento de assinatura
  ///
  /// Permite ao usuário:
  /// - Ver detalhes da assinatura
  /// - Cancelar assinatura
  /// - Solicitar reembolso
  /// - Acessar suporte
  Future<void> presentCustomerCenter() async {
    if (!_isInitialized || !RevenueCatConfig.isConfigured) {
      debugPrint('RevenueCat não inicializado');
      return;
    }

    try {
      await RevenueCatUI.presentCustomerCenter();
      await _loadCustomerInfo();
    } catch (e) {
      debugPrint('Erro ao apresentar Customer Center: $e');
    }
  }

  // ============================================================
  // COMPRAS MANUAIS
  // ============================================================

  /// Realiza uma compra de um tipo específico
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
      _onCustomerInfoUpdated(customerInfo);

      _setStatus(PurchaseStatus.success);
      return PurchaseResult.success(customerInfo);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        _setStatus(PurchaseStatus.cancelled);
        return PurchaseResult.cancelled();
      }

      _setStatus(PurchaseStatus.error);
      return PurchaseResult.error(_getErrorMessage(errorCode));
    } catch (e) {
      _setStatus(PurchaseStatus.error);
      return PurchaseResult.error('Erro inesperado: $e');
    }
  }

  /// Compra um pacote específico
  Future<PurchaseResult> purchasePackage(Package package) async {
    if (!RevenueCatConfig.isConfigured) {
      return PurchaseResult.error('Pagamentos não configurados');
    }

    _setStatus(PurchaseStatus.loading);

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _onCustomerInfoUpdated(customerInfo);

      _setStatus(PurchaseStatus.success);
      return PurchaseResult.success(customerInfo);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        _setStatus(PurchaseStatus.cancelled);
        return PurchaseResult.cancelled();
      }

      _setStatus(PurchaseStatus.error);
      return PurchaseResult.error(_getErrorMessage(errorCode));
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
      _onCustomerInfoUpdated(customerInfo);

      if (_isPro) {
        _setStatus(PurchaseStatus.success);
        return PurchaseResult.success(customerInfo);
      } else {
        _setStatus(PurchaseStatus.idle);
        return PurchaseResult.error('Nenhuma compra encontrada para restaurar');
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      _setStatus(PurchaseStatus.error);
      return PurchaseResult.error(_getErrorMessage(errorCode));
    } catch (e) {
      _setStatus(PurchaseStatus.error);
      return PurchaseResult.error('Erro ao restaurar: $e');
    }
  }

  // ============================================================
  // GERENCIAMENTO DE USUÁRIO
  // ============================================================

  /// Associa usuário (ex: do Supabase) ao RevenueCat
  ///
  /// Isso permite sincronizar compras entre dispositivos
  Future<void> logIn(String userId) async {
    if (!RevenueCatConfig.isConfigured) return;

    try {
      final result = await Purchases.logIn(userId);
      _onCustomerInfoUpdated(result.customerInfo);
      debugPrint('Usuário logado no RevenueCat: $userId');
    } catch (e) {
      debugPrint('Erro ao fazer login no RevenueCat: $e');
    }
  }

  /// Remove associação do usuário
  Future<void> logOut() async {
    if (!RevenueCatConfig.isConfigured) return;

    try {
      final customerInfo = await Purchases.logOut();
      _onCustomerInfoUpdated(customerInfo);
      debugPrint('Usuário deslogado do RevenueCat');
    } catch (e) {
      debugPrint('Erro ao fazer logout do RevenueCat: $e');
    }
  }

  /// Define atributos do usuário para analytics
  Future<void> setUserAttributes({
    String? email,
    String? displayName,
    Map<String, String>? customAttributes,
  }) async {
    if (!RevenueCatConfig.isConfigured) return;

    try {
      if (email != null) {
        await Purchases.setEmail(email);
      }
      if (displayName != null) {
        await Purchases.setDisplayName(displayName);
      }
      if (customAttributes != null) {
        for (final entry in customAttributes.entries) {
          await Purchases.setAttributes({entry.key: entry.value});
        }
      }
    } catch (e) {
      debugPrint('Erro ao definir atributos do usuário: $e');
    }
  }

  // ============================================================
  // UTILITÁRIOS
  // ============================================================

  /// Obtém preço formatado para um tipo de assinatura
  String? getPriceString(SubscriptionType type) {
    final product = _products.cast<ProductInfo?>().firstWhere(
      (p) => p?.type == type,
      orElse: () => null,
    );

    return product?.priceString;
  }

  /// Obtém produto por tipo
  ProductInfo? getProduct(SubscriptionType type) {
    return _products.cast<ProductInfo?>().firstWhere(
      (p) => p?.type == type,
      orElse: () => null,
    );
  }

  /// Verifica se há assinatura ativa
  bool get hasActiveSubscription {
    if (_customerInfo == null) return false;
    return _customerInfo!.entitlements.active.isNotEmpty;
  }

  /// Data de expiração da assinatura (se houver)
  DateTime? get subscriptionExpirationDate {
    if (_customerInfo == null) return null;

    final pro = _customerInfo!.entitlements.active[
        RevenueCatConfig.proEntitlementId];
    if (pro == null) return null;

    final expirationDate = pro.expirationDate;
    if (expirationDate == null) return null;

    return DateTime.tryParse(expirationDate);
  }

  /// Verifica se a assinatura é vitalícia
  bool get isLifetime {
    if (_customerInfo == null) return false;

    final pro = _customerInfo!.entitlements.active[
        RevenueCatConfig.proEntitlementId];
    if (pro == null) return false;

    // Lifetime não tem data de expiração
    return pro.expirationDate == null;
  }

  /// ID do app user no RevenueCat
  String? get appUserId => _customerInfo?.originalAppUserId;

  /// Define status e notifica listeners
  void _setStatus(PurchaseStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  /// Converte código de erro em mensagem amigável
  String _getErrorMessage(PurchasesErrorCode errorCode) {
    switch (errorCode) {
      case PurchasesErrorCode.purchaseCancelledError:
        return 'Compra cancelada';
      case PurchasesErrorCode.storeProblemError:
        return 'Problema com a loja. Tente novamente mais tarde.';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Compras não permitidas neste dispositivo';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'Compra inválida';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'Produto não disponível para compra';
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return 'Produto já comprado';
      case PurchasesErrorCode.networkError:
        return 'Erro de conexão. Verifique sua internet.';
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return 'Este recibo já está em uso por outra conta';
      case PurchasesErrorCode.invalidReceiptError:
        return 'Recibo inválido';
      case PurchasesErrorCode.missingReceiptFileError:
        return 'Arquivo de recibo não encontrado';
      case PurchasesErrorCode.paymentPendingError:
        return 'Pagamento pendente. Aguarde a confirmação.';
      default:
        return 'Erro ao processar compra. Tente novamente.';
    }
  }
}
