import 'numerology_meanings_models.dart';

/// Significados numerológicos — conteúdo em português (idioma-base).
/// Paridade com _en/_es verificada em test/numerology_meanings_parity_test.dart.
const Map<int, NumberMeaning> numberMeaningsPt = {
  1: NumberMeaning(
    number: 1,
    title: 'O Pioneiro',
    keywords: ['iniciativa', 'liderança', 'independência', 'coragem'],
    description:
        'O Um abre caminhos. É a centelha inicial, a vontade que dá o primeiro passo e inaugura ciclos. Quem vibra no Um aprende a confiar em si, liderar com autenticidade e plantar o novo.',
    shadow:
        'Na sombra, pode virar autoritarismo, impaciência ou solidão por não pedir ajuda.',
  ),
  2: NumberMeaning(
    number: 2,
    title: 'O Diplomata',
    keywords: ['cooperação', 'sensibilidade', 'parceria', 'paciência'],
    description:
        'O Dois une. É o número dos laços, da escuta e da mediação. Quem vibra no Dois floresce em parcerias, percebe sutilezas que os outros não veem e cura ambientes com presença suave.',
    shadow:
        'Na sombra, aparece a dependência, o medo de conflito e a autoanulação.',
  ),
  3: NumberMeaning(
    number: 3,
    title: 'O Comunicador',
    keywords: ['criatividade', 'expressão', 'alegria', 'sociabilidade'],
    description:
        'O Três floresce na expressão: palavra, arte, riso. É energia de criação e encanto, que inspira e conecta pessoas através da beleza e do entusiasmo.',
    shadow:
        'Na sombra, dispersa-se em superficialidade, fofoca ou drama.',
  ),
  4: NumberMeaning(
    number: 4,
    title: 'O Construtor',
    keywords: ['estrutura', 'disciplina', 'trabalho', 'estabilidade'],
    description:
        'O Quatro ergue alicerces. É o número da constância, do método e da confiança conquistada tijolo a tijolo. Quem vibra no Quatro materializa sonhos com paciência e ordem.',
    shadow:
        'Na sombra, enrijece: teimosia, excesso de controle e medo de mudanças.',
  ),
  5: NumberMeaning(
    number: 5,
    title: 'O Aventureiro',
    keywords: ['liberdade', 'mudança', 'versatilidade', 'experiência'],
    description:
        'O Cinco é vento: movimento, viagem, os cinco sentidos. Quem vibra no Cinco aprende pela experiência direta e ensina o mundo a se reinventar sem medo.',
    shadow:
        'Na sombra, vira inquietude crônica, excessos e dificuldade de compromisso.',
  ),
  6: NumberMeaning(
    number: 6,
    title: 'O Guardião',
    keywords: ['cuidado', 'harmonia', 'família', 'responsabilidade'],
    description:
        'O Seis acolhe. É o número do lar, da beleza e do serviço amoroso. Quem vibra no Seis cria espaços seguros, embeleza a vida e cuida do que ama com devoção.',
    shadow:
        'Na sombra, sacrifica-se demais, controla em nome do cuidado e cobra gratidão.',
  ),
  7: NumberMeaning(
    number: 7,
    title: 'O Místico',
    keywords: ['introspecção', 'sabedoria', 'análise', 'espiritualidade'],
    description:
        'O Sete mergulha. É o eremita que busca a verdade sob a superfície — estudo, meditação, mistério. Quem vibra no Sete precisa de silêncio para ouvir o que realmente importa.',
    shadow:
        'Na sombra, isola-se, desconfia de tudo e racionaliza os sentimentos.',
  ),
  8: NumberMeaning(
    number: 8,
    title: 'O Realizador',
    keywords: ['poder', 'abundância', 'justiça', 'ambição'],
    description:
        'O Oito equilibra matéria e espírito. É o número da colheita, da autoridade justa e da prosperidade construída com integridade. Quem vibra no Oito aprende a lidar com poder sem se perder nele.',
    shadow:
        'Na sombra, obceca-se por status, controle e acúmulo.',
  ),
  9: NumberMeaning(
    number: 9,
    title: 'O Humanitário',
    keywords: ['compaixão', 'encerramento', 'generosidade', 'visão ampla'],
    description:
        'O Nove completa o ciclo. É amor que se expande além do pessoal: causas, arte universal, perdão. Quem vibra no Nove ensina a soltar com gratidão e a servir sem se apagar.',
    shadow:
        'Na sombra, martiriza-se, dramatiza perdas e adia finais necessários.',
  ),
  11: NumberMeaning(
    number: 11,
    title: 'O Iluminador (Mestre)',
    keywords: ['intuição', 'inspiração', 'sensibilidade elevada', 'visão'],
    description:
        'O Onze é o canal: intuição à flor da pele, sonhos vívidos, capacidade de inspirar multidões. Vibra como um Dois amplificado — a missão é iluminar sem se queimar.',
    shadow:
        'Na sombra, ansiedade, nervosismo e fuga da própria potência.',
  ),
  22: NumberMeaning(
    number: 22,
    title: 'O Construtor Mestre',
    keywords: ['visão prática', 'grandes obras', 'legado', 'maestria'],
    description:
        'O Vinte e Dois materializa o impossível: une a visão do Onze à disciplina do Quatro. É energia de projetos que atravessam gerações — templos, instituições, legados.',
    shadow:
        'Na sombra, esmaga-se sob a própria expectativa ou domina pelos fins.',
  ),
  33: NumberMeaning(
    number: 33,
    title: 'O Mestre do Amor',
    keywords: ['cura', 'serviço amoroso', 'ensino', 'compaixão elevada'],
    description:
        'O Trinta e Três é raro: o Seis elevado à devoção universal. Vibra como cura pelo exemplo — ensinar amando, servir sem esperar retorno.',
    shadow:
        'Na sombra, sacrifício extremo e negação das próprias necessidades.',
  ),
};


