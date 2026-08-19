import 'package:flutter/material.dart';
import '../../../../core/utils/mask.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/debug_log_service.dart';
import '../providers/auth_provider.dart';
import 'onboarding_page.dart';
import 'welcome_page.dart';
import '../../../../features/home/presentation/pages/home_page.dart';
import '../../../../core/widgets/splash_screen.dart';

/// Widget wrapper que gerencia o fluxo de autenticação
/// Decide se mostra onboarding, tela de boas-vindas, login ou home
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

        // Verificar se usuário já usou o app antes
        final hasSeenOnboarding = authProvider.hasSeenOnboarding;

        // Verificar se tem conta autenticada (email válido)
        final isAuthenticated = authProvider.currentUser.isAuthenticated;

        // Log para debug (fire-and-forget)
        debugLog('NAV',
            'AuthWrapper: isAuthenticated=$isAuthenticated, hasSeenOnboarding=$hasSeenOnboarding, email=${maskEmail(authProvider.currentUser.email)}');

        // Se tem conta logada, ir para home
        if (isAuthenticated) {
          debugLog('NAV', 'AuthWrapper: → HomePage (autenticado)');
          return showSplash
              ? const SplashScreen(child: HomePage())
              : const HomePage();
        }

        // Se já viu onboarding mas não tem conta, mostrar tela de boas-vindas
        if (hasSeenOnboarding) {
          debugLog('NAV', 'AuthWrapper: → WelcomePage (viu onboarding, sem conta)');
          return const WelcomePage();
        }

        // Se é primeira vez, mostrar onboarding
        debugLog('NAV', 'AuthWrapper: → OnboardingPage (primeira vez)');
        return const OnboardingPage();
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
