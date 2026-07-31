import '../../../../core/content/content_locale.dart';
import '../../../encyclopedia/data/models/herb_model.dart' show Planet, PlanetExtension;
import 'magical_moment_en.dart';
import 'magical_moment_es.dart';
import 'magical_moment_pt.dart';

/// Texto localizado de um dia da semana mágico.
typedef WeekdayText = ({String theme, List<String> goodFor, String suggestion});

/// Texto localizado de um período do dia.
typedef DayPeriodText = ({String title, String goodFor});

/// Período mágico do dia (correspondências da hora de lançar um feitiço).
enum DayPeriod {
  sunrise,
  day,
  noon,
  sunset,
  night,
  midnight;

  /// Mapeia qualquer hora (0–23) para um período. Faixas:
  /// 0–1 e 23 = meia-noite; 2–4 e 20–22 = noite; 5–7 = nascer do sol;
  /// 8–10 e 14–16 = durante o dia; 11–13 = meio-dia; 17–19 = pôr do sol.
  static DayPeriod fromHour(int hour) {
    assert(hour >= 0 && hour < 24);
    if (hour == 23 || hour <= 1) return DayPeriod.midnight;
    if (hour <= 4 || hour >= 20) return DayPeriod.night;
    if (hour <= 7) return DayPeriod.sunrise;
    if (hour <= 10) return DayPeriod.day;
    if (hour <= 13) return DayPeriod.noon;
    if (hour <= 16) return DayPeriod.day;
    return DayPeriod.sunset;
  }

  String get emoji {
    switch (this) {
      case DayPeriod.sunrise:
        return '🌅';
      case DayPeriod.day:
        return '☀️';
      case DayPeriod.noon:
        return '🌞';
      case DayPeriod.sunset:
        return '🌇';
      case DayPeriod.night:
        return '🌌';
      case DayPeriod.midnight:
        return '🕛';
    }
  }

  DayPeriodText get _text => ContentLocale.instance.select(
      pt: dayPeriodTextsPt, en: dayPeriodTextsEn, es: dayPeriodTextsEs)[this]!;

  String get title => _text.title;
  String get goodFor => _text.goodFor;
}

/// Correspondências mágicas de um dia da semana (planeta regente + propósitos).
class WeekdayCorrespondence {
  /// 1 = segunda … 7 = domingo (padrão de [DateTime.weekday]).
  final int weekday;

  const WeekdayCorrespondence(this.weekday)
      : assert(weekday >= DateTime.monday && weekday <= DateTime.sunday);

  static const Map<int, Planet> _planets = {
    DateTime.monday: Planet.moon,
    DateTime.tuesday: Planet.mars,
    DateTime.wednesday: Planet.mercury,
    DateTime.thursday: Planet.jupiter,
    DateTime.friday: Planet.venus,
    DateTime.saturday: Planet.saturn,
    DateTime.sunday: Planet.sun,
  };

  Planet get planet => _planets[weekday]!;
  String get planetName => planet.displayName;
  String get planetEmoji => planet.emoji;

  WeekdayText get _text => ContentLocale.instance.select(
      pt: weekdayTextsPt, en: weekdayTextsEn, es: weekdayTextsEs)[weekday]!;

  /// Tema resumido do dia (ex.: "dia de Vênus — amor e beleza").
  String get theme => _text.theme;

  /// Propósitos favorecidos hoje (chips).
  List<String> get goodFor => _text.goodFor;

  /// Sugestão prática do que fazer hoje.
  String get suggestion => _text.suggestion;
}

/// O momento mágico de um instante: dia da semana + período do dia.
class MagicalMoment {
  final WeekdayCorrespondence day;
  final DayPeriod period;

  const MagicalMoment._(this.day, this.period);

  factory MagicalMoment.of(DateTime when) => MagicalMoment._(
        WeekdayCorrespondence(when.weekday),
        DayPeriod.fromHour(when.hour),
      );
}
