import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/utils/mask.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/debug_log_service.dart';
import '../providers/auth_provider.dart';
import 'welcome_page.dart';
import '../../../../features/home/presentation/pages/home_page.dart';
import '../../../../core/widgets/splash_screen.dart';

/// Widget wrapper que gerencia o fluxo de autenticação
/// Decide se mostra a tela de boas-vindas ou a home
class AuthWrapper extends StatelessWidget {
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
        // Aguardando inicialização
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Verificar se tem conta autenticada (email válido)
        final isAuthenticated = authProvider.currentUser.isAuthenticated;

        // Log para debug (fire-and-forget)
        debugLog('NAV',
            'AuthWrapper: isAuthenticated=$isAuthenticated, email=${maskEmail(authProvider.currentUser.email)}');

        // Volta do login social com a troca do código ainda em voo: a
        // sessão está a caminho do servidor. Mostrar a tela de login agora
        // seria mentir ("não funcionou") para alguém cujo login FUNCIONOU —
        // e induzir o segundo login que virou rotina. Espera com nome; o
        // AuthProvider libera quando a sessão chega ou após 15s.
        if (!isAuthenticated && authProvider.oauthReturnPending) {
          debugLog('NAV', 'AuthWrapper: aguardando sessão do retorno OAuth');
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

        // Se tem conta logada, ir para home
        if (isAuthenticated) {
          debugLog('NAV', 'AuthWrapper: → HomePage (autenticado)');
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authProvider.currentUser.isAuthenticated) {
      debugLog('NAV', 'RequireAuth: sem sessão → fluxo de entrada');
      return const AuthGate();
    }

    return child;
  }
}
