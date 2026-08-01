import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Sendero 'aguas_magicas' — contenido en español.
/// Paridad con _pt/_en verificada en test/trails_parity_test.dart.
const LearningTrail aguasMagicasTrailEs = LearningTrail(
    id: 'aguas_magicas',
    emoji: '💧',
    title: 'Aguas Mágicas',
    subtitle: 'Luna, Sol, lluvia, mar y río en tu caldero',
    description:
        'Cada agua lleva una memoria y un poder distinto: aprende a recoger, preparar y usar las aguas de la naturaleza — escribiendo tu propio libro de las aguas',
    lessons: [
      TrailLesson(
        id: 'am_01',
        recordKind: LessonRecordKind.note,
        title: 'El agua en la brujería',
        teaching:
            'El agua es la gran conductora de la magia: disuelve, guarda, lleva y devuelve. En casi toda tradición de brujería cumple los tres papeles esenciales — limpiar lo que pesa, cargar la intención y sellar el trabajo. Antes de conocer las aguas una a una, conviene entender por qué este elemento es tan central: el agua lo toca todo, lo atraviesa todo y cambia de forma sin perder su esencia\n\nLas tradiciones dicen que el agua tiene memoria: absorbe la energía del lugar de donde vino y del momento en que fue recogida. Por eso el agua de lluvia no sirve para el mismo trabajo que el agua del mar, y el agua recogida bajo la luna llena no es la misma que la recogida al mediodía. Recoger agua es recoger un momento — y ese es el arte que enseña este sendero\n\nEn lo cotidiano, la bruja de las aguas trabaja con lo que tiene: el grifo también es agua, y puede bendecirse. Pero las aguas especiales — de luna, de sol, de lluvia, de tormenta, del mar, de río — son reservas de energía concentrada para los trabajos que piden más fuerza. La regla de oro desde ya: etiqueta siempre tus frascos con el tipo de agua y la fecha de la recogida\n\nGuarda esta imagen: cada frasco de agua en tu estante es un momento embotellado. En este sendero aprenderás a recoger cada uno, para qué sirven y cómo despedirlos con respeto. Tu primera página es el inventario de lo que ya tienes — y de lo que quieres recoger',
        practice:
            'Haz hoy tu inventario de las aguas. Primero observa: ¿qué aguas pasan por tu vida — lluvia en la ventana, un río en el camino, el mar cerca o lejos? Después separa 2 o 3 frascos de vidrio limpios, lávalos bien y déjalos secar. Por último, escribe en etiquetas el nombre de las primeras aguas que quieres recoger. El objetivo es preparar el terreno: la bruja de las aguas empieza organizando sus frascos',
        pageTitle: 'Mi Libro de las Aguas',
        pagePurpose: 'Abrir el inventario de mis aguas mágicas',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Frascos de vidrio', 'Etiquetas'],
        pagePrompts: [
          'Aguas que existen cerca de mí:',
          'Frascos que preparé:',
          'La primera agua que quiero recoger y por qué:',
          'Dónde guardaré mi reserva:',
        ],
      ),
      TrailLesson(
        id: 'am_02',
        recordKind: LessonRecordKind.note,
        title: 'Agua lunar',
        teaching:
            'El agua de luna es la más clásica de las aguas mágicas: agua limpia dejada bajo la luz de la luna llena para absorber el auge del poder lunar. Lleva las cualidades de la Luna — intuición, emoción, misterio, limpieza suave — y por eso es el agua preferida para consagrar instrumentos, bendecir objetos y preparar baños de purificación delicados\n\nLa recogida tradicional es simple: un recipiente de vidrio con agua potable, expuesto a la luz de la noche de luna llena (ventana o cielo abierto), retirado antes de que salga el sol. El sol de la mañana "quema" la energía lunar — por eso el horario importa. En la página de la Luna de la Enciclopedia hay un ritual guiado paso a paso del Agua de Luna: úsalo en la próxima luna llena como práctica de esta lección\n\nUsos consagrados: limpiar cristales y barajas (los que aceptan agua), ungir velas antes de hechizos de intuición y sueño, añadir un poco al baño para disolver pesos emocionales, regar levemente plantas de trabajos lunares y bendecir espejos y vidrios de adivinación. Unas gotas bastan — el agua de luna es concentrada por naturaleza\n\nGuárdala en la oscuridad, en frasco etiquetado con la fecha y, si quieres, el nombre de la luna (Luna del Lobo, Luna de las Flores...). Su validez es el próximo ciclo: al llegar la nueva luna llena, devuelve el agua antigua a la tierra con gratitud y recoge una nueva. El agua de luna no se acumula — se renueva',
        practice:
            'Programa tu recogida: mira en Tu Día cuándo es la próxima luna llena y deja el frasco preparado desde ya. Si la luna llena es hoy o mañana, sigue el ritual guiado del Agua de Luna en la página de la Luna de la Enciclopedia. Si aún falta tiempo, practica la segunda parte: decide desde ya CUÁL será el primer uso de tu agua de luna — un baño, una limpieza de cristal, una unción de vela — y escribe el paso a paso en tu página',
        pageTitle: 'Mi Agua de Luna',
        pagePurpose: 'Registrar la recogida y los usos de mi agua lunar',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Frasco de vidrio', 'Agua potable', 'Luz de luna llena'],
        pagePrompts: [
          'Fecha y luna de mi recogida:',
          'Cómo fue la noche (cielo, sensaciones):',
          'El primer uso que le daré:',
          'Lo que sentí al usarla:',
        ],
      ),
      TrailLesson(
        id: 'am_03',
        recordKind: LessonRecordKind.note,
        title: 'Agua solar',
        teaching:
            'Si el agua de luna calma y profundiza, el agua solar despierta y fortalece. Es agua cargada bajo la luz directa del Sol — de preferencia en la mañana de un domingo, día solar, o en un sabbat de sol como Litha — y concentra vitalidad, coraje, alegría y fuerza de realización. Es el agua de los nuevos comienzos con energía\n\nLa recogida es el espejo de la lunar: recipiente de vidrio con agua potable expuesto al sol de la mañana por 2 a 4 horas. El sol del mediodía es demasiado fuerte para algunos trabajos delicados; el de la mañana es vitalidad pura. En la página del Sol de la Enciclopedia hay un ritual guiado completo del Agua Solar — es la práctica ideal de esta lección\n\nUsos consagrados: rociar los rincones de la casa para espantar el estancamiento, ungir velas de trabajos de coraje y prosperidad, añadir al cubo de fregar el suelo para renovar la energía del hogar, y un sorbo simbólico (de agua limpia y fresca) antes de un día que pide fuerza. Cuidado con los cristales: algunos se decoloran al sol — carga en el agua solar solo los que aceptan luz, como el citrino y la cornalina\n\nEl agua solar pide uso rápido: la recoges, la usas. La tradición dice que guarda su calor pocos días — después, riega una planta con ella y recoge de nuevo. Etiquétala con la fecha y el día de la semana: un agua solar de domingo es la más solar de todas',
        practice:
            'Recoge tu primera agua solar esta semana: mañana de cielo abierto, frasco de vidrio, 2 a 4 horas de sol directo. Si es posible, sigue el ritual guiado del Agua Solar en la página del Sol de la Enciclopedia. Después úsala el mismo día: rocía los rincones de la habitación donde más vives, pidiendo en voz baja que la vitalidad circule. Anota en la página qué cambió en el ambiente y en ti',
        pageTitle: 'Mi Agua Solar',
        pagePurpose: 'Registrar la recogida y los usos de mi agua solar',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Frasco de vidrio', 'Agua potable', 'Sol de la mañana'],
        pagePrompts: [
          'Día y horario de mi recogida:',
          'Cómo usé el agua el mismo día:',
          'Qué sentí distinto en el ambiente:',
          'Para qué quiero la próxima recogida:',
        ],
      ),
      TrailLesson(
        id: 'am_04',
        recordKind: LessonRecordKind.note,
        title: 'Agua de lluvia',
        teaching:
            'El agua de lluvia es la bendición que cae del cielo gratis: agua de crecimiento, renovación y fertilidad de los trabajos. Viene "de arriba", y las tradiciones la asocian a la purificación natural — la lluvia lava el mundo — y al crecimiento, porque es ella la que hace brotar. Es una de las aguas más versátiles del libro de la bruja\n\nRecogida: un recipiente limpio de vidrio o cerámica en un lugar abierto — nunca bajo techo o canaleta, que contaminan el agua y la intención. La lluvia del inicio de la tormenta se considera la más potente; la lluvia mansa de un día entero lleva constancia y paciencia. Deja que la naturaleza llene el frasco a su ritmo\n\nUsos consagrados: regar plantas de hechizos y de la enciclopedia personal (les encanta), lavarse las manos antes de un trabajo de crecimiento, añadir a baños de renovación después de ciclos difíciles y humedecer semillas — literales o simbólicas — plantadas en luna nueva. El agua de lluvia es la aliada natural de los trabajos de prosperidad que necesitan CRECER despacio y firme\n\nComo no es potable, el agua de lluvia no se bebe — uso externo y ritual solamente. Guárdala etiquetada ("lluvia mansa", "lluvia de marzo") y renuévala cuando el olor cambie. Devuelve la antigua a las plantas: lo que vino del cielo vuelve a la tierra',
        practice:
            'En la próxima lluvia, coloca un recipiente limpio en un lugar totalmente abierto y deja que se llene. Mientras llueve, quédate un minuto en la ventana observando: ¿qué tipo de lluvia es esta — lavado, alivio, crecimiento? Nombra el agua por lo que sentiste. Después usa la mitad regando una planta querida con intención de crecimiento y guarda la otra mitad etiquetada para el próximo trabajo',
        pageTitle: 'Mi Agua de Lluvia',
        pagePurpose: 'Registrar la recogida y los usos del agua de lluvia',
        pageCategory: SpellCategory.prosperity,
        pageIngredients: ['Recipiente limpio', 'Lluvia', 'Lugar abierto'],
        pagePrompts: [
          'Fecha y el "tipo" de lluvia que recogí:',
          'El nombre que le di a esta agua:',
          'La planta o trabajo que regó:',
          'Lo que quiero que crezca con ella:',
        ],
      ),
      TrailLesson(
        id: 'am_05',
        recordKind: LessonRecordKind.note,
        title: 'Agua de tormenta',
        teaching:
            'El agua de tormenta es la hermana salvaje del agua de lluvia: recogida durante tormentas y vendavales, lleva potencia bruta — ruptura de bloqueos, coraje, fuerza para dar la vuelta al juego. Es un agua de respeto, usada en pequeñas dosis en los trabajos que piden un empujón que el agua mansa no da\n\nRecogida con la seguridad primero: el recipiente va al lugar abierto ANTES de la tormenta o entre chubascos — nunca te quedes a la intemperie bajo rayos. La bruja lista prepara el frasco cuando el cielo se oscurece y lo recoge cuando el tiempo se calma. La tradición dice que cuanto más fuerte el trueno durante la recogida, más "cargada" el agua\n\nUsos consagrados: ungir velas de trabajos de destierro y ruptura de bloqueos, lavar (pocas gotas) amuletos que necesitan fuerza extra, añadir una cucharada al cubo de limpieza pesada de la casa después de peleas o visitas difíciles, y tocar con el dedo mojado la propia frente antes de una conversación que exige coraje. Poca cantidad, mucha intención\n\nEsta agua no es para el día a día: guarda un frasco pequeño, bien etiquetado ("tormenta de enero"), lejos de las aguas mansas. Cuando el trabajo termine, devuélvela a la tierra agradeciendo la fuerza prestada. La tormenta que cumplió su papel no se guarda por nostalgia',
        practice:
            'Prepara hoy tu "kit de tormenta", aunque el cielo esté despejado: un frasco pequeño, una etiqueta escrita y un lugar definido fuera de casa para colocarlo cuando el tiempo cambie. Ensaya el gesto: dónde exactamente va el frasco, por dónde lo recoges sin exponerte a los rayos. En la próxima tormenta, recoge con seguridad y anota en la página qué parecía querer romper la tormenta',
        pageTitle: 'Mi Agua de Tormenta',
        pagePurpose: 'Registrar la recogida y los usos del agua de tormenta',
        pageCategory: SpellCategory.banishing,
        pageIngredients: ['Frasco pequeño', 'Tormenta', 'Cautela'],
        pagePrompts: [
          'Fecha y fuerza de la tormenta:',
          'Cómo la recogí con seguridad:',
          'El bloqueo que quiero romper con ella:',
          'Cómo y dónde la despedí después del uso:',
        ],
      ),
      TrailLesson(
        id: 'am_06',
        recordKind: LessonRecordKind.note,
        title: 'Agua del mar',
        teaching:
            'El agua del mar es el gran caldero del planeta: salada, viva e implacable con lo que ya no sirve. La sal la convierte en el agua más poderosa para limpieza pesada, destierro y protección — el mar se lleva lo que le entregamos. Es el agua de las limpiezas espirituales de verdad\n\nRecogida: en el mar, con los pies en la arena, de preferencia agradeciendo a Yemayá o a la divinidad del mar de tu tradición — recoger agua es recibir un regalo, no tomarlo. ¿Lejos del mar? La tradición acepta el sustituto honesto: agua limpia con sal gruesa disuelta, consagrada con la intención del océano. No es igual, pero trabaja\n\nUsos consagrados: limpieza pesada de objetos que llegaron "cargados" (los que aceptan sal), baños de descarga del cuello hacia abajo, lavar el umbral de la puerta de una casa que recibió mala energía, y círculos de protección trazados con agua salada en los rincones de la habitación. Atención: la sal corroe metales y reseca plantas — nunca uses agua del mar en cristales delicados, instrumentos de metal ni en la maceta de tus hierbas\n\nLa despedida es parte del rito: el agua salada usada en limpieza no vuelve a las plantas — va al desagüe con agradecimiento, llevándose lo que capturó. Guarda poca, úsala pronto y, siempre que puedas, renuévala en la fuente: una ida al mar es, por sí sola, el mayor baño de limpieza que existe',
        practice:
            'Si el mar está a tu alcance, ve a él esta semana: mójate los pies, agradece, recoge un frasco pequeño y deja una ofrenda simple y biodegradable (una flor). Si no lo está, prepara el sustituto: disuelve sal gruesa en agua limpia nombrando la intención del océano. Después haz una limpieza pequeña y real — el picaporte, el umbral, un objeto pesado — y siente la diferencia del agua salada',
        pageTitle: 'Mi Agua del Mar',
        pagePurpose: 'Registrar la recogida y los usos del agua del mar',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Frasco', 'Agua del mar (o agua + sal gruesa)'],
        pagePrompts: [
          'De dónde vino mi agua (mar o preparación):',
          'Lo que agradecí/ofrecí al recoger:',
          'La limpieza que hice con ella:',
          'Lo que el mar se llevó:',
        ],
      ),
      TrailLesson(
        id: 'am_07',
        recordKind: LessonRecordKind.note,
        title: 'Agua de río',
        teaching:
            'El río es movimiento que nunca para: el agua de río lleva desbloqueo, fluidez y el arte de soltar. Mientras el mar arranca, el río conduce — se lleva con suavidad lo que se estanca, y por eso es el agua de los trabajos de destrabar caminos, soltar lo que ata y retomar el flujo de la vida\n\nRecogida: en río corriente y lo más limpio posible, siempre del agua que se mueve — nunca de charcos quietos en la orilla. La tradición pide permiso al río antes (cada río tiene dueño, espíritu o nombre) y recomienda recoger a favor de la corriente, dejando que las manos sientan el movimiento. Una moneda o una flor entregada al agua paga el pasaje\n\nUsos consagrados: lavarse las manos al cerrar un ciclo (un trabajo, una relación, un duelo), ungir los pies antes de caminos nuevos — una entrevista, una mudanza, un viaje —, rociar documentos y proyectos parados para destrabarlos, y el rito clásico del río: entregar a la corriente una hoja con lo que quieres soltar, escrita a lápiz, y verla partir\n\nEl agua de río tampoco se bebe — uso ritual externo. Guarda poca y con etiqueta ("río tal, recogida en..."), y prefiere siempre el agua fresca: el poder del río está en el movimiento, y un agua de río guardada por meses se volvió lo contrario de lo que era. En la duda, vuelve al río — el camino hasta él ya es parte del hechizo',
        practice:
            'Encuentra el agua que se mueve cerca de ti — río, arroyo, riachuelo limpio o incluso una fuente corriente. Pide permiso, recoge un poco y haz en el momento el rito de la hoja: escribe a lápiz una cosa que necesita fluir o irse, dóblala y entrégala a la corriente, observando hasta que desaparezca. En casa, usa unas gotas en los pies antes del próximo camino nuevo que la vida te pida',
        pageTitle: 'Mi Agua de Río',
        pagePurpose: 'Registrar la recogida y los usos del agua de río',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Frasco', 'Agua de río corriente'],
        pagePrompts: [
          'El río (o agua corriente) que encontré:',
          'Lo que entregué a la corriente:',
          'El camino que quiero destrabar:',
          'Lo que sentí cuando la hoja partió:',
        ],
      ),
      TrailLesson(
        id: 'am_08',
        recordKind: LessonRecordKind.note,
        title: 'Rocío, manantial y otras aguas raras',
        teaching:
            'Antes de cerrar el libro, las aguas raras — las que no se recogen cuando se quiere, sino cuando la naturaleza las ofrece. El rocío, recogido de mañanita pasando un paño limpio por las hojas o dejando un cuenco en la hierba durante la noche, es el agua de la belleza, la juventud y los comienzos delicados. La tradición manda lavarse el rostro con rocío el primer día de mayo, y unas gotas bendicen cualquier trabajo de amor propio\n\nEl agua de manantial o fuente es pureza en estado bruto: agua que nace de la tierra, ideal para consagraciones, bendiciones y para "bautizar" instrumentos nuevos. Si hay un manantial natural en tu camino, vale el viaje — el agua recogida en la propia fuente, con permiso pedido, está entre las más preciosas de la reserva de una bruja\n\nEl agua de pozo, honda y guardada en la oscuridad de la tierra, sirve a los trabajos de misterio, secreto y ancestralidad — es el agua de las preguntas antiguas. Y el hielo derretido, el agua de deshielo, lleva el poder de las transiciones lentas: excelente para descongelar, gota a gota, situaciones trabadas hace mucho tiempo. Hasta la niebla recogida en un paño tiene nombre en las tradiciones: agua del velo, para trabajos de discreción\n\nLo que estas aguas comparten: no se planifican, se reciben. La bruja de las aguas lleva un frasco vacío en el bolso y los ojos abiertos — cuando la naturaleza ofrece un agua rara, agradece y recoge. Tu página de esta lección es el mapa de las aguas raras posibles en tu vida',
        practice:
            'Haz tu mapa de las aguas raras: piensa en tu rutina y tu región y lista dónde podrías recoger rocío (un jardín, un parque por la mañana), manantial (¿alguna fuente natural conocida?), pozo o deshielo. Si puedes, recoge rocío mañana temprano con un paño limpio y pásalo por tu rostro nombrando un comienzo delicado que quieres para ti. Anota en la página lo que ya es posible hoy y lo que queda como promesa',
        pageTitle: 'Mi Mapa de las Aguas Raras',
        pagePurpose: 'Mapear las aguas raras a mi alcance',
        pageCategory: SpellCategory.selfLove,
        pageIngredients: ['Paño limpio', 'Frasco pequeño', 'Atención'],
        pagePrompts: [
          'Dónde puedo recoger rocío:',
          'Manantiales o fuentes que conozco:',
          'El agua rara que quiero recoger un día:',
          'El comienzo delicado que nombré para mí:',
        ],
      ),
      TrailLesson(
        id: 'am_09',
        recordKind: LessonRecordKind.note,
        title: 'La despedida sagrada y tu reserva',
        teaching:
            'La última lección es el arte que nadie enseña: la despedida. Toda agua mágica tiene destino propio, y devolverla bien importa tanto como recogerla bien — el ciclo solo se completa cuando el agua vuelve al mundo. Un agua olvidada al fondo del armario no es reserva: es trabajo inacabado\n\nLa regla general: las aguas dulces y limpias (luna, sol, lluvia, rocío, manantial) vuelven a la tierra — riega plantas, devuélvelas al jardín, ofrécelas a un cantero. Las aguas de trabajo pesado (sal, tormenta usada en destierro, agua de limpieza que "capturó" algo) van al desagüe o a la tierra lejos de las plantas, siempre con agradecimiento por el servicio prestado\n\nY la regla de oro de los templos: nunca viertas agua de trabajo en un río o mar limpios. No son basurero — son la fuente. Lo que vuelve a la naturaleza debe volver limpio o neutro; lo que lleva residuo sale por los caminos de la casa (desagüe, tierra distante). La bruja que respeta las aguas es respetada por ellas\n\nTu reserva ideal es pequeña y viva: pocos frascos, todos etiquetados con tipo y fecha, renovados cada ciclo. La bruja de las aguas no colecciona — recoge, usa, agradece y devuelve. Con el inventario de la primera lección y las aguas de todo el sendero, tu libro de las aguas está abierto: crece con cada lluvia, cada luna y cada marea de tu vida',
        practice:
            'Cierra el ciclo del sendero con una revisión completa de tu reserva: reúne todos los frascos que recogiste, revisa etiquetas y fechas, y decide el destino de cada uno — usar esta semana, renovar o devolver a la tierra con gratitud. Haz al menos una despedida sagrada hoy, de la forma correcta para ese tipo de agua. Registra en la página el estado final de tu libro de las aguas',
        pageTitle: 'El Cierre de Mi Libro de las Aguas',
        pagePurpose: 'Revisar mi reserva y el destino de cada agua',
        pageCategory: SpellCategory.wisdom,
        pageIngredients: ['Mis frascos', 'Etiquetas', 'Gratitud'],
        pagePrompts: [
          'Las aguas que tengo hoy (tipo y fecha):',
          'Lo que devolví a la tierra y por qué:',
          'Cómo quedó mi reserva final:',
          'Lo que las aguas me enseñaron hasta aquí:',
        ],
      ),
    ]);
