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
          'lunaciones',
  'sun_taurus':
      'Con el Sol en Tauro, tu esencia mágica es TERRENAL y SENSUAL. Eres una bruja '
          'verde, conectada profundamente con la naturaleza y los ciclos de la tierra. '
          'Tu magia se manifiesta mejor a través de los sentidos - aromas, texturas, '
          'sabores. Rituales de prosperidad, amor y abundancia material son naturales '
          'para ti. Cristales, hierbas y jardinería mágica son tus aliados',
  'sun_gemini':
      'Con el Sol en Géminis, tu esencia mágica es MENTAL y COMUNICATIVA. Eres una '
          'bruja de las palabras, maestra en encantamientos verbales y sigilos. Tu '
          'curiosidad te lleva a explorar diversas tradiciones mágicas. Tarot, runas y '
          'cualquier forma de adivinación son naturales para ti. Usa inciensos y '
          'trabaja con el elemento Aire para potenciar tu magia',
  'sun_cancer':
      'Con el Sol en Cáncer, tu esencia mágica es LUNAR e INTUITIVA. Eres una bruja '
          'del hogar, protectora natural de la familia y del espacio sagrado. Tu magia '
          'fluye con los ciclos de la Luna. Rituales de protección doméstica, sanación '
          'emocional y trabajo con ancestros son tus dones. Baños rituales y pociones '
          'son especialmente poderosos en tus manos',
  'sun_leo':
      'Con el Sol en Leo, tu esencia mágica es SOLAR y RADIANTE. Eres una bruja '
          'escénica, que brilla en rituales de grupo. Tu presencia energiza cualquier '
          'círculo mágico. Magia de glamur, éxito y autoconfianza son naturales para '
          'ti. Trabaja con oro, velas doradas y rituales al mediodía. Lidera rituales '
          'con corazón generoso',
  'sun_virgo':
      'Con el Sol en Virgo, tu esencia mágica es PRÁCTICA y SANADORA. Eres una bruja '
          'herbolaria, maestra en preparar remedios y pociones con precisión. Tu '
          'atención a los detalles hace tus rituales impecables. Magia de sanación, '
          'purificación y organización son tus puntos fuertes. Mantén un grimorio '
          'detallado y un altar perfectamente organizado',
  'sun_libra':
      'Con el Sol en Libra, tu esencia mágica es ARMÓNICA y RELACIONAL. Eres una '
          'bruja diplomática, capaz de equilibrar energías y armonizar ambientes. '
          'Magia de amor, alianzas y justicia son naturales para ti. Tus altares son '
          'estéticamente bellos. Trabaja en parejas o grupos para potenciar tu magia. '
          'Los rituales de equilibrio energético son tu especialidad',
  'sun_scorpio':
      'Con el Sol en Escorpio, tu esencia mágica es TRANSFORMADORA y PROFUNDA. Eres '
          'una bruja de lo oculto, sin miedo a explorar los misterios más profundos. '
          'Tu magia es intensa y poderosa. Transformación, destierros y trabajo de '
          'sombra son naturales para ti. Rituales de muerte y renacimiento simbólico '
          'te fortalecen. Plutón es tu aliado en las transmutaciones',
  'sun_sagittarius':
      'Con el Sol en Sagitario, tu esencia mágica es EXPANSIVA y FILOSÓFICA. Eres '
          'una bruja aventurera, buscadora de verdades en diversas tradiciones. Tu '
          'magia se fortalece cuando estudias y viajas (física o espiritualmente). '
          'Rituales de suerte, expansión y viaje astral son naturales. Júpiter '
          'bendice tu camino espiritual',
  'sun_capricorn':
      'Con el Sol en Capricornio, tu esencia mágica es DISCIPLINADA y TRADICIONAL. '
          'Eres una bruja ancestral, conectada con prácticas antiguas y tradiciones '
          'familiares. Tu magia se fortalece con consistencia y estructura. Rituales '
          'de carrera, manifestación a largo plazo y protección son tus puntos '
          'fuertes. Saturno enseña paciencia en tu práctica',
  'sun_aquarius':
      'Con el Sol en Acuario, tu esencia mágica es INNOVADORA y COLECTIVA. Eres una '
          'bruja futurista, que trae nuevas ideas a prácticas antiguas. Tu magia es '
          'más fuerte en grupo y para causas humanitarias. Rituales de libertad, '
          'amistad y cambio social son naturales. Urano te inspira a romper '
          'paradigmas en la brujería',
  'sun_pisces':
      'Con el Sol en Piscis, tu esencia mágica es MÍSTICA y COMPASIVA. Eres una '
          'bruja vidente, naturalmente conectada con el mundo espiritual. Tu magia '
          'fluye a través de sueños, visiones e intuición pura. Mediumnidad, '
          'canalización y sanación empática son tus dones naturales. Neptuno te guía '
          'en los viajes espirituales',

  // LUNA en cada signo
  'moon_aries':
      'Con la Luna en Aries, tus emociones son INTENSAS e IMPULSIVAS. Procesas los '
          'sentimientos a través de la acción. Tu intuición mágica es rápida e '
          'instintiva. Los rituales espontáneos funcionan bien para ti. Cuando estés '
          'emocionalmente cargada, canalízalo en magia de protección o ejercicio '
          'físico ritual. La Luna en Aries potencia hechizos de coraje',
  'moon_taurus':
      'Con la Luna en Tauro, tus emociones son ESTABLES y SENSUALES. Encuentras '
          'consuelo emocional a través de los sentidos - comida, naturaleza, tacto. '
          'Tu intuición habla a través del cuerpo. Rituales con elementos físicos '
          '(cristales, hierbas, aceites) son especialmente eficaces. Necesitas '
          'seguridad emocional para que tu magia fluya',
  'moon_gemini':
      'Con la Luna en Géminis, tus emociones son VERSÁTILES y COMUNICATIVAS. '
          'Procesas los sentimientos hablando o escribiendo sobre ellos. Tu intuición '
          'llega a través de palabras, mensajes y sincronicidades. El journaling '
          'mágico y la escritura automática son herramientas poderosas. La Luna en '
          'Géminis potencia la adivinación',
  'moon_cancer':
      'Con la Luna en Cáncer, estás EN CASA. Esta es la posición más poderosa de la '
          'Luna. Tus emociones son profundas, tu intuición es fuerte, y tu conexión '
          'con los ciclos lunares es natural. Sientes las fases de la Luna en el '
          'cuerpo. Toda magia lunar se amplifica para ti. El trabajo con ancestros y '
          'la protección familiar son dones naturales',
  'moon_leo':
      'Con la Luna en Leo, tus emociones son DRAMÁTICAS y GENEROSAS. Necesitas '
          'sentirte especial y reconocida para estar bien. Tu intuición brilla cuando '
          'estás en el escenario o liderando. Los rituales teatrales y expresivos '
          'funcionan bien. La Luna en Leo potencia la magia de autoestima y expresión '
          'creativa',
  'moon_virgo':
      'Con la Luna en Virgo, tus emociones son ANALÍTICAS y buscan ORDEN. Procesas '
          'los sentimientos intentando entenderlos lógicamente. Tu intuición habla a '
          'través de detalles y patrones. Los rituales meticulosos y organizados te '
          'calman. La Luna en Virgo potencia la magia de sanación y purificación',
  'moon_libra':
      'Con la Luna en Libra, tus emociones buscan ARMONÍA y BELLEZA. Necesitas paz '
          'y relaciones equilibradas para estar bien. Tu intuición habla a través de '
          'la estética y el sentido de justicia. Los rituales elegantes y '
          'equilibrados funcionan mejor. La Luna en Libra potencia la magia de las '
          'relaciones',
  'moon_scorpio':
      'Con la Luna en Escorpio, tus emociones son INTENSAS y TRANSFORMADORAS. '
          'Sientes todo profundamente y no temes la oscuridad emocional. Tu '
          'intuición psíquica es poderosa. Los rituales de transformación y el '
          'trabajo de sombra son naturales. La Luna en Escorpio amplifica la magia '
          'oculta y de destierro',
  'moon_sagittarius':
      'Con la Luna en Sagitario, tus emociones buscan LIBERTAD y SIGNIFICADO. '
          'Necesitas espacio emocional y propósito. Tu intuición habla a través de '
          'visiones e insights filosóficos. Los rituales al aire libre y los viajes '
          'espirituales te nutren. La Luna en Sagitario potencia la magia de '
          'expansión',
  'moon_capricorn':
      'Con la Luna en Capricornio, tus emociones son CONTENIDAS y PRÁCTICAS. '
          'Procesas los sentimientos a través del trabajo y la estructura. Tu '
          'intuición habla a través de la tradición y la experiencia. Los rituales '
          'estructurados y tradicionales funcionan mejor. La Luna en Capricornio '
          'potencia la magia de manifestación material',
  'moon_aquarius':
      'Con la Luna en Acuario, tus emociones son DESAPEGADAS y HUMANITARIAS. '
          'Procesas los sentimientos de forma intelectual. Tu intuición llega como '
          'descargas repentinas e insights. Los rituales de grupo y para causas '
          'colectivas te nutren. La Luna en Acuario potencia la magia de innovación',
  'moon_pisces':
      'Con la Luna en Piscis, tus emociones son OCEÁNICAS y sin fronteras. Absorbes '
          'los sentimientos a tu alrededor como una esponja. Tu intuición psíquica es '
          'fortísima. Los rituales con agua, los sueños lúcidos y la meditación '
          'profunda son naturales. La Luna en Piscis amplifica toda magia intuitiva y '
          'espiritual',

  // MERCURIO en cada signo
  'mercury_aries':
      'Con Mercurio en Aries, tu mente es RÁPIDA y DIRECTA. Piensas y hablas con '
          'velocidad y asertividad. Los encantamientos cortos y directos funcionan '
          'mejor que los rituales largos. Tu comunicación mágica es valiente. Los '
          'sigilos de acción rápida son tu especialidad',
  'mercury_taurus':
      'Con Mercurio en Tauro, tu mente es PRÁCTICA y DELIBERADA. Piensas despacio '
          'pero con profundidad. Prefieres memorizar encantamientos a improvisar. Tu '
          'comunicación mágica tiene peso y sustancia. Los cantos y mantras '
          'repetitivos son especialmente poderosos',
  'mercury_gemini':
      'Con Mercurio en Géminis, tu mente es BRILLANTE y VERSÁTIL. Esta es la '
          'posición más fuerte de Mercurio. Eres maestra de las palabras mágicas. '
          'Sigilos, encantamientos y toda magia verbal se amplifican. El tarot y los '
          'oráculos hablan claramente contigo',
  'mercury_cancer':
      'Con Mercurio en Cáncer, tu mente es INTUITIVA y EMOCIONAL. Piensas con el '
          'corazón. Tu comunicación mágica carga emoción profunda. Los encantamientos '
          'pronunciados con sentimiento son especialmente poderosos. Recibes mensajes '
          'a través de recuerdos y sueños',
  'mercury_leo':
      'Con Mercurio en Leo, tu mente es CREATIVA y DRAMÁTICA. Te expresas con '
          'estilo y confianza. Los encantamientos proclamados en voz alta son '
          'especialmente poderosos. Tu comunicación mágica inspira a otros. Eres '
          'excelente liderando invocaciones de grupo',
  'mercury_virgo':
      'Con Mercurio en Virgo, tu mente es ANALÍTICA y PRECISA. Esta es otra '
          'posición fuerte de Mercurio. Eres meticulosa con las palabras y las '
          'correspondencias. Tus registros mágicos son impecables. Los encantamientos '
          'detallados y precisos son tu especialidad',
  'mercury_libra':
      'Con Mercurio en Libra, tu mente busca EQUILIBRIO y DIPLOMACIA. Consideras '
          'todos los lados antes de decidir. Tu comunicación mágica es elegante y '
          'armoniosa. Los encantamientos de alianza y justicia son naturales. Eres '
          'excelente en la mediación espiritual',
  'mercury_scorpio':
      'Con Mercurio en Escorpio, tu mente es PENETRANTE e INVESTIGADORA. Vas a '
          'fondo en cualquier tema. Tu comunicación mágica es intensa y '
          'transformadora. Las palabras de poder y las invocaciones secretas son tu '
          'especialidad. Descubres conocimiento oculto con facilidad',
  'mercury_sagittarius':
      'Con Mercurio en Sagitario, tu mente es EXPANSIVA y FILOSÓFICA. Piensas en '
          'términos amplios y universales. Tu comunicación mágica es inspiradora y '
          'optimista. Estudiar diversas tradiciones enriquece tu práctica. Los '
          'encantamientos de expansión son poderosos',
  'mercury_capricorn':
      'Con Mercurio en Capricornio, tu mente es ESTRUCTURADA y SERIA. Piensas a '
          'largo plazo y con practicidad. Tu comunicación mágica es tradicional y '
          'respetuosa. Los encantamientos formales y tradicionales funcionan mejor. '
          'Aprendes bien con mentores',
  'mercury_aquarius':
      'Con Mercurio en Acuario, tu mente es ORIGINAL y VISIONARIA. Piensas fuera de '
          'la caja y lo cuestionas todo. Tu comunicación mágica es innovadora. Creas '
          'nuevos encantamientos y sistemas. Las descargas intuitivas repentinas son '
          'comunes para ti',
  'mercury_pisces':
      'Con Mercurio en Piscis, tu mente es INTUITIVA e IMAGINATIVA. Piensas en '
          'símbolos e imágenes. Tu comunicación mágica es poética y fluida. La '
          'escritura automática y la canalización son naturales. Recibes mensajes a '
          'través de sueños y visiones',

  // VENUS en cada signo
  'venus_aries':
      'Con Venus en Aries, AMAS con PASIÓN e INTENSIDAD. La magia de amor para ti '
          'debe ser directa y valiente. Atraes a través de la energía y la '
          'iniciativa. Los rituales de amor propio y confianza son especialmente '
          'poderosos. Los hechizos de pasión y atracción funcionan rápidamente',
  'venus_taurus':
      'Con Venus en Tauro, AMAS con los SENTIDOS. Esta es la posición más fuerte de '
          'Venus. Atraes a través de la belleza y el placer sensorial. La magia de '
          'amor con aceites, perfumes y comida es especialmente eficaz. Los rituales '
          'de prosperidad amorosa son naturales',
  'venus_gemini':
      'Con Venus en Géminis, AMAS a través de la COMUNICACIÓN. La conexión mental '
          'es esencial para ti. La magia de amor incluye palabras, cartas y '
          'conversaciones. Atraes a través del intelecto y el humor. Los hechizos con '
          'sigilos de amor son especialmente eficaces',
  'venus_cancer':
      'Con Venus en Cáncer, AMAS con CUIDADO y PROTECCIÓN. La seguridad emocional '
          'es esencial. La magia de amor enfocada en la familia y el hogar es '
          'poderosa. Atraes a través del cariño y la nutrición. Los rituales de amor '
          'durante la Luna Llena se amplifican',
  'venus_leo':
      'Con Venus en Leo, AMAS con DRAMA y GENEROSIDAD. El romance grandioso te '
          'atrae. La magia de amor debe ser especial y teatral. Atraes a través del '
          'brillo y la confianza. Los rituales de glamur amoroso son tu especialidad',
  'venus_virgo':
      'Con Venus en Virgo, AMAS a través del SERVICIO. Los actos de cuidado son tu '
          'lenguaje del amor. La magia de amor práctica y útil funciona mejor. '
          'Atraes a través de la competencia y la atención a los detalles. Prepara '
          'pociones de amor con cuidado',
  'venus_libra':
      'Con Venus en Libra, AMAS con ARMONÍA y ELEGANCIA. Esta es otra posición '
          'fuerte de Venus. Las alianzas equilibradas son esenciales. La magia de '
          'amor estética y romántica es poderosa. Atraes a través de la gracia y la '
          'diplomacia. Los rituales de matrimonio son tu especialidad',
  'venus_scorpio':
      'Con Venus en Escorpio, AMAS con INTENSIDAD TOTAL. Las conexiones profundas y '
          'transformadoras te atraen. La magia de amor es intensa y poderosa para '
          'ti. Atraes a través del magnetismo y el misterio. Los rituales de amor '
          'que implican compromiso profundo son eficaces',
  'venus_sagittarius':
      'Con Venus en Sagitario, AMAS con LIBERTAD. Las conexiones que expanden tu '
          'mundo te atraen. La magia de amor debe incluir aventura y crecimiento. '
          'Atraes a través del optimismo y el humor. Los rituales de amor al aire '
          'libre son poderosos',
  'venus_capricorn':
      'Con Venus en Capricornio, AMAS con COMPROMISO. Las relaciones serias y '
          'duraderas te atraen. La magia de amor debe ser práctica y construir para '
          'el futuro. Atraes a través de la estabilidad. Los rituales de amor con '
          'estructura y tradición funcionan',
  'venus_aquarius':
      'Con Venus en Acuario, AMAS con LIBERTAD y AMISTAD. Las conexiones únicas y '
          'no convencionales te atraen. La magia de amor debe respetar la '
          'individualidad. Atraes a través de la originalidad. Los rituales de amor '
          'en grupo o para la amistad son poderosos',
  'venus_pisces':
      'Con Venus en Piscis, AMAS con DEVOCIÓN TOTAL. Esta es la posición más '
          'romántica de Venus. Las conexiones espirituales te atraen. La magia de '
          'amor es trascendente para ti. Atraes a través de la compasión. Los '
          'rituales de amor con agua y música son especialmente eficaces',

  // MARTE en cada signo
  'mars_aries':
      'Con Marte en Aries, tu ENERGÍA es EXPLOSIVA y DIRECTA. Esta es la posición '
          'más fuerte de Marte. Actúas con coraje e iniciativa. La magia de '
          'protección y destierro es especialmente poderosa. Los rituales de acción '
          'rápida son eficaces. Usa esta energía para comenzar proyectos mágicos',
  'mars_taurus':
      'Con Marte en Tauro, tu ENERGÍA es PERSISTENTE y DETERMINADA. Actúas despacio '
          'pero con fuerza imparable. La magia de manifestación material es poderosa. '
          'Los rituales que exigen paciencia funcionan bien. Usa esta energía para '
          'protección duradera',
  'mars_gemini':
      'Con Marte en Géminis, tu ENERGÍA es VERSÁTIL y MENTAL. Actúas a través de '
          'palabras e ideas. La magia verbal y de comunicación es poderosa. Los '
          'debates y discusiones te energizan. Usa esta energía para sigilos activos',
  'mars_cancer':
      'Con Marte en Cáncer, tu ENERGÍA es PROTECTORA y EMOCIONAL. Actúas para '
          'defender a quienes amas. La magia de protección familiar es especialmente '
          'poderosa. Los rituales emocionalmente cargados son eficaces. Usa esta '
          'energía para proteger el hogar',
  'mars_leo':
      'Con Marte en Leo, tu ENERGÍA es DRAMÁTICA y CREATIVA. Actúas con estilo y '
          'confianza. La magia de autoexpresión y coraje es poderosa. Los rituales '
          'teatrales son eficaces. Usa esta energía para rituales de liderazgo',
  'mars_virgo':
      'Con Marte en Virgo, tu ENERGÍA es PRECISA y EFICIENTE. Actúas de forma '
          'metódica y detallista. La magia de sanación y purificación es poderosa. '
          'Los rituales bien planificados son más eficaces. Usa esta energía para '
          'trabajos precisos',
  'mars_libra':
      'Con Marte en Libra, tu ENERGÍA busca JUSTICIA y EQUILIBRIO. Actúas en nombre '
          'de la armonía. La magia de justicia y equilibrio es poderosa. Los rituales '
          'de alianza son eficaces. Usa esta energía para resolver conflictos '
          'mágicamente',
  'mars_scorpio':
      'Con Marte en Escorpio, tu ENERGÍA es INTENSA y TRANSFORMADORA. Esta es una '
          'posición muy fuerte de Marte. Actúas con determinación implacable. La '
          'magia de transformación y destierro es extremadamente poderosa. Usa esta '
          'energía para cambios profundos',
  'mars_sagittarius':
      'Con Marte en Sagitario, tu ENERGÍA es AVENTURERA y EXPANSIVA. Actúas con '
          'optimismo y entusiasmo. La magia de expansión y viaje es poderosa. Los '
          'rituales al aire libre son eficaces. Usa esta energía para el crecimiento '
          'espiritual activo',
  'mars_capricorn':
      'Con Marte en Capricornio, tu ENERGÍA es DISCIPLINADA y AMBICIOSA. Esta es '
          'una posición muy fuerte de Marte. Actúas con estrategia y paciencia. La '
          'magia de carrera y manifestación material es poderosa. Los rituales '
          'estructurados son eficaces',
  'mars_aquarius':
      'Con Marte en Acuario, tu ENERGÍA es REVOLUCIONARIA e INDEPENDIENTE. Actúas '
          'de formas no convencionales. La magia de grupo y para causas sociales es '
          'poderosa. Los rituales innovadores son eficaces. Usa esta energía para el '
          'cambio colectivo',
  'mars_pisces':
      'Con Marte en Piscis, tu ENERGÍA es FLUIDA e INTUITIVA. Actúas guiada por la '
          'intuición y la compasión. La magia espiritual y sanadora es poderosa. Los '
          'rituales meditativos son eficaces. Usa esta energía para el trabajo '
          'espiritual activo',
};

