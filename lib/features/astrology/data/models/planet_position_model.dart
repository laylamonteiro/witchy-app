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

  /// Lê o mapa GRAVADO, que nem sempre é o que este código escreve hoje.
  ///
  /// Os campos numéricos vinham como downcast direto (`json['speed']`), que
  /// estoura com `null is not a subtype of double` — e também com um número
  /// INTEIRO no JSON (`"speed": 0`), porque em Dart `int` não é `double`. Uma
  /// linha antiga, ou um JSON que passou por outra serialização, derrubava o
  /// mapa astral inteiro: o `calcVersion`, que existe justamente para
  /// recalcular mapas velhos, nunca chegava a ser lido, porque o parse morria
  /// antes. O padrão de tolerância é o mesmo que o BirthChartModel já usa em
  /// latitude/longitude.
  factory PlanetPosition.fromJson(Map<String, dynamic> json) {
    final sign = ZodiacSign.values.firstWhere((e) => e.name == json['sign']);
    final degree = (json['degree'] as num?)?.toInt() ?? 0;
    final minute = (json['minute'] as num?)?.toInt() ?? 0;
    return PlanetPosition(
      planet: Planet.values.firstWhere((e) => e.name == json['planet']),
      sign: sign,
      degree: degree,
      minute: minute,
      houseNumber: (json['houseNumber'] as num?)?.toInt() ?? 1,
      isRetrograde: json['isRetrograde'] as bool? ?? false,
      // Sem a longitude absoluta, o signo + grau + minuto a reconstroem: é a
      // mesma conta que ZodiacSign.fromLongitude desfaz. Zerar seria dizer
      // "0° de Áries", que é uma posição de verdade — e errada.
      longitude: (json['longitude'] as num?)?.toDouble() ??
          (sign.index * 30 + degree + minute / 60),
      // Velocidade só decide o retrógrado, que já vem no campo próprio.
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
