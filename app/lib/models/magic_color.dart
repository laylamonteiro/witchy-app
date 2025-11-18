// lib/models/magic_color.dart
class MagicColor {
  final String id;
  final String name;
  final String hex;
  final List<String> intentions;
  final String description;

  const MagicColor({
    required this.id,
    required this.name,
    required this.hex,
    required this.intentions,
    required this.description,
  });
}
