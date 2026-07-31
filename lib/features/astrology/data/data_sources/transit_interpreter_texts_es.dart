import '../models/enums.dart';
import 'transit_interpreter_texts.dart';

/// Textos del intérprete de tránsitos — contenido en español.
///
/// Mantén las mismas claves/estructuras en los tres archivos
/// (`transit_interpreter_texts_pt/en/es.dart`) — la paridad se verifica en
/// `test/astrology_interpreters_parity_test.dart`.
final TransitInterpreterTexts transitInterpreterTextsEs =
    TransitInterpreterTexts(
  phaseNames: const {
    'newMoon': 'Luna Nueva',
    'waxingCrescent': 'Luna Creciente',
    'firstQuarter': 'Cuarto Creciente',
    'waxingGibbous': 'Luna Gibosa Creciente',
    'fullMoon': 'Luna Llena',
    'waningGibbous': 'Luna Gibosa Menguante',
    'lastQuarter': 'Cuarto Menguante',
    'waningCrescent': 'Luna Menguante',
  },
  phaseInterpretations: const {
    'newMoon': 'Momento ideal para nuevos comienzos e intenciones mágicas',
    'waxingCrescent':
        'La energía creciente favorece la manifestación y el crecimiento',
    'firstQuarter': 'La acción y el movimiento están favorecidos',
    'waxingGibbous': 'Refinamiento y ajustes antes de la culminación',
    'fullMoon': 'Poder máximo para rituales y liberación',
    'waningGibbous': 'Gratitud y cosecha de los frutos',
    'lastQuarter': 'Momento de liberación y limpieza',
    'waningCrescent': 'La introspección y el destierro están favorecidos',
  },
  phaseFallback: 'La luna guía tus prácticas mágicas',
  moonInSign: (moonSignName, signQualities) =>
      'Con la Luna en $moonSignName, las emociones se muestran $signQualities',
  energyDescriptions: const {
    EnergyLevel.intense: 'El día trae una energía intensa y transformadora',
    EnergyLevel.challenging:
        'Los desafíos planetarios piden atención y trabajo consciente',
    EnergyLevel.moderate: 'El flujo energético está equilibrado y estable',
    EnergyLevel.harmonious: 'Las energías fluyen con armonía y facilidad',
  },
  phasePractices: const {
    'newMoon':
        'Definir intenciones, plantar semillas mágicas, trabajo de manifestación',
    'waxingCrescent':
        'Hechizos de atracción, crecimiento de proyectos, magia verde',
    'firstQuarter': 'Rituales de coraje, acción mágica, trabajo con fuego',
    'waxingGibbous': 'Ajuste de hechizos, refinamiento de prácticas',
    'fullMoon': 'Rituales poderosos, carga de herramientas, agua lunar',
    'waningGibbous': 'Gratitud, reconocimiento, ofrendas',
    'lastQuarter': 'Destierro, limpieza energética, corte de lazos',
    'waningCrescent': 'Meditación profunda, trabajo de sombra, adivinación',
  },
  practiceIntenseDay: 'El enraizamiento y la protección son esenciales hoy',
  practiceHarmoniousDay:
      'Excelente momento para hechizos complejos y trabajo en grupo',
  phaseKeywords: const {
    'newMoon': ['renovación', 'intención', 'inicio'],
    'waxingCrescent': ['crecimiento', 'expansión', 'manifestación'],
    'firstQuarter': ['acción', 'movimiento', 'decisión'],
    'waxingGibbous': ['refinamiento', 'paciencia', 'preparación'],
    'fullMoon': ['poder', 'culminación', 'plenitud'],
    'waningGibbous': ['gratitud', 'compartir', 'cosecha'],
    'lastQuarter': ['liberación', 'limpieza', 'transformación'],
    'waningCrescent': ['introspección', 'sabiduría', 'descanso'],
  },
  keywordIntensity: 'intensidad',
  keywordHarmony: 'armonía',
  transitAspect: (planet1, aspectSymbol, planet2, aspectQuality) =>
      '$planet1 $aspectSymbol $planet2: energía $aspectQuality',
  conjunctionTitle: (transitPlanet, natalPlanet) =>
      'Conjunción $transitPlanet-$natalPlanet',
  conjunctionDescription: (transitPlanet, natalPlanet) =>
      'Este aspecto poderoso une las energías de $transitPlanet y tu '
      '$natalPlanet natal. Es momento de integración profunda.',
  conjunctionPractices: const [
    'Meditación enfocada en estas energías',
    'Ritual de integración y alineación',
    'Trabajo con cristales correspondientes',
  ],
  harmoniousTitle: 'Energía Armoniosa Disponible',
  harmoniousDescription: (transitPlanet, aspectSymbol, natalPlanet) =>
      '$transitPlanet $aspectSymbol tu $natalPlanet natal crea un flujo '
      'positivo de energía.',
  harmoniousPractices: const [
    'Hechizos de manifestación y atracción',
    'Trabajo creativo e inspirado',
    'Conexión con guías espirituales',
  ],
  challengingTitle: 'Desafío para Crecer',
  challengingDescription: (aspectName, transitPlanet, natalPlanet) =>
      'El aspecto $aspectName entre $transitPlanet y tu $natalPlanet natal '
      'trae lecciones importantes.',
  challengingPractices: const [
    'Trabajo de sombra y autoconocimiento',
    'Destierro de patrones antiguos',
    'Protección y enraizamiento',
  ],
  moonSuggestionTitle: (signName) => 'Luna en $signName',
  moonSuggestionDescription: (signName, elementName) =>
      'La Luna transita por $signName, trayendo energías de $elementName a '
      'tus emociones e intuición.',
  moonSuggestionPractices: const [
    'Trabajo con agua y emociones',
    'Adivinación y lectura intuitiva',
    'Conexión con la energía lunar',
  ],
);
