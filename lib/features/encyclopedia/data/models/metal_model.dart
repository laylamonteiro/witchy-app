import 'crystal_model.dart' show Element, ElementExtension;
import 'herb_model.dart' show Planet, PlanetExtension;

class MetalModel {
  final String name;
  final String description;
  final Element element;
  final Planet planet;
  final List<String> magicalProperties;
  final List<String> ritualUses;
  final List<String> correspondences; // Correspondências (deuses, dias da semana, etc)
  final List<String> safetyWarnings;
  final bool conductsPower; // Se conduz energia mágica facilmente
  final String? traditionalUses; // Usos tradicionais em bruxaria
  final String? imageUrl; // URL da imagem do metal

  const MetalModel({
    required this.name,
    required this.description,
    required this.element,
    required this.planet,
    required this.magicalProperties,
    required this.ritualUses,
    required this.correspondences,
    this.safetyWarnings = const [],
    this.conductsPower = true,
    this.traditionalUses,
    this.imageUrl,
  });
}
