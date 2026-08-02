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

/// Filtro "Minhas"/"Meus" das listas de cristais/ervas/cores: ao lado da
/// busca, no MESMO padrão do filtro de origem das Deusas (ícone que acende
/// em lilás quando ativo). Mostra só as entradas pessoais; a marcação é
/// interna (isUserEntry) e o botão aparece sempre, mesmo sem entradas.
/// O rótulo concorda em gênero com a categoria (Meus cristais, Minhas
/// ervas/cores — e no espanhol color é masculino).
class MineFilterButton extends StatelessWidget {
  final UserEntryCategory category;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const MineFilterButton({
    super.key,
    required this.category,
    required this.selected,
    required this.onChanged,
  });

  String _label(AppLocalizations l10n) {
    switch (category) {
      case UserEntryCategory.crystal:
        return l10n.encyFilterMineCrystals;
      case UserEntryCategory.herb:
        return l10n.encyFilterMineHerbs;
      case UserEntryCategory.color:
        return l10n.encyFilterMineColors;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.filter_list,
        color: selected ? context.gc.lilac : context.gc.softWhite,
      ),
      tooltip: _label(AppLocalizations.of(context)),
      onPressed: () => onChanged(!selected),
    );
  }
}

/// Véu escuro sobre a lista quando o filtro Minhas está ativo e ainda não
/// existe nenhuma entrada pessoal: escurece a página como o tour do Salem
/// e deixa só o botão Adicionar em evidência. Puramente visual
/// (IgnorePointer) — a busca e o filtro continuam tocáveis por baixo.
class MineEmptySpotlight extends StatelessWidget {
  const MineEmptySpotlight({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: Colors.black.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

/// Halo lilás pulsante em volta do FAB durante o spotlight.
class _FabHalo extends StatefulWidget {
  final Widget child;

  const _FabHalo({required this.child});

  @override
  State<_FabHalo> createState() => _FabHaloState();
}

class _FabHaloState extends State<_FabHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      // Acessibilidade: brilho fixo, sem pulsar.
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.gc.lilac.withValues(alpha: 0.55),
              blurRadius: 24,
              spreadRadius: 5,
            ),
          ],
        ),
        child: widget.child,
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.gc.lilac.withValues(alpha: 0.35 + 0.35 * t),
                blurRadius: 18 + 14 * t,
                spreadRadius: 2 + 6 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// FAB "+" das listas de cristais/ervas/cores: abre o fluxo de entrada
/// pessoal (Premium — free vê paywall dentro da página). Com [highlight],
/// ganha o halo pulsante do spotlight de lista vazia.
class AddUserEntryFab extends StatelessWidget {
  final UserEntryCategory category;
  final bool highlight;

  const AddUserEntryFab({
    super.key,
    required this.category,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget fab = _buildFab(context);
    if (highlight) fab = _FabHalo(child: fab);
    return Positioned(
      right: 16,
      bottom: 16,
      child: fab,
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
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
      );
  }
}

/// Confirmação de exclusão de uma entrada pessoal (long-press na lista ou
/// lixeira da página de detalhe). Retorna true se a entrada foi excluída —
/// a página de detalhe usa isso para se fechar em seguida.
Future<bool> confirmDeleteUserEntry(
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
    return true;
  }
  return false;
}
