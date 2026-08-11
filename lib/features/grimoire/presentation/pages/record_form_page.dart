import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/presentation/providers/free_writing_provider.dart';

/// Edição simples de uma entrada do acervo (Meus Registros): só título e
/// texto — a origem (source) é preservada pelo copyWith do modelo.
class RecordFormPage extends StatefulWidget {
  final FreeWritingModel entry;

  const RecordFormPage({super.key, required this.entry});

  @override
  State<RecordFormPage> createState() => _RecordFormPageState();
}

class _RecordFormPageState extends State<RecordFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController =
      TextEditingController(text: widget.entry.title ?? '');
  late final TextEditingController _contentController =
      TextEditingController(text: widget.entry.content);
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

    final updated = widget.entry.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );
    await context.read<FreeWritingProvider>().save(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).recordUpdated),
        backgroundColor: context.gc.success,
      ),
    );
    // Devolve a versão editada para o detalhe atualizar sem recarregar.
    Navigator.pop(context, updated);
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
