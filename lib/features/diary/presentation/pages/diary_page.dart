import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'gratitudes_list_page.dart';
import 'affirmations_list_page.dart';
import 'free_writing_tab.dart';
import 'dreams_list_page.dart';
import 'desires_list_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../core/navigation/section_reset_notifier.dart';

class DiaryPage extends StatefulWidget {
  /// Notificador da HomePage: re-toque na aba "Diários" volta para a
  /// primeira aba interna.
  final SectionResetNotifier? resetNotifier;

  const DiaryPage({super.key, this.resetNotifier});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  /// Aba central "💭" (Escrita Livre) — sempre a aba inicial e o alvo do reset
  /// (duplo-toque em "Diários" na bottom nav).
  static const int _defaultTabIndex = 2;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
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
        title: ResponsiveAppBarTitle(AppLocalizations.of(context)!.diaryPageTitle),
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
          indicatorColor: context.gc.lilac,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelStyle: const TextStyle(fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          labelPadding: const EdgeInsets.symmetric(horizontal: 13),
          tabs: [
            Tab(text: AppLocalizations.of(context)!.diaryTabGratitude),
            Tab(text: AppLocalizations.of(context)!.diaryTabAffirmations),
            const Tab(child: Text('💭', style: TextStyle(fontSize: 16))),
            Tab(text: AppLocalizations.of(context)!.diaryTabDreams),
            Tab(text: AppLocalizations.of(context)!.diaryTabDesires),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GratitudesListPage(),
          AffirmationsListPage(),
          FreeWritingTab(),
          DreamsListPage(),
          DesiresListPage(),
        ],
      ),
    );
  }
}
