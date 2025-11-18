import 'package:flutter/foundation.dart';
import 'package:lunar/lunar.dart';
import '../../../grimoire/data/models/spell_model.dart';

class LunarProvider with ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  MoonPhase getCurrentMoonPhase() {
    final lunar = Lunar.fromDate(_selectedDate);
    final yueXiang = lunar.getYueXiang();

    // Mapeamento das fases lunares chinesas para as ocidentais
    switch (yueXiang) {
      case '朔月': // Lua nova
        return MoonPhase.newMoon;
      case '蛾眉新月': // Crescente inicial
      case '蛾眉残月':
        return MoonPhase.waxingCrescent;
      case '上弦月': // Quarto crescente
        return MoonPhase.firstQuarter;
      case '盈凸月': // Gibosa crescente
        return MoonPhase.waxingGibbous;
      case '满月': // Lua cheia
        return MoonPhase.fullMoon;
      case '亏凸月': // Gibosa minguante
        return MoonPhase.waningGibbous;
      case '下弦月': // Quarto minguante
        return MoonPhase.lastQuarter;
      default: // Minguante
        return MoonPhase.waningCrescent;
    }
  }

  String getMoonPhaseName() {
    return getCurrentMoonPhase().displayName;
  }

  String getMoonPhaseEmoji() {
    return getCurrentMoonPhase().emoji;
  }

  String getMoonPhaseDescription() {
    return getCurrentMoonPhase().description;
  }

  DateTime? getNextFullMoon() {
    final lunar = Lunar.fromDate(_selectedDate);
    final solar = lunar.getSolar();

    // Buscar próxima lua cheia (aproximação)
    for (int i = 1; i <= 30; i++) {
      final nextDate = _selectedDate.add(Duration(days: i));
      final nextLunar = Lunar.fromDate(nextDate);
      if (nextLunar.getYueXiang() == '满月') {
        return nextDate;
      }
    }
    return null;
  }

  DateTime? getNextNewMoon() {
    final lunar = Lunar.fromDate(_selectedDate);

    // Buscar próxima lua nova (aproximação)
    for (int i = 1; i <= 30; i++) {
      final nextDate = _selectedDate.add(Duration(days: i));
      final nextLunar = Lunar.fromDate(nextDate);
      if (nextLunar.getYueXiang() == '朔月') {
        return nextDate;
      }
    }
    return null;
  }

  bool isGoodTimeForSpell(SpellType spellType) {
    final currentPhase = getCurrentMoonPhase();

    if (spellType == SpellType.attraction) {
      // Feitiços de atração são melhores na lua crescente
      return currentPhase == MoonPhase.waxingCrescent ||
          currentPhase == MoonPhase.firstQuarter ||
          currentPhase == MoonPhase.waxingGibbous ||
          currentPhase == MoonPhase.fullMoon;
    } else {
      // Feitiços de banimento são melhores na lua minguante
      return currentPhase == MoonPhase.waningGibbous ||
          currentPhase == MoonPhase.lastQuarter ||
          currentPhase == MoonPhase.waningCrescent ||
          currentPhase == MoonPhase.newMoon;
    }
  }

  String getSpellRecommendation(SpellType spellType) {
    if (isGoodTimeForSpell(spellType)) {
      return 'Este é um bom momento para realizar feitiços de ${spellType.displayName.toLowerCase()}!';
    } else {
      final nextGoodDate = spellType == SpellType.attraction
          ? 'próxima lua crescente'
          : 'próxima lua minguante';
      return 'Para melhores resultados, aguarde a $nextGoodDate.';
    }
  }
}
