import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/theme/app_theme.dart';
import 'core/database/database_helper.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/grimoire/presentation/providers/spell_provider.dart';
import 'features/diary/presentation/providers/dream_provider.dart';
import 'features/diary/presentation/providers/desire_provider.dart';
import 'features/encyclopedia/presentation/providers/encyclopedia_provider.dart';
import 'features/lunar/presentation/providers/lunar_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize database
  await DatabaseHelper.instance.database;

  // Initialize notifications
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

  runApp(const GrimorioDeBolsoApp());
}

class GrimorioDeBolsoApp extends StatelessWidget {
  const GrimorioDeBolsoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpellProvider()),
        ChangeNotifierProvider(create: (_) => DreamProvider()),
        ChangeNotifierProvider(create: (_) => DesireProvider()),
        ChangeNotifierProvider(create: (_) => EncyclopediaProvider()),
        ChangeNotifierProvider(create: (_) => LunarProvider()),
      ],
      child: MaterialApp(
        title: 'Grimório de Bolso',
        theme: AppTheme.darkTheme,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
