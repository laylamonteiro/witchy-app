import '../models/oracle_card_model.dart';

/// As 44 cartas do Oráculo — conteúdo em português (idioma-base).
///
/// Os campos `id` e `emoji` são invariantes entre idiomas; nome, mensagem,
/// orientação e palavras-chave são traduzidos. Mantenha a mesma ordem nos
/// três arquivos (`oracle_cards_data_pt/en/es.dart`) — a paridade é
/// verificada em `test/content_parity_test.dart`.
const List<OracleCard> oracleCardsPt = [
  OracleCard(
    id: 1,
    name: 'A Lua Cheia',
    message: 'É hora de colher o que plantou',
    emoji: '🌕',
    guidance: 'A Lua Cheia ilumina sua jornada e traz à tona tudo que estava oculto. '
        'Este é um momento de culminação e realização. Seus esforços estão dando frutos',
    keywords: ['realização', 'iluminação', 'culminação'],
  ),
  OracleCard(
    id: 2,
    name: 'A Lua Nova',
    message: 'Novos começos aguardam',
    emoji: '🌑',
    guidance: 'A Lua Nova representa um portal para novos começos. '
        'Plante suas intenções agora e veja-as crescer. Este é o momento perfeito para iniciar',
    keywords: ['novos começos', 'intenção', 'plantio'],
  ),
  OracleCard(
    id: 3,
    name: 'O Caldeirão',
    message: 'Transformação está em processo',
    emoji: '🪄',
    guidance: 'Dentro do caldeirão, elementos se misturam e se transformam. '
        'Você está no meio de uma transformação profunda. Confie no processo',
    keywords: ['transformação', 'alquimia', 'mudança'],
  ),
  OracleCard(
    id: 4,
    name: 'A Vassoura',
    message: 'Limpe o que não serve mais',
    emoji: '🧹',
    guidance: 'A vassoura varre energias estagnadas. É hora de uma limpeza profunda '
        'em sua vida. Libere o velho para dar espaço ao novo',
    keywords: ['limpeza', 'liberação', 'renovação'],
  ),
  OracleCard(
    id: 5,
    name: 'O Grimório',
    message: 'Conhecimento ancestral está disponível',
    emoji: '📖',
    guidance: 'O grimório guarda sabedoria antiga. Estude, aprenda e conecte-se '
        'com os ensinamentos dos antigos. O conhecimento é poder',
    keywords: ['sabedoria', 'estudo', 'ancestralidade'],
  ),
  OracleCard(
    id: 6,
    name: 'A Vela',
    message: 'Sua luz interior brilha forte',
    emoji: '🕯️',
    guidance: 'A chama da vela nunca vacila. Sua luz interior é poderosa e constante. '
        'Confie em sua própria sabedoria e intuição',
    keywords: ['luz interior', 'fé', 'clareza'],
  ),
  OracleCard(
    id: 7,
    name: 'O Cristal',
    message: 'Clareza e cura chegam',
    emoji: '💎',
    guidance: 'Cristais amplificam energia e trazem cura. Você está entrando em um '
        'período de maior clareza e bem-estar. Permita-se curar',
    keywords: ['cura', 'clareza', 'amplificação'],
  ),
  OracleCard(
    id: 8,
    name: 'O Pentagrama',
    message: 'Proteção divina está com você',
    emoji: '⭐',
    guidance: 'O pentagrama é um símbolo de proteção. Você está seguro e protegido '
        'pelas forças divinas. Nada de mal pode alcançá-lo',
    keywords: ['proteção', 'segurança', 'divino'],
  ),
  OracleCard(
    id: 9,
    name: 'O Athame',
    message: 'Corte o que não serve',
    emoji: '🗡️',
    guidance: 'O athame corta com precisão. É hora de tomar decisões firmes e '
        'eliminar o que não ressoa mais com você',
    keywords: ['decisão', 'corte', 'firmeza'],
  ),
  OracleCard(
    id: 10,
    name: 'O Cálice',
    message: 'Receba as bênçãos oferecidas',
    emoji: '🏆',
    guidance: 'O cálice está cheio de bênçãos esperando para serem recebidas. '
        'Abra-se para receber amor, abundância e alegria',
    keywords: ['receber', 'bênçãos', 'abundância'],
  ),
  OracleCard(
    id: 11,
    name: 'O Fogo',
    message: 'Paixão e ação são necessárias',
    emoji: '🔥',
    guidance: 'O fogo queima, transforma e ilumina. É hora de agir com paixão '
        'e determinação. Deixe seu fogo interior guiar você',
    keywords: ['paixão', 'ação', 'transformação'],
  ),
  OracleCard(
    id: 12,
    name: 'A Terra',
    message: 'Estabilidade e manifestação',
    emoji: '🌍',
    guidance: 'A Terra oferece fundação sólida. Suas intenções estão se manifestando '
        'no plano físico. Continue firme em seu caminho',
    keywords: ['estabilidade', 'manifestação', 'aterramento'],
  ),
  OracleCard(
    id: 13,
    name: 'O Ar',
    message: 'Novos pensamentos e ideias fluem',
    emoji: '💨',
    guidance: 'O Ar traz clareza mental e novas perspectivas. Abra sua mente para '
        'novas ideias e formas de pensar',
    keywords: ['clareza mental', 'ideias', 'comunicação'],
  ),
  OracleCard(
    id: 14,
    name: 'A Água',
    message: 'Flua com suas emoções',
    emoji: '💧',
    guidance: 'A Água nos ensina a fluir. Permita-se sentir profundamente e '
        'siga o fluxo de suas emoções com confiança',
    keywords: ['emoções', 'intuição', 'fluidez'],
  ),
  OracleCard(
    id: 15,
    name: 'A Coruja',
    message: 'Sabedoria oculta se revela',
    emoji: '🦉',
    guidance: 'A Coruja vê através da escuridão. Segredos e sabedoria oculta '
        'estão sendo revelados para você. Preste atenção',
    keywords: ['sabedoria', 'revelação', 'visão'],
  ),
  OracleCard(
    id: 16,
    name: 'O Gato Preto',
    message: 'Magia está ao seu redor',
    emoji: '🐈‍⬛',
    guidance: 'O Gato Preto caminha entre mundos. Você está cercado de magia '
        'e sincronicidades. Reconheça os sinais',
    keywords: ['magia', 'mistério', 'sincronicidade'],
  ),
  OracleCard(
    id: 17,
    name: 'A Serpente',
    message: 'Renascimento e cura profunda',
    emoji: '🐍',
    guidance: 'A Serpente troca de pele e renasce. Você está passando por uma '
        'transformação profunda. Deixe o velho morrer para renascer',
    keywords: ['renascimento', 'cura', 'transformação'],
  ),
  OracleCard(
    id: 18,
    name: 'A Aranha',
    message: 'Você é a criadora de sua teia',
    emoji: '🕷️',
    guidance: 'A Aranha tece pacientemente sua teia. Você está criando sua própria '
        'realidade. Tece com intenção e cuidado',
    keywords: ['criação', 'paciência', 'destino'],
  ),
  OracleCard(
    id: 19,
    name: 'O Corvo',
    message: 'Mensagens dos reinos invisíveis',
    emoji: '🐦‍⬛',
    guidance: 'O Corvo é mensageiro entre mundos. Preste atenção às mensagens '
        'que chegam de formas inesperadas',
    keywords: ['mensagem', 'magia', 'mistério'],
  ),
  OracleCard(
    id: 20,
    name: 'A Rosa',
    message: 'Amor e beleza florescem',
    emoji: '🌹',
    guidance: 'A Rosa simboliza amor em sua forma mais pura. Abra seu coração '
        'para dar e receber amor verdadeiro',
    keywords: ['amor', 'beleza', 'abertura'],
  ),
  OracleCard(
    id: 21,
    name: 'A Árvore',
    message: 'Raízes profundas e crescimento',
    emoji: '🌳',
    guidance: 'A Árvore está firme em suas raízes enquanto cresce em direção ao céu. '
        'Equilibre aterramento com expansão',
    keywords: ['aterramento', 'crescimento', 'equilíbrio'],
  ),
  OracleCard(
    id: 22,
    name: 'As Estrelas',
    message: 'Esperança e orientação divina',
    emoji: '⭐',
    guidance: 'As Estrelas guiam os perdidos. Mesmo na escuridão, há luz e esperança. '
        'Confie na orientação que você recebe',
    keywords: ['esperança', 'guia', 'orientação'],
  ),
  OracleCard(
    id: 23,
    name: 'O Sol',
    message: 'Alegria e vitalidade chegam',
    emoji: '☀️',
    guidance: 'O Sol brilha com força total. Este é um período de alegria, '
        'vitalidade e sucesso. Brilhe sua luz!',
    keywords: ['alegria', 'vitalidade', 'sucesso'],
  ),
  OracleCard(
    id: 24,
    name: 'A Tempestade',
    message: 'Após a tempestade, vem a calma',
    emoji: '⛈️',
    guidance: 'Tempestades passam e trazem renovação. Se você está enfrentando desafios, '
        'saiba que eles são temporários',
    keywords: ['desafio', 'renovação', 'temporário'],
  ),
  OracleCard(
    id: 25,
    name: 'O Arco-Íris',
    message: 'Promessa de tempos melhores',
    emoji: '🌈',
    guidance: 'O Arco-Íris é sinal de esperança e promessa. Tempos melhores '
        'estão chegando. Mantenha a fé',
    keywords: ['esperança', 'promessa', 'beleza'],
  ),
  OracleCard(
    id: 26,
    name: 'A Chave',
    message: 'Você tem a chave da resposta',
    emoji: '🔑',
    guidance: 'A Chave que você procura está dentro de você. Você já sabe a resposta, '
        'confie em sua sabedoria interior',
    keywords: ['resposta', 'sabedoria', 'confiança'],
  ),
  OracleCard(
    id: 27,
    name: 'A Porta',
    message: 'Novas oportunidades se abrem',
    emoji: '🚪',
    guidance: 'Uma porta se abre quando outra se fecha. Novas oportunidades '
        'estão se apresentando. Seja corajoso para cruzá-las',
    keywords: ['oportunidade', 'coragem', 'novo caminho'],
  ),
  OracleCard(
    id: 28,
    name: 'O Espelho',
    message: 'Olhe para dentro',
    emoji: '🪞',
    guidance: 'O Espelho reflete a verdade. É hora de olhar honestamente para si mesmo '
        'e reconhecer suas próprias verdades',
    keywords: ['autoconhecimento', 'verdade', 'reflexão'],
  ),
  OracleCard(
    id: 29,
    name: 'A Ampulheta',
    message: 'O timing divino está em ação',
    emoji: '⏳',
    guidance: 'A Ampulheta marca o tempo perfeito. Confie no timing divino. '
        'Tudo acontece no momento certo',
    keywords: ['timing', 'paciência', 'confiança'],
  ),
  OracleCard(
    id: 30,
    name: 'A Ancora',
    message: 'Mantenha-se firme e estável',
    emoji: '⚓',
    guidance: 'A Âncora mantém o navio firme na tempestade. Encontre sua estabilidade '
        'interior e mantenha-se centrado',
    keywords: ['estabilidade', 'firmeza', 'centro'],
  ),
  OracleCard(
    id: 31,
    name: 'A Borboleta',
    message: 'Transformação completa está acontecendo',
    emoji: '🦋',
    guidance: 'A Borboleta emerge da crisálida transformada. Você está passando '
        'por uma metamorfose profunda. Confie no processo',
    keywords: ['metamorfose', 'transformação', 'beleza'],
  ),
  OracleCard(
    id: 32,
    name: 'A Balança',
    message: 'Busque equilíbrio e justiça',
    emoji: '⚖️',
    guidance: 'A Balança pesa com precisão. É hora de buscar equilíbrio em sua vida '
        'e agir com justiça e integridade',
    keywords: ['equilíbrio', 'justiça', 'integridade'],
  ),
  OracleCard(
    id: 33,
    name: 'A Coroa',
    message: 'Reconheça seu poder pessoal',
    emoji: '👑',
    guidance: 'Você é soberano de sua vida. É hora de reconhecer e reivindicar '
        'seu poder pessoal. Você é digno',
    keywords: ['poder', 'soberania', 'dignidade'],
  ),
  OracleCard(
    id: 34,
    name: 'O Coração',
    message: 'Siga a voz do seu coração',
    emoji: '❤️',
    guidance: 'O Coração sabe o caminho. Suas emoções e intuições são guias válidos. '
        'Confie no que seu coração diz',
    keywords: ['coração', 'amor', 'intuição'],
  ),
  OracleCard(
    id: 35,
    name: 'A Roda',
    message: 'Ciclos mudam, tudo é transitório',
    emoji: '☸️',
    guidance: 'A Roda gira eternamente. Tudo é cíclico. Se está difícil agora, '
        'a roda vai girar. Se está bom, aproveite',
    keywords: ['ciclos', 'mudança', 'impermanência'],
  ),
  OracleCard(
    id: 36,
    name: 'O Caminho',
    message: 'Confie na jornada',
    emoji: '🛤️',
    guidance: 'O Caminho se revela passo a passo. Você não precisa ver todo o trajeto, '
        'apenas o próximo passo. Continue caminhando',
    keywords: ['jornada', 'confiança', 'passo a passo'],
  ),
  OracleCard(
    id: 37,
    name: 'A Fonte',
    message: 'Abundância flui infinitamente',
    emoji: '⛲',
    guidance: 'A Fonte nunca seca. O universo é abundante e há o suficiente para todos. '
        'Permita-se receber',
    keywords: ['abundância', 'fluxo', 'receber'],
  ),
  OracleCard(
    id: 38,
    name: 'O Labirinto',
    message: 'O caminho pode ser tortuoso, mas leva ao centro',
    emoji: '🌀',
    guidance: 'O Labirinto não é uma prisão, mas uma jornada para o centro de si mesmo. '
        'Cada volta tem um propósito',
    keywords: ['jornada interior', 'propósito', 'paciência'],
  ),
  OracleCard(
    id: 39,
    name: 'A Ponte',
    message: 'Conexões importantes surgem',
    emoji: '🌉',
    guidance: 'A Ponte conecta dois lados. Você está criando conexões importantes '
        'ou transitando entre fases da vida',
    keywords: ['conexão', 'transição', 'união'],
  ),
  OracleCard(
    id: 40,
    name: 'A Montanha',
    message: 'Grandes conquistas exigem esforço',
    emoji: '⛰️',
    guidance: 'A Montanha é alta, mas a vista do topo vale a pena. Continue subindo, '
        'passo a passo. Você é capaz',
    keywords: ['desafio', 'conquista', 'perseverança'],
  ),
  OracleCard(
    id: 41,
    name: 'O Oceano',
    message: 'Profundezas emocionais pedem exploração',
    emoji: '🌊',
    guidance: 'O Oceano é vasto e profundo. Suas emoções também são. É hora de '
        'mergulhar fundo e explorar o que está abaixo da superfície',
    keywords: ['profundidade', 'emoção', 'exploração'],
  ),
  OracleCard(
    id: 42,
    name: 'A Semente',
    message: 'Potencial infinito espera para germinar',
    emoji: '🌱',
    guidance: 'Dentro da Semente está todo o potencial de uma árvore. Dentro de você '
        'está todo o potencial para criar sua vida. Nutra suas sementes',
    keywords: ['potencial', 'crescimento', 'início'],
  ),
  OracleCard(
    id: 43,
    name: 'A Colheita',
    message: 'Receba os frutos de seu trabalho',
    emoji: '🌾',
    guidance: 'A Colheita é generosa para quem plantou e cuidou. É hora de receber '
        'os frutos de seu trabalho e dedicação',
    keywords: ['colheita', 'recompensa', 'abundância'],
  ),
  OracleCard(
    id: 44,
    name: 'O Infinito',
    message: 'Você é eterno e ilimitado',
    emoji: '∞',
    guidance: 'O símbolo do Infinito lembra que você é mais do que este corpo e '
        'este momento. Você é eterno, infinito e ilimitado',
    keywords: ['eternidade', 'infinito', 'ilimitado'],
  ),
];
