import 'package:flutter/material.dart';

/// Conjunto de cores semânticas de um tema do app, exposto como
/// [ThemeExtension] para permitir troca de tema em runtime.
///
/// Os nomes espelham os da antiga classe `AppColors` (lilac, background,
/// surface, softWhite, etc.), então migrar um widget é trocar
/// `AppColors.x` por `context.gc.x`.
@immutable
class GrimoireColors extends ThemeExtension<GrimoireColors> {
  // Fundos e bases
  final Color background;
  final Color surface;
  final Color surfaceBorder;

  // Acento principal (papel do antigo "lilás")
  final Color lilac;

  // Acentos secundários
  final Color pink;
  final Color mint;
  final Color starYellow;
  final Color gold;

  // Texto
  final Color textPrimary;
  final Color textSecondary;

  // Status
  final Color success;
  final Color alert;
  final Color info;

  // Texto/ícone sobre o acento principal (ex.: texto de botão preenchido)
  final Color onPrimary;

  final Brightness brightness;

  const GrimoireColors({
    required this.background,
    required this.surface,
    required this.surfaceBorder,
    required this.lilac,
    required this.pink,
    required this.mint,
    required this.starYellow,
    required this.gold,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.alert,
    required this.info,
    required this.onPrimary,
    required this.brightness,
  });

  // Aliases de compatibilidade com os nomes antigos de AppColors.
  Color get pinkWitch => pink;
  Color get warning => alert;
  Color get softWhite => textPrimary;
  Color get darkBackground => background;
  Color get cardBackground => surface;

  bool get isDark => brightness == Brightness.dark;

