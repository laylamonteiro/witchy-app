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
import 'package:sqflite_common/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/theme_provider.dart';
import 'core/database/database_helper.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/sync_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/config/supabase_config.dart';
import 'core/services/payment_service.dart';
import 'core/services/premium_access.dart';
import 'core/services/debug_log_service.dart';
import 'core/services/data_sync_service.dart';
import 'core/navigation/app_deep_link.dart';
import 'core/utils/app_session_policy.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/auth/auth.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';
import 'features/subscription/subscription.dart';
import 'features/grimoire/presentation/providers/spell_provider.dart';
import 'features/diary/presentation/providers/dream_provider.dart';
import 'features/diary/presentation/providers/desire_provider.dart';
import 'features/diary/presentation/providers/gratitude_provider.dart';
import 'features/diary/presentation/providers/affirmation_provider.dart';
import 'features/diary/presentation/providers/free_writing_provider.dart';
import 'features/learning/presentation/providers/learning_provider.dart';
import 'features/encyclopedia/presentation/providers/encyclopedia_provider.dart';
import 'features/lunar/presentation/providers/lunar_provider.dart';
import 'features/wheel_of_year/presentation/providers/wheel_of_year_provider.dart';
import 'features/astrology/presentation/providers/astrology_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize debug log service FIRST
  await DebugLogService().initialize();
  await debugLog('SYSTEM', 'App iniciando...');

  // Initialize sqflite for web
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Necessário para os agendamentos locais de Lua e Sabbats.
  tz.initializeTimeZones();

  // Initialize date formatting for Portuguese locale
  await initializeDateFormatting('pt_BR', null);
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('es', null);

  // Initialize database
  await DatabaseHelper.instance.database;

  // Initialize Supabase
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    // Initialize DataSyncService after Supabase
    DataSyncService().initialize();
    await debugLog('SYNC', 'DataSyncService inicializado');
  }

  // Initialize RevenueCat (only for mobile platforms)
  if (!kIsWeb) {
    await PaymentService().initialize();
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

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
  }

  runApp(GrimorioDeBolsoApp(prefs: prefs));
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
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

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

  Future<void> _triggerBackgroundSync() async {
    final syncService = DataSyncService();
    // Sincronização é exclusiva para usuários Premium (fonte única:
    // RevenueCat OU premium local via Código Premium/admin) E precisa estar
    // habilitada nas configurações de Privacidade.
    final syncEnabled = await syncService.cloudSyncEnabled;
    if (syncEnabled &&
        syncService.isReady &&
        PremiumAccess.instance.isPremium) {
      await debugLog('SYNC', 'Auto-sync (Premium) iniciado em background');
      final result = await syncService.syncAll();
      if (result.success) {
        await debugLog('SYNC', 'Auto-sync concluído com sucesso');
      } else {
        await debugLog('SYNC', 'Auto-sync falhou: ${result.error}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(widget.prefs)),
        ChangeNotifierProxyProvider<AuthProvider, LearningProvider>(
          create: (_) => LearningProvider(),
          update: (_, auth, provider) {
            provider!.setUserId(auth.currentUser.id);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
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
        ChangeNotifierProvider(create: (_) => EncyclopediaProvider()),
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
          title: 'Grimório de Bolso',
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
          home: child,
          routes: {
            '/home': (context) => const HomePage(),
            '/welcome': (context) => const WelcomePage(),
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignupPage(),
            '/onboarding': (context) => const OnboardingPage(),
            '/subscription': (context) => const SubscriptionPage(),
          },
          debugShowCheckedModeBanner: false,
        ),
        child: AuthWrapper(showSplash: _showSplash),
      ),
    );
  }
}
