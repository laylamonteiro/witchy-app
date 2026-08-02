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

/// Chip "Minhas" das listas de cristais/ervas/cores: filtra para mostrar só
/// as entradas pessoais. A marcação de "minha" é interna (isUserEntry) — o
/// chip só aparece quando a Bruxa já criou alguma entrada na categoria.
class MineFilterChip extends StatelessWidget {
  final UserEntryCategory category;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const MineFilterChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasEntries =
        context.watch<EncyclopediaProvider>().userEntries(category).isNotEmpty;
    if (!hasEntries) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: FilterChip(
          label: Text(AppLocalizations.of(context).encyFilterMine),
          selected: selected,
          onSelected: onChanged,
          backgroundColor: context.gc.surface,
          selectedColor: context.gc.lilac.withValues(alpha: 0.25),
          checkmarkColor: context.gc.lilac,
          labelStyle: TextStyle(
            color: selected ? context.gc.lilac : context.gc.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(color: context.gc.lilac.withValues(alpha: 0.4)),
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
