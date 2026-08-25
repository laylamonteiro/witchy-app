import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/utils/mask.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/debug_log_service.dart';
import '../providers/auth_provider.dart';
import '../../../../core/navigation/janela_de_login.dart';
import '../../../../core/navigation/recomeco.dart';
import 'welcome_page.dart';
import '../../../../features/home/presentation/pages/home_page.dart';
import '../../../../core/widgets/splash_screen.dart';

/// Widget wrapper que gerencia o fluxo de autenticação
/// Decide se mostra a tela de boas-vindas ou a home
class AuthWrapper extends StatelessWidget {
  /// Último estado de sessão que virou linha de log — ver o uso abaixo.
  static bool? _ultimoEstadoLogado;

  /// Se deve mostrar splash screen
  final bool showSplash;

  const AuthWrapper({
    super.key,
    this.showSplash = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Aguardando inicialização. Guardado: sem PopScope, um voltar aqui
        // não acha ninguém que o trate, e o framework cai no
        // `SystemNavigator.pop()` — que na web DESMONTA o histórico do
        // motor (ouvinte de popstate desligado, guarda apagada) e deixa o
        // voltar morto pelo resto da vida do documento.
        if (!authProvider.isInitialized) {
          return const _Carregando();
        }

        // Verificar se tem conta autenticada (email válido)
        final isAuthenticated = authProvider.currentUser.isAuthenticated;

        // Log só quando o estado MUDA: o Consumer reconstrói a cada aviso
        // do provider (dezenas de vezes num boot), e uma linha por build
        // reescrevia o log inteiro no armazenamento sem dizer nada de novo.
        if (_ultimoEstadoLogado != isAuthenticated) {
          _ultimoEstadoLogado = isAuthenticated;
          debugLog('NAV',
              'AuthWrapper: isAuthenticated=$isAuthenticated, email=${maskEmail(authProvider.currentUser.email)}');
        }

        // Volta do login social com a troca do código ainda em voo: a
        // sessão está a caminho do servidor. Mostrar a tela de login agora
        // seria mentir ("não funcionou") para alguém cujo login FUNCIONOU —
        // e induzir o segundo login que virou rotina. Espera com nome; o
        // AuthProvider libera quando a sessão chega ou após 15s.
        if (!isAuthenticated && authProvider.oauthReturnPending) {
          debugLog('NAV', 'AuthWrapper: aguardando sessão do retorno OAuth');
          // O guarda é o que faltava aqui: são até 15 segundos logo depois
          // de voltar do Google, e é JUSTAMENTE quando o Google é a entrada
          // anterior do histórico. Um voltar nesta janela saía do app.
          return const _EsperandoASessao();
        }

        // Este documento é a JANELA DE LOGIN voltando do Google (a marca
        // no armazenamento diz — o COOP do Google apaga o `opener`). Ela
        // NUNCA vira o app: o histórico dela está cheio de páginas do
        // Google, e o voltar aqui reabriria o login — o defeito que a
        // janela existe para matar. Tenta fechar-se; o COOP em geral não
        // deixa, e aí fica a tela de "pode fechar esta aba" (o Grimório
        // já abriu na aba original, que recolheu a sessão sozinha). O
        // ramo é GRUDENTO de propósito: sem limpar a marca, qualquer
        // rebuild cairia na Home e a janela viraria um segundo app.
        if (isAuthenticated && AuthProvider.bootNaJanelaDeLogin) {
          AuthProvider.bootCameFromOAuthReturn = false;
          if (fecharSeJanelaDeLogin()) {
            debugLog('NAV', 'AuthWrapper: janela de login fechada');
            return const _EsperandoASessao();
          }
          return const _JanelaDeLoginConcluida();
        }

        // A volta do login social com a sessão pronta pelo caminho de
        // página inteira (pop-up bloqueado, ou plano B). Vale o de sempre:
        // DESCARTAR este documento e recomeçar na raiz — o Supabase
        // atropela (replaceState) o estado que o motor usa para segurar o
        // voltar ao limpar o ?code= da URL, e o documento novo nasce com
        // a guarda intacta. Uma vez por login social; o boot seguinte não
        // tem ?code= e não passa por aqui.
        if (isAuthenticated && AuthProvider.bootCameFromOAuthReturn) {
          AuthProvider.bootCameFromOAuthReturn = false;
          debugLog('NAV', 'AuthWrapper: sessão do OAuth pronta → recomeço');
          recomecarNaRaiz(); // no-op fora da web
          return const _EsperandoASessao();
        }

        // Se tem conta logada, ir para home
        if (isAuthenticated) {
          debugLog('NAV', 'AuthWrapper: → HomePage (autenticado)');
          // Os 2,5s do splash vivem na rota raiz SEM `PopScope` nenhum (o da
          // Home só nasce depois do pushReplacement). Isso já exigiu um guarda
          // aqui; hoje quem cobre a janela é o `PorteiroDoVoltar`, que é
          // observador do BINDING e vale mesmo sem árvore montada.
          return showSplash
              ? const SplashScreen(child: HomePage())
              : const HomePage();
        }

        // Sem conta: a porta de entrada é a tela de boas-vindas, que já
        // apresenta o app em uma tela só.
        debugLog('NAV', 'AuthWrapper: → WelcomePage (sem conta)');
        return const WelcomePage();
      },
    );
  }
}

