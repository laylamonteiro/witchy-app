import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../services/debug_log_service.dart';
import '../theme/grimoire_colors.dart';
import '../utils/image_compression.dart';
import '../utils/reducao_de_imagem.dart';
import '../utils/reducao_de_imagem_stub.dart'
    if (dart.library.js_interop) '../utils/reducao_de_imagem_web.dart';
import 'etapa_da_foto.dart';
import 'url_temporaria_stub.dart'
    if (dart.library.js_interop) 'url_temporaria_web.dart';

/// Lado maior com que a foto chega ao recorte. Maior que o resultado final
/// (1600) de propósito: quem recorta um pedaço da foto precisa de sobra.
const int ladoDoRecorte = 2400;

typedef AoMudarEtapa = void Function(EtapaDaFoto etapa);

/// Os quatro passos, trocáveis em teste. Em produção: o picker do aparelho,
/// a conversão (na web, navegador ou libheif), o image_cropper e a redução
/// que já existe.
typedef PegarFoto = Future<XFile?> Function(
  ImageSource origem, {
  int? ladoMaximo,
});
typedef PrepararFonte = Future<String> Function(
  XFile escolhida,
  void Function(String) relatar,
);
typedef RecortarFoto = Future<String?> Function(
  BuildContext context,
  String fonte,
  AppLocalizations l10n,
);
typedef ReduzirFoto = Future<Uint8List?> Function(
  XFile recortada,
  int ladoMaximo,
);

/// O ÚNICO caminho de foto do app para o que é guardado: verbete e avatar.
///
/// Pegar (câmera ou galeria) → converter para algo que a tela abre (HEIC
/// inclusive; na web pelo libheif, no celular pelo sistema) → recortar em
/// quadrado → reduzir a [ladoMaximoDaFoto] em JPEG → devolver os bytes.
/// Sempre JPEG, seja qual for a entrada; sempre quadrado.
///
/// Quiromancia e diagnóstico ficam de fora de propósito: a leitura da mão
/// quer a foto inteira, sem recorte, e continuam usando
/// [compressPickedImage] direto.
class SeletorDeFoto {
  const SeletorDeFoto({
    this.pegar = _pegarDoAparelho,
    this.preparar = _prepararFonte,
    this.recortar = _recortarQuadrado,
    this.reduzir = _reduzirParaGuardar,
  });

  final PegarFoto pegar;
  final PrepararFonte preparar;
  final RecortarFoto recortar;
  final ReduzirFoto reduzir;

  /// `null` quando a pessoa desistiu (no seletor ou no recorte) — sem
  /// mensagem. Lança [FotoNaoSuportadaException] quando nem o libheif abre
  /// a foto; qualquer outra falha sobe como veio.
  Future<Uint8List?> escolher(
    BuildContext context, {
    required ImageSource origem,
    int ladoMaximo = ladoMaximoDaFoto,
    AoMudarEtapa? aoMudarEtapa,
  }) async {
    final relogio = Stopwatch()..start();
    void relatar(String o) {
      unawaited(debugLog('FOTO', '$o (${relogio.elapsedMilliseconds} ms)'));
    }

    aoMudarEtapa?.call(EtapaDaFoto.abrindo);
    // Na web o picker é cego ao formato (devolve o original quando não
    // decodifica): a conversão é toda nossa. No celular ele já reexporta
    // JPEG pelo decodificador do sistema, que abre HEIC.
    final escolhida = await pegar(
      origem,
      ladoMaximo: kIsWeb ? null : ladoDoRecorte,
    );
    if (escolhida == null) {
      relatar('desistiu no seletor');
      return null;
    }
    relatar('escolhida: ${escolhida.name} (${escolhida.mimeType ?? '?'})');

    aoMudarEtapa?.call(EtapaDaFoto.convertendo);
    final fonte = await preparar(escolhida, relatar);
    try {
      if (!context.mounted) return null;
      aoMudarEtapa?.call(EtapaDaFoto.recortando);
      final recortada = await recortar(
        context,
        fonte,
        AppLocalizations.of(context),
      );
      if (recortada == null) {
        relatar('desistiu no recorte');
        return null;
      }

      aoMudarEtapa?.call(EtapaDaFoto.reduzindo);
      final arquivo = XFile(recortada);
      final bytes = await reduzir(arquivo, ladoMaximo) ??
          // JPEG do recorte que a redução não quis: segue com ele (é o
          // caso da quiromancia hoje), o limite de tamanho decide depois.
          await arquivo.readAsBytes();
      relatar('pronta: ${bytes.length} bytes');
      if (kIsWeb) liberarUrlTemporaria(recortada);
      return bytes;
    } finally {
      if (kIsWeb) liberarUrlTemporaria(fonte);
    }
  }
}

