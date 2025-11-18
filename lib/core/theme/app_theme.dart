import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Fundos e bases
  static const background = Color(0xFF0B0A16); // Quase preto com tom roxo profundo
  static const surface = Color(0xFF171425); // Roxo bem escuro para cards
  static const surfaceBorder = Color(0xFF26213A); // Roxo mais claro para bordas

  // Pastéis principais
  static const lilac = Color(0xFFC9A7FF); // Magia, espiritualidade, lua
  static const pink = Color(0xFFF1A7C5); // Amor próprio, afeto, fofura
  static const mint = Color(0xFFA7F0D8); // Cura, natureza, bruxaria verde
  static const starYellow = Color(0xFFFFE8A3); // Brilho, glitter, feedback positivo

  // Texto
  static const textPrimary = Color(0xFFF6F4FF); // Branquinho suave
  static const textSecondary = Color(0xFFB7B2D6); // Texto secundário/placeholder

  // Status
  static const success = Color(0xFF7EE08A); // Sucesso/proteção
  static const alert = Color(0xFFFF6B81); // Alerta/cuidado
  static const info = Color(0xFFA7C7FF); // Info/neutro
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.lilac,
        secondary: AppColors.pink,
        tertiary: AppColors.mint,
        surface: AppColors.surface,
        error: AppColors.alert,
        onPrimary: Color(0xFF2B2143),
        onSecondary: Color(0xFF2B2143),
        onSurface: AppColors.textPrimary,
      ),

      // Text Theme
      textTheme: TextTheme(
        // Títulos grandes (logo, nome do app)
        displayLarge: GoogleFonts.cinzelDecorative(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.lilac,
        ),
        displayMedium: GoogleFonts.cinzelDecorative(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.lilac,
        ),
        displaySmall: GoogleFonts.cinzelDecorative(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.lilac,
        ),

        // Títulos de seções
        headlineLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        // Títulos de cards
        titleLarge: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lilac,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.lilac,
        ),
        titleSmall: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.lilac,
        ),

        // Corpo de texto
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),

        // Labels
        labelLarge: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.surfaceBorder,
            width: 1,
          ),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lilac,
          foregroundColor: const Color(0xFF2B2143),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lilac,
          side: const BorderSide(color: AppColors.lilac, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lilac,
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lilac, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.alert),
        ),
        labelStyle: GoogleFonts.nunito(
          color: AppColors.textSecondary,
        ),
        hintStyle: GoogleFonts.nunito(
          color: AppColors.textSecondary,
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lilac,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.lilac,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.lilac,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.lilac,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
