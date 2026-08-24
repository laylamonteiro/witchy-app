import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/home/presentation/caminhada_do_voltar.dart';

/// Os dez testes da caminhada injetam uma saída FALSA — eles provam a
/// caminhada, não a saída. Este arquivo olha a saída DE VERDADE, e a única
/// afirmação que interessa é esta: na web ela não existe.
///
/// Guarda o defeito de 23/08: um `history.go(-2)` autorizado por
/// `history.length > 3`. Como o motor só usa `replaceState` depois do boot, esse
/// número mede o que existia na aba ANTES do app — quem abrisse o Grimório por
/// um link passava no teste, e o segundo voltar no Seu Dia a tirava de lá.
void main() {
  test('na web o app nunca entrega a aba', () {
    expect(const SaidaDaAbaReal(naWeb: true).podeSair(), isFalse);
  });

  test('no celular a saída continua existindo', () {
    expect(const SaidaDaAbaReal(naWeb: false).podeSair(), isTrue);
  });

  testWidgets('na web, sair não pede NADA à plataforma', (tester) async {
    final chamadas = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (chamada) async {
      chamadas.add(chamada);
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    const SaidaDaAbaReal(naWeb: true).sair();
    await tester.pump();

    expect(chamadas.where((c) => c.method == 'SystemNavigator.pop'), isEmpty,
        reason: 'o exit() do motor mata o voltar do documento inteiro');
  });

  testWidgets('no celular, sair manda o app para segundo plano',
      (tester) async {
    final chamadas = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (chamada) async {
      chamadas.add(chamada);
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    const SaidaDaAbaReal(naWeb: false).sair();
    await tester.pump();

    expect(chamadas.map((c) => c.method), contains('SystemNavigator.pop'));
  });
}
