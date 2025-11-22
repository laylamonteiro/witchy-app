import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/spell_model.dart';
import '../providers/spell_provider.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/theme/app_theme.dart';

class SpellFormPage extends StatefulWidget {
  final SpellModel? spell;

  const SpellFormPage({super.key, this.spell});

  @override
  State<SpellFormPage> createState() => _SpellFormPageState();
}

class _SpellFormPageState extends State<SpellFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _purposeController;
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;
  late TextEditingController _durationController;
  late TextEditingController _observationsController;

  SpellType _selectedType = SpellType.attraction;
  SpellCategory _selectedCategory = SpellCategory.other;
  MoonPhase? _selectedMoonPhase;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.spell?.name ?? '');
    _purposeController =
        TextEditingController(text: widget.spell?.purpose ?? '');
    _ingredientsController = TextEditingController(
        text: widget.spell?.ingredients.join('\n') ?? '');
    _stepsController = TextEditingController(text: widget.spell?.steps ?? '');
    _durationController = TextEditingController(
        text: widget.spell?.duration?.toString() ?? '');
    _observationsController =
        TextEditingController(text: widget.spell?.observations ?? '');

    if (widget.spell != null) {
      _selectedType = widget.spell!.type;
      _selectedCategory = widget.spell!.category;
      _selectedMoonPhase = widget.spell!.moonPhase;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _durationController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spell == null
            ? 'Novo Feitiço'
            : 'Editar Feitiço'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Feitiço *',
                hintText: 'Ex: Proteção de Lar',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Propósito *',
                hintText: 'Ex: Proteção, Amor Próprio, Prosperidade',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SpellType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo de Feitiço *',
              ),
              items: SpellType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SpellCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria *',
              ),
              items: SpellCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Text(category.icon),
                      const SizedBox(width: 8),
                      Text(category.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MoonPhase?>(
              value: _selectedMoonPhase,
              decoration: const InputDecoration(
                labelText: 'Fase da Lua (Opcional)',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Nenhuma'),
                ),
                ...MoonPhase.values.map((phase) {
                  return DropdownMenuItem(
                    value: phase,
                    child: Row(
                      children: [
                        Text(phase.emoji),
                        const SizedBox(width: 8),
                        Text(phase.displayName),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMoonPhase = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Ingredientes',
                hintText: 'Digite um ingrediente por linha',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stepsController,
              decoration: const InputDecoration(
                labelText: 'Como Realizar *',
                hintText: 'Descreva os passos do ritual',
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duração (em dias)',
                hintText: 'Ex: 3',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observationsController,
              decoration: const InputDecoration(
                labelText: 'Observações',
                hintText: 'Resultados, sensações, anotações...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            MagicalButton(
              text: widget.spell == null ? 'Adicionar Feitiço' : 'Salvar',
              icon: Icons.save,
              onPressed: _saveSpell,
            ),
          ],
        ),
      ),
    );
  }

  void _saveSpell() {
    if (_formKey.currentState!.validate()) {
      final ingredients = _ingredientsController.text
          .split('\n')
          .where((i) => i.trim().isNotEmpty)
          .toList();

      final duration = int.tryParse(_durationController.text);

      final spell = widget.spell?.copyWith(
            name: _nameController.text,
            purpose: _purposeController.text,
            type: _selectedType,
            category: _selectedCategory,
            moonPhase: _selectedMoonPhase,
            ingredients: ingredients,
            steps: _stepsController.text,
            duration: duration,
            observations: _observationsController.text.isEmpty
                ? null
                : _observationsController.text,
          ) ??
          SpellModel(
            name: _nameController.text,
            purpose: _purposeController.text,
            type: _selectedType,
            category: _selectedCategory,
            moonPhase: _selectedMoonPhase,
            ingredients: ingredients,
            steps: _stepsController.text,
            duration: duration,
            observations: _observationsController.text.isEmpty
                ? null
                : _observationsController.text,
          );

      if (widget.spell == null) {
        context.read<SpellProvider>().addSpell(spell);
      } else {
        context.read<SpellProvider>().updateSpell(spell);
      }

      Navigator.pop(context);
    }
  }
}
