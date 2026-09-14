import '../../../grimoire/data/models/spell_model.dart';
import '../../domain/menstrual_shortcut.dart';
import '../models/blood_lore_model.dart';

/// Os Saberes do Sangue em português.
///
/// Regra editorial desta área, e ela vale para os três idiomas:
///
/// * história é história e invenção é invenção. Cada verbete carrega a sua
///   etiqueta, e nenhuma leitura contemporânea é apresentada como tradição
///   antiga;
/// * não existe um significado universal para menstruar. Onde uma tradição
///   específica diz algo, o texto diz de qual tradição se trata;
/// * a Lua é correspondência mágica e ferramenta de observação — nunca
///   relógio, hormônio ou causa do corpo de quem lê;
/// * descrever o que a história registrou é uma coisa; ensinar o passo a
///   passo é outra. O filtro amoroso é contado, não ensinado;
/// * toda prática que fala de sangue oferece a mesma prática sem ele.
const bloodLoreContentPt = BloodLoreContent(
  pageTitle: 'Saberes do Sangue',
  intro:
      'Quatro caminhos para o mesmo assunto: o que os registros mostram, o '
      'que a magia lunar faz com o ciclo, o que se pode praticar hoje e de '
      'onde tudo isso foi tirado',
  introNote:
      'Cada texto vem com uma etiqueta que diz de onde ele vem. Prática de '
      'agora não é apresentada aqui como tradição antiga.',
  categoryTitles: {
    BloodLoreCategory.bloodInMagic: 'O sangue na magia',
    BloodLoreCategory.cycleAndMoon: 'Ciclo e Lua',
    BloodLoreCategory.practices: 'Práticas e feitiços',
    BloodLoreCategory.traditions: 'Tradições e história',
  },
  categorySubtitles: {
    BloodLoreCategory.bloodInMagic:
        'Vínculo, ambivalência, amor, proteção e poder pessoal',
    BloodLoreCategory.cycleAndMoon:
        'Duas rodas que se encontram — e o que isso não quer dizer',
    BloodLoreCategory.practices:
        'Gestos para fazer, com a origem de cada um à vista',
    BloodLoreCategory.traditions:
        'O que foi registrado, por quem, e o que não dá para saber',
  },
  tagLabels: {
    BloodLoreTag.documented: 'Historicamente documentado',
    BloodLoreTag.tradition: 'Tradição específica',
    BloodLoreTag.contemporary: 'Prática contemporânea',
    BloodLoreTag.modernAdaptation: 'Adaptação moderna',
  },
  safetyNote:
      'Use apenas o seu próprio sangue menstrual. Não compartilhe fluidos '
      'corporais, não os ponha em alimentos ou bebidas e não use materiais '
      'que possam ferir você. Nada aqui pede que você se corte: a prática é '
      'sobre o sangue que o corpo já produziu.',
  classificationLabel: 'Classificação',
  practiceIntentionLabel: 'Intenção',
  practiceMaterialsLabel: 'Materiais',
  practiceStepsLabel: 'A prática',
  practiceWithoutBloodLabel: 'Versão sem sangue',
  entriesCountTemplate: '{count} textos',
  cycleCta: 'Explorar os saberes do sangue',
  momentTitle: 'Práticas para este momento',
  momentIntro:
      'Atalhos para o que o Grimório já tem. O que você escrever, tirar ou '
      'sonhar continua morando no lugar de sempre.',
  shortcuts: {
    MenstrualShortcut.release: BloodLoreShortcut(
      title: 'O que você quer deixar?',
      body: 'Escreva sobre algo que chegou ao fim',
      prompt:
          'O que está pedindo para terminar neste ciclo?\n\nEscreva sem '
          'tentar resolver. Apenas observe o que você não quer carregar para '
          'a próxima volta.',
    ),
    MenstrualShortcut.cultivate: BloodLoreShortcut(
      title: 'O que você quer cultivar?',
      body: 'Escreva sobre algo que está começando',
      prompt:
          'O que está começando em você nesta volta?\n\nEscreva sem cobrar '
          'resultado. Só nomeie o que você quer cuidar até o próximo sangue.',
    ),
    MenstrualShortcut.oracle: BloodLoreShortcut(
      title: 'Ouvir o oráculo',
      body: 'Faça uma tiragem sobre este ciclo',
    ),
    MenstrualShortcut.dream: BloodLoreShortcut(
      title: 'Registrar um sonho',
      body: 'O sonho vai para o seu Diário de Sonhos, como qualquer outro',
    ),
    MenstrualShortcut.intention: BloodLoreShortcut(
      title: 'Definir uma intenção',
      body: 'Uma palavra vira sigilo no criador que já existe no Grimório',
    ),
    MenstrualShortcut.practices: BloodLoreShortcut(
      title: 'Praticar',
      body:
          'Explore práticas ligadas ao sangue, à proteção, ao vínculo e ao '
          'encerramento',
    ),
  },
  moonCorrespondences: {
    MoonPhase.newMoon: 'semente, silêncio e o que ainda não tem forma',
    MoonPhase.waxingCrescent:
        'expansão, fortalecimento e aquilo que está sendo cultivado',
    MoonPhase.firstQuarter: 'decisão, impulso e o que pede uma escolha',
    MoonPhase.waxingGibbous: 'amadurecimento e ajuste do que já está a caminho',
    MoonPhase.fullMoon: 'plenitude, revelação e o que transborda',
    MoonPhase.waningGibbous: 'gratidão, partilha e o que já pode descansar',
    MoonPhase.lastQuarter: 'corte, perdão e o que se solta',
    MoonPhase.waningCrescent: 'recolhimento, descanso e o fim do círculo',
  },
  correspondenceTemplate:
      'Na magia lunar, {phase} costuma ser associada a {meaning}',
  startUnderTemplate: 'Seu último ciclo começou sob {phase}',
  phaseTallyTemplate:
      '{count} dos seus {total} últimos começos aconteceram sob {phase}',
  moonNotSynced:
      'O ciclo lunar e o menstrual não precisam estar sincronizados. Observe '
      'como os dois se encontram ao longo do tempo.',
  closingCorrespondence:
      '{phase} e o sangramento compartilham uma correspondência simbólica de '
      'encerramento. Se isso fizer sentido para a sua prática, pode ser um '
      'bom momento para observar o que você quer deixar.',
  entries: [
    // ── 🩸 O sangue na magia ──────────────────────────────────────────────
    BloodLoreEntry(
      id: 'sangue-vinculo',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '🔗',
      title: 'Sangue como vínculo',
      summary: 'Por que matéria do corpo aparece tanto na magia popular',
      sections: [
        BloodLoreSection(
          title: 'Matéria que pertence a alguém',
          body:
              'Sangue, cabelo, unhas, saliva, um pedaço de roupa usada: a '
              'magia popular registrada na Europa, nas Américas e em outras '
              'partes do mundo volta a esses materiais o tempo todo. A lógica '
              'é sempre a mesma — o que pertenceu a um corpo continua ligado '
              'a ele, e trabalhar com o material seria trabalhar com a '
              'pessoa.',
        ),
        BloodLoreSection(
          title: 'O que o sangue menstrual reúne',
          body:
              'Ele junta num material só: sangue, identidade corporal, ciclo, '
              'sexualidade e fertilidade simbólica. É essa soma, e não o '
              'sangue sozinho, que explica por que ele aparece com tanta '
              'insistência nos registros.',
        ),
        BloodLoreSection(
          title: 'O termo moderno',
          body:
              'A bruxaria contemporânea costuma chamar esses materiais de '
              'taglock. A palavra é recente e é útil para nomear o conjunto, '
              'mas o conceito é muito mais antigo do que ela — e as fontes '
              'históricas não a usam.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'ambivalencia',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '⚖️',
      title: 'A ambivalência do sangue menstrual',
      summary:
          'Perigoso, tabu, protetor, poderoso: os registros não concordam '
          'entre si',
      sections: [
        BloodLoreSection(
          title: 'Não existe uma visão única',
          body:
              'Dependendo do lugar e da época, o sangue menstrual já foi '
              'tratado como perigoso, como tabu, como protetor, como '
              'poderoso, como ligado à fertilidade e como capaz de afastar '
              'determinadas influências. Todas essas leituras aparecem nos '
              'registros, e às vezes na mesma cultura.',
        ),
        BloodLoreSection(
          title: 'Por que isso importa',
          body:
              'A frase "antigamente o sangue menstrual era considerado '
              'sagrado" circula muito e não se sustenta como afirmação '
              'universal. Houve reverência em alguns lugares e interdição '
              'severa em outros. A ambivalência é o achado, não um detalhe '
              'incômodo.',
        ),
        BloodLoreSection(
          title: 'O que fazer com isso',
          body:
              'Saber que não há consenso devolve a escolha para você. '
              'Nenhuma tradição decide sozinha o que menstruar significa na '
              'sua prática.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'amor-e-ligacao',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '❤️',
      title: 'Amor e ligação',
      summary:
          'O uso mais recorrente do sangue menstrual na magia amorosa '
          'registrada',
      sections: [
        BloodLoreSection(
          title: 'O que os registros mostram',
          body:
              'Entre os usos do sangue menstrual que mais aparecem em '
              'processos, receituários e coleções de folclore, a magia '
              'amorosa vem em primeiro lugar. Há registros de práticas em que '
              'o sangue era posto às escondidas na comida ou na bebida da '
              'pessoa desejada para produzir desejo, ligação, afeição ou '
              'submissão.',
        ),
        BloodLoreSection(
          title: 'Isto é história, não instrução',
          body:
              'O Grimório conta essa prática porque ela é parte da história '
              'da magia. Não a transforma em passo a passo: ela envolve '
              'fluido corporal, uma pessoa que não escolheu participar e '
              'risco sanitário real.',
        ),
        BloodLoreSection(
          title: 'O que cabe aqui',
          body:
              'A mesma intenção — atração, magnetismo, abertura — pode ser '
              'trabalhada sobre você mesma, sem tocar no que é de outra '
              'pessoa.',
        ),
      ],
      cta: BloodLoreCta(
        label: 'Explorar um encanto de atração',
        link: BloodLoreLink.entry,
        entryId: 'encanto-de-atracao',
      ),
    ),
    BloodLoreEntry(
      id: 'protecao',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.documented,
      emoji: '🛡️',
      title: 'Proteção',
      summary: 'Contra-magia, casa e limiares: o outro lado dos registros',
      sections: [
        BloodLoreSection(
          title: 'Força que repele',
          body:
              'Uma ideia atravessa muitas fontes: aquilo que é considerado '
              'magicamente forte — ou perigoso — também serve para afastar '
              'outra influência. É por isso que o mesmo material que aparece '
              'em interdições aparece em proteções.',
        ),
        BloodLoreSection(
          title: 'Casa e limiares',
          body:
              'Portas, soleiras, janelas e cercas são os pontos onde a '
              'proteção doméstica costuma ser posta, em tradições muito '
              'diferentes entre si. O sangue menstrual aparece nesse conjunto '
              'em parte dos registros, ao lado de sal, ferro, ervas e '
              'símbolos riscados.',
        ),
        BloodLoreSection(
          title: 'Contra-magia',
          body:
              'Em vários corpos de relatos ele é citado como recurso contra '
              'feitiço alheio, e não como feitiço de ataque.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'vinculo-e-poder',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.contemporary,
      emoji: '🔮',
      title: 'Vínculo e poder pessoal',
      summary: 'Matéria do próprio corpo como assinatura mágica',
      sections: [
        BloodLoreSection(
          title: 'A assinatura',
          body:
              'Se material do corpo cria vínculo, o material do seu corpo '
              'cria vínculo com você. É a leitura contemporânea mais comum: '
              'usar algo seu para assinar um gesto, marcar um compromisso, '
              'reforçar uma intenção.',
        ),
        BloodLoreSection(
          title: 'Onde isso costuma entrar',
          body:
              'Compromissos consigo mesma, proteção pessoal, fortalecimento '
              'de intenção, trabalhos de identidade e de poder pessoal. O '
              'foco é sempre você — nunca a vontade de outra pessoa.',
        ),
        BloodLoreSection(
          title: 'De onde vem',
          body:
              'A ideia de que matéria do corpo assina é antiga. Voltá-la para '
              'si mesma como prática de autonomia é recente, e vem da '
              'bruxaria contemporânea.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'vida-e-terra',
      category: BloodLoreCategory.bloodInMagic,
      tag: BloodLoreTag.tradition,
      emoji: '🌱',
      title: 'Vida, fertilidade e natureza',
      summary: 'Tradições específicas ligam esse sangue ao que cresce',
      sections: [
        BloodLoreSection(
          title: 'Um recorte, não uma regra',
          body:
              'Existem tradições que associam o sangue menstrual à '
              'fertilidade, aos campos, ao cultivo, à vida e aos ciclos '
              'naturais. São tradições específicas, de lugares e épocas '
              'específicos — não um significado universal do corpo.',
        ),
        BloodLoreSection(
          title: 'Como aparece',
          body:
              'Em parte desses relatos, o gesto descrito é devolver o sangue '
              'à terra ou às plantas da casa, num movimento de restituição: '
              'o que veio do corpo volta ao que alimenta o corpo.',
        ),
        BloodLoreSection(
          title: 'O cuidado ao ler',
          body:
              'Transformar esses casos em "todas as culturas antigas" é o '
              'erro mais comum quando se fala do assunto. Aqui eles ficam '
              'onde estão: como tradições, com lugar e época.',
        ),
      ],
    ),

    // ── 🌙 Ciclo e Lua ────────────────────────────────────────────────────
    BloodLoreEntry(
      id: 'duas-rodas',
      category: BloodLoreCategory.cycleAndMoon,
      tag: BloodLoreTag.contemporary,
      emoji: '🌙',
      title: 'Duas rodas que se encontram',
      summary: 'A Lua como correspondência e ferramenta de observação',
      sections: [
        BloodLoreSection(
          title: 'Dois calendários redondos',
          body:
              'O ciclo lunar tem cerca de vinte e nove dias e meio. O ciclo '
              'menstrual varia de pessoa para pessoa e de volta para volta. '
              'Os dois são redondos, e é daí que vem a analogia — não de um '
              'mandar no outro.',
        ),
        BloodLoreSection(
          title: 'O que a magia lunar faz com isso',
          body:
              'Na magia, cada fase carrega uma correspondência: o que cresce, '
              'o que está cheio, o que recolhe, o que recomeça. Pôr o seu '
              'começo ao lado da fase daquele dia é usar essa correspondência '
              'como lente, do mesmo jeito que se usa a roda do ano.',
        ),
        BloodLoreSection(
          title: 'O que isto não é',
          body:
              'O ciclo lunar e o menstrual não precisam estar sincronizados, '
              'e não há por que esperar que estejam. Observe como os dois se '
              'encontram ao longo do tempo, se isso fizer sentido para a sua '
              'prática.',
        ),
      ],
    ),
    BloodLoreEntry(
      id: 'interpretacoes-contemporaneas',
      category: BloodLoreCategory.cycleAndMoon,
      tag: BloodLoreTag.contemporary,
      emoji: '✨',
      title: 'Interpretações contemporâneas',
      summary: 'Lua Branca, Lua Vermelha e outras categorias recentes',
      sections: [
        BloodLoreSection(
          title: 'De onde vêm',
          body:
              'As categorias de Lua Branca, Lua Vermelha, Lua Rosa e Lua '
              'Púrpura são criação do fim do século XX e circulam em livros e '
              'cursos de agora. Não são tradição antiga e não aparecem em '
              'fontes históricas.',
        ),
        BloodLoreSection(
          title: 'Por que não são a base daqui',
          body:
              'Elas classificam a pessoa pela fase em que ela sangra e '
              'costumam ligar cada categoria a um papel — maternidade, cura, '
              'ensino. O Grimório não faz essa classificação: o que ele '
              'mostra é a sua Lua e o seu começo, lado a lado.',
        ),
        BloodLoreSection(
          title: 'Se você quiser usá-las',
          body:
              'Nada impede. Só vale saber a idade da ideia antes de adotá-la, '
              'e lembrar que ela descreve uma leitura, não o seu corpo.',
        ),
      ],
    ),

    // ── 🔮 Práticas e feitiços ────────────────────────────────────────────
    BloodLoreEntry(
      id: 'selo-do-limiar',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.modernAdaptation,
      emoji: '🛡️',
      title: 'Selo do Limiar',
      summary: 'Um símbolo de proteção guardado perto da porta',
      intention: 'Proteção da casa.',
      materials: [
        'Um papel pequeno',
        'Caneta',
        'Um envelope ou recipiente que feche',
        'Uma quantidade mínima do seu próprio sangue menstrual, se você quiser',
      ],
      steps: [
        'Escolha ou desenhe um símbolo pessoal de proteção — uma letra, um '
            'traço, um sigilo seu.',
        'Escreva ou desenhe o símbolo no papel.',
        'Se quiser trabalhar com o seu sangue menstrual, faça uma marca '
            'mínima no papel e deixe secar completamente.',
        'Dobre o papel, feche no envelope e guarde perto da entrada da casa.',
      ],
      withoutBlood:
          'Sem sangue, a prática é a mesma: o símbolo desenhado, o papel '
          'fechado e guardado no limiar. Se quiser marcá-lo com algo seu, a '
          'sua letra ou uma gota de um óleo que você usa cumprem o papel.',
      sections: [
        BloodLoreSection(
          title: 'De onde vem',
          body:
              'Adaptada de registros que ligam o sangue menstrual à proteção '
              'de limiares e à contra-magia doméstica. O gesto de guardar o '
              'papel fechado é de agora: as fontes antigas não descrevem esta '
              'prática desta forma.',
        ),
        BloodLoreSection(
          title: 'Um cuidado',
          body:
              'Não espalhe sangue pela casa, por móveis ou por superfícies '
              'compartilhadas. A marca é mínima, seca e fica dentro de um '
              'papel fechado.',
        ),
      ],
      mentionsBlood: true,
    ),
    BloodLoreEntry(
      id: 'laco-de-compromisso',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.modernAdaptation,
      emoji: '🔗',
      title: 'Laço de compromisso',
      summary: 'Uma frase que você quer sustentar, dobrada e amarrada',
      intention: 'Firmar um compromisso com você mesma.',
      materials: [
        'Papel e caneta',
        'Linha ou cordão',
        'Uma quantidade mínima do seu próprio sangue menstrual, se você quiser',
      ],
      steps: [
        'Escreva uma frase curta, no presente, sobre algo que você quer '
            'sustentar: "Eu protejo meu tempo", "Eu termino o que começo", '
            '"Eu mantenho este limite".',
        'Se quiser, faça uma marca mínima do seu sangue no papel e espere '
            'secar completamente.',
        'Dobre o papel em direção a você, nunca para longe.',
        'Amarre com a linha e guarde onde você vá encontrá-lo de novo.',
      ],
      withoutBlood:
          'Sem sangue, assine o papel com o seu nome ou com a sua letra. O '
          'que assina é o gesto de escrever, não o material.',
      sections: [
        BloodLoreSection(
          title: 'De onde vem',
          body:
              'Adaptação moderna da magia de vínculo: o mesmo raciocínio de '
              'amarrar e dobrar em direção a si, voltado para um compromisso '
              'pessoal em vez de outra pessoa.',
        ),
        BloodLoreSection(
          title: 'O foco',
          body:
              'O trabalho é sobre você. Vínculo dirigido a quem não escolheu '
              'participar é outra coisa, e não é o que esta prática faz.',
        ),
      ],
      mentionsBlood: true,
    ),
    BloodLoreEntry(
      id: 'encanto-de-atracao',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.modernAdaptation,
      emoji: '❤️',
      title: 'Encanto de atração',
      summary: 'Atração e abertura, sem endereçar ninguém',
      intention:
          'Atração, magnetismo, autoestima e abertura para as relações que '
          'você deseja.',
      materials: [
        'Papel e caneta',
        'Um sigilo seu, se você quiser criar um',
        'Um perfume ou óleo que você use',
        'Um objeto pessoal que fique com você',
        'Uma quantidade mínima do seu próprio sangue menstrual, se você quiser',
      ],
      steps: [
        'Escreva a intenção sem endereçá-la a ninguém: "Que aquilo que me '
            'deseja e me faz bem encontre caminho até mim".',
        'Se quiser, transforme a frase num sigilo — o Grimório já tem um '
            'criador de sigilos.',
        'Passe o perfume no objeto pessoal.',
        'Se quiser trabalhar com o seu sangue menstrual, faça uma marca '
            'mínima no papel do sigilo e deixe secar completamente.',
        'Carregue o objeto com você enquanto a intenção estiver de pé.',
      ],
      withoutBlood:
          'Sem sangue, o perfume e o objeto pessoal já são o material seu que '
          'o encanto pede.',
      sections: [
        BloodLoreSection(
          title: 'De onde vem',
          body:
              'Adaptação contemporânea. Não é a magia amorosa dos registros '
              'históricos, que agia sobre uma pessoa específica sem que ela '
              'soubesse.',
        ),
        BloodLoreSection(
          title: 'O foco',
          body:
              'O encanto não é dirigido a ninguém. Ele trabalha o que parte '
              'de você: atração, autoestima e abertura. Nunca ponha sangue — '
              'nem qualquer outro fluido — no que pertence a outra pessoa.',
        ),
      ],
      mentionsBlood: true,
      cta: BloodLoreCta(
        label: 'Criar um sigilo',
        link: BloodLoreLink.sigils,
      ),
    ),
    BloodLoreEntry(
      id: 'consagracao-de-sigilo',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.contemporary,
      emoji: '🕯️',
      title: 'Consagração de sigilo',
      summary: 'Dar carga pessoal a um sigilo que você criou',
      intention: 'Consagrar um sigilo com algo que é seu.',
      materials: [
        'Um sigilo criado por você',
        'Papel e caneta',
        'Uma vela, se quiser',
        'Uma quantidade mínima do seu próprio sangue menstrual, se você quiser',
      ],
      steps: [
        'Crie o sigilo no Grimório, a partir de uma intenção de uma palavra.',
        'Copie o traço do sigilo num papel, à mão.',
        'Segure o papel e diga a intenção em voz alta, uma vez.',
        'Se quiser, marque o papel com uma quantidade mínima do seu sangue e '
            'deixe secar completamente.',
        'Guarde o papel onde você o veja, ou feche-o e guarde onde ninguém '
            'mexa.',
      ],
      withoutBlood:
          'Sem sangue, use a sua respiração sobre o papel, a chama de uma '
          'vela ou apenas a sua letra. A consagração é o gesto de dedicar, e '
          'ele não depende do material.',
      sections: [
        BloodLoreSection(
          title: 'De onde vem',
          body:
              'Prática contemporânea. Consagrar um objeto com algo do '
              'praticante é gesto antigo; o sigilo do jeito que a bruxaria '
              'usa hoje vem do século XX.',
        ),
      ],
      mentionsBlood: true,
      cta: BloodLoreCta(
        label: 'Abrir o criador de sigilos',
        link: BloodLoreLink.sigils,
      ),
    ),
    BloodLoreEntry(
      id: 'ritual-de-encerramento',
      category: BloodLoreCategory.practices,
      tag: BloodLoreTag.contemporary,
      emoji: '🍂',
      title: 'Ritual de encerramento',
      summary: 'Nomear e soltar o que chegou ao fim',
      intention: 'Nomear e soltar algo que chegou ao fim.',
      materials: [
        'Papel e caneta',
        'Uma vela, se quiser',
        'Um recipiente seguro, se você for queimar',
      ],
      steps: [
        'Escreva, sem tentar resolver, o que você não quer levar para a '
            'próxima volta.',
        'Leia o que escreveu uma vez, em voz alta ou em silêncio.',
        'Rasgue o papel, queime-o num recipiente seguro ou guarde-o fechado '
            'até a próxima volta.',
        'Se quiser continuar escrevendo, o Diário do Grimório é o lugar.',
      ],
      sections: [
        BloodLoreSection(
          title: 'De onde vem',
          body:
              'Prática contemporânea. A relação simbólica entre sangramento e '
              'liberação é leitura de agora, e não uma tradição antiga '
              'determinada.',
        ),
        BloodLoreSection(
          title: 'Um cuidado',
          body:
              'Se for queimar, use um recipiente próprio para isso, longe de '
              'cortinas e de qualquer coisa que pegue fogo.',
        ),
      ],
      cta: BloodLoreCta(
        label: 'Escrever no Diário',
        link: BloodLoreLink.diary,
      ),
    ),

    // ── 📜 Tradições e história ───────────────────────────────────────────
    BloodLoreEntry(
      id: 'filtro-de-sangue',
      category: BloodLoreCategory.traditions,
      tag: BloodLoreTag.documented,
      emoji: '📜',
      title: 'Filtro de sangue menstrual',
      summary:
          'A prática amorosa mais registrada — e por que ela não vira '
          'tutorial',
      sections: [
        BloodLoreSection(
          title: 'O que os registros descrevem',
          body:
              'Em atas de processos, receituários de magia popular e coleções '
              'de folclore aparece com frequência a mesma prática: pôr às '
              'escondidas uma pequena quantidade de sangue menstrual na '
              'comida ou na bebida da pessoa desejada, para criar ligação, '
              'desejo ou submissão.',
        ),
        BloodLoreSection(
          title: 'A lógica mágica',
          body:
              'Uma substância que pertence a quem faz o feitiço seria '
              'incorporada pelo alvo. Ao passar para dentro do corpo dele, '
              'ela estabeleceria simbolicamente o vínculo — a mesma ideia de '
              'que matéria do corpo liga pessoas, levada ao limite.',
        ),
        BloodLoreSection(
          title: 'Por que o Grimório não ensina',
          body:
              'Porque a prática envolve fluido corporal, alimento ou bebida '
              'de outra pessoa, ausência de consentimento e risco sanitário '
              'real. Descrever o que a história registrou é uma coisa; dar o '
              'passo a passo é outra.',
        ),
      ],
      cta: BloodLoreCta(
        label: 'Explorar um encanto de atração',
        link: BloodLoreLink.entry,
        entryId: 'encanto-de-atracao',
      ),
    ),
    BloodLoreEntry(
      id: 'onde-os-registros-estao',
      category: BloodLoreCategory.traditions,
      tag: BloodLoreTag.documented,
      emoji: '🗂️',
      title: 'Onde estão os registros',
      summary: 'Como sabemos o que sabemos — e o que não dá para saber',
      sections: [
        BloodLoreSection(
          title: 'As fontes',
          body:
              'O que se sabe sobre magia com sangue menstrual vem sobretudo '
              'de três lugares: atas de processos, onde a prática é descrita '
              'por quem acusa; receituários e manuais de magia popular; e '
              'coleções de folclore feitas entre os séculos XIX e XX.',
        ),
        BloodLoreSection(
          title: 'O que isso distorce',
          body:
              'Nenhuma dessas fontes é neutra. Um processo registra o que o '
              'tribunal quis ouvir; quem coleta folclore escreve o que '
              'entendeu. O que chega até nós são práticas reais vistas por '
              'olhos de fora.',
        ),
        BloodLoreSection(
          title: 'O que fica de pé',
          body:
              'A recorrência. Quando o mesmo gesto aparece em fontes que não '
              'conversam entre si, é razoável dizer que ele existia. Quando '
              'aparece uma vez só, ele é um relato — e é assim que fica '
              'marcado aqui.',
        ),
      ],
    ),
  ],
);
