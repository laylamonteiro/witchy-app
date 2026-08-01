import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Ruta 'wicca' — contenido en español.
/// Paridad con _pt/_en verificada en test/trails_parity_test.dart.
const LearningTrail wiccaTrailEs = LearningTrail(
    id: 'wicca',
    emoji: '🌕',
    title: 'Wicca',
    subtitle: 'La Diosa, el Dios y la Rueda del Año',
    description:
        'Los fundamentos de la religión de la brujería moderna: dualidad divina, sabbats, esbats y ética — mientras construyes tu Libro de las Sombras',
    lessons: [
      TrailLesson(
        id: 'wi_01',
        recordKind: LessonRecordKind.note,
        title: 'La Rede: "no dañes a nadie"',
        teaching:
            'La ética wiccana cabe en una frase conocida como la Rede: haz lo que quieras, siempre que no dañes a nadie. Importa porque es la brújula que orienta toda la práctica — antes de cualquier hechizo, vela o altar, viene la pregunta sobre a quién alcanza tu acción. Y hay un detalle que mucha gente olvida: "nadie" te incluye a ti. Cuidarte ya es practicar la Rede\n\nDe la Rede deriva la reflexión del retorno, que muchas tradiciones llaman la Ley Triple: la energía que pones en movimiento vuelve a ti, en calidad más que en aritmética exacta. La frase se popularizó con la Wicca moderna, difundida a partir de Gerald Gardner y Doreen Valiente, y cada tradición la interpreta a su manera — algunas como ley espiritual, otras como invitación a la responsabilidad. No existe un dogma único aquí: existe un principio vivo\n\nEn lo cotidiano, la Rede aparece en las elecciones pequeñas: lo que dices de alguien, el hechizo que piensas hacer, el límite que aceptas cruzar contra ti misma. Antes de actuar, una bruja principiante puede preguntarse: ¿esto daña a alguien, incluida yo? Un error común es usar la Rede como tribunal para culparse por todo. Es entrenamiento de conciencia, no vara de castigo\n\nGuarda esta idea: libertad y responsabilidad caminan juntas. Eres libre de desear, crear y actuar — y es justamente esa libertad la que pide cuidado con cada hilo de la red que te une a los demás y a ti misma. Tu ética es la primera página de tu camino, y se escribe todos los días',
        practice:
            'Qué hacer: revisitar con honestidad una situación difícil reciente. Cómo: primero, recuerda la escena sin juzgar; después, pregúntate cómo la Rede habría orientado tu acción, incluyendo el cuidado contigo; por último, anota en tu página qué harías igual y qué harías diferente. El objetivo es entrenar la conciencia ética antes de la próxima elección real — esto es entrenamiento, no tribunal',
        pageTitle: 'Mi Código de la Rede',
        pagePurpose: 'Traducir la ética wiccana a mi vida',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'La Rede con mis palabras:',
          'Tres situaciones reales donde me guía:',
          'Dónde suelo dañarme (nuevo acuerdo conmigo):',
          'Qué significa "retorno" para mí:',
        ],
      ),
      TrailLesson(
        id: 'wi_02',
        recordKind: LessonRecordKind.note,
        title: 'Diosa y Dios: la dualidad',
        teaching:
            'La Wicca clásica honra lo divino en dualidad: la Diosa y el Dios, dos rostros complementarios de lo mismo sagrado. La Diosa Triple se revela como Doncella, Madre y Anciana, reflejando los ciclos de la luna; el Dios Astado es el sol y la naturaleza salvaje que nace, madura y muere con las estaciones. Esta dualidad importa porque da imagen y ritmo a aquello que, sin ella, quedaría demasiado abstracto\n\nEn la Wicca difundida por Gerald Gardner, Diosa y Dios danzan a lo largo de la Rueda del Año: él nace en el solsticio de invierno, crece, se une a la Diosa y declina, mientras ella permanece, cambiando de rostro. Corrientes actuales flexibilizan esta visión — hay quien venera solo a la Diosa, quien honra a múltiples divinidades y quien ve un sagrado sin género. Lo esencial, común a casi todas las tradiciones, es la inmanencia: lo divino está EN la naturaleza, no fuera de ella\n\nEn el día a día, esta relación empieza pequeña: notar la fase de la luna al volver a casa, saludar al sol de la mañana, encender una vela plateada para la Diosa o dorada para el Dios. Una principiante no necesita sentir nada grandioso — el error común es forzar experiencias místicas o copiar la devoción ajena. Observa lo que te toca de verdad y comienza por ese punto\n\nLleva contigo esta llave: lo sagrado no vive lejos. Te encuentra en la luna que cambia, en el sol que regresa, en la hierba que insiste en nacer en la acera. Cualquiera que sea el rostro que lo divino tenga para ti, la Wicca te invita a reconocerlo cerca — y a dejar que esa cercanía transforme tu mirada',
        practice:
            'Qué hacer: un ejercicio de contemplación devocional de cinco minutos. Cómo: sal al aire libre o quédate junto a la ventana, elige algo vivo de la naturaleza — un árbol, el cielo, la luna — y obsérvalo en silencio, como quien contempla un rostro de lo divino, sin pedir nada y sin prisa. Después, registra en tu página lo que sentiste. El objetivo es ejercitar la percepción de lo sagrado inmanente, el que no exige templo: solo presencia',
        pageTitle: 'Cómo lo Sagrado me Encuentra',
        pagePurpose: 'Registrar mi relación con lo divino',
        pageCategory: SpellCategory.wisdom,
        pageIngredients: ['Velas plateada y dorada (opcionales)'],
        pagePrompts: [
          'Qué rostro de lo sagrado me toca más:',
          'Dónde ya sentí esto en la naturaleza:',
          'Mi gesto simple de devoción diaria:',
          'Cómo fue la observación de 5 minutos:',
        ],
      ),
      TrailLesson(
        id: 'wi_03',
        recordKind: LessonRecordKind.note,
        title: 'El altar wiccano',
        teaching:
            'El altar wiccano es el cosmos organizado sobre una mesa: un punto de encuentro entre tú y las fuerzas con las que trabajas. En él viven los cuatro elementos — el pentáculo o la sal para la Tierra, el incienso para el Aire, la vela para el Fuego, la copa para el Agua — además de símbolos de la Diosa y del Dios. Importa porque le da a lo invisible una dirección concreta dentro de tu casa\n\nEn la tradición que se difundió a partir de Gardner, cada herramienta tiene su función: el athame o la varita conducen la voluntad, el cáliz recibe, el pentáculo consagra. Símbolos comunes de la dualidad divina son una vela plateada y otra dorada, una concha y un cuerno, o dos imágenes. Pero las tradiciones varían bastante — existen altares fijos, altares estacionales que cambian con cada sabbat y altares mínimos guardados en una caja. Todos son legítimos\n\nPara la principiante, el mensaje es: empieza simple. Una vela, un vaso con agua, una piedra y una pluma ya forman un altar completo. El error más común es aplazar la práctica esperando comprar herramientas perfectas — el altar crece CON la práctica, no antes de ella. Cuídalo como cuidas una planta: límpialo, renueva el agua, cambia lo que perdió sentido. La pestaña Altar de la Enciclopedia trae más ideas\n\nGuarda esta idea: el altar no es vitrina, es relación. Vale más una mesa humilde visitada todos los días que un conjunto lujoso cubierto de polvo. Donde pones atención y cariño, lo sagrado encuentra morada. Monta el tuyo con lo que tienes hoy y deja que crezca junto contigo',
        practice:
            'Qué hacer: montar tu primer altar mínimo, aunque sea provisional. Cómo: elige un rincón tranquilo, limpia la superficie y dispón cuatro objetos, uno por cada elemento — por ejemplo, una piedra o sal para la Tierra, una pluma o incienso para el Aire, una vela para el Fuego y un vaso con agua para el Agua. Quédate un instante frente a él en silencio. El objetivo es crear un punto físico de encuentro con lo sagrado, que crecerá junto con tu práctica',
        pageTitle: 'Mi Altar',
        pagePurpose: 'Registrar el montaje de mi altar',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Dónde lo monté y qué representa cada elemento:',
          'Símbolos de la Diosa/del Dios (si elegí tenerlos):',
          'Qué siento frente a él:',
          'Qué quiero añadir con el tiempo:',
        ],
      ),
      TrailLesson(
        id: 'wi_04',
        title: 'Llamando a los Cuadrantes',
        teaching:
            'Llamar a los Cuadrantes es invitar a los guardianes de las cuatro direcciones a sostener el círculo ritual: el Este ligado al Aire, el Norte o el Sur ligado al Fuego según el hemisferio, el Oeste ligado al Agua y la dirección restante ligada a la Tierra. La práctica importa porque afirma el círculo como espacio vivo, rodeado de presencias aliadas, y ancla el rito en los cuatro elementos\n\nEn la estructura ritual heredada de la Wicca gardneriana, las llamadas ocurren después del trazado del círculo, generalmente empezando por el Este y siguiendo el giro del sol. Cada llamada es una invitación respetuosa, nunca una orden: los guardianes — vistos por algunas tradiciones como espíritus elementales, por otras como aspectos de la propia psique — son recibidos como invitados de honor. Al final del rito, se les despide en orden inverso, siempre agradeciendo\n\nAl principio, es común trabarse al hablar en voz alta u olvidar el orden. Ve con calma: palabras simples y sinceras valen más que versos memorizados. Un error frecuente es copiar correspondencias del hemisferio norte sin reflexionar — en el hemisferio sur, muchas brujas ajustan las direcciones a las estaciones y a los vientos reales. Elige tu lógica, regístrala y sé coherente con ella\n\nLleva contigo: una invitación no es una orden. La fuerza de esta práctica está en la cortesía — llamas, acoges, trabajas y agradeces. Empieza pequeño y repite: la familiaridad transforma el gesto en rito. Quien aprende a abrir y cerrar las puertas con respeto descubre que el círculo se vuelve, cada vez más, un hogar',
        practice:
            'Qué hacer: tu primera llamada a los cuadrantes. Cómo: ponte de pie, gírate hacia cada dirección — en el orden que tenga sentido en tu hemisferio — y di una invitación simple, como: guardianes de esta dirección, elemento correspondiente, sean bienvenidos a mi círculo. Al terminar el momento, agradece a cada dirección en orden inverso. El objetivo es experimentar en el cuerpo el gesto de abrir y cerrar un espacio ritual con respeto y presencia',
        pageTitle: 'Mi Llamada a los Cuadrantes',
        pagePurpose: 'Crear mi liturgia de las direcciones',
        pageCategory: SpellCategory.protection,
        pagePrompts: [
          'Mi correspondencia dirección→elemento (y hemisferio):',
          'Mis palabras para cada llamada:',
          'Mis palabras de despedida:',
          'Qué sentí en cada dirección:',
        ],
      ),
      TrailLesson(
        id: 'wi_05',
        title: 'La Rueda del Año',
        teaching:
            'La Rueda del Año es el calendario sagrado de la Wicca: el tiempo vivido como círculo, no como línea recta. Son ocho sabbats — los dos solsticios, los dos equinoccios y los cuatro festivales del fuego: Samhain, Imbolc, Beltane y Lughnasadh. Celebrarlos importa porque reconecta tu vida al ritmo real de la tierra: sembrar, florecer, cosechar y descansar dejan de ser metáforas y se vuelven experiencia\n\nEn la narrativa wiccana clásica, la Rueda cuenta la historia de la Diosa y el Dios a través de las estaciones: el Dios nace en el solsticio de invierno, crece, se une a la Diosa en Beltane, se entrega en la cosecha y regresa al vientre de la Anciana en Samhain, cuando se honra a los ancestros. Cada sabbat refleja un momento interno: honrar a quienes vinieron antes, renacer, florecer, agradecer la cosecha. Tradiciones diferentes cuentan esta historia con variaciones — y todas son válidas\n\nEn el hemisferio sur, muchas brujas invierten las fechas para acompañar las estaciones reales — celebrando Samhain en mayo, por ejemplo — mientras otras mantienen el calendario del norte. No existe una respuesta única: elige tu coherencia y regístrala. El error común de la principiante es querer rituales grandiosos en todos los sabbats; empieza con celebraciones de diez minutos, sinceras y simples\n\nLleva contigo: la Rueda gira sin prisa, y tú giras con ella. Cada estación de la tierra encuentra una estación dentro de ti. Celebrar los sabbats es solo eso: marcar encuentros regulares con tu propio ciclo. Cuando la vida parezca detenida, recuerda: ningún invierno es definitivo — la Rueda siempre vuelve a girar hacia la luz',
        practice:
            'Qué hacer: planear tu primera celebración estacional. Cómo: consulta la Rueda del Año de la app y descubre cuál es el próximo sabbat en tu hemisferio; lee sobre lo que celebra; después diseña una celebración de diez minutos — puede ser encender una vela, preparar un alimento de la estación o escribir una intención. Anota el plan en tu página y realízalo en la fecha. El objetivo es salir de la teoría y vivir la Rueda a tu propio ritmo',
        pageTitle: 'Mi Próximo Sabbat',
        pagePurpose: 'Planear mi primera celebración de la Rueda',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Sabbat y fecha (en mi hemisferio):',
          'Qué celebra y qué refleja en mí:',
          'Mi celebración de 10 minutos:',
          'Después: ¿cómo fue?',
        ],
      ),
      TrailLesson(
        id: 'wi_06',
        title: 'El Esbat: magia de luna llena',
        teaching:
            'Si los sabbats celebran el viaje del sol, los esbats honran a la luna — en especial la luna llena, hora clásica del trabajo mágico en la Wicca. El esbat es el encuentro regular de la bruja con la Diosa en su rostro lunar: un momento de recarga, magia y escucha. Importa porque crea ritmo: mientras los sabbats llegan cada seis o siete semanas, la luna llena te visita todos los meses\n\nEn los covens tradicionales, el esbat es la reunión de trabajo: es cuando se hace magia, adivinación y sanación, bajo la luna llena que amplifica las mareas sutiles. Un guion clásico para la bruja solitaria: baño de preparación, trazado del círculo, saludo a la Diosa, el gesto de Bajar la Luna — recibir la luz en silencio, dejando que llene el cuerpo —, el trabajo mágico u oracular, el compartir de pasteles y vino y el cierre con gratitud\n\nEn la vida real, no toda luna llena te encuentra con ánimo — y está bien. Un esbat puede durar diez minutos: vela encendida, tres respiraciones bajo la luna, una intención. El error común es creer que solo vale con el guion completo; la constancia vale más que la pompa. Y si el cielo está nublado, la luna sigue ahí: trabaja igual, confiando en la marea invisible\n\nLleva contigo: la luna es el recordatorio mensual de que tú también tienes fases. Bajar la Luna es, en el fondo, permitirte recibir — algo raro en una vida de tanto hacer. Agenda tu encuentro con ella: la liturgia que escribas en tu página será tu primera obra propia en este camino',
        practice:
            'Qué hacer: tu primer gesto de Bajar la Luna. Cómo: en la próxima noche de luna visible, sal afuera o quédate junto a la ventana, respira hondo y pasa tres minutos bajo su luz — sin pedir, sin hablar, solo recibiendo, como quien toma un baño de plata. Después, registra en tu página lo que sentiste en el cuerpo y en el ánimo. El objetivo es entrenar el arte de recibir, que es el corazón del esbat, antes de construir tu liturgia completa de luna llena',
        pageTitle: 'Mi Ritual de Esbat',
        pagePurpose: 'Crear mi liturgia de luna llena',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Vela blanca', 'Agua', 'Algo para "pasteles y vino"'],
        pagePrompts: [
          'Mi apertura (círculo + saludo):',
          'Mi momento de Bajar la Luna:',
          'El trabajo que haré en los esbats:',
          'Mi cierre y compartir:',
        ],
      ),
      TrailLesson(
        id: 'wi_07',
        recordKind: LessonRecordKind.note,
        title: 'El Libro de las Sombras',
        teaching:
            'El Libro de las Sombras es el corazón material de la bruja wiccana: el lugar donde viven rituales, recetas, sueños, fracasos y descubrimientos — todo registrado, sin censura. Importa porque la memoria falla y la práctica evoluciona: lo que anotas hoy se convierte en el mapa que orientará a la bruja que serás dentro de algunos años\n\nEn la tradición gardneriana, el Libro de las Sombras se copiaba a mano, de la maestra a la iniciada, preservando los ritos del coven — y cada copia ganaba las marcas de quien la escribía. Hoy, con la fuerza de la brujería solitaria, cada practicante inicia el suyo desde cero, y las tradiciones difieren sobre el formato: cuadernos artesanales, archivos digitales, cajas de fichas. Lo que permanece es el principio: registrar es parte del rito, no burocracia después de él\n\nYa estás escribiendo el tuyo: esta app lo es. Cada página completada en las rutas y en Mi Grimorio es una hoja de tu Libro. En lo cotidiano, el hábito que sostiene todo es simple: después de cada ritual o práctica, anota la fecha, qué hiciste, qué sentiste y el resultado. El error común es registrar solo los éxitos — los fracasos enseñan más y merecen página propia\n\nLleva contigo: un Libro de las Sombras no necesita ser bonito, necesita ser verdadero. Organízalo a tu manera y deja que la estructura crezca con el uso. Es el espejo de tu jornada y, un día, podrá ser herencia. Escribe como quien conversa con la bruja del futuro — ella agradecerá cada línea',
        practice:
            'Qué hacer: una revisión editorial de tu propio Libro. Cómo: recorre con calma las páginas que ya escribiste en las rutas y en Mi Grimorio; observa temas que se repiten, registros que funcionaron y vacíos; después esboza, en la página de esta lección, las secciones que tendrían sentido para organizarlo todo. El objetivo es descubrir la estructura que ya emerge naturalmente de tus registros — y asumirla como el orden de tu Libro de las Sombras',
        pageTitle: 'El Orden de Mi Libro',
        pagePurpose: 'Organizar mi Libro de las Sombras',
        pageCategory: SpellCategory.study,
        pagePrompts: [
          'Mis secciones (cómo organizo mis registros):',
          'Lo que SIEMPRE registro después de un ritual:',
          'Mi ritual de apertura del libro (¿una frase? ¿un símbolo?):',
          'A quién (si a alguien) le dejaría este libro un día:',
        ],
      ),
      TrailLesson(
        id: 'wi_08',
        title: 'Magia con la Diosa: invocación',
        teaching:
            'Invocar, en la Wicca, es invitar a lo divino a acercarse — no bajar entidades ni dar órdenes a lo sagrado. Es el gesto de abrir la puerta de casa a una visita querida: llamas, acoges y convives. La invocación importa porque transforma la práctica, que deja de ser un conjunto de técnicas y se vuelve una relación viva con aquello que consideras sagrado\n\nLa invocación tiene tres tiempos. Primero, prepararte: un baño, el trazado del círculo, algunos minutos de silencio para llegar entera. Después, llamar: con palabras del corazón, no fórmulas memorizadas de otras personas — las tradiciones wiccanas guardan invocaciones célebres a la Diosa en la luna llena, pero todas nacieron del mismo lugar: alguien que habló con verdad. Por último, ESCUCHAR — el tiempo más olvidado de los tres\n\nEn la práctica de la principiante, la señal de que la invocación funcionó rara vez es espectacular: es un silencio diferente, un calor en el pecho, una certeza mansa. El error más común es esperar fenómenos y desistir cuando no llegan — o hablar tanto que no queda espacio para respuesta alguna. Reserva siempre al menos dos minutos de escucha absoluta después de llamar\n\nLleva contigo: invocar es conversar, y toda buena conversación tiene más escucha que habla. Llama a lo sagrado con tus propias palabras, a tu manera, y confía en las señales discretas. La presencia divina suele llegar en voz baja — aprende, poco a poco, a escuchar bajito también',
        practice:
            'Qué hacer: tu primera invocación completa. Cómo: prepárate con un baño o algunos minutos de silencio; en tu espacio, llama con palabras propias a la energía divina que más te toca — Diosa, Dios o lo sagrado como lo entiendas; después permanece dos minutos en escucha absoluta, sin esperar nada específico; cierra agradeciendo. El objetivo es experimentar los tres tiempos del rito — preparar, llamar y escuchar — y registrar las señales sutiles que aparezcan',
        pageTitle: 'Mi Invocación',
        pagePurpose: 'Crear mis palabras de llamada',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Mis palabras de invocación:',
          'Cómo me preparo antes:',
          'Qué percibí en la escucha:',
          'Cómo cierro y agradezco:',
        ],
      ),
      TrailLesson(
        id: 'wi_09',
        title: 'Cakes and Wine: lo sagrado que alimenta',
        teaching:
            'El rito de pasteles y vino cierra los rituales wiccanos con un gesto de anclaje: después de mover energía, el cuerpo pide tierra — y comer y beber con bendición te devuelve al mundo. Es la eucaristía de la naturaleza: lo sagrado que se hace cuerpo. El rito importa porque enseña algo central en la Wicca: materia y espíritu no son enemigos, y la mesa también es altar\n\nEn los covens tradicionales, el momento de cakes and wine sella el encuentro: el alimento se bendice — en algunas tradiciones, con el gesto simbólico del athame sumergido en el cáliz, unión del Dios y la Diosa —, la primera porción se ofrenda a la tierra y el resto se comparte entre todos. La bruja solitaria adapta: la ofrenda puede ir al jardín, a la maceta de la ventana o al pie de un árbol. ¿Sin vino? Jugo, té o agua sirven: la bendición está en el gesto, no en el menú\n\nEn lo cotidiano, este rito puede desbordar del círculo hacia la vida: bendecir el desayuno, agradecer antes del almuerzo, hacer una comida al día sin pantallas y con presencia. El error común es tratar la etapa como merienda informal y saltarse la ofrenda — es justamente ofrendar primero lo que transforma el consumo en comunión. La presencia es el ingrediente que no puede faltar\n\nLleva contigo: todo alimento es la tierra llegando hasta ti. Cuando bendices, ofrendas y comes con atención, el acto más banal del día se vuelve rito — y lo sagrado deja de ser un evento raro para volverse hábito que nutre, en el sentido más literal de la palabra. Come despacio: anclar también es celebrar',
        practice:
            'Qué hacer: tu primer rito de pasteles y vino fuera del círculo. Cómo: prepara una merienda simple y una bebida — té, jugo o agua valen tanto como el vino; bendice el alimento con palabras tuyas; separa una primera porción simbólica y ofréndala a la tierra, a una maceta o junto a una planta; luego come despacio, con total presencia y sin pantallas. El objetivo es experimentar el anclaje a través del alimento y sentir la diferencia entre comer en automático y comulgar',
        pageTitle: 'Mi Rito de Pasteles y Vino',
        pagePurpose: 'Crear mi rito de anclaje',
        pageCategory: SpellCategory.home,
        pagePrompts: [
          'Mi "pastel" y mi "vino" (lo que uso):',
          'Mi bendición sobre el alimento:',
          'Cómo hago la ofrenda:',
          'Diferencia entre comer así y comer en automático:',
        ],
      ),
      TrailLesson(
        id: 'wi_10',
        recordKind: LessonRecordKind.desire,
        title: 'Autoiniciación: el compromiso',
        teaching:
            'La autoiniciación es el rito en que la bruja solitaria, sin coven, se compromete formalmente con el camino — ante lo sagrado tal como lo entiende. No es diploma ni graduación: es un voto íntimo, hecho de ti para ti, atestiguado por aquello que consideras divino. Importa porque marca una travesía: de curiosa a practicante, de quien estudia a quien asume el camino\n\nEn las tradiciones iniciáticas, como la gardneriana, la iniciación la confiere el coven tras el periodo clásico de un año y un día de estudio — y parte de la comunidad wiccana entiende que solo ella transmite el linaje. Otras corrientes, sobre todo desde la difusión de la práctica solitaria, defienden que la dedicación sincera ante los dioses tiene pleno valor. Las dos visiones conviven en la Wicca de hoy; tu camino es tuyo para elegir, con respeto por ambas\n\nEn la práctica, el rito suele reunir todo lo que aprendiste: baño, círculo, llamada a los cuadrantes, invocación, el voto dicho en voz alta, pasteles y vino, registro en el Libro de las Sombras. El error común es la prisa — dedicarse en la primera semana de estudio — o lo contrario: aplazar para siempre por no sentirse lista. El tiempo correcto es el tuyo, pero existen señales: constancia en la práctica y claridad en el deseo\n\nLleva contigo: nadie te inicia en tu propio camino — ni siquiera un coven lo haría sin tu sí interior. Esta última página es el borrador de tu rito de dedicación. Escríbelo sin prisa, realízalo cuando sientas que es hora y vuelve para registrarlo. La Rueda sigue girando, y ahora tú giras con ella, de la mano de lo que es sagrado para ti',
        practice:
            'Qué hacer: escribir, solo para ti, el borrador de tu compromiso. Cómo: en un momento tranquilo, responde por escrito qué significa comprometerte con este camino — qué te prometes, qué dejas atrás, qué deseas cultivar; después esboza el rito que harás un día: lugar, elementos, palabras. Sin plazo y sin prisa. El objetivo es preparar el corazón y el texto de tu futura autoiniciación, para realizarla cuando sientas que llegó la hora',
        pageTitle: 'Mi Rito de Dedicación',
        pagePurpose: 'Diseñar mi compromiso con el camino',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Lo que me prometo a mí misma en este camino:',
          'El rito que planeo (lugar, elementos, palabras):',
          'Cómo sabré que es la hora:',
          '(Después de realizarlo) Cómo fue mi día de dedicación:',
        ],
      ),
    ],
  );
