import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config/supabase_config.dart';
import 'debug_log_service.dart';

/// Guarda as fotos das usuárias no Supabase Storage.
///
/// O app sempre guardou a foto como caminho de arquivo local. Isso não existe
/// na web e, mesmo no celular, o caminho não faz sentido em outro aparelho —
/// por isso as fotos nunca sincronizaram. Aqui a foto vai para a nuvem e o
/// banco guarda uma REFERÊNCIA (`supabase://<caminho>`), não uma URL: o bucket
/// é privado e as URLs de exibição são assinadas e expiram.
class ImageStorageService {
  ImageStorageService._();

  static final ImageStorageService instance = ImageStorageService._();

  /// Bucket privado criado no painel do Supabase.
  static const String bucketName = 'user-images';

  /// Prefixo que marca uma referência do Storage no banco, distinguindo-a de
  /// caminho local (`/data/...`), URL (`https://...`) e asset do app.
  static const String scheme = 'supabase://';

  static const Duration _signedUrlTtl = Duration(hours: 1);

  final Map<String, _SignedUrl> _signedUrlCache = {};

  /// Só é possível enviar com sessão: o caminho começa com o id da usuária,
  /// que é o que as políticas do bucket usam para isolar uma pessoa da outra.
  bool get isAvailable =>
      SupabaseConfig.isConfigured &&
      Supabase.instance.client.auth.currentUser != null;

  static bool isRemote(String reference) => reference.startsWith(scheme);

  /// Envia bytes JPEG e devolve a referência para guardar no banco.
  ///
  /// [folder] separa os usos (`avatar`, `encyclopedia`, ...) dentro da pasta
  /// da usuária.
  Future<String> uploadJpeg(
    Uint8List bytes, {
    required String folder,
  }) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('É preciso estar logada para enviar imagens');
    }

    final path = '$userId/$folder/${const Uuid().v4()}.jpg';
    await client.storage.from(bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    await debugLog('STORAGE', 'Imagem enviada: $folder (${bytes.length} bytes)');
    return '$scheme$path';
  }

  /// URL temporária para exibir a imagem. Guardada em memória enquanto vale,
  /// para não pedir uma nova assinatura a cada rebuild da tela.
  Future<String> signedUrl(String reference) async {
    final path = reference.substring(scheme.length);

    final cached = _signedUrlCache[path];
    if (cached != null && cached.isValid) return cached.url;

    final url = await Supabase.instance.client.storage
        .from(bucketName)
        .createSignedUrl(path, _signedUrlTtl.inSeconds);
    _signedUrlCache[path] =
        _SignedUrl(url, DateTime.now().add(_signedUrlTtl));
    return url;
  }

  /// Remove a imagem do bucket. Falha não é fatal: a referência já saiu do
  /// banco, e um arquivo órfão é menos grave do que travar a tela da usuária.
  Future<void> delete(String reference) async {
    if (!isRemote(reference)) return;
    final path = reference.substring(scheme.length);
    try {
      await Supabase.instance.client.storage.from(bucketName).remove([path]);
      _signedUrlCache.remove(path);
    } catch (e) {
      await debugLog('STORAGE', 'Falha ao remover imagem: $e');
    }
  }
}

class _SignedUrl {
  final String url;
  final DateTime expiresAt;

  const _SignedUrl(this.url, this.expiresAt);

  /// Renova com folga: uma URL prestes a expirar quebraria a imagem na tela.
  bool get isValid =>
      DateTime.now().isBefore(expiresAt.subtract(const Duration(minutes: 5)));
}
