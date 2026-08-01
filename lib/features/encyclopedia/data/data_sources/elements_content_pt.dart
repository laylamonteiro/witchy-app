import '../models/elements_content_model.dart';

/// Conteúdo da página "Os Quatro Elementos" — português (idioma-base).
///
/// Emojis e a ordem/contagem das listas (Terra, Água, Fogo, Ar) são
/// invariantes entre idiomas. Mantenha a mesma estrutura nos três arquivos
/// (`elements_content_pt/en/es.dart`) — a paridade é verificada em
/// `test/encyclopedia_content_parity_test.dart`.
const ElementsContent elementsContentPt = ElementsContent(
  pageTitle: 'Os Quatro Elementos',
  introTitle: 'Sobre os 4 Elementos',
  introBody:
      'Na Wicca e na bruxaria tradicional, os quatro elementos - Terra, Água, Fogo e Ar - '
      'são forças fundamentais da natureza e da existência. Eles não são apenas substâncias físicas, '
      'mas energias primordiais que compõem toda a criação',
  introHint:
      'Explore cada elemento abaixo para compreender suas qualidades, correspondências e como trabalhar com eles',
  essenceLabel: 'Essência',
  qualitiesLabel: 'Qualidades',
  directionLabel: 'Direção Cardeal',
  seasonLabel: 'Estação',
  lifePhaseLabel: 'Fase da Vida',
  timeOfDayLabel: 'Hora do Dia',
  colorsLabel: 'Cores',
  toolsLabel: 'Ferramentas Mágicas',
  correspondencesLabel: 'Correspondências',
  elements: [
    ElementInfo(
      name: 'Terra',
      emoji: '🌍',
      essence:
          'A Terra representa estabilidade, solidez, crescimento e manifestação física. '
          'É o elemento da matéria, do corpo, da abundância material e da conexão com o mundo natural. '
          'Terra é onde as ideias se tornam realidade',
      qualities:
          'Estável, fértil, nutritiva, confiável, prática, paciente, enraizada',
      direction: 'Norte',
      season: 'Inverno (momento de recolhimento e gestação)',
      lifePhase: 'Velhice e sabedoria',
      timeOfDay: 'Meia-noite',
      colors: 'Verde, marrom, preto, amarelo (tons terrosos)',
      tools: 'Pentáculo, cristais, sal, pedras, moedas',
      correspondences:
          '• Cristais: Quartzo fumê, turmalina negra, jaspe, ágata, hematita\n'
          '• Ervas: Alecrim, cedro, patchouli, vetiver, raízes\n'
          '• Animais: Urso, veado, touro, coelho, cobra\n'
          '• Zodíaco: Touro, Virgem, Capricórnio',
      whenToWorkTitle: 'Quando Trabalhar com Terra',
      whenToWork: '• Manifestação de objetivos materiais\n'
          '• Prosperidade e abundância\n'
          '• Enraizamento e centralização\n'
          '• Cura física\n'
          '• Conexão com a natureza\n'
          '• Estabilidade e segurança\n'
          '• Crescimento e fertilidade',
    ),
    ElementInfo(
      name: 'Água',
      emoji: '🌊',
      essence:
          'A Água representa emoções, intuição, cura e purificação. '
          'É o elemento dos sentimentos profundos, do subconsciente, dos sonhos e da psique. '
          'Água flui, adapta-se e reflete a verdade interior',
      qualities:
          'Fluida, adaptável, emocional, intuitiva, curativa, purificadora, reflexiva',
      direction: 'Oeste',
      season: 'Outono (momento de colheita e reflexão)',
      lifePhase: 'Maturidade',
      timeOfDay: 'Crepúsculo',
      colors: 'Azul, turquesa, prateado, índigo, roxo',
      tools: 'Cálice, caldeirão, espelho, taça, conchas',
      correspondences:
          '• Cristais: Ametista, pedra da lua, água-marinha, pérola, sodalita\n'
          '• Ervas: Camomila, gardênia, jasmim, lótus, sálvia\n'
          '• Animais: Peixe, golfinho, cisne, sapo, lontra\n'
          '• Zodíaco: Câncer, Escorpião, Peixes',
      whenToWorkTitle: 'Quando Trabalhar com Água',
      whenToWork: '• Cura emocional e espiritual\n'
          '• Desenvolvimento da intuição\n'
          '• Trabalho com sonhos\n'
          '• Purificação energética\n'
          '• Amor e relacionamentos\n'
          '• Meditação e contemplação\n'
          '• Conexão com o subconsciente',
    ),
    ElementInfo(
      name: 'Fogo',
      emoji: '🔥',
      essence:
          'O Fogo representa transformação, paixão, vontade e poder pessoal. '
          'É o elemento da energia vital, da coragem, da criatividade e da ação. '
          'Fogo consome, transforma e ilumina',
      qualities:
          'Dinâmico, transformador, purificador, apaixonado, corajoso, energético, criativo',
      direction: 'Sul',
      season: 'Verão (momento de pico de energia)',
      lifePhase: 'Juventude e vigor',
      timeOfDay: 'Meio-dia',
      colors: 'Vermelho, laranja, dourado, amarelo brilhante',
      tools: 'Athame (adaga ritual), varinha, vela, caldeirão em chamas',
      correspondences:
          '• Cristais: Cornalina, citrino, rubi, granada, obsidiana\n'
          '• Ervas: Canela, gengibre, pimenta, manjericão, cravo\n'
          '• Animais: Dragão, leão, fênix, serpente de fogo, salamandra\n'
          '• Zodíaco: Áries, Leão, Sagitário',
      whenToWorkTitle: 'Quando Trabalhar com Fogo',
      whenToWork: '• Transformação pessoal\n'
          '• Coragem e força de vontade\n'
          '• Paixão e criatividade\n'
          '• Proteção ativa\n'
          '• Purificação energética\n'
          '• Banimento de energias negativas\n'
          '• Manifestação rápida de desejos',
    ),
    ElementInfo(
      name: 'Ar',
      emoji: '💨',
      essence:
          'O Ar representa intelecto, comunicação, pensamento e inspiração. '
          'É o elemento da mente, das ideias, da sabedoria e do conhecimento. '
          'Ar carrega mensagens, dispersa e renova',
      qualities:
          'Leve, móvel, comunicativo, intelectual, inspirador, livre, renovador',
      direction: 'Leste',
      season: 'Primavera (momento de novos começos)',
      lifePhase: 'Infância e aprendizado',
      timeOfDay: 'Amanhecer',
      colors: 'Amarelo claro, branco, azul claro, lavanda',
      tools:
          'Varinha (em algumas tradições), athame (em outras), incenso, penas, sinos',
      correspondences:
          '• Cristais: Citrino, topázio, fluorita, ágata de renda azul\n'
          '• Ervas: Lavanda, hortelã, eucalipto, sálvia branca, dente-de-leão\n'
          '• Animais: Águia, borboleta, pássaros, libélula, fada\n'
          '• Zodíaco: Gêmeos, Libra, Aquário',
      whenToWorkTitle: 'Quando Trabalhar com Ar',
      whenToWork: '• Estudo e aprendizado\n'
          '• Comunicação e eloquência\n'
          '• Viagem e movimento\n'
          '• Inspiração criativa\n'
          '• Clareza mental\n'
          '• Novos começos\n'
          '• Trabalho com divindades celestes',
    ),
  ],
  balanceTitle: 'O Equilíbrio Elemental',
  balanceIntro:
      'Na prática da bruxaria, buscar o equilíbrio dos quatro elementos é essencial. '
      'Cada elemento representa aspectos diferentes de nossa vida e personalidade:',
  balanceItems: [
    ElementBalanceItem(
        '🌍', 'Terra', 'Nosso corpo físico e recursos materiais'),
    ElementBalanceItem('🌊', 'Água', 'Nossas emoções e relacionamentos'),
    ElementBalanceItem('🔥', 'Fogo', 'Nossa energia e poder pessoal'),
    ElementBalanceItem('💨', 'Ar', 'Nossa mente e comunicação'),
  ],
  imbalanceTitle: 'Sinais de Desequilíbrio:',
  imbalanceBody:
      '• Terra em excesso: Teimosia, materialismo, resistência a mudanças\n'
      '• Água em excesso: Emotividade excessiva, instabilidade emocional\n'
      '• Fogo em excesso: Impulsividade, raiva, esgotamento\n'
      '• Ar em excesso: Distração, falta de praticidade, desconexão',
  practicesTitle: 'Como Trabalhar com os Elementos',
  practices: [
    ElementPractice(
      'Meditação Elemental',
      'Sente-se com um objeto representando cada elemento e medite sobre suas qualidades. '
          'Sinta a energia do elemento fluindo através de você',
    ),
    ElementPractice(
      'Círculo Mágico',
      'Ao lançar um círculo, invoque cada elemento em sua direção cardeal. '
          'Isso cria um espaço sagrado equilibrado e protegido',
    ),
    ElementPractice(
      'Altar Elemental',
      'Mantenha representações dos quatro elementos em seu altar para manter o equilíbrio energético',
    ),
    ElementPractice(
      'Feitiços Específicos',
      'Trabalhe com o elemento correspondente à sua intenção: '
          'Terra para prosperidade, Água para amor, Fogo para coragem, Ar para sabedoria',
    ),
    ElementPractice(
      'Conexão Diária',
      'Passe tempo na natureza conectando-se com os elementos: '
          'caminhe descalço (Terra), tome banho ritual (Água), acenda velas (Fogo), pratique respiração (Ar)',
    ),
  ],
  honoringTitle: 'Honrando os Elementos',
  honoringBody:
      'Os quatro elementos não são apenas ferramentas mágicas - eles são forças vivas que sustentam toda a existência. '
      'Ao trabalhar com os elementos, estamos nos conectando com as próprias fundações do universo. '
      '\n\nRespeite cada elemento, aprenda suas lições e permita que suas energias guiem e fortaleçam sua prática. '
      'Com o tempo, você desenvolverá uma relação profunda com cada elemento, reconhecendo sua presença '
      'tanto no mundo exterior quanto dentro de si mesmo',
);
