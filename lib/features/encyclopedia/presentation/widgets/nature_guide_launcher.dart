import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../data/models/user_entry_model.dart';
import '../pages/add_entry_page.dart';

/// Guia da Natureza: pergunta O QUE identificar (erva/pedra/cor) e leva ao
/// fluxo de foto + IA da enciclopédia. Compartilhado pela ferramenta do
/// Grimório e pelo atalho do Seu Dia. O gate Premium é da própria
/// AddEntryPage — aqui não se duplica paywall.
Future<void> openNatureGuide(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final category = await showModalBottomSheet<UserEntryCategory>(
    context: context,
    backgroundColor: context.gc.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: sheetContext.gc.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.toolNatureGuideSheetTitle,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _categoryTile(
                sheetContext, '🌿', l10n.encyTabHerbs, UserEntryCategory.herb),
            _categoryTile(sheetContext, '💎', l10n.encyTabCrystals,
                UserEntryCategory.crystal),
            _categoryTile(sheetContext, '🎨', l10n.encyTabColors,
                UserEntryCategory.color),
          ],
        ),
      ),
    ),
  );
  if (category == null || !context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => AddEntryPage(category: category)),
  );
}

Widget _categoryTile(
  BuildContext context,
  String emoji,
  String label,
  UserEntryCategory category,
) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.gc.lilac.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 22)),
    ),
    title: Text(label),
    onTap: () => Navigator.pop(context, category),
  );
}
