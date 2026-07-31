import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../grimoire/presentation/pages/spell_detail_page.dart';
import '../../data/models/guided_ritual_model.dart';

/// CTA "Criar feitiço deste momento": gera o feitiço DIRETO via IA (mesmo
/// motor do Conselheiro Místico), já com o contexto do ritual que a Bruxa
/// está fazendo (nome, propósito e correspondências), e abre o resultado
/// pronto para salvar — sem passar pelo formulário.
Future<void> generateRitualSpell(
  BuildContext context,
  GuidedRitual ritual,
) async {
  final l10n = AppLocalizations.of(context);
  final authProvider = context.read<AuthProvider>();

  // Mesmo gate diário da criação de feitiços por IA.
  if (!authProvider.currentUser.canUseAi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.aiSpellDailyLimit),
        backgroundColor: context.gc.alert,
        duration: const Duration(seconds: 4),
      ),
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PremiumUpgradeSheet(),
    );
    return;
  }

  // Diálogo de espera enquanto a IA escreve o feitiço.
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      backgroundColor: context.gc.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.guidedRitualCreatingSpell)),
          ],
        ),
      ),
    ),
  );

  try {
    final intention = l10n.guidedRitualSpellContext(
      ritual.title,
      ritual.intro,
      ritual.crystals.take(4).join(', '),
      ritual.herbs.take(4).join(', '),
    );
    final spell = await AIService.instance.generateSpell(intention);
    await authProvider.incrementAiConsultations();

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // fecha o diálogo
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpellDetailPage(spell: spell, showSaveButton: true),
      ),
    );
    AdService.instance.maybeShowInterstitial();
  } catch (e) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // fecha o diálogo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.aiSpellGenericError),
        backgroundColor: context.gc.alert,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
