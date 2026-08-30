import '../content/content_locale.dart';
import '../../l10n/generated/app_localizations.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/revenuecat_config.dart';

AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

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

  /// Desistir não é defeito.
  ///
  /// Existe como CAMPO porque duas telas distinguiam o cancelamento
  /// comparando `errorMessage` com o literal 'Compra cancelada'. Traduzir a
  /// mensagem — que é o que tem de acontecer, ela chega à tela em inglês e
  /// espanhol hoje — faria as duas acusarem erro num cancelamento normal.
  final bool foiCancelada;

  PurchaseResult({
    required this.success,
    this.errorMessage,
    this.customerInfo,
    this.foiCancelada = false,
  });

  factory PurchaseResult.success(CustomerInfo info) {
    return PurchaseResult(success: true, customerInfo: info);
  }

  factory PurchaseResult.error(String message) {
    return PurchaseResult(success: false, errorMessage: message);
  }

  factory PurchaseResult.cancelled() {
    return PurchaseResult(
      success: false,
      foiCancelada: true,
      errorMessage: _l10n.paymentErrCancelled,
    );
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

  /// O `Purchases.configure` rodou de verdade?
  ///
  /// Separado de [_isInitialized], que vira true até nos caminhos de erro
  /// ("continuar sem pagamentos"). Sem esta distinção não havia como saber se
  /// o SDK está de pé — e o `logIn` conferia só a presença da chave, que na
  /// web existe (a `rcb_`) mesmo com o SDK nunca configurado.
  bool _sdkConfigurado = false;
  bool _isPro = false;
  PurchaseStatus _status = PurchaseStatus.idle;
  List<ProductInfo> _products = [];
  CustomerInfo? _customerInfo;
  Offerings? _offerings;
  Future<PurchaseResult> Function(SubscriptionType)? _purchaseOverride;

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
    // Sai cedo só quando não há mais nada a tentar: SDK de pé, ou sem chave
    // para esta plataforma. Um boot que falhou no configure (rede ruim) pode
    // ser retomado por qualquer chamador depois — antes, `_isInitialized`
    // virava true no erro e trancava a sessão inteira sem pagamentos.
    if (_isInitialized &&
        (_sdkConfigurado || !RevenueCatConfig.isConfigured)) {
      debugPrint('ℹ️  RevenueCat já inicializado');
      return;
    }

    debugPrint('🔄 Iniciando RevenueCat...');
    // Platform.* (dart:io) estoura no navegador — só loga fora da web.
    if (!kIsWeb) {
      debugPrint('📋 Plataforma: ${Platform.operatingSystem}');
    }

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
      // Verificar se plataforma é suportada. Na web, quem decide é a presença
      // da chave do RevenueCat Billing (já checada em isConfigured acima).
      if (!kIsWeb && !Platform.isIOS && !Platform.isAndroid) {
        debugPrint('⚠️  Plataforma ${Platform.operatingSystem} não suportada para pagamentos');
        _isInitialized = true;
        return;
      }

      // Configurar RevenueCat
      debugPrint('🔑 Configurando RevenueCat com API key...');
      final configuration = PurchasesConfiguration(RevenueCatConfig.apiKey);

      await Purchases.configure(configuration);
      _sdkConfigurado = true;
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

  /// Um entitlement concedido por ESTE produto vale como Premium?
  ///
  /// Vale dinheiro, e a resposta é sempre não para os avulsos da Leitura do
  /// Ciclo: eles são consumíveis e não devem estar ligados a entitlement
  /// nenhum no painel — o crédito vive na tabela `cycle_readings`. Um
  /// consumível ligado por engano concede o Pro SEM data de expiração, e uma
  /// leitura de R$ 4,99 vira Premium vitalício — a de R$ 249,90, de graça.
  ///
  /// Estática e exposta porque é a regra que o teste tranca: se
  /// `cycleReadingProductIds` esvaziar, a guarda para de guardar em silêncio.
  @visibleForTesting
  static bool entitlementValeComoPro(String productIdentifier) =>
      !RevenueCatConfig.cycleReadingProductIds.contains(productIdentifier);

  /// O entitlement Pro ativo, reduzido ao que o app precisa — ou null quando
  /// não há, e TAMBÉM quando quem o concedeu foi um consumível.
  ///
  /// Ponto único de leitura do entitlement no serviço. Antes, `isLifetime`
  /// documentava o risco do consumível e se defendia sozinho, enquanto
  /// `_updateProStatus` era só um `containsKey` — e é o `isPro` que alimenta
  /// o app inteiro e faz o auth_provider gravar role=premium e persistir.
  /// O guarda estreito valia; o largo não. Agora é um só, e vale para os dois.
  ({String productIdentifier, String? expirationDate})? get _proAtivo {
    final info = _customerInfo;
    if (info == null) return null;

    final pro = info.entitlements.active[RevenueCatConfig.proEntitlementId];
    if (pro == null) return null;

    if (!entitlementValeComoPro(pro.productIdentifier)) {
      debugPrint(
        '⚠️ Entitlement Pro concedido por ${pro.productIdentifier}: um '
        'consumível da Leitura do Ciclo NÃO deveria ter entitlement no '
        'painel do RevenueCat. Ignorando.',
      );
      return null;
    }

    return (
      productIdentifier: pro.productIdentifier,
      expirationDate: pro.expirationDate,
    );
  }

  /// Atualiza status Pro baseado no entitlement
  void _updateProStatus() {
    _isPro = _proAtivo != null;
    debugPrint('Status Pro atualizado: $_isPro');
  }

  /// Verifica se o usuário tem o entitlement Pro ativo
  bool hasPro() => _proAtivo != null;

  /// Carrega ofertas disponíveis
  Future<void> _loadOfferings() async {
    try {
      debugPrint('📦 Buscando ofertas no RevenueCat...');
      _offerings = await Purchases.getOfferings();
      // Os pacotes avulsos resolvidos vieram das ofertas ANTIGAS (com os
      // preços antigos): recarregar as ofertas invalida esse cache.
      _consumablePackages.clear();

      // Nas lojas (App Store/Play) o "current" sempre vem. No RevenueCat
      // Billing (web) há projetos que só têm offerings em `all`, sem marcar
      // uma como current — aí caímos para a primeira disponível, senão a web
      // mostraria "planos indisponíveis" mesmo com produtos cadastrados.
      final offering = _offerings?.current ??
          (_offerings != null && _offerings!.all.isNotEmpty
              ? _offerings!.all.values.first
              : null);

      if (offering == null) {
        debugPrint('⚠️  Nenhuma oferta disponível no RevenueCat');
        debugPrint('💡 Verifique se:');
        debugPrint('   1. A offering "default" existe no dashboard');
        debugPrint('   2. Os produtos estão associados à offering');
        debugPrint('   3. Os produtos foram criados nas lojas (App Store/Google Play)');
        return;
      }

      debugPrint('✅ Offering encontrada: ${offering.identifier}');
      debugPrint('📦 Pacotes disponíveis: ${offering.availablePackages.length}');

      _products = [];

      for (final package in offering.availablePackages) {
        final product = package.storeProduct;

        debugPrint('   📦 ${package.identifier}:');
        debugPrint('      - Product ID: ${product.identifier}');
        debugPrint('      - Título: ${product.title}');
        debugPrint('      - Preço: ${product.priceString}');
        debugPrint('      - Tipo: ${package.packageType}');

        final type = _subscriptionTypeFor(package);
        if (type == null) {
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

  /// Garante que há catálogo, tentando de novo quando ele faltou.
  ///
  /// O catálogo era carregado UMA vez, no boot, e a falha morria num
  /// debugPrint. O `refreshOfferings`, que existiria para tentar de novo, não
  /// tinha nenhum chamador. E as telas que achavam estar garantindo o
  /// catálogo chamavam `initialize()`, que saía na primeira linha porque
  /// `_isInitialized` vira true até no erro. Resultado: um boot com rede ruim
  /// deixava "planos indisponíveis" e o botão de compra desligado pela sessão
  /// inteira, sem retry em lugar nenhum.
  Future<void> garantirCatalogo() async {
    await initialize();
    if (_offerings != null || !_sdkConfigurado) return;

    debugPrint('🔁 Catálogo vazio — tentando carregar de novo');
    await _loadOfferings();
    notifyListeners();
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
    if (kIsWeb) {
      // Os Paywalls do RevenueCat (purchases_ui_flutter) são nativos e não
      // existem na web — a compra no navegador precisa de tela própria.
      debugPrint('ℹ️  Paywall nativo indisponível na web');
      return PaywallResult.cancelled;
    }

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
    // Paywall nativo não existe na web (ver presentPaywall).
    if (kIsWeb) return PaywallResult.cancelled;

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
  /// Abre a gestão da assinatura (ver detalhes, cancelar, pedir reembolso).
  ///
  /// No celular usa o Customer Center nativo do RevenueCat. Na web ele não
  /// existe — abrimos o portal do provedor, cujo endereço o próprio RevenueCat
  /// devolve em `managementURL`, numa aba nova. Sem esse endereço não há para
  /// onde mandar a pessoa; devolve false para a tela poder avisar, em vez de o
  /// botão piscar sem efeito.
  Future<bool> presentCustomerCenter() async {
    if (!_isInitialized || !RevenueCatConfig.isConfigured) {
      debugPrint('RevenueCat não inicializado');
      return false;
    }

    if (kIsWeb) {
      final endereco = _customerInfo?.managementURL;
      if (endereco == null || endereco.isEmpty) {
        debugPrint('ℹ️  Sem managementURL para gerenciar a assinatura');
        return false;
      }
      final uri = Uri.tryParse(endereco);
      if (uri == null) return false;
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    try {
      await RevenueCatUI.presentCustomerCenter();
      await _loadCustomerInfo();
      return true;
    } catch (e) {
      debugPrint('Erro ao apresentar Customer Center: $e');
      return false;
    }
  }

  // ============================================================
  // COMPRAS MANUAIS
  // ============================================================

  /// Realiza uma compra de um tipo específico
  Future<PurchaseResult> purchase(SubscriptionType type) async {
    if (_purchaseOverride != null) return _purchaseOverride!(type);

    debugPrint('🛒 Iniciando compra: $type');

    if (!RevenueCatConfig.isConfigured) {
      debugPrint('❌ Compra falhou: RevenueCat não configurado');
      return PurchaseResult.error(_l10n.paymentNotConfigured);
    }

    _setStatus(PurchaseStatus.loading);

    try {
      debugPrint('📦 Buscando ofertas...');
      final offerings = await Purchases.getOfferings();

      // Mesma tolerância do catálogo: na web a offering pode não estar marcada
      // como current, então caímos para a primeira disponível em `all`.
      final offering = offerings.current ??
          (offerings.all.isNotEmpty ? offerings.all.values.first : null);

      if (offering == null) {
        debugPrint('❌ Nenhuma oferta disponível');
        debugPrint('💡 Verifique se a offering "default" existe no RevenueCat Dashboard');
        _setStatus(PurchaseStatus.error);
        return PurchaseResult.error(_l10n.paymentNoOffers);
      }

      debugPrint('✅ Offering encontrada: ${offering.identifier}');

      // Encontrar o pacote correto. Os atalhos `.monthly/.annual/.lifetime` só
      // acham pacotes com identificador padrão (`$rc_...`) — o que vale nas
      // lojas. No RevenueCat Billing (web) os pacotes costumam ter
      // identificador próprio (PackageType.custom), então caímos para a mesma
      // dedução por identificador usada ao montar o catálogo.
      final packageName = switch (type) {
        SubscriptionType.monthly => 'monthly',
        SubscriptionType.yearly => 'annual',
        SubscriptionType.lifetime => 'lifetime',
      };
      final package = _packageForType(offering, type);

      if (package == null) {
        debugPrint('❌ Pacote $packageName não encontrado na offering');
        debugPrint('💡 Verifique se o produto está associado à offering no RevenueCat Dashboard');
        debugPrint('   Pacotes disponíveis: ${offering.availablePackages.map((p) => p.identifier).join(", ")}');
        _setStatus(PurchaseStatus.error);
        return PurchaseResult.error(_l10n.paymentProductNotFound(packageName));
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
      // O texto da exceção fica no log, não na tela: ele não diz à pessoa o
      // que houve nem o que fazer, e vaza detalhe de SDK.
      return PurchaseResult.error(_l10n.paymentErrUnexpected);
    }
  }

  /// Compra um pacote específico
  Future<PurchaseResult> purchasePackage(Package package) async {
    if (!RevenueCatConfig.isConfigured) {
      return PurchaseResult.error(_l10n.paymentNotConfigured);
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

  // ============================================================
  // CONSUMÍVEIS (compra avulsa — ex.: Leitura do Ciclo)
  // ============================================================

  /// Cache dos pacotes avulsos já resolvidos (por id do produto).
  final Map<String, Package> _consumablePackages = {};

  Future<PurchaseResult> Function(String productId)? _consumableOverride;

  /// Encontra (e cacheia) o pacote de um produto avulso.
  ///
  /// O caminho é SEMPRE por offering/pacote, e não por produto solto, porque
  /// é o único que existe nas três plataformas: no navegador o SDK só
  /// implementa `getOfferings`/`purchasePackage` — `getProducts` e
  /// `purchaseStoreProduct` lançam `UnsupportedPlatformException`.
  ///
  /// Procura primeiro na offering dedicada
  /// ([RevenueCatConfig.cycleReadingsOfferingId]) e depois em qualquer
  /// offering disponível, casando pelo id do produto da loja — assim o app
  /// não depende de como os pacotes foram nomeados no painel.
  Future<Package?> getConsumablePackage(String productId) async {
    if (!RevenueCatConfig.isConfigured) return null;
    final cached = _consumablePackages[productId];
    if (cached != null) return cached;

    try {
      final offerings = _offerings ?? await Purchases.getOfferings();
      _offerings ??= offerings;

      Package? matches(Offering? offering) {
        if (offering == null) return null;
        for (final package in offering.availablePackages) {
          if (package.storeProduct.identifier == productId ||
              package.storeProduct.identifier.startsWith('$productId:') ||
              package.identifier == productId) {
            return package;
          }
        }
        return null;
      }

      final package =
          matches(offerings.all[RevenueCatConfig.cycleReadingsOfferingId]) ??
              matches(offerings.current) ??
              offerings.all.values
                  .map(matches)
                  .firstWhere((p) => p != null, orElse: () => null);

      if (package == null) {
        debugPrint('⚠️ Pacote avulso não encontrado: $productId');
        return null;
      }
      return _consumablePackages[productId] = package;
    } catch (e) {
      debugPrint('❌ Erro ao buscar pacote avulso $productId: $e');
      return null;
    }
  }

  /// Preço formatado de um produto avulso (null quando indisponível).
  Future<String?> getConsumablePriceString(String productId) async =>
      (await getConsumablePackage(productId))?.storeProduct.priceString;

  /// Compra um produto avulso (consumível) pelo id do produto na loja.
  ///
  /// Consumível NÃO gera entitlement: o "crédito" é registrado pelo app
  /// (ex.: tabela `cycle_readings`) — quem chama grava o registro após o
  /// sucesso e só o consome quando o produto for entregue de verdade.
  Future<PurchaseResult> purchaseConsumable(String productId) async {
    if (_consumableOverride != null) return _consumableOverride!(productId);

    if (!RevenueCatConfig.isConfigured) {
      return PurchaseResult.error(_l10n.paymentNotConfigured);
    }

    final package = await getConsumablePackage(productId);
    if (package == null) {
      return PurchaseResult.error(_l10n.paymentProductNotFound(productId));
    }

    // purchasePackage já trata plataforma, cancelamento e erros de loja.
    return purchasePackage(package);
  }

  @visibleForTesting
  void setConsumableOverride(
    Future<PurchaseResult> Function(String productId)? onPurchase,
  ) {
    _consumableOverride = onPurchase;
  }

  /// Restaura compras anteriores
  Future<PurchaseResult> restorePurchases() async {
    if (!RevenueCatConfig.isConfigured) {
      return PurchaseResult.error(_l10n.paymentNotConfigured);
    }

    _setStatus(PurchaseStatus.loading);

    try {
      final customerInfo = await Purchases.restorePurchases();
      _onCustomerInfoUpdated(customerInfo);

      if (_isPro) {
        _setStatus(PurchaseStatus.success);
        return PurchaseResult.success(customerInfo);
      }

      // Sem assinatura, ainda pode haver compra avulsa: a Leitura do Ciclo é
      // consumível e nunca aparece em `entitlements`. Dizer "nenhuma compra
      // encontrada" a quem pagou uma leitura era mentira — e era o único
      // lugar do app onde ela poderia descobrir que a loja tem registro.
      if (comprasAvulsasNaLoja.isNotEmpty) {
        _setStatus(PurchaseStatus.success);
        return PurchaseResult.success(customerInfo);
      }

      _setStatus(PurchaseStatus.idle);
      return PurchaseResult.error(_l10n.paymentErrNothingToRestore);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      _setStatus(PurchaseStatus.error);
      return PurchaseResult.error(_getErrorMessage(errorCode));
    } catch (e) {
      // O texto cru da exceção não vai para a tela: ele carrega URL de
      // provedor e detalhe de SDK, e não diz à pessoa o que fazer.
      debugPrint('Erro ao restaurar: $e');
      _setStatus(PurchaseStatus.error);
      return PurchaseResult.error(_l10n.paymentErrRestore);
    }
  }

  /// Os avulsos que a loja tem registrados para esta pessoa.
  ///
  /// `nonSubscriptionTransactions` é onde o RevenueCat guarda consumível, e
  /// não aparecia em lugar nenhum do app — por isso "paguei e o app não sabe"
  /// não tinha nem como ser diagnosticado. Aqui ele vira sinal.
  ///
  /// ATENÇÃO: é histórico de compra, não saldo. Uma leitura já usada continua
  /// listada. Serve para saber que a loja cobrou, nunca para conceder
  /// crédito — quem devolve crédito é o registro de compra pendente da tela
  /// da Leitura do Ciclo, que sabe QUAL janela foi paga.
  List<String> get comprasAvulsasNaLoja {
    final info = _customerInfo;
    if (info == null) return const [];

    return info.nonSubscriptionTransactions
        .map((t) => t.productIdentifier)
        .where(RevenueCatConfig.cycleReadingProductIds.contains)
        .toList(growable: false);
  }

  // ============================================================
  // GERENCIAMENTO DE USUÁRIO
  // ============================================================

  /// Associa usuário (ex: do Supabase) ao RevenueCat
  ///
  /// Isso permite sincronizar compras entre dispositivos
  Future<void> logIn(String userId) async {
    // O catálogo é resolvido POR CLIENTE do RevenueCat (moeda, loja,
    // segmentação, experimentos). Trocar de conta sem esvaziar estes caches
    // faz a conta nova herdar o catálogo da anterior — e, quando o pacote
    // herdado não vale para ela, os preços somem e a compra não abre. Como
    // `logIn` também é chamado ao adotar a sessão do servidor (retorno do
    // OAuth na web), sem logout no meio, esta limpeza precisa estar AQUI, e
    // não só no logOut.
    _offerings = null;
    _consumablePackages.clear();

    if (!RevenueCatConfig.isConfigured) return;

    // `isConfigured` diz que EXISTE chave, não que o SDK subiu. Era essa a
    // confusão que quebrava a web: a chave `rcb_` existe, o
    // `Purchases.configure` nunca tinha rodado (o boot pulava a
    // inicialização na web), o `logIn` estourava e o catch abaixo engolia.
    // A compra ficava num usuário anônimo do RevenueCat, sem ligação com a
    // conta do Supabase — e `logIn` é o único ponto de associação do app.
    if (!_sdkConfigurado) {
      await initialize();
      if (!_sdkConfigurado) {
        debugPrint('⚠️  RevenueCat não configurado: logIn adiado');
        return;
      }
    }

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
    // Zera o estado local imediatamente: a fonte única de premium
    // (isPremiumEffective/PremiumAccess) depende de isPro=false após logout.
    _customerInfo = null;
    _isPro = false;
    // A próxima conta pode estar em outra loja/moeda: nem os pacotes avulsos
    // nem as offerings resolvidas para esta sessão valem para ela.
    _offerings = null;
    _consumablePackages.clear();
    notifyListeners();

    if (!RevenueCatConfig.isConfigured) return;

    try {
      await Purchases.logOut();
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

  /// Quanto o plano anual economiza em relação a doze mensais, em porcento.
  ///
  /// Null quando NÃO dá para calcular — e aí o selo simplesmente não aparece.
  /// Era texto fixo num ARB ("Economize 50%"), o que é uma conta com dois
  /// números que o app não tinha na mão: se a loja devolver outro preço, se a
  /// pessoa estiver fora do Brasil, ou se o catálogo não carregou, o selo
  /// mentia. Um número inventado numa tela de venda custa mais confiança do
  /// que a ausência do selo.
  int? get economiaAnualEmPorcento {
    final mensal = getProduct(SubscriptionType.monthly);
    final anual = getProduct(SubscriptionType.yearly);
    if (mensal == null || anual == null) return null;

    return economiaEntre(
      mensal: mensal.price,
      anual: anual.price,
      moedaMensal: mensal.currencyCode,
      moedaAnual: anual.currencyCode,
    );
  }

  /// A conta do selo, isolada para teste.
  ///
  /// Devolve null em tudo que não dá para afirmar: moedas diferentes (o
  /// catálogo às vezes vem meio resolvido), preço zerado, ou anual que não
  /// economiza nada. Melhor sem selo do que com número errado.
  @visibleForTesting
  static int? economiaEntre({
    required double mensal,
    required double anual,
    required String moedaMensal,
    required String moedaAnual,
  }) {
    if (moedaMensal != moedaAnual) return null;
    if (mensal <= 0 || anual <= 0) return null;

    final dozeMeses = mensal * 12;
    if (anual >= dozeMeses) return null;

    final porcento = ((1 - anual / dozeMeses) * 100).round();
    // Abaixo de 1% não há o que comemorar, e 100% seria de graça.
    return (porcento < 1 || porcento >= 100) ? null : porcento;
  }

  /// Deduz o tipo de assinatura de um pacote.
  ///
  /// Nas lojas (App Store/Play) o RevenueCat entrega os pacotes já com
  /// `PackageType.monthly/annual/lifetime`. No RevenueCat Billing (web), porém,
  /// os pacotes costumam vir como `PackageType.custom` — o identificador não é
  /// um dos `$rc_` padrão. Se dependêssemos só do `packageType`, na web TODOS
  /// os pacotes seriam descartados: a tela mostraria "planos indisponíveis" e o
  /// Vitalício nunca apareceria. Por isso, quando o tipo não é uma duração
  /// reconhecida, caímos para o identificador do pacote/produto.
  SubscriptionType? _subscriptionTypeFor(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:
        return SubscriptionType.monthly;
      case PackageType.annual:
        return SubscriptionType.yearly;
      case PackageType.lifetime:
        return SubscriptionType.lifetime;
      default:
        return subscriptionTypeFromIdentifier(
          '${package.identifier} ${package.storeProduct.identifier}',
        );
    }
  }

  /// Casa um identificador (do pacote e/ou do produto) com um tipo de
  /// assinatura. Só usado como plano B, quando o `packageType` não diz a
  /// duração — o caso da web.
  ///
  /// Evita de propósito os tokens curtos "ano"/"mes": ambos são substring de
  /// palavras comuns em português (ex.: "plano" contém "ano"), o que
  /// classificaria errado. "anual"/"mensal" já cobrem o português com
  /// segurança.
  @visibleForTesting
  static SubscriptionType? subscriptionTypeFromIdentifier(String raw) {
    final id = raw.toLowerCase();
    if (id.contains('lifetime') || id.contains('vitalic')) {
      return SubscriptionType.lifetime;
    }
    if (id.contains('annual') ||
        id.contains('anual') ||
        id.contains('yearly') ||
        id.contains('year')) {
      return SubscriptionType.yearly;
    }
    if (id.contains('monthly') ||
        id.contains('mensal') ||
        id.contains('month')) {
      return SubscriptionType.monthly;
    }
    return null;
  }

  /// Acha o pacote de um tipo dentro de uma offering.
  ///
  /// Tenta primeiro os atalhos do RevenueCat (que só valem para os
  /// identificadores `$rc_` padrão das lojas) e, se não achar, varre os
  /// pacotes deduzindo o tipo pelo identificador — assim a compra também
  /// funciona na web, onde os pacotes têm nome próprio.
  Package? _packageForType(Offering offering, SubscriptionType type) {
    final direct = switch (type) {
      SubscriptionType.monthly => offering.monthly,
      SubscriptionType.yearly => offering.annual,
      SubscriptionType.lifetime => offering.lifetime,
    };
    if (direct != null) return direct;

    for (final package in offering.availablePackages) {
      if (_subscriptionTypeFor(package) == type) return package;
    }
    return null;
  }

  @visibleForTesting
  void setTestProducts(
    List<ProductInfo> products, {
    Future<PurchaseResult> Function(SubscriptionType)? onPurchase,
  }) {
    _products = List<ProductInfo>.of(products);
    _purchaseOverride = onPurchase;
    _isInitialized = true;
    _status = PurchaseStatus.idle;
    notifyListeners();
  }

  @visibleForTesting
  void clearTestProducts() {
    _products = [];
    _purchaseOverride = null;
    _status = PurchaseStatus.idle;
    notifyListeners();
  }

  /// Verifica se há assinatura ativa
  bool get hasActiveSubscription {
    if (_customerInfo == null) return false;
    return _customerInfo!.entitlements.active.isNotEmpty;
  }

  /// O RevenueCat REALMENTE respondeu sobre este cliente?
  ///
  /// `_customerInfo` só é não-nulo depois de um `getCustomerInfo`/update bem
  /// sucedido. Distingue "sei que NÃO é Pro" de "não consegui verificar" — e
  /// essa diferença vale dinheiro: sem ela, `isPro == false` por falha de
  /// carregamento (o caso da web / rede ruim, onde o SDK às vezes nem sobe)
  /// era lido como "não é assinante", e o boot rebaixava para Free um
  /// assinante válido cujo acesso o servidor já concedeu (o espelho de
  /// `profiles`). Enquanto o status é desconhecido, mantém-se o acesso.
  bool get subscriptionStatusKnown => _customerInfo != null;

  /// Deve rebaixar para Free com base no RevenueCat?
  ///
  /// Só com sinal POSITIVO de que a assinatura não vale mais: RevenueCat
  /// consultado ([statusConhecido]) E dizendo que não é Pro. NUNCA rebaixa por
  /// não ter conseguido consultar (mantém o acesso do espelho/servidor), nem
  /// vitalício (Código Premium/compra), nem admin. É a trava central do
  /// "nunca perde acesso enquanto o plano vigorar".
  ///
  /// Pública (não `@visibleForTesting`) porque é usada em produção pelo
  /// AuthProvider (`_checkSubscriptionExpiration`/`refreshPremiumStatus`), e
  /// não só nos testes — a lógica de rebaixar mora aqui, num único lugar.
  static bool deveRebaixar({
    required bool statusConhecido,
    required bool isPro,
    required bool isLifetime,
    required bool isAdmin,
  }) {
    if (isAdmin || isLifetime) return false;
    if (!statusConhecido) return false;
    return !isPro;
  }

  /// Data de expiração da assinatura (se houver)
  DateTime? get subscriptionExpirationDate {
    final expirationDate = _proAtivo?.expirationDate;
    if (expirationDate == null) return null;

    return DateTime.tryParse(expirationDate);
  }

  /// Verifica se a assinatura é vitalícia.
  ///
  /// Vale dinheiro: é este getter que libera a Leitura da Lunação sem
  /// cobrança. A defesa contra o consumível que virou entitlement mora em
  /// [_proAtivo], junto com a do `isPro` — aqui sobra só a regra do vitalício.
  bool get isLifetime {
    final pro = _proAtivo;
    if (pro == null) return false;

    // Lifetime não tem data de expiração
    return pro.expirationDate == null;
  }

  /// O TIPO da assinatura Pro ativa (mensal/anual/vitalícia), ou null quando
  /// não há entitlement Pro.
  ///
  /// Existe para o app rotular o plano CERTO: o atalho `isLifetime ? lifetime
  /// : monthly` colapsava o ANUAL em mensal (o servidor, via webhook, já
  /// gravava `yearly` correto, mas o rótulo local não). Sem expiração ⇒
  /// vitalício; com expiração, deduz mensal/anual pelo id do produto (mesma
  /// regra de [subscriptionTypeFromIdentifier]), caindo em mensal só quando o
  /// id não diz a duração.
  SubscriptionType? get activeSubscriptionType {
    final pro = _proAtivo;
    if (pro == null) return null;
    if (pro.expirationDate == null) return SubscriptionType.lifetime;
    return subscriptionTypeFromIdentifier(pro.productIdentifier) ??
        SubscriptionType.monthly;
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
        return _l10n.paymentErrCancelled;
      case PurchasesErrorCode.storeProblemError:
        return _l10n.paymentErrStore;
      case PurchasesErrorCode.purchaseNotAllowedError:
        return _l10n.paymentErrNotAllowed;
      case PurchasesErrorCode.purchaseInvalidError:
        return _l10n.paymentErrInvalid;
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return _l10n.paymentErrUnavailable;
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return _l10n.paymentErrAlreadyOwned;
      case PurchasesErrorCode.networkError:
        return _l10n.paymentErrNetwork;
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return _l10n.paymentErrReceiptInUse;
      case PurchasesErrorCode.invalidReceiptError:
        return _l10n.paymentErrInvalidReceipt;
      case PurchasesErrorCode.missingReceiptFileError:
        return _l10n.paymentErrMissingReceipt;
      case PurchasesErrorCode.paymentPendingError:
        return _l10n.paymentErrPending;
      case PurchasesErrorCode.configurationError:
        return _l10n.paymentErrConfiguration;
      case PurchasesErrorCode.invalidCredentialsError:
        return _l10n.paymentErrCredentials;
      default:
        return _l10n.paymentErrGeneric('$errorCode');
    }
  }
}