  @override
  GrimoireColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceBorder,
    Color? lilac,
    Color? pink,
    Color? mint,
    Color? starYellow,
    Color? gold,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? alert,
    Color? info,
    Color? onPrimary,
    Brightness? brightness,
  }) {
    return GrimoireColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      lilac: lilac ?? this.lilac,
      pink: pink ?? this.pink,
      mint: mint ?? this.mint,
      starYellow: starYellow ?? this.starYellow,
      gold: gold ?? this.gold,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      alert: alert ?? this.alert,
      info: info ?? this.info,
      onPrimary: onPrimary ?? this.onPrimary,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  GrimoireColors lerp(ThemeExtension<GrimoireColors>? other, double t) {
    if (other is! GrimoireColors) return this;
    return GrimoireColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      lilac: Color.lerp(lilac, other.lilac, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      starYellow: Color.lerp(starYellow, other.starYellow, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      alert: Color.lerp(alert, other.alert, t)!,
      info: Color.lerp(info, other.info, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }

  // ==========================================================================
  // PRESETS
  // ==========================================================================

  /// Vinho + Orquídea — tema padrão.
  static const vinhoOrquidea = GrimoireColors(
    background: Color(0xFF140A17),
    surface: Color(0xFF221329),
    surfaceBorder: Color(0xFF3A2647),
    lilac: Color(0xFFD98FE0),
    pink: Color(0xFFF1A7C5),
    mint: Color(0xFFA7F0D8),
    starYellow: Color(0xFFFFE8A3),
    gold: Color(0xFFFFD700),
    textPrimary: Color(0xFFF6F4FF),
    textSecondary: Color(0xFFB7B2D6),
    success: Color(0xFF7EE08A),
    alert: Color(0xFFFF6B81),
    info: Color(0xFFA7C7FF),
    onPrimary: Color(0xFF2B1030),
    brightness: Brightness.dark,
  );

  /// Azul meia-noite + Celeste.
  static const azulCeleste = GrimoireColors(
    background: Color(0xFF0A0E1F),
    surface: Color(0xFF141A30),
    surfaceBorder: Color(0xFF29324F),
    lilac: Color(0xFF9DC0FF),
    pink: Color(0xFFF1A7C5),
    mint: Color(0xFFA7F0D8),
    starYellow: Color(0xFFFFE8A3),
    gold: Color(0xFFFFD700),
    textPrimary: Color(0xFFF6F4FF),
    textSecondary: Color(0xFFB7B2D6),
    success: Color(0xFF7EE08A),
    alert: Color(0xFFFF6B81),
    info: Color(0xFFA7C7FF),
    onPrimary: Color(0xFF0A0E1F),
    brightness: Brightness.dark,
  );

  /// Esmeralda-noite + Jade.
  static const esmeraldaJade = GrimoireColors(
    background: Color(0xFF07130F),
    surface: Color(0xFF10201A),
    surfaceBorder: Color(0xFF234034),
    lilac: Color(0xFF86E6B4),
    pink: Color(0xFFF1A7C5),
    mint: Color(0xFFA7F0D8),
    starYellow: Color(0xFFFFE8A3),
    gold: Color(0xFFFFD700),
    textPrimary: Color(0xFFF6F4FF),
    textSecondary: Color(0xFFB7B2D6),
    success: Color(0xFF7EE08A),
    alert: Color(0xFFFF6B81),
    info: Color(0xFFA7C7FF),
    onPrimary: Color(0xFF08211E),
    brightness: Brightness.dark,
  );

  /// Ardósia lavanda — crepúsculo (mais claro, texto ainda claro).
  static const ardosiaLavanda = GrimoireColors(
    background: Color(0xFF322D46),
    surface: Color(0xFF3E3859),
    surfaceBorder: Color(0xFF544D72),
    lilac: Color(0xFFE3D9FF),
    pink: Color(0xFFF1A7C5),
    mint: Color(0xFFA7F0D8),
    starYellow: Color(0xFFFFE8A3),
    gold: Color(0xFFFFD700),
    textPrimary: Color(0xFFF6F4FF),
    textSecondary: Color(0xFFC7C1DB),
    success: Color(0xFF7EE08A),
    alert: Color(0xFFFF6B81),
    info: Color(0xFFA7C7FF),
    onPrimary: Color(0xFF241F38),
    brightness: Brightness.dark,
  );

  /// Clássico — Índigo + Lilás (o tema original).
  static const classico = GrimoireColors(
    background: Color(0xFF0B0A16),
    surface: Color(0xFF171425),
    surfaceBorder: Color(0xFF26213A),
    lilac: Color(0xFFC9A7FF),
    pink: Color(0xFFF1A7C5),
    mint: Color(0xFFA7F0D8),
    starYellow: Color(0xFFFFE8A3),
    gold: Color(0xFFFFD700),
    textPrimary: Color(0xFFF6F4FF),
    textSecondary: Color(0xFFB7B2D6),
    success: Color(0xFF7EE08A),
    alert: Color(0xFFFF6B81),
    info: Color(0xFFA7C7FF),
    onPrimary: Color(0xFF2B2143),
    brightness: Brightness.dark,
  );

  /// Lavanda-névoa — tema claro (lilás acinzentado, texto escuro).
  static const lavandaNevoa = GrimoireColors(
    background: Color(0xFFC7C0D2),
    surface: Color(0xFFDAD4E2),
    surfaceBorder: Color(0xFFADA5BE),
    lilac: Color(0xFF5F4A8C),
    pink: Color(0xFFC25E8E),
    mint: Color(0xFF277F66),
    starYellow: Color(0xFFB8860B),
    gold: Color(0xFFB8860B),
    textPrimary: Color(0xFF241F30),
    textSecondary: Color(0xFF554E66),
    success: Color(0xFF2E8B57),
    alert: Color(0xFFD23F52),
    info: Color(0xFF3F6FD0),
    onPrimary: Color(0xFFFFFFFF),
    brightness: Brightness.light,
  );
}

/// Metadados de um preset selecionável (id persistido + rótulo para a UI).
class AppThemePreset {
  final String id;
  final String label;
  final String subtitle;
  final GrimoireColors colors;

  const AppThemePreset({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.colors,
  });
}

class AppThemes {
  AppThemes._();

  static const String defaultId = 'vinhoOrquidea';

  static const List<AppThemePreset> all = [
    AppThemePreset(
      id: 'vinhoOrquidea',
      label: 'Vinho & Orquídea',
      subtitle: 'Escuro • roxo-vinho quente',
      colors: GrimoireColors.vinhoOrquidea,
    ),
    AppThemePreset(
      id: 'azulCeleste',
      label: 'Azul Meia-Noite',
      subtitle: 'Escuro • celestial',
      colors: GrimoireColors.azulCeleste,
    ),
    AppThemePreset(
      id: 'esmeraldaJade',
      label: 'Esmeralda & Jade',
      subtitle: 'Escuro • bruxaria verde',
      colors: GrimoireColors.esmeraldaJade,
    ),
    AppThemePreset(
      id: 'ardosiaLavanda',
      label: 'Ardósia Lavanda',
      subtitle: 'Crepúsculo • lilás acinzentado',
      colors: GrimoireColors.ardosiaLavanda,
    ),
    AppThemePreset(
      id: 'classico',
      label: 'Clássico',
      subtitle: 'Escuro • índigo & lilás (original)',
      colors: GrimoireColors.classico,
    ),
    AppThemePreset(
      id: 'lavandaNevoa',
      label: 'Lavanda Névoa',
      subtitle: 'Claro • lilás acinzentado',
      colors: GrimoireColors.lavandaNevoa,
    ),
  ];

  static AppThemePreset byId(String? id) {
    return all.firstWhere(
      (p) => p.id == id,
      orElse: () => all.first,
    );
  }

  static GrimoireColors colorsById(String? id) => byId(id).colors;
}

/// Atalho: `context.gc.lilac`, `context.gc.background`, etc.
extension GrimoireColorsX on BuildContext {
  GrimoireColors get gc =>
      Theme.of(this).extension<GrimoireColors>() ?? GrimoireColors.vinhoOrquidea;
}
