import 'dart:convert';
import 'enums.dart';
import 'planet_position_model.dart';

/// Representa a posição atual de um planeta em trânsito
class Transit {
  final Planet planet;
  final ZodiacSign sign;
  final double degree;
  final bool isRetrograde;

  const Transit({
    required this.planet,
    required this.sign,
    required this.degree,
    required this.isRetrograde,
  });

  String get formattedPosition =>
      '${planet.displayName} em ${sign.displayName} ${degree.toStringAsFixed(0)}°';

  Map<String, dynamic> toJson() {
    return {
      'planet': planet.name,
      'sign': sign.name,
      'degree': degree,
      'isRetrograde': isRetrograde,
    };
  }

  factory Transit.fromJson(Map<String, dynamic> json) {
    return Transit(
      planet: Planet.values.firstWhere((e) => e.name == json['planet']),
      sign: ZodiacSign.values.firstWhere((e) => e.name == json['sign']),
      degree: json['degree'],
      isRetrograde: json['isRetrograde'],
    );
  }
}

/// Representa um aspecto entre planeta em trânsito e planeta natal
class TransitAspect {
  final Planet transitPlanet;
  final Planet natalPlanet;
  final AspectType aspectType;
  final double orb;
  final String interpretation;
  final EnergyLevel energyLevel;

  const TransitAspect({
    required this.transitPlanet,
    required this.natalPlanet,
    required this.aspectType,
    required this.orb,
    required this.interpretation,
    required this.energyLevel,
  });

  String get description =>
      '${transitPlanet.displayName} ${aspectType.symbol} ${natalPlanet.displayName}';

  bool get isActive => orb <= aspectType.maxOrb;

  Map<String, dynamic> toJson() {
    return {
      'transitPlanet': transitPlanet.name,
      'natalPlanet': natalPlanet.name,
      'aspectType': aspectType.name,
      'orb': orb,
      'interpretation': interpretation,
      'energyLevel': energyLevel.name,
    };
  }

  factory TransitAspect.fromJson(Map<String, dynamic> json) {
    return TransitAspect(
      transitPlanet:
          Planet.values.firstWhere((e) => e.name == json['transitPlanet']),
      natalPlanet:
          Planet.values.firstWhere((e) => e.name == json['natalPlanet']),
      aspectType:
          AspectType.values.firstWhere((e) => e.name == json['aspectType']),
      orb: json['orb'],
      interpretation: json['interpretation'],
      energyLevel:
          EnergyLevel.values.firstWhere((e) => e.name == json['energyLevel']),
    );
  }
}

/// Representa o clima mágico do dia com base nos trânsitos
class DailyMagicalWeather {
  final DateTime date;
  final List<Transit> transits;
  final List<TransitAspect> aspects;
  final String generalInterpretation;
  final List<String> recommendedPractices;
  final List<String> energyKeywords;
  final EnergyLevel overallEnergy;
  final ZodiacSign moonSign;
  final String moonPhase;

  const DailyMagicalWeather({
    required this.date,
    required this.transits,
    required this.aspects,
    required this.generalInterpretation,
    required this.recommendedPractices,
    required this.energyKeywords,
    required this.overallEnergy,
    required this.moonSign,
    required this.moonPhase,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'transits': transits.map((t) => t.toJson()).toList(),
      'aspects': aspects.map((a) => a.toJson()).toList(),
      'generalInterpretation': generalInterpretation,
      'recommendedPractices': recommendedPractices,
      'energyKeywords': energyKeywords,
      'overallEnergy': overallEnergy.name,
      'moonSign': moonSign.name,
      'moonPhase': moonPhase,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory DailyMagicalWeather.fromJson(Map<String, dynamic> json) {
    return DailyMagicalWeather(
      date: DateTime.parse(json['date']),
      transits: (json['transits'] as List)
          .map((t) => Transit.fromJson(t))
          .toList(),
      aspects: (json['aspects'] as List)
          .map((a) => TransitAspect.fromJson(a))
          .toList(),
      generalInterpretation: json['generalInterpretation'],
      recommendedPractices: List<String>.from(json['recommendedPractices']),
      energyKeywords: List<String>.from(json['energyKeywords']),
      overallEnergy: EnergyLevel.values
          .firstWhere((e) => e.name == json['overallEnergy']),
      moonSign:
          ZodiacSign.values.firstWhere((e) => e.name == json['moonSign']),
      moonPhase: json['moonPhase'],
    );
  }

  factory DailyMagicalWeather.fromJsonString(String jsonString) {
    return DailyMagicalWeather.fromJson(jsonDecode(jsonString));
  }
}

/// Sugestão personalizada baseada em trânsitos e mapa natal
class PersonalizedSuggestion {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final List<String> practices;
  final List<TransitAspect> relevantAspects;
  final EnergyLevel priority;
  final String category; // ritual, meditation, spell, divination, etc.

  const PersonalizedSuggestion({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.practices,
    required this.relevantAspects,
    required this.priority,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'practices': practices,
      'relevantAspects': relevantAspects.map((a) => a.toJson()).toList(),
      'priority': priority.name,
      'category': category,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory PersonalizedSuggestion.fromJson(Map<String, dynamic> json) {
    return PersonalizedSuggestion(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      description: json['description'],
      practices: List<String>.from(json['practices']),
      relevantAspects: (json['relevantAspects'] as List)
          .map((a) => TransitAspect.fromJson(a))
          .toList(),
      priority:
          EnergyLevel.values.firstWhere((e) => e.name == json['priority']),
      category: json['category'],
    );
  }

  factory PersonalizedSuggestion.fromJsonString(String jsonString) {
    return PersonalizedSuggestion.fromJson(jsonDecode(jsonString));
  }
}
