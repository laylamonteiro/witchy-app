import '../models/enums.dart';
import 'birth_chart_content.dart';

/// Conteúdo da página do mapa astral — português.
const BirthChartContent birthChartContentPt = BirthChartContent(
  ui: {
    'viewMagicalProfileTooltip': 'Ver Perfil Mágico',
    'noChartFound': 'Nenhum mapa astral encontrado',
    'sectionMainTrio': 'Trio Principal',
    'sectionPersonalPlanets': 'Planetas Pessoais',
    'sectionSocialPlanets': 'Planetas Sociais',
    'sectionTranspersonalPlanets': 'Planetas Transpessoais',
    'sectionAstroPoints': 'Pontos Astrológicos',
    'sectionHouses': 'Casas Astrológicas',
    'sectionAspects': 'Aspectos Principais',
    'ascendant': 'Ascendente',
    'ascendantMeaning': 'Como você se apresenta',
    'houseWord': 'Casa',
    'planetsInHousePrefix': 'Planetas:',
    'noAspects': 'Nenhum aspecto significativo encontrado',
    'unlockFullInterpretations': 'Desbloquear interpretações completas',
    'viewMagicalProfileButton': 'Ver Perfil Mágico ✨',
    'tapToLearnMore': 'Toque para saber mais',
    'beginnersGuide': 'Guia para Iniciantes',
  },
  planetRowMeanings: {
    Planet.sun: 'Sua essência',
    Planet.moon: 'Suas emoções',
    Planet.mercury: 'Comunicação',
    Planet.venus: 'Amor e beleza',
    Planet.mars: 'Ação e energia',
  },
  trioSections: [
    BirthChartSection(
      title: '☉ O Sol - Sua Essência',
      body:
          'O Sol representa quem você realmente é no seu núcleo mais profundo. É a sua identidade '
          'fundamental, seus objetivos de vida e como você brilha no mundo\n\n'
          'Na bruxaria, o Sol representa sua força vital, sua energia criativa e seu propósito mágico. '
          'O signo solar indica que tipo de magia você naturalmente expressa',
    ),
    BirthChartSection(
      title: '☽ A Lua - Suas Emoções',
      body:
          'A Lua governa suas emoções, intuição e mundo interior. Ela revela como você processa '
          'sentimentos, o que precisa para se sentir seguro(a) e suas reações instintivas\n\n'
          'Para praticantes de magia, a Lua é extremamente importante. Ela indica seus dons intuitivos, '
          'sua conexão com o inconsciente e como você se relaciona com os ciclos lunares',
    ),
    BirthChartSection(
      title: '⬆ O Ascendente - Sua Máscara',
      body:
          'O Ascendente (ou signo nascente) é como você se apresenta ao mundo e as primeiras '
          'impressões que causa. É sua "máscara social" e aparência externa\n\n'
          'Na prática mágica, o Ascendente influencia como sua energia é percebida pelos outros '
          'e pode indicar que tipo de trabalho mágico você atrai naturalmente',
    ),
  ],
  trioTip: BirthChartSection(
    title: '💡 Por que é importante?',
    body:
        'Esses três pontos formam a base da sua personalidade astrológica. '
        'Se você está começando na astrologia, entender seu Sol, Lua e Ascendente '
        'é o primeiro passo para se conhecer através das estrelas',
  ),
  personalIntro:
      'Os planetas pessoais são aqueles que se movem rapidamente pelo zodíaco e '
      'influenciam aspectos do dia a dia da sua personalidade',
  personalSections: [
    BirthChartSection(
      title: '☿ Mercúrio - Comunicação',
      body:
          'Mercúrio governa como você pensa, se comunica e processa informações. '
          'Influencia sua forma de aprender, falar e escrever\n\n'
          'Na magia: Indica como você lança encantamentos, escreve feitiços e se comunica com o divino',
    ),
    BirthChartSection(
      title: '♀ Vênus - Amor e Beleza',
      body:
          'Vênus rege o amor, relacionamentos, beleza e prazer. Mostra o que você valoriza, '
          'como se relaciona romanticamente e seu senso estético\n\n'
          'Na magia: Influencia trabalhos de amor (sempre éticos!), prosperidade e beleza do altar',
    ),
    BirthChartSection(
      title: '♂ Marte - Ação e Energia',
      body:
          'Marte representa sua energia de ação, como você luta pelo que quer, sua coragem '
          'e também raiva. É o planeta da iniciativa e determinação\n\n'
          'Na magia: Indica sua energia protetora, capacidade de banimento e força de vontade mágica',
    ),
  ],
  personalTip: BirthChartSection(
    title: '✨ Dica para iniciantes',
    body:
        'Esses planetas mudam de signo com frequência, por isso pessoas nascidas no mesmo dia '
        'podem ter posições diferentes. Confira o seu Perfil Mágico para uma análise '
        'personalizada de cada planeta',
  ),
  socialIntro:
      'Júpiter e Saturno são os planetas sociais: fazem a ponte entre a sua '
      'personalidade individual e o mundo coletivo — sua relação com a '
      'sociedade, o crescimento, as regras, as responsabilidades e o amadurecimento',
  socialSections: [
    BirthChartSection(
      title: '♃ Júpiter - Expansão',
      body:
          'Expansão, fé, conhecimento, oportunidades e visão de mundo. Mostra onde '
          'você cresce, confia e encontra facilidade e sorte na vida',
    ),
    BirthChartSection(
      title: '♄ Saturno - Estrutura',
      body:
          'Limites, disciplina, dever, medo, estrutura e amadurecimento. Indica onde '
          'você aprende com desafios, assume responsabilidades e constrói solidez',
    ),
  ],
  transpersonalIntro:
      'Urano, Netuno e Plutão são os planetas transpessoais (ou geracionais). '
      'Movem-se lentamente e ficam anos em cada signo, então gerações inteiras '
      'os compartilham — falam de mudanças coletivas, espirituais e profundas',
  transpersonalSections: [
    BirthChartSection(
      title: '♅ Urano - Ruptura',
      body:
          'Ruptura, liberdade, inovação e revolução. Onde você quebra padrões, '
          'busca autenticidade e abre caminhos novos',
    ),
    BirthChartSection(
      title: '♆ Netuno - Dissolução',
      body:
          'Sonhos, espiritualidade, idealização, dissolução e ilusão. Sua conexão '
          'com o transcendente, a imaginação e a compaixão',
    ),
    BirthChartSection(
      title: '♇ Plutão - Transformação',
      body:
          'Poder, crise, morte simbólica, transformação e regeneração. Onde você '
          'se reinventa profundamente e renasce',
    ),
  ],
  pointsIntro:
      'Além dos planetas, o mapa tem pontos e eixos calculados — cruzamentos, '
      'ângulos e apogeus que não são corpos celestes, mas revelam camadas '
      'profundas do destino, da sombra e da alma',
  pointsSections: [
    BirthChartSection(
      title: 'MC · Meio do Céu - Vocação',
      body:
          'O ponto mais alto do mapa (cúspide da Casa 10). Mostra a sua vocação, a '
          'imagem pública, a carreira e o legado que você constrói no mundo',
    ),
    BirthChartSection(
      title: 'IC · Fundo do Céu - Raízes',
      body:
          'O ponto mais baixo (cúspide da Casa 4), oposto ao MC. Fala das suas '
          'raízes, do lar, da família e da base emocional mais íntima',
    ),
    BirthChartSection(
      title: 'Dsc · Descendente - O Outro',
      body:
          'A cúspide da Casa 7, oposta ao Ascendente. Descreve os relacionamentos, '
          'as parcerias e as qualidades que você busca (ou projeta) no outro',
    ),
    BirthChartSection(
      title: 'Vx · Vértex - Destino',
      body:
          'Um ponto sensível ligado a encontros fatídicos e viradas do destino — '
          'situações e pessoas que chegam como se fossem "escritas"',
    ),
    BirthChartSection(
      title: '⚸ Lilith - Lua Negra',
      body:
          'O apogeu da órbita lunar. Representa o seu poder instintivo, a sombra, o '
          'desejo indomado e aquilo que se recusa a ser domesticado. Na bruxaria, '
          'é o portal da bruxa selvagem e da soberania feminina',
    ),
    BirthChartSection(
      title: '⊗ Parte da Fortuna - Sorte',
      body:
          'Ponto árabe calculado a partir do Sol, da Lua e do Ascendente. Indica '
          'onde moram a sua sorte natural, a prosperidade e o bem-estar — o lugar '
          'de fluidez e alegria no mapa',
    ),
    BirthChartSection(
      title: '☊ Nodo Norte - Crescimento',
      body:
          'Aponta as experiências que exigem crescimento e desenvolvimento — a '
          'direção para onde a sua alma caminha nesta vida',
    ),
    BirthChartSection(
      title: '☋ Nodo Sul - Bagagem',
      body:
          'Hábitos, talentos e padrões familiares ou automáticos — o repertório que '
          'você já traz e no qual tende a se acomodar',
    ),
  ],
  housesIntro:
      'As 12 casas astrológicas representam diferentes áreas da sua vida. Cada casa '
      'é governada pelo signo que está na sua cúspide (início)',
  houseMeanings: {
    1: 'Identidade, aparência física, como você inicia coisas',
    2: 'Recursos, dinheiro, valores pessoais, autoestima',
    3: 'Comunicação, irmãos, vizinhos, pensamento',
    4: 'Lar, família, raízes, vida privada',
    5: 'Criatividade, romance, filhos, diversão',
    6: 'Saúde, rotina, trabalho diário, serviço',
    7: 'Parcerias, casamento, contratos, o outro',
    8: 'Transformação, sexualidade, morte/renascimento, magia',
    9: 'Filosofia, viagens, ensino superior, expansão',
    10: 'Carreira, reputação, status, missão de vida',
    11: 'Amizades, grupos, sonhos, causas sociais',
    12: 'Inconsciente, espiritualidade, karma, retiros',
  },
  housesTip: BirthChartSection(
    title: '🔮 Casas importantes para bruxaria',
    body:
        'A Casa 8 (magia, transformação, mistérios) e Casa 12 (espiritualidade, intuição, '
        'conexão com o divino) são especialmente importantes para praticantes de magia. '
        'Veja seu Perfil Mágico para uma análise detalhada dessas casas',
  ),
  aspectsIntro:
      'Aspectos são as relações angulares entre os planetas. Eles mostram como as energias '
      'planetárias interagem entre si no seu mapa',
  aspectTypeMeanings: {
    AspectType.conjunction:
        'Os planetas estão juntos. Energia intensa e fusionada',
    AspectType.sextile:
        'Aspecto harmonioso. Oportunidades e talentos naturais',
    AspectType.square: 'Aspecto desafiador. Tensão que gera crescimento',
    AspectType.trine: 'Aspecto muito harmonioso. Fluxo fácil de energia',
    AspectType.opposition:
        'Aspecto desafiador. Polaridade e necessidade de equilíbrio',
  },
  aspectsTip: BirthChartSection(
    title: '💫 Importante saber',
    body:
        'Aspectos "desafiadores" não são ruins! Eles indicam áreas de crescimento e '
        'potencial. Muitas vezes são onde desenvolvemos nossas maiores forças\n\n'
        'Na magia, entender seus aspectos ajuda a saber quais energias trabalham '
        'bem juntas e quais precisam de mais atenção nos seus rituais',
  ),
);
