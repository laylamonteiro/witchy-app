import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../data/models/desire_model.dart';
import '../providers/desire_provider.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';

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
        title: ResponsiveAppBarTitle(
          widget.desire == null ? AppLocalizations.of(context)!.diaryNewDesire : AppLocalizations.of(context)!.diaryEditDesire,
        ),
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
                labelText: AppLocalizations.of(context)!.diaryTitleLabel,
                hintText: AppLocalizations.of(context)!.diaryDesireTitleHint,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: AppLocalizations.of(context)!.diaryDescLabel,
                hintText: AppLocalizations.of(context)!.diaryDesireDescHint,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DesireStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: AppLocalizations.of(context)!.diaryStatusLabel,
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
                labelText: AppLocalizations.of(context)!.diaryDesireProgressLabel,
                hintText: AppLocalizations.of(context)!.diaryDesireProgressHint,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            MagicalButton(
              text: widget.desire == null ? AppLocalizations.of(context)!.diarySaveDesire : AppLocalizations.of(context)!.commonUpdate,
              icon: Icons.save,
              onPressed: _saveDesire,
            ),
          ],
        ),
      ),
    );
  }

  void _saveDesire() {
    // Verificar se pelo menos um campo foi preenchido
    if (_titleController.text.isEmpty && _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppLocalizations.of(context)!.diaryFillTitleOrDesc),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final desire = widget.desire?.copyWith(
          title: _titleController.text.isEmpty
              ? AppLocalizations.of(context)!.commonNoTitle
              : _titleController.text,
          description: _descriptionController.text,
          status: _selectedStatus,
          evolution: _evolutionController.text.isEmpty
              ? null
              : _evolutionController.text,
        ) ??
        DesireModel(
          title: _titleController.text.isEmpty
              ? AppLocalizations.of(context)!.commonNoTitle
              : _titleController.text,
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.commonConfirmDelete),
        content: Text(AppLocalizations.of(context)!.diaryDeleteDesireConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: context.gc.alert,
            ),
            child: Text(AppLocalizations.of(context)!.commonDelete),
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
