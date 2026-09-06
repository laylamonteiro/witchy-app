import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:path_provider/path_provider.dart';

import 'debug_log_service.dart';
import 'image_storage_service.dart';

/// Espelho local (só celular) das fotos que vivem no Supabase Storage.
///
/// A referência `supabase://{uid}/{pasta}/{id}.jpg` vira o arquivo
/// `<suporte do app>/user-images/{uid}/{pasta}/{id}.jpg`. Quem cria a foto
/// grava aqui na hora (aparece sem rede e sem esperar URL assinada); quem
/// recebe a foto pelo sync baixa uma vez e guarda. Na web não há filesystem:
/// tudo aqui é no-op e a tela usa a URL assinada.
class UserImageCache {
  UserImageCache._();

  static final UserImageCache instance = UserImageCache._();

  Directory? _dir;

  /// Downloads em voo por referência: dez cards da mesma foto numa lista
  /// disparam UM download, não dez.
  final Map<String, Future<File?>> _emVoo = {};

  /// Resolve a pasta uma vez (no boot). Depois disso [arquivoPara] é
  /// síncrono, e a tela decide sem FutureBuilder se a foto já está aqui.
  Future<void> preparar() async {
    if (kIsWeb || _dir != null) return;
    try {
      final base = await getApplicationSupportDirectory();
      _dir = Directory('${base.path}/user-images');
    } catch (e) {
      await debugLog('STORAGE', 'Espelho local indisponível: $e');
    }
  }

  /// Teste: aponta o espelho para uma pasta temporária (null desliga).
  @visibleForTesting
  void usarDiretorio(Directory? dir) {
    _dir = dir;
    _emVoo.clear();
  }

  bool get pronto => !kIsWeb && _dir != null;

  /// O arquivo que espelha [reference] — exista ele ou não. Null na web,
  /// antes de [preparar] ou para o que não é referência do Storage.
  File? arquivoPara(String reference) {
    final dir = _dir;
    if (kIsWeb || dir == null || !ImageStorageService.isRemote(reference)) {
      return null;
    }
    return File('${dir.path}/${ImageStorageService.pathOf(reference)}');
  }

  bool existeSync(String reference) =>
      arquivoPara(reference)?.existsSync() ?? false;

  Future<File?> gravar(String reference, Uint8List bytes) async {
    final arquivo = arquivoPara(reference);
    if (arquivo == null) return null;
    try {
      await arquivo.parent.create(recursive: true);
      await arquivo.writeAsBytes(bytes, flush: true);
      return arquivo;
    } catch (e) {
      await debugLog('STORAGE', 'Falha ao espelhar imagem: $e');
      return null;
    }
  }

  Future<void> apagar(String reference) async {
    final arquivo = arquivoPara(reference);
    if (arquivo == null) return;
    try {
      if (await arquivo.exists()) await arquivo.delete();
    } catch (_) {
      // Espelho órfão não é grave; a referência já saiu do banco.
    }
  }

  /// O arquivo do espelho, baixando com [baixar] se ainda não existir.
  /// Null quando o espelho está desligado ou o download falhou (a tela cai
  /// para a URL assinada).
  Future<File?> baixarSeFaltar(
    String reference,
    Future<Uint8List> Function() baixar,
  ) {
    final arquivo = arquivoPara(reference);
    if (arquivo == null) return Future.value(null);
    if (arquivo.existsSync()) return Future.value(arquivo);
    return _emVoo.putIfAbsent(reference, () async {
      try {
        return await gravar(reference, await baixar());
      } catch (e) {
        await debugLog('STORAGE', 'Falha ao baixar imagem: $e');
        return null;
      } finally {
        _emVoo.remove(reference);
      }
    });
  }
}
