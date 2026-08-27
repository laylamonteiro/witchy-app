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
import 'core/utils/app_session_policy.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/auth/auth.dart';
import 'features/auth/presentation/pages/change_password_page.dart';
import 'features/subscription/subscription.dart';
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
import 'core/navigation/corrimao_de_voltar.dart';
import 'core/navigation/observador_de_rotas_raiz.dart';
import 'core/navigation/porteiro_do_voltar.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// A chave do Navigator raiz.
///
/// Fora da classe de propósito: o [PorteiroDoVoltar] é instalado ANTES do
/// `runApp` — precisa estar na fila de observadores antes do primeiro voltar, e
/// antes até da tela de erro de boot — e precisa alcançar o navegador assim que
/// ele existir.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

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
  final nav = _rootNavigatorKey.currentState;
  if (nav == null) {
    if (tentativas > 600) return; // boot não montou o app; desiste em silêncio
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _abrirTrocaDeSenhaDaRecuperacao(tentativas + 1));
    return;
  }
  // Consumida: aconteça o que acontecer com esta tela, o próximo boot não
  // deve reabri-la.
  unawaited(SharedPreferences.getInstance()
      .then((p) => p.remove(_chaveRecuperacaoPendente)));
  nav.push(MaterialPageRoute(
    builder: (_) => const ChangePasswordPage(recovery: true),
  ));
}

void main() {
  // Zona guardada: erros assíncronos não capturados (fora do ciclo de build)
  // são logados em vez de derrubarem o app silenciosamente — na web eles
  // viravam um "Uncaught Error" minificado no console e tela branca.
  runZonedGuarded<void>(() async {
    // O VIGIA DO CORRIMÃO antes de tudo: assim o ouvinte de `popstate` do app
    // entra na fila ANTES do ouvinte do motor (que só nasce quando o Navigator
    // raiz monta) e lê o estado do pouso antes de qualquer reação dele. Não
    // escreve nada no histórico — quem ergue os degraus é o script de
    // `web/index.html`, que roda antes deste código existir.
    instalarVigiaDoCorrimao();

    // Precisa rodar DENTRO da zona: binding e runApp na mesma zona, senão o
    // Flutter emite aviso de "Zone mismatch" e os erros escapam da guarda.
    WidgetsFlutterBinding.ensureInitialized();

    // O PORTEIRO DO VOLTAR, antes de qualquer tela existir.
    //
    // Ele é observador do BINDING, não widget: vale no boot, na tela de erro de
    // render, na troca de sessão e em qualquer quadro sem `PopScope` montado.
    // Enquanto ele estiver de pé, `handlePopRoute` NUNCA chega ao
    // `SystemNavigator.pop()` — que na web desmonta o histórico do motor e
    // deixa o voltar morto pelo resto do documento, fazendo o gesto seguinte
    // fechar a aba a partir de qualquer tela. Ver [PorteiroDoVoltar].
    PorteiroDoVoltar.instalar(raiz: () => _rootNavigatorKey.currentState);

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DeepLinkService.instance.pending.addListener(_onDeepLink);
    _checkSplashDisplay();
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
    super.dispose();
  }

  /// Um deep link chegou (toque em notificação): fecha fluxos de tela cheia
  /// (Configurações, Assinatura...) para revelar a HomePage, que fará a troca
  /// de aba. A seção de destino consome o link ao concluir a navegação.
  void _onDeepLink() {
    if (DeepLinkService.instance.pending.value == null) return;
    _rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  Future<void> _checkSplashDisplay() async {
    final lastOpened = widget.prefs.getInt(_lastOpenedKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Se o app foi aberto nos últimos 30 minutos, não mostrar splash
    // (significa que está voltando de background, não de um fechamento completo)
    if (now - lastOpened < 30 * 60 * 1000) {
      setState(() {
        _showSplash = false;
      });
    }

    // Atualizar timestamp de abertura
    await widget.prefs.setInt(_lastOpenedKey, now);
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
      // Sessão nova = Salem de volta (o esconderijo é sempre temporário).
      _mascotProvider.show();
      // Recria toda a navegação, como em uma abertura real: páginas internas
      // são descartadas, o splash reaparece e a bubble verifica o novo dia.
      _rootNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AuthWrapper(showSplash: true),
        ),
        (_) => false,
      );
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
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
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
        builder: (context, languageProvider, themeProvider, child) => MaterialApp(
          navigatorKey: _rootNavigatorKey,
          // Avisa a Home quando uma tela cheia abre ou fecha na raiz — ela
          // não enxerga isso sozinha (ver [mudancasDaPilhaRaiz]).
          navigatorObservers: [ObservadorDeRotasRaiz()],
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
          builder: (context, navigator) =>
              WebMobileFrame(child: navigator ?? const SizedBox.shrink()),
          home: child,
          routes: {
            // Rotas de conteúdo exigem sessão: na web a URL é endereçável
            // (o navegador guarda `#/home`) e abriria a Home sem passar pelo
            // AuthWrapper. Sem login, RequireAuth devolve o fluxo de entrada.
            '/home': (context) => const RequireAuth(child: HomePage()),
            '/subscription': (context) =>
                const RequireAuth(child: SubscriptionPage()),
            // E o inverso: as telas de ENTRADA não podem aparecer para quem
            // já entrou. Voltar no navegador caminha pelo histórico, que
            // guarda a URL de antes do login — sem GuestOnly, um voltar
            // reabria `#/login` por cima de uma sessão viva.
            '/welcome': (context) => const GuestOnly(child: WelcomePage()),
            '/login': (context) => const GuestOnly(child: LoginPage()),
            '/signup': (context) => const GuestOnly(child: SignupPage()),
          },
          debugShowCheckedModeBanner: false,
        ),
        child: AuthWrapper(showSplash: _showSplash),
      ),
    );
  }
}
