import '../models/enums.dart';
import 'magical_interpreter_texts.dart';

/// Textos del intérprete mágico — contenido en español.
///
/// Mantén las mismas claves/estructuras en los tres archivos
/// (`magical_interpreter_texts_pt/en/es.dart`) — la paridad se verifica en
/// `test/astrology_interpreters_parity_test.dart`.
final MagicalInterpreterTexts magicalInterpreterTextsEs =
    MagicalInterpreterTexts(
  sunEssence: const {
    ZodiacSign.aries:
        'Tu esencia mágica es de pionerismo y coraje. Eres una bruja guerrera, '
            'que actúa con rapidez y decisión. Tus hechizos más poderosos implican iniciar nuevos '
            'ciclos y romper barreras. Usa el fuego como tu elemento principal.',
    ZodiacSign.taurus:
        'Tu esencia mágica está enraizada en la tierra y en la manifestación. Eres una bruja '
            'que trae el mundo espiritual al plano físico. Tus hechizos más poderosos implican '
            'prosperidad, sensualidad y belleza. Trabaja con cristales y hierbas.',
    ZodiacSign.gemini:
        'Tu esencia mágica fluye a través de la comunicación y el conocimiento. Eres una '
            'bruja estudiosa, que domina la magia mediante palabras y símbolos. Tus hechizos más '
            'poderosos implican comunicación, aprendizaje y versatilidad.',
    ZodiacSign.cancer:
        'Tu esencia mágica fluye con las mareas lunares. Eres una bruja intuitiva, '
            'profundamente conectada con las emociones. Tus hechizos más poderosos implican protección '
            'del hogar, sanación emocional y magia lunar.',
    ZodiacSign.leo:
        'Tu esencia mágica brilla como el Sol. Eres una bruja radiante, segura y '
            'creativa. Tus hechizos más poderosos implican autoexpresión, creatividad y '
            'liderazgo. Usa rituales solares.',
    ZodiacSign.virgo:
        'Tu esencia mágica está en la precisión y el servicio. Eres una bruja meticulosa, '
            'que domina los detalles de cada ritual. Tus hechizos más poderosos implican sanación, '
            'purificación y magia herbal.',
    ZodiacSign.libra:
        'Tu esencia mágica busca el equilibrio y la armonía. Eres una bruja diplomática, '
            'que trabaja con energías de belleza y justicia. Tus hechizos más poderosos implican '
            'relaciones, armonía y estética.',
    ZodiacSign.scorpio:
        'Tu esencia mágica se sumerge en las profundidades. Eres una bruja transformadora, '
            'que no teme a las sombras. Tus hechizos más poderosos implican transformación profunda, '
            'magia sexual y renacimiento.',
    ZodiacSign.sagittarius:
        'Tu esencia mágica busca la sabiduría y la expansión. Eres una bruja filósofa, '
            'que explora diferentes tradiciones. Tus hechizos más poderosos implican crecimiento '
            'espiritual, protección en los viajes y abundancia.',
    ZodiacSign.capricorn:
        'Tu esencia mágica es estructurada y ambiciosa. Eres una bruja disciplinada, '
            'que construye poder a lo largo del tiempo. Tus hechizos más poderosos implican manifestación '
            'material, carrera y magia saturnina.',
    ZodiacSign.aquarius:
        'Tu esencia mágica es innovadora y única. Eres una bruja revolucionaria, que '
            'rompe tradiciones y crea nuevos caminos. Tus hechizos más poderosos implican cambio '
            'social, intuición y magia tecnológica.',
    ZodiacSign.pisces:
        'Tu esencia mágica disuelve fronteras. Eres una bruja mística, profundamente '
            'conectada con el inconsciente colectivo. Tus hechizos más poderosos implican sueños, '
            'mediumnidad y compasión universal.',
  },
  moonIntro: (signName, houseNumber) =>
      'Tu Luna en $signName en la Casa $houseNumber ',
  moonBySign: const {
    ZodiacSign.aries:
        'trae intuiciones rápidas e instintivas. Confía en tus primeros impulsos.',
    ZodiacSign.taurus:
        'ofrece intuición a través de los sentidos. Trabaja con aromas, texturas y sabores.',
    ZodiacSign.cancer:
        'amplifica tu sensibilidad psíquica. Eres naturalmente empática y receptiva.',
    ZodiacSign.scorpio:
        'se sumerge en las profundidades emocionales. Tienes dones psíquicos poderosos.',
    ZodiacSign.pisces:
        'disuelve las fronteras entre mundos. Puedes tener sueños proféticos.',
  },
  moonByElement: (elementName) =>
      'ofrece intuición en sintonía con $elementName. '
      'Trabaja con ese elemento para fortalecer tu conexión.',
  mercuryByElement: const {
    Element.fire:
        'Tu comunicación mágica es directa e inspiradora. Usa afirmaciones poderosas '
            'y encantamientos pronunciados en voz alta.',
    Element.earth:
        'Tu comunicación mágica es práctica y fundamentada. Escribe tus hechizos y '
            'trabaja con grimorios físicos.',
    Element.air:
        'Tu comunicación mágica es versátil y clara. Eres excelente en la lectura de runas, '
            'tarot y otros sistemas adivinatorios basados en símbolos.',
    Element.water:
        'Tu comunicación mágica es intuitiva y emocional. Trabaja con poesía, música y '
            'expresión creativa en tus rituales.',
  },
  venus: (signName, elementName) =>
      'Tu Venus en $signName indica que atraes belleza y placer a través '
      'de $elementName. Incorpora ese elemento en hechizos de amor y autocuidado.',
  mars: (signName, elementName) =>
      'Tu Marte en $signName muestra que tu energía protectora se manifiesta a través '
      'de $elementName. Usa ese elemento en hechizos de protección y destierro.',
  house8Intro: (signName) =>
      'Tu Casa 8 (magia y ocultismo) está en $signName. ',
  house8NoPlanets:
      'Aunque no haya planetas aquí, aún puedes desarrollar tus habilidades '
      'mágicas a través de la práctica consciente.',
  house8WithPlanets: (count, planetNames) =>
      'Con $count planeta(s) aquí, tienes una fuerte afinidad natural '
      'con la magia: $planetNames. ',
  house8Moon: 'La Luna aquí intensifica tu intuición mágica. ',
  house8Pluto: 'Plutón aquí indica poderes transformadores profundos. ',
  house12Intro: (signName) =>
      'Tu Casa 12 (espiritualidad) está en $signName. ',
  house12NoPlanets:
      'Desarrolla tu conexión espiritual a través de la meditación y los sueños.',
  house12WithPlanets: (count, planetNames) =>
      'Con $count planeta(s) aquí, tienes una fuerte conexión con lo divino: '
      '$planetNames. ',
  house12Neptune:
      'Neptuno aquí amplifica tu mediumnidad y tu conexión mística. ',
  house12Moon: 'La Luna aquí trae sueños proféticos y una fuerte intuición. ',
  strengthPsychicIntuition: 'Intuición psíquica natural',
  strengthSunMoonBalance: 'Equilibrio entre acción e intuición',
  strengthMagicAffinity: 'Afinidad natural con la magia',
  strengthSpiritualConnection: 'Conexión espiritual profunda',
  strengthDominantElement: (elementName) =>
      'Dominio del elemento $elementName',
  practicesByElement: const {
    Element.fire: [
      'Magia de velas',
      'Rituales bajo el sol',
      'Trabajo con fuego sagrado',
      'Hechizos de acción rápida',
    ],
    Element.earth: [
      'Brujería verde (hierbas y plantas)',
      'Magia de cristales',
      'Rituales de manifestación',
      'Trabajo con altar permanente',
    ],
    Element.air: [
      'Magia de palabras y encantamientos',
      'Lectura de runas y tarot',
      'Trabajo con inciensos',
      'Comunicación con espíritus',
    ],
    Element.water: [
      'Magia lunar',
      'Baños rituales',
      'Trabajo con sueños',
      'Adivinación con agua',
    ],
  },
  practicesHouse8: const [
    'Magia sexual y transformación profunda',
    'Trabajo de sombras',
  ],
  practicesHouse12: const [
    'Meditación y viajes astrales',
    'Trabajo con el inconsciente',
  ],
  toolsByElement: const {
    Element.fire: ['Citrino', 'Cornalina', 'Rubí', 'Velas rojas/naranjas'],
    Element.earth: [
      'Cuarzo Verde',
      'Turmalina Negra',
      'Sal gruesa',
      'Hierbas',
    ],
    Element.air: ['Cuarzo Transparente', 'Amatista', 'Inciensos', 'Plumas'],
    Element.water: ['Piedra Luna', 'Agua lunar', 'Conchas', 'Espejo'],
  },
  sunCrystal: (signName) => 'Cristal de $signName',
  moonHerb: (signName) => 'Hierba de $signName',
  shadowSunMoon: 'Integrar el ego consciente con las necesidades emocionales',
  shadowSaturn: 'Trabajar con limitaciones y estructuras rígidas',
  shadowHouse12:
      'Explorar aspectos ocultos de la personalidad a través de la meditación',
);
