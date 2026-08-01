import '../models/altar_content_model.dart';

/// Contenido de la página "El Altar Mágico" — español.
///
/// Los emojis y el orden/recuento de las listas son invariantes entre
/// idiomas. Mantén la misma estructura en los tres archivos
/// (`altar_content_pt/en/es.dart`) — la paridad se verifica en
/// `test/encyclopedia_content_parity_test.dart`.
const AltarContent altarContentEs = AltarContent(
  pageTitle: 'El Altar Mágico',
  introTitle: 'Sobre el Altar',
  introBody:
      'Un altar es tu espacio sagrado personal - un punto focal para tu práctica mágica. '
      'No necesita ser elaborado ni caro; lo que importa es la intención y el respeto con que lo tratas. '
      'Tu altar es una extensión de tu energía y un portal entre el mundo físico y el espiritual',
  introHint:
      'Explora las secciones de abajo para aprender a montar, purificar, mantener y utilizar tu altar',
  beginnerTitle: 'Paso a Paso para Principiantes',
  beginnerSubtitle: 'Tu primer encuentro con tu altar',
  beginnerIntro:
      'No te preocupes si no tienes todos los objetos "tradicionales". '
      'Un altar puede empezar con una vela y una intención. Lo importante es que '
      'sea significativo para TI. No existe altar equivocado cuando se hace con el corazón',
  beginnerSteps: [
    AltarNumberedStep(
      'Elige el Lugar',
      'Un rinconcito donde no te molesten. Puede ser una mesita, una repisa, o incluso una caja que abres cuando vas a practicar',
      '¡No necesita ser grande! Un espacio de 30x30cm ya es suficiente',
    ),
    AltarNumberedStep(
      'Limpia el Espacio',
      'Limpia físicamente con un paño, luego pasa humo de incienso o visualiza una luz blanca purificando',
      'Di: "Que este espacio sea purificado y bendecido"',
    ),
    AltarNumberedStep(
      'Añade una Vela',
      'La vela es el corazón del altar - representa el fuego y la luz divina. Una única vela blanca ya es suficiente',
      'Las velas blancas son universales y pueden sustituir cualquier color',
    ),
    AltarNumberedStep(
      'Añade Objetos Significativos',
      'Coloca lo que tiene significado para ti: una foto de ancestros, un cristal que te regalaron, flores, una concha de la playa',
      'Empieza con 3-5 objetos y ve añadiendo con el tiempo',
    ),
    AltarNumberedStep(
      'Consagra tu Altar',
      'Enciende la vela, respira hondo y di: "Consagro este altar como mi espacio sagrado. Que sea un portal de conexión"',
      '¡Usa tus propias palabras! Lo importante es la intención',
    ),
  ],
  firstTimesTitle: '🌟 En las primeras veces en el altar',
  firstTimesItems: [
    '1. Enciende la vela con intención, observa la llama',
    '2. Haz 3 respiraciones profundas para centrarte',
    '3. Agradece por el día, por la vida, por algo bueno',
    '4. Define una intención: "Hoy pido/agradezco..."',
    '5. Quédate unos minutos en silencio o conversa',
    '6. Cierra: "Agradezco la conexión. Que así sea"',
  ],
  speakTitle: '💬 ¿Qué decir en el altar?',
  speakExamples: [
    AltarSpeech('Para abrir:',
        '"Enciendo esta vela como símbolo de mi conexión con lo sagrado"'),
    AltarSpeech('Para pedir:',
        '"Pido orientación para [situación]. Que la sabiduría ilumine mi camino"'),
    AltarSpeech('Para agradecer:',
        '"Agradezco por [bendición específica]. Mi corazón está lleno de gratitud"'),
    AltarSpeech('Para cerrar:',
        '"Agradezco la conexión. Que la magia continúe conmigo. Así sea"'),
  ],
  speakNote:
      'Recuerda: no existe fórmula equivocada. ¡El universo entiende tu intención!',
  faqTitle: '❓ Dudas Comunes de Principiantes',
  faqs: [
    AltarFaq('¿Puedo tener un altar secreto?',
        '¡Sí! Usa una caja que abres cuando vas a practicar'),
    AltarFaq('¿Necesito ir al altar todos los días?',
        'No hay regla. Ve cuando sientas el llamado. Una rutina fortalece, pero no es obligatoria'),
    AltarFaq('¿Puedo mover las cosas?',
        '¡Sí! El altar está vivo y debe cambiar contigo'),
    AltarFaq('¿Y si olvido las palabras?',
        '¡Improvisa! A lo divino no le importan las palabras perfectas'),
  ],
  mountTitle: 'Cómo Montar tu Altar',
  mountSteps: [
    AltarStep(
      '1. Elige el lugar',
      'Selecciona un espacio tranquilo donde puedas tener privacidad. '
          'Puede ser una mesa, repisa, cómoda o incluso un rincón de tu habitación. '
          'Evita baños y lavaderos (puntos de salida de energía)',
    ),
    AltarStep(
      '2. Limpia el espacio',
      'Limpia físicamente la superficie y energéticamente con humo de hierbas '
          '(romero, ruda, salvia) o rocía agua con sal',
    ),
    AltarStep(
      '3. Usa un mantel o tela',
      'Opcional, pero recomendado. Usa colores que resuenen contigo: '
          'negro (protección), blanco (pureza), morado (espiritualidad), verde (sanación)',
    ),
    AltarStep(
      '4. Representa los 4 elementos',
      'Cada elemento trae una energía esencial al altar:\n\n'
          '🌍 Tierra (Norte): Cristales, sal, piedras, plantas, pentáculo\n'
          '💧 Agua (Oeste): Copa con agua, conchas, agua lunar\n'
          '🔥 Fuego (Sur): Vela, caldero, athame\n'
          '💨 Aire (Este): Incienso, plumas, campanas, varita\n\n'
          '💡 Consejo: Coloca cada elemento en la dirección cardinal correspondiente cuando sea posible',
    ),
    AltarStep(
      '5. Añade objetos personales',
      'Imágenes de divinidades, fotos de ancestros, símbolos que tienen sentido para ti, '
          'herramientas mágicas (athame, caldero, varita), libro de las sombras',
    ),
  ],
  itemsTitle: 'Qué Usar en el Altar',
  items: [
    AltarEmojiItem('🕯️', 'Velas',
        'Representan el elemento Fuego y la luz divina. Usa colores correspondientes a tus intenciones'),
    AltarEmojiItem('💎', 'Cristales',
        'Amplifican energía y traen propiedades específicas (cuarzo rosa para el amor, amatista para la espiritualidad)'),
    AltarEmojiItem('🌿', 'Hierbas',
        'Secas o frescas, cada hierba tiene correspondencias mágicas únicas'),
    AltarEmojiItem('🔮', 'Objetos simbólicos',
        'Pentáculo, símbolos lunares, runas, tarot, estatuillas de divinidades'),
    AltarEmojiItem('💧', 'Copa con agua',
        'Elemento Agua, puede cambiarse regularmente o usarse en rituales'),
    AltarEmojiItem(
        '🧂', 'Sal', 'Purificación y protección, representa la Tierra'),
    AltarEmojiItem('📿', 'Incienso',
        'Elemento Aire, limpia la energía y eleva las vibraciones'),
    AltarEmojiItem('📖', 'Grimorio',
        'Tu libro de las sombras o diario de prácticas'),
    AltarEmojiItem('🌙', 'Objetos lunares',
        'Representaciones de la luna, agua lunar, calendario lunar'),
    AltarEmojiItem('🪶', 'Plumas', 'Elemento Aire, conexión con lo divino'),
  ],
  itemsNote:
      '💡 Recuerda: no existe lista obligatoria. Usa lo que resuene contigo y con tu práctica',
  avoidTitle: 'Qué Evitar en el Altar',
  avoidItems: [
    AltarStep('Objetos de energía negativa',
        'Objetos que traigan malos recuerdos o sensaciones incómodas'),
    AltarStep('Exceso de objetos',
        'Un altar abarrotado dispersa la energía. Mantenlo organizado e intencional'),
    AltarStep('Objetos prestados sin permiso',
        'Cada objeto lleva la energía de su dueño'),
    AltarStep('Basura o suciedad',
        'Mantén tu altar limpio física y energéticamente'),
    AltarStep('Objetos ajenos a tu práctica',
        'No coloques símbolos de tradiciones que no practicas por moda'),
    AltarStep('Plantas muertas',
        'Retira hojas secas y plantas muertas regularmente'),
  ],
  safetyNote:
      'SEGURIDAD: Nunca dejes velas encendidas sin supervisión. Mantén materiales inflamables lejos de las llamas',
  purifyTitle: 'Cómo Purificar tu Altar',
  purifyIntro:
      'La purificación remueve energías estancadas o negativas, renovando el espacio sagrado',
  purifyMethods: [
    AltarEmojiItem('🔥', 'Sahumado',
        'Usa romero, ruda, salvia o palo santo. Pasa el humo por todo el altar y los objetos con intención de limpieza'),
    AltarEmojiItem('💧', 'Agua y sal',
        'Rocía agua con sal gruesa (o agua lunar) por el espacio. Cuidado con los objetos que no pueden mojarse'),
    AltarEmojiItem('🔔', 'Sonido',
        'Usa campanas, cuencos tibetanos o palmadas para romper la energía estancada'),
    AltarEmojiItem('🌙', 'Luz de la luna',
        'Deja los objetos bajo la luz de la luna llena para una limpieza energética profunda'),
    AltarEmojiItem('🧘', 'Visualización',
        'Visualiza luz blanca o dorada llenando el altar y disolviendo energías densas'),
  ],
  purifyFrequency:
      '🌙 Frecuencia recomendada: En cada luna nueva o llena, o cuando sientas la energía pesada',
  maintainTitle: 'Cómo Mantener tu Altar',
  maintainItems: [
    AltarStep('Limpieza física regular',
        'Quita el polvo, limpia superficies, organiza objetos. Idealmente en luna menguante'),
    AltarStep('Cambia las ofrendas',
        'Si dejas ofrendas (flores, alimentos, agua), cámbialas antes de que se estropeen'),
    AltarStep('Recarga los cristales',
        'Limpia y recarga los cristales regularmente (luna, sol, tierra, humo)'),
    AltarStep('Actualiza según las estaciones',
        'Adapta decoraciones y elementos estacionales (Sabbats, solsticios, equinoccios)'),
    AltarStep('Visítalo a diario',
        'Aunque sea brevemente. Enciende una vela, agradece, medita. Mantén la energía viva'),
    AltarStep('Reorganiza cuando sea necesario',
        'Tu altar puede evolucionar contigo. Retira lo que ya no resuena, añade lo nuevo'),
    AltarStep('Protégelo energéticamente',
        'Renueva las protecciones regularmente con sal alrededor, visualizaciones o sigilos'),
  ],
  usageTitle: 'Cómo Utilizar tu Altar',
  usageItems: [
    AltarStep('Meditación y conexión',
        'Siéntate frente al altar para meditar, centrarte y conectarte con lo divino'),
    AltarStep('Hechizos y rituales',
        'Úsalo como espacio de trabajo mágico. Enciende velas, prepara pociones, consagra herramientas'),
    AltarStep('Ofrendas y agradecimientos',
        'Deja ofrendas para divinidades, ancestros o espíritus que honras'),
    AltarStep('Celebraciones estacionales',
        'Decora y celebra Sabbats, lunas llenas y equinoccios en el altar'),
    AltarStep('Carga de objetos',
        'Deja objetos (talismanes, joyas, cristales) en el altar para cargarlos de energía'),
    AltarStep('Adivinación',
        'Practica tarot, runas, péndulo u otras formas de adivinación en el altar'),
    AltarStep('Punto focal diario',
        'Comienza o termina el día en el altar, definiendo intenciones o reflexionando'),
  ],
  routineTitle: '💚 Sugerencia de rutina diaria:',
  routineBody: '• Mañana: Enciende una vela, define la intención del día\n'
      '• Tarde: Momento de gratitud o reflexión breve\n'
      '• Noche: Agradece por el día, apaga la vela con reverencia',
  finalTitle: 'Consideraciones Finales',
  finalBody:
      'Tu altar es una expresión personal de tu espiritualidad. No existe forma "correcta" o "incorrecta" - '
      'lo que importa es que sea significativo para TI. '
      '\n\nUn altar sencillo con tres velas y un cristal cargado de intención es más poderoso '
      'que un altar elaborado sin conexión emocional. '
      '\n\nPermite que tu altar crezca orgánicamente, refleje tus cambios y sea siempre un espacio de paz, '
      'poder y conexión con lo sagrado',
);
