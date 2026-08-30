import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/theme_provider.dart';
import 'core/widgets/boot_error_app.dart';
import 'core/widgets/web_mobile_frame.dart';
import 'core/database/database_helper.dart';
import 'core/database/records_archive_migration.dart';
import 'core/providers/mascot_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/sync_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/services/ad_service.dart';
import 'core/services/payment_service.dart';
import 'core/services/debug_log_service.dart';
import 'core/services/data_sync_service.dart';
import 'core/navigation/app_deep_link.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/section_reset_notifier.dart';
import 'core/utils/app_session_policy.dart';
import 'features/auth/auth.dart';
import 'features/grimoire/presentation/providers/spell_provider.dart';
import 'features/diary/presentation/providers/dream_provider.dart';
import 'features/diary/presentation/providers/desire_provider.dart';
import 'features/diary/presentation/providers/gratitude_provider.dart';
import 'features/diary/presentation/providers/affirmation_provider.dart';
import 'features/diary/presentation/providers/free_writing_provider.dart';
import 'features/learning/presentation/providers/learning_provider.dart';
import 'features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'features/encyclopedia/presentation/providers/encyclopedia_provider.dart';
import 'features/lunar/presentation/providers/lunar_provider.dart';
import 'features/wheel_of_year/presentation/providers/wheel_of_year_provider.dart';
import 'features/astrology/presentation/providers/astrology_provider.dart';
import 'core/navigation/janela_de_login.dart';
import 'core/navigation/observador_de_rotas_raiz.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// A chave do Navigator raiz do go_router (`criarAppRouter`).
///
/// Fora da classe de propósito: é passada ao router na criação e usada por
/// alguns pontos que precisam do Navigator raiz de fora da árvore (o deep link
/// que revela a Home fechando telas cheias, e a espera do boot pela montagem).
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// O router do app, exposto no nível de biblioteca para os poucos pontos que
/// navegam de FORA da árvore de widgets (o retorno do link de recuperação de
/// senha, que chega durante o boot). Preenchido pelo estado do app ao montar.
GoRouter? _routerGlobal;

/// Marca de recuperação de senha pendente. Persistida porque, NA WEB, o
/// AuthWrapper descarta o documento da volta do OAuth com um
/// `recomecarNaRaiz()` — e o retorno do link de recuperação passa por esse
/// mesmo caminho (o fragment tem access_token): um push feito antes do
/// recomeço morre com o documento. A marca sobrevive e o boot seguinte
/// abre a tela. Validade curta: uma marca velha não pode abrir a troca de
/// senha numa sessão qualquer semanas depois.
const String _chaveRecuperacaoPendente = 'pending_password_recovery';
const Duration _validadeRecuperacaoPendente = Duration(minutes: 15);

/// Abre a troca de senha do fluxo "esqueci minha senha".
///
/// Na web o evento `passwordRecovery` chega DURANTE o boot — o
/// `Supabase.initialize` troca o token da URL antes de o Navigator raiz
/// existir — então espera-se o navegador montar, frame a frame, com um
/// teto de tentativas para não rodar para sempre num boot que falhou.
void _abrirTrocaDeSenhaDaRecuperacao([int tentativas = 0]) {
  final router = _routerGlobal;
  if (router == null || _rootNavigatorKey.currentState == null) {
    if (tentativas > 600) return; // boot não montou o app; desiste em silêncio
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _abrirTrocaDeSenhaDaRecuperacao(tentativas + 1));
    return;
  }
  // Consumida: aconteça o que acontecer com esta tela, o próximo boot não
  // deve reabri-la.
  unawaited(SharedPreferences.getInstance()
      .then((p) => p.remove(_chaveRecuperacaoPendente)));
  router.go(rotaRecuperarSenha);
}

/// Os tipos de link de e-mail que o app sabe verificar por `token_hash`.
/// Só os que o Grimório emite — cada valor a mais é superfície sem uso.
OtpType? _tipoDeLinkDeEmail(String? tipo) => switch (tipo) {
      'signup' => OtpType.signup,
      'email' => OtpType.email,
      'recovery' => OtpType.recovery,
      _ => null,
    };

