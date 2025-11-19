import '../models/crystal_model.dart';

final List<CrystalModel> crystalsData = [
  const CrystalModel(
    name: 'Quartzo Rosa',
    description:
        'Pedra do amor próprio e do amor incondicional. Promove paz interior e cura emocional.',
    element: Element.water,
    imageUrl: 'https://cdn.pixabay.com/photo/2016/03/23/22/25/rose-quartz-1275681_1280.jpg',
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
    imageUrl: 'https://cdn.pixabay.com/photo/2017/01/20/15/59/crystal-1994858_1280.jpg',
    intentions: [
      'Proteção espiritual',
      'Intuição',
      'Meditação',
      'Clareza mental',
      'Sono tranquilo',
      'Transformação',
    ],
    usageTips: [
      'Coloque no quarto para sonhos protetores',
      'Medite segurando-a para abrir o terceiro olho',
      'Use durante práticas espirituais',
      'Carregue para proteção psíquica',
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
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Outros cristais',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sol nascente (breve)',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Pode perder cor com exposição prolongada ao sol',
    ],
  ),
  const CrystalModel(
    name: 'Citrino',
    description:
        'Pedra da prosperidade e abundância. Atrai sucesso, alegria e energia positiva.',
    element: Element.fire,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/05/12/17/14/citrine-5163032_1280.jpg',
    intentions: [
      'Prosperidade',
      'Abundância',
      'Sucesso',
      'Alegria',
      'Confiança',
      'Criatividade',
    ],
    usageTips: [
      'Coloque na carteira ou caixa registradora',
      'Use no escritório para sucesso profissional',
      'Medite para atrair abundância',
      'Coloque em plantas para energia positiva',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente',
        isSafe: false,
        warning: 'Pode desbotar - prefira outros métodos',
      ),
      CrystalMethod(
        method: 'Fumaça de ervas',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol (manhã)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Quartzo transparente',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Muito sensível ao sol - pode perder cor rapidamente',
      'Evite calor excessivo',
    ],
  ),
  const CrystalModel(
    name: 'Turmalina Negra',
    description:
        'Poderosa pedra de proteção e aterramento. Bloqueia energias negativas.',
    element: Element.earth,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/04/24/13/05/stone-5087138_1280.jpg',
    intentions: [
      'Proteção',
      'Aterramento',
      'Limpeza energética',
      'Bloqueio de negatividade',
      'Equilíbrio',
      'Purificação',
    ],
    usageTips: [
      'Coloque nos cantos da casa para proteção',
      'Carregue para se proteger de energias pesadas',
      'Use durante meditação de aterramento',
      'Coloque perto de eletrônicos',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente com sal',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça de alecrim ou sálvia',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra (enterrar)',
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
      CrystalMethod(
        method: 'Sol',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Quartzo Transparente',
    description:
        'Mestre curador e amplificador. Pode ser programado para qualquer intenção.',
    element: Element.spirit,
    imageUrl: 'https://cdn.pixabay.com/photo/2018/02/15/06/14/mineral-3154042_1280.jpg',
    intentions: [
      'Amplificação de energia',
      'Clareza',
      'Cura geral',
      'Programação de intenções',
      'Limpeza',
      'Equilíbrio',
    ],
    usageTips: [
      'Programe com sua intenção',
      'Use para amplificar outros cristais',
      'Medite para clareza mental',
      'Coloque em água para energizar',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz do sol ou lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol ou lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Intenção e visualização',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Selenita',
    description:
        'Pedra da paz e purificação. Auto-limpante, não precisa de limpeza frequente.',
    element: Element.air,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/02/11/17/01/selenite-4839523_1280.jpg',
    intentions: [
      'Purificação',
      'Paz',
      'Clareza mental',
      'Conexão espiritual',
      'Limpeza de ambientes',
      'Proteção suave',
    ],
    usageTips: [
      'Coloque em ambientes para purificar',
      'Use para limpar outros cristais',
      'Medite para paz interior',
      'Coloque sob o travesseiro (cuidado - é frágil)',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água',
        isSafe: false,
        warning: 'NUNCA use água - dissolve a selenita!',
      ),
      CrystalMethod(
        method: 'Auto-limpante',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua (se desejar)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Auto-carregante',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'NUNCA molhe - dissolve em água',
      'Muito frágil - manuseie com cuidado',
      'Não deixe ao sol - pode ficar opaca',
    ],
  ),
  const CrystalModel(
    name: 'Labradorita',
    description:
        'Pedra mística da transformação e magia. Protege contra energias negativas e aguça intuição.',
    element: Element.air,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/01/16/11/38/labradorite-4769618_1280.jpg',
    intentions: [
      'Proteção psíquica',
      'Intuição e clarividência',
      'Transformação',
      'Magia',
      'Força interior',
      'Sincronicidade',
    ],
    usageTips: [
      'Use durante trabalhos mágicos',
      'Medite para desenvolver intuição',
      'Carregue para proteção áurica',
      'Coloque no altar',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente (rápido)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Lua cheia',
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
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Olho de Tigre',
    description:
        'Pedra de coragem, proteção e prosperidade. Fortalece a confiança e traz boa sorte.',
    element: Element.fire,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/02/09/14/13/tiger-eye-4832664_1280.jpg',
    intentions: [
      'Coragem e força',
      'Proteção',
      'Prosperidade',
      'Confiança',
      'Aterramento',
      'Boa sorte',
    ],
    usageTips: [
      'Carregue para coragem e confiança',
      'Coloque no trabalho para sucesso',
      'Use durante negociações',
      'Medite para equilíbrio',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Howlita',
    description:
        'Pedra calmante da paciência e consciência. Excelente para insônia e ansiedade.',
    element: Element.air,
    imageUrl: 'https://cdn.pixabay.com/photo/2021/01/14/11/30/howlite-5916694_1280.jpg',
    intentions: [
      'Calma e paciência',
      'Sono tranquilo',
      'Redução de ansiedade',
      'Consciência',
      'Memória',
      'Comunicação calma',
    ],
    usageTips: [
      'Coloque sob o travesseiro para insônia',
      'Medite para reduzir ansiedade',
      'Carregue durante situações estressantes',
      'Use para acalmar raiva',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente (breve)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Lua',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Quartzo',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Pirita',
    description:
        'Pedra da prosperidade e manifestação. Atrai abundância e protege contra negatividade.',
    element: Element.earth,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/06/06/12/46/pyrite-5265502_1280.jpg',
    intentions: [
      'Prosperidade',
      'Manifestação',
      'Proteção',
      'Confiança',
      'Memória',
      'Vitalidade',
    ],
    usageTips: [
      'Coloque no escritório ou negócio',
      'Carregue na carteira',
      'Use em rituais de prosperidade',
      'Coloque em cofres ou gavetas de dinheiro',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água',
        isSafe: false,
        warning: 'Pode enferrujar - evite água!',
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Não molhe - pode enferrujar e liberar enxofre',
      'Mantenha seca',
    ],
  ),
  const CrystalModel(
    name: 'Pedra da Lua',
    description:
        'Pedra sagrada da lua e do feminino. Conecta com ciclos lunares e intuição.',
    element: Element.water,
    imageUrl: 'https://cdn.pixabay.com/photo/2021/08/11/14/54/moonstone-6538407_1280.jpg',
    intentions: [
      'Intuição',
      'Ciclos femininos',
      'Novos começos',
      'Equilíbrio emocional',
      'Sonhos',
      'Fertilidade',
    ],
    usageTips: [
      'Use durante a lua cheia',
      'Coloque sob o travesseiro para sonhos',
      'Carregue para equilíbrio hormonal',
      'Medite para conexão lunar',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente (breve)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Luz da lua',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua cheia (especialmente)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Água da lua',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Evite sol intenso - pode desbotar',
    ],
  ),
  const CrystalModel(
    name: 'Obsidiana Negra',
    description:
        'Poderosa pedra de proteção e aterramento. Absorve e transforma energias negativas.',
    element: Element.earth,
    imageUrl: 'https://cdn.pixabay.com/photo/2017/09/25/14/45/obsidian-2785774_1280.jpg',
    intentions: [
      'Proteção forte',
      'Aterramento',
      'Transformação',
      'Verdade',
      'Limpeza profunda',
      'Liberação de traumas',
    ],
    usageTips: [
      'Use para proteção intensa',
      'Medite para trabalho sombra',
      'Coloque na entrada da casa',
      'Carregue para proteção pessoal',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente com sal',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra (enterrar)',
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
      'Muito poderosa - use com consciência',
      'Pode trazer emoções à superfície',
    ],
  ),
  const CrystalModel(
    name: 'Sodalita',
    description:
        'Pedra da lógica, verdade e comunicação. Estimula pensamento racional e intuição.',
    element: Element.air,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/03/14/15/50/sodalite-4930732_1280.jpg',
    intentions: [
      'Comunicação clara',
      'Verdade e honestidade',
      'Lógica e racionalidade',
      'Intuição',
      'Auto-aceitação',
      'Paz interior',
    ],
    usageTips: [
      'Use durante estudos',
      'Carregue para comunicação clara',
      'Medite para equilíbrio lógica/intuição',
      'Coloque no escritório',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente (breve)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Lua',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Quartzo',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Cornalina',
    description:
        'Pedra da criatividade, coragem e vitalidade. Estimula motivação e confiança.',
    element: Element.fire,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/07/03/14/20/carnelian-5365445_1280.jpg',
    intentions: [
      'Criatividade',
      'Coragem e confiança',
      'Vitalidade e energia',
      'Motivação',
      'Fertilidade',
      'Manifestação',
    ],
    usageTips: [
      'Use para projetos criativos',
      'Carregue para energia e motivação',
      'Medite no chakra sacral',
      'Coloque no espaço de trabalho',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Jaspe Vermelho',
    description:
        'Pedra de aterramento, força e estabilidade. Conecta com a energia da Terra.',
    element: Element.earth,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/03/07/16/58/red-jasper-4910138_1280.jpg',
    intentions: [
      'Aterramento',
      'Força física',
      'Estabilidade',
      'Resistência',
      'Coragem',
      'Vitalidade',
    ],
    usageTips: [
      'Use para aterramento',
      'Carregue para força física',
      'Medite no chakra raiz',
      'Coloque no ambiente para estabilidade',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Terra (enterrar)',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Sol',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Ágata',
    description:
        'Pedra de equilíbrio, harmonia e proteção suave. Estabiliza energias e acalma.',
    element: Element.earth,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/02/03/17/26/agate-4816574_1280.jpg',
    intentions: [
      'Equilíbrio emocional',
      'Harmonia',
      'Proteção suave',
      'Estabilidade',
      'Concentração',
      'Aceitação',
    ],
    usageTips: [
      'Use para equilíbrio emocional',
      'Carregue para estabilidade',
      'Medite para paz interior',
      'Coloque em ambientes para harmonia',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água corrente',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Sol ou lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Terra',
        isSafe: true,
      ),
    ],
    safetyWarnings: [],
  ),
  const CrystalModel(
    name: 'Fluorita',
    description:
        'Pedra do foco, aprendizado e organização mental. Excelente para estudos.',
    element: Element.air,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/05/21/16/40/fluorite-5201028_1280.jpg',
    intentions: [
      'Foco e concentração',
      'Aprendizado',
      'Organização mental',
      'Limpeza áurica',
      'Decisões claras',
      'Memória',
    ],
    usageTips: [
      'Use durante estudos',
      'Coloque na mesa de trabalho',
      'Medite para clareza mental',
      'Carregue para foco',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água',
        isSafe: false,
        warning: 'Evite água - pode danificar',
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Quartzo',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Frágil - manuseie com cuidado',
      'Evite sol intenso',
    ],
  ),
  const CrystalModel(
    name: 'Lápis Lazúli',
    description:
        'Pedra da sabedoria, verdade e visão espiritual. Abre o terceiro olho.',
    element: Element.air,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/01/09/15/00/lapis-lazuli-4753916_1280.jpg',
    intentions: [
      'Sabedoria',
      'Verdade',
      'Visão espiritual',
      'Comunicação superior',
      'Intuição',
      'Paz interior',
    ],
    usageTips: [
      'Medite para abrir terceiro olho',
      'Use para comunicação verdadeira',
      'Carregue para sabedoria',
      'Coloque no altar',
    ],
    cleaningMethods: [
      CrystalMethod(
        method: 'Água',
        isSafe: false,
        warning: 'Evite água - pode danificar',
      ),
      CrystalMethod(
        method: 'Fumaça',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Som',
        isSafe: true,
      ),
    ],
    chargingMethods: [
      CrystalMethod(
        method: 'Lua',
        isSafe: true,
      ),
      CrystalMethod(
        method: 'Quartzo ou ametista',
        isSafe: true,
      ),
    ],
    safetyWarnings: [
      'Não molhe - pode manchar ou danificar',
      'Mantenha longe de produtos químicos',
    ],
  ),
];
