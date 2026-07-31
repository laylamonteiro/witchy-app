import '../data_sources/runes_data.dart';

/// Modelo para representar uma runa do Futhark Antigo
class Rune {
  final String name;
  final String symbol;
  final List<String> keywords;
  final String description;

  const Rune({
    required this.name,
    required this.symbol,
    required this.keywords,
    required this.description,
  });

  // Aliases para compatibilidade
  String get meaning => description;
  String get divination => description;
  String? get reversedMeaning => null; // Runas podem ser interpretadas ao contrário

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'keywords': keywords,
      'description': description,
    };
  }

  factory Rune.fromJson(Map<String, dynamic> json) {
    return Rune(
      name: json['name'],
      symbol: json['symbol'],
      keywords: List<String>.from(json['keywords']),
      description: json['description'],
    );
  }

  /// Lista completa das 24 runas do Futhark Antigo, no idioma atual.
  ///
  /// O conteúdo vive em `data_sources/runes_data_{pt,en,es}.dart`.
  static List<Rune> getAllRunes() => runesData;

  /// Buscar runa por nome
  static Rune? findByName(String name) {
    try {
      return getAllRunes().firstWhere(
        (rune) => rune.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
