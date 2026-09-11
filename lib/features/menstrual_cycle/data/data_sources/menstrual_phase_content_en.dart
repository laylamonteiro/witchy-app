import '../../domain/internal_season.dart';
import '../models/menstrual_season_content.dart';

/// Conteúdo das Estações Internas — inglês.
///
/// Mesma ordem, mesma quantidade e mesmas chaves do arquivo em português.
const List<MenstrualSeasonContent> menstrualSeasonsEn = [
  MenstrualSeasonContent(
    season: InternalSeason.winter,
    title: 'Winter',
    invitation:
        'A time for pause and shelter, if that is what the day asks for. '
        'Attention goes to whatever needs care — yours first. Nothing has to '
        'be produced for the day to count.',
    practices: [
      'Leave one thing on the week for later, chosen by you.',
      'A warm corner: a blanket, the tea you like, low light.',
      'Light a candle and stay with it for as long as you want.',
    ],
    writingQuestion: 'What would you like to welcome today?',
    correspondences: [
      MenstrualCorrespondence(key: 'obsidian', label: 'Black Obsidian'),
      MenstrualCorrespondence(key: 'selenite', label: 'Selenite'),
      MenstrualCorrespondence(key: 'hecate', label: 'Hecate'),
    ],
  ),
  MenstrualSeasonContent(
    season: InternalSeason.spring,
    title: 'Spring',
    invitation:
        'Curiosity and small beginnings, if they make sense. Nothing here '
        'asks for a whole plan: a first gesture is enough, and it can be tiny.',
    practices: [
      'Write a short intention, a single line.',
      'Water a plant, or plant any seed at all.',
      'Pick something up again, starting from the easiest part.',
    ],
    writingQuestion: 'Which intention deserves a first gesture?',
    correspondences: [
      MenstrualCorrespondence(key: 'citrine', label: 'Citrine'),
      MenstrualCorrespondence(key: 'green', label: 'Green'),
      MenstrualCorrespondence(key: 'brigid', label: 'Brigid'),
    ],
  ),
  MenstrualSeasonContent(
    season: InternalSeason.summer,
    title: 'Summer',
    invitation:
        'Expression and company as possibilities — not as a task. If today '
        'there is a wish to show up, to speak, to be with someone, there is '
        'room for it. If there is not, that is right too.',
    practices: [
      'Send a message to whoever you kept remembering.',
      'Set the altar with whatever looks beautiful nearby.',
      'Sing, dance, or say out loud something you like.',
    ],
    writingQuestion: 'What do you want to share or celebrate?',
    correspondences: [
      MenstrualCorrespondence(key: 'roseQuartz', label: 'Rose Quartz'),
      MenstrualCorrespondence(key: 'carnelian', label: 'Carnelian'),
      MenstrualCorrespondence(key: 'aphrodite', label: 'Aphrodite'),
    ],
  ),
  MenstrualSeasonContent(
    season: InternalSeason.autumn,
    title: 'Autumn',
    invitation:
        'Review and limits: looking at what got heavy and choosing what to '
        'let go. Letting go here is a choice, not a loss — and it can be one '
        'small thing.',
    practices: [
      'Move out of the way one thing that no longer serves.',
      'Say no to a commitment you accepted without meaning to.',
      'Read what you wrote a month ago, correcting nothing.',
    ],
    writingQuestion: 'What could become lighter for you?',
    correspondences: [
      MenstrualCorrespondence(key: 'amethyst', label: 'Amethyst'),
      MenstrualCorrespondence(key: 'blackTourmaline', label: 'Black Tourmaline'),
      MenstrualCorrespondence(key: 'morrigan', label: 'Morrigan'),
    ],
  ),
];