// Los getters de los enums (`displayName`, `magicalDescription`) ya están
// localizados vía `ContentLocale`, así que las funciones de plantilla los usan
// directamente en lugar de re-traducir nombres de planeta/signo/elemento.

/// Interpretación por defecto (compuesta) cuando no existe una específica en
/// el mapa — cubre planetas exteriores, nodos y los puntos místicos
/// (MC/IC/DSC, Vértex, Lilith, Parte de la Fortuna). Une el tema del planeta
/// con el estilo del signo y un consejo mágico breve.
String planetSignDefaultInterpretationEs(Planet planet, ZodiacSign sign) {
  final style = _signStyleEs(sign);
  final magic = _planetMagicEs(planet);

  if (planet == Planet.northNode) {
    return 'Tu Nodo Norte en ${sign.displayName} señala el camino de '
        'crecimiento y propósito de esta vida, a recorrer $style. $magic';
  }
  if (planet == Planet.southNode) {
    return 'Tu Nodo Sur en ${sign.displayName} revela dones ya heredados y la '
        'zona de confort que traes $style. $magic';
  }
  // En español el posesivo "Tu" no tiene género — vale para todos los puntos.
  return 'Tu ${planet.displayName} en ${sign.displayName} vive '
      '${_planetMeaningEs(planet)}, $style. $magic';
}

