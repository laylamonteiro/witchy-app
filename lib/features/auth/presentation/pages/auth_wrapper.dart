import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/debug_log_service.dart';
import '../providers/auth_provider.dart';
import '../../../../core/navigation/janela_de_login.dart';
import '../../../../core/navigation/recomeco.dart';
// A `main` padronizou as telas de espera em LoadingWidget (o merge dobrou essa
// troca dentro das classes desta versão). Só este import vem de lá: os de
// welcome/home/splash eram do AuthWrapper antigo, que saiu.
import '../../../../core/widgets/loading_widget.dart';

/// A decisão de "logada → app / sem sessão → entrada" MUDOU DE CASA: agora vive
/// no `redirect` do [criarAppRouter] (lib/core/navigation/app_router.dart), com
/// URL por tela e histórico de navegador de verdade. O antigo `AuthWrapper`
/// (mais `RequireAuth`/`AuthGate`) saiu junto — os estados TRANSITÓRIOS da volta
/// do login social ficaram na [PortalDeEntrada] abaixo, e a espera pela sessão
/// na [TelaDeCarregamento].
///
/// O [GuestOnly] continua aqui porque ainda tem teste próprio
/// (test/guest_only_routing_test.dart), e a lógica dele — telas de entrada que
/// quem já entrou não deve ver — é a mesma que o `redirect` agora aplica.

/// A roda de carregar das telas de espera do fluxo de entrada.
class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: LoadingWidget(),
      );
}

/// A espera pela sessão que vem do retorno OAuth.
class _EsperandoASessao extends StatelessWidget {
  const _EsperandoASessao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget(message: AppLocalizations.of(context).authFinishingLogin),
    );
  }
}

/// A janela de login que fez o trabalho e não conseguiu se fechar (o COOP
/// do Google corta o direito de fechar-se): diz que o Grimório já abriu na
/// aba original e convida a fechar esta.
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

/// Tela de carregamento pública — o gate `/carregando` do [criarAppRouter]
/// enquanto a sessão não foi lida do disco.
class TelaDeCarregamento extends StatelessWidget {
  const TelaDeCarregamento({super.key});

  @override
  Widget build(BuildContext context) => const _Carregando();
}

/// O portal dos estados TRANSITÓRIOS da volta do login social — o gate
/// `/entrando` do [criarAppRouter]. Reproduz os ramos que antes viviam no
/// `AuthWrapper` (janela de login, recomeço na raiz, espera pela sessão), e é
/// AQUI que moram os efeitos colaterais (fechar a janela, `recomecarNaRaiz`) —
/// fora do `redirect`, que pode rodar várias vezes.
class PortalDeEntrada extends StatelessWidget {
  const PortalDeEntrada({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.currentUser.isAuthenticated;

    // Este documento é a JANELA DE LOGIN voltando do Google: NUNCA vira o app
    // (o histórico dela está cheio de páginas do Google). Tenta fechar-se; se o
    // COOP não deixar, fica o "pode fechar esta aba". GRUDENTO de propósito:
    // sem limpar a marca, qualquer rebuild cairia na Home.
    if (isAuthenticated && AuthProvider.bootNaJanelaDeLogin) {
      AuthProvider.bootCameFromOAuthReturn = false;
      if (fecharSeJanelaDeLogin()) {
        debugLog('NAV', 'PortalDeEntrada: janela de login fechada');
        return const _EsperandoASessao();
      }
      return const _JanelaDeLoginConcluida();
    }

    // Sessão do OAuth pronta pelo caminho de página inteira: DESCARTAR este
    // documento e recomeçar na raiz — o documento novo nasce com a URL limpa.
    if (isAuthenticated && AuthProvider.bootCameFromOAuthReturn) {
      AuthProvider.bootCameFromOAuthReturn = false;
      debugLog('NAV', 'PortalDeEntrada: sessão do OAuth pronta → recomeço');
      recomecarNaRaiz(); // no-op fora da web
      return const _EsperandoASessao();
    }

    // Volta do login social com a troca do código ainda em voo: a sessão está a
    // caminho. Espera com nome, sem mostrar a tela de login.
    return const _EsperandoASessao();
  }
}

/// Telas de ENTRADA que quem já entrou não deve ver — boas-vindas, login e
/// cadastro. Hoje o `redirect` do router faz o mesmo; este widget fica pelo
/// teste que guarda o comportamento (test/guest_only_routing_test.dart).
///
/// A correção não é só mostrar a Home no lugar: é TROCAR de rota, com a pilha
/// limpa — renderizar a Home sob a URL de login deixaria o endereço mentindo.
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugLog('NAV', 'GuestOnly: sessão viva → /home');
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
