import 'package:path_provider/path_provider.dart';
import 'package:sweph/sweph.dart';

import '../models/enums.dart';

/// Resultado de posição de um corpo celeste.
class BodyPosition {
  final double longitude; // eclíptica, 0-360
  final double speed; // velocidade em longitude (°/dia); < 0 = retrógrado
  const BodyPosition(this.longitude, this.speed);
}

/// Resultado do cálculo de casas.
class HousesResult {
  final List<double> cusps; // 12 cúspides (casa 1..12), em graus 0-360
  final double ascendant;
  final double mc;
  final double vertex; // ascmc[3], ponto do destino
  const HousesResult(this.cusps, this.ascendant, this.mc, this.vertex);
}

/// Fina camada sobre o Swiss Ephemeris (pacote `sweph`).
///
/// Usa o efemeris analítico **Moshier** (`SEFLG_MOSEPH`), que é embutido na
/// biblioteca e NÃO precisa dos arquivos `.se1` — precisão de ~arco-minuto,
/// mais que suficiente para o mapa astral, sem inflar o tamanho do app.
class SwephService {
  static final SwephService instance = SwephService._();
  SwephService._();

  bool _ready = false;
  Future<void>? _initFuture;

  /// Inicializa o Swiss Ephemeris uma única vez (idempotente).
  Future<void> ensureReady() {
    if (_ready) return Future.value();
    return _initFuture ??= _init();
  }

  Future<void> _init() async {
    // O sweph precisa de um diretório GRAVÁVEL para preparar os arquivos de
    // efemérides. O padrão ('ephe_files', relativo) falha no Android/iOS, onde
    // o diretório de trabalho é somente leitura. Usamos o suporte do app.
    final dir = await getApplicationSupportDirectory();
    await Sweph.init(epheFilesPath: '${dir.path}/ephe');
    _ready = true;
  }

  // Moshier (sem arquivos de efemérides) + velocidade (para retrogradação).
  static final SwephFlag _flags =
      SwephFlag.SEFLG_MOSEPH | SwephFlag.SEFLG_SPEED;

  /// Julian Day (UT) a partir de data/hora já em UTC.
  double julianDayUt({
    required int year,
    required int month,
    required int day,
    required double hourUt,
  }) {
    return Sweph.swe_julday(year, month, day, hourUt, CalendarType.SE_GREG_CAL);
  }

  /// Longitude eclíptica e velocidade de um corpo em determinado JD (UT).
  BodyPosition bodyPosition(double jdUt, HeavenlyBody body) {
    final coords = Sweph.swe_calc_ut(jdUt, body, _flags);
    var lon = coords.longitude % 360;
    if (lon < 0) lon += 360;
    return BodyPosition(lon, coords.speedInLongitude);
  }

  /// Casas Placidus: 12 cúspides + Ascendente + Meio do Céu + Vértex.
  HousesResult houses(double jdUt, double latitude, double longitude) {
    final h = Sweph.swe_houses(jdUt, latitude, longitude, Hsys.P);
    final raw = h.cusps;
    // O Swiss Ephemeris preenche cusps[1..12] (índice 0 não usado). O wrapper
    // pode devolver a lista com ou sem o elemento inicial — normalizamos.
    final cusps = <double>[];
    final startsAtOne = raw.length >= 13;
    for (int i = 0; i < 12; i++) {
      final idx = startsAtOne ? i + 1 : i;
      var v = (idx < raw.length ? raw[idx] : 0.0) % 360;
      if (v < 0) v += 360;
      cusps.add(v);
    }
    double norm(double v) {
      v = v % 360;
      return v < 0 ? v + 360 : v;
    }

    // ascmc: [0]=Ascendente, [1]=MC, [2]=ARMC, [3]=Vértex.
    return HousesResult(
      cusps,
      norm(h.ascmc[0]),
      norm(h.ascmc[1]),
      norm(h.ascmc[3]),
    );
  }

  /// Mapeia o [Planet] do app para o corpo do Swiss Ephemeris.
  /// O Nodo Sul usa o Nodo Norte (mean node) e é oposto (+180°) no cálculo.
  static HeavenlyBody heavenlyBody(Planet planet) {
    switch (planet) {
      case Planet.sun:
        return HeavenlyBody.SE_SUN;
      case Planet.moon:
        return HeavenlyBody.SE_MOON;
      case Planet.mercury:
        return HeavenlyBody.SE_MERCURY;
      case Planet.venus:
        return HeavenlyBody.SE_VENUS;
      case Planet.mars:
        return HeavenlyBody.SE_MARS;
      case Planet.jupiter:
        return HeavenlyBody.SE_JUPITER;
      case Planet.saturn:
        return HeavenlyBody.SE_SATURN;
      case Planet.uranus:
        return HeavenlyBody.SE_URANUS;
      case Planet.neptune:
        return HeavenlyBody.SE_NEPTUNE;
      case Planet.pluto:
        return HeavenlyBody.SE_PLUTO;
      case Planet.northNode:
      case Planet.southNode:
        return HeavenlyBody.SE_MEAN_NODE;
      case Planet.lilith:
        return HeavenlyBody.SE_MEAN_APOG; // Lua Negra (apogeu médio)
      case Planet.midheaven:
      case Planet.imumCoeli:
      case Planet.descendant:
      case Planet.vertex:
      case Planet.partOfFortune:
        // Pontos calculados a partir das casas/ângulos, não corpos do sweph.
        throw ArgumentError('${planet.displayName} não é um corpo do Swiss Ephemeris');
    }
  }
}
