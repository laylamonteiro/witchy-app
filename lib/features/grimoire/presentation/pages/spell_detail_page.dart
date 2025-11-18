import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/spell_model.dart';
import '../providers/spell_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/widgets/moon_phase_widget.dart';
import '../../../../core/theme/app_theme.dart';
import 'spell_form_page.dart';

class SpellDetailPage extends StatelessWidget {
  final SpellModel spell;

  const SpellDetailPage({super.key, required this.spell});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Feitiço'),
        actions: [
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
                            ? AppColors.mint
                            : AppColors.pink,
                      ),
                      _buildChip(
                        spell.purpose,
                        AppColors.lilac,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Fase da lua
            if (spell.moonPhase != null)
              MagicalCard(
                child: Column(
                  children: [
                    Text(
                      'Fase Lunar Recomendada',
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
                      'Ingredientes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...spell.ingredients.map(
                      (ingredient) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.fiber_manual_record,
                              size: 12,
                              color: AppColors.lilac,
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
                    'Como Realizar',
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
                    const Icon(Icons.timer, color: AppColors.lilac),
                    const SizedBox(width: 12),
                    Text(
                      'Duração: ${spell.duration} ${spell.duration == 1 ? "dia" : "dias"}',
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
                      'Observações',
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
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Criado em: ${dateFormat.format(spell.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (spell.updatedAt != spell.createdAt)
                    Text(
                      'Atualizado em: ${dateFormat.format(spell.updatedAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
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
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o feitiço "${spell.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.alert,
            ),
            child: const Text('Excluir'),
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
