import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/cycles/domain/cycle_time.dart';
import 'package:grimorio_de_bolso/features/cycles/domain/era_ruler.dart';
import 'package:grimorio_de_bolso/features/cycles/domain/life_eras_calculator.dart';
import 'package:grimorio_de_bolso/features/cycles/domain/life_timeline.dart';

/// "aaaa-MM" — a precisão em que o caso de referência foi validado.
String mesAno(DateTime d) =>
    '${d.toUtc().year}-${d.toUtc().month.toString().padLeft(2, '0')}';

/// Caso de referência, conferido contra o sistema de origem.
const goldenLongitudeLua = 83.4598;
final goldenNascimento = DateTime.utc(1994, 8, 15, 12, 0);

LinhaDoTempo golden() => calcularLinhaDoTempo(
      longitudeLuaTropical: goldenLongitudeLua,
      nascimentoUtc: goldenNascimento,
    );

void main() {
  group('Ordem canônica', () {
    test('as nove Eras somam exatamente 120 anos', () {
      expect(kTotalAnosDoCiclo, 120);
    });

    test('a ordem é circular: depois de Mercúrio vem A Cauda', () {
      expect(EraRegente.mercurio.proximo, EraRegente.cauda);
      expect(EraRegente.mercurio.avancar(1), EraRegente.cauda);
      expect(EraRegente.cauda.avancar(9), EraRegente.cauda);
    });

    test('as durações são as canônicas', () {
      expect(EraRegente.cauda.anos, 7);
      expect(EraRegente.venus.anos, 20);
      expect(EraRegente.sol.anos, 6);
      expect(EraRegente.lua.anos, 10);
      expect(EraRegente.marte.anos, 7);
      expect(EraRegente.serpente.anos, 18);
      expect(EraRegente.jupiter.anos, 16);
      expect(EraRegente.saturno.anos, 19);
      expect(EraRegente.mercurio.anos, 17);
    });
  });

  group('Ayanamsa', () {
    test('vale ~23,85 na âncora de 2000 e cresce com o tempo', () {
      expect(ayanamsaLahiri(DateTime.utc(2000, 1, 1)), closeTo(23.85306, 1e-6));
      expect(ayanamsaLahiri(DateTime.utc(2020, 1, 1)),
          greaterThan(ayanamsaLahiri(DateTime.utc(2000, 1, 1))));
    });

    test('o sideral fica ATRÁS do tropical', () {
      // Guarda contra a regressão de trocar o sinal da subtração: isso
      // deslocaria a linha do tempo inteira em cerca de um setor lunar.
      final ayanamsa = ayanamsaLahiri(goldenNascimento);
      expect(ayanamsa, closeTo(23.7779, 1e-3));
      final sideral = goldenLongitudeLua - ayanamsa;
      expect(sideral, lessThan(goldenLongitudeLua));
      expect(sideral, closeTo(59.6819, 1e-3));
    });
  });

  group('Caso de referência', () {
    test('regente natal, setor lunar e saldo da primeira Era', () {
      final linha = golden();
      expect(linha.regenteNatal, EraRegente.marte);
      expect(linha.nakshatra, 4);
      expect(linha.saldoInicialAnos, closeTo(3.667, 0.01));
    });

    test('as nove Eras batem ao mês', () {
      final linha = golden();
      final esperado = <(EraRegente, String, String)>[
        (EraRegente.marte, '1994-08', '1998-04'),
        (EraRegente.serpente, '1998-04', '2016-04'),
        (EraRegente.jupiter, '2016-04', '2032-04'),
        (EraRegente.saturno, '2032-04', '2051-04'),
        (EraRegente.mercurio, '2051-04', '2068-04'),
        (EraRegente.cauda, '2068-04', '2075-04'),
        (EraRegente.venus, '2075-04', '2095-04'),
        (EraRegente.sol, '2095-04', '2101-04'),
        (EraRegente.lua, '2101-04', '2111-04'),
      ];

      expect(linha.eras.length, 9);
      for (var i = 0; i < esperado.length; i++) {
        final (regente, inicio, fim) = esperado[i];
        expect(linha.eras[i].regente, regente, reason: 'Era $i');
        expect(mesAno(linha.eras[i].inicio), inicio, reason: 'início da Era $i');
        expect(mesAno(linha.eras[i].fim), fim, reason: 'fim da Era $i');
      }
    });

    test('a Fase de Vênus dentro de Júpiter vai de Fev 2024 a Out 2026', () {
      final linha = golden();
      final jupiter =
          linha.eras.firstWhere((e) => e.regente == EraRegente.jupiter);
      final fase =
          jupiter.fases.firstWhere((f) => f.regente == EraRegente.venus);

      expect(mesAno(fase.inicio), '2024-02');
      expect(mesAno(fase.fim), '2026-10');
      expect(fase.duracaoEmAnos, closeTo(2.667, 0.01));
    });
  });

  group('Recorte das Fases da primeira Era', () {
    test('em Jun 1996 a Fase é a de Vênus, não a de Mercúrio', () {
      // Este é o teste que separa o recorte correto (a partir de um início
      // virtual anterior ao nascimento) da subdivisão ingênua do saldo em nove
      // partes, que devolveria Mercúrio aqui — mais de um ano de erro.
      final fase = golden().faseEm(DateTime.utc(1996, 6, 15));
      expect(fase.regenteDaEra, EraRegente.marte);
      expect(fase.regente, EraRegente.venus);
    });

    test('nenhuma Fase sobrevive terminando antes do nascimento', () {
      final primeira = golden().eras.first;
      expect(primeira.parcial, isTrue);
      for (final fase in primeira.fases) {
        expect(fase.fim.isAfter(goldenNascimento), isTrue,
            reason: 'Fase de ${fase.regente.name} termina antes do nascimento');
      }
    });

    test('a primeira Fase começa exatamente no nascimento e a última fecha a Era',
        () {
      final primeira = golden().eras.first;
      expect(primeira.fases.first.inicio, primeira.inicio);
      expect(primeira.fases.last.fim, primeira.fim);
      // A Era parcial perde Fases pelo caminho; as demais têm as nove.
      expect(primeira.fases.length, lessThan(9));
    });

    test('as Eras completas têm as nove Fases, começando pelo próprio regente',
        () {
      for (final era in golden().eras.skip(1)) {
        expect(era.parcial, isFalse);
        expect(era.fases.length, 9, reason: 'Era de ${era.regente.name}');
        expect(era.fases.first.regente, era.regente);
        expect(era.fases.first.inicio, era.inicio);
        expect(era.fases.last.fim, era.fim);
      }
    });
  });

  group('Fronteira de setor lunar', () {
    test('longitudes vizinhas de um múltiplo de 13°20\' caem em Eras vizinhas',
        () {
      final quando = DateTime.utc(1990, 6, 1);
      final ayanamsa = ayanamsaLahiri(quando);
      // Fronteira entre o 5º e o 6º setor (índices 4 e 5).
      final fronteiraTropical = 5 * kNakshatraGraus + ayanamsa;

      final antes = calcularLinhaDoTempo(
          longitudeLuaTropical: fronteiraTropical - 0.01,
          nascimentoUtc: quando);
      final depois = calcularLinhaDoTempo(
          longitudeLuaTropical: fronteiraTropical + 0.01,
          nascimentoUtc: quando);

      expect(antes.nakshatra, 4);
      expect(depois.nakshatra, 5);
      expect(antes.regenteNatal, EraRegente.marte);
      expect(depois.regenteNatal, EraRegente.serpente);
    });

    test('logo antes da fronteira o saldo é mínimo; logo depois é quase cheio',
        () {
      final quando = DateTime.utc(1990, 6, 1);
      final fronteira = 5 * kNakshatraGraus + ayanamsaLahiri(quando);

      final antes = calcularLinhaDoTempo(
          longitudeLuaTropical: fronteira - 0.001, nascimentoUtc: quando);
      final depois = calcularLinhaDoTempo(
          longitudeLuaTropical: fronteira + 0.001, nascimentoUtc: quando);

      expect(antes.saldoInicialAnos, lessThan(0.01));
      expect(depois.saldoInicialAnos,
          closeTo(EraRegente.serpente.anos.toDouble(), 0.01));
    });

    test('o setor 26 volta para Mercúrio (26 % 9 = 8)', () {
      final quando = DateTime.utc(1990, 6, 1);
      final tropical =
          (26 * kNakshatraGraus + 5 + ayanamsaLahiri(quando)) % 360.0;
      final linha = calcularLinhaDoTempo(
          longitudeLuaTropical: tropical, nascimentoUtc: quando);
      expect(linha.nakshatra, 26);
      expect(linha.regenteNatal, EraRegente.mercurio);
      expect(linha.eras[1].regente, EraRegente.cauda);
    });
  });

  group('Progresso', () {
    test('vai de 0.0 a 1.0 e fica clampado fora do intervalo', () {
      final era = golden().eras[2]; // Júpiter, uma Era completa
      expect(era.progresso(era.inicio), 0.0);
      expect(era.progresso(era.fim), 1.0);
      expect(era.progresso(era.inicio.subtract(const Duration(days: 900))), 0.0);
      expect(era.progresso(era.fim.add(const Duration(days: 900))), 1.0);

      final meio = era.inicio.add(era.duracao ~/ 2);
      expect(era.progresso(meio), closeTo(0.5, 0.001));
    });
  });

  group('Consultas', () {
    test('passadas + corrente + futuras reconstroem as nove Eras', () {
      final linha = golden();
      final quando = DateTime.utc(2026, 3, 1);
      final passadas = linha.passadas(quando);
      final futuras = linha.futuras(quando);
      final corrente = linha.eraEm(quando);

      expect(passadas.length + 1 + futuras.length, 9);
      expect(passadas.contains(corrente), isFalse);
      expect(futuras.contains(corrente), isFalse);
      expect(corrente.regente, EraRegente.jupiter);
      // O passado sai do mais recente para o mais antigo.
      expect(passadas.first.regente, EraRegente.serpente);
      expect(passadas.last.regente, EraRegente.marte);
      expect(futuras.first.regente, EraRegente.saturno);
    });

    test('as Eras se encadeiam sem buraco nem sobreposição', () {
      final eras = golden().eras;
      for (var i = 0; i < eras.length - 1; i++) {
        expect(eras[i].fim, eras[i + 1].inicio, reason: 'emenda $i');
      }
      for (final era in eras) {
        for (var i = 0; i < era.fases.length - 1; i++) {
          expect(era.fases[i].fim, era.fases[i + 1].inicio,
              reason: 'emenda de Fase $i em ${era.regente.name}');
        }
      }
    });

    test('fora da linha do tempo devolve a primeira ou a última Era', () {
      final linha = golden();
      expect(linha.eraEm(DateTime.utc(1950)).regente, EraRegente.marte);
      expect(linha.eraEm(DateTime.utc(2200)).regente, EraRegente.lua);
    });
  });

  group('Serialização', () {
    test('ida e volta em JSON preserva regentes e datas', () {
      final original = golden();
      final copia = LinhaDoTempo.fromJson(original.toJson());

      expect(copia.regenteNatal, original.regenteNatal);
      expect(copia.nakshatra, original.nakshatra);
      expect(copia.saldoInicialAnos, closeTo(original.saldoInicialAnos, 1e-9));
      expect(copia.nascimentoUtc, original.nascimentoUtc);
      expect(copia.eras.length, original.eras.length);

      for (var i = 0; i < original.eras.length; i++) {
        expect(copia.eras[i].regente, original.eras[i].regente);
        expect(copia.eras[i].inicio, original.eras[i].inicio);
        expect(copia.eras[i].fim, original.eras[i].fim);
        expect(copia.eras[i].parcial, original.eras[i].parcial);
        expect(copia.eras[i].fases.length, original.eras[i].fases.length);
      }
    });
  });

  group('Robustez', () {
    test('mil nascimentos aleatórios mantêm as invariantes', () {
      // Semente fixa: o teste precisa falhar sempre no mesmo caso.
      var semente = 20260820;
      double proximo() {
        semente = (semente * 1103515245 + 12345) & 0x7FFFFFFF;
        return semente / 0x7FFFFFFF;
      }

      for (var i = 0; i < 1000; i++) {
        final longitude = proximo() * 360.0;
        final nascimento = DateTime.utc(1940, 1, 1)
            .add(Duration(minutes: (proximo() * 43200000).round()));
        final linha = calcularLinhaDoTempo(
            longitudeLuaTropical: longitude, nascimentoUtc: nascimento);

        expect(linha.nakshatra, inInclusiveRange(0, 26));
        expect(linha.eras.length, 9);
        expect(linha.eras.first.inicio, nascimento);
        expect(linha.saldoInicialAnos,
            inInclusiveRange(0, linha.regenteNatal.anos.toDouble()));

        for (final era in linha.eras) {
          expect(era.fases, isNotEmpty);
          expect(era.fases.first.inicio, era.inicio);
          expect(era.fases.last.fim, era.fim);
        }
      }
    });
  });
}
