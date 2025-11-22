import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/database/database_helper.dart';
import 'core/widgets/splash_screen.dart';
import 'core/providers/notification_provider.dart';
import 'core/config/supabase_config.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/auth/auth.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';
import 'features/grimoire/presentation/providers/spell_provider.dart';
import 'features/diary/presentation/providers/dream_provider.dart';
import 'features/diary/presentation/providers/desire_provider.dart';
import 'features/diary/presentation/providers/gratitude_provider.dart';
import 'features/diary/presentation/providers/affirmation_provider.dart';
import 'features/encyclopedia/presentation/providers/encyclopedia_provider.dart';
import 'features/lunar/presentation/providers/lunar_provider.dart';
import 'features/wheel_of_year/presentation/providers/wheel_of_year_provider.dart';
import 'features/astrology/presentation/providers/astrology_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for web
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize date formatting for Portuguese locale
  await initializeDateFormatting('pt_BR', null);

  // Initialize database
  await DatabaseHelper.instance.database;

  // Initialize Supabase
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize notifications (only for mobile platforms)
  if (!kIsWeb) {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
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
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSplashDisplay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkSplashDisplay() async {
    final lastOpened = widget.prefs.getInt(_lastOpenedKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Se o app foi aberto nos últimos 5 minutos, não mostrar splash
    // (significa que está voltando de background, não de um fechamento completo)
    if (now - lastOpened < 5 * 60 * 1000) {
      setState(() {
        _showSplash = false;
      });
    }

    // Atualizar timestamp de abertura
    await widget.prefs.setInt(_lastOpenedKey, now);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Atualizar timestamp quando o app volta do background
      widget.prefs.setInt(_lastOpenedKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => SpellProvider()),
        ChangeNotifierProvider(create: (_) => DreamProvider()),
        ChangeNotifierProvider(create: (_) => DesireProvider()),
        ChangeNotifierProvider(create: (_) => GratitudeProvider()),
        ChangeNotifierProvider(create: (_) => AffirmationProvider()),
        ChangeNotifierProvider(create: (_) => EncyclopediaProvider()),
        ChangeNotifierProvider(create: (_) => LunarProvider()),
        ChangeNotifierProvider(create: (_) => WheelOfYearProvider()),
        ChangeNotifierProvider(create: (_) => AstrologyProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            flutterLocalNotificationsPlugin,
            widget.prefs,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Grimório de Bolso',
        theme: AppTheme.darkTheme,
        home: AuthWrapper(showSplash: _showSplash),
        routes: {
          '/home': (context) => const HomePage(),
          '/welcome': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/onboarding': (context) => const OnboardingPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
