/// Modelo para representar uma runa do Futhark Antigo
class Rune {
  final String name;
  final String symbol;
  final List<String> keywords;
  final String description;

  const Rune({
    required this.name,
    required this.symbol,
    required this.keywords,
    required this.description,
  });

  // Aliases para compatibilidade
  String get meaning => description;
  String get divination => description;
  String? get reversedMeaning => null; // Runas podem ser interpretadas ao contrário

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'keywords': keywords,
      'description': description,
    };
  }

  factory Rune.fromJson(Map<String, dynamic> json) {
    return Rune(
      name: json['name'],
      symbol: json['symbol'],
      keywords: List<String>.from(json['keywords']),
      description: json['description'],
    );
  }

  /// Lista completa das 24 runas do Futhark Antigo
  static List<Rune> getAllRunes() {
    return [
      const Rune(
        name: 'Fehu',
        symbol: 'ᚠ',
        keywords: ['Prosperidade', 'Riqueza', 'Abundância'],
        description:
            'Fehu representa riqueza móvel, prosperidade e abundância. '
            'Simboliza o gado, que era uma forma de riqueza na antiguidade. '
            'Em leituras, sugere ganhos materiais, novos começos prósperos '
            'e a energia necessária para manifestar seus objetivos.',
      ),
      const Rune(
        name: 'Uruz',
        symbol: 'ᚢ',
        keywords: ['Força', 'Vitalidade', 'Saúde'],
        description:
            'Uruz é a força bruta da natureza, a vitalidade do auroque selvagem. '
            'Representa força física e mental, resistência e boa saúde. '
            'Indica um período de grande energia, cura ou a necessidade '
            'de enfrentar desafios com coragem.',
      ),
      const Rune(
        name: 'Thurisaz',
        symbol: 'ᚦ',
        keywords: ['Proteção', 'Defesa', 'Desafio'],
        description:
            'Thurisaz é o espinho ou o martelo de Thor. Representa proteção, '
            'mas também conflito e desafio. Sugere a necessidade de defender-se '
            'ou de enfrentar obstáculos. Pode indicar uma situação que requer '
            'cautela e preparação.',
      ),
      const Rune(
        name: 'Ansuz',
        symbol: 'ᚨ',
        keywords: ['Comunicação', 'Sabedoria', 'Inspiração'],
        description:
            'Ansuz está ligada a Odin e representa comunicação divina, sabedoria '
            'e inspiração. Simboliza sinais, mensagens e conhecimento. '
            'Em leituras, sugere que você está recebendo orientação, '
            'ou que deve prestar atenção aos sinais ao seu redor.',
      ),
      const Rune(
        name: 'Raidho',
        symbol: 'ᚱ',
        keywords: ['Jornada', 'Movimento', 'Progresso'],
        description:
            'Raidho é a runa da viagem e do movimento. Representa jornadas '
            'físicas e espirituais, progresso e evolução. Sugere que você '
            'está em um caminho de crescimento, ou que é hora de avançar '
            'em alguma direção.',
      ),
      const Rune(
        name: 'Kenaz',
        symbol: 'ᚲ',
        keywords: ['Conhecimento', 'Criatividade', 'Iluminação'],
        description:
            'Kenaz é a tocha que ilumina a escuridão. Representa conhecimento, '
            'criatividade, inspiração e transformação através do aprendizado. '
            'Indica um período de descobertas, insights criativos ou '
            'desenvolvimento de habilidades.',
      ),
      const Rune(
        name: 'Gebo',
        symbol: 'ᚷ',
        keywords: ['Presente', 'Parceria', 'Troca'],
        description:
            'Gebo representa presentes, generosidade e trocas equilibradas. '
            'Simboliza parcerias, relacionamentos e reciprocidade. '
            'Sugere que você está em um período de dar e receber, '
            'ou que uma parceria importante está em destaque.',
      ),
      const Rune(
        name: 'Wunjo',
        symbol: 'ᚹ',
        keywords: ['Alegria', 'Harmonia', 'Satisfação'],
        description:
            'Wunjo é a runa da alegria, harmonia e realização. Representa '
            'felicidade, contentamento e períodos de paz. Indica que você '
            'está ou estará em um estado de harmonia e satisfação com a vida.',
      ),
      const Rune(
        name: 'Hagalaz',
        symbol: 'ᚺ',
        keywords: ['Disrupção', 'Mudança', 'Purificação'],
        description:
            'Hagalaz é o granizo - uma força disruptiva da natureza. '
            'Representa mudanças súbitas, eventos inesperados e purificação. '
            'Pode indicar um período de desafios que levam a transformação '
            'e crescimento.',
      ),
      const Rune(
        name: 'Nauthiz',
        symbol: 'ᚾ',
        keywords: ['Necessidade', 'Resistência', 'Superação'],
        description:
            'Nauthiz representa necessidade, restrição e resistência. '
            'Simboliza tempos difíceis que exigem paciência e perseverança. '
            'Sugere que você está enfrentando limitações, mas que pode '
            'superá-las através da determinação.',
      ),
      const Rune(
        name: 'Isa',
        symbol: 'ᛁ',
        keywords: ['Pausa', 'Estagnação', 'Introspecção'],
        description:
            'Isa é o gelo - imóvel e preservador. Representa pausa, estagnação '
            'e a necessidade de introspecção. Sugere um período de espera, '
            'reflexão ou congelamento de uma situação. Nem sempre é negativa; '
            'às vezes precisamos parar para avaliar.',
      ),
      const Rune(
        name: 'Jera',
        symbol: 'ᛃ',
        keywords: ['Colheita', 'Ciclos', 'Recompensa'],
        description:
            'Jera representa a colheita e os ciclos naturais do tempo. '
            'Simboliza recompensas por esforços passados e a importância '
            'do timing. Sugere que você colherá o que plantou, ou que é '
            'importante respeitar os ciclos naturais das coisas.',
      ),
      const Rune(
        name: 'Eihwaz',
        symbol: 'ᛇ',
        keywords: ['Proteção', 'Resistência', 'Transformação'],
        description:
            'Eihwaz é o teixo - árvore da vida e da morte. Representa proteção, '
            'resistência e transformação profunda. Simboliza a capacidade de '
            'sobreviver e se adaptar, mesmo em condições difíceis.',
      ),
      const Rune(
        name: 'Perthro',
        symbol: 'ᛈ',
        keywords: ['Mistério', 'Destino', 'Oculto'],
        description:
            'Perthro é o copo de dados - representa mistério, destino e o '
            'desconhecido. Simboliza segredos, coisas ocultas e o elemento '
            'de chance na vida. Sugere que há forças em jogo além do que você '
            'pode ver ou controlar.',
      ),
      const Rune(
        name: 'Algiz',
        symbol: 'ᛉ',
        keywords: ['Proteção', 'Defesa', 'Conexão Divina'],
        description:
            'Algiz representa proteção divina e conexão espiritual. '
            'Simboliza a mão erguida em proteção ou os chifres do alce. '
            'Sugere que você está protegido, ou que deve buscar orientação '
            'espiritual e confiar em sua intuição.',
      ),
      const Rune(
        name: 'Sowilo',
        symbol: 'ᛊ',
        keywords: ['Sucesso', 'Vitalidade', 'Iluminação'],
        description:
            'Sowilo é o sol - fonte de vida e energia. Representa sucesso, '
            'vitalidade, clareza e iluminação. É uma runa extremamente positiva '
            'que indica vitória, realização e energia solar radiante.',
      ),
      const Rune(
        name: 'Tiwaz',
        symbol: 'ᛏ',
        keywords: ['Justiça', 'Honra', 'Liderança'],
        description:
            'Tiwaz está ligada ao deus Tyr e representa justiça, honra e '
            'liderança. Simboliza sacrifício por um bem maior e a vitória '
            'através da integridade. Sugere que você deve agir com honra '
            'e liderar pelo exemplo.',
      ),
      const Rune(
        name: 'Berkano',
        symbol: 'ᛒ',
        keywords: ['Crescimento', 'Fertilidade', 'Renovação'],
        description:
            'Berkano é a bétula - árvore do renascimento e fertilidade. '
            'Representa novos começos, crescimento, cuidado e nutrição. '
            'Simboliza processos de crescimento gradual, tanto físicos quanto '
            'espirituais.',
      ),
      const Rune(
        name: 'Ehwaz',
        symbol: 'ᛖ',
        keywords: ['Parceria', 'Confiança', 'Movimento'],
        description:
            'Ehwaz representa o cavalo - símbolo de parceria e confiança. '
            'Simboliza a relação entre cavalo e cavaleiro, sugerindo cooperação, '
            'lealdade e movimento conjunto. Indica parcerias harmoniosas e '
            'progresso através da colaboração.',
      ),
      const Rune(
        name: 'Mannaz',
        symbol: 'ᛗ',
        keywords: ['Humanidade', 'Autoconsciência', 'Comunidade'],
        description:
            'Mannaz representa a humanidade e a autoconsciência. Simboliza '
            'a mente humana, a sociedade e nossa conexão uns com os outros. '
            'Sugere reflexão sobre seu papel na comunidade e desenvolvimento '
            'da consciência.',
      ),
      const Rune(
        name: 'Laguz',
        symbol: 'ᛚ',
        keywords: ['Água', 'Intuição', 'Fluxo'],
        description:
            'Laguz é a água - fonte da vida e do inconsciente. Representa '
            'intuição, emoções e o fluxo natural da vida. Sugere que você '
            'deve confiar em seus instintos e seguir o fluxo, adaptando-se '
            'às circunstâncias.',
      ),
      const Rune(
        name: 'Ingwaz',
        symbol: 'ᛜ',
        keywords: ['Fertilidade', 'Potencial', 'Gestação'],
        description:
            'Ingwaz está ligada ao deus Ing e representa fertilidade e potencial. '
            'Simboliza períodos de gestação - quando algo está se desenvolvendo '
            'internamente antes de se manifestar. Sugere que é um tempo de '
            'preparação e cultivo.',
      ),
      const Rune(
        name: 'Dagaz',
        symbol: 'ᛞ',
        keywords: ['Dia', 'Despertar', 'Transformação'],
        description:
            'Dagaz é o dia - o amanhecer após a noite. Representa transformação, '
            'despertar e novos começos. Simboliza o momento de clareza quando '
            'tudo se ilumina. Indica um ponto de virada importante ou '
            'uma revelação transformadora.',
      ),
      const Rune(
        name: 'Othala',
        symbol: 'ᛟ',
        keywords: ['Herança', 'Lar', 'Ancestralidade'],
        description:
            'Othala representa herança ancestral, lar e propriedade. '
            'Simboliza raízes, tradições familiares e legados. Sugere conexão '
            'com suas raízes, questões de lar e família, ou recebimento de '
            'uma herança (material ou espiritual).',
      ),
    ];
  }

  /// Buscar runa por nome
  static Rune? findByName(String name) {
    try {
      return getAllRunes().firstWhere(
        (rune) => rune.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
