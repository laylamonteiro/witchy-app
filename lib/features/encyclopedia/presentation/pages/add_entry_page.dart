import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/services/debug_log_service.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/images/etapa_da_foto.dart';
import '../../../../core/images/seletor_de_foto.dart';
import '../../../../core/utils/reducao_de_imagem.dart';
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
import '../../../../core/tools/tool_identity.dart';

/// Escolhe (câmera/galeria) e comprime a foto; null se a pessoa desistiu.
typedef EscolherFoto = Future<Uint8List?> Function(ImageSource source);

/// A porta da IA desta tela. Existe para o teste trocar a IA por um dublê:
/// a decisão (quando identificar, quando gerar, o que fica desabilitado) é
/// desta página; a chamada de rede, não.
abstract class GuiaDaNaturezaIa {
  /// Identificação por foto — SÓ para ervas (ver
  /// [UserEntryCategory.identificavelPorFoto]).
  Future<Map<String, dynamic>> identificarErva({required Uint8List jpegBytes});

  /// O verbete completo a partir do nome. A foto vai junto SÓ para erva
  /// (a descrição se ancora no exemplar real); cristal vai sem foto, pelo
  /// caminho de texto — o de visão é mais lento e tem cota apertada, e a
  /// pedra não precisa dele.
  Future<Map<String, dynamic>> gerar({
    required String name,
    required String categoryKey,
    Uint8List? jpegBytes,
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
    Uint8List? jpegBytes,
  }) =>
      AIService.instance.generateEncyclopediaEntry(
        name: name,
        categoryKey: categoryKey,
        jpegBytes: jpegBytes,
      );
}

/// Adicionar entrada pessoal à enciclopédia (Premium): erva ou cristal.
///
/// A jornada é a mesma para as duas: foto obrigatória (câmera ou galeria),
/// nome, "Gerar conteúdo" — a IA monta a página no formato da categoria e
/// tudo é salvo com a foto. A única diferença é a caixa "Não sei o nome —
/// identificar pela foto", que só a erva tem: marcada, o campo do nome fica
/// para a identificação e o mesmo "Gerar conteúdo" descobre o nome antes de
/// montar a página. A identificação visual de cristais errava demais para
/// entrar aqui, e cores não têm mais verbete pessoal (o catálogo fixo da
/// aba Cores basta).
///
/// Privacidade: a foto é enviada à IA em memória (identificação e geração).
/// A cópia comprimida vai para o armazenamento privado da conta (Supabase
/// Storage) quando há sessão e a sincronização está ligada — e fica também
/// no aparelho; sem isso, só no aparelho. Ver política de privacidade,
/// seção "Onde seus dados vivem".
class AddEntryPage extends StatefulWidget {
  final UserEntryCategory category;

  /// Trocáveis em teste; em produção, o [SeletorDeFoto] (picker, conversão,
  /// recorte quadrado, redução) e o AIService.
  final EscolherFoto? escolherFoto;
  final GuiaDaNaturezaIa ia;

