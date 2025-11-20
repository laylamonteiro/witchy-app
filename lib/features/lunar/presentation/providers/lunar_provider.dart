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
    // Lua nova conhecida mais recente: 1 de novembro de 2024, 12:47 UTC (09:47 horário de Brasília)
    // Usar uma referência mais recente aumenta a precisão do cálculo
    final knownNewMoon = DateTime.utc(2024, 11, 1, 12, 47);

    // Calcular diferença em dias com precisão de horas
    final difference = _selectedDate.toUtc().difference(knownNewMoon);
    final daysSinceKnownNewMoon = difference.inHours / 24.0;

    // Ciclo lunar médio é de 29.53059 dias
    const lunarCycle = 29.53059;
    final phase = (daysSinceKnownNewMoon % lunarCycle) / lunarCycle;

    // Determinar a fase baseado na posição no ciclo
    // Thresholds ajustados para maior precisão (~12h de janela para cada fase principal)
    // 0.017 = ~0.5 dia = 12 horas
    if (phase < 0.017 || phase >= 0.983) {
      return MoonPhase.newMoon; // Lua Nova: primeiras/últimas 12h do ciclo
    } else if (phase < 0.1875) {
      return MoonPhase.waxingCrescent; // Crescente
    } else if (phase < 0.3125) {
      return MoonPhase.firstQuarter; // Quarto Crescente
    } else if (phase < 0.4375) {
      return MoonPhase.waxingGibbous; // Gibosa Crescente
    } else if (phase < 0.5625) {
      return MoonPhase.fullMoon; // Lua Cheia
    } else if (phase < 0.6875) {
      return MoonPhase.waningGibbous; // Gibosa Minguante
    } else if (phase < 0.8125) {
      return MoonPhase.lastQuarter; // Quarto Minguante
    } else {
      return MoonPhase.waningCrescent; // Minguante: de 81.25% até 98.3%
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
    return _getNextPhaseWithTime(MoonPhase.fullMoon);
  }

  DateTime? getNextNewMoon() {
    return _getNextPhaseWithTime(MoonPhase.newMoon);
  }

  DateTime? getNextWaxingCrescent() {
    return _getNextPhaseWithTime(MoonPhase.waxingCrescent);
  }

  DateTime? getNextFirstQuarter() {
    return _getNextPhaseWithTime(MoonPhase.firstQuarter);
  }

  DateTime? getNextWaxingGibbous() {
    return _getNextPhaseWithTime(MoonPhase.waxingGibbous);
  }

  DateTime? getNextWaningGibbous() {
    return _getNextPhaseWithTime(MoonPhase.waningGibbous);
  }

  DateTime? getNextLastQuarter() {
    return _getNextPhaseWithTime(MoonPhase.lastQuarter);
  }

  DateTime? getNextWaningCrescent() {
    return _getNextPhaseWithTime(MoonPhase.waningCrescent);
  }

  // Método melhorado que calcula com precisão de horas
  DateTime? _getNextPhaseWithTime(MoonPhase targetPhase) {
    // Buscar o dia aproximado primeiro
    DateTime? approximateDate;
    for (int i = 1; i <= 30; i++) {
      final nextDate = _selectedDate.add(Duration(days: i));
      final tempProvider = LunarProvider();
      tempProvider._selectedDate = nextDate;
      if (tempProvider.getCurrentMoonPhase() == targetPhase) {
        approximateDate = nextDate;
        break;
      }
    }

    if (approximateDate == null) return null;

    // Refinar para encontrar a hora mais precisa dentro do dia
    // Procurar desde o dia anterior até o dia seguinte, a cada hora
    final startSearch = approximateDate.subtract(const Duration(days: 1));
    for (int hour = 0; hour < 72; hour++) {
      final candidateDate = startSearch.add(Duration(hours: hour));
      final tempProvider = LunarProvider();
      tempProvider._selectedDate = candidateDate;

      // Se encontramos a fase alvo e está no futuro
      if (tempProvider.getCurrentMoonPhase() == targetPhase &&
          candidateDate.isAfter(_selectedDate)) {
        return candidateDate;
      }
    }

    return approximateDate;
  }

  // Retorna lista de todas as próximas fases em ordem cronológica
  List<Map<String, dynamic>> getAllNextPhases() {
    final phases = <Map<String, dynamic>>[];

    for (final phase in MoonPhase.values) {
      final nextDate = _getNextPhaseWithTime(phase);
      if (nextDate != null) {
        phases.add({
          'phase': phase,
          'date': nextDate,
          'daysUntil': nextDate.difference(_selectedDate).inDays,
          'hoursUntil': nextDate.difference(_selectedDate).inHours,
        });
      }
    }

    // Ordenar por data
    phases.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // Retornar apenas as próximas 4 fases
    return phases.take(4).toList();
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
    final currentPhase = getCurrentMoonPhase();
    final isGoodTime = isGoodTimeForSpell(spellType);

    if (spellType == SpellType.attraction) {
      if (isGoodTime) {
        switch (currentPhase) {
          case MoonPhase.waxingCrescent:
            return 'Momento ideal para plantar intenções e iniciar manifestações. A energia está crescendo!';
          case MoonPhase.firstQuarter:
            return 'Fase de ação! Tome decisões importantes e supere obstáculos em seus feitiços de atração.';
          case MoonPhase.waxingGibbous:
            return 'Refine e ajuste seus rituais. A Lua Cheia se aproxima - prepare-se para o ápice!';
          case MoonPhase.fullMoon:
            return 'Poder máximo! Momento perfeito para rituais importantes de atração, amor e prosperidade.';
          default:
            return 'Momento favorável para feitiços de atração e crescimento.';
        }
      } else {
        final daysUntilWaxing = _getDaysUntilPhase(MoonPhase.waxingCrescent);
        if (daysUntilWaxing != null && daysUntilWaxing <= 3) {
          return 'A lua crescente está chegando em $daysUntilWaxing ${daysUntilWaxing == 1 ? 'dia' : 'dias'}. Prepare seus rituais!';
        }
        return 'Para melhores resultados em feitiços de atração, aguarde a próxima lua crescente.';
      }
    } else {
      if (isGoodTime) {
        switch (currentPhase) {
          case MoonPhase.waningGibbous:
            return 'Momento de gratidão e liberação. Deixe ir o que não te serve mais.';
          case MoonPhase.lastQuarter:
            return 'Fase poderosa para banimento e corte de laços. Libere, perdoe, siga em frente.';
          case MoonPhase.waningCrescent:
            return 'Tempo de descanso e limpeza profunda. Banimentos e proteções são muito efetivos.';
          case MoonPhase.newMoon:
            return 'Fim de ciclo e novos começos. Banimentos, limpezas e proteções têm poder total.';
          default:
            return 'Momento favorável para feitiços de banimento e corte.';
        }
      } else {
        final daysUntilWaning = _getDaysUntilPhase(MoonPhase.waningGibbous);
        if (daysUntilWaning != null && daysUntilWaning <= 3) {
          return 'A lua minguante está chegando em $daysUntilWaning ${daysUntilWaning == 1 ? 'dia' : 'dias'}. Prepare-se!';
        }
        return 'Para melhores resultados em feitiços de banimento, aguarde a próxima lua minguante.';
      }
    }
  }

  int? _getDaysUntilPhase(MoonPhase targetPhase) {
    for (int i = 1; i <= 30; i++) {
      final nextDate = _selectedDate.add(Duration(days: i));
      final tempProvider = LunarProvider();
      tempProvider._selectedDate = nextDate;
      if (tempProvider.getCurrentMoonPhase() == targetPhase) {
        return i;
      }
    }
    return null;
  }
}
