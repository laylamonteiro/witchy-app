import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'app_spells_list_page.dart';
import 'user_spells_list_page.dart';

class GrimoirePage extends StatelessWidget {
  const GrimoirePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Grimório Digital'),
          bottom: const TabBar(
            indicatorColor: AppColors.lilac,
            tabs: [
              Tab(text: 'Grimório Ancestral'),
              Tab(text: 'Meu Grimório'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AppSpellsListPage(),
            UserSpellsListPage(),
          ],
        ),
      ),
    );
  }
}
