import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/navigation/app_deep_link.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/tools/tool_emblem_art.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/shortcut_registry.dart';

/// Grade de atalhos personalizáveis do Seu Dia (persistidos por usuário).
class ShortcutsGrid extends StatefulWidget {
  const ShortcutsGrid({super.key});

  @override
  State<ShortcutsGrid> createState() => _ShortcutsGridState();
}

class _ShortcutsGridState extends State<ShortcutsGrid> {
  List<String> _ids = List.of(YourDayShortcuts.defaults);
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final userId = context.read<AuthProvider>().currentUser.id;
    final ids = await YourDayShortcuts.loadIds(prefs, userId);
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _ids = ids;
    });
  }

  Future<void> _edit() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    if (!mounted) return;
    final userId = context.read<AuthProvider>().currentUser.id;
    final l10n = AppLocalizations.of(context);

    final selected = Set<String>.from(_ids);
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: context.gc.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.yourDayShortcutsEditTitle,
                style: Theme.of(sheetContext).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.yourDayShortcutsEditHint,
                style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                      color: sheetContext.gc.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: YourDayShortcuts.all.map((tool) {
                  final isSelected = selected.contains(tool.id);
                  return FilterChip(
                    selected: isSelected,
                    // Emblema e nome em widgets separados: o de duas das
                    // ferramentas é desenhado, e desenho não entra numa
                    // interpolação de string. 18 aproxima o desenho do corpo
                    // do emoji no rótulo do chip.
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _EmblemaDoAtalho(tool: tool, size: 18),
                        const SizedBox(width: 6),
                        Text(tool.label(l10n)),
                      ],
                    ),
                    selectedColor: sheetContext.gc.lilac.withValues(alpha: 0.3),
                    checkmarkColor: sheetContext.gc.lilac,
                    onSelected: (value) {
                      setSheetState(() {
                        if (value) {
                          selected.add(tool.id);
                        } else {
                          selected.remove(tool.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sheetContext.gc.lilac,
                    foregroundColor: sheetContext.gc.onPrimary,
                  ),
                  onPressed: () {
                    // Preserva a ordem canônica do registry.
                    final ordered = YourDayShortcuts.all
                        .where((t) => selected.contains(t.id))
                        .map((t) => t.id)
                        .toList();
                    Navigator.of(sheetContext).pop(ordered);
                  },
                  child: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null || !mounted) return;
    await YourDayShortcuts.saveIds(prefs, userId, result);
    setState(() => _ids = result.isEmpty
        ? List.of(YourDayShortcuts.defaults)
        : result);
  }

  /// Abre a ferramenta: ação customizada, destino interno (mantém a
  /// navegação da seção) ou página empilhada.
  void _open(BuildContext context, ShortcutTool tool) {
    final onTap = tool.onTap;
    if (onTap != null) {
      onTap(context);
      return;
    }
    final link = tool.link;
    if (link != null) {
      DeepLinkService.instance.dispatch(link);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: tool.builder!));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tools = _ids
        .map(YourDayShortcuts.byId)
        .whereType<ShortcutTool>()
        .toList();

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: context.gc.starYellow),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.yourDayShortcutsTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              TextButton(
                onPressed: _edit,
                child: Text(
                  l10n.yourDayShortcutsEdit,
                  style: TextStyle(color: context.gc.lilac),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
            children: tools.map((tool) {
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _open(context, tool),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.gc.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.gc.surfaceBorder),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _EmblemaDoAtalho(tool: tool, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        tool.label(l10n),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// O emblema de um atalho: o emoji do sistema ou o desenho do app.
///
/// Existe para os dois caminhos conviverem no MESMO slot — a grade e o chip
/// do Editar pedem o emblema em tamanhos diferentes, e nenhum dos dois quer
/// saber qual dos dois caminhos aquele atalho usa.
///
/// O desenho NÃO voa (é [ToolDrawingArt] direto, e não o `ToolEmblem`): a
/// etiqueta de Hero de cada ferramenta pertence ao card do Grimório, e a aba
/// do Grimório vive no mesmo IndexedStack do shell que a aba do Seu Dia —
/// dois donos da mesma etiqueta na mesma rota derrubariam a tela. O desenho
/// também já sai da árvore de semântica por conta própria: o nome da
/// ferramenta está escrito ao lado nos dois lugares.
class _EmblemaDoAtalho extends StatelessWidget {
  const _EmblemaDoAtalho({required this.tool, required this.size});

  final ShortcutTool tool;
  final double size;

  @override
  Widget build(BuildContext context) {
    final drawing = tool.drawing;
    if (drawing != null) return ToolDrawingArt(drawing: drawing, size: size);
    // O construtor garante que, sem desenho, há emoji.
    return Text(tool.emoji!, style: TextStyle(fontSize: size));
  }
}
