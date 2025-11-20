import '../models/birth_chart_model.dart';
import '../models/magical_profile_model.dart';
import '../models/planet_position_model.dart';
import '../models/enums.dart';

/// Interpretador Mágico
///
/// Gera perfil mágico personalizado baseado no mapa natal
class MagicalInterpreter {
  static final MagicalInterpreter instance = MagicalInterpreter._();

  MagicalInterpreter._();

  MagicalProfile interpretChart(BirthChartModel chart) {
    // 1. Analisar elementos
    final elementDist = chart.getElementDistribution();
    final dominantElement = _getDominantElement(elementDist);

    // 2. Analisar modalidades
    final modalityDist = chart.getModalityDistribution();
    final dominantModality = _getDominantModality(modalityDist);

    // 3. Interpretar planetas pessoais
    final sun = chart.sun;
    final moon = chart.moon;
    final mercury = chart.mercury;
    final venus = chart.venus;
    final mars = chart.mars;

    // 4. Analisar casas especiais
    final house8 = chart.house8;
    final house12 = chart.house12;
    final house8Planets = chart.getPlanetsInHouse(8);
    final house12Planets = chart.getPlanetsInHouse(12);

    return MagicalProfile(
      userId: chart.userId,
      birthChartId: chart.id,
      dominantElement: dominantElement,
      elementDistribution: elementDist,
      dominantModality: dominantModality,
      modalityDistribution: modalityDist,
      magicalEssence: _interpretSun(sun),
      intuitiveGifts: _interpretMoon(moon),
      communicationStyle: _interpretMercury(mercury),
      loveAndBeauty: _interpretVenus(venus),
      protectiveEnergy: _interpretMars(mars),
      houseOfMagic: _interpretHouse8(house8, house8Planets),
      houseOfSpirit: _interpretHouse12(house12, house12Planets),
      magicalStrengths: _calculateStrengths(chart),
      recommendedPractices: _recommendPractices(chart, dominantElement),
      favorableTools: _recommendTools(chart, dominantElement),
      shadowWork: _identifyShadowWork(chart),
      generatedAt: DateTime.now(),
    );
  }

  Element _getDominantElement(Map<Element, int> distribution) {
    Element dominant = Element.fire;
    int maxCount = 0;

    distribution.forEach((element, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = element;
      }
    });

