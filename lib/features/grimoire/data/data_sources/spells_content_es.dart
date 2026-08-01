import '../repositories/spell_repository.dart';
import 'spell_localizer.dart';

/// Spanish overlays for the 65 preloaded spells.
///
/// Keys are computed with the SAME Portuguese seed names from
/// `spells_data.dart`, so they always match the `preloaded_*` slug ids
/// stored in SQLite. Only display text is translated here — identity and
/// structure live exclusively in the PT seed.
final Map<String, SpellContentOverlay> spellOverlaysEs = {
  // ============================================
  // AMOR Y ROMANCE
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Rosa para Atrair Amor'):
      const SpellContentOverlay(
    name: 'Vela Rosa para Atraer el Amor',
    purpose: 'Atraer amor romántico',
    ingredients: [
      '1 vela rosa',
      'Aceite de rosa o rosa mosqueta',
      'Pétalos de rosa secos',
      'Cuarzo rosa',
    ],
    steps: '''1. Limpia tu espacio con humo de incienso o hierbas
2. Unge la vela con el aceite, del centro hacia los extremos
3. Rueda la vela sobre los pétalos de rosa
4. Coloca el cuarzo rosa junto a la vela
5. Enciende la vela visualizando el amor llegando a ti
6. Di: "Amor verdadero, ven a mí, con respeto y reciprocidad"
7. Deja que la vela se consuma por completo
8. Lleva el cuarzo rosa contigo''',
    observations:
        'Mejor hacerlo un viernes (día de Venus). Mantén el corazón abierto a nuevas posibilidades',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Rosas para Amor'):
      const SpellContentOverlay(
    name: 'Baño de Rosas para el Amor',
    purpose: 'Atraer el amor y abrir el corazón',
    ingredients: [
      'Pétalos de rosa (blancas, rojas o rosadas)',
      'Miel',
      'Canela en rama',
      'Agua tibia',
    ],
    steps: '''1. Prepara un baño tibio
2. Agrega pétalos de rosa, 1 cucharada de miel y canela
3. Entra al agua y relájate
4. Visualízate irradiando amor y siendo amado(a)
5. Di: "Abro mi corazón al amor verdadero"
6. Sumérgete 3 veces
7. Deja que tu piel se seque de forma natural''',
    observations:
        'Puede hacerse en luna llena o creciente. Excelente para abrir el corazón después de una herida',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Sache de Amor'):
      const SpellContentOverlay(
    name: 'Saquito de Amor',
    purpose: 'Llevar contigo energía de amor',
    ingredients: [
      'Saquito rosa o rojo',
      'Pétalos de rosa',
      'Lavanda',
      'Cuarzo rosa pequeño',
      'Canela',
      'Papel y bolígrafo',
    ],
    steps: '''1. Escribe en el papel las cualidades que buscas en un amor
2. Dobla el papel hacia adentro (atrayendo)
3. Colócalo en el saquito con las hierbas y el cristal
4. Sostén el saquito entre las manos y visualiza el amor llegando
5. Di: "Este amor es mío, para el bien de todos y el mal de nadie"
6. Llévalo en el bolso o cerca de la cama
7. Recárgalo en luna llena''',
    observations:
        'Sustituye las hierbas cada 3 meses o cuando sientas que es necesario',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Feitiço do Espelho do Amor'):
      const SpellContentOverlay(
    name: 'Hechizo del Espejo del Amor',
    purpose: 'Reflejar el amor de vuelta hacia ti',
    ingredients: [
      'Espejo pequeño',
      'Vela rosa',
      'Aceite esencial de rosa',
      'Una foto tuya',
    ],
    steps: '''1. En luna llena, limpia el espejo
2. Unge la vela con aceite de rosa
3. Coloca tu foto frente al espejo
4. Enciende la vela
5. Mírate en el espejo y di: "Soy digno(a) de amor, merezco amor, atraigo amor"
6. Deja que la vela se consuma
7. Guarda el espejo en un lugar especial''',
    observations:
        'Este hechizo trabaja el amor propio y la atracción al mismo tiempo',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Mel para Adoçar Relacionamento'):
      const SpellContentOverlay(
    name: 'Miel para Endulzar la Relación',
    purpose: 'Endulzar una relación existente',
    ingredients: [
      'Tarro de miel',
      'Papel y bolígrafo rojo',
      'Canela en polvo',
      '2 velas rojas pequeñas',
    ],
    steps: '''1. Escribe tu nombre y el nombre de la persona en el papel
2. Coloca el papel en el fondo de un cuenco
3. Cúbrelo con miel y espolvorea canela
4. Coloca las velas a los lados
5. Enciéndelas y di: "Que nuestra relación sea dulce como esta miel"
6. Deja que se consuman
7. Entierra los restos en un jardín''',
    observations:
        'Solo para relaciones que ya existen. No funciona contra el libre albedrío',
  ),

  // ============================================
  // AMOR PROPIO
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Ritual do Espelho'):
      const SpellContentOverlay(
    name: 'Ritual del Espejo',
    purpose: 'Fortalecer el amor propio',
    ingredients: [
      'Espejo',
      'Vela rosa',
      'Cuarzo rosa',
    ],
    steps: '''1. Enciende la vela rosa
2. Sostén el cuarzo rosa
3. Mírate en el espejo
4. Di afirmaciones positivas sobre ti
5. "Me amo", "Soy suficiente", "Merezco felicidad"
6. Hazlo durante 5-10 minutos
7. Repite a diario durante una semana''',
    observations:
        'Puede parecer extraño al principio, pero con constancia es transformador',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Amor Próprio'):
      const SpellContentOverlay(
    name: 'Baño de Amor Propio',
    purpose: 'Nutrirte y amarte a ti mismo',
    ingredients: [
      'Sal rosa del Himalaya',
      'Pétalos de rosa',
      'Lavanda',
      'Miel',
      'Aceite esencial de naranja',
    ],
    steps: '''1. Prepara un baño tibio
2. Agrega la sal rosa, los pétalos, la lavanda, la miel y el aceite
3. Entra al agua
4. Coloca las manos sobre el corazón
5. Respira y visualiza una luz rosa envolviéndote
6. Di: "Me amo y me acepto completamente"
7. Relájate durante 20 minutos
8. Deja que tu piel se seque de forma natural''',
    observations:
        'Hazlo siempre que necesites reconectar contigo mismo',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Frasco de Amor Próprio'):
      const SpellContentOverlay(
    name: 'Frasco de Amor Propio',
    purpose: 'Guardar energía de amor propio',
    ingredients: [
      'Frasco de vidrio con tapa',
      'Sal rosa',
      'Pétalos de rosa',
      'Cuarzo rosa pequeño',
      'Canela',
      'Papel y bolígrafo rosa',
    ],
    steps: '''1. Escribe cualidades que amas de ti mismo
2. Colócalas en el frasco
3. Agrega la sal, los pétalos, el cuarzo y la canela
4. Sostén el frasco e infúndelo con amor
5. Di: "Soy amor, soy luz, soy suficiente"
6. Ciérralo y mantenlo en un lugar visible
7. Sostenlo siempre que necesites fuerza''',
    observations:
        'Añade nuevos papeles con cualidades cada vez que descubras algo más de ti',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Lista de Gratidão'):
      const SpellContentOverlay(
    name: 'Lista de Gratitud',
    purpose: 'Cultivar amor por ti a través de la gratitud',
    ingredients: [
      'Cuaderno bonito',
      'Bolígrafo que te guste',
      'Vela rosa o dorada',
    ],
    steps: '''1. Enciende la vela
2. Abre el cuaderno
3. Escribe 10 cosas que te gustan de ti
4. Escribe 10 cosas que tu cuerpo hace por ti
5. Escribe 10 logros tuyos (pequeños o grandes)
6. Léelos en voz alta
7. Agradécete a ti mismo
8. Repite cada semana''',
    observations:
        'La gratitud transforma la percepción que tenemos de nosotros mismos',
  ),

  // ============================================
  // PROTECCIÓN
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Círculo de Sal'):
      const SpellContentOverlay(
    name: 'Círculo de Sal',
    purpose: 'Protección básica del espacio',
    ingredients: [
      'Sal gruesa o sal marina',
    ],
    steps: '''1. Camina por el perímetro del espacio
2. Esparce la sal mientras visualizas una barrera de luz
3. Di: "Este espacio está protegido, solo el amor y la luz pueden entrar"
4. Repite en las esquinas del ambiente
5. Renueva cada mes o cuando sientas que es necesario''',
    observations:
        'La protección más simple y poderosa. Funciona para la casa, la habitación o el altar',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Sache de Proteção'):
      const SpellContentOverlay(
    name: 'Saquito de Protección',
    purpose: 'Protección personal portátil',
    ingredients: [
      'Saquito negro o rojo',
      'Romero',
      'Ruda (manipúlala con cuidado)',
      'Sal gruesa',
      'Turmalina negra u obsidiana',
      'Diente de ajo',
    ],
    steps: '''1. Coloca todos los ingredientes en el saquito
2. Sostenlo entre las manos
3. Visualiza un escudo protector a tu alrededor
4. Di: "La protección va siempre conmigo, ningún mal me alcanzará"
5. Llévalo en el bolso o la mochila
6. Renuévalo en cada luna nueva''',
    observations:
        'Mantenlo lejos de niños y animales (la ruda es tóxica)',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Proteção'):
      const SpellContentOverlay(
    name: 'Baño de Protección',
    purpose: 'Limpiar y proteger la energía personal',
    ingredients: [
      'Sal gruesa',
      'Romero',
      'Ruda',
      'Anamú',
      'Agua',
    ],
    steps: '''1. Hierve las hierbas en agua durante 10 minutos
2. Cuela y deja enfriar
3. Después del baño normal, viértelo del cuello hacia abajo
4. Visualiza las energías negativas yéndose
5. Di: "Estoy limpio y protegido"
6. No te seques, deja que tu piel se seque de forma natural''',
    observations:
        'Hazlo después de situaciones pesadas o semanalmente como mantenimiento',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Garrafa de Bruxa'):
      const SpellContentOverlay(
    name: 'Botella de Bruja',
    purpose: 'Protección permanente de la casa',
    ingredients: [
      'Frasco de vidrio con tapa',
      'Clavos, alfileres, agujas',
      'Sal gruesa',
      'Pimienta negra',
      'Ajo',
      'Romero',
      'Tu orina (tradicional) o vinagre',
    ],
    steps: '''1. Coloca los objetos puntiagudos en el frasco
2. Agrega la sal, la pimienta, el ajo y el romero
3. Añade el líquido hasta llenarlo
4. Ciérralo bien y agítalo
5. Di: "Esta casa está protegida"
6. Entiérralo en la entrada de la casa o escóndelo cerca de la puerta
7. Nunca lo abras''',
    observations:
        'Protección tradicional muy poderosa. Dura años',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vassoura de Proteção'):
      const SpellContentOverlay(
    name: 'Escoba de Protección',
    purpose: 'Barrer energías negativas',
    ingredients: [
      'Escoba (puede ser común)',
      'Romero fresco',
      'Sal gruesa',
    ],
    steps: '''1. Ata romero al mango de la escoba
2. Esparce sal por el suelo
3. Barre desde la puerta de entrada hacia adentro
4. Barre cada habitación en sentido antihorario
5. Di: "Barro toda la negatividad de esta casa"
6. Recoge la sal y tírala lejos de casa
7. Guarda la escoba detrás de la puerta''',
    observations:
        'Hazlo después de visitas pesadas o discusiones en casa',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Pentagrama de Proteção'):
      const SpellContentOverlay(
    name: 'Pentagrama de Protección',
    purpose: 'Protección energética personal',
    ingredients: [
      'Dedo índice o athame (cuchillo ritual)',
      'Visualización',
    ],
    steps: '''1. De pie, respira hondo 3 veces
2. Con el dedo índice, dibuja un pentagrama brillante en el aire frente a ti
3. Comienza en la punta superior, baja a la izquierda, sube a la derecha, cruza hacia la izquierda, baja a la derecha y vuelve a la punta superior
4. Visualízalo brillando en azul o blanco
5. Di: "Estoy protegido por este símbolo sagrado"
6. Dibuja uno en cada dirección (norte, sur, este, oeste)
7. Siéntete envuelto en protección''',
    observations:
        'Puede hacerse mentalmente en cualquier lugar cuando sientas la necesidad',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Proteção com Espelho'):
      const SpellContentOverlay(
    name: 'Protección con Espejo',
    purpose: 'Reflejar las energías negativas de vuelta',
    ingredients: [
      'Espejo pequeño',
      'Vela negra',
      'Sal gruesa',
      'Romero',
    ],
    steps: '''1. Limpia el espejo con agua y sal
2. Coloca el espejo mirando hacia afuera en una ventana o puerta
3. Enciende la vela negra al lado
4. Pon sal y romero alrededor
5. Di: "Que toda negatividad sea reflejada de vuelta a su origen, transformada en luz"
6. Deja que la vela se consuma''',
    observations:
        'El espejo siempre mirando hacia afuera, nunca hacia el interior de la casa',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Óleo de Proteção'):
      const SpellContentOverlay(
    name: 'Aceite de Protección',
    purpose: 'Unción protectora',
    ingredients: [
      'Aceite base (almendras o jojoba)',
      'Romero',
      'Clavo de olor',
      'Canela',
      'Pimienta negra',
      'Frasco de vidrio oscuro',
    ],
    steps: '''1. Coloca las hierbas en el frasco
2. Cúbrelas con el aceite
3. Agita mientras visualizas protección
4. Di: "Este aceite me protege de todo mal"
5. Déjalo en la ventana durante la luna menguante por 3 noches
6. Cuela y úsalo para ungir velas, puertas, ventanas o a ti mismo''',
    observations:
        'Es duradero. Guárdalo en un lugar fresco y oscuro',
  ),

  // ============================================
  // PROSPERIDAD
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Folha de Louro dos Desejos'):
      const SpellContentOverlay(
    name: 'Hoja de Laurel de los Deseos',
    purpose: 'Manifestar prosperidad',
    ingredients: [
      'Hojas de laurel secas',
      'Bolígrafo o palillo',
      'Recipiente resistente al fuego',
    ],
    steps: '''1. Escribe en la hoja de laurel lo que deseas manifestar
2. Puede ser una cantidad, una oportunidad o "prosperidad"
3. Sostén la hoja y visualiza tu deseo cumplido
4. Siente la gratitud de haberlo recibido ya
5. Quema la hoja con cuidado
6. Di: "Mi prosperidad crece cada día"
7. Deja que el viento se lleve las cenizas o arrójalas a agua corriente''',
    observations:
        'Puede hacerse siempre que lo necesites. Confía en los tiempos del universo',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Manjericão'):
      const SpellContentOverlay(
    name: 'Baño de Albahaca',
    purpose: 'Atraer prosperidad y abrir caminos',
    ingredients: [
      'Albahaca fresca o seca',
      'Canela',
      'Miel',
      'Agua',
    ],
    steps: '''1. Hierve la albahaca y la canela en agua
2. Deja enfriar y agrega la miel
3. Después del baño normal, viértelo del cuello hacia abajo
4. Visualiza caminos abriéndose y dinero llegando
5. Di: "La prosperidad fluye hacia mí con facilidad"
6. Deja que tu piel se seque de forma natural''',
    observations:
        'Excelente antes de entrevistas o reuniones importantes',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vela Verde da Abundância'):
      const SpellContentOverlay(
    name: 'Vela Verde de la Abundancia',
    purpose: 'Atraer dinero y abundancia',
    ingredients: [
      'Vela verde',
      'Aceite de canela o aceite de cocina con canela',
      'Albahaca',
      'Moneda',
    ],
    steps: '''1. Unge la vela con el aceite, del centro hacia los extremos
2. Ruédala sobre albahaca seca
3. Coloca la moneda debajo de la vela
4. Enciéndela visualizando la abundancia fluyendo hacia ti
5. Di: "El dinero viene a mí en abundancia, con facilidad y alegría"
6. Deja que se consuma por completo
7. Lleva la moneda en la cartera''',
    observations:
        'Mejor en jueves (día de Júpiter). Repite cuando sientas la necesidad',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Frasco da Prosperidade'):
      const SpellContentOverlay(
    name: 'Frasco de la Prosperidad',
    purpose: 'Atraer y mantener la prosperidad',
    ingredients: [
      'Frasco de vidrio con tapa',
      'Monedas',
      'Arroz',
      'Canela',
      'Albahaca',
      'Citrino o pirita',
      'Papel verde',
    ],
    steps: '''1. Escribe en el papel tu objetivo financiero
2. Colócalo en el fondo del frasco
3. Agrega capas: monedas, arroz, hierbas, cristal
4. Llénalo hasta arriba
5. Sostén el frasco y visualiza abundancia
6. Di: "Mi prosperidad crece constantemente"
7. Mantenlo cerca de donde guardas el dinero
8. Añade monedas cada vez que recibas dinero''',
    observations:
        'Nunca lo abras ni retires nada. Es un imán permanente de prosperidad',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Carteira Magnetizada'):
      const SpellContentOverlay(
    name: 'Cartera Magnetizada',
    purpose: 'Atraer dinero a la cartera',
    ingredients: [
      'Tu cartera vacía',
      'Albahaca',
      'Canela',
      'Billete de dinero',
    ],
    steps: '''1. Limpia tu cartera
2. Pon dentro una pizca de albahaca y canela
3. Agrega el billete
4. Sostén la cartera y visualízala siempre llena
5. Di: "El dinero entra y se multiplica, siempre hay suficiente y más"
6. Nunca dejes la cartera completamente vacía
7. Mantén siempre al menos un billete''',
    observations:
        'Renueva las hierbas en cada luna nueva. El billete nunca debe gastarse',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Ritual da Chuva de Moedas'):
      const SpellContentOverlay(
    name: 'Ritual de la Lluvia de Monedas',
    purpose: 'Multiplicar el dinero',
    ingredients: [
      'Varias monedas',
      'Cuenco con agua',
      'Vela dorada o amarilla',
    ],
    steps: '''1. En luna llena, coloca el cuenco bajo la luz lunar
2. Enciende la vela al lado
3. Sostén las monedas en las manos
4. Visualiza el dinero multiplicándose
5. Arroja las monedas al agua una a una
6. Por cada moneda di: "Una se convierte en dos, dos se convierten en cuatro..."
7. Deja que el agua absorba la energía lunar
8. A la mañana siguiente, usa esa agua para regar plantas''',
    observations:
        'La prosperidad "crecerá" como las plantas. Las monedas pueden donarse',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Sigilo de Prosperidade'):
      const SpellContentOverlay(
    name: 'Sigilo de Prosperidad',
    purpose: 'Manifestar abundancia a través de símbolos',
    ingredients: [
      'Papel verde o dorado',
      'Bolígrafo dorado o verde',
      'Vela verde',
    ],
    steps: '''1. Escribe tu intención: "Soy próspero y abundante"
2. Elimina las letras repetidas
3. Crea un símbolo único con las letras restantes
4. Concéntrate en el sigilo y visualiza prosperidad
5. Enciende la vela
6. Quema el papel con el sigilo o guárdalo en la cartera
7. Olvídalo (deja que el universo trabaje)''',
    observations:
        'Técnica de magia del caos. Cuanto menos pienses en él después, mejor funciona',
  ),

  // ============================================
  // SANACIÓN
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Cura'):
      const SpellContentOverlay(
    name: 'Baño de Sanación',
    purpose: 'Sanación física y energética',
    ingredients: [
      'Sal gruesa o sal del Himalaya',
      'Romero',
      'Menta',
      'Eucalipto',
      'Manzanilla',
    ],
    steps: '''1. Hierve las hierbas en agua
2. Cuela y deja enfriar
3. Agrégalas al baño tibio con la sal
4. Entra al agua y relájate
5. Visualiza una luz verde sanadora envolviéndote
6. Di: "Mi cuerpo se sana, mi energía se renueva"
7. Quédate al menos 15 minutos
8. Deja que tu piel se seque de forma natural''',
    observations:
        'No sustituye el tratamiento médico. Complementa los procesos de sanación',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vela de Cura'):
      const SpellContentOverlay(
    name: 'Vela de Sanación',
    purpose: 'Enviar energía sanadora',
    ingredients: [
      'Vela azul o blanca',
      'Aceite de eucalipto o menta',
      'Cuarzo transparente o amatista',
      'Foto de la persona (o papel con su nombre)',
    ],
    steps: '''1. Limpia el cristal
2. Unge la vela con el aceite
3. Coloca la foto/papel debajo de la vela
4. Pon el cristal al lado
5. Enciende la vela
6. Visualiza una luz sanadora envolviendo a la persona
7. Di: "Que [nombre] sea sanado(a) para su mayor bien"
8. Deja que la vela se consuma por completo''',
    observations:
        'Pide siempre permiso antes de hacer magia para otros. Respeta el libre albedrío',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Chá Mágico de Cura'):
      const SpellContentOverlay(
    name: 'Té Mágico de Sanación',
    purpose: 'Poción de sanación interna',
    ingredients: [
      'Té de manzanilla',
      'Menta',
      'Jengibre',
      'Miel',
      'Limón',
    ],
    steps: '''1. Prepara el té con intención de sanar
2. Revuélvelo en sentido horario mientras lo haces
3. Agrega la miel y el limón
4. Sostén la taza entre las manos
5. Visualiza una luz dorada en el té
6. Di: "Esta poción me sana, célula a célula"
7. Bébelo lentamente con plena atención
8. Siente la sanación recorriendo tu cuerpo''',
    observations:
        'Puede hacerse a diario durante un proceso de sanación',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Grade de Cristais Curativa'):
      const SpellContentOverlay(
    name: 'Rejilla de Cristales Sanadora',
    purpose: 'Amplificar la sanación a través de cristales',
    ingredients: [
      '1 cuarzo transparente grande (centro)',
      '4 amatistas (esquinas)',
      '4 cuarzos rosas (lados)',
      'Foto tuya o del lugar del dolor',
    ],
    steps: '''1. Limpia todos los cristales
2. Coloca la foto en el centro
3. Posiciona el cuarzo transparente sobre la foto
4. Coloca las amatistas en las 4 esquinas (cuadrado)
5. Coloca los cuarzos rosas en los 4 lados (entre las amatistas)
6. Visualiza la luz fluyendo entre los cristales
7. Di: "Esta rejilla amplifica la sanación perfecta"
8. Déjala montada durante 3 días
9. Lleva el cristal central contigo''',
    observations:
        'Potente amplificador de energía sanadora. Recarga los cristales después de usarlos',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Poppet de Cura'):
      const SpellContentOverlay(
    name: 'Poppet de Sanación',
    purpose: 'Muñeco energético para sanar',
    ingredients: [
      'Tela blanca o verde',
      'Hilo y aguja',
      'Algodón para rellenar',
      'Hierbas sanadoras (manzanilla, romero)',
      'Pequeño cristal sanador',
      'Papel con nombre/foto',
    ],
    steps: '''1. Corta dos piezas de tela con forma humana
2. Cóselas dejando una abertura
3. Coloca dentro: algodón, hierbas, cristal, papel
4. Cose para cerrarlo
5. Sostén el poppet y visualiza sanación
6. Di: "Este muñeco representa a [nombre] en perfecta salud"
7. Guárdalo en un lugar seguro
8. Descóselo cuando la sanación se complete''',
    observations:
        'Técnica tradicional. Trata el poppet con cariño como si fuera la persona',
  ),

  // ============================================
  // LIMPIEZA ENERGÉTICA
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Defumação com Alecrim'):
      const SpellContentOverlay(
    name: 'Sahumerio de Romero',
    purpose: 'Limpiar las energías del ambiente',
    ingredients: [
      'Romero seco',
      'Carbón o recipiente resistente al fuego',
    ],
    steps: '''1. Enciende el romero (usa carbón si lo prefieres)
2. Deja que humee bien
3. Comienza por la puerta de entrada
4. Recorre todo el ambiente en sentido antihorario
5. Presta especial atención a las esquinas
6. Di: "Toda negatividad es desterrada, solo la luz permanece"
7. Abre las ventanas para que la energía salga
8. Deja que el romero se queme por completo''',
    observations:
        'Hazlo siempre que el ambiente esté pesado o después de discusiones',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Limpeza com Sálvia Branca'):
      const SpellContentOverlay(
    name: 'Limpieza con Salvia Blanca',
    purpose: 'Purificación profunda',
    ingredients: [
      'Salvia blanca (atado o smudge stick)',
      'Pluma (opcional)',
      'Recipiente resistente al fuego',
    ],
    steps: '''1. Abre las ventanas
2. Enciende la salvia
3. Usa la pluma para dirigir el humo
4. Límpiate a ti mismo primero (de arriba hacia abajo)
5. Luego limpia el ambiente (en sentido antihorario)
6. Di: "Con este humo sagrado, limpio y purifico"
7. Apágala presionándola contra arena o tierra''',
    observations:
        'Cómprala de fuentes éticas. La salvia blanca es sagrada para los pueblos indígenas',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Spray de Limpeza Lunar'):
      const SpellContentOverlay(
    name: 'Spray de Limpieza Lunar',
    purpose: 'Limpieza rápida y práctica',
    ingredients: [
      'Frasco con atomizador',
      'Agua de luna llena',
      'Sal marina',
      'Romero',
      'Lavanda',
      'Cristal de cuarzo',
    ],
    steps: '''1. En luna llena, coloca agua en un recipiente bajo la luna
2. Agrega una pizca de sal y las hierbas
3. Deja el cuarzo dentro
4. Por la mañana, cuela y vierte en el atomizador
5. Para usarlo: rocía el ambiente o rocíate a ti mismo
6. Di: "Estoy limpio y protegido"
7. Recarga el spray en la próxima luna llena''',
    observations:
        'Práctico para limpiezas rápidas. Mantenlo refrigerado',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Sal nos Cantos'):
      const SpellContentOverlay(
    name: 'Sal en las Esquinas',
    purpose: 'Limpiar y proteger el ambiente',
    ingredients: [
      'Sal gruesa',
    ],
    steps: '''1. Coloca una pizca de sal en cada esquina de la casa
2. Comienza por la puerta de entrada, avanza en sentido antihorario
3. En cada esquina di: "Este espacio está limpio y protegido"
4. Déjala 24 horas
5. Barre la sal y tírala (no la reutilices)
6. Lava el suelo con agua y vinagre''',
    observations:
        'Método simple y muy efectivo. Hazlo cada mes',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho de Descarrego Completo'):
      const SpellContentOverlay(
    name: 'Baño de Descarga Energética Completo',
    purpose: 'Limpiar energía personal pesada',
    ingredients: [
      'Sal gruesa',
      'Ruda',
      'Anamú',
      'Romero',
      'Lavanda',
      'Agua',
    ],
    steps: '''1. Hierve todas las hierbas en agua
2. Cuela y reserva
3. Toma tu baño normal
4. Vierte el baño de hierbas del cuello hacia abajo
5. Visualiza todo lo malo siendo lavado
6. Di 3 veces: "Estoy limpio, estoy renovado, estoy protegido"
7. Deja que tu piel se seque de forma natural
8. Ponte ropa limpia''',
    observations:
        'Para después de situaciones muy pesadas. Potente limpieza energética',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Limpeza com Som'):
      const SpellContentOverlay(
    name: 'Limpieza con Sonido',
    purpose: 'Limpiar con vibración sonora',
    ingredients: [
      'Campana, cuenco tibetano o palmas',
    ],
    steps: '''1. Comienza por la puerta de entrada
2. Toca la campana (o aplaude) en cada esquina
3. Continúa por todo el ambiente
4. La vibración rompe la energía estancada
5. Visualiza el sonido dispersando una niebla oscura
6. Di: "Con este sonido, limpio y renuevo este espacio"
7. Termina de nuevo en la puerta de entrada''',
    observations:
        'Método sin humo, ideal para quien tiene sensibilidad respiratoria',
  ),

  // ============================================
  // DESTIERRO
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Cebola de Banimento'):
      const SpellContentOverlay(
    name: 'Cebolla de Destierro',
    purpose: 'Absorber y desterrar la negatividad',
    ingredients: [
      'Cebolla morada grande',
      'Alfileres o clavos',
      'Sal gruesa',
    ],
    steps: '''1. Corta la cebolla por la mitad
2. Escribe en un papel el nombre de la persona/situación a desterrar
3. Coloca el papel entre las mitades
4. Únelas con alfileres
5. Entiérrala en un lugar alejado o tírala a una basura lejana
6. Di: "Como esta cebolla se pudre, así se va [situación/persona] de mi vida"
7. Lávate bien las manos
8. No mires atrás''',
    observations:
        'Solo para situaciones/personas tóxicas. Úsalo con responsabilidad',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vela Preta de Banimento'):
      const SpellContentOverlay(
    name: 'Vela Negra de Destierro',
    purpose: 'Desterrar a una persona o energía negativa',
    ingredients: [
      'Vela negra',
      'Papel y bolígrafo',
      'Ajo en polvo',
      'Pimienta negra',
      'Sal',
    ],
    steps: '''1. Escribe en el papel lo que deseas desterrar
2. Coloca el papel debajo de la vela
3. Rodéala con sal, ajo y pimienta
4. Enciende la vela
5. Visualiza la situación alejándose
6. Di: "Te libero, estás desterrado de mi vida"
7. Deja que se consuma por completo
8. Entierra o tira los restos lejos de casa''',
    observations:
        'Termina siempre con una limpieza personal y protección',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Corda de Banimento'):
      const SpellContentOverlay(
    name: 'Cuerda de Destierro',
    purpose: 'Cortar lazos energéticos',
    ingredients: [
      'Cuerda negra o hilo grueso',
      'Tijeras o cuchillo',
      'Vela negra',
    ],
    steps: '''1. Enciende la vela
2. Sostén la cuerda
3. Visualiza la conexión que quieres cortar
4. Di: "Este lazo ya no me sirve"
5. Corta la cuerda con decisión
6. Quema los trozos en la vela
7. Di: "Soy libre"
8. Arroja las cenizas al viento o a agua corriente''',
    observations:
        'Poderoso para cerrar relaciones o adicciones energéticas',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Freezer Spell (Congelamento)'):
      const SpellContentOverlay(
    name: 'Hechizo del Congelador',
    purpose: 'Detener chismes o conductas dañinas',
    ingredients: [
      'Papel',
      'Recipiente con agua',
      'Congelador',
    ],
    steps: '''1. Escribe el nombre de la persona y la conducta que debe cesar
2. Dobla el papel hacia afuera (alejando)
3. Colócalo en el recipiente con agua
4. Di: "Tus acciones contra mí están congeladas"
5. Ponlo en el congelador
6. Déjalo congelado hasta que la situación se resuelva
7. Cuando se resuelva, descongélalo y tíralo''',
    observations:
        'No perjudica, solo inmoviliza la acción negativa. Ético para la autodefensa',
  ),

  // ============================================
  // SUERTE
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Sache da Sorte'):
      const SpellContentOverlay(
    name: 'Saquito de la Suerte',
    purpose: 'Atraer buena suerte en general',
    ingredients: [
      'Saquito verde o dorado',
      'Trébol (si lo encuentras)',
      'Canela',
      'Albahaca',
      'Anís estrellado',
      'Moneda de la suerte',
      'Citrino o aventurina',
    ],
    steps: '''1. Coloca todos los ingredientes en el saquito
2. Sostenlo entre las manos
3. Visualiza oportunidades surgiendo
4. Di: "La suerte me acompaña adonde quiera que vaya"
5. Llévalo contigo
6. Toca el saquito cuando necesites suerte
7. Recárgalo en luna llena''',
    observations:
        'Cuanto más crees en él, mejor funciona',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vela Laranja da Oportunidade'):
      const SpellContentOverlay(
    name: 'Vela Naranja de la Oportunidad',
    purpose: 'Abrir puertas a las oportunidades',
    ingredients: [
      'Vela naranja',
      'Aceite esencial de naranja',
      'Canela',
      'Aventurina',
    ],
    steps: '''1. Unge la vela con aceite de naranja
2. Ruédala en canela
3. Coloca la aventurina al lado
4. Enciende la vela
5. Visualiza puertas abriéndose
6. Di: "Las oportunidades fluyen hacia mí con facilidad"
7. Déjala arder 30 minutos
8. Apágala y repite durante 3 días seguidos''',
    observations:
        'Ideal antes de eventos importantes o cambios de vida',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Mão da Sorte'):
      const SpellContentOverlay(
    name: 'Mano de la Suerte',
    purpose: 'Suerte en juegos y apuestas',
    ingredients: [
      'Canela en polvo',
      'Sal',
      'Tu mano dominante',
    ],
    steps: '''1. Mezcla la canela y la sal
2. Frótala en la palma de tu mano dominante
3. Visualízate ganando
4. Di: "La suerte está en mis manos"
5. Sopla la mezcla al viento (hacia afuera)
6. No te laves las manos de inmediato
7. Usa esa mano para jugar/apostar''',
    observations:
        'La magia no garantiza la victoria. Juega con responsabilidad',
  ),

  // ============================================
  // CREATIVIDAD
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Amarela da Inspiração'):
      const SpellContentOverlay(
    name: 'Vela Amarilla de la Inspiración',
    purpose: 'Desbloquear la creatividad',
    ingredients: [
      'Vela amarilla o naranja',
      'Aceite esencial de naranja o limón',
      'Canela',
      'Cornalina o citrino',
    ],
    steps: '''1. Unge la vela con el aceite
2. Ruédala en canela
3. Coloca el cristal al lado
4. Enciende la vela en tu espacio creativo
5. Di: "La creatividad fluye a través de mí"
6. Trabaja en tu proyecto con la vela encendida
7. Repite siempre que lo necesites''',
    observations:
        'La llama representa la chispa creativa. Mantenla encendida mientras trabajas',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Chá da Inspiração'):
      const SpellContentOverlay(
    name: 'Té de la Inspiración',
    purpose: 'Estimular ideas creativas',
    ingredients: [
      'Té verde o blanco',
      'Menta',
      'Jengibre',
      'Limón',
      'Miel',
    ],
    steps: '''1. Prepara el té con la intención de despertar la creatividad
2. Agrega los ingredientes
3. Revuelve en sentido horario
4. Di: "Este té despierta mi genio creativo"
5. Bébelo mientras visualizas ideas fluyendo
6. Siéntate a crear justo después''',
    observations:
        'Funciona como ritual para entrar en estado creativo',
  ),

  // ============================================
  // COMUNICACIÓN
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Mel na Língua'):
      const SpellContentOverlay(
    name: 'Miel en la Lengua',
    purpose: 'Endulzar las palabras y la comunicación',
    ingredients: [
      'Miel',
      'Tu dedo',
    ],
    steps: '''1. Pon un poco de miel en el dedo
2. Toca ligeramente tu lengua con la miel
3. Visualiza tus palabras siendo bien recibidas
4. Di mentalmente: "Mis palabras son dulces y bien recibidas"
5. Úsalo antes de conversaciones importantes
6. Sé consciente de lo que dices''',
    observations:
        'Antes de entrevistas, presentaciones o conversaciones difíciles',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vela Azul da Comunicação Clara'):
      const SpellContentOverlay(
    name: 'Vela Azul de la Comunicación Clara',
    purpose: 'Mejorar la expresión y ser comprendido',
    ingredients: [
      'Vela azul claro',
      'Aceite de lavanda o menta',
      'Sodalita o lapislázuli',
      'Papel y bolígrafo azul',
    ],
    steps: '''1. Escribe tu intención de comunicación clara
2. Coloca el papel debajo de la vela
3. Unge la vela con el aceite
4. Coloca el cristal al lado
5. Enciende la vela
6. Di: "Me expreso con claridad, soy escuchado y comprendido"
7. Déjala arder mientras visualizas la comunicación fluyendo
8. Lleva el cristal cuando vayas a comunicarte''',
    observations:
        'Chakra laríngeo (garganta). Ideal para quien tiene dificultad para expresarse',
  ),

  // ============================================
  // SUEÑOS
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Travesseiro dos Sonhos'):
      const SpellContentOverlay(
    name: 'Almohada de los Sueños',
    purpose: 'Sueños proféticos y lúcidos',
    ingredients: [
      'Saquito pequeño de tela',
      'Lavanda',
      'Artemisa',
      'Manzanilla',
      'Amatista pequeña',
    ],
    steps: '''1. En luna llena, coloca las hierbas y el cristal en el saquito
2. Sostenlo y di: "Que mis sueños sean claros y memorables"
3. Colócalo bajo o dentro de la almohada
4. Antes de dormir, di: "Recuerdo mis sueños con claridad"
5. Mantén un diario de sueños cerca de la cama
6. Anota al despertar''',
    observations:
        'La artemisa es potente para los sueños. Puede provocar sueños intensos',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Água Lunar dos Sonhos'):
      const SpellContentOverlay(
    name: 'Agua Lunar de los Sueños',
    purpose: 'Aclarar los sueños y la intuición',
    ingredients: [
      'Agua',
      'Vaso o jarra de vidrio',
      'Amatista o piedra luna',
    ],
    steps: '''1. En luna llena, pon agua en el vaso
2. Agrega el cristal
3. Déjalo bajo la luz de la luna durante la noche
4. Por la mañana, retira el cristal
5. Bebe un sorbo antes de dormir
6. Di: "Esta agua lunar aclara mis sueños"
7. Anota los sueños al despertar''',
    observations:
        'El agua lunar potencia la conexión con el inconsciente',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Óleo de Unção para Sonhos'):
      const SpellContentOverlay(
    name: 'Aceite de Unción para los Sueños',
    purpose: 'Facilitar sueños lúcidos',
    ingredients: [
      'Aceite base (jojoba o almendras)',
      'Aceite esencial de lavanda',
      'Artemisa',
      'Manzanilla',
      'Frasco pequeño',
    ],
    steps: '''1. Mezcla los aceites esenciales con el aceite base
2. Agrega pizcas de hierbas
3. Déjalo bajo la luna llena
4. Antes de dormir, unge el tercer ojo (entre las cejas)
5. Unge también las muñecas
6. Di: "Estoy consciente en mis sueños"
7. Duerme con la intención de soñar lúcido''',
    observations:
        'Practica técnicas de sueño lúcido junto con el aceite para mejores resultados',
  ),

  // ============================================
  // ENERGÍA
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Vermelha de Vitalidade'):
      const SpellContentOverlay(
    name: 'Vela Roja de Vitalidad',
    purpose: 'Aumentar la energía física',
    ingredients: [
      'Vela roja',
      'Aceite de canela',
      'Jengibre en polvo',
      'Cornalina o jaspe rojo',
    ],
    steps: '''1. Unge la vela con el aceite
2. Ruédala en jengibre
3. Coloca el cristal al lado
4. Enciende la vela
5. Visualiza una energía vibrante llenándote
6. Di: "Estoy lleno de energía vital y fuerza"
7. Déjala arder mientras haces algo activo
8. Lleva el cristal para tener energía constante''',
    observations:
        'No sustituye el descanso necesario. Úsalo cuando necesites energía extra',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Banho Energizante'):
      const SpellContentOverlay(
    name: 'Baño Energizante',
    purpose: 'Renovar la energía vital',
    ingredients: [
      'Romero',
      'Menta',
      'Cáscara de naranja',
      'Jengibre',
      'Sal marina',
    ],
    steps: '''1. Hierve las hierbas en agua
2. Cuela y deja enfriar un poco
3. Toma tu baño normal
4. Viértelo del cuello hacia abajo
5. Visualiza una energía dorada llenándote
6. Di: "Estoy renovado y lleno de energía"
7. Deja que tu piel se seque de forma natural
8. Ponte ropa vibrante si es posible''',
    observations:
        'Mejor por la mañana para empezar el día con energía',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Cristal de Energia Pessoal'):
      const SpellContentOverlay(
    name: 'Cristal de Energía Personal',
    purpose: 'Cargar un cristal con energía',
    ingredients: [
      'Cuarzo transparente o citrino',
      'Luz del sol',
    ],
    steps: '''1. Limpia el cristal
2. Sostenlo entre las manos
3. Visualiza una luz dorada entrando por tu coronilla
4. Siente la energía fluir hacia tus manos
5. Programa el cristal: "Tú almacenas y me devuelves energía cuando la necesito"
6. Ponlo al sol durante 2 horas
7. Llévalo contigo
8. Sostenlo cuando necesites energía''',
    observations:
        'Recarga el cristal al sol cada mes',
  ),

  // ============================================
  // CASA Y HOGAR
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Proteção e Bênção do Lar'):
      const SpellContentOverlay(
    name: 'Protección y Bendición del Hogar',
    purpose: 'Bendecir y proteger la casa',
    ingredients: [
      'Sal gruesa',
      'Romero',
      'Lavanda',
      'Agua',
      'Vela blanca',
    ],
    steps: '''1. Hierve agua con las hierbas
2. Agrega la sal
3. Deja enfriar y cuela
4. Enciende la vela blanca
5. Ve de habitación en habitación rociando o pasando un paño
6. En cada habitación di: "Esta casa está bendecida, protegida y llena de amor"
7. Termina en la puerta de entrada
8. Deja que la vela se consuma por completo''',
    observations:
        'Hazlo al mudarte o cada mes para renovar la energía',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Vassoura de Bruxa para Lar'):
      const SpellContentOverlay(
    name: 'Escoba de Bruja para el Hogar',
    purpose: 'Limpiar y renovar la energía de la casa',
    ingredients: [
      'Escoba',
      'Romero fresco',
      'Cinta morada o negra',
      'Sal',
    ],
    steps: '''1. Ata romero al mango de la escoba con la cinta
2. Esparce sal por el suelo
3. Comienza por la puerta de entrada
4. Barre cada habitación con movimiento de "barrer hacia afuera"
5. Di: "Barro toda la negatividad, traigo renovación"
6. Recoge la sal y tírala lejos de casa
7. Guarda la escoba detrás de la puerta o en un armario''',
    observations:
        'Cada semana o después de energía pesada en casa',
  ),

  // ============================================
  // SABIDURÍA Y ESTUDIOS
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Roxa da Sabedoria'):
      const SpellContentOverlay(
    name: 'Vela Morada de la Sabiduría',
    purpose: 'Aumentar la comprensión y la sabiduría',
    ingredients: [
      'Vela morada',
      'Aceite de romero',
      'Salvia',
      'Amatista o fluorita',
      'Libro o material de estudio',
    ],
    steps: '''1. Unge la vela con aceite de romero
2. Coloca la amatista junto a la vela
3. Pon el libro/material cerca
4. Enciende la vela
5. Di: "Que la sabiduría fluya a través de mí, que yo comprenda y retenga el conocimiento"
6. Estudia con la vela encendida
7. Déjala arder al menos 30 minutos''',
    observations:
        'El morado es el color de la sabiduría y del tercer ojo. Úsala antes de exámenes o al estudiar',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Chá da Concentração'):
      const SpellContentOverlay(
    name: 'Té de la Concentración',
    purpose: 'Mejorar el enfoque en los estudios',
    ingredients: [
      'Té verde',
      'Menta',
      'Romero',
      'Miel',
      'Limón',
    ],
    steps: '''1. Prepara el té con intención de concentración
2. Agrega la menta y el romero
3. Revuelve en sentido horario 3 veces
4. Di: "Este té aclara mi mente y agudiza mi enfoque"
5. Agrega la miel y el limón
6. Bébelo despacio antes de estudiar
7. Siente la claridad mental llegando''',
    observations:
        'La menta y el romero son hierbas de claridad mental. Prepáralo fresco para mejores resultados',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Sachê do Estudante'):
      const SpellContentOverlay(
    name: 'Saquito del Estudiante',
    purpose: 'Ayudar a retener el conocimiento',
    ingredients: [
      'Saquito amarillo o morado',
      'Romero (memoria)',
      'Salvia (sabiduría)',
      'Menta (claridad)',
      'Fluorita o sodalita',
      'Papel con el objetivo de estudio',
    ],
    steps: '''1. Escribe en el papel lo que deseas aprender
2. Colócalo en el saquito con las hierbas y el cristal
3. Sostenlo y visualízate absorbiendo conocimiento
4. Di: "Mi mente está abierta, absorbo y retengo el conocimiento con facilidad"
5. Guárdalo en la mochila o en la mesa de estudio
6. Huele el saquito antes de estudiar o de los exámenes
7. Recárgalo en cada luna nueva''',
    observations:
        'El romero se usa tradicionalmente para la memoria desde la antigua Grecia',
  ),

  // ============================================
  // CORAJE
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Vermelha da Coragem'):
      const SpellContentOverlay(
    name: 'Vela Roja del Coraje',
    purpose: 'Invocar coraje y fuerza interior',
    ingredients: [
      'Vela roja',
      'Aceite de canela',
      'Pimienta negra',
      'Jaspe rojo o cornalina',
    ],
    steps: '''1. Unge la vela con aceite de canela
2. Espolvorea pimienta en la base
3. Coloca el cristal al lado
4. Enciende la vela
5. Mira la llama y di: "Soy valiente, soy fuerte, enfrento mis miedos"
6. Visualízate enfrentando con éxito lo que temes
7. Deja que se consuma por completo
8. Lleva el cristal cuando necesites coraje''',
    observations:
        'El rojo es el color de Marte, planeta del coraje y la acción. Úsala antes de situaciones desafiantes',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Amuleto do Guerreiro'):
      const SpellContentOverlay(
    name: 'Amuleto del Guerrero',
    purpose: 'Llevar el coraje contigo',
    ingredients: [
      'Saquito pequeño rojo o naranja',
      'Pimienta negra',
      'Ajo en polvo',
      'Jengibre',
      'Jaspe rojo o hematita',
      'Papel rojo',
    ],
    steps: '''1. Escribe en el papel: "Soy fuerte y valiente"
2. Coloca todos los ingredientes en el saquito
3. Sostenlo con las dos manos sobre el pecho
4. Respira hondo 3 veces
5. Di: "Llevo la fuerza de un guerrero, nada me intimida"
6. Visualízate como un guerrero invencible
7. Llévalo en el bolsillo en los momentos difíciles''',
    observations:
        'Toca el amuleto cuando sientas miedo o inseguridad para recordar tu fuerza',
  ),

  // ============================================
  // AMISTAD
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Laranja da Amizade'):
      const SpellContentOverlay(
    name: 'Vela Naranja de la Amistad',
    purpose: 'Atraer nuevas amistades',
    ingredients: [
      'Vela naranja o amarilla',
      'Aceite de naranja dulce',
      'Canela',
      'Citrino o cuarzo rosa',
    ],
    steps: '''1. Unge la vela con aceite de naranja
2. Ruédala en canela
3. Coloca el cristal al lado
4. Enciende la vela
5. Di: "Atraigo amigos verdaderos, almas afines, conexiones de alegría y lealtad"
6. Visualízate rodeado de buenas amistades
7. Deja que se consuma
8. Sal y socializa (¡la magia necesita oportunidad!)''',
    observations:
        'El naranja es el color de la alegría y la sociabilidad. La magia abre caminos, pero tú tienes que recorrerlos',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Nó de Amizade'):
      const SpellContentOverlay(
    name: 'Nudo de la Amistad',
    purpose: 'Fortalecer un lazo de amistad existente',
    ingredients: [
      '2 cintas o cuerdas (de colores que les gusten a ti y a tu amigo)',
      'Vela rosa o naranja',
    ],
    steps: '''1. Enciende la vela
2. Sostén las dos cintas
3. Visualízate feliz junto a tu amigo
4. Haz 3 nudos con las cintas entrelazadas
5. En cada nudo di: "Nuestra amistad es fuerte, verdadera y duradera"
6. Guarda las cintas anudadas o regálale una a tu amigo
7. Deja que la vela se consuma''',
    observations:
        'La magia de nudos es antigua y poderosa. Deshaz los nudos solo si la amistad termina',
  ),

  // ============================================
  // TRABAJO
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Vela Verde do Sucesso Profissional'):
      const SpellContentOverlay(
    name: 'Vela Verde del Éxito Profesional',
    purpose: 'Atraer éxito en el trabajo',
    ingredients: [
      'Vela verde o dorada',
      'Aceite de albahaca o canela',
      'Albahaca',
      'Citrino o pirita',
      'Tarjeta de visita o papel con tu objetivo profesional',
    ],
    steps: '''1. Escribe tu objetivo profesional en el papel
2. Colócalo debajo de la vela
3. Unge la vela con el aceite
4. Ruédala en albahaca
5. Coloca el cristal al lado
6. Enciende la vela
7. Di: "El éxito viene a mí, soy reconocido y valorado en mi trabajo"
8. Deja que se consuma por completo
9. Lleva el cristal a entrevistas/al trabajo''',
    observations:
        'El jueves (día de Júpiter) es ideal para hechizos de trabajo y carrera',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Óleo de Unção para Entrevista'):
      const SpellContentOverlay(
    name: 'Aceite de Unción para Entrevistas',
    purpose: 'Éxito en entrevistas de trabajo',
    ingredients: [
      'Aceite base (jojoba o almendras)',
      'Aceite esencial de albahaca',
      'Aceite esencial de naranja',
      'Canela en polvo',
      'Frasco pequeño',
    ],
    steps: '''1. Mezcla los aceites esenciales con el aceite base
2. Agrega una pizca de canela
3. Sostén el frasco y visualiza el éxito en la entrevista
4. Di: "Este aceite me trae confianza, claridad y éxito"
5. Antes de la entrevista, unge las muñecas y detrás de las orejas
6. Di mentalmente: "Soy la persona indicada para este trabajo"
7. ¡Ve con confianza!''',
    observations:
        'Úsalo también para presentaciones o reuniones importantes. ¡La confianza es mágica!',
  ),

  // ============================================
  // ADIVINACIÓN
  // ============================================

  SqfliteSpellLocalStore.preloadedSpellId('Água da Lua para Vidência'):
      const SpellContentOverlay(
    name: 'Agua de Luna para la Videncia',
    purpose: 'Amplificar las habilidades adivinatorias',
    ingredients: [
      'Cuenco o copa de vidrio/plata',
      'Agua pura',
      'Amatista o piedra luna',
      'Lavanda',
    ],
    steps: '''1. En luna llena, pon agua en el cuenco
2. Agrega el cristal y una pizca de lavanda
3. Déjalo bajo la luz lunar toda la noche
4. Por la mañana, retira el cristal y cuela la lavanda
5. Usa esa agua para limpiar herramientas adivinatorias (tarot, runas, péndulo)
6. O bebe un sorbo antes de hacer lecturas
7. Di: "Mi visión es clara, mi intuición es fuerte"''',
    observations:
        'El agua lunar cargada en luna llena tiene una fuerte energía psíquica',
  ),

  SqfliteSpellLocalStore.preloadedSpellId('Ritual de Abertura do Terceiro Olho'):
      const SpellContentOverlay(
    name: 'Ritual de Apertura del Tercer Ojo',
    purpose: 'Desarrollar la intuición y la clarividencia',
    ingredients: [
      'Vela morada o índigo',
      'Amatista o lapislázuli',
      'Incienso de lavanda o artemisa',
      'Aceite de lavanda',
    ],
    steps: '''1. Enciende la vela y el incienso
2. Siéntate cómodamente
3. Coloca el cristal en el tercer ojo (entre las cejas)
4. Unge el tercer ojo con una gota de aceite
5. Cierra los ojos y respira profundamente
6. Visualiza una luz índigo girando en el tercer ojo
7. Di: "Mi tercer ojo está abierto, veo más allá del velo"
8. Medita durante 10-15 minutos
9. Anota cualquier visión o sensación''',
    observations:
        'Hazlo durante 7 noches seguidas para mejores resultados. Lleva un diario de las experiencias',
  ),
};
