import '../models/crystal_model.dart';

final List<CrystalModel> crystalsData = [
  const CrystalModel(
    name: 'Quartzo Rosa',
    description:
        'Pedra do amor próprio e do amor incondicional. Promove paz interior e cura emocional.',
    element: Element.water,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Rosenquarz_1.jpg/800px-Rosenquarz_1.jpg',
    intentions: [
      'Amor próprio',
      'Auto-aceitação',
      'Cura emocional',
      'Relacionamentos',
      'Compaixão',
    ],
    usageTips: [
      'Coloque sob o travesseiro para sonhos amorosos',
      'Use no altar de amor próprio',
      'Carregue no bolso para atrair amor',
      'Medite segurando-o no coração',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente',
        isSafe: false,
        warning: 'Pode desbotar com exposição prolongada à água',
      ),
      CrystalMethod(
        method: 'Fumaça de ervas (incenso, palo santo)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som (sino, taça tibetana)',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia (preferencialmente)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra (enterrar por 24h)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Outros cristais (ametista, quartzo)',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Pode desbotar com exposição prolongada ao sol',
      'Evite água por longos períodos',
    ],
  ),
  const CrystalModel(
    name: 'Ametista',
    description:
        'Pedra da espiritualidade e proteção. Acalma a mente e promove clareza mental.',
    element: Element.air,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Amethyst._Magaliesburg%2C_South_Africa.jpg/800px-Amethyst._Magaliesburg%2C_South_Africa.jpg',
    intentions: [
      'Proteção espiritual',
      'Intuição',
      'Meditação',
      'Clareza mental',
      'Transformação',
    ],
    usageTips: [
      'Use durante meditação',
      'Coloque no altar para proteção',
      'Sob o travesseiro para sonhos lúcidos',
      'No ambiente de trabalho para foco',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som (sino, taça tibetana)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra (enterrar brevemente)',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia ou crescente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sol direto',
        isSafe: false,
        warning: 'Pode desbotar com exposição ao sol',
      ),
      CrystalMethod(
        method: 'Cluster de quartzo',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'NUNCA exponha ao sol direto - a ametista desbota rapidamente',
    ],
  ),
  const CrystalModel(
    name: 'Citrino',
    description:
        'Pedra da prosperidade e abundância. Atrai sucesso, alegria e energia positiva.',
    element: Element.fire,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Citrine_facet.jpg/800px-Citrine_facet.jpg',
    intentions: [
      'Prosperidade',
      'Abundância',
      'Sucesso',
      'Autoconfiança',
      'Manifestação',
    ],
    usageTips: [
      'Coloque na carteira para atrair dinheiro',
      'No ambiente de trabalho',
      'Use em rituais de prosperidade',
      'Carregue durante entrevistas',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água corrente',
        isSafe: false,
        warning: 'Evite água prolongada - pode danificar',
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol (breves períodos - manhã)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Evite exposição prolongada à água',
      'Sol intenso pode desbotar - prefira sol da manhã',
    ],
  ),
  const CrystalModel(
    name: 'Turmalina Negra',
    description:
        'Poderosa pedra de proteção e aterramento. Bloqueia energias negativas.',
    element: Element.earth,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Schorl-121483.jpg/800px-Schorl-121483.jpg',
    intentions: [
      'Proteção',
      'Aterramento',
      'Limpeza energética',
      'Bloqueio de negatividade',
      'Equilíbrio',
    ],
    usageTips: [
      'Coloque na entrada da casa',
      'Carregue para proteção diária',
      'Use em rituais de banimento',
      'Próxima a eletrônicos',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra (enterrar)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Terra (enterrar por 24h)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Lua nova ou minguante',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sal grosso',
        isSafe: false,
        warning: 'Use com cuidado - sal pode danificar alguns cristais',
      ),
    ],
  ),
  const CrystalModel(
    name: 'Quartzo Transparente',
    description:
        'Mestre curador e amplificador. Pode ser programado para qualquer intenção.',
    element: Element.spirit,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Quartz_Br%C3%A9sil.jpg/800px-Quartz_Br%C3%A9sil.jpg',
    intentions: [
      'Amplificação de energia',
      'Clareza',
      'Cura geral',
      'Programável para qualquer intenção',
      'Limpeza energética',
    ],
    usageTips: [
      'Use com outros cristais para amplificar',
      'Programe com suas intenções',
      'Centro do altar',
      'Meditação e cura',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz do sol',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sol (manhã)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Intenção/programação',
        isSafe: true,
      ),
    ],
  ),
  const CrystalModel(
    name: 'Selenita',
    description:
        'Pedra da paz e purificação. Auto-limpante, não precisa de limpeza frequente.',
    element: Element.air,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Selenite_%28Gypsum%29.jpg/800px-Selenite_%28Gypsum%29.jpg',
    intentions: [
      'Purificação',
      'Paz',
      'Clareza mental',
      'Conexão espiritual',
      'Limpeza de outros cristais',
    ],
    usageTips: [
      'Use para limpar outros cristais',
      'Coloque no quarto para paz',
      'Meditação e conexão espiritual',
      'Nunca use com água (dissolve)',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água',
        isSafe: false,
        warning: 'NUNCA use água - selenita dissolve completamente!',
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Auto-limpante (raramente precisa)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Intenção',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      '⚠️ CRÍTICO: NUNCA exponha selenita à água - ela dissolve completamente!',
      'É um cristal auto-limpante, raramente precisa de limpeza',
    ],
  ),
  const CrystalModel(
    name: 'Labradorita',
    description:
        'Pedra mística da transformação e magia. Protet contra energias negativas e aguça intuição.',
    element: Element.air,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Labradorite_detail.jpg/800px-Labradorite_detail.jpg',
    intentions: [
      'Proteção psíquica',
      'Intuição e clarividência',
      'Transformação',
      'Magia e manifestação',
      'Força interior',
    ],
    usageTips: [
      'Use durante trabalhos mágicos',
      'Medite com ela para desenvolver dons psíquicos',
      'Carregue para proteção energética',
      'Coloque no altar para amplificar magia',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água corrente',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Outros cristais',
        isSafe: true,
      ),
    ],
  ),
  const CrystalModel(
    name: 'Olho de Tigre',
    description:
        'Pedra de coragem, proteção e prosperidade. Fortalece a confiança e traz boa sorte.',
    element: Element.fire,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Tiger_eye_gem.jpg/800px-Tiger_eye_gem.jpg',
    intentions: [
      'Coragem e força',
      'Proteção',
      'Prosperidade',
      'Confiança',
      'Foco e determinação',
    ],
    usageTips: [
      'Carregue para proteção diária',
      'Use em entrevistas e apresentações',
      'Coloque na carteira para atrair dinheiro',
      'Medite para aumentar autoconfiança',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol (breves períodos)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
    ],
  ),
  const CrystalModel(
    name: 'Howlita',
    description:
        'Pedra calmante da paciência e consciência. Excelente para insônia e ansiedade.',
    element: Element.air,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Howlite.jpg/800px-Howlite.jpg',
    intentions: [
      'Calma e paciência',
      'Sono tranquilo',
      'Redução de ansiedade',
      'Consciência',
      'Comunicação serena',
    ],
    usageTips: [
      'Coloque sob travesseiro para insônia',
      'Carregue para acalmar ansiedade',
      'Use durante meditação',
      'Segure quando precisar de paciência',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água',
        isSafe: false,
        warning: 'Porosa - pode absorver água e danificar',
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Cluster de quartzo',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Evite água - é porosa e pode danificar',
    ],
  ),
  const CrystalModel(
    name: 'Pirita',
    description:
        'Pedra da prosperidade e manifestação. Atrai abundância e protege contra negatividade.',
    element: Element.earth,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/2780M-pyrite1.jpg/800px-2780M-pyrite1.jpg',
    intentions: [
      'Prosperidade',
      'Manifestação',
      'Proteção',
      'Força de vontade',
      'Confiança',
    ],
    usageTips: [
      'Coloque no ambiente de trabalho',
      'Use em rituais de prosperidade',
      'Carregue na carteira',
      'Coloque na entrada para proteção',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água',
        isSafe: false,
        warning: 'NUNCA use água - pirita oxida e pode criar ácido sulfúrico!',
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sol (breves períodos)',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      '⚠️ CRÍTICO: NUNCA use água - pirita contém enxofre e pode criar ácido!',
      'Pode oxidar e criar manchas - armazene em local seco',
    ],
  ),
  const CrystalModel(
    name: 'Pedra da Lua',
    description:
        'Pedra sagrada da lua e do feminino. Conecta com ciclos lunares e intuição.',
    element: Element.water,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Moonstone_gem.jpg/800px-Moonstone_gem.jpg',
    intentions: [
      'Intuição',
      'Ciclos femininos',
      'Novos começos',
      'Equilíbrio emocional',
      'Conexão lunar',
    ],
    usageTips: [
      'Use durante rituais de lua',
      'Carregue para equilibrar emoções',
      'Medite nos ciclos menstruais',
      'Coloque sob lua cheia para carregar',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia (ideal)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água lunar',
        isSafe: true,
      ),
    ],
  ),
  const CrystalModel(
    name: 'Obsidiana Negra',
    description:
        'Poderosa pedra de proteção e aterramento. Absorve e transforma energias negativas.',
    element: Element.earth,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/ObsidianOregon.jpg/800px-ObsidianOregon.jpg',
    intentions: [
      'Proteção forte',
      'Aterramento',
      'Transformação',
      'Trabalho de sombra',
      'Bloqueio de negatividade',
    ],
    usageTips: [
      'Use em trabalhos de sombra',
      'Coloque na entrada da casa',
      'Carregue para proteção intensa',
      'Use em rituais de banimento',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra (enterrar)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água corrente',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Lua nova',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Energia muito intensa - não use 24/7',
      'Limpe frequentemente pois absorve muita negatividade',
    ],
  ),
  const CrystalModel(
    name: 'Sodalita',
    description:
        'Pedra da lógica, verdade e comunicação. Estimula pensamento racional e intuição.',
    element: Element.air,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Sodalite_Canada.jpg/800px-Sodalite_Canada.jpg',
    intentions: [
      'Comunicação clara',
      'Verdade e honestidade',
      'Lógica e racionalidade',
      'Intuição',
      'Autoestima',
    ],
    usageTips: [
      'Use durante estudos',
      'Carregue em apresentações',
      'Medite para clareza mental',
      'Coloque no ambiente de trabalho',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água',
        isSafe: false,
        warning: 'Pode desbotar - evite água prolongada',
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Cluster de quartzo',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Evite água - pode desbotar a cor azul',
    ],
  ),
  const CrystalModel(
    name: 'Cornalina',
    description:
        'Pedra da criatividade, coragem e vitalidade. Estimula motivação e confiança.',
    element: Element.fire,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Carnelian.jpg/800px-Carnelian.jpg',
    intentions: [
      'Criatividade',
      'Coragem e confiança',
      'Vitalidade e energia',
      'Motivação',
      'Fertilidade',
    ],
    usageTips: [
      'Use durante trabalhos criativos',
      'Carregue para coragem',
      'Medite para motivação',
      'Coloque no bolso em entrevistas',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água corrente',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol (breves períodos)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
    ],
  ),
  const CrystalModel(
    name: 'Jaspe Vermelho',
    description:
        'Pedra de aterramento, força e estabilidade. Conecta com a energia da Terra.',
    element: Element.earth,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Jaspis_rot.jpg/800px-Jaspis_rot.jpg',
    intentions: [
      'Aterramento',
      'Força física',
      'Estabilidade',
      'Coragem',
      'Proteção',
    ],
    usageTips: [
      'Carregue para aterramento',
      'Use após rituais intensos',
      'Medite para conexão com a Terra',
      'Segure durante momentos estressantes',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra (enterrar)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água corrente',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sol (breves períodos)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
    ],
  ),
  const CrystalModel(
    name: 'Ágata',
    description:
        'Pedra de equilíbrio, harmonia e proteção suave. Estabiliza energias e acalma.',
    element: Element.earth,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Agate_banded_750pix.jpg/800px-Agate_banded_750pix.jpg',
    intentions: [
      'Equilíbrio emocional',
      'Harmonia',
      'Proteção suave',
      'Calma',
      'Estabilidade',
    ],
    usageTips: [
      'Carregue para equilíbrio',
      'Use em ambientes tensos',
      'Medite para harmonia',
      'Coloque em cômodos para estabilizar energia',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água corrente',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Cluster de quartzo',
        isSafe: true,
      ),
    ],
  ),
  const CrystalModel(
    name: 'Fluorita',
    description:
        'Pedra do foco, aprendizado e organização mental. Excelente para estudos.',
    element: Element.air,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Fluorite_with_iron_pyrite.jpg/800px-Fluorite_with_iron_pyrite.jpg',
    intentions: [
      'Foco e concentração',
      'Aprendizado',
      'Organização mental',
      'Clareza de pensamento',
      'Proteção psíquica',
    ],
    usageTips: [
      'Use durante estudos',
      'Coloque na mesa de trabalho',
      'Medite antes de provas',
      'Carregue para clareza mental',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água',
        isSafe: false,
        warning: 'NUNCA use água - fluorita dissolve em água!',
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Cluster de quartzo',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      '⚠️ CRÍTICO: NUNCA exponha à água - dissolve facilmente!',
      'Muito frágil - manuseie com cuidado',
    ],
  ),
  const CrystalModel(
    name: 'Lápis Lazúli',
    description:
        'Pedra da sabedoria, verdade e visão espiritual. Abre o terceiro olho.',
    element: Element.air,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Lapis_lazuli_block.jpg/800px-Lapis_lazuli_block.jpg',
    intentions: [
      'Sabedoria',
      'Verdade',
      'Visão espiritual',
      'Terceiro olho',
      'Comunicação divina',
    ],
    usageTips: [
      'Use durante meditação',
      'Coloque no terceiro olho',
      'Carregue para buscar verdade',
      'Durma com ela para sonhos vívidos',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água',
        isSafe: false,
        warning: 'Evite água - pode danificar e soltar partículas de pirita',
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Cluster de quartzo',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Evite água - contém pirita que oxida',
      'Pode soltar pó - lave as mãos após manusear',
    ],
  ),
];
