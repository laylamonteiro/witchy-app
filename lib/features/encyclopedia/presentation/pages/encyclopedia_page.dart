import 'package:flutter/material.dart';
import 'crystals_list_page.dart';
import 'colors_list_page.dart';
import 'herbs_list_page.dart';
import 'metals_list_page.dart';
import 'altar_page.dart';
import 'elements_page.dart';
import 'goddesses_list_page.dart';
import '../../../lunar/presentation/pages/lunar_calendar_page.dart';
import '../../../wheel_of_year/presentation/pages/wheel_of_year_page.dart';
import '../../../../core/theme/app_theme.dart';

class EncyclopediaPage extends StatelessWidget {
  const EncyclopediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 9,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enciclopédia Mágica'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
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
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            LunarCalendarPage(embedded: true),
            WheelOfYearPage(embedded: true),
            CrystalsListPage(),
            HerbsListPage(),
            MetalsListPage(),
            ColorsListPage(),
            GoddessesListPage(),
            ElementsPage(),
            AltarPage(),
          ],
        ),
      ),
    );
  }
}
