import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/data_sync_service.dart';
import '../../../../core/services/debug_log_service.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../../../core/services/user_image_cache.dart';
import '../models/user_entry_model.dart';

/// Onde a foto de um verbete pessoal vive — e a decisão de para onde ela vai.
///
/// Com conta, sessão e sincronização ligada, a foto sobe para o bucket
/// privado no caminho determinístico `{uid}/{herbs|crystals}/{id}.jpg` e o
/// banco guarda a referência `supabase://…` (que sincroniza; o outro aparelho
/// baixa pela referência). Uma cópia fica no espelho local do celular, para
/// abrir sem rede. Sem conta (`local_user`), sem sessão, com a sincronização
/// desligada ou sem rede, o celular guarda um arquivo local — e
/// [subirArquivoLocal] leva esse arquivo para o bucket depois, quando der.
class UserPhotoStore {
  UserPhotoStore({
    ImageStorageService? storage,
    UserImageCache? cache,
    Future<Directory> Function()? pastaLocal,
    Future<bool> Function()? nuvemLigada,
  })  : _storage = storage ?? ImageStorageService.instance,
        _cache = cache ?? UserImageCache.instance,
        _pastaLocal = pastaLocal ?? getApplicationDocumentsDirectory,
        _nuvemLigada = nuvemLigada ?? _sincronizacaoLigada;

  static const String guestUserId = 'local_user';

  final ImageStorageService _storage;
  final UserImageCache _cache;
  final Future<Directory> Function() _pastaLocal;
  final Future<bool> Function() _nuvemLigada;

  static Future<bool> _sincronizacaoLigada() =>
      DataSyncService().cloudSyncEnabled;

  /// A referência que a foto de [entryId] tem (ou terá) no bucket.
  static String referenciaPara({
    required String userId,
    required UserEntryCategory category,
    required String entryId,
  }) =>
      ImageStorageService.referenceFor(
        ImageStorageService.pathFor(
          userId: userId,
          folder: category.pastaNoStorage,
          id: entryId,
        ),
      );

  /// Caminho de arquivo do aparelho (foto antiga ou guardada sem nuvem).
  static bool ehArquivoLocal(String? path) =>
      path != null && (path.startsWith('/') || path.startsWith('file:'));

  /// A foto desta pessoa pode subir agora? Convidada não tem pasta no bucket;
  /// a sessão precisa ser DELA (o uid da linha é o da política); e quem
  /// desligou a sincronização não quer nada seu na nuvem — foto inclusa.
  Future<bool> podeSubir(String userId) async {
    if (userId == guestUserId) return false;
    if (_storage.currentUserId != userId) return false;
    return _nuvemLigada();
  }

  /// Guarda a foto comprimida de um verbete novo e devolve o que gravar em
  /// `image_path`: a referência do bucket, um caminho local (celular sem
  /// nuvem ou sem rede) ou null (web sem sessão — não há onde guardar).
  Future<String?> guardar({
    required String userId,
    required UserEntryCategory category,
    required String entryId,
    required Uint8List jpeg,
  }) async {
    if (await podeSubir(userId)) {
      final referencia = referenciaPara(
        userId: userId,
        category: category,
        entryId: entryId,
      );
      try {
        await _storage.uploadJpegAt(
          jpeg,
          path: ImageStorageService.pathOf(referencia),
        );
        await _cache.gravar(referencia, jpeg);
        return referencia;
      } catch (e) {
        // Sem rede (ou bucket fora do ar): no celular a foto fica local e
        // sobe depois; na web não há esse depois — a pessoa vê o erro e
        // tenta de novo.
        await debugLog('STORAGE', 'Foto do verbete não subiu agora: $e');
        if (kIsWeb) rethrow;
      }
    }
    return _gravarLocal(entryId, jpeg);
  }

  Future<String?> _gravarLocal(String entryId, Uint8List jpeg) async {
    if (kIsWeb) return null;
    final dir = await _pastaLocal();
    final file = File('${dir.path}/encyclopedia_$entryId.jpg');
    await file.writeAsBytes(jpeg, flush: true);
    return file.path;
  }

  /// Leva um arquivo local para o bucket (retry de quando não deu, ou
  /// migração das fotos antigas do celular). Devolve a referência nova, ou
  /// null se não foi possível agora (sem sessão/nuvem, arquivo sumido).
  Future<String?> subirArquivoLocal({
    required String userId,
    required UserEntryCategory category,
    required String entryId,
    required String localPath,
  }) async {
    if (kIsWeb) return null;
    final file = File(localPath.replaceFirst('file://', ''));
    if (!await file.exists()) return null;
    if (!await podeSubir(userId)) return null;

    final bytes = await file.readAsBytes();
    final referencia = referenciaPara(
      userId: userId,
      category: category,
      entryId: entryId,
    );
    await _storage.uploadJpegAt(
      bytes,
      path: ImageStorageService.pathOf(referencia),
    );
    await _cache.gravar(referencia, bytes);
    try {
      await file.delete();
    } catch (_) {
      // O espelho já tem a cópia; o arquivo antigo é só lixo.
    }
    return referencia;
  }

  /// Apaga a foto de um verbete removido: do bucket e do espelho, ou o
  /// arquivo local. Nunca lança — a exclusão do verbete já aconteceu.
  Future<void> apagar(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    if (ImageStorageService.isRemote(imagePath)) {
      await _storage.delete(imagePath);
      await _cache.apagar(imagePath);
      return;
    }
    if (!ehArquivoLocal(imagePath) || kIsWeb) return;
    try {
      final file = File(imagePath.replaceFirst('file://', ''));
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Foto órfã não deve impedir a exclusão do registro.
    }
  }
}
