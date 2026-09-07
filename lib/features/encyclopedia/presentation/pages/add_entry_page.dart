import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/utils/image_compression.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/photo_source_buttons.dart';
import '../../../../core/widgets/premium_locked_preview.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';
import '../../data/models/user_entry_model.dart';
import '../providers/encyclopedia_provider.dart';
import 'crystal_detail_page.dart';
import 'herb_detail_page.dart';

/// Escolhe (câmera/galeria) e comprime a foto; null se a pessoa desistiu.
typedef EscolherFoto = Future<Uint8List?> Function(ImageSource source);

/// A porta da IA desta tela. Existe para o teste trocar a IA por um dublê:
/// a decisão (quando identificar, quando gerar, o que fica desabilitado) é
/// desta página; a chamada de rede, não.
abstract class GuiaDaNaturezaIa {
  /// Identificação por foto — SÓ para ervas (ver
  /// [UserEntryCategory.identificavelPorFoto]).
  Future<Map<String, dynamic>> identificarErva({required Uint8List jpegBytes});

  /// O verbete completo a partir do nome, com a foto anexada.
  Future<Map<String, dynamic>> gerar({
    required String name,
    required String categoryKey,
    required Uint8List jpegBytes,
  });
}

class _IaDoApp implements GuiaDaNaturezaIa {
  const _IaDoApp();

  @override
  Future<Map<String, dynamic>> identificarErva({
    required Uint8List jpegBytes,
  }) =>
      AIService.instance.identifyHerb(jpegBytes: jpegBytes);

  @override
  Future<Map<String, dynamic>> gerar({
    required String name,
    required String categoryKey,
    required Uint8List jpegBytes,
  }) =>
      AIService.instance.generateEncyclopediaEntry(
        name: name,
        categoryKey: categoryKey,
        jpegBytes: jpegBytes,
      );
}

/// A foto do aparelho: picker (já reduzida a 1600 px) + compressão, que
/// corrige o EXIF e remove metadados — mesmo pipeline da quiromancia.
Future<Uint8List?> _fotoDoAparelho(ImageSource source) async {
  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1600,
    maxHeight: 1600,
  );
  if (picked == null) return null;
  return compressPickedImage(picked);
}

/// Adicionar entrada pessoal à enciclopédia (Premium): erva ou cristal.
///
/// A jornada é a mesma para as duas: foto obrigatória (câmera ou galeria),
/// nome, "Gerar conteúdo" — a IA monta a página no formato da categoria e
/// tudo é salvo com a foto. A única diferença é o botão secundário "Não sei
/// o nome — identificar pela foto", que só a erva tem: a identificação
/// visual de cristais errava demais para ser a porta de entrada, e cores não
/// têm mais verbete pessoal (o catálogo fixo da aba Cores basta).
///
/// Privacidade: a foto é enviada à IA em memória (identificação e geração).
/// A cópia comprimida vai para o armazenamento privado da conta (Supabase
/// Storage) quando há sessão e a sincronização está ligada — e fica também
/// no aparelho; sem isso, só no aparelho. Ver política de privacidade,
/// seção "Onde seus dados vivem".
class AddEntryPage extends StatefulWidget {
  final UserEntryCategory category;

  /// Trocáveis em teste; em produção, o picker do aparelho e o AIService.
  final EscolherFoto escolherFoto;
  final GuiaDaNaturezaIa ia;

  const AddEntryPage({
    super.key,
    required this.category,
    this.escolherFoto = _fotoDoAparelho,
    this.ia = const _IaDoApp(),
  }) : assert(
          category != UserEntryCategory.color,
          'cores não têm verbete pessoal',
        );

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  static const int _maxUploadBytes = 4 * 1024 * 1024; // limite da API (base64)

  final TextEditingController _nameController = TextEditingController();

  Uint8List? _jpegBytes;
  bool _identifying = false;
  bool _identified = false;

  /// Já pediu identificação para ESTA foto: é o que decide entre "Encontrei!"
  /// e "Não consegui identificar" no card do nome.
  bool _tentouIdentificar = false;
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

  /// Pediu a foto sem ter Premium: a tela mostra os campos que o verbete
  /// traria, em vez de bater a porta na entrada.
  bool _mostrarPrevia = false;