    return dominant;
  }

  Modality _getDominantModality(Map<Modality, int> distribution) {
    Modality dominant = Modality.cardinal;
    int maxCount = 0;

    distribution.forEach((modality, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = modality;
      }
    });

    return dominant;
  }

  String _interpretSun(PlanetPosition sun) {
    switch (sun.sign) {
      case ZodiacSign.aries:
        return 'Sua essência mágica é de pioneirismo e coragem. Você é uma bruxa guerreira, '
            'que age com rapidez e decisão. Seus feitiços mais poderosos envolvem iniciar novos '
            'ciclos e quebrar barreiras. Use o fogo como seu elemento principal.';

      case ZodiacSign.taurus:
        return 'Sua essência mágica está enraizada na terra e na manifestação. Você é uma bruxa '
            'que traz o mundo espiritual para o físico. Seus feitiços mais poderosos envolvem '
            'prosperidade, sensualidade e beleza. Trabalhe com cristais e ervas.';

      case ZodiacSign.gemini:
        return 'Sua essência mágica flui através da comunicação e do conhecimento. Você é uma '
            'bruxa estudiosa, que domina a magia através de palavras e símbolos. Seus feitiços mais '
            'poderosos envolvem comunicação, aprendizado e versatilidade.';

      case ZodiacSign.cancer:
        return 'Sua essência mágica flui com as marés lunares. Você é uma bruxa intuitiva, '
            'profundamente conectada às emoções. Seus feitiços mais poderosos envolvem proteção '
            'do lar, cura emocional e magia lunar.';

      case ZodiacSign.leo:
        return 'Sua essência mágica brilha como o Sol. Você é uma bruxa radiante, confiante e '
            'criativa. Seus feitiços mais poderosos envolvem autoexpressão, criatividade e '
            'liderança. Use rituais solares.';

      case ZodiacSign.virgo:
        return 'Sua essência mágica está na precisão e no serviço. Você é uma bruxa meticulosa, '
            'que domina os detalhes de cada ritual. Seus feitiços mais poderosos envolvem cura, '
            'purificação e magia herbal.';

      case ZodiacSign.libra:
        return 'Sua essência mágica busca o equilíbrio e a harmonia. Você é uma bruxa diplomata, '
            'que trabalha com energias de beleza e justiça. Seus feitiços mais poderosos envolvem '
            'relacionamentos, harmonia e estética.';

      case ZodiacSign.scorpio:
        return 'Sua essência mágica mergulha nas profundezas. Você é uma bruxa transformadora, '
            'que não teme as sombras. Seus feitiços mais poderosos envolvem transformação profunda, '
            'magia sexual e renascimento.';

      case ZodiacSign.sagittarius:
        return 'Sua essência mágica busca a sabedoria e a expansão. Você é uma bruxa filósofa, '
            'que explora diferentes tradições. Seus feitiços mais poderosos envolvem crescimento '
            'espiritual, proteção em viagens e abundância.';

      case ZodiacSign.capricorn:
        return 'Sua essência mágica é estruturada e ambiciosa. Você é uma bruxa disciplinada, '
            'que constrói poder ao longo do tempo. Seus feitiços mais poderosos envolvem manifestação '
            'material, carreira e magia saturnina.';

      case ZodiacSign.aquarius:
        return 'Sua essência mágica é inovadora e única. Você é uma bruxa revolucionária, que '
            'quebra tradições e cria novos caminhos. Seus feitiços mais poderosos envolvem mudança '
            'social, intuição e magia tecnológica.';

      case ZodiacSign.pisces:
        return 'Sua essência mágica dissolve fronteiras. Você é uma bruxa mística, profundamente '
            'conectada ao inconsciente coletivo. Seus feitiços mais poderosos envolvem sonhos, '
            'mediunidade e compaixão universal.';
    }
  }

  String _interpretMoon(PlanetPosition moon) {
    final sign = moon.sign;
    final house = moon.houseNumber;

    String base = 'Sua Lua em ${sign.displayName} na Casa $house ';

    switch (sign) {
      case ZodiacSign.aries:
        base += 'traz intuições rápidas e instintivas. Confie em seus primeiros impulsos.';
        break;
      case ZodiacSign.taurus:
        base += 'oferece intuição através dos sentidos. Trabalhe com aromas, texturas e sabores.';
        break;
      case ZodiacSign.cancer:
        base += 'amplifica sua sensibilidade psíquica. Você é naturalmente empática e receptiva.';
        break;
      case ZodiacSign.scorpio:
        base += 'mergulha nas profundezas emocionais. Você tem dons psíquicos poderosos.';
        break;
      case ZodiacSign.pisces:
        base += 'dissolve as fronteiras entre mundos. Você pode ter sonhos proféticos.';
        break;
      default:
        base += 'oferece intuição de acordo com ${sign.element.displayName}. '
            'Trabalhe com esse elemento para fortalecer sua conexão.';
    }

    return base;
  }

  String _interpretMercury(PlanetPosition mercury) {
    final sign = mercury.sign;

    switch (sign.element) {
      case Element.fire:
        return 'Sua comunicação mágica é direta e inspiradora. Use afirmações poderosas '
            'e encantamentos falados em voz alta.';
      case Element.earth:
        return 'Sua comunicação mágica é prática e fundamentada. Escreva seus feitiços e '
            'trabalhe com grimórios físicos.';
      case Element.air:
        return 'Sua comunicação mágica é versátil e clara. Você é excelente em leitura de runas, '
            'tarô e outros sistemas divinatórios baseados em símbolos.';
      case Element.water:
        return 'Sua comunicação mágica é intuitiva e emocional. Trabalhe com poesia, música e '
            'expressão criativa em seus rituais.';
    }
  }

  String _interpretVenus(PlanetPosition venus) {
    return 'Sua Vênus em ${venus.sign.displayName} indica que você atrai beleza e prazer através '
        'de ${venus.sign.element.displayName}. Incorpore esse elemento em feitiços de amor e autocuidado.';
  }

  String _interpretMars(PlanetPosition mars) {
    return 'Seu Marte em ${mars.sign.displayName} mostra que sua energia protetora se manifesta através '
        'de ${mars.sign.element.displayName}. Use esse elemento em feitiços de proteção e banimento.';
  }

  String _interpretHouse8(House house, List<PlanetPosition> planets) {
    String interpretation = 'Sua Casa 8 (magia e ocultismo) está em ${house.sign.displayName}. ';

    if (planets.isEmpty) {
      interpretation += 'Embora não haja planetas aqui, você ainda pode desenvolver suas habilidades '
          'mágicas através da prática consciente.';
    } else {
      interpretation += 'Com ${planets.length} planeta(s) aqui, você tem forte afinidade natural '
          'com magia: ${planets.map((p) => p.planet.displayName).join(', ')}. ';

      if (planets.any((p) => p.planet == Planet.moon)) {
        interpretation += 'A Lua aqui intensifica sua intuição mágica. ';
      }
      if (planets.any((p) => p.planet == Planet.pluto)) {
        interpretation += 'Plutão aqui indica poderes transformadores profundos. ';
      }
    }

    return interpretation;
  }

  String _interpretHouse12(House house, List<PlanetPosition> planets) {
    String interpretation = 'Sua Casa 12 (espiritualidade) está em ${house.sign.displayName}. ';

    if (planets.isEmpty) {
      interpretation += 'Desenvolva sua conexão espiritual através de meditação e sonhos.';
    } else {
      interpretation += 'Com ${planets.length} planeta(s) aqui, você tem forte conexão com o divino: '
          '${planets.map((p) => p.planet.displayName).join(', ')}. ';

      if (planets.any((p) => p.planet == Planet.neptune)) {
        interpretation += 'Netuno aqui amplifica sua mediunidade e conexão mística. ';
      }
      if (planets.any((p) => p.planet == Planet.moon)) {
        interpretation += 'A Lua aqui traz sonhos proféticos e forte intuição. ';
      }
    }

    return interpretation;
  }

  List<String> _calculateStrengths(BirthChartModel chart) {
    final strengths = <String>[];

    // Baseado em aspectos harmônicos
    final harmonicAspects = chart.aspects.where((a) => a.type.isHarmonious).toList();

    if (harmonicAspects.any((a) =>
        (a.planet1 == Planet.moon || a.planet2 == Planet.moon) &&
        (a.planet1 == Planet.neptune || a.planet2 == Planet.neptune))) {
      strengths.add('Intuição psíquica natural');
    }

    if (harmonicAspects.any((a) =>
        (a.planet1 == Planet.sun || a.planet2 == Planet.sun) &&
        (a.planet1 == Planet.moon || a.planet2 == Planet.moon))) {
      strengths.add('Equilíbrio entre ação e intuição');
    }

    // Baseado em planetas em casas mágicas
    if (chart.getPlanetsInHouse(8).isNotEmpty) {
      strengths.add('Afinidade natural com magia');
    }

    if (chart.getPlanetsInHouse(12).isNotEmpty) {
      strengths.add('Conexão espiritual profunda');
    }

    // Baseado no elemento dominante
    final element = _getDominantElement(chart.getElementDistribution());
    strengths.add('Domínio do elemento ${element.displayName}');

    return strengths;
  }

  List<String> _recommendPractices(BirthChartModel chart, Element dominantElement) {
    final practices = <String>[];

    // Baseado no elemento dominante
    switch (dominantElement) {
      case Element.fire:
        practices.addAll([
          'Magia de velas',
          'Rituais sob o sol',
          'Trabalho com fogo sagrado',
          'Feitiços de ação rápida',
        ]);
        break;
      case Element.earth:
        practices.addAll([
          'Bruxaria verde (ervas e plantas)',
          'Magia de cristais',
          'Rituais de manifestação',
          'Trabalho com altar permanente',
        ]);
        break;
      case Element.air:
        practices.addAll([
          'Magia de palavras e encantamentos',
          'Leitura de runas e tarô',
          'Trabalho com incensos',
          'Comunicação com espíritos',
        ]);
        break;
      case Element.water:
        practices.addAll([
          'Magia lunar',
          'Banhos rituais',
          'Trabalho com sonhos',
          'Adivinhação por água',
        ]);
        break;
    }

    // Baseado em planetas em casas específicas
    if (chart.getPlanetsInHouse(8).isNotEmpty) {
      practices.add('Magia sexual e transformação profunda');
      practices.add('Trabalho com sombras');
    }

    if (chart.getPlanetsInHouse(12).isNotEmpty) {
      practices.add('Meditação e viagens astrais');
      practices.add('Trabalho com o inconsciente');
    }

    return practices;
  }

  List<String> _recommendTools(BirthChartModel chart, Element dominantElement) {
    final tools = <String>[];

    // Cristais baseados no elemento
    switch (dominantElement) {
      case Element.fire:
        tools.addAll(['Citrino', 'Cornalina', 'Rubi', 'Velas vermelhas/laranja']);
        break;
      case Element.earth:
        tools.addAll(['Quartzo Verde', 'Turmalina Negra', 'Sal grosso', 'Ervas']);
        break;
      case Element.air:
        tools.addAll(['Quartzo Transparente', 'Ametista', 'Incensos', 'Penas']);
        break;
      case Element.water:
        tools.addAll(['Pedra da Lua', 'Água lunar', 'Conchas', 'Espelho']);
        break;
    }

    // Baseado no Sol
    tools.add('Cristal de ${chart.sun.sign.displayName}');

    // Baseado na Lua
    tools.add('Erva de ${chart.moon.sign.displayName}');

    return tools;
  }

  List<String> _identifyShadowWork(BirthChartModel chart) {
    final shadowWork = <String>[];

    // Baseado em aspectos desafiadores
    final challengingAspects = chart.aspects.where((a) => a.type.isChallenging).toList();

    if (challengingAspects.any((a) =>
        (a.planet1 == Planet.sun || a.planet2 == Planet.sun) &&
        (a.planet1 == Planet.moon || a.planet2 == Planet.moon))) {
      shadowWork.add('Integrar ego consciente com necessidades emocionais');
    }

    if (challengingAspects.any((a) =>
        a.planet1 == Planet.saturn || a.planet2 == Planet.saturn)) {
      shadowWork.add('Trabalhar com limitações e estruturas rígidas');
    }

    if (chart.getPlanetsInHouse(12).length > 2) {
      shadowWork.add('Explorar aspectos ocultos da personalidade através de meditação');
    }

    return shadowWork;
  }
}
