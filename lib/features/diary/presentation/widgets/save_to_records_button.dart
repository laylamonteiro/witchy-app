import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../data/models/free_writing_model.dart';
import '../../data/repositories/free_writing_repository.dart';

/// Botão "Salvar nos Registros": leituras (tarot, runas, pêndulo, oráculo)
/// só entram no acervo quando a Bruxa QUER — salvar tudo automaticamente
/// poluía o Meus Registros. Salva uma vez e vira confirmação; use uma `key`
/// por leitura (ex.: ValueKey do id) para o botão renascer a cada tiragem.
class SaveToRecordsButton extends StatefulWidget {
  /// Monta a entrada na hora do toque (título/conteúdo/origem prontos).
  final FreeWritingModel Function() buildEntry;

  const SaveToRecordsButton({super.key, required this.buildEntry});

  @override
  State<SaveToRecordsButton> createState() => _SaveToRecordsButtonState();
}

class _SaveToRecordsButtonState extends State<SaveToRecordsButton> {
  bool _saved = false;
  bool _saving = false;

  Future<void> _save() async {
    if (_saved || _saving) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final successColor = context.gc.success;

    await FreeWritingRepository().insert(widget.buildEntry());

    if (!mounted) return;
    setState(() {
      _saved = true;
      _saving = false;
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.palmSavedToRecords),
        backgroundColor: successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OutlinedButton.icon(
      onPressed: _saved || _saving ? null : _save,
      icon: Icon(_saved ? Icons.check : Icons.bookmark_add_outlined, size: 18),
      label: Text(_saved ? l10n.palmSavedShort : l10n.saveToRecords),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.gc.lilac,
        side: BorderSide(color: context.gc.lilac),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
