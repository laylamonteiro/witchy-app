import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/relogin_dialog.dart';
import '../../../cycle_reading/presentation/pages/cycle_reading_intro_page.dart';
import '../../../grimoire/presentation/pages/grimoire_page.dart';
import '../../../your_day/presentation/pages/your_day_page.dart';
import '../../../diary/presentation/pages/diary_page.dart';
import '../../../encyclopedia/presentation/pages/encyclopedia_page.dart';
import '../../../../core/navigation/app_deep_link.dart';
import '../../../../core/navigation/section_reset_notifier.dart';
import '../../../../core/providers/mascot_provider.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/navigation/observador_de_rotas_raiz.dart';
import '../../../../core/utils/saida_por_dois_toques.dart';
import '../caminhada_do_voltar.dart';
import '../../../../core/utils/um_de_cada_vez.dart';
import '../../../../core/widgets/mascot/cat_chat_bubble.dart';
import '../../../../core/widgets/mascot/draggable_cat_mascot.dart';
import '../../../../core/widgets/mascot/salem_tour.dart';
import '../../../../core/widgets/mascot/tour_targets.dart';

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

  /// A regra do "voltar de novo para sair".
  ///
  /// NA WEB ELA NÃO É MAIS CONSULTADA: o passo 4 da caminhada termina antes,
  /// porque `SaidaDaAbaReal.podeSair()` é `false` na web — o app não fecha a
  /// aba que não abriu (ver [SaidaDaAbaReal]). Fica valendo no celular, onde
  /// sair é ir para segundo plano: reversível, um toque traz de volta, e o
  /// toque duplo rápido de sempre é o esperado.
  ///
  /// Ver [SaidaPorDoisToques] — inclusive para o registro do piso anti-rajada
  /// que existiu aqui e por que ele não defendia de nada.
  final _saida = SaidaPorDoisToques();

  /// A caminhada do voltar, fora do widget para poder ser testada — ver
  /// [CaminhadaDoVoltar]. As bordas (navegadores, aba, aviso) são estas
  /// aqui; a decisão é dela.
  late final CaminhadaDoVoltar _caminhada = CaminhadaDoVoltar(
    raiz: () => mounted ? Navigator.maybeOf(context) : null,
    abaAtiva: () => _navigatorKeys[_selectedIndex].currentState,
    abaAtual: () => _selectedIndex,
    irParaAba: (indice) => setState(() => _selectedIndex = indice),
    mostrarAviso: _avisarQueOProximoSai,
    mostrarFimDaCaminhada: _avisarQueJaEstaNoSeuDia,
    regra: _saida,
    vivo: () => mounted,
  );

  /// Um voltar por vez.
  ///
  /// [_handleSystemBack] é assíncrono e espera em dois `maybePop`. Enquanto
  /// ele espera, NADA impedia uma segunda entrada: o `PopScope` chama o
  /// mesmo método a cada pop RECUSADO, e um pop recusado por uma rota de
  /// cima (ou um segundo toque rápido) chega enquanto o primeiro ainda está
  /// em voo. Duas execuções em paralelo desempilham duas telas de uma vez;
  /// em cadeia, recursam até a pilha estourar — foi assim que o
  /// WebBackKeeper morreu.
  final _voltar = UmDeCadaVez();

  /// Tamanho e ponto de partida do Salem: centro superior da tela. Vale para
  /// toda entrada em cena — abertura, "refresh" de sessão e volta do
  /// esconderijo (o mascote é recriado nos três casos, então nasce aqui).
  static const double _mascotSize = 100;
  static const double _mascotTop = 110;

  final ValueNotifier<Offset> _mascotPosition =
      ValueNotifier(const Offset(0, _mascotTop));

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

  /// Gesto secreto para o Salem escondido voltar: 5 toques rápidos NO MESMO
  /// PONTO da tela. O ponto importa — contar toques em qualquer lugar fazia
  /// ele reaparecer sozinho enquanto a Bruxa só navegava pelo app.
  static const int _returnTapsNeeded = 5;
  static const double _returnTapRadius = 48;
  static const Duration _returnTapWindow = Duration(milliseconds: 900);

  int _returnTapCount = 0;
  DateTime? _lastReturnTap;
  Offset? _returnTapAnchor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DeepLinkService.instance.pending.addListener(_onDeepLink);
    // Uma tela cheia que abre ou fecha na raiz caduca o aviso de saída: o
    // framework a desempilha sem passar por aqui, e um aviso dado antes
    // dela sairia do app sem nada na tela. Ver [mudancasDaPilhaRaiz].
    mudancasDaPilhaRaiz.addListener(_esquecerASaida);
    // Link pendente de um toque em notificação que ABRIU o app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onDeepLink();
      _maybeStartTour();
      // Conta "logada" sem sessão Supabase (cadastros de 20-27/08 que a
      // exigência de confirmação deixou sem token): pede o re-login que
      // reativa a sincronização. Ver ReloginDialog.
      ReloginDialog.maybeShow(context);
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
    // O Salem-guia sai de cena e o mascote real entra em fumaça no lugar.
    mascot.materializeNext();
    setState(() => _showTour = false);
  }

  /// Salem escondido volta em fumaça com 5 toques rápidos no mesmo ponto.
  /// Toque longe do anterior, ou depois da janela de tempo, recomeça a
  /// contagem — navegar pelo app não é gesto secreto.
  void _onHiddenScreenTap(PointerDownEvent event) {
    final now = DateTime.now();
    final lastTap = _lastReturnTap;
    final anchor = _returnTapAnchor;

    final restarted = lastTap == null ||
        now.difference(lastTap) > _returnTapWindow ||
        anchor == null ||
        (event.position - anchor).distance > _returnTapRadius;

    _lastReturnTap = now;
    if (restarted) {
      _returnTapCount = 1;
      _returnTapAnchor = event.position;
      return;
    }

    _returnTapCount++;
    if (_returnTapCount >= _returnTapsNeeded) {
      _returnTapCount = 0;
      _returnTapAnchor = null;
      context.read<MascotProvider>().show();
    }
  }

  @override
  void dispose() {
    DeepLinkService.instance.pending.removeListener(_onDeepLink);
    mudancasDaPilhaRaiz.removeListener(_esquecerASaida);
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
    final navigator = _navigatorKeys[link.homeTab].currentState;
    navigator?.popUntil((route) => route.isFirst);
    if (_selectedIndex != link.homeTab) {
      setState(() => _selectedIndex = link.homeTab);
    }

    // A Leitura do Ciclo não tem aba própria: o convite empilha a página
    // sobre a aba de destino e consome o link aqui mesmo (nenhuma seção
    // reivindica este destino, então ninguém mais o consumiria).
    if (link.opensCycleReading) {
      navigator?.push(
        MaterialPageRoute(builder: (_) => const CycleReadingIntroPage()),
      );
      DeepLinkService.instance.consume();
    }
  }

  void _onTabTapped(int index) {
    // Trocar de aba pela barra também caduca o aviso de saída: quem
    // navegou mudou de ideia, e o voltar seguinte tem de recomeçar a
    // caminhada em vez de encontrar uma saída armada.
    _esquecerASaida();
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
  /// 2) páginas de detalhe empilhadas dentro da aba ativa; 3) raiz de outra
  /// aba volta para o Seu Dia; 4) só no Seu Dia, um segundo toque em 2s sai
  /// de fato do app.
  ///
  /// Esta camada só faz uma coisa: garantir que a decisão aconteça UMA vez
  /// por vez. Ver [_voltar].
  Future<void> _handleSystemBack() => _voltar.executar(_caminhada.resolver);

  void _esquecerASaida() => _saida.esquecer();

  /// "Toque de novo para sair" — com a duração da PRÓPRIA janela da regra:
  /// um aviso que some antes de a janela fechar deixaria a saída armada
  /// com a tela já limpa, que é o jeito de sair sem querer.
  void _avisarQueOProximoSai() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).commonBackAgainToExit),
        duration: _saida.janela,
      ),
    );
  }

  /// "Você já está no Seu Dia" — o fim da caminhada na web, onde o voltar não
  /// sai do app.
  ///
  /// Sem fila de propósito (`removeCurrentSnackBar` antes): numa sequência de
  /// voltares a mensagem é sempre a mesma, e cinco delas enfileiradas ficariam
  /// dez segundos na tela depois de a Bruxa ter parado de deslizar.
  void _avisarQueJaEstaNoSeuDia() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).commonAlreadyAtYourDay),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget _buildTabNavigator(int index) {
    // Aba escondida não é aba em cena: sem ticker, nada anima atrás da aba
    // que a pessoa está olhando — e o card de Ritos sabe adiar a celebração
    // do dia selado para quando a aba volta, em vez de gastá-la invisível.
    // (O IndexedStack, ao contrário do que se supõe, mantém o ticker dos
    // filhos escondidos vivo; quem desliga é este TickerMode.) O mascote
    // fica FORA da pilha de abas, então segue animando normalmente.
    return TickerMode(
      enabled: index == _selectedIndex,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => _pages[index],
        ),
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
      child: Consumer<MascotProvider>(
        builder: (context, mascot, _) {
          if (mascot.tourRequested) {
            // "Rever tour com o Salem" nas Configurações.
            mascot.consumeTourRequest();
            _showTour = true;
          }
          // O tour vive FORA do Scaffold para escurecer a tela inteira —
          // inclusive a bottom bar, que ele ilumina item a item.
          return Stack(
            children: [
              Positioned.fill(
                child: _buildScaffold(context, mascot),
              ),
              if (_showTour)
                Positioned.fill(
                  child: SalemTourOverlay(
                    onTabChange: (index) =>
                        setState(() => _selectedIndex = index),
                    onFinished: _finishTour,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, MascotProvider mascot) {
    // Durante o tour quem aparece é o Salem-guia do overlay: o mascote real
    // (e o contador de toques para trazê-lo de volta) fica fora de cena.
    final showMascot = !mascot.isHidden && !_showTour;
    final showReturnTapCounter = mascot.isHidden && !_showTour;
    final mascotLeft =
        (MediaQuery.of(context).size.width - _mascotSize) / 2;

    return Scaffold(
      body: Stack(
        children: [
          // Páginas principais — cada aba com seu próprio Navigator.
          // O NotificationListener ABSORVE as NavigationNotification dos
          // navigators aninhados: com o predictive back do Android
          // (targetSdk 36), quando um navigator de aba esvaziava ele
          // avisava o sistema "não tenho mais nada a tratar"
          // (setFrameworkHandlesBack(false)) e o gesto seguinte fechava o
          // app sem consultar o PopScope desta página. Quem manda no back
          // é sempre o PopScope raiz (canPop: false).
          NotificationListener<NavigationNotification>(
            onNotification: (_) => true,
            child: IndexedStack(
              index: _selectedIndex,
              children: List.generate(4, _buildTabNavigator),
            ),
          ),
          if (showMascot) ...[
            CatChatBubble(mascotPosition: _mascotPosition),
            // Mascote flutuando sobre o conteúdo — sobrepõe o balão
            DraggableCatMascot(
              initialX: mascotLeft,
              initialY: _mascotTop,
              size: _mascotSize,
              positionNotifier: _mascotPosition,
              onDismissed: mascot.hide,
              // Voltou do esconderijo (ou do tour) → materializa em fumaça.
              appearInSmoke: mascot.appearPending,
              onAppeared: mascot.consumeAppearPending,
            ),
          ],
          if (showReturnTapCounter)
            // Salem escondido: contador invisível de toques para ele voltar.
            // Translucent = não bloqueia a UI de baixo.
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _onHiddenScreenTap,
              ),
            ),
        ],
      ),
      bottomNavigationBar: TourTarget(
        id: TourTargetIds.bottomBar,
        child: Container(
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
                icon: _NavIcon(
                  selected: _selectedIndex == 0,
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome,
                ),
                label: AppLocalizations.of(context).navYourDay,
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(
                  selected: _selectedIndex == 1,
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories,
                ),
                label: AppLocalizations.of(context).navEncyclopedia,
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(
                  selected: _selectedIndex == 2,
                  icon: Icons.stars_outlined,
                  activeIcon: Icons.stars,
                ),
                label: AppLocalizations.of(context).navGrimoire,
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(
                  selected: _selectedIndex == 3,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                ),
                label: AppLocalizations.of(context).navDiaries,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ícone da barra inferior: o item selecionado assenta (0.92 → 1, sobe 2 px)
/// com um brilho lilás muito leve e a versão preenchida do ícone; os demais
/// descansam levemente recolhidos. Só Transform/efeito visual — a largura de
/// cada slot não muda, então o spotlight do tour continua alinhado.
///
/// Nada aqui mexe em re-tap, reset de seção, back ou deep link: o widget é
/// só a cara do item, o comportamento segue no BottomNavigationBar.
class _NavIcon extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final IconData activeIcon;

  const _NavIcon({
    required this.selected,
    required this.icon,
    required this.activeIcon,
  });

  @override
  Widget build(BuildContext context) {
    // 180 ms de propósito, entre tap (140) e state (260): navegação pede
    // resposta mais viva que uma mudança de estado, sem virar estalo.
    final duration = GrimoireMotion.reduced(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);

    return AnimatedContainer(
      duration: duration,
      curve: GrimoireMotion.enter,
      transform: Matrix4.translationValues(0, selected ? 0 : 2, 0),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: context.gc.lilac.withValues(alpha: 0.18),
                  blurRadius: 14,
                ),
              ]
            : const [],
      ),
      child: AnimatedScale(
        scale: selected ? 1.0 : 0.92,
        duration: duration,
        curve: GrimoireMotion.enter,
        child: AnimatedSwitcher(
          duration: duration,
          child: Icon(
            selected ? activeIcon : icon,
            key: ValueKey(selected),
          ),
        ),
      ),
    );
  }
}