  const AddEntryPage({
    super.key,
    required this.category,
    this.escolherFoto,
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

  /// O seletor está aberto ou a foto está sendo comprimida: botões travados
  /// e um aviso no card. Antes não havia estado nenhum aqui — uma falha caía
  /// na zona (só log) e a pessoa via "nada acontecer".
  bool _escolhendoFoto = false;

  /// Falha ao abrir/aceitar a foto, mostrada DENTRO do card da foto (o erro
  /// geral fica no fim da página, fora da vista).
  String? _erroDaFoto;

  /// Em que passo a foto está enquanto [_escolhendoFoto]: é o texto ao lado
  /// do spinner ("Convertendo…" numa HEIC leva segundos, e silêncio parece
  /// travamento).
  EtapaDaFoto _etapa = EtapaDaFoto.abrindo;

  /// "Não sei o nome": o campo do nome fica desabilitado e quem descobre o
  /// nome é a identificação por foto, disparada pelo próprio "Gerar
  /// conteúdo". Só existe para erva (`identificavelPorFoto`).
  bool _naoSeiONome = false;

  /// Pediu a foto sem ter Premium: a tela mostra os campos que o verbete
  /// traria, em vez de bater a porta na entrada.
  bool _mostrarPrevia = false;

  bool get _ocupado =>
      _escolhendoFoto || _identifying || _generating || _saving;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _escolher(ImageSource source) {
    final dubl = widget.escolherFoto;
    if (dubl != null) return dubl(source);
    return const SeletorDeFoto().escolher(
      context,
      origem: source,
      aoMudarEtapa: (etapa) {
        if (mounted) setState(() => _etapa = etapa);
      },
    );
  }

  String _textoDaEtapa(AppLocalizations l10n) => switch (_etapa) {
        EtapaDaFoto.abrindo => l10n.photoStageOpening,
        EtapaDaFoto.convertendo => l10n.photoStageConverting,
        EtapaDaFoto.recortando => l10n.photoStageCropping,
        EtapaDaFoto.reduzindo => l10n.photoStageReducing,
      };

  Future<void> _pick(ImageSource source) async {
    if (_ocupado) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _error = null;
      _erroDaFoto = null;
    });

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

    setState(() {
      _escolhendoFoto = true;
      _etapa = EtapaDaFoto.abrindo;
    });
    final Uint8List? bytes;
    try {
      bytes = await _escolher(source);
    } on FotoNaoSuportadaException catch (e) {
      if (!mounted) return;
      setState(() {
        _escolhendoFoto = false;
        _erroDaFoto = l10n.encyAddPhotoUnsupported(e.formato);
      });
      return;
    } catch (e) {
      unawaited(debugLog('ENCY', 'Falha ao abrir a foto ($source): $e'));
      if (!mounted) return;
      setState(() {
        _escolhendoFoto = false;
        _erroDaFoto = l10n.encyAddPhotoFailed;
      });
      return;
    }
    if (!mounted) return;
    if (bytes == null) {
      // Desistiu no seletor: nada a dizer.
      setState(() => _escolhendoFoto = false);
      return;
    }
    if (bytes.length > _maxUploadBytes) {
      unawaited(debugLog('ENCY', 'Foto grande demais: ${bytes.length} bytes'));
      setState(() {
        _escolhendoFoto = false;
        _erroDaFoto = l10n.encyAddImageTooLarge;
      });
      return;
    }
    unawaited(debugLog('ENCY', 'Foto pronta: ${bytes.length} bytes ($source)'));

    // Foto nova, verbete novo: o que a IA disse da foto anterior não vale
    // mais. O nome só é limpo se veio da identificação — o que a pessoa
    // digitou por conta própria continua valendo.
    setState(() {
      _escolhendoFoto = false;
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
        // Não reconheci nada: com a caixa marcada o campo ficaria travado e
        // sem nome nenhum — um beco. Ela volta a poder digitar.
        if (candidates.isEmpty) _naoSeiONome = false;
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

  /// Toque num candidato: além de fixar o nome, retoma a jornada que a
  /// pessoa pediu ao tocar em "Gerar conteúdo" — escolher qual era a planta
  /// era a única pergunta em aberto.
  void _escolherCandidatoEContinuar(int index) {
    // `_generated == null` fecha o laço do "ver as outras possibilidades":
    // com a página já montada, trocar de candidato só troca o nome — não
    // dispara outra geração a cada toque.
    final continuar = index >= 0 && _naoSeiONome && _generated == null;
    _chooseCandidate(index);
    if (continuar) unawaited(_generate());
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
        // Nenhum candidato serve: quem vai dizer o nome é ela, então o campo
        // precisa voltar a aceitar digitação.
        _naoSeiONome = false;
      } else {
        final candidate = _candidates[index];
        _identified = true;
        _confidence = '${candidate['confidence']}';
        _nameController.text = _candidateName(candidate);
      }
    });
  }

