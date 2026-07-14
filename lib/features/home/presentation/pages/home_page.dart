import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../grimoire/presentation/pages/grimoire_page.dart';
import '../../../diary/presentation/pages/diary_page.dart';
import '../../../encyclopedia/presentation/pages/encyclopedia_page.dart';
import '../../../../core/navigation/section_reset_notifier.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/mascot/cat_chat_bubble.dart';
import '../../../../core/widgets/mascot/draggable_cat_mascot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  static const String _lastTabKey = 'last_selected_tab';

  /// Um Navigator aninhado por aba: as páginas de conteúdo (detalhes de
  /// cristais, feitiços, sigilos etc.) são empilhadas DENTRO da aba, mantendo
  /// a bottom bar sempre visível. Fluxos de tela cheia (Configurações,
  /// Assinatura) devem usar `Navigator.of(context, rootNavigator: true)`.
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    3,
    (_) => GlobalKey<NavigatorState>(),
  );

  /// Notificadores de reset por seção (re-toque na aba ativa → seção volta
  /// à primeira aba interna).
  final List<SectionResetNotifier> _resetNotifiers = List.generate(
    3,
    (_) => SectionResetNotifier(),
  );

  late final List<Widget> _pages = [
    EncyclopediaPage(resetNotifier: _resetNotifiers[0]),
    GrimoirePage(resetNotifier: _resetNotifiers[1]),
    DiaryPage(resetNotifier: _resetNotifiers[2]),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLastTab();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final notifier in _resetNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> _loadLastTab() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTab = prefs.getInt(_lastTabKey) ?? 0;
    if (mounted && lastTab != _selectedIndex) {
      setState(() {
        _selectedIndex = lastTab;
      });
    }
  }

  Future<void> _saveLastTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastTabKey, index);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Salvar tab atual quando app vai para background
      _saveLastTab(_selectedIndex);
    }
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) {
      // Re-toque na aba já selecionada: volta para a raiz da seção
      // (desempilha as páginas de detalhe e reseta a TabBar interna).
      final navigator = _navigatorKeys[index].currentState;
      navigator?.popUntil((route) => route.isFirst);
      _resetNotifiers[index].requestReset();
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    _saveLastTab(index);
  }

  /// Botão voltar do Android: primeiro desempilha o Navigator da aba ativa;
  /// se já estiver na raiz, sai do app.
  void _handleSystemBack() {
    final navigator = _navigatorKeys[_selectedIndex].currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    } else {
      SystemNavigator.pop();
    }
  }

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (_) => _pages[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleSystemBack();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Páginas principais — cada aba com seu próprio Navigator
            IndexedStack(
              index: _selectedIndex,
              children: List.generate(3, _buildTabNavigator),
            ),
            // Mascote arrastável flutuando sobre o conteúdo
            DraggableCatMascot(
              initialX: 20,
              initialY: 120,
              size: 100,
              onTap: () {
                // Opcional: adicionar interação ao clicar no mascote
              },
            ),
            // Balão de conversa diário (1x/dia) — irmão do mascote, não o
            // modifica nem interfere nas suas interações
            const CatChatBubble(),
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
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_stories),
                label: 'Enciclopédia',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.stars_outlined),
                label: 'Grimório',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: 'Diários',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
