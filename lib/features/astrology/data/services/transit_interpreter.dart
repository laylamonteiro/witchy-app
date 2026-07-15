import 'package:uuid/uuid.dart';
import '../models/enums.dart';
import '../models/transit_model.dart';
import '../models/birth_chart_model.dart';
import 'transit_calculator.dart';

/// Interpreta trânsitos para contexto de bruxaria e magia
class TransitInterpreter {
  final TransitCalculator _calculator = TransitCalculator();

  /// Gera o clima mágico diário
  Future<DailyMagicalWeather> getDailyMagicalWeather(
    DateTime date, {
    BirthChartModel? natalChart,
  }) async {
    try {
      final transits = await _calculator.calculateTransits(date);

      print(
          '🌟 TransitInterpreter: ${transits.length} trânsitos calculados inicialmente');

      // Garantir que temos pelo menos Sol e Lua (CRÍTICO!)
      _ensureEssentialTransits(transits, date);

      print(
          '✅ TransitInterpreter: ${transits.length} trânsitos após garantir essenciais');

      // Agora podemos assumir que a Lua está presente
      final moonTransit = transits.firstWhere((t) => t.planet == Planet.moon);
      final moonPhase = _calculateMoonPhase(date);

      // Analisar aspectos entre planetas em trânsito
      final transitAspects = _getSignificantTransitAspects(transits);
      final personalizedAspects = natalChart == null
          ? <TransitAspect>[]
          : (await _calculator.calculateTransitAspects(transits, natalChart))
              .where((aspect) => aspect.orb <= 5)
              .take(5)
              .toList();
      final significantAspects = [...transitAspects, ...personalizedAspects]
        ..sort((a, b) => a.orb.compareTo(b.orb));
      if (significantAspects.length > 5) {
        significantAspects.removeRange(5, significantAspects.length);
      }

      // Determinar energia geral do dia
      final overallEnergy =
          _determineOverallEnergy(transits, significantAspects);

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
    } catch (e) {
      print('Erro em getDailyMagicalWeather: $e');
      rethrow;
    }
  }

  /// Gera sugestões personalizadas baseadas em trânsitos e mapa natal
  Future<List<PersonalizedSuggestion>> generatePersonalizedSuggestions(
    DateTime date,
    BirthChartModel natalChart,
  ) async {
    final suggestions = <PersonalizedSuggestion>[];
    final transits = await _calculator.calculateTransits(date);

    print(
        '🌟 PersonalizedSuggestions: ${transits.length} trânsitos calculados');

    // Garantir que temos pelo menos Sol e Lua (CRÍTICO!)
    _ensureEssentialTransits(transits, date);

    print(
        '✅ PersonalizedSuggestions: ${transits.length} trânsitos após garantir essenciais');

    final aspects =
        await _calculator.calculateTransitAspects(transits, natalChart);

    // Filtrar apenas aspectos mais importantes (orb < 3°)
    final importantAspects = aspects.where((a) => a.orb < 3.0).toList();

    // Agrupar por tipo de energia
    final conjunctions =
        importantAspects.where((a) => a.aspectType == AspectType.conjunction);
    final harmonious = importantAspects.where((a) =>
        a.aspectType == AspectType.trine || a.aspectType == AspectType.sextile);
    final challenging = importantAspects.where((a) =>
        a.aspectType == AspectType.square ||
        a.aspectType == AspectType.opposition);

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

    // Sugestão baseada na Lua (se disponível)
    try {
      final moonTransit = transits.firstWhere((t) => t.planet == Planet.moon);
      suggestions.add(_createMoonSuggestion(date, moonTransit));
    } catch (e) {
      print('⚠️ Lua não encontrada nos trânsitos, pulando sugestão lunar');
    }

    return suggestions;
  }

  /// Calcula a fase da lua (sincronizado com LunarProvider)
  String _calculateMoonPhase(DateTime date) {
    // Usar a mesma referência do LunarProvider para consistência
    // Lua nova conhecida: 1 de novembro de 2024, 12:47 UTC
    final knownNewMoon = DateTime.utc(2024, 11, 1, 12, 47);

    // Calcular diferença em dias com precisão de horas
    final difference = date.toUtc().difference(knownNewMoon);
    final daysSinceKnownNewMoon = difference.inHours / 24.0;

    // Ciclo lunar médio é de 29.53059 dias
    const lunarCycle = 29.53059;
    final phase = (daysSinceKnownNewMoon % lunarCycle) / lunarCycle;

    // Usar os mesmos thresholds do LunarProvider para consistência
    if (phase < 0.017 || phase >= 0.983) {
      return 'Lua Nova';
    } else if (phase < 0.1875) {
      return 'Lua Crescente';
    } else if (phase < 0.3125) {
      return 'Quarto Crescente';
    } else if (phase < 0.4375) {
      return 'Lua Gibosa Crescente';
    } else if (phase < 0.5625) {
      return 'Lua Cheia';
    } else if (phase < 0.6875) {
      return 'Lua Gibosa Minguante';
    } else if (phase < 0.8125) {
      return 'Quarto Minguante';
    } else {
      return 'Lua Minguante';
    }
  }

