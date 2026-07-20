/// Modelo compartilhado das categorias "arcanas" da Enciclopédia:
/// Arquétipos, Anjos, Demônios e Símbolos Sagrados.
///
/// Estrutura segue o padrão editorial das demais categorias, com o cuidado
/// extra de que Anjos e Demônios são tratados de forma histórico-informativa,
/// diferenciando tradições sem apresentar uma única interpretação como
/// verdade absoluta.
class ArcaneEntry {
  final String name;
  final String emoji;

  /// Resumo curto exibido na lista.
  final String summary;

  /// Origem cultural/tradicional.
  final String origin;

  /// Contexto histórico.
  final String history;

  /// Características principais.
  final List<String> characteristics;

  /// Simbolismos associados.
  final List<String> symbolism;

  /// Correspondências mágicas (cores, ervas, cristais, dias...).
  final List<String> correspondences;

  /// Como diferentes tradições enxergam a figura (religiosa, folclórica,
  /// ocultista, literária). Usado principalmente em Anjos e Demônios.
  final List<ArcanePerspective> perspectives;

  /// Formas de estudo ou contemplação.
  final List<String> studyPractices;

  /// Usos mágicos.
  final List<String> magicalUses;

  /// Cuidados e observações.
  final String cautions;

  /// Referências internas relacionadas (outras entradas/áreas do app).
  final List<String> related;

  const ArcaneEntry({
    required this.name,
    required this.emoji,
    required this.summary,
    required this.origin,
    required this.history,
    this.characteristics = const [],
    this.symbolism = const [],
    this.correspondences = const [],
    this.perspectives = const [],
    this.studyPractices = const [],
    this.magicalUses = const [],
    this.cautions = '',
    this.related = const [],
  });
}

class ArcanePerspective {
  final String tradition;
  final String view;

  const ArcanePerspective({required this.tradition, required this.view});
}

/// Caminho da imagem de um verbete arcano:
/// assets/images/<categoria>/<slug>.webp (slug = nome minúsculo sem acento).
/// Usado pela lista e pelo detalhe — fallback visual é o emoji do verbete.
String arcaneImageAsset(String categoryTitle, String name) {
  const folders = {
    'Arquétipos': 'arquetipos',
    'Anjos': 'anjos',
    'Demônios': 'demonios',
    'Símbolos Sagrados': 'simbolos',
  };
  const accents = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const plain = 'aaaaaeeeeiiiiooooouuuucn';
  var slug = name.trim().toLowerCase();
  for (var i = 0; i < accents.length; i++) {
    slug = slug.replaceAll(accents[i], plain[i]);
  }
  slug = slug.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return 'assets/images/${folders[categoryTitle] ?? 'outros'}/$slug.webp';
}
