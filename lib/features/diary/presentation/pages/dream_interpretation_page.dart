import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/models/dream_model.dart';
import '../providers/dream_provider.dart';
import '../widgets/dream_interpretation_text.dart';

/// Interpretação personalizada de sonhos por IA (exclusiva Premium).
///
/// Fluxo: descrever o sonho -> IA interpreta -> revisar título/data/notas ->
/// salvar sonho + interpretação como UMA entrada no Diário de Sonhos.
class DreamInterpretationPage extends StatefulWidget {
  const DreamInterpretationPage({super.key});

  @override
  State<DreamInterpretationPage> createState() =>
      _DreamInterpretationPageState();
}

class _DreamInterpretationPageState extends State<DreamInterpretationPage> {
  final _dreamController = TextEditingController();
  final _feelingsController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String? _interpretation;
  DateTime _dreamDate = DateTime.now();
  bool _isInterpreting = false;
  bool _saved = false;

  @override
  void dispose() {
    _dreamController.dispose();
    _feelingsController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _interpret() async {
    final text = _dreamController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dreamDescribeFirst),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    setState(() {
      _isInterpreting = true;
      _interpretation = null;
      _saved = false;
    });

    try {
      final result = await AIService.instance.interpretDream(
        dreamDescription: text,
        feelings: _feelingsController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _interpretation = result;
        if (_titleController.text.trim().isEmpty) {
          _titleController.text = _suggestedTitle(text);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'.replaceAll('Exception: ', '')),
          backgroundColor: context.gc.alert,
        ),
      );
    } finally {
      if (mounted) setState(() => _isInterpreting = false);
    }
  }

  String _suggestedTitle(String dreamText) {
    final firstWords = dreamText.split(RegExp(r'\s+')).take(6).join(' ');
    return firstWords.length >= dreamText.trim().length
        ? firstWords
        : '$firstWords…';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dreamDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _dreamDate = picked);
    }
  }

  Future<void> _save() async {
    if (_interpretation == null || _saved) return;

    final notes = _notesController.text.trim();
    final dream = DreamModel(
      title: _titleController.text.trim().isEmpty
          ? AppLocalizations.of(context)!.dreamInterpretedTitle
          : _titleController.text.trim(),
      content: notes.isEmpty
          ? _dreamController.text.trim()
          : '${_dreamController.text.trim()}\n\n${AppLocalizations.of(context)!.dreamNotesPrefix}: $notes',
      tags: const ['interpretado'],
      feeling: _feelingsController.text.trim().isEmpty
          ? null
          : _feelingsController.text.trim(),
      interpretation: _interpretation,
      date: _dreamDate,
    );

    await context.read<DreamProvider>().addDream(dream);
    if (!mounted) return;
    // _saved evita entradas duplicadas por toques repetidos no botão.
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.dreamSavedToDiary),
        backgroundColor: context.gc.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final access = authProvider.checkFeatureAccess(
      AppFeature.aiPersonalizedDreamInterpretation,
    );

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context)!.diaryInterpretDream),
      ),
      body: !access.hasFullAccess
          ? _buildPremiumInvite(access.message)
          : _buildInterpretFlow(),
    );
  }

  Widget _buildPremiumInvite(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔮', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.dreamInterpretationTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: context.gc.lilac,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message ??
                  AppLocalizations.of(context)!.dreamPremiumOnly,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.gc.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const PremiumUpgradeSheet(),
              ),
              icon: const Icon(Icons.star, size: 18),
              label: Text(AppLocalizations.of(context)!.premiumBePremium),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.gc.lilac,
                foregroundColor: context.gc.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterpretFlow() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.dreamTellYourDream,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.dreamTellHelp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _dreamController,
                  maxLines: 6,
                  minLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.dreamTextHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _feelingsController,
                  maxLines: 2,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.dreamFeelingOptional,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isInterpreting ? null : _interpret,
                    icon: _isInterpreting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.gc.onPrimary,
                            ),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(
                      _isInterpreting
                          ? AppLocalizations.of(context)!.dreamInterpreting
                          : (_interpretation == null
                              ? AppLocalizations.of(context)!.diaryInterpretDream
                              : AppLocalizations.of(context)!.dreamInterpretAgain),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_interpretation != null) ...[
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('🌙 ',
                          style: TextStyle(color: context.gc.starYellow)),
                      Text(
                        AppLocalizations.of(context)!.dreamInterpretationLabel,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: context.gc.lilac,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DreamInterpretationText(_interpretation!),
                ],
              ),
            ),
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.dreamSaveToDiary,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.diaryTitleLabel),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: context.gc.lilac),
                          const SizedBox(width: 8),
                          Text(
                            '${AppLocalizations.of(context)!.dreamDateLabel}: '
                            '${_dreamDate.day.toString().padLeft(2, '0')}/'
                            '${_dreamDate.month.toString().padLeft(2, '0')}/'
                            '${_dreamDate.year}',
                            style: TextStyle(color: context.gc.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.dreamNotesOptional,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saved ? null : _save,
                      icon: Icon(
                        _saved ? Icons.check : Icons.bookmark_add_outlined,
                        size: 18,
                      ),
                      label: Text(_saved ? AppLocalizations.of(context)!.dreamSavedShort : AppLocalizations.of(context)!.commonSave),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
