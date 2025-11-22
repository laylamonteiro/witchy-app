import '../models/enums.dart';

/// Interpretações mágicas de cada planeta em cada signo
/// Para ajudar iniciantes a entenderem seu mapa astral de forma prática
class PlanetSignInterpretations {
  /// Retorna a interpretação mágica de um planeta em um signo
  static String getInterpretation(Planet planet, ZodiacSign sign) {
    final key = '${planet.name}_${sign.name}';
    return _interpretations[key] ?? _getDefaultInterpretation(planet, sign);
  }

  /// Interpretação padrão caso não exista uma específica
  static String _getDefaultInterpretation(Planet planet, ZodiacSign sign) {
    return 'Seu ${planet.displayName} em ${sign.displayName} combina a energia '
        '${_getPlanetEnergy(planet)} com as qualidades ${sign.magicalDescription} '
        'deste signo de ${sign.element.displayName}.';
  }

  static String _getPlanetEnergy(Planet planet) {
    switch (planet) {
      case Planet.sun:
        return 'da sua essência vital';
      case Planet.moon:
        return 'das suas emoções e intuição';
      case Planet.mercury:
        return 'da sua comunicação e mente';
      case Planet.venus:
        return 'do amor e da beleza';
      case Planet.mars:
        return 'da ação e proteção';
      case Planet.jupiter:
        return 'da expansão e sorte';
      case Planet.saturn:
        return 'da disciplina e estrutura';
      case Planet.uranus:
        return 'da inovação e liberdade';
      case Planet.neptune:
        return 'da espiritualidade e sonhos';
      case Planet.pluto:
        return 'da transformação profunda';
      case Planet.northNode:
        return 'do seu destino kármico';
      case Planet.southNode:
        return 'das suas vidas passadas';
    }
  }