/// Verifica um link de e-mail que chega como `?token_hash=...&type=...`.
///
/// SÓ NA WEB. No celular o link volta pelo deep link do próprio Supabase,
/// que resolve a sessão sozinho — lá o verificador PKCE está no
/// armazenamento do app, então o caminho de sempre funciona e não há o que
/// consertar.
///
/// Nunca propaga erro: link expirado ou já usado é caminho normal (o
/// primeiro clique é o que vale), e a saída é entrar com e-mail e senha.
Future<void> _verificarLinkDeEmailDaUrl() async {
  if (!kIsWeb) return;
  final tokenHash = Uri.base.queryParameters['token_hash'];
  if (tokenHash == null || tokenHash.isEmpty) return;

  final tipo = _tipoDeLinkDeEmail(Uri.base.queryParameters['type']);
  if (tipo == null) {
    await debugLog('AUTH', 'Link de e-mail com tipo desconhecido na URL');
    return;
  }

  try {
    await Supabase.instance.client.auth.verifyOTP(
      tokenHash: tokenHash,
      type: tipo,
    );
    await debugLog('AUTH', 'Link de e-mail verificado (${tipo.name})');

    // A URL ainda carrega o token de uso único. Marcar como retorno faz o
    // AuthWrapper recomeçar na raiz (o mesmo caminho do login social), o
    // que limpa a URL e tira o token do histórico da aba.
    AuthProvider.bootCameFromOAuthReturn = true;

    if (tipo == OtpType.recovery) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          _chaveRecuperacaoPendente, DateTime.now().millisecondsSinceEpoch);
    }
  } catch (e) {
    await debugLog('AUTH', 'Link de e-mail não verificou: $e');
    AuthProvider.linkDeEmailExpirado = true;
  }
}

void main() {
  // Zona guardada: erros assíncronos não capturados (fora do ciclo de build)
  // são logados em vez de derrubarem o app silenciosamente — na web eles
  // viravam um "Uncaught Error" minificado no console e tela branca.
  runZonedGuarded<void>(() async {
    // Precisa rodar DENTRO da zona: binding e runApp na mesma zona, senão o
    // Flutter emite aviso de "Zone mismatch" e os erros escapam da guarda.
    WidgetsFlutterBinding.ensureInitialized();

    // O CONSERTO DE VERDADE DO VOLTAR: URL de caminho por tela.
    //
    // Com `usePathUrlStrategy()` + `MaterialApp.router` + o [criarAppRouter], o
    // Flutter passa a usar `MultiEntriesBrowserHistory` — cada tela vira uma
    // entrada de histórico de verdade, e o gesto de voltar do navegador
    // desempilha telas de verdade. Isso substitui o antigo "corrimão" de
    // degraus (`web/index.html`) e o `PorteiroDoVoltar`, que existiam só porque
    // o app vivia dentro de UMA entrada de histórico.
    if (kIsWeb) usePathUrlStrategy();

    // Erros do framework (build/layout) também vão para o log persistente,
    // mantendo o comportamento padrão de apresentação.
    FlutterError.onError = (details) {
      unawaited(
        debugLog('ERROR', 'FlutterError: ${details.exceptionAsString()}'),
      );
      FlutterError.presentError(details);
    };

    // Erros de build/render não passam pelo try/catch do _boot; em release o
    // ErrorWidget padrão é um retângulo cinza mudo. Detalhe técnico só onde
    // ele serve (web e debug) — ver buildRenderErrorWidget.
    ErrorWidget.builder = buildRenderErrorWidget;

    await _boot();
  }, (error, stackTrace) {
    debugPrint('Erro não capturado (zona): $error\n$stackTrace');
    unawaited(debugLog('ERROR', 'Erro não capturado (zona): $error'));
  });
}

/// Executa a inicialização e sobe o app; se qualquer passo do boot estourar,
/// renderiza a tela de erro de diagnóstico no lugar da tela branca.
/// Permanente (produção inclusive), não só debug.
Future<void> _boot() async {
  try {
    final prefs = await _initializeApp();
    runApp(GrimorioDeBolsoApp(prefs: prefs));
  } catch (error, stackTrace) {
    debugPrint('Boot falhou: $error\n$stackTrace');
    unawaited(debugLog('ERROR', 'Boot falhou: $error'));
    runApp(BootErrorApp(
      error: error,
      stackTrace: stackTrace,
      onRetry: _boot,
    ));
  }
}

