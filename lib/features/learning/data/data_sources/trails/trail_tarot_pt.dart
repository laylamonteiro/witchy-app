import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trilha 'tarot' — conteúdo em português (idioma-base).
/// Paridade com _en/_es verificada em test/trails_parity_test.dart.
const LearningTrail tarotTrailPt = LearningTrail(
    id: 'tarot',
    emoji: '🎴',
    title: 'Tarot',
    subtitle: 'As 78 portas do autoconhecimento',
    description:
        'Do zero à leitura fluida: os arcanos, os naipes e a arte de tecer histórias com as cartas — treinando no Tutor de Tarot e registrando suas descobertas',
    lessons: [
      TrailLesson(
        id: 'ta_01',
        recordKind: LessonRecordKind.tarot,
        tool: LessonTool.tarotLibrary,
        title: 'O baralho: mapa em 78 cartas',
        teaching:
            'O tarot é um mapa da experiência humana desenhado em 78 cartas. São 22 Arcanos Maiores, que retratam as grandes forças e passagens da vida, e 56 Arcanos Menores, que descrevem o cotidiano. Conhecer esse mapa importa porque ele oferece um espelho: cada carta nomeia algo que você já viveu ou ainda vai viver, e nomear é o primeiro passo para compreender\n\nOs Menores se dividem em quatro naipes, cada um ligado a um elemento. Paus é fogo e fala de ação, projetos e paixão. Copas é água e rege emoções, vínculos e intuição. Espadas é ar, o território da mente, das ideias e dos conflitos. Ouros é terra: corpo, trabalho e matéria. Assim, um Ás de Paus traz uma faísca criativa, enquanto um Dez de Copas mostra a plenitude afetiva de um lar em paz\n\nAntes de decorar qualquer significado, manuseie. O tarot se aprende pelas mãos e pelos olhos: observe cores, gestos e paisagens de cada lâmina. O erro mais comum da iniciante é tentar memorizar 78 verbetes de uma vez e se frustrar. Prefira visitas curtas e frequentes ao baralho, deixando que as imagens falem primeiro e o estudo venha depois, como apoio\n\nLeve consigo esta ideia: o baralho não é um código a decifrar, é um território a habitar. Você não precisa dominar as 78 cartas hoje — precisa apenas começar a caminhar por elas com curiosidade. Cada visita torna o mapa mais familiar, e é a intimidade, não a pressa, que forma uma boa leitora',
        practice:
            'Abra a Biblioteca de Cartas do app e percorra as 78 cartas sem pressa, olhando a imagem antes de ler o significado. Ao final, escolha uma carta que atraiu você e outra que incomodou, e releia o texto de cada uma com atenção. Depois registre na página desta lição o que viu e sentiu. O objetivo é criar seu primeiro vínculo com o baralho: perceber que ele já conversa com você antes de qualquer estudo formal',
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
            'Os Arcanos Maiores contam uma história contínua, conhecida como a Jornada do Louco. O Louco, carta zero, parte sem bagagem e atravessa as 21 lâminas seguintes como etapas de amadurecimento. Estudar os maiores em ordem importa porque transforma uma lista solta de cartas em um enredo vivo, que a sua memória abraça com muito mais facilidade\n\nNeste primeiro terço, o Louco encontra os mestres iniciais: o Mago ensina a vontade que realiza, a Sacerdotisa guarda a intuição e o mistério, a Imperatriz rege a criação fértil, o Imperador dá estrutura e limites, o Hierofante transmite a tradição, os Enamorados apresentam a escolha que define caminhos e o Carro celebra a vitória da vontade bem dirigida\n\nPara estudar, conte a história em voz alta: o Louco salta, aprende com o Mago, silencia com a Sacerdotisa, e assim por diante. Associe cada arcano a uma palavra sua, não a definições emprestadas. O tropeço comum é confundir os pares: lembre que o Mago age e o Imperador organiza, que a Sacerdotisa sabe em silêncio e a Imperatriz gera em abundância\n\nGuarde esta chave: de 0 a VII você aprende as forças básicas do mundo — vontade, intuição, criação, ordem, tradição, escolha e direção. Quando uma dessas cartas surgir numa leitura, pergunte qual dessas forças pede passagem na sua vida agora. A Jornada começou, e você já caminha dentro dela',
        practice:
            'Abra o Tutor de Tarot e faça uma sessão de quiz dedicada aos Arcanos Maiores de 0 a VII. Responda com calma, tentando lembrar a cena de cada carta antes de escolher a alternativa. Refaça as questões que errar até acertar com segurança. Ao terminar, anote na página desta lição quais arcanos ainda se confundem na sua cabeça. O objetivo é fixar o primeiro terço da Jornada do Louco pela repetição gentil, sem decoreba',
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
            'Depois de aprender as forças do mundo, o Louco enfrenta o segundo terço da Jornada: as provas internas. Dos arcanos VIII a XIV, a história deixa os mestres externos e mergulha na alma. Essas cartas importam porque tratam daquilo de que ninguém escapa — coragem, recolhimento, ciclos, consequências e a grande arte de se transformar\n\nA Força, arcano VIII no Rider-Waite, ensina a coragem gentil que doma sem violência. O Eremita se recolhe para encontrar a própria luz. A Roda da Fortuna gira os ciclos da vida, e a Justiça, arcano XI, cobra a consequência de cada escolha. O Enforcado inverte o olhar e ganha nova perspectiva, a Morte encerra o que já cumpriu seu tempo e a Temperança mistura os opostos em síntese serena\n\nSão as cartas que assustam as iniciantes e sustentam as leitoras experientes. O erro clássico é ler a Morte como tragédia: ela fala de fins necessários, quase nunca de morte física. Estude o grupo ligando cada carta a uma prova que você já viveu — a memória afetiva fixa muito mais do que a repetição seca. E não apresse o Eremita: recolher também é avançar\n\nLeve consigo: maturidade no tarot é perder o medo dessas sete lâminas. Quando uma delas aparecer, em vez de temer, pergunte qual prova está madura na sua vida e o que ela veio ensinar. Aqui mora a diferença entre quem apenas consulta as cartas e quem de fato dialoga com elas',
        practice:
            'No Tutor de Tarot, faça uma sessão de quiz focada nos arcanos VIII a XIV, com atenção especial aos que se parecem, como Roda e Justiça. Depois do quiz, abra a carta da Morte e contemple a imagem por dois minutos, respirando fundo, sem medo. Por fim, registre suas impressões na página desta lição. O objetivo é fixar as provas da alma e transformar a carta mais temida do baralho em uma aliada sua',
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
            'O terço final da Jornada atravessa a noite mais escura antes do amanhecer. Dos arcanos XV a XXI, o Louco encara seus apegos e ilusões para renascer inteiro. Conhecer esse trecho importa porque ele descreve as crises que transformam — e mostra que nenhuma noite, por mais funda que pareça, é o fim da história que você está vivendo\n\nO Diabo revela os apegos que prendem, a Torre derruba estruturas falsas de um só golpe, a Estrela devolve a esperança nua e serena, e a Lua mergulha nas ilusões e medos do inconsciente. Então amanhece: o Sol traz alegria clara, o Julgamento soa como um chamado de renascimento e o Mundo fecha o ciclo em completude — a dança de quem integrou a Jornada inteira\n\nPara fixar, conte o arco completo como história, do salto do Louco à dança do Mundo: narrar em voz alta grava mais do que reler. Cuidado com o erro de tratar Torre e Diabo como maldições — em leituras reais, eles costumam apontar libertações urgentes. E lembre: a Jornada não é linha reta, é espiral; você a percorre muitas vezes ao longo da vida\n\nGuarde esta imagem: toda Torre que cai abre vista para uma Estrela. Com os 22 maiores completos, você já carrega o esqueleto do tarot. Diante de qualquer mesa, procure primeiro em que ponto da espiral a consulente está — o resto da leitura se organiza a partir daí',
        practice:
            'Abra o Tutor de Tarot e faça uma sessão de quiz com os arcanos XV a XXI; depois, uma rodada geral com os 22 Arcanos Maiores. Em seguida, afaste o app por um instante e conte a Jornada inteira em voz alta, carta a carta, como quem narra um conto. Volte e registre na página o seu resumo e a sua precisão no quiz. O objetivo é costurar o arco completo dos maiores na memória, de uma vez por todas',
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
            'Se os maiores narram as grandes passagens, os naipes falam do cotidiano — e é neles que a maior parte das leituras acontece. Paus e Copas formam o par quente do baralho: fogo e água, impulso e sentimento. Dominar essa dupla importa porque ela descreve quase tudo o que move os seus dias: desejo, projetos, vínculos e emoções\n\nPaus é fogo: projetos, paixão, movimento. O Ás acende a faísca criativa, o Três já contempla o horizonte dos planos e o Dez mostra a sobrecarga de quem abraçou demais. Copas é água: vínculos, emoções, intuição. O Ás transborda um sentimento novo, o Três celebra entre amigas e o Dez coroa a plenitude afetiva. Cada número conta um estágio da energia do naipe\n\nA dica de ouro: número mais naipe forma uma frase. Pense no número como verbo e no naipe como assunto — Três é expansão, Copas é afeto, logo o Três de Copas é celebração compartilhada. O erro comum é decorar cada carta isolada; monte a frase e você lê qualquer menor. Treine com o seu dia: aquela reunião agitada foi qual carta de Paus?\n\nLeve consigo: fogo sem água queima, água sem fogo estagna. Paus pergunta onde está o seu impulso; Copas, como anda o seu coração. Quando esses dois naipes dominarem uma mesa, a vida está falando de paixão e de vínculo — e você já sabe conjugar os dois',
        practice:
            'Abra o Tutor de Tarot e faça uma sessão de quiz dedicada aos naipes de Paus e Copas. Antes de responder cada questão, monte mentalmente a frase número mais naipe e só então confira a alternativa. Depois do quiz, crie por conta própria três frases desse tipo e registre na página, junto com as confusões que aparecerem. O objetivo é internalizar a lógica que permite ler qualquer carta menor sem decoreba',
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
            'Espadas e Ouros completam o quarteto dos naipes: ar e terra, mente e matéria. É o par que equilibra o baralho — depois do desejo e da emoção, chegam o pensamento e o chão firme. Conhecer os dois importa porque toda leitura madura precisa distinguir o que é ideia, o que é fato concreto e o que é medo vestido de verdade\n\nEspadas é ar: a mente, com sua clareza que corta e sua ansiedade que fere. É o naipe de fama mais difícil e também o mais honesto — o Ás traz a verdade nua, o Três nomeia a dor da decepção, o Nove retrata a insônia das preocupações. Ouros é terra: corpo, trabalho, dinheiro e a magia da matéria bem cuidada — do Ás, semente concreta, ao Dez, patrimônio e legado\n\nContinue usando a fórmula número mais elemento: agora você lê qualquer menor numerado do baralho. O erro comum aqui é dramatizar Espadas — o naipe descreve pensamentos, não sentenças. Diante de uma carta dura, pergunte que pensamento é esse, e não que desgraça vem aí. E honre Ouros: cuidar do concreto também é prática espiritual\n\nGuarde esta síntese: Espadas mostra o que a sua mente conta a você; Ouros mostra o que as suas mãos constroem. Entre o pensar e o concretizar caminha a vida inteira. Com os quatro naipes na bagagem, o cotidiano inteiro virou vocabulário de leitura para você',
        practice:
            'No Tutor de Tarot, faça uma sessão de quiz com os naipes de Espadas e Ouros, aplicando a fórmula número mais elemento antes de cada resposta. Ao terminar, percorra mentalmente o naipe de Espadas e identifique qual carta mais se parece com a sua mente hoje; faça o mesmo com Ouros e a sua vida material. Registre tudo na página. O objetivo é completar o domínio dos quatro naipes e trazer as cartas para o seu presente',
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
            'Dezesseis cartas do baralho não descrevem situações, e sim gente: são as cartas de corte — Valete, Cavaleiro, Rainha e Rei de cada naipe. Elas importam porque toda leitura envolve pessoas e posturas, e a corte é o espelho onde consulente, leitora e os personagens da vida aparecem com rosto, idade interna e temperamento\n\nCada posto indica uma maturidade da energia do naipe: o Valete aprende e experimenta, o Cavaleiro age e parte em missão, a Rainha domina a energia por dentro, o Rei a governa por fora, no mundo. Cruze o posto com o elemento e o retrato surge: a Rainha de Copas acolhe com profundidade emocional, o Cavaleiro de Espadas avança com ideias afiadas e muita pressa\n\nNa mesa, uma corte pode ser alguém presente na situação ou um papel que você mesma está vestindo — pergunte sempre: quem é, ou o que estou sendo? O erro comum é fixar cada corte numa pessoa física de aparência parecida; prefira ler temperamentos. Treine associando pessoas queridas às dezesseis cartas: a memória afetiva firma o aprendizado\n\nLeve consigo: você não é uma única carta de corte — é o baralho inteiro, vestindo postos conforme a semana pede. Diante de uma corte, faça sempre a pergunta dupla: quem está agindo assim, e quando sou eu que ajo assim. Com ela, essas dezesseis cartas deixam de confundir e passam a revelar',
        practice:
            'Abra o Tutor de Tarot e faça uma sessão de quiz dedicada às dezesseis cartas de corte, atenta ao par posto e naipe de cada uma. Depois, reflita: qual corte você está vestindo esta semana — um Valete curioso, uma Rainha de Ouros provedora? Escolha também cortes para três pessoas da sua vida e registre tudo na página. O objetivo é reconhecer posturas e temperamentos, dentro e fora de você',
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
            'Uma boa leitura começa antes do embaralhar: na pergunta. A pergunta é metade da resposta, porque define a lente pela qual as cartas serão lidas. Perguntar bem importa tanto quanto conhecer significados — uma mesa inteira de cartas certeiras não salva uma pergunta torta, vaga ou que entrega ao baralho o seu poder de decidir\n\nPerguntas abertas rendem: o que preciso enxergar sobre esta situação, que energia me ajuda agora. Perguntas de sim ou não empobrecem a conversa, e perguntas sobre a vida de terceiros invadem território alheio. Reformule até a pergunta apontar para você — em vez de querer saber se alguém volta, pergunte o que você precisa compreender sobre esse vínculo\n\nNa hora de tirar: respire fundo, embaralhe com a pergunta viva no corpo e vire as cartas com calma. Leia primeiro a imagem — o que a cena mostra, o que você sente ao olhar — e só depois consulte o significado, que vem em socorro, nunca na frente. O erro comum é pular direto para o texto e ignorar o que os seus olhos já sabiam\n\nGuarde esta medida: pergunta aberta, olhos primeiro, significado depois. Quem pergunta bem já recebeu meia resposta antes de virar a primeira carta. O tarot não decide por você — ele ilumina o terreno para que você decida melhor, e é aí que mora a sua força',
        practice:
            'Vá à página de Tarot do app e escolha a tiragem de Três Cartas. Antes de tirar, escreva sua pergunta e reformule até que fique aberta e apontada para você. Embaralhe respirando fundo, vire as cartas e leia primeiro as imagens, anotando suas impressões; só então abra os significados e compare. Registre o processo na página da lição. O objetivo é firmar o ritual completo: pergunta bem feita, olhar próprio e estudo como apoio',
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
            'Cartas não falam sozinhas — conversam. A leitura madura não soma verbetes isolados: tece uma história em que cada carta ilumina as vizinhas. Aprender a combinar importa porque é isso que separa quem consulta significados de quem realmente lê. A mesa é um texto, e as cartas são frases que só ganham sentido pleno quando lidas juntas\n\nTrês padrões guiam o tecido: a repetição de naipe revela o tema dominante — muitas Copas, e o assunto é afeto; a maioria de Arcanos Maiores indica forças grandes em jogo, acima do cotidiano; e as vizinhanças se iluminam — a Torre ao lado da Estrela é ruptura com esperança, o Dez de Paus perto do Eremita pede pausa e recolhimento antes de seguir\n\nNa prática, antes de consultar qualquer significado, olhe a mesa inteira e conte a história: onde ela começa, onde aperta, onde aponta saída. Escrever a leitura como um pequeno conto educa o olhar. O erro comum é ler carta por carta como fichas soltas, cada uma com seu parágrafo, sem nunca conectar — e a história se perde dentro do dicionário\n\nLeve consigo: o seu papel de leitora é narrar o que as cartas formam juntas, com começo, tensão e conselho. Confie no fio que você enxerga entre as lâminas — ele é a sua leitura. O dicionário, qualquer pessoa abre; a história, só você é capaz de contar',
        practice:
            'Na página de Tarot, faça uma tiragem de Três Cartas sobre um tema do seu momento. Antes de consultar qualquer significado, observe a mesa inteira e escreva a leitura como um mini conto de cinco linhas, com começo, tensão e conselho. Depois confira os significados, note repetições de naipe, presença de maiores e vizinhanças, e registre tudo. O objetivo é treinar a leitura combinada: tecer histórias em vez de somar cartas soltas',
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
            'Chegando ao fim da trilha, o que falta não é técnica: é identidade. A leitora madura se reconhece por duas marcas — ética firme e voz própria. Isso importa porque o tarot toca pessoas em momentos sensíveis, e a diferença entre ajudar e assombrar está inteira na postura de quem segura as cartas diante de outra alma\n\nA ética se resume em devolver o poder: não prever morte nem doença, não decidir a vida de ninguém, não alimentar dependência de consultas. A voz própria se constrói com o tempo: suas cartas âncora, aquelas que você lê de olhos fechados; seus rituais de mesa, o jeito de abrir e fechar cada leitura; sua forma única de contar o que a mesa mostra\n\nNo dia a dia, nada firma voz e vínculo como a constância: uma carta por dia vale mais do que uma tiragem enorme por mês. Tire a Carta do Dia, escreva uma linha, siga a vida — e à noite repare em como a carta apareceu. O erro comum é abandonar a prática quando a rotina aperta; encolha o ritual se for preciso, mas não o abandone\n\nGuarde como manifesto: o tarot não prevê um destino fechado — ilumina caminhos para quem escolhe. Você agora conhece o mapa, os naipes, a corte e a Jornada inteira. Daqui em diante, o baralho fala com a sua voz. Leia com coragem, com ética e com a ternura de quem sabe que toda carta é um espelho',
        practice:
            'Na página de Tarot, tire a Carta do Dia por sete dias seguidos. A cada manhã, observe a imagem, respire e escreva uma única linha sobre o que a carta desperta; à noite, se quiser, acrescente como ela apareceu no seu dia. Ao fim da semana, releia as sete linhas e escreva seu manifesto de leitora na página da lição. O objetivo é firmar o hábito que sustenta toda leitora: presença diária, breve e constante, com as cartas',
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
  );
