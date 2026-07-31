import 'numerology_meanings_models.dart';

/// Significados numerológicos — contenido en español.
/// Paridad con _pt/_en verificada en test/numerology_meanings_parity_test.dart.
const Map<int, NumberMeaning> numberMeaningsEs = {
  1: NumberMeaning(
    number: 1,
    title: 'El Pionero',
    keywords: ['iniciativa', 'liderazgo', 'independencia', 'valentía'],
    description:
        'El Uno abre caminos. Es la chispa inicial, la voluntad que da el primer paso e inaugura ciclos. Quien vibra en el Uno aprende a confiar en sí, liderar con autenticidad y sembrar lo nuevo.',
    shadow:
        'En la sombra, puede volverse autoritarismo, impaciencia o soledad por no pedir ayuda.',
  ),
  2: NumberMeaning(
    number: 2,
    title: 'El Diplomático',
    keywords: ['cooperación', 'sensibilidad', 'alianza', 'paciencia'],
    description:
        'El Dos une. Es el número de los lazos, la escucha y la mediación. Quien vibra en el Dos florece en las alianzas, percibe sutilezas que otros no ven y sana ambientes con presencia suave.',
    shadow:
        'En la sombra, aparecen la dependencia, el miedo al conflicto y la autoanulación.',
  ),
  3: NumberMeaning(
    number: 3,
    title: 'El Comunicador',
    keywords: ['creatividad', 'expresión', 'alegría', 'sociabilidad'],
    description:
        'El Tres florece en la expresión: palabra, arte, risa. Es energía de creación y encanto, que inspira y conecta a las personas a través de la belleza y el entusiasmo.',
    shadow:
        'En la sombra, se dispersa en superficialidad, chismes o drama.',
  ),
  4: NumberMeaning(
    number: 4,
    title: 'El Constructor',
    keywords: ['estructura', 'disciplina', 'trabajo', 'estabilidad'],
    description:
        'El Cuatro construye cimientos. Es la energía del método, la paciencia y el trabajo honesto que convierte ideas en algo sólido y duradero. Quien vibra en el Cuatro es la roca en la que otros se apoyan.',
    shadow:
        'En la sombra, rigidez, exceso de rutina y resistencia al cambio.',
  ),
  5: NumberMeaning(
    number: 5,
    title: 'El Espíritu Libre',
    keywords: ['libertad', 'cambio', 'aventura', 'versatilidad'],
    description:
        'El Cinco se mueve. Es el número de la experiencia, los sentidos y la transformación. Quien vibra en el Cinco aprende viviendo, se adapta rápido y trae aire fresco adonde llega.',
    shadow:
        'En la sombra, inquietud, excesos y dificultad para comprometerse.',
  ),
  6: NumberMeaning(
    number: 6,
    title: 'El Guardián',
    keywords: ['cuidado', 'responsabilidad', 'armonía', 'familia'],
    description:
        'El Seis abraza. Es la energía del hogar, la belleza y el servicio a quienes amamos. Quien vibra en el Seis nutre con naturalidad, armoniza espacios y se responsabiliza del bienestar a su alrededor.',
    shadow:
        'En la sombra, sobreprotección, martirio e intromisión.',
  ),
  7: NumberMeaning(
    number: 7,
    title: 'El Místico',
    keywords: ['sabiduría', 'introspección', 'espiritualidad', 'análisis'],
    description:
        'El Siete profundiza. Es el número del estudio, el silencio y la búsqueda interior. Quien vibra en el Siete necesita tiempo a solas para comprender el mundo y hallar verdades bajo la superficie.',
    shadow:
        'En la sombra, aislamiento, escepticismo y frialdad emocional.',
  ),
  8: NumberMeaning(
    number: 8,
    title: 'El Realizador',
    keywords: ['poder', 'abundancia', 'ambición', 'justicia'],
    description:
        'El Ocho materializa. Es la energía del logro en el mundo concreto: recursos, reconocimiento, influencia. Quien vibra en el Ocho aprende a usar el poder con integridad y a generar prosperidad que circula.',
    shadow:
        'En la sombra, avaricia, control y un valor medido solo por resultados.',
  ),
  9: NumberMeaning(
    number: 9,
    title: 'El Humanitario',
    keywords: ['compasión', 'cierre', 'generosidad', 'universalidad'],
    description:
        'El Nueve completa y entrega. Es el número del amor universal, el arte y el cierre de ciclos. Quien vibra en el Nueve siente el dolor y la belleza del mundo y convierte la experiencia en sabiduría para compartir.',
    shadow:
        'En la sombra, drama, dificultad para soltar y decepción con la humanidad.',
  ),
  11: NumberMeaning(
    number: 11,
    title: 'El Maestro Intuitivo',
    keywords: ['intuición', 'inspiración', 'sensibilidad', 'visión'],
    description:
        'El Once es un número maestro: el Dos elevado a una octava superior. Es un canal entre mundos: intuición refinada, inspiración que llega como un rayo, sensibilidad que capta lo invisible.',
    shadow:
        'En la sombra, ansiedad, tensión nerviosa y la sensación de no pertenecer.',
  ),
  22: NumberMeaning(
    number: 22,
    title: 'El Constructor Maestro',
    keywords: ['visión práctica', 'grandes obras', 'legado', 'maestría'],
    description:
        'El Veintidós materializa lo imposible: une la visión del Once con la disciplina del Cuatro. Es energía de proyectos que atraviesan generaciones: templos, instituciones, legados.',
    shadow:
        'En la sombra, se aplasta bajo su propia expectativa o domina por los fines.',
  ),
  33: NumberMeaning(
    number: 33,
    title: 'El Maestro del Amor',
    keywords: ['sanación', 'servicio amoroso', 'enseñanza', 'compasión elevada'],
    description:
        'El Treinta y Tres es raro: el Seis elevado a la devoción universal. Vibra como sanación por el ejemplo: enseñar amando, servir sin esperar retorno.',
    shadow:
        'En la sombra, sacrificio extremo y negación de las propias necesidades.',
  ),
};

