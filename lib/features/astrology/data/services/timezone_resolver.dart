import 'package:timezone/timezone.dart' as tz;
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';

/// Strings do idioma atual sem BuildContext; o locale vem do ContentLocale.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

/// Fuso resolvido para uma data/local de nascimento.
class ResolvedTimezone {
  /// Instante de nascimento em UTC (já com horário de verão aplicado, se houver).
  final DateTime utc;

  /// Offset em horas usado (ex.: -3.0, -2.0 no verão).
  final double offsetHours;

  /// Se o horário de verão estava vigente naquele instante.
  final bool isDst;

  /// Rótulo legível (ex.: "UTC-2 (horário de verão)").
  final String label;

  const ResolvedTimezone({
    required this.utc,
    required this.offsetHours,
    required this.isDst,
    required this.label,
  });
}

/// Resolve o fuso horário de nascimento com **horário de verão histórico**.
///
/// Usa o banco IANA do pacote `timezone` (já inicializado em `main.dart`), que
/// contém as regras reais de DST — inclusive os verões brasileiros até 2019.
/// A zona IANA é derivada de lat/lon com foco no Brasil (onde o horário de
/// verão importa para o público do app); fora do Brasil, cai para o offset
/// "natural" da longitude (sem DST).
class TimezoneResolver {
  static ResolvedTimezone resolve({
    required DateTime date,
    required int hour,
    required int minute,
    required double latitude,
    required double longitude,
    double? explicitOffsetHours,
  }) {
    // Offset informado manualmente pelo usuário tem prioridade.
    if (explicitOffsetHours != null) {
      final utc = DateTime.utc(date.year, date.month, date.day, hour, minute)
          .subtract(Duration(minutes: (explicitOffsetHours * 60).round()));
      return ResolvedTimezone(
        utc: utc,
        offsetHours: explicitOffsetHours,
        isDst: false,
        label: _label(explicitOffsetHours, false),
      );
    }

    final zone = _ianaZone(latitude, longitude);
    if (zone != null) {
      try {
        final loc = tz.getLocation(zone);
        final local =
            tz.TZDateTime(loc, date.year, date.month, date.day, hour, minute);
        final offset = local.timeZoneOffset.inMinutes / 60.0;
        // Compara com o inverno do hemisfério sul (julho) para detectar DST.
        final winter = tz.TZDateTime(loc, date.year, 7, 15, 12);
        final isDst =
            local.timeZoneOffset.inMinutes > winter.timeZoneOffset.inMinutes;
        return ResolvedTimezone(
          utc: local.toUtc(),
          offsetHours: offset,
          isDst: isDst,
          label: _label(offset, isDst),
        );
      } catch (_) {
        // zona não encontrada no banco: cai no fallback abaixo
      }
    }

    // Fallback global: offset natural da longitude (sem horário de verão).
    final off = (longitude / 15.0).roundToDouble();
    final utc = DateTime.utc(date.year, date.month, date.day, hour, minute)
        .subtract(Duration(minutes: (off * 60).round()));
    return ResolvedTimezone(
      utc: utc,
      offsetHours: off,
      isDst: false,
      label: _label(off, false),
    );
  }

  static String _label(double offset, bool isDst) {
    final sign = offset >= 0 ? '+' : '-';
    final abs = offset.abs();
    final whole = abs.truncate();
    final minutes = ((abs - whole) * 60).round();
    final base = minutes == 0
        ? 'UTC$sign$whole'
        : 'UTC$sign$whole:${minutes.toString().padLeft(2, '0')}';
    return isDst ? _l10n.astroDstSuffix(base) : base;
  }

  /// Zona IANA aproximada por lat/lon. Retorna null fora do Brasil (usa o
  /// fallback por longitude). As regras de DST de cada zona vêm do banco IANA.
  static String? _ianaZone(double lat, double lon) {
    final inBrazil = lat <= 6.0 && lat >= -34.5 && lon <= -32.0 && lon >= -74.5;
    if (!inBrazil) return null;

    // Fernando de Noronha (UTC-2).
    if (lon > -33.5) return 'America/Noronha';

    // Acre e extremo oeste do Amazonas (UTC-5).
    if (lon < -67.5) return 'America/Rio_Branco';

    // Faixa oeste (UTC-4): AM, RR, RO, MT, MS.
    if (lon < -55.0) {
      if (lat < -12.0) return 'America/Campo_Grande'; // MS (teve DST)
      if (lat < -7.0) return 'America/Cuiaba'; // MT (teve DST)
      return 'America/Manaus'; // AM/RR/RO (sem DST)
    }

    // Nordeste (sem DST na maior parte do período): faixa norte-leste.
    if (lat > -13.0 && lon > -47.0) return 'America/Fortaleza';
    // Bahia.
    if (lat <= -8.0 && lat > -18.5 && lon > -46.5) return 'America/Bahia';

    // Restante — a maior parte populada (SE, S, Centro): São Paulo, que carrega
    // o histórico de horário de verão do Sul/Sudeste.
    return 'America/Sao_Paulo';
  }
}
