import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/services/image_storage_service.dart';
import 'package:grimorio_de_bolso/core/services/user_image_cache.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/models/user_entry_model.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/services/user_photo_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dubles/armazem_de_mentira.dart';

/// Para onde vai a foto de um verbete: bucket (com conta + sincronização),
/// arquivo local (sem isso, ou sem rede) — e o caminho de volta, quando o
/// arquivo local finalmente sobe.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = 'uid-1';
  final bytes = Uint8List.fromList(List<int>.generate(64, (i) => i));

  late Directory raiz;
  late Directory espelho;
  late Directory docs;
  late ArmazemDeMentira armazem;
  late UserPhotoStore store;
  var nuvemLigada = true;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    raiz = await Directory.systemTemp.createTemp('grimorio_fotos');
    espelho = Directory('${raiz.path}/espelho')..createSync();
    docs = Directory('${raiz.path}/docs')..createSync();
    armazem = ArmazemDeMentira()..usuarioAtual = uid;
    ImageStorageService.instance.configurarParaTeste(armazem);
    UserImageCache.instance.usarDiretorio(espelho);
    nuvemLigada = true;
    store = UserPhotoStore(
      pastaLocal: () async => docs,
      nuvemLigada: () async => nuvemLigada,
    );
  });

  tearDown(() async {
    ImageStorageService.instance.configurarParaTeste(null);
    UserImageCache.instance.usarDiretorio(null);
    await raiz.delete(recursive: true);
  });

  Future<String?> guardar({
    String userId = uid,
    UserEntryCategory category = UserEntryCategory.herb,
    String entryId = 'e1',
  }) =>
      store.guardar(
        userId: userId,
        category: category,
        entryId: entryId,
        jpeg: bytes,
      );

  test('a referência é determinística: {uid}/{pasta}/{id}.jpg', () {
    expect(
      UserPhotoStore.referenciaPara(
        userId: uid,
        category: UserEntryCategory.crystal,
        entryId: 'abc',
      ),
      'supabase://uid-1/crystals/abc.jpg',
    );
    expect(UserPhotoStore.ehArquivoLocal('/data/user/0/x.jpg'), isTrue);
    expect(UserPhotoStore.ehArquivoLocal('file:///tmp/x.jpg'), isTrue);
    expect(UserPhotoStore.ehArquivoLocal('supabase://u/herbs/x.jpg'), isFalse);
    expect(UserPhotoStore.ehArquivoLocal(null), isFalse);
  });

  test('logada com sincronização: sobe, espelha e devolve a referência',
      () async {
    final ref = await guardar();
    expect(ref, 'supabase://uid-1/herbs/e1.jpg');
    expect(armazem.objetos.keys, ['uid-1/herbs/e1.jpg']);
    expect(armazem.objetos['uid-1/herbs/e1.jpg'], bytes);
    expect(UserImageCache.instance.existeSync(ref!), isTrue);
    expect(docs.listSync(), isEmpty, reason: 'nada fica solto em Documents');
  });

  test('cristal vai para a pasta crystals', () async {
    final ref = await guardar(category: UserEntryCategory.crystal);
    expect(ref, 'supabase://uid-1/crystals/e1.jpg');
  });

  test('convidada (local_user): arquivo local, nada sobe', () async {
    final caminho = await guardar(userId: UserPhotoStore.guestUserId);
    expect(caminho, startsWith(docs.path));
    expect(File(caminho!).existsSync(), isTrue);
    expect(armazem.objetos, isEmpty);
  });

  test('sessão de OUTRA conta: fica local (a pasta do bucket não é dela)',
      () async {
    armazem.usuarioAtual = 'outra-pessoa';
    final caminho = await guardar();
    expect(caminho, startsWith(docs.path));
    expect(armazem.objetos, isEmpty);
  });

  test('sincronização desligada: fica local', () async {
    nuvemLigada = false;
    final caminho = await guardar();
    expect(caminho, startsWith(docs.path));
    expect(armazem.objetos, isEmpty);
  });

  test('sem rede: fica local — e sobe depois por subirArquivoLocal', () async {
    armazem.foraDoAr = true;
    final caminho = await guardar();
    expect(caminho, startsWith(docs.path));
    expect(armazem.objetos, isEmpty);

    armazem.foraDoAr = false;
    final ref = await store.subirArquivoLocal(
      userId: uid,
      category: UserEntryCategory.herb,
      entryId: 'e1',
      localPath: caminho!,
    );
    expect(ref, 'supabase://uid-1/herbs/e1.jpg');
    expect(armazem.objetos['uid-1/herbs/e1.jpg'], bytes);
    expect(UserImageCache.instance.existeSync(ref!), isTrue);
    expect(File(caminho).existsSync(), isFalse,
        reason: 'o arquivo antigo vira espelho; não fica em dobro');
  });

  test('subirArquivoLocal: arquivo sumido ou sem sessão → null', () async {
    expect(
      await store.subirArquivoLocal(
        userId: uid,
        category: UserEntryCategory.herb,
        entryId: 'e1',
        localPath: '${docs.path}/nao-existe.jpg',
      ),
      isNull,
    );

    final foto = File('${docs.path}/antiga.jpg')..writeAsBytesSync(bytes);
    armazem.usuarioAtual = null;
    expect(
      await store.subirArquivoLocal(
        userId: uid,
        category: UserEntryCategory.herb,
        entryId: 'e1',
        localPath: foto.path,
      ),
      isNull,
    );
    expect(foto.existsSync(), isTrue, reason: 'sem subir, não se apaga');
  });

  test('reenviar a mesma referência não dá 409 (upsert)', () async {
    await guardar();
    final foto = File('${docs.path}/de-novo.jpg')..writeAsBytesSync([1, 1]);
    final ref = await store.subirArquivoLocal(
      userId: uid,
      category: UserEntryCategory.herb,
      entryId: 'e1',
      localPath: foto.path,
    );
    expect(ref, 'supabase://uid-1/herbs/e1.jpg');
    expect(armazem.objetos['uid-1/herbs/e1.jpg'], [1, 1]);
  });

  test('apagar: remota some do bucket e do espelho; local some do disco',
      () async {
    final ref = await guardar();
    await store.apagar(ref);
    expect(armazem.objetos, isEmpty);
    expect(UserImageCache.instance.existeSync(ref!), isFalse);

    final caminho = await guardar(userId: UserPhotoStore.guestUserId);
    await store.apagar(caminho);
    expect(File(caminho!).existsSync(), isFalse);

    // Nada disto lança.
    await store.apagar(null);
    await store.apagar('');
    await store.apagar('https://fora.do/escopo.jpg');
  });
}
