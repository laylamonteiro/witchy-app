import '../models/crystal_model.dart';

final List<CrystalModel> crystalsData = [
  const CrystalModel(
    name: 'Quartzo Rosa',
    description:
        'Pedra do amor próprio e do amor incondicional. Promove paz interior e cura emocional.',
    element: Element.water,
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
];
