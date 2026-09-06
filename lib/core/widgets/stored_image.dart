import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../services/image_storage_service.dart';
import '../services/user_image_cache.dart';

/// Exibe uma foto da usuária venha ela de onde vier.
///
/// O app acumulou quatro origens ao longo do tempo, e todas continuam válidas:
/// - `supabase://...` — Supabase Storage (padrão, em toda plataforma;
///   sincroniza entre aparelhos). No celular vem do espelho local
///   ([UserImageCache]) — sem rede e sem piscar; na web, de uma URL assinada.
/// - `http(s)://...` — URL direta (fotos de perfil vindas do login social).
/// - `/data/...` — arquivo local, só no celular (fotos antigas, ou salvas sem
///   sessão/sem sincronização; na web não há como abri-las).
/// - qualquer outra coisa — asset do próprio app.
class StoredImage extends StatefulWidget {
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

  @override
  State<StoredImage> createState() => _StoredImageState();
}

class _StoredImageState extends State<StoredImage> {
  /// Resolução da referência remota, criada UMA vez por referência. Um
  /// Future novo a cada rebuild reiniciava o FutureBuilder — e a lista
  /// piscava o placeholder a cada rolagem.
  Future<_FotoResolvida?>? _resolucao;

  @override
  void didUpdateWidget(StoredImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reference != widget.reference) _resolucao = null;
  }

  Widget _placeholder(BuildContext context) =>
      widget.placeholderBuilder?.call(context) ??
      SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Icon(Icons.image_not_supported_outlined),
      );

  Widget _aguardando() => SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final reference = widget.reference;
    if (ImageStorageService.isRemote(reference)) {
      return _remota(context, reference);
    }

    if (reference.startsWith('http')) return _network(context, reference);

    final isLocalFile =
        reference.startsWith('/') || reference.startsWith('file:');
    if (isLocalFile) {
      // Na web não há filesystem — mostra o placeholder em vez de derrubar
      // a tela.
      if (kIsWeb) return _placeholder(context);
      return _arquivo(context, File(reference.replaceFirst('file://', '')));
    }

    return Image.asset(
      reference,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true,
      errorBuilder: (context, _, __) => _placeholder(context),
    );
  }

  Widget _remota(BuildContext context, String reference) {
    final cache = UserImageCache.instance;
    // 1) Espelho local (celular): direto do disco, sem rede e sem piscar.
    final local = cache.arquivoPara(reference);
    if (local != null && local.existsSync()) return _arquivo(context, local);

    // 2) Sem espelho (web): a URL assinada ainda válida em memória é
    //    síncrona — a lista rebuilda sem passar pelo spinner.
    if (!cache.pronto) {
      final url = ImageStorageService.instance.signedUrlSync(reference);
      if (url != null) return _network(context, url);
    }

    // 3) Resolve uma vez: baixa para o espelho (celular) ou assina (web).
    _resolucao ??= _resolver(reference);
    return FutureBuilder<_FotoResolvida?>(
      future: _resolucao,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _placeholder(context);
        if (snapshot.connectionState != ConnectionState.done) {
          return _aguardando();
        }
        final foto = snapshot.data;
        if (foto == null) return _placeholder(context);
        final arquivo = foto.arquivo;
        if (arquivo != null) return _arquivo(context, arquivo);
        final url = foto.url;
        if (url != null) return _network(context, url);
        return _placeholder(context);
      },
    );
  }

  Future<_FotoResolvida?> _resolver(String reference) async {
    final storage = ImageStorageService.instance;
    final cache = UserImageCache.instance;
    if (cache.pronto) {
      final arquivo = await cache.baixarSeFaltar(
        reference,
        () => storage.download(reference),
      );
      if (arquivo != null) return _FotoResolvida(arquivo: arquivo);
    }
    return _FotoResolvida(url: await storage.signedUrl(reference));
  }

  Widget _arquivo(BuildContext context, File file) => Image.file(
        file,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (context, _, __) => _placeholder(context),
      );

  Widget _network(BuildContext context, String url) => Image.network(
        url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (context, _, __) => _placeholder(context),
      );
}

/// Onde a foto remota acabou: no espelho local ou numa URL assinada.
class _FotoResolvida {
  final File? arquivo;
  final String? url;

  const _FotoResolvida({this.arquivo, this.url});
}
