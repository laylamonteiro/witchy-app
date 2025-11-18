// lib/main.dart
import 'package:flutter/material.dart';
import 'ui/home/root_shell.dart';

void main() {
  runApp(const GrimorioDeBolsoApp());
}

class GrimorioDeBolsoApp extends StatelessWidget {
  const GrimorioDeBolsoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF0B0A16);
    const Color surface = Color(0xFF171425);
    const Color primary = Color(0xFFC9A7FF);
    const Color secondary = Color(0xFFF1A7C5);

    return MaterialApp(
      title: 'Grimório de Bolso',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        primaryColor: primary,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          background: background,
          surface: surface,
        ),
        cardColor: surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      home: const RootShell(),
    );
  }
}
