// lib/ui/diaries/diaries_shell.dart
import 'package:flutter/material.dart';
import 'dreams_list_screen.dart';
import 'desires_list_screen.dart';

class DiariesShell extends StatelessWidget {
  const DiariesShell({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Diários'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sonhos', icon: Icon(Icons.bedtime_outlined)),
              Tab(text: 'Desejos', icon: Icon(Icons.favorite_border)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DreamsListScreen(),
            DesiresListScreen(),
          ],
        ),
      ),
    );
  }
}
