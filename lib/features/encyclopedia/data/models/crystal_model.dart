import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';

/// Strings do idioma atual sem BuildContext (modelos são usados fora da
/// árvore de widgets); o locale vem do ContentLocale, setado pelo
/// LanguageProvider.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

enum Element {
  earth,
  water,
  air,
  fire,
  spirit,
}

/// Método de limpeza ou carregamento com flag de segurança
class CrystalMethod {
  final String method;
  final bool isSafe;
  final String? warning;

  const CrystalMethod({
    required this.method,
    required this.isSafe,
    this.warning,
  });
}

class CrystalModel {
  final String name;
  final String description;
  final Element element;
  final List<String> intentions;
  final List<String> usageTips;
  final List<CrystalMethod> cleaningMethods;
  final List<CrystalMethod> chargingMethods;
  final List<String> safetyWarnings; // ⚠️ Avisos de segurança
  final String? imageUrl; // 🖼️ URL da imagem do cristal

  const CrystalModel({
    required this.name,
    required this.description,
    required this.element,
    required this.intentions,
    required this.usageTips,
    required this.cleaningMethods,
    required this.chargingMethods,
    this.safetyWarnings = const [],
    this.imageUrl, // 🖼️ Opcional
  });

  /// Métodos de limpeza seguros (apenas os que isSafe == true)
  List<String> get safeCleaningMethods =>
      cleaningMethods.where((m) => m.isSafe).map((m) => m.method).toList();

  /// Métodos de carregamento seguros (apenas os que isSafe == true)
  List<String> get safeChargingMethods =>
      chargingMethods.where((m) => m.isSafe).map((m) => m.method).toList();
}

extension ElementExtension on Element {
  String get displayName {
    switch (this) {
      case Element.earth:
        return _l10n.elementEarth;
      case Element.water:
        return _l10n.elementWater;
      case Element.air:
        return _l10n.elementAir;
      case Element.fire:
        return _l10n.elementFire;
      case Element.spirit:
        return _l10n.elementSpirit;
    }
  }

  String get emoji {
    switch (this) {
      case Element.earth:
        return '🌍';
      case Element.water:
        return '💧';
      case Element.air:
        return '🌬️';
      case Element.fire:
        return '🔥';
      case Element.spirit:
        return '✨';
    }
  }
}
