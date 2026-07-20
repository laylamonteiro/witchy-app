import '../models/enums.dart';

/// Interpretaciones mágicas planeta-signo — contenido en español.
///
/// Las CLAVES del mapa (`'<planeta>_<signo>'`, derivadas de `Planet.name` y
/// `ZodiacSign.name`) son invariantes entre idiomas; solo se traducen los
/// VALORES de texto. Mantén las mismas claves en los tres archivos
/// (`planet_sign_interpretations_pt/en/es.dart`) — la paridad se verifica en
/// `test/astrology_interpretations_parity_test.dart`.
const Map<String, String> planetSignInterpretationsEs = {
  // SOL en cada signo
  'sun_aries':
      'Con el Sol en Aries, tu esencia mágica es de FUEGO INICIADOR. Eres una bruja '
          'guerrera, que no teme comenzar nuevos proyectos mágicos. Tu magia es más '
          'fuerte cuando actúas con coraje y determinación. Rituales de protección, '
          'fuerza de voluntad y nuevos comienzos son tus puntos fuertes. Trabaja con '
          'velas rojas y naranjas, y realiza tus hechizos justo al inicio de las '
          'lunaciones.',
  'sun_taurus':
      'Con el Sol en Tauro, tu esencia mágica es TERRENAL y SENSUAL. Eres una bruja '
          'verde, conectada profundamente con la naturaleza y los ciclos de la tierra. '
          'Tu magia se manifiesta mejor a través de los sentidos - aromas, texturas, '
          'sabores. Rituales de prosperidad, amor y abundancia material son naturales '
          'para ti. Cristales, hierbas y jardinería mágica son tus aliados.',
  'sun_gemini':
      'Con el Sol en Géminis, tu esencia mágica es MENTAL y COMUNICATIVA. Eres una '
          'bruja de las palabras, maestra en encantamientos verbales y sigilos. Tu '
          'curiosidad te lleva a explorar diversas tradiciones mágicas. Tarot, runas y '
          'cualquier forma de adivinación son naturales para ti. Usa inciensos y '
          'trabaja con el elemento Aire para potenciar tu magia.',
  'sun_cancer':
      'Con el Sol en Cáncer, tu esencia mágica es LUNAR e INTUITIVA. Eres una bruja '
          'del hogar, protectora natural de la familia y del espacio sagrado. Tu magia '
          'fluye con los ciclos de la Luna. Rituales de protección doméstica, sanación '
          'emocional y trabajo con ancestros son tus dones. Baños rituales y pociones '
          'son especialmente poderosos en tus manos.',
  'sun_leo':
      'Con el Sol en Leo, tu esencia mágica es SOLAR y RADIANTE. Eres una bruja '
          'escénica, que brilla en rituales de grupo. Tu presencia energiza cualquier '
          'círculo mágico. Magia de glamur, éxito y autoconfianza son naturales para '
          'ti. Trabaja con oro, velas doradas y rituales al mediodía. Lidera rituales '
          'con corazón generoso.',
  'sun_virgo':
      'Con el Sol en Virgo, tu esencia mágica es PRÁCTICA y SANADORA. Eres una bruja '
          'herbolaria, maestra en preparar remedios y pociones con precisión. Tu '
          'atención a los detalles hace tus rituales impecables. Magia de sanación, '
          'purificación y organización son tus puntos fuertes. Mantén un grimorio '
          'detallado y un altar perfectamente organizado.',
  'sun_libra':
      'Con el Sol en Libra, tu esencia mágica es ARMÓNICA y RELACIONAL. Eres una '
          'bruja diplomática, capaz de equilibrar energías y armonizar ambientes. '
          'Magia de amor, alianzas y justicia son naturales para ti. Tus altares son '
          'estéticamente bellos. Trabaja en parejas o grupos para potenciar tu magia. '
          'Los rituales de equilibrio energético son tu especialidad.',
  'sun_scorpio':
      'Con el Sol en Escorpio, tu esencia mágica es TRANSFORMADORA y PROFUNDA. Eres '
          'una bruja de lo oculto, sin miedo a explorar los misterios más profundos. '
          'Tu magia es intensa y poderosa. Transformación, destierros y trabajo de '
          'sombra son naturales para ti. Rituales de muerte y renacimiento simbólico '
          'te fortalecen. Plutón es tu aliado en las transmutaciones.',
  'sun_sagittarius':
      'Con el Sol en Sagitario, tu esencia mágica es EXPANSIVA y FILOSÓFICA. Eres '
          'una bruja aventurera, buscadora de verdades en diversas tradiciones. Tu '
          'magia se fortalece cuando estudias y viajas (física o espiritualmente). '
          'Rituales de suerte, expansión y viaje astral son naturales. Júpiter '
          'bendice tu camino espiritual.',
  'sun_capricorn':
      'Con el Sol en Capricornio, tu esencia mágica es DISCIPLINADA y TRADICIONAL. '
          'Eres una bruja ancestral, conectada con prácticas antiguas y tradiciones '
          'familiares. Tu magia se fortalece con consistencia y estructura. Rituales '
          'de carrera, manifestación a largo plazo y protección son tus puntos '
          'fuertes. Saturno enseña paciencia en tu práctica.',
  'sun_aquarius':
      'Con el Sol en Acuario, tu esencia mágica es INNOVADORA y COLECTIVA. Eres una '
          'bruja futurista, que trae nuevas ideas a prácticas antiguas. Tu magia es '
          'más fuerte en grupo y para causas humanitarias. Rituales de libertad, '
          'amistad y cambio social son naturales. Urano te inspira a romper '
          'paradigmas en la brujería.',
  'sun_pisces':
      'Con el Sol en Piscis, tu esencia mágica es MÍSTICA y COMPASIVA. Eres una '
          'bruja vidente, naturalmente conectada con el mundo espiritual. Tu magia '
          'fluye a través de sueños, visiones e intuición pura. Mediumnidad, '
          'canalización y sanación empática son tus dones naturales. Neptuno te guía '
          'en los viajes espirituales.',

  // LUNA en cada signo
  'moon_aries':
      'Con la Luna en Aries, tus emociones son INTENSAS e IMPULSIVAS. Procesas los '
          'sentimientos a través de la acción. Tu intuición mágica es rápida e '
          'instintiva. Los rituales espontáneos funcionan bien para ti. Cuando estés '
          'emocionalmente cargada, canalízalo en magia de protección o ejercicio '
          'físico ritual. La Luna en Aries potencia hechizos de coraje.',
  'moon_taurus':
      'Con la Luna en Tauro, tus emociones son ESTABLES y SENSUALES. Encuentras '
          'consuelo emocional a través de los sentidos - comida, naturaleza, tacto. '
          'Tu intuición habla a través del cuerpo. Rituales con elementos físicos '
          '(cristales, hierbas, aceites) son especialmente eficaces. Necesitas '
          'seguridad emocional para que tu magia fluya.',
  'moon_gemini':
      'Con la Luna en Géminis, tus emociones son VERSÁTILES y COMUNICATIVAS. '
          'Procesas los sentimientos hablando o escribiendo sobre ellos. Tu intuición '
          'llega a través de palabras, mensajes y sincronicidades. El journaling '
          'mágico y la escritura automática son herramientas poderosas. La Luna en '
          'Géminis potencia la adivinación.',
  'moon_cancer':
      'Con la Luna en Cáncer, estás EN CASA. Esta es la posición más poderosa de la '
          'Luna. Tus emociones son profundas, tu intuición es fuerte, y tu conexión '
          'con los ciclos lunares es natural. Sientes las fases de la Luna en el '
          'cuerpo. Toda magia lunar se amplifica para ti. El trabajo con ancestros y '
          'la protección familiar son dones naturales.',
  'moon_leo':
      'Con la Luna en Leo, tus emociones son DRAMÁTICAS y GENEROSAS. Necesitas '
          'sentirte especial y reconocida para estar bien. Tu intuición brilla cuando '
          'estás en el escenario o liderando. Los rituales teatrales y expresivos '
          'funcionan bien. La Luna en Leo potencia la magia de autoestima y expresión '
          'creativa.',
  'moon_virgo':
      'Con la Luna en Virgo, tus emociones son ANALÍTICAS y buscan ORDEN. Procesas '
          'los sentimientos intentando entenderlos lógicamente. Tu intuición habla a '
          'través de detalles y patrones. Los rituales meticulosos y organizados te '
          'calman. La Luna en Virgo potencia la magia de sanación y purificación.',
  'moon_libra':
      'Con la Luna en Libra, tus emociones buscan ARMONÍA y BELLEZA. Necesitas paz '
          'y relaciones equilibradas para estar bien. Tu intuición habla a través de '
          'la estética y el sentido de justicia. Los rituales elegantes y '
          'equilibrados funcionan mejor. La Luna en Libra potencia la magia de las '
          'relaciones.',
  'moon_scorpio':
      'Con la Luna en Escorpio, tus emociones son INTENSAS y TRANSFORMADORAS. '
          'Sientes todo profundamente y no temes la oscuridad emocional. Tu '
          'intuición psíquica es poderosa. Los rituales de transformación y el '
          'trabajo de sombra son naturales. La Luna en Escorpio amplifica la magia '
          'oculta y de destierro.',
  'moon_sagittarius':
      'Con la Luna en Sagitario, tus emociones buscan LIBERTAD y SIGNIFICADO. '
          'Necesitas espacio emocional y propósito. Tu intuición habla a través de '
          'visiones e insights filosóficos. Los rituales al aire libre y los viajes '
          'espirituales te nutren. La Luna en Sagitario potencia la magia de '
          'expansión.',
  'moon_capricorn':
      'Con la Luna en Capricornio, tus emociones son CONTENIDAS y PRÁCTICAS. '
          'Procesas los sentimientos a través del trabajo y la estructura. Tu '
          'intuición habla a través de la tradición y la experiencia. Los rituales '
          'estructurados y tradicionales funcionan mejor. La Luna en Capricornio '
          'potencia la magia de manifestación material.',
  'moon_aquarius':
      'Con la Luna en Acuario, tus emociones son DESAPEGADAS y HUMANITARIAS. '
          'Procesas los sentimientos de forma intelectual. Tu intuición llega como '
          'descargas repentinas e insights. Los rituales de grupo y para causas '
          'colectivas te nutren. La Luna en Acuario potencia la magia de innovación.',
  'moon_pisces':
      'Con la Luna en Piscis, tus emociones son OCEÁNICAS y sin fronteras. Absorbes '
          'los sentimientos a tu alrededor como una esponja. Tu intuición psíquica es '
          'fortísima. Los rituales con agua, los sueños lúcidos y la meditación '
          'profunda son naturales. La Luna en Piscis amplifica toda magia intuitiva y '
          'espiritual.',

  // MERCURIO en cada signo
  'mercury_aries':
      'Con Mercurio en Aries, tu mente es RÁPIDA y DIRECTA. Piensas y hablas con '
          'velocidad y asertividad. Los encantamientos cortos y directos funcionan '
          'mejor que los rituales largos. Tu comunicación mágica es valiente. Los '
          'sigilos de acción rápida son tu especialidad.',
  'mercury_taurus':
      'Con Mercurio en Tauro, tu mente es PRÁCTICA y DELIBERADA. Piensas despacio '
          'pero con profundidad. Prefieres memorizar encantamientos a improvisar. Tu '
          'comunicación mágica tiene peso y sustancia. Los cantos y mantras '
          'repetitivos son especialmente poderosos.',
  'mercury_gemini':
      'Con Mercurio en Géminis, tu mente es BRILLANTE y VERSÁTIL. Esta es la '
          'posición más fuerte de Mercurio. Eres maestra de las palabras mágicas. '
          'Sigilos, encantamientos y toda magia verbal se amplifican. El tarot y los '
          'oráculos hablan claramente contigo.',
  'mercury_cancer':
      'Con Mercurio en Cáncer, tu mente es INTUITIVA y EMOCIONAL. Piensas con el '
          'corazón. Tu comunicación mágica carga emoción profunda. Los encantamientos '
          'pronunciados con sentimiento son especialmente poderosos. Recibes mensajes '
          'a través de recuerdos y sueños.',
  'mercury_leo':
      'Con Mercurio en Leo, tu mente es CREATIVA y DRAMÁTICA. Te expresas con '
          'estilo y confianza. Los encantamientos proclamados en voz alta son '
          'especialmente poderosos. Tu comunicación mágica inspira a otros. Eres '
          'excelente liderando invocaciones de grupo.',
  'mercury_virgo':
      'Con Mercurio en Virgo, tu mente es ANALÍTICA y PRECISA. Esta es otra '
          'posición fuerte de Mercurio. Eres meticulosa con las palabras y las '
          'correspondencias. Tus registros mágicos son impecables. Los encantamientos '
          'detallados y precisos son tu especialidad.',
  'mercury_libra':
      'Con Mercurio en Libra, tu mente busca EQUILIBRIO y DIPLOMACIA. Consideras '
          'todos los lados antes de decidir. Tu comunicación mágica es elegante y '
          'armoniosa. Los encantamientos de alianza y justicia son naturales. Eres '
          'excelente en la mediación espiritual.',
  'mercury_scorpio':
      'Con Mercurio en Escorpio, tu mente es PENETRANTE e INVESTIGADORA. Vas a '
          'fondo en cualquier tema. Tu comunicación mágica es intensa y '
          'transformadora. Las palabras de poder y las invocaciones secretas son tu '
          'especialidad. Descubres conocimiento oculto con facilidad.',
  'mercury_sagittarius':
      'Con Mercurio en Sagitario, tu mente es EXPANSIVA y FILOSÓFICA. Piensas en '
          'términos amplios y universales. Tu comunicación mágica es inspiradora y '
          'optimista. Estudiar diversas tradiciones enriquece tu práctica. Los '
          'encantamientos de expansión son poderosos.',
  'mercury_capricorn':
      'Con Mercurio en Capricornio, tu mente es ESTRUCTURADA y SERIA. Piensas a '
          'largo plazo y con practicidad. Tu comunicación mágica es tradicional y '
          'respetuosa. Los encantamientos formales y tradicionales funcionan mejor. '
          'Aprendes bien con mentores.',
  'mercury_aquarius':
      'Con Mercurio en Acuario, tu mente es ORIGINAL y VISIONARIA. Piensas fuera de '
          'la caja y lo cuestionas todo. Tu comunicación mágica es innovadora. Creas '
          'nuevos encantamientos y sistemas. Las descargas intuitivas repentinas son '
          'comunes para ti.',
  'mercury_pisces':
      'Con Mercurio en Piscis, tu mente es INTUITIVA e IMAGINATIVA. Piensas en '
          'símbolos e imágenes. Tu comunicación mágica es poética y fluida. La '
          'escritura automática y la canalización son naturales. Recibes mensajes a '
          'través de sueños y visiones.',

  // VENUS en cada signo
  'venus_aries':
      'Con Venus en Aries, AMAS con PASIÓN e INTENSIDAD. La magia de amor para ti '
          'debe ser directa y valiente. Atraes a través de la energía y la '
          'iniciativa. Los rituales de amor propio y confianza son especialmente '
          'poderosos. Los hechizos de pasión y atracción funcionan rápidamente.',
  'venus_taurus':
      'Con Venus en Tauro, AMAS con los SENTIDOS. Esta es la posición más fuerte de '
          'Venus. Atraes a través de la belleza y el placer sensorial. La magia de '
          'amor con aceites, perfumes y comida es especialmente eficaz. Los rituales '
          'de prosperidad amorosa son naturales.',
  'venus_gemini':
      'Con Venus en Géminis, AMAS a través de la COMUNICACIÓN. La conexión mental '
          'es esencial para ti. La magia de amor incluye palabras, cartas y '
          'conversaciones. Atraes a través del intelecto y el humor. Los hechizos con '
          'sigilos de amor son especialmente eficaces.',
  'venus_cancer':
      'Con Venus en Cáncer, AMAS con CUIDADO y PROTECCIÓN. La seguridad emocional '
          'es esencial. La magia de amor enfocada en la familia y el hogar es '
          'poderosa. Atraes a través del cariño y la nutrición. Los rituales de amor '
          'durante la Luna Llena se amplifican.',
  'venus_leo':
      'Con Venus en Leo, AMAS con DRAMA y GENEROSIDAD. El romance grandioso te '
          'atrae. La magia de amor debe ser especial y teatral. Atraes a través del '
          'brillo y la confianza. Los rituales de glamur amoroso son tu especialidad.',
  'venus_virgo':
      'Con Venus en Virgo, AMAS a través del SERVICIO. Los actos de cuidado son tu '
          'lenguaje del amor. La magia de amor práctica y útil funciona mejor. '
          'Atraes a través de la competencia y la atención a los detalles. Prepara '
          'pociones de amor con cuidado.',
  'venus_libra':
      'Con Venus en Libra, AMAS con ARMONÍA y ELEGANCIA. Esta es otra posición '
          'fuerte de Venus. Las alianzas equilibradas son esenciales. La magia de '
          'amor estética y romántica es poderosa. Atraes a través de la gracia y la '
          'diplomacia. Los rituales de matrimonio son tu especialidad.',
  'venus_scorpio':
      'Con Venus en Escorpio, AMAS con INTENSIDAD TOTAL. Las conexiones profundas y '
          'transformadoras te atraen. La magia de amor es intensa y poderosa para '
          'ti. Atraes a través del magnetismo y el misterio. Los rituales de amor '
          'que implican compromiso profundo son eficaces.',
  'venus_sagittarius':
      'Con Venus en Sagitario, AMAS con LIBERTAD. Las conexiones que expanden tu '
          'mundo te atraen. La magia de amor debe incluir aventura y crecimiento. '
          'Atraes a través del optimismo y el humor. Los rituales de amor al aire '
          'libre son poderosos.',
  'venus_capricorn':
      'Con Venus en Capricornio, AMAS con COMPROMISO. Las relaciones serias y '
          'duraderas te atraen. La magia de amor debe ser práctica y construir para '
          'el futuro. Atraes a través de la estabilidad. Los rituales de amor con '
          'estructura y tradición funcionan.',
  'venus_aquarius':
      'Con Venus en Acuario, AMAS con LIBERTAD y AMISTAD. Las conexiones únicas y '
          'no convencionales te atraen. La magia de amor debe respetar la '
          'individualidad. Atraes a través de la originalidad. Los rituales de amor '
          'en grupo o para la amistad son poderosos.',
  'venus_pisces':
      'Con Venus en Piscis, AMAS con DEVOCIÓN TOTAL. Esta es la posición más '
          'romántica de Venus. Las conexiones espirituales te atraen. La magia de '
          'amor es trascendente para ti. Atraes a través de la compasión. Los '
          'rituales de amor con agua y música son especialmente eficaces.',

  // MARTE en cada signo
  'mars_aries':
      'Con Marte en Aries, tu ENERGÍA es EXPLOSIVA y DIRECTA. Esta es la posición '
          'más fuerte de Marte. Actúas con coraje e iniciativa. La magia de '
          'protección y destierro es especialmente poderosa. Los rituales de acción '
          'rápida son eficaces. Usa esta energía para comenzar proyectos mágicos.',
  'mars_taurus':
      'Con Marte en Tauro, tu ENERGÍA es PERSISTENTE y DETERMINADA. Actúas despacio '
          'pero con fuerza imparable. La magia de manifestación material es poderosa. '
          'Los rituales que exigen paciencia funcionan bien. Usa esta energía para '
          'protección duradera.',
  'mars_gemini':
      'Con Marte en Géminis, tu ENERGÍA es VERSÁTIL y MENTAL. Actúas a través de '
          'palabras e ideas. La magia verbal y de comunicación es poderosa. Los '
          'debates y discusiones te energizan. Usa esta energía para sigilos activos.',
  'mars_cancer':
      'Con Marte en Cáncer, tu ENERGÍA es PROTECTORA y EMOCIONAL. Actúas para '
          'defender a quienes amas. La magia de protección familiar es especialmente '
          'poderosa. Los rituales emocionalmente cargados son eficaces. Usa esta '
          'energía para proteger el hogar.',
  'mars_leo':
      'Con Marte en Leo, tu ENERGÍA es DRAMÁTICA y CREATIVA. Actúas con estilo y '
          'confianza. La magia de autoexpresión y coraje es poderosa. Los rituales '
          'teatrales son eficaces. Usa esta energía para rituales de liderazgo.',
  'mars_virgo':
      'Con Marte en Virgo, tu ENERGÍA es PRECISA y EFICIENTE. Actúas de forma '
          'metódica y detallista. La magia de sanación y purificación es poderosa. '
          'Los rituales bien planificados son más eficaces. Usa esta energía para '
          'trabajos precisos.',
  'mars_libra':
      'Con Marte en Libra, tu ENERGÍA busca JUSTICIA y EQUILIBRIO. Actúas en nombre '
          'de la armonía. La magia de justicia y equilibrio es poderosa. Los rituales '
          'de alianza son eficaces. Usa esta energía para resolver conflictos '
          'mágicamente.',
  'mars_scorpio':
      'Con Marte en Escorpio, tu ENERGÍA es INTENSA y TRANSFORMADORA. Esta es una '
          'posición muy fuerte de Marte. Actúas con determinación implacable. La '
          'magia de transformación y destierro es extremadamente poderosa. Usa esta '
          'energía para cambios profundos.',
  'mars_sagittarius':
      'Con Marte en Sagitario, tu ENERGÍA es AVENTURERA y EXPANSIVA. Actúas con '
          'optimismo y entusiasmo. La magia de expansión y viaje es poderosa. Los '
          'rituales al aire libre son eficaces. Usa esta energía para el crecimiento '
          'espiritual activo.',
  'mars_capricorn':
      'Con Marte en Capricornio, tu ENERGÍA es DISCIPLINADA y AMBICIOSA. Esta es '
          'una posición muy fuerte de Marte. Actúas con estrategia y paciencia. La '
          'magia de carrera y manifestación material es poderosa. Los rituales '
          'estructurados son eficaces.',
  'mars_aquarius':
      'Con Marte en Acuario, tu ENERGÍA es REVOLUCIONARIA e INDEPENDIENTE. Actúas '
          'de formas no convencionales. La magia de grupo y para causas sociales es '
          'poderosa. Los rituales innovadores son eficaces. Usa esta energía para el '
          'cambio colectivo.',
  'mars_pisces':
      'Con Marte en Piscis, tu ENERGÍA es FLUIDA e INTUITIVA. Actúas guiada por la '
          'intuición y la compasión. La magia espiritual y sanadora es poderosa. Los '
          'rituales meditativos son eficaces. Usa esta energía para el trabajo '
          'espiritual activo.',
};

