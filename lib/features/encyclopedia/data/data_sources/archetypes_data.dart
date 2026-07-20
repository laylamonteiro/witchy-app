import '../models/arcane_entry_model.dart';

/// Arquétipos do caminho mágico — figuras universais que habitam mitos,
/// contos e a psique, usadas como espelhos de autoconhecimento.
const List<ArcaneEntry> archetypesData = [
  ArcaneEntry(
    name: 'A Bruxa',
    emoji: '🧙‍♀️',
    summary: 'Soberania sobre o próprio poder e saber proibido',
    origin: 'Universal — do folclore europeu às benzedeiras das Américas',
    history:
        'Da curandeira da aldeia à perseguida das fogueiras, a Bruxa atravessou séculos como símbolo do poder feminino fora do controle institucional. No século XX foi ressignificada pelos movimentos de bruxaria moderna como emblema de autonomia espiritual.',
    characteristics: [
      'Autossuficiência e intimidade com a natureza',
      'Conhecimento das ervas, ciclos e mistérios',
      'Coragem de viver fora das expectativas alheias',
      'Relação direta com o sagrado, sem intermediários',
    ],
    symbolism: [
      'O caldeirão: transformação interior',
      'A vassoura: travessia entre mundos',
      'A lua: os ciclos e o oculto',
    ],
    correspondences: ['Lua', 'Artemísia', 'Obsidiana', 'Preto e violeta'],
    studyPractices: [
      'Journaling: "onde abro mão do meu poder para ser aceita?"',
      'Estudar a história das perseguições e das curandeiras locais',
    ],
    magicalUses: [
      'Invocar autoconfiança em rituais de soberania pessoal',
      'Meditação-espelho para integrar partes rejeitadas',
    ],
    cautions:
        'Arquétipos são espelhos simbólicos, não identidades fixas — use como ferramenta de reflexão.',
    related: ['A Sábia', 'A Curandeira', 'Hécate (Deusas)'],
  ),
  ArcaneEntry(
    name: 'A Curandeira',
    emoji: '🌿',
    summary: 'O dom de cuidar, restaurar e devolver o equilíbrio',
    origin: 'Universal — xamãs, benzedeiras, parteiras e herbalistas',
    history:
        'Presente em todas as culturas, a Curandeira guarda o conhecimento prático da cura: plantas, toques, palavras e rezas. Benzedeiras e parteiras mantiveram viva essa linhagem mesmo sob perseguição, transmitindo o ofício de mãe para filha.',
    characteristics: [
      'Empatia profunda e presença que acalma',
      'Conhecimento de remédios naturais e rituais de limpeza',
      'Escuta do corpo e dos sinais sutis',
    ],
    symbolism: [
      'As mãos: canal de energia e cuidado',
      'A serpente: renovação e medicina',
      'A água: limpeza e fluidez emocional',
    ],
    correspondences: ['Alecrim', 'Quartzo verde', 'Verde e branco', 'Mercúrio'],
    studyPractices: [
      'Estudar uma erva por semana (ver Enciclopédia de Ervas)',
      'Praticar autocuidado ritualizado antes de cuidar dos outros',
    ],
    magicalUses: [
      'Banhos e chás ritualísticos de limpeza',
      'Rituais de cura à distância e bênçãos',
    ],
    cautions:
        'Cuidar dos outros não substitui cuidar de si; a Curandeira sombria se esgota em nome do próximo. Práticas energéticas não substituem medicina.',
    related: ['Ervas (Enciclopédia)', 'A Mãe', 'Brigid (Deusas)'],
  ),
  ArcaneEntry(
    name: 'A Vidente',
    emoji: '👁️',
    summary: 'Ver além do véu: intuição, oráculos e profecia',
    origin: 'Oráculo de Delfos, sibilas romanas, videntes do folclore',
    history:
        'Das pitonisas gregas às cartomantes de feira, a Vidente encarna a capacidade humana de ler sinais e pressentir. Sempre reverenciada e temida, seu dom desafia a lógica linear do tempo.',
    characteristics: [
      'Intuição aguçada e sonhos significativos',
      'Conforto com símbolos, presságios e ambiguidade',
      'Sensibilidade às energias de pessoas e lugares',
    ],
    symbolism: [
      'O terceiro olho: percepção sutil',
      'A névoa: o véu entre os mundos',
      'O espelho e a bola de cristal: superfícies de visão',
    ],
    correspondences: ['Ametista', 'Artemísia', 'Índigo', 'Lua e Netuno'],
    studyPractices: [
      'Registrar sonhos e sincronicidades no Diário',
      'Praticar com um oráculo por vez até criar vínculo',
    ],
    magicalUses: [
      'Leituras de tarot, runas e pêndulo',
      'Meditações de abertura da intuição',
    ],
    cautions:
        'Intuição se educa com discernimento: nem todo pressentimento é profecia. Evite decisões importantes baseadas apenas em sinais.',
    related: ['Cartas do Oráculo', 'Runas', 'Pêndulo', 'Sonhos & Visões'],
  ),
  ArcaneEntry(
    name: 'A Guardiã',
    emoji: '🛡️',
    summary: 'Proteção dos limiares, das pessoas e dos espaços sagrados',
    origin: 'Guardiãs de templos, lares e encruzilhadas em todas as culturas',
    history:
        'Dos leões de pedra nos portais aos círculos de sal da bruxaria, a Guardiã vigia fronteiras: o que entra, o que sai, o que não passa. É a força que diz "até aqui" com amor e firmeza.',
    characteristics: [
      'Senso agudo de limites e justiça',
      'Lealdade e proteção aos seus',
      'Coragem serena diante de ameaças',
    ],
    symbolism: [
      'O escudo e o círculo: fronteira sagrada',
      'A chave: autoridade sobre passagens',
      'O sal: pureza que barra o indesejado',
    ],
    correspondences: ['Sal grosso', 'Arruda', 'Turmalina negra', 'Marte'],
    studyPractices: [
      'Refletir: "que limites meus precisam de reforço?"',
      'Estudar amuletos protetores de diferentes culturas',
    ],
    magicalUses: [
      'Rituais de proteção do lar e escudos energéticos',
      'Consagração de amuletos e talismãs',
    ],
    cautions:
        'Proteção em excesso vira muralha: revise se os limites guardam ou isolam.',
    related: ['Proteção & Limpeza (Grimório)', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'A Sábia',
    emoji: '🦉',
    summary: 'A anciã interior: experiência transformada em sabedoria',
    origin: 'A crone dos contos, avós e mestras de todas as tradições',
    history:
        'Terceiro rosto da Deusa Tripla, a Anciã guarda a sabedoria dos ciclos completos. Em culturas ancestrais, as mais velhas eram conselheiras da comunidade; nos contos, é a velha da floresta que testa e presenteia.',
    characteristics: [
      'Desapego das aparências e do julgamento alheio',
      'Visão de longo prazo e humor afiado',
      'Capacidade de soltar o que já cumpriu seu papel',
    ],
    symbolism: [
      'A coruja: ver no escuro',
      'A lua minguante: recolhimento fértil',
      'O fio e a tesoura: saber a hora de cortar',
    ],
    correspondences: ['Lua minguante', 'Sálvia', 'Ônix', 'Cinza e preto'],
    studyPractices: [
      'Escrever cartas da sua "eu anciã" para a sua "eu atual"',
      'Honrar as mulheres mais velhas da sua linhagem',
    ],
    magicalUses: [
      'Rituais de encerramento de ciclos na minguante',
      'Conselho interior em meditações profundas',
    ],
    cautions:
        'A sombra da Sábia é o cinismo: sabedoria sem ternura endurece.',
    related: ['A Bruxa', 'Hécate (Deusas)', 'Fases da Lua'],
  ),
  ArcaneEntry(
    name: 'A Donzela',
    emoji: '🌸',
    summary: 'Começos, frescor e a coragem do primeiro passo',
    origin: 'Primeiro rosto da Deusa Tripla; Perséfone antes do rapto',
    history:
        'A Donzela é a primavera do ciclo: curiosidade, potencial e independência juvenil. Nos mitos, é frequentemente a que parte, explora e inaugura — a energia de tudo que ainda vai florescer.',
    characteristics: [
      'Entusiasmo, abertura e fé no possível',
      'Independência e desejo de explorar',
      'Pureza de intenção — começar sem cicatrizes',
    ],
    symbolism: [
      'A lua crescente: promessa em formação',
      'As flores e sementes: potencial',
      'O amanhecer: recomeço diário',
    ],
    correspondences: ['Lua crescente', 'Jasmim', 'Quartzo rosa', 'Branco e rosa'],
    studyPractices: [
      'Listar sonhos "engavetados" que merecem primeira tentativa',
      'Praticar iniciante-mente: aprender algo do zero sem cobrança',
    ],
    magicalUses: [
      'Rituais de novos começos na lua crescente',
      'Feitiços de inspiração e frescor criativo',
    ],
    cautions:
        'A sombra da Donzela é a eterna promessa que nunca amadurece: começar também pede continuar.',
    related: ['A Mãe', 'A Sábia', 'Lua Crescente'],
  ),
  ArcaneEntry(
    name: 'A Mãe',
    emoji: '🤱',
    summary: 'Nutrição, criação e a força que faz crescer',
    origin: 'Deusas-mãe neolíticas, Deméter, Yemanjá, a Deusa Tripla',
    history:
        'Rosto central da Deusa Tripla, a Mãe é a plenitude da lua cheia: gestar, parir e sustentar — filhos, projetos, comunidades. As deusas-mãe estão entre as figuras mais antigas do sagrado humano.',
    characteristics: [
      'Generosidade, abundância e presença',
      'Fertilidade em sentido amplo: fazer crescer',
      'Fúria protetora quando os seus são ameaçados',
    ],
    symbolism: [
      'A lua cheia: plenitude',
      'O ventre e o cálice: gestação',
      'A colheita: fruto do cuidado constante',
    ],
    correspondences: ['Lua cheia', 'Camomila', 'Pedra da lua', 'Dourado e verde'],
    studyPractices: [
      'Perguntar-se: "o que estou nutrindo — e o que me nutre?"',
      'Práticas de gratidão pela linhagem materna (ver Diário)',
    ],
    magicalUses: [
      'Rituais de abundância e concretização na lua cheia',
      'Bênçãos de projetos em crescimento',
    ],
    cautions:
        'A sombra da Mãe é o controle disfarçado de cuidado e o esquecimento de si.',
    related: ['A Donzela', 'A Curandeira', 'Lua Cheia'],
  ),
  ArcaneEntry(
    name: 'A Caçadora',
    emoji: '🏹',
    summary: 'Foco, independência e a flecha que não desvia',
    origin: 'Ártemis/Diana e as senhoras da caça do folclore europeu',
    history:
        'Senhora dos bosques e protetora dos animais selvagens, a Caçadora corre livre fora dos muros da cidade. Diana tornou-se, na tradição da bruxaria italiana e na Wicca, uma das faces centrais da Deusa.',
    characteristics: [
      'Foco absoluto no alvo escolhido',
      'Autossuficiência e amor pela liberdade',
      'Instinto apurado e prontidão',
    ],
    symbolism: [
      'O arco e a flecha: intenção dirigida',
      'A floresta: território selvagem interior',
      'A matilha: lealdade sem domesticação',
    ],
    correspondences: ['Lua crescente', 'Cipreste', 'Prata', 'Sagitário'],
    studyPractices: [
      'Definir um único alvo por ciclo lunar e persegui-lo',
      'Caminhadas contemplativas na natureza',
    ],
    magicalUses: [
      'Feitiços de foco e conquista de metas',
      'Rituais de reconexão com a natureza selvagem',
    ],
    cautions:
        'A sombra da Caçadora é a solidão orgulhosa: pedir ajuda também é pontaria.',
    related: ['A Guardiã', 'Diana (Deusas)', 'Prosperidade & Caminhos'],
  ),
  ArcaneEntry(
    name: 'A Tecelã',
    emoji: '🕸️',
    summary: 'Destino, paciência e a arte de entrelaçar os fios da vida',
    origin: 'Moiras gregas, Nornas nórdicas, Aranha-Avó dos povos originários',
    history:
        'Em muitos mitos, o destino é tecido: as Moiras fiam, medem e cortam; as Nornas regam a árvore do mundo. A Tecelã lembra que cada escolha é um fio — e que padrões podem ser refeitos.',
    characteristics: [
      'Visão de padrões e conexões invisíveis',
      'Paciência de quem constrói ponto a ponto',
      'Responsabilidade pelas próprias escolhas',
    ],
    symbolism: [
      'A teia: interdependência de todas as coisas',
      'O fuso: o tempo que gira',
      'O nó: intenção fixada',
    ],
    correspondences: ['Fios e nós', 'Lavanda', 'Labradorita', 'Saturno'],
    studyPractices: [
      'Mapear padrões que se repetem na sua história',
      'Artesanato meditativo: tricô, macramê, bordado',
    ],
    magicalUses: [
      'Magia de nós (atar intenções em cordões)',
      'Rituais de reescrita de padrões na minguante',
    ],
    cautions:
        'Nem todo fio é seu para tecer: respeite o livre-arbítrio alheio.',
    related: ['Sigilos', 'Sonhos & Visões', 'A Sábia'],
  ),
  ArcaneEntry(
    name: 'A Alquimista',
    emoji: '⚗️',
    summary: 'Transmutar: transformar chumbo interior em ouro',
    origin: 'Alquimia greco-egípcia, árabe e europeia medieval',
    history:
        'Mais que precursores da química, os alquimistas buscavam a transformação da própria alma — o solve et coagula: dissolver o que endureceu e recompor em forma mais nobre. Jung releu a alquimia como mapa da individuação.',
    characteristics: [
      'Fascínio por processos de transformação',
      'Disciplina experimental: testar, observar, refinar',
      'Fé de que nada se perde, tudo se transmuta',
    ],
    symbolism: [
      'O ouroboros: ciclos que se renovam',
      'O forno (athanor): pressão que refina',
      'O ouro: a essência realizada',
    ],
    correspondences: ['Enxofre e sal simbólicos', 'Canela', 'Pirita', 'Sol'],
    studyPractices: [
      'Estudar as etapas alquímicas (nigredo, albedo, rubedo) como fases pessoais',
      'Transformar um hábito por vez, documentando o processo',
    ],
    magicalUses: [
      'Rituais de transmutação de dor em aprendizado',
      'Trabalho com o caldeirão como athanor simbólico',
    ],
    cautions:
        'Transformação real é lenta: desconfie de ouro instantâneo.',
    related: ['A Bruxa', 'Metais (Enciclopédia)', 'Energia & Cura'],
  ),
  ArcaneEntry(
    name: 'A Rainha Sombria',
    emoji: '🌑',
    summary: 'Soberania sobre a própria sombra e os territórios profundos',
    origin: 'Perséfone no submundo, Hel nórdica, a madrasta dos contos',
    history:
        'Toda psique tem porões. A Rainha Sombria governa o que foi exilado: raiva, inveja, desejo, luto. Nos mitos, descer ao submundo — como Inanna ou Perséfone — é o caminho para reinar inteira.',
    characteristics: [
      'Honestidade radical consigo mesma',
      'Capacidade de sustentar emoções difíceis sem fugir',
      'Poder pessoal que não pede desculpas',
    ],
    symbolism: [
      'O trono no escuro: dignidade nas profundezas',
      'A romã: o pacto com o próprio submundo',
      'A lua nova: o invisível fértil',
    ],
    correspondences: ['Lua nova', 'Mirra', 'Obsidiana', 'Vinho escuro e preto'],
    studyPractices: [
      'Trabalho de sombra: dialogar por escrito com o que você rejeita em si',
      'Ler os mitos de descida (Inanna, Perséfone) como roteiros interiores',
    ],
    magicalUses: [
      'Rituais de integração da sombra na lua nova',
      'Banimentos conscientes do que já foi compreendido',
    ],
    cautions:
        'Trabalho de sombra mexe com material sensível: vá no seu ritmo e busque apoio profissional quando a dor for grande.',
    related: ['A Sábia', 'Hécate (Deusas)', 'Lua Nova'],
  ),
];
