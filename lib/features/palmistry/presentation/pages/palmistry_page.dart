import 'package:flutter/material.dart';
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

  static const int _maxUploadBytes = 4 * 1024 * 1024; // limite Groq ~4MB base64

  Future<void> _pick(ImageSource source) async {
    if (_isAnalyzing) return;

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
          'A imagem ficou grande demais. Tente com menos zoom ou outra foto.',
        );
      }
      if (bytes.length < 20 * 1024) {
        throw Exception(
          'A imagem parece pequena ou escura demais para leitura. '
          'Fotografe a palma bem iluminada, preenchendo a tela.',
        );
      }

      final reading = await AIService.instance.analyzePalm(jpegBytes: bytes);
      if (!mounted) return;
      setState(() => _reading = reading);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'.replaceAll('Exception: ', '')),
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
          FreeWritingModel(content: '🖐️ Leitura de Mãos — $date\n\n$reading'),
        );
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Leitura salva nas suas Reflexões! ✨'),
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
        title: const ResponsiveAppBarTitle('Leitura de Mãos'),
      ),
      body: !access.hasFullAccess
          ? _buildPremiumInvite(access.message)
          : _buildFlow(),
    );
  }

  Widget _buildPremiumInvite(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🖐️', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Quiromancia',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: context.gc.lilac,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message ??
                  'A leitura de mãos é exclusiva do plano Premium.',
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
              label: const Text('Seja Premium'),
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
                  '🖐️ Como fotografar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                _tip(context, 'Palma da mão dominante aberta e relaxada'),
                _tip(context, 'Luz natural, sem sombras fortes sobre as linhas'),
                _tip(context, 'A palma deve preencher quase toda a foto'),
                _tip(context, 'Evite fotos tremidas ou desfocadas'),
                const SizedBox(height: 10),
                Text(
                  'Privacidade: a foto é processada na hora e descartada — '
                  'não fica salva no aparelho nem em servidores.',
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
                    label: const Text('Câmera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isAnalyzing ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Galeria'),
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
                    'Lendo as linhas da sua mão…',
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
                    '✨ Sua Leitura',
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
                    'Leitura simbólica para reflexão — não substitui '
                    'orientação médica, psicológica ou profissional.',
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
                        _saved ? 'Salva nas Reflexões' : 'Salvar leitura',
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
