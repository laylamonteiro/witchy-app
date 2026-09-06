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

  group('decidirTiragem — a cota é por pergunta, não por tiragem', () {
    DecisaoDaTiragem decidir({
      bool premium = false,
      String? perguntaDoDia,
      String pergunta = 'Vou viajar?',
      bool feitaHoje = false,
      bool temCota = true,
    }) =>
        decidirTiragem(
          premium: premium,
          perguntaDoDia: perguntaDoDia,
          pergunta: pergunta,
          tiragemJaFeitaHoje: feitaHoje,
          temCota: temCota,
        );

    test('Premium nunca é cobrada nem barrada', () {
      expect(decidir(premium: true), DecisaoDaTiragem.liberar);
      expect(
        decidir(premium: true, perguntaDoDia: 'outra', temCota: false),
        DecisaoDaTiragem.liberar,
      );
      expect(
        decidir(premium: true, perguntaDoDia: 'vou viajar?', feitaHoje: true),
        DecisaoDaTiragem.liberar,
      );
    });

    test('a primeira pergunta do dia gasta a cota; sem cota, barra', () {
      expect(decidir(), DecisaoDaTiragem.cobrar);
      expect(decidir(temCota: false), DecisaoDaTiragem.bloquear);
    });

    test('com a pergunta do dia, cada tiragem sai uma vez sem cobrar', () {
      expect(
        decidir(perguntaDoDia: 'vou viajar?', temCota: false),
        DecisaoDaTiragem.liberar,
        reason: 'três cartas e cruz com a mesma pergunta não gastam nada',
      );
      expect(
        decidir(perguntaDoDia: 'vou viajar?', pergunta: '  VOU viajar?'),
        DecisaoDaTiragem.liberar,
      );
    });

    test('tiragem já feita hoje com a pergunta do dia só se mostra de novo',
        () {
      expect(
        decidir(
          perguntaDoDia: 'vou viajar?',
          feitaHoje: true,
          temCota: false,
        ),
        DecisaoDaTiragem.repetir,
      );
    });

    test('pergunta diferente no mesmo dia: cobra, ou barra sem cota', () {
      expect(
        decidir(perguntaDoDia: 'vou viajar?', pergunta: 'Devo aceitar?'),
        DecisaoDaTiragem.cobrar,
      );
      expect(
        decidir(
          perguntaDoDia: 'vou viajar?',
          pergunta: 'Devo aceitar?',
          temCota: false,
        ),
        DecisaoDaTiragem.bloquear,
      );
    });
  });

  group('pergunta guardada com o carimbo do dia', () {
    test('carimbo de hoje devolve a pergunta com a grafia original', () {
      final guardada = carimbarPerguntaDoDia(
        hoje: '2026-9-6',
        pergunta: 'Devo Aceitar a proposta?',
      );
      expect(guardada, '2026-9-6|Devo Aceitar a proposta?');
      expect(
        perguntaSeForDeHoje(guardada: guardada, hoje: '2026-9-6'),
        'Devo Aceitar a proposta?',
      );
    });

    test('carimbo de ontem, nada guardado ou lixo devolve null', () {
      expect(
        perguntaSeForDeHoje(guardada: '2026-9-5|Viajo?', hoje: '2026-9-6'),
        isNull,
      );
      expect(perguntaSeForDeHoje(guardada: null, hoje: '2026-9-6'), isNull);
      expect(perguntaSeForDeHoje(guardada: 'Viajo?', hoje: '2026-9-6'), isNull);
      expect(
        perguntaSeForDeHoje(guardada: '2026-9-6|', hoje: '2026-9-6'),
        isNull,
      );
    });

    test('uma pergunta com | dentro sobrevive inteira', () {
      expect(
        perguntaSeForDeHoje(guardada: '2026-9-6|A | B?', hoje: '2026-9-6'),
        'A | B?',
      );
    });
  });
}
