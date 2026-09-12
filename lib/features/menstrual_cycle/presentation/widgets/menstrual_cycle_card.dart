import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/menstrual_access.dart';
import '../pages/menstrual_cycle_page.dart';

/// O cartão do Ciclo Menstrual na aba Ciclos.
///
/// Só existe para quem se identifica no feminino ou no neutro — no
/// masculino não há cartão, chamada nem oferta desta funcionalidade.
///
/// Antes de ativar, o cartão apresenta a área com as próprias palavras, sem
/// “dados de exemplo” que pareçam registros de alguém. Depois de ativar, ele
/// continua discreto: mostrar o dia aqui dependeria de uma escolha
/// explícita, e ela não existe ainda.
class MenstrualCycleCard extends StatelessWidget {
  const MenstrualCycleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final access = MenstrualAccess(
      gender: auth.currentUser.gender,
      // O cartão não precisa saber se já houve consentimento: quem abre
      // encontra a porta certa, com ou sem ele.
      consented: true,
      premium: auth.isPremiumEffective,
    );
    if (!access.isOffered) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final colors = context.gc;
    final tema = Theme.of(context);
    // A língua da aba Ciclos, não a da página do Ciclo: este cartão mora ao
    // lado da Leitura e das Eras, e é com eles que precisa parecer irmão —
    // o emblema, o título em textPrimary, a linha discreta e a seta.
    return MagicalCard(
      key: const ValueKey('menstrual-card'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MenstrualCyclePage()),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A gota, não a lua: o card é do ciclo dela, e a lua já tem casa
          // em outros três cartões da mesma aba. Fora da semântica porque o
          // título logo ao lado já diz "Ciclo Menstrual" — anunciar "gota de
          // sangue" antes dele só atrapalha quem ouve a tela.
          const ExcludeSemantics(child: Text('🩸', style: TextStyle(fontSize: 34))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.menstrualCardTitle,
                  style: tema.textTheme.titleLarge?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.menstrualCardPoetic,
                  style:
                      tema.textTheme.bodySmall?.copyWith(color: colors.lilac),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.menstrualCardIntro,
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_outward, size: 18, color: colors.lilac),
        ],
      ),
    );
  }
}