/// Todos os passos de inicialização que antecedem o runApp.
/// Qualquer exceção aqui é capturada por [_boot] e exibida na [BootErrorApp].
Future<SharedPreferences> _initializeApp() async {
  // Initialize debug log service FIRST
  await DebugLogService().initialize();
  await debugLog('SYSTEM', 'App iniciando...');

  // Initialize sqflite for web.
  //
  // Usa o modo SEM web worker: o SQLite (sqlite3.wasm) roda na própria
  // thread principal, carregado diretamente. Evita o SharedWorker, que
  // exige secure context e é fonte de falhas silenciosas ("unsupported
  // result null" no boot) quando não sobe. Para um grimório pessoal de
  // uma aba só, não há necessidade de compartilhar o banco entre abas,
  // então o worker não traz benefício e só adiciona um ponto de falha.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
    await debugLog('SYSTEM', 'sqflite web (no web worker) configurado');
  }

  // Necessário para os agendamentos locais de Lua e Sabbats.
  tz.initializeTimeZones();

  // Initialize date formatting for Portuguese locale
  await initializeDateFormatting('pt_BR', null);
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('es', null);
  await debugLog('SYSTEM', 'Timezones e formatos de data prontos');

  // Initialize database
  await DatabaseHelper.instance.database;
  await debugLog('SYSTEM', 'Banco de dados aberto');

  // Registrar AGORA se este boot é a volta de um login social: o
  // Supabase.initialize pode limpar o ?code= da URL enquanto a troca do
  // código ainda está em voo, e depois dele não há mais como saber.
  // O AuthWrapper usa isso para segurar uma tela de "entrando..." em vez
  // de despejar a pessoa na tela de login com a sessão a caminho.
  AuthProvider.bootCameFromOAuthReturn = kIsWeb &&
      (Uri.base.queryParameters.containsKey('code') ||
          Uri.base.fragment.contains('access_token'));

  // E se este boot é a JANELA DE LOGIN voltando do Google: a marca fica no
  // armazenamento da origem porque o COOP do Google apaga o `opener` — sem
  // ela, a janela viraria um segundo app, com as páginas do Google no
  // histórico dela (o defeito do voltar, de volta pela porta dos fundos).
  // O AuthWrapper mostra então o "pode fechar esta aba".
  if (AuthProvider.bootCameFromOAuthReturn) {
    final prefs = await SharedPreferences.getInstance();
    final marca =
        int.tryParse(prefs.getString(chaveJanelaDeLoginEmAndamento) ?? '');
    AuthProvider.bootNaJanelaDeLogin = marca != null &&
        DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(marca)) <
            validadeDaMarcaDeJanela;
  }

  // Initialize Supabase
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // anonKey foi deprecado (sai na próxima major do supabase_flutter);
      // o parâmetro novo aceita a mesma chave.
      publishableKey: SupabaseConfig.anonKey,
    );
    // Link de e-mail no formato `token_hash` (ver docs/email_templates):
    // verificação que NÃO depende do verificador PKCE — aquele vive no
    // armazenamento de QUEM PEDIU o cadastro, e o link quase sempre abre em
    // outro navegador (o do app de e-mail), onde ele não existe. Sem isto, o
    // clique no link terminava sem sessão nenhuma.
    await _verificarLinkDeEmailDaUrl();

    // Initialize DataSyncService after Supabase
    DataSyncService().initialize();
    await debugLog('SYNC', 'DataSyncService inicializado');

    // O retorno do link de "esqueci minha senha": o supabase_flutter troca
    // o token da URL (web) ou do deep link (celular) por uma sessão de
    // recuperação e emite este evento — e até aqui NINGUÉM o ouvia: a
    // pessoa aterrissava logada sem ser convidada a trocar a senha. Abre a
    // tela de troca em modo recuperação (sem pedir a senha atual, que é
    // justamente o que ela não sabe).
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        unawaited(debugLog('AUTH', 'Evento passwordRecovery → troca de senha'));
        // A marca primeiro: na web este documento pode ser descartado pelo
        // recomeço do AuthWrapper antes de a tela abrir.
        unawaited(SharedPreferences.getInstance().then((p) => p.setInt(
            _chaveRecuperacaoPendente,
            DateTime.now().millisecondsSinceEpoch)));
        _abrirTrocaDeSenhaDaRecuperacao();
      }
    });

    // O boot pós-recomeço da web: o evento já disparou no documento
    // anterior (descartado), sobrou a marca. Sessão viva + marca fresca =
    // a pessoa acabou de chegar pelo link de recuperação.
    final prefsRecuperacao = await SharedPreferences.getInstance();
    final marcaRecuperacao =
        prefsRecuperacao.getInt(_chaveRecuperacaoPendente);
    if (marcaRecuperacao != null) {
      final fresca = DateTime.now()
              .difference(
                  DateTime.fromMillisecondsSinceEpoch(marcaRecuperacao)) <
          _validadeRecuperacaoPendente;
      if (fresca && Supabase.instance.client.auth.currentSession != null) {
        await debugLog('AUTH', 'Recuperação pendente do boot anterior');
        _abrirTrocaDeSenhaDaRecuperacao();
      } else {
        await prefsRecuperacao.remove(_chaveRecuperacaoPendente);
      }
    }
  }

  // Initialize RevenueCat — TAMBÉM na web.
  //
  // Pular a web deixava o `Purchases.configure` sem rodar no navegador. Aí o
  // `logIn`, que é o único ponto onde a compra é associada à conta do
  // Supabase, estourava e o erro morria num debugPrint: quem comprava pelo
  // navegador ficava num usuário anônimo do RevenueCat, sem ligação nenhuma
  // com a própria conta. Era o único defeito de pagamento que atingia todo
  // mundo que compra pela web.
  //
  // Quem decide se há pagamento é a presença da chave — na web, a `rcb_` do
  // RevenueCat Billing. Sem chave, o `initialize` sai na primeira linha e
  // nada quebra.
  await PaymentService().initialize();
  await debugLog('SYSTEM', 'PaymentService inicializado');

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Acervo único: move os registros do Grimório Vivo (antigos feitiços com
  // id 'registro_*') para free_writings. Roda uma vez; falha não bloqueia.
  await RecordsArchiveMigration().run(prefs);

  // Initialize notifications (only for mobile platforms)
  if (!kIsWeb) {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // Toque em notificação com o app aberto/em background: navega para a
      // página do evento (lua → Enciclopédia da Lua, sabbat → Sabbats etc.).
      onDidReceiveNotificationResponse: (response) =>
          DeepLinkService.instance.dispatchPayload(response.payload),
    );

    // App ABERTO por uma notificação (estava encerrado): o payload chega
    // aqui antes do runApp; HomePage/seções leem o link pendente ao montar.
    final launchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      DeepLinkService.instance
          .dispatchPayload(launchDetails!.notificationResponse?.payload);
    }

    // Anúncios (free): inicialização em segundo plano, sem atrasar o boot.
    unawaited(AdService.instance.initialize());
  }

  await debugLog('SYSTEM', 'Boot concluído, subindo a UI');
  return prefs;
}

