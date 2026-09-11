import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/utils/image_compression.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/premium_locked_preview.dart';
import '../../../diary/presentation/widgets/dream_interpretation_text.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../grimoire/presentation/pages/record_detail_page.dart';
import '../../../diary/presentation/providers/free_writing_provider.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';
import '../../../../core/widgets/motion/retry_notice.dart';
import '../widgets/palm_scan_view.dart';
import '../../../../core/tools/tool_identity.dart';

/// Leitura de Mãos (Quiromancia) — exclusiva Premium.
///
/// A foto é redimensionada/comprimida em memória, enviada para análise e
/// descartada: nada é armazenado local ou remotamente.
class PalmistryPage extends StatefulWidget {
  const PalmistryPage({super.key, this.choosePhoto, this.analyzePalm});

  /// Só para teste: entrega os bytes já comprimidos no lugar do plugin de
  /// câmera/galeria. Devolver null é o mesmo que desistir da foto.
  final Future<Uint8List?> Function(ImageSource source)? choosePhoto;

  /// Só para teste: a análise, no lugar da chamada de visão real.
  final Future<String> Function(Uint8List bytes)? analyzePalm;

  @override
  State<PalmistryPage> createState() => _PalmistryPageState();
}

class _PalmistryPageState extends State<PalmistryPage> {
  final _picker = ImagePicker();

  bool _isAnalyzing = false;
  String? _reading;
  bool _saved = false;

  /// A foto já comprimida, guardada só em memória para uma segunda
  /// tentativa: tentar de novo não pede outra foto nem cobra a cota de novo.
  Uint8List? _bytes;

  /// A falha visível. Um aviso que some não basta: a pessoa fica sem
  /// leitura e sem saber o que fazer.
  String? _error;

  /// Pediu a leitura sem ter Premium: a tela mostra o sumário do que ela
  /// diria, em vez de bater a porta na entrada.
  bool _mostrarPrevia = false;

  static const int _maxUploadBytes = 4 * 1024 * 1024; // limite Groq ~4MB base64

