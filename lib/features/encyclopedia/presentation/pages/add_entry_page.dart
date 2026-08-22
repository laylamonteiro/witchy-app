import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../../../core/utils/image_compression.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/premium_locked_preview.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
/// Privacidade: a foto é enviada à IA em memória apenas para identificação.
/// A cópia comprimida é persistida no aparelho (celular) ou no armazenamento
/// privado da conta (web, onde não há filesystem) — ver política de
/// privacidade, seção "Onde seus dados vivem".
class AddEntryPage extends StatefulWidget {
  final UserEntryCategory category;

  const AddEntryPage({super.key, required this.category});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  static const int _maxUploadBytes = 4 * 1024 * 1024; // limite da API (base64)

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  Uint8List? _jpegBytes;
  bool _identifying = false;
  bool _identified = false;
  String? _confidence;

  /// Candidatos devolvidos pela identificação, do mais provável ao menos.
  /// Com mais de um, a tela pergunta em vez de escolher por conta própria.
  List<Map<String, dynamic>> _candidates = const [];

  /// Índice do candidato escolhido; null enquanto a lista ainda está aberta
  /// e -1 depois de "nenhuma dessas", que libera o campo manual.
  int? _chosen;
  bool _generating = false;
  Map<String, dynamic>? _generated;
  bool _saving = false;
  String? _error;

