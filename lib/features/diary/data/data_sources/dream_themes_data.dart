/// Temas e simbolismos oníricos exibidos como cards na seção de
/// Interpretação de Sonhos. Conteúdo estático e gratuito.
class DreamTheme {
  final String id;
  final String emoji;
  final String title;
  final String summary;

  /// Diferentes possibilidades de leitura do símbolo — o texto sempre
  /// apresenta hipóteses, nunca certezas.
  final List<DreamThemeReading> readings;

  /// Convite final à reflexão pessoal.
  final String reflection;

  const DreamTheme({
    required this.id,
    required this.emoji,
    required this.title,
    required this.summary,
    required this.readings,
    required this.reflection,
  });
}

class DreamThemeReading {
  final String title;
  final String content;

  const DreamThemeReading({required this.title, required this.content});
}

const List<DreamTheme> dreamThemes = [
  DreamTheme(
    id: 'agua',
    emoji: '🌊',
    title: 'Água',
    summary: 'Emoções, inconsciente e fluxo da vida',
    readings: [
      DreamThemeReading(
        title: 'Estado das emoções',
        content:
            'A água costuma espelhar o momento emocional: águas calmas e cristalinas podem indicar serenidade e clareza; águas turvas, agitadas ou escuras podem apontar sentimentos confusos, represados ou que pedem atenção.',
      ),
      DreamThemeReading(
        title: 'O inconsciente profundo',
        content:
            'Na leitura junguiana, mares e oceanos representam o inconsciente. Mergulhar pode ser um convite a se conhecer melhor; afogar-se pode sugerir sensação de sobrecarga por emoções não elaboradas.',
      ),
      DreamThemeReading(
        title: 'Purificação e renovação',
        content:
            'Em muitas tradições mágicas, a água é o elemento da limpeza e da cura. Chuva, banhos e rios em sonho podem indicar um ciclo de purificação em curso — algo sendo lavado para dar lugar ao novo.',
      ),
    ],
    reflection:
        'Como estava a água do seu sonho — e como estão as suas emoções ao acordar? Registrar os dois lados ajuda a perceber padrões.',
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
            'Sonhar que cai é um dos sonhos mais universais e costuma acompanhar fases em que algo parece fora do controle: trabalho, relações, finanças. O corpo traduz em queda a insegurança do momento.',
      ),
      DreamThemeReading(
        title: 'Medo de decepcionar',
        content:
            'A queda também pode falar do medo de falhar aos olhos dos outros — a altura do "penhasco" costuma ser proporcional às expectativas que carregamos.',
      ),
      DreamThemeReading(
        title: 'Convite à entrega',
        content:
            'Em leituras místicas, cair sem se machucar (ou voar depois da queda) pode indicar que é seguro soltar o controle e confiar no fluxo — a queda vira travessia.',
      ),
    ],
    reflection:
        'O que na sua vida parece "sem chão" agora? Nomear esse medo já reduz o poder dele.',
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
            'Ser perseguido costuma representar algo que estamos evitando: uma conversa difícil, uma decisão adiada, um sentimento negado. O perseguidor é, muitas vezes, o próprio assunto pendente.',
      ),
      DreamThemeReading(
        title: 'A sombra interior',
        content:
            'Na psicologia dos sonhos, o que nos persegue pode ser uma parte de nós que rejeitamos — a "sombra". Virar-se e encarar o perseguidor, no sonho ou na imaginação ao acordar, costuma transformar o enredo.',
      ),
      DreamThemeReading(
        title: 'Pressões externas',
        content:
            'Também pode refletir cobranças reais: prazos, dívidas, expectativas de terceiros. O sonho exagera a imagem para que o recado seja ouvido.',
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
            'Na imensa maioria das tradições — do tarot ao simbolismo junguiano — a morte em sonho fala de fim de ciclo e renascimento, não de morte literal. Algo em você ou na sua vida está se encerrando para abrir espaço.',
      ),
      DreamThemeReading(
        title: 'Luto e saudade',
        content:
            'Sonhar com pessoas que já partiram pode ser parte natural do luto: o inconsciente elabora a ausência e, para muitas tradições espirituais, é também um espaço de encontro e despedida.',
      ),
      DreamThemeReading(
        title: 'O que precisa ir',
        content:
            'Quando quem "morre" no sonho é o próprio sonhador, vale perguntar: que versão de mim está pronta para ficar no passado? Hábitos, papéis e identidades também morrem.',
      ),
    ],
    reflection:
        'Que ciclo está se fechando na sua vida? Honrar o fim é o primeiro passo do recomeço.',
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
            'Animais em sonho costumam encarnar instintos: um lobo pode falar de lealdade e território; um gato, de independência e mistério; uma serpente, de transformação e energia vital.',
      ),
      DreamThemeReading(
        title: 'Animais de poder',
        content:
            'Em tradições xamânicas e da bruxaria, um animal recorrente pode ser lido como aliado ou guia espiritual. Observe o comportamento dele no sonho: ameaça, protege, conduz?',
      ),
      DreamThemeReading(
        title: 'Relação com o próprio corpo',
        content:
            'Animais feridos ou presos podem espelhar necessidades básicas negligenciadas — descanso, alimentação, prazer, movimento.',
      ),
    ],
    reflection:
        'Qual animal apareceu e o que ele estava fazendo? Pesquise o simbolismo dele nas tradições que fazem sentido para você.',
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
            'Dentes caindo é um clássico ligado à autoimagem e ao medo do julgamento: como serei visto se eu "perder a fachada"? Costuma surgir em fases de exposição — novo emprego, relação, mudança.',
      ),
      DreamThemeReading(
        title: 'Sensação de impotência',
        content:
            'Dentes são a nossa "mordida" no mundo. Perdê-los pode indicar sensação de perda de força, voz ou capacidade de se defender em alguma área.',
      ),
      DreamThemeReading(
        title: 'Transição e crescimento',
        content:
            'Assim como os dentes de leite caem para dar lugar aos definitivos, o sonho pode marcar uma transição de fase — desconfortável, mas necessária.',
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
            'A casa costuma representar quem sonha: a fachada é a imagem social; a sala, a convivência; o quarto, a intimidade; o banheiro, a limpeza emocional; a cozinha, a criatividade e o cuidado.',
      ),
      DreamThemeReading(
        title: 'Cômodos desconhecidos',
        content:
            'Descobrir quartos novos ou andares secretos é um sonho poderoso: aponta talentos, memórias ou possibilidades que você ainda não explorou em si.',
      ),
      DreamThemeReading(
        title: 'Estado da estrutura',
        content:
            'Casa em ruínas, alagada ou invadida pode falar de limites pessoais fragilizados ou de cansaço estrutural — o corpo e a rotina pedindo reforma.',
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
            'Voar com prazer costuma acompanhar fases de expansão: um peso saiu, um limite foi superado, uma decisão libertadora foi tomada.',
      ),
      DreamThemeReading(
        title: 'Ganhar perspectiva',
        content:
            'Ver o mundo do alto pode indicar a necessidade — ou a recém-adquirida capacidade — de olhar um problema de longe, com visão de conjunto.',
      ),
      DreamThemeReading(
        title: 'Fuga do chão',
        content:
            'Se o voo é para escapar de algo, vale perguntar se há um assunto "terreno" sendo evitado. Voos instáveis podem falar de idealização sem base prática.',
      ),
    ],
    reflection:
        'O voo era leve ou ansioso? Liberdade e fuga às vezes usam as mesmas asas.',
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
            'Sonhar com gravidez raramente é literal: costuma indicar um projeto, ideia, relação ou versão de si em gestação — algo que cresce em silêncio e ainda não veio ao mundo.',
      ),
      DreamThemeReading(
        title: 'Tempo de maturação',
        content:
            'O sonho pode lembrar que há um tempo certo: gestações não se apressam. Ansiedade com o "parto" pode espelhar pressa com resultados.',
      ),
      DreamThemeReading(
        title: 'Potencial criativo',
        content:
            'Na bruxaria, a gravidez onírica é frequentemente lida como fertilidade em sentido amplo — criatividade, abundância e manifestação a caminho.',
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
            'Ex-parceiros, amigos distantes ou colegas antigos costumam aparecer quando algo daquela época pede fechamento: um perdão, uma lição, uma palavra não dita.',
      ),
      DreamThemeReading(
        title: 'Qualidades a resgatar',
        content:
            'A pessoa pode representar uma característica sua daquela fase — coragem, leveza, disciplina — que o presente está pedindo de volta.',
      ),
      DreamThemeReading(
        title: 'Ciclos comparados',
        content:
            'O inconsciente também usa o passado como régua: aparece quem viveu com você um ciclo parecido com o atual, convidando a comparar escolhas.',
      ),
    ],
    reflection:
        'O que essa pessoa representava para você? Talvez o recado seja sobre essa qualidade, não sobre ela.',
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
            'Cidades, estradas e paisagens nunca vistas costumam anunciar fases inéditas — interna ou externamente. O tom do lugar (acolhedor, hostil, vasto) indica como você sente essa novidade.',
      ),
      DreamThemeReading(
        title: 'Potenciais não visitados',
        content:
            'Como os cômodos secretos da casa, terras desconhecidas podem representar capacidades suas ainda não exploradas.',
      ),
      DreamThemeReading(
        title: 'Sensação de deslocamento',
        content:
            'Perder-se em lugar estranho pode espelhar a sensação de não pertencer — a um grupo, trabalho ou fase. O sonho pede que você se localize: o que é seu ali?',
      ),
    ],
    reflection:
        'Você se sentia perdido ou explorando? A mesma paisagem muda de sentido conforme a sensação.',
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
            'A repetição costuma indicar um tema não resolvido: o inconsciente reapresenta a cena até que algo mude na vida desperta. Pequenas variações entre as versões são pistas valiosas.',
      ),
      DreamThemeReading(
        title: 'Padrões emocionais',
        content:
            'Sonhos recorrentes frequentemente acompanham padrões que se repetem em relações ou escolhas. Quando o padrão muda na vida real, o sonho costuma mudar junto — ou cessar.',
      ),
      DreamThemeReading(
        title: 'Como trabalhar',
        content:
            'Registrar cada ocorrência no Diário de Sonhos, comparar detalhes e conversar com o sonho (imaginar finais diferentes antes de dormir) são práticas clássicas para destravar a repetição.',
      ),
    ],
    reflection:
        'O que mudou nas últimas versões do sonho? A variação é o termômetro do seu processo.',
  ),
];