  /// Identifica aspectos significativos entre planetas em trânsito
  List<TransitAspect> _getSignificantTransitAspects(List<Transit> transits) {
    final aspects = <TransitAspect>[];

    try {
      // Verificar aspectos entre planetas em trânsito
      for (var i = 0; i < transits.length; i++) {
        for (var j = i + 1; j < transits.length; j++) {
          final t1 = transits[i];
          final t2 = transits[j];

          final long1 = (t1.sign.index * 30.0) + t1.degree;
          final long2 = (t2.sign.index * 30.0) + t2.degree;

          var diff = (long1 - long2).abs();
          if (diff > 180) diff = 360 - diff;

          // Verificar se diff é válido
          if (diff.isNaN || diff.isInfinite) continue;

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
            if (orb <= 5.0 && !orb.isNaN && !orb.isInfinite) {
              aspects.add(TransitAspect(
                transitPlanet: t1.planet,
                natalPlanet: t2.planet,
                aspectType: aspectType,
                orb: orb,
                interpretation:
                    _interpretTransitAspect(t1.planet, t2.planet, aspectType),
                energyLevel: _getAspectEnergyLevel(aspectType),
              ));
            }
          }
        }
      }

      aspects.sort((a, b) => a.orb.compareTo(b.orb));
      return aspects.take(5).toList();
    } catch (e) {
      print('Erro em _getSignificantTransitAspects: $e');
      return []; // Retorna lista vazia em caso de erro
    }
  }

  /// Determina a energia geral do dia
  EnergyLevel _determineOverallEnergy(
      List<Transit> transits, List<TransitAspect> aspects) {
    var intensityScore = 0;

    // Aspectos tensos aumentam a pontuação; aspectos harmoniosos a reduzem.
    for (final aspect in aspects) {
      switch (aspect.aspectType) {
        case AspectType.conjunction:
          intensityScore += 3;
        case AspectType.opposition:
        case AspectType.square:
          intensityScore += 2;
        case AspectType.trine:
        case AspectType.sextile:
          intensityScore -= 1;
      }
    }

    if (intensityScore >= 8) return EnergyLevel.intense;
    if (intensityScore >= 4) return EnergyLevel.challenging;
    if (intensityScore >= 1) return EnergyLevel.moderate;
    return EnergyLevel.harmonious;
  }

  /// Expõe a classificação determinística para testes de regressão.
  EnergyLevel determineOverallEnergyForTest(List<TransitAspect> aspects) =>
      _determineOverallEnergy(const [], aspects);

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

    parts.add(
        phaseInterpretations[moonPhase] ?? 'A lua guia suas práticas mágicas');

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
      'Lua Nova':
          'Definir intenções, plantar sementes mágicas, trabalho de manifestação',
      'Lua Crescente':
          'Feitiços de atração, crescimento de projetos, magia verde',
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
      practices.add('Aterramento e proteção são essenciais hoje');
    } else if (energy == EnergyLevel.harmonious) {
      practices
          .add('Excelente momento para feitiços complexos e trabalho em grupo');
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
  String _interpretTransitAspect(Planet p1, Planet p2, AspectType aspect) {
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
        title:
            'Conjunção ${aspect.transitPlanet.displayName}-${aspect.natalPlanet.displayName}',
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

  /// Estima a posição da Lua quando o cálculo preciso falhar
  Transit _estimateMoonPosition(DateTime date) {
    // A Lua se move aproximadamente 13.17 graus por dia
    final daysSinceEpoch = date.difference(DateTime(2000, 1, 1)).inDays;
    final moonLongitude = (218.0 + (13.1764 * daysSinceEpoch)) % 360;

    final signIndex = (moonLongitude / 30).floor() % 12;
    final degree = moonLongitude % 30;

    return Transit(
      planet: Planet.moon,
      sign: ZodiacSign.values[signIndex],
      degree: degree,
      isRetrograde: false,
    );
  }

  /// Estima a posição do Sol quando o cálculo preciso falhar
  Transit _estimateSunPosition(DateTime date) {
    // O Sol se move aproximadamente 0.9856 graus por dia
    final daysSinceEpoch = date.difference(DateTime(2000, 1, 1)).inDays;
    final sunLongitude = (280.0 + (0.9856 * daysSinceEpoch)) % 360;

    final signIndex = (sunLongitude / 30).floor() % 12;
    final degree = sunLongitude % 30;

    return Transit(
      planet: Planet.sun,
      sign: ZodiacSign.values[signIndex],
      degree: degree,
      isRetrograde: false,
    );
  }

  /// Garante que temos pelo menos Sol e Lua nos trânsitos
  void _ensureEssentialTransits(List<Transit> transits, DateTime date) {
    // Garantir Sol
    if (!transits.any((t) => t.planet == Planet.sun)) {
      print('⚠️ Sol não encontrado, adicionando posição estimada');
      transits.add(_estimateSunPosition(date));
    }

    // Garantir Lua
    if (!transits.any((t) => t.planet == Planet.moon)) {
      print('⚠️ Lua não encontrada, adicionando posição estimada');
      transits.add(_estimateMoonPosition(date));
    }
  }
}
