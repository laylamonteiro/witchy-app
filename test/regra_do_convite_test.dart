// Pedir avaliação é a única coisa que o app pede para si mesmo — e a mais
// fácil de estragar. Estes casos trancam os dois lados: convidar quem já
// gostou, e nunca insistir com quem já disse que não.
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/reviews/regra_do_convite.dart';

final _agora = DateTime(2026, 9, 15, 20);

/// Uso que já basta para convidar (duas semanas seguidas de prática).
const _bruxaAntiga = UsoAtePagora(sequencia: 14, diasPraticados: 40);

bool _pode({
  MemoriaDoConvite memoria = const MemoriaDoConvite(),
  UsoAtePagora uso = _bruxaAntiga,
  bool temLoja = true,
  DateTime? agora,
  double sorteio = 0,
}) =>
    podeConvidar(
      memoria: memoria,
      uso: uso,
      temLoja: temLoja,
      agora: agora ?? _agora,
      sorteio: sorteio,
    );

void main() {
  group('quem ainda não formou opinião não é perguntada', () {
    test('quem acabou de instalar não vê convite nenhum', () {
      expect(
          _pode(uso: const UsoAtePagora(sequencia: 1, diasPraticados: 1)),
          isFalse,
          reason: 'perguntar cedo é como se colhe nota 1');
      expect(_pode(uso: const UsoAtePagora(sequencia: 0, diasPraticados: 0)),
          isFalse);
    });

    test('uma semana seguida já basta', () {
      expect(
          _pode(
              uso: const UsoAtePagora(
                  sequencia: sequenciaQueBastaParaConvidar,
                  diasPraticados: 7)),
          isTrue);
      expect(
          _pode(uso: const UsoAtePagora(sequencia: 6, diasPraticados: 6)),
          isFalse,
          reason: 'um dia a menos ainda não é hábito');
    });

    test('quem pratica muito, mas não todo dia, também conta', () {
      expect(
          _pode(
              uso: const UsoAtePagora(
                  sequencia: 2,
                  diasPraticados: diasPraticadosQueBastamParaConvidar)),
          isTrue,
          reason: 'sequência curta não quer dizer pouco uso');
    });
  });

  group('quem já respondeu não é perguntada de novo', () {
    test('quem avaliou nunca mais vê o convite', () {
      expect(_pode(memoria: const MemoriaDoConvite(jaAvaliou: true)), isFalse);
      // Nem mesmo depois de muito tempo e de muita prática.
      expect(
          _pode(
              memoria: MemoriaDoConvite(
                  jaAvaliou: true, ultimoConvite: DateTime(2020)),
              agora: DateTime(2030)),
          isFalse);
    });

    test('depois de três dispensas, o convite some para sempre', () {
      expect(
          _pode(
              memoria: MemoriaDoConvite(
                  dispensas: dispensasAteDesistir,
                  ultimoConvite: DateTime(2020))),
          isFalse,
          reason: 'quem disse não três vezes já disse o que tinha a dizer');
      expect(
          _pode(
              memoria: MemoriaDoConvite(
                  dispensas: dispensasAteDesistir + 5,
                  ultimoConvite: DateTime(2020))),
          isFalse);
    });
  });

  group('a espera cresce a cada dispensa', () {
    test('a escada é 2, 5 e 15 dias', () {
      expect(intervaloApos(0), const Duration(days: 2));
      expect(intervaloApos(1), const Duration(days: 5));
      expect(intervaloApos(2), const Duration(days: 15));
    });

    test('dentro da espera, não aparece; passada ela, aparece', () {
      for (final (dispensas, dias) in [(0, 2), (1, 5), (2, 15)]) {
        final ultimo = _agora.subtract(Duration(days: dias));
        expect(
            _pode(
                memoria: MemoriaDoConvite(
                    dispensas: dispensas,
                    ultimoConvite: ultimo.add(const Duration(minutes: 1)))),
            isFalse,
            reason: 'com $dispensas dispensa(s), um minuto antes ainda é cedo');
        expect(
            _pode(
                memoria: MemoriaDoConvite(
                    dispensas: dispensas, ultimoConvite: ultimo)),
            isTrue,
            reason: 'com $dispensas dispensa(s), $dias dias bastam');
      }
    });

    test('o primeiro convite não espera nada', () {
      expect(_pode(memoria: const MemoriaDoConvite()), isTrue);
    });
  });

  group('o convite é encontrado, não esperado', () {
    test('metade dos momentos elegíveis passa', () {
      expect(_pode(sorteio: 0.0), isTrue);
      expect(_pode(sorteio: chanceDeAparecer - 0.01), isTrue);
      expect(_pode(sorteio: chanceDeAparecer), isFalse);
      expect(_pode(sorteio: 0.99), isFalse);
    });

    test('o sorteio não ressuscita quem já foi descartada', () {
      // Sorteio favorável não pode furar nenhuma das travas anteriores.
      expect(_pode(sorteio: 0, memoria: const MemoriaDoConvite(jaAvaliou: true)),
          isFalse);
      expect(_pode(sorteio: 0, temLoja: false), isFalse);
      expect(
          _pode(
              sorteio: 0,
              uso: const UsoAtePagora(sequencia: 0, diasPraticados: 0)),
          isFalse);
    });
  });

  test('onde não há loja, não há convite', () {
    // A web roda o mesmo app e não tem Play Store para abrir.
    expect(_pode(temLoja: false), isFalse);
  });

  test('em ritmo de prática diária, dá algumas vezes por semana', () {
    // O pedido era esse: nem todo dia, nem uma vez por mês.
    //
    // O sorteio vem de um gerador simples e reproduzível — alternar par/ímpar
    // casaria certinho com a espera de 2 dias e daria o TETO em vez de uma
    // amostra.
    var semente = 7;
    double proximoSorteio() {
      semente = (semente * 1103515245 + 12345) & 0x7fffffff;
      return (semente % 1000) / 1000;
    }

    DateTime? ultimo;
    final diasComConvite = <int>[];
    for (var dia = 1; dia <= 28; dia++) {
      final hoje = _agora.add(Duration(days: dia));
      final passou = podeConvidar(
        memoria: MemoriaDoConvite(ultimoConvite: ultimo),
        uso: _bruxaAntiga,
        temLoja: true,
        agora: hoje,
        sorteio: proximoSorteio(),
      );
      if (passou) {
        diasComConvite.add(dia);
        ultimo = hoje;
      }
    }

    // Quatro semanas: nem um por dia, nem quase nada.
    expect(diasComConvite.length, inInclusiveRange(4, 14),
        reason: 'deu ${diasComConvite.length} convites em quatro semanas');

    // E o que o intervalo garante, independente de sorte: nunca dois convites
    // com menos de dois dias entre eles.
    for (var i = 1; i < diasComConvite.length; i++) {
      expect(diasComConvite[i] - diasComConvite[i - 1],
          greaterThanOrEqualTo(intervalosDoConvite.first.inDays),
          reason: 'convites em ${diasComConvite[i - 1]} e ${diasComConvite[i]}');
    }
  });
}
