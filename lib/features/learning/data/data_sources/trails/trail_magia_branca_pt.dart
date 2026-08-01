import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trilha 'magia_branca' — conteúdo em português (idioma-base).
/// Paridade com _en/_es verificada em test/trails_parity_test.dart.
const LearningTrail magiaBrancaTrailPt = LearningTrail(
    id: 'magia_branca',
    emoji: '🕯️',
    title: 'Magia Branca',
    subtitle: 'Luz, proteção e bênçãos',
    description:
        'O caminho da intenção luminosa: proteção, cura e bênçãos para si e para quem você ama. Dez lições, dez páginas escritas por você',
    lessons: [
      TrailLesson(
        id: 'mb_01',
        recordKind: LessonRecordKind.note,
        title: 'A intenção é o coração',
        teaching:
            'Toda magia começa antes da vela, do cristal ou da palavra: começa na intenção. Ela é o coração de qualquer trabalho porque direciona a energia que você move. Na magia branca, a intenção é formulada de forma clara, positiva e no tempo presente — em vez de dizer que quer parar de ter medo, você afirma que caminha protegida e confiante. É essa clareza que transforma um desejo vago em um ato mágico\n\nUma boa intenção tem três marcas: é específica, é sua — nunca tenta controlar a vontade dos outros — e é dita como se já fosse realidade. Essa estrutura aparece em tradições diversas, das orações antigas às afirmações modernas, porque a mente responde melhor a imagens concretas e presentes. Praticantes experientes passam mais tempo lapidando a frase do que montando o altar, pois sabem que a palavra certa carrega o trabalho inteiro\n\nNo cotidiano da bruxa iniciante, a intenção aparece antes de tudo: ao acender uma vela, preparar um banho ou abrir o caderno. Um erro comum é acumular vários pedidos numa frase só ou usar negações, que mantêm o foco no problema. Outro é formular às pressas. Reserve alguns minutos, escreva, leia em voz alta e observe se o corpo responde: uma intenção viva costuma dar um leve arrepio de reconhecimento\n\nLeve com você esta ideia: a magia começa na frase que você escolhe. Antes de qualquer ferramenta, lapide a sua intenção até que ela seja clara, sua e presente. Quando a palavra está certa, todo o resto do ritual apenas a acompanha — a vela ilumina, o gesto sela, mas quem conduz é o coração que soube dizer o que deseja',
        practice:
            'Nesta prática você vai lapidar uma intenção importante. Primeiro, escreva três versões diferentes da mesma intenção no papel. Depois, revise cada uma cortando negações, promessas para um futuro distante e desejos sobre outras pessoas. Por fim, leia as três em voz alta e escolha a que soa mais viva no corpo. O objetivo é treinar a clareza que sustenta toda magia branca: uma frase específica, sua e dita no presente',
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
            'O círculo é a tecnologia mais antiga da magia: um limite simbólico que separa o espaço sagrado do cotidiano. Ele importa porque a mente precisa de fronteiras para mudar de estado — ao traçar o círculo, você avisa a si mesma que ali dentro, naquele momento, tudo é diferente. É a moldura que protege e concentra qualquer trabalho de magia branca\n\nTradições do mundo inteiro traçam círculos: com sal, giz, cordão, o dedo apontado ou pura visualização. O material importa menos que o gesto consciente. Em muitas linhagens, caminha-se no sentido do sol para abrir e no sentido contrário para desfazer. E o que se abre, se fecha: encerrar o círculo agradecendo é tão importante quanto traçá-lo, pois devolve o espaço ao cotidiano sem deixar portas abertas\n\nNo dia a dia, a iniciante pode traçar um círculo antes de meditar, escrever no grimório ou acender uma vela. Não precisa de espaço grande: um círculo imaginado ao redor da cadeira já funciona. Erros comuns: sair do círculo no meio do trabalho sem necessidade e esquecer de desfazê-lo ao final. Comece simples, com sal ou visualização, e repita até o gesto virar memória do corpo\n\nGuarde esta chave: o círculo é um gesto de consciência, não de material. Onde você traça um limite com presença, nasce um espaço sagrado — e onde você o desfaz com gratidão, o cotidiano volta em paz. Abrir e fechar, sempre nessa ordem: esse é o ritmo silencioso de toda proteção bem feita',
        practice:
            'Nesta prática você vai criar seu primeiro espaço sagrado. Primeiro, trace um círculo ao seu redor — com sal, um gesto ou pura visualização. Depois, permaneça três minutos em silêncio dentro dele, apenas percebendo a diferença no ar e no corpo. Por fim, desfaça o círculo com consciência, agradecendo. O objetivo é sentir na pele que abrir e fechar um limite muda o estado interno — a base de toda proteção mágica',
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
            'A bênção é a forma mais generosa da magia branca: desejar ativamente o bem de alguém sem controlar o caminho de ninguém. Ela importa porque muda a direção da prática — em vez de pedir para si, você irradia para fora. Abençoar treina o coração na abundância e lembra que a magia também é serviço, não apenas conquista pessoal\n\nA estrutura clássica da bênção tem três passos: nomear quem recebe, declarar o bem desejado e selar com um gesto — as mãos sobre o coração, um sopro, um toque na água. Culturas inteiras se organizaram em torno de bênçãos: sobre alimentos, casas, viagens e nascimentos. A regra de ouro atravessa todas elas: abençoe sem esperar retorno e jamais para influenciar decisões alheias — isso já seria outra coisa\n\nNo cotidiano, a bênção cabe em qualquer lugar: um pensamento bom ao cruzar com um vizinho, uma palavra silenciosa sobre a comida, um desejo de paz ao entrar em casa. O erro mais comum da iniciante é disfarçar um pedido de controle como bênção — desejar que alguém tome certa decisão, por exemplo. Abençoe a pessoa como ela é hoje, não como você gostaria que fosse\n\nLeve esta ideia no bolso: abençoar é desejar o bem e soltar o resultado. Quando você abençoa sem controlar, a energia flui limpa e volta em forma de leveza. Um coração que abençoa todos os dias nunca pratica magia pequena — ele transforma cada encontro em um altar discreto',
        practice:
            'Nesta prática você fará sua primeira bênção consciente. Primeiro, escolha alguém querido e traga o rosto dessa pessoa à mente. Depois, durante um minuto inteiro, deseje o bem dela em silêncio — exatamente como ela é hoje, sem corrigir nada, sem pedir mudanças. Por fim, sele com um gesto simples, como a mão sobre o coração. O objetivo é experimentar a magia que flui para fora: desejar o bem sem controlar o caminho de ninguém',
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
        tool: LessonTool.addColor,
        title: 'A vela: chama e foco',
        teaching:
            'A vela é o altar portátil da magia branca: fogo que concentra a intenção num único ponto de luz. Ela importa porque reúne muito poder em um objeto simples — a cera que vem da terra, o pavio que respira o ar e a chama que transforma. Poucas ferramentas oferecem tanto foco com tão pouco, e por isso a vela costuma ser a primeira companheira da bruxa\n\nCada detalhe conversa com o objetivo. A cor da vela dialoga com a intenção — consulte a Enciclopédia de Cores para escolher com consciência. Ungir a vela com óleo é vesti-la para o trabalho, e riscar símbolos na cera grava o pedido na matéria antes de entregá-lo à chama. Tradições de velas existem em quase toda prática devocional: a chama sempre foi vista como mensageira entre mundos\n\nPara a iniciante, a vela é o ritual mais acessível: acender com intenção clara, observar a chama, apagar com gratidão. Erros comuns: pressa para pedir sem preparar a intenção e descuido com o fogo. Segurança é parte do ritual: vela acesa nunca fica sozinha, sempre longe de cortinas e sobre superfície firme. Comece com a vela branca, que serve a todo propósito luminoso\n\nMemorize esta chave: a chama é o seu foco tornado visível. Quando você acende uma vela com presença, ela sustenta a intenção enquanto queima. Cuide do fogo como cuida do desejo — com atenção, respeito e constância — e a vela será sempre um altar completo cabendo na palma da mão',
        practice:
            'Nesta prática você vai treinar presença diante do fogo. Primeiro, prepare um lugar seguro e acenda uma vela branca. Depois, durante dez minutos, apenas observe a chama — o movimento, a cor, a dança — sem pedir absolutamente nada. Por fim, apague com gratidão ou deixe queimar em segurança. O objetivo é construir intimidade com a ferramenta antes de usá-la: quem sabe contemplar a chama aprende a focar a própria intenção. Aproveite para registrar a cor escolhida: fotografe-a pelo atalho abaixo e crie o verbete dela na sua enciclopédia de Cores',
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
            'Água e sal formam a combinação mais antiga de purificação que a humanidade conhece. A água lustral é a versão consagrada dessa dupla: um preparado simples que limpa objetos, espaços e a própria energia antes dos trabalhos. Ela importa porque toda magia pede terreno limpo — trabalhar em ambiente carregado é como plantar em solo cansado\n\nO preparo é um ritual em si: água limpa, uma pitada de sal, as mãos pousadas sobre o recipiente e uma palavra de consagração dita com presença. Templos antigos mantinham vasilhas de água à entrada para purificar quem chegava — a lógica é a mesma. O sal desfaz e a água carrega: juntos, dissolvem o que pesa e levam embora o que não serve mais\n\nNo cotidiano, a água lustral aparece borrifada pelos cantos da casa, ungindo a testa e os pulsos antes de um ritual ou lavando ferramentas recém-chegadas. Guarde em recipiente bonito e renove com frequência — água parada por muitas semanas perde o viço. Dois cuidados essenciais: nunca beba a água lustral e não pule a consagração, pois sem a palavra ela é apenas água com sal\n\nA chave desta lição: limpar é preparar. Antes de pedir, purifique; antes de plantar, cuide do solo. Uma bruxa que mantém sua água lustral viva mantém também o hábito mais importante da prática — começar cada trabalho em terreno claro, leve e pronto para receber',
        practice:
            'Nesta prática você vai preparar sua primeira água lustral. Primeiro, escolha um recipiente bonito, encha com água limpa e acrescente uma pitada de sal. Depois, pouse as mãos sobre ele e diga uma palavra de consagração com presença. Por fim, use essa água para limpar um objeto que você usa todos os dias, passando algumas gotas com intenção. O objetivo é sentir como a purificação prepara o terreno para toda magia',
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
            'Nem todo dia tem altar — mas todo dia tem mundo. O escudo energético é a proteção portátil da bruxa: uma barreira invisível criada pela imaginação treinada, que filtra o que chega de fora. Ele importa porque a sensibilidade que a prática desperta também pede defesa — quem sente mais precisa aprender a se resguardar mais\n\nO escudo funciona por visualização repetida: uma esfera de luz ao redor do corpo, um manto que envolve, espelhos que devolvem o que não é seu. Cada tradição tem sua imagem preferida, mas o princípio é o mesmo — a mente treinada cria fronteiras energéticas reais para quem as habita. O gesto-gatilho, discreto e sempre igual, é o interruptor que ativa tudo em segundos\n\nNo cotidiano, o escudo aparece antes de sair de casa, em reuniões tensas, no transporte lotado. O segredo é o treino: escudo se constrói em casa, com calma e repetição, para funcionar no ônibus cheio. O erro clássico da iniciante é tentar criar a proteção pela primeira vez no meio da crise — sem treino prévio, a imagem não se sustenta. Pratique um pouco todos os dias\n\nGrave esta ideia: proteção é hábito, não emergência. Alguns minutos diários de visualização criam um escudo que responde ao seu gesto em qualquer lugar. A bruxa protegida não é a que nunca encontra peso no mundo — é a que sabe voltar depressa para a própria luz',
        practice:
            'Nesta prática você vai construir seu escudo pessoal. Primeiro, sente-se em um lugar tranquilo e visualize por cinco minutos uma esfera de luz envolvendo todo o seu corpo — perceba a cor, o brilho, a textura. Depois, escolha um gesto discreto, como tocar um anel ou cruzar os dedos, e repita-o enquanto a imagem está viva. O objetivo é associar gesto e escudo, criando um gatilho que ativa sua proteção em segundos, onde você estiver',
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
            'O banho ritual transforma o ato mais cotidiano em rito de cura: água morna, ervas ou sal, luz baixa e intenção. Ele importa porque une o corpo à magia — a pele sente, o vapor envolve e a mente entende, sem esforço, que algo está sendo lavado por dentro também. É a cura mais acessível da magia branca: você já toma banho todos os dias\n\nA tradição distingue direções: do pescoço para baixo, o banho limpa e descarrega, preservando a cabeça, centro da consciência; da cabeça para baixo, apenas com ervas suaves, renova por completo. Banhos de ervas atravessam culturas — das casas de cura às aldeias antigas — sempre com a mesma gramática: preparar com intenção, despejar com presença, deixar o corpo secar naturalmente quando possível\n\nNa rotina da iniciante, o banho ritual pode fechar a semana ou preceder trabalhos importantes. Prepare tudo antes: erva ou sal, vela acesa em local seguro no banheiro, celular longe. Erros comuns: pressa, banho tomado no piloto automático e ervas fortes demais sem conhecimento. Comece com o simples — sal grosso ou camomila — e cresça aos poucos, anotando o que funciona\n\nLeve esta chave: o essencial é sair do banho diferente de como entrou — e nomear essa diferença. Água que corre leva o que pesa; intenção que guia chama o que renova. Com presença, o seu chuveiro pode se tornar o templo mais fiel e constante de toda a sua prática',
        practice:
            'Nesta prática você vai transformar o banho de hoje em ritual. Primeiro, deixe o celular fora do banheiro e, se quiser, acenda uma vela em local seguro. Depois, tome o banho sem pressa alguma, visualizando a água levando embora tudo o que pesa — preocupações, cansaço, restos do dia. Por fim, ao fechar o chuveiro, respire fundo e nomeie em silêncio como você se sente. O objetivo é experimentar a cura mais simples que existe: água, presença e intenção',
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
        tool: LessonTool.addCrystal,
        title: 'Amuletos de luz',
        teaching:
            'O amuleto é intenção condensada em matéria: um objeto pequeno, consagrado para um único propósito e carregado junto ao corpo. Ele importa porque estende a magia para além do ritual — enquanto você vive o seu dia, o amuleto segue trabalhando em silêncio, lembrando à sua energia o que foi combinado diante do altar\n\nNa magia branca, os clássicos são amuletos de proteção — o olho, o sal, a arruda — e de bênção, como medalhas e pedras claras. A consagração segue quatro passos simples: limpar o objeto, declarar seu propósito em voz alta, energizar sob a luz da lua, perto de uma chama ou com o próprio sopro, e portar com fé. Povos de todas as eras carregaram amuletos: levar a proteção consigo é um desejo tão antigo quanto o caminho\n\nPara a iniciante, o melhor amuleto costuma ser um objeto que já tem história com você — um anel herdado, uma pedra achada, uma medalha querida. Erros comuns: acumular vários propósitos num mesmo objeto, o que dilui a força, e esquecer de limpá-lo de tempos em tempos. Um propósito por amuleto e uma limpeza ocasional, e ele serve por anos\n\nA ideia para guardar: o amuleto é um pacto silencioso entre você e um objeto. Consagre com clareza, carregue com fé e renove com cuidado, e ele responderá com constância. Assim, mesmo nos dias sem altar e sem vela, um pedaço da sua magia caminha junto ao seu corpo, para onde quer que você vá',
        practice:
            'Nesta prática você vai escolher seu primeiro amuleto de luz. Primeiro, olhe ao redor e encontre um objeto pequeno que você já ama e que tenha história com você. Depois, segure-o nas mãos e pergunte-se em silêncio qual propósito único ele vai servir — proteção ou bênção. Por fim, guarde-o em um lugar especial até registrar a consagração na sua página. O objetivo é entender que o poder do amuleto nasce do vínculo: um objeto, um propósito, uma fé. Se o seu amuleto for uma pedra, fotografe-a pelo atalho abaixo e crie o verbete dela na sua enciclopédia de Cristais',
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
            'A magia branca brilha nos dias escuros: um velório, um diagnóstico, um término. Nesses momentos ela não resolve — acompanha. E isso importa porque a prática que só serve para os dias bons abandona a bruxa exatamente quando ela mais precisa. Um rito de travessia dá chão quando o chão parece faltar sob os pés\n\nO ritual mínimo para atravessar tem quatro gestos: acender uma chama, nomear a dor em voz alta, pedir força — não solução — e agradecer por estar viva para sentir. Ritos de passagem existem em toda cultura humana justamente porque a dor precisa de forma: quando ganha nome, vela e palavra, ela deixa de ser um mar sem margem e se torna um rio que se atravessa\n\nNo cotidiano, isso significa ter seu rito pronto antes da tempestade: três passos simples que o corpo conhece de cor. O erro mais comum é exigir da magia o que ela não promete — apagar a dor, trazer alguém de volta, mudar o diagnóstico. Se a dor for grande demais, procure também apoio humano e profissional: magia madura caminha junto com o cuidado, nunca no lugar dele\n\nGuarde esta sabedoria: magia madura sabe a diferença entre transformar e aceitar. Nos dias escuros, acenda a chama, nomeie a dor e peça força para atravessar. Você não precisa vencer a noite inteira de uma vez — só precisa de luz suficiente para dar o próximo passo',
        practice:
            'Nesta prática você vai experimentar um rito de travessia. Primeiro, pense em uma dor atual ou antiga que ainda mereça acolhimento. Depois, acenda uma vela branca em local seguro e, olhando a chama, diga em voz alta: eu te vejo, eu te atravesso, eu peço força. Por fim, fique alguns instantes em silêncio e agradeça por estar viva para sentir. O objetivo é dar forma à dor com nome, chama e palavra, pedindo força em vez de solução',
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
            'Todo trabalho de magia branca termina no mesmo lugar: a gratidão. Agradecer fecha o circuito da energia, reconhecendo o recebido antes mesmo de ver resultados. Importa porque um final bem feito protege o trabalho inteiro — ritual sem encerramento é porta entreaberta, e a gratidão é a chave que gira suave na fechadura\n\nA gratidão é também a proteção mais subestimada da prática: um coração agradecido não opera pela carência, e magia feita da falta tende a atrair mais falta. Tradições do mundo todo encerram seus ritos agradecendo — às forças invocadas, ao espaço, ao próprio corpo. O agradecimento devolve cada coisa ao seu lugar e sela o que foi feito, como quem assina uma carta antes de enviá-la\n\nNo cotidiano, o encerramento vira assinatura pessoal: um gesto sempre igual, uma frase curta de gratidão, um sopro na vela. Repetido ao final de cada trabalho, ele ensina ao corpo que o rito terminou. O erro comum é sair correndo do altar assim que o pedido é feito — dedique ao final o mesmo carinho que dedicou ao começo. Nesta última página, você cria o seu ritual de encerramento\n\nLeve consigo a última chave desta trilha: a gratidão é começo e fim de toda magia branca. Agradeça antes de ver, agradeça depois de receber, agradeça até nos dias em que só houve travessia. Quem encerra com gratidão nunca sai de um ritual de mãos vazias — essa é a sua assinatura mágica',
        practice:
            'Nesta prática você vai encerrar a trilha como quem fecha uma cerimônia. Primeiro, respire fundo e olhe para trás, relembrando as lições que atravessou. Depois, liste cinco coisas que a sua prática já trouxe para a sua vida — pequenas ou grandes, todas contam. Por fim, leia a lista em voz alta, devagar, como as palavras finais de um rito. O objetivo é fechar o circuito da energia com gratidão, selando tudo o que você construiu até aqui',
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
  );
