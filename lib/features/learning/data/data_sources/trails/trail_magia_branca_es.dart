import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Senda 'magia_branca' — contenido en español.
/// Paridad con _pt/_en verificada en test/trails_parity_test.dart.
const LearningTrail magiaBrancaTrailEs = LearningTrail(
    id: 'magia_branca',
    emoji: '🕯️',
    title: 'Magia Blanca',
    subtitle: 'Luz, protección y bendiciones',
    description:
        'El camino de la intención luminosa: protección, sanación y bendiciones para ti y para quienes amas. Diez lecciones, diez páginas escritas por ti',
    lessons: [
      TrailLesson(
        id: 'mb_01',
        recordKind: LessonRecordKind.note,
        title: 'La intención es el corazón',
        teaching:
            'Toda magia comienza antes de la vela, del cristal o de la palabra: comienza en la intención. Ella es el corazón de cualquier trabajo porque dirige la energía que pones en movimiento. En la magia blanca, la intención se formula de manera clara, positiva y en tiempo presente — en lugar de decir que quieres dejar de tener miedo, afirmas que caminas protegida y confiada. Esa claridad es lo que transforma un deseo vago en un acto mágico\n\nUna buena intención tiene tres marcas: es específica, es tuya — nunca intenta controlar la voluntad de otras personas — y se dice como si ya fuera realidad. Esta estructura aparece en tradiciones diversas, desde las oraciones antiguas hasta las afirmaciones modernas, porque la mente responde mejor a imágenes concretas y presentes. Las practicantes experimentadas dedican más tiempo a pulir la frase que a montar el altar, pues saben que la palabra justa sostiene el trabajo entero\n\nEn el día a día de la bruja principiante, la intención aparece antes que todo: al encender una vela, preparar un baño o abrir el cuaderno. Un error común es acumular varios pedidos en una sola frase o usar negaciones, que mantienen el foco en el problema. Otro es formular con prisa. Reserva unos minutos, escribe, lee en voz alta y observa si el cuerpo responde: una intención viva suele provocar un leve escalofrío de reconocimiento\n\nLleva contigo esta idea: la magia comienza en la frase que eliges. Antes de cualquier herramienta, pule tu intención hasta que sea clara, tuya y presente. Cuando la palabra está bien dicha, todo el resto del ritual solo la acompaña — la vela ilumina, el gesto sella, pero quien conduce es el corazón que supo decir lo que desea',
        practice:
            'En esta práctica vas a pulir una intención importante. Primero, escribe tres versiones diferentes de la misma intención en papel. Después, revisa cada una eliminando negaciones, promesas para un futuro lejano y deseos sobre otras personas. Por último, lee las tres en voz alta y elige la que suene más viva en tu cuerpo. El objetivo es entrenar la claridad que sostiene toda la magia blanca: una frase específica, tuya y dicha en presente',
        pageTitle: 'Mi Intención de Luz',
        pagePurpose: 'Formular y consagrar una intención clara',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['1 vela blanca', 'Papel y bolígrafo'],
        pagePrompts: [
          'La versión final de mi intención (clara, mía, en presente):',
          '¿Por qué esta intención me importa ahora?',
          '¿Cómo sabré que se ha realizado?',
          '¿Qué sentí al leerla en voz alta frente a la vela?',
        ],
      ),
      TrailLesson(
        id: 'mb_02',
        title: 'El círculo de protección',
        teaching:
            'El círculo es la tecnología más antigua de la magia: un límite simbólico que separa el espacio sagrado de lo cotidiano. Importa porque la mente necesita fronteras para cambiar de estado — al trazar el círculo, te avisas a ti misma que allí dentro, en ese momento, todo es diferente. Es el marco que protege y concentra cualquier trabajo de magia blanca\n\nTradiciones de todo el mundo trazan círculos: con sal, tiza, cordón, el dedo apuntado o pura visualización. El material importa menos que el gesto consciente. En muchos linajes se camina en el sentido del sol para abrir y en sentido contrario para deshacer. Y lo que se abre, se cierra: terminar el círculo agradeciendo es tan importante como trazarlo, pues devuelve el espacio a lo cotidiano sin dejar puertas abiertas\n\nEn el día a día, la principiante puede trazar un círculo antes de meditar, escribir en el grimorio o encender una vela. No necesitas mucho espacio: un círculo imaginado alrededor de la silla ya funciona. Errores comunes: salir del círculo en medio del trabajo sin necesidad y olvidar deshacerlo al final. Comienza con lo simple, con sal o visualización, y repite hasta que el gesto se vuelva memoria del cuerpo\n\nGuarda esta llave: el círculo es un gesto de conciencia, no de material. Donde trazas un límite con presencia, nace un espacio sagrado — y donde lo deshaces con gratitud, lo cotidiano regresa en paz. Abrir y cerrar, siempre en ese orden: ese es el ritmo silencioso de toda protección bien hecha',
        practice:
            'En esta práctica vas a crear tu primer espacio sagrado. Primero, traza un círculo a tu alrededor — con sal, un gesto o pura visualización. Después, permanece tres minutos en silencio dentro de él, solo percibiendo la diferencia en el aire y en el cuerpo. Por último, deshaz el círculo con conciencia, agradeciendo. El objetivo es sentir en la piel que abrir y cerrar un límite cambia el estado interno — la base de toda protección mágica',
        pageTitle: 'Mi Círculo de Protección',
        pagePurpose: 'Crear y deshacer un espacio sagrado',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Sal gruesa (opcional)', 'Vela blanca (opcional)'],
        pagePrompts: [
          'Cómo trazo mi círculo (material o visualización):',
          'Mis palabras al abrir:',
          'Mis palabras al cerrar:',
          'La diferencia que sentí entre dentro y fuera:',
        ],
      ),
      TrailLesson(
        id: 'mb_03',
        title: 'Bendiciones: magia para los demás',
        teaching:
            'La bendición es la forma más generosa de la magia blanca: desear activamente el bien de alguien sin controlar el camino de nadie. Importa porque cambia la dirección de la práctica — en lugar de pedir para ti, irradias hacia afuera. Bendecir entrena al corazón en la abundancia y recuerda que la magia también es servicio, no solo conquista personal\n\nLa estructura clásica de la bendición tiene tres pasos: nombrar a quien recibe, declarar el bien deseado y sellar con un gesto — las manos sobre el corazón, un soplo, un toque en el agua. Culturas enteras se organizaron en torno a bendiciones: sobre alimentos, casas, viajes y nacimientos. La regla de oro las atraviesa a todas: bendice sin esperar retorno y jamás para influir en decisiones ajenas — eso ya sería otra cosa\n\nEn lo cotidiano, la bendición cabe en cualquier lugar: un buen pensamiento al cruzarte con un vecino, una palabra silenciosa sobre la comida, un deseo de paz al entrar en casa. El error más común de la principiante es disfrazar de bendición un pedido de control — desear que alguien tome cierta decisión, por ejemplo. Bendice a la persona como es hoy, no como te gustaría que fuera\n\nLleva esta idea en el bolsillo: bendecir es desear el bien y soltar el resultado. Cuando bendices sin controlar, la energía fluye limpia y regresa en forma de ligereza. Un corazón que bendice todos los días nunca practica magia pequeña — transforma cada encuentro en un altar discreto',
        practice:
            'En esta práctica harás tu primera bendición consciente. Primero, elige a alguien querido y trae su rostro a la mente. Después, durante un minuto entero, desea su bien en silencio — exactamente como es hoy, sin corregir nada, sin pedir cambios. Por último, sella con un gesto simple, como la mano sobre el corazón. El objetivo es experimentar la magia que fluye hacia afuera: desear el bien sin controlar el camino de nadie',
        pageTitle: 'Bendición de Mi Casa',
        pagePurpose: 'Bendecir el hogar y a quienes viven en él',
        pageCategory: SpellCategory.home,
        pageIngredients: ['1 vaso de agua limpia', 'Vela blanca'],
        pagePrompts: [
          'La bendición que creé para mi hogar:',
          'El gesto que sella mi bendición:',
          'Habitación por habitación: ¿dónde sentí cambiar la energía?',
          '¿Qué sentí al bendecir en lugar de pedir?',
        ],
      ),
      TrailLesson(
        id: 'mb_04',
        tool: LessonTool.addColor,
        title: 'La vela: llama y foco',
        teaching:
            'La vela es el altar portátil de la magia blanca: fuego que concentra la intención en un único punto de luz. Importa porque reúne mucho poder en un objeto simple — la cera que viene de la tierra, la mecha que respira el aire y la llama que transforma. Pocas herramientas ofrecen tanto foco con tan poco, y por eso la vela suele ser la primera compañera de la bruja\n\nCada detalle conversa con el objetivo. El color de la vela dialoga con la intención — consulta la Enciclopedia de Colores para elegir con conciencia. Ungir la vela con aceite es vestirla para el trabajo, y grabar símbolos en la cera inscribe el pedido en la materia antes de entregarlo a la llama. Existen tradiciones de velas en casi toda práctica devocional: la llama siempre fue vista como mensajera entre mundos\n\nPara la principiante, la vela es el ritual más accesible: encender con intención clara, observar la llama, apagar con gratitud. Errores comunes: la prisa por pedir sin preparar la intención y el descuido con el fuego. La seguridad es parte del ritual: una vela encendida nunca se queda sola, siempre lejos de cortinas y sobre una superficie firme. Comienza con la vela blanca, que sirve a todo propósito luminoso\n\nMemoriza esta llave: la llama es tu foco hecho visible. Cuando enciendes una vela con presencia, ella sostiene la intención mientras arde. Cuida del fuego como cuidas del deseo — con atención, respeto y constancia — y la vela será siempre un altar completo que cabe en la palma de la mano',
        practice:
            'En esta práctica vas a entrenar la presencia frente al fuego. Primero, prepara un lugar seguro y enciende una vela blanca. Después, durante diez minutos, solo observa la llama — el movimiento, el color, la danza — sin pedir absolutamente nada. Por último, apágala con gratitud o déjala consumirse con seguridad. El objetivo es construir intimidad con la herramienta antes de usarla: quien sabe contemplar la llama aprende a enfocar su propia intención. Aprovecha para registrar el color elegido: fotografíalo con el atajo de abajo y crea su entrada en tu enciclopedia de Colores',
        pageTitle: 'Mi Ritual de Vela',
        pagePurpose: 'Estructurar mi trabajo con velas',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Vela del color elegido', 'Aceite (opcional)', 'Palillo para grabar'],
        pagePrompts: [
          'Color elegido y el porqué (¿consulté la Enciclopedia?):',
          'Cómo preparo la vela (unción, símbolos):',
          'Lo que la llama me "dijo" en los 10 minutos de observación:',
          'Mis reglas personales de seguridad:',
        ],
      ),
      TrailLesson(
        id: 'mb_05',
        title: 'Agua lustral: limpieza que consagra',
        teaching:
            'Agua y sal forman la combinación de purificación más antigua que la humanidad conoce. El agua lustral es la versión consagrada de esa dupla: un preparado simple que limpia objetos, espacios y tu propia energía antes de los trabajos. Importa porque toda magia pide terreno limpio — trabajar en un ambiente cargado es como plantar en suelo cansado\n\nLa preparación es un ritual en sí misma: agua limpia, una pizca de sal, las manos posadas sobre el recipiente y una palabra de consagración dicha con presencia. Los templos antiguos mantenían vasijas de agua en la entrada para purificar a quien llegaba — la lógica es la misma. La sal deshace y el agua transporta: juntas disuelven lo que pesa y se llevan lo que ya no sirve\n\nEn lo cotidiano, el agua lustral aparece rociada por los rincones de la casa, ungiendo la frente y las muñecas antes de un ritual o lavando herramientas recién llegadas. Guárdala en un recipiente bonito y renuévala con frecuencia — el agua estancada durante muchas semanas pierde su frescura. Dos cuidados esenciales: nunca bebas el agua lustral y no te saltes la consagración, pues sin la palabra es solo agua con sal\n\nLa llave de esta lección: limpiar es preparar. Antes de pedir, purifica; antes de plantar, cuida el suelo. Una bruja que mantiene viva su agua lustral mantiene también el hábito más importante de la práctica — comenzar cada trabajo en terreno claro, ligero y listo para recibir',
        practice:
            'En esta práctica vas a preparar tu primera agua lustral. Primero, elige un recipiente bonito, llénalo con agua limpia y añade una pizca de sal. Después, posa las manos sobre él y di una palabra de consagración con presencia. Por último, usa esa agua para limpiar un objeto que utilizas todos los días, pasando algunas gotas con intención. El objetivo es sentir cómo la purificación prepara el terreno para toda magia',
        pageTitle: 'Mi Agua Lustral',
        pagePurpose: 'Preparar y usar agua de limpieza',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Agua limpia', 'Sal', 'Recipiente bonito'],
        pagePrompts: [
          'Mis palabras de consagración del agua:',
          'El objeto que limpié primero y por qué:',
          'Dónde guardo mi agua lustral:',
          'Cuándo pienso renovarla:',
        ],
      ),
      TrailLesson(
        id: 'mb_06',
        title: 'Escudos: protección en el día a día',
        teaching:
            'No todos los días hay altar — pero todos los días hay mundo. El escudo energético es la protección portátil de la bruja: una barrera invisible creada por la imaginación entrenada, que filtra lo que llega de afuera. Importa porque la sensibilidad que la práctica despierta también pide defensa — quien siente más necesita aprender a resguardarse más\n\nEl escudo funciona por visualización repetida: una esfera de luz alrededor del cuerpo, un manto que envuelve, espejos que devuelven lo que no es tuyo. Cada tradición tiene su imagen preferida, pero el principio es el mismo — la mente entrenada crea fronteras energéticas reales para quien las habita. El gesto disparador, discreto y siempre igual, es el interruptor que lo activa todo en segundos\n\nEn lo cotidiano, el escudo aparece antes de salir de casa, en reuniones tensas, en el transporte lleno. El secreto es el entrenamiento: el escudo se construye en casa, con calma y repetición, para funcionar en el autobús repleto. El error clásico de la principiante es intentar crear la protección por primera vez en medio de la crisis — sin entrenamiento previo, la imagen no se sostiene. Practica un poco todos los días\n\nGraba esta idea: la protección es hábito, no emergencia. Unos minutos diarios de visualización crean un escudo que responde a tu gesto en cualquier lugar. La bruja protegida no es la que nunca encuentra peso en el mundo — es la que sabe volver rápido a su propia luz',
        practice:
            'En esta práctica vas a construir tu escudo personal. Primero, siéntate en un lugar tranquilo y visualiza durante cinco minutos una esfera de luz envolviendo todo tu cuerpo — percibe el color, el brillo, la textura. Después, elige un gesto discreto, como tocar un anillo o cruzar los dedos, y repítelo mientras la imagen está viva. El objetivo es asociar gesto y escudo, creando un disparador que activa tu protección en segundos, estés donde estés',
        pageTitle: 'Mi Escudo Diario',
        pagePurpose: 'Crear mi protección portátil',
        pageCategory: SpellCategory.protection,
        pagePrompts: [
          'Cómo es mi escudo (forma, color, textura):',
          'Mi gesto disparador:',
          'Situaciones en las que más lo necesito:',
          'Primera vez que lo usé "en campo" — ¿funcionó?',
        ],
      ),
      TrailLesson(
        id: 'mb_07',
        title: 'Sanarse a una misma: el baño ritual',
        teaching:
            'El baño ritual transforma el acto más cotidiano en rito de sanación: agua tibia, hierbas o sal, luz baja e intención. Importa porque une el cuerpo a la magia — la piel siente, el vapor envuelve y la mente entiende, sin esfuerzo, que algo se está lavando también por dentro. Es la sanación más accesible de la magia blanca: ya te bañas todos los días\n\nLa tradición distingue direcciones: del cuello hacia abajo, el baño limpia y descarga, preservando la cabeza, centro de la conciencia; de la cabeza hacia abajo, solo con hierbas suaves, renueva por completo. Los baños de hierbas atraviesan culturas — de las casas de sanación a las aldeas antiguas — siempre con la misma gramática: preparar con intención, verter con presencia, dejar que el cuerpo se seque naturalmente cuando sea posible\n\nEn la rutina de la principiante, el baño ritual puede cerrar la semana o preceder trabajos importantes. Prepara todo antes: hierba o sal, vela encendida en un lugar seguro del baño, celular lejos. Errores comunes: la prisa, el baño en piloto automático y las hierbas demasiado fuertes sin conocimiento. Comienza con lo simple — sal gruesa o manzanilla — y crece poco a poco, anotando lo que funciona\n\nLleva esta llave: lo esencial es salir del baño diferente de como entraste — y nombrar esa diferencia. El agua que corre se lleva lo que pesa; la intención que guía llama a lo que renueva. Con presencia, tu ducha puede convertirse en el templo más fiel y constante de toda tu práctica',
        practice:
            'En esta práctica vas a transformar el baño de hoy en ritual. Primero, deja el celular fuera del baño y, si quieres, enciende una vela en un lugar seguro. Después, báñate sin prisa alguna, visualizando el agua llevándose todo lo que pesa — preocupaciones, cansancio, restos del día. Por último, al cerrar la ducha, respira hondo y nombra en silencio cómo te sientes. El objetivo es experimentar la sanación más simple que existe: agua, presencia e intención',
        pageTitle: 'Mi Baño de Sanación',
        pagePurpose: 'Crear mi receta de baño ritual',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Hierbas suaves o sal gruesa', 'Vela para el baño'],
        pagePrompts: [
          'Mi receta (hierbas/sal, preparación):',
          'Lo que el agua se lleva:',
          'Lo que llamo hacia mí al final:',
          'Cómo me sentí después:',
        ],
      ),
      TrailLesson(
        id: 'mb_08',
        tool: LessonTool.addCrystal,
        title: 'Amuletos de luz',
        teaching:
            'El amuleto es intención condensada en materia: un objeto pequeño, consagrado a un único propósito y llevado junto al cuerpo. Importa porque extiende la magia más allá del ritual — mientras vives tu día, el amuleto sigue trabajando en silencio, recordándole a tu energía lo que se acordó frente al altar\n\nEn la magia blanca, los clásicos son amuletos de protección — el ojo, la sal, la ruda — y de bendición, como medallas y piedras claras. La consagración sigue cuatro pasos simples: limpiar el objeto, declarar su propósito en voz alta, energizarlo bajo la luz de la luna, cerca de una llama o con el propio soplo, y llevarlo con fe. Pueblos de todas las épocas cargaron amuletos: llevar la protección consigo es un deseo tan antiguo como el camino\n\nPara la principiante, el mejor amuleto suele ser un objeto que ya tiene historia contigo — un anillo heredado, una piedra encontrada, una medalla querida. Errores comunes: acumular varios propósitos en un mismo objeto, lo que diluye la fuerza, y olvidar limpiarlo de vez en cuando. Un propósito por amuleto y una limpieza ocasional, y servirá por años\n\nLa idea para guardar: el amuleto es un pacto silencioso entre tú y un objeto. Consagra con claridad, lleva con fe y renueva con cuidado, y él responderá con constancia. Así, incluso en los días sin altar y sin vela, un pedazo de tu magia camina junto a tu cuerpo, vayas donde vayas',
        practice:
            'En esta práctica vas a elegir tu primer amuleto de luz. Primero, mira a tu alrededor y encuentra un objeto pequeño que ya ames y que tenga historia contigo. Después, sostenlo en las manos y pregúntate en silencio qué propósito único va a servir — protección o bendición. Por último, guárdalo en un lugar especial hasta registrar la consagración en tu página. El objetivo es entender que el poder del amuleto nace del vínculo: un objeto, un propósito, una fe. Si tu amuleto es una piedra, fotografíala con el atajo de abajo y crea su entrada en tu enciclopedia de Cristales',
        pageTitle: 'Mi Amuleto de Luz',
        pagePurpose: 'Consagrar un amuleto personal',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['El objeto elegido'],
        pagePrompts: [
          'Mi objeto y su historia conmigo:',
          'Su propósito único:',
          'Cómo lo consagré (limpieza, palabras, energización):',
          'Dónde vive (bolsillo, cadena, bolso):',
        ],
      ),
      TrailLesson(
        id: 'mb_09',
        title: 'Magia para momentos difíciles',
        teaching:
            'La magia blanca brilla en los días oscuros: un velorio, un diagnóstico, una ruptura. En esos momentos no resuelve — acompaña. Y eso importa porque la práctica que solo sirve para los días buenos abandona a la bruja exactamente cuando más la necesita. Un rito de travesía da suelo cuando el suelo parece faltar bajo los pies\n\nEl ritual mínimo para atravesar tiene cuatro gestos: encender una llama, nombrar el dolor en voz alta, pedir fuerza — no solución — y agradecer por estar viva para sentir. Los ritos de paso existen en toda cultura humana justamente porque el dolor necesita forma: cuando gana nombre, vela y palabra, deja de ser un mar sin orilla y se convierte en un río que se puede cruzar\n\nEn lo cotidiano, esto significa tener tu rito listo antes de la tormenta: tres pasos simples que el cuerpo conoce de memoria. El error más común es exigirle a la magia lo que no promete — borrar el dolor, traer a alguien de vuelta, cambiar el diagnóstico. Si el dolor es demasiado grande, busca también apoyo humano y profesional: la magia madura camina junto al cuidado, nunca en su lugar\n\nGuarda esta sabiduría: la magia madura sabe la diferencia entre transformar y aceptar. En los días oscuros, enciende la llama, nombra el dolor y pide fuerza para atravesar. No necesitas vencer la noche entera de una vez — solo necesitas luz suficiente para dar el siguiente paso',
        practice:
            'En esta práctica vas a experimentar un rito de travesía. Primero, piensa en un dolor actual o antiguo que aún merezca acogida. Después, enciende una vela blanca en un lugar seguro y, mirando la llama, di en voz alta: te veo, te atravieso, pido fuerza. Por último, quédate unos instantes en silencio y agradece por estar viva para sentir. El objetivo es darle forma al dolor con nombre, llama y palabra, pidiendo fuerza en lugar de solución',
        pageTitle: 'Ritual para Días Oscuros',
        pagePurpose: 'Crear mi rito de travesía',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Vela blanca'],
        pagePrompts: [
          'Mi rito mínimo para días difíciles (3 pasos):',
          'Las palabras que me dan suelo:',
          'A quién/a qué le pido fuerza:',
          'Lo que este rito NO promete (y está bien así):',
        ],
      ),
      TrailLesson(
        id: 'mb_10',
        recordKind: LessonRecordKind.gratitude,
        title: 'Cerrar con gratitud',
        teaching:
            'Todo trabajo de magia blanca termina en el mismo lugar: la gratitud. Agradecer cierra el circuito de la energía, reconociendo lo recibido incluso antes de ver resultados. Importa porque un final bien hecho protege el trabajo entero — un ritual sin cierre es una puerta entreabierta, y la gratitud es la llave que gira suave en la cerradura\n\nLa gratitud es también la protección más subestimada de la práctica: un corazón agradecido no opera desde la carencia, y la magia hecha desde la falta tiende a atraer más falta. Tradiciones de todo el mundo cierran sus ritos agradeciendo — a las fuerzas invocadas, al espacio, al propio cuerpo. El agradecimiento devuelve cada cosa a su lugar y sella lo que se hizo, como quien firma una carta antes de enviarla\n\nEn lo cotidiano, el cierre se vuelve una firma personal: un gesto siempre igual, una frase corta de gratitud, un soplo a la vela. Repetido al final de cada trabajo, le enseña al cuerpo que el rito terminó. El error común es salir corriendo del altar apenas se hace el pedido — dedícale al final el mismo cariño que le dedicaste al comienzo. En esta última página, creas tu ritual de cierre\n\nLleva contigo la última llave de esta senda: la gratitud es comienzo y fin de toda magia blanca. Agradece antes de ver, agradece después de recibir, agradece incluso en los días en que solo hubo travesía. Quien cierra con gratitud nunca sale de un ritual con las manos vacías — esa es tu firma mágica',
        practice:
            'En esta práctica vas a cerrar la senda como quien cierra una ceremonia. Primero, respira hondo y mira hacia atrás, recordando las lecciones que atravesaste. Después, haz una lista de cinco cosas que tu práctica ya trajo a tu vida — pequeñas o grandes, todas cuentan. Por último, lee la lista en voz alta, despacio, como las palabras finales de un rito. El objetivo es cerrar el circuito de la energía con gratitud, sellando todo lo que construiste hasta aquí',
        pageTitle: 'Mi Ritual de Cierre',
        pagePurpose: 'Sellar trabajos con gratitud',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Mi gesto de cierre:',
          'Mis palabras de gratitud:',
          'Las 5 cosas que la práctica ya me trajo:',
          'Releyendo esta senda: ¿qué se volvió "mi manera"?',
        ],
      ),
    ],
  );
