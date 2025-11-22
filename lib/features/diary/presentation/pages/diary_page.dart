import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gratitudes_list_page.dart';
import 'affirmations_list_page.dart';
import 'dreams_list_page.dart';
import 'desires_list_page.dart';
import '../../../../core/theme/app_theme.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  static const String _lastTabKey = 'diary_last_tab';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Diários'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.lilac,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelStyle: const TextStyle(fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: const [
            Tab(text: 'Gratidão'),
            Tab(text: 'Afirmações'),
            Tab(text: 'Sonhos'),
            Tab(text: 'Desejos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GratitudesListPage(),
          AffirmationsListPage(),
          DreamsListPage(),
          DesiresListPage(),
        ],
      ),
    );
  }
}
