import '../models/dream_theme_model.dart';

/// Temas y simbolismos oníricos — contenido en español.
///
/// Ids y emojis son invariantes entre idiomas; solo se traducen títulos,
/// resúmenes, lecturas y reflexiones. Mantén el mismo orden que
/// `dream_themes_data_pt.dart` — la paridad se verifica en
/// `test/dream_themes_parity_test.dart`.
const List<DreamTheme> dreamThemesEs = [
  DreamTheme(
    id: 'agua',
    emoji: '🌊',
    title: 'Agua',
    summary: 'Emociones, inconsciente y flujo de la vida',
    readings: [
      DreamThemeReading(
        title: 'Estado de las emociones',
        content:
            'El agua suele reflejar el momento emocional: aguas calmas y cristalinas pueden indicar serenidad y claridad; aguas turbias, agitadas u oscuras pueden señalar sentimientos confusos, reprimidos o que piden atención',
      ),
      DreamThemeReading(
        title: 'El inconsciente profundo',
        content:
            'En la lectura junguiana, mares y océanos representan el inconsciente. Sumergirse puede ser una invitación a conocerse mejor; ahogarse puede sugerir una sensación de sobrecarga por emociones no elaboradas',
      ),
      DreamThemeReading(
        title: 'Purificación y renovación',
        content:
            'En muchas tradiciones mágicas, el agua es el elemento de la limpieza y la sanación. Lluvia, baños y ríos en un sueño pueden indicar un ciclo de purificación en curso — algo siendo lavado para dar lugar a lo nuevo',
      ),
    ],
    reflection:
        '¿Cómo estaba el agua de tu sueño — y cómo están tus emociones al despertar? Registrar ambos lados ayuda a percibir patrones',
  ),
  DreamTheme(
    id: 'queda',
    emoji: '🪂',
    title: 'Caída',
    summary: 'Pérdida de control y miedo a fallar',
    readings: [
      DreamThemeReading(
        title: 'Sensación de descontrol',
        content:
            'Soñar que caes es uno de los sueños más universales y suele acompañar fases en que algo parece fuera de control: trabajo, relaciones, finanzas. El cuerpo traduce en caída la inseguridad del momento',
      ),
      DreamThemeReading(
        title: 'Miedo a decepcionar',
        content:
            'La caída también puede hablar del miedo a fallar ante los ojos de los demás — la altura del "precipicio" suele ser proporcional a las expectativas que cargamos',
      ),
      DreamThemeReading(
        title: 'Invitación a la entrega',
        content:
            'En lecturas místicas, caer sin lastimarse (o volar después de la caída) puede indicar que es seguro soltar el control y confiar en el flujo — la caída se vuelve travesía',
      ),
    ],
    reflection:
        '¿Qué en tu vida parece "sin suelo" ahora? Nombrar ese miedo ya reduce su poder',
  ),
  DreamTheme(
    id: 'perseguicao',
    emoji: '🏃',
    title: 'Persecución',
    summary: 'Aquello que evitamos enfrentar',
    readings: [
      DreamThemeReading(
        title: 'Huida de un conflicto',
        content:
            'Ser perseguida suele representar algo que estamos evitando: una conversación difícil, una decisión aplazada, un sentimiento negado. El perseguidor es, muchas veces, el propio asunto pendiente',
      ),
      DreamThemeReading(
        title: 'La sombra interior',
        content:
            'En la psicología de los sueños, lo que nos persigue puede ser una parte de nosotros que rechazamos — la "sombra". Girarse y enfrentar al perseguidor, en el sueño o en la imaginación al despertar, suele transformar la trama',
      ),
      DreamThemeReading(
        title: 'Presiones externas',
        content:
            'También puede reflejar exigencias reales: plazos, deudas, expectativas de terceros. El sueño exagera la imagen para que el mensaje sea escuchado',
      ),
    ],
    reflection:
        'Si dejaras de correr y miraras hacia atrás, ¿quién — o qué — estaría allí?',
  ),
  DreamTheme(
    id: 'morte',
    emoji: '🦋',
    title: 'Muerte',
    summary: 'Fin de ciclo y transformación',
    readings: [
      DreamThemeReading(
        title: 'Transformación, no presagio',
        content:
            'En la inmensa mayoría de las tradiciones — del tarot al simbolismo junguiano — la muerte en un sueño habla de fin de ciclo y renacimiento, no de muerte literal. Algo en ti o en tu vida se está cerrando para abrir espacio',
      ),
      DreamThemeReading(
        title: 'Duelo y añoranza',
        content:
            'Soñar con personas que ya partieron puede ser parte natural del duelo: el inconsciente elabora la ausencia y, para muchas tradiciones espirituales, es también un espacio de encuentro y despedida',
      ),
      DreamThemeReading(
        title: 'Lo que necesita irse',
        content:
            'Cuando quien "muere" en el sueño es la propia soñadora, vale preguntarse: ¿qué versión de mí está lista para quedarse en el pasado? Hábitos, roles e identidades también mueren',
      ),
    ],
    reflection:
        '¿Qué ciclo se está cerrando en tu vida? Honrar el final es el primer paso del nuevo comienzo',
  ),
  DreamTheme(
    id: 'animais',
    emoji: '🦉',
    title: 'Animales',
    summary: 'Instintos y guías de la naturaleza',
    readings: [
      DreamThemeReading(
        title: 'La voz de los instintos',
        content:
            'Los animales en sueños suelen encarnar instintos: un lobo puede hablar de lealtad y territorio; un gato, de independencia y misterio; una serpiente, de transformación y energía vital',
      ),
      DreamThemeReading(
        title: 'Animales de poder',
        content:
            'En tradiciones chamánicas y de la brujería, un animal recurrente puede leerse como aliado o guía espiritual. Observa su comportamiento en el sueño: ¿amenaza, protege, conduce?',
      ),
      DreamThemeReading(
        title: 'Relación con el propio cuerpo',
        content:
            'Animales heridos o encerrados pueden reflejar necesidades básicas descuidadas — descanso, alimentación, placer, movimiento',
      ),
    ],
    reflection:
        '¿Qué animal apareció y qué estaba haciendo? Investiga su simbolismo en las tradiciones que tengan sentido para ti',
  ),
  DreamTheme(
    id: 'dentes',
    emoji: '🦷',
    title: 'Dientes',
    summary: 'Autoimagen, poder personal y pérdidas',
    readings: [
      DreamThemeReading(
        title: 'Inseguridad con la imagen',
        content:
            'Los dientes que se caen son un clásico ligado a la autoimagen y al miedo al juicio: ¿cómo seré vista si "pierdo la fachada"? Suele surgir en fases de exposición — nuevo empleo, relación, cambio',
      ),
      DreamThemeReading(
        title: 'Sensación de impotencia',
        content:
            'Los dientes son nuestra "mordida" en el mundo. Perderlos puede indicar una sensación de pérdida de fuerza, voz o capacidad de defenderse en algún área',
      ),
      DreamThemeReading(
        title: 'Transición y crecimiento',
        content:
            'Así como los dientes de leche caen para dar lugar a los definitivos, el sueño puede marcar una transición de fase — incómoda, pero necesaria',
      ),
    ],
    reflection:
        '¿En qué situación reciente sentiste que "perdiste la voz" o el poder de reaccionar?',
  ),
  DreamTheme(
    id: 'casa',
    emoji: '🏠',
    title: 'Casa',
    summary: 'El yo y sus habitaciones internas',
    readings: [
      DreamThemeReading(
        title: 'Mapa de una misma',
        content:
            'La casa suele representar a quien sueña: la fachada es la imagen social; la sala, la convivencia; el dormitorio, la intimidad; el baño, la limpieza emocional; la cocina, la creatividad y el cuidado',
      ),
      DreamThemeReading(
        title: 'Habitaciones desconocidas',
        content:
            'Descubrir cuartos nuevos o pisos secretos es un sueño poderoso: señala talentos, memorias o posibilidades que aún no has explorado en ti',
      ),
      DreamThemeReading(
        title: 'Estado de la estructura',
        content:
            'Una casa en ruinas, inundada o invadida puede hablar de límites personales debilitados o de cansancio estructural — el cuerpo y la rutina pidiendo reforma',
      ),
    ],
    reflection:
        '¿Qué habitación apareció y en qué estado estaba? ¿Qué dice eso sobre esa área de tu vida?',
  ),
  DreamTheme(
    id: 'voo',
    emoji: '🕊️',
    title: 'Volar',
    summary: 'Libertad, perspectiva y expansión',
    readings: [
      DreamThemeReading(
        title: 'Libertad conquistada',
        content:
            'Volar con placer suele acompañar fases de expansión: un peso se fue, un límite fue superado, una decisión liberadora fue tomada',
      ),
      DreamThemeReading(
        title: 'Ganar perspectiva',
        content:
            'Ver el mundo desde lo alto puede indicar la necesidad — o la recién adquirida capacidad — de mirar un problema desde lejos, con visión de conjunto',
      ),
      DreamThemeReading(
        title: 'Huida del suelo',
        content:
            'Si el vuelo es para escapar de algo, vale preguntarse si hay un asunto "terrenal" siendo evitado. Vuelos inestables pueden hablar de idealización sin base práctica',
      ),
    ],
    reflection:
        '¿El vuelo era ligero o ansioso? Libertad y huida a veces usan las mismas alas',
  ),
  DreamTheme(
    id: 'gravidez',
    emoji: '🌱',
    title: 'Embarazo',
    summary: 'Proyectos y nuevos comienzos gestándose',
    readings: [
      DreamThemeReading(
        title: 'Algo nuevo siendo gestado',
        content:
            'Soñar con un embarazo rara vez es literal: suele indicar un proyecto, idea, relación o versión de ti en gestación — algo que crece en silencio y aún no ha venido al mundo',
      ),
      DreamThemeReading(
        title: 'Tiempo de maduración',
        content:
            'El sueño puede recordarte que hay un tiempo justo: las gestaciones no se apresuran. La ansiedad por el "parto" puede reflejar prisa por los resultados',
      ),
      DreamThemeReading(
        title: 'Potencial creativo',
        content:
            'En la brujería, el embarazo onírico se lee con frecuencia como fertilidad en sentido amplio — creatividad, abundancia y manifestación en camino',
      ),
    ],
    reflection:
        '¿Qué estás gestando ahora — y qué necesita ese proyecto para nacer bien?',
  ),
  DreamTheme(
    id: 'pessoas-do-passado',
    emoji: '🕰️',
    title: 'Personas del Pasado',
    summary: 'Memorias, pendientes y reintegración',
    readings: [
      DreamThemeReading(
        title: 'Asuntos inacabados',
        content:
            'Exparejas, amigos distantes o antiguos colegas suelen aparecer cuando algo de aquella época pide cierre: un perdón, una lección, una palabra no dicha',
      ),
      DreamThemeReading(
        title: 'Cualidades por rescatar',
        content:
            'La persona puede representar una característica tuya de aquella fase — coraje, ligereza, disciplina — que el presente está pidiendo de vuelta',
      ),
      DreamThemeReading(
        title: 'Ciclos comparados',
        content:
            'El inconsciente también usa el pasado como vara de medir: aparece quien vivió contigo un ciclo parecido al actual, invitándote a comparar elecciones',
      ),
    ],
    reflection:
        '¿Qué representaba esa persona para ti? Quizás el mensaje sea sobre esa cualidad, no sobre ella',
  ),
  DreamTheme(
    id: 'lugares-desconhecidos',
    emoji: '🗺️',
    title: 'Lugares Desconocidos',
    summary: 'Territorios internos inexplorados',
    readings: [
      DreamThemeReading(
        title: 'Lo nuevo llamando',
        content:
            'Ciudades, caminos y paisajes nunca vistos suelen anunciar fases inéditas — interna o externamente. El tono del lugar (acogedor, hostil, vasto) indica cómo sientes esa novedad',
      ),
      DreamThemeReading(
        title: 'Potenciales no visitados',
        content:
            'Como las habitaciones secretas de la casa, las tierras desconocidas pueden representar capacidades tuyas aún no exploradas',
      ),
      DreamThemeReading(
        title: 'Sensación de desarraigo',
        content:
            'Perderse en un lugar extraño puede reflejar la sensación de no pertenecer — a un grupo, trabajo o fase. El sueño pide que te ubiques: ¿qué es tuyo allí?',
      ),
    ],
    reflection:
        '¿Te sentías perdida o explorando? El mismo paisaje cambia de sentido según la sensación',
  ),
  DreamTheme(
    id: 'sonhos-recorrentes',
    emoji: '🔁',
    title: 'Sueños Recurrentes',
    summary: 'Mensajes que insisten hasta ser escuchados',
    readings: [
      DreamThemeReading(
        title: 'Mensaje no atendido',
        content:
            'La repetición suele indicar un tema no resuelto: el inconsciente vuelve a presentar la escena hasta que algo cambie en la vida despierta. Pequeñas variaciones entre las versiones son pistas valiosas',
      ),
      DreamThemeReading(
        title: 'Patrones emocionales',
        content:
            'Los sueños recurrentes con frecuencia acompañan patrones que se repiten en relaciones o elecciones. Cuando el patrón cambia en la vida real, el sueño suele cambiar con él — o cesar',
      ),
      DreamThemeReading(
        title: 'Cómo trabajarlo',
        content:
            'Registrar cada ocurrencia en el Diario de Sueños, comparar detalles y conversar con el sueño (imaginar finales diferentes antes de dormir) son prácticas clásicas para destrabar la repetición',
      ),
    ],
    reflection:
        '¿Qué cambió en las últimas versiones del sueño? La variación es el termómetro de tu proceso',
  ),
  DreamTheme(
    id: 'fogo',
    emoji: '🔥',
    title: 'Fuego',
    summary: 'Pasión, rabia y transformación intensa',
    readings: [
      DreamThemeReading(
        title: 'Energía vital en movimiento',
        content:
            'El fuego es el elemento de la voluntad y la pasión. Llamas controladas — una vela, una hoguera acogedora — suelen hablar de entusiasmo, deseo y fuerza creativa en buena medida',
      ),
      DreamThemeReading(
        title: 'Rabia y sobrecarga',
        content:
            'Incendios fuera de control pueden reflejar emociones calientes reprimidas: rabia tragada, estrés acumulado, un límite a punto de estallar. El sueño muestra el tamaño del hervor interno',
      ),
      DreamThemeReading(
        title: 'Purificación por la quema',
        content:
            'En muchas tradiciones mágicas, quemar es transmutar: lo que el fuego consume en el sueño puede indicar lo que necesita ser destruido para volverse abono — un hábito, un vínculo, una versión de ti',
      ),
    ],
    reflection:
        '¿El fuego de tu sueño calentaba o destruía? Observa dónde aparece esa misma energía en tu vida despierta',
  ),
  DreamTheme(
    id: 'serpente',
    emoji: '🐍',
    title: 'Serpiente',
    summary: 'Transformación, sanación y energía vital',
    readings: [
      DreamThemeReading(
        title: 'Cambio de piel',
        content:
            'La serpiente es el gran símbolo de la renovación: cambia de piel para crecer. Soñar con serpientes suele acompañar fases de transformación profunda — incómodas, pero necesarias',
      ),
      DreamThemeReading(
        title: 'Sanación y sabiduría',
        content:
            'Del bastón de Asclepio a la kundalini, la serpiente también representa sanación y energía vital ascendente. Una serpiente tranquila puede indicar poder personal e intuición despertando',
      ),
      DreamThemeReading(
        title: 'Alerta y traición',
        content:
            'En el imaginario popular, la serpiente escondida habla de peligros silenciosos: situaciones o personas que piden atención. El miedo sentido en el sueño es la pista — pavor y fascinación cuentan historias diferentes',
      ),
    ],
    reflection:
        '¿La serpiente atacaba, observaba o simplemente seguía su camino? Tu reacción en el sueño dice tanto como el símbolo',
  ),
  DreamTheme(
    id: 'bebe',
    emoji: '👶',
    title: 'Bebé',
    summary: 'Comienzos, vulnerabilidad y cuidado',
    readings: [
      DreamThemeReading(
        title: 'Algo recién nacido',
        content:
            'Un bebé en un sueño suele representar lo que acaba de nacer en tu vida: un proyecto, una relación, una fase. El estado del bebé — sano, llorando, olvidado — refleja cómo está siendo cuidado ese comienzo',
      ),
      DreamThemeReading(
        title: 'La niña interior',
        content:
            'El bebé también puede ser tu propia parte más vulnerable pidiendo abrazo: necesidades básicas de afecto, descanso y acogida que la vida adulta atropelló',
      ),
      DreamThemeReading(
        title: 'Responsabilidad nueva',
        content:
            'Soñar que debes cuidar de un bebé que no es tuyo puede hablar de responsabilidades recién asumidas — y del miedo a no poder con ellas',
      ),
    ],
    reflection:
        '¿Qué en tu vida está en fase de recién nacido ahora — y qué cuidado está (o no está) recibiendo?',
  ),
  DreamTheme(
    id: 'dinheiro',
    emoji: '💰',
    title: 'Dinero',
    summary: 'Valor personal, intercambio y energía de abundancia',
    readings: [
      DreamThemeReading(
        title: 'Tu propio valor',
        content:
            'El dinero en un sueño rara vez es solo dinero: encontrar monedas o billetes suele hablar de recursos internos descubiertos — talentos, tiempo, energía — y de cuán valiosa te sientes',
      ),
      DreamThemeReading(
        title: 'Pérdida y miedo a la falta',
        content:
            'Perder dinero, ser robada o no poder pagar algo puede reflejar inseguridad material real o la sensación de estar gastando energía en lo que no retorna',
      ),
      DreamThemeReading(
        title: 'Flujo de intercambio',
        content:
            'En la lectura mágica, el dinero es un símbolo de flujo: lo que das y lo que recibes. Sueños de abundancia pueden confirmar que el flujo está abierto — o compensar una fase de apuros',
      ),
    ],
    reflection:
        'En el sueño, ¿el dinero llegaba o se escapaba? Compáralo con lo que andas dando y recibiendo — en todas las monedas, no solo la financiera',
  ),
  DreamTheme(
    id: 'nudez',
    emoji: '🙈',
    title: 'Desnudez en Público',
    summary: 'Exposición, vergüenza y autenticidad',
    readings: [
      DreamThemeReading(
        title: 'Miedo a ser vista de verdad',
        content:
            'Estar desnuda en público es el clásico sueño de la exposición: suele surgir cuando algo íntimo — un error, un sentimiento, un proyecto personal — está a punto de hacerse visible, y hay miedo al juicio',
      ),
      DreamThemeReading(
        title: 'Una vergüenza que solo es tuya',
        content:
            'Un detalle revelador: en muchos de estos sueños, nadie nota la desnudez. El inconsciente sugiere que la vergüenza es mayor por dentro que ante los ojos de los demás',
      ),
      DreamThemeReading(
        title: 'Invitación a la autenticidad',
        content:
            'En lecturas más luminosas, la desnudez habla de mostrarse sin máscaras. Sentirse libre en el sueño, aun desnuda, puede indicar una fase de aceptación y verdad contigo misma',
      ),
    ],
    reflection:
        '¿Qué temes que descubran sobre ti — y qué pasaría, de verdad, si lo descubrieran?',
  ),
  DreamTheme(
    id: 'provas-atrasos',
    emoji: '⏰',
    title: 'Exámenes y Retrasos',
    summary: 'Exigencia, preparación y miedo a no poder',
    readings: [
      DreamThemeReading(
        title: 'Sensación de falta de preparación',
        content:
            'Llegar tarde, perder el vuelo, hacer un examen sin haber estudiado: son variaciones del mismo tema — la sensación de que la vida exige más de lo que lograste preparar',
      ),
      DreamThemeReading(
        title: 'Autoexigencia en exceso',
        content:
            'Curiosamente, este sueño es común en personas muy responsables. El "examen" es el tribunal interno: una vara demasiado alta aplicada a una misma, no una evaluación real',
      ),
      DreamThemeReading(
        title: 'Revisión de prioridades',
        content:
            'El retraso también puede indicar que estás corriendo detrás de un horario que no es el tuyo — plazos y metas definidos por otras personas. Quizás el reloj del sueño no deba mandar en tu vida',
      ),
    ],
    reflection:
        '¿Qué examen sientes que estás haciendo en la vida real ahora — y quién fue que programó ese examen?',
  ),
  DreamTheme(
    id: 'traicao',
    emoji: '💔',
    title: 'Traición',
    summary: 'Confianza, inseguridad y lealtad contigo',
    readings: [
      DreamThemeReading(
        title: 'Inseguridad, no profecía',
        content:
            'Soñar con la traición de la pareja rara vez denuncia un hecho: suele reflejar inseguridad en el vínculo, carencia de atención o viejas heridas de confianza pidiendo cuidado',
      ),
      DreamThemeReading(
        title: 'Traición a ti misma',
        content:
            'Vale girar el espejo: ¿en qué área te has traicionado — tragándote lo que sientes, aplazando lo que importa, diciendo sí cuando era no? El sueño toma prestado el rostro de otra persona para un dolor interno',
      ),
      DreamThemeReading(
        title: 'Expectativa rota',
        content:
            'Ser traicionada por amigos o colegas en el sueño puede hablar de expectativas no dichas: acuerdos que solo existían en tu cabeza y que la otra persona ni sabía que había firmado',
      ),
    ],
    reflection:
        '¿El dolor del sueño apunta a la otra persona o a un acuerdo que hiciste sola? Conversar deshace la mitad de estas tramas',
  ),
  DreamTheme(
    id: 'espelho',
    emoji: '🪞',
    title: 'Espejo',
    summary: 'Identidad, autoimagen y verdad interior',
    readings: [
      DreamThemeReading(
        title: 'Encuentro con la propia imagen',
        content:
            'El espejo confronta: verse diferente, más vieja, más joven o irreconocible suele acompañar fases de cambio de identidad — cuando la imagen interna aún no ha alcanzado la nueva vida',
      ),
      DreamThemeReading(
        title: 'Lo que el reflejo esconde',
        content:
            'Espejos vacíos, empañados o rotos pueden hablar de desconexión contigo misma: cansancio de actuar un papel, dificultad para saber qué se quiere y qué se siente',
      ),
      DreamThemeReading(
        title: 'Portal y adivinación',
        content:
            'En la brujería, el espejo es herramienta de videncia y portal simbólico. Atravesarlo o ver otra escena reflejada puede indicar intuición aguda y una invitación a mirar más allá de la superficie',
      ),
    ],
    reflection:
        'Si te miraras al espejo ahora, por dentro: ¿la imagen que verías combina con la vida que estás viviendo?',
  ),
];
