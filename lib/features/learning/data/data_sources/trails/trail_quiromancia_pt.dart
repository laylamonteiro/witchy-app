import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trilha 'quiromancia' — conteúdo em português (idioma-base).
/// Paridade com _en/_es verificada em test/trails_parity_test.dart.
const LearningTrail quiromanciaTrailPt = LearningTrail(
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
);
