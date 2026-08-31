import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_wrapper.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/diary/presentation/pages/diary_page.dart';
import '../../features/encyclopedia/presentation/pages/encyclopedia_page.dart';
import '../../features/grimoire/presentation/pages/grimoire_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../../features/your_day/presentation/pages/your_day_page.dart';
import 'section_reset_notifier.dart';

/// O CONSERTO DE VERDADE DO VOLTAR: um endereço por tela.
///
/// O app viveu por muito tempo dentro de UMA entrada de histórico do navegador
/// (`SingleEntryBrowserHistory`, `replaceState`): nada crescia, e o gesto de
/// voltar não tinha entradas reais para desempilhar — na web ele "não mexia" e,
/// no Chrome Android, fechava a aba depois de alguns gestos. O próprio código
/// receitava a cura em `web/index.html`: "dar endereço próprio a cada tela".
///
/// Com `MaterialApp.router` + `usePathUrlStrategy()` + este [GoRouter], o
/// Flutter passa a usar `MultiEntriesBrowserHistory`: cada rota vira uma
/// entrada de verdade, e o voltar do navegador desempilha telas de verdade.
///
/// As 4 abas são um [StatefulShellRoute.indexedStack] — cada aba com seu
/// próprio Navigator, a bottom bar sempre visível — e o "nunca sair na raiz na
/// web" fica no `PopScope` do shell (ver [HomePage]).
///
/// Os `redirect` abaixo substituem os antigos `RequireAuth`/`GuestOnly`.

/// Caminhos das 4 abas (índices: 0=Seu Dia, 1=Enciclopédia, 2=Grimório,
/// 3=Diários) — a ordem tem de casar com a bottom bar e com a caminhada.
const String rotaSeuDia = '/seu-dia';
const String rotaEnciclopedia = '/enciclopedia';
const String rotaGrimorio = '/grimorio';
const String rotaDiarios = '/diarios';

const String rotaWelcome = '/welcome';
const String rotaLogin = '/login';
const String rotaSignup = '/signup';
const String rotaRecuperarSenha = '/recuperar-senha';
const String rotaAssinatura = '/assinatura';

/// Gate de carregamento (enquanto a sessão não foi lida do disco) e gate dos
/// estados transitórios da volta do login social.
const String _rotaCarregando = '/carregando';
const String _rotaEntrando = '/entrando';

const Set<String> _rotasDeEntrada = {rotaWelcome, rotaLogin, rotaSignup};

