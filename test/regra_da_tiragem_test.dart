// O que a tela diz ANTES da escolha tem de ser o que o repositório faz depois.
// Estes casos trancam a parte nova da regra: a forma canônica da pergunta e a
// prévia que vira o estado do leque e do aviso.
//
// A parte antiga (decidirTiragem e a memória carimbada) veio junto quando a
// regra mudou de casa: era `regra_da_carta_do_dia_test.dart`.
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/divination/regra_da_tiragem.dart';

SituacaoDaTiragem _avaliar({
  bool premium = false,
  String? perguntaDoDia,
  String pergunta = 'Vou viajar?',
  bool temCota = true,
  bool jaFeita = false,
}) =>
    avaliarTiragem(
      premium: premium,
      perguntaDoDia: perguntaDoDia,
      pergunta: pergunta,
      temCota: temCota,
      tiragemJaFeitaHoje: jaFeita,
    );

void main() {
  group('normalizarPergunta — a forma canônica', () {
    test('espaço nas pontas e caixa não fazem pergunta nova', () {
      expect(normalizarPergunta('  Vou Viajar? '),
          normalizarPergunta('vou viajar?'));
    });

    test('campo vazio e só espaços viram a mesma coisa', () {
      expect(normalizarPergunta(''), '');
      expect(normalizarPergunta('   '), '');
      expect(normalizarPergunta('\n\t '), '');
    });

    test('o que está no meio é preservado', () {
      expect(normalizarPergunta('A | B?'), 'a | b?');
    });
  });

  group('avaliarTiragem — o aviso antes da escolha', () {
    test('a primeira pergunta do dia gasta a tiragem', () {
      expect(_avaliar(perguntaDoDia: null), SituacaoDaTiragem.gastaUma);
    });

    test('repetir a pergunta do dia é livre', () {
      expect(_avaliar(perguntaDoDia: 'vou viajar?'),
          SituacaoDaTiragem.livre);
    });

    test('grafia diferente ainda é a mesma pergunta', () {
      expect(_avaliar(perguntaDoDia: 'vou viajar?', pergunta: ' Vou Viajar? '),
          SituacaoDaTiragem.livre);
    });

    test('pergunta nova sem cota cai no convite ao Premium', () {
      expect(_avaliar(perguntaDoDia: 'vou viajar?', pergunta: 'Mudo de casa?',
              temCota: false),
          SituacaoDaTiragem.semCota);
    });

    test('pergunta nova com cota avisa que vai gastar', () {
      expect(
          _avaliar(perguntaDoDia: 'vou viajar?', pergunta: 'Mudo de casa?'),
          SituacaoDaTiragem.gastaUma);
    });

    test('Premium nunca esbarra em cota', () {
      expect(
          _avaliar(
              premium: true,
              perguntaDoDia: 'vou viajar?',
              pergunta: 'Mudo de casa?',
              temCota: false),
          SituacaoDaTiragem.livre);
    });
  });

  group('sem pergunta é um balde como qualquer outro', () {
    test('a primeira sem pergunta gasta, como uma escrita gastaria', () {
      expect(_avaliar(perguntaDoDia: null, pergunta: ''),
          SituacaoDaTiragem.gastaUma);
    });

    test('as seguintes sem pergunta saem livres', () {
      expect(_avaliar(perguntaDoDia: '', pergunta: ''),
          SituacaoDaTiragem.livre);
      expect(_avaliar(perguntaDoDia: '', pergunta: '   '),
          SituacaoDaTiragem.livre);
    });

    test('não é brecha: escrever algo depois de tirar sem pergunta cobra',
        () {
      expect(_avaliar(perguntaDoDia: '', pergunta: 'Vou viajar?'),
          SituacaoDaTiragem.gastaUma);
      expect(
          _avaliar(perguntaDoDia: '', pergunta: 'Vou viajar?', temCota: false),
          SituacaoDaTiragem.semCota);
    });
  });

  group('mesa já feita', () {
    test('reabrir é livre, mesmo sem cota', () {
      expect(
          _avaliar(
              perguntaDoDia: 'vou viajar?', temCota: false, jaFeita: true),
          SituacaoDaTiragem.jaFeita);
    });

    test('vale para Premium também, e não vira "livre" genérico', () {
      expect(_avaliar(premium: true, jaFeita: true),
          SituacaoDaTiragem.jaFeita);
    });

    test('mesa feita com OUTRA pergunta não protege a pergunta nova', () {
      // Quem decide se a mesa é "a mesma" é a consulta que alimenta
      // `tiragemJaFeitaHoje`; aqui a pergunta nova não tem mesa e a cota
      // acabou.
      expect(
          _avaliar(
              perguntaDoDia: 'vou viajar?',
              pergunta: 'Mudo de casa?',
              temCota: false,
              jaFeita: false),
          SituacaoDaTiragem.semCota);
    });
  });

  group('a prévia não pode discordar da cobrança', () {
    // A tela e o repositório chamam a mesma regra. Se um dia alguém trocar a
    // prévia por um atalho, é aqui que se vê.
    for (final caso in [
      (null, 'Vou viajar?', true),
      ('vou viajar?', 'Vou viajar?', true),
      ('vou viajar?', 'Mudo de casa?', true),
      ('vou viajar?', 'Mudo de casa?', false),
      ('', '', true),
    ]) {
      final (doDia, pergunta, temCota) = caso;
      test('pergunta do dia ${doDia ?? "(nenhuma)"} → "$pergunta" '
          '(cota: $temCota)', () {
        final decisao = decidirTiragem(
          premium: false,
          perguntaDoDia: doDia,
          pergunta: pergunta,
          tiragemJaFeitaHoje: false,
          temCota: temCota,
        );
        final situacao = _avaliar(
            perguntaDoDia: doDia, pergunta: pergunta, temCota: temCota);
        expect(situacao, switch (decisao) {
          DecisaoDaTiragem.liberar ||
          DecisaoDaTiragem.repetir =>
            SituacaoDaTiragem.livre,
          DecisaoDaTiragem.cobrar => SituacaoDaTiragem.gastaUma,
          DecisaoDaTiragem.bloquear => SituacaoDaTiragem.semCota,
        });
      });
    }
  });

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
