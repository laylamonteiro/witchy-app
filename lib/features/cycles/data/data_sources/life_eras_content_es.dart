import '../../domain/era_ruler.dart';
import '../models/cycle_content.dart';

/// Contenido de las Eras y Fases — español.
///
/// Mantén el MISMO ORDEN y la MISMA CANTIDAD en los tres archivos
/// (`life_eras_content_pt/en/es.dart`) — la paridad se verifica en
/// `test/life_eras_content_parity_test.dart`. Solo cambia la prosa entre
/// idiomas; `regente` y la cantidad de etiquetas son invariantes.
const List<EraContent> erasEs = [
  EraContent(
    regente: EraRegente.cauda,
    titulo: 'Tiempo de soltar y mirar lejos',
    tags: ['desapego', 'silencio', 'búsqueda'],
    corpo:
        'La Cola rige un tiempo de **aflojar las manos**. Cosas que sostenías con fuerza '
            'empiezan a soltarse solas — vínculos, planes, versiones tuyas que ya '
            'cumplieron lo suyo. Puede parecer pérdida, pero es **limpieza de altar**: solo '
            'queda lo que de verdad es tuyo. También es un período de **hambre espiritual**, en '
            'el que lo que antes bastaba empieza a parecer pequeño',
    sombra:
        'El riesgo es confundir **desapego con abandono**. Puedes quedarte **sin suelo**, sin '
            'ganas de nada, creyendo que perdiste el rumbo. Esa sensación de estar fuera '
            'del mundo puede volverse **aislamiento** si la dejas crecer',
    convite:
        'No fuerces decisiones grandes ahora — este tiempo **pide preguntas**, no respuestas. '
            'Guarda lo que aparezca en tu **diario de sueños**, que es por ahí donde la Cola '
            'suele hablar. Un altar sencillo, con pocas cosas, hace más efecto que uno '
            'lleno',
  ),
  EraContent(
    regente: EraRegente.venus,
    titulo: 'Tiempo de belleza y placer',
    tags: ['amor', 'placer', 'armonía'],
    corpo:
        'Venus abre el período más largo del ciclo, y **lo abre con dulzura**. Los afectos '
            'ganan peso: lo que empieza aquí tiende a durar, y lo que ya existe pide '
            'cuidado y belleza. Es buen tiempo para el dinero que viene de **lo que haces con** '
            'gusto, para que la casa quede bonita, para tratar al cuerpo con cariño en vez '
            'de exigencia',
    sombra:
        '**Veinte años de dulzura** también acomodan. Puedes acostumbrarte tanto a la '
            'comodidad que cualquier roce se vuelva motivo de huida. Cuidado con decir que '
            'sí solo para **mantener la paz**, y con gastar por placer más de lo que cabe',
    convite:
        'Di lo que quieres, **en voz alta**, a quien necesita oírlo. Haz algo con las manos '
            '**sin más finalidad que el placer**. Trabaja con rosas, cobre y todo lo que '
            'perfuma — Venus responde a la belleza ofrecida a propósito',
  ),
  EraContent(
    regente: EraRegente.sol,
    titulo: 'Tiempo de aparecer',
    tags: ['expresión', 'coraje', 'reconocimiento'],
    corpo:
        'Seis años **cortos y cálidos**. El Sol ilumina lo que haces, y la gente empieza a '
            'verlo. Es el tiempo de **asumir tu propio nombre**: liderar, firmar, subir al '
            'escenario que sea el tuyo. Se abren puertas por quien eres, no por a quién '
            'conoces, y tu palabra **pesa más que antes**',
    sombra:
        '**La luz fuerte también ciega**. Puede darte ganas de ser vista a cualquier precio, '
            'de estirar la historia hasta que quepa en la admiración ajena. Y el **orgullo** '
            'herido duele más en este período que en cualquier otro',
    convite:
        'Elige un lugar para brillar y **ve hasta el final en él** — este tiempo es corto y no '
            'rinde dividido en cinco. Oro, girasol y la luz del mediodía son tus aliados. '
            'Haz al menos una cosa importante con tu nombre en ella',
  ),
  EraContent(
    regente: EraRegente.lua,
    titulo: 'Tiempo de sentirlo todo',
    tags: ['emoción', 'cuidado', 'raíces'],
    corpo:
        'La Luna rige **diez años de piel fina**. Sientes más, y **más hondo**: lo que a otros les '
            'pasa desapercibido a ti te llega entero. La casa, la familia y las personas '
            'que son tu puerto ganan el centro. También es un tiempo de **intuición afilada**, '
            'en el que el cuerpo sabe antes que la cabeza',
    sombra:
        '**Sentirlo todo cansa**. El humor **se vuelve marea** y puedes terminar gobernada por él, '
            'guardando la herida en vez de nombrarla, o cuidando de todos menos de ti. '
            'Dormir mal y aferrarte al pasado son los avisos de que se pasó el punto',
    convite:
        'Marca las fases lunares en tu diario y fíjate en lo que se repite — es **el mapa de** '
            'tus mareas. Plata, jazmín y agua en la cabeza te asientan. Y **pide regazo**: en '
            'este tiempo, pedir no es debilidad, es técnica',
  ),
  EraContent(
    regente: EraRegente.marte,
    titulo: 'Tiempo de actuar y defender',
    tags: ['coraje', 'acción', 'límite'],
    corpo:
        'Marte **enciende la mecha**. Siete años de **energía en bruto** disponible, que piden ser '
            'gastados en algo. Es el mejor tramo del ciclo para empezar de cero, entrenar '
            'el cuerpo, pelear por lo que importa y por fin decir que no. El coraje llega '
            '**antes que la certeza** — y funciona igual',
    sombra:
        '**Energía sin destino** se vuelve roce. **Mecha corta**, discusión por nada, accidente '
            'por prisa, decisión tomada con rabia y pagada después. Si no se está '
            'construyendo nada, Marte encuentra qué destruir',
    convite:
        'Dale al cuerpo lo que está pidiendo: **movimiento, sudor**, esfuerzo con hora fija. '
            'Elige **una pelea que valga la pena** y deja pasar las demás. Hierro, ortiga y una '
            'vela roja encendida antes de decidir algo difícil',
  ),
  EraContent(
    regente: EraRegente.serpente,
    titulo: 'Tiempo de darte vuelta',
    tags: ['ruptura', 'deseo', 'reinvención'],
    corpo:
        'La Serpiente trae dieciocho años en los que la vida **deja de seguir las reglas** '
            'conocidas. Las cosas pasan **a destiempo**, del modo equivocado, y aun así '
            'funcionan. Puedes verte haciendo lo que jurabas que no harías, yéndote lejos, '
            'cambiando de nombre o de mundo. Al final, **otra persona** sale del otro lado',
    sombra:
        'Es **el período de los espejismos**. Lo que brilla puede no ser oro, y el hambre de '
            'más puede llevarte lejos de lo que de verdad importa. Prisa, atajo y promesa '
            '**demasiado buena** piden aquí doble verificación',
    convite:
        'Antes de decidir algo grande, **deja pasar un ciclo lunar** — lo que sea verdadero '
            'seguirá ahí después. Anota lo que jurabas que nunca harías, para reconocer el '
            'giro cuando llegue. Y **confía en lo extraño**: es lo que te está llevando adonde '
            'necesitas ir',
  ),
  EraContent(
    regente: EraRegente.jupiter,
    titulo: 'Tiempo de cosechar y multiplicar',
    tags: ['expansión', 'abundancia', 'sabiduría'],
    corpo:
        'Júpiter es **el regente más generoso** del ciclo, y dieciséis años suyos cambian el '
            'tamaño de tu vida. Lo que plantaste empieza **a dar en cantidad**. Estudio, viaje, '
            'reconocimiento y dinero aparecen con más facilidad de lo normal, y gente con '
            'poder de abrir puertas se cruza en tu camino **sin que la hayas buscado**',
    sombra:
        '**La abundancia también exagera**. Puedes decir que sí de más, prometer más de lo que '
            'cabe en la semana y crecer hacia todos lados sin terminar nada. **El exceso** — de '
            'comida, de gasto, de opinión — es la forma que tiene Júpiter de avisarte',
    convite:
        'Elige en qué dirección crecer y rechaza las otras con educación. **Enseña lo que** '
            'sabes: en este tiempo, **dar multiplica** en vez de restar. Estaño, salvia y un '
            'propósito escrito donde lo veas a diario',
  ),
  EraContent(
    regente: EraRegente.saturno,
    titulo: 'Tiempo de construir con tus propias manos',
    tags: ['disciplina', 'madurez', 'consecuencia'],
    corpo:
        'Saturno es **el maestro severo** del ciclo, y diecinueve años suyos construyen a una '
            'persona entera. Nada viene gratis, pero **nada de lo que viene se pierde**: lo que '
            'levantes aquí queda en pie por décadas. Es el tiempo de asumir lo tuyo, '
            'terminar lo que quedó a medias y descubrir que **aguantas más de lo que creías**',
    sombra:
        'También es **el tramo más pesado**. Elecciones viejas vuelven **a pedir cuentas**, las '
            'puertas tardan, y el cansancio es real. Puede darte ganas de cerrarte, de '
            'creer que no eres capaz, de tratarte con **una dureza** que no usarías con nadie',
    convite:
        '**Haz poco, pero hazlo todos los días** — Saturno paga por constancia, nunca por '
            'arranque. Escribe **lo que terminaste**, no lo que falta. Plomo, ciprés y la '
            'paciencia de quien sabe que esta cosecha no es de esta luna',
  ),
  EraContent(
    regente: EraRegente.mercurio,
    titulo: 'Tiempo de aprender y conectar',
    tags: ['comunicación', 'estudio', 'movimiento'],
    corpo:
        'Mercurio abre **diecisiete años de mente encendida**. Aprendes rápido, hablas mejor y '
            'circulas más: gente nueva, tema nuevo, ciudad nueva. Es excelente para '
            'estudiar, escribir, negociar y para cualquier trabajo donde **la palabra sea la** '
            'herramienta. Las ideas llegan más rápido de lo que alcanzas a anotarlas',
    sombra:
        'Una mente encendida **no se apaga**. Pensamiento en bucle, insomnio de cabeza llena, '
            'diez cosas empezadas y ninguna terminada. Y la palabra que abre una puerta es '
            'la misma que la cierra: aquí, **hablar sin pensar sale caro**',
    convite:
        'Escribe — en el diario, en un cuaderno, donde sea. **Sacarlo fuera** es lo que deja '
            'descansar a esta mente. Elige **tres temas al año** y deja los otros para después. '
            'Mercurio, lavanda y silencio a propósito una vez por semana',
  ),
];

