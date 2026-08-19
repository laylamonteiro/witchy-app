import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/grimoire_colors.dart';
// Na web não há galeria do sistema: o equivalente é o download do navegador.
import 'image_download_stub.dart'
    if (dart.library.js_interop) 'image_download_web.dart';

/// Abre o sheet de compartilhamento como imagem: pré-visualização do
/// [card] (um [ShareCard]) com ações de compartilhar e salvar na galeria.
///
/// A captura acontece sobre o widget JÁ RENDERIZADO na pré-visualização
/// (RepaintBoundary), então o PNG sai exatamente como a pessoa está vendo —
/// fontes carregadas e tudo.
Future<void> showShareCardSheet(
  BuildContext context, {
  required Widget card,
  required String fileName,
  required String shareText,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ShareCardSheet(
      card: card,
      fileName: fileName,
      shareText: shareText,
    ),
  );
}

class _ShareCardSheet extends StatefulWidget {
  final Widget card;
  final String fileName;
  final String shareText;

  const _ShareCardSheet({
    required this.card,
    required this.fileName,
    required this.shareText,
  });

  @override
  State<_ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<_ShareCardSheet> {
  final GlobalKey _previewKey = GlobalKey();
  bool _isBusy = false;

  Future<Uint8List> _capturePng(String errorMessage) async {
    final boundary = _previewKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception(errorMessage);
    }
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception(errorMessage);
    }
    return byteData.buffer.asUint8List();
  }

  Future<void> _share() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final messenger = ScaffoldMessenger.of(context);
    final gc = context.gc;
    final l10n = AppLocalizations.of(context);
    try {
      final bytes = await _capturePng(l10n.shareImageError);
      final nome = '${widget.fileName}_'
          '${DateTime.now().millisecondsSinceEpoch}.png';

      // Na web não existe diretório temporário (path_provider não tem
      // implementação): compartilha direto dos bytes.
      final XFile arquivo;
      if (kIsWeb) {
        arquivo = XFile.fromData(
          bytes,
          name: nome,
          mimeType: 'image/png',
        );
      } else {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$nome');
        await file.writeAsBytes(bytes);
        arquivo = XFile(file.path, mimeType: 'image/png');
      }

      await SharePlus.instance.share(
        ShareParams(files: [arquivo], text: widget.shareText),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.shareImageError),
          backgroundColor: gc.alert,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _saveToGallery() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final messenger = ScaffoldMessenger.of(context);
    final gc = context.gc;
    final l10n = AppLocalizations.of(context);
    try {
      final bytes = await _capturePng(l10n.shareImageError);
      final nome = '${widget.fileName}_'
          '${DateTime.now().millisecondsSinceEpoch}';

      // O Gal fala com a galeria do sistema, que não existe no navegador.
      if (kIsWeb) {
        await downloadBytes(bytes, '$nome.png', mimeType: 'image/png');
      } else {
        await Gal.putImageBytes(bytes, name: nome);
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb ? l10n.shareImageDownloaded : l10n.shareImageSaved,
          ),
          backgroundColor: gc.success,
        ),
      );
    } on GalException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.type == GalExceptionType.accessDenied
                ? l10n.sigilGalleryPermission
                : l10n.shareImageError,
          ),
          backgroundColor: gc.alert,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.shareImageError),
          backgroundColor: gc.alert,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: context.gc.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.gc.surfaceBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: context.gc.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // O FittedBox só ENCOLHE a moldura em telas estreitas; o
            // RepaintBoundary fica por dentro, no tamanho lógico cheio,
            // então a captura não depende do tamanho da tela. O ClipRRect
            // arredonda SÓ a pré-visualização: por estar acima do
            // RepaintBoundary, não entra no PNG capturado — que sai
            // retangular cheio, sem cantos transparentes.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: RepaintBoundary(
                    key: _previewKey,
                    child: widget.card,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Uma ação primária clara (compartilhar) e o salvar como ação
            // secundária discreta — sem dois botões de pesos diferentes
            // disputando a mesma linha.
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isBusy ? null : _share,
                icon: const Icon(Icons.share_outlined, size: 18),
                label: Text(l10n.shareImageShare),
              ),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: _isBusy ? null : _saveToGallery,
              icon: Icon(
                Icons.download_outlined,
                size: 18,
                color: context.gc.textSecondary,
              ),
              label: Text(
                kIsWeb ? l10n.shareImageDownload : l10n.shareImageSave,
                style: TextStyle(
                  color: context.gc.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
