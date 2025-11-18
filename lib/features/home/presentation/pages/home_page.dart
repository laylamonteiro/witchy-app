import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../lunar/presentation/pages/lunar_calendar_page.dart';
import '../../../grimoire/presentation/pages/grimoire_list_page.dart';
import '../../../diary/presentation/pages/diary_page.dart';
import '../../../encyclopedia/presentation/pages/encyclopedia_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_assets.dart';

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
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _selectedIndex == 0 ? AppAssets.moonLight : AppAssets.moonDark,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 0 ? AppColors.lilac : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Lua',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AppAssets.grimoireDark,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 1 ? AppColors.lilac : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Grimório',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AppAssets.diaryDark,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 2 ? AppColors.lilac : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Diários',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AppAssets.crystalsDark,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 3 ? AppColors.lilac : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Enciclopédia',
            ),
          ],
        ),
      ),
    );
  }
}
