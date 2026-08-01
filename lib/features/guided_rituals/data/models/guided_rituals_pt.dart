import 'guided_ritual_model.dart';

/// Conteúdo dos rituais guiados — português (idioma-base).
/// Paridade com EN/ES verificada em test/guided_rituals_parity_test.dart.

const Map<String, GuidedRitualText> guidedRitualTextsPt = {
  'sabbat_samhain': (
    title: 'Ritual de Samhain',
    intro:
        'O Ano Novo das Bruxas. O véu entre os mundos está no seu ponto mais fino: é a noite de honrar ancestrais, encerrar ciclos e ouvir a própria intuição.',
    timing:
        'No dia de Samhain, preferencialmente ao anoitecer, quando o véu se afina.',
  ),
  'sabbat_yule': (
    title: 'Ritual de Yule',
    intro:
        'O Solstício de Inverno traz a noite mais longa do ano. Celebramos o renascimento da luz: a partir de agora, os dias voltam a crescer.',
    timing: 'No dia do solstício, ao entardecer ou à noite.',
  ),
  'sabbat_imbolc': (
    title: 'Ritual de Imbolc',
    intro:
        'Festival da luz crescente. A Terra desperta lentamente e os primeiros sinais da primavera aparecem. É tempo de purificar, limpar e preparar o novo crescimento.',
    timing: 'No dia de Imbolc, pela manhã ou ao meio-dia, em honra à luz que cresce.',
  ),
  'sabbat_ostara': (
    title: 'Ritual de Ostara',
    intro:
        'Equinócio de Primavera: luz e escuridão em equilíbrio perfeito e a natureza desperta em plenitude. Tempo de novos começos e fertilidade de ideias.',
    timing: 'No dia do equinócio, pela manhã.',
  ),
  'sabbat_beltane': (
    title: 'Ritual de Beltane',
    intro:
        'O festival do fogo e da fertilidade. A vida está em plenitude: celebre o amor, a paixão e a alegria de estar viva.',
    timing: 'No dia de Beltane, do fim da tarde até a noite.',
  ),
  'sabbat_litha': (
    title: 'Ritual de Litha',
    intro:
        'Solstício de Verão: o dia mais longo e o pico do poder solar. Momento de celebrar conquistas, agradecer e absorver a força do Sol.',
    timing: 'No dia do solstício, do nascer ao pôr do sol.',
  ),
  'sabbat_lammas': (
    title: 'Ritual de Lammas',
    intro:
        'A primeira colheita. Depois da abundância do verão, é tempo de agradecer, compartilhar e reconhecer o esforço por trás de cada conquista.',
    timing: 'No dia de Lammas, à tarde.',
  ),
  'sabbat_mabon': (
    title: 'Ritual de Mabon',
    intro:
        'Equinócio de Outono: a segunda colheita e o segundo equilíbrio do ano. Tempo de gratidão, balanço e de liberar o que não precisa seguir com você.',
    timing: 'No dia do equinócio, ao entardecer.',
  ),
  'full_moon': (
    title: 'Ritual de Lua Cheia',
    intro:
        'A Lua está no auge do seu poder e ilumina tudo o que você vem construindo. É a hora de manifestar intenções, carregar seus cristais e instrumentos e praticar adivinhação.',
    timing: 'Na noite da lua cheia (a energia também vale na véspera e no dia seguinte).',
  ),
  'new_moon': (
    title: 'Ritual de Lua Nova',
    intro:
        'O céu escuro é uma página em branco. A lua nova é o momento de plantar intenções, começar projetos e se reconectar com o que você quer atrair.',
    timing: 'Na noite da lua nova, em um lugar tranquilo.',
  ),
  'moon_water': (
    title: 'Água de Lua',
    intro:
        'A Água de Lua guarda a energia da lua cheia para você usar quando precisar: em feitiços, banhos, limpezas e até para regar as plantas.',
    timing:
        'Prepare na noite da lua cheia e recolha antes de o sol nascer, para a água não receber energia solar.',
  ),
  'sun_water': (
    title: 'Água Solar',
    intro:
        'A Água Solar carrega vitalidade, coragem e alegria. É a irmã diurna da água de lua: use quando precisar de um impulso de energia e força.',
    timing:
        'Em um dia ensolarado, do início da manhã até o meio da tarde (3 a 6 horas de sol bastam).',
  ),
};

