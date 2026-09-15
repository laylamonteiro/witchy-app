import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/debug_log_service.dart';
import 'regra_do_convite.dart';

/// O convite para avaliar o app na loja: o que já foi perguntado, o que a
/// pessoa respondeu, e como abrir a avaliação.
///
/// A DECISÃO mora em [podeConvidar], que é pura. Aqui fica só o que precisa do
/// mundo: as preferências, o relógio, o sorteio e a loja.
///
/// O estado vive em SharedPreferences, local e por aparelho — não sincroniza.
/// Ter avaliado não é registro da pessoa, é um fato entre ela e a loja; e
/// reinstalar o app já é motivo suficiente para a conversa recomeçar.
class ConviteDeAvaliacao {
  ConviteDeAvaliacao(
    this._prefs, {
    DateTime Function()? relogio,
    Random? sorteador,
    AberturaDaLoja? loja,
  })  : _relogio = relogio ?? DateTime.now,
        _sorteador = sorteador ?? Random(),
        _loja = loja ?? const AberturaDaLoja();

  final SharedPreferences _prefs;
  final DateTime Function() _relogio;
  final Random _sorteador;
  final AberturaDaLoja _loja;

  static const _jaAvaliouKey = 'convite_avaliacao_ja_avaliou';
  static const _dispensasKey = 'convite_avaliacao_dispensas';
  static const _ultimoKey = 'convite_avaliacao_ultimo_ms';

  static Future<ConviteDeAvaliacao> carregar() async =>
      ConviteDeAvaliacao(await SharedPreferences.getInstance());

  MemoriaDoConvite get memoria {
    final ultimo = _prefs.getInt(_ultimoKey);
    return MemoriaDoConvite(
      jaAvaliou: _prefs.getBool(_jaAvaliouKey) ?? false,
      dispensas: _prefs.getInt(_dispensasKey) ?? 0,
      ultimoConvite:
          ultimo == null ? null : DateTime.fromMillisecondsSinceEpoch(ultimo),
    );
  }

  /// Se o convite pode aparecer agora, para quem usou o app [uso].
  bool devoConvidar(UsoAtePagora uso) => podeConvidar(
        memoria: memoria,
        uso: uso,
        temLoja: _loja.existe,
        agora: _relogio(),
        sorteio: _sorteador.nextDouble(),
      );

  /// O convite apareceu. Marca a hora para a próxima espera contar a partir
  /// daqui — inclusive quando a pessoa nem responde e só fecha a folha.
  Future<void> registrarConvite() async {
    await _prefs.setInt(_ultimoKey, _relogio().millisecondsSinceEpoch);
  }

  /// "Agora não". Cada recusa afasta mais a próxima; na terceira, o convite
  /// some para sempre.
  Future<void> registrarDispensa() async {
    await _prefs.setInt(_dispensasKey, memoria.dispensas + 1);
  }

  /// Tocou em "Avaliar". Não dá para saber se ela deixou a nota — a loja não
  /// conta isso ao app —, e não importa: quem chegou até lá não deve ser
  /// perguntada de novo.
  Future<void> registrarAvaliacao() async {
    await _prefs.setBool(_jaAvaliouKey, true);
  }

  /// Abre a avaliação e marca que ela foi até lá.
  Future<bool> avaliar() async {
    await registrarAvaliacao();
    return _loja.abrir();
  }
}

/// Como chegar até a avaliação.
///
/// Hoje abre a ficha da loja no navegador/app da Play. O caminho MELHOR é a
/// folha nativa de avaliação do Google (pacote `in_app_review`), que avalia
/// sem sair do Grimório e converte muito mais — e é o que o Google recomenda.
/// Ela entra aqui, nesta classe e em mais lugar nenhum:
///
/// ```dart
/// final loja = InAppReview.instance;
/// if (await loja.isAvailable()) {
///   await loja.requestReview();   // a folha nativa
///   return true;
/// }
/// return _abrirFicha();           // reserva: a ficha na loja
/// ```
///
/// A separação é de propósito: quem decide QUANDO convidar não precisa saber
/// COMO a avaliação abre, e trocar um não mexe no outro.
///
/// Sobre a cota: a folha nativa tem limite próprio e silencioso — chamá-la
/// demais simplesmente não mostra nada. Por isso o convite que a pessoa vê é o
/// nosso, e a folha nativa só é acionada no toque em "Avaliar".
class AberturaDaLoja {
  const AberturaDaLoja();

  static const idDoApp = 'com.grimoriodebolso.app';

  /// Onde o app roda, existe loja para abrir? Na web, não.
  bool get existe {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  Uri get ficha => Uri.parse(
      'https://play.google.com/store/apps/details?id=$idDoApp');

  Future<bool> abrir() async {
    if (!existe) return false;
    try {
      return await launchUrl(ficha, mode: LaunchMode.externalApplication);
    } catch (e) {
      unawaitedLog('could not open the store listing: $e');
      return false;
    }
  }
}

/// Um log que não precisa ser esperado — o convite nunca pode derrubar a tela
/// em que apareceu.
void unawaitedLog(String mensagem) {
  debugLog('AVALIACAO', mensagem).ignore();
}
