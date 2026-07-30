import '../models/enums.dart';
import 'magical_interpreter_texts.dart';

/// Textos do interpretador mágico — conteúdo em português (idioma-base).
///
/// Mantenha as mesmas chaves/estruturas nos três arquivos
/// (`magical_interpreter_texts_pt/en/es.dart`) — a paridade é verificada em
/// `test/astrology_interpreters_parity_test.dart`.
final MagicalInterpreterTexts magicalInterpreterTextsPt =
    MagicalInterpreterTexts(
  sunEssence: const {
    ZodiacSign.aries:
        'Sua essência mágica é de pioneirismo e coragem. Você é uma bruxa guerreira, '
            'que age com rapidez e decisão. Seus feitiços mais poderosos envolvem iniciar novos '
            'ciclos e quebrar barreiras. Use o fogo como seu elemento principal.',
    ZodiacSign.taurus:
        'Sua essência mágica está enraizada na terra e na manifestação. Você é uma bruxa '
            'que traz o mundo espiritual para o físico. Seus feitiços mais poderosos envolvem '
            'prosperidade, sensualidade e beleza. Trabalhe com cristais e ervas.',
    ZodiacSign.gemini:
        'Sua essência mágica flui através da comunicação e do conhecimento. Você é uma '
            'bruxa estudiosa, que domina a magia através de palavras e símbolos. Seus feitiços mais '
            'poderosos envolvem comunicação, aprendizado e versatilidade.',
    ZodiacSign.cancer:
        'Sua essência mágica flui com as marés lunares. Você é uma bruxa intuitiva, '
            'profundamente conectada às emoções. Seus feitiços mais poderosos envolvem proteção '
            'do lar, cura emocional e magia lunar.',
    ZodiacSign.leo:
        'Sua essência mágica brilha como o Sol. Você é uma bruxa radiante, confiante e '
            'criativa. Seus feitiços mais poderosos envolvem autoexpressão, criatividade e '
            'liderança. Use rituais solares.',
    ZodiacSign.virgo:
        'Sua essência mágica está na precisão e no serviço. Você é uma bruxa meticulosa, '
            'que domina os detalhes de cada ritual. Seus feitiços mais poderosos envolvem cura, '
            'purificação e magia herbal.',
    ZodiacSign.libra:
        'Sua essência mágica busca o equilíbrio e a harmonia. Você é uma bruxa diplomata, '
            'que trabalha com energias de beleza e justiça. Seus feitiços mais poderosos envolvem '
            'relacionamentos, harmonia e estética.',
    ZodiacSign.scorpio:
        'Sua essência mágica mergulha nas profundezas. Você é uma bruxa transformadora, '
            'que não teme as sombras. Seus feitiços mais poderosos envolvem transformação profunda, '
            'magia sexual e renascimento.',
    ZodiacSign.sagittarius:
        'Sua essência mágica busca a sabedoria e a expansão. Você é uma bruxa filósofa, '
            'que explora diferentes tradições. Seus feitiços mais poderosos envolvem crescimento '
            'espiritual, proteção em viagens e abundância.',
    ZodiacSign.capricorn:
        'Sua essência mágica é estruturada e ambiciosa. Você é uma bruxa disciplinada, '
            'que constrói poder ao longo do tempo. Seus feitiços mais poderosos envolvem manifestação '
            'material, carreira e magia saturnina.',
    ZodiacSign.aquarius:
        'Sua essência mágica é inovadora e única. Você é uma bruxa revolucionária, que '
            'quebra tradições e cria novos caminhos. Seus feitiços mais poderosos envolvem mudança '
            'social, intuição e magia tecnológica.',
    ZodiacSign.pisces:
        'Sua essência mágica dissolve fronteiras. Você é uma bruxa mística, profundamente '
            'conectada ao inconsciente coletivo. Seus feitiços mais poderosos envolvem sonhos, '
            'mediunidade e compaixão universal.',
  },
  moonIntro: (signName, houseNumber) =>
      'Sua Lua em $signName na Casa $houseNumber ',
  moonBySign: const {
    ZodiacSign.aries:
        'traz intuições rápidas e instintivas. Confie em seus primeiros impulsos.',
    ZodiacSign.taurus:
        'oferece intuição através dos sentidos. Trabalhe com aromas, texturas e sabores.',
    ZodiacSign.cancer:
        'amplifica sua sensibilidade psíquica. Você é naturalmente empática e receptiva.',
    ZodiacSign.scorpio:
        'mergulha nas profundezas emocionais. Você tem dons psíquicos poderosos.',
    ZodiacSign.pisces:
        'dissolve as fronteiras entre mundos. Você pode ter sonhos proféticos.',
  },
  moonByElement: (elementName) =>
      'oferece intuição de acordo com $elementName. '
      'Trabalhe com esse elemento para fortalecer sua conexão.',
  mercuryByElement: const {
    Element.fire:
        'Sua comunicação mágica é direta e inspiradora. Use afirmações poderosas '
            'e encantamentos falados em voz alta.',
    Element.earth:
        'Sua comunicação mágica é prática e fundamentada. Escreva seus feitiços e '
            'trabalhe com grimórios físicos.',
    Element.air:
        'Sua comunicação mágica é versátil e clara. Você é excelente em leitura de runas, '
            'tarô e outros sistemas divinatórios baseados em símbolos.',
    Element.water:
        'Sua comunicação mágica é intuitiva e emocional. Trabalhe com poesia, música e '
            'expressão criativa em seus rituais.',
  },
  venus: (signName, elementName) =>
      'Sua Vênus em $signName indica que você atrai beleza e prazer através '
      'de $elementName. Incorpore esse elemento em feitiços de amor e autocuidado.',
  mars: (signName, elementName) =>
      'Seu Marte em $signName mostra que sua energia protetora se manifesta através '
      'de $elementName. Use esse elemento em feitiços de proteção e banimento.',
  house8Intro: (signName) =>
      'Sua Casa 8 (magia e ocultismo) está em $signName. ',
  house8NoPlanets:
      'Embora não haja planetas aqui, você ainda pode desenvolver suas habilidades '
      'mágicas através da prática consciente.',
  house8WithPlanets: (count, planetNames) =>
      'Com $count planeta(s) aqui, você tem forte afinidade natural '
      'com magia: $planetNames. ',
  house8Moon: 'A Lua aqui intensifica sua intuição mágica. ',
  house8Pluto: 'Plutão aqui indica poderes transformadores profundos. ',
  house12Intro: (signName) =>
      'Sua Casa 12 (espiritualidade) está em $signName. ',
  house12NoPlanets:
      'Desenvolva sua conexão espiritual através de meditação e sonhos.',
  house12WithPlanets: (count, planetNames) =>
      'Com $count planeta(s) aqui, você tem forte conexão com o divino: '
      '$planetNames. ',
  house12Neptune: 'Netuno aqui amplifica sua mediunidade e conexão mística. ',
  house12Moon: 'A Lua aqui traz sonhos proféticos e forte intuição. ',
  strengthPsychicIntuition: 'Intuição psíquica natural',
  strengthSunMoonBalance: 'Equilíbrio entre ação e intuição',
  strengthMagicAffinity: 'Afinidade natural com magia',
  strengthSpiritualConnection: 'Conexão espiritual profunda',
  strengthDominantElement: (elementName) => 'Domínio do elemento $elementName',
  practicesByElement: const {
    Element.fire: [
      'Magia de velas',
      'Rituais sob o sol',
      'Trabalho com fogo sagrado',
      'Feitiços de ação rápida',
    ],
    Element.earth: [
      'Bruxaria verde (ervas e plantas)',
      'Magia de cristais',
      'Rituais de manifestação',
      'Trabalho com altar permanente',
    ],
    Element.air: [
      'Magia de palavras e encantamentos',
      'Leitura de runas e tarô',
      'Trabalho com incensos',
      'Comunicação com espíritos',
    ],
    Element.water: [
      'Magia lunar',
      'Banhos rituais',
      'Trabalho com sonhos',
      'Adivinhação por água',
    ],
  },
  practicesHouse8: const [
    'Magia sexual e transformação profunda',
    'Trabalho com sombras',
  ],
  practicesHouse12: const [
    'Meditação e viagens astrais',
    'Trabalho com o inconsciente',
  ],
  toolsByElement: const {
    Element.fire: ['Citrino', 'Cornalina', 'Rubi', 'Velas vermelhas/laranja'],
    Element.earth: ['Quartzo Verde', 'Turmalina Negra', 'Sal grosso', 'Ervas'],
    Element.air: ['Quartzo Transparente', 'Ametista', 'Incensos', 'Penas'],
    Element.water: ['Pedra da Lua', 'Água lunar', 'Conchas', 'Espelho'],
  },
  sunCrystal: (signName) => 'Cristal de $signName',
  moonHerb: (signName) => 'Erva de $signName',
  shadowSunMoon: 'Integrar ego consciente com necessidades emocionais',
  shadowSaturn: 'Trabalhar com limitações e estruturas rígidas',
  shadowHouse12:
      'Explorar aspectos ocultos da personalidade através de meditação',
);