/// A roda de carregar das telas de espera do fluxo de entrada.
///
/// Existe como widget próprio para poder ser `const` sob o guarda de
/// voltar: toda tela da raiz precisa de alguém que trate o voltar, senão o
/// framework o entrega ao `SystemNavigator.pop()` (ver o comentário no
/// AuthWrapper).
class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

/// A espera pela sessão que vem do retorno OAuth.
///
/// Separada em widget só para poder ser `const` sob o guarda de voltar: o
/// [AuthWrapper] reconstrói a cada aviso do provider, e esta tela não muda.
class _EsperandoASessao extends StatelessWidget {
  const _EsperandoASessao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).authFinishingLogin),
          ],
        ),
      ),
    );
  }
}

/// A janela de login que fez o trabalho e não conseguiu se fechar (o COOP
/// do Google corta o direito de fechar-se): diz que o Grimório já abriu na
/// aba original e convida a fechar esta.
///
/// SEM botão de "continuar nesta aba", de propósito (decisão de 23/08,
/// depois de vê-lo em uso): esta aba foi aberta por script e carrega as
/// páginas do Google no histórico — usar o app aqui devolve o defeito do
/// voltar E o Chrome ainda FECHA a aba ao voltar além do início. O app
/// vive na aba original; esta se encerra.
class _JanelaDeLoginConcluida extends StatelessWidget {
  const _JanelaDeLoginConcluida();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 56,
                color: tema.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.authPopupDoneTitle,
                textAlign: TextAlign.center,
                style: tema.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.authPopupDoneBody,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget simples que apenas mostra o conteúdo correto sem splash
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthWrapper(showSplash: false);
  }
}

/// Exige login para entregar [child]; sem sessão, devolve o fluxo de entrada.
///
/// Rotas nomeadas são endereços de verdade na web: a URL fica `#/home` depois
/// do login e o navegador a guarda, então a visita seguinte abria a HomePage
/// direto, sem passar pelo [AuthWrapper]. Toda rota de conteúdo precisa desta
/// verificação — não basta o gate da tela inicial.
class RequireAuth extends StatelessWidget {
  final Widget child;

  const RequireAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isInitialized) {
      return const _Carregando();
    }

    if (!authProvider.currentUser.isAuthenticated) {
      debugLog('NAV', 'RequireAuth: sem sessão → fluxo de entrada');
      return const AuthGate();
    }

    return child;
  }
}

/// O oposto de [RequireAuth]: telas de ENTRADA que quem já entrou não deve
/// ver — boas-vindas, login e cadastro.
///
/// Na web o botão (ou gesto) de voltar caminha pelo histórico do navegador,
/// e o histórico guarda a URL de antes do login. Sem esta verificação, um
/// voltar depois de entrar reabria `#/login` — a tela de login por cima de
/// uma sessão viva. A pessoa não era deslogada, mas via a porta de entrada
/// de novo, o que é indistinguível de ter sido.
///
/// A correção não é só mostrar a Home no lugar: é TROCAR de rota, com a
/// pilha limpa. Renderizar a Home sob a URL `#/login` deixaria o endereço
/// mentindo e a rota de entrada guardada no histórico, pronta para o mesmo
/// susto no voltar seguinte.
class GuestOnly extends StatefulWidget {
  final Widget child;

  const GuestOnly({super.key, required this.child});

  @override
  State<GuestOnly> createState() => _GuestOnlyState();
}

class _GuestOnlyState extends State<GuestOnly> {
  bool _redirecionando = false;

  void _paraHome() {
    if (_redirecionando) return;
    _redirecionando = true;
    // Depois do frame: durante o build não se navega. Se a própria tela de
    // login já tiver empurrado a Home (o caminho normal do login), este
    // widget já saiu da árvore e o `mounted` cancela a segunda ida.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugLog('NAV', 'GuestOnly: sessão viva → /home');
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Antes de a sessão ser lida do disco não se decide nada: mostrar a tela
    // de login por meio segundo e trocar por Home é pior que esperar.
    if (!authProvider.isInitialized) {
      return const _Carregando();
    }

    if (authProvider.currentUser.isAuthenticated) {
      _paraHome();
      return const _Carregando();
    }

    return widget.child;
  }
}
