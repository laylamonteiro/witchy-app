/// Preferência de tratamento gramatical para textos gerados pelo aplicativo.
///
/// A preferência deve ser aplicada somente a textos do sistema ou prompts de IA.
/// Não transforme textos escritos pelo usuário, citações, nomes próprios ou
/// conteúdo histórico já persistido.
enum TreatmentPreference {
  feminine,
  masculine,
  neutral;

  static const fallback = TreatmentPreference.neutral;

  static TreatmentPreference fromJson(Object? value) {
    if (value is! String) return fallback;

    return TreatmentPreference.values.firstWhere(
      (preference) => preference.name == value,
      orElse: () => fallback,
    );
  }

  String toJson() => name;
}

/// Conjunto de variantes textuais por preferência de tratamento.
class TreatmentVariants {
  final String feminine;
  final String masculine;
  final String neutral;

  const TreatmentVariants({
    required this.feminine,
    required this.masculine,
    required this.neutral,
  });

  String resolve(TreatmentPreference preference) {
    return switch (preference) {
      TreatmentPreference.feminine => feminine,
      TreatmentPreference.masculine => masculine,
      TreatmentPreference.neutral => neutral,
    };
  }
}

/// Helper central para seleção de variantes de linguagem por tratamento.
class TreatmentText {
  const TreatmentText._();

  static String select({
    required TreatmentPreference preference,
    required String feminine,
    required String masculine,
    required String neutral,
  }) {
    return TreatmentVariants(
      feminine: feminine,
      masculine: masculine,
      neutral: neutral,
    ).resolve(preference);
  }

  static String practitioner(TreatmentPreference preference) {
    return select(
      preference: preference,
      feminine: 'bruxa e praticante',
      masculine: 'bruxo e praticante',
      neutral: 'pessoa praticante',
    );
  }

  static String advisorTitle(TreatmentPreference preference) {
    return select(
      preference: preference,
      feminine: 'Conselheira Mística',
      masculine: 'Conselheiro Místico',
      neutral: 'Conselho Místico',
    );
  }

  static String wiseGuide(TreatmentPreference preference) {
    return select(
      preference: preference,
      feminine: 'uma mentora sábia e carinhosa',
      masculine: 'um mentor sábio e carinhoso',
      neutral: 'uma orientação sábia e carinhosa',
    );
  }

  static String aiInstruction(TreatmentPreference preference) {
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
