import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/numerology/domain/numerology_calculator.dart';

void main() {
  group('Tabela pitagórica', () {
    test('mapeia letras para valores 1-9', () {
      expect(NumerologyCalculator.letterValue('A'), 1);
      expect(NumerologyCalculator.letterValue('I'), 9);
      expect(NumerologyCalculator.letterValue('J'), 1);
      expect(NumerologyCalculator.letterValue('R'), 9);
      expect(NumerologyCalculator.letterValue('S'), 1);
      expect(NumerologyCalculator.letterValue('Z'), 8);
    });

    test('normaliza acentos e ignora símbolos', () {
      expect(NumerologyCalculator.letterValue('á'), 1);
      expect(NumerologyCalculator.letterValue('Ç'), 3); // C
      expect(NumerologyCalculator.letterValue('-'), 0);
      expect(NumerologyCalculator.letterValue(' '), 0);
    });
  });

  group('Redução', () {
    test('reduz até um dígito', () {
      expect(NumerologyCalculator.reduce(28), 1); // 2+8=10 -> 1
      expect(NumerologyCalculator.reduce(1985), 5); // 23 -> 5
      expect(NumerologyCalculator.reduce(9), 9);
    });

    test('preserva números mestres 11, 22 e 33', () {
      expect(NumerologyCalculator.reduce(11), 11);
      expect(NumerologyCalculator.reduce(22), 22);
      expect(NumerologyCalculator.reduce(33), 33);
      // 29 -> 11 (mestre) permanece
      expect(NumerologyCalculator.reduce(29), 11);
    });

    test('sem mestres quando keepMasters=false', () {
      expect(NumerologyCalculator.reduce(29, keepMasters: false), 2);
      expect(NumerologyCalculator.reduce(22, keepMasters: false), 4);
    });
  });

  group('Caminho de Vida', () {
    test('caso clássico: 15/07/1990', () {
      // dia 15->6, mês 7, ano 1990->19->1 (1+9+9+0=19->10->1); 6+7+1=14->5
      expect(NumerologyCalculator.lifePath(DateTime(1990, 7, 15)), 5);
    });

    test('preserva mestre no resultado final', () {
      // 29/11/1975: dia 29->11(mestre), mês 11(mestre), ano 1975->22(mestre)
      // 11+11+22=44 -> 8
      expect(NumerologyCalculator.lifePath(DateTime(1975, 11, 29)), 8);
    });
  });

  group('Números do nome', () {
    // MARIA: M=4 A=1 R=9 I=9 A=1 => 24 -> 6
    // vogais A,I,A = 1+9+1 = 11 (mestre)
    // consoantes M,R = 4+9 = 13 -> 4
    test('expressão de MARIA', () {
      expect(NumerologyCalculator.expression('Maria'), 6);
    });

    test('alma de MARIA preserva mestre 11', () {
      expect(NumerologyCalculator.soulUrge('Maria'), 11);
    });

    test('personalidade de MARIA', () {
      expect(NumerologyCalculator.personality('Maria'), 4);
    });

    test('acentos não mudam o resultado', () {
      expect(
        NumerologyCalculator.expression('José da Silva'),
        NumerologyCalculator.expression('Jose da Silva'),
      );
    });

    test('expressão = alma + personalidade (antes da redução final)', () {
      const name = 'Ana Clara Souza';
      final vowels = NumerologyCalculator.soulUrge(name);
      final consonants = NumerologyCalculator.personality(name);
      final expression = NumerologyCalculator.expression(name);
      // A soma reduzida das partes deve reduzir ao mesmo dígito da expressão
      // (propriedade da soma digital), exceto interações com mestres.
      expect(
        NumerologyCalculator.reduce(vowels + consonants, keepMasters: false),
        NumerologyCalculator.reduce(expression, keepMasters: false),
      );
    });
  });

  group('Ano Pessoal', () {
    test('é determinístico para um ano de referência fixo', () {
      // 15/07 em 2026: 6 + 7 + (2+0+2+6=10->1) = 14 -> 5
      expect(
        NumerologyCalculator.personalYear(
          DateTime(1990, 7, 15),
          referenceYear: 2026,
        ),
        5,
      );
    });
  });

  group('Perfil completo', () {
    test('gera os 5 números de uma vez', () {
      final profile = NumerologyCalculator.profile(
        fullName: 'Maria',
        birthDate: DateTime(1990, 7, 15),
        referenceYear: 2026,
      );
      expect(profile.lifePath, 5);
      expect(profile.expression, 6);
      expect(profile.soulUrge, 11);
      expect(profile.personality, 4);
      expect(profile.personalYear, 5);
    });
  });
}
