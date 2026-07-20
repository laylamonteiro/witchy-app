import '../models/crystal_model.dart';

/// Cristales de la enciclopedia — contenido en español.
///
/// Los nombres siguen la convención de cada idioma; enums, elementos e
/// imágenes son invariantes. Mantén el mismo orden que
/// `crystals_data_pt.dart` — la paridad se verifica en
/// `test/content_parity_test.dart`.
final List<CrystalModel> crystalsEs = [
  const CrystalModel(
    name: 'Ágata',
    description:
        'Piedra de equilibrio, armonía y protección suave. Estabiliza las energías y calma.',
    element: Element.earth,
    imageUrl: 'assets/images/crystals/agata.jpg',
    intentions: [
      'Equilibrio emocional',
      'Armonía',
      'Protección suave',
      'Estabilidad',
      'Concentración',
      'Aceptación',
    ],
    usageTips: [
      'Úsala para el equilibrio emocional',
      'Llévala contigo para la estabilidad',
      'Medita con ella para la paz interior',
      'Colócala en los ambientes para la armonía',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol o luna',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Amatista',
    description:
        'Piedra de la espiritualidad y la protección. Calma la mente y favorece la claridad mental.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/ametista.jpg',
    intentions: [
      'Protección espiritual',
      'Intuición',
      'Meditación',
      'Claridad mental',
      'Sueño tranquilo',
      'Transformación',
    ],
    usageTips: [
      'Colócala en el dormitorio para sueños protectores',
      'Medita sosteniéndola para abrir el tercer ojo',
      'Úsala durante prácticas espirituales',
      'Llévala contigo para protección psíquica',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo de hierbas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz de la luna',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Luna llena',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Otros cristales',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sol naciente (breve)',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Puede perder color con la exposición prolongada al sol',
    ],
  ),
  const CrystalModel(
    name: 'Citrino',
    description:
        'Piedra de la prosperidad y la abundancia. Atrae éxito, alegría y energía positiva.',
    element: Element.fire,
    imageUrl: 'assets/images/crystals/citrino.jpg',
    intentions: [
      'Prosperidad',
      'Abundancia',
      'Éxito',
      'Alegría',
      'Confianza',
      'Creatividad',
    ],
    usageTips: [
      'Colócalo en la cartera o en la caja registradora',
      'Úsalo en la oficina para el éxito profesional',
      'Medita con él para atraer abundancia',
      'Colócalo junto a las plantas para energía positiva',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente',
        isSafe: false,
        warning: 'Puede desteñirse - prefiere otros métodos',
      ),
      CrystalMethod(
        method: 'Humo de hierbas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz de la luna',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol (mañana)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Cuarzo transparente',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Muy sensible al sol - puede perder el color rápidamente',
      'Evita el calor excesivo',
    ],
  ),
  const CrystalModel(
    name: 'Cornalina',
    description:
        'Piedra de la creatividad, el coraje y la vitalidad. Estimula la motivación y la confianza.',
    element: Element.fire,
    imageUrl: 'assets/images/crystals/cornalina.jpg',
    intentions: [
      'Creatividad',
      'Coraje y confianza',
      'Vitalidad y energía',
      'Motivación',
      'Fertilidad',
      'Manifestación',
    ],
    usageTips: [
      'Úsala para proyectos creativos',
      'Llévala contigo para energía y motivación',
      'Medita en el chakra sacro',
      'Colócala en tu espacio de trabajo',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Fluorita',
    description:
        'Piedra del enfoque, el aprendizaje y la organización mental. Excelente para los estudios.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/fluorita.jpg',
    intentions: [
      'Enfoque y concentración',
      'Aprendizaje',
      'Organización mental',
      'Limpieza áurica',
      'Decisiones claras',
      'Memoria',
    ],
    usageTips: [
      'Úsala durante los estudios',
      'Colócala en tu escritorio',
      'Medita con ella para la claridad mental',
      'Llévala contigo para el enfoque',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua',
        isSafe: false,
        warning: 'Evita el agua - puede dañarla',
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sonido',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Luna',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Cuarzo',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Frágil - manipúlala con cuidado',
      'Evita el sol intenso',
    ],
  ),
  const CrystalModel(
    name: 'Howlita',
    description:
        'Piedra calmante de la paciencia y la consciencia. Excelente para el insomnio y la ansiedad.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/howlita.jpg',
    intentions: [
      'Calma y paciencia',
      'Sueño tranquilo',
      'Reducción de la ansiedad',
      'Consciencia',
      'Memoria',
      'Comunicación serena',
    ],
    usageTips: [
      'Colócala bajo la almohada para el insomnio',
      'Medita con ella para reducir la ansiedad',
      'Llévala contigo en situaciones estresantes',
      'Úsala para calmar la ira',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente (breve)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luna',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Luna',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Cuarzo',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Jaspe Rojo',
    description:
        'Piedra de enraizamiento, fuerza y estabilidad. Conecta con la energía de la Tierra.',
    element: Element.earth,
    imageUrl: 'assets/images/crystals/jaspe_vermelho.jpg',
    intentions: [
      'Enraizamiento',
      'Fuerza física',
      'Estabilidad',
      'Resistencia',
      'Coraje',
      'Vitalidad',
    ],
    usageTips: [
      'Úsalo para enraizarte',
      'Llévalo contigo para la fuerza física',
      'Medita en el chakra raíz',
      'Colócalo en el ambiente para la estabilidad',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Tierra (enterrar)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sol',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Labradorita',
    description:
        'Piedra mística de la transformación y la magia. Protege contra energías negativas y agudiza la intuición.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/labradorita.jpg',
    intentions: [
      'Protección psíquica',
      'Intuición y clarividencia',
      'Transformación',
      'Magia',
      'Fuerza interior',
      'Sincronicidad',
    ],
    usageTips: [
      'Úsala durante trabajos mágicos',
      'Medita con ella para desarrollar la intuición',
      'Llévala contigo para protección áurica',
      'Colócala en el altar',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente (rápido)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luna llena',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Luna llena',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Lapislázuli',
    description:
        'Piedra de la sabiduría, la verdad y la visión espiritual. Abre el tercer ojo.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/lapis_lazuli.jpg',
    intentions: [
      'Sabiduría',
      'Verdad',
      'Visión espiritual',
      'Comunicación superior',
      'Intuición',
      'Paz interior',
    ],
    usageTips: [
      'Medita con él para abrir el tercer ojo',
      'Úsalo para una comunicación verdadera',
      'Llévalo contigo para la sabiduría',
      'Colócalo en el altar',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua',
        isSafe: false,
        warning: 'Evita el agua - puede dañarlo',
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sonido',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Luna',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Cuarzo o amatista',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'No lo mojes - puede mancharse o dañarse',
      'Mantenlo lejos de productos químicos',
    ],
  ),
  const CrystalModel(
    name: 'Obsidiana Negra',
    description:
        'Poderosa piedra de protección y enraizamiento. Absorbe y transforma las energías negativas.',
    element: Element.earth,
    imageUrl: 'assets/images/crystals/obsidiana_negra.jpg',
    intentions: [
      'Protección fuerte',
      'Enraizamiento',
      'Transformación',
      'Verdad',
      'Limpieza profunda',
      'Liberación de traumas',
    ],
    usageTips: [
      'Úsala para una protección intensa',
      'Medita con ella para el trabajo de sombra',
      'Colócala en la entrada de la casa',
      'Llévala contigo para protección personal',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente con sal',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra (enterrar)',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luna nueva',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Muy poderosa - úsala con consciencia',
      'Puede traer emociones a la superficie',
    ],
  ),
  const CrystalModel(
    name: 'Ojo de Tigre',
    description:
        'Piedra del coraje, la protección y la prosperidad. Fortalece la confianza y trae buena suerte.',
    element: Element.fire,
    imageUrl: 'assets/images/crystals/olho_de_tigre.jpg',
    intentions: [
      'Coraje y fuerza',
      'Protección',
      'Prosperidad',
      'Confianza',
      'Enraizamiento',
      'Buena suerte',
    ],
    usageTips: [
      'Llévalo contigo para coraje y confianza',
      'Colócalo en el trabajo para el éxito',
      'Úsalo durante negociaciones',
      'Medita con él para el equilibrio',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Piedra Luna',
    description:
        'Piedra sagrada de la luna y lo femenino. Conecta con los ciclos lunares y la intuición.',
    element: Element.water,
    imageUrl: 'assets/images/crystals/pedra_da_lua.jpg',
    intentions: [
      'Intuición',
      'Ciclos femeninos',
      'Nuevos comienzos',
      'Equilibrio emocional',
      'Sueños',
      'Fertilidad',
    ],
    usageTips: [
      'Úsala durante la luna llena',
      'Colócala bajo la almohada para los sueños',
      'Llévala contigo para el equilibrio hormonal',
      'Medita con ella para la conexión lunar',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente (breve)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz de la luna',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Luna llena (especialmente)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Agua de luna',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Evita el sol intenso - puede desteñirse',
    ],
  ),
  const CrystalModel(
    name: 'Pirita',
    description:
        'Piedra de la prosperidad y la manifestación. Atrae la abundancia y protege contra la negatividad.',
    element: Element.earth,
    imageUrl: 'assets/images/crystals/pirita.jpg',
    intentions: [
      'Prosperidad',
      'Manifestación',
      'Protección',
      'Confianza',
      'Memoria',
      'Vitalidad',
    ],
    usageTips: [
      'Colócala en la oficina o el negocio',
      'Llévala en la cartera',
      'Úsala en rituales de prosperidad',
      'Colócala en cajas fuertes o cajones de dinero',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua',
        isSafe: false,
        warning: '¡Puede oxidarse - evita el agua!',
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sonido',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'No la mojes - puede oxidarse y liberar azufre',
      'Mantenla seca',
    ],
  ),
  const CrystalModel(
    name: 'Cuarzo Rosa',
    description:
        'Piedra del amor propio y el amor incondicional. Favorece la paz interior y la sanación emocional.',
    element: Element.water,
    imageUrl: 'assets/images/crystals/quartzo_rosa.jpg',
    intentions: [
      'Amor propio',
      'Autoaceptación',
      'Sanación emocional',
      'Relaciones',
      'Compasión',
    ],
    usageTips: [
      'Colócalo bajo la almohada para sueños amorosos',
      'Úsalo en el altar de amor propio',
      'Llévalo en el bolsillo para atraer el amor',
      'Medita sosteniéndolo sobre el corazón',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente',
        isSafe: false,
        warning: 'Puede desteñirse con la exposición prolongada al agua',
      ),
      CrystalMethod(
        method: 'Humo de hierbas (incienso, palo santo)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz de la luna',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sonido (campana, cuenco tibetano)',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Luna llena (preferentemente)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra (enterrar por 24h)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Otros cristales (amatista, cuarzo)',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Puede desteñirse con la exposición prolongada al sol',
      'Evita el agua por períodos largos',
    ],
  ),
  const CrystalModel(
    name: 'Cuarzo Transparente',
    description:
        'Maestro sanador y amplificador. Puede programarse para cualquier intención.',
    element: Element.spirit,
    imageUrl: 'assets/images/crystals/quartzo_transparente.jpg',
    intentions: [
      'Amplificación de energía',
      'Claridad',
      'Sanación general',
      'Programación de intenciones',
      'Limpieza',
      'Equilibrio',
    ],
    usageTips: [
      'Prográmalo con tu intención',
      'Úsalo para amplificar otros cristales',
      'Medita con él para la claridad mental',
      'Colócalo en agua para energizarla',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz del sol o de la luna',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sonido',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol o luna',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Intención y visualización',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Selenita',
    description:
        'Piedra de la paz y la purificación. Se limpia sola, no necesita limpieza frecuente.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/selenita.jpg',
    intentions: [
      'Purificación',
      'Paz',
      'Claridad mental',
      'Conexión espiritual',
      'Limpieza de ambientes',
      'Protección suave',
    ],
    usageTips: [
      'Colócala en los ambientes para purificarlos',
      'Úsala para limpiar otros cristales',
      'Medita con ella para la paz interior',
      'Colócala bajo la almohada (cuidado - es frágil)',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua',
        isSafe: false,
        warning: '¡NUNCA uses agua - disuelve la selenita!',
      ),
      CrystalMethod(
        method: 'Autolimpiante',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz de la luna (si lo deseas)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sonido',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Luz de la luna',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Se carga sola',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'NUNCA la mojes - se disuelve en agua',
      'Muy frágil - manipúlala con cuidado',
      'No la dejes al sol - puede volverse opaca',
    ],
  ),
  const CrystalModel(
    name: 'Sodalita',
    description:
        'Piedra de la lógica, la verdad y la comunicación. Estimula el pensamiento racional y la intuición.',
    element: Element.air,
    imageUrl: 'assets/images/crystals/sodalita.jpg',
    intentions: [
      'Comunicación clara',
      'Verdad y honestidad',
      'Lógica y racionalidad',
      'Intuición',
      'Autoaceptación',
      'Paz interior',
    ],
    usageTips: [
      'Úsala durante los estudios',
      'Llévala contigo para una comunicación clara',
      'Medita con ella para equilibrar lógica e intuición',
      'Colócala en la oficina',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente (breve)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luna',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Luna',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Cuarzo',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Turmalina Negra',
    description:
        'Poderosa piedra de protección y enraizamiento. Bloquea las energías negativas.',
    element: Element.earth,
    imageUrl: 'assets/images/crystals/turmalina_negra.jpg',
    intentions: [
      'Protección',
      'Enraizamiento',
      'Limpieza energética',
      'Bloqueo de negatividad',
      'Equilibrio',
      'Purificación',
    ],
    usageTips: [
      'Colócala en las esquinas de la casa para protección',
      'Llévala contigo para protegerte de energías pesadas',
      'Úsala durante meditaciones de enraizamiento',
      'Colócala cerca de aparatos electrónicos',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Agua corriente con sal',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Humo de romero o salvia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Tierra (enterrar)',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Tierra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luna nueva',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sol',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
];
