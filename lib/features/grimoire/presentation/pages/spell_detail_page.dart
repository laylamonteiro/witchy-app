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
import 'record_form_page.dart';

class SpellDetailPage extends StatelessWidget {
  final SpellModel spell;
  final bool showSaveButton;

  const SpellDetailPage({
    super.key,
    required this.spell,
    this.showSaveButton = false,
  });

  Future<void> _saveSpell(BuildContext context) async {
    final provider = context.read<SpellProvider>();
    await provider.addSpell(spell);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).spellSavedToGrimoire),
        backgroundColor: context.gc.success,
      ),
    );

    // Voltar duas páginas (SpellDetailPage e AISpellCreationPage)
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(spell.isRecord
            ? AppLocalizations.of(context).recordDetails
            : AppLocalizations.of(context).spellDetails),
        actions: [
          if (showSaveButton) ...[
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: AppLocalizations.of(context).spellSaveToGrimoire,
              onPressed: () => _saveSpell(context),
            ),
          ] else if (!spell.isPreloaded) ...[
            // Feitiços ancestrais (pré-carregados) são somente leitura.
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => spell.isRecord
                        ? RecordFormPage(record: spell)
                        : SpellFormPage(spell: spell),
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
      body: spell.isRecord
          ? _buildRecordBody(context, dateFormat)
          : SingleChildScrollView(
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

  /// Corpo próprio das páginas de registro do Grimório Vivo: só o que faz
  /// sentido para um registro (título, origem, conteúdo escrito e datas) —
  /// sem ingredientes, fase lunar ou passos de feitiço.
  Widget _buildRecordBody(BuildContext context, DateFormat dateFormat) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spell.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (spell.purpose.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    spell.purpose,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
                if (spell.observations != null &&
                    spell.observations!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_stories,
                          size: 16, color: context.gc.lilac),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          spell.observations!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.gc.lilac,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _recordContentLines(context),
            ),
          ),
          _dateCard(context, dateFormat),
        ],
      ),
    );
  }

  /// O conteúdo da página vem como "✦ pergunta \n resposta": destaca as
  /// perguntas e mantém as respostas como texto corrido.
  List<Widget> _recordContentLines(BuildContext context) {
    final widgets = <Widget>[];
    for (final line in spell.steps.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 14));
      } else if (trimmed.startsWith('✦')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            trimmed,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
          ),
        ));
      } else {
        widgets.add(Text(
          line,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ));
      }
    }
    return widgets;
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
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).commonConfirmDelete),
        content: Text(spell.isRecord
            ? AppLocalizations.of(context).recordDeleteConfirm(spell.name)
            : AppLocalizations.of(context).spellDeleteConfirm(spell.name)),
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
