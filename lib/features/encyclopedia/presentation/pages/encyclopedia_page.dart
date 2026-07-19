import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'crystals_list_page.dart';
import 'colors_list_page.dart';
import 'herbs_list_page.dart';
import 'metals_list_page.dart';
import 'altar_page.dart';
import 'elements_page.dart';
import 'goddesses_list_page.dart';
import 'arcane_list_page.dart';
import '../../data/data_sources/archetypes_data.dart';
import '../../data/data_sources/angels_data.dart';
import '../../data/data_sources/demons_data.dart';
import '../../data/data_sources/sacred_symbols_data.dart';
import '../../../lunar/presentation/pages/lunar_calendar_page.dart';
import '../../../wheel_of_year/presentation/pages/wheel_of_year_page.dart';
import '../../../runes/presentation/pages/runes_list_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../core/navigation/section_reset_notifier.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';

class EncyclopediaPage extends StatefulWidget {
  /// Notificador da HomePage: re-toque na aba "Enciclopédia" volta para a
  /// primeira aba interna.
  final SectionResetNotifier? resetNotifier;

  const EncyclopediaPage({super.key, this.resetNotifier});

  @override
  State<EncyclopediaPage> createState() => _EncyclopediaPageState();
}

class _EncyclopediaPageState extends State<EncyclopediaPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  static const String _lastTabKey = 'encyclopedia_last_tab';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 14, vsync: this);
    _tabController.addListener(_onTabChanged);
    widget.resetNotifier?.addListener(_onResetRequested);
    _loadLastTab();
  }

  @override
  void dispose() {
    widget.resetNotifier?.removeListener(_onResetRequested);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onResetRequested() {
    if (mounted && _tabController.index != 0) {
      _tabController.animateTo(0);
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _saveLastTab(_tabController.index);
    }
  }

  Future<void> _loadLastTab() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTab = prefs.getInt(_lastTabKey) ?? 0;
    if (mounted && lastTab != _tabController.index) {
      _tabController.animateTo(lastTab);
    }
  }

  Future<void> _saveLastTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastTabKey, index);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Enciclopédia Mágica'),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              indicatorColor: context.gc.lilac,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelStyle: const TextStyle(fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              tabs: const [
                Tab(text: 'Lua'),
                Tab(text: 'Sabbats'),
                Tab(text: 'Cristais'),
                Tab(text: 'Ervas'),
                Tab(text: 'Metais'),
                Tab(text: 'Cores'),
                Tab(text: 'Deusas'),
                Tab(text: 'Elementos'),
                Tab(text: 'Altar'),
                Tab(text: 'Runas'),
                Tab(text: 'Arquétipos'),
                Tab(text: 'Anjos'),
                Tab(text: 'Demônios'),
                Tab(text: 'Símbolos'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LunarCalendarPage(embedded: true),
          WheelOfYearPage(embedded: true),
          CrystalsListPage(),
          HerbsListPage(),
          MetalsListPage(),
          ColorsListPage(),
          GoddessesListPage(),
          ElementsPage(),
          AltarPage(),
          RunesListPage(),
          ArcaneListPage(
            categoryTitle: 'Arquétipos',
            intro:
                'Figuras universais dos mitos e da psique — espelhos para o autoconhecimento no caminho mágico.',
            entries: archetypesData,
          ),
          ArcaneListPage(
            categoryTitle: 'Anjos',
            intro:
                'Abordagem histórica e informativa: como diferentes tradições — religiosas, ocultistas, folclóricas e literárias — enxergam essas figuras.',
            entries: angelsData,
          ),
          ArcaneListPage(
            categoryTitle: 'Demônios',
            intro:
                'Estudo histórico e simbólico, sem sensacionalismo: goécia, folclore e literatura, diferenciando as tradições sem verdade única.',
            entries: demonsData,
          ),
          ArcaneListPage(
            categoryTitle: 'Símbolos Sagrados',
            intro:
                'A origem e o poder dos símbolos usados na bruxaria — do pentagrama ao ouroboros.',
            entries: sacredSymbolsData,
          ),
        ],
      ),
    );
  }
}
