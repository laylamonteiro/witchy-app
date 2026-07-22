import 'package:dio/dio.dart';

/// Um lugar retornado pela busca de geocodificação.
class GeoPlace {
  final String displayName;
  final double latitude;
  final double longitude;

  const GeoPlace({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

/// Busca de cidades via **Nominatim (OpenStreetMap)** — global e precisa.
///
/// Substitui o geocoder nativo do SO (que devolvia o centroide do país para
/// buscas parciais). Respeita a política do Nominatim: `User-Agent` válido e
/// baixo volume (a tela aplica debounce). Requer internet ao criar o mapa.
class GeocodingService {
  static final GeocodingService instance = GeocodingService._();
  GeocodingService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        // Exigência da política de uso do Nominatim.
        'User-Agent': 'GrimorioDeBolso/1.0 (app de bruxaria)',
      },
    ),
  );

  /// Níveis grosseiros que NÃO servem como local de nascimento — descartar
  /// (é o que gerava o "centroide do Brasil"). NÃO inclui 'administrative':
  /// muitos municípios (ex.: Campinas) voltam do Nominatim com esse tipo e
  /// seriam descartados indevidamente. País/estado/região já cobrem o coarse.
  static const _coarseTypes = {
    'country',
    'state',
    'region',
    'continent',
    'sea',
    'ocean',
    'archipelago',
  };

  Future<List<GeoPlace>> search(String query, {String lang = 'pt-BR'}) async {
    final resp = await _dio.get(
      'https://nominatim.openstreetmap.org/search',
      queryParameters: {
        'q': query,
        'format': 'jsonv2',
        'addressdetails': 1,
        'limit': 8,
        'accept-language': lang,
      },
    );

    final data = resp.data;
    if (data is! List) return [];

    final places = <GeoPlace>[];
    for (final item in data) {
      if (item is! Map) continue;

      final addressType =
          (item['addresstype'] ?? item['type'] ?? '').toString();
      // Mantém cidades/vilas/municípios; descarta país/estado/região.
      if (_coarseTypes.contains(addressType)) continue;

      final lat = double.tryParse('${item['lat']}');
      final lon = double.tryParse('${item['lon']}');
      if (lat == null || lon == null) continue;

      places.add(GeoPlace(
        displayName: _shortName(item),
        latitude: lat,
        longitude: lon,
      ));
    }
    return places;
  }

  /// Uma leitura só (primeiro resultado utilizável) — usada como fallback ao
  /// calcular quando nenhuma sugestão foi selecionada.
  Future<GeoPlace?> resolveFirst(String query, {String lang = 'pt-BR'}) async {
    final results = await search(query, lang: lang);
    return results.isEmpty ? null : results.first;
  }

  String _shortName(Map item) {
    final addr = item['address'];
    if (addr is Map) {
      final city = addr['city'] ??
          addr['town'] ??
          addr['village'] ??
          addr['municipality'] ??
          addr['county'] ??
          addr['suburb'];
      final state = addr['state'];
      final country = addr['country'];
      final parts = [city, state, country]
          .where((e) => e != null && '$e'.trim().isNotEmpty)
          .map((e) => '$e')
          .toList();
      if (parts.isNotEmpty) return parts.join(', ');
    }
    return (item['display_name'] ?? '').toString();
  }
}
