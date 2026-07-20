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
            'Toda magia começa antes da vela, do cristal ou da palavra: começa na intenção. Ela é o coração de qualquer trabalho porque direciona a energia que você move. Na magia branca, a intenção é formulada de forma clara, positiva e no tempo presente — em vez de dizer que quer parar de ter medo, você afirma que caminha protegida e confiante. É essa clareza que transforma um desejo vago em um ato mágico.\n\nUma boa intenção tem três marcas: é específica, é sua — nunca tenta controlar a vontade dos outros — e é dita como se já fosse realidade. Essa estrutura aparece em tradições diversas, das orações antigas às afirmações modernas, porque a mente responde melhor a imagens concretas e presentes. Praticantes experientes passam mais tempo lapidando a frase do que montando o altar, pois sabem que a palavra certa carrega o trabalho inteiro.\n\nNo cotidiano da bruxa iniciante, a intenção aparece antes de tudo: ao acender uma vela, preparar um banho ou abrir o caderno. Um erro comum é acumular vários pedidos numa frase só ou usar negações, que mantêm o foco no problema. Outro é formular às pressas. Reserve alguns minutos, escreva, leia em voz alta e observe se o corpo responde: uma intenção viva costuma dar um leve arrepio de reconhecimento.\n\nLeve com você esta ideia: a magia começa na frase que você escolhe. Antes de qualquer ferramenta, lapide a sua intenção até que ela seja clara, sua e presente. Quando a palavra está certa, todo o resto do ritual apenas a acompanha — a vela ilumina, o gesto sela, mas quem conduz é o coração que soube dizer o que deseja.',
        practice:
            'Nesta prática você vai lapidar uma intenção importante. Primeiro, escreva três versões diferentes da mesma intenção no papel. Depois, revise cada uma cortando negações, promessas para um futuro distante e desejos sobre outras pessoas. Por fim, leia as três em voz alta e escolha a que soa mais viva no corpo. O objetivo é treinar a clareza que sustenta toda magia branca: uma frase específica, sua e dita no presente.',
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
            'O círculo é a tecnologia mais antiga da magia: um limite simbólico que separa o espaço sagrado do cotidiano. Ele importa porque a mente precisa de fronteiras para mudar de estado — ao traçar o círculo, você avisa a si mesma que ali dentro, naquele momento, tudo é diferente. É a moldura que protege e concentra qualquer trabalho de magia branca.\n\nTradições do mundo inteiro traçam círculos: com sal, giz, cordão, o dedo apontado ou pura visualização. O material importa menos que o gesto consciente. Em muitas linhagens, caminha-se no sentido do sol para abrir e no sentido contrário para desfazer. E o que se abre, se fecha: encerrar o círculo agradecendo é tão importante quanto traçá-lo, pois devolve o espaço ao cotidiano sem deixar portas abertas.\n\nNo dia a dia, a iniciante pode traçar um círculo antes de meditar, escrever no grimório ou acender uma vela. Não precisa de espaço grande: um círculo imaginado ao redor da cadeira já funciona. Erros comuns: sair do círculo no meio do trabalho sem necessidade e esquecer de desfazê-lo ao final. Comece simples, com sal ou visualização, e repita até o gesto virar memória do corpo.\n\nGuarde esta chave: o círculo é um gesto de consciência, não de material. Onde você traça um limite com presença, nasce um espaço sagrado — e onde você o desfaz com gratidão, o cotidiano volta em paz. Abrir e fechar, sempre nessa ordem: esse é o ritmo silencioso de toda proteção bem feita.',
        practice:
            'Nesta prática você vai criar seu primeiro espaço sagrado. Primeiro, trace um círculo ao seu redor — com sal, um gesto ou pura visualização. Depois, permaneça três minutos em silêncio dentro dele, apenas percebendo a diferença no ar e no corpo. Por fim, desfaça o círculo com consciência, agradecendo. O objetivo é sentir na pele que abrir e fechar um limite muda o estado interno — a base de toda proteção mágica.',
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
            'A bênção é a forma mais generosa da magia branca: desejar ativamente o bem de alguém sem controlar o caminho de ninguém. Ela importa porque muda a direção da prática — em vez de pedir para si, você irradia para fora. Abençoar treina o coração na abundância e lembra que a magia também é serviço, não apenas conquista pessoal.\n\nA estrutura clássica da bênção tem três passos: nomear quem recebe, declarar o bem desejado e selar com um gesto — as mãos sobre o coração, um sopro, um toque na água. Culturas inteiras se organizaram em torno de bênçãos: sobre alimentos, casas, viagens e nascimentos. A regra de ouro atravessa todas elas: abençoe sem esperar retorno e jamais para influenciar decisões alheias — isso já seria outra coisa.\n\nNo cotidiano, a bênção cabe em qualquer lugar: um pensamento bom ao cruzar com um vizinho, uma palavra silenciosa sobre a comida, um desejo de paz ao entrar em casa. O erro mais comum da iniciante é disfarçar um pedido de controle como bênção — desejar que alguém tome certa decisão, por exemplo. Abençoe a pessoa como ela é hoje, não como você gostaria que fosse.\n\nLeve esta ideia no bolso: abençoar é desejar o bem e soltar o resultado. Quando você abençoa sem controlar, a energia flui limpa e volta em forma de leveza. Um coração que abençoa todos os dias nunca pratica magia pequena — ele transforma cada encontro em um altar discreto.',
        practice:
            'Nesta prática você fará sua primeira bênção consciente. Primeiro, escolha alguém querido e traga o rosto dessa pessoa à mente. Depois, durante um minuto inteiro, deseje o bem dela em silêncio — exatamente como ela é hoje, sem corrigir nada, sem pedir mudanças. Por fim, sele com um gesto simples, como a mão sobre o coração. O objetivo é experimentar a magia que flui para fora: desejar o bem sem controlar o caminho de ninguém.',
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
            'A vela é o altar portátil da magia branca: fogo que concentra a intenção num único ponto de luz. Ela importa porque reúne muito poder em um objeto simples — a cera que vem da terra, o pavio que respira o ar e a chama que transforma. Poucas ferramentas oferecem tanto foco com tão pouco, e por isso a vela costuma ser a primeira companheira da bruxa.\n\nCada detalhe conversa com o objetivo. A cor da vela dialoga com a intenção — consulte a Enciclopédia de Cores para escolher com consciência. Ungir a vela com óleo é vesti-la para o trabalho, e riscar símbolos na cera grava o pedido na matéria antes de entregá-lo à chama. Tradições de velas existem em quase toda prática devocional: a chama sempre foi vista como mensageira entre mundos.\n\nPara a iniciante, a vela é o ritual mais acessível: acender com intenção clara, observar a chama, apagar com gratidão. Erros comuns: pressa para pedir sem preparar a intenção e descuido com o fogo. Segurança é parte do ritual: vela acesa nunca fica sozinha, sempre longe de cortinas e sobre superfície firme. Comece com a vela branca, que serve a todo propósito luminoso.\n\nMemorize esta chave: a chama é o seu foco tornado visível. Quando você acende uma vela com presença, ela sustenta a intenção enquanto queima. Cuide do fogo como cuida do desejo — com atenção, respeito e constância — e a vela será sempre um altar completo cabendo na palma da mão.',
        practice:
            'Nesta prática você vai treinar presença diante do fogo. Primeiro, prepare um lugar seguro e acenda uma vela branca. Depois, durante dez minutos, apenas observe a chama — o movimento, a cor, a dança — sem pedir absolutamente nada. Por fim, apague com gratidão ou deixe queimar em segurança. O objetivo é construir intimidade com a ferramenta antes de usá-la: quem sabe contemplar a chama aprende a focar a própria intenção.',
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
            'Água e sal formam a combinação mais antiga de purificação que a humanidade conhece. A água lustral é a versão consagrada dessa dupla: um preparado simples que limpa objetos, espaços e a própria energia antes dos trabalhos. Ela importa porque toda magia pede terreno limpo — trabalhar em ambiente carregado é como plantar em solo cansado.\n\nO preparo é um ritual em si: água limpa, uma pitada de sal, as mãos pousadas sobre o recipiente e uma palavra de consagração dita com presença. Templos antigos mantinham vasilhas de água à entrada para purificar quem chegava — a lógica é a mesma. O sal desfaz e a água carrega: juntos, dissolvem o que pesa e levam embora o que não serve mais.\n\nNo cotidiano, a água lustral aparece borrifada pelos cantos da casa, ungindo a testa e os pulsos antes de um ritual ou lavando ferramentas recém-chegadas. Guarde em recipiente bonito e renove com frequência — água parada por muitas semanas perde o viço. Dois cuidados essenciais: nunca beba a água lustral e não pule a consagração, pois sem a palavra ela é apenas água com sal.\n\nA chave desta lição: limpar é preparar. Antes de pedir, purifique; antes de plantar, cuide do solo. Uma bruxa que mantém sua água lustral viva mantém também o hábito mais importante da prática — começar cada trabalho em terreno claro, leve e pronto para receber.',
        practice:
            'Nesta prática você vai preparar sua primeira água lustral. Primeiro, escolha um recipiente bonito, encha com água limpa e acrescente uma pitada de sal. Depois, pouse as mãos sobre ele e diga uma palavra de consagração com presença. Por fim, use essa água para limpar um objeto que você usa todos os dias, passando algumas gotas com intenção. O objetivo é sentir como a purificação prepara o terreno para toda magia.',
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
            'Nem todo dia tem altar — mas todo dia tem mundo. O escudo energético é a proteção portátil da bruxa: uma barreira invisível criada pela imaginação treinada, que filtra o que chega de fora. Ele importa porque a sensibilidade que a prática desperta também pede defesa — quem sente mais precisa aprender a se resguardar mais.\n\nO escudo funciona por visualização repetida: uma esfera de luz ao redor do corpo, um manto que envolve, espelhos que devolvem o que não é seu. Cada tradição tem sua imagem preferida, mas o princípio é o mesmo — a mente treinada cria fronteiras energéticas reais para quem as habita. O gesto-gatilho, discreto e sempre igual, é o interruptor que ativa tudo em segundos.\n\nNo cotidiano, o escudo aparece antes de sair de casa, em reuniões tensas, no transporte lotado. O segredo é o treino: escudo se constrói em casa, com calma e repetição, para funcionar no ônibus cheio. O erro clássico da iniciante é tentar criar a proteção pela primeira vez no meio da crise — sem treino prévio, a imagem não se sustenta. Pratique um pouco todos os dias.\n\nGrave esta ideia: proteção é hábito, não emergência. Alguns minutos diários de visualização criam um escudo que responde ao seu gesto em qualquer lugar. A bruxa protegida não é a que nunca encontra peso no mundo — é a que sabe voltar depressa para a própria luz.',
        practice:
            'Nesta prática você vai construir seu escudo pessoal. Primeiro, sente-se em um lugar tranquilo e visualize por cinco minutos uma esfera de luz envolvendo todo o seu corpo — perceba a cor, o brilho, a textura. Depois, escolha um gesto discreto, como tocar um anel ou cruzar os dedos, e repita-o enquanto a imagem está viva. O objetivo é associar gesto e escudo, criando um gatilho que ativa sua proteção em segundos, onde você estiver.',
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
            'O banho ritual transforma o ato mais cotidiano em rito de cura: água morna, ervas ou sal, luz baixa e intenção. Ele importa porque une o corpo à magia — a pele sente, o vapor envolve e a mente entende, sem esforço, que algo está sendo lavado por dentro também. É a cura mais acessível da magia branca: você já toma banho todos os dias.\n\nA tradição distingue direções: do pescoço para baixo, o banho limpa e descarrega, preservando a cabeça, centro da consciência; da cabeça para baixo, apenas com ervas suaves, renova por completo. Banhos de ervas atravessam culturas — das casas de cura às aldeias antigas — sempre com a mesma gramática: preparar com intenção, despejar com presença, deixar o corpo secar naturalmente quando possível.\n\nNa rotina da iniciante, o banho ritual pode fechar a semana ou preceder trabalhos importantes. Prepare tudo antes: erva ou sal, vela acesa em local seguro no banheiro, celular longe. Erros comuns: pressa, banho tomado no piloto automático e ervas fortes demais sem conhecimento. Comece com o simples — sal grosso ou camomila — e cresça aos poucos, anotando o que funciona.\n\nLeve esta chave: o essencial é sair do banho diferente de como entrou — e nomear essa diferença. Água que corre leva o que pesa; intenção que guia chama o que renova. Com presença, o seu chuveiro pode se tornar o templo mais fiel e constante de toda a sua prática.',
        practice:
            'Nesta prática você vai transformar o banho de hoje em ritual. Primeiro, deixe o celular fora do banheiro e, se quiser, acenda uma vela em local seguro. Depois, tome o banho sem pressa alguma, visualizando a água levando embora tudo o que pesa — preocupações, cansaço, restos do dia. Por fim, ao fechar o chuveiro, respire fundo e nomeie em silêncio como você se sente. O objetivo é experimentar a cura mais simples que existe: água, presença e intenção.',
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
            'O amuleto é intenção condensada em matéria: um objeto pequeno, consagrado para um único propósito e carregado junto ao corpo. Ele importa porque estende a magia para além do ritual — enquanto você vive o seu dia, o amuleto segue trabalhando em silêncio, lembrando à sua energia o que foi combinado diante do altar.\n\nNa magia branca, os clássicos são amuletos de proteção — o olho, o sal, a arruda — e de bênção, como medalhas e pedras claras. A consagração segue quatro passos simples: limpar o objeto, declarar seu propósito em voz alta, energizar sob a luz da lua, perto de uma chama ou com o próprio sopro, e portar com fé. Povos de todas as eras carregaram amuletos: levar a proteção consigo é um desejo tão antigo quanto o caminho.\n\nPara a iniciante, o melhor amuleto costuma ser um objeto que já tem história com você — um anel herdado, uma pedra achada, uma medalha querida. Erros comuns: acumular vários propósitos num mesmo objeto, o que dilui a força, e esquecer de limpá-lo de tempos em tempos. Um propósito por amuleto e uma limpeza ocasional, e ele serve por anos.\n\nA ideia para guardar: o amuleto é um pacto silencioso entre você e um objeto. Consagre com clareza, carregue com fé e renove com cuidado, e ele responderá com constância. Assim, mesmo nos dias sem altar e sem vela, um pedaço da sua magia caminha junto ao seu corpo, para onde quer que você vá.',
        practice:
            'Nesta prática você vai escolher seu primeiro amuleto de luz. Primeiro, olhe ao redor e encontre um objeto pequeno que você já ama e que tenha história com você. Depois, segure-o nas mãos e pergunte-se em silêncio qual propósito único ele vai servir — proteção ou bênção. Por fim, guarde-o em um lugar especial até registrar a consagração na sua página. O objetivo é entender que o poder do amuleto nasce do vínculo: um objeto, um propósito, uma fé.',
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
            'A magia branca brilha nos dias escuros: um velório, um diagnóstico, um término. Nesses momentos ela não resolve — acompanha. E isso importa porque a prática que só serve para os dias bons abandona a bruxa exatamente quando ela mais precisa. Um rito de travessia dá chão quando o chão parece faltar sob os pés.\n\nO ritual mínimo para atravessar tem quatro gestos: acender uma chama, nomear a dor em voz alta, pedir força — não solução — e agradecer por estar viva para sentir. Ritos de passagem existem em toda cultura humana justamente porque a dor precisa de forma: quando ganha nome, vela e palavra, ela deixa de ser um mar sem margem e se torna um rio que se atravessa.\n\nNo cotidiano, isso significa ter seu rito pronto antes da tempestade: três passos simples que o corpo conhece de cor. O erro mais comum é exigir da magia o que ela não promete — apagar a dor, trazer alguém de volta, mudar o diagnóstico. Se a dor for grande demais, procure também apoio humano e profissional: magia madura caminha junto com o cuidado, nunca no lugar dele.\n\nGuarde esta sabedoria: magia madura sabe a diferença entre transformar e aceitar. Nos dias escuros, acenda a chama, nomeie a dor e peça força para atravessar. Você não precisa vencer a noite inteira de uma vez — só precisa de luz suficiente para dar o próximo passo.',
        practice:
            'Nesta prática você vai experimentar um rito de travessia. Primeiro, pense em uma dor atual ou antiga que ainda mereça acolhimento. Depois, acenda uma vela branca em local seguro e, olhando a chama, diga em voz alta: eu te vejo, eu te atravesso, eu peço força. Por fim, fique alguns instantes em silêncio e agradeça por estar viva para sentir. O objetivo é dar forma à dor com nome, chama e palavra, pedindo força em vez de solução.',
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
            'Todo trabalho de magia branca termina no mesmo lugar: a gratidão. Agradecer fecha o circuito da energia, reconhecendo o recebido antes mesmo de ver resultados. Importa porque um final bem feito protege o trabalho inteiro — ritual sem encerramento é porta entreaberta, e a gratidão é a chave que gira suave na fechadura.\n\nA gratidão é também a proteção mais subestimada da prática: um coração agradecido não opera pela carência, e magia feita da falta tende a atrair mais falta. Tradições do mundo todo encerram seus ritos agradecendo — às forças invocadas, ao espaço, ao próprio corpo. O agradecimento devolve cada coisa ao seu lugar e sela o que foi feito, como quem assina uma carta antes de enviá-la.\n\nNo cotidiano, o encerramento vira assinatura pessoal: um gesto sempre igual, uma frase curta de gratidão, um sopro na vela. Repetido ao final de cada trabalho, ele ensina ao corpo que o rito terminou. O erro comum é sair correndo do altar assim que o pedido é feito — dedique ao final o mesmo carinho que dedicou ao começo. Nesta última página, você cria o seu ritual de encerramento.\n\nLeve consigo a última chave desta trilha: a gratidão é começo e fim de toda magia branca. Agradeça antes de ver, agradeça depois de receber, agradeça até nos dias em que só houve travessia. Quem encerra com gratidão nunca sai de um ritual de mãos vazias — essa é a sua assinatura mágica.',
        practice:
            'Nesta prática você vai encerrar a trilha como quem fecha uma cerimônia. Primeiro, respire fundo e olhe para trás, relembrando as lições que atravessou. Depois, liste cinco coisas que a sua prática já trouxe para a sua vida — pequenas ou grandes, todas contam. Por fim, leia a lista em voz alta, devagar, como as palavras finais de um rito. O objetivo é fechar o circuito da energia com gratidão, selando tudo o que você construiu até aqui.',
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
            'A magia verde não começa decorando tabelas de correspondências — começa com UMA planta conhecida de verdade: nome, cheiro, textura, como ela reage à água e ao sol. Conhecer de perto uma única aliada vale mais do que memorizar cem nomes, porque a magia verde nasce de relação, não de catálogo. É por isso que este é o primeiro passo do caminho.\n\nBruxas verdes tradicionais tinham relação profunda com poucas dúzias de plantas: sabiam colher na hora certa, agradeciam, usavam cada parte, da raiz à flor. O alecrim da janela, a arruda do portão e a hortelã do quintal eram vizinhas conhecidas, não itens de uma lista. Essa intimidade — observar a planta ao longo dos dias e das estações — é o que transforma informação em sabedoria.\n\nNo cotidiano, isso significa escolher uma planta acessível — um vaso da sua casa, uma árvore do caminho — e visitá-la com atenção verdadeira. Observe as folhas, o perfume, a textura, como ela amanhece. O erro comum da iniciante é querer trabalhar com dez ervas de uma vez e não conhecer nenhuma de verdade. Vá devagar: uma aliada bem conhecida sustenta muita magia.\n\nSua primeira página de magia verde é o retrato de uma aliada, escrito com os seus próprios sentidos. Guarde esta ideia como quem guarda uma semente: antes de usar uma planta, conheça a planta. Relação vem antes de feitiço — e é ela que dá raiz, força e verdade a tudo o que floresce depois no seu caminho.',
        practice:
            'Passe 5 minutos com uma planta acessível usando os cinco sentidos com segurança. Primeiro observe cores e formas, depois toque com delicadeza, cheire as folhas e escute o ambiente ao redor — sem provar nada, pois nunca se leva à boca o que não se conhece com certeza. Por fim, anote 3 observações que nenhum livro daria. O objetivo é iniciar uma relação real com a sua primeira aliada verde.',
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
            'Água, fogo, planta e intenção: o chá é o ritual verde mais acessível que existe. Ele reúne os elementos essenciais da magia em uma xícara e cabe em qualquer rotina, em qualquer cozinha. A diferença entre tomar um chá e ritualizar um chá não está em ingredientes raros, e sim na presença com que você prepara e bebe cada gole.\n\nRitualizar significa escolher a erva pela intenção — camomila para acalmar, hortelã para clarear, capim-limão para suavizar —, mexer em círculos no sentido do objetivo, horário para atrair e anti-horário para afastar, e beber em silêncio, deixando o calor levar a intenção para dentro. Curandeiras e avós sempre souberam: um chá feito com cuidado carrega muito mais do que princípios ativos.\n\nNo cotidiano da bruxa iniciante, o chá ritual pode ser o momento mais mágico do dia: cinco minutos de fogão, vapor e silêncio. Segurança primeiro: use apenas plantas comestíveis conhecidas, respeite contraindicações e, na dúvida, não beba. O erro mais comum é preparar com pressa, mexendo no celular — presença é o ingrediente principal, e sem ela o rito vira rotina.\n\nGuarde esta ideia: a xícara é um pequeno caldeirão que cabe nas suas mãos. Sempre que precisar de um ritual simples e imediato, lembre que água quente, uma erva segura e a sua intenção já formam um feitiço completo. Repetido com constância — sete dias, toda lua —, esse gesto pequeno se torna uma das práticas mais profundas da magia verde.',
        practice:
            'Prepare um chá simples com presença total, do início ao fim. Primeiro escolha uma erva comestível conhecida e nomeie a intenção; depois aqueça a água observando o vapor, mexa em círculos no sentido do seu objetivo e coe com calma; por fim, beba em silêncio, sem celular, sentindo o calor levar a intenção para dentro. O objetivo é experimentar como a presença transforma um gesto comum em ritual.',
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
            'O sachê é a magia verde portátil: ervas secas reunidas num saquinho de tecido, fechado com nó e palavra de poder. Ele leva a força das plantas para onde você for — debaixo do travesseiro para bons sonhos, na bolsa para proteção, no armário para harmonia. É um dos amuletos mais antigos e simples da bruxaria, e por isso mesmo um dos mais queridos.\n\nA montagem clássica segue uma lógica de três partes: a erva principal, que carrega a intenção; uma erva de suporte, que amplia e equilibra; e um fixador — casca, raiz ou pedrinha — que ancora o trabalho no tempo. A cor do tecido conversa com o objetivo: vermelho para coragem, verde para prosperidade, branco para paz. Tradições populares do mundo inteiro usam variações desse mesmo desenho.\n\nPara a iniciante, a própria cozinha já é um armário mágico: louro, alecrim, canela, cravo e camomila rendem combinações poderosas. O erro comum é acumular sachês sem propósito claro — cada um deve nascer de uma intenção definida e ganhar um lugar certo para viver. Quando sentir que ele cumpriu o papel, desfaça ou renove com gratidão, devolvendo as ervas à terra se puder.\n\nLeve consigo esta imagem: um sachê é uma intenção embrulhada em pano e selada com um nó. Poucas ervas, propósito claro e palavra dita com firmeza valem mais do que dezenas de ingredientes misturados sem escuta. Onde quer que o seu saquinho viva — travesseiro, bolsa ou armário —, ele seguirá sussurrando a intenção que você amarrou nele.',
        practice:
            'Separe ervas secas que você já tem na cozinha, como louro, alecrim e canela, e sinta qual combinação pede para existir. Primeiro defina a intenção; depois escolha a erva principal, a de suporte e um fixador, tocando e cheirando cada uma com calma; por fim, anote a combinação escolhida e a cor de tecido que conversa com o objetivo. A meta é treinar a escuta das plantas antes de montar o seu primeiro sachê.',
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
            'A bruxa de cozinha sabe: panela é caldeirão, colher de pau é varinha, tempero é feitiço. A cozinha é o altar mais antigo da humanidade — o lugar onde fogo, água, terra e ar se encontram todos os dias. Cozinhar com intenção transforma alimento em magia e faz da rotina mais comum um espaço sagrado, sem precisar de nada além do que você já tem.\n\nA tradição da magia de cozinha atravessa culturas e gerações: mexer no sentido horário para atrair, temperar nomeando o desejo em voz baixa, servir como quem abençoa. Cada ingrediente carrega correspondências — canela para prosperidade, alho para proteção, manjericão para harmonia — e o calor do fogo é o que sela a intenção no alimento, como um forno sela o pão.\n\nNo dia a dia, você não precisa de receitas especiais: o arroz de todo dia pode ser encantado. Comece nomeando uma intenção antes de acender o fogo e declare algo a cada ingrediente-chave que entrar na panela. O erro comum é cozinhar com raiva ou pressa — o alimento absorve o estado de quem prepara, então respire fundo antes de começar e cozinhe como quem reza.\n\nGuarde esta verdade simples: a refeição encantada mais poderosa é a feita para alguém que você ama, incluindo você mesma. Não espere ocasiões especiais — o altar da cozinha se acende todos os dias. Sempre que cozinhar, lembre que as suas mãos já são instrumentos mágicos e que cada panela no fogo pode ser um feitiço em andamento.',
        practice:
            'Cozinhe algo simples hoje transformando o preparo em feitiço. Primeiro escolha a receita e defina uma intenção clara; depois, a cada ingrediente adicionado, declare em voz baixa o que ele traz — proteção, doçura, força; mexa no sentido horário para atrair e finalize servindo como quem abençoa. O objetivo é sentir na prática como a intenção muda a sua relação com o alimento e com quem o recebe.',
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
            'Plantar uma semente com intenção é o feitiço de longa duração da magia verde: o crescimento da planta espelha o crescimento do desejo. Enquanto muitos feitiços buscam resultado rápido, o plantio ensina a magia do tempo — aquilo que você semeia com cuidado hoje se torna força enraizada amanhã, no vaso e na vida.\n\nA estrutura é simples e antiga: vaso, terra, semente, palavra. Camponesas e curandeiras sempre plantaram nomeando desejos — um alecrim para a saúde da casa, um manjericão para a fartura da mesa. Depois do gesto inicial vem o verdadeiro trabalho: cuidar todos os dias, regar, dar sol, observar. O feitiço não está apenas no plantio; está na constância que o sustenta.\n\nPara a iniciante, até um grão de feijão no algodão serve de começo. O erro comum é plantar com entusiasmo e esquecer na primeira semana — e aqui mora a lição: se a planta murcha, o recado também é mágico. Pergunte a si mesma que cuidado está faltando, ali no vaso e na intenção que ele carrega. Ajuste a rega, ajuste a vida, e recomece sem culpa.\n\nLeve esta ideia: toda intenção é uma semente e todo cuidado diário é o feitiço continuando em silêncio. Plante devagar, cuide com constância e confie no tempo da terra — ele raramente é o nosso, e quase sempre é o certo. Quando o primeiro broto aparecer, você vai entender por que a magia mais duradoura é a que cresce devagar.',
        practice:
            'Plante uma semente ou muda — até um grão de feijão serve — dedicando o plantio a uma intenção de crescimento. Primeiro prepare vaso e terra com calma; depois plante dizendo em voz alta o que deseja ver crescer junto com ela; por fim, assuma um compromisso simples de cuidado diário, como regar e observar. O objetivo é viver um feitiço lento, em que cuidar da planta é cuidar da própria intenção.',
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
            'A fumaça de ervas é a vassoura energética da magia verde: onde o denso se acumula, ela passa, solta e renova. Defumar é uma das práticas de limpeza mais antigas da humanidade, presente em incontáveis tradições ao redor do mundo, e continua sendo um dos ritos mais diretos para mudar a sensação de um espaço — e de quem vive nele.\n\nCada erva tem seu ofício na fumaça: alecrim para renovar, louro para prosperar, arruda para cortar o que pesa. O rito tradicional percorre a casa dos fundos para a porta de entrada, passando pelos cantos e atrás das portas, sempre com janelas abertas — o denso sai, o novo entra. A direção do trajeto importa tanto quanto a erva escolhida: você conduz a limpeza para fora.\n\nNo cotidiano, comece pequeno: um cômodo, uma erva, um recipiente resistente ao fogo. Respeite alergias, animais e vizinhos, e nunca deixe brasas sem vigilância. Atenção também à origem das ervas: magia verde é responsabilidade ecológica, então prefira o que você cultiva ou compra de fontes conscientes. O erro comum é defumar com a casa fechada — sem saída, o denso não vai embora.\n\nGuarde a imagem: a fumaça é oração visível e vassoura invisível ao mesmo tempo. Quando o ambiente pesar — depois de uma discussão, de uma semana difícil, de uma visita que deixou rastro —, lembre que uma erva seca, uma brasa segura e janelas abertas bastam para renovar o ar. O de fora e, com um pouco de presença, também o de dentro.',
        practice:
            'Defume um único cômodo hoje com uma erva que você já tenha em casa. Primeiro abra as janelas e acenda a erva num recipiente resistente ao fogo; depois percorra o espaço com calma, dos fundos em direção à saída, levando a fumaça aos cantos e atrás da porta; por fim, apague tudo com segurança e sente-se um instante. O objetivo é observar a mudança na sensação do espaço antes e depois do rito.',
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
            'O óleo condimentado é a poção de uso contínuo da bruxa verde: azeite ou óleo vegetal, ervas e tempo. Diferente do chá, que se faz e se bebe na hora, o óleo amadurece devagar e depois acompanha você por semanas — ungindo velas, amuletos, pulsos e portas com a intenção que ele carrega desde o primeiro dia.\n\nO preparo tradicional é paciente: ervas dentro de um vidro escuro coberto de óleo, descansando por cerca de três semanas, agitado diariamente enquanto você renova a intenção em voz baixa ou em pensamento. Ao final, coa-se e guarda-se ao abrigo da luz. Alecrim no azeite para vitalidade e alho para proteção são exemplos clássicos das cozinhas e boticas de sempre.\n\nNo dia a dia, o óleo vira uma ferramenta discreta: uma gota na vela antes de acender, um toque nos pulsos antes de uma conversa difícil, um traço no batente da porta. Rotule sempre com nome, data e propósito — bruxa organizada é bruxa poderosa. O erro comum é esquecer o vidro no fundo do armário: sem a agitação diária, o feitiço perde o fio. E use na pele apenas ervas e óleos seguros.\n\nLeve esta síntese: óleo mágico é intenção que amadurece no escuro, gota a gota, dia após dia. Tempo, constância e rótulo bem feito transformam um vidro simples numa poção que trabalha por você durante semanas. Comece hoje o seu primeiro vidro e deixe que as três semanas de espera sejam, elas mesmas, parte do feitiço.',
        practice:
            'Comece hoje um óleo simples, como alecrim no azeite, dedicado a uma intenção. Primeiro higienize um vidro escuro e coloque a erva coberta de óleo; depois agite o vidro todos os dias repetindo a intenção, por cerca de três semanas; por fim, coe, rotule com nome, data e propósito e registre o primeiro uso. Use apenas ervas seguras e não ingira o preparo. O objetivo é praticar a magia paciente, que amadurece com o tempo.',
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
            'A lua é a grande regente dos ritmos da magia verde. A tradição planta o que cresce para cima na lua crescente e raízes na minguante; colhe folhas de poder na cheia; descansa a terra na nova. Alinhar o trabalho verde às fases lunares é entrar no compasso que jardineiras e bruxas seguem há gerações — o compasso do céu marcando o tempo da terra.\n\nEsse saber vem dos almanaques rurais e da observação paciente do céu: a crescente favorece começos e expansão, a cheia é o auge da força — hora de colher folhas e celebrar —, a minguante pede poda e desapego, e a nova convida ao repouso e ao planejamento. Mais que agricultura, é treino de paciência mágica: nem tudo é para agora, e cada coisa tem a sua lua certa.\n\nNo cotidiano, você não precisa de horta para praticar: regar, podar folhas secas, trocar um vaso de lugar ou simplesmente planejar já são ações verdes que podem seguir a lua. O Calendário Lunar do app é o seu almanaque de bolso — consulte a fase antes de agir. O erro comum é forçar começos na minguante e se frustrar: respeitar o descanso também é magia.\n\nGuarde o compasso: crescente começa, cheia colhe, minguante solta, nova descansa. Quando estiver em dúvida sobre o momento certo de agir, olhe para o céu — ou para o seu almanaque de bolso — e pergunte em que lua você está. Com o tempo, esse compasso deixa de ser consulta e vira instinto: o seu jardim e a sua vida passam a girar juntos com a lua.',
        practice:
            'Descubra a fase da lua de HOJE no Calendário Lunar do app e faça uma ação verde alinhada a ela: plantar ou começar algo na crescente, colher ou celebrar na cheia, podar ou soltar na minguante, descansar e planejar na nova. Primeiro consulte a fase, depois escolha o gesto que combina com ela e realize com presença; por fim, anote o que fez. O objetivo é começar a viver os ciclos em vez de apenas conhecê-los.',
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
            'Colher é a metade esquecida do plantio. Muita gente aprende a semear e a cuidar, mas poucas aprendem a receber com reverência o que a terra entrega. Na magia verde, a colheita é um rito completo em si mesma — e a forma como você colhe diz tanto sobre a sua prática quanto a forma como você planta.\n\nA colheita ritual tradicional pede quatro gestos: a hora certa — pela tradição, a manhã, depois que o orvalho seca —, o pedido de licença à planta antes de tocar, o corte limpo que não machuca além do necessário e o agradecimento sincero. E uma regra de ouro: uso íntegro, nada colhido à toa. Era assim que as curandeiras colhiam suas ervas de poder, com o respeito de quem visita uma mestra.\n\nNo dia a dia, isso vale até para uma folha do seu vaso ou um fruto escolhido na feira com presença: pare, peça licença em pensamento, colha com delicadeza, agradeça. O erro comum é colher no automático, como quem pega um objeto qualquer — a pressa quebra o elo. E lembre: o mesmo rito serve para as colheitas simbólicas da vida — reconhecer o que chegou, agradecer e usar bem.\n\nLeve consigo a regra de ouro da bruxa verde: nada colhido à toa. Licença, corte limpo, gratidão e uso íntegro — quatro gestos simples que transformam o ato de receber em cerimônia. Pratique-os na planta e depois na vida: quem aprende a colher com reverência descobre que a gratidão é, ela mesma, uma forma de adubo para as próximas colheitas.',
        practice:
            'Colha algo hoje com o rito completo — pode ser uma folha do seu vaso ou um fruto da feira escolhido com presença. Primeiro pare diante da planta e peça licença em silêncio; depois faça o corte ou a escolha com delicadeza; em seguida agradeça com palavras suas; por fim, use integralmente o que colheu, sem desperdício. O objetivo é aprender a receber com a mesma reverência com que se planta.',
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
            'A última página desta trilha é, na verdade, uma capa: a abertura do seu herbário mágico, a lista viva das suas plantas aliadas com os usos testados por VOCÊ. Mais do que um caderno de anotações, o herbário é o retrato da sua relação com o mundo verde — único, pessoal e intransferível, como toda magia que nasce da experiência.\n\nAs bruxas verdes de antigamente guardavam seus saberes em cadernos de receitas, folhas prensadas e memória passada entre gerações. O valor desses registros nunca esteve na quantidade, e sim na verdade: cada erva anotada tinha sido colhida, preparada e observada de perto. O seu herbário segue essa mesma tradição — ele nunca está pronto, cresce a cada estação, como o jardim.\n\nDaqui em diante, cada planta nova merece uma página própria no seu grimório: nome, observações diretas, usos que você mesma testou, receitas que funcionaram. Releia as suas páginas verdes de tempos em tempos e visite a Enciclopédia de Ervas quando quiser escolher a próxima aliada. O erro comum é copiar tabelas prontas sem vivência — registre apenas o que passou pelas suas mãos.\n\nLeve esta certeza: você começou a trilha conhecendo uma única planta e termina com um caminho inteiro pela frente. O herbário cresce no ritmo do jardim — uma aliada de cada vez, uma estação de cada vez, uma página de cada vez. A terra tem tempo, e agora você também: siga escrevendo, e o seu grimório verde florescerá junto com você.',
        practice:
            'Encerre a trilha organizando o seu índice vivo. Primeiro releia as páginas verdes que você escreveu ao longo das lições, anotando cada planta e o uso que realmente testou; depois visite a Enciclopédia de Ervas e escolha a próxima aliada que deseja conhecer; por fim, registre por que ela chamou você. O objetivo é consolidar o que foi vivido e abrir espaço para o herbário seguir crescendo estação após estação.',
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
            'A ética wiccana cabe numa frase conhecida como a Rede: faz o que quiseres, desde que não prejudiques ninguém. Ela importa porque é a bússola que orienta toda a prática — antes de qualquer feitiço, vela ou altar, vem a pergunta sobre quem a sua ação alcança. E há um detalhe que muita gente esquece: ninguém inclui você mesma. Cuidar de si já é praticar a Rede.\n\nDa Rede deriva a reflexão do retorno, que muitas tradições chamam de Lei Tríplice: a energia que você põe em movimento volta para você, em qualidade mais do que em aritmética exata. A frase se popularizou com a Wicca moderna, difundida a partir de Gerald Gardner e Doreen Valiente, e cada tradição a interpreta a seu modo — algumas como lei espiritual, outras como convite à responsabilidade. Não existe dogma único aqui: existe um princípio vivo.\n\nNo cotidiano, a Rede aparece nas escolhas pequenas: o que você fala de alguém, o feitiço que pensa em fazer, o limite que aceita ultrapassar contra si mesma. Antes de agir, uma bruxa iniciante pode se perguntar: isso prejudica alguém, inclusive a mim? Um erro comum é usar a Rede como tribunal para se culpar por tudo. Ela é treino de consciência, não vara de castigo.\n\nGuarde esta ideia: liberdade e responsabilidade caminham juntas. Você é livre para desejar, criar e agir — e é justamente essa liberdade que pede cuidado com cada fio da teia que liga você aos outros e a si mesma. Sua ética é a primeira página do seu caminho, e ela se escreve todos os dias.',
        practice:
            'O que fazer: revisitar com honestidade uma situação difícil recente. Como: primeiro, lembre a cena sem julgamento; depois, pergunte a si mesma como a Rede teria orientado sua ação, incluindo o cuidado com você; por fim, anote na sua página o que faria igual e o que faria diferente. O objetivo é treinar a consciência ética antes da próxima escolha real — isto é treino, não tribunal.',
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
            'A Wicca clássica honra o divino em dualidade: a Deusa e o Deus, dois rostos complementares do mesmo sagrado. A Deusa Tripla se revela como Donzela, Mãe e Anciã, espelhando os ciclos da lua; o Deus Cornífero é o sol e a natureza selvagem que nasce, amadurece e morre com as estações. Essa dualidade importa porque dá imagem e ritmo àquilo que, sem ela, ficaria abstrato demais.\n\nNa Wicca difundida por Gerald Gardner, Deusa e Deus dançam ao longo da Roda do Ano: ele nasce no solstício de inverno, cresce, une-se à Deusa e declina, enquanto ela permanece, mudando de face. Correntes atuais flexibilizam essa visão — há quem cultue apenas a Deusa, quem honre múltiplas divindades e quem veja um sagrado sem gênero. O essencial, comum a quase todas as tradições, é a imanência: o divino está NA natureza, não fora dela.\n\nNo dia a dia, essa relação começa pequena: notar a fase da lua ao voltar para casa, cumprimentar o sol da manhã, acender uma vela prateada para a Deusa ou dourada para o Deus. Uma iniciante não precisa sentir nada grandioso — o erro comum é forçar experiências místicas ou copiar a devoção alheia. Observe o que toca você de verdade e comece por esse ponto.\n\nLeve consigo esta chave: o sagrado não mora longe. Ele encontra você na lua que muda, no sol que retorna, no mato que insiste em nascer na calçada. Qualquer que seja o rosto que o divino tenha para você, a Wicca convida a reconhecê-lo perto — e a deixar que essa proximidade transforme o seu olhar.',
        practice:
            'O que fazer: um exercício de contemplação devocional de cinco minutos. Como: vá para o ar livre ou fique à janela, escolha algo vivo da natureza — uma árvore, o céu, a lua — e observe em silêncio, como quem contempla um rosto do divino, sem pedir nada e sem pressa. Depois, registre na sua página o que sentiu. O objetivo é exercitar a percepção do sagrado imanente, aquele que não exige templo: apenas presença.',
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
            'O altar wiccano é o cosmos organizado numa mesa: um ponto de encontro entre você e as forças com que trabalha. Nele vivem os quatro elementos — o pentáculo ou o sal para a Terra, o incenso para o Ar, a vela para o Fogo, a taça para a Água — além de símbolos da Deusa e do Deus. Ele importa porque dá ao invisível um endereço concreto dentro da sua casa.\n\nNa tradição que se difundiu a partir de Gardner, cada ferramenta tem função: o athame ou a varinha conduzem a vontade, o cálice recebe, o pentáculo consagra. Símbolos comuns da dualidade divina são uma vela prateada e outra dourada, uma concha e um chifre, ou duas imagens. Mas as tradições variam bastante — existem altares fixos, altares sazonais que mudam a cada sabá e altares mínimos guardados numa caixa. Todos são legítimos.\n\nPara a iniciante, o recado é: comece simples. Uma vela, um copo com água, uma pedra e uma pena já formam um altar completo. O erro mais comum é adiar a prática esperando comprar ferramentas perfeitas — o altar cresce COM a prática, não antes dela. Cuide dele como cuida de uma planta: limpe, renove a água, troque o que perdeu sentido. A aba Altar da Enciclopédia traz mais ideias.\n\nGuarde esta ideia: o altar não é vitrine, é relação. Vale mais uma mesa humilde visitada todos os dias do que um conjunto luxuoso coberto de poeira. Onde você põe atenção e carinho, o sagrado encontra morada. Monte o seu com o que tem hoje e deixe que ele cresça junto com você.',
        practice:
            'O que fazer: montar seu primeiro altar mínimo, ainda que provisório. Como: escolha um cantinho tranquilo, limpe a superfície e disponha quatro objetos, um para cada elemento — por exemplo, uma pedra ou sal para a Terra, uma pena ou incenso para o Ar, uma vela para o Fogo e um copo com água para a Água. Fique um instante diante dele em silêncio. O objetivo é criar um ponto físico de encontro com o sagrado, que crescerá junto com a sua prática.',
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
            'Chamar os Quadrantes é convidar os guardiões das quatro direções para sustentar o círculo ritual: o Leste ligado ao Ar, o Norte ou o Sul ligado ao Fogo conforme o hemisfério, o Oeste ligado à Água e a direção restante ligada à Terra. A prática importa porque firma o círculo como espaço vivo, cercado de presenças aliadas, e ancora o rito nos quatro elementos.\n\nNa estrutura ritual herdada da Wicca gardneriana, as chamadas acontecem depois do traçado do círculo, geralmente começando pelo Leste e seguindo o giro do sol. Cada chamada é um convite respeitoso, nunca uma ordem: os guardiões — vistos por algumas tradições como espíritos elementais, por outras como aspectos da própria psique — são recebidos como convidados de honra. Ao final do rito, libera-se na ordem inversa, sempre agradecendo.\n\nNo começo, é comum travar na hora de falar em voz alta ou esquecer a ordem. Vá com calma: palavras simples e sinceras valem mais do que versos decorados. Um erro frequente é copiar correspondências do hemisfério norte sem refletir — no hemisfério sul, muitas bruxas ajustam as direções às estações e aos ventos reais. Escolha a sua lógica, registre-a e seja coerente com ela.\n\nLeve consigo: um convite não é uma ordem. A força dessa prática está na cortesia — você chama, acolhe, trabalha e agradece. Comece pequeno e repita: a familiaridade transforma gesto em rito. Quem aprende a abrir e fechar as portas com respeito descobre que o círculo se torna, cada vez mais, um lar.',
        practice:
            'O que fazer: sua primeira chamada dos quadrantes. Como: fique de pé, vire-se para cada direção — na ordem que fizer sentido no seu hemisfério — e diga um convite simples, como: guardiões desta direção, elemento correspondente, sejam bem-vindos ao meu círculo. Ao terminar o momento, agradeça a cada direção na ordem inversa. O objetivo é experimentar no corpo o gesto de abrir e fechar um espaço ritual com respeito e presença.',
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
            'A Roda do Ano é o calendário sagrado da Wicca: o tempo vivido como círculo, não como linha reta. São oito sabás — os dois solstícios, os dois equinócios e os quatro festivais do fogo: Samhain, Imbolc, Beltane e Lughnasadh. Celebrá-los importa porque reconecta a sua vida ao ritmo real da terra: plantar, florescer, colher e repousar deixam de ser metáforas e viram experiência.\n\nNa narrativa wiccana clássica, a Roda conta a história da Deusa e do Deus através das estações: o Deus nasce no solstício de inverno, cresce, une-se à Deusa em Beltane, entrega-se na colheita e retorna ao ventre da Anciã em Samhain, quando se honram os ancestrais. Cada sabá espelha um momento interno: honrar quem veio antes, renascer, florescer, agradecer a colheita. Tradições diferentes contam essa história com variações — e todas são válidas.\n\nNo hemisfério sul, muitas bruxas invertem as datas para acompanhar as estações reais — celebrando Samhain em maio, por exemplo — enquanto outras mantêm o calendário do norte. Não existe resposta única: escolha a sua coerência e registre-a. O erro comum da iniciante é querer rituais grandiosos em todos os sabás; comece com celebrações de dez minutos, sinceras e simples.\n\nLeve consigo: a Roda gira sem pressa, e você gira com ela. Cada estação da terra encontra uma estação dentro de você. Celebrar os sabás é apenas isso: marcar encontros regulares com o próprio ciclo. Quando a vida parecer parada, lembre: nenhum inverno é definitivo — a Roda sempre volta a girar para a luz.',
        practice:
            'O que fazer: planejar sua primeira celebração sazonal. Como: consulte a Roda do Ano do app e descubra qual é o próximo sabá no seu hemisfério; leia sobre o que ele celebra; depois desenhe uma celebração de dez minutos — pode ser acender uma vela, preparar um alimento da estação ou escrever uma intenção. Anote o plano na sua página e realize na data. O objetivo é sair da teoria e viver a Roda no seu próprio ritmo.',
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
            'Se os sabás celebram a jornada do sol, os esbás honram a lua — em especial a lua cheia, hora clássica do trabalho mágico na Wicca. O esbá é o encontro regular da bruxa com a Deusa em seu rosto lunar: um momento de recarga, magia e escuta. Ele importa porque cria ritmo: enquanto os sabás chegam a cada seis ou sete semanas, a lua cheia visita você todos os meses.\n\nNos covens tradicionais, o esbá é a reunião de trabalho: é quando se faz magia, adivinhação e cura, sob a lua cheia que amplifica as marés sutis. Um roteiro clássico para a bruxa solitária: banho de preparação, traçado do círculo, saudação à Deusa, o gesto de Puxar a Lua — receber a luz em silêncio, deixando que ela preencha o corpo —, o trabalho mágico ou oracular, a partilha de bolo e vinho e o encerramento com gratidão.\n\nNa vida real, nem toda lua cheia encontra você disposta — e tudo bem. Um esbá pode durar dez minutos: vela acesa, três respirações sob a lua, uma intenção. O erro comum é achar que só vale com o roteiro completo; a constância vale mais do que a pompa. E se o céu estiver nublado, a lua continua lá: trabalhe do mesmo jeito, confiando na maré invisível.\n\nLeve consigo: a lua é o lembrete mensal de que você também tem fases. Puxar a Lua é, no fundo, permitir-se receber — coisa rara numa vida de tanto fazer. Marque encontro com ela: a liturgia que você escrever na sua página será a sua primeira obra autoral neste caminho.',
        practice:
            'O que fazer: seu primeiro gesto de Puxar a Lua. Como: na próxima noite de lua visível, vá para fora ou fique à janela, respire fundo e passe três minutos sob a luz dela — sem pedir, sem falar, apenas recebendo, como quem toma um banho de prata. Depois, registre na sua página o que sentiu no corpo e no ânimo. O objetivo é treinar a arte de receber, que é o coração do esbá, antes de construir sua liturgia completa de lua cheia.',
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
            'O Livro das Sombras é o coração material da bruxa wiccana: o lugar onde vivem rituais, receitas, sonhos, fracassos e descobertas — tudo registrado, sem censura. Ele importa porque a memória falha e a prática evolui: o que você anota hoje vira o mapa que orientará a bruxa que você será daqui a alguns anos.\n\nNa tradição gardneriana, o Livro das Sombras era copiado à mão, da mestra para a iniciada, preservando os ritos do coven — e cada cópia ganhava as marcas de quem a escrevia. Hoje, com a força da bruxaria solitária, cada praticante inicia o seu do zero, e as tradições divergem sobre o formato: cadernos artesanais, arquivos digitais, caixas de fichas. O que permanece é o princípio: registrar é parte do rito, não burocracia depois dele.\n\nVocê já está escrevendo o seu: este app é ele. Cada página preenchida nas trilhas e no Meu Grimório é uma folha do seu Livro. No cotidiano, o hábito que sustenta tudo é simples: após cada ritual ou prática, anote data, o que fez, o que sentiu e o resultado. O erro comum é registrar apenas os sucessos — os fracassos ensinam mais e merecem página própria.\n\nLeve consigo: um Livro das Sombras não precisa ser bonito, precisa ser verdadeiro. Organize do seu jeito e deixe a estrutura crescer com o uso. Ele é o espelho da sua jornada e, um dia, poderá ser herança. Escreva como quem conversa com a bruxa do futuro — ela vai agradecer cada linha.',
        practice:
            'O que fazer: uma revisão editorial do seu próprio Livro. Como: percorra com calma as páginas que você já escreveu nas trilhas e no Meu Grimório; observe temas que se repetem, registros que funcionaram e lacunas; depois esboce, na página desta lição, as seções que fariam sentido para organizar tudo. O objetivo é descobrir a estrutura que já emerge naturalmente dos seus registros — e assumi-la como a ordem do seu Livro das Sombras.',
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
            'Invocar, na Wicca, é convidar o divino para perto — não baixar entidades nem dar ordens ao sagrado. É o gesto de abrir a porta de casa para uma visita querida: você chama, acolhe e convive. A invocação importa porque transforma a prática, que deixa de ser um conjunto de técnicas e vira uma relação viva com aquilo que você considera sagrado.\n\nA invocação tem três tempos. Primeiro, preparar-se: um banho, o traçado do círculo, alguns minutos de silêncio para chegar inteira. Depois, chamar: com palavras do coração, não fórmulas decoradas de outras pessoas — as tradições wiccanas guardam invocações célebres à Deusa na lua cheia, mas todas nasceram do mesmo lugar: alguém que falou com verdade. Por fim, ESCUTAR — o tempo mais esquecido de todos os três.\n\nNa prática da iniciante, o sinal de que a invocação funcionou raramente é espetacular: é um silêncio diferente, um calor no peito, uma certeza mansa. O erro mais comum é esperar fenômenos e desistir quando eles não vêm — ou falar tanto que não sobra espaço para resposta alguma. Reserve sempre ao menos dois minutos de escuta absoluta depois de chamar.\n\nLeve consigo: invocar é conversar, e toda conversa boa tem mais escuta do que fala. Chame o sagrado com suas próprias palavras, do seu jeito, e confie nos sinais discretos. A presença divina costuma chegar em voz baixa — aprenda, aos poucos, a ouvir baixinho também.',
        practice:
            'O que fazer: sua primeira invocação completa. Como: prepare-se com um banho ou alguns minutos de silêncio; no seu espaço, chame com palavras próprias a energia divina que mais toca você — Deusa, Deus ou o sagrado como o entende; depois permaneça dois minutos em escuta absoluta, sem esperar nada específico; encerre agradecendo. O objetivo é experimentar os três tempos do rito — preparar, chamar e escutar — e registrar os sinais sutis que aparecerem.',
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
            'O rito de bolo e vinho encerra os rituais wiccanos com um gesto de aterramento: depois de mover energia, o corpo pede chão — e comer e beber com bênção devolve você ao mundo. É a eucaristia da natureza: o sagrado que vira corpo. O rito importa porque ensina algo central na Wicca: matéria e espírito não são inimigos, e a mesa também é altar.\n\nNos covens tradicionais, o momento de cakes and wine sela o encontro: o alimento é abençoado — em algumas tradições, com o gesto simbólico do athame mergulhado no cálice, união do Deus e da Deusa —, a primeira porção é ofertada à terra e o restante é partilhado entre todos. A bruxa solitária adapta: a oferta pode ir ao jardim, ao vaso da janela ou ao pé de uma árvore. Sem vinho? Suco, chá ou água servem: a bênção está no gesto, não no cardápio.\n\nNo cotidiano, esse rito pode transbordar do círculo para a vida: abençoar o café da manhã, agradecer antes do almoço, fazer uma refeição por dia sem telas e com presença. O erro comum é tratar a etapa como lanche informal e pular a oferta — é justamente ofertar primeiro que transforma consumo em comunhão. Presença é o ingrediente que não pode faltar.\n\nLeve consigo: todo alimento é a terra chegando até você. Quando você abençoa, oferta e come com atenção, o ato mais banal do dia vira rito — e o sagrado deixa de ser evento raro para virar hábito que nutre, no sentido mais literal da palavra. Coma devagar: aterrar também é celebrar.',
        practice:
            'O que fazer: seu primeiro rito de bolo e vinho fora do círculo. Como: prepare um lanche simples e uma bebida — chá, suco ou água valem tanto quanto vinho; abençoe o alimento com palavras suas; separe uma primeira porção simbólica e oferte à terra, a um vaso ou junto a uma planta; então coma devagar, com total presença e sem telas. O objetivo é experimentar o aterramento pelo alimento e sentir a diferença entre comer no automático e comungar.',
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
            'A autoiniciação é o rito em que a bruxa solitária, sem coven, se compromete formalmente com o caminho — diante do sagrado como o entende. Não é diploma nem formatura: é um voto íntimo, feito de você para você, testemunhado por aquilo que você considera divino. Ela importa porque marca uma travessia: de curiosa a praticante, de quem estuda a quem assume o caminho.\n\nNas tradições iniciáticas, como a gardneriana, a iniciação é conferida pelo coven após o período clássico de um ano e um dia de estudo — e parte da comunidade wiccana entende que só ela transmite a linhagem. Outras correntes, sobretudo desde a difusão da prática solitária, defendem que a dedicação sincera diante dos deuses tem pleno valor. As duas visões convivem na Wicca de hoje; o seu caminho é seu para escolher, com respeito por ambas.\n\nNa prática, o rito costuma reunir tudo o que você aprendeu: banho, círculo, chamada dos quadrantes, invocação, o voto dito em voz alta, bolo e vinho, registro no Livro das Sombras. O erro comum é a pressa — dedicar-se na primeira semana de estudo — ou o oposto: adiar para sempre por não se sentir pronta. O tempo certo é o seu, mas existem sinais: constância na prática e clareza no desejo.\n\nLeve consigo: ninguém inicia você no seu próprio caminho — nem mesmo um coven o faria sem o seu sim interior. Esta última página é o rascunho do seu rito de dedicação. Escreva sem pressa, realize quando sentir que é hora e volte para registrar. A Roda continua girando, e agora você gira com ela, de mãos dadas com o que é sagrado para você.',
        practice:
            'O que fazer: escrever, só para você, o rascunho do seu compromisso. Como: em um momento tranquilo, responda por escrito o que significa comprometer-se com este caminho — o que promete a si mesma, o que deixa para trás, o que deseja cultivar; depois esboce o rito que fará um dia: local, elementos, palavras. Sem prazo e sem pressa. O objetivo é preparar o coração e o texto da sua futura autoiniciação, para realizá-la quando sentir que chegou a hora.',
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
            'A bruxaria tradicional é enraizada no lugar: rios, encruzilhadas, quintais, esquinas. Antes de qualquer ferramenta ou grimório, o primeiro passo é conhecer o chão que você pisa, porque a magia dessa vertente não vem de livros distantes — ela nasce da relação viva com o território. Cada terra tem seus espíritos, e a bruxa que os conhece pratica com raízes, não de empréstimo.\n\nQuase todo povo reconheceu espíritos do lugar: o folclore europeu fala de guardiões de fontes, bosques e colinas, e o Brasil é riquíssimo em encantados — a mãe do rio, o saci, o curupira, as almas das porteiras. Com eles se faz amizade como com gente: presença regular, pequenas oferendas respeitosas, escuta paciente. Por isso o folclore local é o mapa espiritual mais honesto que existe: ele conta quem já mora ali há muito tempo.\n\nNo dia a dia, isso vira caminhada atenta: notar a árvore mais antiga da rua, a esquina onde o ar muda, o terreno que pede silêncio. Comece pequeno — água limpa, uma flor, uma saudação em pensamento — e não exija nada em troca. O erro comum da iniciante é importar espíritos da moda e ignorar o próprio quintal; outro é retirar folhas e pedras sem pedir licença. Respeito abre mais portas que qualquer ritual elaborado.\n\nLeve consigo esta ideia: você não pratica sobre a terra, pratica com ela. A amizade com os espíritos do lugar se constrói como toda amizade — com presença constante e respeito verdadeiro. Conheça o seu chão, e o seu chão passará a te reconhecer. Esse é o alicerce de todo o caminho torto.',
        practice:
            'Caminhe 15 minutos pelo bairro como bruxa: saia sem pressa e sem fones, observando onde a energia muda, que lugar te chama e que histórias os antigos contam sobre a região. Ao voltar, anote na sua página os pontos que se destacaram e pense na primeira oferenda respeitosa que gostaria de deixar. O objetivo é começar o mapa espiritual do seu território e abrir, com presença e escuta, a relação com os espíritos do lugar.',
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
            'Na bruxaria tradicional, os mortos não estão longe: os ancestrais são aliados de primeira hora, presentes no cotidiano de quem os honra. Eles formam três correntes — os de sangue, da sua família; os de afeto, que você amou sem parentesco; e os de ofício, as bruxas e benzedeiras que vieram antes. Honrá-los importa porque ninguém caminha sozinha: toda prática se apoia em quem abriu a trilha primeiro.\n\nO culto aos ancestrais atravessa quase todas as culturas: mesas postas para os mortos no folclore europeu, o dia de finados, as benzedeiras brasileiras que pedem licença aos antigos antes de rezar. O altar tradicional é simples: uma superfície limpa, um copo de água, uma vela, uma foto ou objeto de quem partiu. A água se renova, a vela se acende, e a conversa acontece como com alguém querido que apenas mudou de sala.\n\nNa prática, escolha um cantinho tranquilo da casa e cuide dele com constância: renove a água num dia fixo, fale com naturalidade, agradeça antes de pedir. Um erro comum é tratar o altar como balcão de pedidos; outro é achar que só vale quem você conheceu em vida — a linhagem de afeto e de ofício também conta. E lembre: você escolhe quem honra. Só convide para o seu altar quem traz paz ao seu coração.\n\nGuarde esta chave: lembrar é manter vivo. Você é a continuação de muitas mãos, muitas rezas e muitos nomes, e o copo de água renovado toda semana vale mais que o ritual grandioso feito uma vez só. A devoção ancestral é feita de constância pequena, presença sincera e carinho verdadeiro.',
        practice:
            'Acenda uma vela por seus ancestrais num momento calmo. Diante da chama, diga em voz baixa que você se lembra deles, que agradece pelo que recebeu e que os convida a seguirem com você no caminho. Depois, monte ou renove o cantinho com o copo de água e um objeto ou foto de quem você honra. O objetivo é iniciar o vínculo vivo com a sua linhagem e transformar a lembrança em devoção diária e afetuosa.',
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
            'A bruxa tradicional não espera a loja esotérica: a vassoura varre energia, a tesoura corta laços, a agulha costura destinos, a colher de pau mexe intenções. O poder não está no preço nem no brilho do objeto, mas no uso consciente que você faz dele. Essa é uma das marcas mais antigas da bruxaria popular — trabalhar com o que a casa já oferece, transformando o comum em sagrado.\n\nO folclore confirma essa herança: a ferradura de ferro sobre a porta, a tesoura aberta atrás dela, a faca que corta o ar carregado, a peneira e a chave usadas em adivinhações antigas. Objetos comuns viram guardiões porque carregam história de uso e proximidade com a vida. Consagrar segue uma lógica simples: limpar o objeto, declarar em voz alta o novo papel dele e usá-lo somente para isso — a exclusividade é o que carrega o poder.\n\nNo cotidiano, isso significa olhar a própria casa com olhos de bruxa antes de comprar qualquer coisa. O erro comum da iniciante é consagrar dez objetos de uma vez e não usar nenhum, ou misturar a ferramenta ritual com a função comum — a vassoura consagrada não toca o lixo físico. Comece com um único objeto, limpe com sal ou fumaça, dê a ele um papel claro e guarde com respeito, separado dos demais.\n\nA ideia para memorizar: a magia mora na relação, não no objeto. Uma colher consagrada com verdade vale mais que um punhal caro sem história nenhuma. Sua casa já é um pequeno arsenal mágico esperando o seu olhar — desperte uma ferramenta de cada vez, com calma, uso constante e intenção clara.',
        practice:
            'Percorra a casa com calma e escolha UM objeto para consagrar como sua primeira ferramenta. Segure os candidatos nas mãos e perceba qual deles parece aceitar o trabalho — costuma haver um que se destaca. Depois limpe o escolhido com sal ou fumaça, declare em voz alta a nova função dele e guarde-o separado, só para esse uso. O objetivo é iniciar seu conjunto de ferramentas consagradas e treinar a escuta dos objetos.',
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
            'Em quase toda tradição, a encruzilhada é lugar de poder: onde os caminhos se cruzam, os mundos também se tocam. Ali a estrada comum vira portal — ponto de decisões, passagens e possibilidades abertas. Para a bruxaria tradicional, conhecer a encruzilhada importa porque ela ensina o essencial do caminho torto: toda escolha abre uma direção e fecha outra, e há forças que guardam essas passagens.\n\nO folclore é unânime: na Grécia antiga, Hécate recebia oferendas nos cruzamentos; na Europa, os trívios eram pontos de encontros, juramentos e assombros; no Brasil, as tradições de matriz africana honram nas encruzilhadas os guardiões dos caminhos, com fundamentos profundos e próprios. Ali tradicionalmente se deixam trabalhos, se fazem pedidos de abertura e se agradece a quem guarda as passagens — sempre com licença e reverência.\n\nPara a iniciante, a regra de ouro é o respeito: encruzilhada não é lixeira ritual. Se deixar oferenda, que seja biodegradável, discreta e em local seguro; jamais recolha o que outros deixaram, e não copie rituais de tradições que você não conhece por dentro. No cotidiano, basta atravessar com consciência: um cumprimento silencioso, feito de coração, já é reconhecimento de quem guarda o ponto.\n\nLeve esta imagem: a vida inteira é feita de encruzilhadas, e a bruxa não teme os cruzamentos — ela os saúda. Peça caminhos abertos, agradeça as passagens e siga andando com confiança. Quem respeita o ponto onde os mundos se tocam aprende, aos poucos, a atravessar as próprias escolhas.',
        practice:
            'Passe por uma encruzilhada do seu trajeto com plena consciência: pare um instante em local seguro, respire fundo, cumprimente em silêncio quem guarda as passagens e faça um pedido calado de caminhos abertos para a sua vida. Depois siga adiante sem ansiedade, observando o que o dia responde. O objetivo é reconhecer pontos de poder no percurso comum e treinar a reverência simples do caminho torto.',
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
            'As benzedeiras são a bruxaria tradicional viva do Brasil: mulheres e homens que curam com palavra, ramo e fé, de porta aberta, sem cobrar nada. O benzimento importa porque é a linhagem mágica mais próxima de você — talvez exista na sua própria família — e prova que a palavra dita com intenção é uma das ferramentas de cura mais antigas e poderosas do mundo.\n\nA estrutura do benzimento é poesia funcional: primeiro nomeia o mal — quebranto, mau-olhado, espinhela caída —, depois invoca a força maior, manda o mal para longe, para as ondas do mar ou para os confins, e por fim sela o trabalho. O ramo verde, de arruda ou guiné, participa: quando murcha, diz a tradição, é porque levou o que tirou. Essa herança mistura rezas ibéricas, saberes indígenas e africanos numa medicina feita de palavra.\n\nNo seu cotidiano, comece pela pesquisa: avós, vizinhas e registros locais guardam versões preciosas. Use o que aprender para autocuidado — benzer a própria água, o próprio sono — e evite dois erros comuns: tratar a reza como fórmula vazia, sem fé nem presença, e apresentar-se como benzedeira sem ter recebido o ofício. O dom tradicional se recebe e se cultiva; o respeito por quem o guarda faz parte da prática.\n\nFique com esta chave: a palavra dita com fé é remédio antigo. Honre a fonte de cada reza que aprender, pronuncie com o coração presente, e você estará mantendo viva uma das correntes mais bonitas da tradição brasileira — a que cura de graça, na soleira da porta, com um ramo verde na mão.',
        practice:
            'Pesquise UM benzimento tradicional da sua região: pergunte a avós e vizinhas ou busque em registros de folclore local. Copie a reza na sua página como relíquia, anotando quem ensinou ou onde você a encontrou. Depois, crie uma versão simples para autocuidado e experimente com um ramo verde, como arruda ou guiné. O objetivo é honrar a linhagem das benzedeiras e guardar a sua primeira palavra de cura.',
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
            'A vassoura da bruxa não voa — varre mundos. Na bruxaria tradicional, varrer nunca foi só limpeza: é rito de proteção e renovação escondido no gesto mais comum da casa. A direção importa: varrer da porta para dentro puxa a sorte para o lar; varrer para fora expulsa o que está denso e pesado. O instrumento mais banal do lar é também um dos mais antigos da magia popular.\n\nO folclore guarda camadas: a vassoura atrás da porta espanta visita indesejada, diz a crença popular brasileira; na Europa, saltar a vassoura selava uniões e varrer a soleira protegia o limiar da casa. A vassoura ritual é aquela que não toca lixo físico — vive deitada atrás da porta ou pendurada na parede, guardando a entrada. E o quintal varrido de manhã era a proteção diária das antigas: o rito disfarçado de rotina.\n\nNa prática, você pode ter uma vassoura só para o rito ou ritualizar a varrida comum: o que muda é a intenção. Ao varrer para fora, nomeie o que sai junto com o pó — cansaço, brigas, peso; ao terminar, chame o que entra no espaço limpo. Erros comuns: varrer com raiva, espalhando o denso em vez de conduzi-lo para fora, e deixar a vassoura ritual virar objeto de limpeza qualquer. Varra devagar, como quem reza.\n\nLeve consigo: o rito mora escondido no gesto comum. Sua casa varrida com intenção é seu primeiro círculo de proteção, refeito todos os dias sem que ninguém perceba. Onde a vassoura passa com consciência, o denso não se acomoda. Essa é a magia das antigas: simples, diária e poderosa.',
        practice:
            'Varra um cômodo hoje como rito completo: comece varrendo em direção à porta e para fora, nomeando em voz baixa o que sai junto com o pó — cansaço, discussões, peso acumulado. Depois, da porta para dentro, chame o que deseja para o espaço limpo: sorte, calma, proteção. Termine agradecendo à casa. O objetivo é transformar a limpeza comum em rito de proteção e sentir na prática o poder do gesto simples.',
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
            'A witch bottle, ou garrafa de bruxa, é uma proteção tradicional com séculos de história: um vidro preenchido com itens cortantes simbólicos, elementos protetores e algo seu, selado e escondido na casa. Ela funciona como guardiã silenciosa — absorve e prende o mal dirigido a você antes que ele te alcance. É a defesa clássica da bruxaria popular: discreta, duradoura e feita em casa.\n\nGarrafas assim são encontradas por arqueólogos sob lareiras e soleiras inglesas desde o século XVII, cheias de pregos, alfinetes e itens pessoais de quem protegiam. A lógica tradicional é o engodo: contendo algo seu, a garrafa se passa por você; o mal a encontra primeiro, fica preso nos elementos cortantes e é neutralizado pelos protetores. A versão moderna usa vidro pequeno, sal, alecrim ou arruda, um fio de cabelo e cera de vela para selar.\n\nNa prática, monte a sua num momento tranquilo, com intenção clara, e esconda em ponto discreto: fundo de armário, canto alto, jardim. Depois de selada, não se abre — se um dia sentir que ela cumpriu o trabalho, agradeça e descarte com respeito, montando outra. O erro comum é exibir a garrafa ou contar onde está: proteção escondida trabalha melhor. Outro é usar itens perigosos sem cuidado; o símbolo basta.\n\nGuarde esta ideia: nem toda defesa precisa ser visível. A garrafa ensina a magia da discrição — proteção que trabalha em silêncio, dia e noite, sem pedir atenção nem manutenção constante. Monte a sua com calma e deixe a guardiã cuidar do que não deve chegar até você. Casa protegida é casa que dorme em paz.',
        practice:
            'Reúna com calma os materiais da sua garrafa de proteção: um vidro pequeno com tampa, sal, ervas protetoras como arruda ou alecrim, um fio do seu cabelo e uma vela para selar com cera. Guarde tudo junto e monte quando se sentir pronta, num momento tranquilo, colocando cada item com intenção e selando com palavras suas. O objetivo é criar a guardiã silenciosa da casa e escondê-la num ponto discreto.',
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
            'O caminho torto escuta o mundo: sonhos que insistem, bichos que cruzam a estrada, objetos que caem sozinhos, nomes ouvidos três vezes no mesmo dia. Isso não é paranoia — é atenção poética, uma forma antiga de perceber que a vida fala por padrões e imagens. Para a bruxaria tradicional, o mundo está sempre em conversa; a bruxa é quem decide escutar com cuidado.\n\nOs presságios atravessam o folclore: a coruja no telhado, a borboleta que entra em casa, o sonho com dente, a visita anunciada pelo talher que cai. O método tradicional é registrar sem interpretar na hora — o significado amadurece com o tempo, e os padrões só aparecem para quem acumula registros. Sonhos são a parte mais rica dessa escuta: o Diário de Sonhos e os Significados dos Sonhos do app são seus aliados nesse trabalho.\n\nNa prática, mantenha um caderno de sinais: anote data, contexto e o que aconteceu, sem julgar se é importante. Releia uma vez por semana procurando repetições. Os erros comuns da iniciante são dois opostos: transformar tudo em presságio e viver ansiosa, ou decidir a vida inteira por um sinal isolado. O equilíbrio é registrar muito, concluir devagar e deixar o padrão se mostrar sozinho.\n\nA chave para levar: o mundo fala baixinho, e quem anota aprende o idioma. Um sinal é curiosidade; três sinais repetidos são conversa. Registre sem pressa, releia com atenção, e a escuta torta vai se tornando a sua segunda natureza — o radar silencioso da bruxa no meio do cotidiano comum.',
        practice:
            'Hoje, anote três coincidências ou sinais do dia — um bicho que cruzou seu caminho, uma frase ouvida na hora exata, um objeto que caiu do nada. Registre apenas o fato, a data e o contexto, sem interpretar nada agora. Guarde as anotações e releia tudo daqui a uma semana, procurando repetições e ligações. O objetivo é treinar a escuta dos presságios e descobrir como os padrões falam com o tempo.',
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
            'A bruxaria tradicional não pede conversão — pede coerência. O pacto verdadeiro do caminho torto não é com entidade nenhuma: é consigo mesma. Significa praticar o que funciona, honrar o que sustenta e abandonar sem culpa o que é só enfeite. Essa honestidade importa porque um caminho sem dogma só se sustenta pelo compromisso real e cotidiano de quem o percorre.\n\nO pacto com o diabo dos julgamentos de bruxas era caricatura criada pelos acusadores — no folclore vivo, o compromisso sempre foi com o ofício. A benzedeira mantém o dom pelo uso: se para de benzer, a reza esfria. O saber tradicional se sustenta na prática constante, não em juramentos solenes. Por isso o caminho torto valoriza o que se faz de verdade: três práticas vividas valem mais que trinta ideias bonitas guardadas na gaveta.\n\nNa sua rotina, isso pede revisão honesta de tempos em tempos: o que das trilhas virou hábito real? O que você só admirou e nunca fez? O erro comum é acumular rituais de estante — práticas que existem apenas no caderno — e carregar culpa por não dar conta de tudo. A bruxa tradicional simplifica: escolhe as práticas inegociáveis, faz bem feito e deixa o resto ir embora sem drama.\n\nLeve esta síntese: sem dogma, com raiz. Seu caminho vale pelo que você realmente vive, não pelo que acumula em teoria. Firme o pacto consigo — poucas práticas, verdadeiras e sustentadas — e o caminho torto se torna inabalável, porque estará plantado em chão real, regado todos os dias.',
        practice:
            'Releia com calma as páginas que você criou nesta trilha, uma a uma. Separe mentalmente em dois grupos: o que já virou prática real na sua rotina e o que ficou apenas bonito no papel. Depois registre suas práticas inegociáveis, o que abandona sem culpa e com o que se compromete neste ciclo. O objetivo é firmar seu pacto de praticante: um acordo honesto consigo mesma, sem dogma e com raiz.',
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
            'Todo saber tradicional sobrevive por transmissão: a avó que benze e ensina a reza, a vizinha que passa o chá certo, a mão que guia outra mão. Sem essa corrente, ofícios inteiros morrem com quem os guardava. Ao chegar até aqui, você se tornou elo dessa corrente — guardiã do que aprendeu e, um dia, ponte para alguém que ainda nem sabe que vai precisar de você.\n\nA transmissão tradicional tem seus modos: é oral, próxima e escolhida. A benzedeira não ensina qualquer um — observa, espera maturidade e, em algumas regiões, só passa a reza em datas especiais, como a sexta-feira santa. O gesto se aprende olhando, a receita vai de mão em mão, e o caderno da família atravessa gerações. É assim que um saber vence o tempo: uma pessoa confiando em outra, um elo de cada vez.\n\nNo seu cotidiano, transmitir começa por guardar bem: escreva suas páginas como quem deixa herança, com clareza, citando de quem aprendeu cada coisa. Quando alguém pedir com respeito, ensine o simples primeiro. Os erros comuns são os extremos: guardar tudo por avareza, até o saber morrer com você, ou espalhar sem cuidado o que foi confiado com pedido de discrição e reserva.\n\nFique com esta imagem: você é ponte entre quem veio antes e quem ainda virá. Cada página escrita com verdade é uma semente da corrente. Guarde com zelo, passe adiante com generosidade — e o seu caminho torto seguirá vivo muito além de você, como todo saber que foi amado e bem cuidado.',
        practice:
            'Pense em uma pessoa, real ou futura, a quem você confiaria seus saberes — pode ser alguém da família, uma amiga ou alguém que ainda vai chegar. Liste o que ensinaria primeiro e por quê, e registre na página os três saberes que passaria adiante, junto com o conselho que daria a quem começa. O objetivo é transformar o que você aprendeu em legado e assumir seu lugar na corrente da transmissão.',
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

  // ═════════════ MAGIA NEGRA ═════════════
  LearningTrail(
    id: 'magia_negra',
    emoji: '🌑',
    title: 'Magia Negra',
    subtitle: 'Sombra, corte e poder consciente',
    description:
        'Desfazer os mitos e atravessar o escuro com responsabilidade: trabalho de sombra, banimentos, cortes e proteções — o poder que nasce quando você olha para o que a maioria evita.',
    lessons: [
      TrailLesson(
        id: 'mn_01',
        recordKind: LessonRecordKind.note,
        title: 'O que a magia negra é (e o que nunca foi)',
        teaching:
            'Magia negra, nesta trilha, é o nome que damos ao trabalho consciente com a sombra: banir o que adoece, defender o próprio campo, cortar o que drena e assumir poder com ética. Não é receita para prejudicar ninguém — é o lado da bruxaria que olha o escuro de frente. Entender o que esse termo é, e o que nunca foi, é o primeiro passo para praticar sem medo e sem irresponsabilidade.\n\nO rótulo de magia negra carrega uma história pesada: foi usado para demonizar religiões afro-diaspóricas, benzedeiras e saberes populares, associando o escuro ao mal por puro preconceito e racismo. O folclore e o cinema exageraram o resto, criando a caricatura da maldição e do pacto sombrio. A prática moderna desfaz essa confusão: escuro não é sinônimo de maldade, assim como a noite não é inimiga do dia.\n\nNo começo, é comum chegar a este tema com medo ou com fascínio demais — os dois desequilibram. O erro clássico é buscar feitiços contra alguém que machucou você: além de eticamente errado, isso prende sua energia justamente a quem você quer distância. A dica é firmar limites antes de qualquer prática: escreva o que você nunca fará, e por quê. Ética definida com clareza é a maior proteção que existe.\n\nLeve consigo: o escuro é parte natural do caminho, e quem o percorre com responsabilidade encontra ali força, não perigo. Você não precisa temer esta trilha nem provar coragem a ninguém. Seu pacto é com você mesma — e é ele que transforma poder em maturidade. A bruxa que conhece seus limites pode ir muito mais fundo do que aquela que finge não os ter.',
        practice:
            'Você vai escrever seu Pacto de Responsabilidade. Primeiro, reflita com honestidade sobre o que te trouxe até esta trilha. Depois, escreva na sua página os limites que assume: o que você nunca fará com a própria magia e os valores que guiarão cada prática. Por fim, leia o pacto em voz alta, como quem assina um compromisso consigo. O objetivo é firmar a base ética que protegerá você em todo o caminho da sombra.',
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
            'A sombra é tudo aquilo que você escondeu de si para ser aceita: raiva engolida, desejos negados, talentos que pareciam perigosos demais. Na chave mística, ela é o porão da alma — e todo porão guarda tanto entulho quanto tesouro. Trabalhar a sombra importa porque o que você não olha não desaparece: apenas passa a agir no escuro, sem a sua permissão.\n\nA psicologia de Jung deu nome ao que as bruxas sempre souberam: o que reprimimos não morre, projeta-se. É por isso que certos defeitos alheios irritam tanto — costumam ser espelhos de algo nosso. Nos contos antigos, o monstro da floresta quase sempre guarda um tesouro ou vira aliado quando é encarado de frente: o folclore já ensinava que o escuro esconde poder, e não apenas perigo.\n\nNa prática, o trabalho de sombra começa pequeno: notar as irritações desproporcionais, os ciúmes que envergonham, os elogios que você rejeita. O erro comum é transformar isso em autopunição — sombra não se espanca, se escuta. Outro é querer iluminar tudo de uma vez. Vá aos poucos, com curiosidade e sem julgamento, como quem explora uma casa antiga com uma vela na mão.\n\nLeve consigo: sua sombra não é sua inimiga — é a parte de você que esperou anos por atenção. Cada pedaço escutado devolve energia que estava presa em esconder. A bruxa que conhece a própria sombra não fica mais sombria: fica mais inteira, mais honesta e muito mais difícil de manipular. O mapa começa hoje, e quem segura a lanterna é você.',
        practice:
            'Você vai desenhar o primeiro Mapa da sua Sombra. Primeiro, liste três comportamentos alheios que te irritam de forma desproporcional. Depois, pergunte a si mesma, com honestidade e sem julgamento, o que cada um pode espelhar em você — memórias e vergonhas que surgirem são pistas valiosas. Por fim, registre na página os aspectos de sombra que reconheceu. O objetivo é iniciar o encontro consciente com o que você esconde de si.',
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
            'Banir é o gesto mágico de dizer basta: retirar do seu campo um hábito, uma energia ou uma situação que adoece. É a faxina profunda da bruxaria — antes de atrair qualquer coisa boa, é preciso abrir espaço. Nesta trilha, o banimento nunca mira pessoas para causar dano: o alvo é sempre o padrão, o vício, o peso. Você bane o que te prende, não quem te cerca.\n\nO banimento é das práticas mais antigas do mundo: sal nos cantos da casa, vassoura varrendo para fora, fumaça de ervas amargas, água levando embora o que não serve. A lógica tradicional segue a lua minguante: assim como ela diminui no céu, diminui o que foi banido. Escrever o que se quer remover e destruir o papel com segurança é a forma clássica — o fogo e a água sempre foram os grandes dissolventes da magia popular.\n\nPara a iniciante, a chave é escolher um alvo concreto e justo: um hábito que drena, uma energia pesada num cômodo, um ciclo que se repete. O erro comum é banir vagamente — tudo de ruim da minha vida — e não sentir efeito, ou disfarçar de banimento um ataque a alguém. Outro é banir e continuar alimentando o padrão no dia seguinte: o feitiço abre a porta, mas quem atravessa é você.\n\nLeve consigo: banir é um ato de amor-próprio com cara de coragem. Cada coisa que você remove conscientemente devolve espaço para o que merece crescer. Este é seu primeiro feitiço da trilha — simples, honesto e poderoso na medida do seu compromisso. O poder não está no papel queimado: está na decisão que você sustenta depois dele.',
        practice:
            'Você vai realizar seu primeiro banimento. Primeiro, escolha um alvo justo: um hábito, uma energia ou uma situação — nunca uma pessoa. Depois, escreva-o num papel, acenda uma vela em local seguro e queime o papel declarando que aquilo não tem mais lugar na sua vida; descarte as cinzas fora de casa. Por fim, registre tudo na página do grimório. O objetivo é abrir espaço, retirando conscientemente o que adoece.',
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
            'Defesa mágica é higiene, não paranoia: assim como você tranca a porta sem viver com medo, o escudo energético protege seu campo sem transformar o mundo em ameaça. Escudos filtram o que vem de fora; espelhos devolvem à origem o que foi enviado, sem que você precise revidar. Saber se proteger é o que permite trabalhar a sombra com tranquilidade e seguir aberta à vida.\n\nO folclore está cheio de defesas: ferro na porta, olho grego contra inveja, arruda na entrada, espelhinhos que confundem e devolvem o mau-olhado. A ideia do espelho é elegante: você não ataca ninguém, apenas deixa de absorver — o que vem, volta para quem mandou, e a responsabilidade é de quem enviou. A visualização moderna herda isso: imaginar-se dentro de uma esfera espelhada é técnica simples e antiga ao mesmo tempo.\n\nNo cotidiano, o escudo se constrói pela manhã em um minuto: respire, visualize a esfera de luz espelhada ao redor do corpo e firme a intenção. O erro comum é blindar-se tanto que nada entra — nem o bom; escudo é filtro, não muralha de isolamento. Outro é lembrar da proteção só na crise. Constância vale mais que intensidade: um amuleto simples renovado com carinho protege mais que rituais grandiosos esquecidos.\n\nLeve consigo: você tem o direito de não absorver o que não é seu. Proteger-se não é agressão nem desconfiança do mundo — é respeito pelo próprio campo. Com o escudo espelhado, você caminha mais leve, sabendo que o que não te pertence encontra sozinho o caminho de volta. Segurança energética é a base silenciosa de toda a magia que vem depois.',
        practice:
            'Você vai erguer seu Escudo Espelhado. Primeiro, sente-se em silêncio, respire fundo três vezes e sinta os pés firmes no chão. Depois, visualize uma esfera de luz ao seu redor cuja face externa é um espelho: o que é bom atravessa, o que pesa é devolvido à origem; sustente a imagem por alguns minutos e, se quiser, consagre um objeto pequeno como amuleto. Por fim, registre a experiência na página. O objetivo é criar uma proteção diária que filtra sem isolar.',
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
            'Entre você e cada pessoa da sua vida existem laços invisíveis — cordas de afeto, de história, de energia. Alguns nutrem; outros drenam, prendem a relações encerradas ou tornam o convívio um cabo de guerra. O corte de laços é o ritual que devolve a cada um a própria energia. Cortar não é atacar nem apagar alguém: é encerrar um contrato energético que já venceu.\n\nTradições do mundo inteiro conhecem essas cordas: fitas que se atam e desatam em ritos populares, nós que se desfazem para liberar caminhos, tesouras que cortam o ar carregado. O rito moderno usa símbolos simples: um cordão representando o laço, duas velas representando os dois lados, uma tesoura consagrada. Ao cortar o cordão, você declara o fim do vínculo que drena — e deseja, de coração, que cada parte siga em paz com o que é seu.\n\nNa prática, comece por um laço claramente vencido: uma relação encerrada que ainda ocupa seus pensamentos, um convívio que só suga. O erro comum é cortar com raiva, transformando o rito em vingança silenciosa — corte se faz com firmeza serena, não com ódio. Outro é esperar que alguém suma da sua vida no dia seguinte: o que se corta é a corda energética; as escolhas práticas de distância continuam sendo suas.\n\nLeve consigo: soltar também é magia — talvez a mais difícil e a mais libertadora. Cada laço cortado com consciência devolve energia que estava presa no passado. Você não precisa carregar cordas que já não levam a lugar nenhum. Corte com respeito, agradeça o que foi aprendido e caminhe mais leve: o espaço que se abre é seu, e o da outra pessoa também.',
        practice:
            'Você vai realizar o Ritual de Corte de Laços. Primeiro, escolha um vínculo que drena e pegue um cordão ou barbante para representá-lo, segurando uma ponta em cada mão enquanto nomeia em silêncio o que aquele laço se tornou. Depois, corte o cordão com uma tesoura, desejando paz para os dois lados, e descarte as partes separadas. Por fim, registre o rito e o que sentiu na página. O objetivo é liberar energia presa em relações que já cumpriram seu papel.',
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
            'A lua negra é a fase em que o céu parece vazio: a lua está lá, mas não reflete luz nenhuma. Nas tradições da bruxaria, esse é o tempo do silêncio, do mergulho e do descanso — o escuro fértil onde tudo se prepara antes de nascer. Honrar essa fase importa porque poder não é só ação: a pausa consciente é tão mágica quanto qualquer feitiço bem feito.\n\nOs povos antigos plantavam conforme a lua e sabiam que a semente germina no escuro da terra, não na luz. O folclore associou a lua escura aos mistérios profundos, à deusa anciã, ao tempo em que não se começa nada — se escuta. A prática moderna traduz isso em retiro pessoal: menos estímulo, mais silêncio, adivinhação, escrita e sono reparador. É o momento em que a sombra fala mais claro, porque o barulho diminui.\n\nNa prática, marque a lua negra no seu calendário e reserve para ela uma noite mais quieta: menos telas, banho demorado, escrita solta, dormir cedo. O erro comum é tratar o descanso como preguiça e se forçar a produzir — nesta fase, isso só gera exaustão. Outro é esperar grandes revelações: às vezes a lua negra entrega apenas um sono profundo, e isso já é o presente da fase.\n\nLeve consigo: você também tem fases, e nenhuma delas é errada. O escuro fértil ensina que recolher-se é preparar a próxima florada. A bruxa que respeita o próprio inverno não se apaga — acumula profundidade. Deixe a lua negra ser seu lembrete mensal de que o vazio não é falta: é o útero silencioso onde a sua próxima versão está sendo gerada.',
        practice:
            'Você vai começar seu Diário da Lua Negra. Primeiro, descubra quando é a próxima lua negra e reserve essa noite — ou faça hoje um ensaio numa noite tranquila. Depois, diminua os estímulos: luz baixa, silêncio, menos telas, e escreva livremente o que pede descanso na sua vida e o que está germinando no escuro. Por fim, registre as percepções na página. O objetivo é transformar a fase escura num rito mensal de escuta e descanso.',
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
            'Pesadelos assustam, mas raramente vêm para atormentar: na leitura mística, são cartas urgentes da sombra. Quando algo importante não consegue chegar até você pela via comum, o sonho aumenta o volume — e vira monstro, queda, perseguição. Aprender a escutar sonhos sombrios importa porque eles apontam exatamente para o que o seu trabalho de sombra precisa olhar agora.\n\nCulturas antigas tratavam sonhos como oráculos: templos de incubação na Grécia, benzeduras contra pesadelo, guardiões do sono no folclore de vários povos. A chave simbólica moderna lê o pesadelo pelo avesso: quem te persegue no sonho costuma ser algo seu pedindo encontro; a casa em ruínas fala de estruturas internas; a queda, de controle que precisa ser solto. O monstro, quase sempre, quer entregar um recado — não te devorar.\n\nNa prática, o segredo é registrar logo ao acordar, antes que o sonho evapore: anote cenas, emoções e símbolos no Diário de Sonhos do app e consulte os Significados dos Sonhos para abrir camadas. O erro comum é interpretar ao pé da letra e concluir que sonho ruim é presságio — na maioria das vezes, é retrato interno, não profecia. Outro é fugir do tema: pesadelo ignorado tende a voltar mais alto.\n\nLeve consigo: a noite é sua aliada, mesmo quando fala em imagens assustadoras. Cada pesadelo escutado com coragem é uma conversa a menos que a sombra precisa gritar. Você não está à mercê dos seus sonhos — está em diálogo com eles. Durma como quem confia na própria profundidade: o escuro dos sonhos também trabalha a seu favor.',
        practice:
            'Você vai escutar um sonho sombrio. Primeiro, registre no Diário de Sonhos do app um pesadelo recente — ou o próximo que vier — com cenas, símbolos e emoções. Depois, explore os Significados dos Sonhos para abrir as camadas simbólicas e pergunte a si mesma que parte sua pode estar falando por meio daquelas imagens. Por fim, escreva na página a mensagem que conseguiu escutar. O objetivo é transformar o pesadelo de ameaça em mensageiro da sombra.',
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
            'Vidência sombria é a arte de olhar para o escuro até que ele comece a falar. O espelho negro, a tigela de água escura e a chama da vela são portas antigas para isso: superfícies que ocupam os olhos para que a intuição assuma o comando. Aprender essa prática importa porque treina a habilidade central da bruxa: sustentar o olhar diante do desconhecido sem fugir dele.\n\nA prática atravessa séculos: videntes olharam espelhos de obsidiana, poços fundos e bacias de tinta em muitas culturas, e o folclore guardou histórias de espelhos que mostram verdades escondidas. O funcionamento é menos misterioso do que parece: diante de uma superfície escura e sem detalhes, a mente racional aquieta e as imagens internas ganham espaço — símbolos, memórias, intuições. O espelho não mostra fantasmas: mostra você, em profundidade.\n\nPara começar, escureça o ambiente, acenda uma vela fora do reflexo e olhe suavemente para a superfície negra por alguns minutos, piscando normalmente. O erro comum é forçar visões ou desistir na terceira tentativa — vidência é músculo, cresce devagar. Se preferir um apoio mais concreto, as Cartas do Oráculo do app cumprem papel parecido: imagens que emprestam forma à sua intuição. Registre tudo, mesmo o que parecer pouco.\n\nLeve consigo: o escuro não está vazio — está cheio de você. Cada sessão de vidência ensina seus olhos a confiarem no que os outros sentidos já sabem. Não há resposta certa a encontrar, há escuta a refinar. Com paciência, o espelho negro deixa de ser assustador e vira o que sempre foi: uma janela tranquila para a sua própria profundidade.',
        practice:
            'Você vai fazer sua primeira sessão de vidência. Primeiro, prepare o ambiente: luz baixa, uma vela acesa e um espelho escuro ou uma tigela com água sobre fundo escuro — ou, se preferir, as Cartas do Oráculo do app. Depois, olhe suavemente para a superfície ou tire uma carta, deixando impressões, imagens e sensações surgirem sem forçar, por cinco a dez minutos. Por fim, registre tudo na página, sem censura. O objetivo é treinar o olhar intuitivo diante do escuro.',
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
            'Contenção, ou binding, é o feitiço que amarra um dano para que ele pare de se espalhar — como quem enfaixa um braço quebrado ou fecha um registro que vaza. Nesta trilha, ele existe para conter padrões, situações e comportamentos destrutivos, nunca para controlar a vontade de alguém ou ferir quem quer que seja. É a magia do limite: o basta dito em nó e cordão.\n\nA imagem do nó atravessa a história da magia: nós que seguram ventos nas lendas dos marinheiros, fitas que firmam promessas, tranças que guardam intenções. O binding clássico amarra um símbolo do problema com cordão e palavra firme. A ética é explícita: conter é impedir que um mal continue — como conter o próprio vício, uma dinâmica de fofoca ou um ciclo de autossabotagem. Controlar ou ferir pessoas é outra coisa, e esta trilha não ensina isso.\n\nNa prática, escreva a situação ou o padrão a conter num papel, dobre-o para dentro e amarre com cordão escuro, declarando que aquele dano está contido e não cresce mais. Guarde o pacote num lugar fechado. O erro comum é usar contenção como atalho para não agir — o feitiço segura a hemorragia, mas a cura pede atitudes concretas. Outro é mirar alguém por raiva disfarçada de justiça: pergunte-se sempre o que exatamente você quer conter.\n\nLeve consigo: todo feitiço volta para as mãos que o fazem — por isso a bruxa madura mede a intenção antes do nó. A contenção bem feita não é ataque: é o limite sagrado que protege você e os outros de um dano em curso. Use-a raramente, com clareza e responsabilidade, e ela será uma das ferramentas mais sóbrias do seu grimório.',
        practice:
            'Você vai fazer um Feitiço de Contenção ético. Primeiro, identifique um dano em curso que precisa parar de crescer — um padrão, um ciclo, uma situação; jamais uma pessoa como alvo. Depois, escreva-o num papel, dobre-o para dentro e amarre com um cordão escuro em nós firmes, declarando que aquele mal está contido; guarde o pacote em local fechado. Por fim, registre o feitiço e as atitudes concretas que o acompanharão. O objetivo é conter o dano enquanto você age para resolvê-lo.',
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
            'A trilha termina onde a bruxaria inteira começa: na integração. Depois de olhar a sombra, banir, cortar, proteger e conter, você descobre que não existem duas bruxas dentro de você — uma de luz e outra de escuro. Existe uma só, mais honesta, que conhece as próprias profundezas. Integrar é isso: parar de escolher metades e habitar o próprio inteiro com serenidade.\n\nOs símbolos antigos sempre apontaram para essa união: o dia precisa da noite, a lua cheia carrega a memória da lua negra, a semente e a flor são a mesma planta em tempos diferentes. Nas histórias, quem desce ao mundo de baixo e retorna volta transformada — não mais sombria, mais sábia. A sombra integrada não desaparece: vira discernimento, humor, compaixão e aquela força tranquila de quem já se conhece por dentro.\n\nNo cotidiano, a integração aparece em sinais discretos: você se irrita menos com os espelhos alheios, diz não sem culpa, descansa sem vergonha, protege-se sem endurecer. O erro comum é achar que o trabalho de sombra termina — ele muda de ritmo, mas acompanha a vida. Outro é esperar perfeição: a bruxa inteira não é a que nunca erra; é a que se responsabiliza pelo que faz com o próprio poder.\n\nLeve consigo: você atravessou o escuro e ele não te engoliu — te ampliou. O manifesto que escreve agora é o retrato de quem chegou até aqui: alguém que pratica com ética, sente sem se afogar e brilha sem negar a própria noite. Siga com as duas mãos abertas, uma para a luz e outra para a sombra. É assim que caminha a bruxa inteira.',
        practice:
            'Você vai escrever o Manifesto da Bruxa Inteira. Primeiro, releia as páginas desta trilha e observe o que mudou do pacto inicial até aqui. Depois, escreva um texto curto e pessoal declarando quem você é como praticante: seus valores, seus limites, o que integra da luz e da sombra. Por fim, leia o manifesto em voz alta e guarde-o como fechamento da trilha. O objetivo é selar a integração e assumir, com ética, o próprio poder inteiro.',
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
            'O axioma central da magia do caos afirma que a crença não é a verdade: é o instrumento. Se acreditar em algo produz o resultado desejado, o praticante veste essa crença como um casaco, trabalha com ela e depois a pendura. Essa virada importa porque devolve o poder a você: em vez de esperar encontrar a fé perfeita, você aprende a escolher e operar crenças de propósito.\n\nIsso não é cinismo: é levar a crença tão a sério a ponto de usá-la deliberadamente. A magia do caos nasceu no espírito pós-moderno, herdeira de Austin Osman Spare, e trata cada sistema como um mapa útil, nunca como o território. Um dia você opera como animista, no outro como cética metódica: o que conta é o efeito que cada lente produz na sua percepção e nos seus resultados.\n\nNo cotidiano de quem inicia, isso vira experimento: adotar por um período uma crença escolhida e observar o que muda em decisões, postura e oportunidades. Prefira crenças úteis e testáveis, uma de cada vez, e anote os efeitos. O erro comum é o meio-termo morno: acreditar pela metade não gera dados. Vista a crença por inteiro durante o teste e tire-a por inteiro depois.\n\nLeve com você a imagem do casaco: crenças são vestimentas de trabalho, não tatuagens. Você pode trocá-las conforme a tarefa, sem culpa e sem se perder, porque quem escolhe é você. Bem-vinda ao laboratório: aqui, acreditar é uma técnica — e toda técnica se aprende com prática e paciência.',
        practice:
            'Você vai testar a crença como ferramenta. Primeiro, escolha uma crença útil, afirmativa e testável, como: as pessoas gostam de me ajudar. Depois, viva 24 horas como se ela fosse absolutamente verdadeira, agindo em coerência total com ela. Por fim, anote o que mudou em você e ao seu redor. O objetivo é sentir na pele que uma crença vestida de propósito altera percepção, atitude e resultados.',
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
            'O sigilo é o desejo criptografado: um símbolo que carrega sua intenção sem que a mente consciente consiga lê-la. Criado por Austin Osman Spare, o método transforma uma frase de desejo em um glifo abstrato. Ele importa porque resolve o maior sabotador da magia: a ansiedade de quem fica vigiando o resultado e, sem querer, o afasta.\n\nO processo de Spare tem três atos: escrever o desejo, eliminar as letras repetidas e fundir as restantes num desenho único. Depois vem o passo decisivo: lançar o glifo no inconsciente através de um estado alterado, o gnosis — exaustão, dança, olhar fixo — e então esquecer. O esquecimento não é detalhe: a mente ansiosa sabota, enquanto o inconsciente, livre de vigilância, trabalha em silêncio.\n\nPara quem inicia, o desafio prático é a formulação do desejo: frases afirmativas, no presente, sem negações. A ferramenta de Sigilos do app monta o glifo por você, o que libera sua energia para o que importa: o lançamento e o esquecimento. O erro mais comum é revisitar o sigilo toda hora para conferir se funcionou. Lançou, esqueceu: distraia-se de verdade e deixe a semente germinar no escuro.\n\nGuarde esta chave: o sigilo funciona na medida em que você solta. Desejar, criptografar, lançar, esquecer — quatro gestos simples que treinam a arte mais difícil da magia, que é confiar no que não se vê. Seu inconsciente é um aliado competente: entregue o pedido e saia da frente dele.',
        practice:
            'Você vai criar e lançar seu primeiro sigilo. Abra a ferramenta do app em Ferramentas, escolha Sigilos e escreva seu desejo em frase afirmativa: o glifo será gerado para você. Antes de ativar, defina seu método de gnosis, como dança até o cansaço ou olhar fixo numa vela. Ative o sigilo nesse estado, depois destrua ou guarde o desenho e distraia-se. O objetivo é completar o ciclo inteiro: desejar, criptografar, lançar e esquecer.',
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
            'Gnosis é o estado em que a mente crítica silencia e o comando mágico passa direto ao fundo da psique. É o momento de abertura de que toda operação precisa: sem ele, a intenção fica presa na camada tagarela do pensamento. Conhecer seus próprios caminhos até esse estado é infraestrutura mágica básica, tão essencial quanto o próprio desejo que você quer lançar.\n\nA tradição caóta divide os portais em duas vias. A excitatória sobe: dança, tambor, hiperventilação leve, clímax — o corpo acelera até a mente soltar o leme. A inibitória desce: imobilidade, jejum curto, olhar fixo, silêncio absoluto — o mundo desacelera até restar só o foco. Nenhuma via é superior; cada pessoa tem seus portais naturais, e descobri-los é um trabalho de mapeamento pessoal.\n\nComece pelo que seu corpo já conhece: quem dança com facilidade tende à via excitatória; quem medita, à inibitória. Teste em sessões curtas, com segurança e sem substâncias — o corpo já tem tudo o que precisa. O erro comum é forçar intensidade: gnosis não é desmaio, é o instante em que o mundo afina. Registre cada teste e respeite seus limites físicos sempre.\n\nLeve consigo a ideia do portal: gnosis não é um lugar distante, é uma porta que seu próprio corpo sabe abrir. Com prática, você aprende a alcançá-la em poucos minutos, e cada operação mágica ganha profundidade. Mapear seus estados alterados é conhecer a chave da sua própria casa.',
        practice:
            'Você vai testar um portal inibitório hoje. Acenda uma vela num ambiente calmo, sente-se confortável e sustente o olhar fixo na chama por 5 minutos, sem forçar as pálpebras, deixando a respiração desacelerar. Perceba o momento em que o mundo parece afinar e os pensamentos se espaçam. Ao terminar, anote as sensações. O objetivo é reconhecer no corpo o gosto do gnosis para usá-lo depois nas suas operações.',
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
            'O diário de resultados é o que separa o caóta do místico de sofá: um registro fiel de cada operação com data, técnica, estado e desfecho. Sem ele, a memória trapaceia — todo sucesso é lembrado, todo fracasso convenientemente esquecido — e você não aprende nada. Com ele, sua magia vira um laboratório de verdade, com histórico e evolução visível.\n\nA magia do caos se define como tecnologia experimental, e experimento sem dados não existe. O registro transforma impressões vagas em padrões visíveis: qual técnica rende mais, em que estado você opera melhor, quanto tempo os efeitos levam. É o mesmo espírito que guiou Spare e os caótas modernos: resultados mensuráveis acima de teorias bonitas, zero dogma e revisão constante.\n\nNa prática, crie um template curto e use-o sempre: data, operação, técnica, estado interno, resultado e uma nota de confiança. Revise em ciclos fixos, semanais ou lunares. O erro clássico é registrar só quando dá certo, ou maquiar o fracasso com desculpas. Seja impiedosa com a autoilusão e gentil com o processo: fracasso é dado precioso, não vergonha.\n\nGuarde esta máxima: o que não se registra, não se aprende. Seu diário é o instrumento mais poderoso do laboratório, porque transforma cada tentativa — boa ou má — em degrau. A honestidade de hoje no papel se converte em maestria amanhã na prática, e ninguém pode fazer esse trabalho por você.',
        practice:
            'Você vai auditar seus experimentos até aqui. Releia os registros das lições anteriores — a crença de 24 horas, o sigilo, os testes de gnosis — e avalie cada um com honestidade brutal: o que funcionou de fato, o que foi coincidência, o que foi viés de confirmação. Depois, monte seu template fixo de registro para as próximas operações. O objetivo é fundar seu diário de resultados sobre dados limpos, não sobre desejos.',
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
            'O servidor é um programa psíquico: uma entidade criada por você para cumprir uma única função, como lembrar, proteger ou encontrar. Diferente de espíritos herdados de tradições, ele nasce do seu desenho consciente. A técnica importa porque ensina, em escala pequena e segura, como a atenção dá vida e forma às construções da mente.\n\nA construção segue uma receita clara: o servidor recebe nome, forma visual, uma função única e bem delimitada, um alimento simbólico — atenção diária, um gesto, um símbolo — e, ponto crucial, uma data de desligamento. Na visão caóta, pouco importa se ele é um ser real ou um mecanismo psicológico: se cumpre a função e responde ao protocolo, é tecnologia funcionando.\n\nPara quem inicia, o segredo é a modéstia: um servidor para uma tarefa concreta da semana, não um guardião cósmico. Escreva a função em uma frase; se precisar de duas, são dois servidores. Alimente-o no horário combinado e observe. O erro comum é criar e abandonar: entidade esquecida vira ruído. Trate como criação responsável, com manutenção e aposentadoria digna.\n\nLeve esta imagem: o servidor é um aplicativo que você instala na própria psique — propósito claro, consumo definido, prazo de validade. Criar, manter e desligar com respeito é um ciclo completo de responsabilidade mágica. Comece pequeno e aprenda o ofício de dar forma ao invisível.',
        practice:
            'Você vai projetar seu primeiro servidor. Escolha uma tarefa concreta desta semana, como lembrar de beber água. Esboce a criatura em desenho ou texto: defina nome, forma, a função única em uma frase, o alimento simbólico e a data exata de desligamento. Apresente-o mentalmente à tarefa e alimente-o uma vez por dia. O objetivo é experimentar o ciclo completo de criar, manter e desligar uma entidade de propósito.',
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
            'A troca de paradigma é o exercício-rei da magia do caos: viver um período inteiro dentro de outro sistema de crenças — uma semana como animista, outra como cética radical, outra como devota. Não se trata de zombar nem de fingir por fora: trata-se de experimentar o sistema de dentro, com as regras, os olhos e os gestos de quem realmente acredita.\n\nA prática nasce da postura pós-moderna do caos: todo paradigma é um mapa, e mapas se trocam conforme a viagem. Ao habitar um sistema estranho, você descobre o que ele revela e o que ele esconde. Um exemplo concreto: passar três dias lendo o mundo através das runas nórdicas, consultando-as nas decisões do dia, mesmo que seu caminho usual seja outro. A imersão gera dados que a leitura de fora jamais daria.\n\nPara quem inicia, o formato seguro é curto e delimitado: escolha o paradigma, escreva suas regras de imersão, defina começo e fim, e registre diariamente o que muda na percepção. O erro comum é a imersão pela metade, visitando o sistema como turista apressada. Outro é esquecer a saída: terminado o prazo, encerre com clareza e volte ao seu centro.\n\nO prêmio deste exercício é a flexibilidade: quem já morou em várias casas de crença nunca mais confunde a mobília com o mundo. Cada paradigma visitado deixa uma ferramenta na sua bagagem e afrouxa a ilusão de que existe um único jeito certo de ver. Viaje com curiosidade, aprenda e volte mais livre.',
        practice:
            'Você vai morar 3 dias num paradigma diferente do seu — por exemplo, o das runas nórdicas. Defina suas regras de imersão, abra a ferramenta de Runas do app em Ferramentas e tire uma runa por dia, deixando a leitura orientar decisões pequenas. Registre a cada noite o que mudou na sua percepção. Ao final, encerre a imersão com clareza. O objetivo é experimentar outro sistema de dentro e ganhar flexibilidade de crença.',
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
            'A magia do resultado é o coração pragmático do caos: magia a serviço de metas reais, com alvo específico, prazo definido e técnica escolhida. Nada de pedidos vagos ao universo: uma operação bem desenhada se parece mais com um projeto do que com uma prece. Isso importa porque tira a magia do terreno da fantasia e a coloca no dos efeitos verificáveis.\n\nA marca registrada caóta é a ação mundana casada: todo trabalho mágico vem acompanhado de movimentos concretos no mundo. O feitiço de emprego caminha junto com currículos enviados; o sigilo de saúde, com a consulta marcada. A lógica é de dupla via: a magia abre caminhos e afina a percepção, enquanto a ação garante que exista porta onde o caminho desemboque. Magia sem ação é loteria; ação sem magia é metade do arsenal.\n\nNo dia a dia, desenhe operações pequenas e mensuráveis: uma meta de 30 dias, uma técnica, três ações mundanas e um critério claro de sucesso. Anote tudo no diário de resultados. Os erros comuns são metas nebulosas como querer prosperar em geral, prazos infinitos e a tentação de esperar o feitiço agir sozinho enquanto nada se move na vida prática.\n\nGrave esta fórmula: alvo claro, prazo real, técnica escolhida e ação casada no mundo. Quando magia e movimento caminham juntos, cada resultado — venha de onde vier — é conquista sua. Você deixa de pedir permissão ao universo e passa a negociar com ele de igual para igual, usando as duas mãos.',
        practice:
            'Você vai desenhar uma operação completa de 30 dias. Escolha uma meta real e específica, com prazo. Depois defina a técnica mágica — um sigilo, um servidor, o que seu diário aprovar — e liste 3 ações mundanas casadas que você fará no mesmo período. Registre tudo e marque a data da avaliação. O objetivo é viver a fórmula caóta na íntegra: magia e ação trabalhando juntas por um resultado mensurável.',
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
            'O banimento é a faxina do laboratório: a técnica que limpa resíduos entre operações, desfaz trabalhos que não serviram e devolve o espaço interno ao estado neutro. Sem ele, restos de intenção, ansiedade e imagens carregadas se acumulam de um rito para outro. Encerrar bem é tão importante quanto começar bem — talvez até mais.\n\nA tradição caóta cultiva do riso banidor — gargalhar da própria operação até dissolvê-la por completo — a versões adaptadas do pentagrama ritual. O riso funciona porque quebra a gravidade: nada resiste a uma boa gargalhada, nem mesmo a sua própria solenidade. Mas o critério caóta é um só: o rito precisa funcionar para você. Teste formatos e meça o efeito, como em qualquer técnica.\n\nNo cotidiano, banir também é psicológico: fechar as abas mentais do dia, cortar a ruminação, marcar o fim de um ciclo com um gesto físico — palmas, uma palavra, um sopro na vela. Quem inicia costuma pular essa etapa por pressa ou por achá-la pouco importante, e depois carrega a operação na cabeça por dias. Um rito curto e repetido vale mais que um elaborado e esquecido.\n\nLeve consigo a regra do laboratório limpo: toda operação merece um fim nítido. Um gesto, uma risada, um corte — e a bancada fica livre para o próximo experimento. Quem sabe encerrar dorme melhor, opera melhor e não confunde o eco de ontem com o sinal de hoje.',
        practice:
            'Você vai criar sua primeira faxina energética. Ao final do dia, fique de pé, respire fundo e bata palmas 3 vezes com firmeza. Em seguida, ria alto de tudo o que ficou pendente — deixe a gargalhada dissolver o peso. Sinta o corte entre o que passou e o agora. Repita por alguns dias e anote o efeito no corpo e no sono. O objetivo é instalar um rito simples de banimento que encerre ciclos e limpe o espaço entre operações.',
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
            'Para o caóta, a sincronicidade é o feedback do sistema: quando as coincidências começam a se alinhar à sua operação — a música certa, o encontro improvável, a palavra repetida — algo está em curso. Ler esses ecos importa porque eles indicam se a rota está viva, funcionando como o painel de instrumentos do seu voo mágico.\n\nO termo vem de Jung: coincidências significativas sem causa comum aparente. A postura caóta é pragmática: a sincronicidade não se força — se surfa. Você registra o eco, agradece e ajusta a rota, sem transformar cada folha caindo em profecia. O acaso também pode ser consultado ativamente: oráculos são geradores de aleatoriedade significativa, convites para o padrão emergir.\n\nA armadilha de quem inicia é a apofenia: ver padrão em tudo, sinal em cada placa de rua. O antídoto é o diário de resultados: anote o eco no momento em que ocorre, releia com frieza depois e pergunte se ele apontava algo verificável. Trabalhe com uma pergunta por vez, colete os ecos de um dia inteiro e só então faça a leitura, honesta e sem forçar.\n\nGuarde a imagem da surfista: você não cria a onda do acaso, mas aprende a montá-la. Sinal registrado, gratidão breve, rota ajustada — e o diário como quilha para a leitura não virar delírio. O mundo conversa com quem opera; seu trabalho é ouvir com atenção, sem inventar o que não foi dito.',
        practice:
            'Você vai lançar uma pergunta ao acaso. De manhã, formule uma questão clara e faça uma consulta na ferramenta de Oráculo do app, em Ferramentas, guardando a resposta como semente. Ao longo do dia, colete os ecos — coincidências, frases, encontros — sem forçar nada. À noite, releia tudo e faça a leitura honesta: sinal ou apofenia? O objetivo é treinar a escuta do acaso com o diário como proteção contra o autoengano.',
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
            'O destino da magia do caos é a autonomia: depois de testar crenças, técnicas e paradigmas, você monta o seu próprio sistema — pessoal, funcional e revisável. Nenhum grimório alheio conhece seus portais de gnosis, seus símbolos vivos, seu ritmo. Chegar aqui importa porque encerra a fase de seguir mapas e inaugura a fase de desenhá-los.\n\nO critério de montagem é experimental: se passa no seu diário de resultados, é seu. Misture sem medo o esbá com sigilos, o benzimento da avó com servidores modernos — a tradição caóta sempre tratou sistemas como caixas de ferramentas, não como igrejas. Os limites são apenas éticos: nada de dano a pessoas ou animais, nada criminoso. O resto — o estranho, o simbólico, o inventado — é matéria-prima legítima.\n\nNa prática, comece enxuta: três técnicas centrais comprovadas, seus princípios inegociáveis e uma área de testes para o que ainda está em avaliação. Dê ao sistema um nome e uma data de revisão, como um software que ganha versões. O erro comum é a colcha infinita: acumular técnicas sem nunca podar. Sistema bom é o que você usa de verdade, não o que enfeita o caderno.\n\nLeve consigo a ideia da versão 1.0: seu sistema não precisa nascer pronto, precisa nascer seu. Revisável, honesto e vivo, ele crescerá com cada experimento registrado. Nada é verdade, tudo é permitido criar — e a sua magia, a partir de agora, carrega a sua própria assinatura.',
        practice:
            'Você vai consolidar seu caminho. Releia todas as suas páginas e registros das trilhas, com calma, e circule o que já funciona como o seu jeito: técnicas que rendem, símbolos que falam, ritmos que sustentam. Depois, organize o essencial em três técnicas centrais, seus princípios e uma lista do que segue em teste. Marque a data da primeira revisão. O objetivo é transformar a experiência acumulada no seu sistema mágico versão 1.0.',
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
            'O tarot é um mapa da experiência humana desenhado em 78 cartas. São 22 Arcanos Maiores, que retratam as grandes forças e passagens da vida, e 56 Arcanos Menores, que descrevem o cotidiano. Conhecer esse mapa importa porque ele oferece um espelho: cada carta nomeia algo que você já viveu ou ainda vai viver, e nomear é o primeiro passo para compreender.\n\nOs Menores se dividem em quatro naipes, cada um ligado a um elemento. Paus é fogo e fala de ação, projetos e paixão. Copas é água e rege emoções, vínculos e intuição. Espadas é ar, o território da mente, das ideias e dos conflitos. Ouros é terra: corpo, trabalho e matéria. Assim, um Ás de Paus traz uma faísca criativa, enquanto um Dez de Copas mostra a plenitude afetiva de um lar em paz.\n\nAntes de decorar qualquer significado, manuseie. O tarot se aprende pelas mãos e pelos olhos: observe cores, gestos e paisagens de cada lâmina. O erro mais comum da iniciante é tentar memorizar 78 verbetes de uma vez e se frustrar. Prefira visitas curtas e frequentes ao baralho, deixando que as imagens falem primeiro e o estudo venha depois, como apoio.\n\nLeve consigo esta ideia: o baralho não é um código a decifrar, é um território a habitar. Você não precisa dominar as 78 cartas hoje — precisa apenas começar a caminhar por elas com curiosidade. Cada visita torna o mapa mais familiar, e é a intimidade, não a pressa, que forma uma boa leitora.',
        practice:
            'Abra a Biblioteca de Cartas do app e percorra as 78 cartas sem pressa, olhando a imagem antes de ler o significado. Ao final, escolha uma carta que atraiu você e outra que incomodou, e releia o texto de cada uma com atenção. Depois registre na página desta lição o que viu e sentiu. O objetivo é criar seu primeiro vínculo com o baralho: perceber que ele já conversa com você antes de qualquer estudo formal.',
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
            'Os Arcanos Maiores contam uma história contínua, conhecida como a Jornada do Louco. O Louco, carta zero, parte sem bagagem e atravessa as 21 lâminas seguintes como etapas de amadurecimento. Estudar os maiores em ordem importa porque transforma uma lista solta de cartas em um enredo vivo, que a sua memória abraça com muito mais facilidade.\n\nNeste primeiro terço, o Louco encontra os mestres iniciais: o Mago ensina a vontade que realiza, a Sacerdotisa guarda a intuição e o mistério, a Imperatriz rege a criação fértil, o Imperador dá estrutura e limites, o Hierofante transmite a tradição, os Enamorados apresentam a escolha que define caminhos e o Carro celebra a vitória da vontade bem dirigida.\n\nPara estudar, conte a história em voz alta: o Louco salta, aprende com o Mago, silencia com a Sacerdotisa, e assim por diante. Associe cada arcano a uma palavra sua, não a definições emprestadas. O tropeço comum é confundir os pares: lembre que o Mago age e o Imperador organiza, que a Sacerdotisa sabe em silêncio e a Imperatriz gera em abundância.\n\nGuarde esta chave: de 0 a VII você aprende as forças básicas do mundo — vontade, intuição, criação, ordem, tradição, escolha e direção. Quando uma dessas cartas surgir numa leitura, pergunte qual dessas forças pede passagem na sua vida agora. A Jornada começou, e você já caminha dentro dela.',
        practice:
            'Abra o Tutor de Tarot e faça uma sessão de quiz dedicada aos Arcanos Maiores de 0 a VII. Responda com calma, tentando lembrar a cena de cada carta antes de escolher a alternativa. Refaça as questões que errar até acertar com segurança. Ao terminar, anote na página desta lição quais arcanos ainda se confundem na sua cabeça. O objetivo é fixar o primeiro terço da Jornada do Louco pela repetição gentil, sem decoreba.',
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
            'Depois de aprender as forças do mundo, o Louco enfrenta o segundo terço da Jornada: as provas internas. Dos arcanos VIII a XIV, a história deixa os mestres externos e mergulha na alma. Essas cartas importam porque tratam daquilo de que ninguém escapa — coragem, recolhimento, ciclos, consequências e a grande arte de se transformar.\n\nA Força, arcano VIII no Rider-Waite, ensina a coragem gentil que doma sem violência. O Eremita se recolhe para encontrar a própria luz. A Roda da Fortuna gira os ciclos da vida, e a Justiça, arcano XI, cobra a consequência de cada escolha. O Enforcado inverte o olhar e ganha nova perspectiva, a Morte encerra o que já cumpriu seu tempo e a Temperança mistura os opostos em síntese serena.\n\nSão as cartas que assustam as iniciantes e sustentam as leitoras experientes. O erro clássico é ler a Morte como tragédia: ela fala de fins necessários, quase nunca de morte física. Estude o grupo ligando cada carta a uma prova que você já viveu — a memória afetiva fixa muito mais do que a repetição seca. E não apresse o Eremita: recolher também é avançar.\n\nLeve consigo: maturidade no tarot é perder o medo dessas sete lâminas. Quando uma delas aparecer, em vez de temer, pergunte qual prova está madura na sua vida e o que ela veio ensinar. Aqui mora a diferença entre quem apenas consulta as cartas e quem de fato dialoga com elas.',
        practice:
            'No Tutor de Tarot, faça uma sessão de quiz focada nos arcanos VIII a XIV, com atenção especial aos que se parecem, como Roda e Justiça. Depois do quiz, abra a carta da Morte e contemple a imagem por dois minutos, respirando fundo, sem medo. Por fim, registre suas impressões na página desta lição. O objetivo é fixar as provas da alma e transformar a carta mais temida do baralho em uma aliada sua.',
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
            'O terço final da Jornada atravessa a noite mais escura antes do amanhecer. Dos arcanos XV a XXI, o Louco encara seus apegos e ilusões para renascer inteiro. Conhecer esse trecho importa porque ele descreve as crises que transformam — e mostra que nenhuma noite, por mais funda que pareça, é o fim da história que você está vivendo.\n\nO Diabo revela os apegos que prendem, a Torre derruba estruturas falsas de um só golpe, a Estrela devolve a esperança nua e serena, e a Lua mergulha nas ilusões e medos do inconsciente. Então amanhece: o Sol traz alegria clara, o Julgamento soa como um chamado de renascimento e o Mundo fecha o ciclo em completude — a dança de quem integrou a Jornada inteira.\n\nPara fixar, conte o arco completo como história, do salto do Louco à dança do Mundo: narrar em voz alta grava mais do que reler. Cuidado com o erro de tratar Torre e Diabo como maldições — em leituras reais, eles costumam apontar libertações urgentes. E lembre: a Jornada não é linha reta, é espiral; você a percorre muitas vezes ao longo da vida.\n\nGuarde esta imagem: toda Torre que cai abre vista para uma Estrela. Com os 22 maiores completos, você já carrega o esqueleto do tarot. Diante de qualquer mesa, procure primeiro em que ponto da espiral a consulente está — o resto da leitura se organiza a partir daí.',
        practice:
            'Abra o Tutor de Tarot e faça uma sessão de quiz com os arcanos XV a XXI; depois, uma rodada geral com os 22 Arcanos Maiores. Em seguida, afaste o app por um instante e conte a Jornada inteira em voz alta, carta a carta, como quem narra um conto. Volte e registre na página o seu resumo e a sua precisão no quiz. O objetivo é costurar o arco completo dos maiores na memória, de uma vez por todas.',
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
            'Se os maiores narram as grandes passagens, os naipes falam do cotidiano — e é neles que a maior parte das leituras acontece. Paus e Copas formam o par quente do baralho: fogo e água, impulso e sentimento. Dominar essa dupla importa porque ela descreve quase tudo o que move os seus dias: desejo, projetos, vínculos e emoções.\n\nPaus é fogo: projetos, paixão, movimento. O Ás acende a faísca criativa, o Três já contempla o horizonte dos planos e o Dez mostra a sobrecarga de quem abraçou demais. Copas é água: vínculos, emoções, intuição. O Ás transborda um sentimento novo, o Três celebra entre amigas e o Dez coroa a plenitude afetiva. Cada número conta um estágio da energia do naipe.\n\nA dica de ouro: número mais naipe forma uma frase. Pense no número como verbo e no naipe como assunto — Três é expansão, Copas é afeto, logo o Três de Copas é celebração compartilhada. O erro comum é decorar cada carta isolada; monte a frase e você lê qualquer menor. Treine com o seu dia: aquela reunião agitada foi qual carta de Paus?\n\nLeve consigo: fogo sem água queima, água sem fogo estagna. Paus pergunta onde está o seu impulso; Copas, como anda o seu coração. Quando esses dois naipes dominarem uma mesa, a vida está falando de paixão e de vínculo — e você já sabe conjugar os dois.',
        practice:
            'Abra o Tutor de Tarot e faça uma sessão de quiz dedicada aos naipes de Paus e Copas. Antes de responder cada questão, monte mentalmente a frase número mais naipe e só então confira a alternativa. Depois do quiz, crie por conta própria três frases desse tipo e registre na página, junto com as confusões que aparecerem. O objetivo é internalizar a lógica que permite ler qualquer carta menor sem decoreba.',
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
            'Espadas e Ouros completam o quarteto dos naipes: ar e terra, mente e matéria. É o par que equilibra o baralho — depois do desejo e da emoção, chegam o pensamento e o chão firme. Conhecer os dois importa porque toda leitura madura precisa distinguir o que é ideia, o que é fato concreto e o que é medo vestido de verdade.\n\nEspadas é ar: a mente, com sua clareza que corta e sua ansiedade que fere. É o naipe de fama mais difícil e também o mais honesto — o Ás traz a verdade nua, o Três nomeia a dor da decepção, o Nove retrata a insônia das preocupações. Ouros é terra: corpo, trabalho, dinheiro e a magia da matéria bem cuidada — do Ás, semente concreta, ao Dez, patrimônio e legado.\n\nContinue usando a fórmula número mais elemento: agora você lê qualquer menor numerado do baralho. O erro comum aqui é dramatizar Espadas — o naipe descreve pensamentos, não sentenças. Diante de uma carta dura, pergunte que pensamento é esse, e não que desgraça vem aí. E honre Ouros: cuidar do concreto também é prática espiritual.\n\nGuarde esta síntese: Espadas mostra o que a sua mente conta a você; Ouros mostra o que as suas mãos constroem. Entre o pensar e o concretizar caminha a vida inteira. Com os quatro naipes na bagagem, o cotidiano inteiro virou vocabulário de leitura para você.',
        practice:
            'No Tutor de Tarot, faça uma sessão de quiz com os naipes de Espadas e Ouros, aplicando a fórmula número mais elemento antes de cada resposta. Ao terminar, percorra mentalmente o naipe de Espadas e identifique qual carta mais se parece com a sua mente hoje; faça o mesmo com Ouros e a sua vida material. Registre tudo na página. O objetivo é completar o domínio dos quatro naipes e trazer as cartas para o seu presente.',
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
            'Dezesseis cartas do baralho não descrevem situações, e sim gente: são as cartas de corte — Valete, Cavaleiro, Rainha e Rei de cada naipe. Elas importam porque toda leitura envolve pessoas e posturas, e a corte é o espelho onde consulente, leitora e os personagens da vida aparecem com rosto, idade interna e temperamento.\n\nCada posto indica uma maturidade da energia do naipe: o Valete aprende e experimenta, o Cavaleiro age e parte em missão, a Rainha domina a energia por dentro, o Rei a governa por fora, no mundo. Cruze o posto com o elemento e o retrato surge: a Rainha de Copas acolhe com profundidade emocional, o Cavaleiro de Espadas avança com ideias afiadas e muita pressa.\n\nNa mesa, uma corte pode ser alguém presente na situação ou um papel que você mesma está vestindo — pergunte sempre: quem é, ou o que estou sendo? O erro comum é fixar cada corte numa pessoa física de aparência parecida; prefira ler temperamentos. Treine associando pessoas queridas às dezesseis cartas: a memória afetiva firma o aprendizado.\n\nLeve consigo: você não é uma única carta de corte — é o baralho inteiro, vestindo postos conforme a semana pede. Diante de uma corte, faça sempre a pergunta dupla: quem está agindo assim, e quando sou eu que ajo assim. Com ela, essas dezesseis cartas deixam de confundir e passam a revelar.',
        practice:
            'Abra o Tutor de Tarot e faça uma sessão de quiz dedicada às dezesseis cartas de corte, atenta ao par posto e naipe de cada uma. Depois, reflita: qual corte você está vestindo esta semana — um Valete curioso, uma Rainha de Ouros provedora? Escolha também cortes para três pessoas da sua vida e registre tudo na página. O objetivo é reconhecer posturas e temperamentos, dentro e fora de você.',
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
            'Uma boa leitura começa antes do embaralhar: na pergunta. A pergunta é metade da resposta, porque define a lente pela qual as cartas serão lidas. Perguntar bem importa tanto quanto conhecer significados — uma mesa inteira de cartas certeiras não salva uma pergunta torta, vaga ou que entrega ao baralho o seu poder de decidir.\n\nPerguntas abertas rendem: o que preciso enxergar sobre esta situação, que energia me ajuda agora. Perguntas de sim ou não empobrecem a conversa, e perguntas sobre a vida de terceiros invadem território alheio. Reformule até a pergunta apontar para você — em vez de querer saber se alguém volta, pergunte o que você precisa compreender sobre esse vínculo.\n\nNa hora de tirar: respire fundo, embaralhe com a pergunta viva no corpo e vire as cartas com calma. Leia primeiro a imagem — o que a cena mostra, o que você sente ao olhar — e só depois consulte o significado, que vem em socorro, nunca na frente. O erro comum é pular direto para o texto e ignorar o que os seus olhos já sabiam.\n\nGuarde esta medida: pergunta aberta, olhos primeiro, significado depois. Quem pergunta bem já recebeu meia resposta antes de virar a primeira carta. O tarot não decide por você — ele ilumina o terreno para que você decida melhor, e é aí que mora a sua força.',
        practice:
            'Vá à página de Tarot do app e escolha a tiragem de Três Cartas. Antes de tirar, escreva sua pergunta e reformule até que fique aberta e apontada para você. Embaralhe respirando fundo, vire as cartas e leia primeiro as imagens, anotando suas impressões; só então abra os significados e compare. Registre o processo na página da lição. O objetivo é firmar o ritual completo: pergunta bem feita, olhar próprio e estudo como apoio.',
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
            'Cartas não falam sozinhas — conversam. A leitura madura não soma verbetes isolados: tece uma história em que cada carta ilumina as vizinhas. Aprender a combinar importa porque é isso que separa quem consulta significados de quem realmente lê. A mesa é um texto, e as cartas são frases que só ganham sentido pleno quando lidas juntas.\n\nTrês padrões guiam o tecido: a repetição de naipe revela o tema dominante — muitas Copas, e o assunto é afeto; a maioria de Arcanos Maiores indica forças grandes em jogo, acima do cotidiano; e as vizinhanças se iluminam — a Torre ao lado da Estrela é ruptura com esperança, o Dez de Paus perto do Eremita pede pausa e recolhimento antes de seguir.\n\nNa prática, antes de consultar qualquer significado, olhe a mesa inteira e conte a história: onde ela começa, onde aperta, onde aponta saída. Escrever a leitura como um pequeno conto educa o olhar. O erro comum é ler carta por carta como fichas soltas, cada uma com seu parágrafo, sem nunca conectar — e a história se perde dentro do dicionário.\n\nLeve consigo: o seu papel de leitora é narrar o que as cartas formam juntas, com começo, tensão e conselho. Confie no fio que você enxerga entre as lâminas — ele é a sua leitura. O dicionário, qualquer pessoa abre; a história, só você é capaz de contar.',
        practice:
            'Na página de Tarot, faça uma tiragem de Três Cartas sobre um tema do seu momento. Antes de consultar qualquer significado, observe a mesa inteira e escreva a leitura como um mini conto de cinco linhas, com começo, tensão e conselho. Depois confira os significados, note repetições de naipe, presença de maiores e vizinhanças, e registre tudo. O objetivo é treinar a leitura combinada: tecer histórias em vez de somar cartas soltas.',
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
            'Chegando ao fim da trilha, o que falta não é técnica: é identidade. A leitora madura se reconhece por duas marcas — ética firme e voz própria. Isso importa porque o tarot toca pessoas em momentos sensíveis, e a diferença entre ajudar e assombrar está inteira na postura de quem segura as cartas diante de outra alma.\n\nA ética se resume em devolver o poder: não prever morte nem doença, não decidir a vida de ninguém, não alimentar dependência de consultas. A voz própria se constrói com o tempo: suas cartas âncora, aquelas que você lê de olhos fechados; seus rituais de mesa, o jeito de abrir e fechar cada leitura; sua forma única de contar o que a mesa mostra.\n\nNo dia a dia, nada firma voz e vínculo como a constância: uma carta por dia vale mais do que uma tiragem enorme por mês. Tire a Carta do Dia, escreva uma linha, siga a vida — e à noite repare em como a carta apareceu. O erro comum é abandonar a prática quando a rotina aperta; encolha o ritual se for preciso, mas não o abandone.\n\nGuarde como manifesto: o tarot não prevê um destino fechado — ilumina caminhos para quem escolhe. Você agora conhece o mapa, os naipes, a corte e a Jornada inteira. Daqui em diante, o baralho fala com a sua voz. Leia com coragem, com ética e com a ternura de quem sabe que toda carta é um espelho.',
        practice:
            'Na página de Tarot, tire a Carta do Dia por sete dias seguidos. A cada manhã, observe a imagem, respire e escreva uma única linha sobre o que a carta desperta; à noite, se quiser, acrescente como ela apareceu no seu dia. Ao fim da semana, releia as sete linhas e escreva seu manifesto de leitora na página da lição. O objetivo é firmar o hábito que sustenta toda leitora: presença diária, breve e constante, com as cartas.',
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

  // ═════════════ QUIROMANCIA ═════════════
  LearningTrail(
    id: 'quiromancia',
    emoji: '🖐️',
    title: 'Quiromancia',
    subtitle: 'A leitura técnica das mãos',
    description:
        'A arte de ler as mãos com método: formato, linhas, montes, dedos e marcas. Nove lições que ensinam a observar de verdade — e não apenas a imaginar.',
    lessons: [
      TrailLesson(
        id: 'qm_01',
        recordKind: LessonRecordKind.note,
        title: 'A mão como mapa',
        teaching:
            'A quiromancia (do grego cheir, mão, e manteia, adivinhação) parte de uma ideia simples: a mão registra a pessoa. Formato, textura, linhas e relevos formam um mapa do temperamento e das tendências de quem os carrega. Ler mãos não é prever um destino fixo — é observar inclinações naturais e como elas mudam ao longo da vida, porque as linhas realmente se transformam com os anos.\n\nDuas distinções técnicas abrem qualquer leitura. A primeira é entre mão dominante e mão passiva (ou de nascimento): a passiva — a que você usa menos — mostra o potencial herdado, o "material de origem"; a dominante mostra o que você fez com ele, o presente e a direção. Comparar as duas é meio caminho da leitura. A segunda distinção separa quirognomia (o estudo do formato da mão e dos dedos, mais ligado ao caráter) de quiromancia propriamente dita (o estudo das linhas e marcas).\n\nAntes de olhar qualquer linha, a leitura séria começa pelo conjunto: qual a mão dominante, como é a textura da pele, a cor, a flexibilidade, a temperatura, se a mão é tensa ou relaxada. Uma mão firme e quente fala diferente de uma mão mole e fria. Guarde a regra de ouro do quiromante honesto: descreva o que vê, nunca invente o que não está lá, e trate cada marca como uma tendência a compreender, jamais como uma sentença.',
        practice:
            'Nesta prática você vai conhecer suas próprias mãos como um leitor. Primeiro, identifique sua mão dominante e sua mão passiva. Depois, observe as duas lado a lado sob boa luz e anote as diferenças gerais: qual tem mais linhas, qual a pele mais firme, qual parece mais "movimentada". Por fim, registre suas primeiras impressões. O objetivo é treinar o olhar de conjunto antes de mergulhar nas linhas.',
        pageTitle: 'O Mapa das Minhas Mãos',
        pagePurpose: 'Registrar a leitura inicial de conjunto das duas mãos',
        pageCategory: SpellCategory.divination,
        pageIngredients: ['Suas duas mãos', 'Boa iluminação'],
        pagePrompts: [
          'Minha mão dominante e minha mão passiva:',
          'Diferenças gerais que percebo entre elas:',
          'Textura, temperatura e flexibilidade que observei:',
          'Minhas primeiras impressões sobre o que as mãos contam:',
        ],
      ),
      TrailLesson(
        id: 'qm_02',
        recordKind: LessonRecordKind.note,
        title: 'O formato da mão: os quatro elementos',
        teaching:
            'A quirognomia clássica classifica as mãos em quatro tipos elementais, cruzando o formato da palma com o comprimento dos dedos. É o primeiro dado técnico de qualquer leitura, porque enquadra tudo o que vem depois. A regra: compare o comprimento da palma (do pulso à base dos dedos) com o comprimento dos dedos médios.\n\nMão de Terra — palma quadrada e dedos curtos. Pessoas práticas, estáveis, ligadas ao corpo e ao concreto; mãos firmes, poucas linhas, pele mais grossa. Mão de Ar — palma quadrada e dedos longos. Mente ágil, comunicação, curiosidade; muitas linhas finas e nítidas. Mão de Fogo — palma retangular (mais longa que larga) e dedos curtos. Energia, ação, entusiasmo, impaciência; linhas marcadas e vívidas. Mão de Água — palma longa e estreita e dedos longos. Sensibilidade, imaginação, emoção; pele macia e uma teia de linhas delicadas.\n\nNa prática, o formato raramente é "puro" — a maioria das mãos mistura dois elementos, e é justamente essa combinação que individualiza a leitura. O erro comum da iniciante é decorar rótulos e forçar a mão a caber num deles. Faça o contrário: meça, compare e descreva a mistura. O elemento da mão dá o tom emocional e prático de fundo; as linhas, que veremos a seguir, contam a história sobre esse fundo.',
        practice:
            'Nesta prática você vai classificar o formato da sua mão. Primeiro, meça (com os olhos ou com uma régua) a palma e os dedos da mão dominante. Depois, cruze palma quadrada/retangular com dedos curtos/longos e identifique o elemento — ou a mistura de dois. Por fim, veja se o temperamento do elemento ressoa com você. O objetivo é ancorar a leitura no formato antes de olhar as linhas.',
        pageTitle: 'O Elemento da Minha Mão',
        pagePurpose: 'Classificar o tipo elemental da mão e o que revela',
        pageCategory: SpellCategory.divination,
        pageIngredients: ['Sua mão dominante', 'Régua (opcional)'],
        pagePrompts: [
          'Formato da palma (quadrada ou retangular) e dos dedos (curtos ou longos):',
          'Meu elemento dominante (Terra, Ar, Fogo ou Água) — ou a mistura:',
          'O que o temperamento desse elemento diz sobre mim:',
          'O quanto isso ressoa com como eu me vejo:',
        ],
      ),
      TrailLesson(
        id: 'qm_03',
        recordKind: LessonRecordKind.note,
        title: 'A Linha da Vida',
        teaching:
            'A Linha da Vida é a que nasce entre o polegar e o indicador e desce curvando ao redor do monte de Vênus (a base do polegar). É a linha mais mal compreendida da quiromancia: ao contrário do mito popular, seu comprimento NÃO mede quanto tempo alguém vai viver. Ela fala de vitalidade, força física, entusiasmo pela vida e das grandes mudanças de rumo.\n\nO que se lê tecnicamente nela: a curvatura — quanto mais aberta, abraçando um monte de Vênus largo, mais calor, vigor e generosidade física; quanto mais reta e colada ao polegar, mais reserva e cautela de energia. A profundidade e a nitidez indicam a robustez da vitalidade. Ramificações para cima costumam marcar fases de crescimento e conquista; ilhas (aquele desenho de olho na linha) sugerem períodos de energia dividida ou saúde a cuidar; quebras e sobreposições apontam mudanças de vida — mudanças de cidade, de rumo, de fase — e não catástrofes.\n\nUm ponto técnico importante: a Linha da Vida se lê junto do monte de Vênus e da Linha do Destino, nunca sozinha. Uma linha "curta" pode simplesmente indicar que a vitalidade é sustentada por outra linha. Ao praticar, resista à tentação dramática de ler doença ou fim onde há apenas uma transição. Descreva o traçado, localize os sinais e traduza-os como capítulos de energia — abertos, e não fechados.',
        practice:
            'Nesta prática você vai mapear sua Linha da Vida. Primeiro, localize onde ela nasce e siga sua curva ao redor da base do polegar. Depois, observe: ela é aberta ou colada ao polegar? É profunda ou fina? Tem ramos, ilhas ou quebras? Por fim, anote o que cada traço sugere sobre sua vitalidade — sem transformar nenhum sinal em sentença. O objetivo é ler a linha mais mitificada com método e serenidade.',
        pageTitle: 'Minha Linha da Vida',
        pagePurpose: 'Registrar a leitura técnica da Linha da Vida',
        pageCategory: SpellCategory.divination,
        pageIngredients: ['Sua mão dominante', 'Boa luz'],
        pagePrompts: [
          'Como é o traçado da minha Linha da Vida (curva, profundidade):',
          'Ramos, ilhas ou quebras que encontrei — e onde:',
          'O que ela sugere sobre minha vitalidade e minhas viradas de vida:',
          'Um mito sobre essa linha que eu deixo para trás:',
        ],
      ),
      TrailLesson(
        id: 'qm_04',
        recordKind: LessonRecordKind.note,
        title: 'A Linha da Cabeça',
        teaching:
            'A Linha da Cabeça atravessa a palma horizontalmente, mais ou menos no meio, e fala do intelecto: como você pensa, aprende, decide e concentra. Ela costuma nascer perto do início da Linha da Vida, entre o polegar e o indicador, e segue em direção à borda oposta da mão. Sua leitura é uma das mais reveladoras do temperamento mental.\n\nOs sinais técnicos: o comprimento indica a amplitude do pensamento — uma linha longa, que cruza boa parte da palma, sugere mente detalhista e reflexiva; uma curta, pensamento direto e prático. A inclinação é decisiva: uma Linha da Cabeça reta indica raciocínio lógico, objetivo, "pé no chão"; uma que desce curvando em direção ao monte da Lua (base da palma, do lado oposto ao polegar) indica imaginação, criatividade e mente associativa. A profundidade fala de foco e memória; ilhas e correntes indicam períodos de dispersão ou preocupação.\n\nUm detalhe clássico e importante é como ela começa: unida à Linha da Vida no nascimento sugere cautela, apego à família e prudência ao agir; separada delas desde o início sugere independência precoce e impulsividade. Ao ler, cruze sempre a Linha da Cabeça com a do Coração — juntas, mostram o equilíbrio entre razão e emoção da pessoa. Descreva a direção, a nitidez e o ponto de partida antes de qualquer conclusão.',
        practice:
            'Nesta prática você vai ler sua Linha da Cabeça. Primeiro, localize-a no meio da palma e siga seu trajeto. Depois, observe: ela é reta (lógica) ou desce para a Lua (imaginativa)? É longa ou curta? Nasce unida ou separada da Linha da Vida? Por fim, registre o que revela sobre seu jeito de pensar e decidir. O objetivo é reconhecer o próprio estilo mental na palma.',
        pageTitle: 'Minha Linha da Cabeça',
        pagePurpose: 'Registrar a leitura da Linha da Cabeça e do estilo mental',
        pageCategory: SpellCategory.divination,
        pageIngredients: ['Sua mão dominante', 'Boa luz'],
        pagePrompts: [
          'Direção da minha Linha da Cabeça (reta ou curvada para a Lua):',
          'Comprimento e nitidez — e como nasce (unida ou separada da Vida):',
          'O que isso diz sobre como eu penso e decido:',
          'Onde a razão e a emoção se equilibram em mim:',
        ],
      ),
      TrailLesson(
        id: 'qm_05',
        recordKind: LessonRecordKind.note,
        title: 'A Linha do Coração',
        teaching:
            'A Linha do Coração é a mais alta das três grandes linhas, correndo horizontalmente sob os dedos. Ela fala da vida afetiva: como você ama, se vincula, expressa emoção e cuida dos relacionamentos. É lida a partir da borda da mão (lado do dedo mínimo) em direção aos dedos indicador e médio.\n\nA técnica olha primeiro onde ela termina. Uma Linha do Coração que sobe e termina sob o indicador (monte de Júpiter) indica idealismo no amor, entrega e altos padrões; terminando sob o médio (monte de Saturno) sugere um afeto mais realista, contido, às vezes mais voltado ao desejo que ao romance; terminando entre os dois, um equilíbrio maduro. Uma linha longa e curva expressa emoções com calor e abertura; uma curta e reta indica reserva ou dificuldade de verbalizar sentimentos. Ramos para cima marcam relações felizes e conexões importantes; ramos para baixo, decepções que ensinaram; correntes e ilhas, períodos de instabilidade afetiva.\n\nO erro comum é procurar na Linha do Coração o "número de grandes amores" ou datas exatas — quiromancia séria não faz isso. O que essa linha entrega é o estilo emocional: caloroso ou reservado, idealista ou pragmático, generoso ou protegido. Leia-a junto da Linha da Cabeça para entender como pensamento e sentimento conversam na pessoa, e descreva sempre a tendência, com respeito e sem drama.',
        practice:
            'Nesta prática você vai ler sua Linha do Coração. Primeiro, localize-a sob os dedos e veja onde termina (sob o indicador, o médio ou entre eles). Depois, observe se é longa e curva ou curta e reta, e procure ramos para cima e para baixo. Por fim, anote o que ela revela sobre seu estilo de amar. O objetivo é reconhecer sua assinatura emocional com gentileza.',
        pageTitle: 'Minha Linha do Coração',
        pagePurpose: 'Registrar a leitura da Linha do Coração e do estilo afetivo',
        pageCategory: SpellCategory.divination,
        pageIngredients: ['Sua mão dominante', 'Boa luz'],
        pagePrompts: [
          'Onde termina minha Linha do Coração e o que isso sugere:',
          'Ela é longa e curva ou curta e reta? Ramos que encontrei:',
          'O que revela sobre meu jeito de amar e me vincular:',
          'Como meu coração e minha cabeça conversam:',
        ],
      ),
      TrailLesson(
        id: 'qm_06',
        recordKind: LessonRecordKind.note,
        title: 'A Linha do Destino',
        teaching:
            'A Linha do Destino (ou Linha de Saturno) é uma linha vertical que sobe da base da palma em direção ao dedo médio. Nem todo mundo a tem forte — e sua ausência não é má sorte. Ela fala do senso de rumo, da carreira, do fio condutor que a pessoa sente (ou não) em sua trajetória, e das forças externas que moldam o caminho.\n\nTecnicamente, observa-se de onde ela parte. Nascendo da base do pulso, sugere um senso de propósito desde cedo; nascendo do monte da Lua, um caminho muito influenciado pelos outros, pelo público ou pelo acaso favorável; nascendo da Linha da Vida, uma trajetória construída por esforço próprio. Uma linha nítida e contínua indica um rumo estável; interrupções, mudanças de direção de carreira ou de vida; uma linha dupla, a capacidade de tocar dois caminhos ao mesmo tempo. Quando ela é fraca ou ausente, a pessoa costuma construir o próprio rumo com mais liberdade, sem um trilho pré-marcado — o que é uma leitura, não um veredito.\n\nA Linha do Destino é o melhor exemplo de por que a quiromancia lê tendências, e não sentenças: ela muda visivelmente ao longo da vida conforme as escolhas. Por isso é lida por último entre as verticais e sempre em diálogo com a Linha da Cabeça (as decisões) e a da Vida (a energia). Descreva a origem, a continuidade e as viradas — e lembre que aqui o mapa é desenhado, em boa parte, pela própria pessoa.',
        practice:
            'Nesta prática você vai procurar sua Linha do Destino. Primeiro, veja se há uma linha vertical subindo em direção ao dedo médio — e não se preocupe se for fraca ou ausente. Depois, se existir, observe de onde ela parte e se é contínua ou tem viradas. Por fim, anote o que ela sugere sobre seu senso de rumo. O objetivo é entender a linha que mais muda com as escolhas.',
        pageTitle: 'Minha Linha do Destino',
        pagePurpose: 'Registrar a leitura da Linha do Destino e do senso de rumo',
        pageCategory: SpellCategory.divination,
        pageIngredients: ['Sua mão dominante', 'Boa luz'],
        pagePrompts: [
          'Tenho Linha do Destino forte, fraca ou ausente? De onde ela parte:',
          'Continuidade e viradas que observei nela:',
          'O que ela sugere sobre meu senso de rumo e carreira:',
          'De que forma sinto que construo o meu próprio caminho:',
        ],
      ),
      TrailLesson(
        id: 'qm_07',
        recordKind: LessonRecordKind.note,
        title: 'Os montes',
        teaching:
            'Os montes são as almofadas de carne da palma, cada uma associada a um astro e a um conjunto de qualidades. Ler os montes é avaliar quais estão mais desenvolvidos (altos, firmes, rosados) e quais mais apagados — porque o relevo mostra onde a energia da pessoa se concentra. É a parte da quiromancia mais próxima da astrologia.\n\nOs principais: o monte de Vênus, na base do polegar, fala de amor, sensualidade, vitalidade e afeto pela vida — cheio e firme, calor e generosidade; achatado, reserva. O monte de Júpiter, sob o indicador, rege ambição, liderança e autoconfiança. O de Saturno, sob o médio, fala de responsabilidade, disciplina e introspecção. O de Apolo (ou Sol), sob o anelar, rege criatividade, expressão e brilho. O de Mercúrio, sob o mínimo, comunicação, astúcia e negócios. O monte da Lua, na base da palma do lado oposto ao polegar, rege imaginação, intuição e o mundo dos sonhos. E os montes de Marte (dois, um ativo entre polegar e indicador, outro passivo do lado oposto) falam de coragem, combatividade e resistência.\n\nA técnica é comparativa: nenhum monte se lê sozinho. Você observa qual se destaca — esse "vence" e colore o temperamento — e como os demais se equilibram. Um Júpiter alto com Saturno apagado desenha uma pessoa; o inverso, outra. Marcas sobre um monte (uma cruz, uma estrela, uma grade) intensificam ou perturbam sua qualidade, tema da próxima lição. Ao praticar, apalpe suavemente e compare relevos — descreva onde sua energia mora.',
        practice:
            'Nesta prática você vai mapear seus montes. Primeiro, com a mão relaxada e levemente curvada, observe e apalpe as almofadas sob cada dedo e na base do polegar e da palma. Depois, identifique quais são mais cheios e firmes e quais mais apagados. Por fim, anote qual monte se destaca e o que isso diz de você. O objetivo é localizar onde sua energia se concentra.',
        pageTitle: 'Meus Montes',
        pagePurpose: 'Registrar quais montes se destacam e o que revelam',
        pageCategory: SpellCategory.divination,
        pageIngredients: ['Sua mão dominante', 'Boa luz'],
        pagePrompts: [
          'Meu monte mais desenvolvido (Vênus, Júpiter, Saturno, Apolo, Mercúrio, Lua ou Marte):',
          'Montes mais apagados que percebi:',
          'O que esse equilíbrio diz sobre onde mora minha energia:',
          'Como isso dialoga com o elemento da minha mão:',
        ],
      ),
      TrailLesson(
        id: 'qm_08',
        recordKind: LessonRecordKind.note,
        title: 'Dedos, polegar e marcas especiais',
        teaching:
            'Além de linhas e montes, o quiromante lê os dedos, o polegar e as pequenas marcas. Os dedos recebem nomes dos mesmos astros dos montes que tocam: Júpiter (indicador), Saturno (médio), Apolo (anelar) e Mercúrio (mínimo). Avalia-se o comprimento relativo, a retidão ou inclinação, e o formato das pontas — pontudas (idealismo, sensibilidade), cônicas (arte, intuição), quadradas (ordem, praticidade) ou espatuladas (energia, inquietação). Um dedo de Apolo longo, por exemplo, reforça a expressão criativa; um Mercúrio tortinho, sagacidade nas palavras.\n\nO polegar é considerado por muitos quiromantes o dado mais importante da mão, porque representa a força de vontade e a razão. Vê-se seu tamanho (um polegar grande e firme indica vontade forte), a flexibilidade da ponta (rígida: teimosia e princípios firmes; flexível: adaptabilidade, generosidade) e o ângulo de abertura em relação à mão (aberto: mente livre e generosa; fechado: cautela e reserva). A falange da vontade (a ponta) e a da lógica (a do meio) devem ser comparadas: qual é mais longa mostra se a pessoa é mais movida por querer ou por raciocinar.\n\nPor fim, as marcas menores sobre linhas e montes afinam a leitura: a ilha (enfraquece, divide), a cruz (obstáculo ou ponto de virada), a estrela (evento intenso, brilho ou choque, conforme o local), a grade (energia bloqueada ou dispersa), o quadrado (proteção, reparo) e a trígona/triângulo (talento). Nenhuma marca é lida isolada — ela modifica a qualidade do lugar onde aparece. O bom leitor descreve a marca, o local e a interação, sempre como nuance, nunca como destino selado.',
        practice:
            'Nesta prática você vai ler seus dedos e polegar. Primeiro, compare o comprimento e o formato das pontas dos quatro dedos. Depois, estude o polegar: tamanho, flexibilidade da ponta e ângulo de abertura. Por fim, procure uma marca especial (ilha, cruz, estrela, grade, quadrado) em alguma linha ou monte e anote onde está. O objetivo é afinar o olhar para os detalhes que individualizam a leitura.',
        pageTitle: 'Meus Dedos, Polegar e Marcas',
        pagePurpose: 'Registrar a leitura dos dedos, do polegar e das marcas',
        pageCategory: SpellCategory.divination,
        pageIngredients: ['Suas duas mãos', 'Boa luz'],
        pagePrompts: [
          'Formato das pontas dos meus dedos e o que reforçam:',
          'Meu polegar (tamanho, flexibilidade, ângulo) e o que diz da minha vontade:',
          'Uma marca especial que encontrei e onde ela está:',
          'Como essa marca colore a qualidade daquele lugar:',
        ],
      ),
      TrailLesson(
        id: 'qm_09',
        recordKind: LessonRecordKind.note,
        tool: LessonTool.palmistry,
        title: 'A leitura completa',
        teaching:
            'Uma leitura completa não é a soma de fragmentos: é uma síntese. O quiromante experiente segue uma ordem que integra tudo o que você aprendeu. Primeiro o conjunto — mão dominante e passiva, textura, elemento do formato. Depois as três grandes linhas na sequência clássica: Vida (energia), Cabeça (mente), Coração (afeto). Em seguida a Linha do Destino (rumo). Então os montes (onde a energia mora) e, por fim, dedos, polegar e marcas (as nuances). Cada camada é lida à luz das anteriores.\n\nA arte está em cruzar os dados em vez de listá-los. Uma Linha da Cabeça imaginativa sobre uma mão de Água, com monte da Lua alto, contam a mesma história por três caminhos — e essa convergência é o que dá confiança à leitura. Contradições também informam: uma Linha do Coração reservada numa mão de Fogo revela uma tensão interessante entre calor e proteção. Comparar a mão passiva com a dominante mostra o movimento: o que era potencial e o que a pessoa desenvolveu. O bom leitor conta uma narrativa coerente, não um horóscopo de gaveta.\n\nDuas éticas fecham a arte. Primeira: quiromancia lê tendências, não sentenças — as linhas mudam, e nomear caminhos abertos é mais verdadeiro (e mais útil) que cravar destinos. Segunda: leia com cuidado. Jamais faça diagnósticos de saúde, previsões de morte ou promessas absolutas; devolva sempre à pessoa o poder de escolher. Agora você tem o método. Nesta última prática, junte tudo numa leitura sua — e, se quiser, use a Leitura de Mãos do app para comparar sua análise com a do Conselheiro Místico.',
        practice:
            'Nesta prática você fará sua primeira leitura completa. Primeiro, percorra na ordem: conjunto → Vida, Cabeça, Coração → Destino → montes → dedos e marcas. Depois, procure convergências (dados que se repetem) e contrastes (tensões interessantes) e escreva uma síntese em poucas frases. Por fim, abra a Leitura de Mãos do app, fotografe sua palma e compare a leitura da IA com a sua. O objetivo é integrar todo o método numa narrativa coerente e sua.',
        pageTitle: 'Minha Leitura Completa',
        pagePurpose: 'Integrar todo o método numa leitura de mão coerente',
        pageCategory: SpellCategory.divination,
        pageIngredients: ['Suas duas mãos', 'Boa luz', 'O app de Leitura de Mãos'],
        pagePrompts: [
          'Minha síntese do conjunto e das três grandes linhas:',
          'Convergências que encontrei (dados que se repetem):',
          'Contrastes interessantes entre linhas, montes e formato:',
          'O que a Leitura de Mãos do app acrescentou à minha análise:',
        ],
      ),
    ],
  ),
];
