import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/premium_locked_preview.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/dream_model.dart';
import '../providers/dream_provider.dart';
import '../widgets/dream_interpretation_text.dart';
import 'dream_form_page.dart';

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

  /// Pediu a interpretação sem ter Premium: a tela mostra o sumário do que
  /// ela traria, em vez de gerar (e em vez de ter batido a porta na entrada).
  bool _mostrarPrevia = false;

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
          content: Text(AppLocalizations.of(context).dreamDescribeFirst),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    // Sem Premium, a interpretação não é gerada: nem uma chamada de IA sai
    // daqui. O que aparece é o sumário do que ela traria, sob véu.
    final access = context.read<AuthProvider>().checkFeatureAccess(
          AppFeature.aiPersonalizedDreamInterpretation,
        );
    if (!access.hasFullAccess) {
      setState(() => _mostrarPrevia = true);
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
          ? AppLocalizations.of(context).dreamInterpretedTitle
          : _titleController.text.trim(),
      content: notes.isEmpty
          ? _dreamController.text.trim()
          : '${_dreamController.text.trim()}\n\n${AppLocalizations.of(context).dreamNotesPrefix}: $notes',
      tags: const ['interpretado'],
      feeling: _feelingsController.text.trim().isEmpty
          ? null
          : _feelingsController.text.trim(),
      interpretation: _interpretation,
      date: _dreamDate,
    );

    // _saved evita entradas duplicadas por toques repetidos no botão
    // enquanto o salvamento/navegação acontecem.
    setState(() => _saved = true);
    final provider = context.read<DreamProvider>();
    await provider.addDream(dream);
    if (!mounted) return;
    if (provider.error != null) {
      // addDream não lança: sinaliza falha via provider.error. Reabilita o
      // botão para nova tentativa em vez de navegar para uma entrada
      // inexistente.
      setState(() => _saved = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).dreamSavedToDiary),
        backgroundColor: context.gc.success,
      ),
    );
    // Leva direto à entrada recém-criada no diário (voltar dela cai na
    // tela anterior, sem ter que procurar manualmente na lista).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DreamFormPage(dream: dream)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).diaryInterpretDream),
      ),
      // O corpo é o mesmo para todo mundo: quem não tem Premium escreve o
      // sonho, pede a interpretação e vê o SUMÁRIO do que ela traria, com o
      // texto sob véu. Barrar na porta não vendia nada — a pessoa nunca
      // chegava a saber o que estava comprando.
      body: _buildInterpretFlow(),
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
                  AppLocalizations.of(context).dreamTellYourDream,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).dreamTellHelp,
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
                    hintText: AppLocalizations.of(context).dreamTextHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _feelingsController,
                  maxLines: 2,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).dreamFeelingOptional,
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
                          ? AppLocalizations.of(context).dreamInterpreting
                          : (_interpretation == null
                              ? AppLocalizations.of(context).diaryInterpretDream
                              : AppLocalizations.of(context).dreamInterpretAgain),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_mostrarPrevia && _interpretation == null)
            MagicalCard(
              child: PremiumLockedPreview(
                titles: [
                  AppLocalizations.of(context).dreamLockedTitle1,
                  AppLocalizations.of(context).dreamLockedTitle2,
                  AppLocalizations.of(context).dreamLockedTitle3,
                  AppLocalizations.of(context).dreamLockedTitle4,
                  AppLocalizations.of(context).dreamLockedTitle5,
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
                        AppLocalizations.of(context).dreamInterpretationLabel,
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
                    AppLocalizations.of(context).dreamSaveToDiary,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).diaryTitleLabel),
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
                            '${AppLocalizations.of(context).dreamDateLabel}: '
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
                      labelText: AppLocalizations.of(context).dreamNotesOptional,
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
                      label: Text(_saved ? AppLocalizations.of(context).dreamSavedShort : AppLocalizations.of(context).commonSave),
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
