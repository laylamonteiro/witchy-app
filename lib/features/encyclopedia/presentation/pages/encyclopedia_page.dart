import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'crystals_list_page.dart';
import 'colors_list_page.dart';
import 'herbs_list_page.dart';
import 'metals_list_page.dart';
import 'altar_page.dart';
import 'elements_page.dart';
import 'goddesses_list_page.dart';
import '../../../lunar/presentation/pages/lunar_calendar_page.dart';
import '../../../wheel_of_year/presentation/pages/wheel_of_year_page.dart';
import '../../../runes/presentation/pages/runes_list_page.dart';
import '../../../../core/theme/app_theme.dart';

class EncyclopediaPage extends StatefulWidget {
  const EncyclopediaPage({super.key});

  @override
  State<EncyclopediaPage> createState() => _EncyclopediaPageState();
}

class _EncyclopediaPageState extends State<EncyclopediaPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  static const String _lastTabKey = 'encyclopedia_last_tab';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadLastTab();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
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
        title: const Text('Enciclopédia Mágica'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.lilac,
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
        ],
      ),
    );
  }
}
