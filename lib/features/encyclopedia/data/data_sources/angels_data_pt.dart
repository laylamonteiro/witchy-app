import '../models/arcane_entry_model.dart';

/// Anjos da Enciclopédia — conteúdo em português (idioma-base).
///
/// Abordagem informativa e histórica, diferenciando tradições religiosas,
/// folclóricas, ocultistas e literárias. Emojis são invariantes; mantenha a
/// mesma ordem nos três arquivos (`angels_data_pt/en/es.dart`) — a paridade
/// é verificada em `test/content_parity_test.dart`.
const List<ArcaneEntry> angelsPt = [
  ArcaneEntry(
    name: 'Miguel',
    emoji: '⚔️',
    summary: 'O príncipe dos exércitos celestes, força e proteção',
    origin: 'Tradições judaica, cristã e islâmica (Mikael)',
    history:
        'Mencionado no Livro de Daniel e no Apocalipse, Miguel ("Quem é como Deus?") é o comandante das hostes celestes que derrota o dragão. Sua devoção atravessou o cristianismo medieval, com santuários em montes por toda a Europa.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'Arcanjo guerreiro e psicopompo: protege os fiéis, pesa as almas e lidera o combate ao mal.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'Na magia cerimonial, rege o Sul e o elemento Fogo (em algumas escolas, o Leste e o Ar), invocado em rituais de banimento como o LBRP.',
      ),
      ArcanePerspective(
        tradition: 'Folclórica/Popular',
        view:
            'Padroeiro de policiais e soldados; invocado em orações de proteção contra perigos físicos e espirituais.',
      ),
    ],
    characteristics: ['Coragem', 'Justiça', 'Liderança', 'Corte de vínculos nocivos'],
    symbolism: [
      'A espada flamejante: verdade que corta a ilusão',
      'A balança: julgamento justo',
      'O dragão vencido: a sombra dominada',
    ],
    correspondences: ['Domingo', 'Sol/Fogo', 'Dourado e vermelho', 'Olíbano'],
    studyPractices: [
      'Comparar as menções bíblicas com a angelologia medieval',
      'Contemplar: "que batalha interna pede coragem agora?"',
    ],
    magicalUses: [
      'Invocado em rituais de proteção e coragem',
      'Meditações de corte de laços energéticos',
    ],
    cautions:
        'Conteúdo histórico-informativo: as tradições divergem e nenhuma leitura é definitiva.',
    related: ['A Guardiã (Arquétipos)', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Gabriel',
    emoji: '📯',
    summary: 'O mensageiro: anúncios, revelações e o poder da palavra',
    origin: 'Tradições judaica, cristã e islâmica (Jibril)',
    history:
        'Gabriel ("Força de Deus") aparece em Daniel interpretando visões e, no Novo Testamento, anuncia os nascimentos de João Batista e Jesus. No Islã, é Jibril quem revela o Alcorão a Maomé — o grande intermediário entre o céu e a humanidade.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'O arauto divino por excelência: traz revelações, anúncios de nascimento e chamados proféticos.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'Associado ao Oeste, à Água e à Lua na magia cerimonial; rege sonhos, intuição e os mistérios do ciclo lunar.',
      ),
      ArcanePerspective(
        tradition: 'Literária',
        view:
            'Presente de Milton a obras contemporâneas como o trombeteiro do juízo e o mensageiro relutante.',
      ),
    ],
    characteristics: ['Comunicação', 'Revelação', 'Intuição', 'Fertilidade de ideias'],
    symbolism: [
      'A trombeta: o chamado que desperta',
      'O lírio: pureza da mensagem',
      'A lua: os ciclos e os sonhos',
    ],
    correspondences: ['Segunda-feira', 'Lua/Água', 'Branco e prata', 'Jasmim'],
    studyPractices: [
      'Registrar sonhos anunciadores no Diário de Sonhos',
      'Estudar as anunciações nas três tradições abraâmicas',
    ],
    magicalUses: [
      'Meditações para clareza de comunicação',
      'Trabalhos de intuição e sonhos lúcidos',
    ],
    cautions:
        'Conteúdo histórico-informativo: as tradições divergem e nenhuma leitura é definitiva.',
    related: ['A Vidente (Arquétipos)', 'Sonhos & Visões'],
  ),
  ArcaneEntry(
    name: 'Rafael',
    emoji: '💚',
    summary: 'A medicina de Deus: cura, viagens e bons encontros',
    origin: 'Livro de Tobias (tradição judaico-cristã); Israfil no Islã tem outro papel',
    history:
        'No Livro de Tobias, Rafael ("Deus cura") acompanha disfarçado o jovem Tobias, ensina remédios e cura a cegueira de seu pai — por isso é padroeiro dos viajantes, médicos e casamenteiros.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'Arcanjo da cura e companheiro de estrada: protege viagens e restaura a saúde do corpo e da alma.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'Na magia cerimonial rege o Leste e o Ar (em algumas escolas o Mercúrio), ligado ao conhecimento que cura.',
      ),
      ArcanePerspective(
        tradition: 'Folclórica/Popular',
        view:
            'Invocado em novenas por saúde, cirurgias bem-sucedidas e encontros afortunados.',
      ),
    ],
    characteristics: ['Cura', 'Companhia protetora', 'Alegria serena', 'Conhecimento prático'],
    symbolism: [
      'O cajado do viajante: a jornada guiada',
      'O peixe: o remédio inesperado',
      'O frasco de bálsamo: a medicina sagrada',
    ],
    correspondences: ['Quarta-feira', 'Mercúrio/Ar', 'Verde e amarelo', 'Lavanda'],
    studyPractices: [
      'Ler o Livro de Tobias como narrativa de cura e travessia',
      'Contemplar: "que ferida minha pede um companheiro de estrada?"',
    ],
    magicalUses: [
      'Meditações de cura e convalescência',
      'Bênçãos de viagem e proteção de caminhos',
    ],
    cautions:
        'Práticas espirituais não substituem tratamento médico. Conteúdo histórico-informativo.',
    related: ['A Curandeira (Arquétipos)', 'Energia & Cura'],
  ),
  ArcaneEntry(
    name: 'Uriel',
    emoji: '🔥',
    summary: 'O fogo de Deus: iluminação intelectual e verdade',
    origin: 'Literatura apócrifa judaica (2 Esdras, Livro de Enoque)',
    history:
        'Uriel ("Fogo/Luz de Deus") aparece nos apócrifos como o anjo que guia Esdras e vigia os portais. Fora do cânon oficial das principais igrejas, tornou-se figura central na angelologia esotérica e anglicana.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'Reverenciado em algumas igrejas orientais e anglicanas como arcanjo da sabedoria; ausente do cânon católico atual.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'Rege o Norte e o elemento Terra na magia cerimonial; guardião dos mistérios e da luz interior.',
      ),
      ArcanePerspective(
        tradition: 'Literária',
        view:
            'Em Milton, é o "olho mais aguçado do céu" — o vigia que enxerga longe.',
      ),
    ],
    characteristics: ['Sabedoria', 'Discernimento', 'Estudo', 'Verdade sem rodeios'],
    symbolism: [
      'A chama na palma: iluminação interior',
      'O pergaminho: conhecimento revelado',
      'O relâmpago: insight súbito',
    ],
    correspondences: ['Terra', 'Âmbar', 'Vermelho e ocre', 'Sândalo'],
    studyPractices: [
      'Estudos com intenção: acender uma vela antes de aprender algo novo',
      'Comparar a angelologia canônica com a apócrifa',
    ],
    magicalUses: [
      'Meditações de clareza para decisões difíceis',
      'Rituais de iluminação de caminhos e estudos',
    ],
    cautions:
        'Conteúdo histórico-informativo: as tradições divergem e nenhuma leitura é definitiva.',
    related: ['A Sábia (Arquétipos)', 'A Alquimista (Arquétipos)'],
  ),
  ArcaneEntry(
    name: 'Lúcifer',
    emoji: '🌟',
    summary: 'O anjo portador da luz: a estrela-d\'alva antes e depois da queda',
    origin: 'Latim lucifer ("portador da luz", a estrela-d\'alva); Isaías 14',
    history:
        'Originalmente o nome latino de Vênus como estrela da manhã, "Lúcifer" foi associado ao rei caído de Isaías 14 e, daí, ao anjo rebelde. Milton o tornou o anti-herói trágico de Paraíso Perdido; correntes românticas e ocultistas o releram como símbolo do conhecimento e da rebeldia luminosa.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'O anjo que caiu por orgulho; identificado a Satanás na tradição cristã.',
      ),
      ArcanePerspective(
        tradition: 'Literária',
        view:
            'Em Milton e no romantismo, o rebelde magnífico — "melhor reinar no inferno que servir no céu".',
      ),
      ArcanePerspective(
        tradition: 'Ocultista moderna',
        view:
            'Símbolo do livre-pensamento e da busca do conhecimento (luciferianismo filosófico), distinto do satanismo popular.',
      ),
    ],
    characteristics: ['Orgulho', 'Brilho intelectual', 'Rebeldia', 'Queda e busca'],
    symbolism: [
      'A estrela da manhã: a luz que precede o sol',
      'A queda: o preço da hybris',
      'A tocha: o conhecimento que liberta ou queima',
    ],
    correspondences: ['Vênus matutina', 'Enxofre simbólico', 'Azul elétrico'],
    studyPractices: [
      'Ler Isaías 14 e Paraíso Perdido em paralelo',
      'Refletir sobre orgulho saudável vs. hybris',
    ],
    magicalUses: [
      'Estudo simbólico do próprio brilho e das próprias quedas',
      'Contemplação de Vênus no céu matutino',
    ],
    cautions:
        'Conteúdo histórico-informativo. Nenhuma prática aqui envolve ou incentiva dano.',
    related: ['A Alquimista (Arquétipos)', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Metatron',
    emoji: '📖',
    summary: 'O escriba celeste e a geometria do cosmos',
    origin: 'Misticismo judaico (Talmude, literatura Hekhalot, Cabala)',
    history:
        'Na tradição mística judaica, Metatron é o escriba que registra tudo e, em algumas correntes, o profeta Enoque transfigurado. Na Cabala, associa-se à sefirá Kether — o ponto mais próximo do inefável.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Mística judaica',
        view:
            'O "príncipe da face": escriba divino e voz que transmite; figura de estudo avançado, não de culto.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista/Nova Era',
        view:
            'Ligado ao "Cubo de Metatron", figura da geometria sagrada que conteria os sólidos platônicos — leitura moderna sem fonte antiga.',
      ),
    ],
    characteristics: ['Registro', 'Ordem cósmica', 'Ascensão', 'Estudo profundo'],
    symbolism: [
      'O cubo: a estrutura da criação',
      'A pena e o livro: a memória do universo',
      'A escada: a jornada de Enoque',
    ],
    correspondences: ['Geometria sagrada', 'Selenita', 'Branco e violeta'],
    studyPractices: [
      'Estudar a geometria sagrada e desenhar o Cubo de Metatron',
      'Journaling como "escriba" da própria vida',
    ],
    magicalUses: [
      'Meditações com geometria sagrada para organização mental',
      'Rituais de registro e revisão de ciclos',
    ],
    cautions:
        'Distinga fontes antigas de releituras modernas ao estudar. Conteúdo histórico-informativo.',
    related: ['Símbolos Sagrados', 'A Tecelã (Arquétipos)'],
  ),
  ArcaneEntry(
    name: 'Sandalfon',
    emoji: '🎶',
    summary: 'O irmão gêmeo espiritual de Metatron, senhor da música e das preces',
    origin: 'Misticismo judaico; associado ao profeta Elias',
    history:
        'Na tradição mística, Sandalfon recolhe as orações humanas e as tece em coroas. Como Metatron/Enoque, seria o profeta Elias elevado — o elo entre o clamor da terra e o céu.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Mística judaica',
        view:
            'O anjo que leva as preces ao trono; associado à sefirá Malkuth, o reino terrestre.',
      ),
      ArcanePerspective(
        tradition: 'Nova Era',
        view:
            'Invocado como padroeiro da música e dos músicos, das artes que elevam.',
      ),
    ],
    characteristics: ['Devoção', 'Música', 'Enraizamento', 'Ponte terra-céu'],
    symbolism: [
      'As sandálias: caminhar sagrado na terra',
      'A coroa de preces: a força do coletivo',
      'A lira: a oração cantada',
    ],
    correspondences: ['Música devocional', 'Turquesa', 'Terra e Malkuth'],
    studyPractices: [
      'Cantar ou tocar como prática contemplativa',
      'Estudar o papel da música nas tradições religiosas',
    ],
    magicalUses: [
      'Mantras e cantos em rituais',
      'Práticas de enraizamento antes de trabalhos energéticos',
    ],
    cautions:
        'Conteúdo histórico-informativo: as tradições divergem e nenhuma leitura é definitiva.',
    related: ['Metatron', 'Afirmações (Diário)'],
  ),
  ArcaneEntry(
    name: 'Raziel',
    emoji: '🗝️',
    summary: 'O guardião dos segredos e do livro dos mistérios',
    origin: 'Cabala e literatura mística judaica (Sefer Raziel HaMalakh)',
    history:
        'Raziel ("Segredo de Deus") teria entregue a Adão um livro com todos os mistérios do universo — o lendário Sefer Raziel, cuja versão medieval circulou como grimório de proteção.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Cabalística',
        view:
            'Associado à sefirá Chokmah (sabedoria); o conhecimento oculto que precede a forma.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'O Sefer Raziel medieval era copiado como amuleto: ter o livro em casa protegeria contra incêndios.',
      ),
    ],
    characteristics: ['Mistério', 'Conhecimento esotérico', 'Proteção pelo saber'],
    symbolism: [
      'O livro selado: o saber que se conquista',
      'A chave: iniciação',
      'O véu: o oculto que se revela aos poucos',
    ],
    correspondences: ['Índigo', 'Sodalita', 'Chokmah', 'Mirra'],
    studyPractices: [
      'Manter um grimório pessoal como "seu Sefer Raziel"',
      'Estudar a história dos grimórios medievais',
    ],
    magicalUses: [
      'Consagração do grimório pessoal',
      'Meditações de acesso ao conhecimento interior',
    ],
    cautions:
        'Grimórios históricos refletem seu tempo: estude com senso crítico. Conteúdo histórico-informativo.',
    related: ['Meu Grimório', 'A Alquimista (Arquétipos)'],
  ),
  ArcaneEntry(
    name: 'Anjo da Guarda',
    emoji: '👼',
    summary: 'O companheiro pessoal: a crença universal no protetor individual',
    origin: 'Antiguidade greco-romana (daimon/genius) e tradições abraâmicas',
    history:
        'A ideia de um espírito protetor pessoal antecede o cristianismo: os gregos tinham o daimon, os romanos o genius. O cristianismo consolidou o anjo da guarda individual, e a magia cerimonial fez do contato com o "Sagrado Anjo Guardião" sua grande obra.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'Cada pessoa tem um anjo designado que protege e intercede — memorial litúrgico em 2 de outubro.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'Na tradição de Abramelin e na Golden Dawn, o "Conhecimento e Conversação do Sagrado Anjo Guardião" é o objetivo central do trabalho mágico — lido por muitos como o Eu Superior.',
      ),
      ArcanePerspective(
        tradition: 'Folclórica',
        view:
            'Orações populares ("Santo Anjo do Senhor...") e a crença cotidiana em livramentos.',
      ),
    ],
    characteristics: ['Presença constante', 'Aviso intuitivo', 'Consolo'],
    symbolism: [
      'As asas que envolvem: amparo',
      'A luz ao lado: companhia invisível',
    ],
    correspondences: ['Vela branca', 'Anjo pessoal', 'Quartzo branco'],
    studyPractices: [
      'Registrar "livramentos" e intuições protetoras no Diário',
      'Comparar o daimon socrático com o anjo da guarda cristão',
    ],
    magicalUses: [
      'Diálogo meditativo com o protetor interior',
      'Vela branca semanal em agradecimento',
    ],
    cautions:
        'Conteúdo histórico-informativo: as tradições divergem e nenhuma leitura é definitiva.',
    related: ['A Guardiã (Arquétipos)', 'Conselheiro Místico'],
  ),
  ArcaneEntry(
    name: 'Serafins',
    emoji: '🔥',
    summary: 'Os ardentes: a ordem mais próxima do trono',
    origin: 'Visão de Isaías (Antigo Testamento)',
    history:
        'Isaías os descreve com seis asas, clamando "Santo, Santo, Santo". O nome deriva de "arder" — são o amor divino em estado incandescente, o topo da hierarquia angélica de Pseudo-Dionísio.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'A ordem mais elevada, consumida em adoração perpétua diante do trono.',
      ),
      ArcanePerspective(
        tradition: 'Mística',
        view:
            'O fogo serafínico como metáfora do êxtase espiritual — o amor que purifica ao queimar.',
      ),
    ],
    characteristics: ['Ardor', 'Pureza', 'Adoração', 'Intensidade'],
    symbolism: [
      'As seis asas: reverência, prontidão e voo',
      'A brasa: purificação (a brasa nos lábios de Isaías)',
    ],
    correspondences: ['Fogo', 'Vermelho intenso', 'Olíbano e mirra'],
    studyPractices: [
      'Ler Isaías 6 e a hierarquia de Pseudo-Dionísio',
      'Contemplar: "o que em mim merece arder de entusiasmo?"',
    ],
    magicalUses: [
      'Meditações de purificação pelo fogo simbólico',
      'Velas vermelhas em práticas devocionais',
    ],
    cautions:
        'Conteúdo histórico-informativo: as tradições divergem e nenhuma leitura é definitiva.',
    related: ['Uriel', 'Elementos: Fogo'],
  ),
  ArcaneEntry(
    name: 'Querubins',
    emoji: '🌩️',
    summary: 'Os guardiões do trono e do Éden — longe dos bebês alados',
    origin: 'Gênesis, Ezequiel e a arte mesopotâmica',
    history:
        'Os querubins bíblicos guardam o Éden com espada flamejante e sustentam o trono divino nas visões de Ezequiel — seres tetramorfos imponentes, aparentados aos lamassu assírios. A imagem de bebês alados (putti) é invenção da arte renascentista.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view:
            'Guardiões do sagrado e portadores do trono; esculpidos sobre a Arca da Aliança.',
      ),
      ArcanePerspective(
        tradition: 'Histórico-artística',
        view:
            'Do tetramorfo temível ao putto decorativo: um caso exemplar de transformação iconográfica.',
      ),
    ],
    characteristics: ['Guarda implacável', 'Majestade', 'Conhecimento'],
    symbolism: [
      'As quatro faces: a totalidade da criação',
      'A espada flamejante: o limite inviolável',
      'A tempestade: o poder do sagrado',
    ],
    correspondences: ['Tempestade', 'Lápis-lazúli', 'Azul profundo'],
    studyPractices: [
      'Comparar os querubins de Ezequiel com os lamassu assírios',
      'Refletir sobre o que você guarda como inegociável',
    ],
    magicalUses: [
      'Visualizações de guarda de espaços sagrados',
      'Estudo iconográfico como meditação',
    ],
    cautions:
        'Conteúdo histórico-informativo: as tradições divergem e nenhuma leitura é definitiva.',
    related: ['A Guardiã (Arquétipos)', 'Miguel'],
  ),
  ArcaneEntry(
    name: 'Ariel',
    emoji: '🦁',
    summary: 'O leão de Deus, anjo da natureza e dos elementos',
    origin: 'Hebraico Ari\'el ("leão de Deus"); tradições cabalística e ocultista',
    history:
        'Citado em textos apócrifos e grimórios como o anjo que rege a natureza selvagem, os animais e os espíritos elementais. Na magia renascentista aparece como regente do Ar (e, em algumas fontes, da Terra), e Shakespeare o eternizou como o espírito de A Tempestade.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Cabalística',
        view: 'Nome angélico ligado à face selvagem do sagrado: a força do leão a serviço da criação.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view: 'Regente de espíritos elementais; invocado em operações de harmonia com a natureza.',
      ),
      ArcanePerspective(
        tradition: 'Literária',
        view: 'O espírito ágil de Shakespeare: o vento que serve, encanta e por fim é libertado.',
      ),
    ],
    characteristics: ['Conexão com a natureza', 'Cura ambiental', 'Coragem mansa', 'Elementais'],
    symbolism: [
      'O leão: força que protege em vez de devorar',
      'O vento: mensagens da natureza',
      'A rosa-dos-ventos: os quatro elementos em equilíbrio',
    ],
    correspondences: ['Ar e Terra', 'Verde e dourado', 'Plantas silvestres', 'Quartzo verde'],
    studyPractices: [
      'Comparar Ariel nos grimórios e em A Tempestade',
      'Caminhada contemplativa: que mensagens a natureza traz hoje?',
    ],
    magicalUses: [
      'Meditações de reconexão com a natureza e os elementos',
      'Bênçãos de jardins, plantas e animais',
    ],
    cautions:
        'Conteúdo histórico-informativo: as tradições divergem e nenhuma leitura é definitiva.',
    related: ['A Caçadora (Arquétipos)', 'Elementos'],
  ),
  ArcaneEntry(
    name: 'Haniel',
    emoji: '🌹',
    summary: 'A graça de Deus: anjo de Vênus, do amor e da lua',
    origin: 'Hebraico Hana\'el ("graça de Deus"); angelologia cabalística',
    history:
        'Na Cabala, Haniel rege a esfera de Netzach, associada a Vênus, à beleza e à vitória. A tradição o liga aos ciclos da lua e aos mistérios femininos, sendo um dos anjos mais invocados na magia planetária venusiana.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Cabalística',
        view: 'Regente de Netzach: a beleza, o desejo elevado e a persistência da vida.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view: 'Anjo planetário de Vênus, invocado às sextas-feiras em operações de amor-próprio e harmonia.',
      ),
      ArcanePerspective(
        tradition: 'Popular',
        view: 'Anjo da graça e do encanto: ajuda a ver beleza nos próprios ciclos.',
      ),
    ],
    characteristics: ['Amor-próprio', 'Harmonia', 'Intuição lunar', 'Encanto'],
    symbolism: [
      'A rosa: beleza que floresce com espinhos',
      'A lua crescente: ciclos e renovação',
      'A estrela de Vênus: o amor como bússola',
    ],
    correspondences: ['Sexta-feira', 'Vênus/Lua', 'Verde-esmeralda e rosa', 'Rosa e jasmim'],
    studyPractices: [
      'Estudar Netzach na Árvore da Vida',
      'Diário de ciclos: como a sua energia muda com a lua?',
    ],
    magicalUses: [
      'Rituais de amor-próprio e reconciliação interior',
      'Trabalhos lunares de intuição e beleza',
    ],
    cautions:
        'Conteúdo histórico-informativo: as tradições divergem e nenhuma leitura é definitiva.',
    related: ['A Donzela (Arquétipos)', 'Deusas'],
  ),
  ArcaneEntry(
    name: 'Azrael',
    emoji: '🕊️',
    summary: 'O anjo da morte e das passagens, consolo dos que atravessam',
    origin: 'Tradições islâmica e judaica (Azra\'il, "aquele a quem Deus ajuda")',
    history:
        'No Islã, Azrael é o anjo que recolhe as almas com compaixão; no folclore judaico, o mensageiro das passagens. Longe da figura sombria popular, as fontes o descrevem como servo dedicado que acompanha cada travessia com misericórdia.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'O anjo encarregado da passagem das almas, que age apenas sob ordem divina.',
      ),
      ArcanePerspective(
        tradition: 'Folclórica',
        view: 'O escriba que anota nascimentos e apaga nomes na hora da partida.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista moderna',
        view: 'Psicopompo invocado em ritos de luto e no culto respeitoso aos ancestrais.',
      ),
    ],
    characteristics: ['Compaixão', 'Travessias', 'Luto e consolo', 'Memória dos que partiram'],
    symbolism: [
      'A pena e o livro: cada vida registrada',
      'O véu: a fronteira entre os mundos',
      'A pomba: a alma que parte em paz',
    ],
    correspondences: ['Sábado', 'Saturno', 'Cinza e branco', 'Cipreste e mirra'],
    studyPractices: [
      'Comparar o Azrael islâmico com os psicopompos de outras culturas',
      'Escrever cartas de despedida ou gratidão a quem partiu',
    ],
    magicalUses: [
      'Ritos de luto, encerramento de ciclos e honra aos ancestrais',
      'Meditações de aceitação das grandes mudanças',
    ],
    cautions:
        'Conteúdo histórico-informativo. Luto profundo merece também apoio humano e profissional.',
    related: ['A Rainha Sombria (Arquétipos)', 'Roda do Ano'],
  ),
  ArcaneEntry(
    name: 'Samael',
    emoji: '⚖️',
    summary: 'O veneno de Deus: o anjo severo entre a luz e a sombra',
    origin: 'Talmude e literatura rabínica; Sama\'el ("veneno de Deus")',
    history:
        'Figura ambígua da angelologia judaica: arcanjo da severidade e acusador celeste, às vezes identificado ao anjo da morte, às vezes a Marte. No folclore cabalístico é apontado como consorte de Lilith — um dos pares mais comentados do ocultismo.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Rabínica',
        view: 'O acusador que testa os justos: severidade que serve, não que destrói.',
      ),
      ArcanePerspective(
        tradition: 'Cabalística',
        view: 'Associado a Gevurah e a Marte: a força que corta o que precisa ser cortado.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view: 'Símbolo do trabalho de sombra: encarar o acusador interno e integrá-lo.',
      ),
    ],
    characteristics: ['Severidade', 'Justiça dura', 'Limites', 'Sombra integrada'],
    symbolism: [
      'A espada de Marte: o corte necessário',
      'O veneno: o remédio na dose certa',
      'A balança inclinada: julgamento em tensão',
    ],
    correspondences: ['Terça-feira', 'Marte', 'Vermelho escuro', 'Pimenta e ferro'],
    studyPractices: [
      'Estudar Gevurah e o papel do rigor na Árvore da Vida',
      'Refletir: onde a severidade protege — e onde fere?',
    ],
    magicalUses: [
      'Meditações de limites e de trabalho de sombra',
      'Estudo simbólico do par Samael-Lilith no folclore',
    ],
    cautions:
        'Conteúdo histórico-informativo. Nenhuma prática aqui envolve ou incentiva dano.',
    related: ['Lilith (Demônios)', 'A Rainha Sombria (Arquétipos)'],
  ),
  ArcaneEntry(
    name: 'Zadkiel',
    emoji: '💜',
    summary: 'A justiça de Deus: anjo da misericórdia e da transmutação',
    origin: 'Hebraico Tzadki\'el ("justiça de Deus"); angelologia cabalística',
    history:
        'Associado na Cabala à esfera de Chesed (misericórdia) e a Júpiter, Zadkiel é lembrado como o anjo que deteve a mão de Abraão. O esoterismo moderno o ligou à "chama violeta" da transmutação, popularizada pelas escolas teosóficas.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Cabalística',
        view: 'Regente de Chesed: a generosidade que expande e perdoa.',
      ),
      ArcanePerspective(
        tradition: 'Teosófica/Nova Era',
        view: 'Guardião da chama violeta: transmutar memórias pesadas em aprendizado.',
      ),
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'O anjo da misericórdia que interrompe sacrifícios desnecessários.',
      ),
    ],
    characteristics: ['Perdão', 'Generosidade', 'Transmutação', 'Abundância justa'],
    symbolism: [
      'A chama violeta: o passado transformado',
      'O cetro de Júpiter: benevolência que governa',
      'A mão detida: a misericórdia acima do rito',
    ],
    correspondences: ['Quinta-feira', 'Júpiter', 'Violeta e azul-royal', 'Ametista'],
    studyPractices: [
      'Estudar Chesed e o equilíbrio entre dar e reter',
      'Prática de perdão: a quem você ainda cobra uma dívida interna?',
    ],
    magicalUses: [
      'Rituais de perdão e liberação de mágoas',
      'Meditações de transmutação com a chama violeta',
    ],
    cautions:
        'Conteúdo histórico-informativo: as tradições divergem e nenhuma leitura é definitiva.',
    related: ['A Curandeira (Arquétipos)', 'Cristais'],
  ),
];