const Map<String, List<RitualStepText>> guidedRitualStepsPt = {
  'sabbat_samhain': [
    (
      title: 'Prepare o espaço',
      description:
          'Limpe o ambiente, acenda um incenso (sálvia ou alecrim) e apague as luzes fortes. Deixe o clima silencioso e acolhedor.'
    ),
    (
      title: 'Monte o altar dos ancestrais',
      description:
          'Coloque fotos ou objetos de entes queridos que já partiram, com uma oferenda simples: um copo de água, pão ou uma fruta.'
    ),
    (
      title: 'Acenda as velas',
      description:
          'Acenda uma vela preta (para liberar o que ficou para trás) e uma laranja (para a colheita da vida). Agradeça em voz baixa a quem veio antes de você.'
    ),
    (
      title: 'Converse com a memória',
      description:
          'Diga em voz alta (ou escreva) uma lembrança boa de cada pessoa homenageada. Se quiser, faça uma pequena ceia em silêncio.'
    ),
    (
      title: 'Pratique adivinhação',
      description:
          'Com o véu fino, tire uma carta de tarô, runas ou use o pêndulo perguntando: "o que preciso deixar no ano que termina?".'
    ),
    (
      title: 'Encerre e agradeça',
      description:
          'Apague as velas (sem soprar, se preferir a tradição), agradeça aos ancestrais e descarte a oferenda na natureza no dia seguinte.'
    ),
  ],
  'sabbat_yule': [
    (
      title: 'Decore com elementos naturais',
      description:
          'Recolha (ou separe) pinhas, galhos, canela e frutas secas e monte um pequeno arranjo no seu altar ou mesa.'
    ),
    (
      title: 'Apague tudo por um instante',
      description:
          'Fique um momento no escuro, respirando fundo. Honre a noite mais longa do ano e tudo o que descansa para renascer.'
    ),
    (
      title: 'Acenda a luz que retorna',
      description:
          'Acenda velas douradas, vermelhas ou brancas, uma a uma, dizendo o que você quer que cresça junto com a luz nos próximos meses.'
    ),
    (
      title: 'Banho de ervas purificador',
      description:
          'Prepare um banho com alecrim e canela (do pescoço para baixo). Visualize o que ficou pesado escorrendo pelo ralo.'
    ),
    (
      title: 'Medite sobre o ciclo',
      description:
          'Em frente às velas, medite alguns minutos sobre morte e renascimento: o que termina em você, e o que está nascendo?'
    ),
    (
      title: 'Compartilhe calor',
      description:
          'Prepare uma bebida quente (quentão, chá com gengibre) e, se puder, compartilhe com alguém querido. Yule é festa de aconchego.'
    ),
  ],
  'sabbat_imbolc': [
    (
      title: 'Faça a limpeza de primavera',
      description:
          'Varra a casa da porta dos fundos para a frente (ou visualize a sujeira saindo), abrindo espaço para o novo. Se tiver vassoura ritual, é a hora dela.'
    ),
    (
      title: 'Purifique com fumaça ou água',
      description:
          'Passe incenso de lavanda ou camomila pelos cômodos, ou borrife água com sal, pedindo que a energia estagnada se dissolva.'
    ),
    (
      title: 'Acenda a vela da luz crescente',
      description:
          'Acenda uma vela branca, amarela ou vermelha em honra ao Sol que retorna. Se quiser, dedique-a a Brigid, senhora do fogo e da inspiração.'
    ),
    (
      title: 'Plante suas sementes',
      description:
          'Plante sementes de verdade (ervas, flores) ou simbólicas: escreva no papel o que você quer ver florescer e guarde junto a um vasinho.'
    ),
    (
      title: 'Banho de leite e mel',
      description:
          'Se puder, faça um banho com um pouco de leite e mel, pedindo suavidade, nutrição e novos começos.'
    ),
    (
      title: 'Feche com gratidão',
      description:
          'Agradeça a luz que cresce. Deixe a vela queimar com segurança até o fim (ou apague e reacenda nos próximos dias).'
    ),
  ],
  'sabbat_ostara': [
    (
      title: 'Arrume um altar de primavera',
      description:
          'Use flores frescas, sementes e cores claras. Abra as janelas e deixe o ar circular.'
    ),
    (
      title: 'Pinte ou decore ovos',
      description:
          'Pinte ovos (ou pedrinhas) com símbolos do que você quer fazer nascer: espirais, sóis, runas, corações.'
    ),
    (
      title: 'Plante flores e ervas',
      description:
          'Plante em vasos ou no jardim. Cada muda é uma intenção: diga em voz alta o que cada uma representa.'
    ),
    (
      title: 'Equilibre suas energias',
      description:
          'O equinócio pede equilíbrio: acenda uma vela branca e uma preta e reflita sobre o que precisa equilibrar (trabalho/descanso, dar/receber).'
    ),
    (
      title: 'Crie um sachê de prosperidade',
      description:
          'Num saquinho verde ou amarelo, coloque manjericão, hortelã e uma moeda. Carregue com você ou deixe perto da porta de entrada.'
    ),
  ],
  'sabbat_beltane': [
    (
      title: 'Monte um altar de flores',
      description:
          'Encha o altar de flores vermelhas, rosas e coloridas. Beltane celebra a vida em plenitude.'
    ),
    (
      title: 'Acenda o fogo sagrado',
      description:
          'Acenda velas vermelhas (ou uma fogueira, com segurança). O fogo de Beltane purifica e vitaliza: passe as mãos perto do calor e sinta a energia.'
    ),
    (
      title: 'Dance e celebre',
      description:
          'Coloque uma música que te faça feliz e dance, mesmo que sozinha. Deixe o corpo celebrar estar viva.'
    ),
    (
      title: 'Faça oferendas aos elementais',
      description:
          'Deixe mel, leite ou flores num cantinho do jardim ou vaso, agradecendo às fadas e aos espíritos da natureza.'
    ),
    (
      title: 'Celebre o amor',
      description:
          'Escreva uma carta de amor — para alguém ou para si mesma. Guarde-a junto de um quartzo rosa até o próximo sabbat.'
    ),
  ],
  'sabbat_litha': [
    (
      title: 'Saúde o Sol',
      description:
          'Assista ao nascer (ou ao pôr) do sol. Agradeça em voz alta pela luz, pelo calor e por tudo que amadureceu na sua vida.'
    ),
    (
      title: 'Colha ervas mágicas',
      description:
          'As ervas estão no auge do poder: colha (ou compre) camomila, hortelã e lavanda para secar e usar o ano todo.'
    ),
    (
      title: 'Faça um círculo de proteção',
      description:
          'Caminhe pelo contorno da casa (ou visualize) espalhando sal ou alecrim, pedindo proteção para quem vive nela.'
    ),
    (
      title: 'Carregue seus objetos ao sol',
      description:
          'Deixe joias, amuletos e cristais que aceitam sol (cuidado com os que desbotam) banharem-se na luz por algumas horas.'
    ),
    (
      title: 'Celebre com as cores do Sol',
      description:
          'Prepare uma mesa com frutas frescas e flores amarelas e douradas. Coma devagar, com gratidão.'
    ),
  ],
  'sabbat_lammas': [
    (
      title: 'Asse (ou compre) um pão',
      description:
          'O pão é o símbolo da primeira colheita. Se puder, asse com as próprias mãos, colocando intenção de fartura em cada gesto.'
    ),
    (
      title: 'Agradeça as conquistas',
      description:
          'Liste tudo o que você colheu este ano — até as colheitas pequenas. Leia em voz alta diante do altar.'
    ),
    (
      title: 'Faça uma boneca de milho',
      description:
          'Com palha de milho (ou papel), faça uma bonequinha guardiã da colheita. Guarde-a até o próximo plantio.'
    ),
    (
      title: 'Compartilhe a abundância',
      description:
          'Separe alimentos para doar. A colheita cresce quando é dividida.'
    ),
    (
      title: 'Ofereça o primeiro pedaço',
      description:
          'Ofereça o primeiro pedaço do pão à Terra (num vaso ou jardim), agradecendo o sacrifício que gera abundância.'
    ),
  ],
  'sabbat_mabon': [
    (
      title: 'Monte a cornucópia de gratidão',
      description:
          'Numa cesta ou prato, arrume maçãs, uvas, nozes e abóboras. A cada item, diga uma coisa pela qual é grata.'
    ),
    (
      title: 'Faça o balanço do ano',
      description:
          'Escreva o que deu certo e o que pesou. Mabon é o equilíbrio: olhe para os dois lados sem julgamento.'
    ),
    (
      title: 'Libere o que não segue',
      description:
          'Escreva num papel o que você libera nesta virada. Queime com segurança (ou rasgue e descarte), agradecendo a lição.'
    ),
    (
      title: 'Preserve os sabores',
      description:
          'Prepare uma geleia, um chá ou congele frutas. Guardar alimento é magia de previdência para o inverno.'
    ),
    (
      title: 'Acenda velas de outono',
      description:
          'Acenda velas laranja ou marrom e medite sobre a beleza de soltar — como as árvores soltam as folhas.'
    ),
  ],
  'full_moon': [
    (
      title: 'Prepare o espaço sob o luar',
      description:
          'Se possível, fique onde a luz da lua alcance (janela, varanda, quintal). Acenda uma vela branca ou prateada.'
    ),
    (
      title: 'Coloque a Água de Lua para preparar',
      description:
          'Encha uma jarra ou garrafa com água e tampe. Deixe sob o luar — você recolhe antes do amanhecer. (Há um ritual guiado só para isso!)'
    ),
    (
      title: 'Carregue cristais e instrumentos',
      description:
          'Deixe cristais, baralhos, pêndulos e joias sob os raios da lua para limpar e recarregar a energia deles.'
    ),
    (
      title: 'Manifeste suas intenções',
      description:
          'Releia (ou lembre) as intenções plantadas na lua nova. Agradeça o que já floresceu e visualize o restante se realizando.'
    ),
    (
      title: 'Pratique adivinhação',
      description:
          'A lua cheia potencializa a intuição: tire cartas de tarô ou oráculo, jogue as runas ou consulte o pêndulo.'
    ),
    (
      title: 'Faça um amuleto de proteção',
      description:
          'Deixe um colar, anel ou pedrinha absorvendo o luar e consagre-o como seu amuleto: "que esta lua te carregue de proteção".'
    ),
    (
      title: 'Encerre com gratidão',
      description:
          'Agradeça à Lua, apague a vela e, se colheu ervas hoje, pendure-as para secar — nesta fase é mais fácil desidratá-las.'
    ),
  ],
  'new_moon': [
    (
      title: 'Crie um espaço silencioso',
      description:
          'Apague as luzes fortes, acenda uma única vela e respire fundo algumas vezes. A lua nova pede recolhimento.'
    ),
    (
      title: 'Limpe a energia',
      description:
          'Passe um incenso ou visualize uma luz varrendo o ambiente e o seu corpo, levando embora o ciclo que terminou.'
    ),
    (
      title: 'Escreva suas intenções',
      description:
          'Escreva no papel o que você quer plantar neste ciclo: seja específica e escreva no presente, como se já fosse real.'
    ),
    (
      title: 'Plante simbolicamente',
      description:
          'Dobre o papel e coloque sob um vaso, dentro de uma caixinha ou junto a uma semente plantada de verdade.'
    ),
    (
      title: 'Visualize o crescimento',
      description:
          'De olhos fechados, visualize cada intenção crescendo junto com a lua até a lua cheia. Sinta como se já tivesse acontecido.'
    ),
    (
      title: 'Sele o ritual',
      description:
          'Agradeça, apague a vela e guarde o papel. Reencontre-o na lua cheia para celebrar o que já se moveu.'
    ),
  ],
  'moon_water': [
    (
      title: 'Escolha e lave o recipiente',
      description:
          'Use uma jarra, garrafa ou pote de vidro bem limpo. Se quiser, lave com água e sal e enxágue bem.'
    ),
    (
      title: 'Encha com água',
      description:
          'Água potável se você pretende beber; água comum se for só para uso mágico (banhos, limpezas, plantas).'
    ),
    (
      title: 'Tampe o recipiente',
      description:
          'Tampar protege a água de sujeira e mantém a intenção selada. Vidro tampado é a forma tradicional.'
    ),
    (
      title: 'Declare a intenção',
      description:
          'Segure o recipiente e diga para que essa água vai servir: limpeza, cura, intuição, proteção... A água guarda a mensagem.'
    ),
    (
      title: 'Deixe sob o luar',
      description:
          'Coloque onde a luz da lua alcance (janela, varanda, quintal) por pelo menos algumas horas da noite.'
    ),
    (
      title: 'Recolha antes do sol nascer',
      description:
          'Guarde a água antes do amanhecer para ela não receber energia solar. Rotule com a data e a intenção.'
    ),
  ],
  'sun_water': [
    (
      title: 'Escolha um dia de sol forte',
      description:
          'Quanto mais claro o dia, mais vitalidade a água carrega. Manhãs são ideais: a energia é de começo e expansão.'
    ),
    (
      title: 'Prepare o recipiente',
      description:
          'Vidro limpo e transparente, de preferência. Encha com água potável se for beber, ou comum para uso mágico.'
    ),
    (
      title: 'Declare a intenção',
      description:
          'Segure o pote ao sol e diga o que precisa: coragem, alegria, força, criatividade. O Sol é generoso com quem pede.'
    ),
    (
      title: 'Deixe ao sol por 3 a 6 horas',
      description:
          'Não precisa do dia inteiro: do meio da manhã ao meio da tarde já carrega bem. Tampe para proteger.'
    ),
    (
      title: 'Recolha antes do entardecer',
      description:
          'Guarde a água ainda com o sol no céu. Rotule com a data e use nos próximos dias, enquanto a energia está fresca.'
    ),
  ],
};

