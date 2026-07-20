/// Modelos dos temas e simbolismos oníricos exibidos como cards na seção de
/// Interpretação de Sonhos. Conteúdo estático e gratuito.
class DreamTheme {
  final String id;
  final String emoji;
  final String title;
  final String summary;

  /// Diferentes possibilidades de leitura do símbolo — o texto sempre
  /// apresenta hipóteses, nunca certezas.
  final List<DreamThemeReading> readings;

  /// Convite final à reflexão pessoal.
  final String reflection;

  const DreamTheme({
    required this.id,
    required this.emoji,
    required this.title,
    required this.summary,
    required this.readings,
    required this.reflection,
  });
}

class DreamThemeReading {
  final String title;
  final String content;

  const DreamThemeReading({required this.title, required this.content});
}
