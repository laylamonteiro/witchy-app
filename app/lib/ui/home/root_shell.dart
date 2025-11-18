// lib/ui/home/root_shell.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../calendar/calendar_screen.dart';
import '../grimorio/spells_list_screen.dart';
import '../diaries/diaries_shell.dart';
import '../more/more_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    CalendarScreen(),
    SpellsListScreen(),
    DiariesShell(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF171425),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brightness_3_outlined),
            label: 'Lua',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Grimório',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nightlight_round_outlined),
            label: 'Diários',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}
