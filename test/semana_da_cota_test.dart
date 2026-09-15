// A cota do Conselheiro é a única semanal do app, e a virada da semana é
// aritmética de calendário — o tipo de coisa que erra na virada do ano e só
// aparece em janeiro.
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/domain/semana_da_cota.dart';

void main() {
  group('chaveDaSemana — a semana começa na segunda', () {
    test('os sete dias de uma semana têm a mesma chave', () {
      // 14/9/2026 é uma segunda; 20/9 é o domingo seguinte.
      final segunda = DateTime(2026, 9, 14);
      for (var i = 0; i < 7; i++) {
        expect(chaveDaSemana(DateTime(2026, 9, 14 + i)),
            chaveDaSemana(segunda),
            reason: 'dia ${14 + i}');
      }
    });

    test('a segunda seguinte já é outra semana', () {
      expect(chaveDaSemana(DateTime(2026, 9, 20)),
          isNot(chaveDaSemana(DateTime(2026, 9, 21))),
          reason: 'domingo e segunda são semanas diferentes');
    });

    test('a hora do dia não conta', () {
      expect(chaveDaSemana(DateTime(2026, 9, 16, 0, 0, 1)),
          chaveDaSemana(DateTime(2026, 9, 16, 23, 59, 59)));
    });

    test('a virada do mês não quebra a semana', () {
      // 28/9/2026 é segunda; a semana atravessa para outubro.
      expect(chaveDaSemana(DateTime(2026, 9, 28)),
          chaveDaSemana(DateTime(2026, 10, 4)));
      expect(chaveDaSemana(DateTime(2026, 10, 5)),
          isNot(chaveDaSemana(DateTime(2026, 10, 4))));
    });

    test('a virada do ANO não quebra a semana', () {
      // 28/12/2026 é segunda; a semana termina em 3/1/2027. É aqui que uma
      // conta por número de semana ISO daria duas chaves para a mesma semana.
      expect(chaveDaSemana(DateTime(2026, 12, 28)),
          chaveDaSemana(DateTime(2027, 1, 3)));
      expect(chaveDaSemana(DateTime(2027, 1, 4)),
          isNot(chaveDaSemana(DateTime(2027, 1, 3))));
    });

    test('anos bissextos passam sem susto', () {
      // 28/2/2028 é segunda, e a semana dela atravessa o 29 de fevereiro até
      // domingo 5 de março.
      expect(chaveDaSemana(DateTime(2028, 2, 29)),
          chaveDaSemana(DateTime(2028, 2, 28)));
      expect(chaveDaSemana(DateTime(2028, 3, 5)),
          chaveDaSemana(DateTime(2028, 2, 28)));
      expect(chaveDaSemana(DateTime(2028, 2, 27)),
          isNot(chaveDaSemana(DateTime(2028, 2, 28))),
          reason: 'o domingo anterior é a semana de antes');
    });

    test('nenhuma data fica sem semana, num ano inteiro', () {
      final chaves = <String>{};
      var dia = DateTime(2026, 1, 1);
      while (dia.isBefore(DateTime(2027, 1, 1))) {
        chaves.add(chaveDaSemana(dia));
        dia = DateTime(dia.year, dia.month, dia.day + 1);
      }
      // 365 dias caem em 53 segundas distintas (a primeira é de 2025).
      expect(chaves.length, inInclusiveRange(52, 54));
    });
  });

  group('virouASemana', () {
    test('no mesmo dia e na mesma semana, não virou', () {
      final terca = DateTime(2026, 9, 15, 9);
      expect(virouASemana(ultimoReset: terca, agora: terca), isFalse);
      expect(
          virouASemana(
              ultimoReset: terca, agora: DateTime(2026, 9, 20, 23, 59)),
          isFalse,
          reason: 'até o domingo é a mesma semana');
    });

    test('na segunda seguinte, virou', () {
      expect(
          virouASemana(
              ultimoReset: DateTime(2026, 9, 15),
              agora: DateTime(2026, 9, 21)),
          isTrue);
    });

    test('um relógio que anda para trás não vira a semana de graça', () {
      // Não é "passou tempo o bastante": é "a segunda-feira mudou". Voltar no
      // tempo dentro da mesma semana não devolve a leitura.
      expect(
          virouASemana(
              ultimoReset: DateTime(2026, 9, 18),
              agora: DateTime(2026, 9, 15)),
          isFalse);
    });
  });
}
