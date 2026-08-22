import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/guarda_de_voltar_web.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../core/widgets/starfield_background.dart';
import '../widgets/auth_motion.dart';
import '../widgets/breathing_badge.dart';
import 'login_page.dart';
import 'signup_page.dart';

/// Tela de boas-vindas com opções de login ou cadastro.
///
/// Vive na mesma linguagem de movimento do resto do app: céu estrelado
/// cintilando, emblema respirando (ciclo de 3s) e entrada em cascata.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Quando a espera do retorno OAuth vence sem sessão, é aqui que a pessoa
    // cai — ainda com o Google como página anterior do histórico. Sem o
    // guarda, o voltar a tirava do app na única tela em que ela ainda nem
    // entrou.
    return GuardaDeVoltarWeb(
      child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1033), // Roxo mais escuro no topo
              context.gc.background,
            ],
          ),
        ),
        child: StarfieldBackground(
          child: SafeArea(
            // Teto de largura para a web desktop: sem ele a coluna se espalha
            // pela janela inteira. Centralizado em ~480, mantém a leitura de
            // "aplicativo no bolso" em qualquer tela (o starfield fica fora,
            // então as estrelas seguem preenchendo o fundo todo).
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              // Em telas baixas o conteúdo fixo passa da altura e os Spacers
              // colapsam — sem isto, o rodapé era CORTADO. O minHeight mantém
              // o layout esticado (Spacers vivos) quando a altura sobra; a
              // rolagem só existe quando falta.
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          // Logo/Ícone respirando
                          CascadeIn(index: 0, child: _buildLogo(context)),
                          const SizedBox(height: 16),
                          // Título — linha única, encolhe se a largura apertar
                          CascadeIn(
                            index: 1,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Grimório de Bolso',
                                style: GoogleFonts.cinzelDecorative(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: context.gc.lilac,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subtítulo
                          CascadeIn(
                            index: 2,
                            child: Text(
                              AppLocalizations.of(context).welcomeSubtitle,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: context.gc.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Spacer(flex: 2),
                          // Features preview
                          CascadeIn(
                              index: 3, child: _buildFeaturesList(context)),
                          const Spacer(flex: 2),
                          // Botões
                          CascadeIn(index: 4, child: _buildButtons(context)),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    ),
    ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        BreathingBadge(
          glowColor: context.gc.lilac,
          haloSize: 144,
          // O ícone oficial do app, o mesmo do splash e do cartão de
          // compartilhamento. A arte já é um círculo com anel lilás e fundo
          // escuro, então aqui não entra gradiente nem borda — seria anel
          // sobre anel. O ClipOval só apara a moldura do PNG.
          child: ClipOval(
            child: Image.asset(
              'assets/app_icon.png',
              width: 120,
              height: 120,
              // Se o asset não carregar, volta o emblema desenhado que a
              // tela usava antes — a boas-vindas nunca fica sem símbolo.
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.gc.lilac.withValues(alpha: 0.3),
                      context.gc.pink.withValues(alpha: 0.3),
                    ],
                  ),
                  border: Border.all(
                    color: context.gc.lilac.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.auto_stories,
                  size: 56,
                  color: context.gc.lilac,
                ),
              ),
            ),
          ),
        ),
        // Uma faísca orbita o emblema — a linguagem de órbita do app.
        OrbitingSparkle(radius: 78, color: context.gc.starYellow),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final features = [
      (l10n.welcomeFeatureLunar, Icons.nightlight_round),
      (l10n.welcomeFeatureGrimoire, Icons.menu_book),
      (l10n.welcomeFeatureDiaries, Icons.book),
      (l10n.welcomeFeatureAstrology, Icons.stars),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.gc.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.gc.surfaceBorder,
        ),
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.gc.lilac.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature.$2,
                    color: context.gc.lilac,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  feature.$1,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: context.gc.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Botão de cadastro (primário) com brilho respirando
        PressableScale(
          child: BreathingGlow(
            color: context.gc.lilac,
            child: SheenSweep(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.gc.lilac,
                foregroundColor: const Color(0xFF2B2143),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).authCreateAccount,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Botão de login (secundário)
        PressableScale(
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.gc.lilac,
              side: BorderSide(color: context.gc.lilac, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).welcomeHaveAccount,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ),
        ),
      ],
    );
  }
}
