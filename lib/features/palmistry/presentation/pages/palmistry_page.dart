import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/presentation/providers/free_writing_provider.dart';

/// Leitura de Mãos (Quiromancia) — exclusiva Premium.
///
/// A foto é redimensionada/comprimida em memória, enviada para análise e
/// descartada: nada é armazenado local ou remotamente.
class PalmistryPage extends StatefulWidget {
  const PalmistryPage({super.key});

  @override
  State<PalmistryPage> createState() => _PalmistryPageState();
}

class _PalmistryPageState extends State<PalmistryPage> {
  final _picker = ImagePicker();

  bool _isAnalyzing = false;
  String? _reading;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    // Funcionalidade 100% Premium: sem acesso, sobe o paywall direto
    // (sem tela intermediária de "Seja Premium") e volta.
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAccess());
  }

  Future<void> _ensureAccess() async {
    final access =
        context.read<AuthProvider>().checkFeatureAccess(AppFeature.aiPalmistry);
    if (!access.hasFullAccess && mounted) {
      await showPaywallThenPop(context);
    }
  }

  static const int _maxUploadBytes = 4 * 1024 * 1024; // limite Groq ~4MB base64

  Future<void> _pick(ImageSource source) async {
    if (_isAnalyzing) return;

    // Limite diário (protege a cota compartilhada da API de visão do Groq).
    if (!context.read<AuthProvider>().canUsePalmistry) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.palmDailyLimitReached),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (picked == null || !mounted) return;

      setState(() {
        _isAnalyzing = true;
        _reading = null;
        _saved = false;
      });

      // Redimensiona/comprime em memória: corrige rotação EXIF, remove
      // metadados e limita o tamanho do envio.
      final compressed = await FlutterImageCompress.compressWithFile(
        picked.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 82,
        format: CompressFormat.jpeg,
      );
      final bytes = compressed ?? await picked.readAsBytes();

      if (bytes.length > _maxUploadBytes) {
        throw Exception(
          AppLocalizations.of(context)!.palmImageTooLarge,
        );
      }
      if (bytes.length < 20 * 1024) {
        throw Exception(
          AppLocalizations.of(context)!.palmImageTooSmall,
        );
      }

      final reading = await AIService.instance.analyzePalm(jpegBytes: bytes);
      if (!mounted) return;
      setState(() => _reading = reading);
      // Só conta quando a leitura foi gerada com sucesso.
      await context.read<AuthProvider>().incrementPalmistryReadings();
    } catch (e) {
      if (!mounted) return;
      final message = e is AiRateLimitException
          ? AppLocalizations.of(context)!.palmRateLimit
          : '$e'.replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: context.gc.alert,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _saveReading() async {
    final reading = _reading;
    if (reading == null || _saved) return;

    final now = DateTime.now();
    final date = '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    await context.read<FreeWritingProvider>().save(
          FreeWritingModel(content: '🖐️ ${AppLocalizations.of(context)!.palmReadingHeader} — $date\n\n$reading'),
        );
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.palmSavedToReflections),
        backgroundColor: context.gc.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final access = authProvider.checkFeatureAccess(AppFeature.aiPalmistry);

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context)!.toolPalmistryTitle),
      ),
      body: !access.hasFullAccess
          ? const SizedBox.shrink()
          : _buildFlow(),
    );
  }

  Widget _buildFlow() {
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
                  AppLocalizations.of(context)!.palmHowTo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                _tip(context, AppLocalizations.of(context)!.palmTip1),
                _tip(context, AppLocalizations.of(context)!.palmTip2),
                _tip(context, AppLocalizations.of(context)!.palmTip3),
                _tip(context, AppLocalizations.of(context)!.palmTip4),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.palmPrivacyNote,
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
                    label: Text(AppLocalizations.of(context)!.palmCamera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isAnalyzing ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: Text(AppLocalizations.of(context)!.palmGallery),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.gc.lilac,
                      side: BorderSide(color: context.gc.lilac),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isAnalyzing)
            MagicalCard(
              child: Column(
                children: [
                  CircularProgressIndicator(color: context.gc.lilac),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.palmReadingLines,
                    style: TextStyle(color: context.gc.textSecondary),
                  ),
                ],
              ),
            ),
          if (_reading != null) ...[
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.palmYourReading,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _reading!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.palmDisclaimer,
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
                        _saved ? AppLocalizations.of(context)!.palmSavedShort : AppLocalizations.of(context)!.palmSaveReading,
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
