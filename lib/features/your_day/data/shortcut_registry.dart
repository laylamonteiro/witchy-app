import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/navigation/app_deep_link.dart';
import '../../../core/tools/tool_emblem_art.dart';
import '../../astrology/presentation/pages/birth_chart_input_page.dart';
import '../../astrology/presentation/pages/birth_chart_view_page.dart';
import '../../astrology/presentation/providers/astrology_provider.dart';
import '../../divination/presentation/pages/oracle_cards_page.dart';
import '../../divination/presentation/pages/pendulum_page.dart';
import '../../encyclopedia/presentation/widgets/nature_guide_launcher.dart';
import '../../grimoire/presentation/pages/ai_spell_creation_page.dart';
import '../../grimoire/presentation/pages/mystic_advisor_page.dart';
import '../../learning/presentation/pages/learning_home_page.dart';
import '../../palmistry/presentation/pages/palmistry_page.dart';
import '../../runes/presentation/pages/rune_reading_page.dart';
import '../../sigils/presentation/pages/sigil_step1_intention_page.dart';
import '../../tarot/presentation/pages/tarot_page.dart';

/// Uma ferramenta disponível como atalho no "Seu Dia".
class ShortcutTool {
  /// Id estável — persistido em SharedPreferences; não renomear.
  final String id;

  /// Emoji do card (mesmo visual das ferramentas do Grimório). É null quando
  /// o emblema é DESENHADO — ver [drawing].
  final String? emoji;

  /// Emblema desenhado pelo app, para as ferramentas cujo símbolo era um
  /// caractere de bloco raro do Unicode (Runas e Pêndulo): sem uma fonte de
  /// símbolos instalada, o aparelho mostrava o quadradinho de glifo ausente
  /// dentro do atalho. Desenho não depende de fonte. Ver [ToolDrawing].
  ///
  /// É um campo ao lado de [emoji], e não um `String` novo, porque desenho
  /// não é texto: quem renderiza escolhe entre os dois caminhos. Exatamente
  /// um dos dois é preenchido.
  final ToolDrawing? drawing;

  /// Rótulo localizado (reutiliza as chaves das ferramentas existentes).
  final String Function(AppLocalizations l10n) label;

  /// Página empilhada ao tocar (null quando o atalho usa [link] ou [onTap]).
  final WidgetBuilder? builder;

  /// Destino interno do app. Usado quando a ferramenta VIVE dentro de uma
  /// aba: empilhar a página solta a deixaria sem a navegação da seção.
  final AppDeepLink? link;

  /// Ação customizada (ex.: Guia da Natureza abre um seletor antes da
  /// página). Tem prioridade sobre [builder] e [link].
  final void Function(BuildContext context)? onTap;

  const ShortcutTool({
    required this.id,
    required this.label,
    this.emoji,
    this.drawing,
    this.builder,
    this.link,
    this.onTap,
  })  : assert(builder != null || link != null || onTap != null,
            'Um atalho precisa de uma página, um destino ou uma ação'),
        assert((emoji == null) != (drawing == null),
            'Um atalho tem emoji OU desenho — nunca os dois, nunca nenhum');
}

/// Catálogo dos atalhos personalizáveis do "Seu Dia".
class YourDayShortcuts {
  const YourDayShortcuts._();

  static final List<ShortcutTool> all = [
    ShortcutTool(
      id: 'living_grimoire',
      emoji: '📖',
      label: (l10n) => l10n.toolLivingGrimoireTitle,
      builder: (_) => const LearningHomePage(),
    ),
    ShortcutTool(
      id: 'tarot',
      emoji: '🎴',
      label: (l10n) => l10n.toolTarotTitle,
      builder: (_) => const TarotPage(),
    ),
    ShortcutTool(
      id: 'runes',
      drawing: ToolDrawing.raidho,
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
    // Sonhos abre a ABA de sonhos dos Diários: lá dá para interpretar (quem
    // tem acesso) e para registrar à mão — a tela de interpretação sozinha
    // deixaria de fora quem não tem o recurso.
    ShortcutTool(
      id: 'dreams',
      emoji: '🌙',
      label: (l10n) => l10n.toolDreamsTitle,
      link: AppDeepLink.dreamsDiary,
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
      id: 'palmistry',
      emoji: '🖐️',
      label: (l10n) => l10n.toolPalmistryTitle,
      builder: (_) => const PalmistryPage(),
    ),
    ShortcutTool(
      id: 'nature_guide',
      emoji: '🍃',
      label: (l10n) => l10n.toolNatureGuideTitle,
      onTap: openNatureGuide,
    ),
    // Mesma rota da aba Astrologia: quem já tem mapa vê o mapa; quem não
    // tem cai na criação.
    ShortcutTool(
      id: 'birth_chart',
      emoji: '🌟',
      label: (l10n) => l10n.astroBirthChart,
      onTap: (context) {
        final hasChart = context.read<AstrologyProvider>().hasBirthChart;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => hasChart
                ? const BirthChartViewPage()
                : const BirthChartInputPage(),
          ),
        );
      },
    ),
    ShortcutTool(
      id: 'pendulum',
      drawing: ToolDrawing.pendulum,
      label: (l10n) => l10n.toolPendulumTitle,
      builder: (_) => const PendulumPage(),
    ),
  ];

  /// Seis por padrão: a grade tem 3 colunas, então 6 fecha duas linhas
  /// certinhas — 7 deixava um atalho órfão sozinho na última linha.
  /// Prioridade para os recursos Premium (Conselheiro, Guia da Natureza,
  /// Quiromancia, Feitiço Místico, Sonhos); os demais ficam no Editar.
  static const List<String> defaults = [
    'living_grimoire',
    'mystic_advisor',
    'nature_guide',
    'palmistry',
    'ai_spell',
    'dreams',
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
