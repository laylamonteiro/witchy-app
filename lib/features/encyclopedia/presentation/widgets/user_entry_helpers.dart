import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/models/user_entry_model.dart';
import '../pages/add_entry_page.dart';
import '../providers/encyclopedia_provider.dart';

/// Selo "Minha" das entradas pessoais nas listas da enciclopédia.
class UserEntryBadge extends StatelessWidget {
  const UserEntryBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.gc.mint.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.gc.mint),
      ),
      child: Text(
        AppLocalizations.of(context).encyUserEntryBadge,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.gc.mint,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// FAB "+" das listas de cristais/ervas/cores: abre o fluxo de entrada
/// pessoal (Premium — free vê paywall dentro da página).
class AddUserEntryFab extends StatelessWidget {
  final UserEntryCategory category;

  const AddUserEntryFab({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        heroTag: 'add_user_entry_${category.key}',
        backgroundColor: context.gc.lilac,
        foregroundColor: context.gc.onPrimary,
        tooltip: AppLocalizations.of(context).encyAddFabTooltip,
        onPressed: () {
          final access = context
              .read<AuthProvider>()
              .checkFeatureAccess(AppFeature.encyclopediaPersonalEntries);
          if (!access.hasFullAccess) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const PremiumUpgradeSheet(),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEntryPage(category: category),
            ),
          );
        },
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}

/// Confirmação de exclusão de uma entrada pessoal (long-press na lista).
Future<void> confirmDeleteUserEntry(
  BuildContext context,
  UserEncyclopediaEntry entry,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: context.gc.surface,
      title: Text(l10n.encyDeleteEntryTitle),
      content: Text(l10n.encyDeleteEntryBody(entry.name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            l10n.commonDelete,
            style: TextStyle(color: context.gc.alert),
          ),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await context.read<EncyclopediaProvider>().deleteUserEntry(entry);
  }
}
