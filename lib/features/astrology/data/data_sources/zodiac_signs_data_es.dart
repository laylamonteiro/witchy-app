import '../models/enums.dart';
import '../models/zodiac_sign_data.dart';

/// Los 12 signos del zodíaco — contenido en español.
///
/// El campo `sign` es invariante entre idiomas; solo se traducen los textos.
/// Mantén el mismo orden/cantidad en los tres archivos
/// (`zodiac_signs_data_pt/en/es.dart`) — la paridad se verifica en
/// `test/astrology_content_parity_test.dart`.
const List<ZodiacSignData> zodiacSignsEs = [
  ZodiacSignData(
    sign: ZodiacSign.aries,
    dateRange: '21 de Marzo - 19 de Abril',
    rulingPlanet: 'Marte',
    keywords: 'Coraje, Iniciativa, Liderazgo, Pionerismo',
    personality:
        'Aries es el primer signo del zodíaco, representando el inicio de todo. '
        'Las personas de Aries son naturalmente valientes, directas y llenas de energía. '
        'Tienen un espíritu competitivo y adoran los desafíos. Son líderes natos que prefieren '
        'actuar rápidamente antes que planear durante mucho tiempo. Su honestidad puede '
        'a veces parecer brusca, pero viene de un lugar genuino',
    magicalGifts:
        'Los arianos poseen una energía vital muy fuerte, excelente para la magia de acción '
        'y protección. Tienen facilidad natural con los rituales de coraje, fuerza de voluntad '
        'y nuevos comienzos. Su llama interior es poderosa para destierros y limpiezas energéticas',
    bestPractices:
        'Magia de velas (especialmente rojas y naranjas), rituales de protección, '
        'hechizos de coraje y fuerza, trabajos de Luna Nueva para nuevos inicios, '
        'magia marcial y trabajos con el elemento Fuego',
    crystals: 'Cornalina, Jaspe Rojo, Rubí, Diamante, Hematita',
    herbs: 'Pimienta, Jengibre, Ajo, Canela, Ortiga',
    colors: 'Rojo, Naranja, Dorado',
  ),
  ZodiacSignData(
    sign: ZodiacSign.taurus,
    dateRange: '20 de Abril - 20 de Mayo',
    rulingPlanet: 'Venus',
    keywords: 'Estabilidad, Sensualidad, Persistencia, Abundancia',
    personality:
        'Tauro es el signo de la tierra fértil y la abundancia. Las personas de Tauro valoran '
        'la seguridad, el confort y los placeres sensoriales. Son extremadamente leales, pacientes '
        'y trabajadoras. Aprecian las cosas bellas de la vida y tienen un fuerte sentido estético. '
        'Cuando se comprometen con algo, van hasta el final con determinación inquebrantable',
    magicalGifts:
        'Los taurinos tienen una conexión especial con la tierra y la naturaleza. Son excelentes en '
        'magia de prosperidad, fertilidad y manifestación material. Poseen un toque '
        'curativo natural y habilidad para trabajar con plantas y cristales',
    bestPractices:
        'Brujería verde y herbología, magia de prosperidad y abundancia, '
        'rituales de Luna Llena, trabajo con cristales, jardinería mágica, '
        'hechizos de amor y belleza, baños rituales aromáticos',
    crystals: 'Cuarzo Rosa, Esmeralda, Jade, Malaquita, Turmalina Verde',
    herbs: 'Rosa, Verbena, Tomillo, Manzana, Menta',
    colors: 'Verde, Rosa, Tonos terrosos',
  ),
  ZodiacSignData(
    sign: ZodiacSign.gemini,
    dateRange: '21 de Mayo - 20 de Junio',
    rulingPlanet: 'Mercurio',
    keywords: 'Comunicación, Curiosidad, Versatilidad, Intelecto',
    personality:
        'Géminis es el signo de la dualidad y la comunicación. Los geminianos son curiosos, '
        'versátiles y excelentes comunicadores. Adoran aprender cosas nuevas y '
        'compartir conocimiento. Su mente rápida puede manejar múltiples tareas '
        'simultáneamente. Son sociables, ingeniosos y siempre tienen algo interesante que decir',
    magicalGifts:
        'Los geminianos tienen un don natural para la magia de la palabra - encantamientos, sigilos '
        'e invocaciones. Son excelentes en adivinación, especialmente tarot y bibliomancia. '
        'Su versatilidad les permite dominar diversas formas de magia',
    bestPractices:
        'Magia de la palabra y encantamientos verbales, creación de sigilos, '
        'adivinación (tarot, runas, péndulo), magia de comunicación, '
        'trabajo con inciensos y el elemento Aire, estudios esotéricos',
    crystals: 'Ágata, Citrino, Ojo de Tigre, Aguamarina, Howlita',
    herbs: 'Lavanda, Romero, Menta, Fenogreco, Hinojo',
    colors: 'Amarillo, Gris, Azul claro',
  ),
  ZodiacSignData(
    sign: ZodiacSign.cancer,
    dateRange: '21 de Junio - 22 de Julio',
    rulingPlanet: 'Luna',
    keywords: 'Intuición, Nutrición, Protección, Emoción',
    personality:
        'Cáncer es el signo de la Luna, que gobierna las emociones y la intuición. Los cancerianos son '
        'profundamente intuitivos, protectores y cariñosos. Valoran la familia y el hogar '
        'por encima de todo. Tienen una memoria emocional fuerte y son muy leales a quienes aman. '
        'Su sensibilidad es tanto su fuerza como su vulnerabilidad',
    magicalGifts:
        'Los cancerianos tienen una conexión natural con la Luna y sus ciclos. Poseen una fuerte '
        'intuición psíquica, don para la magia emocional y habilidad natural para '
        'la protección del hogar. Son excelentes en trabajos con agua y magia lunar',
    bestPractices: 'Magia lunar en todas las fases, protección del hogar y la familia, '
        'rituales con agua (baños, pociones, espejos), trabajo con ancestros, '
        'magia de sanación emocional, adivinación por sueños',
    crystals: 'Piedra de Luna, Perla, Selenita, Ópalo, Cuarzo Lechoso',
    herbs: 'Artemisa, Jazmín, Lechuga, Pepino, Nenúfar',
    colors: 'Blanco, Plata, Azul pálido',
  ),
  ZodiacSignData(
    sign: ZodiacSign.leo,
    dateRange: '23 de Julio - 22 de Agosto',
    rulingPlanet: 'Sol',
    keywords: 'Creatividad, Expresión, Generosidad, Poder',
    personality:
        'Leo es el signo del Sol, irradiando luz y calor. Los leoninos son naturalmente '
        'carismáticos, creativos y generosos. Adoran ser el centro de atención y '
        'tienen talento para el liderazgo. Son leales, protectores y de gran corazón. '
        'Su presencia ilumina cualquier ambiente en el que entran',
    magicalGifts:
        'Los leoninos portan una poderosa energía solar. Son maestros en magia de éxito, '
        'glamour y manifestación. Tienen un don natural para liderar rituales en grupo '
        'y canalizar la energía vital. Excelentes en trabajos de autoconfianza',
    bestPractices:
        'Magia solar y rituales al mediodía, trabajos de éxito y reconocimiento, '
        'glamour mágico, magia de velas doradas, rituales de creatividad, '
        'hechizos de autoestima, liderazgo de círculos mágicos',
    crystals: 'Ámbar, Citrino, Ojo de Tigre, Pirita, Topacio',
    herbs: 'Girasol, Manzanilla, Canela, Laurel, Caléndula',
    colors: 'Dorado, Naranja, Amarillo brillante',
  ),
  ZodiacSignData(
    sign: ZodiacSign.virgo,
    dateRange: '23 de Agosto - 22 de Septiembre',
    rulingPlanet: 'Mercurio',
    keywords: 'Análisis, Servicio, Perfección, Practicidad',
    personality:
        'Virgo es el signo de la organización y el servicio. Los virginianos son analíticos, '
        'prácticos y extremadamente detallistas. Tienen un fuerte sentido del deber y adoran ayudar '
        'a los demás. Son perfeccionistas por naturaleza y buscan siempre mejorar. '
        'Su mente organizada es excelente para resolver problemas complejos',
    magicalGifts:
        'Los virginianos tienen un talento especial para la herbología y la magia curativa. '
        'Son excelentes preparando pociones, tinturas y remedios mágicos. '
        'Su atención al detalle hace que sus rituales sean precisos y eficaces',
    bestPractices: 'Herbología y preparación de pociones, magia de sanación y salud, '
        'rituales de purificación, organización de altares, '
        'magia práctica del día a día, creación de talismanes y amuletos',
    crystals: 'Amazonita, Peridoto, Jaspe, Cornalina, Zafiro',
    herbs: 'Valeriana, Melisa, Manzanilla, Hinojo, Espliego',
    colors: 'Verde, Marrón, Beige, Azul marino',
  ),
  ZodiacSignData(
    sign: ZodiacSign.libra,
    dateRange: '23 de Septiembre - 22 de Octubre',
    rulingPlanet: 'Venus',
    keywords: 'Equilibrio, Armonía, Justicia, Relaciones',
    personality:
        'Libra es el signo del equilibrio y la armonía. Los librianos son diplomáticos, '
        'justos y aprecian la belleza en todas sus formas. Valoran las relaciones '
        'y buscan la paz y la cooperación. Tienen un fuerte sentido estético y habilidad natural '
        'para ver todos los lados de una cuestión',
    magicalGifts:
        'Los librianos son naturalmente hábiles en magia de amor y relaciones. '
        'Tienen un don para equilibrar energías y armonizar ambientes. Son excelentes '
        'en trabajos de justicia y contratos mágicos',
    bestPractices:
        'Magia de amor y relaciones, rituales de equilibrio y armonía, '
        'hechizos de belleza y glamour, trabajos de justicia, '
        'magia de asociaciones, decoración de altares estéticos',
    crystals: 'Cuarzo Rosa, Jade, Lapislázuli, Ópalo, Turmalina Rosa',
    herbs: 'Rosa, Violeta, Tomillo, Mirra, Verbena',
    colors: 'Rosa, Azul claro, Verde suave, Lavanda',
  ),
  ZodiacSignData(
    sign: ZodiacSign.scorpio,
    dateRange: '23 de Octubre - 21 de Noviembre',
    rulingPlanet: 'Plutón (y Marte)',
    keywords: 'Transformación, Intensidad, Misterio, Poder',
    personality:
        'Escorpio es el signo de la transformación profunda. Los escorpianos son intensos, '
        'misteriosos y extremadamente perceptivos. Tienen la capacidad de ver más allá de las '
        'apariencias y no temen explorar las sombras. Son leales hasta la muerte '
        'y poseen una fuerza de voluntad incomparable',
    magicalGifts:
        'Los escorpianos tienen una conexión natural con lo oculto y la muerte mística. '
        'Son maestros en magia de transformación, destierro y trabajo con sombras. '
        'Poseen una fuerte intuición psíquica y habilidad para la mediumnidad',
    bestPractices:
        'Trabajo con sombras y psique profunda, magia de transformación, '
        'rituales de Samhain y contacto ancestral, destierros poderosos, '
        'magia sexual, trabajo con Plutón, nigromancia respetuosa',
    crystals: 'Obsidiana, Turmalina Negra, Granate, Labradorita, Malaquita',
    herbs: 'Ajenjo, Mandrágora, Albahaca, Pachulí, Sangre de Dragón',
    colors: 'Negro, Rojo oscuro, Púrpura profundo',
  ),
  ZodiacSignData(
    sign: ZodiacSign.sagittarius,
    dateRange: '22 de Noviembre - 21 de Diciembre',
    rulingPlanet: 'Júpiter',
    keywords: 'Expansión, Filosofía, Aventura, Optimismo',
    personality:
        'Sagitario es el signo de la expansión y la búsqueda de la verdad. Los sagitarianos son '
        'optimistas, aventureros y filosóficos. Adoran viajar (física y mentalmente) '
        'y expandir sus horizontes. Son honestos, generosos y tienen fe en la vida. '
        'Su búsqueda de significado los lleva a explorar diversas tradiciones espirituales',
    magicalGifts:
        'Los sagitarianos tienen conexión con la sabiduría superior y la expansión de la conciencia. '
        'Son excelentes en magia de suerte, abundancia y viajes astrales. '
        'Tienen facilidad para conectarse con guías espirituales y maestros ascendidos',
    bestPractices:
        'Magia de suerte y expansión, rituales de prosperidad jupiteriana, '
        'viaje astral y jornadas chamánicas, trabajo con filosofías antiguas, '
        'hechizos para estudios y sabiduría, rituales en lugares sagrados',
    crystals: 'Turquesa, Amatista, Sodalita, Lapislázuli, Topacio Azul',
    herbs: 'Salvia, Cedro, Nuez Moscada, Anís, Diente de León',
    colors: 'Púrpura, Azul real, Turquesa',
  ),
  ZodiacSignData(
    sign: ZodiacSign.capricorn,
    dateRange: '22 de Diciembre - 19 de Enero',
    rulingPlanet: 'Saturno',
    keywords: 'Disciplina, Ambición, Estructura, Responsabilidad',
    personality:
        'Capricornio es el signo de la estructura y la ambición. Los capricornianos son '
        'disciplinados, responsables y extremadamente determinados. Valoran la tradición '
        'y el trabajo duro. Pueden parecer serios, pero tienen un humor seco. '
        'Construyen sus vidas con paciencia, ladrillo a ladrillo',
    magicalGifts:
        'Los capricornianos tienen maestría en magia de manifestación a largo plazo. '
        'Son excelentes en rituales de estructura, protección y trabajo con ancestros. '
        'Su disciplina permite prácticas mágicas consistentes y poderosas',
    bestPractices: 'Magia de carrera y éxito material, rituales saturninos, '
        'trabajo con ancestros y tradiciones antiguas, hechizos de protección, '
        'magia de compromiso y contratos, rituales de Yule',
    crystals: 'Ónix, Turmalina Negra, Obsidiana, Granate, Azabache',
    herbs: 'Consuelda, Ciprés, Hiedra, Cardo, Raíz de Valeriana',
    colors: 'Negro, Gris, Marrón oscuro, Verde musgo',
  ),
  ZodiacSignData(
    sign: ZodiacSign.aquarius,
    dateRange: '20 de Enero - 18 de Febrero',
    rulingPlanet: 'Urano (y Saturno)',
    keywords: 'Innovación, Humanitarismo, Originalidad, Libertad',
    personality:
        'Acuario es el signo de la innovación y la conciencia colectiva. Los acuarianos son '
        'originales, independientes y humanitarios. Piensan fuera de lo común y valoran '
        'la libertad por encima de todo. Son visionarios que se preocupan genuinamente '
        'por el bienestar de la humanidad',
    magicalGifts:
        'Los acuarianos tienen conexión con las energías cósmicas y la conciencia expandida. '
        'Son excelentes en magia de grupo y trabajos para el bien colectivo. '
        'Tienen facilidad para las innovaciones mágicas y la tecnomancia',
    bestPractices:
        'Magia de grupo y círculos de brujas, rituales para causas humanitarias, '
        'trabajo con astrología y cartas astrales, innovaciones en prácticas mágicas, '
        'hechizos de libertad e independencia, tecnomancia',
    crystals: 'Amatista, Aguamarina, Fluorita, Labradorita, Angelita',
    herbs: 'Espliego, Mirra, Olíbano, Menta Piperita, Verbena',
    colors: 'Azul eléctrico, Violeta, Plata, Turquesa',
  ),
  ZodiacSignData(
    sign: ZodiacSign.pisces,
    dateRange: '19 de Febrero - 20 de Marzo',
    rulingPlanet: 'Neptuno (y Júpiter)',
    keywords: 'Intuición, Compasión, Misticismo, Sueños',
    personality:
        'Piscis es el signo de la trascendencia y la compasión universal. Los piscianos son '
        'extremadamente intuitivos, empáticos y creativos. Viven entre el mundo material '
        'y espiritual con naturalidad. Son artistas del alma, capaces de sentir '
        'profundamente las emociones de los demás y del colectivo',
    magicalGifts:
        'Los piscianos tienen los dones psíquicos más fuertes del zodíaco. Son naturalmente '
        'médiums, videntes y sanadores empáticos. Su conexión con el mundo espiritual '
        'es innata, y tienen facilidad para el trabajo con sueños y visiones',
    bestPractices:
        'Trabajo con sueños e interpretación onírica, mediumnidad y canalización, '
        'magia acuática y rituales con agua, sanación empática, '
        'viaje astral, conexión con seres espirituales, arte como magia',
    crystals: 'Amatista, Aguamarina, Fluorita, Piedra de Luna, Sugilita',
    herbs: 'Jazmín, Loto, Eucalipto, Algas, Sauce',
    colors: 'Azul marino, Púrpura, Verde agua, Plata',
  ),
];
