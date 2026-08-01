import '../models/metal_model.dart';
import '../models/crystal_model.dart';
import '../models/herb_model.dart';

/// Metales de la enciclopedia — contenido en español.
///
/// Enums, elementos, planetas e imágenes son invariantes entre idiomas.
/// Mantén el mismo orden que `metals_data_pt.dart` — la paridad se verifica
/// en `test/content_parity_test.dart`.
final List<MetalModel> metalsEs = [
  const MetalModel(
    name: 'Oro',
    description:
        'Metal precioso del Sol, símbolo de poder divino, realeza y perfección. '
        'Representa la luz espiritual, la iluminación y la energía vital. '
        'Tradicionalmente usado para atraer prosperidad, éxito y protección',
    element: Element.fire,
    planet: Planet.sun,
    conductsPower: true,
    imageUrl: 'assets/images/metais/ouro.jpg',
    magicalProperties: [
      'Prosperidad y abundancia',
      'Poder personal',
      'Éxito y victoria',
      'Protección espiritual',
      'Energía vital',
      'Iluminación',
      'Autoconfianza',
      'Manifestación',
    ],
    ritualUses: [
      'Amuletos de protección y poder',
      'Rituales solares y de prosperidad',
      'Consagración de herramientas rituales',
      'Magia de atracción de riqueza',
      'Trabajos con deidades solares',
      'Rituales de autoconfianza y liderazgo',
    ],
    correspondences: [
      'Día: Domingo',
      'Dioses: Apolo, Ra, Lugh, Balder',
      'Diosas: Brighid, Amaterasu',
      'Chakra: Plexo Solar, Corona',
      'Sabbat: Litha (Solsticio de Verano)',
      'Tarot: El Sol',
    ],
    traditionalUses:
        'Usado en coronas, cetros y objetos rituales de poder. '
        'Las joyas de oro se usan tradicionalmente para protección '
        'y para atraer la energía solar',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Plata',
    description:
        'Metal sagrado de la Luna, símbolo de intuición, misterio y protección psíquica. '
        'Representa lo femenino divino, los ciclos y la magia lunar. '
        'Es el metal más usado en brujería para protección y adivinación',
    element: Element.water,
    planet: Planet.moon,
    conductsPower: true,
    imageUrl: 'assets/images/metais/prata.jpg',
    magicalProperties: [
      'Protección psíquica',
      'Intuición y clarividencia',
      'Conexión lunar',
      'Sueños proféticos',
      'Purificación',
      'Magia femenina',
      'Reflexión e introspección',
      'Adivinación',
    ],
    ritualUses: [
      'Espejos mágicos y bolas de cristal',
      'Joyas de protección',
      'Cálices y copas rituales',
      'Colgantes de Luna',
      'Magia lunar y de los sueños',
      'Rituales de adivinación',
      'Trabajos con deidades lunares',
    ],
    correspondences: [
      'Día: Lunes',
      'Dioses: Thot, Jonsu',
      'Diosas: Selene, Diana, Artemisa, Hécate',
      'Chakra: Tercer Ojo, Corona',
      'Sabbat: Esbats (Lunas Llenas)',
      'Tarot: La Luna, La Sacerdotisa',
    ],
    traditionalUses:
        'Tradicionalmente usada en amuletos, espejos mágicos, '
        'cálices rituales y joyas de protección. Se dice que la plata '
        'se oscurece en presencia de energía negativa',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Cobre',
    description:
        'Metal de Venus, conductor supremo de energía mágica. '
        'Asociado al amor, la belleza, la armonía y la sanación. '
        'Es el metal que mejor conduce la energía después de la plata',
    element: Element.water,
    planet: Planet.venus,
    conductsPower: true,
    imageUrl: 'assets/images/metais/cobre.jpg',
    magicalProperties: [
      'Amor y romance',
      'Belleza y atracción',
      'Armonía y paz',
      'Sanación energética',
      'Conducción de energía',
      'Creatividad artística',
      'Fertilidad',
      'Equilibrio emocional',
    ],
    ritualUses: [
      'Varitas mágicas (núcleo de cobre)',
      'Talismanes de amor',
      'Amuletos de sanación',
      'Herramientas para conducir energía',
      'Rituales de Venus',
      'Magia de atracción',
      'Círculos de protección',
    ],
    correspondences: [
      'Día: Viernes',
      'Dioses: Eros, Cupido',
      'Diosas: Afrodita, Venus, Freya, Hathor',
      'Chakra: Corazón',
      'Sabbat: Beltane',
      'Tarot: La Emperatriz, Los Enamorados',
    ],
    traditionalUses:
        'Usado en varitas, amuletos de amor y herramientas de sanación. '
        'Las pirámides de cobre se usan para amplificar la energía. '
        'Las pulseras de cobre se usan tradicionalmente para aliviar dolores',
    safetyWarnings: [
      'Puede manchar la piel de verde (no es peligroso, solo oxidación)',
    ],
  ),
  const MetalModel(
    name: 'Hierro',
    description:
        'Metal de Marte, símbolo de protección, fuerza y coraje. '
        'Tradicionalmente usado para alejar espíritus malignos y hadas. '
        'Representa la fuerza guerrera y la protección física',
    element: Element.fire,
    planet: Planet.mars,
    conductsPower: false,
    imageUrl: 'assets/images/metais/ferro.jpg',
    magicalProperties: [
      'Protección poderosa',
      'Coraje y fuerza',
      'Destierro de negatividad',
      'Defensa psíquica',
      'Enraizamiento',
      'Fuerza de voluntad',
      'Justicia',
      'Ruptura de maldiciones',
    ],
    ritualUses: [
      'Clavos de hierro para proteger la casa',
      'Herraduras de la suerte',
      'Athames y cuchillos rituales',
      'Calderos',
      'Amuletos de protección',
      'Círculos de destierro',
      'Rituales de Marte',
    ],
    correspondences: [
      'Día: Martes',
      'Dioses: Marte, Ares, Thor, Ogún',
      'Diosas: Morrigan, Durga',
      'Chakra: Raíz, Plexo Solar',
      'Sabbat: Sin asociación específica',
      'Tarot: La Torre, El Carro',
    ],
    traditionalUses:
        'Herraduras sobre las puertas para protección. Clavos de hierro '
        'enterrados en las esquinas de la propiedad. Cuchillos rituales '
        '(athames) con hoja de hierro. Se dice que las hadas y los espíritus '
        'malignos no pueden atravesar el hierro',
    safetyWarnings: [
      'Se oxida fácilmente - manténlo seco',
    ],
  ),
  const MetalModel(
    name: 'Estaño',
    description:
        'Metal de Júpiter, asociado a la expansión, el crecimiento y la justicia. '
        'Tradicionalmente usado para atraer prosperidad, suerte y protección legal',
    element: Element.air,
    planet: Planet.jupiter,
    conductsPower: true,
    imageUrl: 'assets/images/metais/estanho.jpg',
    magicalProperties: [
      'Prosperidad y expansión',
      'Suerte y fortuna',
      'Justicia y equidad',
      'Crecimiento espiritual',
      'Protección en viajes',
      'Abundancia',
      'Sabiduría',
      'Honor y reputación',
    ],
    ritualUses: [
      'Amuletos de prosperidad',
      'Rituales de justicia',
      'Magia de la suerte',
      'Protección en viajes',
      'Trabajos con Júpiter',
      'Rituales de jueves',
      'Magia de crecimiento en los negocios',
    ],
    correspondences: [
      'Día: Jueves',
      'Dioses: Júpiter, Zeus, Thor, Dagda',
      'Diosas: Temis, Fortuna',
      'Chakra: Corona, Tercer Ojo',
      'Sabbat: Yule',
      'Tarot: La Rueda de la Fortuna, El Hierofante',
    ],
    traditionalUses:
        'Usado en talismanes de suerte y prosperidad. '
        'Las monedas de estaño se llevan tradicionalmente para atraer dinero. '
        'También se usa en campanas rituales',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Plomo',
    description:
        'Metal de Saturno, asociado al tiempo, los límites y la transformación profunda. '
        'Usado en magia de destierro, protección pesada y ruptura de vicios. '
        'Representa limitaciones, disciplina y karma',
    element: Element.earth,
    planet: Planet.saturn,
    conductsPower: false,
    imageUrl: 'assets/images/metais/chumbo.jpg',
    magicalProperties: [
      'Destierro poderoso',
      'Protección pesada',
      'Ruptura de vicios',
      'Límites y disciplina',
      'Enraizamiento profundo',
      'Trabajo de sombra',
      'Karma y justicia divina',
      'Transformación difícil',
    ],
    ritualUses: [
      'Rituales de destierro',
      'Ruptura de maldiciones',
      'Magia de límites',
      'Trabajos de Saturno',
      'Rituales de sábado',
      'Enterrar intenciones negativas',
      'Protección contra magia negra',
    ],
    correspondences: [
      'Día: Sábado',
      'Dioses: Saturno, Cronos, Hades',
      'Diosas: Hécate, Las Parcas',
      'Chakra: Raíz',
      'Sabbat: Samhain',
      'Tarot: La Muerte, El Ermitaño, El Mundo',
    ],
    traditionalUses:
        'Tradicionalmente usado para sellar intenciones negativas en cajas '
        'que luego se entierran. Usado en pesos de protección y en rituales '
        'de destierro definitivo',
    safetyWarnings: [
      '⚠️ TÓXICO - No ingerir, evitar el contacto prolongado con la piel',
      'Lávate las manos después de manipularlo',
      'No usar en calderos ni utensilios de cocina',
      'Mantener lejos de niños y animales',
    ],
  ),
  const MetalModel(
    name: 'Bronce',
    description:
        'Aleación antigua de cobre y estaño, representa tradición, antigüedad y conexión ancestral. '
        'Usado desde tiempos inmemoriales en armas, escudos y objetos rituales',
    element: Element.fire,
    planet: Planet.venus,
    conductsPower: true,
    imageUrl: 'assets/images/metais/bronze.jpg',
    magicalProperties: [
      'Conexión ancestral',
      'Tradición e historia',
      'Protección duradera',
      'Fuerza y resistencia',
      'Magia antigua',
      'Honra a los antepasados',
      'Preservación',
      'Memoria',
    ],
    ritualUses: [
      'Campanas rituales',
      'Instrumentos musicales mágicos',
      'Estatuas de deidades',
      'Calderos (tradicional)',
      'Trabajos ancestrales',
      'Rituales de tradición',
      'Protección del linaje',
    ],
    correspondences: [
      'Día: Viernes (del cobre)',
      'Dioses: Hefesto, Goibniu, Wayland',
      'Diosas: Atenea (guerrera)',
      'Chakra: Raíz, Plexo Solar',
      'Sabbat: Mabon',
      'Tarot: El Ermitaño, El Juicio',
    ],
    traditionalUses:
        'Las campanas de bronce se usan para limpiar la energía y marcar '
        'el inicio de los rituales. Los calderos de bronce son tradicionales '
        'en la brujería celta. En la antigüedad se usaban espejos de bronce '
        'pulido para la adivinación',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Latón',
    description:
        'Aleación de cobre y zinc, asociada a la purificación, la limpieza energética '
        'y la protección contra la negatividad. Brilla como el oro pero es más accesible',
    element: Element.fire,
    planet: Planet.sun,
    conductsPower: true,
    imageUrl: 'assets/images/metais/latao.jpg',
    magicalProperties: [
      'Purificación',
      'Limpieza energética',
      'Protección contra la negatividad',
      'Claridad mental',
      'Atracción de suerte',
      'Disipación de ilusiones',
      'Energía solar accesible',
      'Verdad',
    ],
    ritualUses: [
      'Campanas de limpieza',
      'Incensarios',
      'Cuencos de ofrenda',
      'Candelabros',
      'Amuletos de protección',
      'Rituales de purificación',
      'Limpieza de espacios',
    ],
    correspondences: [
      'Día: Domingo',
      'Dioses: Apolo, Helios',
      'Diosas: Brighid',
      'Chakra: Plexo Solar',
      'Sabbat: Litha',
      'Tarot: La Templanza, El Mago',
    ],
    traditionalUses:
        'Tradicionalmente usado en incensarios y campanas de limpieza. '
        'Los objetos de latón pulido se usan en los altares para reflejar '
        'la energía negativa de vuelta. Sustituto accesible del oro en la magia',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Aluminio',
    description:
        'Metal moderno asociado a la protección mental, el bloqueo de influencias '
        'externas y la preservación de la energía. Ligero y versátil',
    element: Element.air,
    planet: Planet.mercury,
    conductsPower: true,
    imageUrl: 'assets/images/metais/aluminio.jpg',
    magicalProperties: [
      'Protección mental',
      'Bloqueo de influencias',
      'Preservación de energía',
      'Ligereza y adaptabilidad',
      'Reflejo de la negatividad',
      'Comunicación clara',
      'Velocidad',
      'Modernidad',
    ],
    ritualUses: [
      'Envolver objetos mágicos para preservarlos',
      'Protección de tarot y herramientas',
      'Rituales de bloqueo mental',
      'Magia de comunicación',
      'Reflejar hechizos de vuelta',
      'Trabajos de Mercurio',
    ],
    correspondences: [
      'Día: Miércoles',
      'Dioses: Mercurio, Hermes',
      'Diosas: Atenea (sabiduría)',
      'Chakra: Garganta, Tercer Ojo',
      'Sabbat: Sin asociación',
      'Tarot: El Loco, El Mago',
    ],
    traditionalUses:
        'El papel de aluminio se usa para envolver y proteger cartas de tarot, '
        'cristales y objetos mágicos. También se usa para reflejar la energía '
        'negativa de vuelta a su origen',
    safetyWarnings: [],
  ),
];
