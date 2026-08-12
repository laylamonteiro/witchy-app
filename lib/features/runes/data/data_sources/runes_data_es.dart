import '../models/rune_model.dart';

/// Las 24 runas del Futhark Antiguo — contenido en español.
///
/// Nombres y símbolos son invariantes entre idiomas; solo palabras clave y
/// descripciones se traducen. Mantén el mismo orden que
/// `runes_data_pt.dart` — la paridad se verifica en
/// `test/content_parity_test.dart`.
const List<Rune> runesEs = [
  Rune(
    name: 'Fehu',
    symbol: 'ᚠ',
    keywords: ['Prosperidad', 'Riqueza', 'Abundancia'],
    description: 'Fehu es el ganado: la riqueza que camina, se cuenta por '
        'cabezas y se gasta. En el mundo nórdico, quien tenía rebaño tenía '
        'sustento, y de esa riqueza concreta y móvil habla la runa, no de '
        'fortuna abstracta. En una lectura, señala recursos que llegan o '
        'que ya están disponibles: dinero, tiempo, energía pidiendo uso. '
        'Pregúntate dónde tu riqueza está circulando y dónde solo se '
        'acumula. El aviso de Fehu es antiguo: los poemas rúnicos dicen '
        'que el oro causa discordia entre parientes — la riqueza quieta, '
        'o mal repartida, se pudre',
  ),
  Rune(
    name: 'Uruz',
    symbol: 'ᚢ',
    keywords: ['Fuerza', 'Vitalidad', 'Salud'],
    description:
        'Uruz es el uro, el buey salvaje gigante que vagaba por los '
        'bosques de Europa hasta ser cazado a la extinción. Cazarlo era '
        'rito de paso: el joven probaba su propia fuerza ante una fiera '
        'que no se dejaba domar. En una lectura, Uruz dice que la '
        'situación pide vigor y que tienes más fuerza de la que crees — '
        'incluida la fuerza de recuperación, por eso es también runa de '
        'salud. Enfrenta el desafío de frente y cuida el cuerpo, que '
        'sostiene todo lo demás. La sombra: la fuerza bruta sin dirección '
        'hiere a quien la carga — dale un blanco a la tuya antes de '
        'usarla',
  ),
  Rune(
    name: 'Thurisaz',
    symbol: 'ᚦ',
    keywords: ['Protección', 'Defensa', 'Desafío'],
    description:
        'Thurisaz es la espina y también el gigante, la fuerza bruta del '
        'caos; la tradición la vincula al martillo de Thor, que mantenía '
        'a los gigantes a distancia. El poema anglosajón advierte: la '
        'espina es cruelmente afilada para quien la agarra. En una '
        'lectura, señala conflicto, amenaza o fricción — y tu poder de '
        'responder a ellos. Antes de actuar, detente: la runa pide una '
        'defensa pensada, como un cerco de espinos, no un ataque. Su '
        'sombra es la impulsividad — la fuerza que, usada con rabia, se '
        'corta la propia mano',
  ),
  Rune(
    name: 'Ansuz',
    symbol: 'ᚨ',
    keywords: ['Comunicación', 'Sabiduría', 'Inspiración'],
    description:
        'Ansuz es la runa del dios — de Odín, que se colgó del árbol del '
        'mundo para conquistar las runas — y significa boca, soplo, '
        'palabra dicha. Es la runa de la comunicación que lleva '
        'sabiduría: el consejo, la poesía, el mensaje justo. En una '
        'lectura, indica que una información importante está en camino o '
        'que una conversación puede destrabar la situación. Escucha con '
        'atención, busca a quien sabe más y di con claridad lo que debe '
        'ser dicho. Solo verifica la fuente: las palabras también '
        'engañan, y no toda voz que suena sabia lo es',
  ),
  Rune(
    name: 'Raidho',
    symbol: 'ᚱ',
    keywords: ['Viaje', 'Movimiento', 'Progreso'],
    description:
        'Raidho es la cabalgata: el viaje largo a caballo, con ruta, '
        'ritmo y desgaste. El poema rúnico noruego recuerda que cabalgar '
        'es fácil de decir y duro para el caballo — todo camino tiene un '
        'costo real. En una lectura, indica movimiento con dirección: un '
        'viaje literal, un proceso en marcha, la hora de ponerse en '
        'camino. Planifica la ruta, mantén un ritmo constante y no te '
        'saltes etapas — es el camino entero el que transforma, no solo '
        'la llegada. Si todo parece trabado, Raidho sugiere que falta '
        'movimiento, no suerte',
  ),
  Rune(
    name: 'Kenaz',
    symbol: 'ᚲ',
    keywords: ['Conocimiento', 'Creatividad', 'Iluminación'],
    description:
        'Kenaz es la antorcha: el fuego de pino que iluminaba salones y '
        'talleres — luz de trabajo, no incendio. Es la runa del oficio y '
        'del conocimiento que se domina con las manos. En una lectura, '
        'anuncia una revelación, una solución que se hace visible o una '
        'habilidad lista para desarrollarse. Estudia, practica e ilumina '
        'un rincón a la vez, en vez de intentar encenderlo todo. Recuerda '
        'que la antorcha pide mano firme: el fuego creativo sin cuidado '
        'quema, incluso en forma de entusiasmo que consume sin construir',
  ),
  Rune(
    name: 'Gebo',
    symbol: 'ᚷ',
    keywords: ['Regalo', 'Alianza', 'Intercambio'],
    description:
        'Gebo es el don. Entre los pueblos germánicos, un regalo nunca '
        'era solo un regalo: creaba un vínculo de honor entre quien daba '
        'y quien recibía, y un regalo pedía otro. En una lectura, habla '
        'de intercambios, alianzas y de la generosidad que une — una '
        'relación, un acuerdo, una oferta en juego. Observa el '
        'equilibrio: ¿estás dando y recibiendo en la misma medida? '
        'Retribuye lo que recibiste y pide reciprocidad sin culpa. La '
        'sombra de Gebo es el intercambio desigual, que convierte el '
        'regalo en deuda y el vínculo en dependencia',
  ),
  Rune(
    name: 'Wunjo',
    symbol: 'ᚹ',
    keywords: ['Alegría', 'Armonía', 'Plenitud'],
    description:
        'Wunjo es la alegría — y, para el poema anglosajón, tiene alegría '
        'quien conoce poca privación y no le faltan sustento ni '
        'comunidad. No es euforia: es el bienestar concreto de pertenecer '
        'y de tener lo suficiente. En una lectura, indica una fase en que '
        'las piezas encajan — armonía en casa, en el grupo, en el '
        'trabajo. Celebra y comparte: la alegría guardada solo para ti se '
        'marchita. Cuidado únicamente con fingir armonía, escondiendo lo '
        'que necesita conversarse',
  ),
  Rune(
    name: 'Hagalaz',
    symbol: 'ᚺ',
    keywords: ['Disrupción', 'Cambio', 'Purificación'],
    description: 'Hagalaz es el granizo: el grano de hielo que cae del '
        'cielo sin aviso, destruye la cosecha y luego se derrite, '
        'volviéndose agua que riega el campo. Los poemas rúnicos lo '
        'llaman el más frío de los granos. En una lectura, indica '
        'disrupción fuera de tu control — planes deshechos, un giro '
        'brusco. No luches contra la tormenta: protege lo esencial, '
        'espera a que el granizo se derrita y mira qué fragilidad quedó '
        'al descubierto. El consuelo de la runa es real: lo que derriba '
        'ya no estaba firme, y el agua que queda alimenta el nuevo '
        'comienzo',
  ),
  Rune(
    name: 'Nauthiz',
    symbol: 'ᚾ',
    keywords: ['Necesidad', 'Resistencia', 'Superación'],
    description: 'Nauthiz es la necesidad, la carencia — y también el '
        'fuego de fricción, encendido con esfuerzo cuando todos los '
        'demás se apagaron. El poema rúnico dice que la necesidad '
        'oprime el pecho, pero puede llegar como aviso y lección a '
        'tiempo. En una lectura, indica escasez, retraso o voluntad '
        'contrariada: algo que quieres aún no es posible. Reduce a lo '
        'esencial, ten paciencia activa y haz lo posible con lo que '
        'tienes — así se enciende el fuego por fricción. Evita los dos '
        'extremos, negar la dificultad o desesperarte en ella: lo que '
        'falta ahora te está mostrando lo que de verdad importa',
  ),
  Rune(
    name: 'Isa',
    symbol: 'ᛁ',
    keywords: ['Pausa', 'Estancamiento', 'Introspección'],
    description:
        'Isa es el hielo: bello de ver, brillante como una joya, '
        'traicionero de pisar. En el invierno nórdico, el hielo detenía '
        'ríos y barcos — y, a veces, se volvía puente. En una lectura, '
        'indica una situación congelada: un enfriamiento, una espera, '
        'algo que no avanza. No fuerces el deshielo; usa la pausa para '
        'ver con la claridad fría que solo da la distancia. Pero mantente '
        'alerta: bajo el hielo la corriente sigue, y un estancamiento '
        'demasiado largo debe romperse con un primer paso pequeño',
  ),
  Rune(
    name: 'Jera',
    symbol: 'ᛃ',
    keywords: ['Cosecha', 'Ciclos', 'Recompensa'],
    description: 'Jera es el año y la cosecha: el ciclo agrícola '
        'completo, de la siembra al granero lleno. Los poemas rúnicos la '
        'celebran como la buena estación, cuando la tierra da su fruto. '
        'En una lectura, indica resultados que llegan a su debido '
        'tiempo — se cosecha lo que fue sembrado, ni antes ni después. '
        'Continúa el trabajo constante, respeta las estaciones del '
        'proceso y cosecha cuando esté maduro, no cuando lo mande la '
        'ansiedad. Jera no tiene atajos: si la cosecha es escasa, la '
        'runa apunta a lo que fue — o no fue — sembrado',
  ),
  Rune(
    name: 'Eihwaz',
    symbol: 'ᛇ',
    keywords: ['Protección', 'Resistencia', 'Transformación'],
    description:
        'Eihwaz es el tejo: árbol de vida larguísima, de madera flexible '
        'y veneno potente, con el que se hacían los mejores arcos — y '
        'que se plantaba junto a los muertos, uniendo los mundos. Muchos '
        'lo asocian con el propio Yggdrasil, el árbol que lo sostiene '
        'todo. En una lectura, indica una travesía difícil que '
        'transforma: un final que es pasaje, una resistencia que viene '
        'de la raíz. Arraígate en lo esencial y aguanta firme, '
        'doblándote sin quebrarte. Como el arco de tejo, la tensión que '
        'soportas ahora es la que dará fuerza al disparo después',
  ),
  Rune(
    name: 'Perthro',
    symbol: 'ᛈ',
    keywords: ['Misterio', 'Destino', 'Oculto'],
    description:
        'Perthro es el cubilete de dados: el poema anglosajón lo '
        'describe como juego y risa entre guerreros en el salón de '
        'cerveza. Es la runa de la suerte, del destino y de lo que aún '
        'está oculto. En una lectura, dice que hay factores en juego que '
        'no ves: un secreto, un resultado aún no decidido, el azar '
        'haciendo su parte. Haz bien tu jugada y suelta el control sobre '
        'el resto; observa lo que se va revelando poco a poco. El aviso '
        'es el de toda mesa de juego: no apuestes lo que no puedes '
        'perder',
  ),
  Rune(
    name: 'Algiz',
    symbol: 'ᛉ',
    keywords: ['Protección', 'Defensa', 'Conexión Divina'],
    description: 'Algiz es el alce — y el junco del alce, la hierba '
        'cortante de los pantanos que, dice el poema anglosajón, hiere a '
        'quien intenta agarrarla. Su trazo recuerda una mano abierta o '
        'cuernos erguidos: protección en estado de alerta. En una '
        'lectura, indica que estás bajo protección o que es hora de levantar '
        'defensas — muchas veces es tu instinto haciendo sonar la '
        'alarma. Escucha ese aviso interno y establece límites claros, '
        'que protegen sin necesidad de herir. La sombra: la defensa '
        'permanente se vuelve aislamiento, y no todo el mundo es una '
        'amenaza',
  ),
  Rune(
    name: 'Sowilo',
    symbol: 'ᛊ',
    keywords: ['Éxito', 'Vitalidad', 'Iluminación'],
    description: 'Sowilo es el sol — para el poema anglosajón, la '
        'esperanza de los navegantes, que se guían por él hasta el '
        'puerto. En un norte de inviernos largos, el sol no es metáfora: '
        'es victoria concreta. En una lectura, indica claridad, éxito y '
        'energía que vuelve — la dirección correcta se hace visible y el '
        'viento sopla a favor. Actúa mientras el cielo está despejado: '
        'el impulso favorable se aprovecha, no se guarda. Solo recuerda '
        'que el sol también expone lo que estaba en la sombra; deja que '
        'esa luz muestre la verdad sin miedo',
  ),
  Rune(
    name: 'Tiwaz',
    symbol: 'ᛏ',
    keywords: ['Justicia', 'Honor', 'Liderazgo'],
    description:
        'Tiwaz es la runa de Tyr, el dios que puso su propia mano en la '
        'boca del lobo Fenrir como garantía, para que los dioses '
        'pudieran encadenarlo — y la perdió, pagando el precio del '
        'pacto. Su trazo es una flecha: dirección firme y puntería. En '
        'una lectura, habla de una causa justa que pide coraje y cobra '
        'un costo — una decisión difícil, una palabra que debe '
        'mantenerse. Haz lo correcto aunque salga caro, y sostén lo que '
        'prometiste. Para Tiwaz, una victoria obtenida sin honor no es '
        'victoria',
  ),
  Rune(
    name: 'Berkano',
    symbol: 'ᛒ',
    keywords: ['Crecimiento', 'Fertilidad', 'Renovación'],
    description: 'Berkano es el abedul, el primer árbol en brotar cuando '
        'el hielo del invierno retrocede — símbolo antiguo de primavera, '
        'maternidad y renovación. En una lectura, indica un comienzo '
        'delicado: algo, o alguien, en fase de gestación, sanación o '
        'crecimiento lento que pide cuidado. Protege lo que es nuevo, '
        'aliméntalo con constancia y acepta el ritmo propio de lo que '
        'crece. La sombra de Berkano es el cuidado que asfixia: proteger '
        'demasiado también impide que el brote se vuelva árbol',
  ),
  Rune(
    name: 'Ehwaz',
    symbol: 'ᛖ',
    keywords: ['Alianza', 'Confianza', 'Movimiento'],
    description:
        'Ehwaz es el caballo — para el poema anglosajón, alegría de los '
        'nobles y consuelo para el inquieto. Pero la runa habla menos '
        'del animal y más del par caballo y jinete: dos seres que solo '
        'avanzan porque confían el uno en el otro. En una lectura, '
        'indica una alianza que funciona — matrimonio, sociedad, '
        'amistad, equipo — y un progreso construido de a dos. Invierte '
        'en la confianza, ajusta tu paso al del otro y verifica que '
        'quieren llegar al mismo lugar. Recuerda que la confianza se '
        'construye despacio y se pierde de un tirón',
  ),
  Rune(
    name: 'Mannaz',
    symbol: 'ᛗ',
    keywords: ['Humanidad', 'Autoconciencia', 'Comunidad'],
    description:
        'Mannaz es el ser humano. El poema anglosajón lo dice sin '
        'rodeos: cada persona es alegría para las demás, y aun así todos '
        'un día faltarán, porque la muerte a todos alcanza. Es la runa '
        'de la conciencia de ser gente — mortal, limitada y, aun así, '
        'ligada a los demás. En una lectura, pide una mirada honesta '
        'hacia ti y hacia tu lugar en la comunidad. Pide ayuda cuando la '
        'necesites, ofrécela cuando puedas y reconoce tus límites sin '
        'vergüenza. Nadie se basta en soledad — y eso no es debilidad, '
        'es la condición humana',
  ),
  Rune(
    name: 'Laguz',
    symbol: 'ᛚ',
    keywords: ['Agua', 'Intuición', 'Fluir'],
    description:
        'Laguz es el agua: el lago y el mar que los poemas describen '
        'como inmensos e impredecibles para quien navega. Es la runa de '
        'las profundidades — emociones, sueños, intuición, todo lo que '
        'corre bajo la superficie. En una lectura, indica una fase de '
        'sentir más que de entender: la respuesta no vendrá solo por la '
        'lógica. Escucha los sueños, confía en la intuición y nada con '
        'la corriente en vez de pelear contra ella. Solo respeta la '
        'profundidad: sumergirse en el sentimiento es distinto de '
        'ahogarse en él',
  ),
  Rune(
    name: 'Ingwaz',
    symbol: 'ᛜ',
    keywords: ['Fertilidad', 'Potencial', 'Gestación'],
    description:
        'Ingwaz es la runa de Ing, nombre antiguo de Freyr, dios de la '
        'fertilidad y de la paz — el poema anglosajón cuenta que fue '
        'visto primero entre los daneses, y que su carro recorría las '
        'tierras bendiciendo los campos. Su trazo cerrado recuerda una '
        'semilla: potencial completo, aún guardado. En una lectura, '
        'indica gestación — algo desarrollándose por dentro, casi listo, '
        'que aún no debe mostrarse. Guarda energía, termina en silencio '
        'y espera el momento justo de liberar lo que maduró. Ingwaz es '
        'buen presagio: promete conclusión, siempre que no la apresures',
  ),
  Rune(
    name: 'Dagaz',
    symbol: 'ᛞ',
    keywords: ['Día', 'Despertar', 'Transformación'],
    description:
        'Dagaz es el día — la luz que el poema anglosajón llama amada '
        'por todos, ricos y pobres. Es el instante exacto en que la '
        'noche se vuelve mañana: el punto de giro, no el mediodía. En '
        'una lectura, anuncia despertar y claridad súbita después de un '
        'período oscuro — un verdadero punto de inflexión. Recibe el '
        'nuevo comienzo de forma práctica: usa la luz nueva para hacer '
        'diferente lo que la oscuridad no dejaba ver. Si esperabas una '
        'señal para cambiar, Dagaz suele ser esa señal',
  ),
  Rune(
    name: 'Othala',
    symbol: 'ᛟ',
    keywords: ['Herencia', 'Hogar', 'Ancestros'],
    description: 'Othala es la propiedad heredada: la tierra de la '
        'familia, el solar que pasa de generación en generación y que no '
        'se compra — se recibe y se transmite. Es la runa de las raíces, '
        'del hogar y de la herencia, tanto material como invisible: '
        'nombre, valores, costumbres, patrones. En una lectura, señala '
        'cuestiones de familia, casa, pertenencia o algo recibido de '
        'quienes vinieron antes. Honra lo que hay de bueno en esa '
        'herencia y cuida tu suelo. Pero recuerda que la herencia también '
        'trae patrones repetidos — parte del trabajo es elegir lo que '
        'mantienes y lo que por fin dejas ir',
  ),
];
