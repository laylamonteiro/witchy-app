import 'package:flutter/material.dart';
import '../../../lunar/presentation/pages/lunar_calendar_page.dart';
import '../../../grimoire/presentation/pages/grimoire_list_page.dart';
import '../../../diary/presentation/pages/diary_page.dart';
import '../../../encyclopedia/presentation/pages/encyclopedia_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/mascot_widget.dart';

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

  final List<String> _pageNames = [
    'Lua',
    'Grimório',
    'Diários',
    'Enciclopédia',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Páginas
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          // Mascote no canto superior direito
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: MascotWidget(
              currentPage: _pageNames[_selectedIndex],
            ),
          ),
        ],
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
