import '../../../grimoire/data/models/spell_model.dart';
import '../../domain/menstrual_shortcut.dart';
import '../models/blood_lore_model.dart';

/// Los Saberes de la Sangre en español. Mismas reglas editoriales que la
/// fuente en portugués (ver `blood_lore_content_pt.dart`): la historia sigue
/// siendo historia, la práctica moderna se declara moderna, la Luna es
/// correspondencia y nunca causa, el filtro amoroso se cuenta y no se enseña,
/// y toda práctica que menciona sangre ofrece la misma práctica sin ella.
const bloodLoreContentEs = BloodLoreContent(
  pageTitle: 'Saberes de la Sangre',
  intro:
      'Cuatro caminos hacia el mismo tema: lo que muestran los registros, lo '
      'que la magia lunar hace con el ciclo, lo que se puede practicar hoy y '
      'de dónde salió todo esto',
  introNote:
      'Cada texto lleva una etiqueta que dice de dónde viene. Una práctica de '
      'ahora nunca se presenta aquí como tradición antigua.',
  categoryTitles: {
    BloodLoreCategory.bloodInMagic: 'La sangre en la magia',
    BloodLoreCategory.cycleAndMoon: 'Ciclo y Luna',
    BloodLoreCategory.practices: 'Prácticas y hechizos',
    BloodLoreCategory.traditions: 'Tradiciones e historia',
  },
  categorySubtitles: {
    BloodLoreCategory.bloodInMagic:
        'Vínculo, ambivalencia, amor, protección y poder personal',
    BloodLoreCategory.cycleAndMoon:
        'Dos ruedas que se encuentran — y lo que eso no significa',
    BloodLoreCategory.practices:
        'Gestos para hacer, con el origen de cada uno a la vista',
    BloodLoreCategory.traditions:
        'Qué se registró, quién lo registró y qué no se puede saber',
  },
  tagLabels: {
    BloodLoreTag.documented: 'Históricamente documentado',
    BloodLoreTag.tradition: 'Tradición específica',
    BloodLoreTag.contemporary: 'Práctica contemporánea',
    BloodLoreTag.modernAdaptation: 'Adaptación moderna',
  },
  safetyNote:
      'Usa solo tu propia sangre menstrual. No compartas fluidos corporales, '
      'no los pongas en alimentos ni bebidas y no uses materiales que puedan '
      'herirte. Nada aquí te pide que te cortes: se trata de la sangre que el '
      'cuerpo ya produjo.',
  classificationLabel: 'Clasificación',
  practiceIntentionLabel: 'Intención',
  practiceMaterialsLabel: 'Materiales',
  practiceStepsLabel: 'La práctica',
  practiceWithoutBloodLabel: 'Versión sin sangre',
  entriesCountTemplate: '{count} textos',
  cycleCta: 'Explorar los saberes de la sangre',
  momentTitle: 'Prácticas para este momento',
  momentIntro:
      'Atajos a lo que el Grimorio ya tiene. Lo que escribas, tires o sueñes '
      'sigue viviendo en su lugar de siempre.',
  shortcuts: {
    MenstrualShortcut.release: BloodLoreShortcut(
      title: '¿Qué quieres dejar?',
      body: 'Escribe sobre algo que llegó a su fin',
      prompt:
          '¿Qué está pidiendo terminar en este ciclo?\n\nEscribe sin intentar '
          'resolverlo. Solo observa lo que no quieres llevar a la próxima '
          'vuelta.',
    ),
    MenstrualShortcut.cultivate: BloodLoreShortcut(
      title: '¿Qué quieres cultivar?',
      body: 'Escribe sobre algo que está empezando',
      prompt:
          '¿Qué está empezando en ti en esta vuelta?\n\nEscribe sin exigir un '
          'resultado. Solo nombra lo que quieres cuidar hasta la próxima '
          'sangre.',
    ),
    MenstrualShortcut.oracle: BloodLoreShortcut(
      title: 'Escuchar al oráculo',
      body: 'Haz una tirada sobre este ciclo',
    ),
    MenstrualShortcut.dream: BloodLoreShortcut(
      title: 'Registrar un sueño',
      body: 'El sueño va a tu Diario de Sueños, como cualquier otro',
    ),
    MenstrualShortcut.intention: BloodLoreShortcut(
      title: 'Definir una intención',
      body:
          'Una palabra se vuelve sigilo en el creador que el Grimorio ya '
          'tiene',
    ),
    MenstrualShortcut.practices: BloodLoreShortcut(
      title: 'Practicar',
      body:
          'Explora prácticas ligadas a la sangre, la protección, el vínculo y '
          'el cierre',
    ),
  },
  moonCorrespondences: {
    MoonPhase.newMoon: 'semilla, silencio y lo que aún no tiene forma',
    MoonPhase.waxingCrescent:
        'expansión, fortalecimiento y aquello que se está cultivando',
    MoonPhase.firstQuarter: 'decisión, impulso y lo que pide una elección',
    MoonPhase.waxingGibbous: 'maduración y ajuste de lo que ya está en marcha',
    MoonPhase.fullMoon: 'plenitud, revelación y lo que desborda',
    MoonPhase.waningGibbous: 'gratitud, entrega y lo que ya puede descansar',
    MoonPhase.lastQuarter: 'corte, perdón y lo que se suelta',
    MoonPhase.waningCrescent: 'recogimiento, descanso y el fin del círculo',
  },
  correspondenceTemplate:
      'En la magia lunar, {phase} suele asociarse con {meaning}',
  startUnderTemplate: 'Tu último ciclo empezó bajo {phase}',
  phaseTallyTemplate:
      '{count} de tus últimos {total} comienzos ocurrieron bajo {phase}',
  moonNotSynced:
      'El ciclo lunar y el menstrual no necesitan estar sincronizados. '
      'Observa cómo se encuentran los dos a lo largo del tiempo.',
  closingCorrespondence:
      '{phase} y el sangrado comparten una correspondencia simbólica de '
      'cierre. Si eso tiene sentido para tu práctica, puede ser un buen '
      'momento para observar lo que quieres dejar.',
  entries: [
    // ── La sangre en la magia ─────────────────────────────────────────────
    BloodLoreEntry(
      id: 'sangue-vinculo',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '🔗',
      title: 'La sangre como vínculo',
      summary: 'Por qué la materia del cuerpo aparece tanto en la magia popular',
      sections: [
        BloodLoreSection(
          title: 'Materia que pertenece a alguien',
          body:
              'Sangre, cabello, uñas, saliva, un trozo de ropa usada: la '
              'magia popular registrada en Europa, en las Américas y en otras '
              'partes vuelve una y otra vez a estos materiales. La lógica es '
              'siempre la misma — lo que perteneció a un cuerpo sigue ligado '
              'a él, y trabajar con el material sería trabajar con la '
              'persona.',
        ),
        BloodLoreSection(
          title: 'Lo que reúne la sangre menstrual',
          body:
              'Junta en un solo material: sangre, identidad corporal, ciclo, '
              'sexualidad y fertilidad simbólica. Es esa suma, y no la sangre '
              'sola, lo que explica por qué aparece con tanta insistencia en '
              'los registros.',
        ),
        BloodLoreSection(
          title: 'El término moderno',
          body:
              'La brujería contemporánea suele llamar taglock a estos '
              'materiales. La palabra es reciente y sirve para nombrar el '
              'conjunto, pero el concepto es mucho más antiguo que ella — y '
              'las fuentes históricas no la usan.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'ambivalencia',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '⚖️',
      title: 'La ambivalencia de la sangre menstrual',
      summary:
          'Peligrosa, tabú, protectora, poderosa: los registros no coinciden '
          'entre sí',
      sections: [
        BloodLoreSection(
          title: 'No existe una visión única',
          body:
              'Según el lugar y la época, la sangre menstrual fue tratada '
              'como peligrosa, como tabú, como protectora, como poderosa, '
              'como ligada a la fertilidad y como capaz de alejar '
              'determinadas influencias. Todas esas lecturas aparecen en los '
              'registros, y a veces en la misma cultura.',
        ),
        BloodLoreSection(
          title: 'Por qué importa',
          body:
              'La frase "antiguamente la sangre menstrual se consideraba '
              'sagrada" circula mucho y no se sostiene como afirmación '
              'universal. Hubo reverencia en algunos lugares y prohibición '
              'severa en otros. La ambivalencia es el hallazgo, no un detalle '
              'incómodo.',
        ),
        BloodLoreSection(
          title: 'Qué hacer con eso',
          body:
              'Saber que no hay consenso te devuelve la elección. Ninguna '
              'tradición decide sola lo que menstruar significa en tu '
              'práctica.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'amor-e-ligacao',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '❤️',
      title: 'Amor y ligadura',
      summary:
          'El uso más recurrente de la sangre menstrual en la magia amorosa '
          'registrada',
      sections: [
        BloodLoreSection(
          title: 'Lo que muestran los registros',
          body:
              'Entre los usos de la sangre menstrual que más aparecen en '
              'procesos, recetarios y colecciones de folclore, la magia '
              'amorosa va primero. Hay registros de prácticas en las que la '
              'sangre se ponía a escondidas en la comida o la bebida de la '
              'persona deseada para producir deseo, ligadura, afecto o '
              'sumisión.',
        ),
        BloodLoreSection(
          title: 'Esto es historia, no instrucción',
          body:
              'El Grimorio cuenta esta práctica porque es parte de la '
              'historia de la magia. No la convierte en paso a paso: implica '
              'un fluido corporal, una persona que no eligió participar y un '
              'riesgo sanitario real.',
        ),
        BloodLoreSection(
          title: 'Lo que sí cabe aquí',
          body:
              'La misma intención — atracción, magnetismo, apertura — puede '
              'trabajarse sobre ti misma, sin tocar lo que es de otra '
              'persona.',
        ),
      ],
      cta: BloodLoreCta(
        label: 'Explorar un encanto de atracción',
        link: BloodLoreLink.entry,
        entryId: 'encanto-de-atracao',
      ),
    ),
    BloodLoreEntry(
      id: 'protecao',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '🛡️',
      title: 'Protección',
      summary:
          'Contramagia, casa y umbrales: la otra cara de los mismos '
          'registros',
      sections: [
        BloodLoreSection(
          title: 'Fuerza que repele',
          body:
              'Una idea atraviesa muchas fuentes: aquello que se considera '
              'mágicamente fuerte — o peligroso — también sirve para alejar '
              'otra influencia. Por eso el mismo material que aparece en '
              'prohibiciones aparece en protecciones.',
        ),
        BloodLoreSection(
          title: 'Casa y umbrales',
          body:
              'Puertas, umbrales, ventanas y cercas son los puntos donde '
              'suele ponerse la protección doméstica, en tradiciones muy '
              'distintas entre sí. La sangre menstrual aparece en ese '
              'conjunto en parte de los registros, junto a sal, hierro, '
              'hierbas y símbolos trazados.',
        ),
        BloodLoreSection(
          title: 'Contramagia',
          body:
              'En varios cuerpos de relatos se la cita como recurso contra el '
              'hechizo ajeno, y no como hechizo de ataque.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'vinculo-e-poder',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.contemporary,
      emoji: '🔮',
      title: 'Vínculo y poder personal',
      summary: 'Materia del propio cuerpo como firma mágica',
      sections: [
        BloodLoreSection(
          title: 'La firma',
          body:
              'Si la materia del cuerpo crea vínculo, la materia de tu cuerpo '
              'crea vínculo contigo. Es la lectura contemporánea más común: '
              'usar algo tuyo para firmar un gesto, marcar un compromiso, '
              'reforzar una intención.',
        ),
        BloodLoreSection(
          title: 'Dónde suele entrar',
          body:
              'Compromisos contigo misma, protección personal, '
              'fortalecimiento de una intención, trabajos de identidad y de '
              'poder personal. El foco eres siempre tú — nunca la voluntad de '
              'otra persona.',
        ),
        BloodLoreSection(
          title: 'De dónde viene',
          body:
              'La idea de que la materia del cuerpo firma es antigua. '
              'Volverla hacia una misma como práctica de autonomía es '
              'reciente, y viene de la brujería contemporánea.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'vida-e-terra',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.tradition,
      emoji: '🌱',
      title: 'Vida, fertilidad y naturaleza',
      summary: 'Tradiciones específicas ligan esta sangre a lo que crece',
      sections: [
        BloodLoreSection(
          title: 'Un recorte, no una regla',
          body:
              'Existen tradiciones que asocian la sangre menstrual con la '
              'fertilidad, los campos, el cultivo, la vida y los ciclos '
              'naturales. Son tradiciones específicas, de lugares y épocas '
              'específicos — no un significado universal del cuerpo.',
        ),
        BloodLoreSection(
          title: 'Cómo aparece',
          body:
              'En parte de esos relatos el gesto descrito es devolver la '
              'sangre a la tierra o a las plantas de la casa, como '
              'restitución: lo que vino del cuerpo vuelve a lo que alimenta '
              'al cuerpo.',
        ),
        BloodLoreSection(
          title: 'El cuidado al leer',
          body:
              'Convertir estos casos en "todas las culturas antiguas" es el '
              'error más común cuando se habla del tema. Aquí se quedan donde '
              'están: como tradiciones, con lugar y época.',
        ),
      ],
    ),

    // ── Ciclo y Luna ──────────────────────────────────────────────────────
    BloodLoreEntry(
      id: 'duas-rodas',
      category: BloodLoreCategory.cycleAndMoon,
      tag: BloodLoreTag.contemporary,
      emoji: '🌙',
      title: 'Dos ruedas que se encuentran',
      summary: 'La Luna como correspondencia y herramienta de observación',
      sections: [
        BloodLoreSection(
          title: 'Dos calendarios redondos',
          body:
              'El ciclo lunar dura unos veintinueve días y medio. El ciclo '
              'menstrual varía de persona a persona y de vuelta a vuelta. Los '
              'dos son redondos, y de ahí viene la analogía — no de que uno '
              'mande sobre el otro.',
        ),
        BloodLoreSection(
          title: 'Qué hace la magia lunar con eso',
          body:
              'En la magia cada fase lleva una correspondencia: lo que crece, '
              'lo que está lleno, lo que se recoge, lo que vuelve a empezar. '
              'Poner tu comienzo junto a la fase de aquel día es usar esa '
              'correspondencia como lente, igual que se usa la rueda del año.',
        ),
        BloodLoreSection(
          title: 'Lo que esto no es',
          body:
              'El ciclo lunar y el menstrual no necesitan estar '
              'sincronizados, y no hay motivo para esperar que lo estén. '
              'Observa cómo se encuentran los dos a lo largo del tiempo, si '
              'eso tiene sentido para tu práctica.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'interpretacoes-contemporaneas',
      category: BloodLoreCategory.cycleAndMoon,
      tag: BloodLoreTag.contemporary,
      emoji: '✨',
      title: 'Interpretaciones contemporáneas',
      summary: 'Luna Blanca, Luna Roja y otras categorías recientes',
      sections: [
        BloodLoreSection(
          title: 'De dónde vienen',
          body:
              'Las categorías de Luna Blanca, Luna Roja, Luna Rosa y Luna '
              'Púrpura son creación de finales del siglo XX y circulan en '
              'libros y cursos de ahora. No son tradición antigua y no '
              'aparecen en fuentes históricas.',
        ),
        BloodLoreSection(
          title: 'Por qué no son la base de aquí',
          body:
              'Clasifican a la persona por la fase en que sangra y suelen '
              'ligar cada categoría a un papel — maternidad, sanación, '
              'enseñanza. El Grimorio no hace esa clasificación: lo que '
              'muestra es tu Luna y tu comienzo, lado a lado.',
        ),
        BloodLoreSection(
          title: 'Si quieres usarlas',
          body:
              'Nada lo impide. Solo vale la pena saber la edad de la idea '
              'antes de adoptarla, y recordar que describe una lectura, no tu '
              'cuerpo.',
        ),
      ],
    ),

    // ── Prácticas y hechizos ──────────────────────────────────────────────
    BloodLoreEntry(
      id: 'selo-do-limiar',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.modernAdaptation,
      emoji: '🛡️',
      title: 'Sello del Umbral',
      summary: 'Un símbolo de protección guardado cerca de la puerta',
      intention: 'Protección de la casa.',
      materials: [
        'Un papel pequeño',
        'Un bolígrafo',
        'Un sobre o un recipiente que cierre',
        'Una cantidad mínima de tu propia sangre menstrual, si quieres',
      ],
      steps: [
        'Elige o dibuja un símbolo personal de protección — una letra, un '
            'trazo, un sigilo tuyo.',
        'Escribe o dibuja el símbolo en el papel.',
        'Si quieres trabajar con tu sangre menstrual, haz una marca mínima en '
            'el papel y deja secar por completo.',
        'Dobla el papel, ciérralo en el sobre y guárdalo cerca de la entrada '
            'de la casa.',
      ],
      withoutBlood:
          'Sin sangre la práctica es la misma: el símbolo dibujado, el papel '
          'cerrado y guardado en el umbral. Si quieres marcarlo con algo '
          'tuyo, tu letra o una gota de un aceite que uses cumplen ese papel.',
      sections: [
        BloodLoreSection(
          title: 'De dónde viene',
          body:
              'Adaptada de registros que ligan la sangre menstrual a la '
              'protección de umbrales y a la contramagia doméstica. Guardar '
              'el papel cerrado es un gesto de ahora: las fuentes antiguas no '
              'describen así esta práctica.',
        ),
        BloodLoreSection(
          title: 'Un cuidado',
          body:
              'No esparzas sangre por la casa, por los muebles ni por '
              'superficies compartidas. La marca es mínima, seca y queda '
              'dentro de un papel cerrado.',
        ),
      ],
      mentionsBlood: true,
    ),
    BloodLoreEntry(
      id: 'laco-de-compromisso',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.modernAdaptation,
      emoji: '🔗',
      title: 'Lazo de compromiso',
      summary: 'Una frase que quieres sostener, doblada y atada',
      intention: 'Firmar un compromiso contigo misma.',
      materials: [
        'Papel y bolígrafo',
        'Hilo o cordón',
        'Una cantidad mínima de tu propia sangre menstrual, si quieres',
      ],
      steps: [
        'Escribe una frase corta, en presente, sobre algo que quieras '
            'sostener: "Protejo mi tiempo", "Termino lo que empiezo", '
            '"Mantengo este límite".',
        'Si quieres, haz una marca mínima de tu sangre en el papel y espera a '
            'que seque por completo.',
        'Dobla el papel hacia ti, nunca hacia afuera.',
        'Átalo con el hilo y guárdalo donde vayas a encontrarlo de nuevo.',
      ],
      withoutBlood:
          'Sin sangre, firma el papel con tu nombre o con tu propia letra. Lo '
          'que firma es el gesto de escribir, no el material.',
      sections: [
        BloodLoreSection(
          title: 'De dónde viene',
          body:
              'Adaptación moderna de la magia de vínculo: el mismo '
              'razonamiento de atar y doblar hacia una misma, dirigido a un '
              'compromiso personal en lugar de a otra persona.',
        ),
        BloodLoreSection(
          title: 'El foco',
          body:
              'El trabajo es sobre ti. Un vínculo dirigido a quien no eligió '
              'participar es otra cosa, y no es lo que hace esta práctica.',
        ),
      ],
      mentionsBlood: true,
    ),
    BloodLoreEntry(
      id: 'encanto-de-atracao',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.modernAdaptation,
      emoji: '❤️',
      title: 'Encanto de atracción',
      summary: 'Atracción y apertura, sin dirigirse a nadie',
      intention:
          'Atracción, magnetismo, autoestima y apertura a las relaciones que '
          'deseas.',
      materials: [
        'Papel y bolígrafo',
        'Un sigilo tuyo, si quieres crear uno',
        'Un perfume o aceite que uses',
        'Un objeto personal que se quede contigo',
        'Una cantidad mínima de tu propia sangre menstrual, si quieres',
      ],
      steps: [
        'Escribe la intención sin dirigirla a nadie: "Que aquello que me '
            'desea y me hace bien encuentre camino hasta mí".',
        'Si quieres, convierte la frase en un sigilo — el Grimorio ya tiene '
            'un creador de sigilos.',
        'Pon el perfume en el objeto personal.',
        'Si quieres trabajar con tu sangre menstrual, haz una marca mínima en '
            'el papel del sigilo y deja secar por completo.',
        'Lleva el objeto contigo mientras la intención siga en pie.',
      ],
      withoutBlood:
          'Sin sangre, el perfume y el objeto personal ya son el material '
          'tuyo que el encanto pide.',
      sections: [
        BloodLoreSection(
          title: 'De dónde viene',
          body:
              'Adaptación contemporánea. No es la magia amorosa de los '
              'registros históricos, que actuaba sobre una persona concreta '
              'sin que ella lo supiera.',
        ),
        BloodLoreSection(
          title: 'El foco',
          body:
              'El encanto no se dirige a nadie. Trabaja lo que parte de ti: '
              'atracción, autoestima y apertura. Nunca pongas sangre — ni '
              'ningún otro fluido — en lo que pertenece a otra persona.',
        ),
      ],
      mentionsBlood: true,
      cta: BloodLoreCta(
        label: 'Crear un sigilo',
        link: BloodLoreLink.sigils,
      ),
    ),
    BloodLoreEntry(
      id: 'consagracao-de-sigilo',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.contemporary,
      emoji: '🕯️',
      title: 'Consagración de sigilo',
      summary: 'Dar carga personal a un sigilo que creaste',
      intention: 'Consagrar un sigilo con algo que es tuyo.',
      materials: [
        'Un sigilo creado por ti',
        'Papel y bolígrafo',
        'Una vela, si quieres',
        'Una cantidad mínima de tu propia sangre menstrual, si quieres',
      ],
      steps: [
        'Crea el sigilo en el Grimorio, a partir de una intención de una '
            'palabra.',
        'Copia el trazo del sigilo en un papel, a mano.',
        'Sostén el papel y di la intención en voz alta, una vez.',
        'Si quieres, marca el papel con una cantidad mínima de tu sangre y '
            'deja secar por completo.',
        'Guarda el papel donde puedas verlo, o ciérralo y guárdalo donde '
            'nadie lo toque.',
      ],
      withoutBlood:
          'Sin sangre, usa tu respiración sobre el papel, la llama de una '
          'vela o simplemente tu propia letra. La consagración es el gesto de '
          'dedicar, y no depende del material.',
      sections: [
        BloodLoreSection(
          title: 'De dónde viene',
          body:
              'Práctica contemporánea. Consagrar un objeto con algo de quien '
              'practica es un gesto antiguo; el sigilo tal como lo usa hoy la '
              'brujería viene del siglo XX.',
        ),
      ],
      mentionsBlood: true,
      cta: BloodLoreCta(
        label: 'Abrir el creador de sigilos',
        link: BloodLoreLink.sigils,
      ),
    ),
    BloodLoreEntry(
      id: 'ritual-de-encerramento',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.contemporary,
      emoji: '🍂',
      title: 'Ritual de cierre',
      summary: 'Nombrar y soltar lo que llegó a su fin',
      intention: 'Nombrar y soltar algo que llegó a su fin.',
      materials: [
        'Papel y bolígrafo',
        'Una vela, si quieres',
        'Un recipiente seguro, si vas a quemar',
      ],
      steps: [
        'Escribe, sin intentar resolverlo, lo que no quieres llevar a la '
            'próxima vuelta.',
        'Lee lo que escribiste una vez, en voz alta o en silencio.',
        'Rompe el papel, quémalo en un recipiente seguro o guárdalo cerrado '
            'hasta la próxima vuelta.',
        'Si quieres seguir escribiendo, el Diario del Grimorio es el lugar.',
      ],
      sections: [
        BloodLoreSection(
          title: 'De dónde viene',
          body:
              'Práctica contemporánea. La relación simbólica entre el '
              'sangrado y la liberación es una lectura de ahora, y no una '
              'tradición antigua establecida.',
        ),
        BloodLoreSection(
          title: 'Un cuidado',
          body:
              'Si vas a quemar, usa un recipiente hecho para eso, lejos de '
              'cortinas y de cualquier cosa que prenda fuego.',
        ),
      ],
      cta: BloodLoreCta(
        label: 'Escribir en el Diario',
        link: BloodLoreLink.diary,
      ),
    ),

    // ── Tradiciones e historia ────────────────────────────────────────────
    BloodLoreEntry(
      id: 'filtro-de-sangue',
      category: BloodLoreCategory.traditions,
      tag: BloodLoreTag.documented,
      emoji: '📜',
      title: 'Filtro de sangre menstrual',
      summary:
          'La práctica amorosa más registrada — y por qué no se convierte en '
          'tutorial',
      sections: [
        BloodLoreSection(
          title: 'Lo que describen los registros',
          body:
              'En actas de procesos, recetarios de magia popular y '
              'colecciones de folclore aparece con frecuencia la misma '
              'práctica: poner a escondidas una pequeña cantidad de sangre '
              'menstrual en la comida o la bebida de la persona deseada, para '
              'crear ligadura, deseo o sumisión.',
        ),
        BloodLoreSection(
          title: 'La lógica mágica',
          body:
              'Una sustancia que pertenece a quien hace el hechizo sería '
              'incorporada por el objetivo. Al pasar dentro de su cuerpo, '
              'establecería simbólicamente el vínculo — la misma idea de que '
              'la materia del cuerpo liga a las personas, llevada al límite.',
        ),
        BloodLoreSection(
          title: 'Por qué el Grimorio no lo enseña',
          body:
              'Porque la práctica implica un fluido corporal, el alimento o '
              'la bebida de otra persona, la ausencia de consentimiento y un '
              'riesgo sanitario real. Describir lo que la historia registró es '
              'una cosa; dar el paso a paso es otra.',
        ),
      ],
      cta: BloodLoreCta(
        label: 'Explorar un encanto de atracción',
        link: BloodLoreLink.entry,
        entryId: 'encanto-de-atracao',
      ),
    ),
    BloodLoreEntry(
      id: 'onde-os-registros-estao',
      category: BloodLoreCategory.traditions,
      tag: BloodLoreTag.documented,
      emoji: '🗂️',
      title: 'Dónde están los registros',
      summary: 'Cómo sabemos lo que sabemos — y qué no se puede saber',
      sections: [
        BloodLoreSection(
          title: 'Las fuentes',
          body:
              'Lo que se sabe sobre magia con sangre menstrual viene sobre '
              'todo de tres lugares: actas de procesos, donde la práctica la '
              'describe quien acusa; recetarios y manuales de magia popular; '
              'y colecciones de folclore hechas entre los siglos XIX y XX.',
        ),
        BloodLoreSection(
          title: 'Lo que eso distorsiona',
          body:
              'Ninguna de esas fuentes es neutra. Un proceso registra lo que '
              'el tribunal quiso oír; quien recoge folclore escribe lo que '
              'entendió. Lo que nos llega son prácticas reales vistas desde '
              'fuera.',
        ),
        BloodLoreSection(
          title: 'Lo que queda en pie',
          body:
              'La recurrencia. Cuando el mismo gesto aparece en fuentes que '
              'no se hablan entre sí, es razonable decir que existía. Cuando '
              'aparece una sola vez, es un relato — y así queda marcado aquí.',
        ),
      ],
    ),
  ],
);
