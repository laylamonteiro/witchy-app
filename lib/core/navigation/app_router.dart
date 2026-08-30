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

/// O PISO do app (só web, só logada). Um degrau com URL PRÓPRIA que fica um
/// nível abaixo do Seu Dia e reempurra o Seu Dia por cima. Assim, quando a
/// Bruxa dá voltar no Seu Dia, o navegador cai AQUI (uma entrada de verdade,
/// URL distinta — o Chrome não a poda como podava os degraus de mesma URL) e o
/// piso a devolve ao Seu Dia, em vez de sair do app. É best-effort: numa recarga
/// direta em `/seu-dia` o piso não existe abaixo, e ali o voltar pode sair.
const String rotaInicio = '/inicio';

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
        path: rotaInicio,
        builder: (_, __) => const _PisoDoApp(),
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomePage(
          navigationShell: navigationShell,
          chavesDeAba: chavesDeAba,
          resetNotifiers: resetNotifiers,
          consumirSplashInicial: consumirSplashInicial,
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: chavesDeAba[0],
            routes: [
              GoRoute(
                path: rotaSeuDia,
                builder: (_, __) => YourDayPage(resetNotifier: resetNotifiers[0]),
              ),
            ],
          ),
          StatefulShellBranch(
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
    // Sem sessão: só as telas de entrada (sem piso — a pessoa ainda não entrou,
    // e prender quem só quer voltar de onde veio seria hostil). A raiz e o resto
    // viram boas-vindas.
    return _rotasDeEntrada.contains(local) ? null : rotaWelcome;
  }

  // Com sessão: a raiz, o pós-carregando, o gate e as telas de entrada passam
  // pelo PISO (/inicio), que monta e empurra /seu-dia por cima — assim o voltar
  // no Seu Dia cai no piso em vez de sair do app. Ver [rotaInicio].
  if (local == '/' ||
      local == _rotaCarregando ||
      local == _rotaEntrando ||
      _rotasDeEntrada.contains(local)) {
    return rotaInicio;
  }

  // /inicio (o piso monta e empurra /seu-dia) e as rotas de conteúdo passam.
  return null;
}

/// O PISO (ver [rotaInicio]): monta e empurra o /seu-dia por cima de si, ficando
/// um degrau abaixo com URL própria. O voltar no Seu Dia cai AQUI (o Chrome não
/// poda uma entrada de URL distinta) e este piso reempurra o Seu Dia, em vez de
/// deixar o app.
class _PisoDoApp extends StatelessWidget {
  const _PisoDoApp();

  @override
  Widget build(BuildContext context) {
    // Depois do frame (durante o build não se navega). `push` — e não `go` —
    // para o /inicio CONTINUAR embaixo, comprando o voltar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.push(rotaSeuDia);
    });
    // Enquanto empurra, a mesma tela de carregamento — sem piscar outra coisa.
    return const TelaDeCarregamento();
  }
}