/// Cria o router do app. Recebe o [AuthProvider] já instanciado (o mesmo do
/// `MultiProvider`) para o `redirect` e o `refreshListenable` — assim uma
/// mudança de sessão reavalia as rotas na hora.
GoRouter criarAppRouter({
  required GlobalKey<NavigatorState> chaveRaiz,
  required AuthProvider auth,
  required List<GlobalKey<NavigatorState>> chavesDeAba,
  required List<SectionResetNotifier> resetNotifiers,
  required bool Function() consumirSplashInicial,
  List<NavigatorObserver> observadoresRaiz = const [],
}) {
  assert(chavesDeAba.length == 4);
  assert(resetNotifiers.length == 4);

  return GoRouter(
    navigatorKey: chaveRaiz,
    initialLocation: rotaSeuDia,
    observers: observadoresRaiz,
    refreshListenable: auth,
    redirect: (context, state) => _redirect(auth, state),
    // Rede de segurança: qualquer rota que não casa (URL antiga com `#/...`, um
    // link quebrado, o `/` da raiz num caso de corrida) cai no Seu Dia, e de lá
    // o `redirect` decide entrada/Home pelo estado real.
    onException: (context, state, router) => router.go(rotaSeuDia),
    routes: [
      // ── Telas de entrada (navegador raiz, tela cheia) ──
      GoRoute(
        path: rotaWelcome,
        builder: (_, __) => const WelcomePage(),
      ),
      GoRoute(
        path: rotaLogin,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: rotaSignup,
        builder: (_, __) => const SignupPage(),
      ),
      GoRoute(
        path: rotaRecuperarSenha,
        builder: (_, __) => const ChangePasswordPage(recovery: true),
      ),

      // ── Gates transitórios ──
      GoRoute(
        path: _rotaCarregando,
        builder: (_, __) => const TelaDeCarregamento(),
      ),
      GoRoute(
        path: _rotaEntrando,
        builder: (_, __) => const PortalDeEntrada(),
      ),

      // ── Telas cheias autenticadas que cobrem a bottom bar ──
      GoRoute(
        path: rotaAssinatura,
        parentNavigatorKey: chaveRaiz,
        builder: (_, __) => const SubscriptionPage(),
      ),

      // ── O shell das 4 abas ──
      StatefulShellRoute(
        builder: (context, state, navigationShell) => HomePage(
          navigationShell: navigationShell,
          chavesDeAba: chavesDeAba,
          resetNotifiers: resetNotifiers,
          consumirSplashInicial: consumirSplashInicial,
        ),
        // Como o `.indexedStack`, mas com TickerMode por aba: aba escondida não
        // anima atrás da que está em cena — e o card de "Ritos de Hoje" adia a
        // celebração do dia selado para quando a aba volta (ver daily_rites_card,
        // que consulta `TickerMode.of`). O IndexedStack sozinho mantém vivo o
        // ticker dos filhos escondidos; quem desliga é este TickerMode. Trazido
        // da main no merge, readaptado ao shell do go_router.
        navigatorContainerBuilder: (context, navigationShell, children) {
          return IndexedStack(
            index: navigationShell.currentIndex,
            children: [
              for (var i = 0; i < children.length; i++)
                TickerMode(
                  enabled: i == navigationShell.currentIndex,
                  child: children[i],
                ),
            ],
          );
        },
        branches: [
          StatefulShellBranch(
            // preload: constrói o Navigator da aba de cara (offstage), como o
            // IndexedStack da main fazia — assim `chavesDeAba[i].currentState`
            // não é null numa aba ainda não visitada (ex.: deep link de
            // notificação abrindo o Grimório com o app fechado).
            preload: true,
            navigatorKey: chavesDeAba[0],
            routes: [
              GoRoute(
                path: rotaSeuDia,
                builder: (_, __) => YourDayPage(resetNotifier: resetNotifiers[0]),
              ),
            ],
          ),
          StatefulShellBranch(
            // preload: constrói o Navigator da aba de cara (offstage), como o
            // IndexedStack da main fazia — assim `chavesDeAba[i].currentState`
            // não é null numa aba ainda não visitada (ex.: deep link de
            // notificação abrindo o Grimório com o app fechado).
            preload: true,
            navigatorKey: chavesDeAba[1],
            routes: [
              GoRoute(
                path: rotaEnciclopedia,
                builder: (_, __) =>
                    EncyclopediaPage(resetNotifier: resetNotifiers[1]),
              ),
            ],
          ),
          StatefulShellBranch(
            // preload: constrói o Navigator da aba de cara (offstage), como o
            // IndexedStack da main fazia — assim `chavesDeAba[i].currentState`
            // não é null numa aba ainda não visitada (ex.: deep link de
            // notificação abrindo o Grimório com o app fechado).
            preload: true,
            navigatorKey: chavesDeAba[2],
            routes: [
              GoRoute(
                path: rotaGrimorio,
                builder: (_, __) =>
                    GrimoirePage(resetNotifier: resetNotifiers[2]),
              ),
            ],
          ),
          StatefulShellBranch(
            // preload: constrói o Navigator da aba de cara (offstage), como o
            // IndexedStack da main fazia — assim `chavesDeAba[i].currentState`
            // não é null numa aba ainda não visitada (ex.: deep link de
            // notificação abrindo o Grimório com o app fechado).
            preload: true,
            navigatorKey: chavesDeAba[3],
            routes: [
              GoRoute(
                path: rotaDiarios,
                builder: (_, __) => DiaryPage(resetNotifier: resetNotifiers[3]),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// A decisão de rota — o que era `RequireAuth`/`GuestOnly` + os ramos
/// transitórios do antigo `AuthWrapper`, agora num lugar só.
///
/// Os EFEITOS COLATERAIS da volta do login social (fechar a janela, recomeçar
/// na raiz) NÃO moram aqui — `redirect` pode rodar várias vezes. Eles vivem na
/// [PortalDeEntrada], para onde este redirect manda enquanto o estado dura.
String? _redirect(AuthProvider auth, GoRouterState state) => decidirRedirect(
      local: state.matchedLocation,
      inicializada: auth.isInitialized,
      logada: auth.currentUser.isAuthenticated,
      oauthPendente: auth.oauthReturnPending,
      naJanelaDeLogin: AuthProvider.bootNaJanelaDeLogin,
      voltaOAuthPronta: AuthProvider.bootCameFromOAuthReturn,
    );

/// A regra de redirect, PURA (sem `BuildContext`, sem provider), para poder ser
/// testada sem montar a árvore. Devolve o destino, ou `null` para deixar passar.
@visibleForTesting
String? decidirRedirect({
  required String local,
  required bool inicializada,
  required bool logada,
  required bool oauthPendente,
  required bool naJanelaDeLogin,
  required bool voltaOAuthPronta,
}) {
  // A recuperação de senha tem token na URL e sessão própria; a página decide.
  if (local == rotaRecuperarSenha) return null;

  // A RAIZ `/` não tem tela própria (o app é servido em `/`): manda para o Seu
  // Dia e deixa o resto deste redirect decidir entrada/Home/gate pelo estado.
  if (local == '/') return rotaSeuDia;

  // Sessão ainda não lida do disco: mostrar login por meio segundo e trocar por
  // Home é pior que esperar (era o `_Carregando` do AuthWrapper).
  if (!inicializada) {
    return local == _rotaCarregando ? null : _rotaCarregando;
  }

  // Estados transitórios da volta do login social (só web). Enquanto durarem,
  // a PortalDeEntrada segura a tela — ela é GRUDENTA de propósito no caso da
  // janela de login (ver AuthWrapper original).
  final emRetornoOAuth = (!logada && oauthPendente) ||
      (logada && naJanelaDeLogin) ||
      (logada && voltaOAuthPronta);
  if (emRetornoOAuth) {
    return local == _rotaEntrando ? null : _rotaEntrando;
  }

  if (!logada) {
    // Sem sessão: só as telas de entrada. Qualquer outra vira boas-vindas.
    return _rotasDeEntrada.contains(local) ? null : rotaWelcome;
  }

  // Com sessão: nunca deixar aparecer tela de entrada nem gate transitório —
  // eles quicam para o Seu Dia (invisível: o redirect roda ANTES do build).
  // Assim, o voltar no Seu Dia que caísse em /login ou /welcome volta ao Seu
  // Dia sem mostrá-los; esgotado o histórico, o voltar sai LIMPO (sem alerta,
  // porque na web o PopScope do shell é `canPop: true`).
  if (_rotasDeEntrada.contains(local) ||
      local == _rotaCarregando ||
      local == _rotaEntrando) {
    return rotaSeuDia;
  }
  return null;
}
