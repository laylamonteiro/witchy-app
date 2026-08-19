import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../services/image_storage_service.dart';

/// Exibe uma foto da usuária venha ela de onde vier.
///
/// O app acumulou quatro origens ao longo do tempo, e todas continuam válidas:
/// - `supabase://...` — Supabase Storage (padrão novo, sincroniza entre
///   aparelhos); resolvida para uma URL assinada na hora de exibir.
/// - `http(s)://...` — URL direta (fotos de perfil vindas do login social).
/// - `/data/...` — arquivo local, só no celular (fotos antigas, salvas antes
///   do Storage; na web não há como abri-las).
/// - qualquer outra coisa — asset do próprio app.
class StoredImage extends StatelessWidget {
  final String reference;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Exibido enquanto a URL assinada é obtida e quando a imagem não pode ser
  /// carregada (arquivo local ausente, foto de outro aparelho, etc.).
  final Widget Function(BuildContext context)? placeholderBuilder;

  const StoredImage({
    super.key,
    required this.reference,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderBuilder,
  });

  Widget _placeholder(BuildContext context) =>
      placeholderBuilder?.call(context) ??
      SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.image_not_supported_outlined),
      );

  @override
  Widget build(BuildContext context) {
    if (ImageStorageService.isRemote(reference)) {
      return FutureBuilder<String>(
        future: ImageStorageService.instance.signedUrl(reference),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _placeholder(context);
          final url = snapshot.data;
          if (url == null) {
            return SizedBox(
              width: width,
              height: height,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return _network(context, url);
        },
      );
    }

    if (reference.startsWith('http')) return _network(context, reference);

    final isLocalFile =
        reference.startsWith('/') || reference.startsWith('file:');
    if (isLocalFile) {
      // Fotos antigas, salvas no aparelho antes do Storage. Na web não há
      // filesystem — mostra o placeholder em vez de derrubar a tela.
      if (kIsWeb) return _placeholder(context);
      return Image.file(
        File(reference.replaceFirst('file://', '')),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, _, __) => _placeholder(context),
      );
    }

    return Image.asset(
      reference,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, _, __) => _placeholder(context),
    );
  }

  Widget _network(BuildContext context, String url) => Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, _, __) => _placeholder(context),
      );
}
