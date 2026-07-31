import '../models/enums.dart';
import 'birth_chart_content.dart';

/// Contenido de la página de la carta natal — español.
const BirthChartContent birthChartContentEs = BirthChartContent(
  ui: {
    'viewMagicalProfileTooltip': 'Ver Perfil Mágico',
    'noChartFound': 'No se encontró ninguna carta natal',
    'sectionMainTrio': 'Trío Principal',
    'sectionPersonalPlanets': 'Planetas Personales',
    'sectionSocialPlanets': 'Planetas Sociales',
    'sectionTranspersonalPlanets': 'Planetas Transpersonales',
    'sectionAstroPoints': 'Puntos Astrológicos',
    'sectionHouses': 'Casas Astrológicas',
    'sectionAspects': 'Aspectos Principales',
    'ascendant': 'Ascendente',
    'ascendantMeaning': 'Cómo te presentas',
    'houseWord': 'Casa',
    'planetsInHousePrefix': 'Planetas:',
    'noAspects': 'No se encontraron aspectos significativos',
    'unlockFullInterpretations': 'Desbloquear interpretaciones completas',
    'viewMagicalProfileButton': 'Ver Perfil Mágico ✨',
    'tapToLearnMore': 'Toca para saber más',
    'beginnersGuide': 'Guía para Principiantes',
  },
  planetRowMeanings: {
    Planet.sun: 'Tu esencia',
    Planet.moon: 'Tus emociones',
    Planet.mercury: 'Comunicación',
    Planet.venus: 'Amor y belleza',
    Planet.mars: 'Acción y energía',
  },
  trioSections: [
    BirthChartSection(
      title: '☉ El Sol - Tu Esencia',
      body:
          'El Sol representa quién eres realmente en tu núcleo más profundo. Es tu identidad '
          'fundamental, tus objetivos de vida y cómo brillas en el mundo.\n\n'
          'En la brujería, el Sol representa tu fuerza vital, tu energía creativa y tu propósito mágico. '
          'El signo solar indica qué tipo de magia expresas de forma natural.',
    ),
    BirthChartSection(
      title: '☽ La Luna - Tus Emociones',
      body:
          'La Luna gobierna tus emociones, tu intuición y tu mundo interior. Revela cómo procesas '
          'los sentimientos, qué necesitas para sentirte segura(o) y tus reacciones instintivas.\n\n'
          'Para quienes practican magia, la Luna es extremadamente importante. Indica tus dones intuitivos, '
          'tu conexión con el inconsciente y cómo te relacionas con los ciclos lunares.',
    ),
    BirthChartSection(
      title: '⬆ El Ascendente - Tu Máscara',
      body:
          'El Ascendente (o signo ascendente) es cómo te presentas ante el mundo y las primeras '
          'impresiones que causas. Es tu "máscara social" y tu apariencia externa.\n\n'
          'En la práctica mágica, el Ascendente influye en cómo los demás perciben tu energía '
          'y puede indicar qué tipo de trabajo mágico atraes de forma natural.',
    ),
  ],
  trioTip: BirthChartSection(
    title: '💡 ¿Por qué es importante?',
    body:
        'Estos tres puntos forman la base de tu personalidad astrológica. '
        'Si estás empezando en la astrología, entender tu Sol, tu Luna y tu Ascendente '
        'es el primer paso para conocerte a través de las estrellas.',
  ),
  personalIntro:
      'Los planetas personales son los que se mueven rápidamente por el zodíaco e '
      'influyen en los aspectos cotidianos de tu personalidad.',
  personalSections: [
    BirthChartSection(
      title: '☿ Mercurio - Comunicación',
      body:
          'Mercurio gobierna cómo piensas, te comunicas y procesas la información. '
          'Influye en tu forma de aprender, hablar y escribir.\n\n'
          'En la magia: Indica cómo lanzas encantamientos, escribes hechizos y te comunicas con lo divino.',
    ),
    BirthChartSection(
      title: '♀ Venus - Amor y Belleza',
      body:
          'Venus rige el amor, las relaciones, la belleza y el placer. Muestra lo que valoras, '
          'cómo te relacionas románticamente y tu sentido estético.\n\n'
          'En la magia: Influye en los trabajos de amor (¡siempre éticos!), la prosperidad y la belleza del altar.',
    ),
    BirthChartSection(
      title: '♂ Marte - Acción y Energía',
      body:
          'Marte representa tu energía de acción, cómo luchas por lo que quieres, tu coraje '
          'y también tu ira. Es el planeta de la iniciativa y la determinación.\n\n'
          'En la magia: Indica tu energía protectora, tu capacidad de destierro y tu fuerza de voluntad mágica.',
    ),
  ],
  personalTip: BirthChartSection(
    title: '✨ Consejo para principiantes',
    body:
        'Estos planetas cambian de signo con frecuencia, por eso personas nacidas el mismo día '
        'pueden tener posiciones diferentes. Consulta tu Perfil Mágico para un análisis '
        'personalizado de cada planeta.',
  ),
  socialIntro:
      'Júpiter y Saturno son los planetas sociales: tienden un puente entre tu '
      'personalidad individual y el mundo colectivo — tu relación con la '
      'sociedad, el crecimiento, las reglas, las responsabilidades y la madurez.',
  socialSections: [
    BirthChartSection(
      title: '♃ Júpiter - Expansión',
      body:
          'Expansión, fe, conocimiento, oportunidades y visión del mundo. Muestra dónde '
          'creces, confías y encuentras facilidad y suerte en la vida.',
    ),
    BirthChartSection(
      title: '♄ Saturno - Estructura',
      body:
          'Límites, disciplina, deber, miedo, estructura y madurez. Indica dónde '
          'aprendes de los desafíos, asumes responsabilidades y construyes solidez.',
    ),
  ],
  transpersonalIntro:
      'Urano, Neptuno y Plutón son los planetas transpersonales (o generacionales). '
      'Se mueven lentamente y pasan años en cada signo, así que generaciones enteras '
      'los comparten — hablan de cambios colectivos, espirituales y profundos.',
  transpersonalSections: [
    BirthChartSection(
      title: '♅ Urano - Ruptura',
      body:
          'Ruptura, libertad, innovación y revolución. Donde rompes patrones, '
          'buscas autenticidad y abres caminos nuevos.',
    ),
    BirthChartSection(
      title: '♆ Neptuno - Disolución',
      body:
          'Sueños, espiritualidad, idealización, disolución e ilusión. Tu conexión '
          'con lo trascendente, la imaginación y la compasión.',
    ),
    BirthChartSection(
      title: '♇ Plutón - Transformación',
      body:
          'Poder, crisis, muerte simbólica, transformación y regeneración. Donde te '
          'reinventas profundamente y renaces.',
    ),
  ],
  pointsIntro:
      'Además de los planetas, la carta tiene puntos y ejes calculados — cruces, '
      'ángulos y apogeos que no son cuerpos celestes, pero revelan capas '
      'profundas del destino, de la sombra y del alma.',
  pointsSections: [
    BirthChartSection(
      title: 'MC · Medio Cielo - Vocación',
      body:
          'El punto más alto de la carta (cúspide de la Casa 10). Muestra tu vocación, la '
          'imagen pública, la carrera y el legado que construyes en el mundo.',
    ),
    BirthChartSection(
      title: 'IC · Fondo del Cielo - Raíces',
      body:
          'El punto más bajo (cúspide de la Casa 4), opuesto al MC. Habla de tus '
          'raíces, del hogar, de la familia y de la base emocional más íntima.',
    ),
    BirthChartSection(
      title: 'Dsc · Descendente - El Otro',
      body:
          'La cúspide de la Casa 7, opuesta al Ascendente. Describe las relaciones, '
          'las asociaciones y las cualidades que buscas (o proyectas) en el otro.',
    ),
    BirthChartSection(
      title: 'Vx · Vértex - Destino',
      body:
          'Un punto sensible ligado a encuentros fatídicos y giros del destino — '
          'situaciones y personas que llegan como si estuvieran "escritas".',
    ),
    BirthChartSection(
      title: '⚸ Lilith - Luna Negra',
      body:
          'El apogeo de la órbita lunar. Representa tu poder instintivo, la sombra, el '
          'deseo indómito y aquello que se niega a ser domesticado. En la brujería, '
          'es el portal de la bruja salvaje y de la soberanía femenina.',
    ),
    BirthChartSection(
      title: '⊗ Parte de la Fortuna - Suerte',
      body:
          'Punto árabe calculado a partir del Sol, la Luna y el Ascendente. Indica '
          'dónde viven tu suerte natural, la prosperidad y el bienestar — el lugar '
          'de fluidez y alegría en la carta.',
    ),
    BirthChartSection(
      title: '☊ Nodo Norte - Crecimiento',
      body:
          'Señala las experiencias que exigen crecimiento y desarrollo — la '
          'dirección hacia donde camina tu alma en esta vida.',
    ),
    BirthChartSection(
      title: '☋ Nodo Sur - Bagaje',
      body:
          'Hábitos, talentos y patrones familiares o automáticos — el repertorio que '
          'ya traes y en el que tiendes a acomodarte.',
    ),
  ],
  housesIntro:
      'Las 12 casas astrológicas representan diferentes áreas de tu vida. Cada casa '
      'está regida por el signo que está en su cúspide (inicio).',
  houseMeanings: {
    1: 'Identidad, apariencia física, cómo inicias las cosas',
    2: 'Recursos, dinero, valores personales, autoestima',
    3: 'Comunicación, hermanos, vecinos, pensamiento',
    4: 'Hogar, familia, raíces, vida privada',
    5: 'Creatividad, romance, hijos, diversión',
    6: 'Salud, rutina, trabajo diario, servicio',
    7: 'Asociaciones, matrimonio, contratos, el otro',
    8: 'Transformación, sexualidad, muerte/renacimiento, magia',
    9: 'Filosofía, viajes, estudios superiores, expansión',
    10: 'Carrera, reputación, estatus, misión de vida',
    11: 'Amistades, grupos, sueños, causas sociales',
    12: 'Inconsciente, espiritualidad, karma, retiros',
  },
  housesTip: BirthChartSection(
    title: '🔮 Casas importantes para la brujería',
    body:
        'La Casa 8 (magia, transformación, misterios) y la Casa 12 (espiritualidad, intuición, '
        'conexión con lo divino) son especialmente importantes para quienes practican magia. '
        'Consulta tu Perfil Mágico para un análisis detallado de estas casas.',
  ),
  aspectsIntro:
      'Los aspectos son las relaciones angulares entre los planetas. Muestran cómo las energías '
      'planetarias interactúan entre sí en tu carta.',
  aspectTypeMeanings: {
    AspectType.conjunction:
        'Los planetas están juntos. Energía intensa y fusionada.',
    AspectType.sextile:
        'Aspecto armonioso. Oportunidades y talentos naturales.',
    AspectType.square: 'Aspecto desafiante. Tensión que genera crecimiento.',
    AspectType.trine: 'Aspecto muy armonioso. Flujo fácil de energía.',
    AspectType.opposition:
        'Aspecto desafiante. Polaridad y necesidad de equilibrio.',
  },
  aspectsTip: BirthChartSection(
    title: '💫 Importante saber',
    body:
        '¡Los aspectos "desafiantes" no son malos! Indican áreas de crecimiento y '
        'potencial. Muchas veces son donde desarrollamos nuestras mayores fortalezas.\n\n'
        'En la magia, entender tus aspectos te ayuda a saber qué energías trabajan '
        'bien juntas y cuáles necesitan más atención en tus rituales.',
  ),
);
