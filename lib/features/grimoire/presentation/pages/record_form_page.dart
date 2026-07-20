import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../data/models/spell_model.dart';
import '../providers/spell_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';

/// Edição simples das páginas de registro do Grimório Vivo (Meus Registros):
/// só título e texto — sem os campos de feitiço (ingredientes, lua, duração).
class RecordFormPage extends StatefulWidget {
  final SpellModel record;

  const RecordFormPage({super.key, required this.record});

  @override
  State<RecordFormPage> createState() => _RecordFormPageState();
}

class _RecordFormPageState extends State<RecordFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController =
      TextEditingController(text: widget.record.name);
  late final TextEditingController _contentController =
      TextEditingController(text: widget.record.steps);
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final updated = widget.record.copyWith(
      name: _titleController.text.trim(),
      steps: _contentController.text.trim(),
    );
    await context.read<SpellProvider>().updateSpell(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).recordUpdated),
        backgroundColor: context.gc.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(l10n.recordEditTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.recordTitleLabel,
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.recordTitleRequired
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 12,
              maxLines: null,
              decoration: InputDecoration(
                labelText: l10n.recordContentLabel,
                alignLabelWithHint: true,
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.recordContentRequired
                  : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(l10n.commonSave),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