  Future<void> _pick(ImageSource source) async {
    if (_isAnalyzing) return;

    // Sem Premium a leitura não é feita: a foto não é escolhida, não sai do
    // aparelho e nenhuma chamada de visão acontece. O que aparece é o
    // sumário do que a leitura traria.
    final access =
        context.read<AuthProvider>().checkFeatureAccess(AppFeature.aiPalmistry);
    if (!access.hasFullAccess) {
      setState(() => _mostrarPrevia = true);
      return;
    }

    // Limite diário (protege a cota compartilhada da API de visão do Groq).
    if (!context.read<AuthProvider>().canUsePalmistry) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).palmDailyLimitReached),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    // Lidos antes de qualquer await (use_build_context_synchronously).
    final l10n = AppLocalizations.of(context);
    try {
      final bytes = await _choosePhoto(source);
      // Desistir da foto não deixa rastro: nem análise em curso, nem erro.
      if (bytes == null || !mounted) return;

      setState(() {
        _reading = null;
        _error = null;
        _saved = false;
      });

      if (bytes.length > _maxUploadBytes) {
        throw Exception(l10n.palmImageTooLarge);
      }
      if (bytes.length < 20 * 1024) {
        throw Exception(l10n.palmImageTooSmall);
      }

      _bytes = bytes;
      await _analyze(bytes, l10n);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _error = _messageFor(e, l10n);
      });
    }
  }

  /// A foto, já comprimida: redimensiona em memória, corrige a rotação EXIF,
  /// remove metadados e limita o tamanho do envio. null = desistiu.
  Future<Uint8List?> _choosePhoto(ImageSource source) async {
    final injected = widget.choosePhoto;
    if (injected != null) return injected(source);
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked == null) return null;
    final compressed = await compressPickedImage(picked);
    return compressed ?? await picked.readAsBytes();
  }

  /// A chamada real. A cota e o rito do dia só mudam quando a leitura chega;
  /// uma falha vira estado visível, com retomada explícita da mesma foto.
  Future<void> _analyze(Uint8List bytes, AppLocalizations l10n) async {
    final auth = context.read<AuthProvider>();
    final checkin = context.read<DailyCheckinProvider>();
    setState(() {
      _isAnalyzing = true;
      _error = null;
    });
    try {
      final read = widget.analyzePalm ??
          ((Uint8List image) => AIService.instance.analyzePalm(jpegBytes: image));
      final reading = await read(bytes);
      if (!mounted) return;
      setState(() => _reading = reading);
      // Só conta quando a leitura foi gerada com sucesso.
      await auth.incrementPalmistryReadings();
      // A leitura saiu: se a quiromancia é o rito de hoje, está cumprida.
      unawaited(checkin.completeRite(DailyRites.palmistry));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _messageFor(e, l10n));
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  /// Tentar de novo usa a MESMA foto já escolhida: nada é pedido outra vez.
  Future<void> _retry() async {
    final bytes = _bytes;
    if (bytes == null || _isAnalyzing) return;
    await _analyze(bytes, AppLocalizations.of(context));
  }

  String _messageFor(Object error, AppLocalizations l10n) =>
      error is AiRateLimitException
          ? l10n.palmRateLimit
          : '$error'.replaceAll('Exception: ', '');

  Future<void> _saveReading() async {
    final reading = _reading;
    if (reading == null || _saved) return;

    final now = DateTime.now();
    final date = '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    // _saved marcado antes do await bloqueia toques repetidos no botão.
    setState(() => _saved = true);
    // Leitura gerada: entra no acervo "Meus Registros" (não é uma
    // reflexão escrita pela Bruxa). O título carrega a data que antes
    // abria o texto.
    final writing = FreeWritingModel(
      title: '${AppLocalizations.of(context).palmReadingHeader} — $date',
      content: reading,
      source: FreeWritingSource.palmistry,
    );
    final provider = context.read<FreeWritingProvider>();
    await provider.save(writing);
    if (!mounted) return;
    if (provider.error != null) {
      // save não lança: sinaliza falha via provider.error. Reabilita o
      // botão para nova tentativa em vez de navegar para uma reflexão
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
        content: Text(AppLocalizations.of(context).palmSavedToRecords),
        backgroundColor: context.gc.success,
      ),
    );
    // Leva direto ao registro recém-criado (voltar dele cai na tela
    // anterior, sem ter que procurar em Meus Registros).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RecordDetailPage(entry: writing)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: ToolHeading(tool: ToolId.palmistry,
            title: AppLocalizations.of(context).toolPalmistryTitle),
      ),
      // A tela é a mesma para todo mundo: quem não tem Premium lê como
      // fotografar a mão, escolhe a foto e vê o SUMÁRIO do que a leitura
      // diria, ponto a ponto, sob véu. A foto nem chega a ser enviada.
      // O saldo do dia só vai para a tela de quem PODE ler. Para o Free, "3
      // leituras restantes hoje" era uma promessa que a tela não cumpre: a
      // leitura de mãos é exclusiva do Premium, e ele vê o sumário sob véu.
      body: _buildFlow(
        authProvider
                .checkFeatureAccess(AppFeature.aiPalmistry)
                .hasFullAccess
            ? authProvider.remainingPalmistryReadings
            : null,
      ),
    );
  }

  Widget _buildFlow(int? remainingReadings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).palmHowTo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                _tip(context, AppLocalizations.of(context).palmTip1),
                _tip(context, AppLocalizations.of(context).palmTip2),
                _tip(context, AppLocalizations.of(context).palmTip3),
                _tip(context, AppLocalizations.of(context).palmTip4),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context).palmPrivacyNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
          MagicalCard(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isAnalyzing ? null : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: Text(AppLocalizations.of(context).palmCamera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isAnalyzing ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: Text(AppLocalizations.of(context).palmGallery),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.gc.lilac,
                      side: BorderSide(color: context.gc.lilac),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Saldo de leituras do dia. Oculto para admin/ilimitado (-1) e para
          // quem não tem acesso à leitura (null).
          if (remainingReadings != null && remainingReadings >= 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                '${AppLocalizations.of(context).palmRemainingToday}: '
                '$remainingReadings',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.gc.textSecondary,
                    ),
              ),
            ),
          if (_isAnalyzing)
            MagicalCard(
              child: Column(
                children: [
                  // A faixa de luz percorre a palma enquanto a análise real
                  // dura — nem um segundo a mais.
                  const PalmScanView(
                    key: ValueKey('palm-scan'),
                    active: true,
                  ),
                  LoadingWidget(
                    message: AppLocalizations.of(context).palmReadingLines,
                  ),
                ],
              ),
            ),
          // Falhou: a foto continua aqui e a retomada é uma escolha da
          // pessoa. Nenhum sucesso é anunciado.
          if (_error != null && !_isAnalyzing)
            RetryNotice(
              retryKey: const ValueKey('palm-retry'),
              message: _error!,
              // Sem foto guardada não há o que repetir: pedir outra é o
              // caminho, e os botões acima continuam ali.
              onRetry: _bytes == null ? null : _retry,
            ),
          if (_mostrarPrevia && _reading == null)
            MagicalCard(
              child: PremiumLockedPreview(
                titles: [
                  AppLocalizations.of(context).palmLockedTitle1,
                  AppLocalizations.of(context).palmLockedTitle2,
                  AppLocalizations.of(context).palmLockedTitle3,
                  AppLocalizations.of(context).palmLockedTitle4,
                  AppLocalizations.of(context).palmLockedTitle5,
                  AppLocalizations.of(context).palmLockedTitle6,
                ],
              ),
            ),
          if (_reading != null) ...[
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).palmYourReading,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  // Destaca os cabeçalhos ◈ (cada ponto da mão) e ✦ (síntese).
                  DreamInterpretationText(_reading!),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).palmDisclaimer,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saved ? null : _saveReading,
                      icon: Icon(
                        _saved ? Icons.check : Icons.bookmark_add_outlined,
                        size: 18,
                      ),
                      label: Text(
                        _saved ? AppLocalizations.of(context).palmSavedShort : AppLocalizations.of(context).palmSaveReading,
                      ),
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

  Widget _tip(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: context.gc.lilac)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
