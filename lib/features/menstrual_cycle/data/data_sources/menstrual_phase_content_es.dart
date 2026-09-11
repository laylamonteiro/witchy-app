import '../../domain/internal_season.dart';
import '../models/menstrual_season_content.dart';

/// Conteúdo das Estações Internas — espanhol.
///
/// Mesma ordem, mesma quantidade e mesmas chaves do arquivo em português.
const List<MenstrualSeasonContent> menstrualSeasonsEs = [
  MenstrualSeasonContent(
    season: InternalSeason.winter,
    title: 'Invierno',
    invitation:
        'Un tiempo de pausa y abrigo, si es lo que pide el día. La atención '
        'va a lo que necesita cuidado — el tuyo, antes que el resto. No hace '
        'falta producir nada para que el día valga.',
    practices: [
      'Dejar para después una cosa de la semana, elegida por ti.',
      'Un rincón cálido: una manta, el té que te gusta, luz baja.',
      'Encender una vela y quedarte con ella el tiempo que quieras.',
    ],
    writingQuestion: '¿Qué te gustaría acoger hoy?',
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
        'Curiosidad y comienzos pequeños, si tienen sentido. Nada aquí pide '
        'un plan entero: un primer gesto basta, y puede ser mínimo.',
    practices: [
      'Escribir una intención corta, de una sola línea.',
      'Regar una planta, o plantar una semilla cualquiera.',
      'Retomar algo detenido, por la parte más fácil.',
    ],
    writingQuestion: '¿Qué intención merece un primer gesto?',
    correspondences: [
      MenstrualCorrespondence(key: 'citrine', label: 'Citrino'),
      MenstrualCorrespondence(key: 'green', label: 'Verde'),
      MenstrualCorrespondence(key: 'brigid', label: 'Brigid'),
    ],
  ),
  MenstrualSeasonContent(
    season: InternalSeason.summer,
    title: 'Verano',
    invitation:
        'Expresión y encuentro como posibilidades — no como tarea. Si hoy hay '
        'ganas de aparecer, de hablar, de estar con alguien, hay lugar para '
        'eso. Si no las hay, también está bien.',
    practices: [
      'Mandar un mensaje a quien venías recordando.',
      'Arreglar el altar con lo que haya bonito cerca.',
      'Cantar, bailar o decir en voz alta algo que te guste.',
    ],
    writingQuestion: '¿Qué quieres compartir o celebrar?',
    correspondences: [
      MenstrualCorrespondence(key: 'roseQuartz', label: 'Cuarzo Rosa'),
      MenstrualCorrespondence(key: 'carnelian', label: 'Cornalina'),
      MenstrualCorrespondence(key: 'aphrodite', label: 'Afrodita'),
    ],
  ),
  MenstrualSeasonContent(
    season: InternalSeason.autumn,
    title: 'Otoño',
    invitation:
        'Revisión y límites: mirar lo que quedó pesado y elegir qué dejar ir. '
        'Dejar ir aquí es elección, no pérdida — y puede ser una sola cosa, '
        'bien pequeña.',
    practices: [
      'Sacar del medio una cosa que ya no sirve.',
      'Decir que no a un compromiso que aceptaste sin querer.',
      'Leer lo que escribiste hace un mes, sin corregir nada.',
    ],
    writingQuestion: '¿Qué puede volverse más liviano para ti?',
    correspondences: [
      MenstrualCorrespondence(key: 'amethyst', label: 'Amatista'),
      MenstrualCorrespondence(key: 'blackTourmaline', label: 'Turmalina Negra'),
      MenstrualCorrespondence(key: 'morrigan', label: 'Morrigan'),
    ],
  ),
];
