import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/tratamento_do_contexto.dart';
import '../../data/models/gratitude_model.dart';
import '../providers/gratitude_provider.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';

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
    _tagsController =
        TextEditingController(text: widget.gratitude?.tags.join(', ') ?? '');
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
        title: ResponsiveAppBarTitle(
            widget.gratitude == null ? AppLocalizations.of(context).diaryNewGratitude : AppLocalizations.of(context).diaryEditGratitude),
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
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).diaryTitleLabel,
                hintText: AppLocalizations.of(context).diaryGratitudeTitleHint,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppLocalizations.of(context).commonDate),
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
                  // Só o calendário: o modo de digitação do seletor pede o
                  // teclado `datetime`, que em vários Androids vem sem a
                  // barra — e a data digitada nunca fecha o formato.
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
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
                labelText: context.porTratamento(
                  feminine:
                      AppLocalizations.of(context).diaryGratitudeLabelFeminine,
                  masculine:
                      AppLocalizations.of(context).diaryGratitudeLabelMasculine,
                  neutral:
                      AppLocalizations.of(context).diaryGratitudeLabelNeutral,
                ),
                hintText: AppLocalizations.of(context).diaryGratitudeHint,
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).diaryTagsLabel,
                hintText: AppLocalizations.of(context).diaryGratitudeTagsHint,
                helperText: AppLocalizations.of(context).diaryTagsHelper,
              ),
            ),
            const SizedBox(height: 32),
            MagicalButton(
              text: widget.gratitude == null ? AppLocalizations.of(context).diarySaveGratitude : AppLocalizations.of(context).commonUpdate,
              icon: Icons.favorite,
              onPressed: _saveGratitude,
            ),
          ],
        ),
      ),
    );
  }

  void _saveGratitude() {
    // Verificar se pelo menos um campo foi preenchido
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).diaryFillTitleOrContent),
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

    final gratitude = GratitudeModel(
      id: widget.gratitude?.id,
      title:
          _titleController.text.isEmpty ? AppLocalizations.of(context).commonNoTitle : _titleController.text,
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).diaryDeleteGratitudeTitle),
        content: Text(AppLocalizations.of(context).diaryDeleteGratitudeConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: context.gc.alert),
            child: Text(AppLocalizations.of(context).commonDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context
          .read<GratitudeProvider>()
          .deleteGratitude(widget.gratitude!.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
