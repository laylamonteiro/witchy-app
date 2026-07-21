import 'package:flutter/material.dart' hide Element;
import 'dart:convert';
import 'planet_position_model.dart';
import 'house_model.dart';
import 'aspect_model.dart';
import 'enums.dart';

/// Versão do algoritmo de cálculo do mapa. Incrementada sempre que o cálculo
/// muda de forma que mapas salvos precisem ser recalculados. Mapas antigos sem
/// o campo são tratados como versão 1.
///
/// v2: adiciona Lilith, MC/IC/DSC, Vértex e Parte da Fortuna.
const int kChartCalcVersion = 2;

class BirthChartModel {
  final String id;
  final String userId;
  final DateTime birthDate;
  final TimeOfDay birthTime;
  final String birthPlace;
  final double latitude;
  final double longitude;
  final String timezone;
  final bool unknownBirthTime;

  // Planetas
  final List<PlanetPosition> planets;

  // Casas
  final List<House> houses;

  // Pontos importantes
  final PlanetPosition? ascendant;
  final PlanetPosition? midheaven;

  // Aspectos
  final List<Aspect> aspects;

  final DateTime calculatedAt;

  /// Versão do cálculo com que este mapa foi gerado (ver [kChartCalcVersion]).
  final int calcVersion;

  const BirthChartModel({
    required this.id,
    required this.userId,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.unknownBirthTime = false,
    required this.planets,
    required this.houses,
    this.ascendant,
    this.midheaven,
    required this.aspects,
    required this.calculatedAt,
    this.calcVersion = 1,
  });

  // Getters úteis
  PlanetPosition get sun =>
      planets.firstWhere((p) => p.planet == Planet.sun);

  PlanetPosition get moon =>
      planets.firstWhere((p) => p.planet == Planet.moon);

  PlanetPosition get mercury =>
      planets.firstWhere((p) => p.planet == Planet.mercury);

  PlanetPosition get venus =>
      planets.firstWhere((p) => p.planet == Planet.venus);

  PlanetPosition get mars =>
      planets.firstWhere((p) => p.planet == Planet.mars);

  House get house8 => houses.firstWhere((h) => h.number == 8);

  House get house12 => houses.firstWhere((h) => h.number == 12);

  List<PlanetPosition> getPlanetsInHouse(int houseNumber) {
    return planets.where((p) => p.houseNumber == houseNumber).toList();
  }

  Map<Element, int> getElementDistribution() {
    final distribution = <Element, int>{
      Element.fire: 0,
      Element.earth: 0,
      Element.air: 0,
      Element.water: 0,
    };

    // Conta todos os planetas do mapa (inclusive Urano, Netuno e Plutão),
    // para que a distribuição seja coerente com a lista "Ver todos os
    // planetas" — evita mostrar "0 em Terra" tendo um planeta em signo de Terra.
    for (final planet in planets.where(_isCountablePlanet)) {
      distribution[planet.sign.element] =
          (distribution[planet.sign.element] ?? 0) + 1;
    }

    return distribution;
  }

  /// Planetas considerados na contagem de elementos/modalidades — os 10 astros,
  /// excluindo pontos calculados (Ascendente, Meio do Céu, nodos etc.).
  static bool _isCountablePlanet(PlanetPosition p) =>
      p.planet == Planet.sun ||
      p.planet == Planet.moon ||
      p.planet == Planet.mercury ||
      p.planet == Planet.venus ||
      p.planet == Planet.mars ||
      p.planet == Planet.jupiter ||
      p.planet == Planet.saturn ||
      p.planet == Planet.uranus ||
      p.planet == Planet.neptune ||
      p.planet == Planet.pluto;

  Map<Modality, int> getModalityDistribution() {
    final distribution = <Modality, int>{
      Modality.cardinal: 0,
      Modality.fixed: 0,
      Modality.mutable: 0,
    };

    for (final planet in planets.where(_isCountablePlanet)) {
      distribution[planet.sign.modality] =
          (distribution[planet.sign.modality] ?? 0) + 1;
    }

    return distribution;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'birthDate': birthDate.toIso8601String(),
      'birthTimeHour': birthTime.hour,
      'birthTimeMinute': birthTime.minute,
      'birthPlace': birthPlace,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'unknownBirthTime': unknownBirthTime,
      'planets': planets.map((p) => p.toJson()).toList(),
      'houses': houses.map((h) => h.toJson()).toList(),
      'ascendant': ascendant?.toJson(),
      'midheaven': midheaven?.toJson(),
      'aspects': aspects.map((a) => a.toJson()).toList(),
      'calculatedAt': calculatedAt.toIso8601String(),
      'calcVersion': calcVersion,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory BirthChartModel.fromJson(Map<String, dynamic> json) {
    return BirthChartModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : DateTime.now(),
      birthTime: TimeOfDay(
        hour: json['birthTimeHour'] ?? 12,
        minute: json['birthTimeMinute'] ?? 0,
      ),
      birthPlace: json['birthPlace'] ?? 'Local desconhecido',
      latitude: (json['latitude'] ?? -23.5505).toDouble(),
      longitude: (json['longitude'] ?? -46.6333).toDouble(),
      timezone: json['timezone'] ?? 'America/Sao_Paulo',
      unknownBirthTime: json['unknownBirthTime'] ?? false,
      planets: (json['planets'] as List?)
          ?.map((p) => PlanetPosition.fromJson(p))
          .toList() ?? [],
      houses: (json['houses'] as List?)
          ?.map((h) => House.fromJson(h))
          .toList() ?? [],
      ascendant: json['ascendant'] != null
          ? PlanetPosition.fromJson(json['ascendant'])
          : null,
      midheaven: json['midheaven'] != null
          ? PlanetPosition.fromJson(json['midheaven'])
          : null,
      aspects: (json['aspects'] as List?)
          ?.map((a) => Aspect.fromJson(a))
          .toList() ?? [],
      calculatedAt: json['calculatedAt'] != null
          ? DateTime.parse(json['calculatedAt'])
          : DateTime.now(),
      calcVersion: json['calcVersion'] ?? 1,
    );
  }

  factory BirthChartModel.fromJsonString(String jsonString) {
    return BirthChartModel.fromJson(jsonDecode(jsonString));
  }

  BirthChartModel copyWith({
    String? id,
    String? userId,
    DateTime? birthDate,
    TimeOfDay? birthTime,
    String? birthPlace,
    double? latitude,
    double? longitude,
    String? timezone,
    bool? unknownBirthTime,
    List<PlanetPosition>? planets,
    List<House>? houses,
    PlanetPosition? ascendant,
    PlanetPosition? midheaven,
    List<Aspect>? aspects,
    DateTime? calculatedAt,
    int? calcVersion,
  }) {
    return BirthChartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthPlace: birthPlace ?? this.birthPlace,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      unknownBirthTime: unknownBirthTime ?? this.unknownBirthTime,
      planets: planets ?? this.planets,
      houses: houses ?? this.houses,
      ascendant: ascendant ?? this.ascendant,
      midheaven: midheaven ?? this.midheaven,
      aspects: aspects ?? this.aspects,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      calcVersion: calcVersion ?? this.calcVersion,
    );
  }
}
