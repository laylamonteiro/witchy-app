import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Bucket privado das fotos das usuárias. Criado no painel do Supabase; o
/// SQL documental (bucket + políticas por pasta da conta) está em
/// `supabase/storage_user_images_migration.sql`.
const String bucketDeImagens = 'user-images';

/// A borda de rede do Storage — o mesmo racional do ServidorDeSync: o
/// ImageStorageService e o UserPhotoStore decidem O QUE sobe, cai no
/// cache ou se apaga; esta porta só executa a chamada. Assim a decisão roda
/// em teste com um armazém de mentira do outro lado, sem Supabase.
abstract class ArmazemDeImagens {
  /// Id da pessoa logada (a primeira pasta de todo caminho) ou null.
  String? get usuarioAtual;

  /// Sobe bytes JPEG em [path]. [upsert] regrava se já existir — é o que
  /// permite reenviar a mesma foto (caminho determinístico) sem erro 409.
  Future<void> enviar(String path, Uint8List bytes, {bool upsert = false});

  Future<Uint8List> baixar(String path);

  Future<String> urlAssinada(String path, int validadeSegundos);

  Future<void> remover(List<String> paths);
}

/// A implementação de produção sobre o cliente do Supabase.
class ArmazemSupabase implements ArmazemDeImagens {
  ArmazemSupabase(this._client);

  final SupabaseClient _client;

  StorageFileApi get _bucket => _client.storage.from(bucketDeImagens);

  @override
  String? get usuarioAtual => _client.auth.currentUser?.id;

  @override
  Future<void> enviar(String path, Uint8List bytes, {bool upsert = false}) =>
      _bucket.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: 'image/jpeg', upsert: upsert),
      );

  @override
  Future<Uint8List> baixar(String path) => _bucket.download(path);

  @override
  Future<String> urlAssinada(String path, int validadeSegundos) =>
      _bucket.createSignedUrl(path, validadeSegundos);

  @override
  Future<void> remover(List<String> paths) => _bucket.remove(paths);
}
