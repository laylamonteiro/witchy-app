import 'enums.dart';

class PlanetPosition {
  final Planet planet;
  final ZodiacSign sign;
  final int degree; // 0-29
  final int minute; // 0-59
  final int houseNumber; // 1-12
  final bool isRetrograde;
  final double longitude; // Longitude eclíptica absoluta (0-360)
  final double speed; // Velocidade do planeta

  const PlanetPosition({
    required this.planet,
    required this.sign,
    required this.degree,
    required this.minute,
    required this.houseNumber,
    required this.isRetrograde,
    required this.longitude,
    required this.speed,
  });

  String get positionString => '${sign.displayName} ${degree}°${minute}\'';

  String get fullDescription =>
      '${planet.displayName} em ${sign.displayName} ${degree}°${minute}\' (Casa $houseNumber)${isRetrograde ? ' ℞' : ''}';

  Map<String, dynamic> toJson() {
    return {
      'planet': planet.name,
      'sign': sign.name,
      'degree': degree,
      'minute': minute,
      'houseNumber': houseNumber,
      'isRetrograde': isRetrograde,
      'longitude': longitude,
      'speed': speed,
    };
  }

  factory PlanetPosition.fromJson(Map<String, dynamic> json) {
    return PlanetPosition(
      planet: Planet.values.firstWhere((e) => e.name == json['planet']),
      sign: ZodiacSign.values.firstWhere((e) => e.name == json['sign']),
      degree: json['degree'],
      minute: json['minute'],
      houseNumber: json['houseNumber'],
      isRetrograde: json['isRetrograde'],
      longitude: json['longitude'],
      speed: json['speed'],
    );
  }
}
