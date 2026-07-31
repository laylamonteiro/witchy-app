import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trilha 'wicca' — conteúdo em português (idioma-base).
/// Paridade com _en/_es verificada em test/trails_parity_test.dart.
const LearningTrail wiccaTrailPt = LearningTrail(
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
  );
