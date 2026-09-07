import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/services/user_image_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// O espelho local das fotos do Storage: a referência `supabase://…` vira
/// um arquivo determinístico, e dez cards da mesma foto disparam UM download.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const ref = 'supabase://u1/herbs/x.jpg';
  final cache = UserImageCache.instance;
  late Directory dir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('grimorio_espelho');
    cache.usarDiretorio(dir);
  });

  tearDown(() async {
    cache.usarDiretorio(null);
    await dir.delete(recursive: true);
  });

  test('a referência vira um arquivo dentro da pasta do espelho', () {
    expect(cache.pronto, isTrue);
    expect(cache.arquivoPara(ref)!.path, '${dir.path}/u1/herbs/x.jpg');
    // Só referências do Storage têm espelho.
    expect(cache.arquivoPara('/data/user/0/foto.jpg'), isNull);
    expect(cache.arquivoPara('https://x/y.jpg'), isNull);
    expect(cache.arquivoPara('assets/images/herbs/alecrim.png'), isNull);
  });

  test('desligado (antes de preparar) não responde nada nem quebra', () async {
    cache.usarDiretorio(null);
    expect(cache.pronto, isFalse);
    expect(cache.arquivoPara(ref), isNull);
    expect(cache.existeSync(ref), isFalse);
    expect(await cache.gravar(ref, Uint8List.fromList([1])), isNull);
    expect(await cache.baixarSeFaltar(ref, () async => Uint8List(1)), isNull);
    await cache.apagar(ref);
  });

  test('gravar cria as pastas, existeSync enxerga e apagar some', () async {
    expect(cache.existeSync(ref), isFalse);
    final arquivo = await cache.gravar(ref, Uint8List.fromList([7, 8, 9]));
    expect(arquivo, isNotNull);
    expect(cache.existeSync(ref), isTrue);
    expect(await arquivo!.readAsBytes(), [7, 8, 9]);

    await cache.apagar(ref);
    expect(cache.existeSync(ref), isFalse);
    // Apagar o que já não existe é silencioso.
    await cache.apagar(ref);
  });

  test('baixarSeFaltar baixa UMA vez para chamadas concorrentes', () async {
    var downloads = 0;
    Future<Uint8List> baixar() async {
      downloads++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return Uint8List.fromList([1, 2, 3]);
    }

    final arquivos = await Future.wait([
      cache.baixarSeFaltar(ref, baixar),
      cache.baixarSeFaltar(ref, baixar),
      cache.baixarSeFaltar(ref, baixar),
    ]);
    expect(downloads, 1);
    expect(arquivos.every((f) => f != null), isTrue);
    expect(await arquivos.first!.readAsBytes(), [1, 2, 3]);

    // Já no disco: nem passa pelo download.
    final deNovo = await cache.baixarSeFaltar(ref, baixar);
    expect(deNovo, isNotNull);
    expect(downloads, 1);
  });

  test('download que falha devolve null e não deixa arquivo pela metade',
      () async {
    final arquivo = await cache.baixarSeFaltar(
      ref,
      () async => throw Exception('sem rede'),
    );
    expect(arquivo, isNull);
    expect(cache.existeSync(ref), isFalse);

    // E a próxima tentativa tenta de novo (o "em voo" foi liberado).
    final depois = await cache.baixarSeFaltar(
      ref,
      () async => Uint8List.fromList([4]),
    );
    expect(depois, isNotNull);
    expect(cache.existeSync(ref), isTrue);
  });
}
