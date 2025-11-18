// lib/ui/grimorio/spell_form_screen.dart
import 'package:flutter/material.dart';
import '../../models/spell.dart';
import '../../services/repositories/spell_repository.dart';

class SpellFormScreen extends StatefulWidget {
  final SpellRepository repository;
  final Spell? existing;

  const SpellFormScreen({
    super.key,
    required this.repository,
    this.existing,
  });

  @override
  State<SpellFormScreen> createState() => _SpellFormScreenState();
}

class _SpellFormScreenState extends State<SpellFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _tagsController;
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;
  late TextEditingController _notesController;
  SpellType _type = SpellType.attraction;
  String? _moonPhase;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _tagsController =
        TextEditingController(text: existing?.tags.join(', ') ?? '');
    _ingredientsController =
        TextEditingController(text: existing?.ingredients ?? '');
    _stepsController = TextEditingController(text: existing?.steps ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _type = existing?.type ?? SpellType.attraction;
    _moonPhase = existing?.moonPhaseRecommendation;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (widget.existing == null) {
      widget.repository.create(
        name: _nameController.text.trim(),
        tags: tags,
        type: _type,
        moonPhaseRecommendation: _moonPhase,
        ingredients: _ingredientsController.text.trim(),
        steps: _stepsController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    } else {
      final updated = widget.existing!.copyWith(
        name: _nameController.text.trim(),
        tags: tags,
        type: _type,
        moonPhaseRecommendation: _moonPhase,
        ingredients: _ingredientsController.text.trim(),
        steps: _stepsController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      widget.repository.update(updated);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar feitiço' : 'Novo feitiço'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do feitiço',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe um nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (separadas por vírgula)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<SpellType>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Tipo de feitiço'),
                  items: const [
                    DropdownMenuItem(
                      value: SpellType.attraction,
                      child: Text('Atração / Crescimento'),
                    ),
                    DropdownMenuItem(
                      value: SpellType.banishment,
                      child: Text('Banimento / Corte'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _type = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _moonPhase,
                  decoration:
                      const InputDecoration(labelText: 'Fase da lua recomendada'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Lua Nova', child: Text('Lua Nova')),
                    DropdownMenuItem(
                        value: 'Lua Crescente', child: Text('Lua Crescente')),
                    DropdownMenuItem(
                        value: 'Lua Cheia', child: Text('Lua Cheia')),
                    DropdownMenuItem(
                        value: 'Lua Minguante', child: Text('Lua Minguante')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _moonPhase = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ingredientsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ingredientes',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stepsController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Passo a passo',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas / resultados (opcional)',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
