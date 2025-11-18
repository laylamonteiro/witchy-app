// lib/models/crystal.dart
class Crystal {
  final String id;
  final String name;
  final List<String> intentions; // proteção, foco, amor...
  final String description;
  final String? howToUse;

  const Crystal({
    required this.id,
    required this.name,
    required this.intentions,
    required this.description,
    this.howToUse,
  });
}
