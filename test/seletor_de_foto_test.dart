import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/images/etapa_da_foto.dart';
import 'package:grimorio_de_bolso/core/images/seletor_de_foto.dart';
import 'package:grimorio_de_bolso/core/utils/reducao_de_imagem.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

// O pedido: um caminho só para toda foto guardada — pegar, converter,
// recortar em quadrado, reduzir a JPEG. Os quatro passos são dublês aqui;
// o que se prova é a ordem, as etapas anunciadas à tela e o que acontece
// quando a pessoa desiste ou a foto não abre.
void main() {
  late Directory pasta;
  late File recorte;
  final jpegDoRecorte = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]);

  setUpAll(() async {
    pasta = await Directory.systemTemp.createTemp('seletor_de_foto_');
    recorte = File('${pasta.path}/recorte.jpg')
      ..writeAsBytesSync(jpegDoRecorte);
  });

  tearDownAll(() => pasta.delete(recursive: true));

  Future<BuildContext> contexto(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Placeholder(),
      ),
    );
    return tester.element(find.byType(Placeholder));
  }

  /// Um seletor com os quatro passos de mentira, cada um anotando que rodou.
  ({SeletorDeFoto seletor, List<String> chamadas}) montar({
    bool desisteNoSeletor = false,
    String? recortado = 'RECORTE',
    Uint8List? reduzida,
    bool conversaoFalha = false,
  }) {
    final chamadas = <String>[];
    // Um XFile só de nome e tipo, sem arquivo por trás.
    final escolhida = desisteNoSeletor
        ? null
        : XFile.fromData(
            Uint8List(0),
            name: 'foto.heic',
            mimeType: 'image/heic',
          );
    final seletor = SeletorDeFoto(
      pegar: (origem, {ladoMaximo}) async {
        chamadas.add('pegar:${origem.name}:${ladoMaximo ?? 'original'}');
        return escolhida;
      },
      preparar: (foto, relatar) async {
        chamadas.add('preparar');
        if (conversaoFalha) throw const FotoNaoSuportadaException('HEIC');
        return 'FONTE';
      },
      recortar: (context, fonte, l10n) async {
        chamadas.add('recortar:$fonte');
        return recortado == 'RECORTE' ? recorte.path : recortado;
      },
      reduzir: (arquivo, ladoMaximo) async {
        chamadas.add('reduzir:$ladoMaximo');
        return reduzida;
      },
    );
    return (seletor: seletor, chamadas: chamadas);
  }

  // Todo `escolher` roda em `runAsync`: o último passo lê um arquivo de
  // verdade, e dentro do testWidgets (FakeAsync) I/O real nunca completa —
  // a suíte inteira ficaria pendurada.
  testWidgets('a jornada inteira, na ordem, anunciando cada etapa',
      (tester) async {
    final etapas = <EtapaDaFoto>[];
    final saida = Uint8List.fromList([9, 9, 9]);
    final m = montar(reduzida: saida);
    final ctx = await contexto(tester);

    final bytes = await tester.runAsync(
      () => m.seletor.escolher(
        ctx,
        origem: ImageSource.gallery,
        aoMudarEtapa: etapas.add,
      ),
    );

    expect(bytes, saida);
    expect(m.chamadas, [
      'pegar:gallery:$ladoDoRecorte',
      'preparar',
      'recortar:FONTE',
      'reduzir:$ladoMaximoDaFoto',
    ]);
    expect(etapas, EtapaDaFoto.values, reason: 'todas, nesta ordem');
  });

  testWidgets('o lado máximo pedido chega à redução (avatar usa 800)',
      (tester) async {
    final m = montar(reduzida: Uint8List(1));
    final ctx = await contexto(tester);

    await tester.runAsync(
      () => m.seletor.escolher(
        ctx,
        origem: ImageSource.camera,
        ladoMaximo: 800,
      ),
    );

    expect(m.chamadas.last, 'reduzir:800');
  });

  testWidgets('desistir no seletor: null, e nada mais roda', (tester) async {
    final etapas = <EtapaDaFoto>[];
    final m = montar(desisteNoSeletor: true);
    final ctx = await contexto(tester);

    final bytes = await tester.runAsync(
      () => m.seletor.escolher(
        ctx,
        origem: ImageSource.gallery,
        aoMudarEtapa: etapas.add,
      ),
    );

    expect(bytes, isNull);
    expect(m.chamadas, ['pegar:gallery:$ladoDoRecorte']);
    expect(etapas, [EtapaDaFoto.abrindo]);
  });

  testWidgets('desistir no recorte: null, sem reduzir', (tester) async {
    final m = montar(recortado: null);
    final ctx = await contexto(tester);

    final bytes = await tester.runAsync(
      () => m.seletor.escolher(ctx, origem: ImageSource.gallery),
    );

    expect(bytes, isNull);
    expect(m.chamadas, [
      'pegar:gallery:$ladoDoRecorte',
      'preparar',
      'recortar:FONTE',
    ]);
  });

  testWidgets('foto que nem o libheif abre: a exceção sobe antes do recorte',
      (tester) async {
    final m = montar(conversaoFalha: true);
    final ctx = await contexto(tester);

    Object? erro;
    await tester.runAsync(() async {
      try {
        await m.seletor.escolher(ctx, origem: ImageSource.gallery);
      } catch (e) {
        erro = e;
      }
    });

    expect(
      erro,
      isA<FotoNaoSuportadaException>()
          .having((e) => e.formato, 'formato', 'HEIC'),
    );
    expect(m.chamadas, ['pegar:gallery:$ladoDoRecorte', 'preparar']);
  });

  testWidgets('redução que devolve null: seguem os bytes do recorte',
      (tester) async {
    final m = montar(reduzida: null);
    final ctx = await contexto(tester);

    final bytes = await tester.runAsync(
      () => m.seletor.escolher(ctx, origem: ImageSource.gallery),
    );

    expect(bytes, jpegDoRecorte);
  });
}
