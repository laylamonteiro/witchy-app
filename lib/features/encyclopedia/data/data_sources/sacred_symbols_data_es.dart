import '../models/arcane_entry_model.dart';

/// Símbolos Sagrados de la Brujería — contenido en español.
///
/// Los emojis y las correspondencias no textuales son invariantes entre
/// idiomas. Mantén el mismo orden que `sacred_symbols_data_pt.dart` — la
/// paridad se verifica en `test/content_parity_test.dart`.
const List<ArcaneEntry> sacredSymbolsEs = [
  ArcaneEntry(
    name: 'Pentagrama',
    emoji: '⛤',
    summary: 'La estrella de cinco puntas: los elementos en equilibrio',
    origin: 'Mesopotamia y Grecia pitagórica; resignificado por la brujería moderna',
    history:
        'Usado por sumerios y pitagóricos (que lo llamaban "salud"), el pentagrama atravesó el cristianismo medieval como símbolo de las cinco llagas antes de convertirse, en el ocultismo del siglo XIX y en la Wicca, en el emblema de los cuatro elementos coronados por el Espíritu. Invertido, ganó lecturas diversas — del símbolo de Baphomet a usos tradicionales sin connotación negativa.',
    characteristics: [
      'Punta hacia arriba: el espíritu rigiendo la materia',
      'Trazo continuo: protección sin brechas',
      'Dentro del círculo (pentáculo): consagración',
    ],
    symbolism: [
      'Las cinco puntas: Tierra, Aire, Fuego, Agua y Espíritu',
      'La proporción áurea escondida en el trazo',
    ],
    correspondences: ['Todos los elementos', 'Plata', 'Sal y velas en los rituales'],
    studyPractices: [
      'Aprender a trazar pentagramas de invocación y destierro',
      'Estudiar la historia del símbolo antes de los estigmas modernos',
    ],
    magicalUses: [
      'Protección de espacios y personas',
      'Consagración de herramientas en el pentáculo del altar',
    ],
    cautions:
        'El pentagrama invertido tiene significados múltiples según la tradición — evita juicios apresurados.',
    related: ['Sigilos', 'Altar (Enciclopedia)', 'Elementos'],
  ),
  ArcaneEntry(
    name: 'Triple Luna',
    emoji: '🌒🌕🌘',
    summary: 'Creciente, llena y menguante: los tres rostros de la Diosa',
    origin: 'Iconografía de la brujería moderna (s. XX), con raíces clásicas',
    history:
        'La asociación Doncella-Madre-Anciana fue articulada por Robert Graves y abrazada por la Wicca. El símbolo — creciente, disco lleno y menguante unidos — se convirtió en el emblema de la Diosa Triple y corona de las sumas sacerdotisas.',
    characteristics: [
      'Síntesis del ciclo lunar completo',
      'Las tres fases de la vida y de la creación',
    ],
    symbolism: [
      'Creciente: comienzos y juventud',
      'Llena: plenitud y poder',
      'Menguante: sabiduría y cierre',
    ],
    correspondences: ['Luna', 'Plata', 'Piedra luna', 'Lunes'],
    studyPractices: [
      'Acompañar un ciclo lunar completo en el Calendario Lunar de la app',
      'Identificar en qué "fase" está cada área de tu vida',
    ],
    magicalUses: [
      'Coronar altares dedicados a la Diosa',
      'Sincronizar rituales con la fase correspondiente',
    ],
    cautions:
        'Símbolo moderno con raíces antiguas: reconocer su historicidad no disminuye su poder devocional.',
    related: ['Fases de la Luna', 'La Doncella, La Madre y La Sabia (Arquetipos)'],
  ),
  ArcaneEntry(
    name: 'Ankh',
    emoji: '☥',
    summary: 'La llave de la vida del antiguo Egipto',
    origin: 'Antiguo Egipto (jeroglífico "vida")',
    history:
        'Jeroglífico que significa "vida", el ankh aparece en las manos de dioses egipcios ofreciendo el soplo vital a los faraones. Adoptado por los coptos como cruz y por el ocultismo moderno como símbolo de vitalidad e inmortalidad.',
    characteristics: [
      'Unión del círculo (lo eterno) con la cruz (la materia)',
      'Símbolo de ofrenda de vida en las escenas sagradas',
    ],
    symbolism: [
      'El asa: el sol naciente, lo eterno',
      'El eje: el camino terrenal',
      'En las manos de los dioses: la vida como don',
    ],
    correspondences: ['Sol', 'Oro', 'Olíbano', 'Vitalidad'],
    studyPractices: [
      'Estudiar la iconografía egipcia y sus dioses',
      'Meditar sosteniendo el símbolo: "¿qué me da vida?"',
    ],
    magicalUses: [
      'Talismán de vitalidad y salud energética',
      'Presencia en altares de ancestralidad',
    ],
    cautions:
        'Respeta el origen cultural: el ankh es herencia del antiguo Egipto, no un adorno vacío.',
    related: ['Energía & Sanación (Grimorio)', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Triquetra',
    emoji: '🔱',
    summary: 'El nudo de tres puntas: trinidades y continuidad',
    origin: 'Arte celta y germánico; resignificaciones cristiana y neopagana',
    history:
        'Presente en piedras rúnicas y en el Libro de Kells, la triquetra es un entrelazado de tres arcos sin comienzo ni fin. Sirvió a la Trinidad cristiana en Irlanda y hoy representa, en la brujería, tríadas como tierra-mar-cielo o cuerpo-mente-espíritu.',
    characteristics: [
      'Línea única y continua: unidad en el tres',
      'Frecuentemente entrelazada con un círculo',
    ],
    symbolism: [
      'Tierra, mar y cielo en la cosmología celta',
      'Pasado, presente y futuro',
      'La Diosa Triple en las lecturas wiccanas',
    ],
    correspondences: ['Tríos rituales', 'Verde y dorado', 'Roble'],
    studyPractices: [
      'Dibujar la triquetra en trazo continuo como meditación',
      'Estudiar el simbolismo del tres en las tradiciones celtas',
    ],
    magicalUses: [
      'Sellar trabajos en tres etapas',
      'Amuleto de protección y continuidad',
    ],
    cautions:
        'Símbolo compartido por varias tradiciones vivas: el contexto importa.',
    related: ['Triple Luna', 'La Tejedora (Arquetipos)'],
  ),
  ArcaneEntry(
    name: 'Ojo de Horus',
    emoji: '𓂀',
    summary: 'El ojo que todo lo restaura: protección e integridad',
    origin: 'Antiguo Egipto (mito de Horus y Set)',
    history:
        'En el mito, Set arranca el ojo de Horus, restaurado después por Thoth — por eso el udyat ("lo que está completo") se convirtió en amuleto de sanación y protección omnipresente en Egipto, de los vivos a los sarcófagos.',
    characteristics: [
      'Amuleto funerario y cotidiano de inmensa popularidad',
      'Sus partes se usaban como fracciones en Egipto',
    ],
    symbolism: [
      'La restauración: lo que fue herido puede rehacerse',
      'La vigilancia benévola: ver y proteger',
    ],
    correspondences: ['Lapislázuli', 'Azul y dorado', 'Protección'],
    studyPractices: [
      'Estudiar el mito de Horus, Set y Osiris',
      'Reflexionar: "¿qué en mí pide restauración?"',
    ],
    magicalUses: [
      'Amuleto contra la envidia y las miradas dañinas',
      'Rituales de sanación y reintegración',
    ],
    cautions:
        'No confundir con el "ojo que todo lo ve" masónico — historias distintas.',
    related: ['Ankh', 'Protección & Limpieza (Grimorio)'],
  ),
  ArcaneEntry(
    name: 'Rueda del Año',
    emoji: '☸️',
    summary: 'Los ocho radios del ciclo sagrado de las estaciones',
    origin: 'Neopaganismo del s. XX, sobre festivales celtas y germánicos',
    history:
        'La Rueda del Año moderna une cuatro festivales celtas del fuego (Samhain, Imbolc, Beltane, Lughnasadh) con los solsticios y equinoccios, formando ocho sabbats. El símbolo — rueda de ocho radios — expresa el tiempo circular de la naturaleza.',
    characteristics: [
      'Ocho festivales equidistantes (~6,5 semanas)',
      'Tiempo cíclico, no lineal',
    ],
    symbolism: [
      'Cada radio: una cualidad de la luz y de la cosecha',
      'El centro: el eje inmóvil de quien observa',
    ],
    correspondences: ['Sabbats', 'Trigo, velas y flores de estación'],
    studyPractices: [
      'Acompañar los sabbats en la sección Rueda del Año de la app',
      'Crear pequeñas celebraciones estacionales personales',
    ],
    magicalUses: [
      'Planear intenciones según la estación',
      'Altar estacional renovado en cada sabbat',
    ],
    cautions:
        'Adapta las fechas al hemisferio sur cuando tenga sentido para tu práctica.',
    related: ['Rueda del Año (app)', 'Sabbats (Enciclopedia)'],
  ),
  ArcaneEntry(
    name: 'Espiral',
    emoji: '🌀',
    summary: 'El camino que regresa distinto: el símbolo más antiguo',
    origin: 'Arte neolítico universal (Newgrange, ~3200 a.C.)',
    history:
        'Grabada en túmulos megalíticos como Newgrange milenios antes de las pirámides, la espiral es quizá el símbolo sagrado más antiguo de la humanidad — presente en caracolas, galaxias y en el propio crecimiento de las plantas.',
    characteristics: [
      'Simple (una línea), doble o triple (trisquel)',
      'Sentido horario/antihorario con lecturas distintas',
    ],
    symbolism: [
      'Evolución: volver al mismo punto, más profundo',
      'Nacimiento-muerte-renacimiento',
      'El viaje hacia dentro y hacia fuera',
    ],
    correspondences: ['Caracolas', 'Danzas circulares', 'Laberintos'],
    studyPractices: [
      'Caminar laberintos o dibujar espirales meditativas',
      'Mapear las "vueltas de espiral" en la propia historia',
    ],
    magicalUses: [
      'Trazar espirales para abrir (deosil) o cerrar (widdershins) rituales',
      'Símbolo de crecimiento en sigilos',
    ],
    cautions:
        'Las direcciones varían entre tradiciones y hemisferios — sigue tu propia coherencia.',
    related: ['Sigilos', 'Sueños Recurrentes (Temas Oníricos)'],
  ),
  ArcaneEntry(
    name: 'Nudo de Bruja',
    emoji: '➰',
    summary: 'Cuatro lazos entrelazados: protección tejida',
    origin: 'Tradición popular europea (magia de nudos)',
    history:
        'El witch\'s knot — cuatro lazos entrelazados en trazo continuo — se marcaba en puertas y chimeneas para proteger contra la magia hostil. Heredero de la antigua magia de nudos, en la que atar y desatar guardaban y liberaban intenciones.',
    characteristics: [
      'Trazo continuo, sin comienzo ni fin',
      'Cuatro lazos: los cuatro vientos/direcciones',
    ],
    symbolism: [
      'El nudo: intención fijada',
      'El entrelazado: fuerzas que se sostienen mutuamente',
    ],
    correspondences: ['Cordones', 'Puertas y umbrales', 'Cuatro direcciones'],
    studyPractices: [
      'Aprender el trazo en línea única',
      'Estudiar la magia de nudos en diferentes culturas',
    ],
    magicalUses: [
      'Protección de las entradas del hogar',
      'Magia de cordón: atar intenciones en nudos',
    ],
    cautions:
        'Al desatar nudos rituales, hazlo con la misma conciencia con la que ataste.',
    related: ['La Tejedora (Arquetipos)', 'Protección & Limpieza (Grimorio)'],
  ),
  ArcaneEntry(
    name: 'Strophalos de Hécate',
    emoji: '🛞',
    summary: 'La rueda de Hécate: el laberinto de la señora de las encrucijadas',
    origin: 'Antigua Grecia; Oráculos Caldeos',
    history:
        'El strophalos — rueda con laberinto serpentino en torno a un centro — está ligado a Hécate, señora de las encrucijadas y de la magia. Los Oráculos Caldeos mencionan la "íynx" giratoria como instrumento teúrgico de invocación.',
    characteristics: [
      'Tres vueltas del laberinto: los tres reinos (cielo, tierra, mar)',
      'Símbolo de la soberanía de Hécate sobre los pasajes',
    ],
    symbolism: [
      'El centro: la llama del alma',
      'El laberinto: el camino iniciático',
      'La encrucijada: el momento de la elección',
    ],
    correspondences: ['Hécate', 'Llaves y antorchas', 'Luna oscura', 'Ajo y granada'],
    studyPractices: [
      'Estudiar a Hécate en las fuentes antiguas vs. relecturas modernas',
      'Meditar en las "encrucijadas" actuales de tu vida',
    ],
    magicalUses: [
      'Devocional a Hécate en lunas oscuras',
      'Rituales de decisión en encrucijadas simbólicas',
    ],
    cautions:
        'Símbolo devocional específico: acércate con estudio y respeto.',
    related: ['Hécate (Diosas)', 'La Reina Sombría (Arquetipos)'],
  ),
  ArcaneEntry(
    name: 'Vegvísir',
    emoji: '🧭',
    summary: 'El "indicador del camino" islandés',
    origin: 'Manuscritos mágicos islandeses (s. XIX, Manuscrito Huld)',
    history:
        'Registrado en el Manuscrito Huld (1860), el vegvísir prometía que "quien lo porte no se perderá en las tormentas". No es un símbolo vikingo de la era antigua, sino heredero tardío de los galdrastafir — bastones mágicos islandeses.',
    characteristics: [
      'Ocho astas con terminaciones distintas',
      'De la familia de los galdrastafir (sigilos islandeses)',
    ],
    symbolism: [
      'Las ocho direcciones: orientación total',
      'La tormenta: las fases confusas de la vida',
    ],
    correspondences: ['Viajes', 'Azul tormenta', 'Runas (parentesco)'],
    studyPractices: [
      'Distinguir símbolos de la era vikinga de los manuscritos tardíos',
      'Estudiar los galdrastafir y su lógica sigilística',
    ],
    magicalUses: [
      'Talismán de orientación en fases de incertidumbre',
      'Bendiciones de viaje',
    ],
    cautions:
        'Evita llamarlo "símbolo vikingo": la honestidad histórica fortalece la práctica.',
    related: ['Runas (Enciclopedia)', 'Sigilos'],
  ),
  ArcaneEntry(
    name: 'Uróboros',
    emoji: '🐍',
    summary: 'La serpiente que muerde su propia cola: el eterno retorno',
    origin: 'Antiguo Egipto; alquimia grecoegipcia',
    history:
        'De la tumba de Tutankamón al tratado alquímico de Cleopatra (con la leyenda "hen to pan" — el Uno es el Todo), el uróboros representa el ciclo que se autoalimenta. Jung lo tomó como símbolo central de la individuación.',
    characteristics: [
      'Círculo perfecto formado por un ser vivo',
      'A veces mitad claro, mitad oscuro (unión de opuestos)',
    ],
    symbolism: [
      'Eterno retorno y autosuficiencia',
      'Muerte que alimenta la vida',
      'El tiempo cíclico del cosmos',
    ],
    correspondences: ['Alquimia', 'Plata y negro', 'Ciclos largos'],
    studyPractices: [
      'Identificar ciclos que se repiten hasta ser comprendidos',
      'Estudiar el uróboros alquímico y junguiano',
    ],
    magicalUses: [
      'Sellar rituales de cierre-y-recomienzo',
      'Símbolo de renovación en sigilos',
    ],
    cautions:
        'Un ciclo que se repite sin conciencia es rueda de hámster: el uróboros pide presencia.',
    related: ['La Alquimista (Arquetipos)', 'Espiral'],
  ),
];
