import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/dream_model.dart';
import '../providers/dream_provider.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/theme/app_theme.dart';

class DreamFormPage extends StatefulWidget {
  final DreamModel? dream;

  const DreamFormPage({super.key, this.dream});

  @override
  State<DreamFormPage> createState() => _DreamFormPageState();
}

class _DreamFormPageState extends State<DreamFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late TextEditingController _feelingController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.dream?.title ?? '');
    _contentController =
        TextEditingController(text: widget.dream?.content ?? '');
    _tagsController =
        TextEditingController(text: widget.dream?.tags.join(', ') ?? '');
    _feelingController =
        TextEditingController(text: widget.dream?.feeling ?? '');
    _selectedDate = widget.dream?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _feelingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dream == null ? 'Novo Sonho' : 'Editar Sonho'),
        actions: widget.dream != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(context),
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex: Sonho com borboletas',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data do Sonho'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Descrição do Sonho *',
                hintText: 'Descreva seu sonho em detalhes',
              ),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Ex: pesadelo, recorrente, lúcido',
                helperText: 'Separe as tags por vírgula',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _feelingController,
              decoration: const InputDecoration(
                labelText: 'Como você se sentiu ao acordar?',
                hintText: 'Ex: Paz, medo, alegria, confusão',
              ),
            ),
            const SizedBox(height: 32),
            MagicalButton(
              text: widget.dream == null ? 'Salvar Sonho' : 'Atualizar',
              icon: Icons.save,
              onPressed: _saveDream,
            ),
          ],
        ),
      ),
    );
  }

  void _saveDream() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final dream = widget.dream?.copyWith(
            title: _titleController.text,
            content: _contentController.text,
            tags: tags,
            feeling: _feelingController.text.isEmpty
                ? null
                : _feelingController.text,
            date: _selectedDate,
          ) ??
          DreamModel(
            title: _titleController.text,
            content: _contentController.text,
            tags: tags,
            feeling: _feelingController.text.isEmpty
                ? null
                : _feelingController.text,
            date: _selectedDate,
          );

      if (widget.dream == null) {
        context.read<DreamProvider>().addDream(dream);
      } else {
        context.read<DreamProvider>().updateDream(dream);
      }

      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este sonho?'),
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
      await context.read<DreamProvider>().deleteDream(widget.dream!.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
