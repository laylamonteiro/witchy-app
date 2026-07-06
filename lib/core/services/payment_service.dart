import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Callback chamado quando o status Pro muda (para sincronizar com AuthProvider)
  Function(bool isPro)? _onProStatusChanged;

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
    if (_isInitialized) {
      debugPrint('ℹ️  RevenueCat já inicializado');
      return;
    }

    debugPrint('🔄 Iniciando RevenueCat...');
    debugPrint('📋 Plataforma: ${Platform.operatingSystem}');

    if (!RevenueCatConfig.isConfigured) {
      debugPrint('⚠️  RevenueCat não configurado - chaves de API ausentes');
      debugPrint('💡 Dica para desenvolvedores:');
      debugPrint('   1. Copie .env.example para .env');
      debugPrint('   2. Adicione suas chaves do RevenueCat');
      debugPrint('   3. Execute: flutter run --dart-define-from-file=.env');
      debugPrint('   OU configure os secrets no GitHub Actions');
      _isInitialized = true;
      return;
    }

    try {
      // Verificar se plataforma é suportada
      if (!Platform.isIOS && !Platform.isAndroid) {
        debugPrint('⚠️  Plataforma ${Platform.operatingSystem} não suportada para pagamentos');
        _isInitialized = true;
        return;
      }

      // Configurar RevenueCat
      debugPrint('🔑 Configurando RevenueCat com API key...');
      final configuration = PurchasesConfiguration(RevenueCatConfig.apiKey);

      await Purchases.configure(configuration);
      debugPrint('✅ SDK configurado');

      // Habilitar logs em debug
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
        debugPrint('🐛 Logs de debug habilitados');
      }

      // Listener para mudanças no status do cliente
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
      debugPrint('👂 Listener de CustomerInfo registrado');

      // Carregar informações iniciais
      debugPrint('📥 Carregando informações do cliente...');
      await _loadCustomerInfo();

      debugPrint('🛒 Carregando ofertas...');
      await _loadOfferings();

      _isInitialized = true;
      notifyListeners();

      debugPrint('✅ RevenueCat inicializado com sucesso!');
      debugPrint('   Status Pro: $_isPro');
      debugPrint('   Produtos disponíveis: ${_products.length}');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar RevenueCat: $e');
      debugPrint('⚠️  Continuando sem funcionalidade de pagamentos');
      _isInitialized = true; // Continuar sem pagamentos
    }
  }

  /// Registra callback para ser notificado quando o status Pro mudar
  ///
  /// Usado pelo AuthProvider para sincronizar UserRole com assinatura
  void setProStatusChangedCallback(Function(bool isPro)? callback) {
    _onProStatusChanged = callback;
  }

  /// Callback quando CustomerInfo é atualizado
  void _onCustomerInfoUpdated(CustomerInfo info) {
    final oldIsPro = _isPro;
    _customerInfo = info;
    _updateProStatus();

    // Notificar AuthProvider se o status Pro mudou
    if (oldIsPro != _isPro && _onProStatusChanged != null) {
      debugPrint('🔄 Status Pro mudou: $oldIsPro → $_isPro');
      debugPrint('   Notificando AuthProvider para sincronizar UserRole...');
      _onProStatusChanged!(_isPro);
    }

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
      debugPrint('📦 Buscando ofertas no RevenueCat...');
      _offerings = await Purchases.getOfferings();

      if (_offerings?.current == null) {
        debugPrint('⚠️  Nenhuma oferta disponível no RevenueCat');
        debugPrint('💡 Verifique se:');
        debugPrint('   1. A offering "default" existe no dashboard');
        debugPrint('   2. Os produtos estão associados à offering');
        debugPrint('   3. Os produtos foram criados nas lojas (App Store/Google Play)');
        return;
      }

      debugPrint('✅ Offering encontrada: ${_offerings!.current!.identifier}');
      debugPrint('📦 Pacotes disponíveis: ${_offerings!.current!.availablePackages.length}');

      _products = [];

      for (final package in _offerings!.current!.availablePackages) {
        final product = package.storeProduct;
        SubscriptionType? type;

        debugPrint('   📦 ${package.identifier}:');
        debugPrint('      - Product ID: ${product.identifier}');
        debugPrint('      - Título: ${product.title}');
        debugPrint('      - Preço: ${product.priceString}');
        debugPrint('      - Tipo: ${package.packageType}');

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
            debugPrint('      ⚠️  Tipo de pacote não reconhecido, pulando...');
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
      debugPrint('✅ Produtos carregados: ${_products.length}');

      if (_products.isEmpty) {
        debugPrint('⚠️  ATENÇÃO: Nenhum produto foi carregado!');
        debugPrint('💡 Verifique a configuração dos produtos no RevenueCat Dashboard');
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar ofertas: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
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
    if (!_isInitialized) {
      debugPrint('❌ RevenueCat não inicializado');
      return PaywallResult.cancelled;
    }

    if (!RevenueCatConfig.isConfigured) {
      debugPrint('❌ RevenueCat não configurado - chaves de API não encontradas');
      debugPrint('💡 Dica: Execute com --dart-define ou configure .env');
      debugPrint('   iOS Key: ${RevenueCatConfig.iosApiKey.isEmpty ? "FALTANDO" : "OK"}');
      debugPrint('   Android Key: ${RevenueCatConfig.androidApiKey.isEmpty ? "FALTANDO" : "OK"}');
      return PaywallResult.cancelled;
    }

    debugPrint('🚀 Apresentando paywall do RevenueCat...');

    try {
      final result = await RevenueCatUI.presentPaywall(
        offering: offering,
        displayCloseButton: displayCloseButton,
      );

      debugPrint('✅ Paywall fechado com resultado: $result');

      // Recarregar informações após paywall
      await _loadCustomerInfo();

      return result;
    } catch (e) {
      debugPrint('❌ Erro ao apresentar paywall: $e');
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
  ///
  /// Throws if the Customer Center cannot be presented.
  Future<void> presentCustomerCenter() async {
    if (!_isInitialized || !RevenueCatConfig.isConfigured) {
      debugPrint('RevenueCat não inicializado - não é possível abrir Customer Center');
      throw StateError('RevenueCat não inicializado');
    }

    try {
      await RevenueCatUI.presentCustomerCenter();
      await _loadCustomerInfo();
    } catch (e) {
      debugPrint('Erro ao apresentar Customer Center: $e');
      rethrow;
    }
  }

  // ============================================================
  // COMPRAS MANUAIS
  // ============================================================

  /// Realiza uma compra de um tipo específico
  Future<PurchaseResult> purchase(SubscriptionType type) async {
    debugPrint('🛒 Iniciando compra: $type');

    if (!RevenueCatConfig.isConfigured) {
      debugPrint('❌ Compra falhou: RevenueCat não configurado');
      return PurchaseResult.error('Pagamentos não configurados');
    }

    _setStatus(PurchaseStatus.loading);

    try {
      debugPrint('📦 Buscando ofertas...');
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        debugPrint('❌ Nenhuma oferta disponível');
        debugPrint('💡 Verifique se a offering "default" existe no RevenueCat Dashboard');
        _setStatus(PurchaseStatus.error);
        return PurchaseResult.error('Nenhuma oferta disponível. Verifique a configuração no RevenueCat Dashboard.');
      }

      debugPrint('✅ Offering encontrada: ${offerings.current!.identifier}');

      // Encontrar o pacote correto
      Package? package;
      String packageName = '';

      switch (type) {
        case SubscriptionType.monthly:
          package = offerings.current!.monthly;
          packageName = 'monthly';
          break;
        case SubscriptionType.yearly:
          package = offerings.current!.annual;
          packageName = 'annual';
          break;
        case SubscriptionType.lifetime:
          package = offerings.current!.lifetime;
          packageName = 'lifetime';
          break;
      }

      if (package == null) {
        debugPrint('❌ Pacote $packageName não encontrado na offering');
        debugPrint('💡 Verifique se o produto está associado à offering no RevenueCat Dashboard');
        debugPrint('   Pacotes disponíveis: ${offerings.current!.availablePackages.map((p) => p.identifier).join(", ")}');
        _setStatus(PurchaseStatus.error);
        return PurchaseResult.error('Produto "$packageName" não encontrado. Verifique a configuração.');
      }

      debugPrint('✅ Pacote encontrado: ${package.identifier}');
      debugPrint('   Product ID: ${package.storeProduct.identifier}');
      debugPrint('   Preço: ${package.storeProduct.priceString}');
      debugPrint('🚀 Iniciando compra na loja...');

      // Realizar compra
      final purchaseResult = await Purchases.purchasePackage(package);
      final customerInfo = purchaseResult.customerInfo;

      debugPrint('✅ Compra concluída com sucesso!');
      debugPrint('   Entitlements ativos: ${customerInfo.entitlements.active.keys.join(", ")}');

      _onCustomerInfoUpdated(customerInfo);

      _setStatus(PurchaseStatus.success);
      return PurchaseResult.success(customerInfo);
    } on PlatformException catch (e) {
      debugPrint('❌ Erro de plataforma na compra:');
      debugPrint('   Código: ${e.code}');
      debugPrint('   Mensagem: ${e.message}');
      debugPrint('   Detalhes: ${e.details}');

      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      final errorMessage = _getErrorMessage(errorCode);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('ℹ️  Compra cancelada pelo usuário');
        _setStatus(PurchaseStatus.cancelled);
        return PurchaseResult.cancelled();
      }

      debugPrint('❌ Erro na compra: $errorMessage');
      _setStatus(PurchaseStatus.error);
      return PurchaseResult.error(errorMessage);
    } catch (e) {
      debugPrint('❌ Erro inesperado na compra: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
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
      final purchaseResult = await Purchases.purchasePackage(package);
      final customerInfo = purchaseResult.customerInfo;
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
  /// Isso permite sincronizar compras entre dispositivos.
  /// Throws on failure so the caller can handle the error.
  Future<void> logIn(String userId) async {
    if (!RevenueCatConfig.isConfigured) return;

    try {
      final result = await Purchases.logIn(userId);
      _onCustomerInfoUpdated(result.customerInfo);
      debugPrint('Usuário logado no RevenueCat: $userId');
    } catch (e) {
      debugPrint('Erro ao fazer login no RevenueCat: $e');
      rethrow;
    }
  }

  /// Remove associação do usuário.
  /// Throws on failure so the caller can handle the error.
  Future<void> logOut() async {
    if (!RevenueCatConfig.isConfigured) return;

    try {
      final customerInfo = await Purchases.logOut();
      _onCustomerInfoUpdated(customerInfo);
      debugPrint('Usuário deslogado do RevenueCat');
    } catch (e) {
      debugPrint('Erro ao fazer logout do RevenueCat: $e');
      rethrow;
    }
  }

  /// Define atributos do usuário para analytics.
  /// Errors are logged but not thrown since attributes are non-critical.
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
      debugPrint('Erro ao definir atributos do usuário (não-crítico): $e');
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
        return 'Problema com a loja. Tente novamente mais tarde.\n\n'
            'Verifique se você está usando uma conta de teste configurada (sandbox).';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Compras não permitidas neste dispositivo.\n\n'
            'Verifique as configurações de Restrições e Compras In-App.';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'Compra inválida.\n\n'
            'Os produtos podem não estar configurados corretamente nas lojas.';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'Produto não disponível para compra.\n\n'
            'Verifique se:\n'
            '• Os produtos foram criados no App Store Connect / Google Play Console\n'
            '• Os produtos estão com status "Ready to Submit" ou aprovados\n'
            '• Os IDs dos produtos correspondem exatamente aos configurados';
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return 'Você já possui este produto.\n\n'
            'Tente restaurar suas compras.';
      case PurchasesErrorCode.networkError:
        return 'Erro de conexão. Verifique sua internet e tente novamente.';
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return 'Este recibo já está em uso por outra conta.\n\n'
            'Você pode ter criado uma compra com outra conta anteriormente.';
      case PurchasesErrorCode.invalidReceiptError:
        return 'Recibo inválido.\n\n'
            'Tente desinstalar e reinstalar o app.';
      case PurchasesErrorCode.missingReceiptFileError:
        return 'Arquivo de recibo não encontrado.\n\n'
            'Tente fazer logout e login novamente no App Store / Google Play.';
      case PurchasesErrorCode.paymentPendingError:
        return 'Pagamento pendente. Aguarde a confirmação da loja.';
      case PurchasesErrorCode.configurationError:
        return 'Erro de configuração do RevenueCat.\n\n'
            'Verifique as API keys e a configuração no dashboard.';
      case PurchasesErrorCode.invalidCredentialsError:
        return 'Credenciais inválidas.\n\n'
            'Verifique se as API keys do RevenueCat estão corretas.';
      default:
        return 'Erro ao processar compra (código: $errorCode).\n\n'
            'Verifique os logs do console para mais detalhes.';
    }
  }
}
