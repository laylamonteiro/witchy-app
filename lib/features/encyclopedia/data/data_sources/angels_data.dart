import '../models/arcane_entry_model.dart';

/// Anjos — abordagem informativa e histórica, diferenciando tradições
/// religiosas, folclóricas, ocultistas e literárias, sem apresentar uma
/// única interpretação como verdade absoluta.
const List<ArcaneEntry> angelsData = [
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
];
