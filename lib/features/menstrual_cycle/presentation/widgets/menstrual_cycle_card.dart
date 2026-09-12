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
    return MagicalCard(
      key: const ValueKey('menstrual-card'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MenstrualCyclePage()),
      ),
      child: Row(
        children: [
          // A gota, não a lua: o card é do ciclo dela, e a lua já tem casa
          // em outros três cartões da mesma aba. Fora da semântica porque o
          // título logo ao lado já diz "Ciclo Menstrual" — anunciar "gota de
          // sangue" antes dele só atrapalha quem ouve a tela.
          const ExcludeSemantics(child: Text('🩸', style: TextStyle(fontSize: 32))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.menstrualCardTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  l10n.menstrualCardPoetic,
                  style: TextStyle(color: colors.lilac, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.menstrualCardIntro,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: colors.lilac, size: 16),
        ],
      ),
    );
  }
}