const profileNumberInfosPt = <String, ProfileNumberInfo>{
  'lifePath': ProfileNumberInfo(
    label: 'Caminho de Vida',
    emoji: '🌟',
    explanation:
        'Calculado a partir da sua data de nascimento, revela a grande lição e a direção da sua jornada.',
  ),
  'expression': ProfileNumberInfo(
    label: 'Expressão',
    emoji: '🗣️',
    explanation:
        'Soma de todas as letras do nome completo: os talentos e a forma como você se apresenta ao mundo.',
  ),
  'soulUrge': ProfileNumberInfo(
    label: 'Alma',
    emoji: '💜',
    explanation:
        'Apenas as vogais do nome: o que o seu coração deseja em silêncio, suas motivações profundas.',
  ),
  'personality': ProfileNumberInfo(
    label: 'Personalidade',
    emoji: '🎭',
    explanation:
        'Apenas as consoantes: a primeira impressão que você causa, a face que o mundo vê.',
  ),
  'personalYear': ProfileNumberInfo(
    label: 'Ano Pessoal',
    emoji: '🗓️',
    explanation:
        'O tema do seu ciclo anual atual — a energia disponível para este ano da sua vida.',
  ),
};


/// Mensagens das sequências repetidas clássicas (visão mística popular +
/// leitura numerológica). A leitura numérica reduzida complementa cada uma.
const Map<String, String> repeatedSequenceMessagesPt = {
  '000': 'Portal do infinito: um ciclo se fecha e tudo é possível. Momento de escolher com consciência o que plantar.',
  '111': 'Alinhamento e manifestação: seus pensamentos estão criando rápido. Foque no que deseja, não no que teme.',
  '222': 'Confiança e paciência: as parcerias e o tempo certo estão trabalhando a seu favor. Mantenha a fé no processo.',
  '333': 'Presença dos mestres e da criatividade: expresse-se, crie, comunique. Você está sendo amparado.',
  '444': 'Proteção e estrutura: seus guardiões confirmam que o alicerce é sólido. Continue o trabalho.',
  '555': 'Mudança à vista: prepare-se para transformações libertadoras. Solte o que já cumpriu seu papel.',
  '666': 'Reequilíbrio: excesso de preocupação material. Volte ao coração, ao lar e ao que realmente nutre.',
  '777': 'Sorte espiritual: você está no caminho certo do aprendizado. Aprofunde seus estudos e sua intuição.',
  '888': 'Abundância em fluxo: colheita e prosperidade se aproximam. Receba com gratidão e faça circular.',
  '999': 'Encerramento sagrado: um grande ciclo se completa. Feche com amor para o novo poder chegar.',
  '1010': 'Novo nível: um passo de cada vez, você está subindo em espiral. Confie na direção.',
  '1212': 'Crescimento harmônico: fé e ação em equilíbrio constroem o próximo capítulo.',
  '1234': 'Progressão: a vida confirma que você está avançando na ordem certa. Continue os passos.',
};
