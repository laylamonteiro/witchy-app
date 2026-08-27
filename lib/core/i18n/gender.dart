/// Preferência de tratamento gramatical para textos gerados pelo aplicativo.
///
/// Vale para todo texto que o app escreve para a pessoa: prompts de IA E as
/// frases da tela que precisam concordar em gênero ("Bem-vinda de volta",
/// "Iniciada", "Pelo que você é grata hoje?"). O que a escolha NÃO pode tocar
/// é texto escrito pela pessoa, citação, nome próprio ou conteúdo histórico já
/// gravado.
///
/// Na tela o caminho é sempre o mesmo: três chaves de ARB
/// (`...Feminine`/`...Masculine`/`...Neutral`) escolhidas por
/// [GenderText.select] — ou, quando o único trecho marcado é o vocativo, um
/// `{tratamento}` no meio da frase alimentado pelas chaves `witchTreatment*`.
/// Nunca conjugar no Dart: a frase inteira mora no ARB, um idioma de cada vez.
enum Gender {
  feminine,
  masculine,
  neutral;

  static const fallback = Gender.neutral;

  static Gender fromJson(Object? value) {
    if (value is! String) return fallback;

    return Gender.values.firstWhere(
      (preference) => preference.name == value,
      orElse: () => fallback,
    );
  }

  String toJson() => name;
}

/// Conjunto de variantes textuais por preferência de tratamento.
class GenderVariants {
  final String feminine;
  final String masculine;
  final String neutral;

  const GenderVariants({
    required this.feminine,
    required this.masculine,
    required this.neutral,
  });

  String resolve(Gender preference) {
    return switch (preference) {
      Gender.feminine => feminine,
      Gender.masculine => masculine,
      Gender.neutral => neutral,
    };
  }
}

/// Helper central para seleção de variantes de linguagem por tratamento.
class GenderText {
  const GenderText._();

  static String select({
    required Gender preference,
    required String feminine,
    required String masculine,
    required String neutral,
  }) {
    return GenderVariants(
      feminine: feminine,
      masculine: masculine,
      neutral: neutral,
    ).resolve(preference);
  }

  static String practitioner(Gender preference) {
    return select(
      preference: preference,
      feminine: 'bruxa e praticante',
      masculine: 'bruxo e praticante',
      neutral: 'pessoa praticante',
    );
  }

  static String advisorTitle(Gender preference) {
    return select(
      preference: preference,
      feminine: 'Conselheira Mística',
      masculine: 'Conselheiro Místico',
      neutral: 'Conselho Místico',
    );
  }

  static String wiseGuide(Gender preference) {
    return select(
      preference: preference,
      feminine: 'uma mentora sábia e carinhosa',
      masculine: 'um mentor sábio e carinhoso',
      neutral: 'uma orientação sábia e carinhosa',
    );
  }

  static String aiInstruction(Gender preference) {
    return select(
      preference: preference,
      feminine: 'Use tratamento gramatical feminino para se dirigir à pessoa (ex.: acolhida, conectada, merecedora), quando a frase exigir marcação de gênero.',
      masculine: 'Use tratamento gramatical masculino para se dirigir à pessoa (ex.: acolhido, conectado, merecedor), quando a frase exigir marcação de gênero.',
      neutral: 'Use linguagem sem marcação de gênero para se dirigir à pessoa; prefira construções neutras como "você", "pessoa", "sua jornada" e evite formas marcadas quando possível.',
    );
  }

  static String preservationInstruction() {
    return 'Não altere textos escritos pela pessoa usuária, citações, nomes próprios ou conteúdo histórico fornecido; aplique a preferência apenas ao texto novo gerado pelo sistema.';
  }
}

/// O tratamento em vigor, fora da árvore de widgets.
///
/// Existe pelo mesmo motivo que o `ContentLocale`: há texto de tela montado
/// sem `BuildContext` — os títulos de nível do Grimório Vivo saem de um getter
/// estático do `LearningProvider`, consumido de vários lugares. Quem tem
/// contexto continua lendo do `AuthProvider` (e rebuilda quando a escolha
/// muda); este espelho é para quem não tem.
///
/// É atualizado exclusivamente pelo `AuthProvider`, no mesmo ponto em que ele
/// avisa o `AIService` — assim os dois nunca discordam.
class TratamentoAtual {
  TratamentoAtual._();

  static final TratamentoAtual instance = TratamentoAtual._();

  /// Feminino, e não [Gender.fallback], de propósito: é o padrão de
  /// `UserModel.defaultUser()`. Quem nunca escolheu continua sendo tratada
  /// como sempre foi — mudar isso reescreveria a voz do app para toda a base
  /// que nunca abriu a configuração.
  Gender _preferencia = Gender.feminine;

  Gender get preferencia => _preferencia;

  void definir(Gender preferencia) => _preferencia = preferencia;
}