/// Fases — el sabor corto que cada regente da a la Era en curso.
const List<FaseContent> fasesEs = [
  FaseContent(
    regente: EraRegente.cauda,
    titulo: 'Deja caer lo que ya terminó',
    tags: ['limpieza', 'pausa', 'intuición'],
    sabor:
        'La Cola pasa corta y pide **espacio vacío**. Algo se cierra **sin ruido**, y tratar de '
            'sostenerlo solo duele más. Aprovecha para limpiar cajones, agenda y promesas '
            'viejas',
  ),
  FaseContent(
    regente: EraRegente.venus,
    titulo: 'Enfócate en sentirte bien',
    tags: ['placer', 'afecto', 'belleza'],
    sabor:
        'Venus **endulza el período**. Los encuentros se vuelven fáciles, el cuerpo pide '
            'cuidado y lo bonito rinde más que lo correcto. Buen tiempo para **pedir aumento**, '
            'declararte y recibir',
  ),
  FaseContent(
    regente: EraRegente.sol,
    titulo: 'Ocupa tu lugar',
    tags: ['visibilidad', 'nombre', 'claridad'],
    sabor:
        'El Sol **enciende el foco** por un rato corto. Te notan, te exigen y te reconocen en '
            'dosis mayor. Si tienes algo que mostrarle al mundo, **muéstralo ahora**',
  ),
  FaseContent(
    regente: EraRegente.lua,
    titulo: 'Cuida lo que sientes',
    tags: ['emoción', 'casa', 'descanso'],
    sabor:
        'La Luna vuelve todo **más sensible**. Los asuntos de familia y de casa pasan al '
            'frente, y la intuición se afila. Si te dan ganas de recogerte, **recógete** — esta '
            'vez no es huida',
  ),
  FaseContent(
    regente: EraRegente.marte,
    titulo: 'Haz que suceda',
    tags: ['acción', 'coraje', 'roce'],
    sabor:
        'Marte **acelera todo**. Aparece energía para empezar y ganas de pelear, a veces en la '
            'misma frase. Gástalo en el cuerpo y en el trabajo, **antes de que se gaste** solo '
            'en una discusión',
  ),
  FaseContent(
    regente: EraRegente.serpente,
    titulo: 'Espera lo inesperado',
    tags: ['giro', 'deseo', 'prisa'],
    sabor:
        'La Serpiente **baraja de nuevo**. Los planes cambian a último momento y aparece una '
            'oportunidad que parece demasiado buena. **Verifica dos veces** y no firmes con '
            'prisa',
  ),
  FaseContent(
    regente: EraRegente.jupiter,
    titulo: 'Di que sí a lo que expande',
    tags: ['suerte', 'estudio', 'puerta abierta'],
    sabor:
        'Júpiter **abre camino**. Invitaciones, buenas noticias y gente dispuesta a ayudar '
            'aparecen con facilidad. Solo cuida de no aceptar más de lo que **cabe en tu** '
            'semana',
  ),
  FaseContent(
    regente: EraRegente.saturno,
    titulo: 'Termina lo que quedó a medias',
    tags: ['esfuerzo', 'prueba', 'estructura'],
    sabor:
        'Saturno **pesa la mano**. Todo tarda más y exige más, y lo que estaba mal hecho sale '
            'a la luz. Es incómodo y es útil: lo que repares ahora **queda reparado**',
  ),
  FaseContent(
    regente: EraRegente.mercurio,
    titulo: 'Habla, escribe, acuerda',
    tags: ['palabra', 'idea', 'tránsito'],
    sabor:
        'Mercurio **acelera la cabeza** y la conversación. Excelente para estudiar, negociar y '
            'resolver pendientes por escrito. Malo para prometer sin pensar — **relee antes** '
            'de enviar',
  ),
];
