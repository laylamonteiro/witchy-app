import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/gratitude_model.dart';
import '../providers/gratitude_provider.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/theme/app_theme.dart';

class GratitudeFormPage extends StatefulWidget {
  final GratitudeModel? gratitude;

  const GratitudeFormPage({super.key, this.gratitude});

  @override
  State<GratitudeFormPage> createState() => _GratitudeFormPageState();
}

class _GratitudeFormPageState extends State<GratitudeFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.gratitude?.title ?? '');
    _contentController =
        TextEditingController(text: widget.gratitude?.content ?? '');
    _tagsController = TextEditingController(
        text: widget.gratitude?.tags.join(', ') ?? '');
    _selectedDate = widget.gratitude?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.gratitude == null ? 'Nova Gratidão' : 'Editar Gratidão'),
        actions: widget.gratitude != null
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
                hintText: 'Ex: Gratidão pelo dia de hoje',
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
              title: const Text('Data'),
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
                labelText: 'Pelo que você é grato(a) hoje? *',
                hintText: 'Descreva suas gratidões...',
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
                hintText: 'Ex: família, saúde, trabalho',
                helperText: 'Separe as tags por vírgula',
              ),
            ),
            const SizedBox(height: 32),
            MagicalButton(
              text: widget.gratitude == null ? 'Salvar Gratidão' : 'Atualizar',
              icon: Icons.favorite,
              onPressed: _saveGratitude,
            ),
          ],
        ),
      ),
    );
  }

  void _saveGratitude() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final gratitude = GratitudeModel(
        id: widget.gratitude?.id,
        title: _titleController.text,
        content: _contentController.text,
        tags: tags,
        date: _selectedDate,
      );

      final provider = context.read<GratitudeProvider>();
      if (widget.gratitude == null) {
        provider.addGratitude(gratitude);
      } else {
        provider.updateGratitude(gratitude);
      }

      Navigator.pop(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Gratidão'),
        content: const Text('Tem certeza que deseja excluir esta gratidão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<GratitudeProvider>()
                  .deleteGratitude(widget.gratitude!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close form
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.alert),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
