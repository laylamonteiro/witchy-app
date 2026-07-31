// lib/core/theme/app_assets.dart

/// Classe para gerenciar todos os assets visuais do app
class AppAssets {
  AppAssets._();

  // Navigation Icons
  static const String moonDark = 'assets/icons/navigation/moon_dark.svg';
  static const String moonLight = 'assets/icons/navigation/moon_light.svg';
  static const String grimoireDark = 'assets/icons/navigation/grimoire_dark.svg';
  static const String grimoireLight = 'assets/icons/navigation/grimoire_light.svg';
  static const String diaryDark = 'assets/icons/navigation/diary_dark.svg';
  static const String diaryLight = 'assets/icons/navigation/diary_light.svg';
  static const String crystalsDark = 'assets/icons/navigation/crystals_dark.svg';
  static const String crystalsLight = 'assets/icons/navigation/crystals_light.svg';

  // Functional Icons
  static const String addDark = 'assets/icons/functional/add_dark.svg';
  static const String addLight = 'assets/icons/functional/add_light.svg';
  static const String searchDark = 'assets/icons/functional/search_dark.svg';
  static const String searchLight = 'assets/icons/functional/search_light.svg';
  static const String editDark = 'assets/icons/functional/edit_dark.svg';
  static const String editLight = 'assets/icons/functional/edit_light.svg';
  static const String deleteDark = 'assets/icons/functional/delete_dark.svg';
  static const String deleteLight = 'assets/icons/functional/delete_light.svg';

  // Decorative Elements
  static const String blackCatMascot = 'assets/decorative/black_cat_mascot.svg';
  static const String animatedStars = 'assets/decorative/animated_stars.svg';
  static const String candlesSet = 'assets/decorative/candles_set.svg';
  static const String crystalCluster = 'assets/decorative/crystal_cluster.svg';
  static const String moonPhases = 'assets/decorative/moon_phases.svg';
  static const String potionBottles = 'assets/decorative/potion_bottles.svg';

  // Empty States Illustrations
  static const String emptyGrimoire = 'assets/illustrations/empty_grimoire.svg';
  static const String emptyDreams = 'assets/illustrations/empty_dreams.svg';
  static const String emptyDesires = 'assets/illustrations/empty_desires.svg';
  static const String noResults = 'assets/illustrations/no_results.svg';

  // Loading Animations
  static const String loadingCauldron = 'assets/illustrations/loading_cauldron.svg';
  static const String loadingStars = 'assets/decorative/animated_stars.svg';

  // Helper method to get icon based on theme
  static String getThemedIcon(String iconName, bool isDarkMode) {
    final suffix = isDarkMode ? '_dark' : '_light';
    return 'assets/icons/$iconName$suffix.svg';
  }

  // Helper method for navigation icons
  static String getNavigationIcon(NavigationItem item, bool isDarkMode) {
    switch (item) {
      case NavigationItem.lunar:
        return isDarkMode ? moonDark : moonLight;
      case NavigationItem.grimoire:
        return isDarkMode ? grimoireDark : grimoireLight;
      case NavigationItem.diary:
        return isDarkMode ? diaryDark : diaryLight;
      case NavigationItem.encyclopedia:
        return isDarkMode ? crystalsDark : crystalsLight;
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