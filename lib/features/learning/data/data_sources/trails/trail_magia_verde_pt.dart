import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trilha 'magia_verde' — conteúdo em português (idioma-base).
/// Paridade com _en/_es verificada em test/trails_parity_test.dart.
const LearningTrail magiaVerdeTrailPt = LearningTrail(
    id: 'magia_verde',
    emoji: '🌿',
    title: 'Magia Verde',
    subtitle: 'O caminho das ervas e da terra',
    description:
        'A bruxaria do jardim, da cozinha e da floresta: aprender com as plantas, seus ciclos e poderes — escrevendo o seu herbário mágico',
    lessons: [
      TrailLesson(
        id: 'mv_01',
        tool: LessonTool.addHerb,
        recordKind: LessonRecordKind.note,
        title: 'Conhecer uma planta de verdade',
        teaching:
            'A magia verde não começa decorando tabelas de correspondências — começa com UMA planta conhecida de verdade: nome, cheiro, textura, como ela reage à água e ao sol. Conhecer de perto uma única aliada vale mais do que memorizar cem nomes, porque a magia verde nasce de relação, não de catálogo. É por isso que este é o primeiro passo do caminho\n\nBruxas verdes tradicionais tinham relação profunda com poucas dúzias de plantas: sabiam colher na hora certa, agradeciam, usavam cada parte, da raiz à flor. O alecrim da janela, a arruda do portão e a hortelã do quintal eram vizinhas conhecidas, não itens de uma lista. Essa intimidade — observar a planta ao longo dos dias e das estações — é o que transforma informação em sabedoria\n\nNo cotidiano, isso significa escolher uma planta acessível — um vaso da sua casa, uma árvore do caminho — e visitá-la com atenção verdadeira. Observe as folhas, o perfume, a textura, como ela amanhece. O erro comum da iniciante é querer trabalhar com dez ervas de uma vez e não conhecer nenhuma de verdade. Vá devagar: uma aliada bem conhecida sustenta muita magia\n\nSua primeira página de magia verde é o retrato de uma aliada, escrito com os seus próprios sentidos. Guarde esta ideia como quem guarda uma semente: antes de usar uma planta, conheça a planta. Relação vem antes de feitiço — e é ela que dá raiz, força e verdade a tudo o que floresce depois no seu caminho',
        practice:
            'Passe 5 minutos com uma planta acessível usando os cinco sentidos com segurança. Primeiro observe cores e formas, depois toque com delicadeza, cheire as folhas e escute o ambiente ao redor — sem provar nada, pois nunca se leva à boca o que não se conhece com certeza. Por fim, anote 3 observações que nenhum livro daria. O objetivo é iniciar uma relação real com a sua primeira aliada verde. Para selar o encontro, fotografe a sua aliada pelo atalho abaixo e crie a página dela na sua enciclopédia de Ervas',
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
            'Água, fogo, planta e intenção: o chá é o ritual verde mais acessível que existe. Ele reúne os elementos essenciais da magia em uma xícara e cabe em qualquer rotina, em qualquer cozinha. A diferença entre tomar um chá e ritualizar um chá não está em ingredientes raros, e sim na presença com que você prepara e bebe cada gole\n\nRitualizar significa escolher a erva pela intenção — camomila para acalmar, hortelã para clarear, capim-limão para suavizar —, mexer em círculos no sentido do objetivo, horário para atrair e anti-horário para afastar, e beber em silêncio, deixando o calor levar a intenção para dentro. Curandeiras e avós sempre souberam: um chá feito com cuidado carrega muito mais do que princípios ativos\n\nNo cotidiano da bruxa iniciante, o chá ritual pode ser o momento mais mágico do dia: cinco minutos de fogão, vapor e silêncio. Segurança primeiro: use apenas plantas comestíveis conhecidas, respeite contraindicações e, na dúvida, não beba. O erro mais comum é preparar com pressa, mexendo no celular — presença é o ingrediente principal, e sem ela o rito vira rotina\n\nGuarde esta ideia: a xícara é um pequeno caldeirão que cabe nas suas mãos. Sempre que precisar de um ritual simples e imediato, lembre que água quente, uma erva segura e a sua intenção já formam um feitiço completo. Repetido com constância — sete dias, toda lua —, esse gesto pequeno se torna uma das práticas mais profundas da magia verde',
        practice:
            'Prepare um chá simples com presença total, do início ao fim. Primeiro escolha uma erva comestível conhecida e nomeie a intenção; depois aqueça a água observando o vapor, mexa em círculos no sentido do seu objetivo e coe com calma; por fim, beba em silêncio, sem celular, sentindo o calor levar a intenção para dentro. O objetivo é experimentar como a presença transforma um gesto comum em ritual',
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
            'O sachê é a magia verde portátil: ervas secas reunidas num saquinho de tecido, fechado com nó e palavra de poder. Ele leva a força das plantas para onde você for — debaixo do travesseiro para bons sonhos, na bolsa para proteção, no armário para harmonia. É um dos amuletos mais antigos e simples da bruxaria, e por isso mesmo um dos mais queridos\n\nA montagem clássica segue uma lógica de três partes: a erva principal, que carrega a intenção; uma erva de suporte, que amplia e equilibra; e um fixador — casca, raiz ou pedrinha — que ancora o trabalho no tempo. A cor do tecido conversa com o objetivo: vermelho para coragem, verde para prosperidade, branco para paz. Tradições populares do mundo inteiro usam variações desse mesmo desenho\n\nPara a iniciante, a própria cozinha já é um armário mágico: louro, alecrim, canela, cravo e camomila rendem combinações poderosas. O erro comum é acumular sachês sem propósito claro — cada um deve nascer de uma intenção definida e ganhar um lugar certo para viver. Quando sentir que ele cumpriu o papel, desfaça ou renove com gratidão, devolvendo as ervas à terra se puder\n\nLeve consigo esta imagem: um sachê é uma intenção embrulhada em pano e selada com um nó. Poucas ervas, propósito claro e palavra dita com firmeza valem mais do que dezenas de ingredientes misturados sem escuta. Onde quer que o seu saquinho viva — travesseiro, bolsa ou armário —, ele seguirá sussurrando a intenção que você amarrou nele',
        practice:
            'Separe ervas secas que você já tem na cozinha, como louro, alecrim e canela, e sinta qual combinação pede para existir. Primeiro defina a intenção; depois escolha a erva principal, a de suporte e um fixador, tocando e cheirando cada uma com calma; por fim, anote a combinação escolhida e a cor de tecido que conversa com o objetivo. A meta é treinar a escuta das plantas antes de montar o seu primeiro sachê',
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
            'A bruxa de cozinha sabe: panela é caldeirão, colher de pau é varinha, tempero é feitiço. A cozinha é o altar mais antigo da humanidade — o lugar onde fogo, água, terra e ar se encontram todos os dias. Cozinhar com intenção transforma alimento em magia e faz da rotina mais comum um espaço sagrado, sem precisar de nada além do que você já tem\n\nA tradição da magia de cozinha atravessa culturas e gerações: mexer no sentido horário para atrair, temperar nomeando o desejo em voz baixa, servir como quem abençoa. Cada ingrediente carrega correspondências — canela para prosperidade, alho para proteção, manjericão para harmonia — e o calor do fogo é o que sela a intenção no alimento, como um forno sela o pão\n\nNo dia a dia, você não precisa de receitas especiais: o arroz de todo dia pode ser encantado. Comece nomeando uma intenção antes de acender o fogo e declare algo a cada ingrediente-chave que entrar na panela. O erro comum é cozinhar com raiva ou pressa — o alimento absorve o estado de quem prepara, então respire fundo antes de começar e cozinhe como quem reza\n\nGuarde esta verdade simples: a refeição encantada mais poderosa é a feita para alguém que você ama, incluindo você mesma. Não espere ocasiões especiais — o altar da cozinha se acende todos os dias. Sempre que cozinhar, lembre que as suas mãos já são instrumentos mágicos e que cada panela no fogo pode ser um feitiço em andamento',
        practice:
            'Cozinhe algo simples hoje transformando o preparo em feitiço. Primeiro escolha a receita e defina uma intenção clara; depois, a cada ingrediente adicionado, declare em voz baixa o que ele traz — proteção, doçura, força; mexa no sentido horário para atrair e finalize servindo como quem abençoa. O objetivo é sentir na prática como a intenção muda a sua relação com o alimento e com quem o recebe',
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
            'Plantar uma semente com intenção é o feitiço de longa duração da magia verde: o crescimento da planta espelha o crescimento do desejo. Enquanto muitos feitiços buscam resultado rápido, o plantio ensina a magia do tempo — aquilo que você semeia com cuidado hoje se torna força enraizada amanhã, no vaso e na vida\n\nA estrutura é simples e antiga: vaso, terra, semente, palavra. Camponesas e curandeiras sempre plantaram nomeando desejos — um alecrim para a saúde da casa, um manjericão para a fartura da mesa. Depois do gesto inicial vem o verdadeiro trabalho: cuidar todos os dias, regar, dar sol, observar. O feitiço não está apenas no plantio; está na constância que o sustenta\n\nPara a iniciante, até um grão de feijão no algodão serve de começo. O erro comum é plantar com entusiasmo e esquecer na primeira semana — e aqui mora a lição: se a planta murcha, o recado também é mágico. Pergunte a si mesma que cuidado está faltando, ali no vaso e na intenção que ele carrega. Ajuste a rega, ajuste a vida, e recomece sem culpa\n\nLeve esta ideia: toda intenção é uma semente e todo cuidado diário é o feitiço continuando em silêncio. Plante devagar, cuide com constância e confie no tempo da terra — ele raramente é o nosso, e quase sempre é o certo. Quando o primeiro broto aparecer, você vai entender por que a magia mais duradoura é a que cresce devagar',
        practice:
            'Plante uma semente ou muda — até um grão de feijão serve — dedicando o plantio a uma intenção de crescimento. Primeiro prepare vaso e terra com calma; depois plante dizendo em voz alta o que deseja ver crescer junto com ela; por fim, assuma um compromisso simples de cuidado diário, como regar e observar. O objetivo é viver um feitiço lento, em que cuidar da planta é cuidar da própria intenção',
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
            'A fumaça de ervas é a vassoura energética da magia verde: onde o denso se acumula, ela passa, solta e renova. Defumar é uma das práticas de limpeza mais antigas da humanidade, presente em incontáveis tradições ao redor do mundo, e continua sendo um dos ritos mais diretos para mudar a sensação de um espaço — e de quem vive nele\n\nCada erva tem seu ofício na fumaça: alecrim para renovar, louro para prosperar, arruda para cortar o que pesa. O rito tradicional percorre a casa dos fundos para a porta de entrada, passando pelos cantos e atrás das portas, sempre com janelas abertas — o denso sai, o novo entra. A direção do trajeto importa tanto quanto a erva escolhida: você conduz a limpeza para fora\n\nNo cotidiano, comece pequeno: um cômodo, uma erva, um recipiente resistente ao fogo. Respeite alergias, animais e vizinhos, e nunca deixe brasas sem vigilância. Atenção também à origem das ervas: magia verde é responsabilidade ecológica, então prefira o que você cultiva ou compra de fontes conscientes. O erro comum é defumar com a casa fechada — sem saída, o denso não vai embora\n\nGuarde a imagem: a fumaça é oração visível e vassoura invisível ao mesmo tempo. Quando o ambiente pesar — depois de uma discussão, de uma semana difícil, de uma visita que deixou rastro —, lembre que uma erva seca, uma brasa segura e janelas abertas bastam para renovar o ar. O de fora e, com um pouco de presença, também o de dentro',
        practice:
            'Defume um único cômodo hoje com uma erva que você já tenha em casa. Primeiro abra as janelas e acenda a erva num recipiente resistente ao fogo; depois percorra o espaço com calma, dos fundos em direção à saída, levando a fumaça aos cantos e atrás da porta; por fim, apague tudo com segurança e sente-se um instante. O objetivo é observar a mudança na sensação do espaço antes e depois do rito',
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
            'O óleo condimentado é a poção de uso contínuo da bruxa verde: azeite ou óleo vegetal, ervas e tempo. Diferente do chá, que se faz e se bebe na hora, o óleo amadurece devagar e depois acompanha você por semanas — ungindo velas, amuletos, pulsos e portas com a intenção que ele carrega desde o primeiro dia\n\nO preparo tradicional é paciente: ervas dentro de um vidro escuro coberto de óleo, descansando por cerca de três semanas, agitado diariamente enquanto você renova a intenção em voz baixa ou em pensamento. Ao final, coa-se e guarda-se ao abrigo da luz. Alecrim no azeite para vitalidade e alho para proteção são exemplos clássicos das cozinhas e boticas de sempre\n\nNo dia a dia, o óleo vira uma ferramenta discreta: uma gota na vela antes de acender, um toque nos pulsos antes de uma conversa difícil, um traço no batente da porta. Rotule sempre com nome, data e propósito — bruxa organizada é bruxa poderosa. O erro comum é esquecer o vidro no fundo do armário: sem a agitação diária, o feitiço perde o fio. E use na pele apenas ervas e óleos seguros\n\nLeve esta síntese: óleo mágico é intenção que amadurece no escuro, gota a gota, dia após dia. Tempo, constância e rótulo bem feito transformam um vidro simples numa poção que trabalha por você durante semanas. Comece hoje o seu primeiro vidro e deixe que as três semanas de espera sejam, elas mesmas, parte do feitiço',
        practice:
            'Comece hoje um óleo simples, como alecrim no azeite, dedicado a uma intenção. Primeiro higienize um vidro escuro e coloque a erva coberta de óleo; depois agite o vidro todos os dias repetindo a intenção, por cerca de três semanas; por fim, coe, rotule com nome, data e propósito e registre o primeiro uso. Use apenas ervas seguras e não ingira o preparo. O objetivo é praticar a magia paciente, que amadurece com o tempo',
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
            'A lua é a grande regente dos ritmos da magia verde. A tradição planta o que cresce para cima na lua crescente e raízes na minguante; colhe folhas de poder na cheia; descansa a terra na nova. Alinhar o trabalho verde às fases lunares é entrar no compasso que jardineiras e bruxas seguem há gerações — o compasso do céu marcando o tempo da terra\n\nEsse saber vem dos almanaques rurais e da observação paciente do céu: a crescente favorece começos e expansão, a cheia é o auge da força — hora de colher folhas e celebrar —, a minguante pede poda e desapego, e a nova convida ao repouso e ao planejamento. Mais que agricultura, é treino de paciência mágica: nem tudo é para agora, e cada coisa tem a sua lua certa\n\nNo cotidiano, você não precisa de horta para praticar: regar, podar folhas secas, trocar um vaso de lugar ou simplesmente planejar já são ações verdes que podem seguir a lua. O Calendário Lunar do app é o seu almanaque de bolso — consulte a fase antes de agir. O erro comum é forçar começos na minguante e se frustrar: respeitar o descanso também é magia\n\nGuarde o compasso: crescente começa, cheia colhe, minguante solta, nova descansa. Quando estiver em dúvida sobre o momento certo de agir, olhe para o céu — ou para o seu almanaque de bolso — e pergunte em que lua você está. Com o tempo, esse compasso deixa de ser consulta e vira instinto: o seu jardim e a sua vida passam a girar juntos com a lua',
        practice:
            'Descubra a fase da lua de HOJE no Calendário Lunar do app e faça uma ação verde alinhada a ela: plantar ou começar algo na crescente, colher ou celebrar na cheia, podar ou soltar na minguante, descansar e planejar na nova. Primeiro consulte a fase, depois escolha o gesto que combina com ela e realize com presença; por fim, anote o que fez. O objetivo é começar a viver os ciclos em vez de apenas conhecê-los',
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
        tool: LessonTool.addHerb,
        recordKind: LessonRecordKind.gratitude,
        title: 'Colheita e agradecimento',
        teaching:
            'Colher é a metade esquecida do plantio. Muita gente aprende a semear e a cuidar, mas poucas aprendem a receber com reverência o que a terra entrega. Na magia verde, a colheita é um rito completo em si mesma — e a forma como você colhe diz tanto sobre a sua prática quanto a forma como você planta\n\nA colheita ritual tradicional pede quatro gestos: a hora certa — pela tradição, a manhã, depois que o orvalho seca —, o pedido de licença à planta antes de tocar, o corte limpo que não machuca além do necessário e o agradecimento sincero. E uma regra de ouro: uso íntegro, nada colhido à toa. Era assim que as curandeiras colhiam suas ervas de poder, com o respeito de quem visita uma mestra\n\nNo dia a dia, isso vale até para uma folha do seu vaso ou um fruto escolhido na feira com presença: pare, peça licença em pensamento, colha com delicadeza, agradeça. O erro comum é colher no automático, como quem pega um objeto qualquer — a pressa quebra o elo. E lembre: o mesmo rito serve para as colheitas simbólicas da vida — reconhecer o que chegou, agradecer e usar bem\n\nLeve consigo a regra de ouro da bruxa verde: nada colhido à toa. Licença, corte limpo, gratidão e uso íntegro — quatro gestos simples que transformam o ato de receber em cerimônia. Pratique-os na planta e depois na vida: quem aprende a colher com reverência descobre que a gratidão é, ela mesma, uma forma de adubo para as próximas colheitas',
        practice:
            'Colha algo hoje com o rito completo — pode ser uma folha do seu vaso ou um fruto da feira escolhido com presença. Primeiro pare diante da planta e peça licença em silêncio; depois faça o corte ou a escolha com delicadeza; em seguida agradeça com palavras suas; por fim, use integralmente o que colheu, sem desperdício. O objetivo é aprender a receber com a mesma reverência com que se planta. Se colheu uma planta que ainda não tem página sua, fotografe-a pelo atalho abaixo e adicione-a à sua enciclopédia de Ervas',
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
        tool: LessonTool.addHerb,
        recordKind: LessonRecordKind.note,
        title: 'Seu herbário mágico',
        teaching:
            'A última página desta trilha é, na verdade, uma capa: a abertura do seu herbário mágico, a lista viva das suas plantas aliadas com os usos testados por VOCÊ. Mais do que um caderno de anotações, o herbário é o retrato da sua relação com o mundo verde — único, pessoal e intransferível, como toda magia que nasce da experiência\n\nAs bruxas verdes de antigamente guardavam seus saberes em cadernos de receitas, folhas prensadas e memória passada entre gerações. O valor desses registros nunca esteve na quantidade, e sim na verdade: cada erva anotada tinha sido colhida, preparada e observada de perto. O seu herbário segue essa mesma tradição — ele nunca está pronto, cresce a cada estação, como o jardim\n\nDaqui em diante, cada planta nova merece uma página própria no seu grimório: nome, observações diretas, usos que você mesma testou, receitas que funcionaram. Releia as suas páginas verdes de tempos em tempos e visite a Enciclopédia de Ervas quando quiser escolher a próxima aliada. O erro comum é copiar tabelas prontas sem vivência — registre apenas o que passou pelas suas mãos\n\nLeve esta certeza: você começou a trilha conhecendo uma única planta e termina com um caminho inteiro pela frente. O herbário cresce no ritmo do jardim — uma aliada de cada vez, uma estação de cada vez, uma página de cada vez. A terra tem tempo, e agora você também: siga escrevendo, e o seu grimório verde florescerá junto com você',
        practice:
            'Encerre a trilha organizando o seu índice vivo. Primeiro releia as páginas verdes que você escreveu ao longo das lições, anotando cada planta e o uso que realmente testou; depois visite a Enciclopédia de Ervas e escolha a próxima aliada que deseja conhecer; por fim, registre por que ela chamou você. O objetivo é consolidar o que foi vivido e abrir espaço para o herbário seguir crescendo estação após estação. E inaugure a próxima página agora: fotografe uma planta sua pelo atalho abaixo e crie a página dela na sua enciclopédia de Ervas',
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
  );
