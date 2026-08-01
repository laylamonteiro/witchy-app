import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trilha 'magia_negra' — conteúdo em português (idioma-base).
/// Paridade com _en/_es verificada em test/trails_parity_test.dart.
const LearningTrail magiaNegraTrailPt = LearningTrail(
    id: 'magia_negra',
    emoji: '🌑',
    title: 'Magia Negra',
    subtitle: 'Sombra, corte e poder consciente',
    description:
        'Desfazer os mitos e atravessar o escuro com responsabilidade: trabalho de sombra, banimentos, cortes e proteções — o poder que nasce quando você olha para o que a maioria evita',
    lessons: [
      TrailLesson(
        id: 'mn_01',
        recordKind: LessonRecordKind.note,
        title: 'O que a magia negra é (e o que nunca foi)',
        teaching:
            'Magia negra, nesta trilha, é o nome que damos ao trabalho consciente com a sombra: banir o que adoece, defender o próprio campo, cortar o que drena e assumir poder com ética. Não é receita para prejudicar ninguém — é o lado da bruxaria que olha o escuro de frente. Entender o que esse termo é, e o que nunca foi, é o primeiro passo para praticar sem medo e sem irresponsabilidade\n\nO rótulo de magia negra carrega uma história pesada: foi usado para demonizar religiões afro-diaspóricas, benzedeiras e saberes populares, associando o escuro ao mal por puro preconceito e racismo. O folclore e o cinema exageraram o resto, criando a caricatura da maldição e do pacto sombrio. A prática moderna desfaz essa confusão: escuro não é sinônimo de maldade, assim como a noite não é inimiga do dia\n\nNo começo, é comum chegar a este tema com medo ou com fascínio demais — os dois desequilibram. O erro clássico é buscar feitiços contra alguém que machucou você: além de eticamente errado, isso prende sua energia justamente a quem você quer distância. A dica é firmar limites antes de qualquer prática: escreva o que você nunca fará, e por quê. Ética definida com clareza é a maior proteção que existe\n\nLeve consigo: o escuro é parte natural do caminho, e quem o percorre com responsabilidade encontra ali força, não perigo. Você não precisa temer esta trilha nem provar coragem a ninguém. Seu pacto é com você mesma — e é ele que transforma poder em maturidade. A bruxa que conhece seus limites pode ir muito mais fundo do que aquela que finge não os ter',
        practice:
            'Você vai escrever seu Pacto de Responsabilidade. Primeiro, reflita com honestidade sobre o que te trouxe até esta trilha. Depois, escreva na sua página os limites que assume: o que você nunca fará com a própria magia e os valores que guiarão cada prática. Por fim, leia o pacto em voz alta, como quem assina um compromisso consigo. O objetivo é firmar a base ética que protegerá você em todo o caminho da sombra',
        pageTitle: 'Meu Pacto de Responsabilidade',
        pagePurpose: 'Definir meus limites antes de tocar a sombra',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'O que me atraiu para este caminho:',
          'Meus limites: o que eu nunca farei:',
          'O que quero transformar em mim:',
          'Meu compromisso, com minhas palavras:',
        ],
      ),
      TrailLesson(
        id: 'mn_02',
        recordKind: LessonRecordKind.note,
        title: 'A sombra: o que você esconde de si',
        teaching:
            'A sombra é tudo aquilo que você escondeu de si para ser aceita: raiva engolida, desejos negados, talentos que pareciam perigosos demais. Na chave mística, ela é o porão da alma — e todo porão guarda tanto entulho quanto tesouro. Trabalhar a sombra importa porque o que você não olha não desaparece: apenas passa a agir no escuro, sem a sua permissão\n\nA psicologia de Jung deu nome ao que as bruxas sempre souberam: o que reprimimos não morre, projeta-se. É por isso que certos defeitos alheios irritam tanto — costumam ser espelhos de algo nosso. Nos contos antigos, o monstro da floresta quase sempre guarda um tesouro ou vira aliado quando é encarado de frente: o folclore já ensinava que o escuro esconde poder, e não apenas perigo\n\nNa prática, o trabalho de sombra começa pequeno: notar as irritações desproporcionais, os ciúmes que envergonham, os elogios que você rejeita. O erro comum é transformar isso em autopunição — sombra não se espanca, se escuta. Outro é querer iluminar tudo de uma vez. Vá aos poucos, com curiosidade e sem julgamento, como quem explora uma casa antiga com uma vela na mão\n\nLeve consigo: sua sombra não é sua inimiga — é a parte de você que esperou anos por atenção. Cada pedaço escutado devolve energia que estava presa em esconder. A bruxa que conhece a própria sombra não fica mais sombria: fica mais inteira, mais honesta e muito mais difícil de manipular. O mapa começa hoje, e quem segura a lanterna é você',
        practice:
            'Você vai desenhar o primeiro Mapa da sua Sombra. Primeiro, liste três comportamentos alheios que te irritam de forma desproporcional. Depois, pergunte a si mesma, com honestidade e sem julgamento, o que cada um pode espelhar em você — memórias e vergonhas que surgirem são pistas valiosas. Por fim, registre na página os aspectos de sombra que reconheceu. O objetivo é iniciar o encontro consciente com o que você esconde de si',
        pageTitle: 'Mapa da Minha Sombra',
        pagePurpose: 'Reconhecer projeções e partes negadas de mim',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'O que mais me irrita nos outros (e pode ser meu):',
          'A parte de mim que escondo do mundo:',
          'Quando ela aparece sem eu querer:',
          'O que ela está tentando me proteger de sentir:',
        ],
      ),
      TrailLesson(
        id: 'mn_03',
        recordKind: LessonRecordKind.spell,
        title: 'Banimento: cortar o que adoece',
        teaching:
            'Banir é o gesto mágico de dizer basta: retirar do seu campo um hábito, uma energia ou uma situação que adoece. É a faxina profunda da bruxaria — antes de atrair qualquer coisa boa, é preciso abrir espaço. Nesta trilha, o banimento nunca mira pessoas para causar dano: o alvo é sempre o padrão, o vício, o peso. Você bane o que te prende, não quem te cerca\n\nO banimento é das práticas mais antigas do mundo: sal nos cantos da casa, vassoura varrendo para fora, fumaça de ervas amargas, água levando embora o que não serve. A lógica tradicional segue a lua minguante: assim como ela diminui no céu, diminui o que foi banido. Escrever o que se quer remover e destruir o papel com segurança é a forma clássica — o fogo e a água sempre foram os grandes dissolventes da magia popular\n\nPara a iniciante, a chave é escolher um alvo concreto e justo: um hábito que drena, uma energia pesada num cômodo, um ciclo que se repete. O erro comum é banir vagamente — tudo de ruim da minha vida — e não sentir efeito, ou disfarçar de banimento um ataque a alguém. Outro é banir e continuar alimentando o padrão no dia seguinte: o feitiço abre a porta, mas quem atravessa é você\n\nLeve consigo: banir é um ato de amor-próprio com cara de coragem. Cada coisa que você remove conscientemente devolve espaço para o que merece crescer. Este é seu primeiro feitiço da trilha — simples, honesto e poderoso na medida do seu compromisso. O poder não está no papel queimado: está na decisão que você sustenta depois dele',
        practice:
            'Você vai realizar seu primeiro banimento. Primeiro, escolha um alvo justo: um hábito, uma energia ou uma situação — nunca uma pessoa. Depois, escreva-o num papel, acenda uma vela em local seguro e queime o papel declarando que aquilo não tem mais lugar na sua vida; descarte as cinzas fora de casa. Por fim, registre tudo na página do grimório. O objetivo é abrir espaço, retirando conscientemente o que adoece',
        pageTitle: 'Meu Primeiro Banimento',
        pagePurpose: 'Banir um hábito, energia ou situação que me adoece',
        pageCategory: SpellCategory.banishing,
        pageType: SpellType.banishment,
        pageIngredients: ['Vela escura ou papel e caneta', 'Um símbolo do que será banido'],
        pagePrompts: [
          'O que estou banindo (hábito, energia ou situação):',
          'Por que ele não tem mais lugar na minha vida:',
          'Como fiz o rito e o que senti:',
          'O que ocupa o espaço que ficou livre:',
        ],
      ),
      TrailLesson(
        id: 'mn_04',
        recordKind: LessonRecordKind.spell,
        title: 'Escudos e espelhos: defesa mágica',
        teaching:
            'Defesa mágica é higiene, não paranoia: assim como você tranca a porta sem viver com medo, o escudo energético protege seu campo sem transformar o mundo em ameaça. Escudos filtram o que vem de fora; espelhos devolvem à origem o que foi enviado, sem que você precise revidar. Saber se proteger é o que permite trabalhar a sombra com tranquilidade e seguir aberta à vida\n\nO folclore está cheio de defesas: ferro na porta, olho grego contra inveja, arruda na entrada, espelhinhos que confundem e devolvem o mau-olhado. A ideia do espelho é elegante: você não ataca ninguém, apenas deixa de absorver — o que vem, volta para quem mandou, e a responsabilidade é de quem enviou. A visualização moderna herda isso: imaginar-se dentro de uma esfera espelhada é técnica simples e antiga ao mesmo tempo\n\nNo cotidiano, o escudo se constrói pela manhã em um minuto: respire, visualize a esfera de luz espelhada ao redor do corpo e firme a intenção. O erro comum é blindar-se tanto que nada entra — nem o bom; escudo é filtro, não muralha de isolamento. Outro é lembrar da proteção só na crise. Constância vale mais que intensidade: um amuleto simples renovado com carinho protege mais que rituais grandiosos esquecidos\n\nLeve consigo: você tem o direito de não absorver o que não é seu. Proteger-se não é agressão nem desconfiança do mundo — é respeito pelo próprio campo. Com o escudo espelhado, você caminha mais leve, sabendo que o que não te pertence encontra sozinho o caminho de volta. Segurança energética é a base silenciosa de toda a magia que vem depois',
        practice:
            'Você vai erguer seu Escudo Espelhado. Primeiro, sente-se em silêncio, respire fundo três vezes e sinta os pés firmes no chão. Depois, visualize uma esfera de luz ao seu redor cuja face externa é um espelho: o que é bom atravessa, o que pesa é devolvido à origem; sustente a imagem por alguns minutos e, se quiser, consagre um objeto pequeno como amuleto. Por fim, registre a experiência na página. O objetivo é criar uma proteção diária que filtra sem isolar',
        pageTitle: 'Meu Escudo Espelhado',
        pagePurpose: 'Erguer minha proteção antes de qualquer trabalho sombrio',
        pageCategory: SpellCategory.protection,
        pageType: SpellType.banishment,
        pageIngredients: ['Espelho pequeno ou objeto reflexivo', 'Sal grosso'],
        pagePrompts: [
          'Do que estou me protegendo:',
          'Como visualizei meu escudo (forma, material, brilho):',
          'A frase que firma minha proteção:',
          'Quando vou renovar este escudo:',
        ],
      ),
      TrailLesson(
        id: 'mn_05',
        recordKind: LessonRecordKind.spell,
        title: 'Corte de laços',
        teaching:
            'Entre você e cada pessoa da sua vida existem laços invisíveis — cordas de afeto, de história, de energia. Alguns nutrem; outros drenam, prendem a relações encerradas ou tornam o convívio um cabo de guerra. O corte de laços é o ritual que devolve a cada um a própria energia. Cortar não é atacar nem apagar alguém: é encerrar um contrato energético que já venceu\n\nTradições do mundo inteiro conhecem essas cordas: fitas que se atam e desatam em ritos populares, nós que se desfazem para liberar caminhos, tesouras que cortam o ar carregado. O rito moderno usa símbolos simples: um cordão representando o laço, duas velas representando os dois lados, uma tesoura consagrada. Ao cortar o cordão, você declara o fim do vínculo que drena — e deseja, de coração, que cada parte siga em paz com o que é seu\n\nNa prática, comece por um laço claramente vencido: uma relação encerrada que ainda ocupa seus pensamentos, um convívio que só suga. O erro comum é cortar com raiva, transformando o rito em vingança silenciosa — corte se faz com firmeza serena, não com ódio. Outro é esperar que alguém suma da sua vida no dia seguinte: o que se corta é a corda energética; as escolhas práticas de distância continuam sendo suas\n\nLeve consigo: soltar também é magia — talvez a mais difícil e a mais libertadora. Cada laço cortado com consciência devolve energia que estava presa no passado. Você não precisa carregar cordas que já não levam a lugar nenhum. Corte com respeito, agradeça o que foi aprendido e caminhe mais leve: o espaço que se abre é seu, e o da outra pessoa também',
        practice:
            'Você vai realizar o Ritual de Corte de Laços. Primeiro, escolha um vínculo que drena e pegue um cordão ou barbante para representá-lo, segurando uma ponta em cada mão enquanto nomeia em silêncio o que aquele laço se tornou. Depois, corte o cordão com uma tesoura, desejando paz para os dois lados, e descarte as partes separadas. Por fim, registre o rito e o que sentiu na página. O objetivo é liberar energia presa em relações que já cumpriram seu papel',
        pageTitle: 'Ritual de Corte de Laços',
        pagePurpose: 'Cortar cordas energéticas que me drenam',
        pageCategory: SpellCategory.banishing,
        pageType: SpellType.banishment,
        pageIngredients: ['Cordão ou barbante', 'Tesoura', 'Vela'],
        pagePrompts: [
          'O laço que precisei cortar (sem culpar, só nomear):',
          'O que esse vínculo drenava de mim:',
          'Como foi o momento do corte:',
          'O que desejo de bom para os dois lados, separados:',
        ],
      ),
      TrailLesson(
        id: 'mn_06',
        recordKind: LessonRecordKind.note,
        title: 'A lua negra e o escuro fértil',
        teaching:
            'A lua negra é a fase em que o céu parece vazio: a lua está lá, mas não reflete luz nenhuma. Nas tradições da bruxaria, esse é o tempo do silêncio, do mergulho e do descanso — o escuro fértil onde tudo se prepara antes de nascer. Honrar essa fase importa porque poder não é só ação: a pausa consciente é tão mágica quanto qualquer feitiço bem feito\n\nOs povos antigos plantavam conforme a lua e sabiam que a semente germina no escuro da terra, não na luz. O folclore associou a lua escura aos mistérios profundos, à deusa anciã, ao tempo em que não se começa nada — se escuta. A prática moderna traduz isso em retiro pessoal: menos estímulo, mais silêncio, adivinhação, escrita e sono reparador. É o momento em que a sombra fala mais claro, porque o barulho diminui\n\nNa prática, marque a lua negra no seu calendário e reserve para ela uma noite mais quieta: menos telas, banho demorado, escrita solta, dormir cedo. O erro comum é tratar o descanso como preguiça e se forçar a produzir — nesta fase, isso só gera exaustão. Outro é esperar grandes revelações: às vezes a lua negra entrega apenas um sono profundo, e isso já é o presente da fase\n\nLeve consigo: você também tem fases, e nenhuma delas é errada. O escuro fértil ensina que recolher-se é preparar a próxima florada. A bruxa que respeita o próprio inverno não se apaga — acumula profundidade. Deixe a lua negra ser seu lembrete mensal de que o vazio não é falta: é o útero silencioso onde a sua próxima versão está sendo gerada',
        practice:
            'Você vai começar seu Diário da Lua Negra. Primeiro, descubra quando é a próxima lua negra e reserve essa noite — ou faça hoje um ensaio numa noite tranquila. Depois, diminua os estímulos: luz baixa, silêncio, menos telas, e escreva livremente o que pede descanso na sua vida e o que está germinando no escuro. Por fim, registre as percepções na página. O objetivo é transformar a fase escura num rito mensal de escuta e descanso',
        pageTitle: 'Diário da Lua Negra',
        pagePurpose: 'Trabalhar o silêncio e o descanso como poder',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'O que o escuro me ensina quando eu paro de fugir dele:',
          'O que estou deixando repousar nesta lua:',
          'O que percebi no silêncio:',
          'A semente que vou plantar quando a luz voltar:',
        ],
      ),
      TrailLesson(
        id: 'mn_07',
        recordKind: LessonRecordKind.dream,
        title: 'Sonhos sombrios: recados da sombra',
        teaching:
            'Pesadelos assustam, mas raramente vêm para atormentar: na leitura mística, são cartas urgentes da sombra. Quando algo importante não consegue chegar até você pela via comum, o sonho aumenta o volume — e vira monstro, queda, perseguição. Aprender a escutar sonhos sombrios importa porque eles apontam exatamente para o que o seu trabalho de sombra precisa olhar agora\n\nCulturas antigas tratavam sonhos como oráculos: templos de incubação na Grécia, benzeduras contra pesadelo, guardiões do sono no folclore de vários povos. A chave simbólica moderna lê o pesadelo pelo avesso: quem te persegue no sonho costuma ser algo seu pedindo encontro; a casa em ruínas fala de estruturas internas; a queda, de controle que precisa ser solto. O monstro, quase sempre, quer entregar um recado — não te devorar\n\nNa prática, o segredo é registrar logo ao acordar, antes que o sonho evapore: anote cenas, emoções e símbolos no Diário de Sonhos do app e consulte os Significados dos Sonhos para abrir camadas. O erro comum é interpretar ao pé da letra e concluir que sonho ruim é presságio — na maioria das vezes, é retrato interno, não profecia. Outro é fugir do tema: pesadelo ignorado tende a voltar mais alto\n\nLeve consigo: a noite é sua aliada, mesmo quando fala em imagens assustadoras. Cada pesadelo escutado com coragem é uma conversa a menos que a sombra precisa gritar. Você não está à mercê dos seus sonhos — está em diálogo com eles. Durma como quem confia na própria profundidade: o escuro dos sonhos também trabalha a seu favor',
        practice:
            'Você vai escutar um sonho sombrio. Primeiro, registre no Diário de Sonhos do app um pesadelo recente — ou o próximo que vier — com cenas, símbolos e emoções. Depois, explore os Significados dos Sonhos para abrir as camadas simbólicas e pergunte a si mesma que parte sua pode estar falando por meio daquelas imagens. Por fim, escreva na página a mensagem que conseguiu escutar. O objetivo é transformar o pesadelo de ameaça em mensageiro da sombra',
        pageTitle: 'Um Sonho Sombrio Escutado',
        pagePurpose: 'Escutar um pesadelo como mensageiro',
        pageCategory: SpellCategory.dreams,
        pagePrompts: [
          'O sonho sombrio que me visitou:',
          'O que senti dentro dele e ao acordar:',
          'Que parte da minha sombra pode estar falando:',
          'O que esse recado pede de mim na vida desperta:',
        ],
      ),
      TrailLesson(
        id: 'mn_08',
        recordKind: LessonRecordKind.oracle,
        title: 'Espelho negro e vidência sombria',
        teaching:
            'Vidência sombria é a arte de olhar para o escuro até que ele comece a falar. O espelho negro, a tigela de água escura e a chama da vela são portas antigas para isso: superfícies que ocupam os olhos para que a intuição assuma o comando. Aprender essa prática importa porque treina a habilidade central da bruxa: sustentar o olhar diante do desconhecido sem fugir dele\n\nA prática atravessa séculos: videntes olharam espelhos de obsidiana, poços fundos e bacias de tinta em muitas culturas, e o folclore guardou histórias de espelhos que mostram verdades escondidas. O funcionamento é menos misterioso do que parece: diante de uma superfície escura e sem detalhes, a mente racional aquieta e as imagens internas ganham espaço — símbolos, memórias, intuições. O espelho não mostra fantasmas: mostra você, em profundidade\n\nPara começar, escureça o ambiente, acenda uma vela fora do reflexo e olhe suavemente para a superfície negra por alguns minutos, piscando normalmente. O erro comum é forçar visões ou desistir na terceira tentativa — vidência é músculo, cresce devagar. Se preferir um apoio mais concreto, as Cartas do Oráculo do app cumprem papel parecido: imagens que emprestam forma à sua intuição. Registre tudo, mesmo o que parecer pouco\n\nLeve consigo: o escuro não está vazio — está cheio de você. Cada sessão de vidência ensina seus olhos a confiarem no que os outros sentidos já sabem. Não há resposta certa a encontrar, há escuta a refinar. Com paciência, o espelho negro deixa de ser assustador e vira o que sempre foi: uma janela tranquila para a sua própria profundidade',
        practice:
            'Você vai fazer sua primeira sessão de vidência. Primeiro, prepare o ambiente: luz baixa, uma vela acesa e um espelho escuro ou uma tigela com água sobre fundo escuro — ou, se preferir, as Cartas do Oráculo do app. Depois, olhe suavemente para a superfície ou tire uma carta, deixando impressões, imagens e sensações surgirem sem forçar, por cinco a dez minutos. Por fim, registre tudo na página, sem censura. O objetivo é treinar o olhar intuitivo diante do escuro',
        pageTitle: 'Minha Sessão de Vidência',
        pagePurpose: 'Olhar o escuro sem medo e registrar o que vi',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Como preparei o espaço e o espelho (ou as cartas):',
          'O que vi, senti ou intuí:',
          'O que pode ser símbolo e o que pode ser medo meu:',
          'A mensagem que levo desta sessão:',
        ],
      ),
      TrailLesson(
        id: 'mn_09',
        recordKind: LessonRecordKind.spell,
        title: 'Contenção: o feitiço amarrado à ética',
        teaching:
            'Contenção, ou binding, é o feitiço que amarra um dano para que ele pare de se espalhar — como quem enfaixa um braço quebrado ou fecha um registro que vaza. Nesta trilha, ele existe para conter padrões, situações e comportamentos destrutivos, nunca para controlar a vontade de alguém ou ferir quem quer que seja. É a magia do limite: o basta dito em nó e cordão\n\nA imagem do nó atravessa a história da magia: nós que seguram ventos nas lendas dos marinheiros, fitas que firmam promessas, tranças que guardam intenções. O binding clássico amarra um símbolo do problema com cordão e palavra firme. A ética é explícita: conter é impedir que um mal continue — como conter o próprio vício, uma dinâmica de fofoca ou um ciclo de autossabotagem. Controlar ou ferir pessoas é outra coisa, e esta trilha não ensina isso\n\nNa prática, escreva a situação ou o padrão a conter num papel, dobre-o para dentro e amarre com cordão escuro, declarando que aquele dano está contido e não cresce mais. Guarde o pacote num lugar fechado. O erro comum é usar contenção como atalho para não agir — o feitiço segura a hemorragia, mas a cura pede atitudes concretas. Outro é mirar alguém por raiva disfarçada de justiça: pergunte-se sempre o que exatamente você quer conter\n\nLeve consigo: todo feitiço volta para as mãos que o fazem — por isso a bruxa madura mede a intenção antes do nó. A contenção bem feita não é ataque: é o limite sagrado que protege você e os outros de um dano em curso. Use-a raramente, com clareza e responsabilidade, e ela será uma das ferramentas mais sóbrias do seu grimório',
        practice:
            'Você vai fazer um Feitiço de Contenção ético. Primeiro, identifique um dano em curso que precisa parar de crescer — um padrão, um ciclo, uma situação; jamais uma pessoa como alvo. Depois, escreva-o num papel, dobre-o para dentro e amarre com um cordão escuro em nós firmes, declarando que aquele mal está contido; guarde o pacote em local fechado. Por fim, registre o feitiço e as atitudes concretas que o acompanharão. O objetivo é conter o dano enquanto você age para resolvê-lo',
        pageTitle: 'Meu Feitiço de Contenção',
        pagePurpose: 'Conter um dano em curso sem ferir ninguém',
        pageCategory: SpellCategory.protection,
        pageType: SpellType.banishment,
        pageIngredients: ['Cordão para o nó simbólico', 'Papel e caneta'],
        pagePrompts: [
          'O dano que precisa parar (fato, não pessoa):',
          'Meu limite ético neste trabalho:',
          'Como amarrei a contenção (nó, palavra, símbolo):',
          'A ação concreta que acompanha o feitiço:',
        ],
      ),
      TrailLesson(
        id: 'mn_10',
        recordKind: LessonRecordKind.note,
        title: 'Integração: a bruxa inteira',
        teaching:
            'A trilha termina onde a bruxaria inteira começa: na integração. Depois de olhar a sombra, banir, cortar, proteger e conter, você descobre que não existem duas bruxas dentro de você — uma de luz e outra de escuro. Existe uma só, mais honesta, que conhece as próprias profundezas. Integrar é isso: parar de escolher metades e habitar o próprio inteiro com serenidade\n\nOs símbolos antigos sempre apontaram para essa união: o dia precisa da noite, a lua cheia carrega a memória da lua negra, a semente e a flor são a mesma planta em tempos diferentes. Nas histórias, quem desce ao mundo de baixo e retorna volta transformada — não mais sombria, mais sábia. A sombra integrada não desaparece: vira discernimento, humor, compaixão e aquela força tranquila de quem já se conhece por dentro\n\nNo cotidiano, a integração aparece em sinais discretos: você se irrita menos com os espelhos alheios, diz não sem culpa, descansa sem vergonha, protege-se sem endurecer. O erro comum é achar que o trabalho de sombra termina — ele muda de ritmo, mas acompanha a vida. Outro é esperar perfeição: a bruxa inteira não é a que nunca erra; é a que se responsabiliza pelo que faz com o próprio poder\n\nLeve consigo: você atravessou o escuro e ele não te engoliu — te ampliou. O manifesto que escreve agora é o retrato de quem chegou até aqui: alguém que pratica com ética, sente sem se afogar e brilha sem negar a própria noite. Siga com as duas mãos abertas, uma para a luz e outra para a sombra. É assim que caminha a bruxa inteira',
        practice:
            'Você vai escrever o Manifesto da Bruxa Inteira. Primeiro, releia as páginas desta trilha e observe o que mudou do pacto inicial até aqui. Depois, escreva um texto curto e pessoal declarando quem você é como praticante: seus valores, seus limites, o que integra da luz e da sombra. Por fim, leia o manifesto em voz alta e guarde-o como fechamento da trilha. O objetivo é selar a integração e assumir, com ética, o próprio poder inteiro',
        pageTitle: 'Manifesto da Bruxa Inteira',
        pagePurpose: 'Integrar luz e sombra no meu caminho',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'O que a sombra me devolveu de poder:',
          'O que mudou na minha relação com o medo:',
          'Minha ética, agora em uma frase:',
          'Como sigo daqui: luz e sombra juntas:',
        ],
      ),
    ],
  );
