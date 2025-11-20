import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/enums.dart';
import '../models/transit_model.dart';
import '../models/birth_chart_model.dart';
import 'transit_calculator.dart';

/// Interpreta trânsitos para contexto de bruxaria e magia
class TransitInterpreter {
  final TransitCalculator _calculator = TransitCalculator();

  /// Gera o clima mágico diário
  Future<DailyMagicalWeather> getDailyMagicalWeather(DateTime date) async {
    final transits = await _calculator.calculateTransits(date);
    final moonTransit = transits.firstWhere((t) => t.planet == Planet.moon);
    final moonPhase = _calculateMoonPhase(date);

    // Analisar aspectos entre planetas em trânsito
    final significantAspects = _getSignificantTransitAspects(transits);

    // Determinar energia geral do dia
    final overallEnergy = _determineOverallEnergy(transits, significantAspects);

    // Gerar interpretação geral
    final interpretation = _generateGeneralInterpretation(
      moonTransit.sign,
      moonPhase,
      significantAspects,
      overallEnergy,
    );

    // Gerar recomendações de práticas
    final practices = _generateRecommendedPractices(
      moonTransit.sign,
      moonPhase,
      significantAspects,
      overallEnergy,
    );

    // Extrair palavras-chave de energia
    final keywords = _extractEnergyKeywords(
      moonTransit.sign,
      moonPhase,
      significantAspects,
    );

    return DailyMagicalWeather(
      date: date,
      transits: transits,
      aspects: significantAspects,
      generalInterpretation: interpretation,
      recommendedPractices: practices,
      energyKeywords: keywords,
      overallEnergy: overallEnergy,
      moonSign: moonTransit.sign,
      moonPhase: moonPhase,
    );
  }

  /// Gera sugestões personalizadas baseadas em trânsitos e mapa natal
  Future<List<PersonalizedSuggestion>> generatePersonalizedSuggestions(
    DateTime date,
    BirthChartModel natalChart,
  ) async {
    final suggestions = <PersonalizedSuggestion>[];
    final transits = await _calculator.calculateTransits(date);
    final aspects =
        await _calculator.calculateTransitAspects(transits, natalChart);

    // Filtrar apenas aspectos mais importantes (orb < 3°)
    final importantAspects = aspects.where((a) => a.orb < 3.0).toList();

    // Agrupar por tipo de energia
    final conjunctions =
        importantAspects.where((a) => a.aspectType == AspectType.conjunction);
    final harmonious = importantAspects.where(
        (a) => a.aspectType == AspectType.trine || a.aspectType == AspectType.sextile);
    final challenging = importantAspects.where(
        (a) => a.aspectType == AspectType.square || a.aspectType == AspectType.opposition);

    // Gerar sugestões para conjunções (muito importantes)
    for (final aspect in conjunctions.take(2)) {
      suggestions.add(_createSuggestionFromAspect(date, aspect, 'conjunction'));
    }

    // Gerar sugestões para aspectos harmoniosos (oportunidades)
    for (final aspect in harmonious.take(2)) {
      suggestions.add(_createSuggestionFromAspect(date, aspect, 'harmonious'));
    }

    // Gerar sugestões para aspectos desafiadores (trabalho necessário)
    for (final aspect in challenging.take(1)) {
      suggestions.add(_createSuggestionFromAspect(date, aspect, 'challenging'));
    }

    // Sugestão baseada na Lua
    final moonTransit = transits.firstWhere((t) => t.planet == Planet.moon);
    suggestions.add(_createMoonSuggestion(date, moonTransit));

    return suggestions;
  }

  /// Calcula a fase da lua (simplificado)
  String _calculateMoonPhase(DateTime date) {
    // Ciclo lunar: ~29.53 dias
    final referenceNewMoon = DateTime(2000, 1, 6); // Lua Nova conhecida
    final daysSinceReference = date.difference(referenceNewMoon).inDays;
    final phaseInCycle = (daysSinceReference % 29.53) / 29.53;

    if (phaseInCycle < 0.0625) return 'Lua Nova';
    if (phaseInCycle < 0.1875) return 'Lua Crescente';
    if (phaseInCycle < 0.3125) return 'Quarto Crescente';
    if (phaseInCycle < 0.4375) return 'Lua Gibosa Crescente';
    if (phaseInCycle < 0.5625) return 'Lua Cheia';
    if (phaseInCycle < 0.6875) return 'Lua Gibosa Minguante';
    if (phaseInCycle < 0.8125) return 'Quarto Minguante';
    if (phaseInCycle < 0.9375) return 'Lua Minguante';
    return 'Lua Nova';
  }

