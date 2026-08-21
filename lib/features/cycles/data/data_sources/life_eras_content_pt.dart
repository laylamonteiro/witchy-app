import '../../domain/era_ruler.dart';
import '../models/cycle_content.dart';

/// Conteúdo das Eras e Fases — português (idioma-base).
///
/// Mantenha a MESMA ORDEM e a MESMA QUANTIDADE nos três arquivos
/// (`life_eras_content_pt/en/es.dart`) — a paridade é verificada em
/// `test/life_eras_content_parity_test.dart`. Só a prosa muda entre idiomas;
/// `regente` e a contagem de etiquetas são invariantes.
///
/// Vocabulário: na tela existem Eras e Fases, "A Serpente" e "A Cauda".
/// Nenhum termo técnico do sistema de origem aparece aqui.
const List<EraContent> erasPt = [
  EraContent(
    regente: EraRegente.cauda,
    titulo: 'Tempo de soltar e enxergar longe',
    tags: ['desapego', 'silêncio', 'busca'],
    corpo:
        'A Cauda rege um tempo de **afrouxar as mãos**. Coisas que você segurava com força '
            'começam a se soltar sozinhas — vínculos, planos, versões suas que já cumpriram '
            'o que tinham para cumprir. Pode parecer perda, mas é **limpeza de altar**: só fica '
            'o que é seu de verdade. É também um período de **fome espiritual**, em que o que '
            'antes bastava passa a parecer pequeno',
    sombra:
        'O risco é confundir **desapego com desistência**. Você pode se pegar **sem chão**, sem '
            'vontade de nada, achando que perdeu o rumo. A sensação de estar de fora do '
            'mundo pode virar **isolamento** se você deixar',
    convite:
        'Não force decisões grandes agora — este tempo pede **pergunta, não resposta**. Guarde '
            'o que aparecer no **diário de sonhos**, que é por ali que a Cauda costuma falar. '
            'Um altar simples, com poucas coisas, faz mais efeito do que um cheio',
  ),
  EraContent(
    regente: EraRegente.venus,
    titulo: 'Tempo de beleza e prazer',
    tags: ['amor', 'prazer', 'harmonia'],
    corpo:
        'Vênus abre o período mais longo do ciclo, e **ela abre com doçura**. Os afetos ganham '
            'peso: relações que começam aqui **tendem a durar**, e as que já existem pedem '
            'cuidado e beleza. É um tempo bom para dinheiro que vem do que você faz com '
            'gosto, para a casa ficar bonita, para o corpo ser tratado com carinho em vez '
            'de cobrança',
    sombra:
        '**Vinte anos de doçura** também acomodam. Dá para se acostumar tanto com o conforto '
            'que qualquer atrito vire motivo de fuga. Cuidado com dizer sim só para manter '
            'a paz, e com gastar por prazer até onde não cabe',
    convite:
        'Diga o que você quer, **em voz alta**, para quem precisa ouvir. Faça algo com as mãos '
            '**sem finalidade nenhuma** além do prazer. Trabalhe com rosas, cobre e o que '
            'perfuma — Vênus responde bem a beleza oferecida de propósito',
  ),
  EraContent(
    regente: EraRegente.sol,
    titulo: 'Tempo de aparecer',
    tags: ['expressão', 'coragem', 'reconhecimento'],
    corpo:
        'Seis anos **curtos e quentes**. O Sol ilumina o que você faz, e as pessoas passam a '
            'ver. É o tempo de **assumir o próprio nome**: liderar, assinar, subir no palco que '
            'for o seu. Portas se abrem por causa de quem você é, não de quem você conhece, '
            'e sua palavra **pesa mais** do que pesava',
    sombra:
        '**Luz forte também cega**. Pode dar vontade de ser visto a qualquer custo, de crescer '
            'a história para caber na admiração dos outros. E **orgulho ferido** dói mais neste '
            'período do que em qualquer outro',
    convite:
        'Escolha um lugar para brilhar **e vá até o fim nele** — este tempo é curto e não '
            'rende dividido em cinco. Ouro, girassol e a luz do meio-dia são seus aliados. '
            'Faça pelo menos uma coisa importante com o seu nome nela',
  ),
  EraContent(
    regente: EraRegente.lua,
    titulo: 'Tempo de sentir tudo',
    tags: ['emoção', 'cuidado', 'raízes'],
    corpo:
        'A Lua rege **dez anos de pele fina**. Você sente mais, e **mais fundo**: o que passa '
            'despercebido pelos outros chega inteiro em você. Casa, família e as pessoas '
            'que são seu porto ganham o centro. É também um tempo de **intuição afiada**, em '
            'que o corpo sabe antes da cabeça',
    sombra:
        '**Sentir tudo cansa**. O humor **vira maré** e você pode acabar governada por ele, '
            'guardando mágoa em vez de dizer, ou cuidando de todo mundo menos de si. Sono '
            'ruim e apego ao passado são os avisos de que passou do ponto',
    convite:
        'Marque as fases da lua no diário e repare no que se repete — é **o mapa das suas** '
            'marés. Prata, jasmim e água na cabeça acalmam. E **peça colo**: neste tempo, pedir '
            'não é fraqueza, é técnica',
  ),
  EraContent(
    regente: EraRegente.marte,
    titulo: 'Tempo de agir e defender',
    tags: ['coragem', 'ação', 'limite'],
    corpo:
        'Marte **acende o pavio**. Sete anos de **energia bruta** disponível, que pedem para ser '
            'gastos em alguma coisa. É o melhor tempo do ciclo para começar do zero, treinar '
            'o corpo, brigar por algo que importa e finalmente dizer não. A coragem chega '
            '**antes da certeza** — e funciona assim mesmo',
    sombra:
        '**Energia sem destino** vira atrito. **Pavio curto**, discussão à toa, acidente por '
            'pressa, decisão tomada com raiva e paga depois. Se nada estiver sendo '
            'construído, Marte encontra o que destruir',
    convite:
        'Dê ao corpo o que ele está pedindo: **movimento, suor**, esforço com hora marcada. '
            'Escolha **uma briga que valha a pena** e deixe as outras passarem. Ferro, urtiga e '
            'vela vermelha acesa antes de decidir alguma coisa difícil',
  ),
  EraContent(
    regente: EraRegente.serpente,
    titulo: 'Tempo de virar do avesso',
    tags: ['ruptura', 'desejo', 'reinvenção'],
    corpo:
        'A Serpente traz dezoito anos em que a vida **para de seguir as regras conhecidas**. '
            'Coisas acontecem **fora de hora**, do jeito errado, e mesmo assim dão certo. Você '
            'pode se ver fazendo o que jurava que não faria, indo para longe, mudando de '
            'nome ou de mundo. No fim, é **outra pessoa** que sai do outro lado',
    sombra:
        'É **o período das miragens**. O que reluz pode não ser ouro, e a fome de mais pode '
            'te levar longe do que realmente importa. Pressa, atalho e **promessa boa demais** '
            'pedem checagem dobrada aqui',
    convite:
        'Antes de decidir algo grande, deixe **passar um ciclo lunar** — o que for verdadeiro '
            'continua lá depois. Anote o que você jurou que nunca faria, para reconhecer a '
            'reviravolta quando ela vier. E **confie no estranho**: é ele que está te levando '
            'para onde você precisa ir',
  ),
  EraContent(
    regente: EraRegente.jupiter,
    titulo: 'Tempo de colher e multiplicar',
    tags: ['expansão', 'abundância', 'sabedoria'],
    corpo:
        'Júpiter é **o regente mais generoso** do ciclo, e dezesseis anos dele mudam o tamanho '
            'da sua vida. O que você plantou começa a **dar em quantidade**. Estudo, viagem, '
            'reconhecimento e dinheiro aparecem com mais facilidade do que o normal, e '
            'gente com poder de abrir portas cruza o seu caminho **sem que você tenha** '
            'procurado',
    sombra:
        '**Abundância também exagera**. Dá para dizer sim demais, prometer além do que cabe '
            'na semana e crescer para todos os lados sem terminar nada. **Excesso** — de '
            'comida, de gasto, de opinião — é o jeito que Júpiter tem de avisar',
    convite:
        'Escolha em que direção crescer e recuse as outras com educação. **Ensine o que você** '
            'sabe: neste tempo, **dar aumenta** em vez de diminuir. Estanho, sálvia e um '
            'propósito escrito onde você veja todo dia',
  ),
  EraContent(
    regente: EraRegente.saturno,
    titulo: 'Tempo de construir com as próprias mãos',
    tags: ['disciplina', 'maturidade', 'consequência'],
    corpo:
        'Saturno é **o mestre severo** do ciclo, e dezenove anos dele constroem uma pessoa '
            'inteira. Nada vem de graça, mas **nada do que vem se perde**: o que você levantar '
            'aqui fica de pé por décadas. É o tempo de assumir o que é seu, de terminar o '
            'que ficou pela metade e de descobrir que **você aguenta mais** do que imaginava',
    sombra:
        'Também é **o tempo mais pesado**. Escolhas antigas voltam **pedindo conta**, portas '
            'demoram, e o cansaço é real. Pode dar vontade de se fechar, de achar que não '
            'é capaz, de tratar a si mesma com **uma dureza** que você não usaria com ninguém',
    convite:
        '**Faça pouco, mas faça todo dia** — Saturno paga por constância, nunca por arranco. '
            'Escreva **o que você terminou**, não o que falta. Chumbo, cipreste e a paciência '
            'de quem sabe que a colheita não é desta lua',
  ),
  EraContent(
    regente: EraRegente.mercurio,
    titulo: 'Tempo de aprender e conectar',
    tags: ['comunicação', 'estudo', 'movimento'],
    corpo:
        'Mercúrio abre **dezessete anos de mente ligada**. Você aprende rápido, fala melhor e '
            'circula mais: gente nova, assunto novo, cidade nova. É excelente para estudar, '
            'escrever, negociar e para qualquer trabalho em que **a palavra seja a ferramenta**. '
            'Ideias chegam mais depressa do que você consegue anotar',
    sombra:
        '**Mente ligada não desliga**. Pensamento em looping, insônia de cabeça cheia, começar '
            'dez coisas e terminar nenhuma. E a palavra que abre porta é a mesma que fecha: '
            'aqui, o que se fala sem pensar **custa caro**',
    convite:
        'Escreva — no diário, num caderno, em qualquer lugar. **Tirar de dentro** é o que faz '
            'esta mente descansar. Escolha **três assuntos por ano** e deixe os outros para '
            'depois. Mercúrio, lavanda e silêncio de propósito uma vez por semana',
  ),
];

