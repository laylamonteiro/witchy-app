import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:grimorio_de_bolso/core/services/image_storage_service.dart';
import 'package:grimorio_de_bolso/core/services/user_image_cache.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/models/user_entry_model.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/repositories/user_encyclopedia_repository.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/services/user_photo_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dubles/armazem_de_mentira.dart';
import 'dubles/servidor_de_mentira.dart';

/// As fotos que ficaram como arquivo local (antigas, ou sem rede na hora)
/// sobem para o bucket e a linha ganha a referência — com `updated_at` novo
/// e `synced = 0`, senão a varredura do sync reverteria a troca no empate.
/// Banco sqlite de verdade, servidor de sync e Storage de mentira.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tabela = 'user_encyclopedia_entries';
  const uid = '11111111-2222-3333-4444-555555555555';
  const outra = '99999999-8888-7777-6666-555555555555';

  final sync = DataSyncService();
  late Directory raiz;
  late Directory espelho;
  late Directory docs;
  late ArmazemDeMentira armazem;
  late ServidorDeMentira servidor;
  late UserEncyclopediaRepository repo;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Pasta própria: `flutter test` roda arquivos em paralelo e dois deles
    // no mesmo grimorio_de_bolso.db disputariam o arquivo.
    final dbDir = await Directory.systemTemp.createTemp('grimorio_fotos_db');
    await databaseFactory.setDatabasesPath(dbDir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    raiz = await Directory.systemTemp.createTemp('grimorio_fotos_pend');
    espelho = Directory('${raiz.path}/espelho')..createSync();
    docs = Directory('${raiz.path}/docs')..createSync();
    armazem = ArmazemDeMentira()..usuarioAtual = uid;
    ImageStorageService.instance.configurarParaTeste(armazem);
    UserImageCache.instance.usarDiretorio(espelho);
    servidor = ServidorDeMentira();
    sync.configurarParaTeste(servidor, uid);
    repo = UserEncyclopediaRepository(
      photos: UserPhotoStore(
        pastaLocal: () async => docs,
        nuvemLigada: () async => true,
      ),
      syncService: sync,
    );
    final db = await DatabaseHelper.instance.database;
    await db.delete(tabela);
    await db.delete('sync_tombstones');
  });

  tearDown(() async {
    ImageStorageService.instance.configurarParaTeste(null);
    UserImageCache.instance.usarDiretorio(null);
    await raiz.delete(recursive: true);
  });

  Future<File> fotoLocal(String nome) async {
    final f = File('${docs.path}/$nome.jpg');
    await f.writeAsBytes([1, 2, 3]);
    return f;
  }

  Future<void> semear({
    required String id,
    String userId = uid,
    String? imagePath,
    int quando = 1000,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(tabela, {
      'id': id,
      'user_id': userId,
      'category': 'herb',
      'name': 'Alecrim',
      'image_path': imagePath,
      'data': '{"name":"Alecrim"}',
      'created_at': quando,
      'updated_at': quando,
      'synced': 1,
    });
  }

  Future<Map<String, dynamic>> linha(String id) async {
    final db = await DatabaseHelper.instance.database;
    return (await db.query(tabela, where: 'id = ?', whereArgs: [id])).single;
  }

  test('sobe só a foto local que existe; deixa as demais em paz', () async {
    final foto = await fotoLocal('antiga');
    await semear(id: 'local-ok', imagePath: foto.path);
    await semear(id: 'local-sumida', imagePath: '${docs.path}/nao-existe.jpg');
    await semear(
      id: 'ja-remota',
      imagePath: 'supabase://$uid/herbs/ja-remota.jpg',
    );
    await semear(id: 'sem-foto');
    await semear(id: 'de-outra', userId: outra, imagePath: foto.path);

    expect(await repo.uploadPendingPhotos(uid), 1);

    const ref = 'supabase://$uid/herbs/local-ok.jpg';
    final ok = await linha('local-ok');
    expect(ok['image_path'], ref);
    expect(ok['updated_at'] as int, greaterThan(1000),
        reason: 'sem carimbo novo o sync reverteria a troca no empate');
    expect(ok['synced'], 1, reason: 'o syncItem subiu a linha e carimbou');
    expect(armazem.objetos.keys, ['$uid/herbs/local-ok.jpg']);
    expect(servidor.linhasDe(tabela).single['image_path'], ref);
    expect(UserImageCache.instance.existeSync(ref), isTrue);
    expect(foto.existsSync(), isFalse, reason: 'virou espelho, não dobra');

    expect((await linha('local-sumida'))['image_path'],
        '${docs.path}/nao-existe.jpg');
    expect((await linha('ja-remota'))['updated_at'], 1000);
    expect((await linha('sem-foto'))['image_path'], isNull);
    expect((await linha('de-outra'))['image_path'], foto.path);

    // Segunda rodada: não há mais nada pendente.
    expect(await repo.uploadPendingPhotos(uid), 0);
  });

  test('servidor de sync fora do ar: a foto sobe e a linha fica synced = 0',
      () async {
    final foto = await fotoLocal('sem-servidor');
    await semear(id: 'pendente', imagePath: foto.path);
    servidor.foraDoAr = true;

    expect(await repo.uploadPendingPhotos(uid), 1);

    final l = await linha('pendente');
    expect(l['image_path'], 'supabase://$uid/herbs/pendente.jpg');
    expect(l['synced'], 0, reason: 'a varredura seguinte sobe a linha');
    expect(armazem.objetos.keys, ['$uid/herbs/pendente.jpg']);
  });

  test('sem sessão desta conta, nada acontece', () async {
    final foto = await fotoLocal('parada');
    await semear(id: 'parada', imagePath: foto.path);
    armazem.usuarioAtual = null;

    expect(await repo.uploadPendingPhotos(uid), 0);
    expect((await linha('parada'))['image_path'], foto.path);
    expect(foto.existsSync(), isTrue);
  });

  test('create grava a referência; delete tira do bucket e do espelho',
      () async {
    final entry = await repo.create(
      userId: uid,
      category: UserEntryCategory.crystal,
      name: 'Ametista',
      photo: Uint8List.fromList([9, 9, 9]),
      data: {'name': 'Ametista'},
    );
    final ref = 'supabase://$uid/crystals/${entry.id}.jpg';
    expect(entry.imagePath, ref);
    expect(armazem.objetos.containsKey('$uid/crystals/${entry.id}.jpg'), isTrue);
    expect(UserImageCache.instance.existeSync(ref), isTrue);
    expect((await linha(entry.id))['image_path'], ref);

    await repo.delete(entry);
    expect(armazem.objetos, isEmpty);
    expect(UserImageCache.instance.existeSync(ref), isFalse);
    final db = await DatabaseHelper.instance.database;
    expect(await db.query(tabela, where: 'id = ?', whereArgs: [entry.id]),
        isEmpty);
  });

  test('create sem sessão: a foto fica local e o verbete nasce mesmo assim',
      () async {
    armazem.usuarioAtual = null;
    final entry = await repo.create(
      userId: uid,
      category: UserEntryCategory.herb,
      name: 'Arruda',
      photo: Uint8List.fromList([5]),
      data: {'name': 'Arruda'},
    );
    expect(entry.imagePath, startsWith(docs.path));
    expect(armazem.objetos, isEmpty);
  });
}