// Nombres localizados — los getters de los enums (`displayName`,
// `magicalDescription`) devuelven texto en portugués, así que las funciones de
// plantilla en español resuelven los nombres desde estos mapas indexados por
// los valores invariantes de los enums.
const Map<Planet, String> _planetNamesEs = {
  Planet.sun: 'Sol',
  Planet.moon: 'Luna',
  Planet.mercury: 'Mercurio',
  Planet.venus: 'Venus',
  Planet.mars: 'Marte',
  Planet.jupiter: 'Júpiter',
  Planet.saturn: 'Saturno',
  Planet.uranus: 'Urano',
  Planet.neptune: 'Neptuno',
  Planet.pluto: 'Plutón',
  Planet.northNode: 'Nodo Norte',
  Planet.southNode: 'Nodo Sur',
};

const Map<ZodiacSign, String> _signNamesEs = {
  ZodiacSign.aries: 'Aries',
  ZodiacSign.taurus: 'Tauro',
  ZodiacSign.gemini: 'Géminis',
  ZodiacSign.cancer: 'Cáncer',
  ZodiacSign.leo: 'Leo',
  ZodiacSign.virgo: 'Virgo',
  ZodiacSign.libra: 'Libra',
  ZodiacSign.scorpio: 'Escorpio',
  ZodiacSign.sagittarius: 'Sagitario',
  ZodiacSign.capricorn: 'Capricornio',
  ZodiacSign.aquarius: 'Acuario',
  ZodiacSign.pisces: 'Piscis',
};

