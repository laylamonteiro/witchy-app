import 'package:flutter/foundation.dart';
import '../../data/models/crystal_model.dart';
import '../../data/models/color_model.dart';
import '../../data/models/herb_model.dart';
import '../../data/models/metal_model.dart';
import '../../data/data_sources/crystals_data.dart';
import '../../data/data_sources/colors_data.dart';
import '../../data/data_sources/herbs_data.dart';
import '../../data/data_sources/metals_data.dart';

class EncyclopediaProvider with ChangeNotifier {
  final List<CrystalModel> _crystals = crystalsData;
  final List<ColorModel> _colors = colorsData;
  final List<HerbModel> _herbs = herbsData;
  final List<MetalModel> _metals = metalsData;

  List<CrystalModel> get crystals => _crystals;
  List<ColorModel> get colors => _colors;
  List<HerbModel> get herbs => _herbs;
  List<MetalModel> get metals => _metals;

  List<CrystalModel> searchCrystals(String query) {
    final lowerQuery = query.toLowerCase();
    return _crystals.where((crystal) {
      return crystal.name.toLowerCase().contains(lowerQuery) ||
          crystal.description.toLowerCase().contains(lowerQuery) ||
          crystal.intentions.any((i) => i.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<ColorModel> searchColors(String query) {
    final lowerQuery = query.toLowerCase();
    return _colors.where((color) {
      return color.name.toLowerCase().contains(lowerQuery) ||
          color.meaning.toLowerCase().contains(lowerQuery) ||
          color.intentions.any((i) => i.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<CrystalModel> getCrystalsByElement(Element element) {
    return _crystals.where((crystal) => crystal.element == element).toList();
  }

  List<CrystalModel> getCrystalsByIntention(String intention) {
    return _crystals.where((crystal) {
      return crystal.intentions
          .any((i) => i.toLowerCase().contains(intention.toLowerCase()));
    }).toList();
  }

  List<ColorModel> getColorsByIntention(String intention) {
    return _colors.where((color) {
      return color.intentions
          .any((i) => i.toLowerCase().contains(intention.toLowerCase()));
    }).toList();
  }

  List<HerbModel> searchHerbs(String query) {
    final lowerQuery = query.toLowerCase();
    return _herbs.where((herb) {
      return herb.name.toLowerCase().contains(lowerQuery) ||
          herb.description.toLowerCase().contains(lowerQuery) ||
          herb.magicalProperties
              .any((p) => p.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<HerbModel> getHerbsByElement(HerbElement element) {
    return _herbs.where((herb) => herb.element == element).toList();
  }

  List<HerbModel> getHerbsByPlanet(Planet planet) {
    return _herbs.where((herb) => herb.planet == planet).toList();
  }

  List<HerbModel> getHerbsByProperty(String property) {
    return _herbs.where((herb) {
      return herb.magicalProperties
          .any((p) => p.toLowerCase().contains(property.toLowerCase()));
    }).toList();
  }

  List<HerbModel> getSafeHerbs() {
    return _herbs.where((herb) => !herb.toxic).toList();
  }

  List<HerbModel> getEdibleHerbs() {
    return _herbs.where((herb) => herb.edible).toList();
  }

  // Métodos para Metais
  List<MetalModel> searchMetals(String query) {
    final lowerQuery = query.toLowerCase();
    return _metals.where((metal) {
      return metal.name.toLowerCase().contains(lowerQuery) ||
          metal.description.toLowerCase().contains(lowerQuery) ||
          metal.magicalProperties
              .any((p) => p.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<MetalModel> getMetalsByElement(Element element) {
    return _metals.where((metal) => metal.element == element).toList();
  }

  List<MetalModel> getMetalsByPlanet(Planet planet) {
    return _metals.where((metal) => metal.planet == planet).toList();
  }

  List<MetalModel> getMetalsByProperty(String property) {
    return _metals.where((metal) {
      return metal.magicalProperties
          .any((p) => p.toLowerCase().contains(property.toLowerCase()));
    }).toList();
  }

  List<MetalModel> getConductiveMetals() {
    return _metals.where((metal) => metal.conductsPower).toList();
  }
}
