import 'package:flutter/material.dart';
import '../../../lunar/presentation/pages/lunar_calendar_page.dart';
import '../../../grimoire/presentation/pages/grimoire_list_page.dart';
import '../../../diary/presentation/pages/diary_page.dart';
import '../../../encyclopedia/presentation/pages/encyclopedia_page.dart';
import '../../../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const LunarCalendarPage(),
    const GrimoireListPage(),
    const DiaryPage(),
    const EncyclopediaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.surfaceBorder,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.nightlight_round),
              label: 'Lua',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories),
              label: 'Grimório',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Diários',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.diamond),
              label: 'Enciclopédia',
            ),
          ],
        ),
      ),
    );
  }
}
