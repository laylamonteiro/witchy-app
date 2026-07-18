import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'grimoire_colors.dart';

/// Título de AppBar que preserva a proporção das letras e só reduz a escala
/// quando o espaço horizontal disponível não é suficiente.
class ResponsiveAppBarTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const ResponsiveAppBarTitle(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        textAlign: textAlign,
        style: style,
      ),
    );
  }
}

/// Constantes de cor legadas — fallback para widgets ainda não migrados para
/// `context.gc`. Os valores apontam para o tema padrão (Vinho & Orquídea).
///
/// Migração: `AppColors.x` → `context.gc.x`.
class AppColors {
  // Fundos e bases
  static const background = Color(0xFF140A17);
  static const surface = Color(0xFF221329);
  static const surfaceBorder = Color(0xFF3A2647);

  // Acento principal
  static const lilac = Color(0xFFD98FE0);

  // Pastéis
  static const pink = Color(0xFFF1A7C5);
  static const pinkWitch = Color(0xFFF1A7C5);
  static const mint = Color(0xFFA7F0D8);
  static const starYellow = Color(0xFFFFE8A3);
  static const gold = Color(0xFFFFD700);

  // Texto
  static const textPrimary = Color(0xFFF6F4FF);
  static const textSecondary = Color(0xFFB7B2D6);

  // Status
  static const success = Color(0xFF7EE08A);
  static const alert = Color(0xFFFF6B81);
  static const warning = Color(0xFFFF6B81);
  static const info = Color(0xFFA7C7FF);

  // Aliases
  static const softWhite = textPrimary;
  static const darkBackground = background;
  static const cardBackground = surface;
}

class AppTheme {
  /// Tema padrão (compatibilidade). Prefira `AppTheme.build(...)`.
  static ThemeData get darkTheme => build(GrimoireColors.vinhoOrquidea);

  /// Monta um [ThemeData] a partir de um conjunto de cores [c].
  static ThemeData build(GrimoireColors c) {
    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      scaffoldBackgroundColor: c.background,
      fontFamily: GoogleFonts.nunito().fontFamily,

      // Disponibiliza as cores via context.gc
      extensions: [c],

      colorScheme: ColorScheme(
        brightness: c.brightness,
        primary: c.lilac,
        onPrimary: c.onPrimary,
        secondary: c.pink,
        onSecondary: c.onPrimary,
        tertiary: c.mint,
        onTertiary: c.onPrimary,
        surface: c.surface,
        onSurface: c.textPrimary,
        error: c.alert,
        onError: c.brightness == Brightness.dark
            ? const Color(0xFF2B2143)
            : Colors.white,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzelDecorative(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: c.lilac,
        ),
        displayMedium: GoogleFonts.cinzelDecorative(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: c.lilac,
        ),
        displaySmall: GoogleFonts.cinzelDecorative(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: c.lilac,
        ),
        headlineLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        headlineMedium: GoogleFonts.cinzelDecorative(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        headlineSmall: GoogleFonts.cinzelDecorative(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: c.lilac,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: c.lilac,
        ),
        titleSmall: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c.lilac,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          color: c.textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          color: c.textPrimary,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          color: c.textSecondary,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        labelMedium: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: c.textSecondary,
        ),
        labelSmall: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: c.textSecondary,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: c.surfaceBorder,
            width: 1,
          ),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.lilac,
          foregroundColor: c.onPrimary,
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
          foregroundColor: c.lilac,
          side: BorderSide(color: c.lilac, width: 2),
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
          foregroundColor: c.lilac,
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.lilac, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.alert),
        ),
        labelStyle: GoogleFonts.nunito(
          color: c.textSecondary,
        ),
        hintStyle: GoogleFonts.nunito(
          color: c.textSecondary,
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzelDecorative(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: c.lilac,
        ),
        iconTheme: IconThemeData(
          color: c.lilac,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.lilac,
        unselectedItemColor: c.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: c.lilac,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: c.surfaceBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