/// Fases — o tempero curto que cada regente dá à Era em curso.
const List<FaseContent> fasesPt = [
  FaseContent(
    regente: EraRegente.cauda,
    titulo: 'Deixe cair o que já acabou',
    tags: ['limpeza', 'pausa', 'intuição'],
    sabor:
        'A Cauda passa curta e pede **espaço vazio**. Alguma coisa se encerra **sem barulho**, e '
            'tentar segurar só faz doer mais. Aproveite para limpar gaveta, agenda e '
            'promessa antiga',
  ),
  FaseContent(
    regente: EraRegente.venus,
    titulo: 'Foque em se sentir bem',
    tags: ['prazer', 'afeto', 'beleza'],
    sabor:
        'Vênus **adoça o período**. Encontros ficam mais fáceis, o corpo pede cuidado e o que '
            'é bonito rende mais que o que é certo. Bom tempo para **pedir aumento**, se '
            'declarar e receber',
  ),
  FaseContent(
    regente: EraRegente.sol,
    titulo: 'Assuma o seu lugar',
    tags: ['visibilidade', 'nome', 'clareza'],
    sabor:
        'O Sol **acende o holofote** por um tempo curto. Você é notada, cobrada e reconhecida '
            'em dose maior. Se tem algo para mostrar ao mundo, **mostre agora**',
  ),
  FaseContent(
    regente: EraRegente.lua,
    titulo: 'Cuide do que sente',
    tags: ['emoção', 'casa', 'descanso'],
    sabor:
        'A Lua deixa tudo **mais sensível**. Assunto de família e de casa vem para a frente, e '
            'a intuição fica afiada. Se der vontade de recolher, **recolha** — desta vez não é '
            'fuga',
  ),
  FaseContent(
    regente: EraRegente.marte,
    titulo: 'Faça acontecer',
    tags: ['ação', 'coragem', 'atrito'],
    sabor:
        'Marte **acelera tudo**. Aparece energia para começar e disposição para brigar, às '
            'vezes na mesma frase. Gaste isso no corpo e em trabalho, **antes que se gaste** '
            'sozinho em discussão',
  ),
  FaseContent(
    regente: EraRegente.serpente,
    titulo: 'Espere o inesperado',
    tags: ['reviravolta', 'desejo', 'pressa'],
    sabor:
        'A Serpente **embaralha as cartas**. Planos mudam de última hora e aparece uma '
            'oportunidade que parece boa demais. **Confira duas vezes** e não assine com pressa',
  ),
  FaseContent(
    regente: EraRegente.jupiter,
    titulo: 'Diga sim ao que expande',
    tags: ['sorte', 'estudo', 'porta aberta'],
    sabor:
        'Júpiter **abre caminho**. Convites, boas notícias e gente disposta a ajudar aparecem '
            'com facilidade. Só cuidado para não aceitar mais do que **cabe na sua semana**',
  ),
  FaseContent(
    regente: EraRegente.saturno,
    titulo: 'Termine o que ficou pela metade',
    tags: ['esforço', 'prova', 'estrutura'],
    sabor:
        'Saturno **pesa a mão**. Tudo demora mais e cobra mais, e o que estava mal feito '
            'aparece. É desconfortável e é útil: o que você consertar agora **fica consertado**',
  ),
  FaseContent(
    regente: EraRegente.mercurio,
    titulo: 'Fale, escreva, combine',
    tags: ['palavra', 'ideia', 'trânsito'],
    sabor:
        'Mercúrio **acelera a cabeça** e a conversa. Ótimo para estudar, negociar e resolver '
            'pendência por escrito. Ruim para prometer sem pensar — **releia antes de enviar**',
  ),
];
