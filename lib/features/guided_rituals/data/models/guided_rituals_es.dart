import 'guided_ritual_model.dart';

/// Contenido de los rituales guiados — español.
/// Paridad con PT/EN verificada en test/guided_rituals_parity_test.dart.

const Map<String, GuidedRitualText> guidedRitualTextsEs = {
  'sabbat_samhain': (
    title: 'Ritual de Samhain',
    intro:
        'El Año Nuevo de las Brujas. El velo entre los mundos está en su punto más fino: es la noche de honrar a los ancestros, cerrar ciclos y escuchar la propia intuición',
    timing:
        'El día de Samhain, preferiblemente al anochecer, cuando el velo se afina',
  ),
  'sabbat_yule': (
    title: 'Ritual de Yule',
    intro:
        'El Solsticio de Invierno trae la noche más larga del año. Celebramos el renacimiento de la luz: a partir de ahora, los días vuelven a crecer',
    timing: 'El día del solsticio, al atardecer o por la noche',
  ),
  'sabbat_imbolc': (
    title: 'Ritual de Imbolc',
    intro:
        'Festival de la luz creciente. La Tierra despierta lentamente y aparecen las primeras señales de la primavera. Es tiempo de purificar, limpiar y preparar el nuevo crecimiento',
    timing:
        'El día de Imbolc, por la mañana o al mediodía, en honor a la luz que crece',
  ),
  'sabbat_ostara': (
    title: 'Ritual de Ostara',
    intro:
        'Equinoccio de Primavera: luz y oscuridad en equilibrio perfecto mientras la naturaleza despierta en plenitud. Tiempo de nuevos comienzos e ideas fértiles',
    timing: 'El día del equinoccio, por la mañana',
  ),
  'sabbat_beltane': (
    title: 'Ritual de Beltane',
    intro:
        'El festival del fuego y la fertilidad. La vida está en plenitud: celebra el amor, la pasión y la alegría de estar viva',
    timing: 'El día de Beltane, desde el final de la tarde hasta la noche',
  ),
  'sabbat_litha': (
    title: 'Ritual de Litha',
    intro:
        'Solsticio de Verano: el día más largo y el pico del poder solar. Momento de celebrar los logros, agradecer y absorber la fuerza del Sol',
    timing: 'El día del solsticio, del amanecer al atardecer',
  ),
  'sabbat_lammas': (
    title: 'Ritual de Lammas',
    intro:
        'La primera cosecha. Después de la abundancia del verano, es tiempo de agradecer, compartir y reconocer el esfuerzo detrás de cada logro',
    timing: 'El día de Lammas, por la tarde',
  ),
  'sabbat_mabon': (
    title: 'Ritual de Mabon',
    intro:
        'Equinoccio de Otoño: la segunda cosecha y el segundo equilibrio del año. Tiempo de gratitud, balance y de liberar lo que no necesita seguir contigo',
    timing: 'El día del equinoccio, al atardecer',
  ),
  'full_moon': (
    title: 'Ritual de Luna Llena',
    intro:
        'La Luna está en el auge de su poder e ilumina todo lo que has estado construyendo. Es la hora de manifestar intenciones, cargar tus cristales e instrumentos y practicar la adivinación',
    timing:
        'En la noche de la luna llena (la energía también vale la víspera y el día siguiente)',
  ),
  'new_moon': (
    title: 'Ritual de Luna Nueva',
    intro:
        'El cielo oscuro es una página en blanco. La luna nueva es el momento de plantar intenciones, comenzar proyectos y reconectar con lo que quieres atraer',
    timing: 'En la noche de la luna nueva, en un lugar tranquilo',
  ),
  'moon_water': (
    title: 'Agua de Luna',
    intro:
        'El Agua de Luna guarda la energía de la luna llena para cuando la necesites: en hechizos, baños, limpiezas e incluso para regar las plantas',
    timing:
        'Prepárala en la noche de la luna llena y recógela antes del amanecer, para que el agua no reciba energía solar',
  ),
  'sun_water': (
    title: 'Agua Solar',
    intro:
        'El Agua Solar carga vitalidad, coraje y alegría. Es la hermana diurna del agua de luna: úsala cuando necesites un impulso de energía y fuerza',
    timing:
        'En un día soleado, desde la mañana temprano hasta media tarde (bastan de 3 a 6 horas de sol)',
  ),
};