  /// Pediu a identificação sem ter Premium: a tela mostra os campos que o
  /// verbete traria, em vez de bater a porta na entrada.
  bool _mostrarPrevia = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);

    // Sem Premium a identificação não acontece: a foto não é escolhida, não
    // sai do aparelho e nenhuma chamada de visão é feita. O que aparece é a
    // lista dos campos que o verbete teria, com o texto sob véu.
    final access = context
        .read<AuthProvider>()
        .checkFeatureAccess(AppFeature.encyclopediaPersonalEntries);
    if (!access.hasFullAccess) {
      setState(() => _mostrarPrevia = true);
      return;
    }

    final provider = context.read<EncyclopediaProvider>();
    final usedToday = await provider.userEntriesCreatedToday();
    if (usedToday >= UserModel.dailyNatureIdentifyLimit) {
      setState(() => _error =
          l10n.encyAddDailyLimit(UserModel.dailyNatureIdentifyLimit));
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
    final compressed = await compressPickedImage(picked);
    if (compressed == null || !mounted) return;
    if (compressed.length > _maxUploadBytes) {
      setState(() => _error = l10n.encyAddImageTooLarge);
      return;
    }

    setState(() {
      _jpegBytes = compressed;
      _identified = false;
      _generated = null;
      _confidence = null;
      _candidates = const [];
      _chosen = null;
      _nameController.clear();
      _identifying = true;
      _error = null;
    });

    try {
      final result = await AIService.instance.identifyEncyclopediaItem(
        jpegBytes: compressed,
        categoryKey: widget.category.key,
      );
      if (!mounted) return;
      final raw = result['candidates'];
      final candidates = raw is List
          ? raw.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : <Map<String, dynamic>>[];
      final identified = result['identified'] == true && candidates.isNotEmpty;
      setState(() {
        _identifying = false;
        _identified = identified;
        _candidates = candidates;
        // Candidato único já vem escolhido; havendo mais de um, quem tirou a
        // foto decide — o modelo não tem como saber qual espécie é.
        _chosen = candidates.length == 1 ? 0 : null;
        _confidence =
            candidates.length == 1 ? '${candidates.first['confidence']}' : null;
        _nameController.text =
            candidates.length == 1 ? _candidateName(candidates.first) : '';
      });
      // Identificou de verdade: se a identificação na natureza é o rito de
      // hoje, está cumprida.
      if (identified) {
        unawaited(context
            .read<DailyCheckinProvider>()
            .completeRite(DailyRites.natureIdentify));
      }
    } catch (e) {
      debugPrint('Guia da Natureza: falha ao identificar: $e');
      if (!mounted) return;
      setState(() {
        _identifying = false;
        _identified = false;
        // Teto de requisições do provedor (compartilhado pelo app inteiro):
        // sem isto, o 429 viraria um "não identificado" enganoso.
        //
        // E TODA falha aparece, não só a de limite. Engolir o resto deixava
        // a pessoa achando que a foto dela é que estava ruim — e, quando
        // reclamasse, não haveria o que olhar. Este era o fluxo que ficou
        // parecido com a Quiromancia na aparência e diferente no
        // comportamento.
        _error = e is AiRateLimitException
            ? AppLocalizations.of(context).aiVisionRateLimit
            : AppLocalizations.of(context).errorsGeneric;
      });
    }
  }

  /// Título do candidato — e, por consequência, nome do verbete.
  ///
  /// O nome POPULAR lidera: é o que a praticante reconhece na hora de escolher
  /// e o que ela vai procurar depois na enciclopédia ("Morango", não "Fragaria
  /// x ananassa"). O binômio latino continua visível como apoio (subtítulo no
  /// card, campo próprio no verbete), preservando a precisão entre espécies
  /// parecidas. Sem nome popular — comum em pedras sem espécie mineral
  /// declarada — o científico assume o título.
  String _candidateName(Map<String, dynamic> candidate) {
    final popular = '${candidate['name'] ?? ''}'.trim();
    if (popular.isNotEmpty) return popular;
    return '${candidate['scientific'] ?? ''}'.trim();
  }

  /// [index] negativo é "nenhuma dessas": abre o campo em branco.
  void _chooseCandidate(int index) {
    setState(() {
      _chosen = index;
      _error = null;
      if (index < 0) {
        _identified = false;
        _confidence = null;
        _nameController.clear();
      } else {
        final candidate = _candidates[index];
        _identified = true;
        _confidence = '${candidate['confidence']}';
        _nameController.text = _candidateName(candidate);
      }
    });
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
      // Persistir a foto. Na web não há filesystem: vai para o Supabase
      // Storage e o banco guarda a referência (`supabase://...`).
      String? savedPath;
      final bytes = _jpegBytes;
      if (bytes != null) {
        if (kIsWeb) {
          savedPath = await ImageStorageService.instance.uploadJpeg(
            bytes,
            folder: 'encyclopedia',
          );
        } else {
          final dir = await getApplicationDocumentsDirectory();
          final file =
              File('${dir.path}/encyclopedia_${const Uuid().v4()}.jpg');
          await file.writeAsBytes(bytes);
          savedPath = file.path;
        }
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

  /// Os campos que o verbete traria — os mesmos que a página gerada mostra,
  /// na ordem em que aparecem lá. Fixos, do l10n: quem não tem acesso não
  /// faz o app gastar identificação nem geração nenhuma.
  List<String> _camposDoVerbete(AppLocalizations l10n) {
    return [
      l10n.encyLockedIdentify,
      switch (widget.category) {
        UserEntryCategory.herb => l10n.encyLockedDescriptionHerb,
        UserEntryCategory.crystal => l10n.encyLockedDescriptionCrystal,
        UserEntryCategory.color => l10n.encyLockedDescriptionColor,
      },
      l10n.encySectionMagicProps,
      l10n.encySectionMagicUses,
      l10n.encySectionCorrespondences,
      if (widget.category == UserEntryCategory.herb) l10n.encySectionSafety,
      l10n.encyLockedSaved,
    ];
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
                  // Prévia a partir dos bytes já comprimidos: funciona no
                  // celular e na web (onde o "caminho" é um blob do navegador,
                  // que Image.file não sabe abrir).
                  if (_jpegBytes != null) ...[
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          _jpegBytes!,
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
            if (_mostrarPrevia && _jpegBytes == null)
              MagicalCard(
                child: PremiumLockedPreview(titles: _camposDoVerbete(l10n)),
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
              if (_candidates.length > 1 && _chosen == null)
                _buildCandidates(context, l10n),
              if (_candidates.length <= 1 || _chosen != null)
                _buildNameCard(context, l10n),
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

  String _confidenceLabel(AppLocalizations l10n) {
    switch (_confidence) {
      case 'high':
        return l10n.encyAddConfidenceHigh;
      case 'low':
        return l10n.encyAddConfidenceLow;
      default:
        return l10n.encyAddConfidenceMedium;
    }
  }

  /// Lista de possibilidades quando a identificação não é inequívoca.
  ///
  /// Perguntar é melhor que adivinhar: quem tirou a foto tem o exemplar na
  /// frente e reconhece detalhes que não cabem numa imagem.
  Widget _buildCandidates(BuildContext context, AppLocalizations l10n) {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.encyAddCandidatesTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.encyAddCandidatesSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _candidates.length; i++) ...[
            _buildCandidateTile(context, l10n, i),
            const SizedBox(height: 8),
          ],
          TextButton.icon(
            onPressed: () => _chooseCandidate(-1),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(l10n.encyAddCandidatesNoneOfThese),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateTile(
    BuildContext context,
    AppLocalizations l10n,
    int index,
  ) {
    final candidate = _candidates[index];
    final title = _candidateName(candidate);
    final scientific = '${candidate['scientific'] ?? ''}'.trim();
    // O científico só vira subtítulo quando NÃO é o próprio título: sem nome
    // popular ele já subiu para cima, e repeti-lo seria ruído.
    final subtitle = title == scientific ? '' : scientific;
    final votes = candidate['votes'] is int ? candidate['votes'] as int : 1;

    return InkWell(
      onTap: () => _chooseCandidate(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: context.gc.surfaceBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.gc.lilac,
                          // Itálico é convenção de binômio latino: o título só
                          // é científico quando não há nome popular (aí não há
                          // subtítulo), e nesse caso ele vai em itálico.
                          fontStyle: subtitle.isEmpty && scientific.isNotEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.textSecondary,
                            // O subtítulo agora é o binômio latino.
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                  if (votes > 1) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.encyAddCandidateVotes(votes),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context.gc.textSecondary,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.gc.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildNameCard(BuildContext context, AppLocalizations l10n) {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _identified ? l10n.encyAddIdentifiedAs : l10n.encyAddNotIdentified,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_identified && _confidence != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.encyAddConfidence(_confidenceLabel(l10n)),
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
          if (_candidates.length > 1) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => setState(() => _chosen = null),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(l10n.encyAddCandidatesBack),
            ),
          ],
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
