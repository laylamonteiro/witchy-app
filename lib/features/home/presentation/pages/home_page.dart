import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../grimoire/presentation/pages/grimoire_page.dart';
import '../../../your_day/presentation/pages/your_day_page.dart';
import '../../../diary/presentation/pages/diary_page.dart';
import '../../../encyclopedia/presentation/pages/encyclopedia_page.dart';
import '../../../../core/navigation/app_deep_link.dart';
import '../../../../core/navigation/section_reset_notifier.dart';
import '../../../../core/providers/mascot_provider.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/mascot/cat_chat_bubble.dart';
import '../../../../core/widgets/mascot/draggable_cat_mascot.dart';
import '../../../../core/widgets/mascot/salem_tour.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  /// A tela inicial é SEMPRE o "Seu Dia" (aba 0) — tanto em aberturas novas
  /// quanto no "refresh" de sessão (AppSessionPolicy recria a navegação
  /// inteira, voltando para cá).
  int _selectedIndex = 0;

  /// Momento do último toque em "voltar" na raiz de uma aba — usado para o
  /// padrão de sair do app apenas com dois toques seguidos.
  DateTime? _lastBackPress;
  final ValueNotifier<Offset> _mascotPosition =
      ValueNotifier(const Offset(20, 120));

  /// Um Navigator aninhado por aba: as páginas de conteúdo (detalhes de
  /// cristais, feitiços, sigilos etc.) são empilhadas DENTRO da aba, mantendo
  /// a bottom bar sempre visível. Fluxos de tela cheia (Configurações,
  /// Assinatura) devem usar `Navigator.of(context, rootNavigator: true)`.
  /// Abas: 0 = Seu Dia, 1 = Enciclopédia, 2 = Grimório, 3 = Diários.
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  /// Notificadores de reset por seção (re-toque na aba ativa → seção volta
  /// à primeira aba interna).
  final List<SectionResetNotifier> _resetNotifiers = List.generate(
    4,
    (_) => SectionResetNotifier(),
  );

  late final List<Widget> _pages = [
    YourDayPage(resetNotifier: _resetNotifiers[0]),
    EncyclopediaPage(resetNotifier: _resetNotifiers[1]),
    GrimoirePage(resetNotifier: _resetNotifiers[2]),
    DiaryPage(resetNotifier: _resetNotifiers[3]),
  ];

  /// Tour do Salem em exibição?
  bool _showTour = false;

  /// Contagem de toques seguidos na tela para o Salem escondido voltar.
  int _returnTapCount = 0;
  DateTime? _lastReturnTap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DeepLinkService.instance.pending.addListener(_onDeepLink);
    // Link pendente de um toque em notificação que ABRIU o app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onDeepLink();
      _maybeStartTour();
    });
  }

  /// 1º acesso desta conta: o Salem apresenta o app (com opção de pular).
  void _maybeStartTour() {
    if (!mounted || _showTour) return;
    final mascot = context.read<MascotProvider>();
    final userId = context.read<AuthProvider>().currentUser.id;
    if (!mascot.hasSeenTour(userId)) {
      setState(() => _showTour = true);
    }
  }

  void _finishTour() {
    final mascot = context.read<MascotProvider>();
    final userId = context.read<AuthProvider>().currentUser.id;
    mascot.markTourSeen(userId);
    setState(() => _showTour = false);
  }

  /// Salem escondido: 5 toques seguidos em qualquer lugar da tela (janela de
  /// 1,5s entre toques) o trazem de volta em fumaça.
  void _onHiddenScreenTap(PointerDownEvent _) {
    final now = DateTime.now();
    if (_lastReturnTap != null &&
        now.difference(_lastReturnTap!).inMilliseconds > 1500) {
      _returnTapCount = 0;
    }
    _lastReturnTap = now;
    _returnTapCount++;
    if (_returnTapCount >= 5) {
      _returnTapCount = 0;
      context.read<MascotProvider>().show();
    }
  }

  @override
  void dispose() {
    DeepLinkService.instance.pending.removeListener(_onDeepLink);
    WidgetsBinding.instance.removeObserver(this);
    for (final notifier in _resetNotifiers) {
      notifier.dispose();
    }
    _mascotPosition.dispose();
    super.dispose();
  }

  /// Deep link pendente (notificação): muda para a aba de destino e volta a
  /// seção à raiz; a própria seção (ex.: Enciclopédia) escolhe a sub-aba e
  /// consome o link.
  void _onDeepLink() {
    final link = DeepLinkService.instance.pending.value?.link;
    if (link == null || !mounted) return;
    _navigatorKeys[link.homeTab]
        .currentState
        ?.popUntil((route) => route.isFirst);
    if (_selectedIndex != link.homeTab) {
      setState(() => _selectedIndex = link.homeTab);
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
  }

  /// Gesto/botão de voltar: SEMPRE prioriza voltar de página em vez de sair.
  /// Ordem: 1) fluxos de tela cheia sobre a home (Configurações, Assinatura);
  /// 2) páginas de detalhe empilhadas dentro da aba ativa; 3) só na raiz de
  /// uma aba, exige um segundo toque em 2s para de fato sair do app.
  void _handleSystemBack() {
    // 1. Rotas empilhadas no Navigator raiz (tela cheia sobre a home).
    final rootNavigator = Navigator.of(context);
    if (rootNavigator.canPop()) {
      rootNavigator.pop();
      return;
    }

    // 2. Páginas de detalhe dentro da aba ativa.
    final tabNavigator = _navigatorKeys[_selectedIndex].currentState;
    if (tabNavigator != null && tabNavigator.canPop()) {
      tabNavigator.pop();
      return;
    }

    // 3. Raiz de uma aba: sair só com toque duplo.
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).commonBackAgainToExit),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    SystemNavigator.pop();
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
        body: Consumer<MascotProvider>(
          builder: (context, mascot, _) {
            if (mascot.tourRequested) {
              // "Rever tour com o Salem" nas Configurações.
              mascot.consumeTourRequest();
              _showTour = true;
            }
            return Stack(
              children: [
                // Páginas principais — cada aba com seu próprio Navigator
                IndexedStack(
                  index: _selectedIndex,
                  children: List.generate(4, _buildTabNavigator),
                ),
                if (!mascot.isHidden) ...[
                  CatChatBubble(mascotPosition: _mascotPosition),
                  // Mascote flutuando sobre o conteúdo — sobrepõe o balão
                  DraggableCatMascot(
                    initialX: 20,
                    initialY: 120,
                    size: 100,
                    positionNotifier: _mascotPosition,
                    onDismissed: mascot.hide,
                    // Voltou do esconderijo → materializa em fumaça.
                    appearInSmoke: mascot.appearPending,
                    onAppeared: mascot.consumeAppearPending,
                  ),
                ] else
                  // Salem escondido: contador invisível de toques para ele
                  // voltar. Translucent = não bloqueia a UI de baixo.
                  Positioned.fill(
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: _onHiddenScreenTap,
                    ),
                  ),
                if (_showTour)
                  SalemTourOverlay(
                    onTabChange: (index) =>
                        setState(() => _selectedIndex = index),
                    onFinished: _finishTour,
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: context.gc.surfaceBorder,
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.auto_awesome),
                label: AppLocalizations.of(context).navYourDay,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.auto_stories),
                label: AppLocalizations.of(context).navEncyclopedia,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.stars_outlined),
                label: AppLocalizations.of(context).navGrimoire,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu_book),
                label: AppLocalizations.of(context).navDiaries,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