  /// Identifica aspectos significativos entre planetas em trânsito
  List<TransitAspect> _getSignificantTransitAspects(List<Transit> transits) {
    final aspects = <TransitAspect>[];

    // Verificar aspectos entre planetas em trânsito
    for (var i = 0; i < transits.length; i++) {
      for (var j = i + 1; j < transits.length; j++) {
        final t1 = transits[i];
        final t2 = transits[j];

        final long1 = (t1.sign.index * 30.0) + t1.degree;
        final long2 = (t2.sign.index * 30.0) + t2.degree;

        var diff = (long1 - long2).abs();
        if (diff > 180) diff = 360 - diff;

        // Verificar aspectos principais
        for (final aspectType in [
          AspectType.conjunction,
          AspectType.opposition,
          AspectType.trine,
          AspectType.square,
          AspectType.sextile,
        ]) {
          final orb = (diff - aspectType.angle).abs();

          // Orb mais apertado para trânsitos (5°)
          if (orb <= 5.0) {
            aspects.add(TransitAspect(
              transitPlanet: t1.planet,
              natalPlanet: t2.planet,
              aspectType: aspectType,
              orb: orb,
              interpretation: _interpretTransitAspect(t1.planet, t2.planet, aspectType),
              energyLevel: _getAspectEnergyLevel(aspectType),
            ));
          }
        }
      }
    }

    aspects.sort((a, b) => a.orb.compareTo(b.orb));
    return aspects.take(5).toList();
  }

  /// Determina a energia geral do dia
  EnergyLevel _determineOverallEnergy(
      List<Transit> transits, List<TransitAspect> aspects) {
    var intensityScore = 0;

    // Aspectos tensos aumentam intensidade
    for (final aspect in aspects) {
      if (aspect.energyLevel == EnergyLevel.intense) intensityScore += 3;
      if (aspect.energyLevel == EnergyLevel.challenging) intensityScore += 2;
      if (aspect.energyLevel == EnergyLevel.harmonious) intensityScore += 1;
    }

    if (intensityScore >= 8) return EnergyLevel.intense;
    if (intensityScore >= 5) return EnergyLevel.challenging;
    if (intensityScore >= 3) return EnergyLevel.moderate;
    return EnergyLevel.harmonious;
  }

  /// Gera interpretação geral do dia
  String _generateGeneralInterpretation(
    ZodiacSign moonSign,
    String moonPhase,
    List<TransitAspect> aspects,
    EnergyLevel energy,
  ) {
    final parts = <String>[];

    // Fase lunar
    final phaseInterpretations = {
      'Lua Nova': 'Momento ideal para novos começos e intenções mágicas',
      'Lua Crescente': 'Energia crescente favorece manifestação e crescimento',
      'Quarto Crescente': 'Ação e movimento são favorecidos',
      'Lua Gibosa Crescente': 'Refinamento e ajustes antes da culminação',
      'Lua Cheia': 'Poder máximo para rituais e liberação',
      'Lua Gibosa Minguante': 'Gratidão e colheita dos frutos',
      'Quarto Minguante': 'Momento de liberação e limpeza',
      'Lua Minguante': 'Introspecção e banimento são favorecidos',
    };

    parts.add(phaseInterpretations[moonPhase] ??
        'A lua guia suas práticas mágicas');

    // Lua no signo
    parts.add(
        'Com a Lua em ${moonSign.displayName}, as emoções estão ${moonSign.magicalDescription}');

    // Energia do dia
    final energyDescriptions = {
      EnergyLevel.intense: 'O dia traz energia intensa e transformadora',
      EnergyLevel.challenging:
          'Desafios planetários pedem atenção e trabalho consciente',
      EnergyLevel.moderate: 'O fluxo energético está equilibrado e estável',
      EnergyLevel.harmonious: 'As energias fluem com harmonia e facilidade',
    };

    parts.add(energyDescriptions[energy]!);

    return parts.join('. ') + '.';
  }

  /// Gera recomendações de práticas
  List<String> _generateRecommendedPractices(
    ZodiacSign moonSign,
    String moonPhase,
    List<TransitAspect> aspects,
    EnergyLevel energy,
  ) {
    final practices = <String>[];

    // Práticas baseadas na fase lunar
    final phasePractices = {
      'Lua Nova': 'Definir intenções, plantar sementes mágicas, trabalho de manifestação',
      'Lua Crescente': 'Feitiços de atração, crescimento de projetos, magia verde',
      'Quarto Crescente': 'Rituais de coragem, ação mágica, trabalho com fogo',
      'Lua Gibosa Crescente': 'Ajuste de feitiços, refinamento de práticas',
      'Lua Cheia': 'Rituais poderosos, carregamento de ferramentas, água lunar',
      'Lua Gibosa Minguante': 'Gratidão, reconhecimento, oferendas',
      'Quarto Minguante': 'Banimento, limpeza energética, corte de cordas',
      'Lua Minguante': 'Meditação profunda, trabalho de sombra, divinação',
    };

    if (phasePractices.containsKey(moonPhase)) {
      practices.add(phasePractices[moonPhase]!);
    }

    // Práticas baseadas no signo lunar
    practices.add(moonSign.magicalDescription);

    // Práticas baseadas na energia
    if (energy == EnergyLevel.intense) {
      practices.add(
          'Aterramento e proteção são essenciais hoje');
    } else if (energy == EnergyLevel.harmonious) {
      practices.add(
          'Excelente momento para feitiços complexos e trabalho em grupo');
    }

    return practices.take(4).toList();
  }

