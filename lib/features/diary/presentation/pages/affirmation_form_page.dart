import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../data/models/affirmation_model.dart';
import '../providers/affirmation_provider.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../auth/data/models/user_model.dart';

class AffirmationFormPage extends StatefulWidget {
  final AffirmationModel? affirmation;

  const AffirmationFormPage({super.key, this.affirmation});

  @override
  State<AffirmationFormPage> createState() => _AffirmationFormPageState();
}

class _AffirmationFormPageState extends State<AffirmationFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late TextEditingController _contextController;
  late AffirmationCategory _selectedCategory;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.affirmation?.text ?? '');
    _contextController = TextEditingController();
    _selectedCategory =
        widget.affirmation?.category ?? AffirmationCategory.manifestation;
  }

  @override
  void dispose() {
    _textController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Não permite editar afirmações pré-carregadas
    final isPreloaded = widget.affirmation?.isPreloaded ?? false;

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(
            widget.affirmation == null ? AppLocalizations.of(context).diaryNewAffirmation : AppLocalizations.of(context).diaryEditAffirmation),
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
                  color: context.gc.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.gc.info),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: context.gc.info),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).diaryPreloadedAffirmationNote,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            // Seção do Conselheiro Místico
            if (!isPreloaded && widget.affirmation == null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.gc.lilac.withOpacity(0.1),
                      context.gc.lilac.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.gc.lilac.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('🧙🏻‍♂️', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).profileMysticAdvisor,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.gc.lilac,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).diaryAdvisorAffirmationPitch,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.gc.softWhite.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contextController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).diaryContextOptional,
                        hintText: AppLocalizations.of(context).diaryContextHint,
                        helperText:
                            AppLocalizations.of(context).diaryContextHelper,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateAffirmation,
                        icon: _isGenerating
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.gc.darkBackground,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_isGenerating
                            ? AppLocalizations.of(context).diaryConsulting
                            : AppLocalizations.of(context).diaryGenerateAffirmation),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.gc.lilac,
                          foregroundColor: context.gc.darkBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).diaryWriteOwnAffirmation,
                style: TextStyle(
                  fontSize: 12,
                  color: context.gc.softWhite.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
            ],
            TextFormField(
              controller: _textController,
              enabled: !isPreloaded,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).diaryAffirmationLabel,
                hintText: AppLocalizations.of(context).diaryAffirmationHint,
                helperText: AppLocalizations.of(context).diaryAffirmationHelper,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AffirmationCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).diaryCategoryLabel,
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
                    ? AppLocalizations.of(context).diarySaveAffirmation
                    : AppLocalizations.of(context).commonUpdate,
                icon: Icons.auto_awesome,
                onPressed: _saveAffirmation,
              ),
            // Exibir usos restantes para usuários free (apenas ao criar nova)
            if (!isPreloaded && widget.affirmation == null)
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (authProvider.isPremium) return const SizedBox.shrink();
                  final remaining =
                      authProvider.currentUser.remainingAffirmations;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      AppLocalizations.of(context).diaryAffirmationsRemaining('$remaining/${UserModel.freeAffirmationsLimit}'),
                      style: TextStyle(
                        color: remaining > 0
                            ? context.gc.softWhite.withOpacity(0.6)
                            : context.gc.alert,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAffirmation() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final affirmationText = await AIService.instance.generateAffirmation(
        category: _selectedCategory.displayName,
        userContext:
            _contextController.text.isEmpty ? null : _contextController.text,
      );

      if (mounted) {
        setState(() {
          _textController.text = affirmationText;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).diaryAffirmationCreated),
            backgroundColor: context.gc.lilac,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).diaryAffirmationError}: $e'),
            backgroundColor: context.gc.alert,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _saveAffirmation() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).diaryTypeOrGenerate),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar limite diário para novas afirmações (usuários free)
    final authProvider = context.read<AuthProvider>();
    if (widget.affirmation == null &&
        !authProvider.currentUser.canUseAffirmations) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).diaryAffirmationLimit),
          backgroundColor: context.gc.alert,
          duration: Duration(seconds: 4),
        ),
      );
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PremiumUpgradeSheet(),
      );
      return;
    }

    final affirmation = AffirmationModel(
      id: widget.affirmation?.id,
      text: _textController.text,
      category: _selectedCategory,
      isPreloaded: false,
    );

    final provider = context.read<AffirmationProvider>();
    if (widget.affirmation == null) {
      provider.addAffirmation(affirmation);
      // Incrementar uso de afirmações
      await authProvider.incrementAffirmations();
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).diaryDeleteAffirmationTitle),
        content: Text(AppLocalizations.of(context).diaryDeleteAffirmationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<AffirmationProvider>()
                  .deleteAffirmation(widget.affirmation!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close form
            },
            style: TextButton.styleFrom(foregroundColor: context.gc.alert),
            child: Text(AppLocalizations.of(context).commonDelete),
          ),
        ],
      ),
    );
  }
}
