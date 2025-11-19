import 'package:flutter/material.dart';
import 'crystals_list_page.dart';
import 'colors_list_page.dart';
import '../../../../core/theme/app_theme.dart';

class EncyclopediaPage extends StatelessWidget {
  const EncyclopediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enciclopédia Mágica'),
          bottom: const TabBar(
            indicatorColor: AppColors.lilac,
            tabs: [
              Tab(text: 'Cristais'),
              Tab(text: 'Cores'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CrystalsListPage(),
            ColorsListPage(),
          ],
        ),
      ),
    );
  }
}
