import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../data/models/dream_model.dart';
import '../providers/dream_provider.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../widgets/dream_interpretation_text.dart';

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
        title: ResponsiveAppBarTitle(
          widget.dream == null ? AppLocalizations.of(context).diaryNewDream : AppLocalizations.of(context).diaryEditDream,
        ),
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
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).diaryTitleLabel,
                hintText: AppLocalizations.of(context).diaryDreamTitleHint,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppLocalizations.of(context).diaryDreamDate),
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
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).diaryDreamDescLabel,
                hintText: AppLocalizations.of(context).diaryDreamDescHint,
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).diaryTagsLabel,
                hintText: AppLocalizations.of(context).diaryDreamTagsHint,
                helperText: AppLocalizations.of(context).diaryTagsHelper,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _feelingController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).diaryDreamFeelingLabel,
                hintText: AppLocalizations.of(context).diaryDreamFeelingHint,
              ),
            ),
            // Interpretação por IA já salva: somente leitura, nunca editada.
            if (widget.dream?.interpretation != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.gc.lilac.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.gc.lilac.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).diaryInterpretationHeader,
                      style: TextStyle(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DreamInterpretationText(widget.dream!.interpretation!),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            MagicalButton(
              text: widget.dream == null ? AppLocalizations.of(context).diarySaveDream : AppLocalizations.of(context).commonUpdate,
              icon: Icons.save,
              onPressed: _saveDream,
            ),
          ],
        ),
      ),
    );
  }

  void _saveDream() {
    // Verificar se pelo menos um campo foi preenchido
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).diaryFillTitleOrDesc),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final dream = widget.dream?.copyWith(
          title: _titleController.text.isEmpty
              ? AppLocalizations.of(context).commonNoTitle
              : _titleController.text,
          content: _contentController.text,
          tags: tags,
          feeling:
              _feelingController.text.isEmpty ? null : _feelingController.text,
          date: _selectedDate,
        ) ??
        DreamModel(
          title: _titleController.text.isEmpty
              ? AppLocalizations.of(context).commonNoTitle
              : _titleController.text,
          content: _contentController.text,
          tags: tags,
          feeling:
              _feelingController.text.isEmpty ? null : _feelingController.text,
          date: _selectedDate,
        );

    if (widget.dream == null) {
      context.read<DreamProvider>().addDream(dream);
    } else {
      context.read<DreamProvider>().updateDream(dream);
    }

    Navigator.pop(context);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).commonConfirmDelete),
        content: Text(AppLocalizations.of(context).diaryDeleteDreamConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: context.gc.alert,
            ),
            child: Text(AppLocalizations.of(context).commonDelete),
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
