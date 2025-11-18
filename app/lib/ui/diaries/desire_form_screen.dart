// lib/ui/diaries/desire_form_screen.dart
import 'package:flutter/material.dart';
import '../../services/repositories/desire_repository.dart';
import '../../models/desire.dart';

class DesireFormScreen extends StatefulWidget {
  final DesireRepository repository;
  final Desire? existing;

  const DesireFormScreen({
    super.key,
    required this.repository,
    this.existing,
  });

  @override
  State<DesireFormScreen> createState() => _DesireFormScreenState();
}

class _DesireFormScreenState extends State<DesireFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
  DesireStatus _status = DesireStatus.open;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _categoryController =
        TextEditingController(text: existing?.category ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _status = existing?.status ?? DesireStatus.open;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.existing == null) {
      widget.repository.create(
        title: _titleController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        status: _status,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    } else {
      final updated = widget.existing!.copyWith(
        title: _titleController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        status: _status,
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
        title: Text(isEditing ? 'Editar desejo' : 'Novo desejo'),
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
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Desejo / intenção',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Descreva o desejo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Categoria (amor, trabalho, etc.)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DesireStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: DesireStatus.open,
                      child: Text('Em aberto'),
                    ),
                    DropdownMenuItem(
                      value: DesireStatus.inProgress,
                      child: Text('Em processo'),
                    ),
                    DropdownMenuItem(
                      value: DesireStatus.realized,
                      child: Text('Realizado'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notas / observações',
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
