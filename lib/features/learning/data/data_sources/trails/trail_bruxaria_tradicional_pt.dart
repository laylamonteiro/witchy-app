import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trilha 'bruxaria_tradicional' — conteúdo em português (idioma-base).
/// Paridade com _en/_es verificada em test/trails_parity_test.dart.
const LearningTrail bruxariaTradicionalTrailPt = LearningTrail(
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
  );
