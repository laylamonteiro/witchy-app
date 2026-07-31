import '../data_sources/magical_interpreter_texts.dart';
import '../models/birth_chart_model.dart';
import '../models/magical_profile_model.dart';
import '../models/planet_position_model.dart';
import '../models/house_model.dart';
import '../models/enums.dart';

/// Interpretador Mágico
///
/// Gera perfil mágico personalizado baseado no mapa natal.
///
/// As frases-template vivem em
/// `data_sources/magical_interpreter_texts_pt/en/es.dart` e são selecionadas
/// pelo idioma atual via `ContentLocale` (getter [magicalInterpreterTexts]) —
/// o perfil é gerado (e persistido) no idioma ativo no momento da geração.
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
    return magicalInterpreterTexts.sunEssence[sun.sign]!;
  }

  String _interpretMoon(PlanetPosition moon) {
    final texts = magicalInterpreterTexts;
    final sign = moon.sign;

    final complement = texts.moonBySign[sign] ??
        texts.moonByElement(sign.element.displayName);

    return texts.moonIntro(sign.displayName, moon.houseNumber) + complement;
  }

  String _interpretMercury(PlanetPosition mercury) {
    return magicalInterpreterTexts.mercuryByElement[mercury.sign.element]!;
  }

  String _interpretVenus(PlanetPosition venus) {
    return magicalInterpreterTexts.venus(
      venus.sign.displayName,
      venus.sign.element.displayName,
    );
  }

  String _interpretMars(PlanetPosition mars) {
    return magicalInterpreterTexts.mars(
      mars.sign.displayName,
      mars.sign.element.displayName,
    );
  }

  String _interpretHouse8(House house, List<PlanetPosition> planets) {
    final texts = magicalInterpreterTexts;
    String interpretation = texts.house8Intro(house.sign.displayName);

    if (planets.isEmpty) {
      interpretation += texts.house8NoPlanets;
    } else {
      interpretation += texts.house8WithPlanets(
        planets.length,
        planets.map((p) => p.planet.displayName).join(', '),
      );

      if (planets.any((p) => p.planet == Planet.moon)) {
        interpretation += texts.house8Moon;
      }
      if (planets.any((p) => p.planet == Planet.pluto)) {
        interpretation += texts.house8Pluto;
      }
    }

    return interpretation;
  }

  String _interpretHouse12(House house, List<PlanetPosition> planets) {
    final texts = magicalInterpreterTexts;
    String interpretation = texts.house12Intro(house.sign.displayName);

    if (planets.isEmpty) {
      interpretation += texts.house12NoPlanets;
    } else {
      interpretation += texts.house12WithPlanets(
        planets.length,
        planets.map((p) => p.planet.displayName).join(', '),
      );

      if (planets.any((p) => p.planet == Planet.neptune)) {
        interpretation += texts.house12Neptune;
      }
      if (planets.any((p) => p.planet == Planet.moon)) {
        interpretation += texts.house12Moon;
      }
    }

    return interpretation;
  }

  List<String> _calculateStrengths(BirthChartModel chart) {
    final texts = magicalInterpreterTexts;
    final strengths = <String>[];

    // Baseado em aspectos harmônicos
    final harmonicAspects =
        chart.aspects.where((a) => a.type.isHarmonious).toList();

    if (harmonicAspects.any((a) =>
        (a.planet1 == Planet.moon || a.planet2 == Planet.moon) &&
        (a.planet1 == Planet.neptune || a.planet2 == Planet.neptune))) {
      strengths.add(texts.strengthPsychicIntuition);
    }

    if (harmonicAspects.any((a) =>
        (a.planet1 == Planet.sun || a.planet2 == Planet.sun) &&
        (a.planet1 == Planet.moon || a.planet2 == Planet.moon))) {
      strengths.add(texts.strengthSunMoonBalance);
    }

    // Baseado em planetas em casas mágicas
    if (chart.getPlanetsInHouse(8).isNotEmpty) {
      strengths.add(texts.strengthMagicAffinity);
    }

    if (chart.getPlanetsInHouse(12).isNotEmpty) {
      strengths.add(texts.strengthSpiritualConnection);
    }

    // Baseado no elemento dominante
    final element = _getDominantElement(chart.getElementDistribution());
    strengths.add(texts.strengthDominantElement(element.displayName));

    return strengths;
  }

  List<String> _recommendPractices(
      BirthChartModel chart, Element dominantElement) {
    final texts = magicalInterpreterTexts;
    final practices = <String>[];

    // Baseado no elemento dominante
    practices.addAll(texts.practicesByElement[dominantElement]!);

    // Baseado em planetas em casas específicas
    if (chart.getPlanetsInHouse(8).isNotEmpty) {
      practices.addAll(texts.practicesHouse8);
    }

    if (chart.getPlanetsInHouse(12).isNotEmpty) {
      practices.addAll(texts.practicesHouse12);
    }

    return practices;
  }

  List<String> _recommendTools(BirthChartModel chart, Element dominantElement) {
    final texts = magicalInterpreterTexts;
    final tools = <String>[];

    // Cristais baseados no elemento
    tools.addAll(texts.toolsByElement[dominantElement]!);

    // Baseado no Sol
    tools.add(texts.sunCrystal(chart.sun.sign.displayName));

    // Baseado na Lua
    tools.add(texts.moonHerb(chart.moon.sign.displayName));

    return tools;
  }

  List<String> _identifyShadowWork(BirthChartModel chart) {
    final texts = magicalInterpreterTexts;
    final shadowWork = <String>[];

    // Baseado em aspectos desafiadores
    final challengingAspects =
        chart.aspects.where((a) => a.type.isChallenging).toList();

    if (challengingAspects.any((a) =>
        (a.planet1 == Planet.sun || a.planet2 == Planet.sun) &&
        (a.planet1 == Planet.moon || a.planet2 == Planet.moon))) {
      shadowWork.add(texts.shadowSunMoon);
    }

    if (challengingAspects
        .any((a) => a.planet1 == Planet.saturn || a.planet2 == Planet.saturn)) {
      shadowWork.add(texts.shadowSaturn);
    }

    if (chart.getPlanetsInHouse(12).length > 2) {
      shadowWork.add(texts.shadowHouse12);
    }

    return shadowWork;
  }
}
