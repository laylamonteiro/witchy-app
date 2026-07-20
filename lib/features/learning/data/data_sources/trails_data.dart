import '../../../grimoire/data/models/spell_model.dart';
import '../models/trail_model.dart';

/// As trilhas do Grimório Vivo. A primeira lição de cada trilha é gratuita;
/// as demais são Premium (regra centralizada no FeatureAccess).
const List<LearningTrail> learningTrails = [
  // ═════════════ MAGIA BRANCA ═════════════
  LearningTrail(
    id: 'magia_branca',
    emoji: '🕯️',
    title: 'Magia Branca',
    subtitle: 'Luz, proteção e bênçãos',
    description:
        'O caminho da intenção luminosa: proteção, cura e bênçãos para si e para quem você ama. Dez lições, dez páginas escritas por você.',
    lessons: [
      TrailLesson(
        id: 'mb_01',
        recordKind: LessonRecordKind.note,
        title: 'A intenção é o coração',
        teaching:
            'Toda magia começa antes da vela, do cristal ou da palavra: começa na intenção. Na magia branca, a intenção é formulada de forma clara, positiva e presente — não "quero parar de ter medo", mas "eu caminho protegida e confiante".\n\nUma boa intenção tem três marcas: é específica, é sua (não controla a vontade dos outros) e é dita como se já fosse. Praticantes experientes passam mais tempo lapidando a frase do que montando o altar.',
        practice:
            'Escreva 3 versões de uma intenção importante. Corte negações, futuro distante e desejos sobre outras pessoas. Escolha a mais viva.',
        pageTitle: 'Minha Intenção de Luz',
        pagePurpose: 'Formular e consagrar uma intenção clara',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['1 vela branca', 'Papel e caneta'],
        pagePrompts: [
          'A versão final da minha intenção (clara, minha, no presente):',
          'Por que essa intenção importa para mim agora?',
          'Como vou saber que ela se realizou?',
          'O que senti ao lê-la em voz alta diante da vela?',
        ],
      ),
      TrailLesson(
        id: 'mb_02',
        title: 'O círculo de proteção',
        teaching:
            'O círculo é a tecnologia mais antiga da magia: um limite simbólico que separa o espaço sagrado do cotidiano. Sal, giz, o dedo apontado ou pura visualização — o material importa menos que o gesto consciente de dizer "aqui dentro, agora, é diferente".\n\nE o que se abre, se fecha: desfazer o círculo agradecendo é tão importante quanto traçá-lo.',
        practice:
            'Trace um círculo ao seu redor (pode ser visualizado), permaneça 3 minutos em silêncio e desfaça-o conscientemente.',
        pageTitle: 'Meu Círculo de Proteção',
        pagePurpose: 'Criar e desfazer um espaço sagrado',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Sal grosso (opcional)', 'Vela branca (opcional)'],
        pagePrompts: [
          'Como eu traço o meu círculo (material ou visualização):',
          'Minhas palavras ao abrir:',
          'Minhas palavras ao fechar:',
          'A diferença que senti entre dentro e fora:',
        ],
      ),
      TrailLesson(
        id: 'mb_03',
        title: 'Bênçãos: magia para os outros',
        teaching:
            'A bênção é a forma mais generosa da magia branca: desejar ativamente o bem, sem controlar o caminho de ninguém. A estrutura clássica: nomear quem recebe, declarar o bem desejado, selar com um gesto.\n\nRegra de ouro: abençoe sem esperar retorno e jamais para influenciar decisões alheias — isso já seria outra coisa.',
        practice:
            'Faça uma bênção silenciosa de um minuto por alguém querido, exatamente como essa pessoa é hoje.',
        pageTitle: 'Bênção da Minha Casa',
        pagePurpose: 'Abençoar o lar e quem vive nele',
        pageCategory: SpellCategory.home,
        pageIngredients: ['1 copo de água limpa', 'Vela branca'],
        pagePrompts: [
          'A bênção que criei para o meu lar:',
          'O gesto que sela a minha bênção:',
          'Cômodo por cômodo: onde senti a energia mudar?',
          'O que senti ao abençoar em vez de pedir?',
        ],
      ),
      TrailLesson(
        id: 'mb_04',
        title: 'A vela: chama e foco',
        teaching:
            'A vela é o altar portátil da magia branca: fogo que concentra a intenção num único ponto de luz. A cor conversa com o objetivo (veja a Enciclopédia de Cores), o ungir com óleo "veste" a vela, e o riscar de símbolos grava o pedido na cera.\n\nSegurança é parte do ritual: vela acesa nunca fica sozinha.',
        practice:
            'Acenda uma vela branca por 10 minutos apenas observando a chama, sem pedir nada. Só presença.',
        pageTitle: 'Meu Ritual de Vela',
        pagePurpose: 'Estruturar meu trabalho com velas',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Vela da cor escolhida', 'Óleo (opcional)', 'Palito para riscar'],
        pagePrompts: [
          'Cor escolhida e o porquê (consultei a Enciclopédia?):',
          'Como preparo a vela (unção, símbolos):',
          'O que a chama me "disse" nos 10 minutos de observação:',
          'Minhas regras pessoais de segurança:',
        ],
      ),
      TrailLesson(
        id: 'mb_05',
        title: 'Água lustral: limpeza que consagra',
        teaching:
            'Água e sal: a combinação mais antiga de purificação. A água lustral limpa objetos, espaços e a própria energia antes dos trabalhos. Prepare com presença: água limpa, uma pitada de sal, mãos sobre o vaso e uma palavra de consagração.\n\nUse borrifando, ungindo a testa e os pulsos, ou lavando ferramentas — nunca para beber.',
        practice:
            'Prepare sua primeira água lustral e limpe com ela um objeto que você usa todos os dias.',
        pageTitle: 'Minha Água Lustral',
        pagePurpose: 'Preparar e usar água de limpeza',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Água limpa', 'Sal', 'Recipiente bonito'],
        pagePrompts: [
          'Minhas palavras de consagração da água:',
          'O objeto que limpei primeiro e por quê:',
          'Onde guardo minha água lustral:',
          'Quando pretendo renová-la:',
        ],
      ),
      TrailLesson(
        id: 'mb_06',
        title: 'Escudos: proteção no dia a dia',
        teaching:
            'Nem todo dia tem altar — mas todo dia tem mundo. O escudo energético é a proteção portátil da bruxa: uma visualização treinada (esfera de luz, manto, espelhos) ativada por um gesto-gatilho discreto.\n\nO segredo é o treino: escudo se constrói em casa, com calma, para funcionar no ônibus lotado.',
        practice:
            'Visualize por 5 minutos uma esfera de luz ao seu redor. Escolha um gesto discreto (tocar o anel, cruzar os dedos) como gatilho.',
        pageTitle: 'Meu Escudo Diário',
        pagePurpose: 'Criar minha proteção portátil',
        pageCategory: SpellCategory.protection,
        pagePrompts: [
          'Como é o meu escudo (forma, cor, textura):',
          'Meu gesto-gatilho:',
          'Situações em que mais preciso dele:',
          'Primeira vez que usei "em campo" — funcionou?',
        ],
      ),
      TrailLesson(
        id: 'mb_07',
        title: 'Cura de si: o banho ritual',
        teaching:
            'O banho ritual transforma o ato mais cotidiano em ritual de cura: água morna, ervas ou sal, luz baixa e intenção. Do pescoço para baixo para limpar, da cabeça para baixo (com ervas suaves) para renovar por completo.\n\nO essencial: sair do banho diferente de como entrou — e nomear essa diferença.',
        practice:
            'Tome um banho consciente hoje: sem pressa, sem celular, visualizando a água levando o que pesa.',
        pageTitle: 'Meu Banho de Cura',
        pagePurpose: 'Criar minha receita de banho ritual',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Ervas suaves ou sal grosso', 'Vela para o banheiro'],
        pagePrompts: [
          'Minha receita (ervas/sal, preparo):',
          'O que a água leva embora:',
          'O que eu chamo para mim ao final:',
          'Como me senti depois:',
        ],
      ),
      TrailLesson(
        id: 'mb_08',
        title: 'Amuletos de luz',
        teaching:
            'O amuleto é intenção condensada em matéria: um objeto pequeno, consagrado para um único propósito, carregado junto ao corpo. Na magia branca, os clássicos são proteção (olho, sal, arruda) e bênção (medalhas, pedras claras).\n\nConsagrar é simples: limpar, declarar o propósito, energizar (luz de lua, chama, sopro) e portar com fé.',
        practice:
            'Escolha um objeto pequeno que você já ama para ser seu primeiro amuleto de luz.',
        pageTitle: 'Meu Amuleto de Luz',
        pagePurpose: 'Consagrar um amuleto pessoal',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['O objeto escolhido'],
        pagePrompts: [
          'Meu objeto e sua história comigo:',
          'O propósito único dele:',
          'Como o consagrei (limpeza, palavras, energização):',
          'Onde ele vive (bolso, corrente, bolsa):',
        ],
      ),
      TrailLesson(
        id: 'mb_09',
        title: 'Magia para momentos difíceis',
        teaching:
            'A magia branca brilha nos dias escuros: velório, diagnóstico, término. Aqui ela não "resolve" — acompanha. Um ritual mínimo para atravessar: acender uma chama, nomear a dor em voz alta, pedir força (não solução) e agradecer por estar viva para sentir.\n\nMagia madura sabe a diferença entre transformar e aceitar.',
        practice:
            'Pense numa dor atual ou antiga. Acenda uma vela e diga: "Eu te vejo. Eu te atravesso. Eu peço força."',
        pageTitle: 'Ritual para Dias Escuros',
        pagePurpose: 'Criar meu rito de travessia',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Vela branca'],
        pagePrompts: [
          'Meu rito mínimo para dias difíceis (3 passos):',
          'As palavras que me dão chão:',
          'A quem/o quê eu peço força:',
          'O que este rito NÃO promete (e está tudo bem):',
        ],
      ),
      TrailLesson(
        id: 'mb_10',
        recordKind: LessonRecordKind.gratitude,
        title: 'Encerrando com gratidão',
        teaching:
            'Todo trabalho de magia branca termina no mesmo lugar: a gratidão. Agradecer fecha o circuito da energia, reconhecendo o recebido antes de ver resultados. É também a proteção mais subestimada: um coração agradecido não opera pela carência.\n\nNesta última página, você cria seu ritual pessoal de encerramento — sua assinatura mágica.',
        practice:
            'Liste 5 coisas que a sua prática já te trouxe. Leia em voz alta como quem encerra uma cerimônia.',
        pageTitle: 'Meu Ritual de Encerramento',
        pagePurpose: 'Selar trabalhos com gratidão',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Meu gesto de encerramento:',
          'Minhas palavras de gratidão:',
          'As 5 coisas que a prática já me trouxe:',
          'Relendo esta trilha: o que virou "meu jeito"?',
        ],
      ),
    ],
  ),

  // ═════════════ MAGIA VERDE ═════════════
  LearningTrail(
    id: 'magia_verde',
    emoji: '🌿',
    title: 'Magia Verde',
    subtitle: 'O caminho das ervas e da terra',
    description:
        'A bruxaria do jardim, da cozinha e da floresta: aprender com as plantas, seus ciclos e poderes — escrevendo o seu herbário mágico.',
    lessons: [
      TrailLesson(
        id: 'mv_01',
        recordKind: LessonRecordKind.note,
        title: 'Conhecer uma planta de verdade',
        teaching:
            'A magia verde não começa decorando tabelas — começa com UMA planta conhecida de verdade: nome, cheiro, textura, como reage à água e ao sol.\n\nBruxas verdes tradicionais tinham relação profunda com poucas dúzias de plantas: colhiam na hora certa, agradeciam, usavam cada parte. Sua primeira página é o retrato de uma aliada.',
        practice:
            'Passe 5 minutos com uma planta acessível usando os cinco sentidos (com segurança). Anote 3 observações que nenhum livro daria.',
        pageTitle: 'Minha Primeira Planta Aliada',
        pagePurpose: 'Registrar a relação com uma planta',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['A planta escolhida'],
        pagePrompts: [
          'Nome da planta e onde ela vive:',
          'Minhas 3 observações diretas:',
          'Usos mágicos tradicionais (pesquisei na Enciclopédia):',
          'O que sinto perto dela:',
        ],
      ),
      TrailLesson(
        id: 'mv_02',
        title: 'O chá como ritual',
        teaching:
            'Água, fogo, planta e intenção: o chá é o ritual verde mais acessível. A diferença entre "tomar" e "ritualizar" está na presença: escolher a erva pela intenção, mexer em círculos no sentido do objetivo, beber em silêncio.\n\nSegurança primeiro: só plantas comestíveis conhecidas, respeitando contraindicações.',
        practice:
            'Prepare um chá simples com presença total: da escolha ao último gole, sem celular.',
        pageTitle: 'Meu Chá Ritual',
        pagePurpose: 'Criar uma receita ritual de chá',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Erva comestível', 'Água', 'Mel (opcional)'],
        pagePrompts: [
          'Erva e intenção do meu chá:',
          'Meu modo de preparo ritual:',
          'O que penso/digo enquanto bebo:',
          'Como pretendo repetir (7 dias? toda lua?):',
        ],
      ),
      TrailLesson(
        id: 'mv_03',
        title: 'Sachês e amuletos de ervas',
        teaching:
            'O sachê é magia verde portátil: ervas secas num saquinho de tecido, fechado com nó e palavra. Debaixo do travesseiro para sonhos, na bolsa para proteção, no armário para harmonia.\n\nMontagem clássica: erva principal (a intenção), erva de suporte e um fixador (casca, raiz, pedrinha). A cor do tecido conversa com o objetivo.',
        practice:
            'Separe ervas secas de cozinha (louro, alecrim, canela...) e sinta qual combinação pede para existir.',
        pageTitle: 'Meu Primeiro Sachê',
        pagePurpose: 'Montar um amuleto de ervas',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['3 ervas secas', 'Tecido', 'Fita ou linha'],
        pagePrompts: [
          'Intenção e as 3 ervas escolhidas (por quê?):',
          'Cor do tecido e motivo:',
          'Palavras ditas ao fechar o nó:',
          'Onde ele vive agora:',
        ],
      ),
      TrailLesson(
        id: 'mv_04',
        title: 'A cozinha como altar',
        teaching:
            'A bruxa de cozinha sabe: panela é caldeirão, colher de pau é varinha, tempero é feitiço. Cozinhar com intenção transforma alimento em magia — mexer no sentido horário para atrair, temperar nomeando o desejo, servir como quem abençoa.\n\nA refeição encantada mais poderosa é a feita para alguém que você ama (incluindo você).',
        practice:
            'Cozinhe algo simples hoje declarando uma intenção a cada ingrediente adicionado.',
        pageTitle: 'Minha Receita Encantada',
        pagePurpose: 'Transformar uma receita em feitiço',
        pageCategory: SpellCategory.home,
        pagePrompts: [
          'A receita e a intenção dela:',
          'O que declaro a cada ingrediente-chave:',
          'Meu gesto ao servir:',
          'Para quem cozinhei e o que aconteceu:',
        ],
      ),
      TrailLesson(
        id: 'mv_05',
        title: 'Plantar: o feitiço mais lento',
        teaching:
            'Plantar uma semente com intenção é o feitiço de longa duração da magia verde: o crescimento da planta espelha o crescimento do desejo. Vaso, terra, semente, palavra — e depois o verdadeiro trabalho: cuidar todos os dias.\n\nSe a planta murcha, o recado também é mágico: que cuidado está faltando, ali e na intenção?',
        practice:
            'Plante uma semente ou muda (até um grão de feijão serve) dedicando-a a uma intenção de crescimento.',
        pageTitle: 'Meu Plantio Mágico',
        pagePurpose: 'Consagrar um plantio a uma intenção',
        pageCategory: SpellCategory.prosperity,
        pageIngredients: ['Semente ou muda', 'Vaso e terra'],
        pagePrompts: [
          'O que plantei e a intenção dedicada:',
          'Minhas palavras no plantio:',
          'Meu compromisso de cuidado diário:',
          'Diário do crescimento (atualize aqui):',
        ],
      ),
      TrailLesson(
        id: 'mv_06',
        title: 'Defumação: o ar que limpa',
        teaching:
            'A fumaça de ervas é vassoura energética: alecrim para renovar, louro para prosperar, arruda para cortar. Defume dos fundos para a porta de entrada, cantos e atrás das portas, com janelas abertas — o denso sai, o novo entra.\n\nRespeite alergias, animais e a origem das ervas: magia verde é responsabilidade ecológica.',
        practice:
            'Defume um único cômodo hoje com uma erva que você tenha, observando a mudança na sensação do espaço.',
        pageTitle: 'Minha Defumação',
        pagePurpose: 'Criar meu rito de limpeza pelo ar',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Ervas secas', 'Recipiente resistente ao fogo'],
        pagePrompts: [
          'Minha mistura de defumação e o propósito de cada erva:',
          'Meu trajeto pela casa:',
          'Palavras que acompanham a fumaça:',
          'Diferença que senti no ambiente:',
        ],
      ),
      TrailLesson(
        id: 'mv_07',
        title: 'Óleos e unguentos',
        teaching:
            'O óleo condimentado é a poção de uso contínuo: azeite ou óleo vegetal + ervas + tempo. Unge velas, amuletos, pulsos e portas. Três semanas em vidro escuro, agitando diariamente com a intenção, coando ao final.\n\nRotule sempre: nome, data, propósito — bruxa organizada é bruxa poderosa.',
        practice:
            'Comece um óleo simples hoje (ex.: alecrim no azeite) dedicado a uma intenção.',
        pageTitle: 'Meu Óleo Mágico',
        pagePurpose: 'Preparar um óleo condimentado ritual',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Óleo vegetal', 'Ervas', 'Vidro escuro'],
        pagePrompts: [
          'Receita (óleo, ervas, proporções):',
          'Intenção e usos planejados:',
          'Data de início e de coar:',
          'Como foi o primeiro uso:',
        ],
      ),
      TrailLesson(
        id: 'mv_08',
        recordKind: LessonRecordKind.note,
        title: 'O jardim de lua',
        teaching:
            'A tradição planta o que cresce para cima na lua crescente e raízes na minguante; colhe folhas de poder na cheia; descansa a terra na nova. Mais que agricultura, é treino de paciência mágica: nem tudo é para agora.\n\nO Calendário Lunar do app é seu almanaque de bolso.',
        practice:
            'Descubra a fase da lua HOJE (no app) e faça uma ação verde alinhada: plantar, podar, colher ou descansar.',
        pageTitle: 'Meu Calendário Verde',
        pagePurpose: 'Alinhar plantios e intenções à lua',
        pageCategory: SpellCategory.prosperity,
        pagePrompts: [
          'Na próxima lua NOVA vou (descansar/planejar):',
          'Na CRESCENTE vou (plantar/começar):',
          'Na CHEIA vou (colher/celebrar):',
          'Na MINGUANTE vou (podar/soltar):',
        ],
      ),
      TrailLesson(
        id: 'mv_09',
        recordKind: LessonRecordKind.gratitude,
        title: 'Colheita e agradecimento',
        teaching:
            'Colher é a metade esquecida do plantio. A colheita ritual pede: hora certa (manhã após secar o orvalho, tradicionalmente), pedido de licença à planta, corte limpo, agradecimento e uso íntegro — nada colhido à toa.\n\nO mesmo vale para as colheitas simbólicas da vida: reconhecer, agradecer, usar bem.',
        practice:
            'Colha algo (uma folha do seu vaso, um fruto da feira escolhido com presença) com o rito completo: licença, corte, agradecimento.',
        pageTitle: 'Meu Rito de Colheita',
        pagePurpose: 'Ritualizar o ato de colher',
        pageCategory: SpellCategory.prosperity,
        pagePrompts: [
          'O que colhi e como pedi licença:',
          'Meu agradecimento à planta/à vida:',
          'Como usei integralmente o que colhi:',
          'Que colheita simbólica estou vivendo agora?',
        ],
      ),
      TrailLesson(
        id: 'mv_10',
        recordKind: LessonRecordKind.note,
        title: 'Seu herbário mágico',
        teaching:
            'A última página desta trilha é a capa do seu herbário: a lista viva das suas plantas aliadas, com seus usos testados por VOCÊ. O herbário da bruxa verde nunca está pronto — cresce a cada estação, como o jardim.\n\nDaqui em diante, cada planta nova merece uma página própria no seu grimório.',
        practice:
            'Releia as páginas verdes que você escreveu e visite a Enciclopédia de Ervas para escolher a próxima aliada a conhecer.',
        pageTitle: 'Meu Herbário: Índice Vivo',
        pagePurpose: 'Consolidar minhas plantas aliadas',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Minhas aliadas até aqui (planta → uso testado):',
          'A próxima planta que quero conhecer e por quê:',
          'Meu ritual verde favorito desta trilha:',
          'O que a terra me ensinou sobre tempo:',
        ],
      ),
    ],
  ),

  // ═════════════ WICCA ═════════════
  LearningTrail(
    id: 'wicca',
    emoji: '🌕',
    title: 'Wicca',
    subtitle: 'A Deusa, o Deus e a Roda do Ano',
    description:
        'Os fundamentos da religião da bruxaria moderna: dualidade divina, sabás, esbás e ética — construindo o seu Livro das Sombras.',
    lessons: [
      TrailLesson(
        id: 'wi_01',
        recordKind: LessonRecordKind.note,
        title: 'A Rede: "não prejudique ninguém"',
        teaching:
            'A ética wiccana cabe numa frase, a Rede: "Faz o que quiseres, desde que não prejudiques ninguém" — incluindo você mesma, o que muita gente esquece.\n\nDela deriva a reflexão do retorno (a "Lei Tríplice" para muitos): a energia posta em movimento volta, em qualidade mais que em aritmética. Sua primeira página é o seu código pessoal.',
        practice:
            'Lembre uma situação difícil recente. Como a Rede teria orientado sua ação? Treino, não tribunal.',
        pageTitle: 'Meu Código da Rede',
        pagePurpose: 'Traduzir a ética wiccana para minha vida',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'A Rede com as minhas palavras:',
          'Três situações reais onde ela me guia:',
          'Onde costumo me prejudicar (novo acordo comigo):',
          'O que "retorno" significa para mim:',
        ],
      ),
      TrailLesson(
        id: 'wi_02',
        recordKind: LessonRecordKind.note,
        title: 'Deusa e Deus: a dualidade',
        teaching:
            'A Wicca clássica honra o divino em dualidade: a Deusa Tripla (Donzela, Mãe, Anciã — os ciclos da lua) e o Deus Cornífero (o sol e a natureza selvagem que nasce e morre com as estações).\n\nCorrentes atuais flexibilizam essa visão. O essencial é o sagrado imanente: o divino NA natureza, não fora dela.',
        practice:
            'Ao ar livre ou à janela, observe algo da natureza por 5 minutos como um rosto do divino. Sem pedir nada.',
        pageTitle: 'Como o Sagrado me Encontra',
        pagePurpose: 'Registrar minha relação com o divino',
        pageCategory: SpellCategory.wisdom,
        pageIngredients: ['Velas prateada e dourada (opcionais)'],
        pagePrompts: [
          'Que face do sagrado me toca mais:',
          'Onde já senti isso na natureza:',
          'Meu gesto simples de devoção diária:',
          'Como foi a observação de 5 minutos:',
        ],
      ),
      TrailLesson(
        id: 'wi_03',
        recordKind: LessonRecordKind.note,
        title: 'O altar wiccano',
        teaching:
            'O altar wiccano organiza o cosmos numa mesa: os quatro elementos (pentáculo/sal para Terra, incenso para Ar, vela para Fogo, taça para Água), símbolos da Deusa e do Deus, e o athame ou varinha como condutor da vontade.\n\nComece simples: uma vela, um copo, uma pedra, uma pena. O altar cresce com a prática (visite a aba Altar da Enciclopédia).',
        practice:
            'Monte um altar mínimo com 4 objetos representando os elementos, mesmo que provisório.',
        pageTitle: 'Meu Altar',
        pagePurpose: 'Registrar a montagem do meu altar',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Onde montei e o que representa cada elemento:',
          'Símbolos da Deusa/do Deus (se escolhi ter):',
          'O que sinto diante dele:',
          'O que quero adicionar com o tempo:',
        ],
      ),
      TrailLesson(
        id: 'wi_04',
        title: 'Chamando os Quadrantes',
        teaching:
            'No ritual wiccano, o círculo se firma convidando os guardiões das quatro direções: Leste/Ar, Norte ou Sul/Fogo (conforme o hemisfério), Oeste/Água e Terra. Cada chamada é um convite respeitoso, não uma ordem.\n\nAo final, libera-se na ordem inversa, agradecendo. Adapte as direções ao seu hemisfério e registre sua escolha.',
        practice:
            'De frente para cada direção, diga um convite simples: "Guardiões do [direção], elemento [X], sejam bem-vindos ao meu círculo."',
        pageTitle: 'Minha Chamada dos Quadrantes',
        pagePurpose: 'Criar minha liturgia das direções',
        pageCategory: SpellCategory.protection,
        pagePrompts: [
          'Minha correspondência direção→elemento (e hemisfério):',
          'Minhas palavras para cada chamada:',
          'Minhas palavras de liberação:',
          'O que senti em cada direção:',
        ],
      ),
      TrailLesson(
        id: 'wi_05',
        title: 'A Roda do Ano',
        teaching:
            'A Wicca celebra o tempo como círculo: oito sabás — solstícios, equinócios e os festivais do fogo (Samhain, Imbolc, Beltane, Lughnasadh). Cada um espelha um momento interno: honrar ancestrais, renascer, florescer, colher.\n\nNo hemisfério sul, muitos invertem as datas para seguir as estações reais. Escolha sua coerência e registre-a.',
        practice:
            'Descubra o PRÓXIMO sabá (Roda do Ano do app) e planeje uma celebração de 10 minutos.',
        pageTitle: 'Meu Próximo Sabá',
        pagePurpose: 'Planejar minha primeira celebração da Roda',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Sabá e data (no meu hemisfério):',
          'O que ele celebra e o que espelha em mim:',
          'Minha celebração de 10 minutos:',
          'Depois: como foi?',
        ],
      ),
      TrailLesson(
        id: 'wi_06',
        title: 'O Esbá: magia da lua cheia',
        teaching:
            'Se os sabás celebram o sol, os esbás honram a lua — especialmente a cheia, hora clássica do trabalho mágico. Um esbá solitário: banho, círculo, saudação, "Puxar a Lua" (receber a luz em silêncio), magia ou adivinhação, bolo e vinho (ou chá e pão!), encerramento.\n\nSua página é sua primeira liturgia autoral.',
        practice:
            'Na próxima noite de lua visível, passe 3 minutos sob a luz dela, apenas recebendo.',
        pageTitle: 'Meu Ritual de Esbá',
        pagePurpose: 'Criar minha liturgia de lua cheia',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Vela branca', 'Água', 'Algo para "bolo e vinho"'],
        pagePrompts: [
          'Minha abertura (círculo + saudação):',
          'Meu momento de Puxar a Lua:',
          'O trabalho que farei nos esbás:',
          'Meu encerramento e partilha:',
        ],
      ),
      TrailLesson(
        id: 'wi_07',
        recordKind: LessonRecordKind.note,
        title: 'O Livro das Sombras',
        teaching:
            'O Livro das Sombras é o coração material da bruxa wiccana: rituais, receitas, sonhos, fracassos e descobertas — TUDO registrado. Tradicionalmente copiado à mão da mestra para a iniciada; hoje, cada bruxa inicia o seu.\n\nVocê já está escrevendo o seu: este app é ele. Esta página define como você o organiza.',
        practice:
            'Revise as páginas que você já escreveu nas trilhas e no Meu Grimório. Que estrutura emerge?',
        pageTitle: 'A Ordem do Meu Livro',
        pagePurpose: 'Organizar meu Livro das Sombras',
        pageCategory: SpellCategory.study,
        pagePrompts: [
          'Minhas seções (como organizo meus registros):',
          'O que SEMPRE registro após um ritual:',
          'Meu ritual de abertura do livro (uma frase? um símbolo?):',
          'Para quem (se alguém) eu deixaria este livro um dia:',
        ],
      ),
      TrailLesson(
        id: 'wi_08',
        title: 'Magia com a Deusa: invocação',
        teaching:
            'Invocar, na Wicca, é convidar o divino para perto — não "baixar" nem ordenar. A invocação tem três tempos: preparar-se (banho, círculo), chamar (palavras do coração, não fórmulas alheias) e ESCUTAR — o mais esquecido.\n\nO sinal de que funcionou raramente é espetacular: é um silêncio diferente, um calor, uma certeza mansa.',
        practice:
            'No seu espaço, faça uma invocação simples à energia divina que te toca. Depois, 2 minutos de escuta absoluta.',
        pageTitle: 'Minha Invocação',
        pagePurpose: 'Criar minhas palavras de chamada',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Minhas palavras de invocação:',
          'Como me preparo antes:',
          'O que percebi na escuta:',
          'Como encerro e agradeço:',
        ],
      ),
      TrailLesson(
        id: 'wi_09',
        title: 'Cakes and Wine: o sagrado que alimenta',
        teaching:
            'O rito de "bolo e vinho" encerra os rituais wiccanos aterrando a energia: abençoar o alimento, ofertar a primeira porção à terra (ou ao vaso!) e comer com presença. É eucaristia da natureza: o sagrado que vira corpo.\n\nSem vinho? Suco, chá, água. A bênção está no gesto, não no cardápio.',
        practice:
            'Abençoe um lanche simples hoje, oferte uma primeira porção simbólica e coma com total presença.',
        pageTitle: 'Meu Rito de Bolo e Vinho',
        pagePurpose: 'Criar meu rito de aterramento',
        pageCategory: SpellCategory.home,
        pagePrompts: [
          'Meu "bolo" e meu "vinho" (o que uso):',
          'Minha bênção sobre o alimento:',
          'Como faço a oferta:',
          'Diferença entre comer assim e comer no automático:',
        ],
      ),
      TrailLesson(
        id: 'wi_10',
        recordKind: LessonRecordKind.desire,
        title: 'Autoiniciação: o compromisso',
        teaching:
            'Sem coven, a bruxa solitária se autoinicia: um ritual em que VOCÊ se compromete com o caminho, diante do sagrado como o entende. Tradicionalmente após "um ano e um dia" de estudo — mas o tempo certo é o seu.\n\nEsta última página é o rascunho do seu rito de dedicação. Realize quando sentir que é hora — e volte para registrar.',
        practice:
            'Escreva (só para você) o que significa comprometer-se com este caminho. Sem prazo, sem pressa.',
        pageTitle: 'Meu Rito de Dedicação',
        pagePurpose: 'Desenhar meu compromisso com o caminho',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'O que eu prometo a mim mesma neste caminho:',
          'O rito que planejo (local, elementos, palavras):',
          'Quando saberei que é a hora:',
          '(Após realizar) Como foi o meu dia de dedicação:',
        ],
      ),
    ],
  ),

  // ═════════════ BRUXARIA TRADICIONAL ═════════════
  LearningTrail(
    id: 'bruxaria_tradicional',
    emoji: '🧹',
    title: 'Bruxaria Tradicional',
    subtitle: 'O caminho torto e os saberes antigos',
    description:
        'A bruxaria dos folclores, das benzedeiras e do caminho torto: espíritos do lugar, ancestrais e ferramentas do cotidiano — sem dogmas, com raízes.',
    lessons: [
      TrailLesson(
        id: 'bt_01',
        recordKind: LessonRecordKind.note,
        title: 'Os espíritos do lugar',
        teaching:
            'A bruxaria tradicional é enraizada no LUGAR: rios, encruzilhadas, quintais. O primeiro passo é conhecer os espíritos da terra onde você pisa — como se faz amizade: presença regular, pequenas oferendas respeitosas, escuta.\n\nO folclore local é o mapa espiritual mais honesto que existe.',
        practice:
            'Caminhe 15 minutos pelo bairro como bruxa: onde a energia muda? Que lugar te chama? Que histórias os antigos contam?',
        pageTitle: 'Os Espíritos do Meu Lugar',
        pagePurpose: 'Mapear o território espiritual onde vivo',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Lugares de poder perto de mim:',
          'Histórias e folclore da região:',
          'Minha primeira oferenda respeitosa (o quê, onde):',
          'O que senti:',
        ],
      ),
      TrailLesson(
        id: 'bt_02',
        recordKind: LessonRecordKind.note,
        title: 'Ancestrais: a linhagem viva',
        teaching:
            'Na tradição, os mortos não estão longe: ancestrais são aliados de primeira hora — os de sangue, os de afeto e os de ofício (as bruxas que vieram antes).\n\nUm altar simples: superfície limpa, copo d\'água, vela, objeto ou foto de quem partiu. Renove a água, converse. Sua página registra o começo do vínculo.',
        practice:
            'Acenda uma vela por seus ancestrais e diga: "Eu me lembro. Obrigada. Sigam comigo."',
        pageTitle: 'Meu Altar Ancestral',
        pagePurpose: 'Iniciar a devoção aos que vieram antes',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Copo de água', 'Vela', 'Objeto ou foto'],
        pagePrompts: [
          'Onde montei (o cantinho):',
          'Quem eu honro:',
          'Minha saudação a eles:',
          'Dia em que renovo a água:',
        ],
      ),
      TrailLesson(
        id: 'bt_03',
        title: 'As ferramentas do cotidiano',
        teaching:
            'A bruxa tradicional não espera loja esotérica: vassoura varre energia, tesoura corta laço, agulha costura destino. O poder está no uso consciente.\n\nConsagrar é simples: limpar, declarar o novo papel e usar SÓ para isso — a exclusividade é o que carrega.',
        practice:
            'Escolha UM objeto da casa para consagrar como primeira ferramenta. Sinta qual "aceita" o trabalho.',
        pageTitle: 'Minhas Ferramentas de Bruxa',
        pagePurpose: 'Consagrar objetos do cotidiano',
        pageCategory: SpellCategory.other,
        pageIngredients: ['O objeto', 'Sal ou fumaça'],
        pagePrompts: [
          'Objeto escolhido e sua função mágica:',
          'Como o limpei e consagrei:',
          'Palavras da consagração:',
          'Próximos objetos que pretendo consagrar:',
        ],
      ),
      TrailLesson(
        id: 'bt_04',
        title: 'A encruzilhada: onde os caminhos falam',
        teaching:
            'Em quase toda tradição, a encruzilhada é lugar de poder: onde os caminhos se cruzam, os mundos também. Ali se deixam trabalhos, se fazem pedidos de abertura e se honra quem guarda as passagens.\n\nRespeito é a regra: encruzilhada não é lixeira ritual. Oferendas biodegradáveis, discrição e gratidão.',
        practice:
            'Passe por uma encruzilhada com consciência: pare um instante (com segurança), sinta e siga com um pedido silencioso de caminhos abertos.',
        pageTitle: 'Meu Rito de Encruzilhada',
        pagePurpose: 'Trabalhar aberturas de caminho',
        pageCategory: SpellCategory.luck,
        pagePrompts: [
          'A encruzilhada que me chama (como é):',
          'Meu pedido de abertura de caminhos:',
          'Minha oferenda respeitosa (se houver):',
          'Sinais que percebi depois:',
        ],
      ),
      TrailLesson(
        id: 'bt_05',
        recordKind: LessonRecordKind.affirmation,
        title: 'Benzimento: a palavra que cura',
        teaching:
            'As benzedeiras são a bruxaria tradicional viva do Brasil: cura com palavra, ramo e fé. A estrutura é poesia funcional: nomeia o mal, invoca a força maior, manda para longe, sela. O ramo que murcha "levou" o que tirou.\n\nSua página honra essa linhagem — para uso pessoal, com respeito por quem guarda o ofício.',
        practice:
            'Pesquise (avós, vizinhas, internet) UM benzimento tradicional da sua região. Copie como relíquia.',
        pageTitle: 'Meu Primeiro Benzimento',
        pagePurpose: 'Honrar e praticar a palavra que cura',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Ramo verde (arruda, guiné...)'],
        pagePrompts: [
          'Benzimento tradicional que encontrei (e a fonte):',
          'Minha versão para autocuidado:',
          'O gesto que acompanha:',
          'Quando usei e o que senti:',
        ],
      ),
      TrailLesson(
        id: 'bt_06',
        title: 'A vassoura: varrer é rito',
        teaching:
            'A vassoura da bruxa não voa — varre mundos. Varrer da porta para dentro puxa a sorte; para fora, expulsa o denso. A vassoura ritual (que não toca lixo físico) guarda a soleira, deitada atrás da porta ou pendurada.\n\nQuintal varrido de manhã era proteção diária das antigas: o rito escondido no gesto comum.',
        practice:
            'Varra um cômodo hoje como rito: nomeando o que sai com o pó e o que entra com o espaço limpo.',
        pageTitle: 'Minha Vassoura de Bruxa',
        pagePurpose: 'Ritualizar a limpeza da casa',
        pageCategory: SpellCategory.cleansing,
        pagePrompts: [
          'Minha vassoura ritual (qual é, onde vive):',
          'O que digo ao varrer para fora:',
          'O que chamo ao varrer para dentro:',
          'Como a casa ficou depois do rito:',
        ],
      ),
      TrailLesson(
        id: 'bt_07',
        title: 'Garrafas e proteções da casa',
        teaching:
            'A witch bottle é proteção tradicional secular: um vidro com itens cortantes simbólicos (pregos, espinhos), protetores (sal, alecrim) e algo seu, selado e escondido na casa — o guardião silencioso que absorve o mal dirigido a você.\n\nVersão moderna e segura: vidro pequeno, sal, arruda, um fio de cabelo, cera de vela para selar.',
        practice:
            'Reúna os materiais da sua garrafa de proteção. Monte quando se sentir pronta, num momento tranquilo.',
        pageTitle: 'Minha Garrafa de Proteção',
        pagePurpose: 'Montar a guardiã silenciosa da casa',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Vidro pequeno', 'Sal', 'Ervas protetoras', 'Cera'],
        pagePrompts: [
          'O que coloquei dentro e o porquê de cada item:',
          'Minhas palavras ao selar:',
          'Onde ela está escondida:',
          'Quando pretendo renová-la:',
        ],
      ),
      TrailLesson(
        id: 'bt_08',
        recordKind: LessonRecordKind.dream,
        title: 'Sonhos e sinais: a escuta torta',
        teaching:
            'O caminho torto escuta o mundo: sonhos, bichos que cruzam, objetos que caem, nomes ouvidos três vezes. Não é paranoia — é atenção poética. O tradicional é registrar SEM interpretar na hora; padrões falam com o tempo.\n\nO Diário de Sonhos e os Temas Oníricos do app são seus aliados aqui.',
        practice:
            'Hoje, anote 3 "coincidências" ou sinais do dia, sem interpretar. Releia em uma semana.',
        pageTitle: 'Meu Caderno de Sinais',
        pagePurpose: 'Treinar a escuta dos presságios',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Os sinais que percebi esta semana:',
          'Padrões que já se repetem na minha vida:',
          'Meu combinado de registro (onde, quando):',
          '(Em 7 dias) O que os sinais formaram juntos:',
        ],
      ),
      TrailLesson(
        id: 'bt_09',
        recordKind: LessonRecordKind.desire,
        title: 'O caminho torto: pacto consigo',
        teaching:
            'A bruxaria tradicional não pede conversão — pede coerência. O "pacto" verdadeiro é consigo: praticar o que funciona, honrar o que sustenta, abandonar o que é enfeite. Sem dogma, com raiz.\n\nEsta página é o seu acordo de praticante: o que é inegociável no SEU caminho torto.',
        practice:
            'Releia suas páginas desta trilha. O que já virou prática real — e o que ficou só bonito no papel?',
        pageTitle: 'Meu Pacto de Praticante',
        pagePurpose: 'Firmar meu acordo com o caminho',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Minhas práticas inegociáveis (as que faço de verdade):',
          'O que abandono sem culpa:',
          'Com o que me comprometo neste ciclo:',
          'A frase que resume meu caminho torto:',
        ],
      ),
      TrailLesson(
        id: 'bt_10',
        recordKind: LessonRecordKind.note,
        title: 'Transmissão: guardar e passar adiante',
        teaching:
            'Todo saber tradicional sobrevive por transmissão: a avó que benze, a vizinha que ensina o chá. Você agora é elo dessa corrente — guardiã do que aprendeu e, um dia, ponte para alguém.\n\nA última página desta trilha é o seu testamento vivo: o que do seu caminho merece atravessar o tempo.',
        practice:
            'Pense em uma pessoa (real ou futura) a quem você confiaria seus saberes. O que ensinaria primeiro?',
        pageTitle: 'O Que Deixo à Corrente',
        pagePurpose: 'Registrar o que merece ser transmitido',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Os 3 saberes que eu passaria adiante:',
          'A quem (real ou simbólico):',
          'A história da minha linhagem até aqui:',
          'O conselho que eu daria a quem começa:',
        ],
      ),
    ],
  ),

  // ═════════════ MAGIA DO CAOS ═════════════
  LearningTrail(
    id: 'magia_do_caos',
    emoji: '🌀',
    title: 'Magia do Caos',
    subtitle: 'Nada é verdade, tudo é permitido criar',
    description:
        'A magia como tecnologia experimental: crença como ferramenta, sigilos, resultados mensuráveis e zero dogma. Você é o laboratório.',
    lessons: [
      TrailLesson(
        id: 'mc_01',
        recordKind: LessonRecordKind.note,
        title: 'Crença como ferramenta',
        teaching:
            'O axioma caóta: a crença não é a verdade — é o INSTRUMENTO. Se acreditar em X produz o resultado, o caóta veste a crença como um casaco, trabalha, e depois o pendura.\n\nNão é cinismo: é levar a crença tão a sério a ponto de usá-la deliberadamente. Bem-vinda ao laboratório.',
        practice:
            'Escolha uma crença útil e testável e viva 24h COMO SE fosse absolutamente verdadeira. Anote o que muda.',
        pageTitle: 'Experimento: Crença de 7 Dias',
        pagePurpose: 'Testar a crença como ferramenta',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'A crença adotada (afirmativa, testável):',
          'Critério de sucesso (como sei que funcionou):',
          'Diário dos 7 dias (uma linha por dia):',
          'Veredito do experimento:',
        ],
      ),
      TrailLesson(
        id: 'mc_02',
        recordKind: LessonRecordKind.sigil,
        title: 'Sigilos: o desejo criptografado',
        teaching:
            'O sigilo de Austin Osman Spare: escrever o desejo, eliminar letras repetidas, fundir as restantes num glifo — e ESQUECER, lançando o símbolo no inconsciente por um estado alterado (o gnosis: exaustão, dança, olhar fixo).\n\nO esquecimento não é detalhe: a mente ansiosa sabota; o inconsciente, livre, trabalha. A ferramenta de Sigilos do app faz o glifo por você.',
        practice:
            'Crie um sigilo na ferramenta do app (Ferramentas → Sigilos). Escolha seu método de gnosis antes de ativar.',
        pageTitle: 'Meu Primeiro Sigilo Lançado',
        pagePurpose: 'Registrar o método completo de sigilização',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Frase do desejo (escreva e risque depois!):',
          'Método de gnosis usado:',
          'Como destruí/esqueci o sigilo:',
          '(Em 1 mês) Resultados observados:',
        ],
      ),
      TrailLesson(
        id: 'mc_03',
        recordKind: LessonRecordKind.note,
        title: 'Gnosis: os portais do transe',
        teaching:
            'Gnosis é o estado onde a mente crítica cala e o comando passa: excitatório (dança, tambor, hiperventilação leve, clímax) ou inibitório (imobilidade, jejum curto, olhar fixo, silêncio absoluto).\n\nCada pessoa tem seus portais. Mapear os SEUS é infraestrutura mágica básica — com segurança e sem substâncias: o corpo já tem tudo.',
        practice:
            'Teste um método inibitório hoje: 5 minutos de olhar fixo numa vela, até o mundo "afinar".',
        pageTitle: 'Meu Mapa de Gnosis',
        pagePurpose: 'Mapear meus estados alterados seguros',
        pageCategory: SpellCategory.energy,
        pagePrompts: [
          'Métodos excitatórios que funcionam em mim:',
          'Métodos inibitórios que funcionam em mim:',
          'Meus limites de segurança:',
          'O portal que vou dominar primeiro:',
        ],
      ),
      TrailLesson(
        id: 'mc_04',
        recordKind: LessonRecordKind.note,
        title: 'O diário de resultados',
        teaching:
            'O que separa o caóta do místico de sofá é o REGISTRO: data, operação, técnica, estado, resultado. Sem diário, todo sucesso é lembrado e todo fracasso esquecido — e você não aprende nada.\n\nImpiedoso com a autoilusão, gentil com o processo: fracasso é dado, não vergonha.',
        practice:
            'Revise os experimentos das lições anteriores com honestidade brutal: o que funcionou, o que foi viés?',
        pageTitle: 'Meu Protocolo de Registro',
        pagePurpose: 'Sistematizar o diário de resultados',
        pageCategory: SpellCategory.study,
        pagePrompts: [
          'O que registro em toda operação (meu template):',
          'Quando reviso (semanal? lunar?):',
          'Minha escala de resultados:',
          'Primeira revisão: aprendizados:',
        ],
      ),
      TrailLesson(
        id: 'mc_05',
        title: 'Servidores: criaturas de propósito',
        teaching:
            'O servidor é um "programa" psíquico: uma entidade criada por você para UMA função (lembrar, proteger, achar). Recebe nome, forma, alimento simbólico e — crucial — data de desligamento.\n\nTrate como criação responsável: propósito claro, manutenção e aposentadoria digna quando cumprir o papel.',
        practice:
            'Esboce (desenho ou texto) um servidor simples para uma tarefa concreta desta semana.',
        pageTitle: 'Meu Primeiro Servidor',
        pagePurpose: 'Criar uma entidade de propósito único',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Nome, forma e função ÚNICA:',
          'Como o alimento (atenção, gesto, símbolo):',
          'Data e rito de desligamento:',
          'Resultados da primeira semana:',
        ],
      ),
      TrailLesson(
        id: 'mc_06',
        recordKind: LessonRecordKind.rune,
        title: 'Troca de paradigma',
        teaching:
            'O exercício-rei do caos: viver um período inteiro dentro de outro sistema de crenças — uma semana como animista, outra como cética radical, outra como devota. Não para zombar: para EXPERIMENTAR de dentro.\n\nO prêmio é a flexibilidade: quem já morou em várias casas de crença nunca mais confunde a mobília com o mundo.',
        practice:
            'Escolha um paradigma diferente do seu e viva 3 dias dentro dele, com registro diário.',
        pageTitle: 'Relatório de Troca de Paradigma',
        pagePurpose: 'Experimentar outro sistema de dentro',
        pageCategory: SpellCategory.study,
        pagePrompts: [
          'O paradigma visitado e minhas regras de imersão:',
          'Diário dos dias (o que mudou na percepção):',
          'O que trago de volta comigo:',
          'O que aprendi sobre o MEU paradigma:',
        ],
      ),
      TrailLesson(
        id: 'mc_07',
        recordKind: LessonRecordKind.desire,
        title: 'Magia do resultado: metas operacionais',
        teaching:
            'Caos é pragmatismo: magia a serviço de metas reais. A operação bem desenhada define alvo específico, prazo, técnica, e — a marca caóta — a AÇÃO MUNDANA casada: o feitiço de emprego acompanha currículos enviados.\n\nMagia sem ação é loteria; ação sem magia é metade do arsenal.',
        practice:
            'Escolha uma meta real de 30 dias. Desenhe a operação: técnica mágica + 3 ações mundanas.',
        pageTitle: 'Operação de 30 Dias',
        pagePurpose: 'Casar magia e ação para uma meta',
        pageCategory: SpellCategory.prosperity,
        pagePrompts: [
          'Meta específica e prazo:',
          'Técnica mágica escolhida:',
          'Minhas 3 ações mundanas casadas:',
          '(No prazo) Resultado e análise:',
        ],
      ),
      TrailLesson(
        id: 'mc_08',
        title: 'Desfazer: o banimento caóta',
        teaching:
            'Todo laboratório precisa de faxina: o banimento limpa resíduos entre operações e desfaz o que não serviu. Do clássico riso banidor (gargalhar da própria operação até dissolvê-la) ao pentagrama adaptado, o critério é funcionar PARA VOCÊ.\n\nBanir também é psicológico: fechar abas mentais é magia de manutenção.',
        practice:
            'Ao final do dia, faça um banimento simples: bata palmas 3 vezes e ria alto de tudo que ficou pendente. Sinta o corte.',
        pageTitle: 'Meu Banimento',
        pagePurpose: 'Criar minha faxina energética',
        pageCategory: SpellCategory.banishing,
        pageType: SpellType.banishment,
        pagePrompts: [
          'Meu rito de banimento (passos):',
          'Quando o uso (entre rituais? diário?):',
          'O riso banidor funcionou? Como foi:',
          'O que percebo depois de banir:',
        ],
      ),
      TrailLesson(
        id: 'mc_09',
        recordKind: LessonRecordKind.oracle,
        title: 'Sincronicidade: surfar o acaso',
        teaching:
            'Para o caóta, a sincronicidade é feedback do sistema: quando as "coincidências" se alinham à operação, algo está em curso. Não se força — se surfa: registrar, agradecer e ajustar a rota pelos sinais.\n\nCuidado com a apofenia (ver padrão em tudo): o diário de resultados é o antídoto.',
        practice:
            'Lance uma "pergunta ao acaso" hoje de manhã e colete os ecos até a noite, sem forçar.',
        pageTitle: 'Diário de Sincronicidades',
        pagePurpose: 'Registrar e ler os ecos do acaso',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Minha pergunta lançada:',
          'Os ecos coletados no dia:',
          'Leitura honesta (sinal ou apofenia?):',
          'Ajuste de rota decidido:',
        ],
      ),
      TrailLesson(
        id: 'mc_10',
        recordKind: LessonRecordKind.note,
        title: 'Construa seu próprio sistema',
        teaching:
            'O destino do caos é a autonomia: depois de testar crenças, técnicas e paradigmas, você monta o SEU sistema — pessoal, funcional, revisável. Misture o esbá com sigilos e o benzimento da avó: se passa no seu diário de resultados, é seu.\n\nLimites apenas éticos: nada de dano a pessoas ou animais, nada criminoso. O resto — o estranho, o simbólico, o inventado — é matéria-prima legítima.',
        practice:
            'Releia TODAS as suas páginas das trilhas. Circule o que já é "seu jeito".',
        pageTitle: 'Meu Sistema Mágico v1.0',
        pagePurpose: 'Consolidar meu caminho pessoal',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Minhas 3 técnicas centrais:',
          'Meus princípios inegociáveis:',
          'O que estou testando agora:',
          'Data da próxima revisão do sistema:',
        ],
      ),
    ],
  ),

  // ═════════════ TAROT ═════════════
  LearningTrail(
    id: 'tarot',
    emoji: '🎴',
    title: 'Tarot',
    subtitle: 'As 78 portas do autoconhecimento',
    description:
        'Do zero à leitura fluida: os arcanos, os naipes e a arte de tecer histórias com as cartas — treinando no Tutor de Tarot e registrando suas descobertas.',
    lessons: [
      TrailLesson(
        id: 'ta_01',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotLibrary,
        title: 'O baralho: mapa em 78 cartas',
        teaching:
            'O tarot é um mapa da experiência humana em 78 cartas: 22 Arcanos Maiores (as grandes forças e passagens da vida) e 56 Menores em quatro naipes — Paus/fogo (ação), Copas/água (emoção), Espadas/ar (mente) e Ouros/terra (matéria).\n\nAntes de decorar: manuseie. O tarot se aprende pelas mãos e pelos olhos.',
        practice:
            'Abra a ferramenta de Tarot do app e percorra as cartas. Escolha UMA que te atrai e outra que te incomoda.',
        pageTitle: 'Meu Encontro com o Baralho',
        pagePurpose: 'Registrar o primeiro contato com as 78 cartas',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'A carta que me ATRAIU e o que vi nela:',
          'A carta que me INCOMODOU e o que ela cutucou:',
          'Meu palpite: por que essas duas?',
          'O que espero aprender com o tarot:',
        ],
      ),
      TrailLesson(
        id: 'ta_02',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'A Jornada do Louco (0-VII)',
        teaching:
            'Os Arcanos Maiores contam uma história: o Louco (0) parte em jornada e encontra os primeiros mestres — Mago (vontade), Sacerdotisa (intuição), Imperatriz (criação), Imperador (estrutura), Hierofante (tradição), Enamorados (escolha) e Carro (vitória da vontade).\n\nÉ o primeiro terço: aprender as forças básicas do mundo.',
        practice:
            'No Tutor de Tarot (aba Aprender), faça uma sessão focando em reconhecer os maiores de 0 a VII.',
        pageTitle: 'Jornada do Louco: Primeiros Passos',
        pagePurpose: 'Fixar os arcanos 0 a VII',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Em que ponto da Jornada (0-VII) estou HOJE? Por quê:',
          'O arcano que mais fez sentido imediato:',
          'O que o quiz revelou que ainda confundo:',
          'Minha frase-resumo para cada carta (0-VII):',
        ],
      ),
      TrailLesson(
        id: 'ta_03',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'As provas da alma (VIII-XIV)',
        teaching:
            'O segundo terço da Jornada são as provas internas: Força (coragem gentil), Eremita (recolhimento), Roda (ciclos), Justiça (consequência), Enforcado (nova perspectiva), Morte (transformação) e Temperança (síntese).\n\nSão as cartas que assustam os iniciantes e sustentam os leitores: aqui mora a maturidade.',
        practice:
            'Sessão no Tutor focada nos arcanos VIII-XIV. Depois, contemple a carta da Morte por 2 minutos sem medo.',
        pageTitle: 'As Provas da Minha Alma',
        pagePurpose: 'Fixar os arcanos VIII a XIV',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'A "prova" (VIII-XIV) que estou vivendo agora:',
          'O que a Morte significa depois da contemplação:',
          'A carta desse grupo que virou aliada:',
          'Minha frase-resumo para cada uma:',
        ],
      ),
      TrailLesson(
        id: 'ta_04',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'A noite escura e o amanhecer (XV-XXI)',
        teaching:
            'O terço final atravessa a noite: Diabo (apegos), Torre (ruptura), Estrela (esperança), Lua (ilusões) — e amanhece: Sol (alegria), Julgamento (chamado) e Mundo (completude).\n\nA Jornada inteira agora é sua: do salto do Louco à dança do Mundo. E ela recomeça sempre, em espiral.',
        practice:
            'Sessão no Tutor com os arcanos XV-XXI. Depois conte a Jornada inteira em voz alta, carta a carta, como história.',
        pageTitle: 'Minha Jornada Completa',
        pagePurpose: 'Fixar os arcanos XV a XXI e o arco inteiro',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Minha "noite escura" mais recente e a Estrela que apareceu:',
          'A Jornada do Louco contada com minhas palavras (resumo):',
          'Meu arcano regente desta fase da vida:',
          'Precisão atual no quiz de maiores:',
        ],
      ),
      TrailLesson(
        id: 'ta_05',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'Paus e Copas: fogo e água',
        teaching:
            'Os naipes falam do cotidiano. PAUS é fogo: projetos, paixão, movimento — do Ás (faísca) ao Dez (sobrecarga). COPAS é água: vínculos, emoções, intuição — do transbordar do Ás à plenitude do Dez.\n\nDica de leitura: número + naipe = frase. Três (expansão) de Copas (afeto) = celebração entre amigas.',
        practice:
            'Sessão no Tutor com Paus e Copas. Monte 3 "frases" número+naipe por conta própria.',
        pageTitle: 'Fogo e Água nas Minhas Mãos',
        pagePurpose: 'Dominar a lógica de Paus e Copas',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Onde meu FOGO está aceso (qual carta de Paus descreve):',
          'Como anda minha ÁGUA (qual carta de Copas descreve):',
          'Minhas 3 frases número+naipe:',
          'Confusões que o quiz revelou:',
        ],
      ),
      TrailLesson(
        id: 'ta_06',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'Espadas e Ouros: ar e terra',
        teaching:
            'ESPADAS é ar: a mente — clareza que corta e ansiedade que fere. O naipe mais "difícil" do baralho é também o mais honesto. OUROS é terra: corpo, trabalho, dinheiro — a magia da matéria bem cuidada.\n\nComplete a lógica: agora você lê qualquer menor por número + elemento.',
        practice:
            'Sessão no Tutor com Espadas e Ouros. Identifique a carta de Espadas que mais parece com sua mente hoje.',
        pageTitle: 'Ar e Terra nas Minhas Mãos',
        pagePurpose: 'Dominar a lógica de Espadas e Ouros',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'A carta de Espadas da minha mente hoje (e por quê):',
          'A carta de Ouros da minha matéria hoje:',
          'O que os "dez" de cada naipe me ensinam sobre excesso:',
          'Precisão atual no quiz de menores:',
        ],
      ),
      TrailLesson(
        id: 'ta_07',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotTutor,
        title: 'A corte: as dezesseis pessoas',
        teaching:
            'Valete, Cavaleiro, Rainha e Rei de cada naipe: as cartas de corte são PESSOAS e POSTURAS — o Valete aprende, o Cavaleiro age, a Rainha domina por dentro, o Rei governa por fora.\n\nNa leitura, corte pode ser alguém na situação OU um papel que você está vestindo. Pergunte sempre: quem é — ou o que estou sendo?',
        practice:
            'Sessão no Tutor com as cortes. Identifique que carta de corte você está "vestindo" esta semana.',
        pageTitle: 'A Corte que Habito',
        pagePurpose: 'Reconhecer posturas nas cartas de corte',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'A corte que estou vestindo esta semana:',
          'Pessoas da minha vida em cartas de corte (3 exemplos):',
          'A corte que preciso invocar mais:',
          'A que preciso descansar:',
        ],
      ),
      TrailLesson(
        id: 'ta_08',
        recordKind: LessonRecordKind.tarot,
        title: 'Tirar cartas: a pergunta é metade',
        teaching:
            'A leitura começa antes do embaralhar: na pergunta. Perguntas abertas rendem ("o que preciso ver sobre X?"); sim/não empobrece; sobre terceiros, invade. Reformule até a pergunta apontar para VOCÊ.\n\nDepois: respire, embaralhe com a pergunta no corpo, e leia primeiro a IMAGEM — o significado decorado vem em socorro, não na frente.',
        practice:
            'Faça uma tiragem de 3 cartas no app com uma pergunta bem formulada. Leia a imagem antes do texto.',
        pageTitle: 'A Arte da Pergunta',
        pagePurpose: 'Estruturar minhas consultas',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Minha pergunta (reformulada até ficar minha):',
          'O que as IMAGENS me disseram antes do texto:',
          'O que o significado confirmou ou corrigiu:',
          'Minha resposta em uma frase:',
        ],
      ),
      TrailLesson(
        id: 'ta_09',
        recordKind: LessonRecordKind.tarot,
        title: 'Tecer a história: leitura combinada',
        teaching:
            'Cartas não falam sozinhas — conversam. A leitura madura tece: repetição de naipe (tema dominante), maiores em maioria (forças grandes em jogo), vizinhanças que se iluminam (a Torre ao lado da Estrela é ruptura com esperança).\n\nSeu papel é contar a história que as cartas formam JUNTAS — com começo, tensão e conselho.',
        practice:
            'Tiragem de 3 cartas: escreva a leitura como um mini-conto de 5 linhas antes de consultar qualquer significado.',
        pageTitle: 'Minha Primeira História Tecida',
        pagePurpose: 'Ler combinações, não cartas soltas',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'As 3 cartas e a tiragem:',
          'Meu mini-conto de 5 linhas:',
          'Padrões que notei (naipes, maiores, vizinhanças):',
          'O conselho final da mesa:',
        ],
      ),
      TrailLesson(
        id: 'ta_10',
        recordKind: LessonRecordKind.tarot,
        title: 'Seu tarot: ética e voz própria',
        teaching:
            'A leitora madura tem ética e voz: não prevê morte nem doença, não decide a vida de ninguém, devolve o poder a quem consulta. E tem estilo próprio — suas cartas-âncora, seus rituais de mesa, sua forma de contar.\n\nEsta última página é o seu manifesto de leitora: como o tarot vive em você daqui em diante.',
        practice:
            'Faça a Carta do Dia por 7 dias seguidos, registrando uma linha por dia. Sustente o hábito.',
        pageTitle: 'Manifesto da Leitora',
        pagePurpose: 'Firmar minha ética e voz no tarot',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Minha ética de leitura (o que faço e o que nunca faço):',
          'Minhas cartas-âncora (as que já leio de olhos fechados):',
          'Meu ritual de mesa (como abro e fecho leituras):',
          'Diário das 7 Cartas do Dia:',
        ],
      ),
    ],
  ),
];
