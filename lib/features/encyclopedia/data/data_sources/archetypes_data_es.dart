import '../models/arcane_entry_model.dart';

/// Arquetipos del camino mágico — contenido en español.
///
/// Los emojis y las correspondencias no textuales son invariantes entre
/// idiomas. Mantén el mismo orden que `archetypes_data_pt.dart` — la paridad
/// se verifica en `test/content_parity_test.dart`.
const List<ArcaneEntry> archetypesEs = [
  ArcaneEntry(
    name: 'La Bruja',
    emoji: '🧙‍♀️',
    summary: 'Soberanía sobre el propio poder y el saber prohibido',
    origin: 'Universal — del folclore europeo a las curanderas de las Américas',
    history:
        'De la sanadora de la aldea a la perseguida de las hogueras, la Bruja atravesó siglos como símbolo del poder femenino fuera del control institucional. En el siglo XX fue resignificada por los movimientos de brujería moderna como emblema de autonomía espiritual.',
    characteristics: [
      'Autosuficiencia e intimidad con la naturaleza',
      'Conocimiento de las hierbas, los ciclos y los misterios',
      'Valentía para vivir fuera de las expectativas ajenas',
      'Relación directa con lo sagrado, sin intermediarios',
    ],
    symbolism: [
      'El caldero: transformación interior',
      'La escoba: travesía entre mundos',
      'La luna: los ciclos y lo oculto',
    ],
    correspondences: ['Luna', 'Artemisa', 'Obsidiana', 'Negro y violeta'],
    studyPractices: [
      'Journaling: "¿dónde renuncio a mi poder para ser aceptada?"',
      'Estudiar la historia de las persecuciones y de las curanderas locales',
    ],
    magicalUses: [
      'Invocar la confianza propia en rituales de soberanía personal',
      'Meditación-espejo para integrar las partes rechazadas',
    ],
    cautions:
        'Los arquetipos son espejos simbólicos, no identidades fijas — úsalos como herramienta de reflexión.',
    related: ['La Sabia', 'La Curandera', 'Hécate (Diosas)'],
  ),
  ArcaneEntry(
    name: 'La Curandera',
    emoji: '🌿',
    summary: 'El don de cuidar, restaurar y devolver el equilibrio',
    origin: 'Universal — chamanas, curanderas, parteras y herbolarias',
    history:
        'Presente en todas las culturas, la Curandera guarda el conocimiento práctico de la sanación: plantas, toques, palabras y rezos. Curanderas y parteras mantuvieron viva esa estirpe incluso bajo persecución, transmitiendo el oficio de madre a hija.',
    characteristics: [
      'Empatía profunda y una presencia que calma',
      'Conocimiento de remedios naturales y rituales de limpieza',
      'Escucha del cuerpo y de las señales sutiles',
    ],
    symbolism: [
      'Las manos: canal de energía y cuidado',
      'La serpiente: renovación y medicina',
      'El agua: limpieza y fluidez emocional',
    ],
    correspondences: ['Romero', 'Cuarzo verde', 'Verde y blanco', 'Mercurio'],
    studyPractices: [
      'Estudiar una hierba por semana (ver Enciclopedia de Hierbas)',
      'Practicar el autocuidado ritualizado antes de cuidar de los demás',
    ],
    magicalUses: [
      'Baños y tés rituales de limpieza',
      'Rituales de sanación a distancia y bendiciones',
    ],
    cautions:
        'Cuidar de los demás no sustituye cuidar de ti; la Curandera en sombra se agota en nombre del prójimo. Las prácticas energéticas no sustituyen la medicina.',
    related: ['Hierbas (Enciclopedia)', 'La Madre', 'Brigid (Diosas)'],
  ),
  ArcaneEntry(
    name: 'La Vidente',
    emoji: '👁️',
    summary: 'Ver más allá del velo: intuición, oráculos y profecía',
    origin: 'El Oráculo de Delfos, las sibilas romanas, las videntes del folclore',
    history:
        'De las pitonisas griegas a las cartománticas de feria, la Vidente encarna la capacidad humana de leer señales y presentir. Siempre reverenciada y temida, su don desafía la lógica lineal del tiempo.',
    characteristics: [
      'Intuición aguda y sueños significativos',
      'Comodidad con símbolos, presagios y ambigüedad',
      'Sensibilidad a las energías de personas y lugares',
    ],
    symbolism: [
      'El tercer ojo: percepción sutil',
      'La niebla: el velo entre los mundos',
      'El espejo y la bola de cristal: superficies de visión',
    ],
    correspondences: ['Amatista', 'Artemisa', 'Índigo', 'Luna y Neptuno'],
    studyPractices: [
      'Registrar sueños y sincronicidades en el Diario',
      'Practicar con un oráculo a la vez hasta crear un vínculo',
    ],
    magicalUses: [
      'Lecturas de tarot, runas y péndulo',
      'Meditaciones para abrir la intuición',
    ],
    cautions:
        'La intuición se educa con discernimiento: no todo presentimiento es profecía. Evita decisiones importantes basadas solo en señales.',
    related: ['Cartas del Oráculo', 'Runas', 'Péndulo', 'Sueños & Visiones'],
  ),
  ArcaneEntry(
    name: 'La Guardiana',
    emoji: '🛡️',
    summary: 'Protección de los umbrales, las personas y los espacios sagrados',
    origin: 'Guardianas de templos, hogares y encrucijadas en todas las culturas',
    history:
        'De los leones de piedra en los portales a los círculos de sal de la brujería, la Guardiana vigila fronteras: lo que entra, lo que sale, lo que no pasa. Es la fuerza que dice "hasta aquí" con amor y firmeza.',
    characteristics: [
      'Sentido agudo de los límites y la justicia',
      'Lealtad y protección hacia los suyos',
      'Valentía serena frente a las amenazas',
    ],
    symbolism: [
      'El escudo y el círculo: frontera sagrada',
      'La llave: autoridad sobre los pasajes',
      'La sal: pureza que detiene lo indeseado',
    ],
    correspondences: ['Sal gruesa', 'Ruda', 'Turmalina negra', 'Marte'],
    studyPractices: [
      'Reflexionar: "¿qué límites míos necesitan refuerzo?"',
      'Estudiar amuletos protectores de diferentes culturas',
    ],
    magicalUses: [
      'Rituales de protección del hogar y escudos energéticos',
      'Consagración de amuletos y talismanes',
    ],
    cautions:
        'La protección en exceso se vuelve muralla: revisa si tus límites guardan o aíslan.',
    related: ['Protección & Limpieza (Grimorio)', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'La Sabia',
    emoji: '🦉',
    summary: 'La anciana interior: experiencia transformada en sabiduría',
    origin: 'La crone de los cuentos, abuelas y maestras de todas las tradiciones',
    history:
        'Tercer rostro de la Diosa Triple, la Anciana guarda la sabiduría de los ciclos completos. En culturas ancestrales, las mayores eran consejeras de la comunidad; en los cuentos, es la vieja del bosque que pone a prueba y regala.',
    characteristics: [
      'Desapego de las apariencias y del juicio ajeno',
      'Visión a largo plazo y humor afilado',
      'Capacidad de soltar lo que ya cumplió su papel',
    ],
    symbolism: [
      'La lechuza: ver en la oscuridad',
      'La luna menguante: recogimiento fértil',
      'El hilo y las tijeras: saber cuándo cortar',
    ],
    correspondences: ['Luna menguante', 'Salvia', 'Ónix', 'Gris y negro'],
    studyPractices: [
      'Escribir cartas de tu "yo anciana" a tu "yo actual"',
      'Honrar a las mujeres mayores de tu linaje',
    ],
    magicalUses: [
      'Rituales de cierre de ciclos en la menguante',
      'Consejo interior en meditaciones profundas',
    ],
    cautions:
        'La sombra de la Sabia es el cinismo: la sabiduría sin ternura endurece.',
    related: ['La Bruja', 'Hécate (Diosas)', 'Fases de la Luna'],
  ),
  ArcaneEntry(
    name: 'La Doncella',
    emoji: '🌸',
    summary: 'Comienzos, frescura y la valentía del primer paso',
    origin: 'Primer rostro de la Diosa Triple; Perséfone antes del rapto',
    history:
        'La Doncella es la primavera del ciclo: curiosidad, potencial e independencia juvenil. En los mitos, suele ser la que parte, explora e inaugura — la energía de todo lo que aún va a florecer.',
    characteristics: [
      'Entusiasmo, apertura y fe en lo posible',
      'Independencia y deseo de explorar',
      'Pureza de intención — comenzar sin cicatrices',
    ],
    symbolism: [
      'La luna creciente: promesa en formación',
      'Las flores y semillas: potencial',
      'El amanecer: recomienzo diario',
    ],
    correspondences: ['Luna creciente', 'Jazmín', 'Cuarzo rosa', 'Blanco y rosa'],
    studyPractices: [
      'Listar sueños "guardados en el cajón" que merecen un primer intento',
      'Practicar la mente de principiante: aprender algo desde cero sin exigencias',
    ],
    magicalUses: [
      'Rituales de nuevos comienzos en la luna creciente',
      'Hechizos de inspiración y frescura creativa',
    ],
    cautions:
        'La sombra de la Doncella es la eterna promesa que nunca madura: comenzar también pide continuar.',
    related: ['La Madre', 'La Sabia', 'Luna Creciente'],
  ),
  ArcaneEntry(
    name: 'La Madre',
    emoji: '🤱',
    summary: 'Nutrición, creación y la fuerza que hace crecer',
    origin: 'Diosas madre neolíticas, Deméter, Yemanjá, la Diosa Triple',
    history:
        'Rostro central de la Diosa Triple, la Madre es la plenitud de la luna llena: gestar, parir y sostener — hijos, proyectos, comunidades. Las diosas madre están entre las figuras más antiguas de lo sagrado humano.',
    characteristics: [
      'Generosidad, abundancia y presencia',
      'Fertilidad en sentido amplio: hacer crecer',
      'Furia protectora cuando los suyos son amenazados',
    ],
    symbolism: [
      'La luna llena: plenitud',
      'El vientre y el cáliz: gestación',
      'La cosecha: fruto del cuidado constante',
    ],
    correspondences: ['Luna llena', 'Manzanilla', 'Piedra luna', 'Dorado y verde'],
    studyPractices: [
      'Preguntarse: "¿qué estoy nutriendo — y qué me nutre?"',
      'Prácticas de gratitud por el linaje materno (ver Diario)',
    ],
    magicalUses: [
      'Rituales de abundancia y concreción en la luna llena',
      'Bendiciones de proyectos en crecimiento',
    ],
    cautions:
        'La sombra de la Madre es el control disfrazado de cuidado y el olvido de sí misma.',
    related: ['La Doncella', 'La Curandera', 'Luna Llena'],
  ),
  ArcaneEntry(
    name: 'La Cazadora',
    emoji: '🏹',
    summary: 'Enfoque, independencia y la flecha que no se desvía',
    origin: 'Artemisa/Diana y las señoras de la caza del folclore europeo',
    history:
        'Señora de los bosques y protectora de los animales salvajes, la Cazadora corre libre fuera de los muros de la ciudad. Diana se convirtió, en la tradición de la brujería italiana y en la Wicca, en uno de los rostros centrales de la Diosa.',
    characteristics: [
      'Enfoque absoluto en el objetivo elegido',
      'Autosuficiencia y amor por la libertad',
      'Instinto afinado y prontitud',
    ],
    symbolism: [
      'El arco y la flecha: intención dirigida',
      'El bosque: el territorio salvaje interior',
      'La manada: lealtad sin domesticación',
    ],
    correspondences: ['Luna creciente', 'Ciprés', 'Plata', 'Sagitario'],
    studyPractices: [
      'Definir un único objetivo por ciclo lunar y perseguirlo',
      'Caminatas contemplativas en la naturaleza',
    ],
    magicalUses: [
      'Hechizos de enfoque y conquista de metas',
      'Rituales de reconexión con la naturaleza salvaje',
    ],
    cautions:
        'La sombra de la Cazadora es la soledad orgullosa: pedir ayuda también es puntería.',
    related: ['La Guardiana', 'Diana (Diosas)', 'Prosperidad & Caminos'],
  ),
  ArcaneEntry(
    name: 'La Tejedora',
    emoji: '🕸️',
    summary: 'Destino, paciencia y el arte de entrelazar los hilos de la vida',
    origin: 'Las Moiras griegas, las Nornas nórdicas, la Abuela Araña de los pueblos originarios',
    history:
        'En muchos mitos, el destino se teje: las Moiras hilan, miden y cortan; las Nornas riegan el árbol del mundo. La Tejedora recuerda que cada elección es un hilo — y que los patrones pueden rehacerse.',
    characteristics: [
      'Visión de patrones y conexiones invisibles',
      'La paciencia de quien construye punto a punto',
      'Responsabilidad por las propias elecciones',
    ],
    symbolism: [
      'La telaraña: interdependencia de todas las cosas',
      'El huso: el tiempo que gira',
      'El nudo: intención fijada',
    ],
    correspondences: ['Hilos y nudos', 'Lavanda', 'Labradorita', 'Saturno'],
    studyPractices: [
      'Mapear patrones que se repiten en tu historia',
      'Artesanía meditativa: tejido, macramé, bordado',
    ],
    magicalUses: [
      'Magia de nudos (atar intenciones en cordones)',
      'Rituales de reescritura de patrones en la menguante',
    ],
    cautions:
        'No todo hilo es tuyo para tejer: respeta el libre albedrío ajeno.',
    related: ['Sigilos', 'Sueños & Visiones', 'La Sabia'],
  ),
  ArcaneEntry(
    name: 'La Alquimista',
    emoji: '⚗️',
    summary: 'Transmutar: transformar el plomo interior en oro',
    origin: 'Alquimia grecoegipcia, árabe y europea medieval',
    history:
        'Más que precursores de la química, los alquimistas buscaban la transformación de la propia alma — el solve et coagula: disolver lo que se endureció y recomponerlo en forma más noble. Jung releyó la alquimia como mapa de la individuación.',
    characteristics: [
      'Fascinación por los procesos de transformación',
      'Disciplina experimental: probar, observar, refinar',
      'Fe en que nada se pierde, todo se transmuta',
    ],
    symbolism: [
      'El uróboros: ciclos que se renuevan',
      'El horno (athanor): presión que refina',
      'El oro: la esencia realizada',
    ],
    correspondences: ['Azufre y sal simbólicos', 'Canela', 'Pirita', 'Sol'],
    studyPractices: [
      'Estudiar las etapas alquímicas (nigredo, albedo, rubedo) como fases personales',
      'Transformar un hábito a la vez, documentando el proceso',
    ],
    magicalUses: [
      'Rituales de transmutación del dolor en aprendizaje',
      'Trabajo con el caldero como athanor simbólico',
    ],
    cautions:
        'La transformación real es lenta: desconfía del oro instantáneo.',
    related: ['La Bruja', 'Metales (Enciclopedia)', 'Energía & Sanación'],
  ),
  ArcaneEntry(
    name: 'La Reina Sombría',
    emoji: '🌑',
    summary: 'Soberanía sobre la propia sombra y los territorios profundos',
    origin: 'Perséfone en el inframundo, la Hel nórdica, la madrastra de los cuentos',
    history:
        'Toda psique tiene sótanos. La Reina Sombría gobierna lo que fue exiliado: rabia, envidia, deseo, duelo. En los mitos, descender al inframundo — como Inanna o Perséfone — es el camino para reinar entera.',
    characteristics: [
      'Honestidad radical consigo misma',
      'Capacidad de sostener emociones difíciles sin huir',
      'Poder personal que no pide disculpas',
    ],
    symbolism: [
      'El trono en la oscuridad: dignidad en las profundidades',
      'La granada: el pacto con el propio inframundo',
      'La luna nueva: lo invisible fértil',
    ],
    correspondences: ['Luna nueva', 'Mirra', 'Obsidiana', 'Vino oscuro y negro'],
    studyPractices: [
      'Trabajo de sombra: dialogar por escrito con lo que rechazas en ti',
      'Leer los mitos de descenso (Inanna, Perséfone) como guiones interiores',
    ],
    magicalUses: [
      'Rituales de integración de la sombra en la luna nueva',
      'Destierros conscientes de lo que ya fue comprendido',
    ],
    cautions:
        'El trabajo de sombra remueve material sensible: ve a tu ritmo y busca apoyo profesional cuando el dolor sea grande.',
    related: ['La Sabia', 'Hécate (Diosas)', 'Luna Nueva'],
  ),
];