const Map<String, List<RitualStepText>> guidedRitualStepsEs = {
  'sabbat_samhain': [
    (
      title: 'Prepara el espacio',
      description:
          'Limpia el ambiente, enciende un incienso (salvia o romero) y apaga las luces fuertes. Deja el clima silencioso y acogedor'
    ),
    (
      title: 'Monta el altar de los ancestros',
      description:
          'Coloca fotos u objetos de seres queridos que ya partieron, con una ofrenda simple: un vaso de agua, pan o una fruta'
    ),
    (
      title: 'Enciende las velas',
      description:
          'Enciende una vela negra (para liberar lo que queda atrás) y una naranja (por la cosecha de la vida). Agradece en voz baja a quienes vinieron antes que tú'
    ),
    (
      title: 'Conversa con la memoria',
      description:
          'Di en voz alta (o escribe) un buen recuerdo de cada persona homenajeada. Si quieres, haz una pequeña cena en silencio'
    ),
    (
      title: 'Practica la adivinación',
      description:
          'Con el velo fino, saca una carta de tarot, tira las runas o usa el péndulo preguntando: "¿qué debo dejar en el año que termina?"'
    ),
    (
      title: 'Cierra y agradece',
      description:
          'Apaga las velas, agradece a los ancestros y devuelve la ofrenda a la naturaleza al día siguiente'
    ),
  ],
  'sabbat_yule': [
    (
      title: 'Decora con elementos naturales',
      description:
          'Recoge (o separa) piñas, ramas, canela y frutas secas y monta un pequeño arreglo en tu altar o mesa'
    ),
    (
      title: 'Apaga todo por un instante',
      description:
          'Quédate un momento en la oscuridad, respirando profundo. Honra la noche más larga del año y todo lo que descansa para renacer'
    ),
    (
      title: 'Enciende la luz que regresa',
      description:
          'Enciende velas doradas, rojas o blancas, una a una, diciendo qué quieres que crezca junto con la luz en los próximos meses'
    ),
    (
      title: 'Baño de hierbas purificador',
      description:
          'Prepara un baño con romero y canela (del cuello hacia abajo). Visualiza lo que quedó pesado escurriendo por el desagüe'
    ),
    (
      title: 'Medita sobre el ciclo',
      description:
          'Frente a las velas, medita unos minutos sobre la muerte y el renacimiento: ¿qué termina en ti y qué está naciendo?'
    ),
    (
      title: 'Comparte calor',
      description:
          'Prepara una bebida caliente (vino especiado, té con jengibre) y, si puedes, compártela con alguien querido. Yule es fiesta de abrigo'
    ),
  ],
  'sabbat_imbolc': [
    (
      title: 'Haz la limpieza de primavera',
      description:
          'Barre la casa desde la puerta de atrás hacia el frente (o visualiza la suciedad saliendo), abriendo espacio para lo nuevo. Si tienes escoba ritual, es su momento'
    ),
    (
      title: 'Purifica con humo o agua',
      description:
          'Pasa incienso de lavanda o manzanilla por las habitaciones, o rocía agua con sal, pidiendo que la energía estancada se disuelva'
    ),
    (
      title: 'Enciende la vela de la luz creciente',
      description:
          'Enciende una vela blanca, amarilla o roja en honor al Sol que regresa. Si quieres, dedícala a Brigid, señora del fuego y la inspiración'
    ),
    (
      title: 'Planta tus semillas',
      description:
          'Planta semillas de verdad (hierbas, flores) o simbólicas: escribe en papel lo que quieres ver florecer y guárdalo junto a una maceta'
    ),
    (
      title: 'Baño de leche y miel',
      description:
          'Si puedes, toma un baño con un poco de leche y miel, pidiendo suavidad, nutrición y nuevos comienzos'
    ),
    (
      title: 'Cierra con gratitud',
      description:
          'Agradece la luz que crece. Deja la vela arder con seguridad hasta el final (o apágala y reenciéndela en los próximos días)'
    ),
  ],
  'sabbat_ostara': [
    (
      title: 'Arregla un altar de primavera',
      description:
          'Usa flores frescas, semillas y colores claros. Abre las ventanas y deja circular el aire'
    ),
    (
      title: 'Pinta o decora huevos',
      description:
          'Pinta huevos (o piedritas) con símbolos de lo que quieres hacer nacer: espirales, soles, runas, corazones'
    ),
    (
      title: 'Planta flores y hierbas',
      description:
          'Planta en macetas o en el jardín. Cada plantita es una intención: di en voz alta qué representa cada una'
    ),
    (
      title: 'Equilibra tus energías',
      description:
          'El equinoccio pide equilibrio: enciende una vela blanca y una negra y reflexiona sobre qué necesitas equilibrar (trabajo/descanso, dar/recibir)'
    ),
    (
      title: 'Crea un saquito de prosperidad',
      description:
          'En una bolsita verde o amarilla, coloca albahaca, menta y una moneda. Llévala contigo o déjala cerca de la puerta de entrada'
    ),
  ],
  'sabbat_beltane': [
    (
      title: 'Monta un altar de flores',
      description:
          'Llena el altar de flores rojas, rosas y coloridas. Beltane celebra la vida en plenitud'
    ),
    (
      title: 'Enciende el fuego sagrado',
      description:
          'Enciende velas rojas (o una hoguera, con seguridad). El fuego de Beltane purifica y vitaliza: acerca las manos al calor y siente la energía'
    ),
    (
      title: 'Baila y celebra',
      description:
          'Pon una música que te haga feliz y baila, aunque sea sola. Deja que el cuerpo celebre estar viva'
    ),
    (
      title: 'Haz ofrendas a los elementales',
      description:
          'Deja miel, leche o flores en un rincón del jardín o en una maceta, agradeciendo a las hadas y a los espíritus de la naturaleza'
    ),
    (
      title: 'Celebra el amor',
      description:
          'Escribe una carta de amor — para alguien o para ti misma. Guárdala junto a un cuarzo rosa hasta el próximo sabbat'
    ),
  ],
  'sabbat_litha': [
    (
      title: 'Saluda al Sol',
      description:
          'Mira el amanecer (o el atardecer). Agradece en voz alta por la luz, el calor y todo lo que maduró en tu vida'
    ),
    (
      title: 'Cosecha hierbas mágicas',
      description:
          'Las hierbas están en el auge de su poder: cosecha (o compra) manzanilla, menta y lavanda para secar y usar todo el año'
    ),
    (
      title: 'Haz un círculo de protección',
      description:
          'Camina por el contorno de la casa (o visualízalo) esparciendo sal o romero, pidiendo protección para quienes viven en ella'
    ),
    (
      title: 'Carga tus objetos al sol',
      description:
          'Deja joyas, amuletos y cristales que aceptan sol (cuidado con los que se destiñen) bañarse en la luz por algunas horas'
    ),
    (
      title: 'Celebra con los colores del Sol',
      description:
          'Prepara una mesa con frutas frescas y flores amarillas y doradas. Come despacio, con gratitud'
    ),
  ],
  'sabbat_lammas': [
    (
      title: 'Hornea (o compra) un pan',
      description:
          'El pan es el símbolo de la primera cosecha. Si puedes, hornéalo con tus propias manos, poniendo intención de abundancia en cada gesto'
    ),
    (
      title: 'Agradece los logros',
      description:
          'Haz una lista de todo lo que cosechaste este año — hasta las cosechas pequeñas. Léela en voz alta frente al altar'
    ),
    (
      title: 'Haz una muñeca de maíz',
      description:
          'Con hojas de maíz (o papel), haz una muñequita guardiana de la cosecha. Guárdala hasta la próxima siembra'
    ),
    (
      title: 'Comparte la abundancia',
      description:
          'Separa alimentos para donar. La cosecha crece cuando se comparte'
    ),
    (
      title: 'Ofrece el primer trozo',
      description:
          'Ofrece el primer trozo del pan a la Tierra (en una maceta o jardín), agradeciendo el sacrificio que genera abundancia'
    ),
  ],
  'sabbat_mabon': [
    (
      title: 'Monta la cornucopia de gratitud',
      description:
          'En una cesta o plato, acomoda manzanas, uvas, nueces y calabazas. Con cada elemento, di una cosa por la que estás agradecida'
    ),
    (
      title: 'Haz el balance del año',
      description:
          'Escribe lo que salió bien y lo que pesó. Mabon es el equilibrio: mira ambos lados sin juicio'
    ),
    (
      title: 'Libera lo que no sigue',
      description:
          'Escribe en un papel lo que liberas en este cambio de ciclo. Quémalo con seguridad (o rómpelo y deséchalo), agradeciendo la lección'
    ),
    (
      title: 'Conserva los sabores',
      description:
          'Prepara una mermelada, un té o congela frutas. Guardar alimento es magia de previsión para el invierno'
    ),
    (
      title: 'Enciende velas de otoño',
      description:
          'Enciende velas naranjas o marrones y medita sobre la belleza de soltar — como los árboles sueltan las hojas'
    ),
  ],
  'full_moon': [
    (
      title: 'Prepara el espacio bajo la luz de la luna',
      description:
          'Si es posible, quédate donde llegue la luz de la luna (ventana, balcón, patio). Enciende una vela blanca o plateada'
    ),
    (
      title: 'Pon el Agua de Luna a preparar',
      description:
          'Llena una jarra o botella con agua y tápala. Déjala bajo la luz de la luna — la recoges antes del amanecer. (¡Hay un ritual guiado solo para esto!)'
    ),
    (
      title: 'Carga cristales e instrumentos',
      description:
          'Deja cristales, barajas, péndulos y joyas bajo los rayos de la luna para limpiar y recargar su energía'
    ),
    (
      title: 'Manifiesta tus intenciones',
      description:
          'Relee (o recuerda) las intenciones plantadas en la luna nueva. Agradece lo que ya floreció y visualiza el resto realizándose'
    ),
    (
      title: 'Practica la adivinación',
      description:
          'La luna llena potencia la intuición: saca cartas de tarot u oráculo, tira las runas o consulta el péndulo'
    ),
    (
      title: 'Haz un amuleto de protección',
      description:
          'Deja un collar, anillo o piedrita absorbiendo la luz de la luna y conságralo como tu amuleto: "que esta luna te cargue de protección"'
    ),
    (
      title: 'Cierra con gratitud',
      description:
          'Agradece a la Luna, apaga la vela y, si cosechaste hierbas hoy, cuélgalas para secar — en esta fase es más fácil deshidratarlas'
    ),
  ],
  'new_moon': [
    (
      title: 'Crea un espacio silencioso',
      description:
          'Apaga las luces fuertes, enciende una única vela y respira profundo algunas veces. La luna nueva pide recogimiento'
    ),
    (
      title: 'Limpia la energía',
      description:
          'Pasa un incienso o visualiza una luz barriendo el ambiente y tu cuerpo, llevándose el ciclo que terminó'
    ),
    (
      title: 'Escribe tus intenciones',
      description:
          'Escribe en papel lo que quieres plantar en este ciclo: sé específica y escribe en presente, como si ya fuera real'
    ),
    (
      title: 'Planta simbólicamente',
      description:
          'Dobla el papel y colócalo bajo una maceta, dentro de una cajita o junto a una semilla plantada de verdad'
    ),
    (
      title: 'Visualiza el crecimiento',
      description:
          'Con los ojos cerrados, visualiza cada intención creciendo junto con la luna hasta la luna llena. Siéntelo como si ya hubiera sucedido'
    ),
    (
      title: 'Sella el ritual',
      description:
          'Agradece, apaga la vela y guarda el papel. Reencuéntralo en la luna llena para celebrar lo que ya se movió'
    ),
  ],
  'moon_water': [
    (
      title: 'Elige y lava el recipiente',
      description:
          'Usa una jarra, botella o frasco de vidrio bien limpio. Si quieres, lávalo con agua y sal y enjuágalo bien'
    ),
    (
      title: 'Llénalo con agua',
      description:
          'Agua potable si piensas beberla; agua común si es solo para uso mágico (baños, limpiezas, plantas)'
    ),
    (
      title: 'Tapa el recipiente',
      description:
          'Tapar protege el agua de la suciedad y mantiene la intención sellada. Vidrio tapado es la forma tradicional'
    ),
    (
      title: 'Declara la intención',
      description:
          'Sostén el recipiente y di para qué servirá esta agua: limpieza, sanación, intuición, protección... El agua guarda el mensaje'
    ),
    (
      title: 'Déjala bajo la luz de la luna',
      description:
          'Colócala donde llegue la luz de la luna (ventana, balcón, patio) por al menos algunas horas de la noche'
    ),
    (
      title: 'Recógela antes del amanecer',
      description:
          'Guarda el agua antes del amanecer para que no reciba energía solar. Etiquétala con la fecha y la intención'
    ),
  ],
  'sun_water': [
    (
      title: 'Elige un día de sol fuerte',
      description:
          'Cuanto más claro el día, más vitalidad carga el agua. Las mañanas son ideales: su energía es de comienzo y expansión'
    ),
    (
      title: 'Prepara el recipiente',
      description:
          'Vidrio limpio y transparente, de preferencia. Llénalo con agua potable si vas a beberla, o común para uso mágico'
    ),
    (
      title: 'Declara la intención',
      description:
          'Sostén el frasco al sol y di lo que necesitas: coraje, alegría, fuerza, creatividad. El Sol es generoso con quien pide'
    ),
    (
      title: 'Déjala al sol de 3 a 6 horas',
      description:
          'No necesita el día entero: de media mañana a media tarde ya la carga bien. Tápala para protegerla'
    ),
    (
      title: 'Recógela antes del atardecer',
      description:
          'Guarda el agua con el sol aún en el cielo. Etiquétala con la fecha y úsala en los próximos días, mientras la energía está fresca'
    ),
  ],
};

