import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/affirmation_model.dart';
import '../providers/affirmation_provider.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/theme/app_theme.dart';

class AffirmationFormPage extends StatefulWidget {
  final AffirmationModel? affirmation;

  const AffirmationFormPage({super.key, this.affirmation});

  @override
  State<AffirmationFormPage> createState() => _AffirmationFormPageState();
}

class _AffirmationFormPageState extends State<AffirmationFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late AffirmationCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.affirmation?.text ?? '');
    _selectedCategory = widget.affirmation?.category ??
        AffirmationCategory.manifestation;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Não permite editar afirmações pré-carregadas
    final isPreloaded = widget.affirmation?.isPreloaded ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.affirmation == null
            ? 'Nova Afirmação'
            : 'Editar Afirmação'),
        actions: widget.affirmation != null && !isPreloaded
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
            if (isPreloaded)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Afirmações pré-carregadas não podem ser editadas ou excluídas.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            TextFormField(
              controller: _textController,
              enabled: !isPreloaded,
              decoration: const InputDecoration(
                labelText: 'Afirmação *',
                hintText: 'Ex: Sou merecedor de abundância e prosperidade',
                helperText: 'Escreva no presente e de forma positiva',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AffirmationCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria *',
              ),
              items: AffirmationCategory.values
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Text(category.icon,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(category.displayName),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: isPreloaded
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 32),
            if (!isPreloaded)
              MagicalButton(
                text: widget.affirmation == null
                    ? 'Salvar Afirmação'
                    : 'Atualizar',
                icon: Icons.auto_awesome,
                onPressed: _saveAffirmation,
              ),
          ],
        ),
      ),
    );
  }

  void _saveAffirmation() {
    if (_formKey.currentState!.validate()) {
      final affirmation = AffirmationModel(
        id: widget.affirmation?.id,
        text: _textController.text,
        category: _selectedCategory,
        isPreloaded: false,
      );

      final provider = context.read<AffirmationProvider>();
      if (widget.affirmation == null) {
        provider.addAffirmation(affirmation);
      }

      Navigator.pop(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Afirmação'),
        content:
            const Text('Tem certeza que deseja excluir esta afirmação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<AffirmationProvider>()
                  .deleteAffirmation(widget.affirmation!.id);
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