  /// Base de dados completa de interpretações
  static const Map<String, String> _interpretations = {
    // SOL em cada signo
    'sun_aries':
        'Com o Sol em Áries, sua essência mágica é de FOGO INICIADOR. Você é uma bruxa '
            'guerreira, que não tem medo de começar novos projetos mágicos. Sua magia é mais '
            'forte quando você age com coragem e determinação. Rituais de proteção, força '
            'de vontade e novos começos são seus pontos fortes. Trabalhe com velas vermelhas '
            'e laranjas, e realize seus feitiços logo no início das lunações.',
    'sun_taurus':
        'Com o Sol em Touro, sua essência mágica é TERRENA e SENSUAL. Você é uma bruxa '
            'verde, conectada profundamente com a natureza e os ciclos da terra. Sua magia '
            'se manifesta melhor através dos sentidos - aromas, texturas, sabores. Rituais '
            'de prosperidade, amor e abundância material são naturais para você. Cristais, '
            'ervas e jardinagem mágica são seus aliados.',
    'sun_gemini':
        'Com o Sol em Gêmeos, sua essência mágica é MENTAL e COMUNICATIVA. Você é uma '
            'bruxa das palavras, mestre em encantamentos verbais e sigilos. Sua curiosidade '
            'te leva a explorar diversas tradições mágicas. Tarot, runas e qualquer forma '
            'de adivinhação são naturais para você. Use incensos e trabalhe com o elemento '
            'Ar para potencializar sua magia.',
    'sun_cancer':
        'Com o Sol em Câncer, sua essência mágica é LUNAR e INTUITIVA. Você é uma bruxa '
            'do lar, protetora natural da família e do espaço sagrado. Sua magia flui com '
            'os ciclos da Lua. Rituais de proteção doméstica, cura emocional e trabalho '
            'com ancestrais são seus dons. Banhos rituais e poções são especialmente '
            'poderosos em suas mãos.',
    'sun_leo':
        'Com o Sol em Leão, sua essência mágica é SOLAR e RADIANTE. Você é uma bruxa '
            'performática, que brilha em rituais de grupo. Sua presença energiza qualquer '
            'círculo mágico. Magia de glamour, sucesso e autoconfiança são naturais para '
            'você. Trabalhe com ouro, velas douradas e rituais ao meio-dia. Lidere rituais '
            'com coração generoso.',
    'sun_virgo':
        'Com o Sol em Virgem, sua essência mágica é PRÁTICA e CURATIVA. Você é uma '
            'bruxa herbalista, mestre em preparar remédios e poções com precisão. Sua '
            'atenção aos detalhes torna seus rituais impecáveis. Magia de cura, purificação '
            'e organização são seus pontos fortes. Mantenha um grimório detalhado e um altar '
            'perfeitamente organizado.',
    'sun_libra':
        'Com o Sol em Libra, sua essência mágica é HARMÔNICA e RELACIONAL. Você é uma '
            'bruxa diplomata, capaz de equilibrar energias e harmonizar ambientes. Magia de '
            'amor, parcerias e justiça são naturais para você. Seus altares são esteticamente '
            'belos. Trabalhe em duplas ou grupos para potencializar sua magia. Rituais de '
            'equilíbrio energético são sua especialidade.',
    'sun_scorpio':
        'Com o Sol em Escorpião, sua essência mágica é TRANSFORMADORA e PROFUNDA. Você '
            'é uma bruxa do oculto, sem medo de explorar os mistérios mais profundos. Sua '
            'magia é intensa e poderosa. Transformação, banimentos e trabalho com sombras '
            'são naturais para você. Rituais de morte e renascimento simbólico te fortalecem. '
            'Plutão é seu aliado nas transmutações.',
    'sun_sagittarius':
        'Com o Sol em Sagitário, sua essência mágica é EXPANSIVA e FILOSÓFICA. Você é '
            'uma bruxa aventureira, buscadora de verdades em diversas tradições. Sua magia '
            'se fortalece quando você estuda e viaja (física ou espiritualmente). Rituais '
            'de sorte, expansão e viagem astral são naturais. Júpiter abençoa sua jornada '
            'espiritual.',
    'sun_capricorn':
        'Com o Sol em Capricórnio, sua essência mágica é DISCIPLINADA e TRADICIONAL. '
            'Você é uma bruxa ancestral, conectada com práticas antigas e tradições familiares. '
            'Sua magia se fortalece com consistência e estrutura. Rituais de carreira, '
            'manifestação a longo prazo e proteção são seus pontos fortes. Saturno ensina '
            'paciência em sua prática.',
    'sun_aquarius':
        'Com o Sol em Aquário, sua essência mágica é INOVADORA e COLETIVA. Você é uma '
            'bruxa futurista, que traz novas ideias para práticas antigas. Sua magia é mais '
            'forte em grupo e para causas humanitárias. Rituais de liberdade, amizade e '
            'mudança social são naturais. Urano te inspira a quebrar paradigmas na bruxaria.',
    'sun_pisces':
        'Com o Sol em Peixes, sua essência mágica é MÍSTICA e COMPASSIVA. Você é uma '
            'bruxa vidente, naturalmente conectada com o mundo espiritual. Sua magia flui '
            'através de sonhos, visões e intuição pura. Mediunidade, canalização e cura '
            'empática são seus dons naturais. Netuno te guia nas jornadas espirituais.',

    // LUA em cada signo
    'moon_aries':
        'Com a Lua em Áries, suas emoções são INTENSAS e IMPULSIVAS. Você processa '
            'sentimentos através da ação. Sua intuição mágica é rápida e instintiva. '
            'Rituais espontâneos funcionam bem para você. Quando emocionalmente carregada, '
            'canalize em magia de proteção ou exercício físico ritual. A Lua em Áries '
            'potencializa feitiços de coragem.',
    'moon_taurus':
        'Com a Lua em Touro, suas emoções são ESTÁVEIS e SENSUAIS. Você encontra '
            'conforto emocional através dos sentidos - comida, natureza, toque. Sua '
            'intuição fala através do corpo. Rituais com elementos físicos (cristais, '
            'ervas, óleos) são especialmente eficazes. Você precisa de segurança emocional '
            'para sua magia fluir.',
    'moon_gemini':
        'Com a Lua em Gêmeos, suas emoções são VERSÁTEIS e COMUNICATIVAS. Você processa '
            'sentimentos falando ou escrevendo sobre eles. Sua intuição vem através de '
            'palavras, mensagens e sincronicidades. Journaling mágico e escrita automática '
            'são ferramentas poderosas. A Lua em Gêmeos potencializa adivinhação.',
    'moon_cancer':
        'Com a Lua em Câncer, você está EM CASA. Esta é a posição mais poderosa da Lua. '
            'Suas emoções são profundas, sua intuição é forte, e sua conexão com os ciclos '
            'lunares é natural. Você sente as fases da Lua no corpo. Toda magia lunar é '
            'amplificada para você. Trabalho com ancestrais e proteção familiar são dons naturais.',
    'moon_leo':
        'Com a Lua em Leão, suas emoções são DRAMÁTICAS e GENEROSAS. Você precisa se '
            'sentir especial e reconhecida para estar bem. Sua intuição brilha quando você '
            'está no palco ou liderando. Rituais teatrais e expressivos funcionam bem. '
            'A Lua em Leão potencializa magia de autoestima e expressão criativa.',
    'moon_virgo':
        'Com a Lua em Virgem, suas emoções são ANALÍTICAS e buscam ORDEM. Você processa '
            'sentimentos tentando entendê-los logicamente. Sua intuição fala através de '
            'detalhes e padrões. Rituais meticulosos e organizados te acalmam. A Lua em '
            'Virgem potencializa magia de cura e purificação.',
    'moon_libra':
        'Com a Lua em Libra, suas emoções buscam HARMONIA e BELEZA. Você precisa de paz '
            'e relacionamentos equilibrados para estar bem. Sua intuição fala através da '
            'estética e do senso de justiça. Rituais elegantes e equilibrados funcionam '
            'melhor. A Lua em Libra potencializa magia de relacionamentos.',
    'moon_scorpio':
        'Com a Lua em Escorpião, suas emoções são INTENSAS e TRANSFORMADORAS. Você '
            'sente tudo profundamente e não tem medo do escuro emocional. Sua intuição '
            'psíquica é poderosa. Rituais de transformação e trabalho com sombras são '
            'naturais. A Lua em Escorpião amplifica magia oculta e de banimento.',
    'moon_sagittarius':
        'Com a Lua em Sagitário, suas emoções buscam LIBERDADE e SIGNIFICADO. Você '
            'precisa de espaço emocional e propósito. Sua intuição fala através de visões '
            'e insights filosóficos. Rituais ao ar livre e viagens espirituais te nutrem. '
            'A Lua em Sagitário potencializa magia de expansão.',
    'moon_capricorn':
        'Com a Lua em Capricórnio, suas emoções são CONTIDAS e PRÁTICAS. Você processa '
            'sentimentos através do trabalho e da estrutura. Sua intuição fala através '
            'da tradição e da experiência. Rituais estruturados e tradicionais funcionam '
            'melhor. A Lua em Capricórnio potencializa magia de manifestação material.',
    'moon_aquarius':
        'Com a Lua em Aquário, suas emoções são DESAPEGADAS e HUMANITÁRIAS. Você '
            'processa sentimentos de forma intelectual. Sua intuição vem como downloads '
            'repentinos e insights. Rituais de grupo e para causas coletivas te nutrem. '
            'A Lua em Aquário potencializa magia de inovação.',
    'moon_pisces':
        'Com a Lua em Peixes, suas emoções são OCEÂNICAS e sem fronteiras. Você absorve '
            'os sentimentos ao seu redor como uma esponja. Sua intuição psíquica é fortíssima. '
            'Rituais com água, sonhos lúcidos e meditação profunda são naturais. A Lua em '
            'Peixes amplifica toda magia intuitiva e espiritual.',

    // MERCÚRIO em cada signo
    'mercury_aries':
        'Com Mercúrio em Áries, sua mente é RÁPIDA e DIRETA. Você pensa e fala com '
            'velocidade e assertividade. Encantamentos curtos e diretos funcionam melhor '
            'que rituais longos. Sua comunicação mágica é corajosa. Sigilos de ação rápida '
            'são sua especialidade.',
    'mercury_taurus':
        'Com Mercúrio em Touro, sua mente é PRÁTICA e DELIBERADA. Você pensa devagar '
            'mas com profundidade. Prefere memorizar encantamentos a improvisar. Sua '
            'comunicação mágica tem peso e substância. Cantos e mantras repetitivos são '
            'especialmente poderosos.',
    'mercury_gemini':
        'Com Mercúrio em Gêmeos, sua mente é BRILHANTE e VERSÁTIL. Esta é a posição '
            'mais forte de Mercúrio. Você é mestre das palavras mágicas. Sigilos, '
            'encantamentos e toda magia verbal são amplificados. Tarot e oráculos falam '
            'claramente com você.',
    'mercury_cancer':
        'Com Mercúrio em Câncer, sua mente é INTUITIVA e EMOCIONAL. Você pensa com '
            'o coração. Sua comunicação mágica carrega emoção profunda. Encantamentos '
            'falados com sentimento são especialmente poderosos. Você recebe mensagens '
            'através de memórias e sonhos.',
    'mercury_leo':
        'Com Mercúrio em Leão, sua mente é CRIATIVA e DRAMÁTICA. Você se expressa '
            'com flair e confiança. Encantamentos proclamados em voz alta são especialmente '
            'poderosos. Sua comunicação mágica inspira outros. Você é excelente em liderar '
            'invocações de grupo.',
    'mercury_virgo':
        'Com Mercúrio em Virgem, sua mente é ANALÍTICA e PRECISA. Esta é outra posição '
            'forte de Mercúrio. Você é meticulosa com palavras e correspondências. Seus '
            'registros mágicos são impecáveis. Encantamentos detalhados e precisos são sua '
            'especialidade.',
    'mercury_libra':
        'Com Mercúrio em Libra, sua mente busca EQUILÍBRIO e DIPLOMACIA. Você considera '
            'todos os lados antes de decidir. Sua comunicação mágica é elegante e harmoniosa. '
            'Encantamentos de parceria e justiça são naturais. Você é excelente em mediação '
            'espiritual.',
    'mercury_scorpio':
        'Com Mercúrio em Escorpião, sua mente é PENETRANTE e INVESTIGATIVA. Você vai '
            'fundo em qualquer assunto. Sua comunicação mágica é intensa e transformadora. '
            'Palavras de poder e invocações secretas são sua especialidade. Você descobre '
            'conhecimento oculto facilmente.',
    'mercury_sagittarius':
        'Com Mercúrio em Sagitário, sua mente é EXPANSIVA e FILOSÓFICA. Você pensa '
            'em termos amplos e universais. Sua comunicação mágica é inspiradora e otimista. '
            'Estudar diversas tradições enriquece sua prática. Encantamentos de expansão '
            'são poderosos.',
    'mercury_capricorn':
        'Com Mercúrio em Capricórnio, sua mente é ESTRUTURADA e SÉRIA. Você pensa '
            'a longo prazo e com praticidade. Sua comunicação mágica é tradicional e '
            'respeitosa. Encantamentos formais e tradicionais funcionam melhor. Você aprende '
            'bem com mentores.',
    'mercury_aquarius':
        'Com Mercúrio em Aquário, sua mente é ORIGINAL e VISIONÁRIA. Você pensa fora '
            'da caixa e questiona tudo. Sua comunicação mágica é inovadora. Você cria novos '
            'encantamentos e sistemas. Downloads intuitivos repentinos são comuns para você.',
    'mercury_pisces':
        'Com Mercúrio em Peixes, sua mente é INTUITIVA e IMAGINATIVA. Você pensa em '
            'símbolos e imagens. Sua comunicação mágica é poética e fluida. Escrita '
            'automática e canalização são naturais. Você recebe mensagens através de '
            'sonhos e visões.',

    // VÊNUS em cada signo
    'venus_aries':
        'Com Vênus em Áries, você AMA com PAIXÃO e INTENSIDADE. Magia de amor para '
            'você deve ser direta e corajosa. Você atrai através da energia e iniciativa. '
            'Rituais de autoamor e confiança são especialmente poderosos. Feitiços de '
            'paixão e atração funcionam rapidamente.',
    'venus_taurus':
        'Com Vênus em Touro, você AMA com os SENTIDOS. Esta é a posição mais forte '
            'de Vênus. Você atrai através da beleza e do prazer sensorial. Magia de amor '
            'com óleos, perfumes e comida é especialmente eficaz. Rituais de prosperidade '
            'amorosa são naturais.',
    'venus_gemini':
        'Com Vênus em Gêmeos, você AMA através da COMUNICAÇÃO. Conexão mental é '
            'essencial para você. Magia de amor inclui palavras, cartas e conversas. '
            'Você atrai através do intelecto e humor. Feitiços com sigilos de amor são '
            'especialmente eficazes.',
    'venus_cancer':
        'Com Vênus em Câncer, você AMA com CUIDADO e PROTEÇÃO. Segurança emocional '
            'é essencial. Magia de amor focada em família e lar é poderosa. Você atrai '
            'através do carinho e nutrição. Rituais de amor durante a Lua Cheia são '
            'amplificados.',
    'venus_leo':
        'Com Vênus em Leão, você AMA com DRAMA e GENEROSIDADE. Romance grandioso te '
            'atrai. Magia de amor deve ser especial e teatral. Você atrai através do '
            'brilho e confiança. Rituais de glamour amoroso são sua especialidade.',
    'venus_virgo':
        'Com Vênus em Virgem, você AMA através do SERVIÇO. Atos de cuidado são sua '
            'linguagem do amor. Magia de amor prática e útil funciona melhor. Você '
            'atrai através da competência e atenção aos detalhes. Prepare poções de '
            'amor com cuidado.',
    'venus_libra':
        'Com Vênus em Libra, você AMA com HARMONIA e ELEGÂNCIA. Esta é outra posição '
            'forte de Vênus. Parcerias equilibradas são essenciais. Magia de amor estética '
            'e romântica é poderosa. Você atrai através da graça e diplomacia. Rituais de '
            'casamento são sua especialidade.',
    'venus_scorpio':
        'Com Vênus em Escorpião, você AMA com INTENSIDADE TOTAL. Conexões profundas '
            'e transformadoras te atraem. Magia de amor é intensa e poderosa para você. '
            'Você atrai através do magnetismo e mistério. Rituais de amor que envolvem '
            'compromisso profundo são eficazes.',
    'venus_sagittarius':
        'Com Vênus em Sagitário, você AMA com LIBERDADE. Conexões que expandem seu '
            'mundo te atraem. Magia de amor deve incluir aventura e crescimento. Você '
            'atrai através do otimismo e humor. Rituais de amor ao ar livre são poderosos.',
    'venus_capricorn':
        'Com Vênus em Capricórnio, você AMA com COMPROMISSO. Relacionamentos sérios '
            'e duradouros te atraem. Magia de amor deve ser prática e construir para o '
            'futuro. Você atrai através da estabilidade. Rituais de amor com estrutura '
            'e tradição funcionam.',
    'venus_aquarius':
        'Com Vênus em Aquário, você AMA com LIBERDADE e AMIZADE. Conexões únicas e '
            'não-convencionais te atraem. Magia de amor deve respeitar individualidade. '
            'Você atrai através da originalidade. Rituais de amor em grupo ou para '
            'amizade são poderosos.',
    'venus_pisces':
        'Com Vênus em Peixes, você AMA com DEVOÇÃO TOTAL. Esta é a posição mais '
            'romântica de Vênus. Conexões espirituais te atraem. Magia de amor é transcendente '
            'para você. Você atrai através da compaixão. Rituais de amor com água e música '
            'são especialmente eficazes.',

    // MARTE em cada signo
    'mars_aries':
        'Com Marte em Áries, sua ENERGIA é EXPLOSIVA e DIRETA. Esta é a posição mais '
            'forte de Marte. Você age com coragem e iniciativa. Magia de proteção e '
            'banimento é especialmente poderosa. Rituais de ação rápida são eficazes. '
            'Use esta energia para começar projetos mágicos.',
    'mars_taurus':
        'Com Marte em Touro, sua ENERGIA é PERSISTENTE e DETERMINADA. Você age '
            'devagar mas com força imparável. Magia de manifestação material é poderosa. '
            'Rituais que exigem paciência funcionam bem. Use esta energia para proteção '
            'duradoura.',
    'mars_gemini':
        'Com Marte em Gêmeos, sua ENERGIA é VERSÁTIL e MENTAL. Você age através de '
            'palavras e ideias. Magia verbal e de comunicação é poderosa. Debates e '
            'discussões te energizam. Use esta energia para sigilos ativos.',
    'mars_cancer':
        'Com Marte em Câncer, sua ENERGIA é PROTETORA e EMOCIONAL. Você age para '
            'defender quem ama. Magia de proteção familiar é especialmente poderosa. '
            'Rituais emocionalmente carregados são eficazes. Use esta energia para '
            'proteger o lar.',
    'mars_leo':
        'Com Marte em Leão, sua ENERGIA é DRAMÁTICA e CRIATIVA. Você age com flair '
            'e confiança. Magia de autoexpressão e coragem é poderosa. Rituais teatrais '
            'são eficazes. Use esta energia para rituais de liderança.',
    'mars_virgo':
        'Com Marte em Virgem, sua ENERGIA é PRECISA e EFICIENTE. Você age de forma '
            'metódica e detalhista. Magia de cura e purificação é poderosa. Rituais '
            'bem planejados são mais eficazes. Use esta energia para trabalhos precisos.',
    'mars_libra':
        'Com Marte em Libra, sua ENERGIA busca JUSTIÇA e EQUILÍBRIO. Você age em '
            'nome da harmonia. Magia de justiça e equilíbrio é poderosa. Rituais de '
            'parceria são eficazes. Use esta energia para resolver conflitos magicamente.',
    'mars_scorpio':
        'Com Marte em Escorpião, sua ENERGIA é INTENSA e TRANSFORMADORA. Esta é uma '
            'posição muito forte de Marte. Você age com determinação implacável. Magia '
            'de transformação e banimento é extremamente poderosa. Use esta energia para '
            'mudanças profundas.',
    'mars_sagittarius':
        'Com Marte em Sagitário, sua ENERGIA é AVENTUREIRA e EXPANSIVA. Você age com '
            'otimismo e entusiasmo. Magia de expansão e viagem é poderosa. Rituais ao '
            'ar livre são eficazes. Use esta energia para crescimento espiritual ativo.',
    'mars_capricorn':
        'Com Marte em Capricórnio, sua ENERGIA é DISCIPLINADA e AMBICIOSA. Esta é '
            'uma posição muito forte de Marte. Você age com estratégia e paciência. '
            'Magia de carreira e manifestação material é poderosa. Rituais estruturados '
            'são eficazes.',
    'mars_aquarius':
        'Com Marte em Aquário, sua ENERGIA é REVOLUCIONÁRIA e INDEPENDENTE. Você '
            'age de formas não-convencionais. Magia de grupo e para causas sociais é '
            'poderosa. Rituais inovadores são eficazes. Use esta energia para mudança '
            'coletiva.',
    'mars_pisces':
        'Com Marte em Peixes, sua ENERGIA é FLUIDA e INTUITIVA. Você age guiada pela '
            'intuição e compaixão. Magia espiritual e curativa é poderosa. Rituais '
            'meditativos são eficazes. Use esta energia para trabalho espiritual ativo.',
  };

  /// Retorna um resumo curto para exibição em lista
  static String getShortInterpretation(Planet planet, ZodiacSign sign) {
    switch (planet) {
      case Planet.sun:
        return 'Sua essência mágica é ${sign.magicalDescription}';
      case Planet.moon:
        return 'Suas emoções e intuição são ${sign.magicalDescription}';
      case Planet.mercury:
        return 'Sua mente e comunicação são ${sign.magicalDescription}';
      case Planet.venus:
        return 'Seu amor e beleza são ${sign.magicalDescription}';
      case Planet.mars:
        return 'Sua energia e ação são ${sign.magicalDescription}';
      case Planet.jupiter:
        return 'Sua sorte e expansão são ${sign.magicalDescription}';
      case Planet.saturn:
        return 'Sua disciplina e estrutura são ${sign.magicalDescription}';
      case Planet.uranus:
        return 'Sua inovação é ${sign.magicalDescription}';
      case Planet.neptune:
        return 'Sua espiritualidade é ${sign.magicalDescription}';
      case Planet.pluto:
        return 'Sua transformação é ${sign.magicalDescription}';
      default:
        return '${planet.displayName} em ${sign.displayName}';
    }
  }
}
