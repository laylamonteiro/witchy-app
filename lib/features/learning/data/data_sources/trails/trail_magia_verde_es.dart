import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Senda 'magia_verde' — contenido en español.
/// Paridad con _pt/_en verificada en test/trails_parity_test.dart.
const LearningTrail magiaVerdeTrailEs = LearningTrail(
    id: 'magia_verde',
    emoji: '🌿',
    title: 'Magia Verde',
    subtitle: 'El camino de las hierbas y de la tierra',
    description:
        'La brujería del jardín, de la cocina y del bosque: aprender de las plantas, sus ciclos y poderes — escribiendo tu herbario mágico',
    lessons: [
      TrailLesson(
        id: 'mv_01',
        recordKind: LessonRecordKind.note,
        title: 'Conocer una planta de verdad',
        teaching:
            'La magia verde no comienza memorizando tablas de correspondencias — comienza con UNA planta conocida de verdad: nombre, olor, textura, cómo reacciona al agua y al sol. Conocer de cerca a una única aliada vale más que memorizar cien nombres, porque la magia verde nace de la relación, no del catálogo. Por eso este es el primer paso del camino\n\nLas brujas verdes tradicionales tenían una relación profunda con unas pocas docenas de plantas: sabían cosechar en el momento justo, agradecían, usaban cada parte, de la raíz a la flor. El romero de la ventana, la ruda del portón y la menta del patio eran vecinas conocidas, no ítems de una lista. Esa intimidad — observar la planta a lo largo de los días y de las estaciones — es lo que transforma la información en sabiduría\n\nEn lo cotidiano, esto significa elegir una planta accesible — una maceta de tu casa, un árbol del camino — y visitarla con atención verdadera. Observa las hojas, el perfume, la textura, cómo amanece. El error común de la principiante es querer trabajar con diez hierbas a la vez y no conocer ninguna de verdad. Ve despacio: una aliada bien conocida sostiene mucha magia\n\nTu primera página de magia verde es el retrato de una aliada, escrito con tus propios sentidos. Guarda esta idea como quien guarda una semilla: antes de usar una planta, conoce la planta. La relación viene antes del hechizo — y es ella la que da raíz, fuerza y verdad a todo lo que florece después en tu camino',
        practice:
            'Pasa 5 minutos con una planta accesible usando los cinco sentidos con seguridad. Primero observa colores y formas, después toca con delicadeza, huele las hojas y escucha el ambiente alrededor — sin probar nada, pues nunca se lleva a la boca lo que no se conoce con certeza. Por último, anota 3 observaciones que ningún libro daría. El objetivo es iniciar una relación real con tu primera aliada verde',
        pageTitle: 'Mi Primera Planta Aliada',
        pagePurpose: 'Registrar la relación con una planta',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['La planta elegida'],
        pagePrompts: [
          'Nombre de la planta y dónde vive:',
          'Mis 3 observaciones directas:',
          'Usos mágicos tradicionales (investigué en la Enciclopedia):',
          'Lo que siento cerca de ella:',
        ],
      ),
      TrailLesson(
        id: 'mv_02',
        title: 'El té como ritual',
        teaching:
            'Agua, fuego, planta e intención: el té es el ritual verde más accesible que existe. Reúne los elementos esenciales de la magia en una taza y cabe en cualquier rutina, en cualquier cocina. La diferencia entre tomar un té y ritualizar un té no está en ingredientes raros, sino en la presencia con que preparas y bebes cada sorbo\n\nRitualizar significa elegir la hierba por la intención — manzanilla para calmar, menta para aclarar, hierba luisa para suavizar —, revolver en círculos en el sentido del objetivo, horario para atraer y antihorario para alejar, y beber en silencio, dejando que el calor lleve la intención hacia dentro. Las curanderas y las abuelas siempre lo supieron: un té hecho con cuidado carga mucho más que principios activos\n\nEn el día a día de la bruja principiante, el té ritual puede ser el momento más mágico del día: cinco minutos de fogón, vapor y silencio. La seguridad primero: usa solo plantas comestibles conocidas, respeta las contraindicaciones y, ante la duda, no bebas. El error más común es preparar con prisa, mirando el celular — la presencia es el ingrediente principal, y sin ella el rito se vuelve rutina\n\nGuarda esta idea: la taza es un pequeño caldero que cabe en tus manos. Siempre que necesites un ritual simple e inmediato, recuerda que agua caliente, una hierba segura y tu intención ya forman un hechizo completo. Repetido con constancia — siete días, cada luna —, ese gesto pequeño se convierte en una de las prácticas más profundas de la magia verde',
        practice:
            'Prepara un té simple con presencia total, de principio a fin. Primero elige una hierba comestible conocida y nombra la intención; después calienta el agua observando el vapor, revuelve en círculos en el sentido de tu objetivo y cuela con calma; por último, bebe en silencio, sin celular, sintiendo el calor llevar la intención hacia dentro. El objetivo es experimentar cómo la presencia transforma un gesto común en ritual',
        pageTitle: 'Mi Té Ritual',
        pagePurpose: 'Crear una receta ritual de té',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Hierba comestible', 'Agua', 'Miel (opcional)'],
        pagePrompts: [
          'Hierba e intención de mi té:',
          'Mi modo de preparación ritual:',
          'Lo que pienso/digo mientras bebo:',
          '¿Cómo pienso repetirlo (7 días? cada luna?):',
        ],
      ),
      TrailLesson(
        id: 'mv_03',
        title: 'Saquitos y amuletos de hierbas',
        teaching:
            'El saquito es la magia verde portátil: hierbas secas reunidas en una bolsita de tela, cerrada con nudo y palabra de poder. Lleva la fuerza de las plantas adonde vayas — bajo la almohada para buenos sueños, en el bolso para protección, en el armario para armonía. Es uno de los amuletos más antiguos y simples de la brujería, y por eso mismo uno de los más queridos\n\nEl armado clásico sigue una lógica de tres partes: la hierba principal, que carga la intención; una hierba de apoyo, que amplía y equilibra; y un fijador — corteza, raíz o piedrita — que ancla el trabajo en el tiempo. El color de la tela conversa con el objetivo: rojo para valentía, verde para prosperidad, blanco para paz. Tradiciones populares de todo el mundo usan variaciones de ese mismo diseño\n\nPara la principiante, la propia cocina ya es un armario mágico: laurel, romero, canela, clavo y manzanilla rinden combinaciones poderosas. El error común es acumular saquitos sin propósito claro — cada uno debe nacer de una intención definida y ganar un lugar propio donde vivir. Cuando sientas que cumplió su papel, deshazlo o renuévalo con gratitud, devolviendo las hierbas a la tierra si puedes\n\nLleva contigo esta imagen: un saquito es una intención envuelta en tela y sellada con un nudo. Pocas hierbas, propósito claro y palabra dicha con firmeza valen más que decenas de ingredientes mezclados sin escucha. Dondequiera que viva tu bolsita — almohada, bolso o armario —, seguirá susurrando la intención que amarraste en ella',
        practice:
            'Separa hierbas secas que ya tengas en la cocina, como laurel, romero y canela, y siente qué combinación pide existir. Primero define la intención; después elige la hierba principal, la de apoyo y un fijador, tocando y oliendo cada una con calma; por último, anota la combinación elegida y el color de tela que conversa con el objetivo. La meta es entrenar la escucha de las plantas antes de armar tu primer saquito',
        pageTitle: 'Mi Primer Saquito',
        pagePurpose: 'Armar un amuleto de hierbas',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['3 hierbas secas', 'Tela', 'Cinta o hilo'],
        pagePrompts: [
          'Intención y las 3 hierbas elegidas (¿por qué?):',
          'Color de la tela y motivo:',
          'Palabras dichas al cerrar el nudo:',
          'Dónde vive ahora:',
        ],
      ),
      TrailLesson(
        id: 'mv_04',
        title: 'La cocina como altar',
        teaching:
            'La bruja de cocina lo sabe: la olla es caldero, la cuchara de palo es varita, el condimento es hechizo. La cocina es el altar más antiguo de la humanidad — el lugar donde fuego, agua, tierra y aire se encuentran todos los días. Cocinar con intención transforma el alimento en magia y hace de la rutina más común un espacio sagrado, sin necesitar nada más que lo que ya tienes\n\nLa tradición de la magia de cocina atraviesa culturas y generaciones: revolver en sentido horario para atraer, condimentar nombrando el deseo en voz baja, servir como quien bendice. Cada ingrediente carga correspondencias — canela para prosperidad, ajo para protección, albahaca para armonía — y el calor del fuego es lo que sella la intención en el alimento, como un horno sella el pan\n\nEn el día a día, no necesitas recetas especiales: el arroz de todos los días puede ser encantado. Comienza nombrando una intención antes de encender el fuego y declara algo con cada ingrediente clave que entre en la olla. El error común es cocinar con rabia o con prisa — el alimento absorbe el estado de quien lo prepara, así que respira hondo antes de comenzar y cocina como quien reza\n\nGuarda esta verdad simple: la comida encantada más poderosa es la hecha para alguien que amas, incluida tú misma. No esperes ocasiones especiales — el altar de la cocina se enciende todos los días. Siempre que cocines, recuerda que tus manos ya son instrumentos mágicos y que cada olla en el fuego puede ser un hechizo en marcha',
        practice:
            'Cocina algo simple hoy transformando la preparación en hechizo. Primero elige la receta y define una intención clara; después, con cada ingrediente añadido, declara en voz baja lo que trae — protección, dulzura, fuerza; revuelve en sentido horario para atraer y termina sirviendo como quien bendice. El objetivo es sentir en la práctica cómo la intención cambia tu relación con el alimento y con quien lo recibe',
        pageTitle: 'Mi Receta Encantada',
        pagePurpose: 'Transformar una receta en hechizo',
        pageCategory: SpellCategory.home,
        pagePrompts: [
          'La receta y su intención:',
          'Lo que declaro con cada ingrediente clave:',
          'Mi gesto al servir:',
          'Para quién cociné y qué pasó:',
        ],
      ),
      TrailLesson(
        id: 'mv_05',
        title: 'Plantar: el hechizo más lento',
        teaching:
            'Plantar una semilla con intención es el hechizo de larga duración de la magia verde: el crecimiento de la planta refleja el crecimiento del deseo. Mientras muchos hechizos buscan un resultado rápido, la siembra enseña la magia del tiempo — aquello que siembras con cuidado hoy se vuelve fuerza enraizada mañana, en la maceta y en la vida\n\nLa estructura es simple y antigua: maceta, tierra, semilla, palabra. Las campesinas y curanderas siempre plantaron nombrando deseos — un romero para la salud de la casa, una albahaca para la abundancia de la mesa. Después del gesto inicial viene el verdadero trabajo: cuidar todos los días, regar, dar sol, observar. El hechizo no está solo en la siembra; está en la constancia que lo sostiene\n\nPara la principiante, hasta un poroto en algodón sirve de comienzo. El error común es plantar con entusiasmo y olvidar en la primera semana — y ahí vive la lección: si la planta se marchita, el mensaje también es mágico. Pregúntate qué cuidado está faltando, allí en la maceta y en la intención que carga. Ajusta el riego, ajusta la vida, y vuelve a empezar sin culpa\n\nLleva esta idea: toda intención es una semilla y todo cuidado diario es el hechizo continuando en silencio. Planta despacio, cuida con constancia y confía en el tiempo de la tierra — rara vez es el nuestro, y casi siempre es el correcto. Cuando aparezca el primer brote, entenderás por qué la magia más duradera es la que crece despacio',
        practice:
            'Planta una semilla o un plantín — hasta un poroto sirve — dedicando la siembra a una intención de crecimiento. Primero prepara maceta y tierra con calma; después planta diciendo en voz alta lo que deseas ver crecer junto con ella; por último, asume un compromiso simple de cuidado diario, como regar y observar. El objetivo es vivir un hechizo lento, en el que cuidar la planta es cuidar la propia intención',
        pageTitle: 'Mi Siembra Mágica',
        pagePurpose: 'Consagrar una siembra a una intención',
        pageCategory: SpellCategory.prosperity,
        pageIngredients: ['Semilla o plantín', 'Maceta y tierra'],
        pagePrompts: [
          'Lo que planté y la intención dedicada:',
          'Mis palabras en la siembra:',
          'Mi compromiso de cuidado diario:',
          'Diario del crecimiento (actualiza aquí):',
        ],
      ),
      TrailLesson(
        id: 'mv_06',
        title: 'Sahumado: el aire que limpia',
        teaching:
            'El humo de hierbas es la escoba energética de la magia verde: donde lo denso se acumula, pasa, suelta y renueva. Sahumar es una de las prácticas de limpieza más antiguas de la humanidad, presente en incontables tradiciones alrededor del mundo, y sigue siendo uno de los ritos más directos para cambiar la sensación de un espacio — y de quien vive en él\n\nCada hierba tiene su oficio en el humo: romero para renovar, laurel para prosperar, ruda para cortar lo que pesa. El rito tradicional recorre la casa desde el fondo hacia la puerta de entrada, pasando por los rincones y detrás de las puertas, siempre con las ventanas abiertas — lo denso sale, lo nuevo entra. La dirección del recorrido importa tanto como la hierba elegida: conduces la limpieza hacia afuera\n\nEn lo cotidiano, comienza pequeño: una habitación, una hierba, un recipiente resistente al fuego. Respeta alergias, animales y vecinos, y nunca dejes brasas sin vigilancia. Atención también al origen de las hierbas: la magia verde es responsabilidad ecológica, así que prefiere lo que cultivas o compras de fuentes conscientes. El error común es sahumar con la casa cerrada — sin salida, lo denso no se va\n\nGuarda la imagen: el humo es oración visible y escoba invisible al mismo tiempo. Cuando el ambiente pese — después de una discusión, de una semana difícil, de una visita que dejó rastro —, recuerda que una hierba seca, una brasa segura y ventanas abiertas bastan para renovar el aire. El de afuera y, con un poco de presencia, también el de adentro',
        practice:
            'Sahuma una única habitación hoy con una hierba que ya tengas en casa. Primero abre las ventanas y enciende la hierba en un recipiente resistente al fuego; después recorre el espacio con calma, desde el fondo hacia la salida, llevando el humo a los rincones y detrás de la puerta; por último, apaga todo con seguridad y siéntate un instante. El objetivo es observar el cambio en la sensación del espacio antes y después del rito',
        pageTitle: 'Mi Sahumado',
        pagePurpose: 'Crear mi rito de limpieza por el aire',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Hierbas secas', 'Recipiente resistente al fuego'],
        pagePrompts: [
          'Mi mezcla de sahumado y el propósito de cada hierba:',
          'Mi recorrido por la casa:',
          'Palabras que acompañan el humo:',
          'Diferencia que sentí en el ambiente:',
        ],
      ),
      TrailLesson(
        id: 'mv_07',
        title: 'Aceites y ungüentos',
        teaching:
            'El aceite condimentado es la poción de uso continuo de la bruja verde: aceite de oliva o vegetal, hierbas y tiempo. A diferencia del té, que se hace y se bebe al momento, el aceite madura despacio y luego te acompaña por semanas — ungiendo velas, amuletos, muñecas y puertas con la intención que carga desde el primer día\n\nLa preparación tradicional es paciente: hierbas dentro de un frasco oscuro cubierto de aceite, reposando por cerca de tres semanas, agitado a diario mientras renuevas la intención en voz baja o en pensamiento. Al final, se cuela y se guarda al abrigo de la luz. Romero en aceite de oliva para la vitalidad y ajo para la protección son ejemplos clásicos de las cocinas y boticas de siempre\n\nEn el día a día, el aceite se vuelve una herramienta discreta: una gota en la vela antes de encenderla, un toque en las muñecas antes de una conversación difícil, un trazo en el marco de la puerta. Rotula siempre con nombre, fecha y propósito — bruja organizada es bruja poderosa. El error común es olvidar el frasco en el fondo del armario: sin la agitación diaria, el hechizo pierde el hilo. Y usa sobre la piel solo hierbas y aceites seguros\n\nLleva esta síntesis: el aceite mágico es intención que madura en la oscuridad, gota a gota, día tras día. Tiempo, constancia y una etiqueta bien hecha transforman un frasco simple en una poción que trabaja por ti durante semanas. Comienza hoy tu primer frasco y deja que las tres semanas de espera sean, ellas mismas, parte del hechizo',
        practice:
            'Comienza hoy un aceite simple, como romero en aceite de oliva, dedicado a una intención. Primero higieniza un frasco oscuro y coloca la hierba cubierta de aceite; después agita el frasco todos los días repitiendo la intención, por cerca de tres semanas; por último, cuela, rotula con nombre, fecha y propósito y registra el primer uso. Usa solo hierbas seguras y no ingieras el preparado. El objetivo es practicar la magia paciente, que madura con el tiempo',
        pageTitle: 'Mi Aceite Mágico',
        pagePurpose: 'Preparar un aceite condimentado ritual',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Aceite vegetal', 'Hierbas', 'Frasco oscuro'],
        pagePrompts: [
          'Receta (aceite, hierbas, proporciones):',
          'Intención y usos planeados:',
          'Fecha de inicio y de colado:',
          'Cómo fue el primer uso:',
        ],
      ),
      TrailLesson(
        id: 'mv_08',
        recordKind: LessonRecordKind.note,
        title: 'El jardín de luna',
        teaching:
            'La luna es la gran regente de los ritmos de la magia verde. La tradición planta lo que crece hacia arriba en luna creciente y las raíces en menguante; cosecha hojas de poder en llena; descansa la tierra en nueva. Alinear el trabajo verde a las fases lunares es entrar en el compás que jardineras y brujas siguen hace generaciones — el compás del cielo marcando el tiempo de la tierra\n\nEse saber viene de los almanaques rurales y de la observación paciente del cielo: la creciente favorece los comienzos y la expansión, la llena es el auge de la fuerza — hora de cosechar hojas y celebrar —, la menguante pide poda y desapego, y la nueva invita al reposo y a la planificación. Más que agricultura, es entrenamiento de paciencia mágica: no todo es para ahora, y cada cosa tiene su luna justa\n\nEn lo cotidiano, no necesitas huerta para practicar: regar, podar hojas secas, cambiar una maceta de lugar o simplemente planificar ya son acciones verdes que pueden seguir la luna. El Calendario Lunar de la app es tu almanaque de bolsillo — consulta la fase antes de actuar. El error común es forzar comienzos en menguante y frustrarse: respetar el descanso también es magia\n\nGuarda el compás: creciente comienza, llena cosecha, menguante suelta, nueva descansa. Cuando estés en duda sobre el momento justo de actuar, mira al cielo — o a tu almanaque de bolsillo — y pregunta en qué luna estás. Con el tiempo, ese compás deja de ser consulta y se vuelve instinto: tu jardín y tu vida pasan a girar juntos con la luna',
        practice:
            'Descubre la fase de la luna de HOY en el Calendario Lunar de la app y haz una acción verde alineada a ella: plantar o comenzar algo en creciente, cosechar o celebrar en llena, podar o soltar en menguante, descansar y planificar en nueva. Primero consulta la fase, después elige el gesto que combina con ella y realízalo con presencia; por último, anota lo que hiciste. El objetivo es empezar a vivir los ciclos en vez de solo conocerlos',
        pageTitle: 'Mi Calendario Verde',
        pagePurpose: 'Alinear siembras e intenciones a la luna',
        pageCategory: SpellCategory.prosperity,
        pagePrompts: [
          'En la próxima luna NUEVA voy a (descansar/planificar):',
          'En CRECIENTE voy a (plantar/comenzar):',
          'En LLENA voy a (cosechar/celebrar):',
          'En MENGUANTE voy a (podar/soltar):',
        ],
      ),
      TrailLesson(
        id: 'mv_09',
        recordKind: LessonRecordKind.gratitude,
        title: 'Cosecha y agradecimiento',
        teaching:
            'Cosechar es la mitad olvidada de la siembra. Mucha gente aprende a sembrar y a cuidar, pero pocas aprenden a recibir con reverencia lo que la tierra entrega. En la magia verde, la cosecha es un rito completo en sí misma — y la forma en que cosechas dice tanto sobre tu práctica como la forma en que plantas\n\nLa cosecha ritual tradicional pide cuatro gestos: la hora justa — según la tradición, la mañana, después de que el rocío se seca —, el pedido de permiso a la planta antes de tocar, el corte limpio que no lastima más de lo necesario y el agradecimiento sincero. Y una regla de oro: uso íntegro, nada cosechado en vano. Así cosechaban las curanderas sus hierbas de poder, con el respeto de quien visita a una maestra\n\nEn el día a día, esto vale hasta para una hoja de tu maceta o una fruta elegida en la feria con presencia: detente, pide permiso en pensamiento, cosecha con delicadeza, agradece. El error común es cosechar en automático, como quien toma un objeto cualquiera — la prisa quiebra el vínculo. Y recuerda: el mismo rito sirve para las cosechas simbólicas de la vida — reconocer lo que llegó, agradecer y usar bien\n\nLleva contigo la regla de oro de la bruja verde: nada cosechado en vano. Permiso, corte limpio, gratitud y uso íntegro — cuatro gestos simples que transforman el acto de recibir en ceremonia. Practícalos en la planta y después en la vida: quien aprende a cosechar con reverencia descubre que la gratitud es, ella misma, una forma de abono para las próximas cosechas',
        practice:
            'Cosecha algo hoy con el rito completo — puede ser una hoja de tu maceta o una fruta de la feria elegida con presencia. Primero detente ante la planta y pide permiso en silencio; después haz el corte o la elección con delicadeza; en seguida agradece con palabras tuyas; por último, usa integralmente lo que cosechaste, sin desperdicio. El objetivo es aprender a recibir con la misma reverencia con que se planta',
        pageTitle: 'Mi Rito de Cosecha',
        pagePurpose: 'Ritualizar el acto de cosechar',
        pageCategory: SpellCategory.prosperity,
        pagePrompts: [
          'Lo que coseché y cómo pedí permiso:',
          'Mi agradecimiento a la planta/a la vida:',
          'Cómo usé integralmente lo que coseché:',
          '¿Qué cosecha simbólica estoy viviendo ahora?',
        ],
      ),
      TrailLesson(
        id: 'mv_10',
        recordKind: LessonRecordKind.note,
        title: 'Tu herbario mágico',
        teaching:
            'La última página de esta senda es, en verdad, una portada: la apertura de tu herbario mágico, la lista viva de tus plantas aliadas con los usos probados por TI. Más que un cuaderno de anotaciones, el herbario es el retrato de tu relación con el mundo verde — único, personal e intransferible, como toda magia que nace de la experiencia\n\nLas brujas verdes de antaño guardaban sus saberes en cuadernos de recetas, hojas prensadas y memoria pasada entre generaciones. El valor de esos registros nunca estuvo en la cantidad, sino en la verdad: cada hierba anotada había sido cosechada, preparada y observada de cerca. Tu herbario sigue esa misma tradición — nunca está terminado, crece con cada estación, como el jardín\n\nDe aquí en adelante, cada planta nueva merece una página propia en tu grimorio: nombre, observaciones directas, usos que tú misma probaste, recetas que funcionaron. Relee tus páginas verdes de vez en cuando y visita la Enciclopedia de Hierbas cuando quieras elegir la próxima aliada. El error común es copiar tablas hechas sin vivencia — registra solo lo que pasó por tus manos\n\nLleva esta certeza: comenzaste la senda conociendo una única planta y la terminas con un camino entero por delante. El herbario crece al ritmo del jardín — una aliada a la vez, una estación a la vez, una página a la vez. La tierra tiene tiempo, y ahora tú también: sigue escribiendo, y tu grimorio verde florecerá junto contigo',
        practice:
            'Cierra la senda organizando tu índice vivo. Primero relee las páginas verdes que escribiste a lo largo de las lecciones, anotando cada planta y el uso que realmente probaste; después visita la Enciclopedia de Hierbas y elige la próxima aliada que deseas conocer; por último, registra por qué te llamó. El objetivo es consolidar lo que fue vivido y abrir espacio para que el herbario siga creciendo estación tras estación',
        pageTitle: 'Mi Herbario: Índice Vivo',
        pagePurpose: 'Consolidar mis plantas aliadas',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Mis aliadas hasta aquí (planta → uso probado):',
          'La próxima planta que quiero conocer y por qué:',
          'Mi ritual verde favorito de esta senda:',
          'Lo que la tierra me enseñó sobre el tiempo:',
        ],
      ),
    ],
  );
