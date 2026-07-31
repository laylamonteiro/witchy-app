import '../models/elements_content_model.dart';

/// Contenido de la página "Los Cuatro Elementos" — español.
///
/// Los emojis y el orden/recuento de las listas (Tierra, Agua, Fuego, Aire)
/// son invariantes entre idiomas. Mantén la misma estructura en los tres
/// archivos (`elements_content_pt/en/es.dart`) — la paridad se verifica en
/// `test/encyclopedia_content_parity_test.dart`.
const ElementsContent elementsContentEs = ElementsContent(
  pageTitle: 'Los Cuatro Elementos',
  introTitle: 'Sobre los 4 Elementos',
  introBody:
      'En la Wicca y en la brujería tradicional, los cuatro elementos - Tierra, Agua, Fuego y Aire - '
      'son fuerzas fundamentales de la naturaleza y de la existencia. No son solo sustancias físicas, '
      'sino energías primordiales que componen toda la creación.',
  introHint:
      'Explora cada elemento abajo para comprender sus cualidades, correspondencias y cómo trabajar con ellos.',
  essenceLabel: 'Esencia',
  qualitiesLabel: 'Cualidades',
  directionLabel: 'Dirección Cardinal',
  seasonLabel: 'Estación',
  lifePhaseLabel: 'Fase de la Vida',
  timeOfDayLabel: 'Hora del Día',
  colorsLabel: 'Colores',
  toolsLabel: 'Herramientas Mágicas',
  correspondencesLabel: 'Correspondencias',
  elements: [
    ElementInfo(
      name: 'Tierra',
      emoji: '🌍',
      essence:
          'La Tierra representa estabilidad, solidez, crecimiento y manifestación física. '
          'Es el elemento de la materia, del cuerpo, de la abundancia material y de la conexión con el mundo natural. '
          'La Tierra es donde las ideas se vuelven realidad.',
      qualities:
          'Estable, fértil, nutritiva, confiable, práctica, paciente, enraizada',
      direction: 'Norte',
      season: 'Invierno (momento de recogimiento y gestación)',
      lifePhase: 'Vejez y sabiduría',
      timeOfDay: 'Medianoche',
      colors: 'Verde, marrón, negro, amarillo (tonos terrosos)',
      tools: 'Pentáculo, cristales, sal, piedras, monedas',
      correspondences:
          '• Cristales: Cuarzo ahumado, turmalina negra, jaspe, ágata, hematita\n'
          '• Hierbas: Romero, cedro, pachulí, vetiver, raíces\n'
          '• Animales: Oso, ciervo, toro, conejo, serpiente\n'
          '• Zodíaco: Tauro, Virgo, Capricornio',
      whenToWorkTitle: 'Cuándo Trabajar con la Tierra',
      whenToWork: '• Manifestación de objetivos materiales\n'
          '• Prosperidad y abundancia\n'
          '• Enraizamiento y centramiento\n'
          '• Sanación física\n'
          '• Conexión con la naturaleza\n'
          '• Estabilidad y seguridad\n'
          '• Crecimiento y fertilidad',
    ),
    ElementInfo(
      name: 'Agua',
      emoji: '🌊',
      essence:
          'El Agua representa emociones, intuición, sanación y purificación. '
          'Es el elemento de los sentimientos profundos, del subconsciente, de los sueños y de la psique. '
          'El Agua fluye, se adapta y refleja la verdad interior.',
      qualities:
          'Fluida, adaptable, emocional, intuitiva, sanadora, purificadora, reflexiva',
      direction: 'Oeste',
      season: 'Otoño (momento de cosecha y reflexión)',
      lifePhase: 'Madurez',
      timeOfDay: 'Crepúsculo',
      colors: 'Azul, turquesa, plateado, índigo, morado',
      tools: 'Cáliz, caldero, espejo, copa, conchas',
      correspondences:
          '• Cristales: Amatista, piedra de luna, aguamarina, perla, sodalita\n'
          '• Hierbas: Manzanilla, gardenia, jazmín, loto, salvia\n'
          '• Animales: Pez, delfín, cisne, rana, nutria\n'
          '• Zodíaco: Cáncer, Escorpio, Piscis',
      whenToWorkTitle: 'Cuándo Trabajar con el Agua',
      whenToWork: '• Sanación emocional y espiritual\n'
          '• Desarrollo de la intuición\n'
          '• Trabajo con sueños\n'
          '• Purificación energética\n'
          '• Amor y relaciones\n'
          '• Meditación y contemplación\n'
          '• Conexión con el subconsciente',
    ),
    ElementInfo(
      name: 'Fuego',
      emoji: '🔥',
      essence:
          'El Fuego representa transformación, pasión, voluntad y poder personal. '
          'Es el elemento de la energía vital, del coraje, de la creatividad y de la acción. '
          'El Fuego consume, transforma e ilumina.',
      qualities:
          'Dinámico, transformador, purificador, apasionado, valiente, energético, creativo',
      direction: 'Sur',
      season: 'Verano (momento de máxima energía)',
      lifePhase: 'Juventud y vigor',
      timeOfDay: 'Mediodía',
      colors: 'Rojo, naranja, dorado, amarillo brillante',
      tools: 'Athame (daga ritual), varita, vela, caldero en llamas',
      correspondences:
          '• Cristales: Cornalina, citrino, rubí, granate, obsidiana\n'
          '• Hierbas: Canela, jengibre, pimienta, albahaca, clavo\n'
          '• Animales: Dragón, león, fénix, serpiente de fuego, salamandra\n'
          '• Zodíaco: Aries, Leo, Sagitario',
      whenToWorkTitle: 'Cuándo Trabajar con el Fuego',
      whenToWork: '• Transformación personal\n'
          '• Coraje y fuerza de voluntad\n'
          '• Pasión y creatividad\n'
          '• Protección activa\n'
          '• Purificación energética\n'
          '• Destierro de energías negativas\n'
          '• Manifestación rápida de deseos',
    ),
    ElementInfo(
      name: 'Aire',
      emoji: '💨',
      essence:
          'El Aire representa intelecto, comunicación, pensamiento e inspiración. '
          'Es el elemento de la mente, de las ideas, de la sabiduría y del conocimiento. '
          'El Aire lleva mensajes, dispersa y renueva.',
      qualities:
          'Ligero, móvil, comunicativo, intelectual, inspirador, libre, renovador',
      direction: 'Este',
      season: 'Primavera (momento de nuevos comienzos)',
      lifePhase: 'Infancia y aprendizaje',
      timeOfDay: 'Amanecer',
      colors: 'Amarillo claro, blanco, azul claro, lavanda',
      tools:
          'Varita (en algunas tradiciones), athame (en otras), incienso, plumas, campanas',
      correspondences:
          '• Cristales: Citrino, topacio, fluorita, ágata de encaje azul\n'
          '• Hierbas: Lavanda, menta, eucalipto, salvia blanca, diente de león\n'
          '• Animales: Águila, mariposa, pájaros, libélula, hada\n'
          '• Zodíaco: Géminis, Libra, Acuario',
      whenToWorkTitle: 'Cuándo Trabajar con el Aire',
      whenToWork: '• Estudio y aprendizaje\n'
          '• Comunicación y elocuencia\n'
          '• Viaje y movimiento\n'
          '• Inspiración creativa\n'
          '• Claridad mental\n'
          '• Nuevos comienzos\n'
          '• Trabajo con divinidades celestes',
    ),
  ],
  balanceTitle: 'El Equilibrio Elemental',
  balanceIntro:
      'En la práctica de la brujería, buscar el equilibrio de los cuatro elementos es esencial. '
      'Cada elemento representa aspectos diferentes de nuestra vida y personalidad:',
  balanceItems: [
    ElementBalanceItem(
        '🌍', 'Tierra', 'Nuestro cuerpo físico y recursos materiales'),
    ElementBalanceItem('🌊', 'Agua', 'Nuestras emociones y relaciones'),
    ElementBalanceItem('🔥', 'Fuego', 'Nuestra energía y poder personal'),
    ElementBalanceItem('💨', 'Aire', 'Nuestra mente y comunicación'),
  ],
  imbalanceTitle: 'Señales de Desequilibrio:',
  imbalanceBody:
      '• Tierra en exceso: Terquedad, materialismo, resistencia a los cambios\n'
      '• Agua en exceso: Emotividad excesiva, inestabilidad emocional\n'
      '• Fuego en exceso: Impulsividad, ira, agotamiento\n'
      '• Aire en exceso: Distracción, falta de practicidad, desconexión',
  practicesTitle: 'Cómo Trabajar con los Elementos',
  practices: [
    ElementPractice(
      'Meditación Elemental',
      'Siéntate con un objeto que represente cada elemento y medita sobre sus cualidades. '
          'Siente la energía del elemento fluyendo a través de ti.',
    ),
    ElementPractice(
      'Círculo Mágico',
      'Al trazar un círculo, invoca cada elemento en su dirección cardinal. '
          'Esto crea un espacio sagrado equilibrado y protegido.',
    ),
    ElementPractice(
      'Altar Elemental',
      'Mantén representaciones de los cuatro elementos en tu altar para conservar el equilibrio energético.',
    ),
    ElementPractice(
      'Hechizos Específicos',
      'Trabaja con el elemento correspondiente a tu intención: '
          'Tierra para prosperidad, Agua para amor, Fuego para coraje, Aire para sabiduría.',
    ),
    ElementPractice(
      'Conexión Diaria',
      'Pasa tiempo en la naturaleza conectándote con los elementos: '
          'camina descalza (Tierra), toma un baño ritual (Agua), enciende velas (Fuego), practica la respiración (Aire).',
    ),
  ],
  honoringTitle: 'Honrando los Elementos',
  honoringBody:
      'Los cuatro elementos no son solo herramientas mágicas - son fuerzas vivas que sostienen toda la existencia. '
      'Al trabajar con los elementos, nos estamos conectando con los propios cimientos del universo. '
      '\n\nRespeta cada elemento, aprende sus lecciones y permite que sus energías guíen y fortalezcan tu práctica. '
      'Con el tiempo, desarrollarás una relación profunda con cada elemento, reconociendo su presencia '
      'tanto en el mundo exterior como dentro de ti misma.',
);
