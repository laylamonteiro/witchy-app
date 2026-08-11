import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/spell_model.dart';
import '../providers/spell_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/moon_phase_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'spell_form_page.dart';

class SpellDetailPage extends StatefulWidget {
  final SpellModel spell;
  final bool showSaveButton;

  const SpellDetailPage({
    super.key,
    required this.spell,
    this.showSaveButton = false,
  });

  @override
  State<SpellDetailPage> createState() => _SpellDetailPageState();
}

class _SpellDetailPageState extends State<SpellDetailPage> {
  /// Depois de salvar, a página permanece aberta e passa a se comportar
  /// como a de um feitiço do grimório (editar/excluir no lugar do salvar) —
  /// antes ela dava dois pops e expulsava a pessoa da entrada recém-criada.
  bool _saved = false;

  SpellModel get spell => widget.spell;

  Future<void> _saveSpell() async {
    if (_saved) return;
    // Marca antes do await para bloquear toques repetidos no ícone.
    setState(() => _saved = true);
    final provider = context.read<SpellProvider>();
    await provider.addSpell(spell);

    if (!mounted) return;
    if (provider.error != null) {
      // addSpell não lança: sinaliza falha via provider.error. Reabilita o
      // botão para nova tentativa.
      setState(() => _saved = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).spellSavedToGrimoire),
        backgroundColor: context.gc.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).spellDetails),
        actions: [
          if (widget.showSaveButton && !_saved) ...[
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: AppLocalizations.of(context).spellSaveToGrimoire,
              onPressed: _saveSpell,
            ),
          ] else if (!spell.isPreloaded) ...[
            // Feitiços ancestrais (pré-carregados) são somente leitura.
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpellFormPage(spell: spell),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nome e tipo
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spell.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        spell.type.displayName,
                        spell.type == SpellType.attraction
                            ? context.gc.mint
                            : context.gc.pink,
                      ),
                      _buildChip(
                        spell.purpose,
                        context.gc.lilac,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Fase da lua - apenas para premium
            if (spell.moonPhase != null &&
                context.watch<AuthProvider>().isPremium)
              MagicalCard(
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).spellRecommendedMoon,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    MoonPhaseWidget(
                      phase: spell.moonPhase!,
                      showName: true,
                      showDescription: true,
                    ),
                  ],
                ),
              ),

            // Ingredientes
            if (spell.ingredients.isNotEmpty)
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).spellIngredientsLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...spell.ingredients.map(
                      (ingredient) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              size: 12,
                              color: context.gc.lilac,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ingredient,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Passos
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).spellHowTo,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    spell.steps,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // Duração
            if (spell.duration != null)
              MagicalCard(
                child: Row(
                  children: [
                    Icon(Icons.timer, color: context.gc.lilac),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context).spellDurationDays('${spell.duration} ${spell.duration == 1 ? AppLocalizations.of(context).spellDay : AppLocalizations.of(context).spellDays}'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),

            // Observações
            if (spell.observations != null && spell.observations!.isNotEmpty)
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).spellNotesLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      spell.observations!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

            // Data de criação
            _dateCard(context, dateFormat),
          ],
        ),
      ),
    );
  }

  Widget _dateCard(BuildContext context, DateFormat dateFormat) {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)
                .spellCreatedAt(dateFormat.format(spell.createdAt)),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (spell.updatedAt != spell.createdAt)
            Text(
              AppLocalizations.of(context)
                  .spellUpdatedAt(dateFormat.format(spell.updatedAt)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: color),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).commonConfirmDelete),
        content:
            Text(AppLocalizations.of(context).spellDeleteConfirm(spell.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: context.gc.alert,
            ),
            child: Text(AppLocalizations.of(context).commonDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SpellProvider>().deleteSpell(spell.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