const Map<ZodiacSign, String> _signQualitiesEs = {
  ZodiacSign.aries: 'valientes y emprendedoras',
  ZodiacSign.taurus: 'estables y sensuales',
  ZodiacSign.gemini: 'curiosas y comunicativas',
  ZodiacSign.cancer: 'intuitivas y nutricias',
  ZodiacSign.leo: 'expresivas y dramáticas',
  ZodiacSign.virgo: 'analíticas y prácticas',
  ZodiacSign.libra: 'armoniosas y diplomáticas',
  ZodiacSign.scorpio: 'profundas y transformadoras',
  ZodiacSign.sagittarius: 'expansivas y filosóficas',
  ZodiacSign.capricorn: 'disciplinadas y estructuradas',
  ZodiacSign.aquarius: 'innovadoras y humanitarias',
  ZodiacSign.pisces: 'místicas y compasivas',
};

const Map<Element, String> _elementNamesEs = {
  Element.fire: 'Fuego',
  Element.earth: 'Tierra',
  Element.air: 'Aire',
  Element.water: 'Agua',
};

/// Interpretación por defecto cuando no existe una específica en el mapa.
String planetSignDefaultInterpretationEs(Planet planet, ZodiacSign sign) {
  return 'Tu ${_planetNamesEs[planet]} en ${_signNamesEs[sign]} combina la '
      'energía ${_planetEnergyEs(planet)} con las cualidades '
      '${_signQualitiesEs[sign]} de este signo de '
      '${_elementNamesEs[sign.element]}.';
}

