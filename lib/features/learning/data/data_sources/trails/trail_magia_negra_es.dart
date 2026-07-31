import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Ruta 'magia_negra' — contenido en español.
/// Paridad con _pt/_en verificada en test/trails_parity_test.dart.
const LearningTrail magiaNegraTrailEs = LearningTrail(
    id: 'magia_negra',
    emoji: '🌑',
    title: 'Magia Negra',
    subtitle: 'Sombra, corte y poder consciente',
    description:
        'Deshacer los mitos y atravesar la oscuridad con responsabilidad: trabajo de sombra, destierros, cortes y protecciones — el poder que nace cuando miras lo que la mayoría evita.',
    lessons: [
      TrailLesson(
        id: 'mn_01',
        recordKind: LessonRecordKind.note,
        title: 'Qué es la magia negra (y qué nunca fue)',
        teaching:
            'La magia negra, en esta ruta, es el nombre que damos al trabajo consciente con la sombra: desterrar lo que enferma, defender el propio campo, cortar lo que drena y asumir el poder con ética. No es una receta para perjudicar a nadie — es el lado de la brujería que mira la oscuridad de frente. Entender qué es este término, y qué nunca fue, es el primer paso para practicar sin miedo y sin irresponsabilidad.\n\nLa etiqueta de magia negra carga una historia pesada: se usó para demonizar religiones afrodiaspóricas, curanderas y saberes populares, asociando lo oscuro con el mal por puro prejuicio y racismo. El folclor y el cine exageraron el resto, creando la caricatura de la maldición y del pacto siniestro. La práctica moderna deshace esa confusión: oscuro no es sinónimo de maldad, así como la noche no es enemiga del día.\n\nAl principio, es común llegar a este tema con miedo o con demasiada fascinación — ambos desequilibran. El error clásico es buscar hechizos contra alguien que te lastimó: además de ser éticamente incorrecto, eso ata tu energía justamente a quien quieres lejos. El consejo es fijar límites antes de cualquier práctica: escribe lo que nunca harás, y por qué. Una ética definida con claridad es la mayor protección que existe.\n\nLleva contigo esto: la oscuridad es parte natural del camino, y quien la recorre con responsabilidad encuentra ahí fuerza, no peligro. No necesitas temer esta ruta ni demostrarle valentía a nadie. Tu pacto es contigo misma — y es el que transforma el poder en madurez. La bruja que conoce sus límites puede ir mucho más profundo que la que finge no tenerlos.',
        practice:
            'Vas a escribir tu Pacto de Responsabilidad. Primero, reflexiona con honestidad sobre lo que te trajo hasta esta ruta. Después, escribe en tu página los límites que asumes: lo que nunca harás con tu propia magia y los valores que guiarán cada práctica. Por último, lee el pacto en voz alta, como quien firma un compromiso consigo misma. El objetivo es asentar la base ética que te protegerá en todo el camino de la sombra.',
        pageTitle: 'Mi Pacto de Responsabilidad',
        pagePurpose: 'Definir mis límites antes de tocar la sombra',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Lo que me atrajo a este camino:',
          'Mis límites: lo que nunca haré:',
          'Lo que quiero transformar en mí:',
          'Mi compromiso, con mis palabras:',
        ],
      ),
      TrailLesson(
        id: 'mn_02',
        recordKind: LessonRecordKind.note,
        title: 'La sombra: lo que escondes de ti',
        teaching:
            'La sombra es todo aquello que escondiste de ti para ser aceptada: rabia tragada, deseos negados, talentos que parecían demasiado peligrosos. En clave mística, es el sótano del alma — y todo sótano guarda tanto trastos como tesoros. Trabajar la sombra importa porque lo que no miras no desaparece: solo pasa a actuar en la oscuridad, sin tu permiso.\n\nLa psicología de Jung le puso nombre a lo que las brujas siempre supieron: lo que reprimimos no muere, se proyecta. Por eso ciertos defectos ajenos irritan tanto — suelen ser espejos de algo nuestro. En los cuentos antiguos, el monstruo del bosque casi siempre guarda un tesoro o se vuelve aliado cuando se lo enfrenta de frente: el folclor ya enseñaba que la oscuridad esconde poder, y no solo peligro.\n\nEn la práctica, el trabajo de sombra empieza pequeño: notar las irritaciones desproporcionadas, los celos que avergüenzan, los elogios que rechazas. El error común es convertir esto en autocastigo — la sombra no se golpea, se escucha. Otro es querer iluminarlo todo de una vez. Ve poco a poco, con curiosidad y sin juicio, como quien explora una casa antigua con una vela en la mano.\n\nLleva contigo esto: tu sombra no es tu enemiga — es la parte de ti que esperó años por atención. Cada pedazo escuchado devuelve energía que estaba atrapada en esconderse. La bruja que conoce su propia sombra no se vuelve más sombría: se vuelve más entera, más honesta y mucho más difícil de manipular. El mapa empieza hoy, y quien sostiene la linterna eres tú.',
        practice:
            'Vas a dibujar el primer Mapa de tu Sombra. Primero, haz una lista de tres comportamientos ajenos que te irritan de forma desproporcionada. Después, pregúntate, con honestidad y sin juicio, qué puede espejar cada uno en ti — los recuerdos y vergüenzas que surjan son pistas valiosas. Por último, registra en la página los aspectos de sombra que reconociste. El objetivo es iniciar el encuentro consciente con lo que escondes de ti.',
        pageTitle: 'Mapa de Mi Sombra',
        pagePurpose: 'Reconocer proyecciones y partes negadas de mí',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Lo que más me irrita en los demás (y puede ser mío):',
          'La parte de mí que escondo del mundo:',
          'Cuándo aparece sin que yo quiera:',
          'De qué está intentando protegerme de sentir:',
        ],
      ),
      TrailLesson(
        id: 'mn_03',
        recordKind: LessonRecordKind.spell,
        title: 'Destierro: cortar lo que enferma',
        teaching:
            'Desterrar es el gesto mágico de decir basta: retirar de tu campo un hábito, una energía o una situación que enferma. Es la limpieza profunda de la brujería — antes de atraer cualquier cosa buena, hay que abrir espacio. En esta ruta, el destierro nunca apunta a personas para causar daño: el blanco es siempre el patrón, el vicio, el peso. Destierras lo que te ata, no a quienes te rodean.\n\nEl destierro es de las prácticas más antiguas del mundo: sal en las esquinas de la casa, escoba barriendo hacia afuera, humo de hierbas amargas, agua llevándose lo que no sirve. La lógica tradicional sigue la luna menguante: así como ella disminuye en el cielo, disminuye lo desterrado. Escribir lo que se quiere remover y destruir el papel con seguridad es la forma clásica — el fuego y el agua siempre fueron los grandes disolventes de la magia popular.\n\nPara la principiante, la clave es elegir un blanco concreto y justo: un hábito que drena, una energía pesada en una habitación, un ciclo que se repite. El error común es desterrar vagamente — todo lo malo de mi vida — y no sentir efecto, o disfrazar de destierro un ataque a alguien. Otro es desterrar y seguir alimentando el patrón al día siguiente: el hechizo abre la puerta, pero quien la atraviesa eres tú.\n\nLleva contigo esto: desterrar es un acto de amor propio con cara de valentía. Cada cosa que remueves conscientemente devuelve espacio a lo que merece crecer. Este es tu primer hechizo de la ruta — simple, honesto y poderoso en la medida de tu compromiso. El poder no está en el papel quemado: está en la decisión que sostienes después de él.',
        practice:
            'Vas a realizar tu primer destierro. Primero, elige un blanco justo: un hábito, una energía o una situación — nunca una persona. Después, escríbelo en un papel, enciende una vela en un lugar seguro y quema el papel declarando que eso ya no tiene lugar en tu vida; desecha las cenizas fuera de casa. Por último, registra todo en la página del grimorio. El objetivo es abrir espacio, retirando conscientemente lo que enferma.',
        pageTitle: 'Mi Primer Destierro',
        pagePurpose: 'Desterrar un hábito, energía o situación que me enferma',
        pageCategory: SpellCategory.banishing,
        pageType: SpellType.banishment,
        pageIngredients: ['Vela oscura o papel y bolígrafo', 'Un símbolo de lo que será desterrado'],
        pagePrompts: [
          'Lo que estoy desterrando (hábito, energía o situación):',
          'Por qué ya no tiene lugar en mi vida:',
          'Cómo hice el rito y qué sentí:',
          'Qué ocupa el espacio que quedó libre:',
        ],
      ),
      TrailLesson(
        id: 'mn_04',
        recordKind: LessonRecordKind.spell,
        title: 'Escudos y espejos: defensa mágica',
        teaching:
            'La defensa mágica es higiene, no paranoia: así como cierras la puerta con llave sin vivir con miedo, el escudo energético protege tu campo sin convertir el mundo en amenaza. Los escudos filtran lo que viene de afuera; los espejos devuelven a su origen lo que fue enviado, sin que necesites contraatacar. Saber protegerte es lo que permite trabajar la sombra con tranquilidad y seguir abierta a la vida.\n\nEl folclor está lleno de defensas: hierro en la puerta, ojo turco contra la envidia, ruda en la entrada, espejitos que confunden y devuelven el mal de ojo. La idea del espejo es elegante: no atacas a nadie, solo dejas de absorber — lo que viene, vuelve a quien lo mandó, y la responsabilidad es de quien lo envió. La visualización moderna hereda eso: imaginarte dentro de una esfera espejada es una técnica simple y antigua a la vez.\n\nEn lo cotidiano, el escudo se construye por la mañana en un minuto: respira, visualiza la esfera de luz espejada alrededor del cuerpo y afirma la intención. El error común es blindarte tanto que nada entra — ni lo bueno; el escudo es filtro, no muralla de aislamiento. Otro es acordarte de la protección solo en la crisis. La constancia vale más que la intensidad: un amuleto simple renovado con cariño protege más que rituales grandiosos olvidados.\n\nLleva contigo esto: tienes derecho a no absorber lo que no es tuyo. Protegerte no es agresión ni desconfianza del mundo — es respeto por tu propio campo. Con el escudo espejado, caminas más ligera, sabiendo que lo que no te pertenece encuentra solo el camino de vuelta. La seguridad energética es la base silenciosa de toda la magia que viene después.',
        practice:
            'Vas a levantar tu Escudo Espejado. Primero, siéntate en silencio, respira hondo tres veces y siente los pies firmes en el suelo. Después, visualiza una esfera de luz a tu alrededor cuya cara externa es un espejo: lo bueno atraviesa, lo que pesa es devuelto a su origen; sostén la imagen por unos minutos y, si quieres, consagra un objeto pequeño como amuleto. Por último, registra la experiencia en la página. El objetivo es crear una protección diaria que filtra sin aislar.',
        pageTitle: 'Mi Escudo Espejado',
        pagePurpose: 'Levantar mi protección antes de cualquier trabajo sombrío',
        pageCategory: SpellCategory.protection,
        pageType: SpellType.banishment,
        pageIngredients: ['Espejo pequeño u objeto reflectante', 'Sal gruesa'],
        pagePrompts: [
          'De qué me estoy protegiendo:',
          'Cómo visualicé mi escudo (forma, material, brillo):',
          'La frase que afirma mi protección:',
          'Cuándo voy a renovar este escudo:',
        ],
      ),
      TrailLesson(
        id: 'mn_05',
        recordKind: LessonRecordKind.spell,
        title: 'Corte de lazos',
        teaching:
            'Entre tú y cada persona de tu vida existen lazos invisibles — cuerdas de afecto, de historia, de energía. Algunos nutren; otros drenan, atan a relaciones terminadas o convierten la convivencia en un tira y afloja. El corte de lazos es el ritual que devuelve a cada uno su propia energía. Cortar no es atacar ni borrar a alguien: es cerrar un contrato energético que ya venció.\n\nTradiciones del mundo entero conocen esas cuerdas: cintas que se atan y desatan en ritos populares, nudos que se deshacen para liberar caminos, tijeras que cortan el aire cargado. El rito moderno usa símbolos simples: un cordón representando el lazo, dos velas representando los dos lados, unas tijeras consagradas. Al cortar el cordón, declaras el fin del vínculo que drena — y deseas, de corazón, que cada parte siga en paz con lo que es suyo.\n\nEn la práctica, empieza por un lazo claramente vencido: una relación terminada que aún ocupa tus pensamientos, una convivencia que solo absorbe. El error común es cortar con rabia, convirtiendo el rito en venganza silenciosa — el corte se hace con firmeza serena, no con odio. Otro es esperar que alguien desaparezca de tu vida al día siguiente: lo que se corta es la cuerda energética; las decisiones prácticas de distancia siguen siendo tuyas.\n\nLleva contigo esto: soltar también es magia — quizá la más difícil y la más liberadora. Cada lazo cortado con conciencia devuelve energía que estaba atrapada en el pasado. No necesitas cargar cuerdas que ya no llevan a ningún lugar. Corta con respeto, agradece lo aprendido y camina más ligera: el espacio que se abre es tuyo, y el de la otra persona también.',
        practice:
            'Vas a realizar el Ritual de Corte de Lazos. Primero, elige un vínculo que te drena y toma un cordón o hilo para representarlo, sosteniendo una punta en cada mano mientras nombras en silencio lo que ese lazo se volvió. Después, corta el cordón con unas tijeras, deseando paz para ambos lados, y desecha las partes separadas. Por último, registra el rito y lo que sentiste en la página. El objetivo es liberar energía atrapada en relaciones que ya cumplieron su papel.',
        pageTitle: 'Ritual de Corte de Lazos',
        pagePurpose: 'Cortar cuerdas energéticas que me drenan',
        pageCategory: SpellCategory.banishing,
        pageType: SpellType.banishment,
        pageIngredients: ['Cordón o hilo', 'Tijeras', 'Vela'],
        pagePrompts: [
          'El lazo que necesité cortar (sin culpar, solo nombrar):',
          'Lo que ese vínculo drenaba de mí:',
          'Cómo fue el momento del corte:',
          'Lo bueno que deseo para ambos lados, separados:',
        ],
      ),
      TrailLesson(
        id: 'mn_06',
        recordKind: LessonRecordKind.note,
        title: 'La luna negra y la oscuridad fértil',
        teaching:
            'La luna negra es la fase en que el cielo parece vacío: la luna está ahí, pero no refleja luz alguna. En las tradiciones de la brujería, ese es el tiempo del silencio, de la inmersión y del descanso — la oscuridad fértil donde todo se prepara antes de nacer. Honrar esta fase importa porque el poder no es solo acción: la pausa consciente es tan mágica como cualquier hechizo bien hecho.\n\nLos pueblos antiguos sembraban según la luna y sabían que la semilla germina en la oscuridad de la tierra, no en la luz. El folclor asoció la luna oscura a los misterios profundos, a la diosa anciana, al tiempo en que no se empieza nada — se escucha. La práctica moderna traduce eso en retiro personal: menos estímulo, más silencio, adivinación, escritura y sueño reparador. Es el momento en que la sombra habla más claro, porque el ruido disminuye.\n\nEn la práctica, marca la luna negra en tu calendario y resérvale una noche más tranquila: menos pantallas, un baño largo, escritura libre, dormir temprano. El error común es tratar el descanso como pereza y forzarte a producir — en esta fase, eso solo genera agotamiento. Otro es esperar grandes revelaciones: a veces la luna negra entrega solo un sueño profundo, y eso ya es el regalo de la fase.\n\nLleva contigo esto: tú también tienes fases, y ninguna de ellas está mal. La oscuridad fértil enseña que recogerse es preparar la próxima floración. La bruja que respeta su propio invierno no se apaga — acumula profundidad. Deja que la luna negra sea tu recordatorio mensual de que el vacío no es falta: es el útero silencioso donde tu próxima versión está siendo gestada.',
        practice:
            'Vas a comenzar tu Diario de la Luna Negra. Primero, averigua cuándo es la próxima luna negra y reserva esa noche — o haz hoy un ensayo en una noche tranquila. Después, disminuye los estímulos: luz baja, silencio, menos pantallas, y escribe libremente qué pide descanso en tu vida y qué está germinando en la oscuridad. Por último, registra las percepciones en la página. El objetivo es transformar la fase oscura en un rito mensual de escucha y descanso.',
        pageTitle: 'Diario de la Luna Negra',
        pagePurpose: 'Trabajar el silencio y el descanso como poder',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Lo que la oscuridad me enseña cuando dejo de huir de ella:',
          'Lo que estoy dejando reposar en esta luna:',
          'Lo que percibí en el silencio:',
          'La semilla que plantaré cuando vuelva la luz:',
        ],
      ),
      TrailLesson(
        id: 'mn_07',
        recordKind: LessonRecordKind.dream,
        title: 'Sueños sombríos: recados de la sombra',
        teaching:
            'Las pesadillas asustan, pero rara vez vienen a atormentar: en la lectura mística, son cartas urgentes de la sombra. Cuando algo importante no logra llegar a ti por la vía común, el sueño sube el volumen — y se vuelve monstruo, caída, persecución. Aprender a escuchar los sueños sombríos importa porque señalan exactamente lo que tu trabajo de sombra necesita mirar ahora.\n\nCulturas antiguas trataban los sueños como oráculos: templos de incubación en Grecia, bendiciones populares contra la pesadilla, guardianes del sueño en el folclor de varios pueblos. La clave simbólica moderna lee la pesadilla al revés: quien te persigue en el sueño suele ser algo tuyo pidiendo encuentro; la casa en ruinas habla de estructuras internas; la caída, de un control que necesita soltarse. El monstruo, casi siempre, quiere entregar un recado — no devorarte.\n\nEn la práctica, el secreto es registrar apenas despiertes, antes de que el sueño se evapore: anota escenas, emociones y símbolos en el Diario de Sueños de la app y consulta los Significados de los Sueños para abrir capas. El error común es interpretar al pie de la letra y concluir que un mal sueño es presagio — la mayoría de las veces, es retrato interno, no profecía. Otro es huir del tema: la pesadilla ignorada tiende a volver más fuerte.\n\nLleva contigo esto: la noche es tu aliada, incluso cuando habla en imágenes aterradoras. Cada pesadilla escuchada con valentía es una conversación menos que la sombra necesita gritar. No estás a merced de tus sueños — estás en diálogo con ellos. Duerme como quien confía en su propia profundidad: la oscuridad de los sueños también trabaja a tu favor.',
        practice:
            'Vas a escuchar un sueño sombrío. Primero, registra en el Diario de Sueños de la app una pesadilla reciente — o la próxima que venga — con escenas, símbolos y emociones. Después, explora los Significados de los Sueños para abrir las capas simbólicas y pregúntate qué parte tuya puede estar hablando a través de esas imágenes. Por último, escribe en la página el mensaje que lograste escuchar. El objetivo es transformar la pesadilla de amenaza en mensajera de la sombra.',
        pageTitle: 'Un Sueño Sombrío Escuchado',
        pagePurpose: 'Escuchar una pesadilla como mensajera',
        pageCategory: SpellCategory.dreams,
        pagePrompts: [
          'El sueño sombrío que me visitó:',
          'Lo que sentí dentro de él y al despertar:',
          'Qué parte de mi sombra puede estar hablando:',
          'Qué me pide ese recado en la vida despierta:',
        ],
      ),
      TrailLesson(
        id: 'mn_08',
        recordKind: LessonRecordKind.oracle,
        title: 'Espejo negro y videncia sombría',
        teaching:
            'La videncia sombría es el arte de mirar la oscuridad hasta que empiece a hablar. El espejo negro, el cuenco de agua oscura y la llama de la vela son puertas antiguas hacia eso: superficies que ocupan los ojos para que la intuición tome el mando. Aprender esta práctica importa porque entrena la habilidad central de la bruja: sostener la mirada ante lo desconocido sin huir de él.\n\nLa práctica atraviesa siglos: videntes miraron espejos de obsidiana, pozos profundos y cuencos de tinta en muchas culturas, y el folclor guardó historias de espejos que muestran verdades escondidas. El funcionamiento es menos misterioso de lo que parece: ante una superficie oscura y sin detalles, la mente racional se aquieta y las imágenes internas ganan espacio — símbolos, recuerdos, intuiciones. El espejo no muestra fantasmas: te muestra a ti, en profundidad.\n\nPara empezar, oscurece el ambiente, enciende una vela fuera del reflejo y mira suavemente la superficie negra por unos minutos, parpadeando con normalidad. El error común es forzar visiones o rendirse al tercer intento — la videncia es un músculo, crece despacio. Si prefieres un apoyo más concreto, las Cartas del Oráculo de la app cumplen un papel parecido: imágenes que le prestan forma a tu intuición. Registra todo, incluso lo que parezca poco.\n\nLleva contigo esto: la oscuridad no está vacía — está llena de ti. Cada sesión de videncia enseña a tus ojos a confiar en lo que los otros sentidos ya saben. No hay respuesta correcta que encontrar, hay escucha que refinar. Con paciencia, el espejo negro deja de ser aterrador y se vuelve lo que siempre fue: una ventana tranquila hacia tu propia profundidad.',
        practice:
            'Vas a hacer tu primera sesión de videncia. Primero, prepara el ambiente: luz baja, una vela encendida y un espejo oscuro o un cuenco con agua sobre fondo oscuro — o, si prefieres, las Cartas del Oráculo de la app. Después, mira suavemente la superficie o saca una carta, dejando surgir impresiones, imágenes y sensaciones sin forzar, por cinco a diez minutos. Por último, registra todo en la página, sin censura. El objetivo es entrenar la mirada intuitiva ante la oscuridad.',
        pageTitle: 'Mi Sesión de Videncia',
        pagePurpose: 'Mirar la oscuridad sin miedo y registrar lo que vi',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Cómo preparé el espacio y el espejo (o las cartas):',
          'Lo que vi, sentí o intuí:',
          'Qué puede ser símbolo y qué puede ser miedo mío:',
          'El mensaje que me llevo de esta sesión:',
        ],
      ),
      TrailLesson(
        id: 'mn_09',
        recordKind: LessonRecordKind.spell,
        title: 'Contención: el hechizo atado a la ética',
        teaching:
            'La contención, o binding, es el hechizo que amarra un daño para que deje de propagarse — como quien venda un brazo roto o cierra una llave que gotea. En esta ruta, existe para contener patrones, situaciones y comportamientos destructivos, nunca para controlar la voluntad de alguien ni herir a nadie. Es la magia del límite: el basta dicho en nudo y cordón.\n\nLa imagen del nudo atraviesa la historia de la magia: nudos que sujetan vientos en las leyendas de los marineros, cintas que afirman promesas, trenzas que guardan intenciones. El binding clásico amarra un símbolo del problema con cordón y palabra firme. La ética es explícita: contener es impedir que un mal continúe — como contener el propio vicio, una dinámica de chismes o un ciclo de autosabotaje. Controlar o herir personas es otra cosa, y esta ruta no enseña eso.\n\nEn la práctica, escribe la situación o el patrón a contener en un papel, dóblalo hacia adentro y amárralo con cordón oscuro, declarando que ese daño está contenido y ya no crece. Guarda el paquete en un lugar cerrado. El error común es usar la contención como atajo para no actuar — el hechizo detiene la hemorragia, pero la cura pide acciones concretas. Otro es apuntar a alguien por rabia disfrazada de justicia: pregúntate siempre qué es exactamente lo que quieres contener.\n\nLleva contigo esto: todo hechizo vuelve a las manos que lo hacen — por eso la bruja madura mide la intención antes del nudo. La contención bien hecha no es ataque: es el límite sagrado que te protege a ti y a los demás de un daño en curso. Úsala rara vez, con claridad y responsabilidad, y será una de las herramientas más sobrias de tu grimorio.',
        practice:
            'Vas a hacer un Hechizo de Contención ético. Primero, identifica un daño en curso que necesita dejar de crecer — un patrón, un ciclo, una situación; jamás una persona como blanco. Después, escríbelo en un papel, dóblalo hacia adentro y amárralo con un cordón oscuro en nudos firmes, declarando que ese mal está contenido; guarda el paquete en un lugar cerrado. Por último, registra el hechizo y las acciones concretas que lo acompañarán. El objetivo es contener el daño mientras actúas para resolverlo.',
        pageTitle: 'Mi Hechizo de Contención',
        pagePurpose: 'Contener un daño en curso sin herir a nadie',
        pageCategory: SpellCategory.protection,
        pageType: SpellType.banishment,
        pageIngredients: ['Cordón para el nudo simbólico', 'Papel y bolígrafo'],
        pagePrompts: [
          'El daño que necesita parar (hecho, no persona):',
          'Mi límite ético en este trabajo:',
          'Cómo amarré la contención (nudo, palabra, símbolo):',
          'La acción concreta que acompaña al hechizo:',
        ],
      ),
      TrailLesson(
        id: 'mn_10',
        recordKind: LessonRecordKind.note,
        title: 'Integración: la bruja entera',
        teaching:
            'La ruta termina donde empieza la brujería entera: en la integración. Después de mirar la sombra, desterrar, cortar, proteger y contener, descubres que no existen dos brujas dentro de ti — una de luz y otra de oscuridad. Existe una sola, más honesta, que conoce sus propias profundidades. Integrar es eso: dejar de elegir mitades y habitar tu propio entero con serenidad.\n\nLos símbolos antiguos siempre apuntaron a esa unión: el día necesita la noche, la luna llena carga la memoria de la luna negra, la semilla y la flor son la misma planta en tiempos distintos. En las historias, quien desciende al mundo de abajo y regresa vuelve transformada — no más sombría, más sabia. La sombra integrada no desaparece: se vuelve discernimiento, humor, compasión y esa fuerza tranquila de quien ya se conoce por dentro.\n\nEn lo cotidiano, la integración aparece en señales discretas: te irritas menos con los espejos ajenos, dices no sin culpa, descansas sin vergüenza, te proteges sin endurecerte. El error común es creer que el trabajo de sombra termina — cambia de ritmo, pero acompaña la vida. Otro es esperar perfección: la bruja entera no es la que nunca se equivoca; es la que se responsabiliza de lo que hace con su propio poder.\n\nLleva contigo esto: atravesaste la oscuridad y no te tragó — te amplió. El manifiesto que escribes ahora es el retrato de quien llegó hasta aquí: alguien que practica con ética, siente sin ahogarse y brilla sin negar su propia noche. Sigue con las dos manos abiertas, una para la luz y otra para la sombra. Así camina la bruja entera.',
        practice:
            'Vas a escribir el Manifiesto de la Bruja Entera. Primero, relee las páginas de esta ruta y observa qué cambió desde el pacto inicial hasta aquí. Después, escribe un texto corto y personal declarando quién eres como practicante: tus valores, tus límites, lo que integras de la luz y de la sombra. Por último, lee el manifiesto en voz alta y guárdalo como cierre de la ruta. El objetivo es sellar la integración y asumir, con ética, tu propio poder entero.',
        pageTitle: 'Manifiesto de la Bruja Entera',
        pagePurpose: 'Integrar luz y sombra en mi camino',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'El poder que la sombra me devolvió:',
          'Lo que cambió en mi relación con el miedo:',
          'Mi ética, ahora en una frase:',
          'Cómo sigo desde aquí: luz y sombra juntas:',
        ],
      ),
    ],
  );
