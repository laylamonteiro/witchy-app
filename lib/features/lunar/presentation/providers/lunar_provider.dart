import 'package:flutter/foundation.dart';
import '../../../grimoire/data/models/spell_model.dart';

class LunarProvider with ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Calcula a fase da lua baseado no ciclo lunar (29.53 dias)
  MoonPhase getCurrentMoonPhase() {
    // Lua nova conhecida: 6 de janeiro de 2000
    final knownNewMoon = DateTime(2000, 1, 6, 18, 14);
    final daysSinceKnownNewMoon = _selectedDate.difference(knownNewMoon).inDays;

    // Ciclo lunar médio é de 29.53059 dias
    const lunarCycle = 29.53059;
    final phase = (daysSinceKnownNewMoon % lunarCycle) / lunarCycle;

    // Determinar a fase baseado na posição no ciclo
    if (phase < 0.0625 || phase >= 0.9375) {
      return MoonPhase.newMoon;
    } else if (phase < 0.1875) {
      return MoonPhase.waxingCrescent;
    } else if (phase < 0.3125) {
      return MoonPhase.firstQuarter;
    } else if (phase < 0.4375) {
      return MoonPhase.waxingGibbous;
    } else if (phase < 0.5625) {
      return MoonPhase.fullMoon;
    } else if (phase < 0.6875) {
      return MoonPhase.waningGibbous;
    } else if (phase < 0.8125) {
      return MoonPhase.lastQuarter;
    } else {
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
    // Buscar próxima lua cheia
    for (int i = 1; i <= 30; i++) {
      final nextDate = _selectedDate.add(Duration(days: i));
      final tempProvider = LunarProvider();
      tempProvider._selectedDate = nextDate;
      if (tempProvider.getCurrentMoonPhase() == MoonPhase.fullMoon) {
        return nextDate;
      }
    }
    return null;
  }

  DateTime? getNextNewMoon() {
    // Buscar próxima lua nova
    for (int i = 1; i <= 30; i++) {
      final nextDate = _selectedDate.add(Duration(days: i));
      final tempProvider = LunarProvider();
      tempProvider._selectedDate = nextDate;
      if (tempProvider.getCurrentMoonPhase() == MoonPhase.newMoon) {
        return nextDate;
      }
    }
    return null;
  }

  int? getDaysUntilFullMoon() {
    final nextFull = getNextFullMoon();
    if (nextFull == null) return null;
    return nextFull.difference(_selectedDate).inDays;
  }

  int? getDaysUntilNewMoon() {
    final nextNew = getNextNewMoon();
    if (nextNew == null) return null;
    return nextNew.difference(_selectedDate).inDays;
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
