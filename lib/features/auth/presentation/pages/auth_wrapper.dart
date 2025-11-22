import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

        // Se tem conta logada, ir para home
        if (isAuthenticated) {
          return showSplash
              ? const SplashScreen(child: HomePage())
              : const HomePage();
        }

        // Se já viu onboarding mas não tem conta, mostrar tela de boas-vindas
        if (hasSeenOnboarding) {
          return const WelcomePage();
        }

        // Se é primeira vez, mostrar onboarding
        return const OnboardingPage()
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
