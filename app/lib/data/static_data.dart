// lib/data/static_data.dart
import '../models/crystal.dart';
import '../models/magic_color.dart';

const List<Crystal> defaultCrystals = [
  Crystal(
    id: 'ametista',
    name: 'Ametista',
    intentions: ['proteção', 'intuição', 'calma'],
    description: 'Cristal de proteção espiritual e transmutação.',
    howToUse: 'No altar, debaixo do travesseiro, em meditações.',
  ),
  Crystal(
    id: 'quartzo_rosa',
    name: 'Quartzo Rosa',
    intentions: ['amor próprio', 'autoestima', 'relacionamentos'],
    description: 'Cristal ligado ao coração e ao amor gentil.',
    howToUse: 'No altar, próximo à cama, em rituais de autocuidado.',
  ),
];

const List<MagicColor> defaultMagicColors = [
  MagicColor(
    id: 'roxo',
    name: 'Roxo',
    hex: '#C9A7FF',
    intentions: ['espiritualidade', 'transmutação'],
    description: 'Cor ligada à magia, espiritualidade e transformação.',
  ),
  MagicColor(
    id: 'rosa',
    name: 'Rosa',
    hex: '#F1A7C5',
    intentions: ['amor próprio', 'autocuidado'],
    description: 'Cor de carinho, doçura e acolhimento.',
  ),
  MagicColor(
    id: 'menta',
    name: 'Verde Menta',
    hex: '#A7F0D8',
    intentions: ['cura', 'equilíbrio', 'natureza'],
    description: 'Cor fresca, ligada à cura e à bruxaria verde.',
  ),
];
