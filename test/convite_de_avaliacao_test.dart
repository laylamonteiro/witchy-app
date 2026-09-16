// O convite de avaliação na tela: aparece depois de um rito fechar, guarda o
// que a pessoa respondeu, e nunca insiste com quem já disse não.
//
// A decisão de QUANDO convidar é pura e está em `regra_do_convite_test.dart`.
// Aqui é o resto: a folha, a memória e o gatilho.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/reviews/convite_de_avaliacao.dart';
import 'package:grimorio_de_bolso/core/reviews/folha_de_avaliacao.dart';
import 'package:grimorio_de_bolso/core/reviews/regra_do_convite.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uma loja que não abre nada — só anota que foi chamada.
class _LojaDeTeste extends AberturaDaLoja {
  _LojaDeTeste({this.temLoja = true, this.desfecho = DesfechoDoCard.falhou});
  final bool temLoja;

  /// O que o card nativo responde. O padrão é a falha, que é o único desfecho
  /// que ainda deixa a folha aparecer.
  final DesfechoDoCard desfecho;

  int aberturas = 0;
  int pedidosDeCard = 0;

  @override
  bool get existe => temLoja;

  @override
  Future<bool> abrir() async {
    aberturas++;
    return true;
  }

  @override
  Future<DesfechoDoCard> pedirCardNativo() async {
    pedidosDeCard++;
    return desfecho;
  }
}

/// Uma loja que se diz Android sem fingir o card: serve para exercitar o
/// caminho REAL de [AberturaDaLoja.pedirCardNativo], o que passa pelo canal.
class _LojaComCanal extends AberturaDaLoja {
  const _LojaComCanal();

  @override
  bool get existe => true;
}

/// Um sorteio que sempre passa — a aleatoriedade tem teste próprio.
class _SempreSorteia implements Random {
  @override
  double nextDouble() => 0;
  @override
  bool nextBool() => true;
  @override
  int nextInt(int max) => 0;
}

Future<ConviteDeAvaliacao> _convite({
  Map<String, Object> guardado = const {},
  _LojaDeTeste? loja,
  DateTime? agora,
}) async {
  SharedPreferences.setMockInitialValues(guardado);
  return ConviteDeAvaliacao(
    await SharedPreferences.getInstance(),
    relogio: () => agora ?? DateTime(2026, 9, 15, 20),
    sorteador: _SempreSorteia(),
    loja: loja ?? _LojaDeTeste(),
  );
}

const _usaDeVerdade = UsoAtePagora(sequencia: 14, diasPraticados: 40);

