import 'package:flutter/material.dart';
import 'dreams_list_page.dart';
import 'desires_list_page.dart';
import '../../../../core/theme/app_theme.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Diários'),
          bottom: const TabBar(
            indicatorColor: AppColors.lilac,
            tabs: [
              Tab(text: 'Sonhos'),
              Tab(text: 'Desejos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DreamsListPage(),
            DesiresListPage(),
          ],
        ),
      ),
    );
  }
}
