import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trilha 'aguas_magicas' — conteúdo em português (idioma-base).
/// Paridade com _en/_es verificada em test/trails_parity_test.dart.
const LearningTrail aguasMagicasTrailPt = LearningTrail(
    id: 'aguas_magicas',
    emoji: '💧',
    title: 'Águas Mágicas',
    subtitle: 'Lua, Sol, chuva, mar e rio no seu caldeirão',
    description:
        'Cada água carrega uma memória e um poder diferente: aprenda a colher, preparar e usar as águas da natureza — escrevendo o seu próprio livro das águas',
    lessons: [
      TrailLesson(
        id: 'am_01',
        recordKind: LessonRecordKind.note,
        title: 'A água na bruxaria',
        teaching:
            'A água é a grande condutora da magia: ela dissolve, guarda, leva e devolve. Em quase toda tradição de bruxaria ela aparece nos três papéis essenciais — limpar o que pesa, carregar a intenção e selar o trabalho. Antes de conhecer as águas uma a uma, vale entender por que esse elemento é tão central: a água toca tudo, atravessa tudo e muda de forma sem perder a essência\n\nAs tradições dizem que a água tem memória: ela absorve a energia do lugar de onde veio e do momento em que foi colhida. É por isso que a água da chuva não serve para o mesmo trabalho que a água do mar, e a água colhida sob a lua cheia não é a mesma colhida ao meio-dia. Colher água é colher um momento — e é essa a arte que esta trilha ensina\n\nNo cotidiano, a bruxa das águas trabalha com o que tem: a torneira também é água, e pode ser abençoada. Mas as águas especiais — de lua, de sol, de chuva, de tempestade, do mar, de rio — são reservas de energia concentrada para os trabalhos que pedem mais força. A regra de ouro desde já: rotule sempre os seus frascos com o tipo de água e a data da colheita\n\nGuarde esta imagem: cada frasco de água na sua prateleira é um momento engarrafado. Nesta trilha você vai aprender a colher cada um deles, a saber para que servem e como descartá-los com respeito. Sua primeira página é o inventário do que você já tem — e do que quer colher',
        practice:
            'Faça hoje o seu inventário das águas. Primeiro, observe: que águas passam pela sua vida — chuva na janela, um rio no caminho, o mar perto ou longe? Depois separe 2 ou 3 frascos de vidro limpos, lave bem e deixe secar. Por fim, escreva em etiquetas o nome das primeiras águas que quer colher. O objetivo é preparar o terreno: a bruxa das águas começa organizando seus frascos',
        pageTitle: 'Meu Livro das Águas',
        pagePurpose: 'Abrir o inventário das minhas águas mágicas',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Frascos de vidro', 'Etiquetas'],
        pagePrompts: [
          'Águas que existem perto de mim:',
          'Frascos que preparei:',
          'A primeira água que quero colher e por quê:',
          'Onde vou guardar meu estoque:',
        ],
      ),
      TrailLesson(
        id: 'am_02',
        recordKind: LessonRecordKind.note,
        title: 'Água lunar',
        teaching:
            'A água de lua é a mais clássica das águas mágicas: água limpa deixada sob a luz da lua cheia para absorver o auge do poder lunar. Ela carrega as qualidades da Lua — intuição, emoção, mistério, limpeza suave — e por isso é a água preferida para consagrar instrumentos, abençoar objetos e preparar banhos de purificação delicados\n\nA colheita tradicional é simples: um recipiente de vidro com água potável, exposto ao luar da noite de lua cheia (janela ou céu aberto), recolhido antes do sol nascer. O sol da manhã "queima" a energia lunar — por isso o horário importa. Na página da Lua da Enciclopédia existe um ritual guiado passo a passo da Água de Lua: use-o na próxima lua cheia como prática desta lição\n\nUsos consagrados: limpar cristais e baralhos (os que aceitam água), ungir velas antes de feitiços de intuição e sonho, adicionar um pouco ao banho para dissolver pesos emocionais, regar levemente plantas de trabalhos lunares e abençoar espelhos e vidros de adivinhação. Algumas gotas bastam — a água de lua é concentrada por natureza\n\nGuarde no escuro, em frasco rotulado com a data e, se quiser, o nome da lua (Lua do Lobo, Lua das Flores...). A validade é o próximo ciclo: ao chegar a nova lua cheia, devolva a água antiga à terra com gratidão e colha uma nova. Água de lua não se acumula — se renova',
        practice:
            'Programe a sua colheita: descubra no Seu Dia quando é a próxima lua cheia e deixe o frasco preparado desde já. Se a lua cheia for hoje ou amanhã, siga o ritual guiado da Água de Lua na página da Lua da Enciclopédia. Se ainda falta tempo, pratique a segunda parte: escolha desde já QUAL será o primeiro uso da sua água de lua — um banho, uma limpeza de cristal, uma unção de vela — e escreva o passo a passo na sua página',
        pageTitle: 'Minha Água de Lua',
        pagePurpose: 'Registrar a colheita e os usos da minha água lunar',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Frasco de vidro', 'Água potável', 'Luz da lua cheia'],
        pagePrompts: [
          'Data e lua da minha colheita:',
          'Como foi a noite (céu, sensações):',
          'O primeiro uso que farei dela:',
          'O que senti ao usar:',
        ],
      ),
      TrailLesson(
        id: 'am_03',
        recordKind: LessonRecordKind.note,
        title: 'Água solar',
        teaching:
            'Se a água de lua acalma e aprofunda, a água solar desperta e fortalece. Ela é água carregada sob a luz direta do Sol — de preferência na manhã de um domingo, dia solar, ou em um sabbat de sol como Litha — e concentra vitalidade, coragem, alegria e força de realização. É a água dos recomeços com energia\n\nA colheita é o espelho da lunar: recipiente de vidro com água potável exposto ao sol da manhã por 2 a 4 horas. O sol do meio-dia é forte demais para alguns trabalhos delicados; o da manhã é vitalidade pura. Na página do Sol da Enciclopédia há um ritual guiado completo da Água Solar — ele é a prática ideal desta lição\n\nUsos consagrados: borrifar nos cantos da casa para espantar estagnação, ungir velas de trabalhos de coragem e prosperidade, adicionar ao balde de limpar o chão para renovar a energia do lar, e um gole simbólico (de água limpa e fresca) antes de um dia que pede força. Atenção com cristais: alguns desbotam ao sol — carregue na água solar apenas os que aceitam luz, como citrino e cornalina\n\nÁgua solar pede uso rápido: colheu, usou. A tradição diz que ela guarda o calor por poucos dias — depois disso, regue uma planta com ela e colha de novo. Rotule com a data e o dia da semana: uma água solar de domingo é a mais solar de todas',
        practice:
            'Colha a sua primeira água solar nesta semana: manhã de céu aberto, frasco de vidro, 2 a 4 horas de sol direto. Se possível, siga o ritual guiado da Água Solar na página do Sol da Enciclopédia. Depois use no mesmo dia: borrife nos cantos do cômodo em que você mais vive, pedindo em voz baixa que a vitalidade circule. Anote na página o que mudou no ambiente e em você',
        pageTitle: 'Minha Água Solar',
        pagePurpose: 'Registrar a colheita e os usos da minha água solar',
        pageCategory: SpellCategory.energy,
        pageIngredients: ['Frasco de vidro', 'Água potável', 'Sol da manhã'],
        pagePrompts: [
          'Dia e horário da minha colheita:',
          'Como usei a água no mesmo dia:',
          'O que senti de diferente no ambiente:',
          'Para que quero a próxima colheita:',
        ],
      ),
      TrailLesson(
        id: 'am_04',
        recordKind: LessonRecordKind.note,
        title: 'Água de chuva',
        teaching:
            'A água de chuva é a bênção que cai do céu de graça: água de crescimento, renovação e fertilidade dos trabalhos. Ela vem "de cima", e as tradições a associam à purificação natural — a chuva lava o mundo — e ao crescimento, porque é ela que faz brotar. É uma das águas mais versáteis do livro da bruxa\n\nColheita: um recipiente limpo de vidro ou cerâmica em local aberto — nunca debaixo de telhado ou calha, que contaminam a água e a intenção. A chuva do início da tempestade é considerada a mais potente; a chuva mansa de um dia inteiro carrega constância e paciência. Deixe a natureza encher o frasco no ritmo dela\n\nUsos consagrados: regar plantas de feitiços e da enciclopédia pessoal (elas amam), lavar as mãos antes de um trabalho de crescimento, adicionar a banhos de renovação depois de ciclos difíceis e umedecer sementes — literais ou simbólicas — plantadas em lua nova. A água de chuva é a parceira natural dos trabalhos de prosperidade que precisam CRESCER devagar e firme\n\nComo não é potável, água de chuva não se bebe — uso externo e ritual apenas. Guarde rotulada ("chuva mansa", "chuva de março") e renove quando o cheiro mudar. Devolva a antiga às plantas: o que veio do céu volta para a terra',
        practice:
            'Na próxima chuva, coloque um recipiente limpo em local totalmente aberto e deixe colher. Enquanto chove, fique um minuto na janela observando: que tipo de chuva é essa — lavagem, alívio, crescimento? Nomeie a água pelo que sentiu. Depois use metade regando uma planta querida com intenção de crescimento e guarde a outra metade rotulada para o próximo trabalho',
        pageTitle: 'Minha Água de Chuva',
        pagePurpose: 'Registrar a colheita e os usos da água de chuva',
        pageCategory: SpellCategory.prosperity,
        pageIngredients: ['Recipiente limpo', 'Chuva', 'Local aberto'],
        pagePrompts: [
          'Data e o "tipo" da chuva que colhi:',
          'O nome que dei a esta água:',
          'A planta ou trabalho que ela regou:',
          'O que quero que cresça com ela:',
        ],
      ),
      TrailLesson(
        id: 'am_05',
        recordKind: LessonRecordKind.note,
        title: 'Água de tempestade',
        teaching:
            'A água de tempestade é a irmã selvagem da água de chuva: colhida durante trovoadas e ventanias, ela carrega potência bruta — quebra de bloqueios, coragem, força para virar o jogo. É uma água de respeito, usada em pequenas doses nos trabalhos que pedem um empurrão que a água mansa não dá\n\nColheita com segurança em primeiro lugar: o recipiente vai para o local aberto ANTES da tempestade ou entre as pancadas — nunca fique ao relento sob raios. A bruxa esperta prepara o frasco quando o céu escurece e recolhe quando o tempo acalma. A tradição diz que quanto mais forte o trovão durante a colheita, mais "carregada" a água\n\nUsos consagrados: ungir velas de trabalhos de banimento e quebra de demanda, lavar (poucas gotas) amuletos que precisam de força extra, adicionar uma colher ao balde de limpeza pesada da casa depois de brigas ou visitas difíceis, e tocar com o dedo molhado a própria testa antes de uma conversa que exige coragem. Pouca quantidade, muita intenção\n\nEssa água não é para o dia a dia: guarde um frasco pequeno, bem rotulado ("tempestade de janeiro"), longe das águas mansas. Quando o trabalho terminar, descarte na terra, agradecendo a força emprestada. Tempestade que cumpriu o papel não se guarda por nostalgia',
        practice:
            'Prepare o seu "kit de tempestade" hoje, mesmo com céu limpo: um frasco pequeno, etiqueta escrita e um lugar definido fora de casa para colocá-lo quando o tempo virar. Ensaie o gesto: onde exatamente o frasco fica, por onde você o recolhe sem se molhar sob raios. Na próxima trovoada, colha com segurança e anote na página o que a tempestade parecia querer quebrar',
        pageTitle: 'Minha Água de Tempestade',
        pagePurpose: 'Registrar a colheita e os usos da água de tempestade',
        pageCategory: SpellCategory.banishing,
        pageIngredients: ['Frasco pequeno', 'Tempestade', 'Cautela'],
        pagePrompts: [
          'Data e força da tempestade:',
          'Como colhi com segurança:',
          'O bloqueio que quero quebrar com ela:',
          'Como e onde descartei depois do uso:',
        ],
      ),
      TrailLesson(
        id: 'am_06',
        recordKind: LessonRecordKind.note,
        title: 'Água do mar',
        teaching:
            'A água do mar é o grande caldeirão do planeta: salgada, viva e implacável com o que não serve. O sal a torna a água mais poderosa para limpeza pesada, banimento e proteção — o mar leva embora o que a gente entrega a ele. É a água das faxinas espirituais de verdade\n\nColheita: no mar, com os pés na areia, de preferência agradecendo a Iemanjá ou à divindade do mar da sua tradição — colher água é receber um presente, não pegar. Longe do mar? A tradição aceita o substituto honesto: água limpa com sal grosso dissolvido, consagrada com a intenção do oceano. Não é igual, mas trabalha\n\nUsos consagrados: limpeza pesada de objetos que chegaram "carregados" (os que aceitam sal), banhos de descarrego do pescoço para baixo, lavar a soleira da porta em casa que recebeu energia ruim, e círculos de proteção traçados com água salgada nos cantos do cômodo. Atenção: sal corrói metais e resseca plantas — nunca use água do mar em cristais delicados, instrumentos de metal ou no vaso das suas ervas\n\nO descarte é parte do rito: água salgada usada em limpeza não volta para as plantas — vai para o ralo com agradecimento, levando junto o que capturou. Guarde pouca, use logo, e sempre que puder, renove na fonte: uma ida ao mar é, por si só, o maior banho de limpeza que existe',
        practice:
            'Se o mar está ao seu alcance, vá até ele esta semana: molhe os pés, agradeça, colha um frasco pequeno e deixe uma oferenda simples e biodegradável (uma flor). Se não está, prepare o substituto: dissolva sal grosso em água limpa nomeando a intenção do oceano. Depois faça uma limpeza pequena e real — a maçaneta, a soleira, um objeto pesado — e sinta a diferença da água salgada',
        pageTitle: 'Minha Água do Mar',
        pagePurpose: 'Registrar a colheita e os usos da água do mar',
        pageCategory: SpellCategory.protection,
        pageIngredients: ['Frasco', 'Água do mar (ou água + sal grosso)'],
        pagePrompts: [
          'De onde veio a minha água (mar ou preparo):',
          'O que agradeci/ofereci ao colher:',
          'A limpeza que fiz com ela:',
          'O que o mar levou embora:',
        ],
      ),
      TrailLesson(
        id: 'am_07',
        recordKind: LessonRecordKind.note,
        title: 'Água de rio',
        teaching:
            'O rio é movimento que nunca para: a água de rio carrega desbloqueio, fluidez e a arte de "deixar ir". Enquanto o mar arranca, o rio conduz — ele leva embora com suavidade o que estagna, e por isso é a água dos trabalhos de destravar caminhos, soltar o que prende e retomar o fluxo da vida\n\nColheita: em rio corrente e o mais limpo possível, sempre da água que se move — nunca de poças paradas na margem. A tradição pede licença ao rio antes (cada rio tem dono, espírito ou nome) e recomenda colher a favor da correnteza, deixando as mãos sentirem o movimento. Uma moeda ou flor entregue à água paga a passagem\n\nUsos consagrados: lavar as mãos ao encerrar um ciclo (um trabalho, um relacionamento, um luto), ungir os pés antes de caminhos novos — entrevista, mudança, viagem —, borrifar em documentos e projetos parados para destravá-los, e o rito clássico do rio: entregar à correnteza uma folha com o que você quer soltar, escrita a lápis, e vê-la partir\n\nÁgua de rio também não se bebe — uso ritual externo. Guarde pouca e com rótulo ("rio tal, colhida em..."), e prefira sempre a água fresca: o poder do rio está no movimento, e água de rio parada há meses virou o contrário do que era. Na dúvida, vá ao rio de novo — o caminho até ele já é parte do feitiço',
        practice:
            'Encontre a água que se move perto de você — rio, riacho, córrego limpo ou até uma fonte corrente. Peça licença, colha um pouco e faça na hora o rito da folha: escreva a lápis uma coisa que precisa fluir ou ir embora, dobre e entregue à correnteza observando até sumir. Em casa, use algumas gotas nos pés antes do próximo caminho novo que a vida pedir',
        pageTitle: 'Minha Água de Rio',
        pagePurpose: 'Registrar a colheita e os usos da água de rio',
        pageCategory: SpellCategory.cleansing,
        pageIngredients: ['Frasco', 'Água de rio corrente'],
        pagePrompts: [
          'O rio (ou água corrente) que encontrei:',
          'O que entreguei à correnteza:',
          'O caminho que quero destravar:',
          'O que senti quando a folha partiu:',
        ],
      ),
      TrailLesson(
        id: 'am_08',
        recordKind: LessonRecordKind.note,
        title: 'Orvalho, nascente e outras águas raras',
        teaching:
            'Antes de fechar o livro, as águas raras — as que não se colhem quando se quer, mas quando a natureza oferece. O orvalho, colhido de manhãzinha passando um pano limpo pelas folhas ou deixando uma tigela na relva durante a noite, é a água da beleza, da juventude e dos começos delicados. A tradição manda lavar o rosto com orvalho no primeiro dia de maio, e gotas dele abençoam qualquer trabalho de amor-próprio\n\nA água de nascente ou fonte é pureza em estado bruto: água que nasce da terra, ideal para consagrações, bênçãos e para "batizar" instrumentos novos. Se houver uma fonte natural no seu caminho, ela vale a viagem — a água colhida na própria nascente, com licença pedida, é das mais preciosas do estoque de uma bruxa\n\nA água de poço, funda e guardada na escuridão da terra, serve aos trabalhos de mistério, segredo e ancestralidade — é a água das perguntas antigas. E o gelo derretido, a água de degelo, carrega o poder das transições lentas: ótima para descongelar, gota a gota, situações travadas há muito tempo. Até a neblina colhida num pano tem nome nas tradições: água do véu, para trabalhos de discrição\n\nO que essas águas têm em comum: não se planejam, se recebem. A bruxa das águas anda com um frasco vazio na bolsa e os olhos abertos — quando a natureza oferece uma água rara, ela agradece e colhe. Sua página desta lição é o mapa das águas raras possíveis na sua vida',
        practice:
            'Faça o seu mapa das águas raras: pense na sua rotina e na sua região e liste onde poderia colher orvalho (um jardim, um parque de manhã), nascente (alguma fonte natural conhecida?), poço ou degelo. Se possível, colha orvalho amanhã cedo com um pano limpo e passe no rosto nomeando um começo delicado que você quer para si. Anote na página o que já é possível hoje e o que fica como promessa',
        pageTitle: 'Meu Mapa das Águas Raras',
        pagePurpose: 'Mapear as águas raras ao meu alcance',
        pageCategory: SpellCategory.selfLove,
        pageIngredients: ['Pano limpo', 'Frasco pequeno', 'Atenção'],
        pagePrompts: [
          'Onde posso colher orvalho:',
          'Nascentes ou fontes que conheço:',
          'A água rara que quero colher um dia:',
          'O começo delicado que nomeei para mim:',
        ],
      ),
      TrailLesson(
        id: 'am_09',
        recordKind: LessonRecordKind.note,
        title: 'O descarte sagrado e o seu estoque',
        teaching:
            'A última lição é a arte que ninguém ensina: o descarte. Toda água mágica tem destino certo, e devolvê-la bem é tão importante quanto colhê-la bem — o ciclo só se completa quando a água volta para o mundo. Uma água esquecida no fundo do armário não é reserva: é trabalho inacabado\n\nA regra geral: águas doces e limpas (lua, sol, chuva, orvalho, nascente) voltam para a terra — regue plantas, devolva ao jardim, entregue a um canteiro. Águas de trabalho pesado (sal, tempestade usada em banimento, água de limpeza que "capturou" algo) vão para o ralo ou para a terra longe das plantas, sempre com agradecimento pelo serviço prestado\n\nE a regra de ouro dos templos: nunca jogue água de trabalho em rio ou mar limpos. Eles não são lixeira — são a fonte. O que se devolve à natureza deve voltar limpo ou neutro; o que carrega descarte vai pelo caminho da casa (ralo, terra distante). A bruxa que respeita as águas é respeitada por elas\n\nSeu estoque ideal é pequeno e vivo: poucos frascos, todos rotulados com tipo e data, renovados a cada ciclo. A bruxa das águas não coleciona — colhe, usa, agradece e devolve. Com o inventário da primeira lição e as águas de toda a trilha, o seu livro das águas está aberto: ele cresce a cada chuva, a cada lua e a cada maré da sua vida',
        practice:
            'Feche o ciclo da trilha com uma revisão completa do seu estoque: reúna todos os frascos que colheu, confira rótulos e datas, e decida o destino de cada um — usar esta semana, renovar ou devolver à terra com gratidão. Faça pelo menos um descarte sagrado hoje, do jeito certo para o tipo de água. Registre na página o estado final do seu livro das águas',
        pageTitle: 'O Fechamento do Meu Livro das Águas',
        pagePurpose: 'Revisar meu estoque e os destinos de cada água',
        pageCategory: SpellCategory.wisdom,
        pageIngredients: ['Meus frascos', 'Etiquetas', 'Gratidão'],
        pagePrompts: [
          'As águas que tenho hoje (tipo e data):',
          'O que devolvi à terra e por quê:',
          'Como ficou meu estoque final:',
          'O que as águas me ensinaram até aqui:',
        ],
      ),
    ]);
