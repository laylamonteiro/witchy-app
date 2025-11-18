// lib/ui/diaries/dream_form_screen.dart
import 'package:flutter/material.dart';
import '../../services/repositories/dream_repository.dart';
import '../../models/dream.dart';

class DreamFormScreen extends StatefulWidget {
  final DreamRepository repository;
  final Dream? existing;

  const DreamFormScreen({
    super.key,
    required this.repository,
    this.existing,
  });

  @override
  State<DreamFormScreen> createState() => _DreamFormScreenState();
}

class _DreamFormScreenState extends State<DreamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late TextEditingController _feelingController;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _contentController = TextEditingController(text: existing?.content ?? '');
    _tagsController =
        TextEditingController(text: existing?.tags.join(', ') ?? '');
    _feelingController =
        TextEditingController(text: existing?.feelingOnWake ?? '');
    _date = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _feelingController.dispose();
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
        date: _date,
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: tags,
        feelingOnWake: _feelingController.text.trim().isEmpty
            ? null
            : _feelingController.text.trim(),
      );
    } else {
      final updated = widget.existing!.copyWith(
        date: _date,
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: tags,
        feelingOnWake: _feelingController.text.trim().isEmpty
            ? null
            : _feelingController.text.trim(),
      );
      widget.repository.update(updated);
    }

    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar sonho' : 'Novo sonho'),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Data: '
                        '${_date.day.toString().padLeft(2, '0')}/'
                        '${_date.month.toString().padLeft(2, '0')}/'
                        '${_date.year.toString()}',
                      ),
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text('Alterar'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Descreva o sonho',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Descreva o sonho';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (pesadelo, recorrente, etc.)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _feelingController,
                  decoration: const InputDecoration(
                    labelText: 'Como você se sentiu ao acordar? (opcional)',
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
