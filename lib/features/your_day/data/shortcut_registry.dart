import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../divination/presentation/pages/oracle_cards_page.dart';
import '../../divination/presentation/pages/pendulum_page.dart';
import '../../diary/presentation/pages/dreams_list_page.dart';
import '../../grimoire/presentation/pages/ai_spell_creation_page.dart';
import '../../grimoire/presentation/pages/mystic_advisor_page.dart';
import '../../runes/presentation/pages/rune_reading_page.dart';
import '../../sigils/presentation/pages/sigil_step1_intention_page.dart';
import '../../tarot/presentation/pages/tarot_page.dart';

/// Uma ferramenta disponível como atalho no "Seu Dia".
class ShortcutTool {
  /// Id estável — persistido em SharedPreferences; não renomear.
  final String id;

  /// Emoji do card (mesmo visual das ferramentas do Grimório).
  final String emoji;

  /// Rótulo localizado (reutiliza as chaves das ferramentas existentes).
  final String Function(AppLocalizations l10n) label;

  final WidgetBuilder builder;

  const ShortcutTool({
    required this.id,
    required this.emoji,
    required this.label,
    required this.builder,
  });
}

/// Catálogo dos atalhos personalizáveis do "Seu Dia".
class ShortcutRegistry {
  const ShortcutRegistry._();

  static final List<ShortcutTool> all = [
    ShortcutTool(
      id: 'tarot',
      emoji: '🎴',
      label: (l10n) => l10n.toolTarotTitle,
      builder: (_) => const TarotPage(),
    ),
    ShortcutTool(
      id: 'runes',
      emoji: ' ᚱ ',
      label: (l10n) => l10n.toolRunesTitle,
      builder: (_) => const RuneReadingPage(),
    ),
    ShortcutTool(
      id: 'ai_spell',
      emoji: '✨',
      label: (l10n) => l10n.yourDayShortcutAiSpell,
      builder: (_) => const AISpellCreationPage(),
    ),
    ShortcutTool(
      id: 'oracle',
      emoji: '🃏',
      label: (l10n) => l10n.toolOracleTitle,
      builder: (_) => const OracleCardsPage(),
    ),
    ShortcutTool(
      id: 'dreams',
      emoji: '🌙',
      label: (l10n) => l10n.toolDreamsTitle,
      builder: (_) => const DreamsListPage(),
    ),
    ShortcutTool(
      id: 'sigils',
      emoji: '🖊️',
      label: (l10n) => l10n.toolSigilsTitle,
      builder: (_) => const SigilStep1IntentionPage(),
    ),
    ShortcutTool(
      id: 'mystic_advisor',
      emoji: '🔮',
      label: (l10n) => l10n.toolMysticAdvisorTitle,
      builder: (_) => const MysticAdvisorPage(),
    ),
    ShortcutTool(
      id: 'pendulum',
      emoji: ' ⟟ ',
      label: (l10n) => l10n.toolPendulumTitle,
      builder: (_) => const PendulumPage(),
    ),
  ];

  static const List<String> defaults = [
    'tarot',
    'runes',
    'ai_spell',
    'oracle',
    'dreams',
    'sigils',
  ];

  static ShortcutTool? byId(String id) {
    for (final tool in all) {
      if (tool.id == id) return tool;
    }
    return null;
  }

  static String _prefsKey(String userId) => 'your_day_shortcuts_$userId';

  /// Ids escolhidos pelo usuário (ids desconhecidos são filtrados — compat
  /// com versões futuras). Lista ausente/vazia → defaults.
  static Future<List<String>> loadIds(
    SharedPreferences prefs,
    String userId,
  ) async {
    final saved = prefs.getStringList(_prefsKey(userId)) ?? const [];
    final valid = saved.where((id) => byId(id) != null).toList();
    return valid.isEmpty ? List.of(defaults) : valid;
  }

  static Future<void> saveIds(
    SharedPreferences prefs,
    String userId,
    List<String> ids,
  ) =>
      prefs.setStringList(_prefsKey(userId), ids);
}
