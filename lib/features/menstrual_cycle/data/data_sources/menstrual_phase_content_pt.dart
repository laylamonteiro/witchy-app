import '../../domain/internal_season.dart';
import '../models/menstrual_season_content.dart';

/// Conteúdo das Estações Internas — português (idioma-base).
///
/// Mantenha a MESMA ORDEM, a MESMA QUANTIDADE e as MESMAS CHAVES de
/// correspondência nos três arquivos (`menstrual_phase_content_pt/en/es.dart`)
/// — a paridade é verificada em `test/menstrual_season_content_parity_test.dart`.
/// Só a prosa e o nome do verbete mudam entre idiomas.
///
/// O que este texto NÃO faz: prever humor, afirmar fase do corpo, tratar dor,
/// fluxo ou hormônio, ou sugerir ingestão de qualquer coisa. Estação é
/// vocabulário escolhido, não diagnóstico.
const List<MenstrualSeasonContent> menstrualSeasonsPt = [
  MenstrualSeasonContent(
    season: InternalSeason.winter,
    title: 'Inverno',
    invitation:
        'Um tempo de pausa e abrigo, se for isso que o dia pede. Aqui a '
        'atenção vai para o que precisa de cuidado — o seu, antes do resto. '
        'Não é preciso produzir nada para que o dia valha.',
    practices: [
      'Deixar uma coisa da semana para depois, escolhida por você.',
      'Um canto quente: manta, chá que você gosta, luz baixa.',
      'Acender uma vela e ficar com ela o tempo que quiser.',
    ],
    writingQuestion: 'O que você gostaria de acolher hoje?',
    correspondences: [
      MenstrualCorrespondence(key: 'obsidian', label: 'Obsidiana Negra'),
      MenstrualCorrespondence(key: 'selenite', label: 'Selenita'),
      MenstrualCorrespondence(key: 'hecate', label: 'Hécate'),
    ],
  ),
  MenstrualSeasonContent(
    season: InternalSeason.spring,
    title: 'Primavera',
    invitation:
        'Curiosidade e começos pequenos, se fizerem sentido. Nada aqui pede '
        'um plano inteiro: um primeiro gesto basta, e ele pode ser mínimo.',
    practices: [
      'Escrever uma intenção curta, de uma linha só.',
      'Regar uma planta, ou plantar uma semente qualquer.',
      'Recomeçar algo parado, pelo pedaço mais fácil.',
    ],
    writingQuestion: 'Que intenção merece um primeiro gesto?',
    correspondences: [
      MenstrualCorrespondence(key: 'citrine', label: 'Citrino'),
      MenstrualCorrespondence(key: 'green', label: 'Verde'),
      MenstrualCorrespondence(key: 'brigid', label: 'Brigid'),
    ],
  ),
  MenstrualSeasonContent(
    season: InternalSeason.summer,
    title: 'Verão',
    invitation:
        'Expressão e encontro como possibilidades — não como tarefa. Se hoje '
        'houver vontade de aparecer, de falar, de estar com alguém, há espaço '
        'para isso. Se não houver, também está certo.',
    practices: [
      'Mandar uma mensagem para quem você andava lembrando.',
      'Arrumar o altar com o que estiver bonito por perto.',
      'Cantar, dançar ou dizer em voz alta algo que você gosta.',
    ],
    writingQuestion: 'O que você quer compartilhar ou celebrar?',
    correspondences: [
      MenstrualCorrespondence(key: 'roseQuartz', label: 'Quartzo Rosa'),
      MenstrualCorrespondence(key: 'carnelian', label: 'Cornalina'),
      MenstrualCorrespondence(key: 'aphrodite', label: 'Afrodite'),
    ],
  ),
  MenstrualSeasonContent(
    season: InternalSeason.autumn,
    title: 'Outono',
    invitation:
        'Revisão e limites: olhar o que ficou pesado e escolher o que deixar '
        'ir. Deixar ir aqui é escolha, não perda — e pode ser uma coisa só, '
        'bem pequena.',
    practices: [
      'Tirar do lugar uma coisa que não serve mais.',
      'Dizer não a um compromisso que você aceitou sem querer.',
      'Ler o que você escreveu há um mês, sem corrigir nada.',
    ],
    writingQuestion: 'O que pode ficar mais leve para você?',
    correspondences: [
      MenstrualCorrespondence(key: 'amethyst', label: 'Ametista'),
      MenstrualCorrespondence(key: 'blackTourmaline', label: 'Turmalina Negra'),
      MenstrualCorrespondence(key: 'morrigan', label: 'Morrigan'),
    ],
  ),
];
