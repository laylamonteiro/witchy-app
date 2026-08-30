import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/relogin_dialog.dart';
import '../../../cycle_reading/presentation/pages/cycle_reading_intro_page.dart';
import '../../../../core/navigation/app_deep_link.dart';
import '../../../../core/navigation/section_reset_notifier.dart';
import '../../../../core/providers/mascot_provider.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/navigation/observador_de_rotas_raiz.dart';
import '../../../../core/utils/saida_por_dois_toques.dart';
import '../caminhada_do_voltar.dart';
import '../../../../core/utils/um_de_cada_vez.dart';
import '../../../../core/widgets/mascot/cat_chat_bubble.dart';
import '../../../../core/widgets/mascot/draggable_cat_mascot.dart';
import '../../../../core/widgets/mascot/salem_tour.dart';
import '../../../../core/widgets/mascot/tour_targets.dart';
import '../../../../core/widgets/splash_screen.dart';

/// O SHELL das 4 abas (StatefulShellRoute do go_router).
///
/// Antes esta página era dona da navegação (um IndexedStack de 4 Navigators
/// aninhados e o `_selectedIndex`). Agora o [criarAppRouter] é o dono: cada aba
/// é um branch com URL própria, e esta página recebe o [navigationShell] —
/// mantendo tudo o mais que sempre foi dela (o Salem, o tour, os deep links, o
/// gesto secreto de volta e o `PopScope` que impede a saída na raiz).
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.navigationShell,
    required this.chavesDeAba,
    required this.resetNotifiers,
    required this.consumirSplashInicial,
  });

  /// O shell do go_router: `currentIndex` e `goBranch` no lugar do antigo
  /// `_selectedIndex`/IndexedStack.
  final StatefulNavigationShell navigationShell;

  /// As chaves dos Navigators de cada aba (as MESMAS instâncias do router),
  /// para a caminhada do voltar desempilhar as páginas de detalhe da aba ativa.
  final List<GlobalKey<NavigatorState>> chavesDeAba;

  /// Reset por seção (re-toque na aba ativa → volta à primeira sub-aba).
  final List<SectionResetNotifier> resetNotifiers;

  /// Splash inicial (regra dos 30 min), consumido uma vez ao montar.
  final bool Function() consumirSplashInicial;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  /// A aba atual — vem do shell do go_router. A tela inicial é SEMPRE o "Seu
  /// Dia" (aba 0), tanto em aberturas novas quanto no "refresh" de sessão.
  int get _selectedIndex => widget.navigationShell.currentIndex;

  /// Splash inicial, decidido uma vez ao montar.
  late final bool _mostrarSplash = widget.consumirSplashInicial();

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
    abaAtiva: () => widget.chavesDeAba[_selectedIndex].currentState,
    abaAtual: () => _selectedIndex,
    irParaAba: (indice) => widget.navigationShell.goBranch(indice),
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

  /// As chaves dos Navigators de aba e os notificadores de reset vêm do router
  /// (ver [criarAppRouter]): as páginas de conteúdo (detalhes de cristais,
  /// feitiços, sigilos etc.) são empilhadas DENTRO da aba pelo go_router,
  /// mantendo a bottom bar sempre visível. Fluxos de tela cheia (Configurações,
  /// Assinatura) usam o Navigator raiz. Abas: 0 = Seu Dia, 1 = Enciclopédia,
  /// 2 = Grimório, 3 = Diários.

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
    // Os resetNotifiers pertencem ao router (vivem o app inteiro); não são
    // descartados aqui.
    _mascotPosition.dispose();
    super.dispose();
  }

  /// Deep link pendente (notificação): muda para a aba de destino e volta a
  /// seção à raiz; a própria seção (ex.: Enciclopédia) escolhe a sub-aba e
  /// consome o link.
  void _onDeepLink() {
    final link = DeepLinkService.instance.pending.value?.link;
    if (link == null || !mounted) return;
    final navigator = widget.chavesDeAba[link.homeTab].currentState;
    navigator?.popUntil((route) => route.isFirst);
    if (_selectedIndex != link.homeTab) {
      widget.navigationShell.goBranch(link.homeTab);
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
      // Re-toque na aba já selecionada: volta para a raiz da seção. O
      // `initialLocation: true` desempilha as páginas de detalhe do branch, e
      // o resetNotifier reseta a TabBar interna da seção.
      widget.navigationShell.goBranch(index, initialLocation: true);
      widget.resetNotifiers[index].requestReset();
      return;
    }

    widget.navigationShell.goBranch(index);
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

  @override
  Widget build(BuildContext context) {
    // NA WEB o voltar é do go_router (histórico real) + a guarda de piso
    // (/inicio) impede a saída no Seu Dia — então NÃO interceptamos aqui
    // (`canPop: true`), o que também tira o alerta "alterações serão perdidas"
    // que o Flutter mostra quando um PopScope declara que trata o voltar.
    // NO CELULAR o voltar do sistema é `popRoute`: mantemos o intercept e a
    // caminhada (que faz o toque duplo para sair, reversível).
    final conteudo = PopScope(
      canPop: kIsWeb,
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
                        widget.navigationShell.goBranch(index),
                    onFinished: _finishTour,
                  ),
                ),
            ],
          );
        },
      ),
    );

    // Splash de marca (2,5s) só na primeira entrada — a regra dos 30 min é
    // decidida uma vez, ao montar. Fora dela, o app aparece direto.
    return _mostrarSplash ? SplashScreen(child: conteudo) : conteudo;
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
          // Páginas principais — o shell do go_router (um IndexedStack de 4
          // branches, cada aba com seu Navigator). As NavigationNotification
          // dos navigators aninhados PRECISAM subir até o Router do go_router,
          // que as usa para reportar ao sistema/navegador se ainda há o que
          // desempilhar (`setFrameworkHandlesBack`). Por isso NÃO há mais um
          // NotificationListener absorvendo-as aqui: com histórico real, quem
          // decide o back é o próprio go_router, e no piso o PopScope abaixo.
          widget.navigationShell,
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
