/// Modelos dos significados numerológicos, compartilhados pelos arquivos de
/// conteúdo por idioma (`numerology_meanings_data_pt/en/es.dart`).
///
/// Conteúdo determinístico — a IA pode complementar, nunca substituir.
class NumberMeaning {
  final int number;
  final String title;
  final List<String> keywords;
  final String description;
  final String shadow;

  const NumberMeaning({
    required this.number,
    required this.title,
    required this.keywords,
    required this.description,
    required this.shadow,
  });
}

/// Rótulos e explicações de cada número-chave do perfil pessoal.
class ProfileNumberInfo {
  final String label;
  final String emoji;
  final String explanation;

  const ProfileNumberInfo({
    required this.label,
    required this.emoji,
    required this.explanation,
  });
}
