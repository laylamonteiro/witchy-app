import '../models/metal_model.dart';
import '../models/crystal_model.dart';
import '../models/herb_model.dart';

final List<MetalModel> metalsData = [
  const MetalModel(
    name: 'Ouro',
    description:
        'Metal precioso do Sol, símbolo de poder divino, realeza e perfeição. '
        'Representa a luz espiritual, a iluminação e a energia vital. '
        'Tradicionalmente usado para atrair prosperidade, sucesso e proteção.',
    element: Element.fire,
    planet: Planet.sun,
    conductsPower: true,
    magicalProperties: [
      'Prosperidade e abundância',
      'Poder pessoal',
      'Sucesso e vitória',
      'Proteção espiritual',
      'Energia vital',
      'Iluminação',
      'Autoconfiança',
      'Manifestação',
    ],
    ritualUses: [
      'Amuletos de proteção e poder',
      'Rituais solares e de prosperidade',
      'Consagração de ferramentas rituais',
      'Magia de atração de riqueza',
      'Trabalhos com deidades solares',
      'Rituais de autoconfiança e liderança',
    ],
    correspondences: [
      'Dia: Domingo',
      'Deuses: Apolo, Rá, Lugh, Balder',
      'Deusas: Brighid, Amaterasu',
      'Chakra: Plexo Solar, Coronário',
      'Sabbat: Litha (Solstício de Verão)',
      'Tarot: O Sol',
    ],
    traditionalUses:
        'Usado em coroas, cetros e objetos rituais de poder. '
        'Joias de ouro são tradicionalmente usadas para proteção '
        'e para atrair a energia solar.',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Prata',
    description:
        'Metal sagrado da Lua, símbolo de intuição, mistério e proteção psíquica. '
        'Representa o feminino divino, os ciclos e a magia lunar. '
        'É o metal mais usado em bruxaria para proteção e adivinhação.',
    element: Element.water,
    planet: Planet.moon,
    conductsPower: true,
    magicalProperties: [
      'Proteção psíquica',
      'Intuição e clarividência',
      'Conexão lunar',
      'Sonhos proféticos',
      'Purificação',
      'Magia feminina',
      'Reflexão e introspecção',
      'Adivinhação',
    ],
    ritualUses: [
      'Espelhos mágicos e bolas de cristal',
      'Joias de proteção',
      'Cálices e taças rituais',
      'Pingentes de Lua',
      'Magia lunar e dos sonhos',
      'Rituais de adivinhação',
      'Trabalhos com deidades lunares',
    ],
    correspondences: [
      'Dia: Segunda-feira',
      'Deuses: Thoth, Khonsu',
      'Deusas: Selene, Diana, Ártemis, Hécate',
      'Chakra: Terceiro Olho, Coronário',
      'Sabbat: Esbats (Luas Cheias)',
      'Tarot: A Lua, A Sacerdotisa',
    ],
    traditionalUses:
        'Tradicionalmente usada em amuletos, espelhos mágicos, '
        'cálices rituais e joias de proteção. Diz-se que a prata '
        'escurece na presença de energia negativa.',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Cobre',
    description:
        'Metal de Vênus, condutor supremo de energia mágica. '
        'Associado ao amor, beleza, harmonia e cura. '
        'É o metal mais condutor de energia após a prata.',
    element: Element.water,
    planet: Planet.venus,
    conductsPower: true,
    magicalProperties: [
      'Amor e romance',
      'Beleza e atração',
      'Harmonia e paz',
      'Cura energética',
      'Condução de energia',
      'Criatividade artística',
      'Fertilidade',
      'Equilíbrio emocional',
    ],
    ritualUses: [
      'Varinhas mágicas (núcleo de cobre)',
      'Talismãs de amor',
      'Amuletos de cura',
      'Ferramentas para conduzir energia',
      'Rituais de Vênus',
      'Magia de atração',
      'Círculos de proteção',
    ],
    correspondences: [
      'Dia: Sexta-feira',
      'Deuses: Eros, Cupido',
      'Deusas: Afrodite, Vênus, Freya, Hathor',
      'Chakra: Cardíaco',
      'Sabbat: Beltane',
      'Tarot: A Imperatriz, Os Amantes',
    ],
    traditionalUses:
        'Usado em varinhas, amuletos de amor, e ferramentas de cura. '
        'Pirâmides de cobre são usadas para amplificar energia. '
        'Pulseiras de cobre são tradicionalmente usadas para aliviar dores.',
    safetyWarnings: [
      'Pode manchar a pele de verde (não é perigoso, apenas oxidação)',
    ],
  ),
  const MetalModel(
    name: 'Ferro',
    description:
        'Metal de Marte, símbolo de proteção, força e coragem. '
        'Tradicionalmente usado para afastar espíritos malignos e fadas. '
        'Representa a força guerreira e a proteção física.',
    element: Element.fire,
    planet: Planet.mars,
    conductsPower: false,
    magicalProperties: [
      'Proteção poderosa',
      'Coragem e força',
      'Banimento de negatividade',
      'Defesa psíquica',
      'Aterramento',
      'Força de vontade',
      'Justiça',
      'Quebra de maldições',
    ],
    ritualUses: [
      'Pregos de ferro em proteção de casa',
      'Ferraduras de sorte',
      'Athames e facas rituais',
      'Caldeirões',
      'Amuletos de proteção',
      'Círculos de banimento',
      'Rituais de Marte',
    ],
    correspondences: [
      'Dia: Terça-feira',
      'Deuses: Marte, Ares, Thor, Ogum',
      'Deusas: Morrígan, Durga',
      'Chakra: Raiz, Plexo Solar',
      'Sabbat: Não associado especificamente',
      'Tarot: A Torre, O Carro',
    ],
    traditionalUses:
        'Ferraduras sobre portas para proteção. Pregos de ferro '
        'enterrados nos cantos da propriedade. Facas rituais (athames) '
        'com lâmina de ferro. Diz-se que fadas e espíritos malignos '
        'não podem atravessar ferro.',
    safetyWarnings: [
      'Enferruja facilmente - mantenha seco',
    ],
  ),
  const MetalModel(
    name: 'Estanho',
    description:
        'Metal de Júpiter, associado à expansão, crescimento e justiça. '
        'Tradicionalmente usado para atrair prosperidade, sorte e proteção legal.',
    element: Element.air,
    planet: Planet.jupiter,
    conductsPower: true,
    magicalProperties: [
      'Prosperidade e expansão',
      'Sorte e fortuna',
      'Justiça e equidade',
      'Crescimento espiritual',
      'Proteção em viagens',
      'Abundância',
      'Sabedoria',
      'Honra e reputação',
    ],
    ritualUses: [
      'Amuletos de prosperidade',
      'Rituais de justiça',
      'Magia de sorte',
      'Proteção em viagens',
      'Trabalhos com Júpiter',
      'Rituais de quinta-feira',
      'Magia de crescimento nos negócios',
    ],
    correspondences: [
      'Dia: Quinta-feira',
      'Deuses: Júpiter, Zeus, Thor, Dagda',
      'Deusas: Têmis, Fortuna',
      'Chakra: Coronário, Terceiro Olho',
      'Sabbat: Yule',
      'Tarot: A Roda da Fortuna, O Hierofante',
    ],
    traditionalUses:
        'Usado em talismãs de sorte e prosperidade. '
        'Moedas de estanho são tradicionalmente carregadas para atrair dinheiro. '
        'Também usado em sinos rituais.',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Chumbo',
    description:
        'Metal de Saturno, associado ao tempo, limites e transformação profunda. '
        'Usado em magia de banimento, proteção pesada e quebra de vícios. '
        'Representa limitações, disciplina e karma.',
    element: Element.earth,
    planet: Planet.saturn,
    conductsPower: false,
    magicalProperties: [
      'Banimento poderoso',
      'Proteção pesada',
      'Quebra de vícios',
      'Limite e disciplina',
      'Aterramento profundo',
      'Trabalho com sombras',
      'Karma e justiça divina',
      'Transformação difícil',
    ],
    ritualUses: [
      'Rituais de banimento',
      'Quebra de maldições',
      'Magia de limite',
      'Trabalhos de Saturno',
      'Rituais de sábado',
      'Enterrar intenções negativas',
      'Proteção contra magia negra',
    ],
    correspondences: [
      'Dia: Sábado',
      'Deuses: Saturno, Cronos, Hades',
      'Deusas: Hécate, As Parcas',
      'Chakra: Raiz',
      'Sabbat: Samhain',
      'Tarot: A Morte, O Eremita, O Mundo',
    ],
    traditionalUses:
        'Tradicionalmente usado para selar intenções negativas em caixas '
        'que são enterradas. Usado em pesos de proteção e em rituais '
        'de banimento definitivo.',
    safetyWarnings: [
      '⚠️ TÓXICO - Não ingerir, evitar contato prolongado com pele',
      'Lavar as mãos após manusear',
      'Não usar em caldeirões ou utensílios de cozinha',
      'Manter longe de crianças e animais',
    ],
  ),
  const MetalModel(
    name: 'Bronze',
    description:
        'Liga antiga de cobre e estanho, representa tradição, antiguidade e conexão ancestral. '
        'Usado desde tempos imemoriais em armas, escudos e objetos rituais.',
    element: Element.fire,
    planet: Planet.venus,
    conductsPower: true,
    magicalProperties: [
      'Conexão ancestral',
      'Tradição e história',
      'Proteção durável',
      'Força e resistência',
      'Magia antiga',
      'Honra aos antepassados',
      'Preservação',
      'Memória',
    ],
    ritualUses: [
      'Sinos rituais',
      'Instrumentos musicais mágicos',
      'Estátuas de deidades',
      'Caldeirões (tradicional)',
      'Trabalhos ancestrais',
      'Rituais de tradição',
      'Proteção de linhagem',
    ],
    correspondences: [
      'Dia: Sexta-feira (do cobre)',
      'Deuses: Hefesto, Goibniu, Wayland',
      'Deusas: Atena (guerreira)',
      'Chakra: Raiz, Plexo Solar',
      'Sabbat: Mabon',
      'Tarot: O Eremita, O Julgamento',
    ],
    traditionalUses:
        'Sinos de bronze são usados para limpar energia e marcar '
        'o início de rituais. Caldeirões de bronze são tradicionais '
        'em bruxaria celta. Espelhos de bronze polido eram usados '
        'na antiguidade para adivinhação.',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Latão',
    description:
        'Liga de cobre e zinco, associada à purificação, limpeza energética '
        'e proteção contra negatividade. Brilha como ouro mas é mais acessível.',
    element: Element.fire,
    planet: Planet.sun,
    conductsPower: true,
    magicalProperties: [
      'Purificação',
      'Limpeza energética',
      'Proteção contra negatividade',
      'Clareza mental',
      'Atração de sorte',
      'Afastamento de ilusões',
      'Energia solar acessível',
      'Verdade',
    ],
    ritualUses: [
      'Sinos de limpeza',
      'Incensários',
      'Tigelas de oferenda',
      'Candelabros',
      'Amuletos de proteção',
      'Rituais de purificação',
      'Limpeza de espaços',
    ],
    correspondences: [
      'Dia: Domingo',
      'Deuses: Apolo, Hélio',
      'Deusas: Brighid',
      'Chakra: Plexo Solar',
      'Sabbat: Litha',
      'Tarot: Temperança, O Mago',
    ],
    traditionalUses:
        'Tradicionalmente usado em incensários e sinos de limpeza. '
        'Objetos de latão polido são usados em altares para refletir '
        'energia negativa de volta. Substituto acessível do ouro em magia.',
    safetyWarnings: [],
  ),
  const MetalModel(
    name: 'Alumínio',
    description:
        'Metal moderno associado à proteção mental, bloqueio de influências '
        'externas e preservação de energia. Leve e versátil.',
    element: Element.air,
    planet: Planet.mercury,
    conductsPower: true,
    magicalProperties: [
      'Proteção mental',
      'Bloqueio de influências',
      'Preservação de energia',
      'Leveza e adaptabilidade',
      'Reflexão de negatividade',
      'Comunicação clara',
      'Velocidade',
      'Modernidade',
    ],
    ritualUses: [
      'Embrulhar objetos mágicos para preservação',
      'Proteção de tarot e ferramentas',
      'Rituais de bloqueio mental',
      'Magia de comunicação',
      'Refletir feitiços de volta',
      'Trabalhos de Mercúrio',
    ],
    correspondences: [
      'Dia: Quarta-feira',
      'Deuses: Mercúrio, Hermes',
      'Deusas: Atena (sabedoria)',
      'Chakra: Garganta, Terceiro Olho',
      'Sabbat: Não associado',
      'Tarot: O Louco, O Mago',
    ],
    traditionalUses:
        'Papel alumínio é usado para embrulhar e proteger cartas de tarot, '
        'cristais e objetos mágicos. Também usado para refletir energia '
        'negativa de volta à origem.',
    safetyWarnings: [],
  ),
];