/// Tema central de cada planeta (frase nominal).
String _planetMeaningEs(Planet planet) {
  switch (planet) {
    case Planet.sun:
      return 'tu esencia y vitalidad';
    case Planet.moon:
      return 'tus emociones y tu mundo interior';
    case Planet.mercury:
      return 'tu mente y tu comunicación';
    case Planet.venus:
      return 'el amor, el placer y la belleza';
    case Planet.mars:
      return 'la acción, el deseo y el coraje';
    case Planet.jupiter:
      return 'la expansión, la fe y la abundancia';
    case Planet.saturn:
      return 'la disciplina, los límites y la madurez';
    case Planet.uranus:
      return 'la innovación, la ruptura y la libertad';
    case Planet.neptune:
      return 'la espiritualidad, los sueños y la imaginación';
    case Planet.pluto:
      return 'la transformación profunda y el poder de renacer';
    case Planet.northNode:
      return 'el camino de crecimiento del alma';
    case Planet.southNode:
      return 'los dones heredados de otras vidas';
    case Planet.midheaven:
      return 'tu vocación, tu imagen pública y el legado que construyes';
    case Planet.imumCoeli:
      return 'tus raíces, el hogar y la base emocional más íntima';
    case Planet.descendant:
      return 'las relaciones y lo que buscas en el otro';
    case Planet.vertex:
      return 'los encuentros fatídicos y los giros del destino';
    case Planet.lilith:
      return 'el poder instintivo, la sombra y el deseo indomable';
    case Planet.partOfFortune:
      return 'tu suerte, la prosperidad y el bienestar';
  }
}

