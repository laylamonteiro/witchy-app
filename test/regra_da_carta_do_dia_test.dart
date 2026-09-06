import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/tarot/domain/regra_da_carta_do_dia.dart';

/// Pergunta obrigatória no Tarô sem tirar a carta do dia grátis da Free:
/// a primeira pergunta do dia é a carta do dia; repetir não cobra; mudar de
/// pergunta é tiragem nova.
void main() {
  test('a primeira pergunta do dia é a carta grátis', () {
    expect(
      deveCobrarCartaDoDia(perguntaLembradaHoje: null, pergunta: 'Viajo?'),
      isFalse,
    );
  });

  test('repetir a mesma pergunta (maiúsculas, espaços) não cobra', () {
    expect(
      deveCobrarCartaDoDia(
        perguntaLembradaHoje: 'vou viajar?',
        pergunta: '  Vou VIAJAR?  ',
      ),
      isFalse,
    );
  });

  test('uma pergunta diferente no mesmo dia é tiragem nova', () {
    expect(
      deveCobrarCartaDoDia(
        perguntaLembradaHoje: 'vou viajar?',
        pergunta: 'Devo aceitar a proposta?',
      ),
      isTrue,
    );
  });
}
