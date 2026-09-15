// O convite de avaliação na tela: aparece depois de um rito fechar, guarda o
// que a pessoa respondeu, e nunca insiste com quem já disse não.
//
// A decisão de QUANDO convidar é pura e está em `regra_do_convite_test.dart`.
// Aqui é o resto: a folha, a memória e o gatilho.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/reviews/convite_de_avaliacao.dart';
import 'package:grimorio_de_bolso/core/reviews/folha_de_avaliacao.dart';
import 'package:grimorio_de_bolso/core/reviews/regra_do_convite.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uma loja que não abre nada — só anota que foi chamada.
class _LojaDeTeste extends AberturaDaLoja {
  _LojaDeTeste({this.temLoja = true});
  final bool temLoja;
  int aberturas = 0;

  @override
  bool get existe => temLoja;

  @override
  Future<bool> abrir() async {
    aberturas++;
    return true;
  }
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
}
