import '../../../../core/content/content_locale.dart';
import 'sabbat_content_en.dart';
import 'sabbat_content_es.dart';
import 'sabbat_content_pt.dart';

enum SabbatType {
  samhain,
  yule,
  imbolc,
  ostara,
  beltane,
  litha,
  lammas,
  mabon,
}

extension SabbatTypeExtension on SabbatType {
  // Nome próprio do Sabbat — INVARIANTE entre idiomas (Samhain, Yule...).
  String get name {
    switch (this) {
      case SabbatType.samhain:
        return 'Samhain';
      case SabbatType.yule:
        return 'Yule';
      case SabbatType.imbolc:
        return 'Imbolc';
      case SabbatType.ostara:
        return 'Ostara';
      case SabbatType.beltane:
        return 'Beltane';
      case SabbatType.litha:
        return 'Litha';
      case SabbatType.lammas:
        return 'Lammas';
      case SabbatType.mabon:
        return 'Mabon';
    }
  }

  String get emoji {
    switch (this) {
      case SabbatType.samhain:
        return '🎃';
      case SabbatType.yule:
        return '❄️';
      case SabbatType.imbolc:
        return '🕯️';
      case SabbatType.ostara:
        return '🌸';
      case SabbatType.beltane:
        return '🔥';
      case SabbatType.litha:
        return '☀️';
      case SabbatType.lammas:
        return '🌾';
      case SabbatType.mabon:
        return '🍂';
    }
  }

  String get description => ContentLocale.instance.select(
      pt: sabbatDescriptionsPt,
      en: sabbatDescriptionsEn,
      es: sabbatDescriptionsEs)[this]!;

  // Data formatada para hemisfério sul (Brasil)
  String get southernHemisphereDate => ContentLocale.instance.select(
      pt: sabbatSouthDatesPt,
      en: sabbatSouthDatesEn,
      es: sabbatSouthDatesEs)[this]!;

  // Data formatada para hemisfério norte (referência tradicional)
  String get northernHemisphereDate => ContentLocale.instance.select(
      pt: sabbatNorthDatesPt,
      en: sabbatNorthDatesEn,
      es: sabbatNorthDatesEs)[this]!;

  List<String> get crystals => ContentLocale.instance.select(
      pt: sabbatCrystalsPt, en: sabbatCrystalsEn, es: sabbatCrystalsEs)[this]!;

  List<String> get herbs => ContentLocale.instance.select(
      pt: sabbatHerbsPt, en: sabbatHerbsEn, es: sabbatHerbsEs)[this]!;

  List<String> get colors => ContentLocale.instance.select(
      pt: sabbatColorsPt, en: sabbatColorsEn, es: sabbatColorsEs)[this]!;

  List<String> get foods => ContentLocale.instance.select(
      pt: sabbatFoodsPt, en: sabbatFoodsEn, es: sabbatFoodsEs)[this]!;

  List<String> get rituals => ContentLocale.instance.select(
      pt: sabbatRitualsPt, en: sabbatRitualsEn, es: sabbatRitualsEs)[this]!;

  // Datas para hemisfério sul (Brasil)
  DateTime getDateForYear(int year) {
    switch (this) {
      case SabbatType.samhain:
        return DateTime(year, 5, 1); // 1º de maio
      case SabbatType.yule:
        return _getSolsticeEquinox(year, 6, 20, 22); // ~21 de junho
      case SabbatType.imbolc:
        return DateTime(year, 8, 1); // 1º de agosto
      case SabbatType.ostara:
        return _getSolsticeEquinox(year, 9, 20, 23); // ~21 de setembro
      case SabbatType.beltane:
        return DateTime(year, 10, 31); // 31 de outubro
      case SabbatType.litha:
        return _getSolsticeEquinox(year, 12, 20, 23); // ~21 de dezembro
      case SabbatType.lammas:
        return DateTime(year, 2, 2); // 2 de fevereiro
      case SabbatType.mabon:
        return _getSolsticeEquinox(year, 3, 19, 21); // ~20 de março
    }
  }

  // Helper para solstícios e equinócios (aproximação)
  DateTime _getSolsticeEquinox(int year, int month, int minDay, int maxDay) {
    // Retorna o dia médio (aproximação simples)
    final day = ((minDay + maxDay) / 2).round();
    return DateTime(year, month, day);
  }
}

class Sabbat {
  final SabbatType type;
  final DateTime date;

  Sabbat({
    required this.type,
    required this.date,
  });

  String get name => type.name;
  String get emoji => type.emoji;
  String get description => type.description;
  List<String> get rituals => type.rituals;

  int daysUntil(DateTime now) {
    return date.difference(now).inDays;
  }

  bool isPast(DateTime now) {
    return date.isBefore(now);
  }
}
