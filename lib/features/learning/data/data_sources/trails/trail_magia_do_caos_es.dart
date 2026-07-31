import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Senda 'magia_do_caos' — contenido en español.
/// Paridad con _pt/_en verificada en test/trails_parity_test.dart.
const LearningTrail magiaDoCaosTrailEs = LearningTrail(
    id: 'magia_do_caos',
    emoji: '🌀',
    title: 'Magia del Caos',
    subtitle: 'Nada es verdad, todo está permitido crear',
    description:
        'La magia como tecnología experimental: la creencia como herramienta, sigilos, resultados medibles y cero dogma. Tú eres el laboratorio.',
    lessons: [
      TrailLesson(
        id: 'mc_01',
        recordKind: LessonRecordKind.note,
        title: 'La creencia como herramienta',
        teaching:
            'El axioma central de la magia del caos afirma que la creencia no es la verdad: es el instrumento. Si creer en algo produce el resultado deseado, la practicante viste esa creencia como un abrigo, trabaja con ella y luego la cuelga. Este giro importa porque te devuelve el poder: en lugar de esperar encontrar la fe perfecta, aprendes a elegir y operar creencias a propósito.\n\nEsto no es cinismo: es tomar la creencia tan en serio como para usarla deliberadamente. La magia del caos nació en el espíritu posmoderno, heredera de Austin Osman Spare, y trata cada sistema como un mapa útil, nunca como el territorio. Un día operas como animista, al otro como escéptica metódica: lo que cuenta es el efecto que cada lente produce en tu percepción y en tus resultados.\n\nEn el día a día de quien inicia, esto se vuelve experimento: adoptar por un período una creencia elegida y observar qué cambia en decisiones, postura y oportunidades. Prefiere creencias útiles y comprobables, una a la vez, y anota los efectos. El error común es el término medio tibio: creer a medias no genera datos. Viste la creencia por entero durante la prueba y quítatela por entero después.\n\nLleva contigo la imagen del abrigo: las creencias son prendas de trabajo, no tatuajes. Puedes cambiarlas según la tarea, sin culpa y sin perderte, porque quien elige eres tú. Bienvenida al laboratorio: aquí, creer es una técnica — y toda técnica se aprende con práctica y paciencia.',
        practice:
            'Vas a probar la creencia como herramienta. Primero, elige una creencia útil, afirmativa y comprobable, como: a las personas les gusta ayudarme. Después, vive 24 horas como si fuera absolutamente verdadera, actuando en coherencia total con ella. Por último, anota qué cambió en ti y a tu alrededor. El objetivo es sentir en la piel que una creencia vestida a propósito altera la percepción, la actitud y los resultados.',
        pageTitle: 'Experimento: Creencia de 7 Días',
        pagePurpose: 'Probar la creencia como herramienta',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'La creencia adoptada (afirmativa, comprobable):',
          'Criterio de éxito (cómo sé que funcionó):',
          'Diario de los 7 días (una línea por día):',
          'Veredicto del experimento:',
        ],
      ),
      TrailLesson(
        id: 'mc_02',
        recordKind: LessonRecordKind.sigil,
        title: 'Sigilos: el deseo cifrado',
        teaching:
            'El sigilo es el deseo cifrado: un símbolo que carga tu intención sin que la mente consciente logre leerla. Creado por Austin Osman Spare, el método transforma una frase de deseo en un glifo abstracto. Importa porque resuelve al mayor saboteador de la magia: la ansiedad de quien se queda vigilando el resultado y, sin querer, lo aleja.\n\nEl proceso de Spare tiene tres actos: escribir el deseo, eliminar las letras repetidas y fundir las restantes en un dibujo único. Después viene el paso decisivo: lanzar el glifo al inconsciente a través de un estado alterado, el gnosis — agotamiento, danza, mirada fija — y entonces olvidar. El olvido no es un detalle: la mente ansiosa sabotea, mientras el inconsciente, libre de vigilancia, trabaja en silencio.\n\nPara quien inicia, el desafío práctico es la formulación del deseo: frases afirmativas, en presente, sin negaciones. La herramienta de Sigilos de la app arma el glifo por ti, lo que libera tu energía para lo que importa: el lanzamiento y el olvido. El error más común es revisitar el sigilo a cada rato para comprobar si funcionó. Lanzaste, olvidaste: distráete de verdad y deja que la semilla germine en la oscuridad.\n\nGuarda esta llave: el sigilo funciona en la medida en que sueltas. Desear, cifrar, lanzar, olvidar — cuatro gestos simples que entrenan el arte más difícil de la magia, que es confiar en lo que no se ve. Tu inconsciente es un aliado competente: entrégale el pedido y quítate de su camino.',
        practice:
            'Vas a crear y lanzar tu primer sigilo. Abre la herramienta de la app en Herramientas, elige Sigilos y escribe tu deseo en frase afirmativa: el glifo se generará por ti. Antes de activar, define tu método de gnosis, como danza hasta el cansancio o mirada fija en una vela. Activa el sigilo en ese estado, después destruye o guarda el dibujo y distráete. El objetivo es completar el ciclo entero: desear, cifrar, lanzar y olvidar.',
        pageTitle: 'Mi Primer Sigilo Lanzado',
        pagePurpose: 'Registrar el método completo de sigilización',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Frase del deseo (¡escríbela y tacha después!):',
          'Método de gnosis usado:',
          'Cómo destruí/olvidé el sigilo:',
          '(En 1 mes) Resultados observados:',
        ],
      ),
      TrailLesson(
        id: 'mc_03',
        recordKind: LessonRecordKind.note,
        title: 'Gnosis: los portales del trance',
        teaching:
            'El gnosis es el estado en que la mente crítica calla y el comando mágico pasa directo al fondo de la psique. Es el momento de apertura que toda operación necesita: sin él, la intención queda atrapada en la capa parlanchina del pensamiento. Conocer tus propios caminos hacia ese estado es infraestructura mágica básica, tan esencial como el propio deseo que quieres lanzar.\n\nLa tradición caótica divide los portales en dos vías. La excitatoria sube: danza, tambor, hiperventilación leve, clímax — el cuerpo acelera hasta que la mente suelta el timón. La inhibitoria baja: inmovilidad, ayuno corto, mirada fija, silencio absoluto — el mundo desacelera hasta que solo queda el foco. Ninguna vía es superior; cada persona tiene sus portales naturales, y descubrirlos es un trabajo de mapeo personal.\n\nComienza por lo que tu cuerpo ya conoce: quien danza con facilidad tiende a la vía excitatoria; quien medita, a la inhibitoria. Prueba en sesiones cortas, con seguridad y sin sustancias — el cuerpo ya tiene todo lo que necesita. El error común es forzar la intensidad: el gnosis no es un desmayo, es el instante en que el mundo se afina. Registra cada prueba y respeta siempre tus límites físicos.\n\nLleva contigo la idea del portal: el gnosis no es un lugar lejano, es una puerta que tu propio cuerpo sabe abrir. Con práctica, aprendes a alcanzarla en pocos minutos, y cada operación mágica gana profundidad. Mapear tus estados alterados es conocer la llave de tu propia casa.',
        practice:
            'Vas a probar un portal inhibitorio hoy. Enciende una vela en un ambiente calmo, siéntate cómoda y sostén la mirada fija en la llama por 5 minutos, sin forzar los párpados, dejando la respiración desacelerar. Percibe el momento en que el mundo parece afinarse y los pensamientos se espacian. Al terminar, anota las sensaciones. El objetivo es reconocer en el cuerpo el sabor del gnosis para usarlo después en tus operaciones.',
        pageTitle: 'Mi Mapa de Gnosis',
        pagePurpose: 'Mapear mis estados alterados seguros',
        pageCategory: SpellCategory.energy,
        pagePrompts: [
          'Métodos excitatorios que funcionan en mí:',
          'Métodos inhibitorios que funcionan en mí:',
          'Mis límites de seguridad:',
          'El portal que voy a dominar primero:',
        ],
      ),
      TrailLesson(
        id: 'mc_04',
        recordKind: LessonRecordKind.note,
        title: 'El diario de resultados',
        teaching:
            'El diario de resultados es lo que separa a la caótica de la mística de sofá: un registro fiel de cada operación con fecha, técnica, estado y desenlace. Sin él, la memoria hace trampa — todo éxito se recuerda, todo fracaso se olvida convenientemente — y no aprendes nada. Con él, tu magia se vuelve un laboratorio de verdad, con historial y evolución visible.\n\nLa magia del caos se define como tecnología experimental, y un experimento sin datos no existe. El registro transforma impresiones vagas en patrones visibles: qué técnica rinde más, en qué estado operas mejor, cuánto tardan los efectos. Es el mismo espíritu que guio a Spare y a las caóticas modernas: resultados medibles por encima de teorías bonitas, cero dogma y revisión constante.\n\nEn la práctica, crea una plantilla corta y úsala siempre: fecha, operación, técnica, estado interno, resultado y una nota de confianza. Revisa en ciclos fijos, semanales o lunares. El error clásico es registrar solo cuando sale bien, o maquillar el fracaso con excusas. Sé implacable con el autoengaño y gentil con el proceso: el fracaso es dato precioso, no vergüenza.\n\nGuarda esta máxima: lo que no se registra, no se aprende. Tu diario es el instrumento más poderoso del laboratorio, porque transforma cada intento — bueno o malo — en escalón. La honestidad de hoy en el papel se convierte en maestría mañana en la práctica, y nadie puede hacer ese trabajo por ti.',
        practice:
            'Vas a auditar tus experimentos hasta aquí. Relee los registros de las lecciones anteriores — la creencia de 24 horas, el sigilo, las pruebas de gnosis — y evalúa cada uno con honestidad brutal: qué funcionó de verdad, qué fue coincidencia, qué fue sesgo de confirmación. Después, arma tu plantilla fija de registro para las próximas operaciones. El objetivo es fundar tu diario de resultados sobre datos limpios, no sobre deseos.',
        pageTitle: 'Mi Protocolo de Registro',
        pagePurpose: 'Sistematizar el diario de resultados',
        pageCategory: SpellCategory.study,
        pagePrompts: [
          'Lo que registro en toda operación (mi plantilla):',
          'Cuándo reviso (¿semanal? ¿lunar?):',
          'Mi escala de resultados:',
          'Primera revisión: aprendizajes:',
        ],
      ),
      TrailLesson(
        id: 'mc_05',
        title: 'Servidores: criaturas de propósito',
        teaching:
            'El servidor es un programa psíquico: una entidad creada por ti para cumplir una única función, como recordar, proteger o encontrar. A diferencia de los espíritus heredados de tradiciones, nace de tu diseño consciente. La técnica importa porque enseña, a escala pequeña y segura, cómo la atención da vida y forma a las construcciones de la mente.\n\nLa construcción sigue una receta clara: el servidor recibe nombre, forma visual, una función única y bien delimitada, un alimento simbólico — atención diaria, un gesto, un símbolo — y, punto crucial, una fecha de apagado. En la visión caótica, poco importa si es un ser real o un mecanismo psicológico: si cumple la función y responde al protocolo, es tecnología funcionando.\n\nPara quien inicia, el secreto es la modestia: un servidor para una tarea concreta de la semana, no un guardián cósmico. Escribe la función en una frase; si necesitas dos, son dos servidores. Aliméntalo en el horario acordado y observa. El error común es crear y abandonar: una entidad olvidada se vuelve ruido. Trátalo como creación responsable, con mantenimiento y jubilación digna.\n\nLleva esta imagen: el servidor es una aplicación que instalas en tu propia psique — propósito claro, consumo definido, fecha de vencimiento. Crear, mantener y apagar con respeto es un ciclo completo de responsabilidad mágica. Comienza pequeño y aprende el oficio de dar forma a lo invisible.',
        practice:
            'Vas a proyectar tu primer servidor. Elige una tarea concreta de esta semana, como recordar beber agua. Esboza a la criatura en dibujo o texto: define nombre, forma, la función única en una frase, el alimento simbólico y la fecha exacta de apagado. Preséntalo mentalmente a la tarea y aliméntalo una vez por día. El objetivo es experimentar el ciclo completo de crear, mantener y apagar una entidad de propósito.',
        pageTitle: 'Mi Primer Servidor',
        pagePurpose: 'Crear una entidad de propósito único',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Nombre, forma y función ÚNICA:',
          'Cómo lo alimento (atención, gesto, símbolo):',
          'Fecha y rito de apagado:',
          'Resultados de la primera semana:',
        ],
      ),
      TrailLesson(
        id: 'mc_06',
        recordKind: LessonRecordKind.rune,
        title: 'Cambio de paradigma',
        teaching:
            'El cambio de paradigma es el ejercicio-rey de la magia del caos: vivir un período entero dentro de otro sistema de creencias — una semana como animista, otra como escéptica radical, otra como devota. No se trata de burlarse ni de fingir por fuera: se trata de experimentar el sistema desde dentro, con las reglas, los ojos y los gestos de quien realmente cree.\n\nLa práctica nace de la postura posmoderna del caos: todo paradigma es un mapa, y los mapas se cambian según el viaje. Al habitar un sistema ajeno, descubres lo que revela y lo que esconde. Un ejemplo concreto: pasar tres días leyendo el mundo a través de las runas nórdicas, consultándolas en las decisiones del día, aunque tu camino habitual sea otro. La inmersión genera datos que la lectura desde fuera jamás daría.\n\nPara quien inicia, el formato seguro es corto y delimitado: elige el paradigma, escribe tus reglas de inmersión, define comienzo y fin, y registra a diario lo que cambia en la percepción. El error común es la inmersión a medias, visitando el sistema como turista apurada. Otro es olvidar la salida: terminado el plazo, cierra con claridad y vuelve a tu centro.\n\nEl premio de este ejercicio es la flexibilidad: quien ya vivió en varias casas de creencia nunca más confunde el mobiliario con el mundo. Cada paradigma visitado deja una herramienta en tu equipaje y afloja la ilusión de que existe una única manera correcta de ver. Viaja con curiosidad, aprende y vuelve más libre.',
        practice:
            'Vas a vivir 3 días en un paradigma diferente del tuyo — por ejemplo, el de las runas nórdicas. Define tus reglas de inmersión, abre la herramienta de Runas de la app en Herramientas y saca una runa por día, dejando que la lectura oriente decisiones pequeñas. Registra cada noche lo que cambió en tu percepción. Al final, cierra la inmersión con claridad. El objetivo es experimentar otro sistema desde dentro y ganar flexibilidad de creencia.',
        pageTitle: 'Informe de Cambio de Paradigma',
        pagePurpose: 'Experimentar otro sistema desde dentro',
        pageCategory: SpellCategory.study,
        pagePrompts: [
          'El paradigma visitado y mis reglas de inmersión:',
          'Diario de los días (qué cambió en la percepción):',
          'Lo que me traigo de vuelta conmigo:',
          'Lo que aprendí sobre MI paradigma:',
        ],
      ),
      TrailLesson(
        id: 'mc_07',
        recordKind: LessonRecordKind.desire,
        title: 'Magia del resultado: metas operativas',
        teaching:
            'La magia del resultado es el corazón pragmático del caos: magia al servicio de metas reales, con blanco específico, plazo definido y técnica elegida. Nada de pedidos vagos al universo: una operación bien diseñada se parece más a un proyecto que a una plegaria. Esto importa porque saca a la magia del terreno de la fantasía y la coloca en el de los efectos verificables.\n\nLa marca registrada caótica es la acción mundana casada: todo trabajo mágico viene acompañado de movimientos concretos en el mundo. El hechizo de empleo camina junto con currículums enviados; el sigilo de salud, con la consulta agendada. La lógica es de doble vía: la magia abre caminos y afina la percepción, mientras la acción garantiza que exista puerta donde el camino desemboque. Magia sin acción es lotería; acción sin magia es la mitad del arsenal.\n\nEn el día a día, diseña operaciones pequeñas y medibles: una meta de 30 días, una técnica, tres acciones mundanas y un criterio claro de éxito. Anota todo en el diario de resultados. Los errores comunes son metas nebulosas como querer prosperar en general, plazos infinitos y la tentación de esperar que el hechizo actúe solo mientras nada se mueve en la vida práctica.\n\nGraba esta fórmula: blanco claro, plazo real, técnica elegida y acción casada en el mundo. Cuando magia y movimiento caminan juntos, cada resultado — venga de donde venga — es conquista tuya. Dejas de pedir permiso al universo y pasas a negociar con él de igual a igual, usando las dos manos.',
        practice:
            'Vas a diseñar una operación completa de 30 días. Elige una meta real y específica, con plazo. Después define la técnica mágica — un sigilo, un servidor, lo que tu diario apruebe — y lista 3 acciones mundanas casadas que harás en el mismo período. Registra todo y marca la fecha de la evaluación. El objetivo es vivir la fórmula caótica por completo: magia y acción trabajando juntas por un resultado medible.',
        pageTitle: 'Operación de 30 Días',
        pagePurpose: 'Casar magia y acción para una meta',
        pageCategory: SpellCategory.prosperity,
        pagePrompts: [
          'Meta específica y plazo:',
          'Técnica mágica elegida:',
          'Mis 3 acciones mundanas casadas:',
          '(En el plazo) Resultado y análisis:',
        ],
      ),
      TrailLesson(
        id: 'mc_08',
        title: 'Deshacer: el destierro caótico',
        teaching:
            'El destierro es la limpieza del laboratorio: la técnica que quita residuos entre operaciones, deshace trabajos que no sirvieron y devuelve el espacio interno al estado neutro. Sin él, restos de intención, ansiedad e imágenes cargadas se acumulan de un rito a otro. Cerrar bien es tan importante como comenzar bien — quizás incluso más.\n\nLa tradición caótica cultiva desde la risa desterradora — carcajear de la propia operación hasta disolverla por completo — hasta versiones adaptadas del pentagrama ritual. La risa funciona porque quiebra la gravedad: nada resiste a una buena carcajada, ni siquiera tu propia solemnidad. Pero el criterio caótico es uno solo: el rito tiene que funcionar para ti. Prueba formatos y mide el efecto, como en cualquier técnica.\n\nEn lo cotidiano, desterrar también es psicológico: cerrar las pestañas mentales del día, cortar la rumiación, marcar el fin de un ciclo con un gesto físico — palmas, una palabra, un soplo a la vela. Quien inicia suele saltarse esta etapa por prisa o por creerla poco importante, y después carga la operación en la cabeza por días. Un rito corto y repetido vale más que uno elaborado y olvidado.\n\nLleva contigo la regla del laboratorio limpio: toda operación merece un fin nítido. Un gesto, una risa, un corte — y la mesa queda libre para el próximo experimento. Quien sabe cerrar duerme mejor, opera mejor y no confunde el eco de ayer con la señal de hoy.',
        practice:
            'Vas a crear tu primera limpieza energética. Al final del día, ponte de pie, respira hondo y da 3 palmadas con firmeza. En seguida, ríe fuerte de todo lo que quedó pendiente — deja que la carcajada disuelva el peso. Siente el corte entre lo que pasó y el ahora. Repite por algunos días y anota el efecto en el cuerpo y en el sueño. El objetivo es instalar un rito simple de destierro que cierre ciclos y limpie el espacio entre operaciones.',
        pageTitle: 'Mi Destierro',
        pagePurpose: 'Crear mi limpieza energética',
        pageCategory: SpellCategory.banishing,
        pageType: SpellType.banishment,
        pagePrompts: [
          'Mi rito de destierro (pasos):',
          'Cuándo lo uso (¿entre rituales? ¿diario?):',
          '¿Funcionó la risa desterradora? Cómo fue:',
          'Lo que percibo después de desterrar:',
        ],
      ),
      TrailLesson(
        id: 'mc_09',
        recordKind: LessonRecordKind.oracle,
        title: 'Sincronicidad: surfear el azar',
        teaching:
            'Para la caótica, la sincronicidad es el feedback del sistema: cuando las coincidencias comienzan a alinearse con tu operación — la canción justa, el encuentro improbable, la palabra repetida — algo está en curso. Leer esos ecos importa porque indican si la ruta está viva, funcionando como el panel de instrumentos de tu vuelo mágico.\n\nEl término viene de Jung: coincidencias significativas sin causa común aparente. La postura caótica es pragmática: la sincronicidad no se fuerza — se surfea. Registras el eco, agradeces y ajustas la ruta, sin transformar cada hoja que cae en profecía. El azar también puede consultarse activamente: los oráculos son generadores de aleatoriedad significativa, invitaciones a que el patrón emerja.\n\nLa trampa de quien inicia es la apofenia: ver patrón en todo, señal en cada letrero de calle. El antídoto es el diario de resultados: anota el eco en el momento en que ocurre, reléelo con frialdad después y pregunta si apuntaba a algo verificable. Trabaja con una pregunta a la vez, colecta los ecos de un día entero y solo entonces haz la lectura, honesta y sin forzar.\n\nGuarda la imagen de la surfista: no creas la ola del azar, pero aprendes a montarla. Señal registrada, gratitud breve, ruta ajustada — y el diario como quilla para que la lectura no se vuelva delirio. El mundo conversa con quien opera; tu trabajo es escuchar con atención, sin inventar lo que no fue dicho.',
        practice:
            'Vas a lanzar una pregunta al azar. Por la mañana, formula una cuestión clara y haz una consulta en la herramienta de Oráculo de la app, en Herramientas, guardando la respuesta como semilla. A lo largo del día, colecta los ecos — coincidencias, frases, encuentros — sin forzar nada. Por la noche, relee todo y haz la lectura honesta: ¿señal o apofenia? El objetivo es entrenar la escucha del azar con el diario como protección contra el autoengaño.',
        pageTitle: 'Diario de Sincronicidades',
        pagePurpose: 'Registrar y leer los ecos del azar',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Mi pregunta lanzada:',
          'Los ecos colectados en el día:',
          'Lectura honesta (¿señal o apofenia?):',
          'Ajuste de ruta decidido:',
        ],
      ),
      TrailLesson(
        id: 'mc_10',
        recordKind: LessonRecordKind.note,
        title: 'Construye tu propio sistema',
        teaching:
            'El destino de la magia del caos es la autonomía: después de probar creencias, técnicas y paradigmas, armas tu propio sistema — personal, funcional y revisable. Ningún grimorio ajeno conoce tus portales de gnosis, tus símbolos vivos, tu ritmo. Llegar aquí importa porque cierra la fase de seguir mapas e inaugura la fase de diseñarlos.\n\nEl criterio de armado es experimental: si pasa por tu diario de resultados, es tuyo. Mezcla sin miedo el esbat con sigilos, la sanación de la abuela con servidores modernos — la tradición caótica siempre trató los sistemas como cajas de herramientas, no como iglesias. Los límites son solo éticos: nada de daño a personas o animales, nada criminal. El resto — lo extraño, lo simbólico, lo inventado — es materia prima legítima.\n\nEn la práctica, comienza sobria: tres técnicas centrales comprobadas, tus principios innegociables y un área de pruebas para lo que aún está en evaluación. Dale al sistema un nombre y una fecha de revisión, como un software que gana versiones. El error común es la colcha infinita: acumular técnicas sin nunca podar. Un buen sistema es el que usas de verdad, no el que adorna el cuaderno.\n\nLleva contigo la idea de la versión 1.0: tu sistema no necesita nacer terminado, necesita nacer tuyo. Revisable, honesto y vivo, crecerá con cada experimento registrado. Nada es verdad, todo está permitido crear — y tu magia, de ahora en adelante, lleva tu propia firma.',
        practice:
            'Vas a consolidar tu camino. Relee todas tus páginas y registros de las sendas, con calma, y encierra en un círculo lo que ya funciona como tu manera: técnicas que rinden, símbolos que hablan, ritmos que sostienen. Después, organiza lo esencial en tres técnicas centrales, tus principios y una lista de lo que sigue en prueba. Marca la fecha de la primera revisión. El objetivo es transformar la experiencia acumulada en tu sistema mágico versión 1.0.',
        pageTitle: 'Mi Sistema Mágico v1.0',
        pagePurpose: 'Consolidar mi camino personal',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Mis 3 técnicas centrales:',
          'Mis principios innegociables:',
          'Lo que estoy probando ahora:',
          'Fecha de la próxima revisión del sistema:',
        ],
      ),
    ],
  );