  /// "Não sei o nome" marcada: o botão "Gerar conteúdo" primeiro descobre o
  /// nome pela foto e só então monta a página. Com um candidato só, tudo
  /// acontece num toque; com vários, o card de candidatos assume e a jornada
  /// continua quando ela escolher.
  Future<void> _identificarEGerar() async {
    await _identify();
    // `_generate` lê o `context` na primeira linha: sem esta guarda, sair da
    // tela durante a identificação (que é uma ida à rede) daria erro.
    if (!mounted) return;
    // `_error` cobre o teto de requisições e a falha genérica. Nenhum
    // candidato já desmarcou a caixa lá dentro, para ela poder digitar.
    if (_error != null || _candidates.length != 1) return;
    if (_nameController.text.trim().isEmpty) return;
    await _generate();
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
        // Erva: o verbete considera a foto real — a descrição fala do
        // exemplar fotografado, não de uma versão genérica da espécie.
        // Cristal: sem foto. O caminho de visão é mais lento (Gemini
        // estourava 60 s) e tem cota apertada (Groq 429), e a pedra não
        // precisa dele; a foto fica só na página.
        jpegBytes: widget.category.identificavelPorFoto ? bytes : null,
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
        // A folha do Guia da Natureza acompanha a ficha que está nascendo.
        title: ToolHeading(
          tool: ToolId.natureGuide,
          title: l10n.encyAddTitle(_categoryLabel(l10n)),
          // O seletor de categoria já fechou: não há de onde o emblema voar.
          flies: false,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chaves nos cards: sem elas, um card que aparece ANTES do card do
            // nome (a prévia Premium) era casado por posição com ele, e o
            // campo do nome renascia — perdia o foco, o teclado fechava.
            KeyedSubtree(
              key: const ValueKey('card-da-foto'),
              child: _buildPhotoCard(context, l10n),
            ),
            if (_mostrarPrevia && _jpegBytes == null)
              MagicalCard(
                key: const ValueKey('card-da-previa'),
                child: PremiumLockedPreview(titles: _camposDoVerbete(l10n)),
              ),
            if (_identifying)
              KeyedSubtree(
                key: const ValueKey('card-identificando'),
                child: _buildIdentifying(context, l10n),
              )
            else if (candidatosAbertos)
              KeyedSubtree(
                key: const ValueKey('card-dos-candidatos'),
                child: _buildCandidates(context, l10n),
              )
            else
              KeyedSubtree(
                key: const ValueKey('card-do-nome'),
                child: _buildNameCard(context, l10n),
              ),
            if (_generated != null)
              KeyedSubtree(
                key: const ValueKey('card-do-verbete'),
                child: _buildPreview(context, l10n),
              ),
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
          if (_escolhendoFoto) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _textoDaEtapa(l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ],
          if (_erroDaFoto != null) ...[
            const SizedBox(height: 12),
            Text(
              _erroDaFoto!,
              style: TextStyle(color: context.gc.alert),
            ),
          ],
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
      onTap: () => _escolherCandidatoEContinuar(index),
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
            // Chave própria: o título "Encontrei!" entra ANTES do campo depois
            // da identificação, e sem chave o campo renascia noutra posição
            // (foco e teclado perdidos).
            key: const ValueKey('campo-do-nome'),
            controller: _nameController,
            // Com "não sei o nome" marcada, quem preenche é a identificação.
            // `readOnly` e não `enabled: false` por dois motivos: desabilitar
            // um campo com foco derruba o foco (foi o que fechava o teclado
            // do pêndulo no meio da consulta), e o tema não tem borda de
            // campo desabilitado — o nome ENCONTRADO sairia esmaecido, logo
            // ele, que é o que ela precisa ler e conferir.
            readOnly: _naoSeiONome,
            canRequestFocus: !_naoSeiONome,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.encyAddNameLabel,
              hintText: _naoSeiONome
                  ? l10n.encyAddNameFromPhoto
                  : l10n.encyAddNameHint,
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
          if (widget.category.identificavelPorFoto) ...[
            const SizedBox(height: 4),
            // Mesma interação do "não sei a hora do nascimento" do mapa
            // astral: marcar tira o campo ao lado das mãos dela e passa o
            // trabalho para quem sabe descobrir. Era um segundo botão, e
            // dois CTAs empilhados faziam escolher entre caminhos que, no
            // fim, são o mesmo — muda só de onde vem o nome.
            CheckboxListTile(
              value: _naoSeiONome,
              onChanged: _ocupado
                  ? null
                  : (marcada) => setState(() {
                        _naoSeiONome = marcada ?? false;
                        // O teclado não fica aberto sobre um campo que
                        // acabou de sair de uso.
                        if (_naoSeiONome) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      }),
              title: Text(
                l10n.encyAddIdentifyCta,
                style: TextStyle(color: context.gc.softWhite),
              ),
              activeColor: context.gc.lilac,
              contentPadding: EdgeInsets.zero,
            ),
          ],
          const SizedBox(height: 8),
          MagicalButton(
            text: _generating
                ? l10n.encyAddGenerating
                : l10n.encyAddGenerateCta,
            icon: Icons.auto_awesome,
            enabled: temFoto && !_ocupado,
            larguraTotal: true,
            onPressed: _naoSeiONome ? _identificarEGerar : _generate,
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
          // Salvar é quando a foto SOBE para a nuvem: além do rótulo do
          // botão, um indicador de que há trabalho em curso.
          if (_saving) ...[
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.encyAddSaving,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          MagicalButton(
            text: _saving ? l10n.encyAddSaving : l10n.encyAddSaveCta,
            icon: Icons.bookmark_add_outlined,
            enabled: !_saving,
            larguraTotal: true,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
