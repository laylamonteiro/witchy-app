import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/desire_model.dart';
import '../providers/desire_provider.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/theme/app_theme.dart';

class DesireFormPage extends StatefulWidget {
  final DesireModel? desire;

  const DesireFormPage({super.key, this.desire});

  @override
  State<DesireFormPage> createState() => _DesireFormPageState();
}

class _DesireFormPageState extends State<DesireFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _evolutionController;
  late DesireStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.desire?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.desire?.description ?? '');
    _evolutionController =
        TextEditingController(text: widget.desire?.evolution ?? '');
    _selectedStatus = widget.desire?.status ?? DesireStatus.open;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _evolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.desire == null ? 'Novo Desejo' : 'Editar Desejo'),
        actions: widget.desire != null
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
                hintText: 'Ex: Viajar para o exterior',
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
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição *',
                hintText: 'Descreva seu desejo em detalhes',
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DesireStatus>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
              ),
              items: DesireStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Text(status.emoji),
                      const SizedBox(width: 8),
                      Text(status.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _evolutionController,
              decoration: const InputDecoration(
                labelText: 'O que se movimentou?',
                hintText: 'Registre a evolução do seu desejo',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            MagicalButton(
              text: widget.desire == null ? 'Salvar Desejo' : 'Atualizar',
              icon: Icons.save,
              onPressed: _saveDesire,
            ),
          ],
        ),
      ),
    );
  }

  void _saveDesire() {
    if (_formKey.currentState!.validate()) {
      final desire = widget.desire?.copyWith(
            title: _titleController.text,
            description: _descriptionController.text,
            status: _selectedStatus,
            evolution: _evolutionController.text.isEmpty
                ? null
                : _evolutionController.text,
          ) ??
          DesireModel(
            title: _titleController.text,
            description: _descriptionController.text,
            status: _selectedStatus,
            evolution: _evolutionController.text.isEmpty
                ? null
                : _evolutionController.text,
          );

      if (widget.desire == null) {
        context.read<DesireProvider>().addDesire(desire);
      } else {
        context.read<DesireProvider>().updateDesire(desire);
      }

      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este desejo?'),
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
      await context.read<DesireProvider>().deleteDesire(widget.desire!.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
