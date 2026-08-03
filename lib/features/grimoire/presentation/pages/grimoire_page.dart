import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import 'spell_categories_hub_page.dart';
import 'mystic_advisor_page.dart';
import '../../../astrology/presentation/pages/astrology_tab.dart';
import '../../../runes/presentation/pages/rune_reading_page.dart';
import '../../../divination/presentation/pages/pendulum_page.dart';
import '../../../divination/presentation/pages/oracle_cards_page.dart';
import '../../../sigils/presentation/pages/sigil_step1_intention_page.dart';
import '../../../sigils/presentation/widgets/sigil_icon.dart';
import '../../../numerology/presentation/pages/numerology_page.dart';
import '../../../tarot/presentation/pages/tarot_page.dart';
import '../../../palmistry/presentation/pages/palmistry_page.dart';
import '../../../diary/presentation/pages/dream_tools_page.dart';
import '../../../encyclopedia/presentation/pages/archetype_quiz_page.dart';
import '../../../encyclopedia/presentation/widgets/nature_guide_launcher.dart';
import '../widgets/grimoire_header_card.dart';
import '../../../learning/presentation/pages/learning_home_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../core/navigation/section_reset_notifier.dart';

class GrimoirePage extends StatefulWidget {
  /// Notificador da HomePage: re-toque na aba "Grimório" volta para a
  /// primeira aba interna.
  final SectionResetNotifier? resetNotifier;

  const GrimoirePage({super.key, this.resetNotifier});

  @override
  State<GrimoirePage> createState() => _GrimoirePageState();
}

class _GrimoirePageState extends State<GrimoirePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  /// Aba central "Ferramentas" — sempre a aba inicial e o alvo do reset
  /// (duplo-toque em "Grimório" na bottom nav).
  static const int _defaultTabIndex = 1;

  /// Trocado para recriar o TabBarView quando o re-toque na bottom bar pede
  /// "voltar ao início" já estando na aba inicial.
  int _viewEpoch = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _defaultTabIndex,
    );
    widget.resetNotifier?.addListener(_onResetRequested);
  }

  @override
  void dispose() {
    widget.resetNotifier?.removeListener(_onResetRequested);
    _tabController.dispose();
    super.dispose();
  }

  void _onResetRequested() {
    if (!mounted) return;
    if (_tabController.index != _defaultTabIndex) {
      _tabController.animateTo(_defaultTabIndex);
      return;
    }
    // Já na aba inicial: recria a view para o conteúdo voltar ao topo
    // (as sub-páginas não mantêm estado fora de cena, então trocar de aba
    // já volta ao topo sozinho — este é o único caso que faltava).
    setState(() => _viewEpoch++);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).grimoirePageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            // rootNavigator: Configurações cobre a bottom bar (tela cheia)
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
            tooltip: AppLocalizations.of(context).settingsTitle,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.gc.lilac,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelStyle: const TextStyle(fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: [
            Tab(text: AppLocalizations.of(context).grimoireTabAstrology),
            Tab(text: AppLocalizations.of(context).grimoireTabTools),
            Tab(text: AppLocalizations.of(context).grimoireTabMyGrimoire),
          ],
        ),
      ),
      body: TabBarView(
        key: ValueKey(_viewEpoch),
        controller: _tabController,
        children: const [
          AstrologyTab(),
          _ToolsTab(),
          SpellCategoriesHubPage(),
        ],
      ),
    );
  }
}