/// Estilo de expresión de cada signo (elemento + cualidad resumidos).
String _signStyleEs(ZodiacSign sign) {
  switch (sign) {
    case ZodiacSign.aries:
      return 'de forma audaz, directa y pionera';
    case ZodiacSign.taurus:
      return 'de forma estable, sensorial y persistente';
    case ZodiacSign.gemini:
      return 'de forma curiosa, comunicativa y versátil';
    case ZodiacSign.cancer:
      return 'de forma sensible, protectora y acogedora';
    case ZodiacSign.leo:
      return 'de forma expresiva, generosa y creativa';
    case ZodiacSign.virgo:
      return 'de forma práctica, analítica y cuidadosa';
    case ZodiacSign.libra:
      return 'de forma armoniosa, diplomática y estética';
    case ZodiacSign.scorpio:
      return 'de forma intensa, profunda y transformadora';
    case ZodiacSign.sagittarius:
      return 'de forma aventurera, filosófica y optimista';
    case ZodiacSign.capricorn:
      return 'de forma disciplinada, ambiciosa y responsable';
    case ZodiacSign.aquarius:
      return 'de forma original, independiente y humanitaria';
    case ZodiacSign.pisces:
      return 'de forma sensible, imaginativa y compasiva';
  }
}

/// Consejo mágico breve por planeta.
String _planetMagicEs(Planet planet) {
  switch (planet) {
    case Planet.sun:
      return 'En la magia, es tu centro de poder e identidad';
    case Planet.moon:
      return 'En la magia, guía tus ciclos, tu intuición y los trabajos lunares';
    case Planet.mercury:
      return 'En la magia, favorece hechizos de comunicación, estudio y claridad';
    case Planet.venus:
      return 'En la magia, rige rituales de amor, autoestima y placer';
    case Planet.mars:
      return 'En la magia, alimenta la protección, el coraje y el destierro';
    case Planet.jupiter:
      return 'En la magia, úsalo en rituales de crecimiento, suerte y abundancia';
    case Planet.saturn:
      return 'En la magia, úsalo en trabajos de estructura, protección y compromisos duraderos';
    case Planet.uranus:
      return 'En la magia, úsalo para romper patrones y abrir caminos nuevos';
    case Planet.neptune:
      return 'En la magia, úsalo en sueños, adivinación y conexión espiritual';
    case Planet.pluto:
      return 'En la magia, úsalo en ritos de transformación, sanación profunda y renacimiento';
    case Planet.northNode:
      return 'Cultiva las cualidades de este signo — es hacia donde crece tu alma';
    case Planet.southNode:
      return 'Reconoce esos dones ya naturales y evita acomodarte solo en ellos';
    case Planet.midheaven:
      return 'En la magia, orienta rituales de propósito, carrera y reconocimiento';
    case Planet.imumCoeli:
      return 'En la magia, úsalo en trabajos de protección del hogar, ancestralidad y raíces';
    case Planet.descendant:
      return 'En la magia, favorece rituales de alianzas, uniones y armonía con el otro';
    case Planet.vertex:
      return 'En la magia, marca encuentros del destino — trabaja sincronicidades y portales';
    case Planet.lilith:
      return 'En la magia, es el portal de la bruja salvaje: soberanía, sombra y deseo';
    case Planet.partOfFortune:
      return 'En la magia, dirige hacia aquí hechizos de prosperidad, suerte y abundancia';
  }
}

/// Resumen corto para mostrar en listas.
String planetSignShortInterpretationEs(Planet planet, ZodiacSign sign) {
  switch (planet) {
    case Planet.sun:
      return 'Tu esencia mágica es ${sign.magicalDescription}';
    case Planet.moon:
      return 'Tus emociones e intuición son ${sign.magicalDescription}';
    case Planet.mercury:
      return 'Tu mente y comunicación son ${sign.magicalDescription}';
    case Planet.venus:
      return 'Tu amor y belleza son ${sign.magicalDescription}';
    case Planet.mars:
      return 'Tu energía y acción son ${sign.magicalDescription}';
    case Planet.jupiter:
      return 'Tu suerte y expansión son ${sign.magicalDescription}';
    case Planet.saturn:
      return 'Tu disciplina y estructura son ${sign.magicalDescription}';
    case Planet.uranus:
      return 'Tu innovación es ${sign.magicalDescription}';
    case Planet.neptune:
      return 'Tu espiritualidad es ${sign.magicalDescription}';
    case Planet.pluto:
      return 'Tu transformación es ${sign.magicalDescription}';
    default:
      return '${planet.displayName} en ${sign.displayName}';
  }
}
