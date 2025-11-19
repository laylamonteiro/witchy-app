import '../models/spell_model.dart';

/// Feitiços pré-carregados do app
/// Baseados em "O Grimório Moderno das Bruxas" (Jason Mankey),
/// "Bruxaria Verde" (Lindsay Squire) e práticas tradicionais de bruxaria
final List<SpellModel> preloadedSpells = [
  // ============================================
  // AMOR E ROMANCE (5 feitiços)
  // ============================================

  SpellModel(
    name: 'Vela Rosa para Atrair Amor',
    purpose: 'Atrair amor romântico',
    type: SpellType.attraction,
    category: SpellCategory.love,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      '1 vela rosa',
      'Óleo de rosa ou rosa mosqueta',
      'Pétalas de rosa secas',
      'Quartzo rosa',
    ],
    steps: '''1. Limpe seu espaço com fumaça de incenso ou ervas
2. Unja a vela com óleo, do centro para as pontas
3. Role a vela nas pétalas de rosa
4. Coloque o quartzo rosa ao lado da vela
5. Acenda a vela visualizando amor chegando até você
6. Diga: "Amor verdadeiro, venha a mim, com respeito e reciprocidade"
7. Deixe a vela queimar completamente
8. Carregue o quartzo rosa com você''',
    duration: 1,
    observations: 'Melhor feito numa sexta-feira (dia de Vênus). Mantenha o coração aberto para novas possibilidades.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Banho de Rosas para Amor',
    purpose: 'Atrair amor e abrir o coração',
    type: SpellType.attraction,
    category: SpellCategory.love,
    moonPhase: MoonPhase.fullMoon,
    ingredients: [
      'Pétalas de rosa (brancas, vermelhas ou rosas)',
      'Mel',
      'Canela em pau',
      'Água morna',
    ],
    steps: '''1. Prepare um banho morno
2. Adicione pétalas de rosa, 1 colher de mel e canela
3. Entre na água e relaxe
4. Visualize-se irradiando amor e sendo amado(a)
5. Diga: "Abro meu coração para o amor verdadeiro"
6. Mergulhe 3 vezes
7. Deixe secar naturalmente''',
    duration: 1,
    observations: 'Pode ser feito na lua cheia ou crescente. Excelente para abrir o coração após mágoas.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Sache de Amor',
    purpose: 'Carregar energia de amor',
    type: SpellType.attraction,
    category: SpellCategory.love,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Saquinho cor de rosa ou vermelho',
      'Pétalas de rosa',
      'Lavanda',
      'Quartzo rosa pequeno',
      'Canela',
      'Papel e caneta',
    ],
    steps: '''1. Escreva no papel as qualidades que busca num amor
2. Dobre o papel para dentro (atraindo)
3. Coloque no saquinho com as ervas e o cristal
4. Segure o sache nas mãos e visualize amor chegando
5. Diga: "Este amor é meu, com o bem de todos e mal de ninguém"
6. Carregue na bolsa ou perto da cama
7. Energize na lua cheia''',
    observations: 'Substitua as ervas a cada 3 meses ou quando sentir necessário.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Feitiço do Espelho do Amor',
    purpose: 'Refletir amor de volta para você',
    type: SpellType.attraction,
    category: SpellCategory.love,
    moonPhase: MoonPhase.fullMoon,
    ingredients: [
      'Espelho pequeno',
      'Vela rosa',
      'Óleo essencial de rosa',
      'Sua foto',
    ],
    steps: '''1. Na lua cheia, limpe o espelho
2. Unja a vela com óleo de rosa
3. Coloque sua foto diante do espelho
4. Acenda a vela
5. Olhe no espelho e diga: "Eu sou digno(a) de amor, eu mereço amor, eu atraio amor"
6. Deixe a vela queimar
7. Mantenha o espelho em local especial''',
    duration: 1,
    observations: 'Este feitiço trabalha amor próprio e atração simultâneos.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Mel para Adoçar Relacionamento',
    purpose: 'Adoçar relação existente',
    type: SpellType.attraction,
    category: SpellCategory.love,
    ingredients: [
      'Pote de mel',
      'Papel e caneta vermelha',
      'Canela em pó',
      '2 velas vermelhas pequenas',
    ],
    steps: '''1. Escreva seu nome e o nome da pessoa no papel
2. Coloque o papel no fundo de uma tigela
3. Cubra com mel e polvilhe canela
4. Coloque as velas nos lados
5. Acenda e diga: "Que nossa relação seja doce como este mel"
6. Deixe queimar
7. Enterre os restos num jardim''',
    duration: 1,
    observations: 'Apenas para relações já existentes. Não funciona contra o livre arbítrio.',
    isPreloaded: true,
  ),

  // ============================================
  // AMOR PRÓPRIO (4 feitiços)
  // ============================================

  SpellModel(
    name: 'Ritual do Espelho',
    purpose: 'Fortalecer amor próprio',
    type: SpellType.attraction,
    category: SpellCategory.selfLove,
    moonPhase: MoonPhase.fullMoon,
    ingredients: [
      'Espelho',
      'Vela rosa',
      'Quartzo rosa',
    ],
    steps: '''1. Acenda a vela rosa
2. Segure o quartzo rosa
3. Olhe-se no espelho
4. Diga afirmações positivas sobre você
5. "Eu me amo", "Eu sou suficiente", "Eu mereço felicidade"
6. Faça por 5-10 minutos
7. Repita diariamente por uma semana''',
    duration: 7,
    observations: 'Pode parecer estranho no início, mas é transformador com persistência.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Banho de Amor Próprio',
    purpose: 'Nutrir e amar a si mesmo',
    type: SpellType.attraction,
    category: SpellCategory.selfLove,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Sal rosa do Himalaia',
      'Pétalas de rosa',
      'Lavanda',
      'Mel',
      'Óleo essencial de laranja',
    ],
    steps: '''1. Prepare banho morno
2. Adicione sal rosa, pétalas, lavanda, mel e óleo
3. Entre na água
4. Coloque mãos no coração
5. Respire e visualize luz rosa te envolvendo
6. Diga: "Eu me amo e me aceito completamente"
7. Relaxe por 20 minutos
8. Deixe secar naturalmente''',
    duration: 1,
    observations: 'Faça sempre que precisar se reconectar consigo mesmo.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Frasco de Amor Próprio',
    purpose: 'Guardar energia de autoamor',
    type: SpellType.attraction,
    category: SpellCategory.selfLove,
    moonPhase: MoonPhase.newMoon,
    ingredients: [
      'Frasco de vidro com tampa',
      'Sal rosa',
      'Pétalas de rosa',
      'Quartzo rosa pequeno',
      'Canela',
      'Papel e caneta rosa',
    ],
    steps: '''1. Escreva qualidades que você ama em si mesmo
2. Coloque no frasco
3. Adicione sal, pétalas, quartzo e canela
4. Segure o frasco e infunda com amor
5. Diga: "Eu sou amor, eu sou luz, eu sou suficiente"
6. Feche e mantenha em local visível
7. Segure sempre que precisar de força''',
    observations: 'Adicione novos papéis com qualidades sempre que descobrir mais sobre si.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Lista de Gratidão',
    purpose: 'Cultivar amor por si através da gratidão',
    type: SpellType.attraction,
    category: SpellCategory.selfLove,
    moonPhase: MoonPhase.fullMoon,
    ingredients: [
      'Caderno bonito',
      'Caneta que você goste',
      'Vela rosa ou dourada',
    ],
    steps: '''1. Acenda a vela
2. Abra o caderno
3. Liste 10 coisas que você gosta em você
4. Liste 10 coisas que seu corpo faz por você
5. Liste 10 conquistas suas (pequenas ou grandes)
6. Leia em voz alta
7. Agradeça a si mesmo
8. Repita semanalmente''',
    duration: 7,
    observations: 'A gratidão transforma a percepção que temos de nós mesmos.',
    isPreloaded: true,
  ),

  // ============================================
  // PROTEÇÃO (8 feitiços)
  // ============================================

  SpellModel(
    name: 'Círculo de Sal',
    purpose: 'Proteção básica de espaço',
    type: SpellType.banishment,
    category: SpellCategory.protection,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Sal grosso ou marinho',
    ],
    steps: '''1. Caminhe pelo perímetro do espaço
2. Espalhe o sal enquanto visualiza uma barreira de luz
3. Diga: "Este espaço está protegido, apenas amor e luz podem entrar"
4. Repita nos cantos do ambiente
5. Renovar mensalmente ou quando sentir necessário''',
    observations: 'Mais simples e poderosa proteção. Funciona para casa, quarto ou altar.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Sache de Proteção',
    purpose: 'Proteção pessoal portátil',
    type: SpellType.banishment,
    category: SpellCategory.protection,
    ingredients: [
      'Saquinho preto ou vermelho',
      'Alecrim',
      'Arruda (manuseie com cuidado)',
      'Sal grosso',
      'Turmalina negra ou obsidiana',
      'Dente de alho',
    ],
    steps: '''1. Coloque todos ingredientes no saquinho
2. Segure entre as mãos
3. Visualize escudo protetor ao seu redor
4. Diga: "Proteção comigo sempre, mal algum me alcançará"
5. Carregue na bolsa ou mochila
6. Renovar a cada lua nova''',
    observations: 'Mantenha longe de crianças e animais (arruda é tóxica).',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Banho de Proteção',
    purpose: 'Limpar e proteger energia pessoal',
    type: SpellType.banishment,
    category: SpellCategory.protection,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Sal grosso',
      'Alecrim',
      'Arruda',
      'Guiné',
      'Água',
    ],
    steps: '''1. Ferva as ervas em água por 10 minutos
2. Coe e deixe esfriar
3. Após banho normal, jogue do pescoço para baixo
4. Visualize energias negativas indo embora
5. Diga: "Estou limpo e protegido"
6. Não se seque, deixe secar naturalmente''',
    duration: 1,
    observations: 'Faça após situações pesadas ou semanalmente para manutenção.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Garrafa de Bruxa',
    purpose: 'Proteção permanente da casa',
    type: SpellType.banishment,
    category: SpellCategory.protection,
    ingredients: [
      'Frasco de vidro com tampa',
      'Pregos, alfinetes, agulhas',
      'Sal grosso',
      'Pimenta preta',
      'Alho',
      'Alecrim',
      'Sua urina (tradicional) ou vinagre',
    ],
    steps: '''1. Coloque objetos pontiagudos no frasco
2. Adicione sal, pimenta, alho e alecrim
3. Adicione líquido até encher
4. Feche bem e agite
5. Diga: "Esta casa está protegida"
6. Enterre na entrada da casa ou esconda perto da porta
7. Nunca abra''',
    observations: 'Proteção tradicional muito poderosa. Dura anos.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Vassoura de Proteção',
    purpose: 'Varrer energias negativas',
    type: SpellType.banishment,
    category: SpellCategory.protection,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Vassoura (pode ser comum)',
      'Alecrim fresco',
      'Sal grosso',
    ],
    steps: '''1. Amarre alecrim no cabo da vassoura
2. Espalhe sal pelo chão
3. Varra da porta de entrada para dentro
4. Varra cada cômodo em sentido anti-horário
5. Diga: "Varro toda negatividade desta casa"
6. Junte o sal e jogue fora longe de casa
7. Mantenha a vassoura atrás da porta''',
    observations: 'Faça após visitas pesadas ou discussões em casa.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Pentagrama de Proteção',
    purpose: 'Proteção energética pessoal',
    type: SpellType.banishment,
    category: SpellCategory.protection,
    moonPhase: MoonPhase.waningGibbous,
    ingredients: [
      'Dedo indicador ou athame (faca ritual)',
      'Visualização',
    ],
    steps: '''1. De pé, respire fundo 3 vezes
2. Com dedo indicador, desenhe pentagrama brilhante no ar à sua frente
3. Comece no topo, vá para baixo esquerda, suba para direita, atravesse para esquerda, desça para direita, volte ao topo
4. Visualize-o brilhando em azul ou branco
5. Diga: "Estou protegido por este símbolo sagrado"
6. Desenhe um em cada direção (norte, sul, leste, oeste)
7. Sinta-se envolto em proteção''',
    observations: 'Pode ser feito mentalmente em qualquer lugar quando sentir necessidade.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Proteção com Espelho',
    purpose: 'Refletir energias negativas de volta',
    type: SpellType.banishment,
    category: SpellCategory.protection,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Espelho pequeno',
      'Vela preta',
      'Sal grosso',
      'Alecrim',
    ],
    steps: '''1. Limpe o espelho com água e sal
2. Coloque o espelho virado para fora numa janela ou porta
3. Acenda a vela preta ao lado
4. Coloque sal e alecrim em volta
5. Diga: "Que toda negatividade seja refletida de volta a sua origem, transformada em luz"
6. Deixe a vela queimar''',
    observations: 'Espelho sempre virado para fora, nunca para dentro da casa.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Óleo de Proteção',
    purpose: 'Unção protetora',
    type: SpellType.banishment,
    category: SpellCategory.protection,
    ingredients: [
      'Óleo de base (amêndoas ou jojoba)',
      'Alecrim',
      'Cravo',
      'Canela',
      'Pimenta preta',
      'Frasco de vidro escuro',
    ],
    steps: '''1. Coloque as ervas no frasco
2. Cubra com óleo
3. Agite enquanto visualiza proteção
4. Diga: "Este óleo me protege de todo mal"
5. Deixe na janela na lua minguante por 3 noites
6. Coe e use para ungir velas, portas, janelas, ou a si mesmo''',
    observations: 'Durável. Mantenha em local fresco e escuro.',
    isPreloaded: true,
  ),

  // ============================================
  // PROSPERIDADE (7 feitiços)
  // ============================================

  SpellModel(
    name: 'Folha de Louro dos Desejos',
    purpose: 'Manifestar prosperidade',
    type: SpellType.attraction,
    category: SpellCategory.prosperity,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Folhas de louro secas',
      'Caneta ou palito',
      'Recipiente à prova de fogo',
    ],
    steps: '''1. Escreva na folha de louro o que deseja manifestar
2. Pode ser quantia, oportunidade ou "prosperidade"
3. Segure a folha e visualize seu desejo realizado
4. Sinta a gratidão de já ter recebido
5. Queime a folha com cuidado
6. Diga: "Minha prosperidade cresce a cada dia"
7. Deixe as cinzas serem levadas pelo vento ou jogue em água corrente''',
    duration: 1,
    observations: 'Pode ser feito sempre que sentir necessidade. Confie no timing do universo.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Banho de Manjericão',
    purpose: 'Atrair prosperidade e abrir caminhos',
    type: SpellType.attraction,
    category: SpellCategory.prosperity,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Manjericão fresco ou seco',
      'Canela',
      'Mel',
      'Água',
    ],
    steps: '''1. Ferva o manjericão e canela em água
2. Deixe esfriar e adicione mel
3. Após banho normal, despeje do pescoço para baixo
4. Visualize caminhos se abrindo e dinheiro chegando
5. Diga: "Prosperidade flui para mim facilmente"
6. Deixe secar naturalmente''',
    duration: 1,
    observations: 'Excelente antes de entrevistas ou reuniões importantes.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Vela Verde da Abundância',
    purpose: 'Atrair dinheiro e abundância',
    type: SpellType.attraction,
    category: SpellCategory.prosperity,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Vela verde',
      'Óleo de canela ou óleo de cozinha com canela',
      'Manjericão',
      'Moeda',
    ],
    steps: '''1. Unja a vela com óleo, do centro para as pontas
2. Role em manjericão seco
3. Coloque a moeda embaixo da vela
4. Acenda visualizando abundância fluindo para você
5. Diga: "Dinheiro vem a mim em abundância, com facilidade e alegria"
6. Deixe queimar completamente
7. Carregue a moeda na carteira''',
    duration: 1,
    observations: 'Melhor em quinta-feira (dia de Júpiter). Repita quando sentir necessidade.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Frasco da Prosperidade',
    purpose: 'Atrair e manter prosperidade',
    type: SpellType.attraction,
    category: SpellCategory.prosperity,
    moonPhase: MoonPhase.newMoon,
    ingredients: [
      'Frasco de vidro com tampa',
      'Moedas',
      'Arroz',
      'Canela',
      'Manjericão',
      'Citrino ou pirita',
      'Papel verde',
    ],
    steps: '''1. Escreva no papel seu objetivo financeiro
2. Coloque no fundo do frasco
3. Adicione camadas: moedas, arroz, ervas, cristal
4. Preencha até o topo
5. Segure o frasco e visualize abundância
6. Diga: "Minha prosperidade cresce constantemente"
7. Mantenha perto de onde guarda dinheiro
8. Adicione moedas quando receber dinheiro''',
    observations: 'Nunca abra ou retire. É um ímã permanente de prosperidade.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Carteira Magnetizada',
    purpose: 'Atrair dinheiro para carteira',
    type: SpellType.attraction,
    category: SpellCategory.prosperity,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Sua carteira vazia',
      'Manjericão',
      'Canela',
      'Nota de dinheiro',
    ],
    steps: '''1. Limpe sua carteira
2. Coloque uma pitada de manjericão e canela dentro
3. Adicione a nota
4. Segure a carteira e visualize ela sempre cheia
5. Diga: "Dinheiro entra e se multiplica, sempre há o suficiente e mais"
6. Nunca deixe a carteira completamente vazia
7. Mantenha sempre ao menos uma nota''',
    observations: 'Renove as ervas a cada lua nova. A nota nunca deve ser gasta.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Ritual da Chuva de Moedas',
    purpose: 'Multiplicar dinheiro',
    type: SpellType.attraction,
    category: SpellCategory.prosperity,
    moonPhase: MoonPhase.fullMoon,
    ingredients: [
      'Várias moedas',
      'Tigela com água',
      'Vela dourada ou amarela',
    ],
    steps: '''1. Na lua cheia, coloque a tigela sob a luz lunar
2. Acenda a vela ao lado
3. Segure as moedas nas mãos
4. Visualize multiplicação de dinheiro
5. Jogue as moedas na água uma a uma
6. Para cada moeda diga: "Um se torna dois, dois se tornam quatro..."
7. Deixe a água absorver energia lunar
8. Na manhã seguinte, use essa água para regar plantas''',
    duration: 1,
    observations: 'A prosperidade "crescerá" como as plantas. As moedas podem ser doadas.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Sigilo de Prosperidade',
    purpose: 'Manifestar abundância através de símbolos',
    type: SpellType.attraction,
    category: SpellCategory.prosperity,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Papel verde ou dourado',
      'Caneta dourada ou verde',
      'Vela verde',
    ],
    steps: '''1. Escreva sua intenção: "Eu sou próspero e abundante"
2. Remova letras repetidas
3. Crie um símbolo único com as letras restantes
4. Foque no sigilo e visualize prosperidade
5. Acenda a vela
6. Queime o papel com sigilo ou guarde na carteira
7. Esqueça (deixe o universo trabalhar)''',
    observations: 'Técnica de magia do caos. Quanto menos pensar depois, mais funciona.',
    isPreloaded: true,
  ),

  // ============================================
  // CURA (5 feitiços)
  // ============================================

  SpellModel(
    name: 'Banho de Cura',
    purpose: 'Cura física e energética',
    type: SpellType.attraction,
    category: SpellCategory.healing,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Sal grosso ou sal do Himalaia',
      'Alecrim',
      'Hortelã',
      'Eucalipto',
      'Camomila',
    ],
    steps: '''1. Ferva as ervas em água
2. Coe e deixe esfriar
3. Adicione ao banho morno com sal
4. Entre na água e relaxe
5. Visualize luz verde curativa te envolvendo
6. Diga: "Meu corpo se cura, minha energia se renova"
7. Fique pelo menos 15 minutos
8. Deixe secar naturalmente''',
    duration: 1,
    observations: 'Não substitui tratamento médico. Complementa processos de cura.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Vela de Cura',
    purpose: 'Enviar energia curativa',
    type: SpellType.attraction,
    category: SpellCategory.healing,
    moonPhase: MoonPhase.fullMoon,
    ingredients: [
      'Vela azul ou branca',
      'Óleo de eucalipto ou hortelã',
      'Quartzo transparente ou ametista',
      'Foto da pessoa (ou papel com nome)',
    ],
    steps: '''1. Limpe o cristal
2. Unja a vela com óleo
3. Coloque a foto/papel embaixo da vela
4. Coloque o cristal ao lado
5. Acenda a vela
6. Visualize luz curativa envolvendo a pessoa
7. Diga: "Que [nome] seja curado(a) para o seu maior bem"
8. Deixe a vela queimar completamente''',
    duration: 1,
    observations: 'Sempre peça permissão antes de fazer magia para outros. Respeite o livre arbítrio.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Chá Mágico de Cura',
    purpose: 'Poção de cura interna',
    type: SpellType.attraction,
    category: SpellCategory.healing,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Chá de camomila',
      'Hortelã',
      'Gengibre',
      'Mel',
      'Limão',
    ],
    steps: '''1. Prepare o chá com intenção de cura
2. Mexa em sentido horário enquanto faz
3. Adicione mel e limão
4. Segure a xícara nas mãos
5. Visualize luz dourada no chá
6. Diga: "Esta poção me cura, célula por célula"
7. Beba lentamente com atenção plena
8. Sinta a cura percorrendo seu corpo''',
    duration: 1,
    observations: 'Pode ser feito diariamente durante processo de cura.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Grade de Cristais Curativa',
    purpose: 'Amplificar cura através de cristais',
    type: SpellType.attraction,
    category: SpellCategory.healing,
    moonPhase: MoonPhase.fullMoon,
    ingredients: [
      '1 quartzo transparente grande (centro)',
      '4 ametistas (cantos)',
      '4 quartzo rosa (lados)',
      'Foto sua ou local da dor',
    ],
    steps: '''1. Limpe todos os cristais
2. Coloque a foto no centro
3. Posicione quartzo transparente sobre a foto
4. Coloque ametistas nos 4 cantos (quadrado)
5. Coloque quartzo rosa nos 4 lados (entre ametistas)
6. Visualize luz fluindo entre os cristais
7. Diga: "Esta grade amplifica cura perfeita"
8. Deixe montada por 3 dias
9. Carregue o cristal central com você''',
    duration: 3,
    observations: 'Potente amplificador de energia curativa. Recarregue os cristais após uso.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Poppet de Cura',
    purpose: 'Boneco energético para cura',
    type: SpellType.attraction,
    category: SpellCategory.healing,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Tecido branco ou verde',
      'Linha e agulha',
      'Algodão para rechear',
      'Ervas curativas (camomila, alecrim)',
      'Pequeno cristal curativo',
      'Papel com nome/foto',
    ],
    steps: '''1. Corte dois pedaços de tecido em forma humana
2. Costure deixando abertura
3. Coloque dentro: algodão, ervas, cristal, papel
4. Costure fechando
5. Segure o poppet e visualize cura
6. Diga: "Este boneco representa [nome] em perfeita saúde"
7. Mantenha em local seguro
8. Descosture quando a cura se completar''',
    observations: 'Técnica tradicional. Trate o poppet com carinho como se fosse a pessoa.',
    isPreloaded: true,
  ),

  // ============================================
  // LIMPEZA ENERGÉTICA (6 feitiços)
  // ============================================

  SpellModel(
    name: 'Defumação com Alecrim',
    purpose: 'Limpar energias de ambiente',
    type: SpellType.banishment,
    category: SpellCategory.cleansing,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Alecrim seco',
      'Carvão ou recipiente à prova de fogo',
    ],
    steps: '''1. Acenda o alecrim (use carvão se preferir)
2. Deixe fumegar bem
3. Comece pela porta de entrada
4. Caminhe por todo ambiente em sentido anti-horário
5. Dê atenção especial a cantos
6. Diga: "Toda negatividade é banida, apenas luz permanece"
7. Abra janelas para energia sair
8. Deixe o alecrim queimar completamente''',
    duration: 1,
    observations: 'Faça sempre que o ambiente estiver pesado ou após discussões.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Limpeza com Sálvia Branca',
    purpose: 'Purificação profunda',
    type: SpellType.banishment,
    category: SpellCategory.cleansing,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Sálvia branca (smudge stick)',
      'Pena (opcional)',
      'Recipiente à prova de fogo',
    ],
    steps: '''1. Abra janelas
2. Acenda a sálvia
3. Use a pena para direcionar a fumaça
4. Limpe a si mesmo primeiro (de cima para baixo)
5. Depois limpe o ambiente (anti-horário)
6. Diga: "Com esta fumaça sagrada, limpo e purifico"
7. Apague pressionando contra areia ou terra''',
    duration: 1,
    observations: 'Compre de fontes éticas. Sálvia branca é sagrada para povos indígenas.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Spray de Limpeza Lunar',
    purpose: 'Limpeza rápida e prática',
    type: SpellType.banishment,
    category: SpellCategory.cleansing,
    moonPhase: MoonPhase.fullMoon,
    ingredients: [
      'Frasco spray',
      'Água da lua cheia',
      'Sal marinho',
      'Alecrim',
      'Lavanda',
      'Cristal de quartzo',
    ],
    steps: '''1. Na lua cheia, coloque água em recipiente sob a lua
2. Adicione pitada de sal e ervas
3. Deixe o quartzo dentro
4. Pela manhã, coe e coloque no spray
5. Para usar: borrife no ambiente ou em você
6. Diga: "Estou limpo e protegido"
7. Recarregue o spray na próxima lua cheia''',
    observations: 'Prático para limpezas rápidas. Mantenha refrigerado.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Sal nos Cantos',
    purpose: 'Limpar e proteger ambiente',
    type: SpellType.banishment,
    category: SpellCategory.cleansing,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Sal grosso',
    ],
    steps: '''1. Coloque uma pitada de sal em cada canto da casa
2. Comece pela porta de entrada, vá anti-horário
3. Em cada canto diga: "Este espaço está limpo e protegido"
4. Deixe por 24 horas
5. Varra e jogue o sal fora (não reutilize)
6. Lave o chão com água e vinagre''',
    duration: 1,
    observations: 'Método simples e muito efetivo. Faça mensalmente.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Banho de Descarrego Completo',
    purpose: 'Limpar energia pessoal pesada',
    type: SpellType.banishment,
    category: SpellCategory.cleansing,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Sal grosso',
      'Arruda',
      'Guiné',
      'Alecrim',
      'Alfazema',
      'Água',
    ],
    steps: '''1. Ferva todas as ervas em água
2. Coe e reserve
3. Tome banho normal normalmente
4. Jogue o banho de ervas do pescoço para baixo
5. Visualize tudo de ruim sendo lavado
6. Diga 3 vezes: "Estou limpo, estou renovado, estou protegido"
7. Deixe secar naturalmente
8. Vista roupas limpas''',
    duration: 1,
    observations: 'Pós situações muito pesadas. Potente limpeza energética.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Limpeza com Som',
    purpose: 'Limpar com vibração sonora',
    type: SpellType.banishment,
    category: SpellCategory.cleansing,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Sino, taça tibetana ou palmas',
    ],
    steps: '''1. Comece pela porta de entrada
2. Toque o sino (ou bata palmas) em cada canto
3. Continue por todo ambiente
4. A vibração quebra energia estagnada
5. Visualize som dispersando névoa escura
6. Diga: "Com este som, limpo e renovo este espaço"
7. Termine na porta de entrada novamente''',
    duration: 1,
    observations: 'Método sem fumaça, ótimo para quem tem sensibilidade respiratória.',
    isPreloaded: true,
  ),

  // ============================================
  // BANIMENTO (4 feitiços)
  // ============================================

  SpellModel(
    name: 'Cebola de Banimento',
    purpose: 'Absorver e banir negatividade',
    type: SpellType.banishment,
    category: SpellCategory.banishing,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Cebola roxa grande',
      'Alfinetes ou pregos',
      'Sal grosso',
    ],
    steps: '''1. Corte a cebola ao meio
2. Escreva o nome da pessoa/situação a banir em papel
3. Coloque o papel entre as metades
4. Una com alfinetes
5. Enterre em local afastado ou jogue em lixeira longe
6. Diga: "Como esta cebola apodrece, assim se vai [situação/pessoa] da minha vida"
7. Lave bem as mãos
8. Não olhe para trás''',
    duration: 1,
    observations: 'Apenas para situações/pessoas tóxicas. Use com responsabilidade.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Vela Preta de Banimento',
    purpose: 'Banir pessoa ou energia negativa',
    type: SpellType.banishment,
    category: SpellCategory.banishing,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Vela preta',
      'Papel e caneta',
      'Alho em pó',
      'Pimenta preta',
      'Sal',
    ],
    steps: '''1. Escreva o que deseja banir no papel
2. Coloque o papel embaixo da vela
3. Circunde com sal, alho e pimenta
4. Acenda a vela
5. Visualize a situação se afastando
6. Diga: "Eu te libero, você está banido da minha vida"
7. Deixe queimar completamente
8. Enterre ou jogue fora os restos longe de casa''',
    duration: 1,
    observations: 'Sempre finalize com limpeza pessoal e proteção.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Corda de Banimento',
    purpose: 'Cortar laços energéticos',
    type: SpellType.banishment,
    category: SpellCategory.banishing,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Corda preta ou linha grossa',
      'Tesoura ou faca',
      'Vela preta',
    ],
    steps: '''1. Acenda a vela
2. Segure a corda
3. Visualize a conexão que quer cortar
4. Diga: "Este laço já não me serve"
5. Corte a corda com decisão
6. Queime os pedaços na vela
7. Diga: "Estou livre"
8. Jogue as cinzas ao vento ou água corrente''',
    duration: 1,
    observations: 'Poderoso para encerrar relacionamentos ou vícios energéticos.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Freezer Spell (Congelamento)',
    purpose: 'Parar fofocas ou comportamento prejudicial',
    type: SpellType.banishment,
    category: SpellCategory.banishing,
    ingredients: [
      'Papel',
      'Recipiente com água',
      'Freezer',
    ],
    steps: '''1. Escreva nome da pessoa e comportamento a cessar
2. Dobre o papel para fora (afastando)
3. Coloque no recipiente com água
4. Diga: "Suas ações contra mim estão congeladas"
5. Coloque no freezer
6. Deixe congelado até a situação resolver
7. Quando resolver, descongele e jogue fora''',
    observations: 'Não prejudica, apenas imobiliza ação negativa. Ético para autodefesa.',
    isPreloaded: true,
  ),

  // ============================================
  // SORTE (3 feitiços)
  // ============================================

  SpellModel(
    name: 'Sache da Sorte',
    purpose: 'Atrair boa sorte geral',
    type: SpellType.attraction,
    category: SpellCategory.luck,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Saquinho verde ou dourado',
      'Trevo (se encontrar)',
      'Canela',
      'Manjericão',
      'Estrela de anis',
      'Moeda de sorte',
      'Citrino ou aventurina',
    ],
    steps: '''1. Coloque todos ingredientes no saquinho
2. Segure entre as mãos
3. Visualize oportunidades surgindo
4. Diga: "Sorte me acompanha onde quer que eu vá"
5. Carregue com você
6. Toque no saquinho ao precisar de sorte
7. Recarregue na lua cheia''',
    observations: 'Quanto mais você acredita, mais funciona.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Vela Laranja da Oportunidade',
    purpose: 'Abrir portas de oportunidades',
    type: SpellType.attraction,
    category: SpellCategory.luck,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Vela laranja',
      'Óleo essencial de laranja',
      'Canela',
      'Aventurina',
    ],
    steps: '''1. Unja a vela com óleo de laranja
2. Role em canela
3. Coloque aventurina ao lado
4. Acenda a vela
5. Visualize portas se abrindo
6. Diga: "Oportunidades fluem para mim com facilidade"
7. Deixe queimar por 30 minutos
8. Apague e repita por 3 dias seguidos''',
    duration: 3,
    observations: 'Ótimo antes de eventos importantes ou mudanças de vida.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Mão da Sorte',
    purpose: 'Sorte em jogos e apostas',
    type: SpellType.attraction,
    category: SpellCategory.luck,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Canela em pó',
      'Sal',
      'Sua mão dominante',
    ],
    steps: '''1. Misture canela e sal
2. Esfregue na palma da mão dominante
3. Visualize você ganhando
4. Diga: "Sorte está em minhas mãos"
5. Sopre a mistura ao vento (para fora)
6. Não lave as mãos imediatamente
7. Use essa mão para jogar/apostar''',
    duration: 1,
    observations: 'Magia não garante vitória. Jogue responsavelmente.',
    isPreloaded: true,
  ),

  // ============================================
  // CRIATIVIDADE (2 feitiços)
  // ============================================

  SpellModel(
    name: 'Vela Amarela da Inspiração',
    purpose: 'Desbloquear criatividade',
    type: SpellType.attraction,
    category: SpellCategory.creativity,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Vela amarela ou laranja',
      'Óleo essencial de laranja ou limão',
      'Canela',
      'Cornalina ou citrino',
    ],
    steps: '''1. Unja a vela com óleo
2. Role em canela
3. Coloque o cristal ao lado
4. Acenda a vela em seu espaço criativo
5. Diga: "Criatividade flui através de mim"
6. Trabalhe em seu projeto com a vela acesa
7. Repita sempre que precisar''',
    observations: 'A chama representa a faísca criativa. Mantenha acesa enquanto trabalha.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Chá da Inspiração',
    purpose: 'Estimular ideias criativas',
    type: SpellType.attraction,
    category: SpellCategory.creativity,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Chá verde ou branco',
      'Hortelã',
      'Gengibre',
      'Limão',
      'Mel',
    ],
    steps: '''1. Prepare o chá com intenção de despertar criatividade
2. Adicione os ingredientes
3. Mexa em sentido horário
4. Diga: "Este chá desperta meu gênio criativo"
5. Beba enquanto visualiza ideias fluindo
6. Sente-se para criar logo após''',
    duration: 1,
    observations: 'Funciona como ritual para entrar em estado criativo.',
    isPreloaded: true,
  ),

  // ============================================
  // COMUNICAÇÃO (2 feitiços)
  // ============================================

  SpellModel(
    name: 'Mel na Língua',
    purpose: 'Adoçar palavras e comunicação',
    type: SpellType.attraction,
    category: SpellCategory.communication,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Mel',
      'Seu dedo',
    ],
    steps: '''1. Coloque um pouco de mel no dedo
2. Toque levemente sua língua com mel
3. Visualize suas palavras sendo bem recebidas
4. Diga mentalmente: "Minhas palavras são doces e bem recebidas"
5. Use antes de conversas importantes
6. Tenha consciência do que diz''',
    duration: 1,
    observations: 'Antes de entrevistas, apresentações ou conversas difíceis.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Vela Azul da Comunicação Clara',
    purpose: 'Melhorar expressão e ser compreendido',
    type: SpellType.attraction,
    category: SpellCategory.communication,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Vela azul clara',
      'Óleo de lavanda ou hortelã',
      'Sodalita ou lápis lazúli',
      'Papel e caneta azul',
    ],
    steps: '''1. Escreva sua intenção de comunicação clara
2. Coloque o papel embaixo da vela
3. Unja a vela com óleo
4. Coloque o cristal ao lado
5. Acenda a vela
6. Diga: "Eu me expresso com clareza, sou ouvido e compreendido"
7. Deixe queimar enquanto visualiza comunicação fluindo
8. Carregue o cristal quando for se comunicar''',
    duration: 1,
    observations: 'Chakra laríngeo (garganta). Ótimo para quem tem dificuldade de se expressar.',
    isPreloaded: true,
  ),

  // ============================================
  // SONHOS (3 feitiços)
  // ============================================

  SpellModel(
    name: 'Travesseiro dos Sonhos',
    purpose: 'Sonhos proféticos e lúcidos',
    type: SpellType.attraction,
    category: SpellCategory.dreams,
    moonPhase: MoonPhase.fullMoon,
    ingredients: [
      'Saquinho pequeno de tecido',
      'Lavanda',
      'Artemísia',
      'Camomila',
      'Ametista pequena',
    ],
    steps: '''1. Na lua cheia, coloque as ervas e cristal no saquinho
2. Segure e diga: "Que meus sonhos sejam claros e memoráveis"
3. Coloque sob ou dentro do travesseiro
4. Antes de dormir, diga: "Lembro de meus sonhos claramente"
5. Mantenha diário de sonhos perto da cama
6. Anote ao acordar''',
    observations: 'Artemísia é potente para sonhos. Pode causar sonhos intensos.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Água Lunar dos Sonhos',
    purpose: 'Clarear sonhos e intuição',
    type: SpellType.attraction,
    category: SpellCategory.dreams,
    moonPhase: MoonPhase.fullMoon,
    ingredients: [
      'Água',
      'Copo ou jarra de vidro',
      'Ametista ou pedra da lua',
    ],
    steps: '''1. Na lua cheia, coloque água no copo
2. Adicione o cristal
3. Deixe sob luz da lua durante a noite
4. Pela manhã, retire o cristal
5. Beba um gole antes de dormir
6. Diga: "Esta água lunar clareia meus sonhos"
7. Anote sonhos ao acordar''',
    observations: 'Água lunar potencializa conexão com inconsciente.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Óleo de Unção para Sonhos',
    purpose: 'Facilitar sonhos lúcidos',
    type: SpellType.attraction,
    category: SpellCategory.dreams,
    moonPhase: MoonPhase.fullMoon,
    ingredients: [
      'Óleo de base (jojoba ou amêndoas)',
      'Óleo essencial de lavanda',
      'Artemísia',
      'Camomila',
      'Frasco pequeno',
    ],
    steps: '''1. Misture óleos essenciais com óleo base
2. Adicione pitadas de ervas
3. Deixe sob a lua cheia
4. Antes de dormir, unja terceiro olho (entre sobrancelhas)
5. Unja pulsos também
6. Diga: "Estou consciente em meus sonhos"
7. Durma com intenção de sonhar lúcido''',
    observations: 'Pratique técnicas de sonho lúcido junto com o óleo para melhores resultados.',
    isPreloaded: true,
  ),

  // ============================================
  // ENERGIA (3 feitiços)
  // ============================================

  SpellModel(
    name: 'Vela Vermelha de Vitalidade',
    purpose: 'Aumentar energia física',
    type: SpellType.attraction,
    category: SpellCategory.energy,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Vela vermelha',
      'Óleo de canela',
      'Gengibre em pó',
      'Cornalina ou jaspe vermelho',
    ],
    steps: '''1. Unja a vela com óleo
2. Role em gengibre
3. Coloque o cristal ao lado
4. Acenda a vela
5. Visualize energia vibrante te preenchendo
6. Diga: "Estou cheio de energia vital e força"
7. Deixe queimar enquanto faz algo ativo
8. Carregue o cristal para energia constante''',
    duration: 1,
    observations: 'Não substitui descanso necessário. Use quando precisar de energia extra.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Banho Energizante',
    purpose: 'Renovar energia vital',
    type: SpellType.attraction,
    category: SpellCategory.energy,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Alecrim',
      'Hortelã',
      'Casca de laranja',
      'Gengibre',
      'Sal marinho',
    ],
    steps: '''1. Ferva as ervas em água
2. Coe e deixe esfriar um pouco
3. Tome banho normal
4. Despeje do pescoço para baixo
5. Visualize energia dourada te preenchendo
6. Diga: "Estou renovado e energizado"
7. Deixe secar naturalmente
8. Vista roupas vibrantes se possível''',
    duration: 1,
    observations: 'Melhor pela manhã para começar o dia com energia.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Cristal de Energia Pessoal',
    purpose: 'Carregar cristal com energia',
    type: SpellType.attraction,
    category: SpellCategory.energy,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Quartzo transparente ou citrino',
      'Luz do sol',
    ],
    steps: '''1. Limpe o cristal
2. Segure-o entre as mãos
3. Visualize luz dourada entrando por sua coroa
4. Sinta a energia fluir para suas mãos
5. Programe o cristal: "Você armazena e me devolve energia quando preciso"
6. Coloque no sol por 2 horas
7. Carregue com você
8. Segure quando precisar de energia''',
    observations: 'Recarregue o cristal ao sol mensalmente.',
    isPreloaded: true,
  ),

  // ============================================
  // CASA E LAR (2 feitiços)
  // ============================================

  SpellModel(
    name: 'Proteção e Bênção do Lar',
    purpose: 'Abençoar e proteger a casa',
    type: SpellType.attraction,
    category: SpellCategory.home,
    moonPhase: MoonPhase.waxingCrescent,
    ingredients: [
      'Sal grosso',
      'Alecrim',
      'Lavanda',
      'Água',
      'Vela branca',
    ],
    steps: '''1. Ferva água com ervas
2. Adicione sal
3. Deixe esfriar e coe
4. Acenda a vela branca
5. Vá de cômodo em cômodo borrif ando ou passando pano
6. Em cada cômodo diga: "Esta casa é abençoada, protegida e cheia de amor"
7. Termine na porta de entrada
8. Deixe a vela queimar completamente''',
    duration: 1,
    observations: 'Faça ao se mudar ou mensalmente para renovar a energia.',
    isPreloaded: true,
  ),

  SpellModel(
    name: 'Vassoura de Bruxa para Lar',
    purpose: 'Limpar e renovar energia da casa',
    type: SpellType.banishment,
    category: SpellCategory.home,
    moonPhase: MoonPhase.waningCrescent,
    ingredients: [
      'Vassoura',
      'Alecrim fresco',
      'Fita roxa ou preta',
      'Sal',
    ],
    steps: '''1. Amarre alecrim no cabo da vassoura com a fita
2. Espalhe sal pelo chão
3. Comece pela porta de entrada
4. Varra cada cômodo em movimento de "varrer para fora"
5. Diga: "Varro toda negatividade, trago renovação"
6. Junte o sal e jogue fora longe de casa
7. Mantenha vassoura atrás da porta ou em armário''',
    duration: 1,
    observations: 'Semanalmente ou após energia pesada em casa.',
    isPreloaded: true,
  ),
];