  bool get _ocupado => _identifying || _generating || _saving;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);

    // Sem Premium nada acontece: a foto não é escolhida, não sai do aparelho
    // e nenhuma chamada de IA é feita. O que aparece é a lista dos campos
    // que o verbete teria, com o texto sob véu.
    final access = context
        .read<AuthProvider>()
        .checkFeatureAccess(AppFeature.encyclopediaPersonalEntries);
    if (!access.hasFullAccess) {
      setState(() => _mostrarPrevia = true);
      return;
    }

    final provider = context.read<EncyclopediaProvider>();
    final usedToday = await provider.userEntriesCreatedToday();
    if (!mounted) return;
    if (usedToday >= UserModel.dailyNatureIdentifyLimit) {
      setState(() => _error =
          l10n.encyAddDailyLimit(UserModel.dailyNatureIdentifyLimit));
      return;
    }

    final bytes = await widget.escolherFoto(source);
    if (bytes == null || !mounted) return;
    if (bytes.length > _maxUploadBytes) {
      setState(() => _error = l10n.encyAddImageTooLarge);
      return;
    }

    // Foto nova, verbete novo: o que a IA disse da foto anterior não vale
    // mais. O nome só é limpo se veio da identificação — o que a pessoa
    // digitou por conta própria continua valendo.
    setState(() {
      _jpegBytes = bytes;
      _generated = null;
      _candidates = const [];
      _chosen = null;
      _confidence = null;
      _tentouIdentificar = false;
      if (_identified) _nameController.clear();
      _identified = false;
      _error = null;
    });
  }

  /// "Não sei o nome": a IA olha a foto e sugere. Só ervas — e sempre um
  /// atalho, nunca a porta de entrada.
  Future<void> _identify() async {
    final bytes = _jpegBytes;
    if (bytes == null || !widget.category.identificavelPorFoto) return;
    final l10n = AppLocalizations.of(context);

    setState(() {
      _identifying = true;
      _identified = false;
      _generated = null;
      _confidence = null;
      _candidates = const [];
      _chosen = null;
      _error = null;
    });

    try {
      final result = await widget.ia.identificarErva(jpegBytes: bytes);
      if (!mounted) return;
      final raw = result['candidates'];
      final candidates = raw is List
          ? raw.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : <Map<String, dynamic>>[];
      final identified = result['identified'] == true && candidates.isNotEmpty;
      setState(() {
        _identifying = false;
        _tentouIdentificar = true;
        _identified = identified;
        _candidates = candidates;
        // Candidato único já vem escolhido; havendo mais de um, quem tirou a
        // foto decide — o modelo não tem como saber qual espécie é. Sem
        // nenhum, o que a pessoa já digitou fica onde está.
        _chosen = candidates.length == 1 ? 0 : null;
        _confidence =
            candidates.length == 1 ? '${candidates.first['confidence']}' : null;
        if (candidates.length == 1) {
          _nameController.text = _candidateName(candidates.first);
        }
      });
    } catch (e) {
      debugPrint('Guia da Natureza: falha ao identificar: $e');
      if (!mounted) return;
      setState(() {
        _identifying = false;
        _identified = false;
        _tentouIdentificar = false;
        // Teto de requisições do provedor (compartilhado pelo app inteiro):
        // sem isto, o 429 viraria um "não identificado" enganoso. E TODA
        // falha aparece: engolir o resto deixava a pessoa achando que a foto
        // dela é que estava ruim.
        _error = e is AiRateLimitException
            ? l10n.aiVisionRateLimit
            : l10n.errorsGeneric;
      });
    }
  }

  /// Título do candidato — e, por consequência, nome do verbete.
  ///
  /// O nome POPULAR lidera: é o que a praticante reconhece na hora de escolher
  /// e o que ela vai procurar depois na enciclopédia ("Morango", não "Fragaria
  /// x ananassa"). O binômio latino continua visível como apoio (subtítulo no
  /// card, campo próprio no verbete), preservando a precisão entre espécies
  /// parecidas. Sem nome popular, o científico assume o título.
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
    final bytes = _jpegBytes;
    if (bytes == null) {
      setState(() => _error = l10n.encyAddPhotoFirstHint);
      return;
    }
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
      final data = await widget.ia.gerar(
        name: name,
        categoryKey: widget.category.key,
        // O verbete considera a foto real: a descrição fala do exemplar
        // fotografado, não de uma versão genérica da espécie.
        jpegBytes: bytes,
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
    final bytes = _jpegBytes;
    if (data == null || bytes == null || _saving) return;
    setState(() => _saving = true);

    try {
      // O verbete gerado traz o nome CANÔNICO (grafia correta, sem nome
      // científico embutido): salva ele, não o texto digitado — corrige
      // erros de digitação e nomes extensos de uma vez.
      final canonicalName = '${data['name'] ?? ''}'.trim();
      final entry = await context.read<EncyclopediaProvider>().addUserEntry(
            category: widget.category,
            name: canonicalName.isNotEmpty
                ? canonicalName
                : _nameController.text.trim(),
            photoBytes: bytes,
            data: data,
          );
      if (!mounted) return;

      // Uma página nova com a foto dela: se a identificação na natureza é o
      // rito de hoje, está cumprida — erva ou cristal.
      unawaited(context
          .read<DailyCheckinProvider>()
          .completeRite(DailyRites.natureIdentify));

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.encyAddSaved)),
      );
      // Direto para a página recém-criada (voltar dela cai na lista);
      // a lixeira do AppBar já funciona porque a entrada vai junto.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => widget.category == UserEntryCategory.herb
              ? HerbDetailPage(herb: entry.toHerbModel(), userEntry: entry)
              : CrystalDetailPage(
                  crystal: entry.toCrystalModel(),
                  userEntry: entry,
                ),
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

  bool get _ehErva => widget.category == UserEntryCategory.herb;

  String _categoryLabel(AppLocalizations l10n) =>
      _ehErva ? l10n.encyTabHerbs : l10n.encyTabCrystals;

  /// Intro menciona só o elemento da categoria aberta — e, na erva, o
  /// atalho de identificar.
  String _intro(AppLocalizations l10n) =>
      _ehErva ? l10n.encyAddIntroHerb : l10n.encyAddIntroCrystal;

  /// Os campos que o verbete traria — os mesmos que a página gerada mostra,
  /// na ordem em que aparecem lá. Fixos, do l10n: quem não tem acesso não
  /// faz o app gastar identificação nem geração nenhuma.
  List<String> _camposDoVerbete(AppLocalizations l10n) {
    return [
      if (widget.category.identificavelPorFoto) l10n.encyLockedIdentify,
      _ehErva
          ? l10n.encyLockedDescriptionHerb
          : l10n.encyLockedDescriptionCrystal,
      l10n.encySectionMagicProps,
      l10n.encySectionMagicUses,
      l10n.encySectionCorrespondences,
      if (_ehErva) l10n.encySectionSafety,
      l10n.encyLockedSaved,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final candidatosAbertos = _candidates.length > 1 && _chosen == null;

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
            _buildPhotoCard(context, l10n),
            if (_mostrarPrevia && _jpegBytes == null)
              MagicalCard(
                child: PremiumLockedPreview(titles: _camposDoVerbete(l10n)),
              ),
            if (_identifying)
              _buildIdentifying(context, l10n)
            else if (candidatosAbertos)
              _buildCandidates(context, l10n)
            else
              _buildNameCard(context, l10n),
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

  /// Passo 1 — a foto, obrigatória: é ela que vai para o verbete.
  Widget _buildPhotoCard(BuildContext context, AppLocalizations l10n) {
    final bytes = _jpegBytes;
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _intro(l10n),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          // Prévia a partir dos bytes já comprimidos: funciona no celular e
          // na web (onde o "caminho" é um blob do navegador).
          if (bytes != null) ...[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  bytes,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          PhotoSourceButtons(
            onCamera: _ocupado ? null : () => _pick(ImageSource.camera),
            onGallery: _ocupado ? null : () => _pick(ImageSource.gallery),
            cameraLabel: l10n.encyAddTakePhoto,
            galleryLabel: l10n.encyAddFromGallery,
          ),
        ],
      ),
    );
  }

  Widget _buildIdentifying(BuildContext context, AppLocalizations l10n) {
    return MagicalCard(
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

  /// Passo 2 — o nome e o "Gerar conteúdo" (sempre à vista; só habilita com
  /// foto). Na erva, também o atalho de identificar pela foto.
  Widget _buildNameCard(BuildContext context, AppLocalizations l10n) {
    final temFoto = _jpegBytes != null;
    final String? titulo;
    if (_identified) {
      titulo = l10n.encyAddIdentifiedAs;
    } else if (_tentouIdentificar) {
      titulo = l10n.encyAddNotIdentified;
    } else {
      titulo = null;
    }

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != null) ...[
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
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
          ],
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
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
          if (!temFoto) ...[
            const SizedBox(height: 8),
            Text(
              l10n.encyAddPhotoFirstHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          MagicalButton(
            text: _generating
                ? l10n.encyAddGenerating
                : l10n.encyAddGenerateCta,
            icon: Icons.auto_awesome,
            enabled: temFoto && !_ocupado,
            onPressed: _generate,
          ),
          if (widget.category.identificavelPorFoto) ...[
            const SizedBox(height: 8),
            // Secundário de propósito: identificar é o atalho de quem não
            // sabe o nome, não a porta de entrada.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: temFoto && !_ocupado ? _identify : null,
                icon: const Icon(Icons.image_search, size: 18),
                label: Text(l10n.encyAddIdentifyCta),
              ),
            ),
          ],
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
            enabled: !_saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
