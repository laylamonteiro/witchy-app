import '../../../../grimoire/data/models/spell_model.dart';
import '../../models/trail_model.dart';

/// Trilha 'magia_do_caos' — conteúdo em português (idioma-base).
/// Paridade com _en/_es verificada em test/trails_parity_test.dart.
const LearningTrail magiaDoCaosTrailPt = LearningTrail(
    id: 'magia_do_caos',
    emoji: '🌀',
    title: 'Magia do Caos',
    subtitle: 'Nada é verdade, tudo é permitido criar',
    description:
        'A magia como tecnologia experimental: crença como ferramenta, sigilos, resultados mensuráveis e zero dogma. Você é o laboratório',
    lessons: [
      TrailLesson(
        id: 'mc_01',
        recordKind: LessonRecordKind.note,
        title: 'Crença como ferramenta',
        teaching:
            'O axioma central da magia do caos afirma que a crença não é a verdade: é o instrumento. Se acreditar em algo produz o resultado desejado, o praticante veste essa crença como um casaco, trabalha com ela e depois a pendura. Essa virada importa porque devolve o poder a você: em vez de esperar encontrar a fé perfeita, você aprende a escolher e operar crenças de propósito\n\nIsso não é cinismo: é levar a crença tão a sério a ponto de usá-la deliberadamente. A magia do caos nasceu no espírito pós-moderno, herdeira de Austin Osman Spare, e trata cada sistema como um mapa útil, nunca como o território. Um dia você opera como animista, no outro como cética metódica: o que conta é o efeito que cada lente produz na sua percepção e nos seus resultados\n\nNo cotidiano de quem inicia, isso vira experimento: adotar por um período uma crença escolhida e observar o que muda em decisões, postura e oportunidades. Prefira crenças úteis e testáveis, uma de cada vez, e anote os efeitos. O erro comum é o meio-termo morno: acreditar pela metade não gera dados. Vista a crença por inteiro durante o teste e tire-a por inteiro depois\n\nLeve com você a imagem do casaco: crenças são vestimentas de trabalho, não tatuagens. Você pode trocá-las conforme a tarefa, sem culpa e sem se perder, porque quem escolhe é você. Bem-vinda ao laboratório: aqui, acreditar é uma técnica — e toda técnica se aprende com prática e paciência',
        practice:
            'Você vai testar a crença como ferramenta. Primeiro, escolha uma crença útil, afirmativa e testável, como: as pessoas gostam de me ajudar. Depois, viva 24 horas como se ela fosse absolutamente verdadeira, agindo em coerência total com ela. Por fim, anote o que mudou em você e ao seu redor. O objetivo é sentir na pele que uma crença vestida de propósito altera percepção, atitude e resultados',
        pageTitle: 'Experimento: Crença de 7 Dias',
        pagePurpose: 'Testar a crença como ferramenta',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'A crença adotada (afirmativa, testável):',
          'Critério de sucesso (como sei que funcionou):',
          'Diário dos 7 dias (uma linha por dia):',
          'Veredito do experimento:',
        ],
      ),
      TrailLesson(
        id: 'mc_02',
        recordKind: LessonRecordKind.sigil,
        title: 'Sigilos: o desejo criptografado',
        teaching:
            'O sigilo é o desejo criptografado: um símbolo que carrega sua intenção sem que a mente consciente consiga lê-la. Criado por Austin Osman Spare, o método transforma uma frase de desejo em um glifo abstrato. Ele importa porque resolve o maior sabotador da magia: a ansiedade de quem fica vigiando o resultado e, sem querer, o afasta\n\nO processo de Spare tem três atos: escrever o desejo, eliminar as letras repetidas e fundir as restantes num desenho único. Depois vem o passo decisivo: lançar o glifo no inconsciente através de um estado alterado, o gnosis — exaustão, dança, olhar fixo — e então esquecer. O esquecimento não é detalhe: a mente ansiosa sabota, enquanto o inconsciente, livre de vigilância, trabalha em silêncio\n\nPara quem inicia, o desafio prático é a formulação do desejo: frases afirmativas, no presente, sem negações. A ferramenta de Sigilos do app monta o glifo por você, o que libera sua energia para o que importa: o lançamento e o esquecimento. O erro mais comum é revisitar o sigilo toda hora para conferir se funcionou. Lançou, esqueceu: distraia-se de verdade e deixe a semente germinar no escuro\n\nGuarde esta chave: o sigilo funciona na medida em que você solta. Desejar, criptografar, lançar, esquecer — quatro gestos simples que treinam a arte mais difícil da magia, que é confiar no que não se vê. Seu inconsciente é um aliado competente: entregue o pedido e saia da frente dele',
        practice:
            'Você vai criar e lançar seu primeiro sigilo. Abra a ferramenta do app em Ferramentas, escolha Sigilos e escreva seu desejo em frase afirmativa: o glifo será gerado para você. Antes de ativar, defina seu método de gnosis, como dança até o cansaço ou olhar fixo numa vela. Ative o sigilo nesse estado, depois destrua ou guarde o desenho e distraia-se. O objetivo é completar o ciclo inteiro: desejar, criptografar, lançar e esquecer',
        pageTitle: 'Meu Primeiro Sigilo Lançado',
        pagePurpose: 'Registrar o método completo de sigilização',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Frase do desejo (escreva e risque depois!):',
          'Método de gnosis usado:',
          'Como destruí/esqueci o sigilo:',
          '(Em 1 mês) Resultados observados:',
        ],
      ),
      TrailLesson(
        id: 'mc_03',
        recordKind: LessonRecordKind.note,
        title: 'Gnosis: os portais do transe',
        teaching:
            'Gnosis é o estado em que a mente crítica silencia e o comando mágico passa direto ao fundo da psique. É o momento de abertura de que toda operação precisa: sem ele, a intenção fica presa na camada tagarela do pensamento. Conhecer seus próprios caminhos até esse estado é infraestrutura mágica básica, tão essencial quanto o próprio desejo que você quer lançar\n\nA tradição caóta divide os portais em duas vias. A excitatória sobe: dança, tambor, hiperventilação leve, clímax — o corpo acelera até a mente soltar o leme. A inibitória desce: imobilidade, jejum curto, olhar fixo, silêncio absoluto — o mundo desacelera até restar só o foco. Nenhuma via é superior; cada pessoa tem seus portais naturais, e descobri-los é um trabalho de mapeamento pessoal\n\nComece pelo que seu corpo já conhece: quem dança com facilidade tende à via excitatória; quem medita, à inibitória. Teste em sessões curtas, com segurança e sem substâncias — o corpo já tem tudo o que precisa. O erro comum é forçar intensidade: gnosis não é desmaio, é o instante em que o mundo afina. Registre cada teste e respeite seus limites físicos sempre\n\nLeve consigo a ideia do portal: gnosis não é um lugar distante, é uma porta que seu próprio corpo sabe abrir. Com prática, você aprende a alcançá-la em poucos minutos, e cada operação mágica ganha profundidade. Mapear seus estados alterados é conhecer a chave da sua própria casa',
        practice:
            'Você vai testar um portal inibitório hoje. Acenda uma vela num ambiente calmo, sente-se confortável e sustente o olhar fixo na chama por 5 minutos, sem forçar as pálpebras, deixando a respiração desacelerar. Perceba o momento em que o mundo parece afinar e os pensamentos se espaçam. Ao terminar, anote as sensações. O objetivo é reconhecer no corpo o gosto do gnosis para usá-lo depois nas suas operações',
        pageTitle: 'Meu Mapa de Gnosis',
        pagePurpose: 'Mapear meus estados alterados seguros',
        pageCategory: SpellCategory.energy,
        pagePrompts: [
          'Métodos excitatórios que funcionam em mim:',
          'Métodos inibitórios que funcionam em mim:',
          'Meus limites de segurança:',
          'O portal que vou dominar primeiro:',
        ],
      ),
      TrailLesson(
        id: 'mc_04',
        recordKind: LessonRecordKind.note,
        title: 'O diário de resultados',
        teaching:
            'O diário de resultados é o que separa o caóta do místico de sofá: um registro fiel de cada operação com data, técnica, estado e desfecho. Sem ele, a memória trapaceia — todo sucesso é lembrado, todo fracasso convenientemente esquecido — e você não aprende nada. Com ele, sua magia vira um laboratório de verdade, com histórico e evolução visível\n\nA magia do caos se define como tecnologia experimental, e experimento sem dados não existe. O registro transforma impressões vagas em padrões visíveis: qual técnica rende mais, em que estado você opera melhor, quanto tempo os efeitos levam. É o mesmo espírito que guiou Spare e os caótas modernos: resultados mensuráveis acima de teorias bonitas, zero dogma e revisão constante\n\nNa prática, crie um template curto e use-o sempre: data, operação, técnica, estado interno, resultado e uma nota de confiança. Revise em ciclos fixos, semanais ou lunares. O erro clássico é registrar só quando dá certo, ou maquiar o fracasso com desculpas. Seja impiedosa com a autoilusão e gentil com o processo: fracasso é dado precioso, não vergonha\n\nGuarde esta máxima: o que não se registra, não se aprende. Seu diário é o instrumento mais poderoso do laboratório, porque transforma cada tentativa — boa ou má — em degrau. A honestidade de hoje no papel se converte em maestria amanhã na prática, e ninguém pode fazer esse trabalho por você',
        practice:
            'Você vai auditar seus experimentos até aqui. Releia os registros das lições anteriores — a crença de 24 horas, o sigilo, os testes de gnosis — e avalie cada um com honestidade brutal: o que funcionou de fato, o que foi coincidência, o que foi viés de confirmação. Depois, monte seu template fixo de registro para as próximas operações. O objetivo é fundar seu diário de resultados sobre dados limpos, não sobre desejos',
        pageTitle: 'Meu Protocolo de Registro',
        pagePurpose: 'Sistematizar o diário de resultados',
        pageCategory: SpellCategory.study,
        pagePrompts: [
          'O que registro em toda operação (meu template):',
          'Quando reviso (semanal? lunar?):',
          'Minha escala de resultados:',
          'Primeira revisão: aprendizados:',
        ],
      ),
      TrailLesson(
        id: 'mc_05',
        title: 'Servidores: criaturas de propósito',
        teaching:
            'O servidor é um programa psíquico: uma entidade criada por você para cumprir uma única função, como lembrar, proteger ou encontrar. Diferente de espíritos herdados de tradições, ele nasce do seu desenho consciente. A técnica importa porque ensina, em escala pequena e segura, como a atenção dá vida e forma às construções da mente\n\nA construção segue uma receita clara: o servidor recebe nome, forma visual, uma função única e bem delimitada, um alimento simbólico — atenção diária, um gesto, um símbolo — e, ponto crucial, uma data de desligamento. Na visão caóta, pouco importa se ele é um ser real ou um mecanismo psicológico: se cumpre a função e responde ao protocolo, é tecnologia funcionando\n\nPara quem inicia, o segredo é a modéstia: um servidor para uma tarefa concreta da semana, não um guardião cósmico. Escreva a função em uma frase; se precisar de duas, são dois servidores. Alimente-o no horário combinado e observe. O erro comum é criar e abandonar: entidade esquecida vira ruído. Trate como criação responsável, com manutenção e aposentadoria digna\n\nLeve esta imagem: o servidor é um aplicativo que você instala na própria psique — propósito claro, consumo definido, prazo de validade. Criar, manter e desligar com respeito é um ciclo completo de responsabilidade mágica. Comece pequeno e aprenda o ofício de dar forma ao invisível',
        practice:
            'Você vai projetar seu primeiro servidor. Escolha uma tarefa concreta desta semana, como lembrar de beber água. Esboce a criatura em desenho ou texto: defina nome, forma, a função única em uma frase, o alimento simbólico e a data exata de desligamento. Apresente-o mentalmente à tarefa e alimente-o uma vez por dia. O objetivo é experimentar o ciclo completo de criar, manter e desligar uma entidade de propósito',
        pageTitle: 'Meu Primeiro Servidor',
        pagePurpose: 'Criar uma entidade de propósito único',
        pageCategory: SpellCategory.other,
        pagePrompts: [
          'Nome, forma e função ÚNICA:',
          'Como o alimento (atenção, gesto, símbolo):',
          'Data e rito de desligamento:',
          'Resultados da primeira semana:',
        ],
      ),
      TrailLesson(
        id: 'mc_06',
        recordKind: LessonRecordKind.rune,
        title: 'Troca de paradigma',
        teaching:
            'A troca de paradigma é o exercício-rei da magia do caos: viver um período inteiro dentro de outro sistema de crenças — uma semana como animista, outra como cética radical, outra como devota. Não se trata de zombar nem de fingir por fora: trata-se de experimentar o sistema de dentro, com as regras, os olhos e os gestos de quem realmente acredita\n\nA prática nasce da postura pós-moderna do caos: todo paradigma é um mapa, e mapas se trocam conforme a viagem. Ao habitar um sistema estranho, você descobre o que ele revela e o que ele esconde. Um exemplo concreto: passar três dias lendo o mundo através das runas nórdicas, consultando-as nas decisões do dia, mesmo que seu caminho usual seja outro. A imersão gera dados que a leitura de fora jamais daria\n\nPara quem inicia, o formato seguro é curto e delimitado: escolha o paradigma, escreva suas regras de imersão, defina começo e fim, e registre diariamente o que muda na percepção. O erro comum é a imersão pela metade, visitando o sistema como turista apressada. Outro é esquecer a saída: terminado o prazo, encerre com clareza e volte ao seu centro\n\nO prêmio deste exercício é a flexibilidade: quem já morou em várias casas de crença nunca mais confunde a mobília com o mundo. Cada paradigma visitado deixa uma ferramenta na sua bagagem e afrouxa a ilusão de que existe um único jeito certo de ver. Viaje com curiosidade, aprenda e volte mais livre',
        practice:
            'Você vai morar 3 dias num paradigma diferente do seu — por exemplo, o das runas nórdicas. Defina suas regras de imersão, abra a ferramenta de Runas do app em Ferramentas e tire uma runa por dia, deixando a leitura orientar decisões pequenas. Registre a cada noite o que mudou na sua percepção. Ao final, encerre a imersão com clareza. O objetivo é experimentar outro sistema de dentro e ganhar flexibilidade de crença',
        pageTitle: 'Relatório de Troca de Paradigma',
        pagePurpose: 'Experimentar outro sistema de dentro',
        pageCategory: SpellCategory.study,
        pagePrompts: [
          'O paradigma visitado e minhas regras de imersão:',
          'Diário dos dias (o que mudou na percepção):',
          'O que trago de volta comigo:',
          'O que aprendi sobre o MEU paradigma:',
        ],
      ),
      TrailLesson(
        id: 'mc_07',
        recordKind: LessonRecordKind.desire,
        title: 'Magia do resultado: metas operacionais',
        teaching:
            'A magia do resultado é o coração pragmático do caos: magia a serviço de metas reais, com alvo específico, prazo definido e técnica escolhida. Nada de pedidos vagos ao universo: uma operação bem desenhada se parece mais com um projeto do que com uma prece. Isso importa porque tira a magia do terreno da fantasia e a coloca no dos efeitos verificáveis\n\nA marca registrada caóta é a ação mundana casada: todo trabalho mágico vem acompanhado de movimentos concretos no mundo. O feitiço de emprego caminha junto com currículos enviados; o sigilo de saúde, com a consulta marcada. A lógica é de dupla via: a magia abre caminhos e afina a percepção, enquanto a ação garante que exista porta onde o caminho desemboque. Magia sem ação é loteria; ação sem magia é metade do arsenal\n\nNo dia a dia, desenhe operações pequenas e mensuráveis: uma meta de 30 dias, uma técnica, três ações mundanas e um critério claro de sucesso. Anote tudo no diário de resultados. Os erros comuns são metas nebulosas como querer prosperar em geral, prazos infinitos e a tentação de esperar o feitiço agir sozinho enquanto nada se move na vida prática\n\nGrave esta fórmula: alvo claro, prazo real, técnica escolhida e ação casada no mundo. Quando magia e movimento caminham juntos, cada resultado — venha de onde vier — é conquista sua. Você deixa de pedir permissão ao universo e passa a negociar com ele de igual para igual, usando as duas mãos',
        practice:
            'Você vai desenhar uma operação completa de 30 dias. Escolha uma meta real e específica, com prazo. Depois defina a técnica mágica — um sigilo, um servidor, o que seu diário aprovar — e liste 3 ações mundanas casadas que você fará no mesmo período. Registre tudo e marque a data da avaliação. O objetivo é viver a fórmula caóta na íntegra: magia e ação trabalhando juntas por um resultado mensurável',
        pageTitle: 'Operação de 30 Dias',
        pagePurpose: 'Casar magia e ação para uma meta',
        pageCategory: SpellCategory.prosperity,
        pagePrompts: [
          'Meta específica e prazo:',
          'Técnica mágica escolhida:',
          'Minhas 3 ações mundanas casadas:',
          '(No prazo) Resultado e análise:',
        ],
      ),
      TrailLesson(
        id: 'mc_08',
        title: 'Desfazer: o banimento caóta',
        teaching:
            'O banimento é a faxina do laboratório: a técnica que limpa resíduos entre operações, desfaz trabalhos que não serviram e devolve o espaço interno ao estado neutro. Sem ele, restos de intenção, ansiedade e imagens carregadas se acumulam de um rito para outro. Encerrar bem é tão importante quanto começar bem — talvez até mais\n\nA tradição caóta cultiva do riso banidor — gargalhar da própria operação até dissolvê-la por completo — a versões adaptadas do pentagrama ritual. O riso funciona porque quebra a gravidade: nada resiste a uma boa gargalhada, nem mesmo a sua própria solenidade. Mas o critério caóta é um só: o rito precisa funcionar para você. Teste formatos e meça o efeito, como em qualquer técnica\n\nNo cotidiano, banir também é psicológico: fechar as abas mentais do dia, cortar a ruminação, marcar o fim de um ciclo com um gesto físico — palmas, uma palavra, um sopro na vela. Quem inicia costuma pular essa etapa por pressa ou por achá-la pouco importante, e depois carrega a operação na cabeça por dias. Um rito curto e repetido vale mais que um elaborado e esquecido\n\nLeve consigo a regra do laboratório limpo: toda operação merece um fim nítido. Um gesto, uma risada, um corte — e a bancada fica livre para o próximo experimento. Quem sabe encerrar dorme melhor, opera melhor e não confunde o eco de ontem com o sinal de hoje',
        practice:
            'Você vai criar sua primeira faxina energética. Ao final do dia, fique de pé, respire fundo e bata palmas 3 vezes com firmeza. Em seguida, ria alto de tudo o que ficou pendente — deixe a gargalhada dissolver o peso. Sinta o corte entre o que passou e o agora. Repita por alguns dias e anote o efeito no corpo e no sono. O objetivo é instalar um rito simples de banimento que encerre ciclos e limpe o espaço entre operações',
        pageTitle: 'Meu Banimento',
        pagePurpose: 'Criar minha faxina energética',
        pageCategory: SpellCategory.banishing,
        pageType: SpellType.banishment,
        pagePrompts: [
          'Meu rito de banimento (passos):',
          'Quando o uso (entre rituais? diário?):',
          'O riso banidor funcionou? Como foi:',
          'O que percebo depois de banir:',
        ],
      ),
      TrailLesson(
        id: 'mc_09',
        recordKind: LessonRecordKind.oracle,
        title: 'Sincronicidade: surfar o acaso',
        teaching:
            'Para o caóta, a sincronicidade é o feedback do sistema: quando as coincidências começam a se alinhar à sua operação — a música certa, o encontro improvável, a palavra repetida — algo está em curso. Ler esses ecos importa porque eles indicam se a rota está viva, funcionando como o painel de instrumentos do seu voo mágico\n\nO termo vem de Jung: coincidências significativas sem causa comum aparente. A postura caóta é pragmática: a sincronicidade não se força — se surfa. Você registra o eco, agradece e ajusta a rota, sem transformar cada folha caindo em profecia. O acaso também pode ser consultado ativamente: oráculos são geradores de aleatoriedade significativa, convites para o padrão emergir\n\nA armadilha de quem inicia é a apofenia: ver padrão em tudo, sinal em cada placa de rua. O antídoto é o diário de resultados: anote o eco no momento em que ocorre, releia com frieza depois e pergunte se ele apontava algo verificável. Trabalhe com uma pergunta por vez, colete os ecos de um dia inteiro e só então faça a leitura, honesta e sem forçar\n\nGuarde a imagem da surfista: você não cria a onda do acaso, mas aprende a montá-la. Sinal registrado, gratidão breve, rota ajustada — e o diário como quilha para a leitura não virar delírio. O mundo conversa com quem opera; seu trabalho é ouvir com atenção, sem inventar o que não foi dito',
        practice:
            'Você vai lançar uma pergunta ao acaso. De manhã, formule uma questão clara e faça uma consulta na ferramenta de Oráculo do app, em Ferramentas, guardando a resposta como semente. Ao longo do dia, colete os ecos — coincidências, frases, encontros — sem forçar nada. À noite, releia tudo e faça a leitura honesta: sinal ou apofenia? O objetivo é treinar a escuta do acaso com o diário como proteção contra o autoengano',
        pageTitle: 'Diário de Sincronicidades',
        pagePurpose: 'Registrar e ler os ecos do acaso',
        pageCategory: SpellCategory.divination,
        pagePrompts: [
          'Minha pergunta lançada:',
          'Os ecos coletados no dia:',
          'Leitura honesta (sinal ou apofenia?):',
          'Ajuste de rota decidido:',
        ],
      ),
      TrailLesson(
        id: 'mc_10',
        recordKind: LessonRecordKind.note,
        title: 'Construa seu próprio sistema',
        teaching:
            'O destino da magia do caos é a autonomia: depois de testar crenças, técnicas e paradigmas, você monta o seu próprio sistema — pessoal, funcional e revisável. Nenhum grimório alheio conhece seus portais de gnosis, seus símbolos vivos, seu ritmo. Chegar aqui importa porque encerra a fase de seguir mapas e inaugura a fase de desenhá-los\n\nO critério de montagem é experimental: se passa no seu diário de resultados, é seu. Misture sem medo o esbá com sigilos, o benzimento da avó com servidores modernos — a tradição caóta sempre tratou sistemas como caixas de ferramentas, não como igrejas. Os limites são apenas éticos: nada de dano a pessoas ou animais, nada criminoso. O resto — o estranho, o simbólico, o inventado — é matéria-prima legítima\n\nNa prática, comece enxuta: três técnicas centrais comprovadas, seus princípios inegociáveis e uma área de testes para o que ainda está em avaliação. Dê ao sistema um nome e uma data de revisão, como um software que ganha versões. O erro comum é a colcha infinita: acumular técnicas sem nunca podar. Sistema bom é o que você usa de verdade, não o que enfeita o caderno\n\nLeve consigo a ideia da versão 1.0: seu sistema não precisa nascer pronto, precisa nascer seu. Revisável, honesto e vivo, ele crescerá com cada experimento registrado. Nada é verdade, tudo é permitido criar — e a sua magia, a partir de agora, carrega a sua própria assinatura',
        practice:
            'Você vai consolidar seu caminho. Releia todas as suas páginas e registros das trilhas, com calma, e circule o que já funciona como o seu jeito: técnicas que rendem, símbolos que falam, ritmos que sustentam. Depois, organize o essencial em três técnicas centrais, seus princípios e uma lista do que segue em teste. Marque a data da primeira revisão. O objetivo é transformar a experiência acumulada no seu sistema mágico versão 1.0.',
        pageTitle: 'Meu Sistema Mágico v1.0',
        pagePurpose: 'Consolidar meu caminho pessoal',
        pageCategory: SpellCategory.wisdom,
        pagePrompts: [
          'Minhas 3 técnicas centrais:',
          'Meus princípios inegociáveis:',
          'O que estou testando agora:',
          'Data da próxima revisão do sistema:',
        ],
      ),
    ],
  );
