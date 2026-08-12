import '../../../../core/content/content_locale.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import '../../../grimoire/data/models/spell_model.dart';

AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

class LunarProvider with ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Lua nova conhecida mais recente: 1 de novembro de 2024, 12:47 UTC
  /// (09:47 no horário de Brasília). Uma referência recente aumenta a
  /// precisão do cálculo.
  static final DateTime _knownNewMoon = DateTime.utc(2024, 11, 1, 12, 47);

  /// Ciclo lunar médio, em dias.
  static const double _lunarCycle = 29.53059;

  // Calcula a fase da lua baseado no ciclo lunar (29.53 dias)
  MoonPhase getCurrentMoonPhase() {
    // Diferença em dias com precisão de minutos: arredondar para a hora
    // cheia deslocava as viradas de fase em até uma hora, e a virada é
    // justamente o que as "Próximas Fases" anunciam.
    final difference = _selectedDate.toUtc().difference(_knownNewMoon);
    final daysSinceKnownNewMoon =
        difference.inMinutes / Duration.minutesPerDay;

    final phase = (daysSinceKnownNewMoon % _lunarCycle) / _lunarCycle;

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

  /// Ponto do ciclo que MARCA cada fase.
  ///
  /// As quatro principais têm instante exato — nova (0), quarto crescente
  /// (¼), cheia (½) e quarto minguante (¾). As de transição são marcadas
  /// pelo momento em que COMEÇAM, que é a mesma fronteira usada por
  /// [getCurrentMoonPhase]: "quando a lua vira Crescente".
  static const Map<MoonPhase, double> _phaseMoment = {
    MoonPhase.newMoon: 0.0,
    MoonPhase.waxingCrescent: 0.017,
    MoonPhase.firstQuarter: 0.25,
    MoonPhase.waxingGibbous: 0.3125,
    MoonPhase.fullMoon: 0.5,
    MoonPhase.waningGibbous: 0.5625,
    MoonPhase.lastQuarter: 0.75,
    MoonPhase.waningCrescent: 0.8125,
  };

  /// Quando a fase acontece de verdade.
  ///
  /// Antes isto varria dia a dia e depois hora a hora, e parava na primeira
  /// hora DENTRO da janela da fase — ou seja, devolvia o começo da janela,
  /// não o evento: a lua cheia chegava quase dois dias adiantada e a nova,
  /// meio dia. Agora o instante sai direto da conta do ciclo.
  DateTime? _getNextPhaseWithTime(MoonPhase targetPhase) {
    final moment = _phaseMoment[targetPhase];
    if (moment == null) return null;

    final elapsedDays =
        _selectedDate.toUtc().difference(_knownNewMoon).inMinutes /
            Duration.minutesPerDay;
    final currentCycle = (elapsedDays / _lunarCycle).floor();

    // O ponto pode já ter passado neste ciclo: tenta o seguinte.
    for (var cycle = currentCycle; cycle <= currentCycle + 1; cycle++) {
      final days = (cycle + moment) * _lunarCycle;
      // `ceil` (e não `round`) garante que o minuto devolvido já esteja
      // DENTRO da fase: nas de transição o ponto é a própria fronteira, e
      // arredondar para trás faria a lista anunciar a fase anterior.
      final instant = _knownNewMoon
          .add(Duration(minutes: (days * Duration.minutesPerDay).ceil()))
          .toLocal();
      if (instant.isAfter(_selectedDate)) return instant;
    }
    return null;
  }

  // Retorna lista de todas as próximas fases em ordem cronológica
  List<Map<String, dynamic>> getAllNextPhases() {
    final phases = <Map<String, dynamic>>[];
    final currentPhase = getCurrentMoonPhase();

    // Buscar próximas ocorrências de todas as fases, exceto a atual
    for (final phase in MoonPhase.values) {
      // Pular a fase atual - não faz sentido mostrar "quanto tempo falta"
      // para a fase que já estamos vivendo
      if (phase == currentPhase) continue;

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
            return _l10n.lunarAdviceWaxingCrescent;
          case MoonPhase.firstQuarter:
            return _l10n.lunarAdviceFirstQuarter;
          case MoonPhase.waxingGibbous:
            return _l10n.lunarAdviceWaxingGibbous;
          case MoonPhase.fullMoon:
            return _l10n.lunarAdviceFullMoon;
          default:
            return _l10n.lunarAdviceWaxingGeneric;
        }
      } else {
        final daysUntilWaxing = _getDaysUntilPhase(MoonPhase.waxingCrescent);
        if (daysUntilWaxing != null && daysUntilWaxing <= 3) {
          return _l10n.lunarWaxingComing(daysUntilWaxing);
        }
        return _l10n.lunarWaitWaxing;
      }
    } else {
      if (isGoodTime) {
        switch (currentPhase) {
          case MoonPhase.waningGibbous:
            return _l10n.lunarAdviceWaningGibbous;
          case MoonPhase.lastQuarter:
            return _l10n.lunarAdviceLastQuarter;
          case MoonPhase.waningCrescent:
            return _l10n.lunarAdviceWaningCrescent;
          case MoonPhase.newMoon:
            return _l10n.lunarAdviceNewMoon;
          default:
            return _l10n.lunarAdviceWaningGeneric;
        }
      } else {
        final daysUntilWaning = _getDaysUntilPhase(MoonPhase.waningGibbous);
        if (daysUntilWaning != null && daysUntilWaning <= 3) {
          return _l10n.lunarWaningComing(daysUntilWaning);
        }
        return _l10n.lunarWaitWaning;
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