  /// Extrai palavras-chave de energia
  List<String> _extractEnergyKeywords(
    ZodiacSign moonSign,
    String moonPhase,
    List<TransitAspect> aspects,
  ) {
    final keywords = <String>[];

    // Palavras da fase lunar
    final phaseKeywords = {
      'Lua Nova': ['renovação', 'intenção', 'início'],
      'Lua Crescente': ['crescimento', 'expansão', 'manifestação'],
      'Quarto Crescente': ['ação', 'movimento', 'decisão'],
      'Lua Gibosa Crescente': ['refinamento', 'paciência', 'preparação'],
      'Lua Cheia': ['poder', 'culminação', 'plenitude'],
      'Lua Gibosa Minguante': ['gratidão', 'compartilhamento', 'colheita'],
      'Quarto Minguante': ['liberação', 'limpeza', 'transformação'],
      'Lua Minguante': ['introspecção', 'sabedoria', 'descanso'],
    };

    keywords.addAll(phaseKeywords[moonPhase] ?? []);

    // Palavras do elemento lunar
    keywords.add(moonSign.element.displayName.toLowerCase());

    // Palavras dos aspectos
    for (final aspect in aspects.take(2)) {
      if (aspect.energyLevel == EnergyLevel.intense) {
        keywords.add('intensidade');
      } else if (aspect.energyLevel == EnergyLevel.harmonious) {
        keywords.add('harmonia');
      }
    }

    return keywords.take(6).toList();
  }

  /// Interpreta um aspecto entre dois planetas em trânsito
  String _interpretTransitAspect(
      Planet p1, Planet p2, AspectType aspect) {
    return '${p1.displayName} ${aspect.symbol} ${p2.displayName}: energia ${aspect.description}';
  }

  /// Determina o nível de energia de um aspecto
  EnergyLevel _getAspectEnergyLevel(AspectType aspect) {
    if (aspect == AspectType.conjunction) return EnergyLevel.intense;
    if (aspect == AspectType.opposition) return EnergyLevel.challenging;
    if (aspect == AspectType.square) return EnergyLevel.challenging;
    if (aspect == AspectType.trine) return EnergyLevel.harmonious;
    if (aspect == AspectType.sextile) return EnergyLevel.harmonious;
    return EnergyLevel.moderate;
  }

  /// Cria sugestão personalizada a partir de um aspecto
  PersonalizedSuggestion _createSuggestionFromAspect(
    DateTime date,
    TransitAspect aspect,
    String type,
  ) {
    final uuid = const Uuid();

    if (type == 'conjunction') {
      return PersonalizedSuggestion(
        id: uuid.v4(),
        date: date,
        title: 'Conjunção ${aspect.transitPlanet.displayName}-${aspect.natalPlanet.displayName}',
        description:
            'Este aspecto poderoso une as energias de ${aspect.transitPlanet.displayName} e seu ${aspect.natalPlanet.displayName} natal. É momento de integração profunda.',
        practices: [
          'Meditação focada nestas energias',
          'Ritual de integração e alinhamento',
          'Trabalho com cristais correspondentes',
        ],
        relevantAspects: [aspect],
        priority: EnergyLevel.intense,
        category: 'ritual',
      );
    } else if (type == 'harmonious') {
      return PersonalizedSuggestion(
        id: uuid.v4(),
        date: date,
        title: 'Energia Harmoniosa Disponível',
        description:
            '${aspect.transitPlanet.displayName} ${aspect.aspectType.symbol} seu ${aspect.natalPlanet.displayName} natal cria um fluxo positivo de energia.',
        practices: [
          'Feitiços de manifestação e atração',
          'Trabalho criativo e inspirado',
          'Conexão com guias espirituais',
        ],
        relevantAspects: [aspect],
        priority: EnergyLevel.harmonious,
        category: 'spell',
      );
    } else {
      return PersonalizedSuggestion(
        id: uuid.v4(),
        date: date,
        title: 'Desafio para Crescimento',
        description:
            'O aspecto ${aspect.aspectType.displayName} entre ${aspect.transitPlanet.displayName} e seu ${aspect.natalPlanet.displayName} natal traz lições importantes.',
        practices: [
          'Trabalho de sombra e autoconhecimento',
          'Banimento de padrões antigos',
          'Proteção e aterramento',
        ],
        relevantAspects: [aspect],
        priority: EnergyLevel.challenging,
        category: 'meditation',
      );
    }
  }

  /// Cria sugestão baseada na posição da Lua
  PersonalizedSuggestion _createMoonSuggestion(
      DateTime date, Transit moonTransit) {
    final uuid = const Uuid();

    return PersonalizedSuggestion(
      id: uuid.v4(),
      date: date,
      title: 'Lua em ${moonTransit.sign.displayName}',
      description:
          'A Lua transita por ${moonTransit.sign.displayName}, trazendo energias ${moonTransit.sign.element.displayName} para suas emoções e intuição.',
      practices: [
        'Trabalho com água e emoções',
        'Divinação e leitura intuitiva',
        'Conexão com a energia lunar',
      ],
      relevantAspects: [],
      priority: EnergyLevel.moderate,
      category: 'divination',
    );
  }
}
