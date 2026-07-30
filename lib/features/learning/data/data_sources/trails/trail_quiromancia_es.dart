import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Ruta 'quiromancia' — contenido en español.
/// La paridad con _pt/_en se verifica en test/trails_parity_test.dart.
const LearningTrail quiromanciaTrailEs = LearningTrail(
  id: 'quiromancia',
  emoji: '🖐️',
  title: 'Quiromancia',
  subtitle: 'La lectura técnica de las manos',
  description:
      'El arte de leer las manos con método: forma, líneas, montes, dedos y marcas. Nueve lecciones que enseñan a observar de verdad — y no solo a imaginar.',
  lessons: [
    TrailLesson(
      id: 'qm_01',
      recordKind: LessonRecordKind.note,
      title: 'La mano como mapa',
      teaching:
          'La quiromancia (del griego cheir, mano, y manteia, adivinación) parte de una idea simple: la mano registra a la persona. Forma, textura, líneas y relieves componen un mapa del temperamento y de las tendencias de quien los lleva. Leer manos no es predecir un destino fijo — es observar inclinaciones naturales y cómo cambian a lo largo de la vida, porque las líneas realmente se transforman con los años.\n\nDos distinciones técnicas abren cualquier lectura. La primera es entre mano dominante y mano pasiva (o de nacimiento): la pasiva — la que usas menos — muestra el potencial heredado, el "material de origen"; la dominante muestra lo que hiciste con él, el presente y la dirección. Comparar las dos es la mitad de la lectura. La segunda distinción separa la quirognomía (el estudio de la forma de la mano y de los dedos, más ligado al carácter) de la quiromancia propiamente dicha (el estudio de las líneas y marcas).\n\nAntes de mirar cualquier línea, la lectura seria comienza por el conjunto: cuál es la mano dominante, cómo es la textura de la piel, el color, la flexibilidad, la temperatura, si la mano está tensa o relajada. Una mano firme y cálida habla distinto de una mano blanda y fría. Guarda la regla de oro del quiromante honesto: describe lo que ves, nunca inventes lo que no está ahí, y trata cada marca como una tendencia por comprender, jamás como una sentencia.',
      practice:
          'En esta práctica vas a conocer tus propias manos como una lectora. Primero, identifica tu mano dominante y tu mano pasiva. Después, obsérvalas lado a lado bajo buena luz y anota las diferencias generales: cuál tiene más líneas, cuál tiene la piel más firme, cuál parece más "movida". Por último, registra tus primeras impresiones. El objetivo es entrenar la mirada de conjunto antes de sumergirte en las líneas.',
      pageTitle: 'El Mapa de Mis Manos',
      pagePurpose: 'Registrar la lectura inicial de conjunto de las dos manos',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Tus dos manos', 'Buena iluminación'],
      pagePrompts: [
        'Mi mano dominante y mi mano pasiva:',
        'Diferencias generales que percibo entre ellas:',
        'Textura, temperatura y flexibilidad que observé:',
        'Mis primeras impresiones sobre lo que cuentan las manos:',
      ],
    ),
    TrailLesson(
      id: 'qm_02',
      recordKind: LessonRecordKind.note,
      title: 'La forma de la mano: los cuatro elementos',
      teaching:
          'La quirognomía clásica clasifica las manos en cuatro tipos elementales, cruzando la forma de la palma con la longitud de los dedos. Es el primer dato técnico de cualquier lectura, porque encuadra todo lo que viene después. La regla: compara la longitud de la palma (de la muñeca a la base de los dedos) con la longitud de los dedos medios.\n\nMano de Tierra — palma cuadrada y dedos cortos. Personas prácticas, estables, ligadas al cuerpo y a lo concreto; manos firmes, pocas líneas, piel más gruesa. Mano de Aire — palma cuadrada y dedos largos. Mente ágil, comunicación, curiosidad; muchas líneas finas y nítidas. Mano de Fuego — palma rectangular (más larga que ancha) y dedos cortos. Energía, acción, entusiasmo, impaciencia; líneas marcadas y vívidas. Mano de Agua — palma larga y estrecha y dedos largos. Sensibilidad, imaginación, emoción; piel suave y una red de líneas delicadas.\n\nEn la práctica, la forma rara vez es "pura" — la mayoría de las manos mezcla dos elementos, y es justamente esa combinación la que individualiza la lectura. El error común de la principiante es memorizar etiquetas y forzar la mano a caber en una de ellas. Haz lo contrario: mide, compara y describe la mezcla. El elemento de la mano da el tono emocional y práctico de fondo; las líneas, que veremos a continuación, cuentan la historia sobre ese fondo.',
      practice:
          'En esta práctica vas a clasificar la forma de tu mano. Primero, mide (a ojo o con una regla) la palma y los dedos de la mano dominante. Después, cruza palma cuadrada/rectangular con dedos cortos/largos e identifica el elemento — o la mezcla de dos. Por último, mira si el temperamento del elemento resuena contigo. El objetivo es anclar la lectura en la forma antes de mirar las líneas.',
      pageTitle: 'El Elemento de Mi Mano',
      pagePurpose: 'Clasificar el tipo elemental de la mano y lo que revela',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Tu mano dominante', 'Regla (opcional)'],
      pagePrompts: [
        'Forma de la palma (cuadrada o rectangular) y de los dedos (cortos o largos):',
        'Mi elemento dominante (Tierra, Aire, Fuego o Agua) — o la mezcla:',
        'Lo que el temperamento de ese elemento dice sobre mí:',
        'Cuánto resuena esto con cómo me veo:',
      ],
    ),
    TrailLesson(
      id: 'qm_03',
      recordKind: LessonRecordKind.note,
      title: 'La Línea de la Vida',
      teaching:
          'La Línea de la Vida es la que nace entre el pulgar y el índice y desciende curvándose alrededor del monte de Venus (la base del pulgar). Es la línea peor comprendida de la quiromancia: al contrario del mito popular, su longitud NO mide cuánto tiempo vivirá alguien. Habla de vitalidad, fuerza física, entusiasmo por la vida y de los grandes cambios de rumbo.\n\nLo que se lee técnicamente en ella: la curvatura — cuanto más abierta, abrazando un monte de Venus amplio, más calor, vigor y generosidad física; cuanto más recta y pegada al pulgar, más reserva y cautela de energía. La profundidad y la nitidez indican la robustez de la vitalidad. Las ramificaciones hacia arriba suelen marcar fases de crecimiento y conquista; las islas (ese dibujo de ojo en la línea) sugieren períodos de energía dividida o salud por cuidar; las rupturas y superposiciones apuntan a cambios de vida — mudanzas de ciudad, de rumbo, de etapa — y no catástrofes.\n\nUn punto técnico importante: la Línea de la Vida se lee junto con el monte de Venus y la Línea del Destino, nunca sola. Una línea "corta" puede simplemente indicar que la vitalidad está sostenida por otra línea. Al practicar, resiste la tentación dramática de leer enfermedad o final donde solo hay una transición. Describe el trazado, localiza las señales y tradúcelas como capítulos de energía — abiertos, y no cerrados.',
      practice:
          'En esta práctica vas a mapear tu Línea de la Vida. Primero, localiza dónde nace y sigue su curva alrededor de la base del pulgar. Después, observa: ¿es abierta o está pegada al pulgar? ¿Es profunda o fina? ¿Tiene ramas, islas o rupturas? Por último, anota lo que cada trazo sugiere sobre tu vitalidad — sin convertir ninguna señal en sentencia. El objetivo es leer la línea más mitificada con método y serenidad.',
      pageTitle: 'Mi Línea de la Vida',
      pagePurpose: 'Registrar la lectura técnica de la Línea de la Vida',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Tu mano dominante', 'Buena luz'],
      pagePrompts: [
        'Cómo es el trazado de mi Línea de la Vida (curva, profundidad):',
        'Ramas, islas o rupturas que encontré — y dónde:',
        'Lo que sugiere sobre mi vitalidad y mis giros de vida:',
        'Un mito sobre esta línea que dejo atrás:',
      ],
    ),
    TrailLesson(
      id: 'qm_04',
      recordKind: LessonRecordKind.note,
      title: 'La Línea de la Cabeza',
      teaching:
          'La Línea de la Cabeza atraviesa la palma horizontalmente, más o menos por el medio, y habla del intelecto: cómo piensas, aprendes, decides y te concentras. Suele nacer cerca del inicio de la Línea de la Vida, entre el pulgar y el índice, y sigue hacia el borde opuesto de la mano. Su lectura es una de las más reveladoras del temperamento mental.\n\nLas señales técnicas: la longitud indica la amplitud del pensamiento — una línea larga, que cruza buena parte de la palma, sugiere una mente detallista y reflexiva; una corta, pensamiento directo y práctico. La inclinación es decisiva: una Línea de la Cabeza recta indica razonamiento lógico, objetivo, "con los pies en la tierra"; una que desciende curvándose hacia el monte de la Luna (la base de la palma, del lado opuesto al pulgar) indica imaginación, creatividad y mente asociativa. La profundidad habla de foco y memoria; las islas y cadenas indican períodos de dispersión o preocupación.\n\nUn detalle clásico e importante es cómo comienza: unida a la Línea de la Vida en su nacimiento sugiere cautela, apego a la familia y prudencia al actuar; separada de ella desde el inicio sugiere independencia precoz e impulsividad. Al leer, cruza siempre la Línea de la Cabeza con la del Corazón — juntas muestran el equilibrio entre razón y emoción de la persona. Describe la dirección, la nitidez y el punto de partida antes de cualquier conclusión.',
      practice:
          'En esta práctica vas a leer tu Línea de la Cabeza. Primero, localízala en el medio de la palma y sigue su trayecto. Después, observa: ¿es recta (lógica) o desciende hacia la Luna (imaginativa)? ¿Es larga o corta? ¿Nace unida o separada de la Línea de la Vida? Por último, registra lo que revela sobre tu manera de pensar y decidir. El objetivo es reconocer el propio estilo mental en la palma.',
      pageTitle: 'Mi Línea de la Cabeza',
      pagePurpose: 'Registrar la lectura de la Línea de la Cabeza y del estilo mental',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Tu mano dominante', 'Buena luz'],
      pagePrompts: [
        'Dirección de mi Línea de la Cabeza (recta o curvada hacia la Luna):',
        'Longitud y nitidez — y cómo nace (unida o separada de la Vida):',
        'Lo que esto dice sobre cómo pienso y decido:',
        'Dónde se equilibran en mí la razón y la emoción:',
      ],
    ),
    TrailLesson(
      id: 'qm_05',
      recordKind: LessonRecordKind.note,
      title: 'La Línea del Corazón',
      teaching:
          'La Línea del Corazón es la más alta de las tres grandes líneas, y corre horizontalmente bajo los dedos. Habla de la vida afectiva: cómo amas, te vinculas, expresas la emoción y cuidas las relaciones. Se lee desde el borde de la mano (lado del meñique) hacia los dedos índice y medio.\n\nLa técnica mira primero dónde termina. Una Línea del Corazón que sube y termina bajo el índice (monte de Júpiter) indica idealismo en el amor, entrega y estándares altos; terminando bajo el medio (monte de Saturno) sugiere un afecto más realista, contenido, a veces más volcado al deseo que al romance; terminando entre los dos, un equilibrio maduro. Una línea larga y curva expresa las emociones con calor y apertura; una corta y recta indica reserva o dificultad para verbalizar sentimientos. Las ramas hacia arriba marcan relaciones felices y conexiones importantes; las ramas hacia abajo, decepciones que enseñaron; las cadenas e islas, períodos de inestabilidad afectiva.\n\nEl error común es buscar en la Línea del Corazón el "número de grandes amores" o fechas exactas — la quiromancia seria no hace eso. Lo que esta línea entrega es el estilo emocional: cálido o reservado, idealista o pragmático, generoso o protegido. Léela junto con la Línea de la Cabeza para entender cómo conversan pensamiento y sentimiento en la persona, y describe siempre la tendencia, con respeto y sin drama.',
      practice:
          'En esta práctica vas a leer tu Línea del Corazón. Primero, localízala bajo los dedos y mira dónde termina (bajo el índice, el medio o entre ellos). Después, observa si es larga y curva o corta y recta, y busca ramas hacia arriba y hacia abajo. Por último, anota lo que revela sobre tu estilo de amar. El objetivo es reconocer tu firma emocional con gentileza.',
      pageTitle: 'Mi Línea del Corazón',
      pagePurpose: 'Registrar la lectura de la Línea del Corazón y del estilo afectivo',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Tu mano dominante', 'Buena luz'],
      pagePrompts: [
        'Dónde termina mi Línea del Corazón y lo que eso sugiere:',
        '¿Es larga y curva o corta y recta? Ramas que encontré:',
        'Lo que revela sobre mi manera de amar y vincularme:',
        'Cómo conversan mi corazón y mi cabeza:',
      ],
    ),
    TrailLesson(
      id: 'qm_06',
      recordKind: LessonRecordKind.note,
      title: 'La Línea del Destino',
      teaching:
          'La Línea del Destino (o Línea de Saturno) es una línea vertical que sube desde la base de la palma hacia el dedo medio. No todo el mundo la tiene fuerte — y su ausencia no es mala suerte. Habla del sentido de rumbo, de la carrera, del hilo conductor que la persona siente (o no) en su trayectoria, y de las fuerzas externas que moldean el camino.\n\nTécnicamente, se observa de dónde parte. Naciendo de la base de la muñeca, sugiere un sentido de propósito desde temprano; naciendo del monte de la Luna, un camino muy influido por los demás, por el público o por el azar favorable; naciendo de la Línea de la Vida, una trayectoria construida por el esfuerzo propio. Una línea nítida y continua indica un rumbo estable; las interrupciones, cambios de dirección de carrera o de vida; una línea doble, la capacidad de llevar dos caminos al mismo tiempo. Cuando es débil o está ausente, la persona suele construir su propio rumbo con más libertad, sin un carril premarcado — lo cual es una lectura, no un veredicto.\n\nLa Línea del Destino es el mejor ejemplo de por qué la quiromancia lee tendencias y no sentencias: cambia visiblemente a lo largo de la vida según las elecciones. Por eso se lee al final entre las verticales y siempre en diálogo con la Línea de la Cabeza (las decisiones) y la de la Vida (la energía). Describe el origen, la continuidad y los giros — y recuerda que aquí el mapa lo dibuja, en buena parte, la propia persona.',
      practice:
          'En esta práctica vas a buscar tu Línea del Destino. Primero, mira si hay una línea vertical subiendo hacia el dedo medio — y no te preocupes si es débil o está ausente. Después, si existe, observa de dónde parte y si es continua o tiene giros. Por último, anota lo que sugiere sobre tu sentido de rumbo. El objetivo es entender la línea que más cambia con las elecciones.',
      pageTitle: 'Mi Línea del Destino',
      pagePurpose: 'Registrar la lectura de la Línea del Destino y del sentido de rumbo',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Tu mano dominante', 'Buena luz'],
      pagePrompts: [
        '¿Tengo Línea del Destino fuerte, débil o ausente? De dónde parte:',
        'Continuidad y giros que observé en ella:',
        'Lo que sugiere sobre mi sentido de rumbo y carrera:',
        'De qué forma siento que construyo mi propio camino:',
      ],
    ),
    TrailLesson(
      id: 'qm_07',
      recordKind: LessonRecordKind.note,
      title: 'Los montes',
      teaching:
          'Los montes son las almohadillas de carne de la palma, cada una asociada a un astro y a un conjunto de cualidades. Leer los montes es evaluar cuáles están más desarrollados (altos, firmes, rosados) y cuáles más apagados — porque el relieve muestra dónde se concentra la energía de la persona. Es la parte de la quiromancia más cercana a la astrología.\n\nLos principales: el monte de Venus, en la base del pulgar, habla de amor, sensualidad, vitalidad y afecto por la vida — lleno y firme, calor y generosidad; aplanado, reserva. El monte de Júpiter, bajo el índice, rige la ambición, el liderazgo y la autoconfianza. El de Saturno, bajo el medio, habla de responsabilidad, disciplina e introspección. El de Apolo (o del Sol), bajo el anular, rige la creatividad, la expresión y el brillo. El de Mercurio, bajo el meñique, la comunicación, la astucia y los negocios. El monte de la Luna, en la base de la palma del lado opuesto al pulgar, rige la imaginación, la intuición y el mundo de los sueños. Y los montes de Marte (dos, uno activo entre el pulgar y el índice, otro pasivo del lado opuesto) hablan de coraje, combatividad y resistencia.\n\nLa técnica es comparativa: ningún monte se lee solo. Observas cuál se destaca — ese "gana" y colorea el temperamento — y cómo se equilibran los demás. Un Júpiter alto con un Saturno apagado dibuja a una persona; lo inverso, a otra. Las marcas sobre un monte (una cruz, una estrella, una rejilla) intensifican o perturban su cualidad, tema de la próxima lección. Al practicar, palpa suavemente y compara los relieves — describe dónde vive tu energía.',
      practice:
          'En esta práctica vas a mapear tus montes. Primero, con la mano relajada y levemente curvada, observa y palpa las almohadillas bajo cada dedo y en la base del pulgar y de la palma. Después, identifica cuáles son más llenas y firmes y cuáles más apagadas. Por último, anota qué monte se destaca y lo que eso dice de ti. El objetivo es localizar dónde se concentra tu energía.',
      pageTitle: 'Mis Montes',
      pagePurpose: 'Registrar qué montes se destacan y lo que revelan',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Tu mano dominante', 'Buena luz'],
      pagePrompts: [
        'Mi monte más desarrollado (Venus, Júpiter, Saturno, Apolo, Mercurio, Luna o Marte):',
        'Montes más apagados que percibí:',
        'Lo que ese equilibrio dice sobre dónde vive mi energía:',
        'Cómo dialoga esto con el elemento de mi mano:',
      ],
    ),
    TrailLesson(
      id: 'qm_08',
      recordKind: LessonRecordKind.note,
      title: 'Dedos, pulgar y marcas especiales',
      teaching:
          'Además de líneas y montes, el quiromante lee los dedos, el pulgar y las pequeñas marcas. Los dedos reciben los nombres de los mismos astros de los montes que tocan: Júpiter (índice), Saturno (medio), Apolo (anular) y Mercurio (meñique). Se evalúa la longitud relativa, la rectitud o inclinación, y la forma de las puntas — puntiagudas (idealismo, sensibilidad), cónicas (arte, intuición), cuadradas (orden, practicidad) o espatuladas (energía, inquietud). Un dedo de Apolo largo, por ejemplo, refuerza la expresión creativa; un Mercurio algo torcido, sagacidad con las palabras.\n\nEl pulgar es considerado por muchos quiromantes el dato más importante de la mano, porque representa la fuerza de voluntad y la razón. Se mira su tamaño (un pulgar grande y firme indica voluntad fuerte), la flexibilidad de la punta (rígida: terquedad y principios firmes; flexible: adaptabilidad, generosidad) y el ángulo de apertura en relación con la mano (abierto: mente libre y generosa; cerrado: cautela y reserva). La falange de la voluntad (la punta) y la de la lógica (la del medio) deben compararse: cuál es más larga muestra si la persona se mueve más por querer o por razonar.\n\nPor último, las marcas menores sobre líneas y montes afinan la lectura: la isla (debilita, divide), la cruz (obstáculo o punto de giro), la estrella (evento intenso, brillo o choque, según el lugar), la rejilla (energía bloqueada o dispersa), el cuadrado (protección, reparación) y el triángulo (talento). Ninguna marca se lee aislada — modifica la cualidad del lugar donde aparece. El buen lector describe la marca, el lugar y la interacción, siempre como matiz, nunca como destino sellado.',
      practice:
          'En esta práctica vas a leer tus dedos y tu pulgar. Primero, compara la longitud y la forma de las puntas de los cuatro dedos. Después, estudia el pulgar: tamaño, flexibilidad de la punta y ángulo de apertura. Por último, busca una marca especial (isla, cruz, estrella, rejilla, cuadrado) en alguna línea o monte y anota dónde está. El objetivo es afinar la mirada para los detalles que individualizan la lectura.',
      pageTitle: 'Mis Dedos, Pulgar y Marcas',
      pagePurpose: 'Registrar la lectura de los dedos, del pulgar y de las marcas',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Tus dos manos', 'Buena luz'],
      pagePrompts: [
        'Forma de las puntas de mis dedos y lo que refuerzan:',
        'Mi pulgar (tamaño, flexibilidad, ángulo) y lo que dice de mi voluntad:',
        'Una marca especial que encontré y dónde está:',
        'Cómo esa marca colorea la cualidad de ese lugar:',
      ],
    ),
    TrailLesson(
      id: 'qm_09',
      recordKind: LessonRecordKind.note,
      tool: LessonTool.palmistry,
      title: 'La lectura completa',
      teaching:
          'Una lectura completa no es la suma de fragmentos: es una síntesis. El quiromante experimentado sigue un orden que integra todo lo que aprendiste. Primero el conjunto — mano dominante y pasiva, textura, elemento de la forma. Después las tres grandes líneas en la secuencia clásica: Vida (energía), Cabeza (mente), Corazón (afecto). Luego la Línea del Destino (rumbo). Entonces los montes (donde vive la energía) y, por último, dedos, pulgar y marcas (los matices). Cada capa se lee a la luz de las anteriores.\n\nEl arte está en cruzar los datos en vez de enumerarlos. Una Línea de la Cabeza imaginativa sobre una mano de Agua, con un monte de la Luna alto, cuentan la misma historia por tres caminos — y esa convergencia es lo que da confianza a la lectura. Las contradicciones también informan: una Línea del Corazón reservada en una mano de Fuego revela una tensión interesante entre calor y protección. Comparar la mano pasiva con la dominante muestra el movimiento: lo que era potencial y lo que la persona desarrolló. El buen lector cuenta una narrativa coherente, no un horóscopo de cajón.\n\nDos éticas cierran el arte. Primera: la quiromancia lee tendencias, no sentencias — las líneas cambian, y nombrar caminos abiertos es más verdadero (y más útil) que clavar destinos. Segunda: lee con cuidado. Jamás hagas diagnósticos de salud, predicciones de muerte o promesas absolutas; devuelve siempre a la persona el poder de elegir. Ahora tienes el método. En esta última práctica, junta todo en una lectura tuya — y, si quieres, usa la Lectura de Manos de la app para comparar tu análisis con el del Consejero Místico.',
      practice:
          'En esta práctica harás tu primera lectura completa. Primero, recorre en orden: conjunto → Vida, Cabeza, Corazón → Destino → montes → dedos y marcas. Después, busca convergencias (datos que se repiten) y contrastes (tensiones interesantes) y escribe una síntesis en pocas frases. Por último, abre la Lectura de Manos de la app, fotografía tu palma y compara la lectura de la IA con la tuya. El objetivo es integrar todo el método en una narrativa coherente y tuya.',
      pageTitle: 'Mi Lectura Completa',
      pagePurpose: 'Integrar todo el método en una lectura de mano coherente',
      pageCategory: SpellCategory.divination,
      pageIngredients: ['Tus dos manos', 'Buena luz', 'La Lectura de Manos de la app'],
      pagePrompts: [
        'Mi síntesis del conjunto y de las tres grandes líneas:',
        'Convergencias que encontré (datos que se repiten):',
        'Contrastes interesantes entre líneas, montes y forma:',
        'Lo que la Lectura de Manos de la app agregó a mi análisis:',
      ],
    ),
  ],
);
