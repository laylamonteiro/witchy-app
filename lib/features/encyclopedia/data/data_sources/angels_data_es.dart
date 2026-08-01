import '../models/arcane_entry_model.dart';

/// Ángeles de la Enciclopedia — contenido en español.
///
/// Enfoque informativo e histórico, diferenciando tradiciones religiosas,
/// folclóricas, ocultistas y literarias. Los emojis son invariantes; mantén
/// el mismo orden que `angels_data_pt.dart` — la paridad se verifica en
/// `test/content_parity_test.dart`.
const List<ArcaneEntry> angelsEs = [
  ArcaneEntry(
    name: 'Miguel',
    emoji: '⚔️',
    summary: 'El príncipe de los ejércitos celestiales, fuerza y protección',
    origin: 'Tradiciones judía, cristiana e islámica (Mikael)',
    history:
        'Mencionado en el Libro de Daniel y en el Apocalipsis, Miguel ("¿Quién como Dios?") es el comandante de las huestes celestiales que vence al dragón. Su devoción recorrió el cristianismo medieval, con santuarios en montes por toda Europa',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'Arcángel guerrero y psicopompo: protege a los fieles, pesa las almas y encabeza el combate contra el mal',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'En la magia ceremonial rige el Sur y el elemento Fuego (en algunas escuelas, el Este y el Aire), invocado en rituales de destierro como el LBRP',
      ),
      ArcanePerspective(
        tradition: 'Folclórica/Popular',
        view:
            'Patrono de policías y soldados; invocado en oraciones de protección contra peligros físicos y espirituales',
      ),
    ],
    characteristics: ['Coraje', 'Justicia', 'Liderazgo', 'Corte de vínculos dañinos'],
    symbolism: [
      'La espada flamígera: la verdad que corta la ilusión',
      'La balanza: el juicio justo',
      'El dragón vencido: la sombra dominada',
    ],
    correspondences: ['Domingo', 'Sol/Fuego', 'Dorado y rojo', 'Olíbano'],
    studyPractices: [
      'Comparar las menciones bíblicas con la angelología medieval',
      'Contemplar: "¿qué batalla interna pide coraje ahora?"',
    ],
    magicalUses: [
      'Invocado en rituales de protección y coraje',
      'Meditaciones de corte de lazos energéticos',
    ],
    cautions:
        'Contenido histórico-informativo: las tradiciones divergen y ninguna lectura es definitiva',
    related: ['La Guardiana (Arquetipos)', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Gabriel',
    emoji: '📯',
    summary: 'El mensajero: anuncios, revelaciones y el poder de la palabra',
    origin: 'Tradiciones judía, cristiana e islámica (Yibril)',
    history:
        'Gabriel ("Fuerza de Dios") aparece en Daniel interpretando visiones y, en el Nuevo Testamento, anuncia los nacimientos de Juan Bautista y de Jesús. En el islam, es Yibril quien revela el Corán a Mahoma — el gran intermediario entre el cielo y la humanidad',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'El heraldo divino por excelencia: trae revelaciones, anuncios de nacimiento y llamados proféticos',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'Asociado al Oeste, al Agua y a la Luna en la magia ceremonial; rige los sueños, la intuición y los misterios del ciclo lunar',
      ),
      ArcanePerspective(
        tradition: 'Literaria',
        view:
            'Presente desde Milton hasta obras contemporáneas como el trompetero del juicio y el mensajero renuente',
      ),
    ],
    characteristics: ['Comunicación', 'Revelación', 'Intuición', 'Fertilidad de ideas'],
    symbolism: [
      'La trompeta: el llamado que despierta',
      'El lirio: la pureza del mensaje',
      'La luna: los ciclos y los sueños',
    ],
    correspondences: ['Lunes', 'Luna/Agua', 'Blanco y plata', 'Jazmín'],
    studyPractices: [
      'Registrar sueños anunciadores en el Diario de Sueños',
      'Estudiar las anunciaciones en las tres tradiciones abrahámicas',
    ],
    magicalUses: [
      'Meditaciones para la claridad en la comunicación',
      'Trabajos de intuición y sueños lúcidos',
    ],
    cautions:
        'Contenido histórico-informativo: las tradiciones divergen y ninguna lectura es definitiva',
    related: ['La Vidente (Arquetipos)', 'Sueños y Visiones'],
  ),
  ArcaneEntry(
    name: 'Rafael',
    emoji: '💚',
    summary: 'La medicina de Dios: sanación, viajes y buenos encuentros',
    origin: 'Libro de Tobías (tradición judeocristiana); Israfil en el islam tiene otro papel',
    history:
        'En el Libro de Tobías, Rafael ("Dios sana") acompaña disfrazado al joven Tobías, le enseña remedios y cura la ceguera de su padre — por eso es patrono de los viajeros, los médicos y los casamenteros',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'Arcángel de la sanación y compañero de camino: protege los viajes y restaura la salud del cuerpo y del alma',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'En la magia ceremonial rige el Este y el Aire (en algunas escuelas, Mercurio), ligado al conocimiento que sana',
      ),
      ArcanePerspective(
        tradition: 'Folclórica/Popular',
        view:
            'Invocado en novenas por la salud, cirugías exitosas y encuentros afortunados',
      ),
    ],
    characteristics: ['Sanación', 'Compañía protectora', 'Alegría serena', 'Conocimiento práctico'],
    symbolism: [
      'El bastón del viajero: el camino guiado',
      'El pez: el remedio inesperado',
      'El frasco de bálsamo: la medicina sagrada',
    ],
    correspondences: ['Miércoles', 'Mercurio/Aire', 'Verde y amarillo', 'Lavanda'],
    studyPractices: [
      'Leer el Libro de Tobías como relato de sanación y travesía',
      'Contemplar: "¿qué herida mía pide un compañero de camino?"',
    ],
    magicalUses: [
      'Meditaciones de sanación y convalecencia',
      'Bendiciones de viaje y protección de caminos',
    ],
    cautions:
        'Las prácticas espirituales no sustituyen el tratamiento médico. Contenido histórico-informativo',
    related: ['La Sanadora (Arquetipos)', 'Energía y Sanación'],
  ),
  ArcaneEntry(
    name: 'Uriel',
    emoji: '🔥',
    summary: 'El fuego de Dios: iluminación intelectual y verdad',
    origin: 'Literatura apócrifa judía (2 Esdras, Libro de Enoc)',
    history:
        'Uriel ("Fuego/Luz de Dios") aparece en los apócrifos como el ángel que guía a Esdras y vigila los portales. Fuera del canon oficial de las principales iglesias, se volvió figura central de la angelología esotérica y anglicana',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'Venerado en algunas iglesias orientales y anglicanas como arcángel de la sabiduría; ausente del canon católico actual',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'Rige el Norte y el elemento Tierra en la magia ceremonial; guardián de los misterios y de la luz interior',
      ),
      ArcanePerspective(
        tradition: 'Literaria',
        view:
            'En Milton es el "espíritu de vista más aguda del cielo" — el vigía que ve lejos',
      ),
    ],
    characteristics: ['Sabiduría', 'Discernimiento', 'Estudio', 'Verdad sin rodeos'],
    symbolism: [
      'La llama en la palma: la iluminación interior',
      'El pergamino: el conocimiento revelado',
      'El relámpago: la intuición súbita',
    ],
    correspondences: ['Tierra', 'Ámbar', 'Rojo y ocre', 'Sándalo'],
    studyPractices: [
      'Estudiar con intención: encender una vela antes de aprender algo nuevo',
      'Comparar la angelología canónica con la apócrifa',
    ],
    magicalUses: [
      'Meditaciones de claridad para decisiones difíciles',
      'Rituales de iluminación de caminos y estudios',
    ],
    cautions:
        'Contenido histórico-informativo: las tradiciones divergen y ninguna lectura es definitiva',
    related: ['La Sabia (Arquetipos)', 'La Alquimista (Arquetipos)'],
  ),
  ArcaneEntry(
    name: 'Lucifer',
    emoji: '🌟',
    summary: 'El ángel portador de la luz: el lucero del alba antes y después de la caída',
    origin: 'Latín lucifer ("portador de la luz", el lucero del alba); Isaías 14',
    history:
        'Originalmente el nombre latino de Venus como estrella de la mañana, "Lucifer" fue asociado al rey caído de Isaías 14 y, de ahí, al ángel rebelde. Milton lo convirtió en el antihéroe trágico de El paraíso perdido; corrientes románticas y ocultistas lo releyeron como símbolo del conocimiento y de la rebeldía luminosa',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'El ángel que cayó por orgullo; identificado con Satanás en la tradición cristiana',
      ),
      ArcanePerspective(
        tradition: 'Literaria',
        view:
            'En Milton y en el romanticismo, el rebelde magnífico — "mejor reinar en el infierno que servir en el cielo"',
      ),
      ArcanePerspective(
        tradition: 'Ocultista moderna',
        view:
            'Símbolo del librepensamiento y de la búsqueda del conocimiento (luciferismo filosófico), distinto del satanismo popular',
      ),
    ],
    characteristics: ['Orgullo', 'Brillo intelectual', 'Rebeldía', 'Caída y búsqueda'],
    symbolism: [
      'El lucero del alba: la luz que precede al sol',
      'La caída: el precio de la hybris',
      'La antorcha: el conocimiento que libera o quema',
    ],
    correspondences: ['Venus matutino', 'Azufre simbólico', 'Azul eléctrico'],
    studyPractices: [
      'Leer Isaías 14 y El paraíso perdido en paralelo',
      'Reflexionar sobre el orgullo sano frente a la hybris',
    ],
    magicalUses: [
      'Estudio simbólico del propio brillo y de las propias caídas',
      'Contemplación de Venus en el cielo matutino',
    ],
    cautions:
        'Contenido histórico-informativo. Ninguna práctica aquí implica ni incentiva daño',
    related: ['La Alquimista (Arquetipos)', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Metatrón',
    emoji: '📖',
    summary: 'El escriba celeste y la geometría del cosmos',
    origin: 'Misticismo judío (Talmud, literatura Hekhalot, Cábala)',
    history:
        'En la tradición mística judía, Metatrón es el escriba que todo lo registra y, en algunas corrientes, el profeta Enoc transfigurado. En la Cábala se asocia a la sefirá Kéter — el punto más cercano a lo inefable',
    perspectives: [
      ArcanePerspective(
        tradition: 'Mística judía',
        view:
            'El "príncipe del rostro": escriba divino y voz transmisora; figura de estudio avanzado, no de culto',
      ),
      ArcanePerspective(
        tradition: 'Ocultista/Nueva Era',
        view:
            'Ligado al "Cubo de Metatrón", figura de la geometría sagrada que contendría los sólidos platónicos — lectura moderna sin fuente antigua',
      ),
    ],
    characteristics: ['Registro', 'Orden cósmico', 'Ascensión', 'Estudio profundo'],
    symbolism: [
      'El cubo: la estructura de la creación',
      'La pluma y el libro: la memoria del universo',
      'La escalera: el viaje de Enoc',
    ],
    correspondences: ['Geometría sagrada', 'Selenita', 'Blanco y violeta'],
    studyPractices: [
      'Estudiar la geometría sagrada y dibujar el Cubo de Metatrón',
      'Journaling como "escriba" de la propia vida',
    ],
    magicalUses: [
      'Meditaciones con geometría sagrada para el orden mental',
      'Rituales de registro y revisión de ciclos',
    ],
    cautions:
        'Distingue las fuentes antiguas de las relecturas modernas al estudiar. Contenido histórico-informativo',
    related: ['Símbolos Sagrados', 'La Tejedora (Arquetipos)'],
  ),
  ArcaneEntry(
    name: 'Sandalfón',
    emoji: '🎶',
    summary: 'El hermano gemelo espiritual de Metatrón, señor de la música y las plegarias',
    origin: 'Misticismo judío; asociado al profeta Elías',
    history:
        'En la tradición mística, Sandalfón recoge las oraciones humanas y las teje en coronas. Como Metatrón/Enoc, sería el profeta Elías elevado — el vínculo entre el clamor de la tierra y el cielo',
    perspectives: [
      ArcanePerspective(
        tradition: 'Mística judía',
        view:
            'El ángel que lleva las plegarias al trono; asociado a la sefirá Malkut, el reino terrestre',
      ),
      ArcanePerspective(
        tradition: 'Nueva Era',
        view:
            'Invocado como patrono de la música y de los músicos, de las artes que elevan',
      ),
    ],
    characteristics: ['Devoción', 'Música', 'Enraizamiento', 'Puente entre tierra y cielo'],
    symbolism: [
      'Las sandalias: el caminar sagrado sobre la tierra',
      'La corona de plegarias: la fuerza de lo colectivo',
      'La lira: la oración cantada',
    ],
    correspondences: ['Música devocional', 'Turquesa', 'Tierra y Malkut'],
    studyPractices: [
      'Cantar o tocar como práctica contemplativa',
      'Estudiar el papel de la música en las tradiciones religiosas',
    ],
    magicalUses: [
      'Mantras y cantos en rituales',
      'Prácticas de enraizamiento antes de trabajos energéticos',
    ],
    cautions:
        'Contenido histórico-informativo: las tradiciones divergen y ninguna lectura es definitiva',
    related: ['Metatrón', 'Afirmaciones (Diario)'],
  ),
  ArcaneEntry(
    name: 'Raziel',
    emoji: '🗝️',
    summary: 'El guardián de los secretos y del libro de los misterios',
    origin: 'Cábala y literatura mística judía (Sefer Raziel HaMalakh)',
    history:
        'Raziel ("Secreto de Dios") habría entregado a Adán un libro con todos los misterios del universo — el legendario Sefer Raziel, cuya versión medieval circuló como grimorio de protección',
    perspectives: [
      ArcanePerspective(
        tradition: 'Cabalística',
        view:
            'Asociado a la sefirá Jojmá (sabiduría); el conocimiento oculto que precede a la forma',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'El Sefer Raziel medieval se copiaba como amuleto: tener el libro en casa protegería contra los incendios',
      ),
    ],
    characteristics: ['Misterio', 'Conocimiento esotérico', 'Protección por el saber'],
    symbolism: [
      'El libro sellado: el saber que se conquista',
      'La llave: la iniciación',
      'El velo: lo oculto que se revela poco a poco',
    ],
    correspondences: ['Índigo', 'Sodalita', 'Jojmá', 'Mirra'],
    studyPractices: [
      'Mantener un grimorio personal como "tu propio Sefer Raziel"',
      'Estudiar la historia de los grimorios medievales',
    ],
    magicalUses: [
      'Consagración del grimorio personal',
      'Meditaciones de acceso al conocimiento interior',
    ],
    cautions:
        'Los grimorios históricos reflejan su época: estúdialos con sentido crítico. Contenido histórico-informativo',
    related: ['Mi Grimorio', 'La Alquimista (Arquetipos)'],
  ),
  ArcaneEntry(
    name: 'Ángel de la Guarda',
    emoji: '👼',
    summary: 'El compañero personal: la creencia universal en el protector individual',
    origin: 'Antigüedad grecorromana (daimon/genius) y tradiciones abrahámicas',
    history:
        'La idea de un espíritu protector personal es anterior al cristianismo: los griegos tenían el daimon, los romanos el genius. El cristianismo consolidó el ángel de la guarda individual, y la magia ceremonial hizo del contacto con el "Sagrado Ángel Guardián" su gran obra',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'Cada persona tiene un ángel asignado que protege e intercede — memorial litúrgico el 2 de octubre',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'En la tradición de Abramelín y en la Golden Dawn, el "Conocimiento y Conversación del Sagrado Ángel Guardián" es el objetivo central del trabajo mágico — leído por muchos como el Yo Superior',
      ),
      ArcanePerspective(
        tradition: 'Folclórica',
        view:
            'Oraciones populares ("Ángel de mi guarda, dulce compañía...") y la creencia cotidiana en los libramientos',
      ),
    ],
    characteristics: ['Presencia constante', 'Aviso intuitivo', 'Consuelo'],
    symbolism: [
      'Las alas que envuelven: el amparo',
      'La luz al lado: la compañía invisible',
    ],
    correspondences: ['Vela blanca', 'Ángel personal', 'Cuarzo blanco'],
    studyPractices: [
      'Registrar "libramientos" e intuiciones protectoras en el Diario',
      'Comparar el daimon socrático con el ángel de la guarda cristiano',
    ],
    magicalUses: [
      'Diálogo meditativo con el protector interior',
      'Una vela blanca semanal en agradecimiento',
    ],
    cautions:
        'Contenido histórico-informativo: las tradiciones divergen y ninguna lectura es definitiva',
    related: ['La Guardiana (Arquetipos)', 'Consejero Místico'],
  ),
  ArcaneEntry(
    name: 'Serafines',
    emoji: '🔥',
    summary: 'Los ardientes: el orden más cercano al trono',
    origin: 'Visión de Isaías (Antiguo Testamento)',
    history:
        'Isaías los describe con seis alas, clamando "Santo, Santo, Santo". Su nombre deriva de "arder" — son el amor divino en estado incandescente, la cima de la jerarquía angélica de Pseudo-Dionisio',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'El orden más elevado, consumido en adoración perpetua ante el trono',
      ),
      ArcanePerspective(
        tradition: 'Mística',
        view:
            'El fuego seráfico como metáfora del éxtasis espiritual — el amor que purifica al arder',
      ),
    ],
    characteristics: ['Ardor', 'Pureza', 'Adoración', 'Intensidad'],
    symbolism: [
      'Las seis alas: reverencia, prontitud y vuelo',
      'La brasa: la purificación (la brasa en los labios de Isaías)',
    ],
    correspondences: ['Fuego', 'Rojo intenso', 'Olíbano y mirra'],
    studyPractices: [
      'Leer Isaías 6 y la jerarquía de Pseudo-Dionisio',
      'Contemplar: "¿qué en mí merece arder de entusiasmo?"',
    ],
    magicalUses: [
      'Meditaciones de purificación por el fuego simbólico',
      'Velas rojas en prácticas devocionales',
    ],
    cautions:
        'Contenido histórico-informativo: las tradiciones divergen y ninguna lectura es definitiva',
    related: ['Uriel', 'Elementos: Fuego'],
  ),
  ArcaneEntry(
    name: 'Querubines',
    emoji: '🌩️',
    summary: 'Los guardianes del trono y del Edén — lejos de los bebés alados',
    origin: 'Génesis, Ezequiel y el arte mesopotámico',
    history:
        'Los querubines bíblicos custodian el Edén con espada flamígera y sostienen el trono divino en las visiones de Ezequiel — seres tetramorfos imponentes, emparentados con los lamassu asirios. La imagen de bebés alados (putti) es invención del arte renacentista',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'Guardianes de lo sagrado y portadores del trono; esculpidos sobre el Arca de la Alianza',
      ),
      ArcanePerspective(
        tradition: 'Histórico-artística',
        view:
            'Del tetramorfo temible al putto decorativo: un caso ejemplar de transformación iconográfica',
      ),
    ],
    characteristics: ['Guardia implacable', 'Majestad', 'Conocimiento'],
    symbolism: [
      'Los cuatro rostros: la totalidad de la creación',
      'La espada flamígera: el límite inviolable',
      'La tormenta: el poder de lo sagrado',
    ],
    correspondences: ['Tormenta', 'Lapislázuli', 'Azul profundo'],
    studyPractices: [
      'Comparar los querubines de Ezequiel con los lamassu asirios',
      'Reflexionar sobre lo que custodias como innegociable',
    ],
    magicalUses: [
      'Visualizaciones de guarda de espacios sagrados',
      'El estudio iconográfico como meditación',
    ],
    cautions:
        'Contenido histórico-informativo: las tradiciones divergen y ninguna lectura es definitiva',
    related: ['La Guardiana (Arquetipos)', 'Miguel'],
  ),
  ArcaneEntry(
    name: 'Ariel',
    emoji: '🦁',
    summary: 'El león de Dios, ángel de la naturaleza y de los elementos',
    origin: 'Hebreo Ari\'el ("león de Dios"); tradiciones cabalística y ocultista',
    history:
        'Citado en textos apócrifos y grimorios como el ángel que rige la naturaleza salvaje, los animales y los espíritus elementales. En la magia renacentista aparece como regente del Aire (y, en algunas fuentes, de la Tierra), y Shakespeare lo eternizó como el espíritu de La tempestad',
    perspectives: [
      ArcanePerspective(
        tradition: 'Cabalística',
        view: 'Nombre angélico ligado al rostro salvaje de lo sagrado: la fuerza del león al servicio de la creación',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view: 'Regente de espíritus elementales; invocado en operaciones de armonía con la naturaleza',
      ),
      ArcanePerspective(
        tradition: 'Literaria',
        view: 'El espíritu ágil de Shakespeare: el viento que sirve, encanta y al final es liberado',
      ),
    ],
    characteristics: ['Conexión con la naturaleza', 'Sanación ambiental', 'Coraje manso', 'Elementales'],
    symbolism: [
      'El león: la fuerza que protege en vez de devorar',
      'El viento: los mensajes de la naturaleza',
      'La rosa de los vientos: los cuatro elementos en equilibrio',
    ],
    correspondences: ['Aire y Tierra', 'Verde y dorado', 'Plantas silvestres', 'Cuarzo verde'],
    studyPractices: [
      'Comparar a Ariel en los grimorios y en La tempestad',
      'Caminata contemplativa: ¿qué mensajes trae hoy la naturaleza?',
    ],
    magicalUses: [
      'Meditaciones de reconexión con la naturaleza y los elementos',
      'Bendiciones de jardines, plantas y animales',
    ],
    cautions:
        'Contenido histórico-informativo: las tradiciones divergen y ninguna lectura es definitiva',
    related: ['La Cazadora (Arquetipos)', 'Elementos'],
  ),
  ArcaneEntry(
    name: 'Haniel',
    emoji: '🌹',
    summary: 'La gracia de Dios: ángel de Venus, del amor y de la luna',
    origin: 'Hebreo Hana\'el ("gracia de Dios"); angelología cabalística',
    history:
        'En la Cábala, Haniel rige la esfera de Netsaj, asociada a Venus, a la belleza y a la victoria. La tradición lo vincula a los ciclos de la luna y a los misterios femeninos, siendo uno de los ángeles más invocados en la magia planetaria venusina',
    perspectives: [
      ArcanePerspective(
        tradition: 'Cabalística',
        view: 'Regente de Netsaj: la belleza, el deseo elevado y la persistencia de la vida',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view: 'Ángel planetario de Venus, invocado los viernes en operaciones de amor propio y armonía',
      ),
      ArcanePerspective(
        tradition: 'Popular',
        view: 'Ángel de la gracia y del encanto: ayuda a ver belleza en los propios ciclos',
      ),
    ],
    characteristics: ['Amor propio', 'Armonía', 'Intuición lunar', 'Encanto'],
    symbolism: [
      'La rosa: la belleza que florece con espinas',
      'La luna creciente: los ciclos y la renovación',
      'La estrella de Venus: el amor como brújula',
    ],
    correspondences: ['Viernes', 'Venus/Luna', 'Verde esmeralda y rosa', 'Rosa y jazmín'],
    studyPractices: [
      'Estudiar Netsaj en el Árbol de la Vida',
      'Diario de ciclos: ¿cómo cambia tu energía con la luna?',
    ],
    magicalUses: [
      'Rituales de amor propio y reconciliación interior',
      'Trabajos lunares de intuición y belleza',
    ],
    cautions:
        'Contenido histórico-informativo: las tradiciones divergen y ninguna lectura es definitiva',
    related: ['La Doncella (Arquetipos)', 'Diosas'],
  ),
  ArcaneEntry(
    name: 'Azrael',
    emoji: '🕊️',
    summary: 'El ángel de la muerte y de los tránsitos, consuelo de quienes cruzan',
    origin: 'Tradiciones islámica y judía (Azra\'il, "aquel a quien Dios ayuda")',
    history:
        'En el islam, Azrael es el ángel que recoge las almas con compasión; en el folclore judío, el mensajero de los tránsitos. Lejos de la figura sombría popular, las fuentes lo describen como un siervo dedicado que acompaña cada travesía con misericordia',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'El ángel encargado del tránsito de las almas, que actúa solo por orden divina',
      ),
      ArcanePerspective(
        tradition: 'Folclórica',
        view: 'El escriba que anota los nacimientos y borra los nombres a la hora de la partida',
      ),
      ArcanePerspective(
        tradition: 'Ocultista moderna',
        view: 'Psicopompo invocado en ritos de duelo y en el culto respetuoso a los ancestros',
      ),
    ],
    characteristics: ['Compasión', 'Travesías', 'Duelo y consuelo', 'Memoria de los que partieron'],
    symbolism: [
      'La pluma y el libro: cada vida registrada',
      'El velo: la frontera entre los mundos',
      'La paloma: el alma que parte en paz',
    ],
    correspondences: ['Sábado', 'Saturno', 'Gris y blanco', 'Ciprés y mirra'],
    studyPractices: [
      'Comparar al Azrael islámico con los psicopompos de otras culturas',
      'Escribir cartas de despedida o gratitud a quienes partieron',
    ],
    magicalUses: [
      'Ritos de duelo, cierre de ciclos y honra a los ancestros',
      'Meditaciones de aceptación de los grandes cambios',
    ],
    cautions:
        'Contenido histórico-informativo. El duelo profundo merece también apoyo humano y profesional',
    related: ['La Reina Oscura (Arquetipos)', 'Rueda del Año'],
  ),
  ArcaneEntry(
    name: 'Samael',
    emoji: '⚖️',
    summary: 'El veneno de Dios: el ángel severo entre la luz y la sombra',
    origin: 'Talmud y literatura rabínica; Sama\'el ("veneno de Dios")',
    history:
        'Figura ambigua de la angelología judía: arcángel de la severidad y acusador celeste, a veces identificado con el ángel de la muerte, a veces con Marte. En el folclore cabalístico se le señala como consorte de Lilith — una de las parejas más comentadas del ocultismo',
    perspectives: [
      ArcanePerspective(
        tradition: 'Rabínica',
        view: 'El acusador que pone a prueba a los justos: severidad que sirve, no que destruye',
      ),
      ArcanePerspective(
        tradition: 'Cabalística',
        view: 'Asociado a Guevurá y a Marte: la fuerza que corta lo que debe ser cortado',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view: 'Símbolo del trabajo de sombra: encarar al acusador interno e integrarlo',
      ),
    ],
    characteristics: ['Severidad', 'Justicia dura', 'Límites', 'Sombra integrada'],
    symbolism: [
      'La espada de Marte: el corte necesario',
      'El veneno: el remedio en la dosis justa',
      'La balanza inclinada: el juicio en tensión',
    ],
    correspondences: ['Martes', 'Marte', 'Rojo oscuro', 'Pimienta y hierro'],
    studyPractices: [
      'Estudiar Guevurá y el papel del rigor en el Árbol de la Vida',
      'Reflexionar: ¿dónde la severidad protege — y dónde hiere?',
    ],
    magicalUses: [
      'Meditaciones de límites y de trabajo de sombra',
      'Estudio simbólico de la pareja Samael-Lilith en el folclore',
    ],
    cautions:
        'Contenido histórico-informativo. Ninguna práctica aquí implica ni incentiva daño',
    related: ['Lilith (Demonios)', 'La Reina Oscura (Arquetipos)'],
  ),
  ArcaneEntry(
    name: 'Zadkiel',
    emoji: '💜',
    summary: 'La justicia de Dios: ángel de la misericordia y de la transmutación',
    origin: 'Hebreo Tzadki\'el ("justicia de Dios"); angelología cabalística',
    history:
        'Asociado en la Cábala a la esfera de Jésed (misericordia) y a Júpiter, Zadkiel es recordado como el ángel que detuvo la mano de Abraham. El esoterismo moderno lo vinculó a la "llama violeta" de la transmutación, popularizada por las escuelas teosóficas',
    perspectives: [
      ArcanePerspective(
        tradition: 'Cabalística',
        view: 'Regente de Jésed: la generosidad que expande y perdona',
      ),
      ArcanePerspective(
        tradition: 'Teosófica/Nueva Era',
        view: 'Guardián de la llama violeta: transmutar recuerdos pesados en aprendizaje',
      ),
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'El ángel de la misericordia que interrumpe los sacrificios innecesarios',
      ),
    ],
    characteristics: ['Perdón', 'Generosidad', 'Transmutación', 'Abundancia justa'],
    symbolism: [
      'La llama violeta: el pasado transformado',
      'El cetro de Júpiter: la benevolencia que gobierna',
      'La mano detenida: la misericordia por encima del rito',
    ],
    correspondences: ['Jueves', 'Júpiter', 'Violeta y azul real', 'Amatista'],
    studyPractices: [
      'Estudiar Jésed y el equilibrio entre dar y retener',
      'Práctica de perdón: ¿a quién le cobras todavía una deuda interna?',
    ],
    magicalUses: [
      'Rituales de perdón y liberación de rencores',
      'Meditaciones de transmutación con la llama violeta',
    ],
    cautions:
        'Contenido histórico-informativo: las tradiciones divergen y ninguna lectura es definitiva',
    related: ['La Sanadora (Arquetipos)', 'Cristales'],
  ),
];
