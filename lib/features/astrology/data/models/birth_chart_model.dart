import 'package:flutter/material.dart';
import 'dart:convert';
import 'planet_position_model.dart';
import 'house_model.dart';
import 'aspect_model.dart';
import 'enums.dart';

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

    // Contar apenas planetas pessoais + sociais para elemento dominante
    final relevantPlanets = planets.where((p) =>
        p.planet == Planet.sun ||
        p.planet == Planet.moon ||
        p.planet == Planet.mercury ||
        p.planet == Planet.venus ||
        p.planet == Planet.mars ||
        p.planet == Planet.jupiter ||
        p.planet == Planet.saturn);

    for (final planet in relevantPlanets) {
      distribution[planet.sign.element] = (distribution[planet.sign.element] ?? 0) + 1;
    }

    return distribution;
  }

  Map<Modality, int> getModalityDistribution() {
    final distribution = <Modality, int>{
      Modality.cardinal: 0,
      Modality.fixed: 0,
      Modality.mutable: 0,
    };

    final relevantPlanets = planets.where((p) =>
        p.planet == Planet.sun ||
        p.planet == Planet.moon ||
        p.planet == Planet.mercury ||
        p.planet == Planet.venus ||
        p.planet == Planet.mars ||
        p.planet == Planet.jupiter ||
        p.planet == Planet.saturn);

    for (final planet in relevantPlanets) {
      distribution[planet.sign.modality] = (distribution[planet.sign.modality] ?? 0) + 1;
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
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory BirthChartModel.fromJson(Map<String, dynamic> json) {
    return BirthChartModel(
      id: json['id'],
      userId: json['userId'],
      birthDate: DateTime.parse(json['birthDate']),
      birthTime: TimeOfDay(
        hour: json['birthTimeHour'],
        minute: json['birthTimeMinute'],
      ),
      birthPlace: json['birthPlace'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timezone: json['timezone'],
      unknownBirthTime: json['unknownBirthTime'] ?? false,
      planets: (json['planets'] as List)
          .map((p) => PlanetPosition.fromJson(p))
          .toList(),
      houses: (json['houses'] as List)
          .map((h) => House.fromJson(h))
          .toList(),
      ascendant: json['ascendant'] != null
          ? PlanetPosition.fromJson(json['ascendant'])
          : null,
      midheaven: json['midheaven'] != null
          ? PlanetPosition.fromJson(json['midheaven'])
          : null,
      aspects: (json['aspects'] as List)
          .map((a) => Aspect.fromJson(a))
          .toList(),
      calculatedAt: DateTime.parse(json['calculatedAt']),
    );
  }

  factory BirthChartModel.fromJsonString(String jsonString) {
    return BirthChartModel.fromJson(jsonDecode(jsonString));
  }
}
