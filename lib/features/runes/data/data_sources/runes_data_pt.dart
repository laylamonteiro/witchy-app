import '../models/rune_model.dart';

/// As 24 runas do Futhark Antigo — conteúdo em português (idioma-base).
///
/// Nomes e símbolos são invariantes entre idiomas; apenas palavras-chave e
/// descrições são traduzidas. Mantenha a mesma ordem nos três arquivos
/// (`runes_data_pt/en/es.dart`) — a paridade é verificada em
/// `test/content_parity_test.dart`.
const List<Rune> runesPt = [
  Rune(
    name: 'Fehu',
    symbol: 'ᚠ',
    keywords: ['Prosperidade', 'Riqueza', 'Abundância'],
    description: 'Fehu é o gado: a riqueza que anda, se conta em cabeças '
        'e se gasta. No mundo nórdico, quem tinha rebanho tinha sustento, '
        'e é dessa riqueza concreta e móvel que a runa fala, não de '
        'fortuna abstrata. Numa leitura, aponta recursos chegando ou já '
        'disponíveis: dinheiro, tempo, energia pedindo uso. Pergunte-se '
        'onde sua riqueza está circulando e onde está apenas acumulando. '
        'O alerta de Fehu é antigo: os poemas rúnicos dizem que o ouro '
        'causa discórdia entre parentes - riqueza parada, ou mal '
        'partilhada, apodrece',
  ),
  Rune(
    name: 'Uruz',
    symbol: 'ᚢ',
    keywords: ['Força', 'Vitalidade', 'Saúde'],
    description:
        'Uruz é o auroque, o boi selvagem gigante que vagava pelas '
        'florestas da Europa até ser caçado à extinção. Caçá-lo era rito '
        'de passagem: o jovem provava a própria força diante de uma fera '
        'que não se deixava domar. Numa leitura, Uruz diz que a situação '
        'pede vigor e que você tem mais força do que imagina - inclusive '
        'força de recuperação, por isso é também runa de saúde. Encare o '
        'desafio de frente e cuide do corpo, que sustenta todo o resto. '
        'A sombra: força bruta sem direção fere quem a carrega - dê um '
        'alvo à sua antes de usá-la',
  ),
  Rune(
    name: 'Thurisaz',
    symbol: 'ᚦ',
    keywords: ['Proteção', 'Defesa', 'Desafio'],
    description:
        'Thurisaz é o espinho e também o gigante, a força bruta do caos; '
        'a tradição a liga ao martelo de Thor, que mantinha os gigantes '
        'à distância. O poema anglo-saxão avisa: o espinho é cruelmente '
        'afiado para quem põe a mão nele. Numa leitura, aponta conflito, '
        'ameaça ou atrito - e o seu poder de reagir a eles. Antes de '
        'agir, pare: a runa pede defesa pensada, como uma cerca de '
        'espinhos, não um ataque. Sua sombra é a impulsividade - a força '
        'que, usada com raiva, corta a própria mão',
  ),
  Rune(
    name: 'Ansuz',
    symbol: 'ᚨ',
    keywords: ['Comunicação', 'Sabedoria', 'Inspiração'],
    description:
        'Ansuz é a runa do deus - de Odin, que se pendurou na árvore do '
        'mundo para conquistar as runas - e significa boca, sopro, '
        'palavra dita. É a runa da comunicação que carrega sabedoria: o '
        'conselho, a poesia, a mensagem certa. Numa leitura, indica que '
        'uma informação importante está a caminho ou que uma conversa '
        'pode destravar a situação. Escute com atenção, procure quem '
        'sabe mais e diga com clareza o que precisa ser dito. Só confira '
        'a fonte: palavras também enganam, e nem toda voz que soa sábia é',
  ),
  Rune(
    name: 'Raidho',
    symbol: 'ᚱ',
    keywords: ['Jornada', 'Movimento', 'Progresso'],
    description:
        'Raidho é a cavalgada: a viagem longa a cavalo, com rota, ritmo '
        'e desgaste. O poema rúnico norueguês lembra que cavalgar é '
        'fácil de dizer e duro para o cavalo - todo caminho tem custo '
        'real. Numa leitura, indica movimento com direção: uma viagem '
        'literal, um processo em andamento, a hora de sair do lugar. '
        'Planeje a rota, mantenha um ritmo constante e não pule etapas - '
        'é a estrada inteira que transforma, não só a chegada. Se tudo '
        'parece travado, Raidho sugere que falta movimento, não sorte',
  ),
  Rune(
    name: 'Kenaz',
    symbol: 'ᚲ',
    keywords: ['Conhecimento', 'Criatividade', 'Iluminação'],
    description:
        'Kenaz é a tocha: o fogo de pinho que iluminava salões e '
        'oficinas - luz de trabalho, não incêndio. É a runa do ofício e '
        'do conhecimento que se domina com as mãos. Numa leitura, '
        'anuncia um insight, uma solução que fica visível ou uma '
        'habilidade pronta para ser desenvolvida. Estude, pratique e '
        'ilumine um canto de cada vez, em vez de tentar acender tudo. '
        'Lembre que tocha pede mão firme: fogo criativo sem cuidado '
        'queima, inclusive na forma de entusiasmo que consome sem '
        'construir',
  ),
  Rune(
    name: 'Gebo',
    symbol: 'ᚷ',
    keywords: ['Presente', 'Parceria', 'Troca'],
    description:
        'Gebo é a dádiva. Entre os povos germânicos, um presente nunca '
        'era só um presente: criava vínculo de honra entre quem dava e '
        'quem recebia, e um presente pedia outro. Numa leitura, fala de '
        'trocas, alianças e generosidade que une - um relacionamento, um '
        'acordo, uma oferta em jogo. Observe o equilíbrio: você está '
        'dando e recebendo na mesma medida? Retribua o que recebeu e '
        'peça reciprocidade sem culpa. A sombra de Gebo é a troca '
        'desigual, que transforma presente em dívida e vínculo em '
        'dependência',
  ),
  Rune(
    name: 'Wunjo',
    symbol: 'ᚹ',
    keywords: ['Alegria', 'Harmonia', 'Satisfação'],
    description:
        'Wunjo é a alegria - e, para o poema anglo-saxão, tem alegria '
        'quem conhece pouca privação e não lhe faltam sustento e '
        'comunidade. Não é euforia: é o bem-estar concreto de pertencer '
        'e de ter o bastante. Numa leitura, indica uma fase em que as '
        'peças se encaixam - harmonia em casa, no grupo, no trabalho. '
        'Celebre e compartilhe: alegria guardada só para si murcha. '
        'Atenção apenas para não fingir harmonia, escondendo o que '
        'precisa ser conversado',
  ),
  Rune(
    name: 'Hagalaz',
    symbol: 'ᚺ',
    keywords: ['Disrupção', 'Mudança', 'Purificação'],
    description: 'Hagalaz é o granizo: o grão de gelo que cai do céu '
        'sem aviso, destrói a colheita e depois derrete, virando água '
        'que rega o campo. Os poemas rúnicos o chamam de o mais frio dos '
        'grãos. Numa leitura, indica disrupção fora do seu controle - '
        'planos desfeitos, uma virada brusca. Não lute contra a '
        'tempestade: proteja o essencial, espere o granizo derreter e '
        'veja o que ele revelou de frágil. O consolo da runa é real: o '
        'que ela derruba já não estava firme, e a água que sobra '
        'alimenta o recomeço',
  ),
  Rune(
    name: 'Nauthiz',
    symbol: 'ᚾ',
    keywords: ['Necessidade', 'Resistência', 'Superação'],
    description: 'Nauthiz é a necessidade, a falta - e também o fogo de '
        'fricção, aceso com esforço quando todos os outros se apagaram. '
        'O poema rúnico diz que a necessidade aperta o peito, mas pode '
        'chegar como aviso e lição a tempo. Numa leitura, indica '
        'escassez, atraso ou vontade contrariada: algo que você quer '
        'ainda não é possível. Reduza ao essencial, tenha paciência '
        'ativa e faça o possível com o que tem - é assim que se acende '
        'fogo por fricção. Evite os dois extremos, negar a dificuldade '
        'ou se desesperar nela: o que falta agora está mostrando o que '
        'de fato importa',
  ),
  Rune(
    name: 'Isa',
    symbol: 'ᛁ',
    keywords: ['Pausa', 'Estagnação', 'Introspecção'],
    description:
        'Isa é o gelo: bonito de ver, brilhante como joia, traiçoeiro '
        'de pisar. No inverno nórdico, o gelo parava rios e navios - e, '
        'às vezes, virava ponte. Numa leitura, indica situação '
        'congelada: um esfriamento, uma espera, algo que não anda. Não '
        'force o degelo; use a pausa para enxergar com a clareza fria '
        'que só a distância dá. Mas fique atento: sob o gelo a '
        'correnteza continua, e uma estagnação longa demais precisa ser '
        'quebrada com um primeiro passo pequeno',
  ),
  Rune(
    name: 'Jera',
    symbol: 'ᛃ',
    keywords: ['Colheita', 'Ciclos', 'Recompensa'],
    description: 'Jera é o ano e a colheita: o ciclo agrícola completo, '
        'do plantio ao celeiro cheio. Os poemas rúnicos a celebram como '
        'a boa estação, quando a terra dá seu fruto. Numa leitura, '
        'indica resultados chegando no tempo certo - colhe-se o que foi '
        'plantado, nem antes, nem depois. Continue o trabalho constante, '
        'respeite as estações do processo e colha quando estiver maduro, '
        'não quando a ansiedade mandar. Jera não tem atalho: se a '
        'colheita está magra, a runa aponta para o que foi - ou não '
        'foi - semeado',
  ),
  Rune(
    name: 'Eihwaz',
    symbol: 'ᛇ',
    keywords: ['Proteção', 'Resistência', 'Transformação'],
    description:
        'Eihwaz é o teixo: árvore de vida longuíssima, de madeira '
        'flexível e veneno potente, com que se faziam os melhores '
        'arcos - e que se plantava junto aos mortos, ligando os mundos. '
        'Muitos a associam à própria Yggdrasil, a árvore que sustenta '
        'tudo. Numa leitura, indica uma travessia difícil que '
        'transforma: um fim que é passagem, uma resistência que vem da '
        'raiz. Enraíze-se no que é essencial e aguente firme, vergando '
        'sem quebrar. Como o arco de teixo, a tensão que você suporta '
        'agora é o que dará força ao disparo depois',
  ),
  Rune(
    name: 'Perthro',
    symbol: 'ᛈ',
    keywords: ['Mistério', 'Destino', 'Oculto'],
    description:
        'Perthro é o copo de dados: o poema anglo-saxão a descreve como '
        'jogo e riso entre guerreiros no salão de cerveja. É a runa da '
        'sorte, do destino e do que ainda está oculto. Numa leitura, '
        'diz que há fatores em jogo que você não vê: um segredo, um '
        'resultado ainda não decidido, o acaso fazendo a parte dele. '
        'Faça bem a sua jogada e solte o controle sobre o resto; '
        'observe o que vai se revelando aos poucos. O aviso é o de toda '
        'mesa de jogo: não aposte o que não pode perder',
  ),
  Rune(
    name: 'Algiz',
    symbol: 'ᛉ',
    keywords: ['Proteção', 'Defesa', 'Conexão Divina'],
    description: 'Algiz é o alce - e o junco-do-alce, o capim cortante '
        'dos pântanos que, diz o poema anglo-saxão, fere quem tenta '
        'agarrá-lo. Seu traço lembra uma mão aberta ou chifres erguidos: '
        'proteção em estado de alerta. Numa leitura, indica que você '
        'está protegido ou que é hora de erguer defesas - muitas vezes '
        'é o seu instinto soando o alarme. Escute esse aviso interno e '
        'estabeleça limites claros, que protegem sem precisar ferir. A '
        'sombra: defesa permanente vira isolamento, e nem todo mundo é '
        'ameaça',
  ),
  Rune(
    name: 'Sowilo',
    symbol: 'ᛊ',
    keywords: ['Sucesso', 'Vitalidade', 'Iluminação'],
    description: 'Sowilo é o sol - para o poema anglo-saxão, a '
        'esperança dos navegantes, que por ele se guiam até o porto. No '
        'norte de invernos longos, sol não é metáfora: é vitória '
        'concreta. Numa leitura, indica clareza, sucesso e energia '
        'voltando - a direção certa fica visível e o vento sopra a '
        'favor. Aja enquanto o céu está limpo: impulso favorável se '
        'aproveita, não se guarda. Lembre só que o sol também expõe o '
        'que estava na sombra; deixe essa luz mostrar a verdade sem medo',
  ),
  Rune(
    name: 'Tiwaz',
    symbol: 'ᛏ',
    keywords: ['Justiça', 'Honra', 'Liderança'],
    description:
        'Tiwaz é a runa de Tyr, o deus que pôs a própria mão na boca do '
        'lobo Fenrir como garantia, para que os deuses pudessem '
        'acorrentá-lo - e a perdeu, pagando o preço do pacto. Seu traço '
        'é uma flecha: direção firme e pontaria. Numa leitura, fala de '
        'uma causa justa que pede coragem e cobra um custo - uma decisão '
        'difícil, uma palavra a ser mantida. Faça o que é certo mesmo '
        'quando sai caro, e sustente o que prometeu. Para Tiwaz, vitória '
        'obtida sem honra não é vitória',
  ),
  Rune(
    name: 'Berkano',
    symbol: 'ᛒ',
    keywords: ['Crescimento', 'Fertilidade', 'Renovação'],
    description: 'Berkano é a bétula, a primeira árvore a brotar quando '
        'o gelo do inverno recua - símbolo antigo de primavera, '
        'maternidade e renovação. Numa leitura, indica um começo '
        'delicado: algo, ou alguém, em fase de gestação, cura ou '
        'crescimento lento que pede cuidado. Proteja o que é novo, '
        'alimente-o com constância e aceite o ritmo próprio do que '
        'cresce. A sombra de Berkano é o cuidado que sufoca: proteger '
        'demais também impede o broto de virar árvore',
  ),
  Rune(
    name: 'Ehwaz',
    symbol: 'ᛖ',
    keywords: ['Parceria', 'Confiança', 'Movimento'],
    description:
        'Ehwaz é o cavalo - para o poema anglo-saxão, alegria dos '
        'nobres e conforto para o inquieto. Mas a runa fala menos do '
        'animal e mais do par cavalo e cavaleiro: dois seres que só '
        'avançam porque confiam um no outro. Numa leitura, indica '
        'parceria que funciona - casamento, sociedade, amizade, '
        'equipe - e progresso construído em dupla. Invista na '
        'confiança, ajuste seu passo ao do outro e confira se vocês '
        'querem chegar ao mesmo lugar. Lembre que confiança se constrói '
        'devagar e se perde num tranco',
  ),
  Rune(
    name: 'Mannaz',
    symbol: 'ᛗ',
    keywords: ['Humanidade', 'Autoconsciência', 'Comunidade'],
    description:
        'Mannaz é o ser humano. O poema anglo-saxão diz, sem rodeios: '
        'cada pessoa é alegria para as outras, e ainda assim todos um '
        'dia faltarão, porque a morte a todos alcança. É a runa da '
        'consciência de ser gente - mortal, limitado e, mesmo assim, '
        'ligado aos outros. Numa leitura, pede um olhar honesto para si '
        'e para o seu lugar na comunidade. Peça ajuda quando precisar, '
        'ofereça quando puder e reconheça seus limites sem vergonha. '
        'Ninguém se basta sozinho - e isso não é fraqueza, é a condição '
        'humana',
  ),
  Rune(
    name: 'Laguz',
    symbol: 'ᛚ',
    keywords: ['Água', 'Intuição', 'Fluxo'],
    description:
        'Laguz é a água: o lago e o mar que os poemas descrevem como '
        'imensos e imprevisíveis para quem navega. É a runa das '
        'profundezas - emoções, sonhos, intuição, tudo o que corre por '
        'baixo da superfície. Numa leitura, indica uma fase de sentir '
        'mais do que entender: a resposta não virá só pela lógica. '
        'Escute os sonhos, confie na intuição e nade com a correnteza '
        'em vez de brigar com ela. Só respeite a profundidade: '
        'mergulhar no sentimento é diferente de se afogar nele',
  ),
  Rune(
    name: 'Ingwaz',
    symbol: 'ᛜ',
    keywords: ['Fertilidade', 'Potencial', 'Gestação'],
    description:
        'Ingwaz é a runa de Ing, nome antigo de Freyr, deus da '
        'fertilidade e da paz - o poema anglo-saxão conta que ele foi '
        'visto primeiro entre os dinamarqueses, e que sua carroça '
        'percorria as terras abençoando os campos. Seu traço fechado '
        'lembra uma semente: potencial completo, ainda guardado. Numa '
        'leitura, indica gestação - algo se desenvolvendo por dentro, '
        'quase pronto, que ainda não deve ser mostrado. Guarde energia, '
        'finalize em silêncio e espere o momento certo de liberar o que '
        'amadureceu. Ingwaz é bom presságio: promete conclusão, desde '
        'que você não a apresse',
  ),
  Rune(
    name: 'Dagaz',
    symbol: 'ᛞ',
    keywords: ['Dia', 'Despertar', 'Transformação'],
    description:
        'Dagaz é o dia - a luz que o poema anglo-saxão chama de amada '
        'por todos, ricos e pobres. É o instante exato em que a noite '
        'vira manhã: a virada, não o meio-dia. Numa leitura, anuncia '
        'despertar e clareza súbita depois de um período escuro - um '
        'ponto de inflexão de verdade. Receba o recomeço de forma '
        'prática: use a luz nova para fazer diferente o que a escuridão '
        'não deixava ver. Se você esperava um sinal para mudar, Dagaz '
        'costuma ser esse sinal',
  ),
  Rune(
    name: 'Othala',
    symbol: 'ᛟ',
    keywords: ['Herança', 'Lar', 'Ancestralidade'],
    description: 'Othala é a propriedade herdada: a terra da família, o '
        'solar que passa de geração em geração e que não se compra - '
        'recebe-se e transmite-se. É a runa das raízes, do lar e da '
        'herança, tanto material quanto invisível: nome, valores, '
        'costumes, padrões. Numa leitura, aponta questões de família, '
        'casa, pertencimento ou algo recebido de quem veio antes. Honre '
        'o que há de bom nessa herança e cuide do seu chão. Mas lembre '
        'que herança também traz padrões repetidos - parte do trabalho '
        'é escolher o que você mantém e o que enfim deixa ir',
  ),
];
