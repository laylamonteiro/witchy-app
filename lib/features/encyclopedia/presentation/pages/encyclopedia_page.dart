import 'package:flutter/material.dart';
import 'crystals_list_page.dart';
import 'colors_list_page.dart';
import 'herbs_list_page.dart';
import 'altar_page.dart';
import 'elements_page.dart';
import '../../../runes/presentation/pages/runes_list_page.dart';
import '../../../sigils/presentation/pages/sigil_step1_intention_page.dart';
import '../../../../core/theme/app_theme.dart';

class EncyclopediaPage extends StatelessWidget {
  const EncyclopediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enciclopédia Mágica'),
          bottom: const TabBar(
            indicatorColor: AppColors.lilac,
            isScrollable: true,
            padding: EdgeInsets.only(left: 8),
            labelPadding: EdgeInsets.symmetric(horizontal: 12),
            tabs: [
              Tab(text: 'Cristais'),
              Tab(text: 'Ervas'),
              Tab(text: 'Cores'),
              Tab(text: 'Elementos'),
              Tab(text: 'Altar'),
              Tab(text: 'Runas'),
              Tab(text: 'Sigilos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CrystalsListPage(),
            HerbsListPage(),
            ColorsListPage(),
            ElementsPage(),
            AltarPage(),
            RunesListPage(),
            SigilStep1IntentionPage(),
          ],
        ),
      ),
    );
  }
}
