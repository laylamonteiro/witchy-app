import '../models/oracle_card_model.dart';

/// Las 44 cartas del Oráculo — contenido en español.
///
/// Los campos `id` y `emoji` son invariantes entre idiomas; nombre, mensaje,
/// orientación y palabras clave se traducen. Mantén el mismo orden que
/// `oracle_cards_data_pt.dart` — la paridad se verifica en
/// `test/content_parity_test.dart`.
const List<OracleCard> oracleCardsEs = [
  OracleCard(
    id: 1,
    name: 'La Luna Llena',
    message: 'Es hora de cosechar lo que sembraste',
    emoji: '🌕',
    guidance: 'La Luna Llena ilumina tu camino y saca a la luz todo lo que estaba '
        'oculto. Este es un momento de culminación y realización. '
        'Tus esfuerzos están dando frutos.',
    keywords: ['realización', 'iluminación', 'culminación'],
  ),
  OracleCard(
    id: 2,
    name: 'La Luna Nueva',
    message: 'Nuevos comienzos te esperan',
    emoji: '🌑',
    guidance: 'La Luna Nueva representa un portal hacia nuevos comienzos. '
        'Siembra tus intenciones ahora y míralas crecer. Este es el momento perfecto para empezar.',
    keywords: ['nuevos comienzos', 'intención', 'siembra'],
  ),
  OracleCard(
    id: 3,
    name: 'El Caldero',
    message: 'La transformación está en marcha',
    emoji: '🪄',
    guidance: 'Dentro del caldero, los elementos se mezclan y se transforman. '
        'Estás en medio de una transformación profunda. Confía en el proceso.',
    keywords: ['transformación', 'alquimia', 'cambio'],
  ),
  OracleCard(
    id: 4,
    name: 'La Escoba',
    message: 'Limpia lo que ya no sirve',
    emoji: '🧹',
    guidance: 'La escoba barre las energías estancadas. Es hora de una limpieza '
        'profunda en tu vida. Suelta lo viejo para dar espacio a lo nuevo.',
    keywords: ['limpieza', 'liberación', 'renovación'],
  ),
  OracleCard(
    id: 5,
    name: 'El Grimorio',
    message: 'El conocimiento ancestral está a tu alcance',
    emoji: '📖',
    guidance: 'El grimorio guarda sabiduría antigua. Estudia, aprende y conéctate '
        'con las enseñanzas de los antiguos. El conocimiento es poder.',
    keywords: ['sabiduría', 'estudio', 'ancestralidad'],
  ),
  OracleCard(
    id: 6,
    name: 'La Vela',
    message: 'Tu luz interior brilla con fuerza',
    emoji: '🕯️',
    guidance: 'La llama de la vela nunca vacila. Tu luz interior es poderosa y '
        'constante. Confía en tu propia sabiduría e intuición.',
    keywords: ['luz interior', 'fe', 'claridad'],
  ),
  OracleCard(
    id: 7,
    name: 'El Cristal',
    message: 'Llegan claridad y sanación',
    emoji: '💎',
    guidance: 'Los cristales amplifican la energía y traen sanación. Estás entrando '
        'en un período de mayor claridad y bienestar. Permítete sanar.',
    keywords: ['sanación', 'claridad', 'amplificación'],
  ),
  OracleCard(
    id: 8,
    name: 'El Pentagrama',
    message: 'La protección divina está contigo',
    emoji: '⭐',
    guidance: 'El pentagrama es un símbolo de protección. Estás a salvo y protegido '
        'por las fuerzas divinas. Nada malo puede alcanzarte.',
    keywords: ['protección', 'seguridad', 'divino'],
  ),
  OracleCard(
    id: 9,
    name: 'El Athame',
    message: 'Corta lo que ya no sirve',
    emoji: '🗡️',
    guidance: 'El athame corta con precisión. Es hora de tomar decisiones firmes y '
        'eliminar lo que ya no resuena contigo.',
    keywords: ['decisión', 'corte', 'firmeza'],
  ),
  OracleCard(
    id: 10,
    name: 'El Cáliz',
    message: 'Recibe las bendiciones que se te ofrecen',
    emoji: '🏆',
    guidance: 'El cáliz está lleno de bendiciones esperando ser recibidas. '
        'Ábrete a recibir amor, abundancia y alegría.',
    keywords: ['recibir', 'bendiciones', 'abundancia'],
  ),
  OracleCard(
    id: 11,
    name: 'El Fuego',
    message: 'Se necesitan pasión y acción',
    emoji: '🔥',
    guidance: 'El fuego quema, transforma e ilumina. Es hora de actuar con pasión '
        'y determinación. Deja que tu fuego interior te guíe.',
    keywords: ['pasión', 'acción', 'transformación'],
  ),
  OracleCard(
    id: 12,
    name: 'La Tierra',
    message: 'Estabilidad y manifestación',
    emoji: '🌍',
    guidance: 'La Tierra ofrece una base sólida. Tus intenciones se están manifestando '
        'en el plano físico. Sigue firme en tu camino.',
    keywords: ['estabilidad', 'manifestación', 'arraigo'],
  ),
  OracleCard(
    id: 13,
    name: 'El Aire',
    message: 'Fluyen nuevos pensamientos e ideas',
    emoji: '💨',
    guidance: 'El Aire trae claridad mental y nuevas perspectivas. Abre tu mente a '
        'nuevas ideas y formas de pensar.',
    keywords: ['claridad mental', 'ideas', 'comunicación'],
  ),
  OracleCard(
    id: 14,
    name: 'El Agua',
    message: 'Fluye con tus emociones',
    emoji: '💧',
    guidance: 'El Agua nos enseña a fluir. Permítete sentir profundamente y '
        'sigue el flujo de tus emociones con confianza.',
    keywords: ['emociones', 'intuición', 'fluidez'],
  ),
  OracleCard(
    id: 15,
    name: 'La Lechuza',
    message: 'La sabiduría oculta se revela',
    emoji: '🦉',
    guidance: 'La Lechuza ve a través de la oscuridad. Secretos y sabiduría oculta '
        'se están revelando ante ti. Presta atención.',
    keywords: ['sabiduría', 'revelación', 'visión'],
  ),
  OracleCard(
    id: 16,
    name: 'El Gato Negro',
    message: 'La magia te rodea',
    emoji: '🐈‍⬛',
    guidance: 'El Gato Negro camina entre mundos. Estás rodeado de magia '
        'y sincronicidades. Reconoce las señales.',
    keywords: ['magia', 'misterio', 'sincronicidad'],
  ),
  OracleCard(
    id: 17,
    name: 'La Serpiente',
    message: 'Renacimiento y sanación profunda',
    emoji: '🐍',
    guidance: 'La Serpiente cambia de piel y renace. Estás atravesando una '
        'transformación profunda. Deja morir lo viejo para renacer.',
    keywords: ['renacimiento', 'sanación', 'transformación'],
  ),
  OracleCard(
    id: 18,
    name: 'La Araña',
    message: 'Eres la creadora de tu telaraña',
    emoji: '🕷️',
    guidance: 'La Araña teje pacientemente su telaraña. Estás creando tu propia '
        'realidad. Teje con intención y cuidado.',
    keywords: ['creación', 'paciencia', 'destino'],
  ),
  OracleCard(
    id: 19,
    name: 'El Cuervo',
    message: 'Mensajes de los reinos invisibles',
    emoji: '🐦‍⬛',
    guidance: 'El Cuervo es mensajero entre mundos. Presta atención a los mensajes '
        'que llegan de formas inesperadas.',
    keywords: ['mensaje', 'magia', 'misterio'],
  ),
  OracleCard(
    id: 20,
    name: 'La Rosa',
    message: 'El amor y la belleza florecen',
    emoji: '🌹',
    guidance: 'La Rosa simboliza el amor en su forma más pura. Abre tu corazón '
        'para dar y recibir amor verdadero.',
    keywords: ['amor', 'belleza', 'apertura'],
  ),
  OracleCard(
    id: 21,
    name: 'El Árbol',
    message: 'Raíces profundas y crecimiento',
    emoji: '🌳',
    guidance: 'El Árbol se mantiene firme en sus raíces mientras crece hacia el cielo. '
        'Equilibra el arraigo con la expansión.',
    keywords: ['arraigo', 'crecimiento', 'equilibrio'],
  ),
  OracleCard(
    id: 22,
    name: 'Las Estrellas',
    message: 'Esperanza y guía divina',
    emoji: '⭐',
    guidance: 'Las Estrellas guían a los perdidos. Incluso en la oscuridad hay luz y '
        'esperanza. Confía en la guía que recibes.',
    keywords: ['esperanza', 'guía', 'orientación'],
  ),
  OracleCard(
    id: 23,
    name: 'El Sol',
    message: 'Llegan alegría y vitalidad',
    emoji: '☀️',
    guidance: 'El Sol brilla con toda su fuerza. Este es un período de alegría, '
        'vitalidad y éxito. ¡Deja brillar tu luz!',
    keywords: ['alegría', 'vitalidad', 'éxito'],
  ),
  OracleCard(
    id: 24,
    name: 'La Tormenta',
    message: 'Después de la tormenta viene la calma',
    emoji: '⛈️',
    guidance: 'Las tormentas pasan y traen renovación. Si estás enfrentando desafíos, '
        'sabe que son temporales.',
    keywords: ['desafío', 'renovación', 'temporal'],
  ),
  OracleCard(
    id: 25,
    name: 'El Arcoíris',
    message: 'Promesa de tiempos mejores',
    emoji: '🌈',
    guidance: 'El Arcoíris es señal de esperanza y promesa. Tiempos mejores '
        'están por llegar. Mantén la fe.',
    keywords: ['esperanza', 'promesa', 'belleza'],
  ),
  OracleCard(
    id: 26,
    name: 'La Llave',
    message: 'Tú tienes la llave de la respuesta',
    emoji: '🔑',
    guidance: 'La Llave que buscas está dentro de ti. Ya conoces la respuesta, '
        'confía en tu sabiduría interior.',
    keywords: ['respuesta', 'sabiduría', 'confianza'],
  ),
  OracleCard(
    id: 27,
    name: 'La Puerta',
    message: 'Se abren nuevas oportunidades',
    emoji: '🚪',
    guidance: 'Una puerta se abre cuando otra se cierra. Nuevas oportunidades '
        'se están presentando. Ten el valor de cruzarlas.',
    keywords: ['oportunidad', 'valentía', 'nuevo camino'],
  ),
  OracleCard(
    id: 28,
    name: 'El Espejo',
    message: 'Mira hacia adentro',
    emoji: '🪞',
    guidance: 'El Espejo refleja la verdad. Es hora de mirarte con honestidad '
        'y reconocer tus propias verdades.',
    keywords: ['autoconocimiento', 'verdad', 'reflexión'],
  ),
  OracleCard(
    id: 29,
    name: 'El Reloj de Arena',
    message: 'El tiempo divino está en acción',
    emoji: '⏳',
    guidance: 'El Reloj de Arena marca el tiempo perfecto. Confía en el tiempo divino. '
        'Todo sucede en el momento justo.',
    keywords: ['tiempo divino', 'paciencia', 'confianza'],
  ),
  OracleCard(
    id: 30,
    name: 'El Ancla',
    message: 'Mantente firme y estable',
    emoji: '⚓',
    guidance: 'El Ancla mantiene el barco firme en la tormenta. Encuentra tu '
        'estabilidad interior y mantente centrado.',
    keywords: ['estabilidad', 'firmeza', 'centro'],
  ),
  OracleCard(
    id: 31,
    name: 'La Mariposa',
    message: 'Una transformación completa está en marcha',
    emoji: '🦋',
    guidance: 'La Mariposa emerge de la crisálida transformada. Estás atravesando '
        'una metamorfosis profunda. Confía en el proceso.',
    keywords: ['metamorfosis', 'transformación', 'belleza'],
  ),
  OracleCard(
    id: 32,
    name: 'La Balanza',
    message: 'Busca equilibrio y justicia',
    emoji: '⚖️',
    guidance: 'La Balanza pesa con precisión. Es hora de buscar equilibrio en tu vida '
        'y actuar con justicia e integridad.',
    keywords: ['equilibrio', 'justicia', 'integridad'],
  ),
  OracleCard(
    id: 33,
    name: 'La Corona',
    message: 'Reconoce tu poder personal',
    emoji: '👑',
    guidance: 'Eres soberano de tu vida. Es hora de reconocer y reclamar '
        'tu poder personal. Eres digno.',
    keywords: ['poder', 'soberanía', 'dignidad'],
  ),
  OracleCard(
    id: 34,
    name: 'El Corazón',
    message: 'Sigue la voz de tu corazón',
    emoji: '❤️',
    guidance: 'El Corazón conoce el camino. Tus emociones e intuiciones son guías '
        'válidas. Confía en lo que dice tu corazón.',
    keywords: ['corazón', 'amor', 'intuición'],
  ),
  OracleCard(
    id: 35,
    name: 'La Rueda',
    message: 'Los ciclos cambian, todo es transitorio',
    emoji: '☸️',
    guidance: 'La Rueda gira eternamente. Todo es cíclico. Si ahora es difícil, '
        'la rueda girará. Si es bueno, disfrútalo.',
    keywords: ['ciclos', 'cambio', 'impermanencia'],
  ),
  OracleCard(
    id: 36,
    name: 'El Camino',
    message: 'Confía en el viaje',
    emoji: '🛤️',
    guidance: 'El Camino se revela paso a paso. No necesitas ver todo el trayecto, '
        'solo el siguiente paso. Sigue caminando.',
    keywords: ['viaje', 'confianza', 'paso a paso'],
  ),
  OracleCard(
    id: 37,
    name: 'La Fuente',
    message: 'La abundancia fluye infinitamente',
    emoji: '⛲',
    guidance: 'La Fuente nunca se seca. El universo es abundante y hay suficiente '
        'para todos. Permítete recibir.',
    keywords: ['abundancia', 'flujo', 'recibir'],
  ),
  OracleCard(
    id: 38,
    name: 'El Laberinto',
    message: 'El camino puede ser sinuoso, pero lleva al centro',
    emoji: '🌀',
    guidance: 'El Laberinto no es una prisión, sino un viaje hacia el centro de ti '
        'mismo. Cada vuelta tiene un propósito.',
    keywords: ['viaje interior', 'propósito', 'paciencia'],
  ),
  OracleCard(
    id: 39,
    name: 'El Puente',
    message: 'Surgen conexiones importantes',
    emoji: '🌉',
    guidance: 'El Puente conecta dos orillas. Estás creando conexiones importantes '
        'o transitando entre etapas de la vida.',
    keywords: ['conexión', 'transición', 'unión'],
  ),
  OracleCard(
    id: 40,
    name: 'La Montaña',
    message: 'Los grandes logros exigen esfuerzo',
    emoji: '⛰️',
    guidance: 'La Montaña es alta, pero la vista desde la cima vale la pena. Sigue '
        'subiendo, paso a paso. Eres capaz.',
    keywords: ['desafío', 'logro', 'perseverancia'],
  ),
  OracleCard(
    id: 41,
    name: 'El Océano',
    message: 'Las profundidades emocionales piden ser exploradas',
    emoji: '🌊',
    guidance: 'El Océano es vasto y profundo. Tus emociones también lo son. Es hora '
        'de sumergirte y explorar lo que hay bajo la superficie.',
    keywords: ['profundidad', 'emoción', 'exploración'],
  ),
  OracleCard(
    id: 42,
    name: 'La Semilla',
    message: 'Un potencial infinito espera germinar',
    emoji: '🌱',
    guidance: 'Dentro de la Semilla está todo el potencial de un árbol. Dentro de ti '
        'está todo el potencial para crear tu vida. Nutre tus semillas.',
    keywords: ['potencial', 'crecimiento', 'inicio'],
  ),
  OracleCard(
    id: 43,
    name: 'La Cosecha',
    message: 'Recibe los frutos de tu trabajo',
    emoji: '🌾',
    guidance: 'La Cosecha es generosa con quien sembró y cuidó. Es hora de recibir '
        'los frutos de tu trabajo y dedicación.',
    keywords: ['cosecha', 'recompensa', 'abundancia'],
  ),
  OracleCard(
    id: 44,
    name: 'El Infinito',
    message: 'Eres eterno e ilimitado',
    emoji: '∞',
    guidance: 'El símbolo del Infinito recuerda que eres más que este cuerpo y '
        'este momento. Eres eterno, infinito e ilimitado.',
    keywords: ['eternidad', 'infinito', 'ilimitado'],
  ),
];
