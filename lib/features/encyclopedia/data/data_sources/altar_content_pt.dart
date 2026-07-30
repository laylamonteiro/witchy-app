import '../models/altar_content_model.dart';

/// Conteúdo da página "O Altar Mágico" — português (idioma-base).
///
/// Emojis e a ordem/contagem das listas são invariantes entre idiomas.
/// Mantenha a mesma estrutura nos três arquivos
/// (`altar_content_pt/en/es.dart`) — a paridade é verificada em
/// `test/encyclopedia_content_parity_test.dart`.
const AltarContent altarContentPt = AltarContent(
  pageTitle: 'O Altar Mágico',
  introTitle: 'Sobre o Altar',
  introBody:
      'Um altar é seu espaço sagrado pessoal - um ponto focal para sua prática mágica. '
      'Não precisa ser elaborado ou caro; o que importa é a intenção e o respeito com que você o trata. '
      'Seu altar é uma extensão da sua energia e um portal entre o mundo físico e o espiritual.',
  introHint:
      'Explore as seções abaixo para aprender a montar, purificar, manter e utilizar seu altar.',
  beginnerTitle: 'Passo-a-Passo para Iniciantes',
  beginnerSubtitle: 'Seu primeiro encontro com seu altar',
  beginnerIntro:
      'Não se preocupe se você não tem todos os itens "tradicionais". '
      'Um altar pode começar com uma vela e uma intenção. O importante é que '
      'seja significativo para VOCÊ. Não existe altar errado quando é feito com coração.',
  beginnerSteps: [
    AltarNumberedStep(
      'Escolha o Local',
      'Um cantinho onde você não será perturbado(a). Pode ser uma mesinha, prateleira, ou até uma caixa que você abre quando for praticar.',
      'Não precisa ser grande! Um espaço de 30x30cm já é suficiente.',
    ),
    AltarNumberedStep(
      'Limpe o Espaço',
      'Limpe fisicamente com um pano, depois passe fumaça de incenso ou visualize uma luz branca purificando.',
      'Diga: "Que este espaço seja purificado e abençoado."',
    ),
    AltarNumberedStep(
      'Adicione uma Vela',
      'A vela é o coração do altar - representa o fogo e a luz divina. Uma única vela branca já é suficiente.',
      'Velas brancas são universais e podem substituir qualquer cor.',
    ),
    AltarNumberedStep(
      'Adicione Itens Significativos',
      'Coloque o que tem significado para você: foto de ancestrais, cristal que ganhou, flores, uma concha da praia.',
      'Comece com 3-5 itens e vá adicionando com o tempo.',
    ),
    AltarNumberedStep(
      'Consagre seu Altar',
      'Acenda a vela, respire fundo e diga: "Consagro este altar como meu espaço sagrado. Que ele seja um portal de conexão."',
      'Use suas próprias palavras! O importante é a intenção.',
    ),
  ],
  firstTimesTitle: '🌟 Nas primeiras vezes no altar',
  firstTimesItems: [
    '1. Acenda a vela com intenção, observe a chama',
    '2. Faça 3 respirações profundas para se centrar',
    '3. Agradeça pelo dia, pela vida, por algo bom',
    '4. Defina uma intenção: "Hoje eu peço/agradeço..."',
    '5. Fique alguns minutos em silêncio ou converse',
    '6. Feche: "Agradeço pela conexão. Que assim seja."',
  ],
  speakTitle: '💬 O que falar no altar?',
  speakExamples: [
    AltarSpeech('Para abrir:',
        '"Acendo esta vela como símbolo da minha conexão com o sagrado."'),
    AltarSpeech('Para pedir:',
        '"Peço orientação para [situação]. Que a sabedoria ilumine meu caminho."'),
    AltarSpeech('Para agradecer:',
        '"Agradeço por [bênção específica]. Meu coração está cheio de gratidão."'),
    AltarSpeech('Para fechar:',
        '"Agradeço a conexão. Que a magia continue comigo. Assim seja."'),
  ],
  speakNote:
      'Lembre-se: Não existe fórmula errada. O universo entende sua intenção!',
  faqTitle: '❓ Dúvidas Comuns de Iniciantes',
  faqs: [
    AltarFaq('Posso ter um altar secreto?',
        'Sim! Use uma caixa que você abre quando for praticar.'),
    AltarFaq('Preciso ir ao altar todo dia?',
        'Não há regra. Vá quando sentir vontade. Uma rotina fortalece, mas não é obrigatória.'),
    AltarFaq('Posso mexer nas coisas?',
        'Sim! O altar é vivo e deve mudar com você.'),
    AltarFaq('E se eu esquecer as palavras?',
        'Improvise! O divino não se importa com palavras perfeitas.'),
  ],
  mountTitle: 'Como Montar seu Altar',
  mountSteps: [
    AltarStep(
      '1. Escolha o local',
      'Selecione um espaço tranquilo onde você possa ter privacidade. '
          'Pode ser uma mesa, prateleira, cômoda ou até um canto do seu quarto. '
          'Evite banheiros e lavanderias (pontos de saída de energia).',
    ),
    AltarStep(
      '2. Limpe o espaço',
      'Limpe fisicamente a superfície e energeticamente com fumaça de ervas '
          '(alecrim, arruda, sálvia) ou borrife água com sal.',
    ),
    AltarStep(
      '3. Use uma toalha ou tecido',
      'Opcional, mas recomendado. Use cores que ressoem com você: '
          'preto (proteção), branco (pureza), roxo (espiritualidade), verde (cura).',
    ),
    AltarStep(
      '4. Represente os 4 elementos',
      'Cada elemento traz uma energia essencial para o altar:\n\n'
          '🌍 Terra (Norte): Cristais, sal, pedras, plantas, pentáculo\n'
          '💧 Água (Oeste): Taça com água, conchas, água lunar\n'
          '🔥 Fogo (Sul): Vela, caldeirão, athame\n'
          '💨 Ar (Leste): Incenso, penas, sinos, varinha\n\n'
          '💡 Dica: Posicione cada elemento na direção cardeal correspondente quando possível.',
    ),
    AltarStep(
      '5. Adicione itens pessoais',
      'Imagens de divindades, fotos de ancestrais, símbolos que fazem sentido para você, '
          'ferramentas mágicas (athame, caldeirão, varinha), livro de sombras.',
    ),
  ],
  itemsTitle: 'O que Usar no Altar',
  items: [
    AltarEmojiItem('🕯️', 'Velas',
        'Representam o elemento Fogo e a luz divina. Use cores correspondentes às suas intenções.'),
    AltarEmojiItem('💎', 'Cristais',
        'Amplificam energia e trazem propriedades específicas (quartzo rosa para amor, ametista para espiritualidade).'),
    AltarEmojiItem('🌿', 'Ervas',
        'Secas ou frescas, cada erva tem correspondências mágicas únicas.'),
    AltarEmojiItem('🔮', 'Objetos simbólicos',
        'Pentáculo, símbolos lunares, runas, tarot, estatuetas de divindades.'),
    AltarEmojiItem('💧', 'Taça com água',
        'Elemento Água, pode ser trocada regularmente ou usada em rituais.'),
    AltarEmojiItem('🧂', 'Sal', 'Purificação e proteção, representa a Terra.'),
    AltarEmojiItem(
        '📿', 'Incenso', 'Elemento Ar, limpa energia e eleva vibrações.'),
    AltarEmojiItem(
        '📖', 'Grimório', 'Seu livro de sombras ou diário de práticas.'),
    AltarEmojiItem('🌙', 'Itens lunares',
        'Representações da lua, água lunar, calendário lunar.'),
    AltarEmojiItem('🪶', 'Penas', 'Elemento Ar, conexão com o divino.'),
  ],
  itemsNote:
      '💡 Lembre-se: Não existe lista obrigatória. Use o que ressoa com você e sua prática.',
  avoidTitle: 'O que Evitar no Altar',
  avoidItems: [
    AltarStep('Itens de energia negativa',
        'Objetos que tragam memórias ruins ou sensações desconfortáveis.'),
    AltarStep('Excesso de objetos',
        'Um altar lotado dispersa a energia. Mantenha organizado e intencional.'),
    AltarStep('Itens emprestados sem permissão',
        'Cada objeto carrega a energia de seu dono.'),
    AltarStep('Lixo ou sujeira',
        'Mantenha seu altar limpo fisicamente e energeticamente.'),
    AltarStep('Objetos alheios à sua prática',
        'Não coloque símbolos de tradições que você não pratica por modismo.'),
    AltarStep('Plantas mortas',
        'Retire folhas secas e plantas mortas regularmente.'),
  ],
  safetyNote:
      'SEGURANÇA: Nunca deixe velas acesas sem supervisão. Mantenha materiais inflamáveis longe das chamas.',
  purifyTitle: 'Como Purificar seu Altar',
  purifyIntro:
      'A purificação remove energias estagnadas ou negativas, renovando o espaço sagrado.',
  purifyMethods: [
    AltarEmojiItem('🔥', 'Defumação',
        'Use alecrim, arruda, sálvia, ou pau santo. Passe a fumaça por todo o altar e objetos com intenção de limpeza.'),
    AltarEmojiItem('💧', 'Água e sal',
        'Borrife água com sal grosso (ou água lunar) pelo espaço. Cuidado com objetos que não podem molhar.'),
    AltarEmojiItem('🔔', 'Som',
        'Use sinos, tigelas tibetanas ou palmas para quebrar energia estagnada.'),
    AltarEmojiItem('🌙', 'Luz da lua',
        'Deixe objetos sob a luz da lua cheia para limpeza energética profunda.'),
    AltarEmojiItem('🧘', 'Visualização',
        'Visualize luz branca ou dourada preenchendo o altar e dissolvendo energias densas.'),
  ],
  purifyFrequency:
      '🌙 Frequência recomendada: A cada lua nova ou cheia, ou quando sentir a energia pesada.',
  maintainTitle: 'Como Manter seu Altar',
  maintainItems: [
    AltarStep('Limpeza física regular',
        'Tire poeira, limpe superfícies, organize objetos. Idealmente na lua minguante.'),
    AltarStep('Troque oferendas',
        'Se você deixa oferendas (flores, alimentos, água), troque antes que estraguem.'),
    AltarStep('Recarregue cristais',
        'Limpe e recarregue cristais regularmente (lua, sol, terra, fumaça).'),
    AltarStep('Atualize conforme as estações',
        'Adapte decorações e elementos sazonais (Sabbats, solstícios, equinócios).'),
    AltarStep('Visite diariamente',
        'Mesmo que brevemente. Acenda uma vela, agradeça, medite. Mantenha a energia viva.'),
    AltarStep('Reorganize quando necessário',
        'Seu altar pode evoluir com você. Remova o que não ressoa mais, adicione o novo.'),
    AltarStep('Proteja energeticamente',
        'Renove proteções regularmente com sal ao redor, visualizações ou sigilos.'),
  ],
  usageTitle: 'Como Utilizar seu Altar',
  usageItems: [
    AltarStep('Meditação e conexão',
        'Sente-se em frente ao altar para meditar, centrar-se e conectar-se com o divino.'),
    AltarStep('Feitiços e rituais',
        'Use como espaço de trabalho mágico. Acenda velas, prepare poções, consagre ferramentas.'),
    AltarStep('Oferendas e agradecimentos',
        'Deixe oferendas para divindades, ancestrais ou espíritos que você honra.'),
    AltarStep('Celebrações sazonais',
        'Decore e celebre Sabbats, luas cheias, equinócios no altar.'),
    AltarStep('Carregamento de objetos',
        'Deixe itens (talismãs, joias, cristais) no altar para carregar com energia.'),
    AltarStep('Divinação',
        'Pratique tarot, runas, pêndulo ou outras formas de divinação no altar.'),
    AltarStep('Ponto focal diário',
        'Comece ou termine o dia no altar, definindo intenções ou refletindo.'),
  ],
  routineTitle: '💚 Sugestão de rotina diária:',
  routineBody: '• Manhã: Acenda uma vela, defina intenção do dia\n'
      '• Tarde: Momento de gratidão ou reflexão breve\n'
      '• Noite: Agradeça pelo dia, apague a vela com reverência',
  finalTitle: 'Considerações Finais',
  finalBody:
      'Seu altar é uma expressão pessoal da sua espiritualidade. Não existe forma "certa" ou "errada" - '
      'o que importa é que ele seja significativo para VOCÊ. '
      '\n\nUm altar simples com três velas e um cristal carregado de intenção é mais poderoso '
      'que um altar elaborado sem conexão emocional. '
      '\n\nPermita que seu altar cresça organicamente, reflita suas mudanças e seja sempre um espaço de paz, '
      'poder e conexão com o sagrado.',
);