/// A folha é mais alta que o palco padrão de 800x600 e estouraria por baixo,
/// levando o botão para fora do alcance do toque. Num celular de verdade ela
/// cabe — é o palco que é baixo.
void _palcoDeCelular(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _tela(Widget filho) => MaterialApp(
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: filho),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('a memória do convite', () {
    test('começa limpa e diz que pode convidar quem usa de verdade', () async {
      final convite = await _convite();
      expect(convite.memoria.jaAvaliou, isFalse);
      expect(convite.memoria.dispensas, 0);
      expect(convite.memoria.ultimoConvite, isNull);
      expect(convite.devoConvidar(_usaDeVerdade), isTrue);
    });

    test('cada dispensa é somada, e a terceira encerra o assunto', () async {
      var convite = await _convite();
      for (var i = 1; i <= dispensasAteDesistir; i++) {
        await convite.registrarDispensa();
        expect(convite.memoria.dispensas, i);
      }
      expect(convite.devoConvidar(_usaDeVerdade), isFalse,
          reason: 'quem disse não três vezes já disse o que tinha a dizer');

      // E continua encerrado depois de muito tempo.
      convite = await _convite(
        guardado: {'convite_avaliacao_dispensas': dispensasAteDesistir},
        agora: DateTime(2030),
      );
      expect(convite.devoConvidar(_usaDeVerdade), isFalse);
    });

    test('quem avaliou não é perguntada de novo', () async {
      final convite = await _convite();
      await convite.registrarAvaliacao();
      expect(convite.memoria.jaAvaliou, isTrue);
      expect(convite.devoConvidar(_usaDeVerdade), isFalse);
    });

    test('o convite carimba a hora, mesmo sem resposta nenhuma', () async {
      final convite = await _convite();
      await convite.registrarConvite();
      expect(convite.memoria.ultimoConvite, DateTime(2026, 9, 15, 20));
      expect(convite.devoConvidar(_usaDeVerdade), isFalse,
          reason: 'a espera conta a partir de ter aparecido');
    });

    test('onde não há loja, não há convite', () async {
      final convite = await _convite(loja: _LojaDeTeste(temLoja: false));
      expect(convite.devoConvidar(_usaDeVerdade), isFalse);
    });

    test('avaliar abre a loja e marca de uma vez só', () async {
      final loja = _LojaDeTeste();
      final convite = await _convite(loja: loja);
      expect(await convite.avaliar(), isTrue);
      expect(loja.aberturas, 1);
      expect(convite.memoria.jaAvaliou, isTrue);
    });
  });

  group('a folha', () {
    testWidgets('não pergunta opinião — só avaliar ou agora não',
        (tester) async {
      _palcoDeCelular(tester);
      late BuildContext contexto;
      await tester.pumpWidget(_tela(Builder(builder: (c) {
        contexto = c;
        return const SizedBox.shrink();
      })));

      final resposta = mostrarConviteDeAvaliacao(contexto);
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(contexto);
      expect(find.text(l10n.conviteAvaliacaoTitulo), findsOneWidget);
      expect(find.byKey(const ValueKey('convite-avaliar')), findsOneWidget);
      expect(find.byKey(const ValueKey('convite-agora-nao')), findsOneWidget);
      // Dois caminhos, e nenhum deles é uma pergunta sobre gostar ou não —
      // filtrar opinião é o que a política da loja proíbe.
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.byKey(const ValueKey('convite-avaliar')));
      await tester.pumpAndSettle();
      expect(await resposta, RespostaDoConvite.avaliou);
    });

    testWidgets('fechar sem responder conta como "agora não"', (tester) async {
      _palcoDeCelular(tester);
      late BuildContext contexto;
      await tester.pumpWidget(_tela(Builder(builder: (c) {
        contexto = c;
        return const SizedBox.shrink();
      })));

      final resposta = mostrarConviteDeAvaliacao(contexto);
      await tester.pumpAndSettle();
      // Tocar fora da folha: quem fecha sem responder está respondendo.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(await resposta, RespostaDoConvite.agoraNao);
    });
  });

  group('convidarEGuardar', () {
    testWidgets('"avaliar" abre a loja e encerra o assunto', (tester) async {
      _palcoDeCelular(tester);
      final loja = _LojaDeTeste();
      final convite = await _convite(loja: loja);
      late BuildContext contexto;
      await tester.pumpWidget(_tela(Builder(builder: (c) {
        contexto = c;
        return const SizedBox.shrink();
      })));

      final foi = convidarEGuardar(contexto, convite);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('convite-avaliar')));
      await tester.pumpAndSettle();

      expect(await foi, isTrue);
      expect(loja.aberturas, 1);
      expect(convite.memoria.jaAvaliou, isTrue);
      expect(convite.memoria.dispensas, 0, reason: 'ela não recusou nada');
    });

    testWidgets('"agora não" soma uma dispensa e não abre a loja',
        (tester) async {
      _palcoDeCelular(tester);
      final loja = _LojaDeTeste();
      final convite = await _convite(loja: loja);
      late BuildContext contexto;
      await tester.pumpWidget(_tela(Builder(builder: (c) {
        contexto = c;
        return const SizedBox.shrink();
      })));

      final foi = convidarEGuardar(contexto, convite);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('convite-agora-nao')));
      await tester.pumpAndSettle();

      expect(await foi, isFalse);
      expect(loja.aberturas, 0);
      expect(convite.memoria.jaAvaliou, isFalse);
      expect(convite.memoria.dispensas, 1);
      expect(convite.memoria.ultimoConvite, isNotNull,
          reason: 'a espera conta a partir de ter aparecido');
    });
  });

  group('o card nativo', () {
    test('o disparo carimba a hora e gasta uma chance', () async {
      final loja = _LojaDeTeste(desfecho: DesfechoDoCard.lancado);
      final convite = await _convite(loja: loja);
      expect(convite.devoMostrarCard(_usaDeVerdade), isTrue);

      expect(await convite.pedirCardNativo(), DesfechoDoCard.lancado);
      expect(loja.pedidosDeCard, 1);
      expect(convite.cardsDisparados, 1);
      expect(convite.ultimoCard, DateTime(2026, 9, 15, 20));
      expect(convite.devoMostrarCard(_usaDeVerdade), isFalse,
          reason: 'a espera conta a partir do disparo');
    });

    test('o que não virou card não gasta chance nenhuma', () async {
      for (final desfecho in [
        DesfechoDoCard.adiar,
        DesfechoDoCard.falhou,
        DesfechoDoCard.semPlay,
      ]) {
        final convite = await _convite(loja: _LojaDeTeste(desfecho: desfecho));
        expect(await convite.pedirCardNativo(), desfecho);
        expect(convite.cardsDisparados, 0, reason: 'desfecho $desfecho');
        expect(convite.ultimoCard, isNull, reason: 'desfecho $desfecho');
      }
    });

    test('três cards encerram o assunto, e a folha não herda o resto',
        () async {
      final convite = await _convite(
        guardado: {'convite_avaliacao_cards_disparados': cardsAteDesistir},
        loja: _LojaDeTeste(desfecho: DesfechoDoCard.lancado),
        agora: DateTime(2030),
      );
      expect(convite.devoMostrarCard(_usaDeVerdade), isFalse);
      expect(convite.valeIrAoDisco, isFalse,
          reason: 'onde há card, é o orçamento dele que manda');
    });

    test('quem já avaliou pela folha não recebe card', () async {
      final convite = await _convite(
        guardado: {'convite_avaliacao_ja_avaliou': true},
        loja: _LojaDeTeste(desfecho: DesfechoDoCard.lancado),
      );
      expect(convite.devoMostrarCard(_usaDeVerdade), isFalse);
      expect(convite.valeIrAoDisco, isFalse);
    });

    test('onde não há card, quem manda é o orçamento da folha', () async {
      var convite = await _convite(loja: _LojaDeTeste(temLoja: false));
      expect(convite.temCardNativo, isFalse);
      expect(convite.valeIrAoDisco, isTrue);

      convite = await _convite(
        guardado: {'convite_avaliacao_dispensas': dispensasAteDesistir},
        loja: _LojaDeTeste(temLoja: false),
      );
      expect(convite.valeIrAoDisco, isFalse);
    });
  });

  group('a ponte com o Kotlin', () {
    final chamadas = <MethodCall>[];

    void responder(Future<Object?> Function(MethodCall) handler) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(AberturaDaLoja.canalNativo, (chamada) {
        chamadas.add(chamada);
        return handler(chamada);
      });
    }

    setUp(chamadas.clear);
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(AberturaDaLoja.canalNativo, null);
    });

    test('pede pelo nome que o Kotlin atende', () async {
      responder((_) async => 0);
      expect(await const _LojaComCanal().pedirCardNativo(),
          DesfechoDoCard.lancado);
      expect(chamadas.single.method, AberturaDaLoja.metodoPedirAvaliacao);
    });

    test('cada código vira o desfecho que o Dart entende', () async {
      const esperado = {
        0: DesfechoDoCard.lancado,
        -1: DesfechoDoCard.semPlay,
        -2: DesfechoDoCard.falhou,
        -100: DesfechoDoCard.falhou,
        -1000: DesfechoDoCard.adiar,
      };
      for (final entrada in esperado.entries) {
        responder((_) async => entrada.key);
        expect(await const _LojaComCanal().pedirCardNativo(), entrada.value,
            reason: 'código ${entrada.key}');
      }
    });

    test('resposta estranha ou ausente é falha, nunca chance gasta', () async {
      for (final resposta in [null, 42]) {
        responder((_) async => resposta);
        expect(await const _LojaComCanal().pedirCardNativo(),
            DesfechoDoCard.falhou,
            reason: 'resposta $resposta');
      }
    });

    test('erro do lado nativo não sobe para a tela', () async {
      responder((_) async => throw PlatformException(code: 'boom'));
      expect(await const _LojaComCanal().pedirCardNativo(),
          DesfechoDoCard.falhou);
    });

    test('canal não registrado é falha — e a folha ainda salva o dia',
        () async {
      // Sem handler, o canal estoura MissingPluginException. É o que
      // aconteceria se alguém escrevesse o canal no MainActivity errado.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(AberturaDaLoja.canalNativo, null);
      expect(await const _LojaComCanal().pedirCardNativo(),
          DesfechoDoCard.falhou);
    });

    test('fora do Android nem se tenta', () async {
      // Em Linux, `existe` é falso — o canal nem é tocado.
      expect(await const AberturaDaLoja().pedirCardNativo(),
          DesfechoDoCard.falhou);
      expect(chamadas, isEmpty);
    });
  });

  group('convidarAgora: nada nosso antes do card', () {
    /// Roda o convite e devolve a loja mais o que ficou em andamento.
    ///
    /// O futuro NÃO é esperado aqui: quando a folha aparece, `convidarAgora` só
    /// volta depois de alguém responder, e esperar por ele antes de bombear os
    /// quadros trava o teste para sempre. Quem precisa do fim, fecha a folha e
    /// espera; quem não, já sabe que nada apareceu.
    Future<(_LojaDeTeste, Future<void>)> rodar(
      WidgetTester tester,
      DesfechoDoCard desfecho,
    ) async {
      _palcoDeCelular(tester);
      final loja = _LojaDeTeste(desfecho: desfecho);
      final convite = await _convite(loja: loja);
      late BuildContext contexto;
      await tester.pumpWidget(_tela(Builder(builder: (c) {
        contexto = c;
        return const SizedBox.shrink();
      })));

      final andamento = convidarAgora(contexto, convite, _usaDeVerdade);
      await tester.pumpAndSettle();
      return (loja, andamento);
    }

    testWidgets('card lançado: a folha NÃO aparece', (tester) async {
      final (loja, andamento) = await rodar(tester, DesfechoDoCard.lancado);
      // As conferências vêm ANTES de esperar o fim: se alguém inverter o garfo,
      // a folha abre e o `andamento` fica pendurado esperando resposta — e a
      // falha viraria um timeout de minutos em vez de um expect que diz o quê.
      expect(find.byKey(const ValueKey('convite-avaliar')), findsNothing,
          reason: 'a política proíbe qualquer coisa nossa antes do card');
      expect(find.byKey(const ValueKey('convite-agora-nao')), findsNothing);
      await andamento;
      expect(loja.pedidosDeCard, 1);
    });

    testWidgets('card falhou: a folha entra como reserva', (tester) async {
      final (loja, andamento) = await rodar(tester, DesfechoDoCard.falhou);
      expect(loja.pedidosDeCard, 1);
      expect(find.byKey(const ValueKey('convite-avaliar')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('convite-agora-nao')));
      await tester.pumpAndSettle();
      await andamento;
    });

    testWidgets('sem Play no aparelho: ninguém é convidado', (tester) async {
      // A folha manda para uma ficha da Play que essa pessoa não tem como
      // usar — e ainda marcaria "já avaliou" para sempre.
      final (_, andamento) = await rodar(tester, DesfechoDoCard.semPlay);
      await andamento;
      expect(find.byKey(const ValueKey('convite-avaliar')), findsNothing);
    });

    testWidgets('adiar: nada aparece e nada é carimbado', (tester) async {
      final (_, andamento) = await rodar(tester, DesfechoDoCard.adiar);
      await andamento;
      expect(find.byKey(const ValueKey('convite-avaliar')), findsNothing);
    });

    testWidgets('sem card no aparelho, o caminho antigo continua inteiro',
        (tester) async {
      _palcoDeCelular(tester);
      final loja = _LojaDeTeste(temLoja: false);
      final convite = await _convite(loja: loja);
      late BuildContext contexto;
      await tester.pumpWidget(_tela(Builder(builder: (c) {
        contexto = c;
        return const SizedBox.shrink();
      })));

      final andamento = convidarAgora(contexto, convite, _usaDeVerdade);
      await tester.pumpAndSettle();
      await andamento;

      expect(loja.pedidosDeCard, 0);
      // Sem loja não há convite nenhum — é a regra de hoje, intacta.
      expect(find.byKey(const ValueKey('convite-avaliar')), findsNothing);
    });
  });
}
