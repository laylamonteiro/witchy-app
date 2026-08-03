import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/models/user_entry_model.dart';
import '../providers/encyclopedia_provider.dart';
import 'color_detail_page.dart';
import 'crystal_detail_page.dart';
import 'herb_detail_page.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';

/// Adicionar entrada pessoal à enciclopédia (Premium): a Bruxa fotografa a
/// erva/pedra/cor, a IA identifica, ela confirma ou corrige o nome, a IA
/// monta a página no formato da categoria e tudo é salvo com a foto dela.
///
/// Privacidade: a foto é enviada à IA em memória apenas para identificação;
/// só a cópia local comprimida é persistida (no aparelho).
class AddEntryPage extends StatefulWidget {
  final UserEntryCategory category;

  const AddEntryPage({super.key, required this.category});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  static const int _maxUploadBytes = 4 * 1024 * 1024; // limite da API (base64)
  static const int _dailyLimit = 5;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  List<int>? _jpegBytes;
  String? _tempImagePath;
  bool _identifying = false;
  bool _identified = false;
  String? _confidence;
  bool _generating = false;
  Map<String, dynamic>? _generated;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAccess());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _ensureAccess() async {
    final access = context
        .read<AuthProvider>()
        .checkFeatureAccess(AppFeature.encyclopediaPersonalEntries);
    if (!access.hasFullAccess && mounted) {
      await showPaywallThenPop(context);
    }
  }

  Future<void> _pick(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);

    final provider = context.read<EncyclopediaProvider>();
    final usedToday = await provider.userEntriesCreatedToday();
    if (usedToday >= _dailyLimit) {
      setState(() => _error = l10n.encyAddDailyLimit(_dailyLimit));
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked == null || !mounted) return;

    // Compressão corrige EXIF e remove metadados (mesmo pipeline da
    // quiromancia).
    final compressed = await FlutterImageCompress.compressWithFile(
      picked.path,
      minWidth: 1024,
      minHeight: 1024,
      quality: 82,
      format: CompressFormat.jpeg,
    );
    if (compressed == null || !mounted) return;
    if (compressed.length > _maxUploadBytes) {
      setState(() => _error = l10n.encyAddImageTooLarge);
      return;
    }

    setState(() {
      _jpegBytes = compressed;
      _tempImagePath = picked.path;
      _identified = false;
      _generated = null;
      _confidence = null;
      _nameController.clear();
      _identifying = true;
    });

    try {
      final result = await AIService.instance.identifyEncyclopediaItem(
        jpegBytes: compressed,
        categoryKey: widget.category.key,
      );
      if (!mounted) return;
      final identified = result['identified'] == true;
      setState(() {
        _identifying = false;
        _identified = identified;
        _confidence = result['confidence']?.toString();
        _nameController.text = identified ? '${result['name'] ?? ''}' : '';
      });
      // Identificou de verdade: se a identificação na natureza é o rito de
      // hoje, está cumprida.
      if (identified) {
        unawaited(context
            .read<DailyCheckinProvider>()
            .completeRite(DailyRites.natureIdentify));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _identifying = false;
        _identified = false;
      });
    }
  }

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.encyAddNameRequired);
      return;
    }
    setState(() {
      _error = null;
      _generating = true;
      _generated = null;
    });
    try {
      final data = await AIService.instance.generateEncyclopediaEntry(
        name: name,
        categoryKey: widget.category.key,
        // O verbete considera a foto real: a descrição fala do exemplar
        // fotografado, não de uma versão genérica da espécie.
        jpegBytes: _jpegBytes,
      );
      if (!mounted) return;
      setState(() {
        _generating = false;
        _generated = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generating = false;
        _error = l10n.encyAddGenerateError;
      });
    }
  }

  Future<void> _save() async {
    final data = _generated;
    if (data == null || _saving) return;
    setState(() => _saving = true);

    try {
      // Persistir a foto no diretório do app (padrão da foto de perfil).
      String? savedPath;
      final bytes = _jpegBytes;
      if (bytes != null) {
        final dir = await getApplicationDocumentsDirectory();
        final file =
            File('${dir.path}/encyclopedia_${const Uuid().v4()}.jpg');
        await file.writeAsBytes(bytes);
        savedPath = file.path;
      }

      if (!mounted) return;
      // O verbete gerado traz o nome CANÔNICO (grafia correta, sem nome
      // científico embutido): salva ele, não o texto digitado — corrige
      // erros de digitação e nomes extensos de uma vez.
      final canonicalName = '${data['name'] ?? ''}'.trim();
      final entry = await context.read<EncyclopediaProvider>().addUserEntry(
            category: widget.category,
            name: canonicalName.isNotEmpty
                ? canonicalName
                : _nameController.text.trim(),
            imagePath: savedPath,
            data: data,
          );

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.encyAddSaved)),
      );
      // Direto para a página recém-criada (voltar dela cai na lista);
      // a lixeira do AppBar já funciona porque a entrada vai junto.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => switch (widget.category) {
            UserEntryCategory.herb => HerbDetailPage(
                herb: entry.toHerbModel(),
                userEntry: entry,
              ),
            UserEntryCategory.crystal => CrystalDetailPage(
                crystal: entry.toCrystalModel(),
                userEntry: entry,
              ),
            UserEntryCategory.color => ColorDetailPage(
                colorModel: entry.toColorModel(),
                userEntry: entry,
              ),
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = AppLocalizations.of(context).encyAddGenerateError;
      });
    }
  }

  String _categoryLabel(AppLocalizations l10n) {
    switch (widget.category) {
      case UserEntryCategory.crystal:
        return l10n.encyTabCrystals;
      case UserEntryCategory.herb:
        return l10n.encyTabHerbs;
      case UserEntryCategory.color:
        return l10n.encyTabColors;
    }
  }

  /// Intro menciona apenas o elemento da categoria aberta ("Fotografe sua
  /// pedra..." em Cristais), não a lista genérica erva/pedra/cor.
  String _intro(AppLocalizations l10n) {
    switch (widget.category) {
      case UserEntryCategory.crystal:
        return l10n.encyAddIntroCrystal;
      case UserEntryCategory.herb:
        return l10n.encyAddIntroHerb;
      case UserEntryCategory.color:
        return l10n.encyAddIntroColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(
          l10n.encyAddTitle(_categoryLabel(l10n)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _intro(l10n),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (_tempImagePath != null) ...[
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_tempImagePath!),
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _identifying
                              ? null
                              : () => _pick(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: Text(l10n.encyAddTakePhoto),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _identifying
                              ? null
                              : () => _pick(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(l10n.encyAddFromGallery),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_identifying)
              MagicalCard(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.encyAddIdentifying)),
                  ],
                ),
              ),
            if (_jpegBytes != null && !_identifying) ...[
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _identified
                          ? l10n.encyAddIdentifiedAs
                          : l10n.encyAddNotIdentified,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_identified && _confidence != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.encyAddConfidence(_confidence!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.gc.textSecondary,
                            ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.encyAddNameLabel,
                        hintText: l10n.encyAddNameHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    MagicalButton(
                      text: _generating
                          ? l10n.encyAddGenerating
                          : l10n.encyAddGenerateCta,
                      icon: Icons.auto_awesome,
                      onPressed: _generating ? () {} : _generate,
                    ),
                  ],
                ),
              ),
            ],
            if (_generated != null) _buildPreview(context, l10n),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: context.gc.alert),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, AppLocalizations l10n) {
    final data = _generated!;

    List<Widget> chips(String key, Color color) {
      final items = data[key];
      if (items is! List || items.isEmpty) return const [];
      return [
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .map((item) => Chip(
                    label: Text('$item',
                        style: Theme.of(context).textTheme.bodySmall),
                    backgroundColor: color.withValues(alpha: 0.15),
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
      ];
    }

    final description =
        '${data['description'] ?? data['meaning'] ?? ''}'.trim();

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.encyAddPreviewTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            _nameController.text.trim(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: context.gc.lilac,
                ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
          ],
          ...chips('intentions', context.gc.lilac),
          ...chips('magicalProperties', context.gc.lilac),
          ...chips('usageTips', context.gc.mint),
          ...chips('ritualUses', context.gc.mint),
          ...chips('safetyWarnings', context.gc.alert),
          const SizedBox(height: 16),
          MagicalButton(
            text: _saving ? l10n.encyAddSaving : l10n.encyAddSaveCta,
            icon: Icons.bookmark_add_outlined,
            onPressed: _saving ? () {} : _save,
          ),
        ],
      ),
    );
  }
}
