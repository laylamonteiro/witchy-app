import '../models/enums.dart';
import 'transit_interpreter_texts.dart';

/// Textos do interpretador de trânsitos — conteúdo em português (idioma-base).
///
/// Mantenha as mesmas chaves/estruturas nos três arquivos
/// (`transit_interpreter_texts_pt/en/es.dart`) — a paridade é verificada em
/// `test/astrology_interpreters_parity_test.dart`.
final TransitInterpreterTexts transitInterpreterTextsPt =
    TransitInterpreterTexts(
  phaseNames: const {
    'newMoon': 'Lua Nova',
    'waxingCrescent': 'Lua Crescente',
    'firstQuarter': 'Quarto Crescente',
    'waxingGibbous': 'Lua Gibosa Crescente',
    'fullMoon': 'Lua Cheia',
    'waningGibbous': 'Lua Gibosa Minguante',
    'lastQuarter': 'Quarto Minguante',
    'waningCrescent': 'Lua Minguante',
  },
  phaseInterpretations: const {
    'newMoon': 'Momento ideal para novos começos e intenções mágicas',
    'waxingCrescent': 'Energia crescente favorece manifestação e crescimento',
    'firstQuarter': 'Ação e movimento são favorecidos',
    'waxingGibbous': 'Refinamento e ajustes antes da culminação',
    'fullMoon': 'Poder máximo para rituais e liberação',
    'waningGibbous': 'Gratidão e colheita dos frutos',
    'lastQuarter': 'Momento de liberação e limpeza',
    'waningCrescent': 'Introspecção e banimento são favorecidos',
  },
  phaseFallback: 'A lua guia suas práticas mágicas',
  moonInSign: (moonSignName, signQualities) =>
      'Com a Lua em $moonSignName, as emoções estão $signQualities',
  energyDescriptions: const {
    EnergyLevel.intense: 'O dia traz energia intensa e transformadora',
    EnergyLevel.challenging:
        'Desafios planetários pedem atenção e trabalho consciente',
    EnergyLevel.moderate: 'O fluxo energético está equilibrado e estável',
    EnergyLevel.harmonious: 'As energias fluem com harmonia e facilidade',
  },
  phasePractices: const {
    'newMoon':
        'Definir intenções, plantar sementes mágicas, trabalho de manifestação',
    'waxingCrescent':
        'Feitiços de atração, crescimento de projetos, magia verde',
    'firstQuarter': 'Rituais de coragem, ação mágica, trabalho com fogo',
    'waxingGibbous': 'Ajuste de feitiços, refinamento de práticas',
    'fullMoon': 'Rituais poderosos, carregamento de ferramentas, água lunar',
    'waningGibbous': 'Gratidão, reconhecimento, oferendas',
    'lastQuarter': 'Banimento, limpeza energética, corte de cordas',
    'waningCrescent': 'Meditação profunda, trabalho de sombra, divinação',
  },
  practiceIntenseDay: 'Aterramento e proteção são essenciais hoje',
  practiceHarmoniousDay:
      'Excelente momento para feitiços complexos e trabalho em grupo',
  phaseKeywords: const {
    'newMoon': ['renovação', 'intenção', 'início'],
    'waxingCrescent': ['crescimento', 'expansão', 'manifestação'],
    'firstQuarter': ['ação', 'movimento', 'decisão'],
    'waxingGibbous': ['refinamento', 'paciência', 'preparação'],
    'fullMoon': ['poder', 'culminação', 'plenitude'],
    'waningGibbous': ['gratidão', 'compartilhamento', 'colheita'],
    'lastQuarter': ['liberação', 'limpeza', 'transformação'],
    'waningCrescent': ['introspecção', 'sabedoria', 'descanso'],
  },
  keywordIntensity: 'intensidade',
  keywordHarmony: 'harmonia',
  transitAspect: (planet1, aspectSymbol, planet2, aspectQuality) =>
      '$planet1 $aspectSymbol $planet2: energia $aspectQuality',
  conjunctionTitle: (transitPlanet, natalPlanet) =>
      'Conjunção $transitPlanet-$natalPlanet',
  conjunctionDescription: (transitPlanet, natalPlanet) =>
      'Este aspecto poderoso une as energias de $transitPlanet e seu '
      '$natalPlanet natal. É momento de integração profunda.',
  conjunctionPractices: const [
    'Meditação focada nestas energias',
    'Ritual de integração e alinhamento',
    'Trabalho com cristais correspondentes',
  ],
  harmoniousTitle: 'Energia Harmoniosa Disponível',
  harmoniousDescription: (transitPlanet, aspectSymbol, natalPlanet) =>
      '$transitPlanet $aspectSymbol seu $natalPlanet natal cria um fluxo '
      'positivo de energia.',
  harmoniousPractices: const [
    'Feitiços de manifestação e atração',
    'Trabalho criativo e inspirado',
    'Conexão com guias espirituais',
  ],
  challengingTitle: 'Desafio para Crescimento',
  challengingDescription: (aspectName, transitPlanet, natalPlanet) =>
      'O aspecto $aspectName entre $transitPlanet e seu $natalPlanet natal '
      'traz lições importantes.',
  challengingPractices: const [
    'Trabalho de sombra e autoconhecimento',
    'Banimento de padrões antigos',
    'Proteção e aterramento',
  ],
  moonSuggestionTitle: (signName) => 'Lua em $signName',
  moonSuggestionDescription: (signName, elementName) =>
      'A Lua transita por $signName, trazendo energias $elementName para '
      'suas emoções e intuição.',
  moonSuggestionPractices: const [
    'Trabalho com água e emoções',
    'Divinação e leitura intuitiva',
    'Conexão com a energia lunar',
  ],
);
