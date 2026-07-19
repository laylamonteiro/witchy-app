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
        'O caminho da intenção luminosa: proteção, cura e bênçãos para si e para quem você ama. Cada lição termina com uma página escrita por você no seu grimório.',
    lessons: [
      TrailLesson(
        id: 'mb_01',
        title: 'A intenção é o coração',
        teaching:
            'Toda magia começa antes da vela, do cristal ou da palavra: começa na intenção. Na magia branca, a intenção é formulada de forma clara, positiva e presente — não "quero parar de ter medo", mas "eu caminho protegida e confiante".\n\nUma boa intenção tem três marcas: é específica (você sabe quando ela se realizou), é sua (não tenta controlar a vontade dos outros) e é dita como se já fosse (o inconsciente não trabalha bem com "talvez um dia").\n\nAntes de qualquer ritual, praticantes experientes passam mais tempo lapidando a frase da intenção do que montando o altar. É essa frase que você vai gravar na sua primeira página.',
        practice:
            'Escreva 3 versões de uma intenção importante para você agora. Corte palavras negativas, futuro distante e desejos sobre outras pessoas. Escolha a versão mais viva.',
        pageTitle: 'Minha Intenção de Luz',
        pagePurpose: 'Formular e consagrar uma intenção clara',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['1 vela branca', 'Papel e caneta'],
        pageStepsTemplate:
            '1. Escreva aqui a versão final da sua intenção:\n___\n\n2. Acenda a vela branca e leia a intenção em voz alta 3 vezes\n3. Guarde o papel neste grimório (anote onde)\n4. Registre como se sentiu:',
      ),
      TrailLesson(
        id: 'mb_02',
        title: 'O círculo de proteção',
        teaching:
            'O círculo é a tecnologia mais antiga da magia: um limite simbólico que separa o espaço sagrado do cotidiano. Dentro dele, você trabalha; fora dele, o mundo espera.\n\nHá muitas formas de traçar: sal, giz, o próprio dedo apontado, visualização de luz. O essencial não é o material — é o gesto consciente de dizer "aqui dentro, agora, é diferente".\n\nO círculo também ensina o encerramento: o que se abre, se fecha. Desfazer o círculo ao final, agradecendo, é tão importante quanto abri-lo.',
        practice:
            'Trace um círculo simples ao seu redor (pode ser só visualizado), fique nele por 3 minutos em silêncio e desfaça-o conscientemente. Note a diferença entre dentro e fora.',
        pageTitle: 'Meu Círculo de Proteção',
        pagePurpose: 'Criar e desfazer um espaço sagrado',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Sal grosso (opcional)', 'Vela branca (opcional)'],
        pageStepsTemplate:
            '1. Como eu traço meu círculo (descreva seu jeito):\n___\n\n2. O que digo ao abrir:\n___\n\n3. O que digo ao fechar:\n___\n\n4. Observações da primeira vez:',
      ),
      TrailLesson(
        id: 'mb_03',
        title: 'Bênçãos: magia para os outros',
        teaching:
            'A bênção é a forma mais generosa da magia branca: desejar ativamente o bem, com palavra e intenção, sem controlar o caminho de ninguém. Abençoar não é pedir que alguém mude — é envolver essa pessoa em luz e confiar.\n\nBênçãos tradicionais usam água, luz e palavras ditas com o coração aberto. A estrutura clássica: nomear quem recebe, declarar o bem desejado, selar com um gesto (mãos ao coração, sopro, sinal).\n\nRegra de ouro que atravessa as tradições: abençoe sem esperar retorno e nunca "abençoe" para influenciar decisões alheias — isso já é outra coisa.',
        practice:
            'Escolha alguém querido e faça uma bênção silenciosa de um minuto por essa pessoa, exatamente como ela é hoje.',
        pageTitle: 'Bênção da Minha Casa',
        pagePurpose: 'Abençoar o lar e quem vive nele',
        pageCategory: SpellCategory.home,
        pageIngredients: ['1 copo de água limpa', 'Vela branca'],
        pageStepsTemplate:
            '1. De cômodo em cômodo, diga a bênção que você escrever aqui:\n___\n\n2. Termine na porta de entrada\n3. Despeje a água numa planta\n4. O que senti ao abençoar:',
      ),
      TrailLesson(
        id: 'mb_04',
        title: 'Encerrando com gratidão',
        teaching:
            'Todo trabalho de magia branca termina no mesmo lugar: a gratidão. Agradecer não é etiqueta — é o gesto que fecha o circuito da energia, reconhecendo o que foi recebido antes mesmo de ver resultados.\n\nA gratidão também é a proteção mais subestimada: um coração agradecido não opera pela carência, e a magia feita da abundância tem outra qualidade.\n\nNesta última página da trilha, você cria o seu ritual pessoal de encerramento — o gesto que vai fechar todos os seus trabalhos daqui em diante. Ele é a sua assinatura mágica.',
        practice:
            'Liste 5 coisas que a sua prática já te trouxe (mesmo pequenas). Leia em voz alta como quem encerra uma cerimônia.',
        pageTitle: 'Meu Ritual de Encerramento',
        pagePurpose: 'Selar trabalhos com gratidão',
        pageCategory: SpellCategory.wisdom,
        pageStepsTemplate:
            '1. Meu gesto de encerramento (descreva):\n___\n\n2. Minhas palavras de gratidão:\n___\n\n3. Quando usar: ao final de todo ritual\n4. Primeira vez que usei e como foi:',
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
        'A bruxaria do jardim, da cozinha e da floresta: aprender com as plantas, seus ciclos e seus poderes — escrevendo o seu próprio herbário mágico.',
    lessons: [
      TrailLesson(
        id: 'mv_01',
        title: 'Conhecer uma planta de verdade',
        teaching:
            'A magia verde não começa decorando tabelas de correspondência — começa com UMA planta conhecida de verdade. Nome, cheiro, textura, onde cresce, como reage à água e ao sol.\n\nBruxas verdes tradicionais tinham relação com poucas dúzias de plantas, mas relação profunda: sabiam colher na hora certa, agradecer à planta, usar cada parte.\n\nSua primeira página é o "retrato" de uma planta aliada — a primeira entrada do seu herbário mágico. A Enciclopédia de Ervas do app pode ajudar, mas o essencial vem da sua observação.',
        practice:
            'Escolha uma planta que você TEM acesso (vaso, quintal, feira). Passe 5 minutos com ela usando os cinco sentidos (com segurança). Anote 3 observações que nenhum livro te daria.',
        pageTitle: 'Minha Primeira Planta Aliada',
        pagePurpose: 'Registrar a relação com uma planta',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['A planta escolhida'],
        pageStepsTemplate:
            '1. Nome da planta:\n___\n\n2. Como a conheci e onde vive:\n___\n\n3. Minhas 3 observações diretas:\n___\n\n4. Usos mágicos tradicionais (pesquise na Enciclopédia):\n___\n\n5. O que sinto perto dela:',
      ),
      TrailLesson(
        id: 'mv_02',
        title: 'O chá como ritual',
        teaching:
            'O chá é o ritual verde mais acessível: água, fogo, planta e intenção. A diferença entre "tomar um chá" e "fazer um chá mágico" está inteira na presença: escolher a erva pela intenção, mexer em círculos no sentido do objetivo (horário para atrair, anti-horário para liberar), e beber em silêncio consciente.\n\nSegurança em primeiro lugar: só use plantas comestíveis conhecidas e respeite contraindicações — magia verde responsável começa na farmacognosia básica.\n\nSua página será a sua primeira receita ritual de chá — que a trilha sugere repetir por 7 dias para sentir o efeito de um ritual sustentado.',
        practice:
            'Prepare um chá simples (camomila, erva-doce…) com total presença: da escolha da erva ao último gole, sem celular.',
        pageTitle: 'Meu Chá Ritual',
        pagePurpose: 'Criar uma receita ritual de chá',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Erva comestível escolhida', 'Água', 'Mel (opcional)'],
        pageStepsTemplate:
            '1. Erva e intenção do meu chá:\n___\n\n2. Como preparo (fogo, tempo, mexer):\n___\n\n3. O que digo/penso enquanto bebo:\n___\n\n4. Diário dos 7 dias (uma linha por dia):',
      ),
      TrailLesson(
        id: 'mv_03',
        title: 'Sachês e amuletos de ervas',
        teaching:
            'O sachê é a forma portátil da magia verde: um saquinho de tecido com ervas secas, costurado ou amarrado com intenção. Debaixo do travesseiro para sonhos, na bolsa para proteção, no armário para harmonia.\n\nA montagem clássica combina 3 elementos: a erva principal (a intenção), uma erva de suporte e um "fixador" (casca, raiz, cristal pequeno). Ímpar de ervas, nó selado com palavra dita.\n\nA cor do tecido conversa com a intenção — visite a Enciclopédia de Cores do app para escolher a sua.',
        practice:
            'Separe ervas secas de cozinha (louro, alecrim, canela...) e sinta qual combinação "pede" para existir. Não monte ainda — só escolha e cheire.',
        pageTitle: 'Meu Primeiro Sachê',
        pagePurpose: 'Montar um amuleto de ervas',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Ervas secas (3)', 'Tecido pequeno', 'Fita ou linha'],
        pageStepsTemplate:
            '1. Intenção do sachê:\n___\n\n2. Minhas 3 ervas e por quê:\n___\n\n3. Cor do tecido e motivo:\n___\n\n4. Palavras ditas ao fechar o nó:\n___\n\n5. Onde ele vive agora:',
      ),
      TrailLesson(
        id: 'mv_04',
        title: 'Os ciclos: plantar com a lua',
        teaching:
            'A magia verde é regida por ciclos: estações, lua, dia e noite. A tradição planta o que cresce para cima na lua crescente e raízes na minguante; colhe folhas de poder na cheia; deixa a terra descansar na nova.\n\nMais que regra agrícola, é um treino de paciência mágica: nem tudo é para agora, e forçar o tempo das coisas é o oposto da sabedoria verde.\n\nSua última página desta trilha é um mini-calendário pessoal: o que você quer plantar (literal ou simbolicamente) em cada fase da próxima lua. O Calendário Lunar do app te acompanha.',
        practice:
            'Descubra a fase da lua HOJE (no app) e faça uma ação verde alinhada: plantar, podar, colher ou simplesmente deixar descansar.',
        pageTitle: 'Meu Calendário Verde',
        pagePurpose: 'Alinhar plantios e intenções à lua',
        pageCategory: SpellCategory.prosperity,
        pageStepsTemplate:
            '1. Na próxima lua NOVA vou (descansar/planejar):\n___\n\n2. Na CRESCENTE vou (plantar/começar):\n___\n\n3. Na CHEIA vou (colher/celebrar):\n___\n\n4. Na MINGUANTE vou (podar/soltar):\n___',
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
        'Os fundamentos da religião da bruxaria moderna: a dualidade divina, os sabás, os esbás e a ética wiccana — construindo o seu Livro das Sombras.',
    lessons: [
      TrailLesson(
        id: 'wi_01',
        title: 'A Rede: "não prejudique ninguém"',
        teaching:
            'A ética wiccana cabe numa frase, a Rede: "Faz o que quiseres, desde que não prejudiques ninguém". Parece simples — é um koan para a vida inteira. Inclui não prejudicar a si mesma, o que muita gente esquece.\n\nDa Rede deriva a reflexão sobre retorno (a "Lei Tríplice" para muitos wiccanos): a energia que você põe em movimento volta — em qualidade, não necessariamente em aritmética.\n\nSua primeira página do Livro das Sombras é o seu próprio código: o que a Rede significa PARA VOCÊ, nas situações reais da sua vida.',
        practice:
            'Lembre de uma situação recente difícil. Como a Rede teria orientado sua ação? Sem culpa — é treino, não tribunal.',
        pageTitle: 'Meu Código da Rede',
        pagePurpose: 'Traduzir a ética wiccana para a minha vida',
        pageCategory: SpellCategory.wisdom,
        pageStepsTemplate:
            '1. A Rede com minhas palavras:\n___\n\n2. Três situações onde ela me guia:\n___\n\n3. Onde costumo me prejudicar (e o novo acordo comigo):\n___',
      ),
      TrailLesson(
        id: 'wi_02',
        title: 'Deusa e Deus: a dualidade',
        teaching:
            'A Wicca clássica honra o divino em dualidade: a Deusa Tripla (Donzela, Mãe, Anciã — os ciclos da lua e da vida) e o Deus Cornífero (o sol, a caça, a natureza selvagem que nasce e morre com as estações).\n\nCorrentes atuais ampliam ou flexibilizam essa visão — há wiccanos duoteístas, politeístas e até ateus rituais. O essencial é a relação viva com o sagrado imanente: o divino NA natureza, não fora dela.\n\nNesta página você começa sua devoção pessoal: como o sagrado se apresenta para VOCÊ.',
        practice:
            'Ao ar livre (ou à janela), observe algo da natureza por 5 minutos como se fosse um rosto do divino. Sem pedir nada — só presença.',
        pageTitle: 'Como o Sagrado me Encontra',
        pagePurpose: 'Registrar minha relação com o divino',
        pageCategory: SpellCategory.wisdom,
        pageIngredients: ['Vela prateada ou branca (Deusa)', 'Vela dourada (Deus) — opcionais'],
        pageStepsTemplate:
            '1. Que face do sagrado me toca mais (Deusa/Deus/ambos/outro):\n___\n\n2. Onde já senti isso na natureza:\n___\n\n3. Meu gesto simples de devoção diária:\n___',
      ),
      TrailLesson(
        id: 'wi_03',
        title: 'A Roda do Ano',
        teaching:
            'A Wicca celebra o tempo como círculo: oito sabás marcam a dança entre luz e escuridão — solstícios, equinócios e os quatro festivais do fogo (Samhain, Imbolc, Beltane, Lughnasadh).\n\nCada sabá é um espelho interno: Samhain honra ancestrais e finais; Yule, o renascer da luz; Beltane, a paixão criativa; Lughnasadh, a primeira colheita do que você plantou.\n\nNo hemisfério sul, muitos praticantes invertem as datas para seguir as estações reais. Escolha a coerência que faz sentido para você — e registre-a, porque seu Livro das Sombras é o seu mapa.',
        practice:
            'Descubra qual é o PRÓXIMO sabá (seção Roda do Ano do app) e planeje uma celebração de 10 minutos para ele.',
        pageTitle: 'Meu Próximo Sabá',
        pagePurpose: 'Planejar minha primeira celebração da Roda',
        pageCategory: SpellCategory.other,
        pageStepsTemplate:
            '1. Sabá e data (meu hemisfério):\n___\n\n2. O que este sabá celebra:\n___\n\n3. Minha celebração de 10 minutos:\n___\n\n4. Depois: como foi?',
      ),
      TrailLesson(
        id: 'wi_04',
        title: 'O Esbá: magia da lua cheia',
        teaching:
            'Se os sabás celebram o sol, os esbás honram a lua — especialmente a cheia, momento clássico de reunião das bruxas e do trabalho mágico wiccano.\n\nUm esbá solitário simples: banho consciente, círculo, saudação à Deusa, "Puxar a Lua" (receber a luz lunar em silêncio de olhos fechados), trabalho de magia ou adivinhação, bolo e vinho (ou chá e pão!), encerramento.\n\nSua última página desta trilha é o SEU roteiro de esbá — a primeira liturgia autoral do seu Livro das Sombras.',
        practice:
            'Na próxima noite de lua visível, passe 3 minutos sob a luz dela (ou à janela), apenas recebendo.',
        pageTitle: 'Meu Ritual de Esbá',
        pagePurpose: 'Criar minha liturgia de lua cheia',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Vela branca', 'Água', 'Algo para "bolo e vinho"'],
        pageStepsTemplate:
            '1. Minha abertura (círculo + saudação):\n___\n\n2. Meu momento de "Puxar a Lua":\n___\n\n3. Trabalho que faço no esbá:\n___\n\n4. Meu encerramento e partilha:\n___',
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
        'A bruxaria dos folclores, das benzedeiras e do "caminho torto": espíritos do lugar, ancestrais e ferramentas do cotidiano — sem dogmas, com raízes.',
    lessons: [
      TrailLesson(
        id: 'bt_01',
        title: 'Os espíritos do lugar',
        teaching:
            'A bruxaria tradicional não é uma religião organizada — é um conjunto de práticas enraizadas no LUGAR: seus rios, encruzilhadas, cemitérios, quintais. O primeiro passo é conhecer os espíritos da terra onde você pisa (genius loci).\n\nIsso se faz como se faz amizade: presença regular, pequenas oferendas respeitosas (água, pão, flores — nunca lixo), escuta. O folclore local — as histórias "de assombração" da sua região — é o mapa espiritual mais honesto que existe.\n\nSua primeira página é o registro do seu território mágico.',
        practice:
            'Caminhe 15 minutos pelo seu bairro como bruxa: onde a energia muda? Que lugar te "chama"? Que histórias os antigos contam dali?',
        pageTitle: 'Os Espíritos do Meu Lugar',
        pagePurpose: 'Mapear o território espiritual onde vivo',
        pageCategory: SpellCategory.wisdom,
        pageStepsTemplate:
            '1. Lugares de poder perto de mim:\n___\n\n2. Histórias/folclore da região:\n___\n\n3. Minha primeira oferenda respeitosa (o quê/onde):\n___\n\n4. O que senti:',
      ),
      TrailLesson(
        id: 'bt_02',
        title: 'Ancestrais: a linhagem viva',
        teaching:
            'Na bruxaria tradicional, os mortos não estão longe: os ancestrais são aliados de primeira hora. Não é preciso saber nomes ou árvore genealógica — a linhagem inclui os de sangue, os de afeto e os de ofício (as bruxas e benzedeiras que vieram antes).\n\nUm altar ancestral simples: uma superfície limpa, um copo d\'água, uma vela, um objeto ou foto (de quem já partiu — a tradição recomenda não colocar fotos de vivos). Renove a água, fale com eles como quem conversa.\n\nSua página registra o começo desse vínculo.',
        practice:
            'Acenda uma vela por seus ancestrais (todos, conhecidos e desconhecidos) e diga em voz alta: "Eu me lembro. Obrigada. Sigam comigo."',
        pageTitle: 'Meu Altar Ancestral',
        pagePurpose: 'Iniciar a devoção aos que vieram antes',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Copo de água', 'Vela', 'Objeto/foto de quem partiu'],
        pageStepsTemplate:
            '1. Onde montei (descreva o cantinho):\n___\n\n2. Quem eu honro (nomes ou "os que vieram antes"):\n___\n\n3. Minha saudação a eles:\n___\n\n4. Dia da semana em que renovo a água:',
      ),
      TrailLesson(
        id: 'bt_03',
        title: 'As ferramentas do cotidiano',
        teaching:
            'A bruxa tradicional não espera loja esotérica: a vassoura varre energia, a tesoura corta laço, a colher de pau mexe intenção, a agulha costura destino. O poder está no uso consciente, não no preço.\n\nConsagrar uma ferramenta do cotidiano é simples: limpar (água/sal/fumaça), declarar o novo papel ("esta tesoura corta o que me prende") e usá-la SÓ para isso a partir de então — a exclusividade é o que carrega.\n\nSua página é o inventário mágico da sua casa.',
        practice:
            'Escolha UM objeto da sua casa para consagrar como primeira ferramenta. Sinta qual deles "aceita" o trabalho.',
        pageTitle: 'Minhas Ferramentas de Bruxa',
        pagePurpose: 'Consagrar objetos do cotidiano',
        pageCategory: SpellCategory.other,
        pageIngredients: ['O objeto escolhido', 'Sal ou fumaça de ervas'],
        pageStepsTemplate:
            '1. Objeto escolhido e sua função mágica:\n___\n\n2. Como limpei/consagrei:\n___\n\n3. Palavras da consagração:\n___\n\n4. Outros objetos que pretendo consagrar:',
      ),
      TrailLesson(
        id: 'bt_04',
        title: 'Benzimento: a palavra que cura',
        teaching:
            'As benzedeiras são a bruxaria tradicional viva do Brasil: mulheres (e homens) que curam com palavra, ramo e fé — quebranto, mau-olhado, espinhela caída. Sem livro, sem loja: transmissão oral, joelho no chão e galho de arruda.\n\nA estrutura do benzimento é poesia funcional: nomeia o mal, invoca a força maior, manda o mal para longe ("para as ondas do mar sagrado…") e sela. O ramo que murcha "levou" o que tirou.\n\nSua última página desta trilha honra essa linhagem: seu primeiro benzimento — para USO PESSOAL, com respeito por quem guarda essa tradição por ofício.',
        practice:
            'Pesquise (com avós, vizinhas, internet) UM benzimento tradicional da sua região. Copie-o como se copia relíquia.',
        pageTitle: 'Meu Primeiro Benzimento',
        pagePurpose: 'Honrar e praticar a palavra que cura',
        pageCategory: SpellCategory.healing,
        pageIngredients: ['Ramo verde (arruda, guiné ou similar)'],
        pageStepsTemplate:
            '1. Benzimento tradicional que encontrei (fonte):\n___\n\n2. Minha versão para autocuidado:\n___\n\n3. Gesto que acompanha (ramo, cruz, sopro):\n___\n\n4. Quando usei e o que senti:',
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
        'A magia como tecnologia experimental: crença como ferramenta, sigilos, resultados mensuráveis e zero dogma. Aqui as regras são hipóteses — e você é o laboratório.',
    lessons: [
      TrailLesson(
        id: 'mc_01',
        title: 'Crença como ferramenta',
        teaching:
            'O axioma caóta: a crença não é a verdade — é o INSTRUMENTO. Se acreditar em X produz o resultado desejado, o caóta veste a crença X como quem veste um casaco, trabalha, e depois o pendura de volta.\n\nIsso não é cinismo: é levar a crença mais a sério que todo mundo — a ponto de usá-la deliberadamente. O "paradigm shifting" (trocar de sistema de crenças por período determinado) é o exercício central da tradição.\n\nSua primeira página é um experimento formal: uma semana operando com uma crença escolhida, com registro de resultados. Bem-vinda ao laboratório.',
        practice:
            'Escolha uma crença útil e testável ("as pessoas respondem bem à minha presença") e viva 24h COMO SE ela fosse absolutamente verdadeira. Anote o que muda.',
        pageTitle: 'Experimento: Crença de 7 Dias',
        pagePurpose: 'Testar a crença como ferramenta',
        pageCategory: SpellCategory.other,
        pageType: SpellType.attraction,
        pageStepsTemplate:
            '1. Crença adotada (afirmativa, testável):\n___\n\n2. Critério de sucesso (como sei que funcionou):\n___\n\n3. Diário dos 7 dias (uma linha por dia):\n___\n\n4. Veredito do experimento:',
      ),
      TrailLesson(
        id: 'mc_02',
        title: 'Sigilos: o desejo criptografado',
        teaching:
            'O sigilo de Austin Osman Spare é a técnica-assinatura do caos: escrever o desejo, eliminar letras repetidas, fundir as restantes num glifo abstrato — e então ESQUECER o desejo, lançando o símbolo no inconsciente através de um estado alterado (o "gnosis": exaustão, dança, clímax, olhar fixo).\n\nO esquecimento não é detalhe: a mente consciente, ansiosa, sabota; o inconsciente, livre dela, trabalha.\n\nVocê já tem a ferramenta perfeita: a seção Sigilos deste app. Sua página documenta seu primeiro sigilo lançado com método completo.',
        practice:
            'Crie um sigilo na ferramenta do app (Ferramentas → Sigilos). Antes de ativá-lo, escolha seu método de gnosis.',
        pageTitle: 'Meu Primeiro Sigilo Lançado',
        pagePurpose: 'Registrar o método completo de sigilização',
        pageCategory: SpellCategory.other,
        pageStepsTemplate:
            '1. Frase original do desejo (escreva e depois risque!):\n___\n\n2. Método de gnosis usado:\n___\n\n3. Como destruí/esqueci o sigilo:\n___\n\n4. (Preencher em 1 mês) Resultados observados:',
      ),
      TrailLesson(
        id: 'mc_03',
        title: 'O diário de resultados',
        teaching:
            'O que separa o caóta do místico de sofá é o REGISTRO: data, operação, técnica, estado, resultado. Sem diário, todo sucesso é lembrado e todo fracasso esquecido — e você não aprende nada.\n\nO diário mágico caóta é impiedoso e gentil ao mesmo tempo: impiedoso com a autoilusão ("isso foi coincidência mesmo"), gentil com o processo (fracasso é dado, não vergonha).\n\nEsta página define o SEU protocolo de registro — que você pode manter nas Reflexões do app ou aqui no grimório.',
        practice:
            'Revise os experimentos das lições 1 e 2 com honestidade brutal: o que funcionou, o que não, o que foi viés?',
        pageTitle: 'Meu Protocolo de Registro',
        pagePurpose: 'Sistematizar o diário de resultados',
        pageCategory: SpellCategory.study,
        pageStepsTemplate:
            '1. O que registro em toda operação (meu template):\n___\n\n2. Quando reviso (semanal/lunar):\n___\n\n3. Como classifico resultados (escala):\n___\n\n4. Primeira revisão feita — aprendizados:',
      ),
      TrailLesson(
        id: 'mc_04',
        title: 'Construa seu próprio sistema',
        teaching:
            'O destino final do caos é a autonomia: depois de testar crenças, técnicas e paradigmas, você monta o SEU sistema — pessoal, funcional, revisável. Pode misturar o esbá wiccano com sigilos e benzimento da avó: se funciona no seu diário de resultados, é seu.\n\nOs únicos limites desta trilha (e deste app) são éticos, não estéticos: nada de dano a pessoas ou animais, nada criminoso. Todo o resto — o estranho, o simbólico, o inventado — é matéria-prima legítima.\n\nSua última página é a constituição do seu sistema mágico v1.0. Ela será revisada muitas vezes — e é exatamente essa a beleza.',
        practice:
            'Releia todas as páginas que você criou nas trilhas. O que já é "seu jeito"? Circule os elementos que vão para o seu sistema.',
        pageTitle: 'Meu Sistema Mágico v1.0',
        pagePurpose: 'Consolidar meu caminho pessoal',
        pageCategory: SpellCategory.wisdom,
        pageStepsTemplate:
            '1. Minhas 3 técnicas centrais:\n___\n\n2. Meus princípios inegociáveis:\n___\n\n3. O que estou testando agora:\n___\n\n4. Data da próxima revisão do sistema:',
      ),
    ],
  ),
];