Future<XFile?> _pegarDoAparelho(ImageSource origem, {int? ladoMaximo}) {
  return ImagePicker().pickImage(
    source: origem,
    maxWidth: ladoMaximo?.toDouble(),
    maxHeight: ladoMaximo?.toDouble(),
  );
}

/// O que o recorte recebe. No celular, o próprio arquivo do picker (já
/// JPEG). Na web, os bytes convertidos — navegador ou libheif — num JPEG de
/// até [ladoDoRecorte] px, atrás de um endereço `blob:`. É aqui, e só aqui,
/// que nasce [FotoNaoSuportadaException].
Future<String> _prepararFonte(
  XFile escolhida,
  void Function(String) relatar,
) async {
  if (!kIsWeb) return escolhida.path;
  final bytes = await escolhida.readAsBytes();
  final jpeg = await reduzirImagemNoNavegador(
    bytes,
    ladoMaximo: ladoDoRecorte,
    // Qualidade alta: ainda vai ser recortado e reduzido de novo.
    qualidade: 0.92,
    relatar: relatar,
  ).timeout(limiteDaReducaoWeb);
  if (jpeg == null) {
    throw FotoNaoSuportadaException(
      formatoDaFoto(mime: escolhida.mimeType, nome: escolhida.name),
    );
  }
  return criarUrlTemporaria(jpeg);
}

Future<String?> _recortarQuadrado(
  BuildContext context,
  String fonte,
  AppLocalizations l10n,
) async {
  final cores = context.gc;
  // Na web o recorte é um diálogo do Flutter com o Cropper.js dentro; o
  // tamanho padrão (500) estoura a largura de um celular.
  final larguraDaTela = MediaQuery.sizeOf(context).width;
  final lado = math.min(larguraDaTela - 64, 420).round();
  final recortada = await ImageCropper().cropImage(
    sourcePath: fonte,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 92,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: l10n.photoCropTitle,
        toolbarColor: cores.surface,
        toolbarWidgetColor: cores.lilac,
        backgroundColor: cores.background,
        activeControlsWidgetColor: cores.lilac,
        cropFrameColor: cores.lilac,
        cropGridColor: cores.surfaceBorder,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
        aspectRatioPresets: const [CropAspectRatioPreset.square],
      ),
      IOSUiSettings(
        title: l10n.photoCropTitle,
        doneButtonTitle: l10n.photoCropConfirm,
        cancelButtonTitle: l10n.photoCropCancel,
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
        aspectRatioPickerButtonHidden: true,
        aspectRatioPresets: const [CropAspectRatioPreset.square],
      ),
      WebUiSettings(
        context: context,
        presentStyle: WebPresentStyle.dialog,
        size: CropperSize(width: lado, height: lado),
        viewwMode: WebViewMode.mode_1,
        dragMode: WebDragMode.move,
        translations: WebTranslations(
          title: l10n.photoCropTitle,
          rotateLeftTooltip: l10n.photoCropRotateLeft,
          rotateRightTooltip: l10n.photoCropRotateRight,
          cancelButton: l10n.photoCropCancel,
          cropButton: l10n.photoCropConfirm,
        ),
      ),
    ],
  );
  return recortada?.path;
}

Future<Uint8List?> _reduzirParaGuardar(XFile recortada, int ladoMaximo) {
  return compressPickedImage(
    recortada,
    minWidth: ladoMaximo,
    minHeight: ladoMaximo,
    ladoMaximoWeb: ladoMaximo,
  );
}