const Map<String, List<String>> guidedRitualMaterialsPt = {
  'sabbat_samhain': [
    'Velas preta e laranja',
    'Fotos ou objetos de entes queridos',
    'Incenso de sálvia ou alecrim',
    'Oferenda simples (água, pão ou fruta)',
    'Tarô, runas ou pêndulo (opcional)',
  ],
  'sabbat_yule': [
    'Velas douradas, vermelhas ou brancas',
    'Pinhas, galhos, canela, frutas secas',
    'Alecrim e canela para o banho',
    'Bebida quente para compartilhar',
  ],
  'sabbat_imbolc': [
    'Vela branca, amarela ou vermelha',
    'Vassoura (ritual ou comum)',
    'Incenso de lavanda ou camomila',
    'Sementes ou papel para intenções',
    'Leite e mel (para o banho, opcional)',
  ],
  'sabbat_ostara': [
    'Flores frescas e sementes',
    'Ovos (ou pedrinhas) e tintas',
    'Velas branca e preta',
    'Saquinho, manjericão, hortelã e uma moeda',
  ],
  'sabbat_beltane': [
    'Flores vermelhas e coloridas',
    'Velas vermelhas',
    'Mel, leite ou flores para oferenda',
    'Papel e caneta para a carta de amor',
    'Quartzo rosa (opcional)',
  ],
  'sabbat_litha': [
    'Ervas para colher ou secar (camomila, lavanda)',
    'Sal ou alecrim para o círculo',
    'Cristais e amuletos para carregar',
    'Frutas frescas e flores amarelas',
  ],
  'sabbat_lammas': [
    'Pão (assado ou comprado)',
    'Palha de milho ou papel para a boneca',
    'Papel e caneta para a lista de conquistas',
    'Alimentos para doar',
  ],
  'sabbat_mabon': [
    'Maçãs, uvas, nozes, abóbora',
    'Papel e caneta para o balanço',
    'Velas laranja ou marrom',
    'Potes para conservas ou chás',
  ],
  'full_moon': [
    'Vela branca ou prateada',
    'Jarra ou garrafa com tampa (água de lua)',
    'Cristais, joias e instrumentos para carregar',
    'Tarô, runas ou pêndulo (opcional)',
  ],
  'new_moon': [
    'Uma vela',
    'Papel e caneta',
    'Incenso (opcional)',
    'Uma semente ou vasinho (opcional)',
  ],
  'moon_water': [
    'Jarra, garrafa ou pote de vidro com tampa',
    'Água (potável, se for beber)',
    'Etiqueta ou fita para rotular',
  ],
  'sun_water': [
    'Pote ou garrafa de vidro transparente com tampa',
    'Água (potável, se for beber)',
    'Etiqueta ou fita para rotular',
  ],
};

