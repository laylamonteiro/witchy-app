import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import 'user_spells_list_page.dart';
import 'mystic_advisor_page.dart';
import '../../../astrology/presentation/pages/astrology_tab.dart';
import '../../../runes/presentation/pages/rune_reading_page.dart';
import '../../../divination/presentation/pages/pendulum_page.dart';
import '../../../divination/presentation/pages/oracle_cards_page.dart';
import '../../../sigils/presentation/pages/sigil_step1_intention_page.dart';
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
        title: const ResponsiveAppBarTitle('Grimório Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            // rootNavigator: Configurações cobre a bottom bar (tela cheia)
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
            tooltip: 'Configurações',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.lilac,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelStyle: const TextStyle(fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: const [
            Tab(text: 'Astrologia'),
            Tab(text: 'Ferramentas'),
            Tab(text: 'Meu Grimório'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AstrologyTab(),
          _ToolsTab(),
          UserSpellsListPage(),
        ],
      ),
    );
  }
}

class _ToolsTab extends StatelessWidget {
  const _ToolsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              children: [
                const Text('‧⋆‧ ⛦ ‧⋆‧', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Ferramentas Mágicas',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.lilac,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recursos para auxiliar em suas práticas de magia e manifestação',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.softWhite.withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _buildToolCard(
            context,
            icon: '🧙🏼‍♂️',
            title: 'Conselheiro Místico',
            description:
                'Sabedoria ancestral para suas dúvidas de bruxaria e magia',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MysticAdvisorPage(),
                ),
              );
            },
          ),
          _buildToolCard(
            context,
            icon: '🃏',
            title: 'Cartas do Oráculo',
            description: 'Mensagens e orientação do universo',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OracleCardsPage(),
                ),
              );
            },
          ),
          _buildToolCard(
            context,
            icon: ' ⛤',
            title: 'Sigilos',
            description: 'Crie símbolos mágicos para suas intenções',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SigilStep1IntentionPage(),
                ),
              );
            },
          ),
          _buildToolCard(
            context,
            icon: ' ᚱ ',
            title: 'Leitura de Runas',
            description: 'Consulte as antigas runas nórdicas',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RuneReadingPage(),
                ),
              );
            },
          ),
          _buildToolCard(
            context,
            icon: ' ⟟ ',
            title: 'Pêndulo',
            description: 'Perguntas de sim ou não',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PendulumPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: MagicalCard(
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.softWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.softWhite.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.lilac,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