class _ToolsTab extends StatelessWidget {
  const _ToolsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Agrupadas por intenção: onze cards empilhados viravam uma lista longa
    // e monótona, em que nada se destacava.
    final practice = <_Tool>[
      (
        icon: const Text('📖', style: TextStyle(fontSize: 40)),
        title: l10n.toolLivingGrimoireTitle,
        description: l10n.toolLivingGrimoireDesc,
        open: () => _push(context, const LearningHomePage()),
      ),
      (
        icon: const Text('🔮', style: TextStyle(fontSize: 40)),
        title: l10n.toolMysticAdvisorTitle,
        description: l10n.toolMysticAdvisorDesc,
        open: () => _push(context, const MysticAdvisorPage()),
      ),
      (
        icon: const SigilIcon(size: 40),
        title: l10n.toolSigilsTitle,
        description: l10n.toolSigilsDesc,
        open: () => _push(context, const SigilStep1IntentionPage()),
      ),
      (
        icon: const Text('🍃', style: TextStyle(fontSize: 40)),
        title: l10n.toolNatureGuideTitle,
        description: l10n.toolNatureGuideDesc,
        // Antes da página vem o seletor: o que vamos identificar?
        open: () => openNatureGuide(context),
      ),
    ];

    final divination = <_Tool>[
      (
        icon: const Text('🎴', style: TextStyle(fontSize: 40)),
        title: l10n.toolTarotTitle,
        description: l10n.toolTarotDesc,
        open: () => _push(context, const TarotPage()),
      ),
      (
        icon: const Text('🌙', style: TextStyle(fontSize: 40)),
        title: l10n.toolDreamsTitle,
        description: l10n.toolDreamsDesc,
        open: () => _push(context, const DreamToolsPage()),
      ),
      (
        icon: const Text('🖐️', style: TextStyle(fontSize: 40)),
        title: l10n.toolPalmistryTitle,
        description: l10n.toolPalmistryDesc,
        open: () => _push(context, const PalmistryPage()),
      ),
      (
        icon: const Text(' ᚱ ', style: TextStyle(fontSize: 40)),
        title: l10n.toolRunesTitle,
        description: l10n.toolRunesDesc,
        open: () => _push(context, const RuneReadingPage()),
      ),
      (
        icon: const Text('🃏', style: TextStyle(fontSize: 40)),
        title: l10n.toolOracleTitle,
        description: l10n.toolOracleDesc,
        open: () => _push(context, const OracleCardsPage()),
      ),
      (
        icon: const Text(' ⟟ ', style: TextStyle(fontSize: 40)),
        title: l10n.toolPendulumTitle,
        description: l10n.toolPendulumDesc,
        open: () => _push(context, const PendulumPage()),
      ),
    ];

    final selfKnowledge = <_Tool>[
      (
        icon: const Text('🎭', style: TextStyle(fontSize: 40)),
        title: l10n.toolArchetypeTitle,
        description: l10n.toolArchetypeDesc,
        open: () => _push(context, const ArchetypeQuizPage()),
      ),
      (
        icon: const Text('🔢', style: TextStyle(fontSize: 40)),
        title: l10n.toolNumerologyTitle,
        description: l10n.toolNumerologyDesc,
        open: () => _push(context, const NumerologyPage()),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mesmo card-cabeçalho (cores e altura) da aba Astrologia.
          GrimoireHeaderCard(
            glyph: '‧ ⛦ ‧',
            title: l10n.toolsHeaderTitle,
            subtitle: l10n.toolsHeaderSubtitle,
          ),
          _buildGroup(context, l10n.toolsGroupPractice, practice),
          _buildGroup(context, l10n.toolsGroupDivination, divination),
          _buildGroup(context, l10n.toolsGroupSelfKnowledge, selfKnowledge),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, String title, List<_Tool> tools) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        ...tools.map((tool) => _buildToolCard(context, tool)),
      ],
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _buildToolCard(BuildContext context, _Tool tool) {
    // O toque é do próprio MagicalCard: antes havia um InkWell POR FORA do
    // card, então o ripple vazava e o alvo de toque ficava duplicado.
    return MagicalCard(
      onTap: tool.open,
      child: Row(
        children: [
          tool.icon,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  tool.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: context.gc.lilac, size: 16),
        ],
      ),
    );
  }
}

/// Uma ferramenta do Grimório: ícone, textos e a ação do toque (em geral
/// um push aninhado; o Guia da Natureza abre um seletor antes).
typedef _Tool = ({
  Widget icon,
  String title,
  String description,
  VoidCallback open,
});
