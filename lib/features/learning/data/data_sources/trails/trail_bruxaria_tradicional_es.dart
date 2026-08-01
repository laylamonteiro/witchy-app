import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Senda 'bruxaria_tradicional' — contenido en español.
/// Paridad con _pt/_en verificada en test/trails_parity_test.dart.
const LearningTrail bruxariaTradicionalTrailEs = LearningTrail(
    id: 'bruxaria_tradicional',
    emoji: '🧹',
    title: 'Brujería Tradicional',
    subtitle: 'El camino torcido y los saberes antiguos',
    description:
        'La brujería de los folclores, de las curanderas y del camino torcido: espíritus del lugar, ancestros y herramientas de lo cotidiano — sin dogmas, con raíces',
    lessons: [
      TrailLesson(
        id: 'bt_01',
        recordKind: LessonRecordKind.note,
        title: 'Los espíritus del lugar',
        teaching:
            'La brujería tradicional está enraizada en el lugar: ríos, encrucijadas, patios, esquinas. Antes de cualquier herramienta o grimorio, el primer paso es conocer el suelo que pisas, porque la magia de esta vertiente no viene de libros lejanos — nace de la relación viva con el territorio. Cada tierra tiene sus espíritus, y la bruja que los conoce practica con raíces, no de prestado\n\nCasi todos los pueblos reconocieron espíritus del lugar: el folclore europeo habla de guardianes de fuentes, bosques y colinas, y América es riquísima en encantados — la madre del río, los duendes del monte, las ánimas de los cruces. Con ellos se hace amistad como con la gente: presencia regular, pequeñas ofrendas respetuosas, escucha paciente. Por eso el folclore local es el mapa espiritual más honesto que existe: cuenta quién ya vive allí desde hace mucho tiempo\n\nEn el día a día, esto se vuelve caminata atenta: notar el árbol más antiguo de la calle, la esquina donde el aire cambia, el terreno que pide silencio. Comienza pequeño — agua limpia, una flor, un saludo en pensamiento — y no exijas nada a cambio. El error común de la principiante es importar espíritus de moda e ignorar el propio patio; otro es retirar hojas y piedras sin pedir permiso. El respeto abre más puertas que cualquier ritual elaborado\n\nLleva contigo esta idea: no practicas sobre la tierra, practicas con ella. La amistad con los espíritus del lugar se construye como toda amistad — con presencia constante y respeto verdadero. Conoce tu suelo, y tu suelo pasará a reconocerte. Ese es el cimiento de todo el camino torcido',
        practice:
            'Camina 15 minutos por el barrio como bruja: sal sin prisa y sin auriculares, observando dónde cambia la energía, qué lugar te llama y qué historias cuentan los antiguos sobre la región. Al volver, anota en tu página los puntos que se destacaron y piensa en la primera ofrenda respetuosa que te gustaría dejar. El objetivo es comenzar el mapa espiritual de tu territorio y abrir, con presencia y escucha, la relación con los espíritus del lugar',
        pageTitle: 'Los Espíritus de Mi Lugar',
        pagePurpose: 'Mapear el territorio espiritual donde vivo',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Lugares de poder cerca de mí:',
          'Historias y folclore de la región:',
          'Mi primera ofrenda respetuosa (qué, dónde):',
          'Lo que sentí:',
        ],
      ),
      TrailLesson(
        id: 'bt_02',
        recordKind: LessonRecordKind.note,
        title: 'Ancestros: el linaje vivo',
        teaching:
            'En la brujería tradicional, los muertos no están lejos: los ancestros son aliados de primera hora, presentes en lo cotidiano de quien los honra. Forman tres corrientes — los de sangre, de tu familia; los de afecto, que amaste sin parentesco; y los de oficio, las brujas y curanderas que vinieron antes. Honrarlos importa porque nadie camina sola: toda práctica se apoya en quien abrió la senda primero\n\nEl culto a los ancestros atraviesa casi todas las culturas: mesas puestas para los muertos en el folclore europeo, el día de los difuntos, las curanderas que piden permiso a los antiguos antes de rezar. El altar tradicional es simple: una superficie limpia, un vaso de agua, una vela, una foto u objeto de quien partió. El agua se renueva, la vela se enciende, y la conversación ocurre como con alguien querido que solo cambió de habitación\n\nEn la práctica, elige un rincón tranquilo de la casa y cuídalo con constancia: renueva el agua en un día fijo, habla con naturalidad, agradece antes de pedir. Un error común es tratar el altar como mostrador de pedidos; otro es creer que solo vale quien conociste en vida — el linaje de afecto y de oficio también cuenta. Y recuerda: tú eliges a quién honras. Solo invita a tu altar a quien trae paz a tu corazón\n\nGuarda esta llave: recordar es mantener vivo. Eres la continuación de muchas manos, muchos rezos y muchos nombres, y el vaso de agua renovado cada semana vale más que el ritual grandioso hecho una sola vez. La devoción ancestral está hecha de constancia pequeña, presencia sincera y cariño verdadero',
        practice:
            'Enciende una vela por tus ancestros en un momento calmo. Ante la llama, di en voz baja que los recuerdas, que agradeces lo que recibiste y que los invitas a seguir contigo en el camino. Después, monta o renueva el rincón con el vaso de agua y un objeto o foto de quien honras. El objetivo es iniciar el vínculo vivo con tu linaje y transformar el recuerdo en devoción diaria y afectuosa',
        pageTitle: 'Mi Altar Ancestral',
        pagePurpose: 'Iniciar la devoción a quienes vinieron antes',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Vaso de agua', 'Vela', 'Objeto o foto'],
        pagePrompts: [
          'Dónde lo monté (el rincón):',
          'A quién honro:',
          'Mi saludo a ellos:',
          'Día en que renuevo el agua:',
        ],
      ),
      TrailLesson(
        id: 'bt_03',
        title: 'Las herramientas de lo cotidiano',
        teaching:
            'La bruja tradicional no espera la tienda esotérica: la escoba barre energía, la tijera corta lazos, la aguja cose destinos, la cuchara de palo revuelve intenciones. El poder no está en el precio ni en el brillo del objeto, sino en el uso consciente que haces de él. Esta es una de las marcas más antiguas de la brujería popular — trabajar con lo que la casa ya ofrece, transformando lo común en sagrado\n\nEl folclore confirma esa herencia: la herradura de hierro sobre la puerta, la tijera abierta detrás de ella, el cuchillo que corta el aire cargado, el cedazo y la llave usados en adivinaciones antiguas. Los objetos comunes se vuelven guardianes porque cargan historia de uso y cercanía con la vida. Consagrar sigue una lógica simple: limpiar el objeto, declarar en voz alta su nuevo papel y usarlo solo para eso — la exclusividad es lo que carga el poder\n\nEn lo cotidiano, esto significa mirar la propia casa con ojos de bruja antes de comprar cualquier cosa. El error común de la principiante es consagrar diez objetos de una vez y no usar ninguno, o mezclar la herramienta ritual con la función común — la escoba consagrada no toca la basura física. Comienza con un único objeto, límpialo con sal o humo, dale un papel claro y guárdalo con respeto, separado de los demás\n\nLa idea para memorizar: la magia vive en la relación, no en el objeto. Una cuchara consagrada con verdad vale más que una daga cara sin historia alguna. Tu casa ya es un pequeño arsenal mágico esperando tu mirada — despierta una herramienta a la vez, con calma, uso constante e intención clara',
        practice:
            'Recorre la casa con calma y elige UN objeto para consagrar como tu primera herramienta. Sostén a los candidatos en las manos y percibe cuál de ellos parece aceptar el trabajo — suele haber uno que se destaca. Después limpia al elegido con sal o humo, declara en voz alta su nueva función y guárdalo aparte, solo para ese uso. El objetivo es iniciar tu conjunto de herramientas consagradas y entrenar la escucha de los objetos',
        pageTitle: 'Mis Herramientas de Bruja',
        pagePurpose: 'Consagrar objetos de lo cotidiano',
        pageCategory: SpellCategory.other,
        pageIngredients: ['El objeto', 'Sal o humo'],
        pagePrompts: [
          'Objeto elegido y su función mágica:',
          'Cómo lo limpié y consagré:',
          'Palabras de la consagración:',
          'Próximos objetos que pienso consagrar:',
        ],
      ),
      TrailLesson(
        id: 'bt_04',
        title: 'La encrucijada: donde los caminos hablan',
        teaching:
            'En casi toda tradición, la encrucijada es lugar de poder: donde los caminos se cruzan, los mundos también se tocan. Allí el sendero común se vuelve portal — punto de decisiones, pasajes y posibilidades abiertas. Para la brujería tradicional, conocer la encrucijada importa porque enseña lo esencial del camino torcido: toda elección abre una dirección y cierra otra, y hay fuerzas que guardan esos pasajes\n\nEl folclore es unánime: en la Grecia antigua, Hécate recibía ofrendas en los cruces; en Europa, los trivios eran puntos de encuentros, juramentos y apariciones; en América, tradiciones de matriz africana honran en las encrucijadas a los guardianes de los caminos, con fundamentos profundos y propios. Allí tradicionalmente se dejan trabajos, se hacen pedidos de apertura y se agradece a quien guarda los pasajes — siempre con permiso y reverencia\n\nPara la principiante, la regla de oro es el respeto: la encrucijada no es un basurero ritual. Si dejas ofrenda, que sea biodegradable, discreta y en lugar seguro; jamás recojas lo que otros dejaron, y no copies rituales de tradiciones que no conoces por dentro. En lo cotidiano, basta atravesar con conciencia: un saludo silencioso, hecho de corazón, ya es reconocimiento de quien guarda el punto\n\nLleva esta imagen: la vida entera está hecha de encrucijadas, y la bruja no teme los cruces — los saluda. Pide caminos abiertos, agradece los pasajes y sigue andando con confianza. Quien respeta el punto donde los mundos se tocan aprende, de a poco, a atravesar sus propias elecciones',
        practice:
            'Pasa por una encrucijada de tu trayecto con plena conciencia: detente un instante en lugar seguro, respira hondo, saluda en silencio a quien guarda los pasajes y haz un pedido callado de caminos abiertos para tu vida. Después sigue adelante sin ansiedad, observando lo que el día responde. El objetivo es reconocer puntos de poder en el recorrido común y entrenar la reverencia simple del camino torcido',
        pageTitle: 'Mi Rito de Encrucijada',
        pagePurpose: 'Trabajar aperturas de camino',
        pageCategory: SpellCategory.luck,
        pagePrompts: [
          'La encrucijada que me llama (cómo es):',
          'Mi pedido de apertura de caminos:',
          'Mi ofrenda respetuosa (si la hay):',
          'Señales que percibí después:',
        ],
      ),
      TrailLesson(
        id: 'bt_05',
        recordKind: LessonRecordKind.affirmation,
        title: 'Sanación: la palabra que cura',
        teaching:
            'Las curanderas son la brujería tradicional viva de nuestros pueblos: mujeres y hombres que curan con palabra, ramo y fe, con la puerta abierta, sin cobrar nada. La sanación con la palabra importa porque es el linaje mágico más cercano a ti — quizás exista en tu propia familia — y prueba que la palabra dicha con intención es una de las herramientas de cura más antiguas y poderosas del mundo\n\nLa estructura de la sanación es poesía funcional: primero nombra el mal — el quebranto, el mal de ojo, el susto —, después invoca la fuerza mayor, manda el mal lejos, a las olas del mar o a los confines, y por último sella el trabajo. El ramo verde, de ruda o de albahaca, participa: cuando se marchita, dice la tradición, es porque se llevó lo que quitó. Esta herencia mezcla rezos ibéricos, saberes indígenas y africanos en una medicina hecha de palabra\n\nEn tu día a día, comienza por la investigación: abuelas, vecinas y registros locales guardan versiones preciosas. Usa lo que aprendas para el autocuidado — sanar tu propia agua, tu propio sueño — y evita dos errores comunes: tratar el rezo como fórmula vacía, sin fe ni presencia, y presentarte como curandera sin haber recibido el oficio. El don tradicional se recibe y se cultiva; el respeto por quien lo guarda es parte de la práctica\n\nQuédate con esta llave: la palabra dicha con fe es remedio antiguo. Honra la fuente de cada rezo que aprendas, pronúncialo con el corazón presente, y estarás manteniendo viva una de las corrientes más bellas de la tradición — la que cura gratis, en el umbral de la puerta, con un ramo verde en la mano',
        practice:
            'Investiga UNA fórmula de sanación tradicional de tu región: pregunta a abuelas y vecinas o busca en registros de folclore local. Copia el rezo en tu página como reliquia, anotando quién lo enseñó o dónde lo encontraste. Después, crea una versión simple para autocuidado y experiméntala con un ramo verde, como ruda o albahaca. El objetivo es honrar el linaje de las curanderas y guardar tu primera palabra de cura',
        pageTitle: 'Mi Primera Sanación',
        pagePurpose: 'Honrar y practicar la palabra que cura',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Ramo verde (ruda, albahaca...)'],
        pagePrompts: [
          'Fórmula tradicional que encontré (y la fuente):',
          'Mi versión para autocuidado:',
          'El gesto que la acompaña:',
          'Cuándo la usé y qué sentí:',
        ],
      ),
      TrailLesson(
        id: 'bt_06',
        title: 'La escoba: barrer es rito',
        teaching:
            'La escoba de la bruja no vuela — barre mundos. En la brujería tradicional, barrer nunca fue solo limpieza: es rito de protección y renovación escondido en el gesto más común de la casa. La dirección importa: barrer de la puerta hacia dentro atrae la suerte al hogar; barrer hacia fuera expulsa lo que está denso y pesado. El instrumento más banal del hogar es también uno de los más antiguos de la magia popular\n\nEl folclore guarda capas: la escoba detrás de la puerta espanta la visita indeseada, dice la creencia popular; en Europa, saltar la escoba sellaba uniones y barrer el umbral protegía el límite de la casa. La escoba ritual es aquella que no toca la basura física — vive acostada detrás de la puerta o colgada en la pared, guardando la entrada. Y el patio barrido por la mañana era la protección diaria de las antiguas: el rito disfrazado de rutina\n\nEn la práctica, puedes tener una escoba solo para el rito o ritualizar el barrido común: lo que cambia es la intención. Al barrer hacia fuera, nombra lo que sale junto con el polvo — cansancio, peleas, peso; al terminar, llama lo que entra al espacio limpio. Errores comunes: barrer con rabia, esparciendo lo denso en vez de conducirlo hacia fuera, y dejar que la escoba ritual se vuelva un objeto de limpieza cualquiera. Barre despacio, como quien reza\n\nLleva contigo: el rito vive escondido en el gesto común. Tu casa barrida con intención es tu primer círculo de protección, rehecho todos los días sin que nadie lo note. Donde la escoba pasa con conciencia, lo denso no se acomoda. Esa es la magia de las antiguas: simple, diaria y poderosa',
        practice:
            'Barre una habitación hoy como rito completo: comienza barriendo en dirección a la puerta y hacia fuera, nombrando en voz baja lo que sale junto con el polvo — cansancio, discusiones, peso acumulado. Después, de la puerta hacia dentro, llama lo que deseas para el espacio limpio: suerte, calma, protección. Termina agradeciendo a la casa. El objetivo es transformar la limpieza común en rito de protección y sentir en la práctica el poder del gesto simple',
        pageTitle: 'Mi Escoba de Bruja',
        pagePurpose: 'Ritualizar la limpieza de la casa',
        pageCategory: SpellCategory.cleansing,
        pagePrompts: [
          'Mi escoba ritual (cuál es, dónde vive):',
          'Lo que digo al barrer hacia fuera:',
          'Lo que llamo al barrer hacia dentro:',
          'Cómo quedó la casa después del rito:',
        ],
      ),
      TrailLesson(
        id: 'bt_07',
        title: 'Botellas y protecciones de la casa',
        teaching:
            'La witch bottle, o botella de bruja, es una protección tradicional con siglos de historia: un frasco lleno de elementos cortantes simbólicos, elementos protectores y algo tuyo, sellado y escondido en la casa. Funciona como guardiana silenciosa — absorbe y atrapa el mal dirigido a ti antes de que te alcance. Es la defensa clásica de la brujería popular: discreta, duradera y hecha en casa\n\nBotellas así son encontradas por arqueólogos bajo chimeneas y umbrales ingleses desde el siglo XVII, llenas de clavos, alfileres y objetos personales de quien protegían. La lógica tradicional es el engaño: al contener algo tuyo, la botella se hace pasar por ti; el mal la encuentra primero, queda atrapado en los elementos cortantes y es neutralizado por los protectores. La versión moderna usa un frasco pequeño, sal, romero o ruda, un cabello y cera de vela para sellar\n\nEn la práctica, arma la tuya en un momento tranquilo, con intención clara, y escóndela en un punto discreto: fondo de armario, rincón alto, jardín. Una vez sellada, no se abre — si un día sientes que cumplió el trabajo, agradece y descártala con respeto, armando otra. El error común es exhibir la botella o contar dónde está: la protección escondida trabaja mejor. Otro es usar objetos peligrosos sin cuidado; el símbolo basta\n\nGuarda esta idea: no toda defensa necesita ser visible. La botella enseña la magia de la discreción — protección que trabaja en silencio, día y noche, sin pedir atención ni mantenimiento constante. Arma la tuya con calma y deja que la guardiana cuide de lo que no debe llegar hasta ti. Casa protegida es casa que duerme en paz',
        practice:
            'Reúne con calma los materiales de tu botella de protección: un frasco pequeño con tapa, sal, hierbas protectoras como ruda o romero, un cabello tuyo y una vela para sellar con cera. Guarda todo junto y ármala cuando te sientas lista, en un momento tranquilo, colocando cada elemento con intención y sellando con palabras tuyas. El objetivo es crear la guardiana silenciosa de la casa y esconderla en un punto discreto',
        pageTitle: 'Mi Botella de Protección',
        pagePurpose: 'Armar la guardiana silenciosa de la casa',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Frasco pequeño', 'Sal', 'Hierbas protectoras', 'Cera'],
        pagePrompts: [
          'Lo que puse dentro y el porqué de cada elemento:',
          'Mis palabras al sellar:',
          'Dónde está escondida:',
          'Cuándo pienso renovarla:',
        ],
      ),
      TrailLesson(
        id: 'bt_08',
        recordKind: LessonRecordKind.dream,
        title: 'Sueños y señales: la escucha torcida',
        teaching:
            'El camino torcido escucha el mundo: sueños que insisten, animales que cruzan la carretera, objetos que caen solos, nombres oídos tres veces el mismo día. Esto no es paranoia — es atención poética, una forma antigua de percibir que la vida habla por patrones e imágenes. Para la brujería tradicional, el mundo está siempre en conversación; la bruja es quien decide escuchar con cuidado\n\nLos presagios atraviesan el folclore: el búho en el tejado, la mariposa que entra en casa, el sueño con un diente, la visita anunciada por el cubierto que cae. El método tradicional es registrar sin interpretar en el momento — el significado madura con el tiempo, y los patrones solo aparecen para quien acumula registros. Los sueños son la parte más rica de esa escucha: el Diario de Sueños y los Significados de los Sueños de la app son tus aliados en ese trabajo\n\nEn la práctica, mantén un cuaderno de señales: anota fecha, contexto y lo que pasó, sin juzgar si es importante. Reléelo una vez por semana buscando repeticiones. Los errores comunes de la principiante son dos opuestos: transformar todo en presagio y vivir ansiosa, o decidir la vida entera por una señal aislada. El equilibrio es registrar mucho, concluir despacio y dejar que el patrón se muestre solo\n\nLa llave para llevar: el mundo habla bajito, y quien anota aprende el idioma. Una señal es curiosidad; tres señales repetidas son conversación. Registra sin prisa, relee con atención, y la escucha torcida se irá volviendo tu segunda naturaleza — el radar silencioso de la bruja en medio de lo cotidiano común',
        practice:
            'Hoy, anota tres coincidencias o señales del día — un animal que cruzó tu camino, una frase oída en el momento exacto, un objeto que cayó de la nada. Registra solo el hecho, la fecha y el contexto, sin interpretar nada ahora. Guarda las anotaciones y relee todo dentro de una semana, buscando repeticiones y conexiones. El objetivo es entrenar la escucha de los presagios y descubrir cómo los patrones hablan con el tiempo',
        pageTitle: 'Mi Cuaderno de Señales',
        pagePurpose: 'Entrenar la escucha de los presagios',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Las señales que percibí esta semana:',
          'Patrones que ya se repiten en mi vida:',
          'Mi acuerdo de registro (dónde, cuándo):',
          '(En 7 días) Lo que las señales formaron juntas:',
        ],
      ),
      TrailLesson(
        id: 'bt_09',
        recordKind: LessonRecordKind.desire,
        title: 'El camino torcido: pacto contigo',
        teaching:
            'La brujería tradicional no pide conversión — pide coherencia. El pacto verdadero del camino torcido no es con ninguna entidad: es contigo misma. Significa practicar lo que funciona, honrar lo que sostiene y abandonar sin culpa lo que es solo adorno. Esa honestidad importa porque un camino sin dogma solo se sostiene por el compromiso real y cotidiano de quien lo recorre\n\nEl pacto con el diablo de los juicios de brujas era una caricatura creada por los acusadores — en el folclore vivo, el compromiso siempre fue con el oficio. La curandera mantiene el don por el uso: si deja de sanar, el rezo se enfría. El saber tradicional se sostiene en la práctica constante, no en juramentos solemnes. Por eso el camino torcido valora lo que se hace de verdad: tres prácticas vividas valen más que treinta ideas bonitas guardadas en el cajón\n\nEn tu rutina, esto pide una revisión honesta de vez en cuando: ¿qué de las sendas se volvió hábito real? ¿Qué solo admiraste y nunca hiciste? El error común es acumular rituales de estante — prácticas que existen solo en el cuaderno — y cargar culpa por no dar abasto con todo. La bruja tradicional simplifica: elige las prácticas innegociables, las hace bien y deja que el resto se vaya sin drama\n\nLleva esta síntesis: sin dogma, con raíz. Tu camino vale por lo que realmente vives, no por lo que acumulas en teoría. Firma el pacto contigo — pocas prácticas, verdaderas y sostenidas — y el camino torcido se vuelve inquebrantable, porque estará plantado en suelo real, regado todos los días',
        practice:
            'Relee con calma las páginas que creaste en esta senda, una a una. Sepáralas mentalmente en dos grupos: lo que ya se volvió práctica real en tu rutina y lo que quedó solo bonito en el papel. Después registra tus prácticas innegociables, lo que abandonas sin culpa y con qué te comprometes en este ciclo. El objetivo es firmar tu pacto de practicante: un acuerdo honesto contigo misma, sin dogma y con raíz',
        pageTitle: 'Mi Pacto de Practicante',
        pagePurpose: 'Firmar mi acuerdo con el camino',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Mis prácticas innegociables (las que hago de verdad):',
          'Lo que abandono sin culpa:',
          'Con qué me comprometo en este ciclo:',
          'La frase que resume mi camino torcido:',
        ],
      ),
      TrailLesson(
        id: 'bt_10',
        recordKind: LessonRecordKind.note,
        title: 'Transmisión: guardar y pasar adelante',
        teaching:
            'Todo saber tradicional sobrevive por transmisión: la abuela que sana y enseña el rezo, la vecina que pasa el té justo, la mano que guía otra mano. Sin esa corriente, oficios enteros mueren con quien los guardaba. Al llegar hasta aquí, te has vuelto eslabón de esa corriente — guardiana de lo que aprendiste y, un día, puente para alguien que aún ni sabe que va a necesitarte\n\nLa transmisión tradicional tiene sus modos: es oral, cercana y escogida. La curandera no enseña a cualquiera — observa, espera la madurez y, en algunas regiones, solo pasa el rezo en fechas especiales, como el Viernes Santo. El gesto se aprende mirando, la receta va de mano en mano, y el cuaderno de la familia atraviesa generaciones. Así es como un saber vence al tiempo: una persona confiando en otra, un eslabón a la vez\n\nEn tu día a día, transmitir comienza por guardar bien: escribe tus páginas como quien deja herencia, con claridad, citando de quién aprendiste cada cosa. Cuando alguien pida con respeto, enseña lo simple primero. Los errores comunes son los extremos: guardar todo por avaricia, hasta que el saber muera contigo, o esparcir sin cuidado lo que fue confiado con pedido de discreción y reserva\n\nQuédate con esta imagen: eres puente entre quien vino antes y quien aún vendrá. Cada página escrita con verdad es una semilla de la corriente. Guarda con celo, pasa adelante con generosidad — y tu camino torcido seguirá vivo mucho más allá de ti, como todo saber que fue amado y bien cuidado',
        practice:
            'Piensa en una persona, real o futura, a quien confiarías tus saberes — puede ser alguien de la familia, una amiga o alguien que aún ha de llegar. Lista lo que enseñarías primero y por qué, y registra en la página los tres saberes que pasarías adelante, junto con el consejo que darías a quien empieza. El objetivo es transformar lo que aprendiste en legado y asumir tu lugar en la corriente de la transmisión',
        pageTitle: 'Lo Que Dejo a la Corriente',
        pagePurpose: 'Registrar lo que merece ser transmitido',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Los 3 saberes que pasaría adelante:',
          'A quién (real o simbólico):',
          'La historia de mi linaje hasta aquí:',
          'El consejo que daría a quien empieza:',
        ],
      ),
    ],
  );
