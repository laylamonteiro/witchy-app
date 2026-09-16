import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/debug_log_service.dart';
import 'regra_do_convite.dart';

/// O que aconteceu quando o app pediu o card nativo de avaliação.
///
/// O card do Google não devolve opinião nenhuma — ele não diz se a pessoa
/// avaliou, nem se chegou a aparecer. O que ele devolve é se o PEDIDO pôde ser
/// feito, e é só isso que estes valores dizem. Confundir "pedido entregue" com
/// "pessoa convidada" é o erro que faz o app gastar em silêncio as poucas
/// chances que tem.
enum DesfechoDoCard {
  /// O fluxo foi lançado. Pode ter aparecido um card, pode a cota do Play ter
  /// engolido — a API não conta, e não há como descobrir.
  lancado,

  /// Não há Play Store neste aparelho. Aqui não existe caminho para avaliar:
  /// nem card, nem ficha da loja. O certo é não convidar.
  semPlay,

  /// Há Play, mas o fluxo falhou (pedido inválido, erro interno, canal não
  /// registrado). É o caso em que a folha de reserva ainda funciona.
  falhou,

  /// Não é hora: a tela está indo embora, o app não está à frente, ou já há um
  /// fluxo em voo. Nada é carimbado e nada é mostrado — tenta-se no próximo
  /// rito.
  adiar,
}