const Map<String, List<String>> guidedRitualMaterialsEs = {
  'sabbat_samhain': [
    'Velas negra y naranja',
    'Fotos u objetos de seres queridos',
    'Incienso de salvia o romero',
    'Ofrenda simple (agua, pan o fruta)',
    'Tarot, runas o péndulo (opcional)',
  ],
  'sabbat_yule': [
    'Velas doradas, rojas o blancas',
    'Piñas, ramas, canela, frutas secas',
    'Romero y canela para el baño',
    'Bebida caliente para compartir',
  ],
  'sabbat_imbolc': [
    'Vela blanca, amarilla o roja',
    'Escoba (ritual o común)',
    'Incienso de lavanda o manzanilla',
    'Semillas o papel para intenciones',
    'Leche y miel (para el baño, opcional)',
  ],
  'sabbat_ostara': [
    'Flores frescas y semillas',
    'Huevos (o piedritas) y pinturas',
    'Velas blanca y negra',
    'Bolsita, albahaca, menta y una moneda',
  ],
  'sabbat_beltane': [
    'Flores rojas y coloridas',
    'Velas rojas',
    'Miel, leche o flores para la ofrenda',
    'Papel y bolígrafo para la carta de amor',
    'Cuarzo rosa (opcional)',
  ],
  'sabbat_litha': [
    'Hierbas para cosechar o secar (manzanilla, lavanda)',
    'Sal o romero para el círculo',
    'Cristales y amuletos para cargar',
    'Frutas frescas y flores amarillas',
  ],
  'sabbat_lammas': [
    'Pan (horneado o comprado)',
    'Hojas de maíz o papel para la muñeca',
    'Papel y bolígrafo para la lista de logros',
    'Alimentos para donar',
  ],
  'sabbat_mabon': [
    'Manzanas, uvas, nueces, calabaza',
    'Papel y bolígrafo para el balance',
    'Velas naranjas o marrones',
    'Frascos para conservas o tés',
  ],
  'full_moon': [
    'Vela blanca o plateada',
    'Jarra o botella con tapa (agua de luna)',
    'Cristales, joyas e instrumentos para cargar',
    'Tarot, runas o péndulo (opcional)',
  ],
  'new_moon': [
    'Una vela',
    'Papel y bolígrafo',
    'Incienso (opcional)',
    'Una semilla o macetita (opcional)',
  ],
  'moon_water': [
    'Jarra, botella o frasco de vidrio con tapa',
    'Agua (potable, si vas a beberla)',
    'Etiqueta o cinta para rotular',
  ],
  'sun_water': [
    'Frasco o botella de vidrio transparente con tapa',
    'Agua (potable, si vas a beberla)',
    'Etiqueta o cinta para rotular',
  ],
};