/// Etiquetas y explicaciones de cada número clave del perfil personal.
const profileNumberInfosEs = <String, ProfileNumberInfo>{
  'lifePath': ProfileNumberInfo(
    label: 'Camino de Vida',
    emoji: '🌟',
    explanation:
        'Calculado a partir de tu fecha de nacimiento, revela la gran lección y la dirección de tu camino.',
  ),
  'expression': ProfileNumberInfo(
    label: 'Expresión',
    emoji: '🗣️',
    explanation:
        'La suma de todas las letras del nombre completo: tus talentos y la forma en que te presentas al mundo.',
  ),
  'soulUrge': ProfileNumberInfo(
    label: 'Alma',
    emoji: '💜',
    explanation:
        'Solo las vocales del nombre: lo que tu corazón desea en silencio, tus motivaciones profundas.',
  ),
  'personality': ProfileNumberInfo(
    label: 'Personalidad',
    emoji: '🎭',
    explanation:
        'Solo las consonantes: la primera impresión que causas, el rostro que el mundo ve.',
  ),
  'personalYear': ProfileNumberInfo(
    label: 'Año Personal',
    emoji: '🗓️',
    explanation:
        'El tema de tu ciclo anual actual: la energía disponible para este año de tu vida.',
  ),
};

/// Mensajes de las secuencias repetidas clásicas (visión mística popular +
/// lectura numerológica). La lectura numérica reducida complementa cada una.
const Map<String, String> repeatedSequenceMessagesEs = {
  '000': 'Portal del infinito: un ciclo se cierra y todo es posible. Momento de elegir con conciencia qué sembrar.',
  '111': 'Alineación y manifestación: tus pensamientos están creando rápido. Enfócate en lo que deseas, no en lo que temes.',
  '222': 'Confianza y paciencia: las alianzas y el momento justo trabajan a tu favor. Mantén la fe en el proceso.',
  '333': 'Presencia de los maestros y de la creatividad: exprésate, crea, comunica. Estás siendo amparado.',
  '444': 'Protección y estructura: tus guardianes confirman que la base es sólida. Continúa el trabajo.',
  '555': 'Cambio a la vista: prepárate para transformaciones liberadoras. Suelta lo que ya cumplió su papel.',
  '666': 'Reequilibrio: exceso de preocupación material. Vuelve al corazón, al hogar y a lo que de verdad nutre.',
  '777': 'Suerte espiritual: vas por el camino correcto del aprendizaje. Profundiza tus estudios y tu intuición.',
  '888': 'Abundancia en flujo: la cosecha y la prosperidad se acercan. Recibe con gratitud y hazla circular.',
  '999': 'Cierre sagrado: un gran ciclo se completa. Ciérralo con amor para que llegue lo nuevo.',
  '1010': 'Nuevo nivel: un paso a la vez, subes en espiral. Confía en la dirección.',
  '1212': 'Crecimiento armónico: fe y acción en equilibrio construyen el próximo capítulo.',
  '1234': 'Progresión: la vida confirma que avanzas en el orden correcto. Sigue dando los pasos.',
};
