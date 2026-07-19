/// Calculadora de Numerologia pitagórica.
///
/// Todos os cálculos são determinísticos e testáveis — a IA nunca calcula,
/// apenas explica resultados. Números mestres (11, 22, 33) são preservados
/// durante as reduções.
class NumerologyCalculator {
  const NumerologyCalculator._();

  /// Tabela pitagórica: A=1 … I=9, J=1 …
  static int letterValue(String letter) {
    final normalized = _normalize(letter);
    if (normalized.isEmpty) return 0;
    final code = normalized.codeUnitAt(0);
    if (code < 65 || code > 90) return 0;
    return ((code - 65) % 9) + 1;
  }

  static const _vowels = {'A', 'E', 'I', 'O', 'U'};

  /// Remove acentos e normaliza para maiúsculas sem símbolos.
  static String _normalize(String input) {
    const accents = 'ÁÀÂÃÄÅáàâãäåÉÈÊËéèêëÍÌÎÏíìîïÓÒÔÕÖóòôõöÚÙÛÜúùûüÇçÑñÝýÿ';
    const plain = 'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuCcNnYyy';
    var result = input;
    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], plain[i]);
    }
    return result.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
  }

  /// Reduz um número somando os algarismos até 1..9, preservando mestres.
  static int reduce(int number, {bool keepMasters = true}) {
    var n = number.abs();
    while (n > 9) {
      if (keepMasters && (n == 11 || n == 22 || n == 33)) return n;
      var sum = 0;
      var rest = n;
      while (rest > 0) {
        sum += rest % 10;
        rest ~/= 10;
      }
      n = sum;
    }
    return n;
  }

  static int _sumLetters(String name, {bool Function(String)? filter}) {
    var total = 0;
    for (final char in _normalize(name).split('')) {
      if (filter != null && !filter(char)) continue;
      total += letterValue(char);
    }
    return total;
  }

  /// Caminho de Vida: soma da data completa de nascimento.
  ///
  /// Reduz dia, mês e ano separadamente (preservando mestres) e então soma
  /// os três — método clássico que evita perder mestres intermediários.
  static int lifePath(DateTime birthDate) {
    final day = reduce(birthDate.day);
    final month = reduce(birthDate.month);
    final year = reduce(_digitSum(birthDate.year));
    return reduce(day + month + year);
  }

  /// Número de Expressão (Destino): todas as letras do nome completo.
  static int expression(String fullName) =>
      reduce(_sumLetters(fullName));

  /// Número da Alma (Desejo da Alma): apenas as vogais.
  static int soulUrge(String fullName) => reduce(
        _sumLetters(fullName, filter: (c) => _vowels.contains(c)),
      );

  /// Número da Personalidade: apenas as consoantes.
  static int personality(String fullName) => reduce(
        _sumLetters(fullName, filter: (c) => !_vowels.contains(c)),
      );

  /// Ano Pessoal: dia + mês de nascimento + ano de referência.
  static int personalYear(DateTime birthDate, {int? referenceYear}) {
    final year = referenceYear ?? DateTime.now().year;
    return reduce(
      reduce(birthDate.day) + reduce(birthDate.month) + reduce(_digitSum(year)),
      keepMasters: false,
    );
  }

  /// Reduz um número livre (consultas avulsas), preservando mestres.
  static int reduceAny(int number) => reduce(number);

  static int _digitSum(int number) {
    var sum = 0;
    var rest = number.abs();
    while (rest > 0) {
      sum += rest % 10;
      rest ~/= 10;
    }
    return sum;
  }

  /// Perfil completo com os 5 números-chave.
  static NumerologyProfile profile({
    required String fullName,
    required DateTime birthDate,
    int? referenceYear,
  }) {
    return NumerologyProfile(
      lifePath: lifePath(birthDate),
      expression: expression(fullName),
      soulUrge: soulUrge(fullName),
      personality: personality(fullName),
      personalYear: personalYear(birthDate, referenceYear: referenceYear),
    );
  }
}

class NumerologyProfile {
  final int lifePath;
  final int expression;
  final int soulUrge;
  final int personality;
  final int personalYear;

  const NumerologyProfile({
    required this.lifePath,
    required this.expression,
    required this.soulUrge,
    required this.personality,
    required this.personalYear,
  });
}