const Map<String, List<String>> guidedRitualUsesPt = {
  'moon_water': [
    'Beber para absorver a energia lunar (se a água for potável)',
    'Usar em feitiços e poções no lugar de água comum',
    'Adicionar ao banho para limpeza e intuição',
    'Regar plantas para fortalecê-las',
    'Limpar cristais e instrumentos mágicos',
    'Borrifar nos ambientes para renovar a energia',
  ],
  'sun_water': [
    'Beber pela manhã para vitalidade (se a água for potável)',
    'Usar em feitiços de energia, coragem e sucesso',
    'Adicionar ao banho antes de desafios importantes',
    'Borrifar no ambiente de trabalho ou estudo',
    'Regar plantas que amam sol',
  ],
};

/// Correspondências dos rituais que não são de sabbat (sabbats reusam a Roda
/// do Ano).
const Map<String, List<String>> guidedRitualCrystalsPt = {
  'full_moon': ['Selenita', 'Pedra da lua', 'Quartzo transparente', 'Ametista'],
  'new_moon': ['Obsidiana', 'Turmalina negra', 'Labradorita', 'Ônix'],
  'moon_water': ['Selenita', 'Pedra da lua', 'Quartzo transparente'],
  'sun_water': ['Citrino', 'Olho de tigre', 'Âmbar', 'Cornalina'],
};

const Map<String, List<String>> guidedRitualHerbsPt = {
  'full_moon': ['Artemísia', 'Jasmim', 'Lavanda', 'Camomila'],
  'new_moon': ['Sálvia', 'Alecrim', 'Hortelã'],
  'moon_water': ['Jasmim', 'Artemísia', 'Lavanda'],
  'sun_water': ['Alecrim', 'Camomila', 'Calêndula', 'Girassol (pétalas)'],
};