class GrimorioDeBolsoApp extends StatefulWidget {
  final SharedPreferences prefs;

  const GrimorioDeBolsoApp({super.key, required this.prefs});

  @override
  State<GrimorioDeBolsoApp> createState() => _GrimorioDeBolsoAppState();
}

class _GrimorioDeBolsoAppState extends State<GrimorioDeBolsoApp>
    with WidgetsBindingObserver {
  static const String _lastOpenedKey = 'last_opened_timestamp';
  static const String _backgroundedAtKey = 'backgrounded_at_timestamp';
  bool _showSplash = true;

  /// Instância única do Salem, viva pelo app inteiro: o "refresh" de sessão
  /// (30 min em background) precisa chamar show() para o gatinho escondido
  /// voltar — o esconderijo nunca sobrevive a uma sessão nova.
  late final MascotProvider _mascotProvider = MascotProvider(widget.prefs);

  /// O AuthProvider é ICADO para fora do MultiProvider: o router precisa lê-lo
  /// no `redirect` e reagir a ele (`refreshListenable`). Continua exposto na
  /// árvore por `.value` (mesma posição — a ORDEM importa para os ProxyProviders
  /// abaixo dele).
  final AuthProvider _authProvider = AuthProvider()..initialize();

  /// Chaves dos Navigators de aba e notificadores de reset por seção — criados
  /// aqui (vida = app) e compartilhados entre o router e o shell.
  final List<GlobalKey<NavigatorState>> _chavesDeAba =
      List.generate(4, (_) => GlobalKey<NavigatorState>());
  final List<SectionResetNotifier> _resetNotifiers =
      List.generate(4, (_) => SectionResetNotifier());

  late final GoRouter _appRouter = criarAppRouter(
    chaveRaiz: _rootNavigatorKey,
    auth: _authProvider,
    chavesDeAba: _chavesDeAba,
    resetNotifiers: _resetNotifiers,
    consumirSplashInicial: _consumirSplashInicial,
    observadoresRaiz: [ObservadorDeRotasRaiz()],
  );

  bool _consumirSplashInicial() {
    final mostrar = _showSplash;
    _showSplash = false;
    return mostrar;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DeepLinkService.instance.pending.addListener(_onDeepLink);
    _decidirSplashInicial();
    // Exposto para os pontos que navegam de fora da árvore (a volta do link de
    // recuperação de senha, que chega durante o boot). Acessar `_appRouter`
    // aqui já o instancia — ele não depende de BuildContext.
    _routerGlobal = _appRouter;
    // Restaura os dados automaticamente quando o app inicia com uma sessão
    // Premium já ativa. O próprio método valida preferência e disponibilidade.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), _triggerBackgroundSync);
    });
  }

  @override
  void dispose() {
    DeepLinkService.instance.pending.removeListener(_onDeepLink);
    WidgetsBinding.instance.removeObserver(this);
    _mascotProvider.dispose();
    for (final n in _resetNotifiers) {
      n.dispose();
    }
    _authProvider.dispose();
    super.dispose();
  }

  /// Um deep link chegou (toque em notificação): fecha fluxos de tela cheia
  /// (Configurações, Assinatura...) para revelar a HomePage, que fará a troca
  /// de aba. A seção de destino consome o link ao concluir a navegação.
  void _onDeepLink() {
    if (DeepLinkService.instance.pending.value == null) return;
    _rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  /// Decide o splash de marca ANTES da primeira montagem, de forma síncrona (o
  /// shell consome a decisão uma vez, ao montar). Se o app foi aberto nos
  /// últimos 30 min, é volta de background, não fechamento — sem splash.
  void _decidirSplashInicial() {
    final lastOpened = widget.prefs.getInt(_lastOpenedKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    _showSplash = (now - lastOpened) >= 30 * 60 * 1000;
    unawaited(widget.prefs.setInt(_lastOpenedKey, now));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.prefs.setInt(
        _backgroundedAtKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return;
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(_handleAppResumed());
    }
  }

  Future<void> _handleAppResumed() async {
    final now = DateTime.now();
    final backgroundedTimestamp = widget.prefs.getInt(_backgroundedAtKey);
    final backgroundedAt = backgroundedTimestamp == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(backgroundedTimestamp);
    final shouldStartNewSession = AppSessionPolicy.shouldStartNewSession(
      backgroundedAt: backgroundedAt,
      now: now,
    );

    await widget.prefs.remove(_backgroundedAtKey);
    await widget.prefs.setInt(_lastOpenedKey, now.millisecondsSinceEpoch);

    if (shouldStartNewSession && mounted) {
      // Sessão nova = Salem de volta (o esconderijo é sempre temporário) e a
      // navegação recomeça no Seu Dia, descartando as páginas internas.
      _mascotProvider.show();
      _appRouter.go(rotaSeuDia);
    }

    await _triggerBackgroundSync();
  }

  /// Carimbo da última TENTATIVA de sincronização automática (ver
  /// [AppSessionPolicy.deveAutoSincronizar] para o porquê de ser tentativa,
  /// e não sucesso).
  static const _ultimaTentativaDeSyncKey = 'auto_sync_tentado_em';

  Future<void> _triggerBackgroundSync() async {
    final syncService = DataSyncService();
    // Sem trava de plano: sincronizar é de todo mundo. O que ainda decide é
    // a preferência da pessoa e haver conta (`isReady`).
    final syncEnabled = await syncService.cloudSyncEnabled;
    if (!syncEnabled || !syncService.isReady) return;

    final carimbo = widget.prefs.getInt(_ultimaTentativaDeSyncKey);
    final podeSincronizar = AppSessionPolicy.deveAutoSincronizar(
      ultimaTentativa: carimbo == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(carimbo),
      now: DateTime.now(),
    );
    if (!podeSincronizar) return;
    // Carimba ANTES de sair: uma varredura que falha (ou que demora e
    // encontra outra volta para a aba no meio) não pode reabrir a porta.
    await widget.prefs.setInt(
      _ultimaTentativaDeSyncKey,
      DateTime.now().millisecondsSinceEpoch,
    );

    await debugLog('SYNC', 'Auto-sync iniciado em background');
    final result = await syncService.syncAll();
    if (result.success) {
      await debugLog('SYNC', 'Auto-sync concluído com sucesso');
    } else {
      await debugLog('SYNC', 'Auto-sync falhou: ${result.detailedError}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(widget.prefs)),
        ChangeNotifierProvider.value(value: _mascotProvider),
        // ATENÇÃO À ORDEM: todo ChangeNotifierProxyProvider<AuthProvider, X>
        // precisa vir DEPOIS desta linha — ele lê o AuthProvider do contexto
        // acima de si mesmo, e não o encontra se for declarado antes.
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProxyProvider<AuthProvider, LearningProvider>(
          create: (_) => LearningProvider(),
          update: (_, auth, provider) {
            provider!.setUserId(auth.currentUser.id);
            return provider;
          },
        ),
        // Check-in diário: registra a visita e mantém a sequência de dias.
        ChangeNotifierProxyProvider<AuthProvider, DailyCheckinProvider>(
          create: (_) => DailyCheckinProvider(),
          update: (_, auth, provider) {
            provider!.setUserId(auth.currentUser.id);
            return provider;
          },
        ),
        ChangeNotifierProvider.value(value: PaymentService()),
        ChangeNotifierProvider(create: (_) => LanguageProvider(widget.prefs)),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        // SpellProvider agora depende de AuthProvider para filtrar por usuário
        ChangeNotifierProxyProvider<AuthProvider, SpellProvider>(
          create: (context) => SpellProvider(),
          update: (context, authProvider, spellProvider) {
            spellProvider!.setUserId(authProvider.currentUser.id);
            return spellProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, DreamProvider>(
          create: (_) => DreamProvider(),
          update: (_, auth, provider) {
            provider!.setUserId(auth.currentUser.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, DesireProvider>(
          create: (_) => DesireProvider(),
          update: (_, auth, provider) {
            provider!.setUserId(auth.currentUser.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, GratitudeProvider>(
          create: (_) => GratitudeProvider(),
          update: (_, auth, provider) {
            provider!.setUserId(auth.currentUser.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AffirmationProvider>(
          create: (_) => AffirmationProvider(),
          update: (_, auth, provider) {
            provider!.setUserId(auth.currentUser.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, FreeWritingProvider>(
          create: (_) => FreeWritingProvider(),
          update: (_, auth, provider) {
            provider!.setUserId(auth.currentUser.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, EncyclopediaProvider>(
          create: (_) => EncyclopediaProvider(),
          update: (_, auth, provider) {
            provider!.loadUserEntries(auth.currentUser.id);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => LunarProvider()),
        ChangeNotifierProvider(create: (_) => WheelOfYearProvider()),
        ChangeNotifierProxyProvider<AuthProvider, AstrologyProvider>(
          create: (_) => AstrologyProvider(),
          update: (_, auth, provider) {
            provider!.setUserId(auth.currentUser.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider3<AuthProvider, LunarProvider,
            WheelOfYearProvider, NotificationProvider>(
          // O provider acompanha o login desde o startup, mas só solicita a
          // permissão depois que existe um usuário autenticado.
          lazy: false,
          create: (_) => NotificationProvider(
            flutterLocalNotificationsPlugin,
            widget.prefs,
          ),
          update: (_, auth, lunar, wheel, provider) {
            provider!.updateSession(
              isAuthenticated: auth.currentUser.isAuthenticated,
              lunarProvider: lunar,
              wheelProvider: wheel,
            );
            return provider;
          },
        ),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, _) =>
            MaterialApp.router(
          // Roteamento de verdade: URL por tela, histórico de navegador real.
          // As guardas de auth e os estados transitórios do login social vivem
          // no `redirect`/gates do [criarAppRouter]; o Navigator raiz e o
          // ObservadorDeRotasRaiz agora vivem dentro do router.
          routerConfig: _appRouter,
          // `onGenerateTitle` e não `title`: o nome do app é TRADUZIDO
          // ("Pocket Grimoire", "Grimorio de Bolsillo") e a chave `appTitle`
          // existia nos quatro ARBs sem nenhum chamador. Cravado, o nome
          // chegava em português para todo mundo — na aba do navegador e no
          // alternador de tarefas do Android, que é onde ele aparece.
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          locale: languageProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: LanguageProvider.supportedLocales,
          localeResolutionCallback: LanguageProvider.resolve,
          theme: themeProvider.themeData,
          // Na web em desktop, enquadra o app numa largura de celular.
          builder: (context, child) =>
              WebMobileFrame(child: child ?? const SizedBox.shrink()),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