const Map<String, List<String>> guidedRitualUsesEs = {
  'moon_water': [
    'Beberla para absorber la energía lunar (si el agua es potable)',
    'Usarla en hechizos y pociones en lugar de agua común',
    'Agregarla al baño para limpieza e intuición',
    'Regar las plantas para fortalecerlas',
    'Limpiar cristales e instrumentos mágicos',
    'Rociarla en los ambientes para renovar la energía',
  ],
  'sun_water': [
    'Beberla por la mañana para vitalidad (si el agua es potable)',
    'Usarla en hechizos de energía, coraje y éxito',
    'Agregarla al baño antes de desafíos importantes',
    'Rociarla en el espacio de trabajo o estudio',
    'Regar plantas que aman el sol',
  ],
};

const Map<String, List<String>> guidedRitualCrystalsEs = {
  'full_moon': ['Selenita', 'Piedra luna', 'Cuarzo transparente', 'Amatista'],
  'new_moon': ['Obsidiana', 'Turmalina negra', 'Labradorita', 'Ónix'],
  'moon_water': ['Selenita', 'Piedra luna', 'Cuarzo transparente'],
  'sun_water': ['Citrino', 'Ojo de tigre', 'Ámbar', 'Cornalina'],
};

const Map<String, List<String>> guidedRitualHerbsEs = {
  'full_moon': ['Artemisa', 'Jazmín', 'Lavanda', 'Manzanilla'],
  'new_moon': ['Salvia', 'Romero', 'Menta'],
  'moon_water': ['Jazmín', 'Artemisa', 'Lavanda'],
  'sun_water': ['Romero', 'Manzanilla', 'Caléndula', 'Girasol (pétalos)'],
};
