import '../models/dream_theme_model.dart';

/// Temas e simbolismos oníricos — conteúdo em português.
///
/// Ids e emojis são invariantes entre idiomas; apenas títulos, resumos,
/// leituras e reflexões são traduzidos. Mantenha a mesma ordem nos três
/// arquivos (`dream_themes_data_pt/en/es.dart`) — a paridade é verificada em
/// `test/dream_themes_parity_test.dart`.
const List<DreamTheme> dreamThemesPt = [
  DreamTheme(
    id: 'agua',
    emoji: '🌊',
    title: 'Água',
    summary: 'Emoções, inconsciente e fluxo da vida',
    readings: [
      DreamThemeReading(
        title: 'Estado das emoções',
        content:
            'A água costuma espelhar o momento emocional: águas calmas e cristalinas podem indicar serenidade e clareza; águas turvas, agitadas ou escuras podem apontar sentimentos confusos, represados ou que pedem atenção',
      ),
      DreamThemeReading(
        title: 'O inconsciente profundo',
        content:
            'Na leitura junguiana, mares e oceanos representam o inconsciente. Mergulhar pode ser um convite a se conhecer melhor; afogar-se pode sugerir sensação de sobrecarga por emoções não elaboradas',
      ),
      DreamThemeReading(
        title: 'Purificação e renovação',
        content:
            'Em muitas tradições mágicas, a água é o elemento da limpeza e da cura. Chuva, banhos e rios em sonho podem indicar um ciclo de purificação em curso — algo sendo lavado para dar lugar ao novo',
      ),
    ],
    reflection:
        'Como estava a água do seu sonho — e como estão as suas emoções ao acordar? Registrar os dois lados ajuda a perceber padrões',
  ),
  DreamTheme(
    id: 'queda',
    emoji: '🪂',
    title: 'Queda',
    summary: 'Perda de controle e medo de falhar',
    readings: [
      DreamThemeReading(
        title: 'Sensação de descontrole',
        content:
            'Sonhar que cai é um dos sonhos mais universais e costuma acompanhar fases em que algo parece fora do controle: trabalho, relações, finanças. O corpo traduz em queda a insegurança do momento',
      ),
      DreamThemeReading(
        title: 'Medo de decepcionar',
        content:
            'A queda também pode falar do medo de falhar aos olhos dos outros — a altura do "penhasco" costuma ser proporcional às expectativas que carregamos',
      ),
      DreamThemeReading(
        title: 'Convite à entrega',
        content:
            'Em leituras místicas, cair sem se machucar (ou voar depois da queda) pode indicar que é seguro soltar o controle e confiar no fluxo — a queda vira travessia',
      ),
    ],
    reflection:
        'O que na sua vida parece "sem chão" agora? Nomear esse medo já reduz o poder dele',
  ),
  DreamTheme(
    id: 'perseguicao',
    emoji: '🏃',
    title: 'Perseguição',
    summary: 'Aquilo que evitamos encarar',
    readings: [
      DreamThemeReading(
        title: 'Fuga de um conflito',
        content:
            'Ser perseguido costuma representar algo que estamos evitando: uma conversa difícil, uma decisão adiada, um sentimento negado. O perseguidor é, muitas vezes, o próprio assunto pendente',
      ),
      DreamThemeReading(
        title: 'A sombra interior',
        content:
            'Na psicologia dos sonhos, o que nos persegue pode ser uma parte de nós que rejeitamos — a "sombra". Virar-se e encarar o perseguidor, no sonho ou na imaginação ao acordar, costuma transformar o enredo',
      ),
      DreamThemeReading(
        title: 'Pressões externas',
        content:
            'Também pode refletir cobranças reais: prazos, dívidas, expectativas de terceiros. O sonho exagera a imagem para que o recado seja ouvido',
      ),
    ],
    reflection:
        'Se você parasse de correr e olhasse para trás, quem — ou o quê — estaria lá?',
  ),
  DreamTheme(
    id: 'morte',
    emoji: '🦋',
    title: 'Morte',
    summary: 'Fim de ciclo e transformação',
    readings: [
      DreamThemeReading(
        title: 'Transformação, não presságio',
        content:
            'Na imensa maioria das tradições — do tarot ao simbolismo junguiano — a morte em sonho fala de fim de ciclo e renascimento, não de morte literal. Algo em você ou na sua vida está se encerrando para abrir espaço',
      ),
      DreamThemeReading(
        title: 'Luto e saudade',
        content:
            'Sonhar com pessoas que já partiram pode ser parte natural do luto: o inconsciente elabora a ausência e, para muitas tradições espirituais, é também um espaço de encontro e despedida',
      ),
      DreamThemeReading(
        title: 'O que precisa ir',
        content:
            'Quando quem "morre" no sonho é o próprio sonhador, vale perguntar: que versão de mim está pronta para ficar no passado? Hábitos, papéis e identidades também morrem',
      ),
    ],
    reflection:
        'Que ciclo está se fechando na sua vida? Honrar o fim é o primeiro passo do recomeço',
  ),
  DreamTheme(
    id: 'animais',
    emoji: '🦉',
    title: 'Animais',
    summary: 'Instintos e guias da natureza',
    readings: [
      DreamThemeReading(
        title: 'A voz dos instintos',
        content:
            'Animais em sonho costumam encarnar instintos: um lobo pode falar de lealdade e território; um gato, de independência e mistério; uma serpente, de transformação e energia vital',
      ),
      DreamThemeReading(
        title: 'Animais de poder',
        content:
            'Em tradições xamânicas e da bruxaria, um animal recorrente pode ser lido como aliado ou guia espiritual. Observe o comportamento dele no sonho: ameaça, protege, conduz?',
      ),
      DreamThemeReading(
        title: 'Relação com o próprio corpo',
        content:
            'Animais feridos ou presos podem espelhar necessidades básicas negligenciadas — descanso, alimentação, prazer, movimento',
      ),
    ],
    reflection:
        'Qual animal apareceu e o que ele estava fazendo? Pesquise o simbolismo dele nas tradições que fazem sentido para você',
  ),
  DreamTheme(
    id: 'dentes',
    emoji: '🦷',
    title: 'Dentes',
    summary: 'Autoimagem, poder pessoal e perdas',
    readings: [
      DreamThemeReading(
        title: 'Insegurança com a imagem',
        content:
            'Dentes caindo é um clássico ligado à autoimagem e ao medo do julgamento: como serei visto se eu "perder a fachada"? Costuma surgir em fases de exposição — novo emprego, relação, mudança',
      ),
      DreamThemeReading(
        title: 'Sensação de impotência',
        content:
            'Dentes são a nossa "mordida" no mundo. Perdê-los pode indicar sensação de perda de força, voz ou capacidade de se defender em alguma área',
      ),
      DreamThemeReading(
        title: 'Transição e crescimento',
        content:
            'Assim como os dentes de leite caem para dar lugar aos definitivos, o sonho pode marcar uma transição de fase — desconfortável, mas necessária',
      ),
    ],
    reflection:
        'Em que situação recente você sentiu que "perdeu a voz" ou o poder de reagir?',
  ),
  DreamTheme(
    id: 'casa',
    emoji: '🏠',
    title: 'Casa',
    summary: 'O eu e seus cômodos internos',
    readings: [
      DreamThemeReading(
        title: 'Mapa de si',
        content:
            'A casa costuma representar quem sonha: a fachada é a imagem social; a sala, a convivência; o quarto, a intimidade; o banheiro, a limpeza emocional; a cozinha, a criatividade e o cuidado',
      ),
      DreamThemeReading(
        title: 'Cômodos desconhecidos',
        content:
            'Descobrir quartos novos ou andares secretos é um sonho poderoso: aponta talentos, memórias ou possibilidades que você ainda não explorou em si',
      ),
      DreamThemeReading(
        title: 'Estado da estrutura',
        content:
            'Casa em ruínas, alagada ou invadida pode falar de limites pessoais fragilizados ou de cansaço estrutural — o corpo e a rotina pedindo reforma',
      ),
    ],
    reflection:
        'Que cômodo apareceu e em que estado ele estava? O que isso diz sobre essa área da sua vida?',
  ),
  DreamTheme(
    id: 'voo',
    emoji: '🕊️',
    title: 'Voar',
    summary: 'Liberdade, perspectiva e expansão',
    readings: [
      DreamThemeReading(
        title: 'Liberdade conquistada',
        content:
            'Voar com prazer costuma acompanhar fases de expansão: um peso saiu, um limite foi superado, uma decisão libertadora foi tomada',
      ),
      DreamThemeReading(
        title: 'Ganhar perspectiva',
        content:
            'Ver o mundo do alto pode indicar a necessidade — ou a recém-adquirida capacidade — de olhar um problema de longe, com visão de conjunto',
      ),
      DreamThemeReading(
        title: 'Fuga do chão',
        content:
            'Se o voo é para escapar de algo, vale perguntar se há um assunto "terreno" sendo evitado. Voos instáveis podem falar de idealização sem base prática',
      ),
    ],
    reflection:
        'O voo era leve ou ansioso? Liberdade e fuga às vezes usam as mesmas asas',
  ),
  DreamTheme(
    id: 'gravidez',
    emoji: '🌱',
    title: 'Gravidez',
    summary: 'Projetos e novos começos gestando',
    readings: [
      DreamThemeReading(
        title: 'Algo novo sendo gerado',
        content:
            'Sonhar com gravidez raramente é literal: costuma indicar um projeto, ideia, relação ou versão de si em gestação — algo que cresce em silêncio e ainda não veio ao mundo',
      ),
      DreamThemeReading(
        title: 'Tempo de maturação',
        content:
            'O sonho pode lembrar que há um tempo certo: gestações não se apressam. Ansiedade com o "parto" pode espelhar pressa com resultados',
      ),
      DreamThemeReading(
        title: 'Potencial criativo',
        content:
            'Na bruxaria, a gravidez onírica é frequentemente lida como fertilidade em sentido amplo — criatividade, abundância e manifestação a caminho',
      ),
    ],
    reflection:
        'O que você está gestando agora — e o que esse projeto precisa para nascer bem?',
  ),
  DreamTheme(
    id: 'pessoas-do-passado',
    emoji: '🕰️',
    title: 'Pessoas do Passado',
    summary: 'Memórias, pendências e reintegração',
    readings: [
      DreamThemeReading(
        title: 'Assuntos inacabados',
        content:
            'Ex-parceiros, amigos distantes ou colegas antigos costumam aparecer quando algo daquela época pede fechamento: um perdão, uma lição, uma palavra não dita',
      ),
      DreamThemeReading(
        title: 'Qualidades a resgatar',
        content:
            'A pessoa pode representar uma característica sua daquela fase — coragem, leveza, disciplina — que o presente está pedindo de volta',
      ),
      DreamThemeReading(
        title: 'Ciclos comparados',
        content:
            'O inconsciente também usa o passado como régua: aparece quem viveu com você um ciclo parecido com o atual, convidando a comparar escolhas',
      ),
    ],
    reflection:
        'O que essa pessoa representava para você? Talvez o recado seja sobre essa qualidade, não sobre ela',
  ),
  DreamTheme(
    id: 'lugares-desconhecidos',
    emoji: '🗺️',
    title: 'Lugares Desconhecidos',
    summary: 'Territórios internos inexplorados',
    readings: [
      DreamThemeReading(
        title: 'O novo chamando',
        content:
            'Cidades, estradas e paisagens nunca vistas costumam anunciar fases inéditas — interna ou externamente. O tom do lugar (acolhedor, hostil, vasto) indica como você sente essa novidade',
      ),
      DreamThemeReading(
        title: 'Potenciais não visitados',
        content:
            'Como os cômodos secretos da casa, terras desconhecidas podem representar capacidades suas ainda não exploradas',
      ),
      DreamThemeReading(
        title: 'Sensação de deslocamento',
        content:
            'Perder-se em lugar estranho pode espelhar a sensação de não pertencer — a um grupo, trabalho ou fase. O sonho pede que você se localize: o que é seu ali?',
      ),
    ],
    reflection:
        'Você se sentia perdido ou explorando? A mesma paisagem muda de sentido conforme a sensação',
  ),
  DreamTheme(
    id: 'sonhos-recorrentes',
    emoji: '🔁',
    title: 'Sonhos Recorrentes',
    summary: 'Recados que insistem até serem ouvidos',
    readings: [
      DreamThemeReading(
        title: 'Mensagem não atendida',
        content:
            'A repetição costuma indicar um tema não resolvido: o inconsciente reapresenta a cena até que algo mude na vida desperta. Pequenas variações entre as versões são pistas valiosas',
      ),
      DreamThemeReading(
        title: 'Padrões emocionais',
        content:
            'Sonhos recorrentes frequentemente acompanham padrões que se repetem em relações ou escolhas. Quando o padrão muda na vida real, o sonho costuma mudar junto — ou cessar',
      ),
      DreamThemeReading(
        title: 'Como trabalhar',
        content:
            'Registrar cada ocorrência no Diário de Sonhos, comparar detalhes e conversar com o sonho (imaginar finais diferentes antes de dormir) são práticas clássicas para destravar a repetição',
      ),
    ],
    reflection:
        'O que mudou nas últimas versões do sonho? A variação é o termômetro do seu processo',
  ),
  DreamTheme(
    id: 'fogo',
    emoji: '🔥',
    title: 'Fogo',
    summary: 'Paixão, raiva e transformação intensa',
    readings: [
      DreamThemeReading(
        title: 'Energia vital em movimento',
        content:
            'O fogo é o elemento da vontade e da paixão. Chamas controladas — uma vela, uma fogueira acolhedora — costumam falar de entusiasmo, desejo e força criativa em boa medida',
      ),
      DreamThemeReading(
        title: 'Raiva e sobrecarga',
        content:
            'Incêndios fora de controle podem espelhar emoções quentes represadas: raiva engolida, estresse acumulado, um limite prestes a estourar. O sonho mostra o tamanho da fervura interna',
      ),
      DreamThemeReading(
        title: 'Purificação pela queima',
        content:
            'Em muitas tradições mágicas, queimar é transmutar: o que o fogo consome no sonho pode indicar o que precisa ser destruído para virar adubo — um hábito, um vínculo, uma versão de si',
      ),
    ],
    reflection:
        'O fogo do seu sonho aquecia ou destruía? Observe onde essa mesma energia aparece na sua vida desperta',
  ),
  DreamTheme(
    id: 'serpente',
    emoji: '🐍',
    title: 'Serpente',
    summary: 'Transformação, cura e energia vital',
    readings: [
      DreamThemeReading(
        title: 'Troca de pele',
        content:
            'A serpente é o grande símbolo da renovação: ela troca de pele para crescer. Sonhar com cobras costuma acompanhar fases de transformação profunda — desconfortáveis, mas necessárias',
      ),
      DreamThemeReading(
        title: 'Cura e sabedoria',
        content:
            'Do bastão de Asclépio à kundalini, a serpente também representa cura e energia vital ascendente. Uma cobra tranquila pode indicar poder pessoal e intuição despertando',
      ),
      DreamThemeReading(
        title: 'Alerta e traição',
        content:
            'No imaginário popular, a cobra escondida fala de perigos silenciosos: situações ou pessoas que pedem atenção. O medo sentido no sonho é a pista — pavor e fascínio contam histórias diferentes',
      ),
    ],
    reflection:
        'A serpente atacava, observava ou apenas seguia o caminho dela? Sua reação no sonho diz tanto quanto o símbolo',
  ),
  DreamTheme(
    id: 'bebe',
    emoji: '👶',
    title: 'Bebê',
    summary: 'Começos, vulnerabilidade e cuidado',
    readings: [
      DreamThemeReading(
        title: 'Algo recém-nascido',
        content:
            'Um bebê em sonho costuma representar o que acabou de nascer na sua vida: um projeto, uma relação, uma fase. O estado do bebê — saudável, chorando, esquecido — espelha como esse começo está sendo cuidado',
      ),
      DreamThemeReading(
        title: 'A criança interior',
        content:
            'O bebê também pode ser a sua própria parte mais vulnerável pedindo colo: necessidades básicas de afeto, descanso e acolhimento que a vida adulta atropelou',
      ),
      DreamThemeReading(
        title: 'Responsabilidade nova',
        content:
            'Sonhar que precisa cuidar de um bebê que não é seu pode falar de responsabilidades recém-assumidas — e do medo de não dar conta delas',
      ),
    ],
    reflection:
        'O que na sua vida está em fase de recém-nascido agora — e que cuidado ele está (ou não está) recebendo?',
  ),
  DreamTheme(
    id: 'dinheiro',
    emoji: '💰',
    title: 'Dinheiro',
    summary: 'Valor pessoal, troca e energia de abundância',
    readings: [
      DreamThemeReading(
        title: 'O seu próprio valor',
        content:
            'Dinheiro em sonho raramente é só dinheiro: encontrar moedas ou notas costuma falar de recursos internos descobertos — talentos, tempo, energia — e de quanto você se sente valiosa',
      ),
      DreamThemeReading(
        title: 'Perda e medo de faltar',
        content:
            'Perder dinheiro, ser roubada ou não conseguir pagar algo pode espelhar insegurança material real ou a sensação de estar gastando energia com o que não retorna',
      ),
      DreamThemeReading(
        title: 'Fluxo de troca',
        content:
            'Na leitura mágica, o dinheiro é um símbolo de fluxo: o que você dá e o que recebe. Sonhos de abundância podem confirmar que o fluxo está aberto — ou compensar uma fase de aperto',
      ),
    ],
    reflection:
        'No sonho, o dinheiro chegava ou escapava? Compare com o que você anda dando e recebendo — em todas as moedas, não só a financeira',
  ),
  DreamTheme(
    id: 'nudez',
    emoji: '🙈',
    title: 'Nudez em Público',
    summary: 'Exposição, vergonha e autenticidade',
    readings: [
      DreamThemeReading(
        title: 'Medo de ser vista de verdade',
        content:
            'Estar nua em público é o clássico sonho da exposição: costuma surgir quando algo íntimo — um erro, um sentimento, um projeto pessoal — está prestes a ficar visível, e há medo do julgamento',
      ),
      DreamThemeReading(
        title: 'Vergonha que só é sua',
        content:
            'Um detalhe revelador: em muitos desses sonhos, ninguém repara na nudez. O inconsciente sugere que a vergonha é maior por dentro do que aos olhos dos outros',
      ),
      DreamThemeReading(
        title: 'Convite à autenticidade',
        content:
            'Em leituras mais luminosas, a nudez fala de se mostrar sem máscaras. Sentir-se livre no sonho, mesmo nua, pode indicar uma fase de aceitação e verdade consigo mesma',
      ),
    ],
    reflection:
        'O que você teme que descubram sobre você — e o que aconteceria, de verdade, se descobrissem?',
  ),
  DreamTheme(
    id: 'provas-atrasos',
    emoji: '⏰',
    title: 'Provas e Atrasos',
    summary: 'Cobrança, preparo e medo de não dar conta',
    readings: [
      DreamThemeReading(
        title: 'Sensação de despreparo',
        content:
            'Chegar atrasada, perder o voo, fazer uma prova sem ter estudado: são variações do mesmo tema — a sensação de que a vida cobra mais do que você conseguiu preparar',
      ),
      DreamThemeReading(
        title: 'Autoexigência em excesso',
        content:
            'Curiosamente, esse sonho é comum em pessoas muito responsáveis. A "prova" é o tribunal interno: uma régua alta demais aplicada a si mesma, não uma avaliação real',
      ),
      DreamThemeReading(
        title: 'Revisão de prioridades',
        content:
            'O atraso também pode indicar que você está correndo atrás de um horário que não é o seu — prazos e marcos definidos por outras pessoas. Talvez o relógio do sonho não deva mandar na sua vida',
      ),
    ],
    reflection:
        'Que prova você sente que está fazendo na vida real agora — e quem foi que marcou essa prova?',
  ),
  DreamTheme(
    id: 'traicao',
    emoji: '💔',
    title: 'Traição',
    summary: 'Confiança, insegurança e lealdade consigo',
    readings: [
      DreamThemeReading(
        title: 'Insegurança, não profecia',
        content:
            'Sonhar com traição do par raramente denuncia um fato: costuma espelhar insegurança no vínculo, carência de atenção ou feridas antigas de confiança pedindo cuidado',
      ),
      DreamThemeReading(
        title: 'Traição de si mesma',
        content:
            'Vale virar o espelho: em que área você tem se traído — engolindo o que sente, adiando o que importa, dizendo sim quando era não? O sonho empresta o rosto de outra pessoa para uma dor interna',
      ),
      DreamThemeReading(
        title: 'Quebra de expectativa',
        content:
            'Ser traída por amigos ou colegas no sonho pode falar de expectativas não ditas: acordos que só existiam na sua cabeça e que a outra pessoa nem sabia que assinou',
      ),
    ],
    reflection:
        'A dor do sonho aponta para a outra pessoa ou para um acordo que você fez sozinha? Conversar desfaz metade dessas tramas',
  ),
  DreamTheme(
    id: 'espelho',
    emoji: '🪞',
    title: 'Espelho',
    summary: 'Identidade, autoimagem e verdade interior',
    readings: [
      DreamThemeReading(
        title: 'Encontro com a própria imagem',
        content:
            'O espelho confronta: ver-se diferente, mais velha, mais jovem ou irreconhecível costuma acompanhar fases de mudança de identidade — quando a imagem interna ainda não alcançou a nova vida',
      ),
      DreamThemeReading(
        title: 'O que o reflexo esconde',
        content:
            'Espelhos vazios, embaçados ou quebrados podem falar de desconexão consigo mesma: cansaço de se performar, dificuldade de saber o que se quer e o que se sente',
      ),
      DreamThemeReading(
        title: 'Portal e adivinhação',
        content:
            'Na bruxaria, o espelho é ferramenta de vidência e portal simbólico. Atravessá-lo ou ver outra cena refletida pode indicar intuição aguçada e convite a olhar além da superfície',
      ),
    ],
    reflection:
        'Se você se olhasse no espelho agora, por dentro: a imagem que veria combina com a vida que está vivendo?',
  ),
];
