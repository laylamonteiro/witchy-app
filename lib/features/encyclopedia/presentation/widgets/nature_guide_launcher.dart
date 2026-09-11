import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:grimorio_de_bolso/core/widgets/folha_com_saida.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../data/models/user_entry_model.dart';
import '../pages/add_entry_page.dart';

/// Guia da Natureza: pergunta O QUE identificar (erva/pedra) e leva ao
/// fluxo de foto + IA da enciclopédia. Compartilhado pela ferramenta do
/// Grimório e pelo atalho do Seu Dia. O gate Premium é da própria
/// AddEntryPage — aqui não se duplica paywall. Quem não tem acesso chega
/// à tela da foto e vê os campos que o verbete traria; nada é gerado.
///
/// Cores ficaram de fora de propósito: a seção de Cores é só o catálogo
/// oficial (roda + páginas completas), sem identificação por foto.
Future<void> openNatureGuide(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final category = await mostrarFolhaComSaida<UserEntryCategory>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // A alça pintada saiu: quem anuncia o gesto agora é a do
            // Material, e quem dá a saída visível é o X.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      l10n.toolNatureGuideSheetTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(sheetContext).textTheme.titleLarge,
                    ),
                  ),
                  const BotaoFecharFolha(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _categoryTile(
                sheetContext, '🌿', l10n.encyTabHerbs, UserEntryCategory.herb),
            _categoryTile(sheetContext, '💎', l10n.encyTabCrystals,
                UserEntryCategory.crystal),
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
