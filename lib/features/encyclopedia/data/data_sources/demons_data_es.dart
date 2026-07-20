import '../models/arcane_entry_model.dart';

/// Demonios de la Enciclopedia — contenido en español.
///
/// Enfoque informativo e histórico: goecia, folclore, demonología literaria
/// y relecturas modernas, sin fomentar prácticas de daño. Los emojis son
/// invariantes; mantén el mismo orden en los tres archivos
/// (`demons_data_pt/en/es.dart`) — la paridad se verifica en
/// `test/content_parity_test.dart`.
const List<ArcaneEntry> demonsEs = [
  ArcaneEntry(
    name: 'Lilith',
    emoji: '🌒',
    summary: 'De la demonización a la reivindicación: la primera que dijo no',
    origin: 'Demonios del viento mesopotámicos; folclore judío medieval',
    history:
        'Lilith nace de los lilitu mesopotámicos y gana biografía en el Alfabeto de Ben Sirá: la primera mujer de Adán, que se negó a la sumisión y se marchó. Temida durante siglos en amuletos de protección, fue reivindicada en el siglo XX como icono de la autonomía femenina.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Folclórica',
        view:
            'Espíritu nocturno contra el que se usaban amuletos, especialmente para recién nacidos.',
      ),
      ArcanePerspective(
        tradition: 'Cabalística',
        view: 'Consorte del lado oscuro en las corrientes místicas medievales.',
      ),
      ArcanePerspective(
        tradition: 'Moderna/Feminista',
        view:
            'Símbolo del rechazo a la sumisión y de soberanía — presente en la astrología (Luna Negra) y en la brujería contemporánea.',
      ),
    ],
    characteristics: ['Independencia radical', 'Noche', 'Sexualidad soberana', 'Rechazo'],
    symbolism: [
      'La lechuza: visión nocturna',
      'La luna negra: lo femenino no domesticado',
      'El desierto: el territorio fuera de las reglas',
    ],
    correspondences: ['Luna Negra (astrología)', 'Obsidiana', 'Negro y vino'],
    studyPractices: [
      'Comparar el Alfabeto de Ben Sirá con las relecturas feministas',
      'Reflexionar: "¿dónde digo sí cuando quiero decir no?"',
    ],
    magicalUses: [
      'Trabajo de sombra sobre autonomía y límites',
      'Estudio de la Luna Negra en la carta astral',
    ],
    cautions:
        'Contenido histórico-informativo. Ninguna práctica aquí implica ni fomenta el daño a nadie.',
    related: ['La Reina Sombría (Arquetipos)', 'Luna Nueva'],
  ),
  ArcaneEntry(
    name: 'Asmodeo',
    emoji: '💍',
    summary: 'El demonio del Libro de Tobías y rey de los placeres en la goecia',
    origin: 'Aeshma-daeva persa; Libro de Tobías; goecia medieval',
    history:
        'Heredero del "demonio de la ira" persa, Asmodeo atormenta el matrimonio de Sara en el Libro de Tobías hasta ser alejado con la ayuda de Rafael. En la Goecia (Lemegeton) figura como un rey que enseña matemáticas y artesanía — ejemplo de la mezcla medieval de temor y fascinación erudita.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'El destructor de matrimonios vencido con ayuda angélica.',
      ),
      ArcanePerspective(
        tradition: 'Goética',
        view:
            'Uno de los 72 espíritus de Salomón: rey que enseña aritmética, astronomía y oficios.',
      ),
      ArcanePerspective(
        tradition: 'Folclórica',
        view: 'En las leyendas de Salomón, el genio que ayudó (a regañadientes) a construir el Templo.',
      ),
    ],
    characteristics: ['Deseo', 'Celos', 'Ingenio', 'Exceso'],
    symbolism: [
      'El anillo de Salomón: el saber que ordena las pasiones',
      'El humo del pez: el remedio inesperado',
    ],
    correspondences: ['Goecia (estudio)', 'Granate', 'Rojo oscuro'],
    studyPractices: [
      'Leer el Libro de Tobías y compararlo con el Lemegeton',
      'Reflexionar sobre los celos y el deseo como mensajeros, no dueños',
    ],
    magicalUses: [
      'Estudio histórico de los grimorios salomónicos',
      'Trabajo de sombra sobre la posesividad',
    ],
    cautions:
        'La goecia se presenta aquí como objeto de estudio histórico. No se enseña ni se fomenta ninguna práctica de daño.',
    related: ['Rafael (Ángeles)', 'Raziel (Ángeles)'],
  ),
  ArcaneEntry(
    name: 'Belcebú',
    emoji: '🪰',
    summary: 'El "Señor de las Moscas": de dios filisteo a príncipe de los demonios',
    origin: 'Baal-Zebub de Ecrón (2 Reyes); evangelios; demonología medieval',
    history:
        'Baal-Zebub era un dios filisteo consultado como oráculo. La tradición judía convirtió el nombre en escarnio ("señor de las moscas") y los evangelios lo citan como príncipe de los demonios — caso clásico de divinidad extranjera demonizada.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Histórica',
        view:
            'Ejemplo didáctico de cómo los dioses de pueblos rivales fueron convertidos en demonios.',
      ),
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'En los evangelios, el príncipe de los demonios en cuyo nombre acusaban a Jesús de actuar.',
      ),
      ArcanePerspective(
        tradition: 'Literaria',
        view:
            'De Milton a la novela "El señor de las moscas", símbolo de la decadencia y del caos social.',
      ),
    ],
    characteristics: ['Decadencia', 'Ruido', 'Poder corrompido'],
    symbolism: [
      'La mosca: lo que se acumula donde algo se pudre',
      'El trono caído: la autoridad que se degrada',
    ],
    correspondences: ['Estudio histórico', 'Gris y negro'],
    studyPractices: [
      'Investigar el proceso histórico de demonización de divinidades',
      'Reflexionar: "¿qué juicios heredé sin examinarlos?"',
    ],
    magicalUses: [
      'Ningún uso ritual propuesto — entrada de estudio histórico',
    ],
    cautions:
        'Contenido histórico-informativo. No se enseña ni se fomenta ninguna práctica de daño.',
    related: ['Lucifer', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Mefistófeles',
    emoji: '🎭',
    summary: 'El demonio del pacto: la creación literaria que definió un género',
    origin: 'Leyenda alemana de Fausto (siglo XVI); Marlowe y Goethe',
    history:
        'Mefistófeles no procede de una tradición religiosa: nace en la leyenda de Fausto y crece en manos de Marlowe y Goethe. Es el espíritu "que siempre niega" — irónico, culto, contractual — y moldeó para siempre la imagen del pacto demoníaco.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Literaria',
        view:
            'En Goethe, "parte de aquella fuerza que siempre quiere el mal y siempre crea el bien" — el adversario que nos pone en movimiento.',
      ),
      ArcanePerspective(
        tradition: 'Filosófica',
        view:
            'El espíritu de la negación y de la ironía: la duda que corroe o que despierta.',
      ),
    ],
    characteristics: ['Ironía', 'Contrato', 'Seducción intelectual', 'Negación'],
    symbolism: [
      'El pacto firmado: elecciones con precio',
      'El perro negro: la forma de la primera aparición',
      'El teatro: la máscara y el juego',
    ],
    correspondences: ['Literatura fáustica', 'Rojo y negro'],
    studyPractices: [
      'Leer el Fausto de Goethe (al menos la escena del pacto)',
      'Reflexionar: "¿qué atajos me saldrían demasiado caros?"',
    ],
    magicalUses: [
      'Ningún uso ritual propuesto — figura literaria para reflexionar sobre las elecciones',
    ],
    cautions:
        'Contenido histórico-literario. Ninguna práctica de pacto es real ni se fomenta.',
    related: ['La Alquimista (Arquetipos)', 'Lucifer'],
  ),
  ArcaneEntry(
    name: 'Pazuzu',
    emoji: '🌪️',
    summary: 'El demonio del viento asirio que protegía contra demonios',
    origin: 'Mesopotamia (siglos VIII-VII a. C.)',
    history:
        'Rey de los demonios del viento en Asiria, Pazuzu traía tormentas y plagas — y, paradójicamente, sus amuletos se usaban para alejar a la temible Lamashtu, protegiendo a embarazadas y bebés. El mal que guarda contra el mal.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Mesopotámica',
        view:
            'Entidad ambivalente: peligrosa por naturaleza, protectora por función apotropaica.',
      ),
      ArcanePerspective(
        tradition: 'Cultura pop',
        view:
            'Se hizo célebre (y distorsionado) por la película El exorcista, convirtiéndose en sinónimo de posesión.',
      ),
    ],
    characteristics: ['Ambivalencia', 'Viento y fiebre', 'Protección paradójica'],
    symbolism: [
      'La cabeza de amuleto: el terror domesticado en guardia',
      'El viento del suroeste: la fuerza que no se controla, se negocia',
    ],
    correspondences: ['Amuletos históricos', 'Bronce'],
    studyPractices: [
      'Estudiar amuletos apotropaicos (el mal contra el mal) en varias culturas',
      'Reflexionar sobre fuerzas propias "temidas" que en realidad protegen',
    ],
    magicalUses: [
      'Estudio del principio apotropaico en los amuletos',
    ],
    cautions:
        'Contenido histórico-informativo. No se enseña ni se fomenta ninguna práctica de daño.',
    related: ['La Guardiana (Arquetipos)', 'Querubines (Ángeles)'],
  ),
  ArcaneEntry(
    name: 'Baphomet',
    emoji: '🐐',
    summary: 'Del proceso de los templarios al símbolo ocultista del equilibrio',
    origin: 'Acusaciones contra los templarios (1307); dibujo de Eliphas Lévi (1856)',
    history:
        'El nombre surge en las confesiones forzadas de los templarios — probablemente una corrupción de "Mahoma". Siglos después, Eliphas Lévi dibujó el Macho Cabrío de Mendes: figura andrógina llena de opuestos reconciliados ("solve" y "coagula" en los brazos), que nada tiene de culto medieval real.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Histórica',
        view:
            'Un fantasma procesal: la "idolatría" que los inquisidores necesitaban encontrar.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'En Lévi, símbolo del equilibrio de los opuestos — materia y espíritu, masculino y femenino, arriba y abajo.',
      ),
      ArcanePerspective(
        tradition: 'Contemporánea',
        view:
            'Adoptado por corrientes satanistas laicas como emblema de antidogmatismo, ampliando aún más la distancia con el origen.',
      ),
    ],
    characteristics: ['Síntesis de opuestos', 'Malentendido histórico', 'Provocación'],
    symbolism: [
      'La antorcha entre los cuernos: la inteligencia por encima de la materia',
      'Solve et coagula: disolver y recomponer',
      'El andrógino: la totalidad',
    ],
    correspondences: ['Alquimia simbólica', 'Negro y plata'],
    studyPractices: [
      'Comparar las actas del proceso templario con el dibujo de Lévi',
      'Meditar sobre pares de opuestos que necesitas reconciliar',
    ],
    magicalUses: [
      'Contemplación alquímica de los opuestos internos',
    ],
    cautions:
        'Contenido histórico-informativo. Símbolo a menudo mal comprendido; estudia las fuentes.',
    related: ['La Alquimista (Arquetipos)', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Belial',
    emoji: '⛓️',
    summary: '"Sin valor": la personificación de la anomia en los textos antiguos',
    origin: 'Hebreo bíblico; Manuscritos del Mar Muerto; goecia',
    history:
        'En la Biblia hebrea, "hijos de Belial" designa a personas sin ley. En los Manuscritos del Mar Muerto, Belial lidera a los Hijos de las Tinieblas contra los Hijos de la Luz. En la Goecia es un rey poderoso que exige ofrendas — retrato del poder sin principios.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Bíblica',
        view: 'No un ser, sino un calificativo: la ausencia de valor y de ley.',
      ),
      ArcanePerspective(
        tradition: 'Qumrán',
        view: 'El príncipe de las tinieblas en el gran combate escatológico.',
      ),
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Rey que reparte favores y títulos — el arquetipo del poder corrupto.',
      ),
    ],
    characteristics: ['Anomia', 'Poder sin ética', 'Seducción del atajo'],
    symbolism: [
      'Las cadenas rotas: libertad sin responsabilidad',
      'El trono vacío: autoridad sin legitimidad',
    ],
    correspondences: ['Estudio de los Manuscritos del Mar Muerto'],
    studyPractices: [
      'Reflexionar sobre poder y ética: "¿qué poder quiero — y a qué precio?"',
    ],
    magicalUses: [
      'Ningún uso ritual propuesto — entrada de estudio histórico',
    ],
    cautions:
        'Contenido histórico-informativo. No se enseña ni se fomenta ninguna práctica de daño.',
    related: ['Lucifer', 'Mefistófeles'],
  ),
  ArcaneEntry(
    name: 'Mammón',
    emoji: '💰',
    summary: 'La riqueza personificada: cuando el dinero se vuelve amo',
    origin: 'Arameo mamona ("riqueza"); evangelios; Milton',
    history:
        '"No podéis servir a Dios y a Mammón": la palabra aramea para riqueza fue personificada por la tradición cristiana y, en Milton, se convirtió en el demonio que incluso en el cielo solo miraba el suelo dorado — la avaricia como rebajamiento de la mirada.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'La idolatría de la riqueza como rival directo de lo sagrado.',
      ),
      ArcanePerspective(
        tradition: 'Literaria',
        view:
            'En Milton, el constructor del Pandemónium: talento al servicio de la acumulación.',
      ),
    ],
    characteristics: ['Avaricia', 'Acumulación', 'Mirada baja'],
    symbolism: [
      'El oro en el suelo: el valor que hace inclinarse',
      'La balanza deshonesta: intercambio sin alma',
    ],
    correspondences: ['Reflexiones sobre la prosperidad', 'Dorado y gris'],
    studyPractices: [
      'Examinar tu relación con el dinero: ¿herramienta o amo?',
      'Contrastar con prácticas sanas de prosperidad (ver Grimorio)',
    ],
    magicalUses: [
      'Ningún uso ritual propuesto — espejo para la relación con la abundancia',
    ],
    cautions:
        'Contenido histórico-informativo. La prosperidad sana difiere de la avaricia.',
    related: ['Prosperidad y Caminos (Grimorio)', 'Belial'],
  ),
  ArcaneEntry(
    name: 'Leviatán',
    emoji: '🐉',
    summary: 'El monstruo del caos primordial que habita las profundidades',
    origin: 'Mitos cananeos (Lotan); Job, Salmos e Isaías',
    history:
        'Heredero del Lotan cananeo, el Leviatán es la serpiente marina del caos que solo lo divino domina. En Job se lo describe con asombro; Hobbes lo tomó como metáfora del Estado; la psicología moderna lo lee como el caos inconsciente.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Bíblica',
        view: 'El caos acuático sometido en la creación — fuerza que solo lo sagrado contiene.',
      ),
      ArcanePerspective(
        tradition: 'Filosófica',
        view: 'En Hobbes, el poder soberano que impide la guerra de todos contra todos.',
      ),
      ArcanePerspective(
        tradition: 'Simbólico-psicológica',
        view: 'Las profundidades del inconsciente: lo que emerge cuando el mar interior se agita.',
      ),
    ],
    characteristics: ['Caos primordial', 'Inmensidad', 'Lo indomable'],
    symbolism: [
      'El mar profundo: el inconsciente colectivo',
      'La serpiente enroscada: energía contenida',
      'La tormenta: emociones que desbordan',
    ],
    correspondences: ['Agua', 'Azul abisal', 'Sueños con el mar'],
    studyPractices: [
      'Leer Job 41 como poema del asombro ante lo incontrolable',
      'Registrar los sueños con mar/agua en el Diario de Sueños',
    ],
    magicalUses: [
      'Meditaciones para navegar las propias profundidades',
    ],
    cautions:
        'Contenido histórico-informativo. No se enseña ni se fomenta ninguna práctica de daño.',
    related: ['Agua (Temas Oníricos)', 'La Reina Sombría (Arquetipos)'],
  ),
  ArcaneEntry(
    name: 'Astaroth',
    emoji: '👑',
    summary: 'El gran duque de la Goecia, eco demonizado de la diosa Astarté',
    origin: 'Goecia (Lemegeton); derivado de Astarté/Ishtar',
    history:
        'En los grimorios, Astaroth es un gran duque que enseña ciencias y revela secretos del pasado y del futuro. El nombre desciende de Astarté, gran diosa del Próximo Oriente — un caso clásico de divinidad antigua demonizada por la tradición posterior.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Duque que enseña artes liberales y responde sobre cosas ocultas.',
      ),
      ArcanePerspective(
        tradition: 'Histórica',
        view: 'La memoria de Astarté/Ishtar transformada en demonio: el rebajamiento de las diosas.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista moderna',
        view: 'Símbolo del saber prohibido y del rescate de lo femenino divino borrado.',
      ),
    ],
    characteristics: ['Conocimiento oculto', 'Memoria ancestral', 'Elocuencia', 'Pasado revelado'],
    symbolism: [
      'La serpiente en la mano: el saber que asusta',
      'La corona ducal: nobleza caída',
      'La estrella de ocho puntas: herencia de Ishtar',
    ],
    correspondences: ['Venus (herencia de Astarté)', 'Miércoles en los grimorios', 'Verde profundo'],
    studyPractices: [
      'Comparar a Astarté en los textos ugaríticos con el Astaroth goético',
      'Reflexionar: ¿qué saberes ya fueron llamados prohibidos?',
    ],
    magicalUses: [
      'Estudio simbólico de la demonización de divinidades femeninas',
      'Contemplación sobre rescatar saberes borrados',
    ],
    cautions:
        'Contenido histórico-informativo sobre grimorios. Ninguna práctica aquí implica ni fomenta el daño.',
    related: ['Diosas', 'La Sabia (Arquetipos)'],
  ),
  ArcaneEntry(
    name: 'Paimon',
    emoji: '🐪',
    summary: 'El rey obediente de la Goecia, maestro de las artes y las ciencias',
    origin: 'Goecia (Lemegeton), uno de los reyes del Oeste',
    history:
        'Descrito como un rey que llega con gran estruendo, montado en un dromedario y precedido por músicos, Paimon enseña todas las artes, ciencias y secretos. Los grimorios lo cuentan entre los espíritus más obedientes al exorcista — y el cine reciente lo devolvió a la cultura popular.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Rey que enseña filosofía, artes y los secretos de la mente.',
      ),
      ArcanePerspective(
        tradition: 'Histórica',
        view: 'Posible eco de espíritus preislámicos del desierto incorporados a los grimorios europeos.',
      ),
      ArcanePerspective(
        tradition: 'Cultura pop',
        view: 'Reintroducido por el terror contemporáneo como símbolo de influencia oculta.',
      ),
    ],
    characteristics: ['Maestría', 'Conocimiento de las mentes', 'Ceremonia', 'Vínculo y lealtad'],
    symbolism: [
      'El dromedario: la travesía paciente del desierto',
      'La música que lo precede: el poder que se anuncia',
      'La corona del Oeste: dominio sobre el atardecer',
    ],
    correspondences: ['Oeste', 'Música ceremonial', 'Azul noche y oro'],
    studyPractices: [
      'Leer la descripción de Paimon en el Lemegeton en contexto histórico',
      'Estudiar cómo el cine resignifica figuras goéticas',
    ],
    magicalUses: [
      'Estudio simbólico de la maestría y del aprendizaje profundo',
      'Análisis crítico de los grimorios como literatura mágica',
    ],
    cautions:
        'Contenido histórico-informativo sobre grimorios. Ninguna práctica aquí implica ni fomenta el daño.',
    related: ['La Alquimista (Arquetipos)', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Bael',
    emoji: '🐸',
    summary: 'El primer rey de la Goecia, señor de la invisibilidad',
    origin: 'Goecia (Lemegeton); del título semítico Ba\'al ("señor")',
    history:
        'Primer espíritu listado en el Lemegeton, Bael aparece con tres cabezas — de hombre, gato y sapo — y concede el arte de volverse invisible. Su nombre viene de Ba\'al, título de los grandes dioses cananeos, otro caso de divinidad antigua rebajada a demonio.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Rey del Este que enseña la invisibilidad y la astucia.',
      ),
      ArcanePerspective(
        tradition: 'Histórica',
        view: 'Ba\'al Hadad, dios cananeo de la tormenta, demonizado por la polémica bíblica.',
      ),
      ArcanePerspective(
        tradition: 'Simbólica',
        view: 'Las tres cabezas: las máscaras que usamos para ser vistos — o no.',
      ),
    ],
    characteristics: ['Invisibilidad', 'Astucia', 'Realeza antigua', 'Máscaras'],
    symbolism: [
      'Las tres cabezas: las caras del yo',
      'La invisibilidad: protección y ocultamiento',
      'El trono del Este: el poder del amanecer',
    ],
    correspondences: ['Este', 'Tormenta (herencia de Ba\'al)', 'Negro y ámbar'],
    studyPractices: [
      'Comparar a Ba\'al en los textos de Ugarit con el Bael goético',
      'Reflexionar: ¿cuándo ser invisible protege — y cuándo borra?',
    ],
    magicalUses: [
      'Estudio simbólico de la discreción y de las fronteras personales',
      'Contemplación de las propias máscaras sociales',
    ],
    cautions:
        'Contenido histórico-informativo sobre grimorios. Ninguna práctica aquí implica ni fomenta el daño.',
    related: ['Diosas', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Stolas',
    emoji: '🦉',
    summary: 'El príncipe-búho que enseña hierbas, piedras y astronomía',
    origin: 'Goecia (Lemegeton), príncipe de los grimorios',
    history:
        'Stolas (o Stolos) aparece como un gran búho coronado que enseña astronomía y el poder de las hierbas y de las piedras preciosas — el espíritu goético más cercano al corazón de la brujería natural. Por eso es una figura querida entre practicantes que estudian plantas y cristales.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Príncipe que enseña astronomía, hierbas y el valor de las piedras.',
      ),
      ArcanePerspective(
        tradition: 'Simbólica',
        view: 'El búho coronado: la sabiduría nocturna que ve en la oscuridad.',
      ),
      ArcanePerspective(
        tradition: 'Brujería natural',
        view: 'Patrono informal del estudio de herbarios y lapidarios mágicos.',
      ),
    ],
    characteristics: ['Sabiduría natural', 'Herbalismo', 'Astros', 'Visión nocturna'],
    symbolism: [
      'El búho: ver lo que la luz esconde',
      'La corona: el saber como realeza',
      'El cielo estrellado: el mapa encima y dentro de nosotros',
    ],
    correspondences: ['Hierbas y cristales', 'Noche', 'Verde musgo y plata'],
    studyPractices: [
      'Crear un índice propio de hierbas y piedras estudiadas',
      'Observar el cielo durante una lunación y registrarlo',
    ],
    magicalUses: [
      'Estudio simbólico del aprendizaje de hierbas y cristales',
      'Contemplaciones nocturnas de observación del cielo',
    ],
    cautions:
        'Contenido histórico-informativo sobre grimorios. Ninguna práctica aquí implica ni fomenta el daño.',
    related: ['Hierbas', 'Cristales'],
  ),
  ArcaneEntry(
    name: 'Buer',
    emoji: '🌿',
    summary: 'El presidente-sanador de la Goecia, maestro de las hierbas medicinales',
    origin: 'Goecia (Lemegeton), presidente de los grimorios',
    history:
        'Buer enseña filosofía natural, lógica y las virtudes de las hierbas, y se lo describe como aquel que "cura todas las enfermedades". Ilustrado por Collin de Plancy como una rueda de cinco patas, se convirtió en un curioso símbolo del movimiento perpetuo del aprendizaje.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Presidente que enseña las virtudes de las plantas y restaura la salud.',
      ),
      ArcanePerspective(
        tradition: 'Histórica',
        view: 'Reflejo del médico-filósofo antiguo: curación, lógica y ética iban juntas.',
      ),
      ArcanePerspective(
        tradition: 'Simbólica',
        view: 'La rueda de cinco patas: el conocimiento que no deja de girar.',
      ),
    ],
    characteristics: ['Curación', 'Herbalismo', 'Lógica', 'Filosofía natural'],
    symbolism: [
      'La rueda: el movimiento continuo del estudio',
      'El centauro con arco (otras fuentes): instinto y puntería',
      'El ramo de hierbas: remedio en la naturaleza',
    ],
    correspondences: ['Hierbas medicinales', 'Sagitario en los grimorios', 'Verde y blanco'],
    studyPractices: [
      'Estudiar la historia de la medicina de las hierbas',
      'Reflexionar sobre la ética de curar: límites y responsabilidad',
    ],
    magicalUses: [
      'Estudio simbólico del camino de quien cura',
      'Contemplación sobre la salud como equilibrio',
    ],
    cautions:
        'Contenido histórico-informativo. Las hierbas medicinales reales requieren orientación profesional.',
    related: ['Hierbas', 'La Curandera (Arquetipos)'],
  ),
  ArcaneEntry(
    name: 'Dantalion',
    emoji: '📖',
    summary: 'El duque de los mil rostros que conoce todos los pensamientos',
    origin: 'Goecia (Lemegeton), espíritu 71',
    history:
        'Dantalion aparece con incontables rostros de hombres y mujeres, sosteniendo un libro. Los grimorios dicen que conoce los pensamientos de todas las personas y enseña todas las artes y ciencias — la imagen perfecta de la empatía llevada al límite del misterio.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Duque que revela pensamientos y enseña cualquier arte o ciencia.',
      ),
      ArcanePerspective(
        tradition: 'Simbólica',
        view: 'Los mil rostros: toda mente humana contiene multitudes.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista moderna',
        view: 'Figura asociada al estudio de la empatía, la persuasión y los propios sesgos.',
      ),
    ],
    characteristics: ['Empatía radical', 'Multiplicidad', 'Estudio de las mentes', 'El libro interior'],
    symbolism: [
      'El libro en la mano: cada persona es una biblioteca',
      'Los mil rostros: las versiones de nosotros mismos',
      'El espejo: leer al otro es leerse a uno mismo',
    ],
    correspondences: ['Mercurio', 'Miércoles', 'Lila y grafito'],
    studyPractices: [
      'Reflexionar: ¿cuántos "yoes" hablan dentro de ti?',
      'Practicar la escucha profunda sin juicio durante un día',
    ],
    magicalUses: [
      'Estudio simbólico de la empatía y la comunicación',
      'Contemplación de los propios múltiples rostros',
    ],
    cautions:
        'Contenido histórico-informativo sobre grimorios. Ninguna práctica aquí implica ni fomenta el daño.',
    related: ['La Vidente (Arquetipos)', 'La Tejedora (Arquetipos)'],
  ),
];
