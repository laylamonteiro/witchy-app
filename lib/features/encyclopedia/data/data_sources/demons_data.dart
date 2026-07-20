import '../models/arcane_entry_model.dart';

/// Demônios — abordagem informativa e histórica: goécia, folclore,
/// demonologia literária e releituras modernas, sem apresentar uma única
/// interpretação como verdade absoluta e sem incentivo a práticas de dano.
const List<ArcaneEntry> demonsData = [
  ArcaneEntry(
    name: 'Lilith',
    emoji: '🌒',
    summary: 'Da demonização à reivindicação: a primeira que disse não',
    origin: 'Demônios-vento mesopotâmicos; folclore judaico medieval',
    history:
        'Lilith nasce dos lilitu mesopotâmicos e ganha biografia no Alfabeto de Ben Sira: a primeira mulher de Adão, que se recusou à submissão e partiu. Temida por séculos em amuletos de proteção, foi reivindicada no século XX como ícone de autonomia feminina.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Folclórica',
        view:
            'Espírito noturno contra o qual se usavam amuletos, especialmente para recém-nascidos.',
      ),
      ArcanePerspective(
        tradition: 'Cabalística',
        view: 'Consorte do lado sombrio nas correntes místicas medievais.',
      ),
      ArcanePerspective(
        tradition: 'Moderna/Feminista',
        view:
            'Símbolo de recusa à submissão e soberania — presente na astrologia (Lua Negra) e na bruxaria contemporânea.',
      ),
    ],
    characteristics: ['Independência radical', 'Noite', 'Sexualidade soberana', 'Recusa'],
    symbolism: [
      'A coruja: visão noturna',
      'A lua negra: o feminino não domesticado',
      'O deserto: o território fora das regras',
    ],
    correspondences: ['Lua Negra (astrologia)', 'Obsidiana', 'Preto e vinho'],
    studyPractices: [
      'Comparar o Alfabeto de Ben Sira com as releituras feministas',
      'Refletir: "onde digo sim quando quero dizer não?"',
    ],
    magicalUses: [
      'Trabalho de sombra sobre autonomia e limites',
      'Estudo da Lua Negra no mapa astral',
    ],
    cautions:
        'Conteúdo histórico-informativo. Nenhuma prática aqui envolve ou incentiva dano a quem quer que seja.',
    related: ['A Rainha Sombria (Arquétipos)', 'Lua Nova'],
  ),
  ArcaneEntry(
    name: 'Asmodeus',
    emoji: '💍',
    summary: 'O demônio do Livro de Tobias e rei dos prazeres na goécia',
    origin: 'Aeshma-daeva persa; Livro de Tobias; goécia medieval',
    history:
        'Herdeiro do "demônio da ira" persa, Asmodeus atormenta o casamento de Sara no Livro de Tobias até ser afastado com a ajuda de Rafael. Na Goécia (Lemegeton), figura como rei que ensina matemática e artesanato — exemplo da mistura medieval entre temor e fascínio erudito.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'O destruidor de casamentos vencido pela ajuda angélica.',
      ),
      ArcanePerspective(
        tradition: 'Goética',
        view:
            'Um dos 72 espíritos de Salomão: rei que ensina aritmética, astronomia e ofícios.',
      ),
      ArcanePerspective(
        tradition: 'Folclórica',
        view: 'Nas lendas de Salomão, o gênio que ajudou (a contragosto) a construir o Templo.',
      ),
    ],
    characteristics: ['Desejo', 'Ciúme', 'Engenho', 'Excesso'],
    symbolism: [
      'O anel de Salomão: o saber que ordena as paixões',
      'O fumo do peixe: o remédio inesperado',
    ],
    correspondences: ['Goécia (estudo)', 'Granada', 'Vermelho escuro'],
    studyPractices: [
      'Ler o Livro de Tobias e comparar com o Lemegeton',
      'Refletir sobre ciúme e desejo como mensageiros, não donos',
    ],
    magicalUses: [
      'Estudo histórico dos grimórios salomônicos',
      'Trabalho de sombra sobre possessividade',
    ],
    cautions:
        'A goécia é apresentada aqui como objeto de estudo histórico. Nenhuma prática de dano é ensinada ou incentivada.',
    related: ['Rafael (Anjos)', 'Raziel (Anjos)'],
  ),
  ArcaneEntry(
    name: 'Belzebu',
    emoji: '🪰',
    summary: 'O "Senhor das Moscas": de deus filisteu a príncipe dos demônios',
    origin: 'Baal-Zebub de Ecrom (2 Reis); evangelhos; demonologia medieval',
    history:
        'Baal-Zebub era um deus filisteu consultado como oráculo. A tradição judaica transformou o nome em escárnio ("senhor das moscas") e os evangelhos o citam como príncipe dos demônios — caso clássico de divindade estrangeira demonizada.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Histórica',
        view:
            'Exemplo didático de como deuses de povos rivais foram convertidos em demônios.',
      ),
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'Nos evangelhos, o príncipe dos demônios pelo qual acusavam Jesus.',
      ),
      ArcanePerspective(
        tradition: 'Literária',
        view:
            'De Milton ao romance "O Senhor das Moscas", símbolo da decadência e do caos social.',
      ),
    ],
    characteristics: ['Decadência', 'Ruído', 'Poder corrompido'],
    symbolism: [
      'A mosca: o que se acumula onde algo apodrece',
      'O trono caído: a autoridade que se degrada',
    ],
    correspondences: ['Estudo histórico', 'Cinza e negro'],
    studyPractices: [
      'Pesquisar o processo histórico de demonização de divindades',
      'Refletir: "que julgamentos herdei sem examinar?"',
    ],
    magicalUses: [
      'Nenhum uso ritual proposto — entrada de estudo histórico',
    ],
    cautions:
        'Conteúdo histórico-informativo. Nenhuma prática de dano é ensinada ou incentivada.',
    related: ['Lúcifer', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Mefistófeles',
    emoji: '🎭',
    summary: 'O demônio do pacto: a criação literária que definiu um gênero',
    origin: 'Lenda alemã de Fausto (séc. XVI); Marlowe e Goethe',
    history:
        'Mefistófeles não vem de tradição religiosa: nasce na lenda de Fausto e cresce nas mãos de Marlowe e Goethe. É o espírito "que sempre nega" — irônico, culto, contratual — e moldou para sempre a imagem do pacto demoníaco.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Literária',
        view:
            'Em Goethe, "parte daquela força que sempre quer o mal e sempre cria o bem" — o adversário que nos põe em movimento.',
      ),
      ArcanePerspective(
        tradition: 'Filosófica',
        view:
            'O espírito da negação e da ironia: a dúvida que corrói ou que desperta.',
      ),
    ],
    characteristics: ['Ironia', 'Contrato', 'Sedução intelectual', 'Negação'],
    symbolism: [
      'O pacto assinado: escolhas com preço',
      'O cão negro: a forma da primeira aparição',
      'O teatro: a máscara e o jogo',
    ],
    correspondences: ['Literatura faustiana', 'Vermelho e negro'],
    studyPractices: [
      'Ler o Fausto de Goethe (ao menos a cena do pacto)',
      'Refletir: "que atalhos me cobrariam caro demais?"',
    ],
    magicalUses: [
      'Nenhum uso ritual proposto — figura literária para reflexão sobre escolhas',
    ],
    cautions:
        'Conteúdo histórico-literário. Nenhuma prática de pacto é real ou incentivada.',
    related: ['A Alquimista (Arquétipos)', 'Lúcifer'],
  ),
  ArcaneEntry(
    name: 'Pazuzu',
    emoji: '🌪️',
    summary: 'O demônio-vento assírio que protegia contra demônios',
    origin: 'Mesopotâmia (séculos VIII-VII a.C.)',
    history:
        'Rei dos demônios do vento na Assíria, Pazuzu trazia tempestades e pragas — e, paradoxalmente, seus amuletos eram usados para afastar a temível Lamashtu, protegendo grávidas e bebês. O mal que guarda contra o mal.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Mesopotâmica',
        view:
            'Entidade ambivalente: perigosa por natureza, protetora por função apotropaica.',
      ),
      ArcanePerspective(
        tradition: 'Cultura pop',
        view:
            'Tornou-se célebre (e distorcido) pelo filme O Exorcista, virando sinônimo de possessão.',
      ),
    ],
    characteristics: ['Ambivalência', 'Vento e febre', 'Proteção paradoxal'],
    symbolism: [
      'A cabeça de amuleto: o terror domesticado em guarda',
      'O vento sudoeste: a força que não se controla, se negocia',
    ],
    correspondences: ['Amuletos históricos', 'Bronze'],
    studyPractices: [
      'Estudar amuletos apotropaicos (o mal contra o mal) em várias culturas',
      'Refletir sobre forças suas "temidas" que na verdade protegem',
    ],
    magicalUses: [
      'Estudo do princípio apotropaico em amuletos',
    ],
    cautions:
        'Conteúdo histórico-informativo. Nenhuma prática de dano é ensinada ou incentivada.',
    related: ['A Guardiã (Arquétipos)', 'Querubins (Anjos)'],
  ),
  ArcaneEntry(
    name: 'Baphomet',
    emoji: '🐐',
    summary: 'Do processo dos Templários ao símbolo ocultista do equilíbrio',
    origin: 'Acusações contra os Templários (1307); desenho de Eliphas Lévi (1856)',
    history:
        'O nome surge nas confissões forçadas dos Templários — provavelmente corruptela de "Mahomet". Séculos depois, Eliphas Lévi desenhou o Bode de Mendes: figura andrógina cheia de opostos reconciliados ("solve" e "coagula" nos braços), que nada tem de culto medieval real.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Histórica',
        view:
            'Um fantasma processual: a "idolatria" que os inquisidores precisavam encontrar.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista',
        view:
            'Em Lévi, símbolo do equilíbrio dos opostos — matéria e espírito, masculino e feminino, acima e abaixo.',
      ),
      ArcanePerspective(
        tradition: 'Contemporânea',
        view:
            'Adotado por correntes satanistas laicas como emblema de antidogmatismo, ampliando ainda mais a distância da origem.',
      ),
    ],
    characteristics: ['Síntese de opostos', 'Mal-entendido histórico', 'Provocação'],
    symbolism: [
      'A tocha entre os chifres: a inteligência acima da matéria',
      'Solve et coagula: dissolver e recompor',
      'O andrógino: a totalidade',
    ],
    correspondences: ['Alquimia simbólica', 'Preto e prata'],
    studyPractices: [
      'Comparar as atas do processo templário com o desenho de Lévi',
      'Meditar sobre pares de opostos que você precisa reconciliar',
    ],
    magicalUses: [
      'Contemplação alquímica dos opostos internos',
    ],
    cautions:
        'Conteúdo histórico-informativo. Símbolo frequentemente mal compreendido; estude as fontes.',
    related: ['A Alquimista (Arquétipos)', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Belial',
    emoji: '⛓️',
    summary: '"Sem valor": a personificação da anomia nos textos antigos',
    origin: 'Hebraico bíblico; Manuscritos do Mar Morto; goécia',
    history:
        'Na Bíblia hebraica, "filhos de Belial" designa pessoas sem lei. Nos Manuscritos do Mar Morto, Belial lidera os Filhos das Trevas contra os Filhos da Luz. Na Goécia, é um rei poderoso que exige oferendas — retrato do poder sem princípio.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Bíblica',
        view: 'Não um ser, mas um qualificativo: a ausência de valor e lei.',
      ),
      ArcanePerspective(
        tradition: 'Qumran',
        view: 'O príncipe das trevas no grande combate escatológico.',
      ),
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Rei que distribui favores e títulos — o arquétipo do poder corrupto.',
      ),
    ],
    characteristics: ['Anomia', 'Poder sem ética', 'Sedução do atalho'],
    symbolism: [
      'As correntes partidas: liberdade sem responsabilidade',
      'O trono vazio: autoridade sem legitimidade',
    ],
    correspondences: ['Estudo dos Manuscritos do Mar Morto'],
    studyPractices: [
      'Refletir sobre poder e ética: "que poder eu quero — e a que custo?"',
    ],
    magicalUses: [
      'Nenhum uso ritual proposto — entrada de estudo histórico',
    ],
    cautions:
        'Conteúdo histórico-informativo. Nenhuma prática de dano é ensinada ou incentivada.',
    related: ['Lúcifer', 'Mefistófeles'],
  ),
  ArcaneEntry(
    name: 'Mammon',
    emoji: '💰',
    summary: 'A riqueza personificada: quando o dinheiro vira senhor',
    origin: 'Aramaico mamona ("riqueza"); evangelhos; Milton',
    history:
        '"Não podeis servir a Deus e a Mamom": a palavra aramaica para riqueza foi personificada pela tradição cristã e, em Milton, virou o demônio que mesmo no céu só olhava para o chão dourado — a avareza como rebaixamento do olhar.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Religiosa',
        view: 'A idolatria da riqueza como rival direto do sagrado.',
      ),
      ArcanePerspective(
        tradition: 'Literária',
        view:
            'Em Milton, o construtor do Pandemônio: talento a serviço do acúmulo.',
      ),
    ],
    characteristics: ['Avareza', 'Acúmulo', 'Olhar baixo'],
    symbolism: [
      'O ouro no chão: o valor que faz curvar',
      'A balança desonesta: troca sem alma',
    ],
    correspondences: ['Reflexões sobre prosperidade', 'Dourado e cinza'],
    studyPractices: [
      'Examinar sua relação com dinheiro: ferramenta ou senhor?',
      'Contrastar com práticas saudáveis de prosperidade (ver Grimório)',
    ],
    magicalUses: [
      'Nenhum uso ritual proposto — espelho para a relação com a abundância',
    ],
    cautions:
        'Conteúdo histórico-informativo. Prosperidade saudável difere de avareza.',
    related: ['Prosperidade & Caminhos (Grimório)', 'Belial'],
  ),
  ArcaneEntry(
    name: 'Leviatã',
    emoji: '🐉',
    summary: 'O monstro do caos primordial que habita as profundezas',
    origin: 'Mitos cananeus (Lotan); Jó, Salmos e Isaías',
    history:
        'Herdeiro do Lotan cananeu, o Leviatã é a serpente marinha do caos que só o divino domina. Em Jó, é descrito com assombro; Hobbes o tomou como metáfora do Estado; a psicologia moderna o lê como o caos inconsciente.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Bíblica',
        view: 'O caos aquático subjugado na criação — força que só o sagrado contém.',
      ),
      ArcanePerspective(
        tradition: 'Filosófica',
        view: 'Em Hobbes, o poder soberano que impede a guerra de todos contra todos.',
      ),
      ArcanePerspective(
        tradition: 'Simbólico-psicológica',
        view: 'As profundezas do inconsciente: o que emerge quando o mar interior se agita.',
      ),
    ],
    characteristics: ['Caos primordial', 'Imensidão', 'O indomável'],
    symbolism: [
      'O mar profundo: o inconsciente coletivo',
      'A serpente enrolada: energia contida',
      'A tempestade: emoções que transbordam',
    ],
    correspondences: ['Água', 'Azul abissal', 'Sonhos com mar'],
    studyPractices: [
      'Ler Jó 41 como poema do assombro diante do incontrolável',
      'Registrar sonhos com mar/água no Diário de Sonhos',
    ],
    magicalUses: [
      'Meditações de navegação das próprias profundezas',
    ],
    cautions:
        'Conteúdo histórico-informativo. Nenhuma prática de dano é ensinada ou incentivada.',
    related: ['Água (Temas Oníricos)', 'A Rainha Sombria (Arquétipos)'],
  ),
  ArcaneEntry(
    name: 'Astaroth',
    emoji: '👑',
    summary: 'O grão-duque da Goécia, eco demonizado da deusa Astarte',
    origin: 'Goécia (Lemegeton); derivado de Astarte/Ishtar',
    history:
        'Nos grimórios, Astaroth é um grão-duque que ensina ciências e revela segredos do passado e do futuro. O nome descende de Astarte, grande deusa do Oriente Próximo — um caso clássico de divindade antiga demonizada pela tradição posterior.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Duque que ensina artes liberais e responde sobre coisas ocultas.',
      ),
      ArcanePerspective(
        tradition: 'Histórica',
        view: 'A memória de Astarte/Ishtar transformada em demônio: o rebaixamento das deusas.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista moderna',
        view: 'Símbolo do saber proibido e do resgate do feminino divino apagado.',
      ),
    ],
    characteristics: ['Conhecimento oculto', 'Memória ancestral', 'Eloquência', 'Passado revelado'],
    symbolism: [
      'A serpente na mão: o saber que assusta',
      'A coroa ducal: nobreza caída',
      'A estrela de oito pontas: herança de Ishtar',
    ],
    correspondences: ['Vênus (herança de Astarte)', 'Quarta-feira nos grimórios', 'Verde profundo'],
    studyPractices: [
      'Comparar Astarte nos textos ugaríticos com o Astaroth goético',
      'Refletir: que saberes já foram chamados de proibidos?',
    ],
    magicalUses: [
      'Estudo simbólico da demonização de divindades femininas',
      'Contemplação sobre resgatar saberes apagados',
    ],
    cautions:
        'Conteúdo histórico-informativo sobre grimórios. Nenhuma prática aqui envolve ou incentiva dano.',
    related: ['Deusas', 'A Sábia (Arquétipos)'],
  ),
  ArcaneEntry(
    name: 'Paimon',
    emoji: '🐪',
    summary: 'O rei obediente da Goécia, mestre das artes e das ciências',
    origin: 'Goécia (Lemegeton), um dos reis do Oeste',
    history:
        'Descrito como um rei que chega em grande estardalhaço, montado num dromedário e precedido de músicos, Paimon ensina todas as artes, ciências e segredos. Os grimórios o listam entre os espíritos mais obedientes ao exorcista — e o cinema recente o devolveu à cultura popular.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Rei que ensina filosofia, artes e os segredos da mente.',
      ),
      ArcanePerspective(
        tradition: 'Histórica',
        view: 'Possível eco de espíritos pré-islâmicos do deserto incorporados aos grimórios europeus.',
      ),
      ArcanePerspective(
        tradition: 'Cultura pop',
        view: 'Reintroduzido pelo terror contemporâneo como símbolo de influência oculta.',
      ),
    ],
    characteristics: ['Maestria', 'Conhecimento das mentes', 'Cerimônia', 'Vínculo e lealdade'],
    symbolism: [
      'O dromedário: a travessia paciente do deserto',
      'A música que o precede: o poder que se anuncia',
      'A coroa do Oeste: domínio sobre o entardecer',
    ],
    correspondences: ['Oeste', 'Música cerimonial', 'Azul-noite e ouro'],
    studyPractices: [
      'Ler a descrição de Paimon no Lemegeton em contexto histórico',
      'Estudar como o cinema ressignifica figuras goéticas',
    ],
    magicalUses: [
      'Estudo simbólico da maestria e do aprendizado profundo',
      'Análise crítica dos grimórios como literatura mágica',
    ],
    cautions:
        'Conteúdo histórico-informativo sobre grimórios. Nenhuma prática aqui envolve ou incentiva dano.',
    related: ['A Alquimista (Arquétipos)', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Bael',
    emoji: '🐸',
    summary: 'O primeiro rei da Goécia, senhor da invisibilidade',
    origin: 'Goécia (Lemegeton); do título semítico Ba\'al ("senhor")',
    history:
        'Primeiro espírito listado no Lemegeton, Bael aparece com três cabeças — de homem, gato e sapo — e concede a arte de tornar-se invisível. Seu nome vem de Ba\'al, título dos grandes deuses cananeus, outro caso de divindade antiga rebaixada a demônio.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Rei do Leste que ensina a invisibilidade e a astúcia.',
      ),
      ArcanePerspective(
        tradition: 'Histórica',
        view: 'Ba\'al Hadade, deus da tempestade cananeu, demonizado pela polêmica bíblica.',
      ),
      ArcanePerspective(
        tradition: 'Simbólica',
        view: 'As três cabeças: as máscaras que usamos para sermos vistos — ou não.',
      ),
    ],
    characteristics: ['Invisibilidade', 'Astúcia', 'Realeza antiga', 'Máscaras'],
    symbolism: [
      'As três cabeças: as faces do eu',
      'A invisibilidade: proteção e ocultamento',
      'O trono do Leste: o poder do amanhecer',
    ],
    correspondences: ['Leste', 'Tempestade (herança de Ba\'al)', 'Preto e âmbar'],
    studyPractices: [
      'Comparar Ba\'al nos textos de Ugarit com o Bael goético',
      'Refletir: quando ser invisível protege — e quando apaga?',
    ],
    magicalUses: [
      'Estudo simbólico de discrição e fronteiras pessoais',
      'Contemplação das próprias máscaras sociais',
    ],
    cautions:
        'Conteúdo histórico-informativo sobre grimórios. Nenhuma prática aqui envolve ou incentiva dano.',
    related: ['Deusas', 'Símbolos Sagrados'],
  ),
  ArcaneEntry(
    name: 'Stolas',
    emoji: '🦉',
    summary: 'O príncipe-coruja que ensina ervas, pedras e astronomia',
    origin: 'Goécia (Lemegeton), príncipe dos grimórios',
    history:
        'Stolas (ou Stolos) aparece como uma grande coruja coroada que ensina astronomia e o poder das ervas e das pedras preciosas — o espírito goético mais próximo do coração da bruxaria natural. Por isso é figura querida entre praticantes que estudam plantas e cristais.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Príncipe que ensina astronomia, ervas e o valor das pedras.',
      ),
      ArcanePerspective(
        tradition: 'Simbólica',
        view: 'A coruja coroada: a sabedoria noturna que enxerga no escuro.',
      ),
      ArcanePerspective(
        tradition: 'Bruxaria natural',
        view: 'Padroeiro informal do estudo de herbários e lapidários mágicos.',
      ),
    ],
    characteristics: ['Sabedoria natural', 'Herbalismo', 'Astros', 'Visão noturna'],
    symbolism: [
      'A coruja: ver o que a luz esconde',
      'A coroa: o saber como realeza',
      'O céu estrelado: o mapa acima e dentro de nós',
    ],
    correspondences: ['Ervas e cristais', 'Noite', 'Verde-musgo e prata'],
    studyPractices: [
      'Montar um índice próprio de ervas e pedras estudadas',
      'Observar o céu por uma lunação e registrar',
    ],
    magicalUses: [
      'Estudo simbólico do aprendizado de ervas e cristais',
      'Contemplações noturnas de observação do céu',
    ],
    cautions:
        'Conteúdo histórico-informativo sobre grimórios. Nenhuma prática aqui envolve ou incentiva dano.',
    related: ['Ervas', 'Cristais'],
  ),
  ArcaneEntry(
    name: 'Buer',
    emoji: '🌿',
    summary: 'O presidente-curandeiro da Goécia, mestre das ervas medicinais',
    origin: 'Goécia (Lemegeton), presidente dos grimórios',
    history:
        'Buer ensina filosofia natural, lógica e as virtudes das ervas, e é descrito como aquele que "cura todas as enfermidades". Ilustrado por Collin de Plancy como uma roda de cinco pernas, tornou-se símbolo curioso do movimento perpétuo do aprendizado.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Presidente que ensina as virtudes das plantas e restaura a saúde.',
      ),
      ArcanePerspective(
        tradition: 'Histórica',
        view: 'Reflexo do médico-filósofo antigo: cura, lógica e ética andavam juntas.',
      ),
      ArcanePerspective(
        tradition: 'Simbólica',
        view: 'A roda de cinco pernas: o conhecimento que não para de girar.',
      ),
    ],
    characteristics: ['Cura', 'Herbalismo', 'Lógica', 'Filosofia natural'],
    symbolism: [
      'A roda: o movimento contínuo do estudo',
      'O centauro com arco (outras fontes): instinto e mira',
      'O ramo de ervas: remédio na natureza',
    ],
    correspondences: ['Ervas medicinais', 'Sagitário nos grimórios', 'Verde e branco'],
    studyPractices: [
      'Estudar a história da medicina das ervas',
      'Refletir sobre a ética de curar: limites e responsabilidade',
    ],
    magicalUses: [
      'Estudo simbólico do caminho de quem cura',
      'Contemplação sobre saúde como equilíbrio',
    ],
    cautions:
        'Conteúdo histórico-informativo. Ervas medicinais reais exigem orientação profissional.',
    related: ['Ervas', 'A Curandeira (Arquétipos)'],
  ),
  ArcaneEntry(
    name: 'Dantalion',
    emoji: '📖',
    summary: 'O duque dos mil rostos que conhece todos os pensamentos',
    origin: 'Goécia (Lemegeton), 71º espírito',
    history:
        'Dantalion aparece com incontáveis rostos de homens e mulheres, segurando um livro. Os grimórios dizem que conhece os pensamentos de todas as pessoas e ensina todas as artes e ciências — a imagem perfeita da empatia levada ao limite do mistério.',
    perspectives: [
      ArcanePerspective(
        tradition: 'Goética',
        view: 'Duque que revela pensamentos e ensina qualquer arte ou ciência.',
      ),
      ArcanePerspective(
        tradition: 'Simbólica',
        view: 'Os mil rostos: toda mente humana contém multidões.',
      ),
      ArcanePerspective(
        tradition: 'Ocultista moderna',
        view: 'Figura associada ao estudo da empatia, da persuasão e dos próprios vieses.',
      ),
    ],
    characteristics: ['Empatia radical', 'Multiplicidade', 'Estudo das mentes', 'O livro interior'],
    symbolism: [
      'O livro na mão: cada pessoa é uma biblioteca',
      'Os mil rostos: as versões de nós mesmos',
      'O espelho: ler o outro é ler a si',
    ],
    correspondences: ['Mercúrio', 'Quarta-feira', 'Lilás e grafite'],
    studyPractices: [
      'Refletir: quantos "eus" falam dentro de você?',
      'Praticar escuta profunda sem julgamento por um dia',
    ],
    magicalUses: [
      'Estudo simbólico da empatia e da comunicação',
      'Contemplação dos próprios múltiplos rostos',
    ],
    cautions:
        'Conteúdo histórico-informativo sobre grimórios. Nenhuma prática aqui envolve ou incentiva dano.',
    related: ['A Vidente (Arquétipos)', 'A Tecelã (Arquétipos)'],
  ),
];
