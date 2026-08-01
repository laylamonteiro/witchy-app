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
    if (mounted && _tabController.index != _defaultTabIndex) {
      _tabController.animateTo(_defaultTabIndex);
    }
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
        icon: const Text('📖', style: TextStyle(fontSize: 32)),
        title: l10n.toolLivingGrimoireTitle,
        description: l10n.toolLivingGrimoireDesc,
        page: () => const LearningHomePage(),
      ),
      (
        icon: const Text('🔮', style: TextStyle(fontSize: 32)),
        title: l10n.toolMysticAdvisorTitle,
        description: l10n.toolMysticAdvisorDesc,
        page: () => const MysticAdvisorPage(),
      ),
      (
        icon: const SigilIcon(size: 32),
        title: l10n.toolSigilsTitle,
        description: l10n.toolSigilsDesc,
        page: () => const SigilStep1IntentionPage(),
      ),
    ];

    final divination = <_Tool>[
      (
        icon: const Text('🎴', style: TextStyle(fontSize: 32)),
        title: l10n.toolTarotTitle,
        description: l10n.toolTarotDesc,
        page: () => const TarotPage(),
      ),
      (
        icon: const Text(' ᚱ ', style: TextStyle(fontSize: 32)),
        title: l10n.toolRunesTitle,
        description: l10n.toolRunesDesc,
        page: () => const RuneReadingPage(),
      ),
      (
        icon: const Text('🃏', style: TextStyle(fontSize: 32)),
        title: l10n.toolOracleTitle,
        description: l10n.toolOracleDesc,
        page: () => const OracleCardsPage(),
      ),
      (
        icon: const Text(' ⟟ ', style: TextStyle(fontSize: 32)),
        title: l10n.toolPendulumTitle,
        description: l10n.toolPendulumDesc,
        page: () => const PendulumPage(),
      ),
      (
        icon: const Text('🌙', style: TextStyle(fontSize: 32)),
        title: l10n.toolDreamsTitle,
        description: l10n.toolDreamsDesc,
        page: () => const DreamToolsPage(),
      ),
      (
        icon: const Text('🖐️', style: TextStyle(fontSize: 32)),
        title: l10n.toolPalmistryTitle,
        description: l10n.toolPalmistryDesc,
        page: () => const PalmistryPage(),
      ),
    ];

    final selfKnowledge = <_Tool>[
      (
        icon: const Text('🎭', style: TextStyle(fontSize: 32)),
        title: l10n.toolArchetypeTitle,
        description: l10n.toolArchetypeDesc,
        page: () => const ArchetypeQuizPage(),
      ),
      (
        icon: const Text('🔢', style: TextStyle(fontSize: 32)),
        title: l10n.toolNumerologyTitle,
        description: l10n.toolNumerologyDesc,
        page: () => const NumerologyPage(),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              children: [
                const Text('‧ ⛦ ‧', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  l10n.toolsHeaderTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: context.gc.lilac,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.toolsHeaderSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          childAspectRatio: 0.95,
          children:
              tools.map((tool) => _buildToolCard(context, tool)).toList(),
        ),
      ],
    );
  }

  Widget _buildToolCard(BuildContext context, _Tool tool) {
    // O toque é do próprio MagicalCard: antes havia um InkWell POR FORA do
    // card, então o ripple vazava e o alvo de toque ficava duplicado.
    return MagicalCard(
      margin: const EdgeInsets.all(8),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => tool.page()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tool.icon,
          const SizedBox(height: 10),
          Text(
            tool.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.gc.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              tool.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Uma ferramenta do Grimório: ícone, textos e a página que ela abre.
typedef _Tool = ({
  Widget icon,
  String title,
  String description,
  Widget Function() page,
});
