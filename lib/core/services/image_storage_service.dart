import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config/supabase_config.dart';
import 'armazem_de_imagens.dart';
import 'debug_log_service.dart';

/// Guarda as fotos das usuárias no Supabase Storage.
///
/// O app sempre guardou a foto como caminho de arquivo local. Isso não existe
/// na web e, mesmo no celular, o caminho não faz sentido em outro aparelho —
/// por isso as fotos nunca sincronizaram. Aqui a foto vai para a nuvem e o
/// banco guarda uma REFERÊNCIA (`supabase://<caminho>`), não uma URL: o bucket
/// é privado e as URLs de exibição são assinadas e expiram.
///
/// O caminho começa SEMPRE pelo id da pessoa (`{uid}/{pasta}/{id}.jpg`): é
/// a primeira pasta que as políticas do bucket usam para isolar uma conta da
/// outra. A rede fica atrás de [ArmazemDeImagens], trocável em teste.
class ImageStorageService {
  ImageStorageService._();

  static final ImageStorageService instance = ImageStorageService._();

  /// Bucket privado criado no painel do Supabase.
  static const String bucketName = bucketDeImagens;

  /// Prefixo que marca uma referência do Storage no banco, distinguindo-a de
  /// caminho local (`/data/...`), URL (`https://...`) e asset do app.
  static const String scheme = 'supabase://';

  static const Duration _signedUrlTtl = Duration(hours: 1);

  final Map<String, _SignedUrl> _signedUrlCache = {};

  ArmazemDeImagens? _duble;
  ArmazemSupabase? _producao;

  /// O armazém de verdade só é criado com o Supabase configurado: sem isso,
  /// `Supabase.instance` nem existe e o serviço se declara indisponível.
  ArmazemDeImagens? get _armazem {
    if (_duble != null) return _duble;
    if (!SupabaseConfig.isConfigured) return null;
    return _producao ??= ArmazemSupabase(Supabase.instance.client);
  }

  /// Troca a borda de rede por um dublê (null volta à produção).
  @visibleForTesting
  void configurarParaTeste(ArmazemDeImagens? armazem) {
    _duble = armazem;
    _signedUrlCache.clear();
  }

  /// Id da pessoa logada segundo o armazém, ou null sem sessão.
  String? get currentUserId => _armazem?.usuarioAtual;

  /// Só é possível enviar com sessão: o caminho começa com o id da usuária,
  /// que é o que as políticas do bucket usam para isolar uma pessoa da outra.
  bool get isAvailable => currentUserId != null;

  static bool isRemote(String reference) => reference.startsWith(scheme);

  /// Caminho determinístico no bucket: `{uid}/{pasta}/{id}.jpg`.
  static String pathFor({
    required String userId,
    required String folder,
    required String id,
  }) =>
      '$userId/$folder/$id.jpg';

  static String referenceFor(String path) => '$scheme$path';

  static String pathOf(String reference) => reference.substring(scheme.length);

  /// Envia bytes JPEG e devolve a referência para guardar no banco.
  ///
  /// [folder] separa os usos (`avatar`, `herbs`, ...) dentro da pasta da
  /// usuária; [id] fixa o nome do arquivo (sem ele, um uuid novo).
  Future<String> uploadJpeg(
    Uint8List bytes, {
    required String folder,
    String? id,
  }) {
    final userId = currentUserId;
    if (userId == null) {
      throw StateError('É preciso estar logada para enviar imagens');
    }
    return uploadJpegAt(
      bytes,
      path: pathFor(userId: userId, folder: folder, id: id ?? const Uuid().v4()),
    );
  }

  /// Envia bytes JPEG num caminho já decidido. [upsert] por padrão: o caminho
  /// é determinístico, e reenviar (retry, migração) não pode dar 409.
  Future<String> uploadJpegAt(
    Uint8List bytes, {
    required String path,
    bool upsert = true,
  }) async {
    final armazem = _armazem;
    if (armazem == null || armazem.usuarioAtual == null) {
      throw StateError('É preciso estar logada para enviar imagens');
    }
    await armazem.enviar(path, bytes, upsert: upsert);
    final partes = path.split('/');
    final pasta = partes.length > 1 ? partes[1] : path;
    await debugLog('STORAGE', 'Imagem enviada: $pasta (${bytes.length} bytes)');
    return referenceFor(path);
  }

  /// Baixa os bytes de uma referência (para o espelho local do celular).
  Future<Uint8List> download(String reference) {
    final armazem = _armazem;
    if (armazem == null) {
      throw StateError('Storage indisponível: Supabase não configurado');
    }
    return armazem.baixar(pathOf(reference));
  }

  /// A URL assinada já em memória e ainda válida — ou null, se for preciso
  /// pedir uma (síncrono, para a tela não passar por um FutureBuilder à toa).
  String? signedUrlSync(String reference) {
    final cached = _signedUrlCache[pathOf(reference)];
    return cached != null && cached.isValid ? cached.url : null;
  }

  /// URL temporária para exibir a imagem. Guardada em memória enquanto vale,
  /// para não pedir uma nova assinatura a cada rebuild da tela.
  Future<String> signedUrl(String reference) async {
    final pronta = signedUrlSync(reference);
    if (pronta != null) return pronta;

    final armazem = _armazem;
    if (armazem == null) {
      throw StateError('Storage indisponível: Supabase não configurado');
    }
    final path = pathOf(reference);
    final url = await armazem.urlAssinada(path, _signedUrlTtl.inSeconds);
    _signedUrlCache[path] = _SignedUrl(url, DateTime.now().add(_signedUrlTtl));
    return url;
  }

  /// Remove a imagem do bucket. Falha não é fatal: a referência já saiu do
  /// banco, e um arquivo órfão é menos grave do que travar a tela da usuária.
  Future<void> delete(String reference) async {
    if (!isRemote(reference)) return;
    final path = pathOf(reference);
    try {
      await _armazem?.remover([path]);
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