/// O convite para avaliar o app na loja: o que já foi perguntado, o que a
/// pessoa respondeu, e como abrir a avaliação.
///
/// A DECISÃO mora em [podeConvidar] e [podeMostrarCardNativo], que são puras.
/// Aqui fica só o que precisa do mundo: as preferências, o relógio, o sorteio e
/// a loja.
///
/// São DOIS orçamentos, de propósito. A folha a gente vê aparecer e vê ser
/// respondida, então ela conta dispensas e desiste na terceira. O card nativo
/// não: quem decide se ele aparece é o Play, por uma cota que o app não
/// consegue ler. Misturar os dois faria as três chances da vida inteira caberem
/// em três semanas, a maior parte delas em disparos que ninguém veria.
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
  static const _ultimoCardKey = 'convite_avaliacao_cards_ms';
  static const _cardsKey = 'convite_avaliacao_cards_disparados';

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

  /// Quando o último card nativo foi disparado.
  DateTime? get ultimoCard {
    final ms = _prefs.getInt(_ultimoCardKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Quantos cards nativos já foram disparados nesta instalação.
  int get cardsDisparados => _prefs.getInt(_cardsKey) ?? 0;

  /// Se o app tem um card nativo para oferecer neste aparelho.
  bool get temCardNativo => _loja.temCardNativo;

  /// Se o card nativo pode ser pedido agora, para quem usou o app [uso].
  bool devoMostrarCard(UsoAtePagora uso) =>
      _loja.temCardNativo &&
      !memoria.jaAvaliou &&
      podeMostrarCardNativo(
        ultimoCard: ultimoCard,
        cardsDisparados: cardsDisparados,
        uso: uso,
        agora: _relogio(),
      );

  /// Se vale consultar o banco para montar o [UsoAtePagora].
  ///
  /// Não é a decisão — é o filtro barato que evita ir ao disco a cada rito de
  /// quem já avaliou ou de quem já ouviu o que tinha para ouvir. Onde há card
  /// nativo é o orçamento DELE que manda: esgotado o card, o assunto se encerra
  /// no Android, e a folha não herda o que sobrou.
  bool get valeIrAoDisco {
    if (memoria.jaAvaliou) return false;
    if (_loja.temCardNativo) return cardsDisparados < cardsAteDesistir;
    return memoria.dispensas < dispensasAteDesistir;
  }

  /// Se a FOLHA pode aparecer agora, para quem usou o app [uso].
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

  /// Pede o card nativo e guarda o que dá para guardar.
  ///
  /// O carimbo sai assim que o Play confirma o LANÇAMENTO, não quando o card
  /// fecha: se ele esperasse o fim, uma morte de processo com o card aberto
  /// deixaria o disparo sem registro, e o próximo rito dispararia outro — em
  /// rajada, contra a cota silenciosa do Google.
  ///
  /// [DesfechoDoCard.adiar] não carimba nada de propósito. Uma tentativa que
  /// nunca chegou a virar card não é uma chance gasta.
  Future<DesfechoDoCard> pedirCardNativo() async {
    final desfecho = await _loja.pedirCardNativo();
    if (desfecho == DesfechoDoCard.lancado) {
      await _prefs.setInt(_ultimoCardKey, _relogio().millisecondsSinceEpoch);
      await _prefs.setInt(_cardsKey, cardsDisparados + 1);
    }
    return desfecho;
  }
}

/// Como chegar até a avaliação.
///
/// Dois caminhos, e a ordem entre eles é exigência da loja, não gosto nosso:
///
/// 1. O CARD NATIVO do Google ([pedirCardNativo]), que avalia sem sair do
///    Grimório. Ele é disparado DIRETO, sem nada nosso perguntando antes — a
///    política é explícita: "you should not have a call-to-action option (such
///    as a button) to trigger the API, as a user might have already hit their
///    quota and the flow won't be shown, presenting a broken experience to the
///    user", e "your app shouldn't ask the user any questions before or while
///    presenting the rating button or card".
/// 2. A FICHA DA LOJA ([abrir]), que é a reserva que o mesmo documento
///    prescreve para o caso do botão — e por isso é ela, e não o card, que fica
///    atrás do "Avaliar" da nossa folha.
///
/// A separação é de propósito: quem decide QUANDO convidar não precisa saber
/// COMO a avaliação abre, e trocar um não mexe no outro.
class AberturaDaLoja {
  const AberturaDaLoja();

  static const idDoApp = 'com.grimoriodebolso.app';

  /// O canal que leva ao card nativo. O outro lado é `MainActivity.kt`, e os
  /// dois nomes precisam bater — `test/ponte_de_avaliacao_test.dart` confere,
  /// porque um rename só do lado Kotlin deixaria a esteira inteira verde e a
  /// avaliação morta em todo aparelho.
  static const canalNativo = MethodChannel('com.grimoriodebolso.app/avaliacao');
  static const metodoPedirAvaliacao = 'pedirAvaliacao';

  /// Onde o app roda, existe loja para abrir?
  ///
  /// Só Android. Na web, não — e no iPhone o que roda é o app web, onde
  /// `kIsWeb` corta antes: não há, nem vai haver, app iOS nativo.
  bool get existe {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Onde o app roda, existe card nativo? É o mesmo conjunto de [existe]: o
  /// card é uma API do Play.
  bool get temCardNativo => existe;

  Uri get ficha => Uri.parse(
      'https://play.google.com/store/apps/details?id=$idDoApp');

  /// Pede o card nativo ao Play.
  ///
  /// Nunca lança: o convite não pode derrubar a tela em que ele apareceria.
  ///
  /// O tempo limite existe porque o lado nativo só responde de dentro dos
  /// listeners do Play. Se um deles nunca voltar — a Play Store sendo
  /// atualizada, por exemplo —, sem isto o convite ficaria pendurado pelo resto
  /// da sessão, sem log e sem sintoma.
  Future<DesfechoDoCard> pedirCardNativo() async {
    if (!temCardNativo) return DesfechoDoCard.falhou;
    try {
      final codigo = await canalNativo
          .invokeMethod<int>(metodoPedirAvaliacao)
          .timeout(const Duration(seconds: 12), onTimeout: () {
        unawaitedLog('the native review channel did not answer in time');
        return _adiar;
      });
      return _desfechoDe(codigo);
    } on MissingPluginException catch (e) {
      unawaitedLog('the review channel is not registered: $e');
      return DesfechoDoCard.falhou;
    } catch (e) {
      unawaitedLog('could not ask for the native review card: $e');
      return DesfechoDoCard.falhou;
    }
  }

  /// Os códigos vêm de `MainActivity.kt`; o -1 e o -2 são do próprio Play
  /// (`PLAY_STORE_NOT_FOUND` e `INVALID_REQUEST`).
  static const _lancado = 0;
  static const _semPlay = -1;
  static const _adiar = -1000;

  static DesfechoDoCard _desfechoDe(int? codigo) {
    switch (codigo) {
      case _lancado:
        return DesfechoDoCard.lancado;
      case _semPlay:
        return DesfechoDoCard.semPlay;
      case _adiar:
        return DesfechoDoCard.adiar;
      default:
        return DesfechoDoCard.falhou;
    }
  }

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
