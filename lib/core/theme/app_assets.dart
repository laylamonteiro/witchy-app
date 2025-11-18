// lib/core/theme/app_assets.dart

/// Classe para gerenciar todos os assets visuais do app
class AppAssets {
  AppAssets._();

  // Navigation Icons
  static const String moonDark = 'assets/icons/moon_dark.svg';
  static const String moonLight = 'assets/icons/moon_light.svg';
  static const String grimoireDark = 'assets/icons/grimoire_dark.svg';
  static const String diaryDark = 'assets/icons/diary_dark.svg';
  static const String crystalsDark = 'assets/icons/crystals_dark.svg';

  // Functional Icons
  static const String addDark = 'assets/icons/add_dark.svg';
  static const String searchDark = 'assets/icons/search_dark.svg';

  // Decorative Elements
  static const String blackCatMascot = 'assets/icons/black_cat_mascot.svg';
  static const String animatedStars = 'assets/icons/animated_stars.svg';

  // Helper method to get icon based on theme
  static String getThemedIcon(String iconName, bool isDarkMode) {
    // Para ícones que só têm versão dark, retornar a versão dark
    final suffix = isDarkMode ? '_dark' : '_dark';
    return 'assets/icons/$iconName$suffix.svg';
  }

  // Helper method for navigation icons
  static String getNavigationIcon(NavigationItem item, bool isDarkMode) {
    switch (item) {
      case NavigationItem.lunar:
        return isDarkMode ? moonDark : moonLight;
      case NavigationItem.grimoire:
        return grimoireDark;
      case NavigationItem.diary:
        return diaryDark;
      case NavigationItem.encyclopedia:
        return crystalsDark;
    }
  }
}

/// Enum para itens de navegação
enum NavigationItem {
  lunar,
  grimoire,
  diary,
  encyclopedia,
}

/// Classe para animações de assets
class AssetAnimations {
  AssetAnimations._();

  // Durações padrão das animações
  static const Duration starTwinkle = Duration(milliseconds: 2000);
  static const Duration candleFlicker = Duration(milliseconds: 500);
  static const Duration crystalGlow = Duration(milliseconds: 3000);
  static const Duration catBlink = Duration(milliseconds: 4000);
  static const Duration loadingRotation = Duration(milliseconds: 1500);
}

/// Paleta de cores para assets em hexadecimal
class AssetColors {
  AssetColors._();

  // Dark Mode
  static const String backgroundDark = '#0B0A16';
  static const String surfaceDark = '#171425';
  static const String borderDark = '#26213A';
  static const String lilacDark = '#C9A7FF';
  static const String pinkDark = '#F1A7C5';
  static const String mintDark = '#A7F0D8';
  static const String starYellowDark = '#FFE8A3';
  static const String textPrimaryDark = '#F6F4FF';
  static const String textSecondaryDark = '#B7B2D6';

  // Light Mode
  static const String backgroundLight = '#F6F4FF';
  static const String surfaceLight = '#FFFFFF';
  static const String borderLight = '#E5E0F5';
  static const String lilacLight = '#8B5FD6';
  static const String pinkLight = '#D668A0';
  static const String mintLight = '#4EC49E';
  static const String starYellowLight = '#D4B14F';
  static const String textPrimaryLight = '#0B0A16';
  static const String textSecondaryLight = '#524D6B';
}