String _planetEnergyEs(Planet planet) {
  switch (planet) {
    case Planet.sun:
      return 'de tu esencia vital';
    case Planet.moon:
      return 'de tus emociones e intuición';
    case Planet.mercury:
      return 'de tu comunicación y mente';
    case Planet.venus:
      return 'del amor y la belleza';
    case Planet.mars:
      return 'de la acción y la protección';
    case Planet.jupiter:
      return 'de la expansión y la suerte';
    case Planet.saturn:
      return 'de la disciplina y la estructura';
    case Planet.uranus:
      return 'de la innovación y la libertad';
    case Planet.neptune:
      return 'de la espiritualidad y los sueños';
    case Planet.pluto:
      return 'de la transformación profunda';
    case Planet.northNode:
      return 'de tu destino kármico';
    case Planet.southNode:
      return 'de tus vidas pasadas';
  }
}

/// Resumen corto para mostrar en listas.
String planetSignShortInterpretationEs(Planet planet, ZodiacSign sign) {
  switch (planet) {
    case Planet.sun:
      return 'Tu esencia mágica es ${_signQualitiesEs[sign]}';
    case Planet.moon:
      return 'Tus emociones e intuición son ${_signQualitiesEs[sign]}';
    case Planet.mercury:
      return 'Tu mente y comunicación son ${_signQualitiesEs[sign]}';
    case Planet.venus:
      return 'Tu amor y belleza son ${_signQualitiesEs[sign]}';
    case Planet.mars:
      return 'Tu energía y acción son ${_signQualitiesEs[sign]}';
    case Planet.jupiter:
      return 'Tu suerte y expansión son ${_signQualitiesEs[sign]}';
    case Planet.saturn:
      return 'Tu disciplina y estructura son ${_signQualitiesEs[sign]}';
    case Planet.uranus:
      return 'Tu innovación es ${_signQualitiesEs[sign]}';
    case Planet.neptune:
      return 'Tu espiritualidad es ${_signQualitiesEs[sign]}';
    case Planet.pluto:
      return 'Tu transformación es ${_signQualitiesEs[sign]}';
    default:
      return '${_planetNamesEs[planet]} en ${_signNamesEs[sign]}';
  }
}
