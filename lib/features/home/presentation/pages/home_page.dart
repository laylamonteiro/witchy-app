import 'package:flutter/material.dart';
import '../../../grimoire/presentation/pages/grimoire_page.dart';
import '../../../diary/presentation/pages/diary_page.dart';
import '../../../encyclopedia/presentation/pages/encyclopedia_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/mascot/draggable_cat_mascot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DiaryPage(),
    const GrimoirePage(),
    const EncyclopediaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Páginas principais
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          // Mascote arrastável flutuando sobre o conteúdo
          DraggableCatMascot(
            initialX: 20,
            initialY: 120,
            size: 70,
            onTap: () {
              // Opcional: adicionar interação ao clicar no mascote
            },
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
              icon: Icon(Icons.menu_book),
              label: 'Diários',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stars_outlined),
              label: 'Grimório',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories),
              label: 'Enciclopédia',
            ),
          ],
        ),
      ),
    );
  }
}
