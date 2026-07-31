import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Ruta 'tarot' — contenido en español.
/// La paridad con _pt/_en se verifica en test/trails_parity_test.dart.
const LearningTrail tarotTrailEs = LearningTrail(
    id: 'tarot',
    emoji: '🎴',
    title: 'Tarot',
    subtitle: 'Las 78 puertas del autoconocimiento',
    description:
        'De cero a la lectura fluida: los arcanos, los palos y el arte de tejer historias con las cartas — entrenando en el Tutor de Tarot y registrando tus descubrimientos.',
    lessons: [
      TrailLesson(
        id: 'ta_01',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotLibrary,
        title: 'La baraja: un mapa en 78 cartas',
        teaching:
            'El tarot es un mapa de la experiencia humana dibujado en 78 cartas. Son 22 arcanos mayores, que retratan las grandes fuerzas y pasajes de la vida, y 56 arcanos menores, que describen lo cotidiano. Conocer ese mapa importa porque ofrece un espejo: cada carta nombra algo que ya viviste o que vivirás algún día, y nombrar es el primer paso para comprender.\n\nLos menores se dividen en cuatro palos, cada uno ligado a un elemento. Bastos es fuego y habla de acción, proyectos y pasión. Copas es agua y rige emociones, vínculos e intuición. Espadas es aire, el territorio de la mente, de las ideas y los conflictos. Oros es tierra: cuerpo, trabajo y materia. Así, un As de Bastos trae una chispa creativa, mientras un Diez de Copas muestra la plenitud afectiva de un hogar en paz.\n\nAntes de memorizar cualquier significado, toca las cartas. El tarot se aprende con las manos y con los ojos: observa los colores, gestos y paisajes de cada lámina. El error más común de la principiante es intentar memorizar 78 entradas de una vez y frustrarse. Prefiere visitas cortas y frecuentes a la baraja, dejando que las imágenes hablen primero y que el estudio venga después, como apoyo.\n\nLlévate esta idea: la baraja no es un código por descifrar, es un territorio por habitar. No necesitas dominar las 78 cartas hoy — solo necesitas empezar a caminar por ellas con curiosidad. Cada visita vuelve el mapa más familiar, y es la intimidad, no la prisa, lo que forma a una buena lectora.',
        practice:
            'Abre la Biblioteca de Cartas de la app y recorre las 78 cartas sin prisa, mirando la imagen antes de leer el significado. Al final, elige una carta que te atrajo y otra que te incomodó, y relee el texto de cada una con atención. Después registra en la página de esta lección lo que viste y sentiste. El objetivo es crear tu primer vínculo con la baraja: notar que ya conversa contigo antes de cualquier estudio formal.',
        pageTitle: 'Mi Encuentro con la Baraja',
        pagePurpose: 'Registrar el primer contacto con las 78 cartas',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'La carta que me ATRAJO y lo que vi en ella:',
          'La carta que me INCOMODÓ y lo que tocó en mí:',
          'Mi intuición: ¿por qué estas dos?',
          'Lo que espero aprender del tarot:',
        ],
      ),
      TrailLesson(
        id: 'ta_02',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'El Viaje del Loco (0-VII)',
        teaching:
            'Los arcanos mayores cuentan una historia continua, conocida como El Viaje del Loco. El Loco, la carta cero, parte sin equipaje y atraviesa las 21 láminas siguientes como etapas de maduración. Estudiar los mayores en orden importa porque transforma una lista suelta de cartas en una trama viva, que tu memoria abraza con mucha más facilidad.\n\nEn este primer tercio, el Loco encuentra a los primeros maestros: el Mago enseña la voluntad que realiza, la Suma Sacerdotisa guarda la intuición y el misterio, la Emperatriz rige la creación fértil, el Emperador da estructura y límites, el Hierofante transmite la tradición, los Enamorados presentan la elección que define caminos y el Carro celebra la victoria de la voluntad bien dirigida.\n\nPara estudiar, cuenta la historia en voz alta: el Loco salta, aprende con el Mago, calla con la Suma Sacerdotisa, y así sucesivamente. Asocia cada arcano a una palabra tuya, no a definiciones prestadas. El tropiezo común es confundir las parejas: recuerda que el Mago actúa y el Emperador organiza, que la Suma Sacerdotisa sabe en silencio y la Emperatriz genera en abundancia.\n\nGuarda esta clave: del 0 al VII aprendes las fuerzas básicas del mundo — voluntad, intuición, creación, orden, tradición, elección y dirección. Cuando una de estas cartas surja en una lectura, pregunta cuál de esas fuerzas pide paso en tu vida ahora. El Viaje ya comenzó, y tú ya caminas dentro de él.',
        practice:
            'Abre el Tutor de Tarot y haz una sesión de quiz dedicada a los arcanos mayores del 0 al VII. Responde con calma, intentando recordar la escena de cada carta antes de elegir la opción. Repite las preguntas que falles hasta acertarlas con seguridad. Al terminar, anota en la página de esta lección qué arcanos todavía se confunden en tu cabeza. El objetivo es fijar el primer tercio de El Viaje del Loco con repetición amable, sin memorización mecánica.',
        pageTitle: 'El Viaje del Loco: Primeros Pasos',
        pagePurpose: 'Fijar los arcanos 0 al VII',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          '¿En qué punto del Viaje (0-VII) estoy HOY? Por qué:',
          'El arcano que me hizo sentido de inmediato:',
          'Lo que el quiz reveló que aún confundo:',
          'Mi frase-resumen para cada carta (0-VII):',
        ],
      ),
      TrailLesson(
        id: 'ta_03',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'Las pruebas del alma (VIII-XIV)',
        teaching:
            'Después de aprender las fuerzas del mundo, el Loco enfrenta el segundo tercio del Viaje: las pruebas internas. De los arcanos VIII al XIV, la historia deja a los maestros externos y se sumerge en el alma. Estas cartas importan porque tratan aquello de lo que nadie escapa — coraje, retiro, ciclos, consecuencias y el gran arte de transformarse.\n\nLa Fuerza, arcano VIII en el Rider-Waite, enseña el coraje gentil que doma sin violencia. El Ermitaño se retira para encontrar su propia luz. La Rueda de la Fortuna gira los ciclos de la vida, y la Justicia, arcano XI, cobra la consecuencia de cada elección. El Colgado invierte la mirada y gana una nueva perspectiva, la Muerte cierra lo que ya cumplió su tiempo y la Templanza mezcla los opuestos en una síntesis serena.\n\nSon las cartas que asustan a las principiantes y sostienen a las lectoras experimentadas. El error clásico es leer la Muerte como tragedia: habla de finales necesarios, casi nunca de muerte física. Estudia el grupo ligando cada carta a una prueba que ya viviste — la memoria afectiva fija mucho más que la repetición seca. Y no apresures al Ermitaño: retirarse también es avanzar.\n\nLlévate esto: madurez en el tarot es perder el miedo a estas siete láminas. Cuando una de ellas aparezca, en vez de temer, pregunta qué prueba está madura en tu vida y qué vino a enseñarte. Ahí vive la diferencia entre quien solo consulta las cartas y quien de verdad dialoga con ellas.',
        practice:
            'En el Tutor de Tarot, haz una sesión de quiz enfocada en los arcanos VIII al XIV, con atención especial a los que se parecen, como la Rueda y la Justicia. Después del quiz, abre la carta de la Muerte y contempla la imagen durante dos minutos, respirando hondo, sin miedo. Por último, registra tus impresiones en la página de esta lección. El objetivo es fijar las pruebas del alma y transformar la carta más temida de la baraja en una aliada tuya.',
        pageTitle: 'Las Pruebas de Mi Alma',
        pagePurpose: 'Fijar los arcanos VIII al XIV',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'La "prueba" (VIII-XIV) que estoy viviendo ahora:',
          'Lo que significa la Muerte después de la contemplación:',
          'La carta de este grupo que se volvió aliada:',
          'Mi frase-resumen para cada una:',
        ],
      ),
      TrailLesson(
        id: 'ta_04',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'La noche oscura y el amanecer (XV-XXI)',
        teaching:
            'El tercio final del Viaje atraviesa la noche más oscura antes del amanecer. De los arcanos XV al XXI, el Loco encara sus apegos e ilusiones para renacer entero. Conocer este tramo importa porque describe las crisis que transforman — y muestra que ninguna noche, por honda que parezca, es el final de la historia que estás viviendo.\n\nEl Diablo revela los apegos que atan, la Torre derriba estructuras falsas de un solo golpe, la Estrella devuelve la esperanza desnuda y serena, y la Luna se sumerge en las ilusiones y miedos del inconsciente. Entonces amanece: el Sol trae alegría clara, el Juicio suena como un llamado de renacimiento y el Mundo cierra el ciclo en plenitud — la danza de quien integró el Viaje entero.\n\nPara fijarlo, cuenta el arco completo como historia, del salto del Loco a la danza del Mundo: narrar en voz alta graba más que releer. Cuidado con el error de tratar a la Torre y el Diablo como maldiciones — en lecturas reales, suelen señalar liberaciones urgentes. Y recuerda: el Viaje no es una línea recta, es una espiral; lo recorres muchas veces a lo largo de la vida.\n\nGuarda esta imagen: toda Torre que cae abre la vista hacia una Estrella. Con los 22 mayores completos, ya cargas el esqueleto del tarot. Ante cualquier mesa, busca primero en qué punto de la espiral está la consultante — el resto de la lectura se organiza a partir de ahí.',
        practice:
            'Abre el Tutor de Tarot y haz una sesión de quiz con los arcanos XV al XXI; después, una ronda general con los 22 arcanos mayores. Enseguida, deja la app por un instante y cuenta el Viaje entero en voz alta, carta por carta, como quien narra un cuento. Vuelve y registra en la página tu resumen y tu precisión en el quiz. El objetivo es coser el arco completo de los mayores en la memoria, de una vez por todas.',
        pageTitle: 'Mi Viaje Completo',
        pagePurpose: 'Fijar los arcanos XV al XXI y el arco entero',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Mi "noche oscura" más reciente y la Estrella que apareció:',
          'El Viaje del Loco contado con mis palabras (resumen):',
          'Mi arcano regente de esta fase de la vida:',
          'Precisión actual en el quiz de mayores:',
        ],
      ),
      TrailLesson(
        id: 'ta_05',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'Bastos y Copas: fuego y agua',
        teaching:
            'Si los mayores narran los grandes pasajes, los palos hablan de lo cotidiano — y es en ellos donde ocurre la mayor parte de las lecturas. Bastos y Copas forman la pareja cálida de la baraja: fuego y agua, impulso y sentimiento. Dominar este dúo importa porque describe casi todo lo que mueve tus días: deseo, proyectos, vínculos y emociones.\n\nBastos es fuego: proyectos, pasión, movimiento. El As enciende la chispa creativa, el Tres ya contempla el horizonte de los planes y el Diez muestra la sobrecarga de quien abrazó demasiado. Copas es agua: vínculos, emociones, intuición. El As desborda un sentimiento nuevo, el Tres celebra entre amigas y el Diez corona la plenitud afectiva. Cada número cuenta una etapa de la energía del palo.\n\nEl consejo de oro: número más palo forma una frase. Piensa en el número como verbo y en el palo como tema — Tres es expansión, Copas es afecto, luego el Tres de Copas es celebración compartida. El error común es memorizar cada carta aislada; arma la frase y podrás leer cualquier menor. Entrena con tu día: ¿esa reunión agitada fue qué carta de Bastos?\n\nLlévate esto: el fuego sin agua quema, el agua sin fuego se estanca. Bastos pregunta dónde está tu impulso; Copas, cómo anda tu corazón. Cuando estos dos palos dominen una mesa, la vida está hablando de pasión y de vínculo — y tú ya sabes conjugar ambos.',
        practice:
            'Abre el Tutor de Tarot y haz una sesión de quiz dedicada a los palos de Bastos y Copas. Antes de responder cada pregunta, arma mentalmente la frase número más palo y solo entonces revisa las opciones. Después del quiz, crea por tu cuenta tres frases de ese tipo y regístralas en la página, junto con las confusiones que aparezcan. El objetivo es interiorizar la lógica que permite leer cualquier carta menor sin memorización mecánica.',
        pageTitle: 'Fuego y Agua en Mis Manos',
        pagePurpose: 'Dominar la lógica de Bastos y Copas',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Dónde está encendido mi FUEGO (qué carta de Bastos lo describe):',
          'Cómo anda mi AGUA (qué carta de Copas la describe):',
          'Mis 3 frases número+palo:',
          'Confusiones que el quiz reveló:',
        ],
      ),
      TrailLesson(
        id: 'ta_06',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'Espadas y Oros: aire y tierra',
        teaching:
            'Espadas y Oros completan el cuarteto de los palos: aire y tierra, mente y materia. Es la pareja que equilibra la baraja — después del deseo y la emoción, llegan el pensamiento y el suelo firme. Conocer ambos importa porque toda lectura madura necesita distinguir qué es idea, qué es hecho concreto y qué es miedo vestido de verdad.\n\nEspadas es aire: la mente, con su claridad que corta y su ansiedad que hiere. Es el palo de fama más difícil y también el más honesto — el As trae la verdad desnuda, el Tres nombra el dolor de la decepción, el Nueve retrata el insomnio de las preocupaciones. Oros es tierra: cuerpo, trabajo, dinero y la magia de la materia bien cuidada — del As, semilla concreta, al Diez, patrimonio y legado.\n\nSigue usando la fórmula número más elemento: ahora puedes leer cualquier menor numerado de la baraja. El error común aquí es dramatizar Espadas — el palo describe pensamientos, no sentencias. Ante una carta dura, pregunta qué pensamiento es ese, y no qué desgracia viene. Y honra a Oros: cuidar lo concreto también es práctica espiritual.\n\nGuarda esta síntesis: Espadas muestra lo que tu mente te cuenta; Oros muestra lo que tus manos construyen. Entre pensar y concretar camina la vida entera. Con los cuatro palos en tu equipaje, lo cotidiano entero se volvió vocabulario de lectura para ti.',
        practice:
            'En el Tutor de Tarot, haz una sesión de quiz con los palos de Espadas y Oros, aplicando la fórmula número más elemento antes de cada respuesta. Al terminar, recorre mentalmente el palo de Espadas e identifica qué carta se parece más a tu mente hoy; haz lo mismo con Oros y tu vida material. Regístralo todo en la página. El objetivo es completar el dominio de los cuatro palos y traer las cartas a tu presente.',
        pageTitle: 'Aire y Tierra en Mis Manos',
        pagePurpose: 'Dominar la lógica de Espadas y Oros',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'La carta de Espadas de mi mente hoy (y por qué):',
          'La carta de Oros de mi materia hoy:',
          'Lo que los "diez" de cada palo me enseñan sobre el exceso:',
          'Precisión actual en el quiz de menores:',
        ],
      ),
      TrailLesson(
        id: 'ta_07',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'La corte: las dieciséis personas',
        teaching:
            'Dieciséis cartas de la baraja no describen situaciones, sino gente: son las cartas de corte — Sota, Caballero, Reina y Rey de cada palo. Importan porque toda lectura involucra personas y posturas, y la corte es el espejo donde la consultante, la lectora y los personajes de la vida aparecen con rostro, edad interna y temperamento.\n\nCada rango indica una madurez de la energía del palo: la Sota aprende y experimenta, el Caballero actúa y parte en misión, la Reina domina la energía por dentro, el Rey la gobierna por fuera, en el mundo. Cruza el rango con el elemento y surge el retrato: la Reina de Copas acoge con profundidad emocional, el Caballero de Espadas avanza con ideas afiladas y mucha prisa.\n\nEn la mesa, una corte puede ser alguien presente en la situación o un papel que tú misma estás vistiendo — pregunta siempre: ¿quién es, o qué estoy siendo? El error común es fijar cada corte en una persona física de apariencia parecida; prefiere leer temperamentos. Entrena asociando a personas queridas con las dieciséis cartas: la memoria afectiva afirma el aprendizaje.\n\nLlévate esto: no eres una única carta de corte — eres la baraja entera, vistiendo rangos según lo pida la semana. Ante una corte, haz siempre la pregunta doble: quién está actuando así, y cuándo soy yo quien actúa así. Con ella, estas dieciséis cartas dejan de confundir y empiezan a revelar.',
        practice:
            'Abre el Tutor de Tarot y haz una sesión de quiz dedicada a las dieciséis cartas de corte, atenta al par rango y palo de cada una. Después, reflexiona: ¿qué corte estás vistiendo esta semana — una Sota curiosa, una Reina de Oros proveedora? Elige también cortes para tres personas de tu vida y regístralo todo en la página. El objetivo es reconocer posturas y temperamentos, dentro y fuera de ti.',
        pageTitle: 'La Corte que Habito',
        pagePurpose: 'Reconocer posturas en las cartas de corte',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'La corte que estoy vistiendo esta semana:',
          'Personas de mi vida en cartas de corte (3 ejemplos):',
          'La corte que necesito invocar más:',
          'La que necesito dejar descansar:',
        ],
      ),
      TrailLesson(
        id: 'ta_08',
        recordKind: LessonRecordKind.tarot,
        title: 'Tirar cartas: la pregunta es la mitad',
        teaching:
            'Una buena lectura comienza antes de barajar: en la pregunta. La pregunta es la mitad de la respuesta, porque define el lente con el que se leerán las cartas. Preguntar bien importa tanto como conocer significados — una mesa entera de cartas certeras no salva una pregunta torcida, vaga o que entrega a la baraja tu poder de decidir.\n\nLas preguntas abiertas rinden: qué necesito ver sobre esta situación, qué energía me ayuda ahora. Las preguntas de sí o no empobrecen la conversación, y las preguntas sobre la vida de terceros invaden territorio ajeno. Reformula hasta que la pregunta apunte hacia ti — en vez de querer saber si alguien vuelve, pregunta qué necesitas comprender sobre ese vínculo.\n\nA la hora de tirar: respira hondo, baraja con la pregunta viva en el cuerpo y voltea las cartas con calma. Lee primero la imagen — qué muestra la escena, qué sientes al mirarla — y solo después consulta el significado, que viene en tu auxilio, nunca por delante. El error común es saltar directo al texto e ignorar lo que tus ojos ya sabían.\n\nGuarda esta medida: pregunta abierta, ojos primero, significado después. Quien pregunta bien ya recibió media respuesta antes de voltear la primera carta. El tarot no decide por ti — ilumina el terreno para que decidas mejor, y ahí vive tu fuerza.',
        practice:
            'Ve a la página de Tarot de la app y elige la tirada de Tres Cartas. Antes de tirar, escribe tu pregunta y reformúlala hasta que quede abierta y apuntada hacia ti. Baraja respirando hondo, voltea las cartas y lee primero las imágenes, anotando tus impresiones; solo entonces abre los significados y compara. Registra el proceso en la página de la lección. El objetivo es afirmar el ritual completo: pregunta bien hecha, mirada propia y estudio como apoyo.',
        pageTitle: 'El Arte de la Pregunta',
        pagePurpose: 'Estructurar mis consultas',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Mi pregunta (reformulada hasta volverse mía):',
          'Lo que las IMÁGENES me dijeron antes del texto:',
          'Lo que el significado confirmó o corrigió:',
          'Mi respuesta en una frase:',
        ],
      ),
      TrailLesson(
        id: 'ta_09',
        recordKind: LessonRecordKind.tarot,
        title: 'Tejer la historia: lectura combinada',
        teaching:
            'Las cartas no hablan solas — conversan. La lectura madura no suma entradas aisladas: teje una historia en la que cada carta ilumina a sus vecinas. Aprender a combinar importa porque eso es lo que separa a quien consulta significados de quien realmente lee. La mesa es un texto, y las cartas son frases que solo ganan sentido pleno cuando se leen juntas.\n\nTres patrones guían el tejido: la repetición de palo revela el tema dominante — muchas Copas, y el asunto es el afecto; la mayoría de arcanos mayores indica fuerzas grandes en juego, por encima de lo cotidiano; y las vecindades se iluminan — la Torre junto a la Estrella es ruptura con esperanza, el Diez de Bastos cerca del Ermitaño pide pausa y retiro antes de seguir.\n\nEn la práctica, antes de consultar cualquier significado, mira la mesa entera y cuenta la historia: dónde comienza, dónde aprieta, dónde señala una salida. Escribir la lectura como un pequeño cuento educa la mirada. El error común es leer carta por carta como fichas sueltas, cada una con su párrafo, sin conectar nunca — y la historia se pierde dentro del diccionario.\n\nLlévate esto: tu papel de lectora es narrar lo que las cartas forman juntas, con comienzo, tensión y consejo. Confía en el hilo que ves entre las láminas — ese hilo es tu lectura. El diccionario lo abre cualquiera; la historia, solo tú puedes contarla.',
        practice:
            'En la página de Tarot, haz una tirada de Tres Cartas sobre un tema de tu momento. Antes de consultar cualquier significado, observa la mesa entera y escribe la lectura como un mini cuento de cinco líneas, con comienzo, tensión y consejo. Después revisa los significados, nota repeticiones de palo, presencia de mayores y vecindades, y regístralo todo. El objetivo es entrenar la lectura combinada: tejer historias en vez de sumar cartas sueltas.',
        pageTitle: 'Mi Primera Historia Tejida',
        pagePurpose: 'Leer combinaciones, no cartas sueltas',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Las 3 cartas y la tirada:',
          'Mi mini-cuento de 5 líneas:',
          'Patrones que noté (palos, mayores, vecindades):',
          'El consejo final de la mesa:',
        ],
      ),
      TrailLesson(
        id: 'ta_10',
        recordKind: LessonRecordKind.tarot,
        title: 'Tu tarot: ética y voz propia',
        teaching:
            'Llegando al final de la ruta, lo que falta no es técnica: es identidad. La lectora madura se reconoce por dos marcas — ética firme y voz propia. Esto importa porque el tarot toca a las personas en momentos sensibles, y la diferencia entre ayudar y asustar está entera en la postura de quien sostiene las cartas frente a otra alma.\n\nLa ética se resume en devolver el poder: no predecir muerte ni enfermedad, no decidir la vida de nadie, no alimentar dependencia de las consultas. La voz propia se construye con el tiempo: tus cartas ancla, esas que lees con los ojos cerrados; tus rituales de mesa, tu manera de abrir y cerrar cada lectura; tu forma única de contar lo que muestra la mesa.\n\nEn el día a día, nada afirma la voz y el vínculo como la constancia: una carta al día vale más que una tirada enorme al mes. Saca la Carta del Día, escribe una línea, sigue con la vida — y por la noche observa cómo apareció la carta. El error común es abandonar la práctica cuando la rutina aprieta; encoge el ritual si hace falta, pero no lo abandones.\n\nGuárdalo como manifiesto: el tarot no predice un destino cerrado — ilumina caminos para quien elige. Ahora conoces el mapa, los palos, la corte y el Viaje entero. De aquí en adelante, la baraja habla con tu voz. Lee con coraje, con ética y con la ternura de quien sabe que toda carta es un espejo.',
        practice:
            'En la página de Tarot, saca la Carta del Día durante siete días seguidos. Cada mañana, observa la imagen, respira y escribe una sola línea sobre lo que la carta despierta; por la noche, si quieres, agrega cómo apareció en tu día. Al final de la semana, relee las siete líneas y escribe tu manifiesto de lectora en la página de la lección. El objetivo es afirmar el hábito que sostiene a toda lectora: presencia diaria, breve y constante, con las cartas.',
        pageTitle: 'Manifiesto de la Lectora',
        pagePurpose: 'Afirmar mi ética y mi voz en el tarot',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Mi ética de lectura (lo que hago y lo que nunca hago):',
          'Mis cartas-ancla (las que ya leo con los ojos cerrados):',
          'Mi ritual de mesa (cómo abro y cierro lecturas):',
          'Diario de las 7 Cartas del Día:',
        ],
      ),
    ],
  );
