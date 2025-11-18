// lib/services/moon_phase_service.dart
enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

class MoonPhaseService {
  static MoonPhase getPhase(DateTime date) {
    final knownNewMoon = DateTime(2000, 1, 6); // referência aproximada
    final diff = date.toUtc().difference(knownNewMoon).inDays;
    final lunations = diff / 29.53058867;
    final frac = lunations - lunations.floorToDouble();
    final index = (frac * 8).round() % 8;

    switch (index) {
      case 0:
        return MoonPhase.newMoon;
      case 1:
        return MoonPhase.waxingCrescent;
      case 2:
        return MoonPhase.firstQuarter;
      case 3:
        return MoonPhase.waxingGibbous;
      case 4:
        return MoonPhase.fullMoon;
      case 5:
        return MoonPhase.waningGibbous;
      case 6:
        return MoonPhase.lastQuarter;
      case 7:
      default:
        return MoonPhase.waningCrescent;
    }
  }

  static String getPhaseLabel(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return 'Lua Nova';
      case MoonPhase.waxingCrescent:
        return 'Lua Crescente';
      case MoonPhase.firstQuarter:
        return 'Quarto Crescente';
      case MoonPhase.waxingGibbous:
        return 'Gibosa Crescente';
      case MoonPhase.fullMoon:
        return 'Lua Cheia';
      case MoonPhase.waningGibbous:
        return 'Gibosa Minguante';
      case MoonPhase.lastQuarter:
        return 'Quarto Minguante';
      case MoonPhase.waningCrescent:
        return 'Lua Minguante';
    }
  }

  static String getPhaseHint(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return 'Bom momento para plantar intenções e começar ciclos.';
      case MoonPhase.waxingCrescent:
        return 'Energia de crescimento e movimento inicial.';
      case MoonPhase.firstQuarter:
        return 'Hora de agir com coragem e ajustar a rota.';
      case MoonPhase.waxingGibbous:
        return 'Ajustes finais antes da colheita, refine seus planos.';
      case MoonPhase.fullMoon:
        return 'Clímax de energia, bom para rituais de manifestação e gratidão.';
      case MoonPhase.waningGibbous:
        return 'Compartilhe, agradeça e comece a liberar o que não serve.';
      case MoonPhase.lastQuarter:
        return 'Tempo de cortar excessos e se desapegar.';
      case MoonPhase.waningCrescent:
        return 'Recolhimento, descanso e limpeza energética.';
    }
  }
}
