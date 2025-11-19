import 'package:flutter/foundation.dart';
import '../../data/models/crystal_model.dart';
import '../../data/models/color_model.dart';
import '../../data/data_sources/crystals_data.dart';
import '../../data/data_sources/colors_data.dart';

class EncyclopediaProvider with ChangeNotifier {
  final List<CrystalModel> _crystals = crystalsData;
  final List<ColorModel> _colors = colorsData;

  List<CrystalModel> get crystals => _crystals;
  List<ColorModel> get colors => _colors;

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
}
